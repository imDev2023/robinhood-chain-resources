// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {PoolKey} from "v4-core/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "v4-core/types/PoolId.sol";
import {SwapParams, ModifyLiquidityParams} from "v4-core/types/PoolOperation.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary, toBeforeSwapDelta} from "v4-core/types/BeforeSwapDelta.sol";
import {BalanceDelta, BalanceDeltaLibrary} from "v4-core/types/BalanceDelta.sol";
import {Currency} from "v4-core/types/Currency.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {IHooks} from "v4-core/interfaces/IHooks.sol";
import {LPFeeLibrary} from "v4-core/libraries/LPFeeLibrary.sol";
import {StateLibrary} from "v4-core/libraries/StateLibrary.sol";
import {TransientStateLibrary} from "v4-core/libraries/TransientStateLibrary.sol";
import {TickMath} from "v4-core/libraries/TickMath.sol";
import {FullMath} from "v4-core/libraries/FullMath.sol";
import {FixedPoint96} from "v4-core/libraries/FixedPoint96.sol";

interface IERC20Minimal_ {
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

interface ISentryFactoryConfig {
    function feeRecipientOf(address token) external view returns (address);
    function treasury() external view returns (address);
}

interface IDividendToken {
    function notifyReward() external;
}

/**
 * @title SentryStockFeeHookV3
 * @notice Third-generation Sentry launch hook. Base-asset agnostic: works
 * for a tokenized-stock pair (reflections paid in the stock) or a WETH
 * pair (reflections paid in WETH). The factory registers which side is
 * the base via setLaunchWhitelist BEFORE initialization.
 *
 * ── What changed vs V2 ────────────────────────────────────────────────
 *  1. Floor fee 1.25% -> 1.70%, matching the market standard.
 *  2. EVERY component now scales with the decay curve. V2 paid a FLAT
 *     reflection regardless of the fee; V3 splits the current fee by
 *     fixed proportions, so a 40% launch swap distributes 40%.
 *  3. Reflections do NOT start until `reflectionStartDelay` after launch.
 *     During the opening window the only buyers are snipers and
 *     whitelisted launch wallets, so paying "holders" would just pay the
 *     snipers. That window's fee goes to creator / treasury / LP instead.
 *  4. The creator/treasury split is IMMUTABLE here rather than read from
 *     the factory's global creatorFeeBps, so tuning this hook can never
 *     disturb tokens launched on earlier hooks.
 *
 * ── Distribution ──────────────────────────────────────────────────────
 * Every share below is bps OF THE CURRENT CURVE FEE. The swapper always
 * pays exactly the curve rate; these only decide where it goes.
 *
 *   before reflectionStartDelay:  creator earlyCreatorBps
 *                                 treasury earlyTreasuryBps
 *                                 LP       remainder
 *   after  reflectionStartDelay:  reflect  lateReflectionBps
 *                                 creator  lateCreatorBps
 *                                 LP       lateLpBps
 *                                 treasury remainder   (absorbs rounding)
 *
 * At the shipped config (endFee 1.7%, delay 600s, early 5000/2500,
 * late 4706/2941/1176) that is:
 *
 *   t < 10m, fee 40%  -> creator 20.00%  treasury 10.00%  LP 10.00%
 *   t >= 10m, floor   -> reflect 0.80%  creator 0.50%  treasury 0.20%  LP 0.20%
 *
 * The LP share accrues in the base asset and is compounded into
 * permanently-locked full-range liquidity by compound(). The minted
 * position is owned by this hook and has no withdrawal path.
 *
 * Hook address: low 14 bits must equal FLAGS (0x30CC), mined via CREATE2.
 *
 * NOTE: return-delta accounting that moves real value. Covered by fork
 * tests; independently audit before it carries meaningful volume.
 */
contract SentryStockFeeHookV3 {
    using PoolIdLibrary for PoolKey;
    using BalanceDeltaLibrary for BalanceDelta;

    /* ─────────────────────────── Config ─────────────────────────── */

    address public immutable poolManager;
    address public immutable factory;

    uint24 public immutable startFee;
    uint24 public immutable endFee;
    uint256 public immutable holdDuration;
    uint256 public immutable halfLife;

    /// @notice Seconds after launch before holder reflections switch on.
    uint256 public immutable reflectionStartDelay;

    /// @notice Pre-reflection window: shares of the fee, in bps.
    uint24 public immutable earlyCreatorBps;
    uint24 public immutable earlyTreasuryBps;

    /// @notice Post-reflection window: shares of the fee, in bps.
    /// Treasury takes the remainder so the split always sums exactly.
    uint24 public immutable lateReflectionBps;
    uint24 public immutable lateCreatorBps;
    uint24 public immutable lateLpBps;

    uint256 private constant PIPS = 1_000_000;
    uint256 private constant BPS = 10_000;

    mapping(PoolId => uint256) public launchedAt;
    mapping(PoolId => mapping(address => bool)) public launchWhitelist;
    mapping(PoolId => bool) public baseIsCurrency0;
    mapping(PoolId => bool) public baseSideRegistered;
    mapping(PoolId => uint256) public lpAccruedBase;
    mapping(PoolId => PoolKey) internal poolKeyOf;
    bool private compounding;

    uint160 internal constant FLAGS = 0x30CC;

    event LaunchRecorded(PoolId indexed poolId, uint256 timestamp);
    event LaunchWhitelistSet(PoolId indexed poolId, uint256 count);
    event AppFeePaid(
        address indexed token, address indexed recipient, bool isBuy, uint256 creatorAmount, uint256 treasuryAmount
    );
    event ReflectionPaid(address indexed token, address indexed base, uint256 amount);
    event LpFeeAccrued(PoolId indexed poolId, uint256 amount);
    event LpCompounded(PoolId indexed poolId, uint256 baseSpent, uint128 liquidityAdded);

    error NotPoolManager();
    error NotFactory();
    error NotDynamicFee();
    error InvalidFeeConfig();
    error PoolAlreadyLaunched();
    error BaseNotRegistered();
    error BadHookAddress();
    error FeeOverflow();
    error NothingToCompound();
    error DecayStillActive();
    error Reentrancy();

    constructor(
        address _poolManager,
        address _factory,
        uint24 _startFee,
        uint24 _endFee,
        uint256 _holdDuration,
        uint256 _halfLife,
        uint256 _reflectionStartDelay,
        uint24 _earlyCreatorBps,
        uint24 _earlyTreasuryBps,
        uint24 _lateReflectionBps,
        uint24 _lateCreatorBps,
        uint24 _lateLpBps
    ) {
        if (_poolManager == address(0) || _factory == address(0)) revert InvalidFeeConfig();
        if (_startFee > LPFeeLibrary.MAX_LP_FEE || _endFee > _startFee || _endFee == 0 || _halfLife == 0) {
            revert InvalidFeeConfig();
        }
        // Each window's named shares must leave a non-negative remainder
        // for the share that absorbs it (LP early, treasury late).
        if (uint256(_earlyCreatorBps) + _earlyTreasuryBps > BPS) revert InvalidFeeConfig();
        if (uint256(_lateReflectionBps) + _lateCreatorBps + _lateLpBps > BPS) revert InvalidFeeConfig();
        if (uint160(address(this)) & 0x3FFF != FLAGS) revert BadHookAddress();

        poolManager = _poolManager;
        factory = _factory;
        startFee = _startFee;
        endFee = _endFee;
        holdDuration = _holdDuration;
        halfLife = _halfLife;
        reflectionStartDelay = _reflectionStartDelay;
        earlyCreatorBps = _earlyCreatorBps;
        earlyTreasuryBps = _earlyTreasuryBps;
        lateReflectionBps = _lateReflectionBps;
        lateCreatorBps = _lateCreatorBps;
        lateLpBps = _lateLpBps;
    }

    modifier onlyPoolManager() {
        if (msg.sender != poolManager) revert NotPoolManager();
        _;
    }

    /* ─────────────────────── Hook entrypoints ───────────────────── */

    function beforeInitialize(address sender, PoolKey calldata key, uint160)
        external
        view
        onlyPoolManager
        returns (bytes4)
    {
        if (sender != factory) revert NotFactory();
        if (key.fee != LPFeeLibrary.DYNAMIC_FEE_FLAG) revert NotDynamicFee();
        if (!baseSideRegistered[key.toId()]) revert BaseNotRegistered();
        return IHooks.beforeInitialize.selector;
    }

    function afterInitialize(address, PoolKey calldata key, uint160, int24)
        external
        onlyPoolManager
        returns (bytes4)
    {
        PoolId id = key.toId();
        launchedAt[id] = block.timestamp;
        poolKeyOf[id] = key;
        emit LaunchRecorded(id, block.timestamp);
        return IHooks.afterInitialize.selector;
    }

    function beforeSwap(address, PoolKey calldata key, SwapParams calldata params, bytes calldata)
        external
        onlyPoolManager
        returns (bytes4, BeforeSwapDelta, uint24)
    {
        uint24 lpOverride = LPFeeLibrary.OVERRIDE_FEE_FLAG; // pool LP fee 0
        PoolId id = key.toId();

        if (!_baseIsSpecified(id, params)) {
            return (IHooks.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, lpOverride);
        }
        uint256 specified =
            params.amountSpecified < 0 ? uint256(-params.amountSpecified) : uint256(params.amountSpecified);
        uint256 total = _skim(id, key, params, specified);
        if (total == 0) {
            return (IHooks.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, lpOverride);
        }
        return (IHooks.beforeSwap.selector, toBeforeSwapDelta(_toInt128(total), 0), lpOverride);
    }

    function afterSwap(address, PoolKey calldata key, SwapParams calldata params, BalanceDelta delta, bytes calldata)
        external
        onlyPoolManager
        returns (bytes4, int128)
    {
        PoolId id = key.toId();
        if (_baseIsSpecified(id, params)) return (IHooks.afterSwap.selector, 0);

        int128 baseDelta = baseIsCurrency0[id] ? delta.amount0() : delta.amount1();
        uint256 baseAbs = baseDelta < 0 ? uint256(uint128(-baseDelta)) : uint256(uint128(baseDelta));
        uint256 total = _skim(id, key, params, baseAbs);
        if (total == 0) return (IHooks.afterSwap.selector, 0);
        return (IHooks.afterSwap.selector, _toInt128(total));
    }

    /// @dev Skim exactly the curve rate and split it by window. Returns
    /// the total skimmed, which the swapper covers via the returned delta.
    function _skim(PoolId id, PoolKey calldata key, SwapParams calldata params, uint256 baseAmount)
        internal
        returns (uint256 total)
    {
        total = (baseAmount * _rate(id, params)) / PIPS;
        if (total == 0) return 0;

        uint256 reflection;
        uint256 creatorCut;
        uint256 treasuryCut;
        uint256 lpCut;

        if (block.timestamp < launchedAt[id] + reflectionStartDelay) {
            // Opening window: no reflections — holders here are snipers.
            creatorCut = (total * earlyCreatorBps) / BPS;
            treasuryCut = (total * earlyTreasuryBps) / BPS;
            lpCut = total - creatorCut - treasuryCut;
        } else {
            reflection = (total * lateReflectionBps) / BPS;
            creatorCut = (total * lateCreatorBps) / BPS;
            lpCut = (total * lateLpBps) / BPS;
            treasuryCut = total - reflection - creatorCut - lpCut;
        }

        if (creatorCut > 0 || treasuryCut > 0) _payOut(id, key, creatorCut, treasuryCut, _isBuy(id, params));
        if (reflection > 0) _payReflection(id, key, reflection);
        if (lpCut > 0) {
            IPoolManager(poolManager).take(_baseCurrency(id, key), address(this), lpCut);
            lpAccruedBase[id] += lpCut;
            emit LpFeeAccrued(id, lpCut);
        }
    }

    /* ─────────────────────── Launch whitelist ───────────────────── */

    function setLaunchWhitelist(PoolId poolId, bool _baseIsCurrency0, address[] calldata wallets) external {
        if (msg.sender != factory) revert NotFactory();
        if (launchedAt[poolId] != 0) revert PoolAlreadyLaunched();
        baseIsCurrency0[poolId] = _baseIsCurrency0;
        baseSideRegistered[poolId] = true;
        for (uint256 i = 0; i < wallets.length; i++) {
            launchWhitelist[poolId][wallets[i]] = true;
        }
        emit LaunchWhitelistSet(poolId, wallets.length);
    }

    /* ─────────────────────────── Rate ───────────────────────────── */

    function _rate(PoolId id, SwapParams calldata params) internal view returns (uint256) {
        uint24 fee = currentFee(id);
        if (fee != endFee && launchWhitelist[id][tx.origin] && params.zeroForOne == baseIsCurrency0[id]) {
            fee = endFee;
        }
        return uint256(fee);
    }

    function currentFee(PoolId poolId) public view returns (uint24) {
        uint256 t0 = launchedAt[poolId];
        if (t0 == 0) return endFee;
        if (block.timestamp <= t0) return startFee;
        return _feeAtElapsed(block.timestamp - t0);
    }

    function feeAtElapsed(uint256 elapsed) external view returns (uint24) {
        return _feeAtElapsed(elapsed);
    }

    function _feeAtElapsed(uint256 elapsed) internal view returns (uint24) {
        if (elapsed <= holdDuration) return startFee;
        uint256 decayElapsed = elapsed - holdDuration;
        uint256 n = decayElapsed / halfLife;
        if (n >= 24) return endFee;
        uint256 feeHigh = uint256(startFee) >> n;
        if (feeHigh <= endFee) return endFee;
        uint256 feeLow = feeHigh >> 1;
        uint256 rem = decayElapsed % halfLife;
        uint256 fee = feeHigh - ((feeHigh - feeLow) * rem) / halfLife;
        if (fee < endFee) fee = endFee;
        return uint24(fee);
    }

    /* ─────────────────────── Fee payout ─────────────────────────── */

    function _payOut(PoolId id, PoolKey calldata key, uint256 creatorCut, uint256 treasuryCut, bool isBuy) internal {
        address token = _campaignToken(id, key);
        Currency base = _baseCurrency(id, key);

        address recipient = ISentryFactoryConfig(factory).feeRecipientOf(token);
        address treasury = ISentryFactoryConfig(factory).treasury();

        // A zero recipient forfeits the creator share to treasury rather
        // than burning it.
        if (recipient == address(0)) {
            treasuryCut += creatorCut;
            creatorCut = 0;
        }
        if (creatorCut > 0) IPoolManager(poolManager).take(base, recipient, creatorCut);
        if (treasuryCut > 0) IPoolManager(poolManager).take(base, treasury, treasuryCut);
        emit AppFeePaid(token, recipient, isBuy, creatorCut, treasuryCut);
    }

    function _payReflection(PoolId id, PoolKey calldata key, uint256 amount) internal {
        address token = _campaignToken(id, key);
        Currency base = _baseCurrency(id, key);
        IPoolManager(poolManager).take(base, token, amount);
        IDividendToken(token).notifyReward();
        emit ReflectionPaid(token, Currency.unwrap(base), amount);
    }

    /* ────────────────────── LP compounding ──────────────────────── */

    function compound(PoolId id) external returns (uint128 liquidityAdded) {
        if (compounding) revert Reentrancy();
        if (launchedAt[id] == 0) revert BaseNotRegistered();
        if (currentFee(id) != endFee) revert DecayStillActive();
        if (lpAccruedBase[id] == 0) revert NothingToCompound();
        compounding = true;
        bytes memory result = IPoolManager(poolManager).unlock(abi.encode(id));
        compounding = false;
        liquidityAdded = abi.decode(result, (uint128));
    }

    function unlockCallback(bytes calldata data) external onlyPoolManager returns (bytes memory) {
        PoolId id = abi.decode(data, (PoolId));
        PoolKey memory key = poolKeyOf[id];
        bool baseIs0 = baseIsCurrency0[id];
        Currency base = baseIs0 ? key.currency0 : key.currency1;
        Currency tokenCur = baseIs0 ? key.currency1 : key.currency0;

        uint256 budget = lpAccruedBase[id];
        lpAccruedBase[id] = 0;

        uint256 half = budget / 2;
        IPoolManager(poolManager).swap(
            key,
            SwapParams({
                zeroForOne: baseIs0,
                amountSpecified: -int256(half),
                sqrtPriceLimitX96: baseIs0 ? TickMath.MIN_SQRT_PRICE + 1 : TickMath.MAX_SQRT_PRICE - 1
            }),
            ""
        );

        (uint160 sqrtP,,,) = StateLibrary.getSlot0(IPoolManager(poolManager), id);
        int24 tickLo = (TickMath.MIN_TICK / key.tickSpacing) * key.tickSpacing;
        int24 tickHi = (TickMath.MAX_TICK / key.tickSpacing) * key.tickSpacing;

        int256 tokenCredit = TransientStateLibrary.currencyDelta(IPoolManager(poolManager), address(this), tokenCur);
        uint256 tokenAvail = tokenCredit > 0 ? uint256(tokenCredit) : 0;
        uint256 baseAvail = budget - half;
        uint256 amt0 = baseIs0 ? baseAvail : tokenAvail;
        uint256 amt1 = baseIs0 ? tokenAvail : baseAvail;
        if (amt0 > 0) amt0 -= 1;
        if (amt1 > 0) amt1 -= 1;

        uint128 liquidity = _liquidityForAmounts(
            sqrtP, TickMath.getSqrtPriceAtTick(tickLo), TickMath.getSqrtPriceAtTick(tickHi), amt0, amt1
        );
        if (liquidity > 0) {
            IPoolManager(poolManager).modifyLiquidity(
                key,
                ModifyLiquidityParams({
                    tickLower: tickLo,
                    tickUpper: tickHi,
                    liquidityDelta: int256(uint256(liquidity)),
                    salt: bytes32(0)
                }),
                ""
            );
        }

        uint256 baseSpent = _settle(base);
        _settle(tokenCur);
        if (baseSpent < budget) lpAccruedBase[id] += budget - baseSpent;
        emit LpCompounded(id, baseSpent, liquidity);
        return abi.encode(liquidity);
    }

    function _settle(Currency cur) internal returns (uint256 paid) {
        int256 delta = TransientStateLibrary.currencyDelta(IPoolManager(poolManager), address(this), cur);
        if (delta < 0) {
            paid = uint256(-delta);
            IPoolManager(poolManager).sync(cur);
            IERC20Minimal_(Currency.unwrap(cur)).transfer(poolManager, paid);
            IPoolManager(poolManager).settle();
        } else if (delta > 0) {
            IPoolManager(poolManager).take(cur, address(this), uint256(delta));
        }
    }

    function _liquidityForAmounts(uint160 sqrtP, uint160 sqrtLo, uint160 sqrtHi, uint256 amt0, uint256 amt1)
        internal
        pure
        returns (uint128)
    {
        if (sqrtP <= sqrtLo) return _liquidity0(amt0, sqrtLo, sqrtHi);
        else if (sqrtP < sqrtHi) {
            uint128 l0 = _liquidity0(amt0, sqrtP, sqrtHi);
            uint128 l1 = _liquidity1(amt1, sqrtLo, sqrtP);
            return l0 < l1 ? l0 : l1;
        } else {
            return _liquidity1(amt1, sqrtLo, sqrtHi);
        }
    }

    function _liquidity0(uint256 amt0, uint160 sqrtA, uint160 sqrtB) internal pure returns (uint128) {
        if (sqrtA > sqrtB) (sqrtA, sqrtB) = (sqrtB, sqrtA);
        uint256 intermediate = FullMath.mulDiv(sqrtA, sqrtB, FixedPoint96.Q96);
        return uint128(FullMath.mulDiv(amt0, intermediate, sqrtB - sqrtA));
    }

    function _liquidity1(uint256 amt1, uint160 sqrtA, uint160 sqrtB) internal pure returns (uint128) {
        if (sqrtA > sqrtB) (sqrtA, sqrtB) = (sqrtB, sqrtA);
        return uint128(FullMath.mulDiv(amt1, FixedPoint96.Q96, sqrtB - sqrtA));
    }

    /* ─────────────────────────── Helpers ────────────────────────── */

    function _baseIsSpecified(PoolId id, SwapParams calldata params) internal view returns (bool) {
        bool specifiedIsCurrency0 = (params.amountSpecified < 0) == params.zeroForOne;
        return specifiedIsCurrency0 == baseIsCurrency0[id];
    }

    function _isBuy(PoolId id, SwapParams calldata params) internal view returns (bool) {
        return params.zeroForOne == baseIsCurrency0[id];
    }

    function _baseCurrency(PoolId id, PoolKey calldata key) internal view returns (Currency) {
        return baseIsCurrency0[id] ? key.currency0 : key.currency1;
    }

    function _campaignToken(PoolId id, PoolKey calldata key) internal view returns (address) {
        return baseIsCurrency0[id] ? Currency.unwrap(key.currency1) : Currency.unwrap(key.currency0);
    }

    function _toInt128(uint256 x) internal pure returns (int128) {
        if (x > uint256(int256(type(int128).max))) revert FeeOverflow();
        return int128(int256(x));
    }
}
