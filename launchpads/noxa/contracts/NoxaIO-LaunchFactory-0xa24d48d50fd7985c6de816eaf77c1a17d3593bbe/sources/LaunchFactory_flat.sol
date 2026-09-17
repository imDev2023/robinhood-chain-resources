// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {LauncherTypes} from "./src/LauncherTypes.sol";
import {LaunchToken} from "./src/LaunchToken.sol";
import {LauncherLocker} from "./src/LauncherLocker.sol";
import {CTOFeeVault} from "./src/CTOFeeVault.sol";
import {INoxaCTOFund} from "./src/interfaces/INoxaCTO.sol";
import {Clones} from "./src/libraries/Clones.sol";
import {TickMath} from "./src/libraries/TickMath.sol";
import {
    INonfungiblePositionManager,
    IUniswapV3Pool,
    IUniswapV3SwapCallback,
    IWETH9
} from "./src/interfaces/IUniswapV3.sol";

/// @notice Deploys new tokens straight into a Uniswap V3 pool: the full supply is
/// minted as single-sided liquidity and the LP NFT is locked forever in the
/// LauncherLocker. Optionally executes the creator's initial buy in the same tx.
contract LaunchFactory is Ownable, ReentrancyGuard, IUniswapV3SwapCallback {
    struct LaunchRuntime {
        address pool;
        address ctoVault;
        uint256 positionId;
        uint256 restrictionsEndBlock;
        uint256 initialBuyAmount;
        bool isToken0;
    }

    error LaunchDisabled();
    error InvalidLaunchConfig();
    error InvalidDexConfig();
    error DexDisabled();
    error NotWhitelisted();
    error InsufficientFee();
    error FeeTransferFailed();
    error InvalidBasisPoints();
    error UnauthorizedCallback();
    error TokenAlreadyLaunched();
    error EmptyNameOrSymbol();
    error ZeroAddress();
    error CTOFundNotConfigured();
    error CTOFundAlreadyConfigured();
    error InvalidCTOFund();
    error OnlyCTOFund();
    error UnknownToken();
    error TokenTransferFailed();
    error InvalidInitialBuyAmount();

    event TokenDeployed(
        address indexed token,
        address indexed deployer,
        address indexed dexFactory,
        address pairToken,
        uint256 dexId,
        uint256 launchConfigId
    );
    event TokenLaunched(
        address indexed token,
        address indexed deployer,
        address indexed dexFactory,
        address pairToken,
        address pool,
        uint256 dexId,
        uint256 launchConfigId,
        uint256 positionId,
        uint256 restrictionsEndBlock,
        uint256 initialBuyAmount
    );
    event TokenMetadata(
        address indexed token,
        string name,
        string symbol,
        string logo,
        string description,
        string telegram,
        string twitter,
        string discord,
        string website,
        string farcaster,
        address devWallet
    );
    event LaunchConfigAdded(uint256 indexed configId);
    event LaunchConfigUpdated(uint256 indexed configId);
    event DexConfigAdded(uint256 indexed dexId);
    event DexStatusUpdated(uint256 indexed dexId, bool enabled);
    event LaunchFeeUpdated(uint256 launchFee);
    event LaunchEnabledUpdated(bool enabled);
    event WhitelistedLauncherUpdated(address indexed launcher, bool allowed);
    event CTOFundConfigured(address indexed ctoFund);
    event CTOFeeVaultCreated(address indexed token, address indexed vault, address indexed initialLeader);
    event FeeRecipientRestrictionExempted(address indexed token, address indexed recipient);

    LauncherLocker public immutable locker;
    address public immutable ctoVaultImplementation;

    uint256 public launchFee;
    bool public launchEnabled;

    uint256 public launchConfigCount;
    uint256 public dexConfigCount;
    mapping(uint256 => LauncherTypes.LaunchConfig) internal launchConfigs;
    mapping(uint256 => LauncherTypes.DexConfig) internal dexConfigs;
    mapping(address => bool) public whitelistedLaunchers;
    mapping(address => LauncherTypes.LaunchedToken) internal launchedTokens;
    mapping(address token => address vault) internal ctoVaults;

    /// @notice Stable election module used by every token launched after configuration.
    /// @dev Wired once after deployment to avoid a circular Factory <-> CTOFund constructor dependency.
    INoxaCTOFund public ctoFund;

    /// @dev Pool allowed to invoke the swap callback for the duration of the initial buy.
    address private _pendingCallbackPool;
    /// @dev Position id minted by the current launch, passed between helpers.
    uint256 private _lastPositionId;

    constructor(address locker_, uint256 launchFee_, bool launchEnabled_) Ownable(msg.sender) {
        if (locker_ == address(0)) revert ZeroAddress();
        locker = LauncherLocker(locker_);
        ctoVaultImplementation = address(new CTOFeeVault());
        launchFee = launchFee_;
        launchEnabled = launchEnabled_;
    }

    // ---------------------------------------------------------------- admin

    function addLaunchConfig(LauncherTypes.LaunchConfig calldata config) external onlyOwner {
        if (config.pairToken == address(0) || config.supply == 0) revert InvalidLaunchConfig();
        if (config.maxWalletBps > 10_000 || config.maxTxBps > 10_000) revert InvalidBasisPoints();
        launchConfigs[launchConfigCount] = config;
        emit LaunchConfigAdded(launchConfigCount++);
    }

    function updateLaunchConfig(uint256 configId, LauncherTypes.LaunchConfig calldata config) external onlyOwner {
        if (configId >= launchConfigCount) revert InvalidLaunchConfig();
        if (config.pairToken == address(0) || config.supply == 0) revert InvalidLaunchConfig();
        if (config.maxWalletBps > 10_000 || config.maxTxBps > 10_000) revert InvalidBasisPoints();
        launchConfigs[configId] = config;
        emit LaunchConfigUpdated(configId);
    }

    function addDexConfig(LauncherTypes.DexConfig calldata config) external onlyOwner {
        if (config.dexFactory == address(0) || config.positionManager == address(0) || config.tickSpacing <= 0) {
            revert InvalidDexConfig();
        }
        dexConfigs[dexConfigCount] = config;
        emit DexConfigAdded(dexConfigCount++);
    }

    function setDexStatus(uint256 dexId, bool enabled) external onlyOwner {
        if (dexId >= dexConfigCount) revert InvalidDexConfig();
        dexConfigs[dexId].enabled = enabled;
        emit DexStatusUpdated(dexId, enabled);
    }

    function setLaunchFee(uint256 fee) external onlyOwner {
        launchFee = fee;
        emit LaunchFeeUpdated(fee);
    }

    function setLaunchEnabled(bool enabled) external onlyOwner {
        launchEnabled = enabled;
        emit LaunchEnabledUpdated(enabled);
    }

    function setWhitelistedLauncher(address launcher, bool allowed) external onlyOwner {
        whitelistedLaunchers[launcher] = allowed;
        emit WhitelistedLauncherUpdated(launcher, allowed);
    }

    /// @notice One-time wiring of the CTO election module.
    function setCTOFund(address ctoFund_) external onlyOwner {
        if (ctoFund_ == address(0)) revert ZeroAddress();
        if (address(ctoFund) != address(0)) revert CTOFundAlreadyConfigured();
        if (INoxaCTOFund(ctoFund_).factory() != address(this)) revert InvalidCTOFund();
        ctoFund = INoxaCTOFund(ctoFund_);
        emit CTOFundConfigured(ctoFund_);
    }

    // ---------------------------------------------------------------- views

    function getLaunchConfig(uint256 configId) external view returns (LauncherTypes.LaunchConfig memory) {
        if (configId >= launchConfigCount) revert InvalidLaunchConfig();
        return launchConfigs[configId];
    }

    function getDexConfig(uint256 dexId) external view returns (LauncherTypes.DexConfig memory) {
        if (dexId >= dexConfigCount) revert InvalidDexConfig();
        return dexConfigs[dexId];
    }

    function getLaunchedToken(address token) external view returns (LauncherTypes.LaunchedToken memory) {
        return launchedTokens[token];
    }

    function isLaunchedToken(address token) external view returns (bool) {
        return launchedTokens[token].token != address(0);
    }

    function poolOf(address token) external view returns (address) {
        return launchedTokens[token].pool;
    }

    function ctoVaultOf(address token) external view returns (address) {
        return ctoVaults[token];
    }

    /// @notice Creates a holder snapshot after validating the caller and synchronizing protocol inventory.
    function ctoSnapshot(address token) external returns (uint256 snapshotId) {
        if (msg.sender != address(ctoFund)) revert OnlyCTOFund();
        if (launchedTokens[token].token == address(0)) revert UnknownToken();
        LaunchToken launchTokenContract = LaunchToken(token);
        _syncFeeRecipients(launchTokenContract, true);
        snapshotId = launchTokenContract.snapshot();
    }

    /// @notice Refreshes anti-snipe treatment after either fixed FeeRouter recipient changes.
    /// @dev Permissionless and fixed-destination: callers cannot choose which account becomes exempt.
    /// Voting exclusion is applied atomically at the next CTO snapshot, never halfway through a round.
    function syncFeeRecipientExemptions(address token) external {
        if (launchedTokens[token].token == address(0)) revert UnknownToken();
        _syncFeeRecipients(LaunchToken(token), false);
    }

    // ---------------------------------------------------------------- launch

    function launchToken(
        LauncherTypes.LaunchParams calldata params,
        uint256 launchConfigId,
        uint256 dexId,
        bytes32 salt
    ) external payable nonReentrant returns (address token, uint256 positionId) {
        if (!launchEnabled) revert LaunchDisabled();
        if (address(ctoFund) == address(0)) revert CTOFundNotConfigured();
        if (launchConfigId >= launchConfigCount) revert InvalidLaunchConfig();
        if (bytes(params.name).length == 0 || bytes(params.symbol).length == 0) revert EmptyNameOrSymbol();
        if (params.devWallet == address(0)) revert ZeroAddress();

        LauncherTypes.LaunchConfig memory cfg = launchConfigs[launchConfigId];
        if (!cfg.enabled) revert InvalidLaunchConfig();
        if (cfg.permissioned && !whitelistedLaunchers[msg.sender]) revert NotWhitelisted();

        if (dexId >= dexConfigCount) revert InvalidDexConfig();
        LauncherTypes.DexConfig memory dex = dexConfigs[dexId];
        if (!dex.enabled) revert DexDisabled();

        if (msg.value < launchFee) revert InsufficientFee();
        LaunchRuntime memory runtime;
        runtime.initialBuyAmount = msg.value - launchFee;
        runtime.restrictionsEndBlock = block.number + cfg.restrictionBlocks;
        token = _deployToken(params, cfg, runtime.restrictionsEndBlock, salt);

        runtime.ctoVault = Clones.clone(ctoVaultImplementation);
        CTOFeeVault(payable(runtime.ctoVault)).initialize(token, cfg.pairToken, address(ctoFund));
        LaunchToken(token).setVotingExcluded(runtime.ctoVault);

        (runtime.pool, runtime.isToken0) = _createPoolAndLockLiquidity(token, cfg, dex, runtime.ctoVault);
        runtime.positionId = _lastPositionId;
        positionId = runtime.positionId;

        launchedTokens[token] = LauncherTypes.LaunchedToken({
            token: token,
            deployer: msg.sender,
            // Preserve the legacy field's meaning for indexers/UIs. The actual LP-fee recipient is the
            // immutable vault stored in `ctoVaults` and registered in LauncherLocker below.
            feeWallet: params.devWallet,
            pairToken: cfg.pairToken,
            pool: runtime.pool,
            dexId: dexId,
            launchConfigId: launchConfigId,
            positionId: runtime.positionId,
            restrictionsEndBlock: runtime.restrictionsEndBlock,
            initialBuyAmount: runtime.initialBuyAmount,
            createdAtBlock: block.number,
            isToken0: runtime.isToken0
        });
        ctoVaults[token] = runtime.ctoVault;
        ctoFund.onCreate(token, params.devWallet);
        emit CTOFeeVaultCreated(token, runtime.ctoVault, params.devWallet);

        emit TokenDeployed(token, msg.sender, dex.dexFactory, cfg.pairToken, dexId, launchConfigId);
        _emitTokenMetadata(token, params);

        if (launchFee > 0) {
            // The anti-spam launch fee remains separate from the LP-fee split,
            // but all payouts stay ERC20: wrap it and fund the burner in WETH.
            IWETH9(cfg.pairToken).deposit{value: launchFee}();
            if (!IWETH9(cfg.pairToken).transfer(locker.feeRouter().burnerRecipient(), launchFee)) {
                revert FeeTransferFailed();
            }
        }

        if (runtime.initialBuyAmount > 0) {
            _executeInitialBuy(runtime.pool, cfg.pairToken, runtime.isToken0, runtime.initialBuyAmount);
        }

        emit TokenLaunched(
            token,
            msg.sender,
            dex.dexFactory,
            cfg.pairToken,
            runtime.pool,
            dexId,
            launchConfigId,
            _lastPositionId,
            runtime.restrictionsEndBlock,
            runtime.initialBuyAmount
        );
        _lastPositionId = 0;
    }

    function _emitTokenMetadata(address token, LauncherTypes.LaunchParams calldata params) private {
        emit TokenMetadata(
            token,
            params.name,
            params.symbol,
            params.logo,
            params.description,
            params.socials.telegram,
            params.socials.twitter,
            params.socials.discord,
            params.socials.website,
            params.socials.farcaster,
            params.devWallet
        );
    }

    function _deployToken(
        LauncherTypes.LaunchParams calldata params,
        LauncherTypes.LaunchConfig memory cfg,
        uint256 restrictionsEndBlock,
        bytes32 salt
    ) private returns (address token) {
        bytes32 finalSalt = keccak256(abi.encode(msg.sender, salt));
        token = address(
            new LaunchToken{salt: finalSalt}(
                params.name, params.symbol, cfg.supply, cfg.maxWalletBps, cfg.maxTxBps, restrictionsEndBlock
            )
        );
        if (launchedTokens[token].token != address(0)) revert TokenAlreadyLaunched();
    }

    function _createPoolAndLockLiquidity(
        address token,
        LauncherTypes.LaunchConfig memory cfg,
        LauncherTypes.DexConfig memory dex,
        address feeWallet
    ) private returns (address pool, bool isToken0) {
        isToken0 = token < cfg.pairToken;
        int24 initialTick = isToken0 ? cfg.initialTick : -cfg.initialTick;
        (address token0, address token1) = isToken0 ? (token, cfg.pairToken) : (cfg.pairToken, token);

        INonfungiblePositionManager pm = INonfungiblePositionManager(dex.positionManager);
        pool = pm.createAndInitializePoolIfNecessary(
            token0, token1, dex.poolFee, TickMath.getSqrtRatioAtTick(initialTick)
        );
        LaunchToken lt = LaunchToken(token);
        lt.setVotingExcluded(pool);
        lt.setVotingExcluded(address(locker.feeRouter()));
        lt.setRestrictionExempt(pool);
        lt.setRestrictionExempt(address(locker));
        lt.setRestrictionExempt(dex.positionManager);
        if (dex.router != address(0)) lt.setRestrictionExempt(dex.router);
        // During the anti-snipe window, max-wallet checks also apply to protocol recipients. Exempt every
        // hop in the permissionless LP-fee path so fee collection cannot be blocked by those launch limits.
        lt.setRestrictionExempt(feeWallet);
        lt.configureFeeVault(feeWallet, address(locker.feeRouter()));
        lt.setRestrictionExempt(address(locker.feeRouter()));
        _syncFeeRecipients(lt, true);

        lt.approve(dex.positionManager, cfg.supply);

        (int24 tickLower, int24 tickUpper) = isToken0
            ? (initialTick, TickMath.maxUsableTick(dex.tickSpacing))
            : (TickMath.minUsableTick(dex.tickSpacing), initialTick);

        (uint256 positionId,,,) = pm.mint(
            INonfungiblePositionManager.MintParams({
                token0: token0,
                token1: token1,
                fee: dex.poolFee,
                tickLower: tickLower,
                tickUpper: tickUpper,
                amount0Desired: isToken0 ? cfg.supply : 0,
                amount1Desired: isToken0 ? 0 : cfg.supply,
                amount0Min: 0,
                amount1Min: 0,
                recipient: address(locker),
                deadline: block.timestamp
            })
        );
        _lastPositionId = positionId;

        locker.registerPosition(token, positionId, dex.positionManager, cfg.pairToken, feeWallet, isToken0);

        // Rounding can leave dust behind. Move it to the permanently excluded dead address.
        uint256 dust = lt.balanceOf(address(this));
        if (dust > 0 && !lt.transfer(0x000000000000000000000000000000000000dEaD, dust)) {
            revert TokenTransferFailed();
        }
    }

    function _syncFeeRecipients(LaunchToken token, bool excludeFromVoting) private {
        address protocolRecipient = locker.feeRouter().protocolRecipient();
        address burnerRecipient = locker.feeRouter().burnerRecipient();
        if (protocolRecipient == address(0) || burnerRecipient == address(0)) revert ZeroAddress();

        token.setRestrictionExempt(protocolRecipient);
        emit FeeRecipientRestrictionExempted(address(token), protocolRecipient);
        if (burnerRecipient != protocolRecipient) {
            token.setRestrictionExempt(burnerRecipient);
            emit FeeRecipientRestrictionExempted(address(token), burnerRecipient);
        }

        if (excludeFromVoting) {
            token.setVotingExcluded(protocolRecipient);
            if (burnerRecipient != protocolRecipient) token.setVotingExcluded(burnerRecipient);
        }
    }

    function _executeInitialBuy(address pool, address pairToken, bool isToken0, uint256 amountIn) private {
        if (amountIn > uint256(type(int256).max)) revert InvalidInitialBuyAmount();
        // The preceding bound makes this conversion exact.
        // forge-lint: disable-next-line(unsafe-typecast)
        int256 signedAmountIn = int256(amountIn);
        IWETH9(pairToken).deposit{value: amountIn}();
        bool zeroForOne = !isToken0; // paying pairToken for token
        _pendingCallbackPool = pool;
        IUniswapV3Pool(pool)
            .swap(
                msg.sender,
                zeroForOne,
                signedAmountIn,
                zeroForOne ? TickMath.MIN_SQRT_RATIO + 1 : TickMath.MAX_SQRT_RATIO - 1,
                abi.encode(pairToken)
            );
        _pendingCallbackPool = address(0);
    }

    /// @inheritdoc IUniswapV3SwapCallback
    function uniswapV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata data) external {
        if (msg.sender != _pendingCallbackPool || _pendingCallbackPool == address(0)) revert UnauthorizedCallback();
        address pairToken = abi.decode(data, (address));
        uint256 owed = uint256(amount0Delta > 0 ? amount0Delta : amount1Delta);
        if (!IWETH9(pairToken).transfer(msg.sender, owed)) revert TokenTransferFailed();
    }
}
