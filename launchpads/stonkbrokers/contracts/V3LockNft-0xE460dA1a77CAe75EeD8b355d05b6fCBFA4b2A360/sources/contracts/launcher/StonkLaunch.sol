// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "../WETH9.sol";
import "../fees/StonkLpFeeSplitter.sol";
import "../staking/StonkYieldStakingVault.sol";
import "../uniswap/INonfungiblePositionManagerMinimal.sol";

/// @notice One meme coin launch instance:
/// - Holds sale supply and sells for ETH at a fixed price.
/// - On finalize, wraps ETH -> WETH, creates/initializes pool, mints full-range LP,
///   and wires up fee splitter + staking vault.
contract StonkLaunch is ReentrancyGuard {
    using SafeERC20 for IERC20;
    using Math for uint256;

    int24 private constant MIN_TICK = -887272;
    int24 private constant MAX_TICK = 887272;

    address public immutable factory;
    address public immutable treasury;
    address public immutable registry;
    INonfungiblePositionManagerMinimal public immutable positionManager;
    WETH9 public immutable weth;

    IERC20 public immutable memeToken;
    string public metadataURI;
    string public imageURI;

    uint256 public immutable priceWeiPerToken; // 18-decimal token
    uint256 public immutable saleSupply;
    uint256 public immutable liquiditySupply;
    uint256 public sold;
    bool public finalized;

    // Post-finalize
    address public pool;
    uint24 public poolFee;
    uint256 public lpTokenId;
    address public feeSplitter;
    address public stakingVault;

    event Bought(address indexed buyer, uint256 ethIn, uint256 tokensOut);
    event Finalized(address indexed pool, uint256 lpTokenId, address feeSplitter, address stakingVault);
    event EthSwept(address indexed to, uint256 amountWei);

    error SoldOut();
    error FinalizedAlready();
    error NotFactory();
    error BadSqrtPrice();

    constructor(
        address _factory,
        address _treasury,
        address _registry,
        address _positionManager,
        address _weth,
        address _memeToken,
        uint256 _priceWeiPerToken,
        uint256 _saleSupply,
        uint256 _liquiditySupply,
        string memory _metadataURI,
        string memory _imageURI
    ) {
        require(_factory != address(0), "factory=0");
        require(_treasury != address(0), "treasury=0");
        require(_registry != address(0), "registry=0");
        require(_positionManager != address(0), "pm=0");
        require(_weth != address(0), "weth=0");
        require(_memeToken != address(0), "token=0");
        require(_priceWeiPerToken > 0, "price=0");
        require(_saleSupply + _liquiditySupply > 0, "supply=0");

        factory = _factory;
        treasury = _treasury;
        registry = _registry;
        positionManager = INonfungiblePositionManagerMinimal(_positionManager);
        weth = WETH9(payable(_weth));
        memeToken = IERC20(_memeToken);
        priceWeiPerToken = _priceWeiPerToken;
        saleSupply = _saleSupply;
        liquiditySupply = _liquiditySupply;
        metadataURI = _metadataURI;
        imageURI = _imageURI;
    }

    receive() external payable {
        buy();
    }

    function remainingForSale() public view returns (uint256) {
        if (sold >= saleSupply) return 0;
        return saleSupply - sold;
    }

    function buy() public payable nonReentrant {
        if (finalized) revert FinalizedAlready();
        uint256 remaining = remainingForSale();
        if (remaining == 0) revert SoldOut();

        // Use mulDiv to avoid overflow and make rounding explicit.
        uint256 tokensWanted = Math.mulDiv(msg.value, 1e18, priceWeiPerToken);
        require(tokensWanted > 0, "too small");

        uint256 tokensOut = tokensWanted > remaining ? remaining : tokensWanted;
        // Round *up* to avoid under-charging due to double-flooring:
        // tokensOut = floor(msg.value*1e18/price) then ethRequired must be ceil(tokensOut*price/1e18).
        uint256 ethRequired = Math.mulDiv(tokensOut, priceWeiPerToken, 1e18, Math.Rounding.Ceil);
        uint256 refund = msg.value - ethRequired;

        sold += tokensOut;
        memeToken.safeTransfer(msg.sender, tokensOut);

        if (refund > 0) {
            (bool ok, ) = payable(msg.sender).call{value: refund}("");
            require(ok, "refund failed");
        }
        emit Bought(msg.sender, ethRequired, tokensOut);
    }

    /// @notice Finalize launch: creates pool and mints a full-range LP position.
    /// @param sqrtPriceX96 initial price for pool initialization.
    /// @param fee Uniswap v3 fee tier (500, 3000, 10000).
    function finalize(uint160 sqrtPriceX96, uint24 fee) external payable nonReentrant {
        if (msg.sender != factory) revert NotFactory();
        if (finalized) revert FinalizedAlready();
        if (sqrtPriceX96 == 0) revert BadSqrtPrice();
        poolFee = fee;
        finalized = true;

        // Wrap all ETH raised into WETH (including any ETH provided during finalize).
        uint256 ethBal = address(this).balance;
        if (ethBal > 0) {
            weth.deposit{value: ethBal}();
        }

        // Create pool (token ordering is enforced by PM args).
        address tokenA = address(memeToken);
        address tokenB = address(weth);
        address t0 = tokenA < tokenB ? tokenA : tokenB;
        address t1 = tokenA < tokenB ? tokenB : tokenA;

        pool = positionManager.createAndInitializePoolIfNecessary(t0, t1, fee, sqrtPriceX96);

        // Deploy staking vault + fee splitter and wire them together.
        StonkYieldStakingVault vault = new StonkYieldStakingVault(address(memeToken), t0, t1);
        StonkLpFeeSplitter splitter = new StonkLpFeeSplitter(address(positionManager), treasury, address(vault));
        vault.setFeeSplitter(address(splitter));
        stakingVault = address(vault);
        feeSplitter = address(splitter);

        // Approve tokens to position manager.
        IERC20(t0).forceApprove(address(positionManager), type(uint256).max);
        IERC20(t1).forceApprove(address(positionManager), type(uint256).max);

        (int24 tickLower, int24 tickUpper) = _fullRangeTicks(fee);

        uint256 memeRemaining = memeToken.balanceOf(address(this));
        uint256 wethRemaining = IERC20(address(weth)).balanceOf(address(this));

        uint256 amount0Desired = t0 == address(memeToken) ? memeRemaining : wethRemaining;
        uint256 amount1Desired = t1 == address(memeToken) ? memeRemaining : wethRemaining;

        (uint256 tokenId,, , ) = positionManager.mint(
            INonfungiblePositionManagerMinimal.MintParams({
                token0: t0,
                token1: t1,
                fee: fee,
                tickLower: tickLower,
                tickUpper: tickUpper,
                amount0Desired: amount0Desired,
                amount1Desired: amount1Desired,
                amount0Min: 0,
                amount1Min: 0,
                recipient: address(this),
                deadline: block.timestamp + 30 minutes
            })
        );

        // Transfer LP position NFT into the splitter.
        positionManager.safeTransferFrom(address(this), address(splitter), tokenId);
        splitter.initializePosition(tokenId, t0, t1);

        lpTokenId = tokenId;

        // Send any leftovers to treasury (dust, unused amounts).
        uint256 left0 = IERC20(t0).balanceOf(address(this));
        uint256 left1 = IERC20(t1).balanceOf(address(this));
        if (left0 > 0) IERC20(t0).safeTransfer(treasury, left0);
        if (left1 > 0) IERC20(t1).safeTransfer(treasury, left1);

        emit Finalized(pool, tokenId, address(splitter), address(vault));
    }

    /// @notice Rescue ETH that may be forced into the contract (e.g. via selfdestruct).
    /// This ETH cannot be wrapped once finalized since finalize is one-shot.
    function sweepEth(address to) external nonReentrant {
        require(msg.sender == factory || msg.sender == treasury, "not auth");
        require(to != address(0), "to=0");
        uint256 bal = address(this).balance;
        require(bal > 0, "no eth");
        (bool ok, ) = payable(to).call{value: bal}("");
        require(ok, "sweep failed");
        emit EthSwept(to, bal);
    }

    /// @dev Full-range ticks for the given fee tier.
    /// tickLower = smallest aligned tick >= MIN_TICK (round toward zero for negative).
    /// tickUpper = largest aligned tick <= MAX_TICK (round toward zero for positive).
    function _fullRangeTicks(uint24 fee) internal pure returns (int24 lower, int24 upper) {
        int24 spacing;
        if (fee == 500) spacing = 10;
        else if (fee == 3000) spacing = 60;
        else if (fee == 10000) spacing = 200;
        else revert("fee tier");

        // Solidity 0.8 int division rounds toward zero, which:
        //   - for MIN_TICK (negative): rounds UP toward zero → valid (>= MIN_TICK)
        //   - for MAX_TICK (positive): rounds DOWN toward zero → valid (<= MAX_TICK)
        lower = (MIN_TICK / spacing) * spacing;
        upper = (MAX_TICK / spacing) * spacing;
    }
}

