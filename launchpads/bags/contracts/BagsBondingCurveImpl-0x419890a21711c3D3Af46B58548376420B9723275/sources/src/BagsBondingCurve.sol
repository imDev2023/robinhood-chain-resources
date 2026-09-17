// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.26;

// OpenZeppelin
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";

// OpenZeppelin Upgradeable
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {Ownable2StepUpgradeable} from "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

// Uniswap v4 Core
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {FixedPoint96} from "@uniswap/v4-core/src/libraries/FixedPoint96.sol";
import {FullMath} from "@uniswap/v4-core/src/libraries/FullMath.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {LPFeeLibrary} from "@uniswap/v4-core/src/libraries/LPFeeLibrary.sol";
import {PoolId} from "@uniswap/v4-core/src/types/PoolId.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";

// Uniswap v4 Periphery
import {Actions} from "@uniswap/v4-periphery/src/libraries/Actions.sol";
import {IPositionManager} from "@uniswap/v4-periphery/src/interfaces/IPositionManager.sol";
import {IWETH9} from "@uniswap/v4-periphery/src/interfaces/external/IWETH9.sol";
import {LiquidityAmounts} from "@uniswap/v4-periphery/src/libraries/LiquidityAmounts.sol";

// Permit2
import {IAllowanceTransfer} from "permit2/src/interfaces/IAllowanceTransfer.sol";

// Solmate
import {FixedPointMathLib} from "solmate/src/utils/FixedPointMathLib.sol";

// Local interfaces
import {IBagsBondingCurve} from "src/interfaces/IBagsBondingCurve.sol";
import {IBagsFeeShare} from "src/interfaces/IBagsFeeShare.sol";

/// @title BagsBondingCurve
/// @notice Constant product market maker with virtual reserves, quoted in the chain's native token
///         (wrapped as WETH for fee sharing and the migration LP).
///         Deployed once as the shared implementation behind an `UpgradeableBeacon`; the factory
///         creates a `BeaconProxy` per launch and calls `initialize(...)`.
/// @dev BEACON UPGRADE DESIGN RULE: this implementation is shared by every live launch through the
///      curve beacon. Flipping the beacon runs NO migration call on any proxy (unlike UUPS's
///      `upgradeToAndCall`), so every future upgrade MUST be safe with new state variables reading
///      as zero in all live proxies (or lazily initialized in the new logic). No upgrade may ever
///      require per-proxy setup.
///
///      STORAGE DISCIPLINE (append-only): never reorder, remove, or retype existing variables;
///      append new ones only at the end, consuming the trailing `__gap`. The OZ upgradeable bases
///      use ERC-7201 namespaced slots and do not shift this contract's linear layout. A bad beacon
///      upgrade corrupts ALL launches at once — diff the storage layout before every upgrade.
///
///      The 5 infra immutables (POOL_MANAGER, POSITION_MANAGER, WETH, VAULT, PERMIT2) live in the
///      implementation (shared by all proxies), keep hot-path gas low, and can only be changed by
///      deploying a new implementation and upgrading the beacon.
/// @author Bags
contract BagsBondingCurve is
    Initializable,
    ReentrancyGuardUpgradeable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    Ownable2StepUpgradeable,
    IBagsBondingCurve
{
    using SafeERC20 for IERC20;

    // --- Constants ---
    /// @notice Access control role allowed to pause/unpause
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    /// @notice Basis points denominator (10_000 = 100%)
    uint256 private constant BPS_DENOM = 10_000;
    /// @notice Token decimals scale used across the system (BagsToken uses 18 decimals)
    uint256 private constant TOKEN_SCALE = 1e18;
    /// @notice Percentage denominator for progress reporting
    uint256 private constant PERCENT_DENOM = 100;
    /// @notice Migration tx deadline buffer for the PositionManager call
    uint256 private constant MIGRATION_DEADLINE_SECONDS = 1 hours;

    // --- Shared immutables (same for all instances on a chain) ---
    /// @notice Uniswap v4 PoolManager (singleton) used post-migration
    IPoolManager public immutable POOL_MANAGER;
    /// @notice Uniswap v4 PositionManager used to mint the full range position
    IPositionManager public immutable POSITION_MANAGER;
    /// @notice WETH address for the target chain
    address public immutable WETH;
    /// @notice Vault that receives platform's 50% of quote fees
    address public immutable VAULT;
    /// @notice Permit2 contract
    IAllowanceTransfer public immutable PERMIT2;

    // --- Per-instance storage (set via initialize) ---
    /// @notice ERC20 token that this curve sells and buys
    address public TOKEN;
    /// @notice Shared Bags v4 hook attached to the migration pool
    IHooks public HOOK;
    /// @notice FeeShare contract that receives creator's 50% of fees (as WETH)
    address public FEE_SHARE;
    /// @notice Burn address used to permanently disown the contract after migration
    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;

    // Virtual reserves (scaled)
    /// @notice Initial virtual token reserve used for pricing (token units, 18 decimals)
    /// @dev Chain-independent curve shape constant: ceil(34445e24 / 33). Together with the
    ///      threshold-derived virtual quote reserve it sells exactly 830M tokens at the threshold.
    uint256 public constant INITIAL_VIRTUAL_TOKEN_RESERVES = 1_043_787_878_787_878_787_878_787_879;
    /// @notice Tokens sold on the curve when the threshold is reached (83% of supply)
    uint256 private constant CURVE_TOKEN_ALLOCATION = 830_000_000 * TOKEN_SCALE;
    /// @dev Absolute dust tolerance (in token wei) for the sold-at-threshold economics assert.
    ///      Numerically verified: max deviation is < 1e11 across thresholds in [0.01 ether, 1000 ether].
    uint256 private constant ECONOMICS_DUST_TOLERANCE = 1e12;
    /// @dev Relative tolerance denominator for the price-continuity economics assert (1e-12 relative).
    ///      Numerically verified: max relative deviation is < 1e-16 across the allowed threshold range.
    uint256 private constant CONTINUITY_TOLERANCE_DENOM = 1e12;

    /// @dev Current virtual token reserve used for pricing (token units, 18 decimals)
    uint256 private _virtualTokenReserves;
    /// @dev Current virtual quote reserve used for pricing (wei)
    uint256 private _virtualQuoteReserves;

    // Real reserves tracked for migration threshold
    /// @notice Tracked real quote balance that contributes toward the migration threshold
    uint256 public realQuoteReserves;
    /// @notice Tracked real token balance held by the curve contract
    uint256 public realTokenReserves;
    /// @notice One-time flag set after initial token mint is observed
    bool public initialized;

    // Fees and parameters

    /// @notice Buy/Sell fee in basis points (taken on the quote leg)
    uint256 public constant TX_FEE_BPS = 200; // 2%
    /// @notice Net quote threshold required to trigger migration (snapshotted at initialize)
    uint256 public thresholdQuote;
    /// @notice Initial virtual quote reserve used for pricing (derived from the threshold at initialize)
    uint256 public initialVirtualQuoteReserves;

    // LP retention config

    /// @notice Token amount reserved to seed the initial LP at migration (17% of total supply)
    uint256 public constant LP_TOKEN_AMOUNT = 170_000_000 * 1e18;

    /// @notice Tick spacing used for the full-range migration position
    int24 private constant TICK_SPACING = 60;
    /// @dev Minimum tick for the full-range position (aligned to tick spacing of 60)
    int24 private constant MIN_TICK = -887220;
    /// @dev Maximum tick for the full-range position (aligned to tick spacing of 60)
    int24 private constant MAX_TICK = 887220;

    // Migration state
    /// @notice True after migration completes
    bool public migrated;
    /// @notice Creator address (kept for record, no reward paid)
    address public creator;
    /// @notice Platform admin: pause authority and migration LP NFT recipient
    address public platformAdmin;

    // Partner fee (carved out of the PROTOCOL half, never the creator half)
    /// @notice Optional partner address (zero for none); snapshotted at initialize
    address public partner;
    /// @notice Partner share in bps (base 10_000) of the PROTOCOL half; snapshotted from the
    ///         factory default at initialize, so live curves never change when the default moves
    uint16 public partnerFeeBps;

    /// @dev Reserved storage to allow appending variables in future beacon upgrades (append-only:
    ///      new variables replace gap slots from the top; never shrink from the middle).
    uint256[50] private __gap;

    /// @notice Modifier to restrict function access to admin only
    modifier onlyAdmin() {
        _onlyAdmin();
        _;
    }

    /// @notice Creates the shared bonding curve implementation (shared immutables only)
    /// @dev The factory deploys a `BeaconProxy` per launch and calls initialize(). The immutables
    ///      are embedded in the implementation code, so every proxy behind the beacon shares them.
    /// @param poolManager Uniswap v4 PoolManager address
    /// @param positionManager Uniswap v4 PositionManager address
    /// @param weth WETH address
    /// @param vault_ Vault that will receive platform's 50% of quote fees
    /// @param permit2 Permit2 contract address
    /// @custom:oz-upgrades-unsafe-allow constructor state-variable-immutable
    constructor(
        address poolManager,
        address positionManager,
        address weth,
        address vault_,
        address permit2
    ) {
        if (poolManager == address(0)) revert BagsBondingCurve_ZeroAddressPoolManager();
        if (positionManager == address(0)) revert BagsBondingCurve_ZeroAddressPositionManager();
        if (weth == address(0)) revert BagsBondingCurve_ZeroAddressWETH();
        if (vault_ == address(0)) revert BagsBondingCurve_ZeroAddressVault();

        POOL_MANAGER = IPoolManager(poolManager);
        POSITION_MANAGER = IPositionManager(positionManager);
        WETH = weth;
        VAULT = vault_;
        PERMIT2 = IAllowanceTransfer(permit2);

        // Lock the implementation so initialize() can only run behind a proxy
        _disableInitializers();
    }

    /// @notice Accept native quote transfers
    receive() external payable {}

    // ====================================================================
    // EXTERNAL FUNCTIONS
    // ====================================================================

    /// @notice Initialize a freshly-deployed BeaconProxy with per-instance parameters
    /// @dev Guarded by OZ's `initializer` (re-calls revert `InvalidInitialization()`). Sets TOKEN,
    ///      HOOK, FEE_SHARE, roles, Permit2 approvals, and snapshots the graduation economics
    ///      (threshold + derived virtual quote reserves). The economics invariants (830M tokens
    ///      sold at threshold, price continuity into the LP) are asserted so a bad threshold can
    ///      never deploy a broken curve.
    /// @param token ERC20 token address traded on this bonding curve
    /// @param hook Shared Bags v4 hook address
    /// @param initialOwner Owner for Ownable (the factory; used for initializeAfterMint)
    /// @param creator_ Creator address
    /// @param feeShare_ FeeShare contract that receives creator's 50% of fees
    /// @param platformAdmin_ Platform admin: receives ADMIN_ROLE/DEFAULT_ADMIN_ROLE and the LP NFT
    /// @param partner_ Optional partner address (zero for none); paid from the protocol half
    /// @param partnerFeeBps_ Partner share in bps of the protocol half (snapshotted from the factory)
    /// @param thresholdQuote_ Net quote amount required to graduate (snapshotted from the factory)
    function initialize(
        address token,
        address hook,
        address initialOwner,
        address creator_,
        address feeShare_,
        address platformAdmin_,
        address partner_,
        uint16 partnerFeeBps_,
        uint256 thresholdQuote_
    ) external override initializer {
        if (token == address(0)) revert BagsBondingCurve_ZeroAddressToken();
        if (hook == address(0)) revert BagsBondingCurve_ZeroAddressHook();
        if (feeShare_ == address(0)) revert BagsBondingCurve_ZeroAddressFeeShare();
        if (platformAdmin_ == address(0)) revert BagsBondingCurve_ZeroAddressPlatformAdmin();
        if (partnerFeeBps_ > BPS_DENOM) revert BagsBondingCurve_InvalidPartnerFeeBps(partnerFeeBps_);
        if (thresholdQuote_ == 0) revert BagsBondingCurve_ZeroThreshold();

        // Initialize upgradeable bases. Pausable starts unpaused (zero-default of a fresh proxy),
        // matching V1: the curve trades from launch and is only ever paused by ADMIN_ROLE or
        // permanently by _migrate(). __Ownable_init sets the factory as owner (used solely for
        // initializeAfterMint); pause authority and the LP NFT belong to the platform admin.
        __ReentrancyGuard_init();
        __AccessControl_init();
        __Pausable_init();
        __Ownable_init(initialOwner);
        __Ownable2Step_init();

        TOKEN = token;
        HOOK = IHooks(hook);
        FEE_SHARE = feeShare_;
        creator = creator_;
        platformAdmin = platformAdmin_;
        partner = partner_;
        partnerFeeBps = partnerFeeBps_;

        // Snapshot graduation economics (implementation constructor values don't apply to proxies)
        thresholdQuote = thresholdQuote_;
        uint256 virtualQuote = (thresholdQuote_ * 17) / 66;
        initialVirtualQuoteReserves = virtualQuote;
        _virtualTokenReserves = INITIAL_VIRTUAL_TOKEN_RESERVES;
        _virtualQuoteReserves = virtualQuote;

        _assertEconomics(thresholdQuote_, virtualQuote);

        _grantRole(DEFAULT_ADMIN_ROLE, platformAdmin_);
        _grantRole(ADMIN_ROLE, platformAdmin_);

        // ERC20 approvals to Permit2 (unlimited)
        IERC20(token).approve(address(PERMIT2), type(uint256).max);
        IERC20(WETH).approve(address(PERMIT2), type(uint256).max);

        // Permit2 allowances to POSITION_MANAGER (unlimited, max expiration)
        PERMIT2.approve(token, address(POSITION_MANAGER), type(uint160).max, type(uint48).max);
        PERMIT2.approve(WETH, address(POSITION_MANAGER), type(uint160).max, type(uint48).max);
    }

    /// @notice Pause trading
    /// @dev Only ADMIN_ROLE can pause
    function pause() external override onlyAdmin {
        _pause();
    }

    /// @notice Unpause trading
    /// @dev Only ADMIN_ROLE can unpause
    function unpause() external override onlyAdmin {
        _unpause();
    }

    /// @notice One-time initializer to sync realTokenReserves after the token supply has been minted to this contract
    /// @dev Only owner (factory) can call, and only once
    function initializeAfterMint() external override onlyOwner {
        if (initialized) revert BagsBondingCurve_AlreadyInitialized();
        realTokenReserves = IERC20(TOKEN).balanceOf(address(this));
        initialized = true;
        emit Initialized(msg.sender, realTokenReserves);
    }

    /// @notice Buy tokens with native quote for yourself, enforcing slippage and threshold-aware refunding
    /// @param minTokensOut Minimum tokens expected to receive to protect against slippage
    function buy(
        uint256 minTokensOut
    ) external payable override nonReentrant whenNotPaused {
        _buyInternal(msg.sender, minTokensOut);
    }

    /// @notice Buy tokens on behalf of a recipient with native quote, enforcing slippage and threshold-aware refunding
    /// @param recipient Address to receive the purchased tokens
    /// @param minTokensOut Minimum tokens expected to receive to protect against slippage
    function buyFor(
        address recipient,
        uint256 minTokensOut
    ) external payable override nonReentrant whenNotPaused {
        if (recipient == address(0)) revert BagsBondingCurve_InvalidRecipient();
        _buyInternal(recipient, minTokensOut);
    }

    /// @notice Sell tokens for native quote, enforcing slippage and routing fee to the vault
    /// @param tokensIn Amount of tokens to sell
    /// @param minQuoteOut Minimum quote expected to receive to protect against slippage
    function sell(
        uint256 tokensIn,
        uint256 minQuoteOut
    ) external override nonReentrant whenNotPaused {
        _sellInternal(msg.sender, tokensIn, minQuoteOut);
    }

    /// @notice Sell tokens for native quote on behalf of a recipient
    /// @dev Tokens are pulled from msg.sender; proceeds are paid to `recipient`.
    /// @param recipient Address to receive the quote proceeds
    /// @param tokensIn Amount of tokens to sell
    /// @param minQuoteOut Minimum quote expected to receive to protect against slippage
    function sellFor(
        address recipient,
        uint256 tokensIn,
        uint256 minQuoteOut
    ) external override nonReentrant whenNotPaused {
        if (recipient == address(0)) revert BagsBondingCurve_InvalidRecipient();
        _sellInternal(recipient, tokensIn, minQuoteOut);
    }

    /// @notice External entry point to trigger migration once threshold is reached
    function migrate() external override nonReentrant whenNotPaused {
        if (migrated) revert BagsBondingCurve_AlreadyMigrated();
        if (realQuoteReserves < thresholdQuote) {
            revert BagsBondingCurve_ThresholdNotReached(realQuoteReserves, thresholdQuote);
        }
        _migrate();
    }

    /// @notice Quote amount seeded into the LP at migration (equals the snapshotted threshold)
    /// @return amount Quote amount wrapped into the migration LP
    function lpQuoteAmount() external view override returns (uint256 amount) {
        return thresholdQuote;
    }

    /// @notice Returns the current virtual reserves used for pricing
    /// @return vToken Virtual token reserve
    /// @return vQuote Virtual quote reserve
    function getVirtualReserves() external view override returns (uint256 vToken, uint256 vQuote) {
        return (_virtualTokenReserves, _virtualQuoteReserves);
    }

    /// @notice Returns the bonding progress percentage based on virtual token depletion
    /// @dev With the curve economics (§ sold-at-threshold == 830M), the maximum virtual-token
    ///      depletion at the threshold is exactly the curve allocation, so progress is linear in it.
    ///      Returns 100 if and only if the curve has migrated: post-migration the value is pinned
    ///      to 100 (the floored division could otherwise read 99 forever when the sold amount lands
    ///      a wei short of exactly 830M), and pre-migration it is clamped to 99 (wei-level rounding
    ///      can push the raw ratio to 100 within a few wei of the threshold before the crossing buy).
    /// @return percent Progress in percent (0-100; 100 == migrated)
    function bondingProgress() external view override returns (uint256 percent) {
        if (migrated) return 100;
        if (_virtualTokenReserves >= INITIAL_VIRTUAL_TOKEN_RESERVES) return 0;
        uint256 diff = INITIAL_VIRTUAL_TOKEN_RESERVES - _virtualTokenReserves;
        percent = (diff * PERCENT_DENOM) / CURVE_TOKEN_ALLOCATION;
        if (percent > 99) percent = 99;
    }

    /// @notice Quote a buy (exact-in quote) against the current virtual reserves
    /// @dev Returns zeroed values if trading is disabled (not initialized or already migrated)
    /// @param quoteIn Amount of quote the user intends to send (msg.value for buy)
    /// @return tokensOut Estimated tokens to receive
    /// @return feeQuote Estimated quote fee split between vault and fee share
    /// @return netQuoteIn Estimated quote added to the curve (after fee)
    /// @return grossUsed Portion of quoteIn that would be used (subject to threshold cap)
    /// @return refundQuote Portion of quoteIn that would be refunded
    function quoteBuy(
        uint256 quoteIn
    )
        external
        view
        override
        returns (uint256 tokensOut, uint256 feeQuote, uint256 netQuoteIn, uint256 grossUsed, uint256 refundQuote)
    {
        if (quoteIn == 0) return (0, 0, 0, 0, 0);
        if (!initialized || migrated) return (0, 0, 0, 0, 0);

        uint256 denom = BPS_DENOM;
        uint256 feeBps = TX_FEE_BPS;
        uint256 netFactor = denom - feeBps;

        uint256 grossCap = quoteIn;
        if (realQuoteReserves < thresholdQuote) {
            uint256 missing = thresholdQuote - realQuoteReserves;
            uint256 grossNeeded = feeBps == 0 ? missing : (missing * denom + netFactor - 1) / netFactor;
            if (grossNeeded < grossCap) grossCap = grossNeeded;
        }

        feeQuote = (grossCap * feeBps) / denom;
        netQuoteIn = grossCap - feeQuote;
        tokensOut = (_virtualTokenReserves * netQuoteIn) / (_virtualQuoteReserves + netQuoteIn);
        grossUsed = grossCap;
        refundQuote = quoteIn - grossCap;
    }

    /// @notice Quote a sell (exact-in tokens) against the current virtual reserves
    /// @dev Returns zeroed values if trading is disabled (not initialized or already migrated)
    /// @param tokensIn Amount of tokens the user intends to sell
    /// @return quoteToSeller Estimated quote to the seller after fee
    /// @return feeQuote Estimated quote fee split between vault and fee share
    /// @return grossQuoteOut Estimated gross quote out before fee
    function quoteSell(
        uint256 tokensIn
    ) external view override returns (uint256 quoteToSeller, uint256 feeQuote, uint256 grossQuoteOut) {
        if (tokensIn == 0) return (0, 0, 0);
        if (!initialized || migrated) return (0, 0, 0);

        uint256 grossQuoteOutNumerator = _virtualQuoteReserves * tokensIn;
        uint256 grossQuoteOutDenominator = _virtualTokenReserves + tokensIn;
        grossQuoteOut = grossQuoteOutNumerator / grossQuoteOutDenominator;
        feeQuote = (grossQuoteOutNumerator * TX_FEE_BPS) / (BPS_DENOM * grossQuoteOutDenominator);
        quoteToSeller = grossQuoteOut - feeQuote;
    }

    // ====================================================================
    // PUBLIC FUNCTIONS
    // ====================================================================

    /// @notice Returns current spot price as quote wei per token unit based on virtual reserves
    /// @return price Spot price in quote wei per token unit (scaled by 1e18)
    function currentPrice() public view override returns (uint256 price) {
        if (_virtualTokenReserves == 0) revert BagsBondingCurve_ZeroVirtualTokenReserve();
        // Return quote wei per 1 token (token has 18 decimals): (vQuote * TOKEN_SCALE) / vToken
        return (_virtualQuoteReserves * TOKEN_SCALE) / _virtualTokenReserves;
    }

    // ====================================================================
    // INTERNAL FUNCTIONS
    // ====================================================================

    /// @dev Internal helper to enforce admin-only access
    function _onlyAdmin() internal view {
        if (!hasRole(ADMIN_ROLE, msg.sender)) revert BagsBondingCurve_NotAdmin(msg.sender);
    }

    /// @dev Asserts the graduation economics for a snapshotted threshold:
    ///      1. Selling the full curve allocation nets exactly the threshold (within dust).
    ///      2. Curve end-price equals the LP composition price (cross-multiplied, relative tolerance),
    ///         so the full-range mint consumes both sides completely.
    /// @param threshold Net quote threshold being snapshotted
    /// @param virtualQuote Derived initial virtual quote reserve (threshold * 17 / 66)
    function _assertEconomics(uint256 threshold, uint256 virtualQuote) internal pure {
        // 1. Sold-at-threshold: vT0 * t / (vQ0 + t) must be the curve allocation within dust.
        uint256 soldAtThreshold =
            (INITIAL_VIRTUAL_TOKEN_RESERVES * threshold) / (virtualQuote + threshold);
        uint256 soldDelta = soldAtThreshold > CURVE_TOKEN_ALLOCATION
            ? soldAtThreshold - CURVE_TOKEN_ALLOCATION
            : CURVE_TOKEN_ALLOCATION - soldAtThreshold;
        if (soldDelta > ECONOMICS_DUST_TOLERANCE) {
            revert BagsBondingCurve_EconomicsSoldMismatch(soldAtThreshold, CURVE_TOKEN_ALLOCATION);
        }

        // 2. Price continuity: (vQ0 + t) * LP_TOKEN_AMOUNT == t * (vT0 - allocation), cross-multiplied.
        uint256 lpSide = (virtualQuote + threshold) * LP_TOKEN_AMOUNT;
        uint256 curveSide = threshold * (INITIAL_VIRTUAL_TOKEN_RESERVES - CURVE_TOKEN_ALLOCATION);
        uint256 continuityDelta = lpSide > curveSide ? lpSide - curveSide : curveSide - lpSide;
        if (continuityDelta > curveSide / CONTINUITY_TOLERANCE_DENOM) {
            revert BagsBondingCurve_EconomicsPriceDiscontinuity(lpSide, curveSide);
        }
    }

    /// @dev Shared internal purchase logic for buy() and buyFor()
    /// @param tokenRecipient Address that receives the purchased tokens
    /// @param minTokensOut Minimum tokens expected to receive to protect against slippage
    function _buyInternal(address tokenRecipient, uint256 minTokensOut) internal {
        if (migrated) revert BagsBondingCurve_AlreadyMigrated();
        if (msg.value == 0) revert BagsBondingCurve_NoQuoteSent();
        if (!initialized) revert BagsBondingCurve_NotInitialized();

        uint256 quoteAvailable = msg.value;
        uint256 denom = BPS_DENOM;
        uint256 feeBps = TX_FEE_BPS;
        uint256 netFactor = denom - feeBps; // denominator for net after fee
        uint256 threshold = thresholdQuote;

        uint256 grossCap = quoteAvailable;
        if (realQuoteReserves < threshold) {
            uint256 missing = threshold - realQuoteReserves;
            uint256 grossNeeded = feeBps == 0 ? missing : (missing * denom + netFactor - 1) / netFactor;
            if (grossNeeded < grossCap) grossCap = grossNeeded;
        }

        uint256 feeQuote = (grossCap * feeBps) / denom;
        uint256 netIn = grossCap - feeQuote; // quote that actually hits the curve

        uint256 tokensOut = (_virtualTokenReserves * netIn) / (_virtualQuoteReserves + netIn);
        if (tokensOut < minTokensOut) {
            revert BagsBondingCurve_SlippageExceeded(minTokensOut, tokensOut);
        }

        _virtualQuoteReserves += netIn;
        _virtualTokenReserves -= tokensOut;

        realQuoteReserves += netIn;
        realTokenReserves -= tokensOut;

        IERC20(TOKEN).safeTransfer(tokenRecipient, tokensOut);

        uint256 vaultFee;
        uint256 creatorFee;
        if (feeQuote > 0) {
            (vaultFee, creatorFee) = _splitFee(feeQuote);
        }
        uint256 refund = quoteAvailable - grossCap;
        if (refund > 0) {
            (bool okRefund,) = msg.sender.call{value: refund}("");
            if (!okRefund) revert BagsBondingCurve_RefundTransferFailed(refund);
        }

        // Emit rich trade data for indexers/integrators.
        emit TokensBought(
            msg.sender,
            tokenRecipient,
            quoteAvailable,
            netIn,
            tokensOut,
            feeQuote,
            vaultFee,
            creatorFee,
            refund,
            currentPrice(),
            _virtualTokenReserves,
            _virtualQuoteReserves
        );

        if (realQuoteReserves >= threshold) {
            _migrate();
        }
    }

    /// @dev Shared internal sell logic for sell() and sellFor(). Tokens are pulled from msg.sender;
    ///      proceeds are paid to `recipient`.
    /// @param recipient Address that receives the quote proceeds
    /// @param tokensIn Amount of tokens to sell
    /// @param minQuoteOut Minimum quote expected to receive to protect against slippage
    function _sellInternal(address recipient, uint256 tokensIn, uint256 minQuoteOut) internal {
        if (migrated) revert BagsBondingCurve_AlreadyMigrated();
        if (tokensIn == 0) revert BagsBondingCurve_ZeroInputAmount();
        if (!initialized) revert BagsBondingCurve_NotInitialized();

        IERC20(TOKEN).safeTransferFrom(msg.sender, address(this), tokensIn);

        uint256 quoteOutNumerator = _virtualQuoteReserves * tokensIn;
        uint256 quoteOutDenominator = _virtualTokenReserves + tokensIn;
        uint256 quoteOut = quoteOutNumerator / quoteOutDenominator;
        uint256 fee = (quoteOutNumerator * TX_FEE_BPS) / (BPS_DENOM * quoteOutDenominator); // quote fee
        uint256 quoteToRecipient = quoteOut - fee;
        if (quoteToRecipient < minQuoteOut) {
            revert BagsBondingCurve_SlippageExceeded(minQuoteOut, quoteToRecipient);
        }

        _virtualTokenReserves += tokensIn;
        _virtualQuoteReserves -= quoteOut; // gross amount leaves virtual reserves

        realTokenReserves += tokensIn;
        realQuoteReserves -= quoteOut; // both recipient payout and fee leave the contract

        // Interactions: send to recipient and split fee between platform and creator
        (bool ok,) = recipient.call{value: quoteToRecipient}("");
        if (!ok) revert BagsBondingCurve_NativeTransferFailed(recipient, quoteToRecipient);
        uint256 vaultFee;
        uint256 creatorFee;
        if (fee > 0) {
            (vaultFee, creatorFee) = _splitFee(fee);
        }

        emit TokensSold(
            msg.sender,
            recipient,
            tokensIn,
            quoteOut,
            quoteToRecipient,
            fee,
            vaultFee,
            creatorFee,
            currentPrice(),
            _virtualTokenReserves,
            _virtualQuoteReserves
        );
    }

    /// @dev Splits a quote fee 50/50 between the protocol half and the creator half, then carves
    ///      the snapshotted partner share out of the PROTOCOL half (never the creator half):
    ///      - Creator half: wrapped to WETH, sent to FEE_SHARE, credited to claimers via notifyFee
    ///      - Partner cut (protocolHalf * partnerFeeBps / 10_000, floor): wrapped to WETH, sent to
    ///        FEE_SHARE, credited to the partner's pull-ledger via notifyPartnerFee (a reverting
    ///        partner address can therefore never block trading)
    ///      - Remainder of the protocol half: sent native to VAULT
    ///      Emits {FeesSplit}.
    /// @param feeQuote Total fee amount in quote wei
    /// @return vaultFee Amount actually sent to the vault (protocol half minus partner cut)
    /// @return creatorFee Creator share (WETH)
    function _splitFee(uint256 feeQuote) internal returns (uint256 vaultFee, uint256 creatorFee) {
        // Split fee 50/50 between protocol (VAULT + partner) and creator (FEE_SHARE)
        uint256 protocolHalf = feeQuote / 2;
        creatorFee = feeQuote - protocolHalf;

        // Carve the partner's snapshotted share out of the protocol half
        uint256 partnerCut;
        address partner_ = partner;
        if (partner_ != address(0) && partnerFeeBps != 0) {
            partnerCut = (protocolHalf * partnerFeeBps) / BPS_DENOM;
        }
        vaultFee = protocolHalf - partnerCut;

        // Send the protocol's remaining share as native quote
        (bool okVault,) = VAULT.call{value: vaultFee}("");
        if (!okVault) revert BagsBondingCurve_VaultFeeTransferFailed(vaultFee);

        // Wrap creator share + partner cut to WETH in one deposit, send to FeeShare, and notify
        IWETH9(WETH).deposit{value: creatorFee + partnerCut}();
        IERC20(WETH).safeTransfer(FEE_SHARE, creatorFee + partnerCut);
        IBagsFeeShare(FEE_SHARE).notifyFee(creatorFee);
        if (partnerCut > 0) {
            IBagsFeeShare(FEE_SHARE).notifyPartnerFee(partnerCut);
        }

        emit FeesSplit(msg.sender, VAULT, FEE_SHARE, vaultFee, creatorFee, partnerCut);
    }

    /// @dev Performs migration to Uniswap v4: initialize pool, mint full-range position for the
    ///      platform admin, pause and burn ownership.
    function _migrate() internal {
        migrated = true;

        uint256 lpQuote = thresholdQuote;

        // Validate liquidity inputs
        if (address(this).balance < lpQuote) {
            revert BagsBondingCurve_InsufficientQuoteForLP(address(this).balance, lpQuote);
        }
        // The integer floor of vQ0 = t*17/66 plus the crossing-buy grossNeeded ceiling can
        // over-sell up to ~1e11 token-wei past 830M (see docs/RESERVES.md "Rounding audit"),
        // so a pure-buy graduation path can leave the curve marginally short of the nominal
        // 170M LP allocation. Seed the LP with the actual balance when the shortfall is within
        // the verified dust bound; anything larger is a real failure and must revert.
        uint256 lpTokens = LP_TOKEN_AMOUNT;
        uint256 tokenBalance = IERC20(TOKEN).balanceOf(address(this));
        if (tokenBalance < LP_TOKEN_AMOUNT) {
            if (LP_TOKEN_AMOUNT - tokenBalance > ECONOMICS_DUST_TOLERANCE) {
                revert BagsBondingCurve_InsufficientTokenForLP(tokenBalance, LP_TOKEN_AMOUNT);
            }
            lpTokens = tokenBalance;
        }

        // Build PoolKey (sorted currencies). The shared hook drives the fee (dynamic flag).
        bool tokenIs0 = TOKEN < WETH;
        Currency c0 = Currency.wrap(tokenIs0 ? TOKEN : WETH);
        Currency c1 = Currency.wrap(tokenIs0 ? WETH : TOKEN);

        PoolKey memory key = PoolKey({
            currency0: c0,
            currency1: c1,
            fee: LPFeeLibrary.DYNAMIC_FEE_FLAG,
            tickSpacing: TICK_SPACING,
            hooks: HOOK
        });

        // Compute initial price from the current bonding curve virtual reserves.
        // This reduces MEV by aligning the AMM's initial price with the curve's prevailing price.
        uint256 amt0Initial = tokenIs0 ? _virtualTokenReserves : _virtualQuoteReserves;
        uint256 amt1Initial = tokenIs0 ? _virtualQuoteReserves : _virtualTokenReserves;
        uint160 sqrtPriceX96 = _sqrtPriceX96FromAmounts(amt0Initial, amt1Initial);

        // Initialize DIRECTLY on the PoolManager (the hook checks sender == this curve).
        // NEVER route through PositionManager.initializePool: it would present the wrong sender
        // to beforeInitialize and swallow the revert in a try/catch.
        POOL_MANAGER.initialize(key, sqrtPriceX96);

        // Wrap the LP quote amount into WETH; the PositionManager pulls both sides via Permit2.
        IWETH9(WETH).deposit{value: lpQuote}();

        uint160 sqrtPriceAtMinTick = TickMath.getSqrtPriceAtTick(MIN_TICK);
        uint160 sqrtPriceAtMaxTick = TickMath.getSqrtPriceAtTick(MAX_TICK);

        // Full amounts
        uint256 amt0All = tokenIs0 ? lpTokens : lpQuote;
        uint256 amt1All = tokenIs0 ? lpQuote : lpTokens;

        // Compute liquidity for full amounts
        uint128 liqAll = LiquidityAmounts.getLiquidityForAmounts(
            sqrtPriceX96, sqrtPriceAtMinTick, sqrtPriceAtMaxTick, amt0All, amt1All
        );

        // Hand-encoded payload: one mint then close both currencies.
        // (v4-periphery's Planner is test-only/UNLICENSED and must not be imported.)
        bytes memory actions = abi.encodePacked(
            uint8(Actions.MINT_POSITION), uint8(Actions.CLOSE_CURRENCY), uint8(Actions.CLOSE_CURRENCY)
        );
        bytes[] memory params = new bytes[](3);
        params[0] = abi.encode(
            key,
            MIN_TICK,
            MAX_TICK,
            uint256(liqAll),
            SafeCast.toUint128(amt0All),
            SafeCast.toUint128(amt1All),
            platformAdmin, // NFT recipient = platform treasury
            bytes("")
        );
        params[1] = abi.encode(key.currency0);
        params[2] = abi.encode(key.currency1);

        POSITION_MANAGER.modifyLiquidities(abi.encode(actions, params), block.timestamp + MIGRATION_DEADLINE_SECONDS);

        // Disable trading by pausing and disowning
        _pause();
        _transferOwnership(DEAD);

        PoolId poolId = key.toId();

        emit Migrated(creator, platformAdmin, TOKEN, lpQuote, lpTokens, poolId, sqrtPriceX96);
    }

    /// @dev Compute sqrtPriceX96 from token amounts with 18/18 decimals
    /// @param amountToken0 Amount of token0 (18 decimals)
    /// @param amountToken1 Amount of token1 (18 decimals)
    /// @return sqrtX96 sqrt(price) encoded as a Q64.96 fixed-point value
    function _sqrtPriceX96FromAmounts(
        uint256 amountToken0,
        uint256 amountToken1
    ) internal pure returns (uint160 sqrtX96) {
        if (amountToken0 == 0 || amountToken1 == 0) {
            revert BagsBondingCurve_InvalidAmounts(amountToken0, amountToken1);
        }
        // ratioX192 = (amount1 / amount0) * Q96 * Q96
        uint256 ratioX192 = FullMath.mulDiv(amountToken1, FixedPoint96.Q96 * FixedPoint96.Q96, amountToken0);
        sqrtX96 = SafeCast.toUint160(FixedPointMathLib.sqrt(ratioX192));
    }
}
