// SPDX-License-Identifier: MIT
pragma solidity ^0.8.36;

import {Ownable2Step, Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {
    Currency,
    PoolKey,
    PoolId,
    SwapParams,
    BalanceDelta,
    BalanceDeltaLib,
    IPoolManager,
    IUnlockCallback,
    IHooks,
    IPositionManager,
    IPermit2,
    IStateView,
    PoolIdLibrary
} from "./interfaces/IV4.sol";
import {TickMath} from "./libraries/TickMath.sol";
import {LiquidityMath} from "./libraries/LiquidityMath.sol";
import {LaunchToken} from "./LaunchToken.sol";
import {LaunchTokenDeployer} from "./LaunchTokenDeployer.sol";

interface IRwaHook {
    function registerToken(address token, uint16 buybackBurnBps, uint16 buyTaxBps, uint16 sellTaxBps) external;
}

interface IPoolManagerErc20 {
    function take(Currency currency, address to, uint256 amount) external;
    function settle() external payable returns (uint256);
    function sync(Currency currency) external;
}

/// @notice Launches meme tokens paired against ERC-20 stock tokens (TSLA, NVDA, …).
/// Creators supply stock tokens directly — no ETH→stock swap, no pool-depth slippage.
/// Identical pool/hook/graduation mechanics to LaunchFactory; only the initial-buy
/// settlement path differs (ERC-20 transferFrom instead of msg.value).
contract RwaFactory is Ownable2Step, ReentrancyGuard, IUnlockCallback {
    using SafeERC20 for IERC20;
    using BalanceDeltaLib for BalanceDelta;
    using PoolIdLibrary for PoolKey;

    uint8 public constant VERSION = 1;

    address public immutable poolManager;
    address public immutable positionManager;
    address private immutable tokenDeployer;
    address public constant PERMIT2      = 0x000000000022D473030F116dDEE9F6B43aC78BA3;
    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    uint8 private constant ACT_MINT_POSITION = 0x02;
    uint8 private constant ACT_SETTLE_PAIR   = 0x0d;
    uint8 private constant ACT_SWEEP         = 0x13;

    uint160 private constant MIN_SQRT_PRICE_LIMIT = 4295128740;
    uint160 private constant MAX_SQRT_PRICE_LIMIT = 1461446703485210103287273052203988822378723970341;

    uint24  public constant POOL_FEE     = 0;
    int24   public constant TICK_SPACING = 200;
    int24   private constant MIN_USABLE_TICK = -887200;
    int24   private constant MAX_USABLE_TICK =  887200;

    uint256 public constant SUPPLY = 1_000_000_000 ether;
    uint256 public constant BPS_DENOM = 10_000;

    uint256 public constant MAX_LAUNCH_FEE            = 0.001 ether;
    // Graduation threshold is denominated in stock-token units (18 dec assumed).
    uint256 public constant MIN_GRADUATION_THRESHOLD  = 0.001 ether;   // 0.001 stock tokens
    uint256 public constant MAX_GRADUATION_THRESHOLD  = 100_000 ether; // 100,000 stock tokens
    int24   public constant MIN_INITIAL_TICK = -887200;
    int24   public constant MAX_INITIAL_TICK = -200;

    address public treasury;
    address public hook;
    address public stateView;
    uint256 public launchFee;
    int24   public initialTick = -204000;
    bool    public launchEnabled = true;

    // Identical struct to LaunchFactory.LaunchedToken so the shared hook interface
    // (ILaunchFactory) and the indexer ABI work without changes.
    struct LaunchedToken {
        address deployer;
        uint256 positionId;
        int24   tickLower;
        int24   tickUpper;
        uint256 graduationThreshold;
        bool    exists;
        bool    graduated;
        address quoteToken;  // stock token address
        bool    tokenIsZero;
    }

    mapping(address => LaunchedToken) public launchedTokens;
    mapping(address => address)       public tokenCreator;
    mapping(address => int256)        public netPoolQuote;

    struct LaunchParams {
        string  name;
        string  symbol;
        string  metadataURI;
        string  image;
        string  description;
        LaunchToken.Socials socials;
        bytes32 salt;
        address quoteToken;          // stock ERC-20 (TSLA, NVDA, …)
        uint256 graduationThreshold; // in stock-token units
        uint256 deadline;
        uint128 minLiquidity;
        uint16  buybackBurnBps;
        uint16  buyTaxBps;
        uint16  sellTaxBps;
    }

    // Same event shape as LaunchFactory so the indexer handler is reused unchanged.
    event TokenLaunched(
        address indexed token,
        address indexed deployer,
        bytes32 indexed poolId,
        uint256 positionId,
        uint256 initialBuyAmount, // stock tokens spent (0 if no initial buy)
        uint16  buybackBurnBps
    );
    event Graduated(address indexed token, uint256 pairedQuote, uint256 threshold);
    event LaunchFeeUpdated(uint256 fee);
    event TreasuryUpdated(address indexed treasury);
    event HookUpdated(address indexed hook);
    event StateViewUpdated(address indexed stateView);
    event InitialTickUpdated(int24 tick);
    event LaunchEnabledUpdated(bool enabled);

    error InsufficientLaunchFee();
    error FeeTransferFailed();
    error TokenDeployFailed();
    error ZeroAddress();
    error TokenNotFound();
    error NotHook();
    error NotPoolManager();
    error LaunchFeeTooHigh();
    error GraduationThresholdTooLow();
    error GraduationThresholdTooHigh();
    error InitialTickOutOfRange();
    error HookAlreadySet();
    error HookNotSet();
    error SlippageTooHigh();
    error LaunchDisabled();
    error TaxAllocationTooHigh();

    constructor(
        address poolManager_,
        address positionManager_,
        address treasury_,
        uint256 launchFee_
    ) Ownable(msg.sender) {
        if (poolManager_ == address(0) || positionManager_ == address(0) || treasury_ == address(0)) {
            revert ZeroAddress();
        }
        poolManager   = poolManager_;
        positionManager = positionManager_;
        treasury      = treasury_;
        launchFee     = launchFee_;
        tokenDeployer = address(new LaunchTokenDeployer());
    }

    // ── Public launch function ───────────────────────────────────────────────

    /// @notice Launch a meme token paired against a stock ERC-20.
    /// @param p          Launch parameters (name, ticker, quote token, graduation threshold, …).
    /// @param stockAmount Stock tokens to spend on the creator initial buy. Pass 0 for no buy.
    ///                    Caller must approve this contract for at least stockAmount of p.quoteToken.
    /// msg.value must equal launchFee exactly (no ETH goes toward the swap).
    function launchWithStockBuy(
        LaunchParams calldata p,
        uint128 stockAmount
    ) external payable nonReentrant returns (address token) {
        if (!launchEnabled)                                    revert LaunchDisabled();
        if (p.quoteToken == address(0))                        revert ZeroAddress();
        if (msg.value != launchFee)                            revert InsufficientLaunchFee();
        if (p.graduationThreshold < MIN_GRADUATION_THRESHOLD)  revert GraduationThresholdTooLow();
        if (p.graduationThreshold > MAX_GRADUATION_THRESHOLD)  revert GraduationThresholdTooHigh();
        if (uint256(p.buybackBurnBps) > BPS_DENOM)             revert TaxAllocationTooHigh();

        if (stockAmount > 0) {
            IERC20(p.quoteToken).safeTransferFrom(msg.sender, address(this), stockAmount);
        }

        return _launch(p, stockAmount);
    }

    // ── Internal launch logic ────────────────────────────────────────────────

    function _launch(LaunchParams calldata p, uint128 stockAmount) private returns (address token) {
        if (hook == address(0)) revert HookNotSet();

        token = _deployToken(p);

        bool    tokenIsZero_ = token < p.quoteToken;
        address rawC0 = tokenIsZero_ ? token       : p.quoteToken;
        address rawC1 = tokenIsZero_ ? p.quoteToken : token;

        PoolKey memory poolKey = PoolKey({
            currency0: Currency.wrap(rawC0),
            currency1: Currency.wrap(rawC1),
            fee:       POOL_FEE,
            tickSpacing: TICK_SPACING,
            hooks:     IHooks(hook)
        });
        bytes32 poolId = PoolId.unwrap(poolKey.toId());

        int24   poolStartTick = tokenIsZero_ ? initialTick : -initialTick;
        uint160 sqrtPriceX96  = TickMath.getSqrtRatioAtTick(poolStartTick);
        IPoolManager(poolManager).initialize(poolKey, sqrtPriceX96);

        (int24 tickLower, int24 tickUpper, uint128 liquidity) =
            _computeRangeAndLiquidity(tokenIsZero_, poolStartTick);
        if (liquidity < p.minLiquidity) revert SlippageTooHigh();

        uint256 lpTokenId = IPositionManager(positionManager).nextTokenId();

        launchedTokens[token] = LaunchedToken({
            deployer:            msg.sender,
            positionId:          lpTokenId,
            tickLower:           tickLower,
            tickUpper:           tickUpper,
            graduationThreshold: p.graduationThreshold,
            exists:              true,
            graduated:           false,
            quoteToken:          p.quoteToken,
            tokenIsZero:         tokenIsZero_
        });
        tokenCreator[token] = msg.sender;

        _mintAndBurnLiquidity(poolKey, tickLower, tickUpper, liquidity, tokenIsZero_, token, p.deadline);

        IRwaHook(hook).registerToken(token, p.buybackBurnBps, p.buyTaxBps, p.sellTaxBps);

        emit TokenLaunched(token, msg.sender, poolId, lpTokenId, uint256(stockAmount), p.buybackBurnBps);

        if (stockAmount > 0) {
            _executeBuy(poolKey, stockAmount, p.quoteToken, tokenIsZero_, msg.sender);
        }

        _forwardLaunchFee();
    }

    function _computeRangeAndLiquidity(bool tokenIsZero_, int24 poolStartTick)
        private pure
        returns (int24 tickLower, int24 tickUpper, uint128 liquidity)
    {
        if (tokenIsZero_) {
            tickLower = poolStartTick;
            tickUpper = MAX_USABLE_TICK;
            uint160 sqrtA = TickMath.getSqrtRatioAtTick(tickLower);
            uint160 sqrtB = TickMath.getSqrtRatioAtTick(tickUpper);
            liquidity = LiquidityMath.getLiquidityForAmount0(sqrtA, sqrtB, SUPPLY);
        } else {
            tickLower = MIN_USABLE_TICK;
            tickUpper = poolStartTick;
            uint160 sqrtA = TickMath.getSqrtRatioAtTick(tickLower);
            uint160 sqrtB = TickMath.getSqrtRatioAtTick(tickUpper);
            liquidity = LiquidityMath.getLiquidityForAmount1(sqrtA, sqrtB, SUPPLY);
        }
    }

    function _mintAndBurnLiquidity(
        PoolKey memory poolKey,
        int24 tickLower,
        int24 tickUpper,
        uint128 liquidity,
        bool tokenIsZero_,
        address token,
        uint256 deadline
    ) private {
        IERC20(token).forceApprove(PERMIT2, SUPPLY);
        IPermit2(PERMIT2).approve(token, positionManager, uint160(SUPPLY), type(uint48).max);

        bytes memory actions = abi.encodePacked(ACT_MINT_POSITION, ACT_SETTLE_PAIR, ACT_SWEEP);
        bytes[] memory mintParams = new bytes[](3);
        mintParams[0] = abi.encode(
            poolKey, tickLower, tickUpper, uint256(liquidity),
            tokenIsZero_ ? uint128(SUPPLY) : uint128(0),
            tokenIsZero_ ? uint128(0)      : uint128(SUPPLY),
            BURN_ADDRESS, bytes("")
        );
        mintParams[1] = abi.encode(poolKey.currency0, poolKey.currency1);
        mintParams[2] = abi.encode(poolKey.currency0, address(this));

        IPositionManager(positionManager).modifyLiquidities(abi.encode(actions, mintParams), deadline);

        IERC20(token).forceApprove(PERMIT2, 0);
        uint256 dust = IERC20(token).balanceOf(address(this));
        if (dust > 0) IERC20(token).safeTransfer(BURN_ADDRESS, dust);
    }

    // ── ERC-20 initial buy via PoolManager unlock ────────────────────────────

    struct BuyCallbackData {
        PoolKey poolKey;
        uint128 stockAmount;
        address stockToken;
        bool    tokenIsZero;
        address recipient;
    }

    function _executeBuy(
        PoolKey memory poolKey,
        uint128 stockAmount,
        address stockToken,
        bool tokenIsZero_,
        address recipient
    ) internal {
        IPoolManager(poolManager).unlock(abi.encode(BuyCallbackData({
            poolKey:     poolKey,
            stockAmount: stockAmount,
            stockToken:  stockToken,
            tokenIsZero: tokenIsZero_,
            recipient:   recipient
        })));
    }

    function unlockCallback(bytes calldata data) external override returns (bytes memory) {
        if (msg.sender != poolManager) revert NotPoolManager();

        BuyCallbackData memory d = abi.decode(data, (BuyCallbackData));

        // token=c0 → stock=c1 → swap direction is NOT zeroForOne (c1 stock comes in)
        // token=c1 → stock=c0 → swap direction IS zeroForOne (c0 stock comes in)
        bool    zeroForOne = !d.tokenIsZero;
        uint160 priceLimit = zeroForOne ? MIN_SQRT_PRICE_LIMIT : MAX_SQRT_PRICE_LIMIT;

        BalanceDelta delta = IPoolManager(poolManager).swap(
            d.poolKey,
            SwapParams({
                zeroForOne:        zeroForOne,
                amountSpecified:   -int256(uint256(d.stockAmount)),
                sqrtPriceLimitX96: priceLimit
            }),
            ""
        );

        int128  quoteDelta = d.tokenIsZero ? delta.amount1() : delta.amount0();
        int128  tokenDelta = d.tokenIsZero ? delta.amount0() : delta.amount1();
        uint256 stockOwed  = uint256(uint128(-quoteDelta));
        uint256 tokensOut  = tokenDelta > 0 ? uint256(uint128(tokenDelta)) : 0;

        // Settle stock via ERC-20 (sync → transfer → settle)
        Currency stockCurrency = d.tokenIsZero ? d.poolKey.currency1 : d.poolKey.currency0;
        IPoolManagerErc20(poolManager).sync(stockCurrency);
        IERC20(d.stockToken).safeTransfer(poolManager, stockOwed);
        IPoolManagerErc20(poolManager).settle();

        // Deliver meme tokens to creator
        if (tokensOut > 0) {
            Currency tokenCurrency = d.tokenIsZero ? d.poolKey.currency0 : d.poolKey.currency1;
            IPoolManagerErc20(poolManager).take(tokenCurrency, d.recipient, tokensOut);
        }

        // Return any unspent stock directly (ERC-20 transfer, no ETH reentrancy risk)
        uint256 refund = uint256(d.stockAmount) - stockOwed;
        if (refund > 0) {
            IERC20(d.stockToken).safeTransfer(d.recipient, refund);
        }

        return "";
    }

    // ── Hook callback: swap accounting ───────────────────────────────────────

    function recordSwap(address token, bool isBuy, uint256 quoteAmount) external {
        if (msg.sender != hook) revert NotHook();
        if (!launchedTokens[token].exists) return;

        int256 prev  = netPoolQuote[token];
        int256 delta = isBuy ? int256(quoteAmount) : -int256(quoteAmount);
        int256 next  = prev + delta;
        netPoolQuote[token] = next;

        uint256 threshold = launchedTokens[token].graduationThreshold;
        if (threshold > 0 && prev < int256(threshold) && next >= int256(threshold)) {
            launchedTokens[token].graduated = true;
            emit Graduated(token, uint256(next), threshold);
        }
    }

    // ── View functions ───────────────────────────────────────────────────────

    function graduationStatus(address token)
        external view
        returns (uint256 pairedQuote, uint256 threshold, bool graduated)
    {
        LaunchedToken storage lt = launchedTokens[token];
        if (!lt.exists) revert TokenNotFound();
        threshold = lt.graduationThreshold;

        if (stateView != address(0)) {
            pairedQuote = _poolQuoteFromStateView(token, lt);
        } else {
            int256 net = netPoolQuote[token];
            pairedQuote = net > 0 ? uint256(net) : 0;
        }
        graduated = lt.graduated || (threshold > 0 && pairedQuote >= threshold);
    }

    function _poolQuoteFromStateView(address token, LaunchedToken storage lt) private view returns (uint256) {
        address rawC0 = lt.tokenIsZero ? token : lt.quoteToken;
        address rawC1 = lt.tokenIsZero ? lt.quoteToken : token;
        PoolKey memory poolKey = PoolKey({
            currency0:   Currency.wrap(rawC0),
            currency1:   Currency.wrap(rawC1),
            fee:         POOL_FEE,
            tickSpacing: TICK_SPACING,
            hooks:       IHooks(hook)
        });
        PoolId poolId = poolKey.toId();

        (uint160 sqrtPriceX96,,,) = IStateView(stateView).getSlot0(poolId);
        uint128 liq = IStateView(stateView).getLiquidity(poolId);
        if (sqrtPriceX96 == 0 || liq == 0) return 0;

        uint160 sqrtA = TickMath.getSqrtRatioAtTick(lt.tickLower);
        uint160 sqrtB = TickMath.getSqrtRatioAtTick(lt.tickUpper);

        if (lt.tokenIsZero) {
            (, uint256 amount1) = LiquidityMath.getAmountsForLiquidity(sqrtPriceX96, sqrtA, sqrtB, liq);
            return amount1;
        } else {
            (uint256 amount0,) = LiquidityMath.getAmountsForLiquidity(sqrtPriceX96, sqrtA, sqrtB, liq);
            return amount0;
        }
    }

    // ── Token deployment ─────────────────────────────────────────────────────

    function predictTokenAddress(LaunchParams calldata p) external view returns (address) {
        bytes32 initHash = _fetchCodeHash(p);
        bytes32 h = keccak256(abi.encodePacked(bytes1(0xff), address(this), p.salt, initHash));
        return address(uint160(uint256(h)));
    }

    function _deployToken(LaunchParams calldata p) private returns (address t) {
        bytes memory code = _fetchCreationCode(p);
        bytes32 salt = p.salt;
        assembly ("memory-safe") {
            t := create2(0, add(code, 0x20), mload(code), salt)
        }
        if (t == address(0)) revert TokenDeployFailed();
    }

    function _fetchCodeHash(LaunchParams calldata p) private view returns (bytes32 initHash) {
        (bool ok, bytes memory ret) = tokenDeployer.staticcall(
            abi.encodeCall(LaunchTokenDeployer.codeHash,
                (p.name, p.symbol, p.metadataURI, p.image, p.description, p.socials, msg.sender))
        );
        if (!ok) revert TokenDeployFailed();
        initHash = abi.decode(ret, (bytes32));
    }

    function _fetchCreationCode(LaunchParams calldata p) private view returns (bytes memory code) {
        (bool ok, bytes memory ret) = tokenDeployer.staticcall(
            abi.encodeCall(LaunchTokenDeployer.creationCode,
                (p.name, p.symbol, p.metadataURI, p.image, p.description, p.socials, msg.sender))
        );
        if (!ok) revert TokenDeployFailed();
        code = abi.decode(ret, (bytes));
    }

    // ── Internal fee forward ─────────────────────────────────────────────────

    function _forwardLaunchFee() internal {
        if (launchFee == 0) return;
        (bool ok,) = treasury.call{value: launchFee}("");
        if (!ok) revert FeeTransferFailed();
    }

    // ── Owner administration ─────────────────────────────────────────────────

    function setLaunchEnabled(bool v) external onlyOwner {
        launchEnabled = v; emit LaunchEnabledUpdated(v);
    }
    function setLaunchFee(uint256 v) external onlyOwner {
        if (v > MAX_LAUNCH_FEE) revert LaunchFeeTooHigh();
        launchFee = v; emit LaunchFeeUpdated(v);
    }
    function setTreasury(address v) external onlyOwner {
        if (v == address(0)) revert ZeroAddress();
        treasury = v; emit TreasuryUpdated(v);
    }
    function setHook(address v) external onlyOwner {
        if (hook != address(0)) revert HookAlreadySet();
        if (v == address(0)) revert ZeroAddress();
        hook = v; emit HookUpdated(v);
    }
    function setStateView(address v) external onlyOwner {
        stateView = v; emit StateViewUpdated(v);
    }
    function setInitialTick(int24 v) external onlyOwner {
        if (v < MIN_INITIAL_TICK || v > MAX_INITIAL_TICK) revert InitialTickOutOfRange();
        if ((-v) % int24(TICK_SPACING) != 0) revert InitialTickOutOfRange();
        initialTick = v; emit InitialTickUpdated(v);
    }

    receive() external payable {}
}
