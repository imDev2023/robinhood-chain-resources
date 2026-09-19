// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {IHooks} from "v4-core/src/interfaces/IHooks.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {PoolId} from "v4-core/src/types/PoolId.sol";
import {Currency} from "v4-core/src/types/Currency.sol";
import {TickMath} from "v4-core/src/libraries/TickMath.sol";
import {LiquidityAmounts} from "v4-core/test/utils/LiquidityAmounts.sol";

import {LaunchHook} from "./LaunchHook.sol";
import {AnnouncementRegistry} from "./AnnouncementRegistry.sol";
import {VestingVault} from "./VestingVault.sol";

/// @title LaunchpadFactoryCore
/// @notice Shared genesis + governance for single-sided Uniswap v4 launchpads. Concrete factories provide the
///         token creation primitive while this core keeps quote registry, vesting, pool creation, seed math,
///         locked-liquidity invariants, fee configuration, and event emission consistent across chains.
abstract contract LaunchpadFactoryCore is Ownable2Step, ReentrancyGuard {
    using SafeERC20 for IERC20;

    uint256 internal constant BPS = 10_000;
    uint8 internal constant TOKEN_DECIMALS = 18;
    /// @notice Sentinel `upperOffset` meaning "extend to the furthest usable tick on the token side".
    int24 internal constant TAIL = type(int24).max;

    uint256 public constant MIN_SUPPLY = 1_000_000e18;
    uint256 public constant MAX_SUPPLY = 1_000_000_000_000e18;
    uint256 public constant MAX_ALLOCATIONS = 128;
    uint256 public constant MAX_VESTED_ALLOCATIONS = 64;
    /// @notice A vested schedule's first step must be at least this far out; must match VestingVault.MIN_VESTING_DURATION.
    uint32 public constant MIN_VESTING_DURATION = 1 days;
    /// @notice Cap on unlock steps per vested allocation; must match VestingVault.MAX_UNLOCK_POINTS.
    uint256 public constant MAX_VEST_STEPS = 24;
    /// @notice Transaction-wide cap on stored vesting points, bounding worst-case launch gas.
    uint256 public constant MAX_TOTAL_VEST_STEPS = 128;
    uint256 internal constant MAX_BANDS = 10;

    IPoolManager public immutable poolManager;
    LaunchHook public immutable hook;

    /// @notice A registered quote. `startTickToken0Frame` is the opening tick assuming the launch token sorts
    ///         as currency0; it is negated at launch when the token is currency1. This single per-quote dial
    ///         folds in the quote's decimals + USD price, so each quote can open at a consistent market cap.
    struct Quote {
        bool registered;
        uint8 decimals;
        int24 startTickToken0Frame;
        uint256 creationFee;
    }

    mapping(address => Quote) public quotes;

    /// @notice A band of the single-sided seed, as tick offsets from the start tick on the token side
    ///         (`lowerOffset` nearer spot, `upperOffset` farther; `TAIL` = to the usable edge) plus a share
    ///         of supply in bps. Reused across every quote; each launch freezes the template it used.
    struct Band {
        int24 lowerOffset;
        int24 upperOffset;
        uint16 bps;
    }

    Band[] internal bandTemplate;

    struct FeeDefaults {
        uint16 baseFeeBps;
        uint16 creatorBps;
        uint16 platformBps;
        uint16 referrerBps;
        uint16 antiSnipeStartTotalBps;
        uint32 antiSnipeWindowSeconds;
        address platformTreasury;
    }

    FeeDefaults public feeDefaults;

    uint256 public launchSupply;
    int24 public tickSpacing;
    address public announcementRegistry;
    address public vestingVault;
    uint64 public configVersion = 1;
    mapping(bytes32 => bool) public usedLaunchSalts;

    /// @notice One unlock step of a vested allocation: by `delay` seconds after launch, `cumulativeBps` of the
    ///         allocation is unlocked (cumulative, in basis points). Steps are strictly increasing in both fields
    ///         and the last step must reach 10000 (100%).
    struct VestStep {
        uint32 delay;
        uint16 cumulativeBps;
    }

    /// @notice A graduated allocation: `amount` of the launch token vesting to `beneficiary` over a step schedule
    ///         anchored to the launch timestamp. Each step says how much (cumulative %) is unlocked by `delay`
    ///         seconds after launch; nothing new unlocks between steps. The vault holds the tokens until claimed.
    struct VestAllocation {
        address beneficiary;
        uint256 amount;
        VestStep[] steps;
    }

    struct LaunchParams {
        string name;
        string symbol;
        string contractURI;
        bytes32 salt;
        address quote;
        address[] allocationRecipients;
        uint256[] allocationAmounts;
        VestAllocation[] vestedAllocations;
        uint64 expectedConfigVersion;
        uint64 deadline;
        uint8 roleMode;
        string[] metadataKeys;
        string[] metadataValues;
    }

    event QuoteRegistered(address indexed quote, uint8 decimals, int24 startTickToken0Frame);
    event QuoteCreationFeeUpdated(address indexed quote, uint256 creationFee);
    event QuoteUnregistered(address indexed quote);
    event BandTemplateUpdated(uint256 bands);
    /// @notice Emitted on every fee-default change. Carries the treasury + headline fee fields so that prospective
    ///         launchers and monitors can detect a hostile reconfiguration before launching.
    event FeeDefaultsUpdated(
        address indexed platformTreasury,
        uint16 baseFeeBps,
        uint16 antiSnipeStartTotalBps,
        uint32 antiSnipeWindowSeconds
    );
    event LaunchSupplyUpdated(uint256 oldSupply, uint256 newSupply);
    event TickSpacingUpdated(int24 oldSpacing, int24 newSpacing);
    event AnnouncementRegistryUpdated(address registry);
    event VestingVaultUpdated(address vault);
    event ConfigVersionUpdated(uint64 version);
    event Launched(
        address indexed token,
        PoolId indexed poolId,
        address indexed creator,
        address quote,
        uint256 supply,
        int24 tickSpacing
    );
    event LaunchFeePaid(address indexed payer, address indexed quote, address indexed treasury, uint256 amount);

    error InvalidConfig();
    error EmptyName();
    error QuoteNotRegistered();
    error QuoteAlreadyRegistered();
    error OutOfBounds();
    error TokenMismatch();
    error MisalignedOffset();
    error NotImmutable();
    error LaunchSaltUsed(bytes32 salt);
    error StaleConfig(uint64 expectedVersion, uint64 actualVersion);
    error LaunchExpired(uint64 deadline);
    error VestingVaultAlreadySet();
    error InvalidLaunchFeePayment();
    error LaunchFeeTransferFailed();

    /// @notice Genesis economics supplied explicitly at deploy. Each field is validated with the same logic as
    ///         its governance setter and stays tunable for future launches.
    struct InitConfig {
        uint256 launchSupply;
        int24 tickSpacing;
        FeeDefaults feeDefaults;
        Band[] bandTemplate;
    }

    constructor(IPoolManager _poolManager, LaunchHook _hook, InitConfig memory cfg) Ownable(msg.sender) {
        if (address(_poolManager) == address(0) || address(_hook) == address(0)) revert InvalidConfig();
        poolManager = _poolManager;
        hook = _hook;
        _setLaunchSupply(cfg.launchSupply);
        _applyTickSpacing(cfg.tickSpacing);
        _applyFeeDefaults(cfg.feeDefaults);
        _applyBandTemplate(cfg.bandTemplate);
    }

    // ============================================================
    //                          CREATE
    // ============================================================

    function createLaunch(LaunchParams calldata p)
        external
        payable
        nonReentrant
        returns (address token, PoolId poolId)
    {
        if (p.expectedConfigVersion != configVersion) {
            revert StaleConfig(p.expectedConfigVersion, configVersion);
        }
        // forge-lint: disable-next-line(block-timestamp) user-supplied transaction expiry, not economic timing
        if (block.timestamp > p.deadline) revert LaunchExpired(p.deadline);
        if (bytes(p.name).length == 0 || bytes(p.symbol).length == 0) revert EmptyName();
        Quote memory quoteConfig = quotes[p.quote];
        if (!quoteConfig.registered) revert QuoteNotRegistered();
        if (p.roleMode > 1) revert InvalidConfig();
        if (p.metadataKeys.length != p.metadataValues.length) revert InvalidConfig();
        for (uint256 i = 0; i < p.metadataKeys.length; i++) {
            if (bytes(p.metadataKeys[i]).length == 0) revert InvalidConfig();
        }

        _beforeCreateLaunch(p);

        uint256 supply = launchSupply;
        (uint256 immediateTotal, uint256 vestedTotal) = _validateAndSumAllocations(p, supply);
        if (immediateTotal + vestedTotal >= supply) revert InvalidConfig();
        uint256 poolSupply = supply - immediateTotal - vestedTotal;

        bytes32 salt = keccak256(abi.encode(msg.sender, p.salt));
        if (usedLaunchSalts[salt]) revert LaunchSaltUsed(salt);
        usedLaunchSalts[salt] = true;
        address predicted = _predictTokenAddress(p, salt, supply, poolSupply, msg.sender, vestedTotal);
        _validatePredictedToken(predicted);
        _collectCreationFee(p.quote, quoteConfig.creationFee);
        bool tokenIsCurrency0 = uint160(predicted) < uint160(p.quote);
        int24 spacing = tickSpacing;
        int24 startTick = _alignedStartTick(p.quote, tokenIsCurrency0, spacing);
        LaunchHook.SeedPosition[] memory positions = _resolveSeed(startTick, spacing, tokenIsCurrency0, poolSupply);

        token = _createToken(p, salt, supply, poolSupply, msg.sender, vestedTotal);
        if (token != predicted) revert TokenMismatch();
        _assertLaunchToken(token, msg.sender, p.roleMode);
        _registerVesting(p, token);

        poolId = _openAndSeed(p.quote, predicted, tokenIsCurrency0, startTick, spacing, positions);

        address registry = announcementRegistry;
        if (registry != address(0)) AnnouncementRegistry(registry).registerCreator(token, msg.sender);

        emit Launched(token, poolId, msg.sender, p.quote, supply, spacing);
    }

    function _collectCreationFee(address quote, uint256 amount) internal virtual {
        bool nativeQuote = quote == address(0);
        if (msg.value != (nativeQuote ? amount : 0)) revert InvalidLaunchFeePayment();
        if (amount == 0) return;

        address treasury = feeDefaults.platformTreasury;
        if (nativeQuote) {
            (bool ok,) = payable(treasury).call{value: amount}("");
            if (!ok) revert LaunchFeeTransferFailed();
        } else {
            IERC20 token = IERC20(quote);
            uint256 beforeFactoryBalance = token.balanceOf(address(this));
            token.safeTransferFrom(msg.sender, address(this), amount);
            if (token.balanceOf(address(this)) != beforeFactoryBalance + amount) revert InvalidLaunchFeePayment();

            uint256 beforeTreasuryBalance = token.balanceOf(treasury);
            token.safeTransfer(treasury, amount);
            if (token.balanceOf(treasury) != beforeTreasuryBalance + amount) revert InvalidLaunchFeePayment();
            if (token.balanceOf(address(this)) != beforeFactoryBalance) revert InvalidLaunchFeePayment();
        }

        emit LaunchFeePaid(msg.sender, quote, treasury, amount);
    }

    function _beforeCreateLaunch(LaunchParams calldata p) internal view virtual;

    function _predictTokenAddress(
        LaunchParams calldata p,
        bytes32 salt,
        uint256 supply,
        uint256 poolSupply,
        address creator,
        uint256 vestedTotal
    ) internal view virtual returns (address);

    function _createToken(
        LaunchParams calldata p,
        bytes32 salt,
        uint256 supply,
        uint256 poolSupply,
        address creator,
        uint256 vestedTotal
    ) internal virtual returns (address);

    function _assertLaunchToken(address token, address creator, uint8 roleMode) internal view virtual;

    function _validatePredictedToken(address) internal view virtual {}

    function _sumUpTo(uint256[] calldata xs, uint256 cap) internal pure returns (uint256 s) {
        for (uint256 i = 0; i < xs.length; i++) {
            if (xs[i] == 0 || xs[i] > cap || s > cap - xs[i]) revert InvalidConfig();
            s += xs[i];
        }
    }

    /// @notice Validate immediate + vested allocations and return their totals. Every recipient and beneficiary
    ///         must be distinct across both sets, non-zero, and never the hook / PoolManager / factory / vault.
    ///         Vested allocations require a configured vault and a non-zero amount; the vault validates each
    ///         schedule's shape on register.
    function _validateAndSumAllocations(LaunchParams calldata p, uint256 supply)
        internal
        view
        returns (uint256 immediateTotal, uint256 vestedTotal)
    {
        uint256 nImm = p.allocationRecipients.length;
        uint256 nVest = p.vestedAllocations.length;
        if (p.allocationAmounts.length != nImm) revert InvalidConfig();
        if (nImm + nVest > MAX_ALLOCATIONS) revert OutOfBounds();
        if (nVest > MAX_VESTED_ALLOCATIONS) revert OutOfBounds();
        if (nVest != 0 && vestingVault == address(0)) revert InvalidConfig();
        uint256 totalSteps;

        for (uint256 i = 0; i < nImm; i++) {
            address r = p.allocationRecipients[i];
            _checkRecipient(r);
            for (uint256 j = 0; j < i; j++) {
                if (p.allocationRecipients[j] == r) revert InvalidConfig();
            }
        }
        immediateTotal = _sumUpTo(p.allocationAmounts, supply);

        for (uint256 i = 0; i < nVest; i++) {
            address b = p.vestedAllocations[i].beneficiary;
            _checkRecipient(b);
            for (uint256 j = 0; j < i; j++) {
                if (p.vestedAllocations[j].beneficiary == b) revert InvalidConfig();
            }
            for (uint256 j = 0; j < nImm; j++) {
                if (p.allocationRecipients[j] == b) revert InvalidConfig();
            }
            uint256 amount = p.vestedAllocations[i].amount;
            if (amount == 0 || amount > supply || vestedTotal > supply - amount) revert InvalidConfig();
            totalSteps += p.vestedAllocations[i].steps.length;
            if (totalSteps > MAX_TOTAL_VEST_STEPS) revert OutOfBounds();
            _validateSteps(p.vestedAllocations[i].steps, amount);
            vestedTotal += amount;
        }
    }

    function _checkRecipient(address r) internal view {
        if (
            r == address(0) || r == address(hook) || r == address(poolManager) || r == address(this)
                || r == vestingVault
        ) revert InvalidConfig();
    }

    /// @notice Validate a vested allocation's step schedule and its rounded absolute token amounts.
    function _validateSteps(VestStep[] calldata steps, uint256 amount) internal pure {
        uint256 n = steps.length;
        if (n == 0 || n > MAX_VEST_STEPS) revert InvalidConfig();
        uint32 prevDelay;
        uint16 prevBps;
        uint256 prevAmount;
        for (uint256 i = 0; i < n; i++) {
            VestStep calldata st = steps[i];
            uint256 cumulativeAmount = amount * st.cumulativeBps / BPS;
            if (
                (i == 0 && st.delay < MIN_VESTING_DURATION) || (i != 0 && st.delay <= prevDelay)
                    || st.cumulativeBps <= prevBps || st.cumulativeBps > BPS || cumulativeAmount <= prevAmount
            ) {
                revert InvalidConfig();
            }
            prevDelay = st.delay;
            prevBps = st.cumulativeBps;
            prevAmount = cumulativeAmount;
        }
        if (prevBps != BPS || prevAmount != amount) revert InvalidConfig();
    }

    /// @notice Record each vested allocation's schedule with the vault. The locked tokens were already minted to
    ///         the vault in `_createToken`, so there is never a window where they are claimable but unregistered.
    function _registerVesting(LaunchParams calldata p, address token) internal {
        address vault = vestingVault;
        // forge-lint: disable-next-line(unsafe-typecast) practical chain timestamps are far below uint64 max
        uint64 launchTime = uint64(block.timestamp);
        for (uint256 i = 0; i < p.vestedAllocations.length; i++) {
            VestAllocation calldata v = p.vestedAllocations[i];
            uint256 n = v.steps.length;
            VestingVault.UnlockPoint[] memory pts = new VestingVault.UnlockPoint[](n);
            for (uint256 j = 0; j < n; j++) {
                pts[j] = VestingVault.UnlockPoint({
                    timestamp: launchTime + uint64(v.steps[j].delay),
                    // forge-lint: disable-next-line(unsafe-typecast) amount * bps / BPS <= amount <= uint128 max
                    cumulativeAmount: uint128(v.amount * v.steps[j].cumulativeBps / BPS)
                });
            }
            VestingVault(vault).register(token, v.beneficiary, v.amount, pts);
        }
    }

    function _openAndSeed(
        address quote,
        address token,
        bool tokenIsCurrency0,
        int24 startTick,
        int24 spacing,
        LaunchHook.SeedPosition[] memory positions
    ) internal returns (PoolId poolId) {
        (Currency c0, Currency c1) = tokenIsCurrency0
            ? (Currency.wrap(token), Currency.wrap(quote))
            : (Currency.wrap(quote), Currency.wrap(token));
        PoolKey memory key =
            PoolKey({currency0: c0, currency1: c1, fee: 0, tickSpacing: spacing, hooks: IHooks(address(hook))});

        int24 initTick = tokenIsCurrency0 ? startTick - spacing : startTick;
        if (initTick < TickMath.MIN_TICK || initTick > TickMath.MAX_TICK) revert OutOfBounds();
        poolManager.initialize(key, TickMath.getSqrtPriceAtTick(initTick));

        hook.registerPool(key, _poolConfig(tokenIsCurrency0));
        hook.seedLiquidity(key, positions, tokenIsCurrency0);

        poolId = key.toId();
    }

    function _poolConfig(bool tokenIsCurrency0) internal view returns (LaunchHook.PoolConfig memory) {
        FeeDefaults memory f = feeDefaults;
        return LaunchHook.PoolConfig({
            initialized: false,
            tokenIsCurrency0: tokenIsCurrency0,
            creator: msg.sender,
            platformTreasury: f.platformTreasury,
            baseFeeBps: f.baseFeeBps,
            creatorBps: f.creatorBps,
            platformBps: f.platformBps,
            referrerBps: f.referrerBps,
            antiSnipeStartTotalBps: f.antiSnipeStartTotalBps,
            antiSnipeWindowSeconds: f.antiSnipeWindowSeconds,
            launchTime: uint48(block.timestamp)
        });
    }

    function _alignedStartTick(address quote, bool tokenIsCurrency0, int24 spacing) internal view returns (int24) {
        int24 frame = quotes[quote].startTickToken0Frame;
        int24 startTick = tokenIsCurrency0 ? frame : -frame;
        // forge-lint: disable-next-line(divide-before-multiply) the truncation IS the alignment
        return (startTick / spacing) * spacing;
    }

    /// @notice Resolve the band template into absolute positions for this launch's ordering and supply.
    function _resolveSeed(int24 startTick, int24 spacing, bool tokenIsCurrency0, uint256 supply)
        internal
        view
        returns (LaunchHook.SeedPosition[] memory positions)
    {
        Band[] memory tmpl = bandTemplate;
        positions = new LaunchHook.SeedPosition[](tmpl.length);
        // forge-lint: disable-next-line(divide-before-multiply) the truncation IS the alignment
        int24 maxUsable = (TickMath.MAX_TICK / spacing) * spacing;
        // forge-lint: disable-next-line(divide-before-multiply) the truncation IS the alignment
        int24 minUsable = (TickMath.MIN_TICK / spacing) * spacing;

        for (uint256 i = 0; i < tmpl.length; i++) {
            if (tmpl[i].lowerOffset % spacing != 0) revert MisalignedOffset();
            if (tmpl[i].upperOffset != TAIL && tmpl[i].upperOffset % spacing != 0) revert MisalignedOffset();

            int24 tickLower;
            int24 tickUpper;
            if (tokenIsCurrency0) {
                tickLower = startTick + tmpl[i].lowerOffset;
                tickUpper = tmpl[i].upperOffset == TAIL ? maxUsable : startTick + tmpl[i].upperOffset;
            } else {
                tickUpper = startTick - tmpl[i].lowerOffset;
                tickLower = tmpl[i].upperOffset == TAIL ? minUsable : startTick - tmpl[i].upperOffset;
            }
            if (tickLower >= tickUpper) revert OutOfBounds();

            uint256 amount = supply * tmpl[i].bps / BPS;
            uint160 sqrtA = TickMath.getSqrtPriceAtTick(tickLower);
            uint160 sqrtB = TickMath.getSqrtPriceAtTick(tickUpper);
            uint128 liquidity = tokenIsCurrency0
                ? LiquidityAmounts.getLiquidityForAmount0(sqrtA, sqrtB, amount)
                : LiquidityAmounts.getLiquidityForAmount1(sqrtA, sqrtB, amount);
            if (liquidity == 0 || liquidity >= uint128(type(int128).max)) revert OutOfBounds();

            positions[i] = LaunchHook.SeedPosition({tickLower: tickLower, tickUpper: tickUpper, liquidity: liquidity});
        }
    }

    // ============================================================
    //                       GOVERNANCE (future launches only)
    // ============================================================

    function registerQuote(address quote, int24 startTickToken0Frame) public virtual onlyOwner nonReentrant {
        if (quotes[quote].registered) revert QuoteAlreadyRegistered();
        _validateStartTickFrame(startTickToken0Frame);
        uint8 dec = quote == address(0) ? 18 : IERC20Metadata(quote).decimals();
        quotes[quote] =
            Quote({registered: true, decimals: dec, startTickToken0Frame: startTickToken0Frame, creationFee: 0});
        _bumpConfigVersion();
        emit QuoteRegistered(quote, dec, startTickToken0Frame);
    }

    function setQuoteStartTick(address quote, int24 startTickToken0Frame) public virtual onlyOwner nonReentrant {
        if (!quotes[quote].registered) revert QuoteNotRegistered();
        if (startTickToken0Frame == quotes[quote].startTickToken0Frame) return;
        _validateStartTickFrame(startTickToken0Frame);
        quotes[quote].startTickToken0Frame = startTickToken0Frame;
        _bumpConfigVersion();
        emit QuoteRegistered(quote, quotes[quote].decimals, startTickToken0Frame);
    }

    function setQuoteCreationFee(address quote, uint256 creationFee) public virtual onlyOwner nonReentrant {
        if (!quotes[quote].registered) revert QuoteNotRegistered();
        if (creationFee == quotes[quote].creationFee) return;
        quotes[quote].creationFee = creationFee;
        _bumpConfigVersion();
        emit QuoteCreationFeeUpdated(quote, creationFee);
    }

    function unregisterQuote(address quote) public virtual onlyOwner nonReentrant {
        if (!quotes[quote].registered) revert QuoteNotRegistered();
        delete quotes[quote];
        _bumpConfigVersion();
        emit QuoteUnregistered(quote);
    }

    function setBandTemplate(Band[] calldata newBands) external onlyOwner nonReentrant {
        _applyBandTemplate(newBands);
        _bumpConfigVersion();
    }

    /// @dev Validate + store the seed band template. Shared by the constructor and the governance setter.
    function _applyBandTemplate(Band[] memory newBands) internal {
        if (newBands.length == 0 || newBands.length > MAX_BANDS) revert OutOfBounds();
        if (newBands[0].lowerOffset != 0) revert InvalidConfig();
        uint256 totalBps;
        int24 spacing = tickSpacing;
        for (uint256 i = 0; i < newBands.length; i++) {
            bool isTail = newBands[i].upperOffset == TAIL;
            if (
                newBands[i].lowerOffset < 0 || newBands[i].bps == 0 || (isTail && i != newBands.length - 1)
                    || (!isTail && newBands[i].upperOffset <= newBands[i].lowerOffset)
            ) {
                revert InvalidConfig();
            }
            if (newBands[i].lowerOffset % spacing != 0 || (!isTail && newBands[i].upperOffset % spacing != 0)) {
                revert MisalignedOffset();
            }
            totalBps += newBands[i].bps;
        }
        if (totalBps != BPS) revert InvalidConfig();
        delete bandTemplate;
        for (uint256 i = 0; i < newBands.length; i++) {
            bandTemplate.push(newBands[i]);
        }
        emit BandTemplateUpdated(newBands.length);
    }

    function setFeeDefaults(FeeDefaults calldata f) external onlyOwner nonReentrant {
        if (keccak256(abi.encode(f)) == keccak256(abi.encode(feeDefaults))) return;
        _applyFeeDefaults(f);
        _bumpConfigVersion();
    }

    /// @dev Validate + store the fee defaults. Shared by the constructor and the governance setter.
    function _applyFeeDefaults(FeeDefaults memory f) internal {
        if (f.baseFeeBps > hook.MAX_BASE_FEE_BPS()) revert OutOfBounds();
        if (uint256(f.creatorBps) + f.platformBps + f.referrerBps != BPS) revert InvalidConfig();
        if (f.antiSnipeStartTotalBps < f.baseFeeBps || f.antiSnipeStartTotalBps > hook.MAX_TOTAL_FEE_BPS()) {
            revert OutOfBounds();
        }
        if (f.antiSnipeWindowSeconds == 0 || f.platformTreasury == address(0)) revert InvalidConfig();
        feeDefaults = f;
        emit FeeDefaultsUpdated(f.platformTreasury, f.baseFeeBps, f.antiSnipeStartTotalBps, f.antiSnipeWindowSeconds);
    }

    function setLaunchSupply(uint256 supply) external onlyOwner nonReentrant {
        if (supply == launchSupply) return;
        _setLaunchSupply(supply);
        _bumpConfigVersion();
    }

    function setTickSpacing(int24 spacing) external onlyOwner nonReentrant {
        if (spacing == tickSpacing) return;
        _applyTickSpacing(spacing);
        _bumpConfigVersion();
    }

    /// @dev Validate + store the tick spacing. Shared by the constructor and the governance setter.
    function _applyTickSpacing(int24 spacing) internal {
        if (spacing <= 0 || spacing > 16_384) revert OutOfBounds();
        for (uint256 i = 0; i < bandTemplate.length; i++) {
            if (
                bandTemplate[i].lowerOffset % spacing != 0
                    || (bandTemplate[i].upperOffset != TAIL && bandTemplate[i].upperOffset % spacing != 0)
            ) revert MisalignedOffset();
        }
        emit TickSpacingUpdated(tickSpacing, spacing);
        tickSpacing = spacing;
    }

    function setAnnouncementRegistry(address registry) external onlyOwner nonReentrant {
        if (registry == announcementRegistry) return;
        if (registry != address(0)) {
            if (registry.code.length == 0 || AnnouncementRegistry(registry).factory() != address(this)) {
                revert InvalidConfig();
            }
        }
        announcementRegistry = registry;
        _bumpConfigVersion();
        emit AnnouncementRegistryUpdated(registry);
    }

    function setVestingVault(address vault) external onlyOwner nonReentrant {
        if (vestingVault != address(0)) revert VestingVaultAlreadySet();
        if (vault == address(0) || vault.codehash != keccak256(type(VestingVault).runtimeCode)) {
            revert InvalidConfig();
        }
        VestingVault candidate = VestingVault(vault);
        if (
            candidate.factory() != address(this) || candidate.MAX_UNLOCK_POINTS() != MAX_VEST_STEPS
                || candidate.MIN_VESTING_DURATION() != MIN_VESTING_DURATION
        ) {
            revert InvalidConfig();
        }
        vestingVault = vault;
        _bumpConfigVersion();
        emit VestingVaultUpdated(vault);
    }

    function bands() external view returns (Band[] memory) {
        return bandTemplate;
    }

    function _setLaunchSupply(uint256 supply) internal {
        if (supply < MIN_SUPPLY || supply > MAX_SUPPLY) revert OutOfBounds();
        emit LaunchSupplyUpdated(launchSupply, supply);
        launchSupply = supply;
    }

    /// @dev Reserve one `tickSpacing` of headroom from both tick extremes.
    function _validateStartTickFrame(int24 frame) internal view {
        int24 spacing = tickSpacing;
        if (frame < TickMath.MIN_TICK + spacing || frame > TickMath.MAX_TICK - spacing) revert OutOfBounds();
    }

    function _bumpConfigVersion() internal {
        configVersion++;
        emit ConfigVersionUpdated(configVersion);
    }
}
