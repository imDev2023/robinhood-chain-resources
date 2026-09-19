// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../StonkTokenRegistry.sol";
import "../uniswap/INonfungiblePositionManagerMinimal.sol";
import "./StonkMemeCoin.sol";
import "./StonkLaunch.sol";

/// @notice Deploys meme coins + their associated StonkLaunch contracts.
contract StonkLauncherFactory is Ownable {
    using SafeERC20 for IERC20;

    address public treasury;
    address public weth;
    address public positionManager;
    StonkTokenRegistry public registry;

    event TreasuryUpdated(address indexed oldTreasury, address indexed newTreasury);
    event UniswapConfigUpdated(address indexed weth, address indexed positionManager);
    event RegistryUpdated(address indexed registry);

    event LaunchCreated(
        address indexed creator,
        address indexed token,
        address indexed launch,
        string name,
        string symbol,
        string metadataURI,
        string imageURI
    );
    event LaunchFinalized(address indexed creator, address indexed launch, address indexed pool, uint256 lpTokenId);

    error ConfigNotSet();
    error NotLaunchCreator();

    constructor(address initialOwner, address _treasury, address _weth, address _positionManager, address _registry)
        Ownable(initialOwner)
    {
        require(_treasury != address(0), "treasury=0");
        require(_weth != address(0), "weth=0");
        require(_positionManager != address(0), "pm=0");
        require(_registry != address(0), "registry=0");
        treasury = _treasury;
        weth = _weth;
        positionManager = _positionManager;
        registry = StonkTokenRegistry(_registry);
    }

    function setTreasury(address newTreasury) external onlyOwner {
        require(newTreasury != address(0), "treasury=0");
        emit TreasuryUpdated(treasury, newTreasury);
        treasury = newTreasury;
    }

    function setUniswapConfig(address _weth, address _positionManager) external onlyOwner {
        require(_weth != address(0), "weth=0");
        require(_positionManager != address(0), "pm=0");
        weth = _weth;
        positionManager = _positionManager;
        emit UniswapConfigUpdated(_weth, _positionManager);
    }

    function setRegistry(address _registry) external onlyOwner {
        require(_registry != address(0), "registry=0");
        registry = StonkTokenRegistry(_registry);
        emit RegistryUpdated(_registry);
    }

    struct CreateLaunchParams {
        string name;
        string symbol;
        string metadataURI; // IPFS JSON metadata pointer
        string imageURI; // optional image pointer (ipfs://.../png)
        uint256 totalSupplyWei; // 18 decimals
        uint256 creatorAllocationBps; // 0..5000 (default safety)
        uint256 saleBpsOfRemaining; // 0..10000
        uint256 priceWeiPerToken; // fixed sale price
    }

    struct LaunchRecord {
        address creator;
        address token;
        bool finalized;
    }
    mapping(address => LaunchRecord) public launches;
    mapping(address => bool) public launchedTokens;

    function createLaunch(CreateLaunchParams calldata p) external returns (address token, address launch) {
        if (treasury == address(0) || weth == address(0) || positionManager == address(0) || address(registry) == address(0)) {
            revert ConfigNotSet();
        }
        require(p.totalSupplyWei > 0, "supply=0");
        require(p.creatorAllocationBps <= 5000, "creator bps");
        require(p.saleBpsOfRemaining <= 10_000, "sale bps");
        require(p.priceWeiPerToken > 0, "price=0");
        require(bytes(p.symbol).length > 0 && bytes(p.symbol).length <= 11, "symbol len");

        uint256 creatorAlloc = (p.totalSupplyWei * p.creatorAllocationBps) / 10_000;
        uint256 remaining = p.totalSupplyWei - creatorAlloc;
        uint256 saleSupply = (remaining * p.saleBpsOfRemaining) / 10_000;
        uint256 liquiditySupply = remaining - saleSupply;

        // Deploy token to this factory, then distribute allocations.
        StonkMemeCoin coin = new StonkMemeCoin(p.name, p.symbol, p.totalSupplyWei, address(this), p.metadataURI);
        token = address(coin);

        // Deploy launch contract.
        StonkLaunch stonkLaunch = new StonkLaunch(
            address(this),
            treasury,
            address(registry),
            positionManager,
            weth,
            token,
            p.priceWeiPerToken,
            saleSupply,
            liquiditySupply,
            p.metadataURI,
            p.imageURI
        );
        launch = address(stonkLaunch);

        // Distribute: creator allocation -> msg.sender
        if (creatorAlloc > 0) IERC20(token).safeTransfer(msg.sender, creatorAlloc);

        // Sale+LP inventory -> launch contract
        if (saleSupply + liquiditySupply > 0) IERC20(token).safeTransfer(launch, saleSupply + liquiditySupply);

        // Auto-register token in the registry (if this factory is configured there).
        // If registry factory isn't set, the tx will revert, so we ignore by using a low-level call.
        (bool ok, ) = address(registry).call(
            abi.encodeWithSelector(
                StonkTokenRegistry.registerLaunchedToken.selector,
                token,
                p.symbol,
                uint8(coin.decimals()),
                p.imageURI,
                p.metadataURI
            )
        );
        ok; // intentionally ignored

        emit LaunchCreated(msg.sender, token, launch, p.name, p.symbol, p.metadataURI, p.imageURI);

        launches[launch] = LaunchRecord({ creator: msg.sender, token: token, finalized: false });
        launchedTokens[token] = true;
    }

    function finalizeLaunch(address launch, uint160 sqrtPriceX96, uint24 fee) external payable {
        LaunchRecord storage rec = launches[launch];
        require(rec.creator != address(0), "unknown launch");
        if (msg.sender != rec.creator && msg.sender != owner()) revert NotLaunchCreator();
        require(!rec.finalized, "finalized");

        StonkLaunch stonkLaunch = StonkLaunch(payable(launch));
        stonkLaunch.finalize{value: msg.value}(sqrtPriceX96, fee);
        rec.finalized = true;
        emit LaunchFinalized(rec.creator, launch, stonkLaunch.pool(), stonkLaunch.lpTokenId());
    }
}

