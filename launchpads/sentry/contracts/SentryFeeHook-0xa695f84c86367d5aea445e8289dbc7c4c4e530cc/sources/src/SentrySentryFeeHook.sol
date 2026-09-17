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

interface IReflectionToken {
    function notifyReward() external;
}

interface IMigrationLock {
    function migrationLocked(address) external view returns (bool);
    function unlockTime() external view returns (uint256);
}

/**
 * @title SentrySentryFeeHook
 * @notice The bespoke v4 hook for the SENTRY relaunch pool on Robinhood
 * Chain. Same decay curve and launch whitelist as every other Sentry hook,
 * but the entire fee is carved three ways and NONE of it is an app fee —
 * this token's fee IS its tokenomics:
 *
 *   reflectionShareBps  → WETH, sent to the token contract and distributed
 *                         to every holder pro-rata (notifyReward()).
 *   lpShareBps          → WETH, accrues here and compounds into
 *                         permanently-locked full-range liquidity.
 *   treasuryShareBps    → SENTRY, taken from the token side of the swap and
 *                         sent to the treasury multisig. The treasury is the
 *                         only address that continuously accumulates SENTRY.
 *
 * The three shares are fractions OF THE CURRENT CURVE FEE and must sum to
 * 10_000 bps, so they ride the decay together: at the 40% launch fee the
 * split is 15% / 15% / 10% of the swap, and at the 2% floor it is
 * 0.75% / 0.75% / 0.5%. Snipers buying into the decay window therefore pay
 * holders, the LP, and the treasury — which is the point.
 *
 * The WETH legs are skimmed from the WETH side of the swap and the treasury
 * leg from the SENTRY side, each in whichever callback owns that currency
 * (beforeSwap for the specified currency, afterSwap for the unspecified).
 *
 * The compounded LP position is owned by this hook and there is NO
 * withdrawal function: reinvested liquidity is locked forever. The hook's
 * own compound swap is exempt from skimming so 100% of accrued WETH lands
 * in liquidity.
 *
 * Hook address: low 14 bits must equal FLAGS (0x30CC), mined via CREATE2.
 *
 * NOTE: return-delta accounting that moves real WETH and real SENTRY.
 * Covered by fork tests; independently audit before it carries meaningful
 * volume.
 */
contract SentrySentryFeeHook {
    using PoolIdLibrary for PoolKey;
    using BalanceDeltaLibrary for BalanceDelta;

    /* ─────────────────────────── Config ─────────────────────────── */

    address public immutable poolManager;
    /// @notice The only address allowed to create the pool on this hook and
    /// to set the launch whitelist.
    address public immutable launcher;
    address public immutable weth;
    /// @notice The SENTRY token (reflection target + treasury payout asset).
    address public immutable sentry;
    /// @notice Destination of the SENTRY treasury reflection.
    address public immutable treasury;

    uint24 public immutable startFee;
    uint24 public immutable endFee;
    uint256 public immutable holdDuration;
    uint256 public immutable halfLife;

    /// @notice Holder WETH reflection share, in bps OF THE CURVE FEE.
    uint24 public immutable reflectionShareBps;
    /// @notice LP-compound share, in bps OF THE CURVE FEE.
    uint24 public immutable lpShareBps;
    /// @notice Treasury SENTRY share, in bps OF THE CURVE FEE.
    uint24 public immutable treasuryShareBps;

    /// @notice Early-exit fee in pips (800_000 = 80%), charged when a wallet
    /// that is STILL INSIDE the migration lock sells. It replaces the curve
    /// fee entirely for that swap and the whole amount goes to the treasury
    /// in WETH, to be recycled into buybacks and liquidity. Buys are never
    /// charged it, and it stops applying the moment the lock expires. Set to
    /// 0 to disable the early-exit path.
    uint24 public immutable earlyExitFee;

    uint256 private constant PIPS = 1_000_000;
    uint256 private constant BPS = 10_000;

    /// @notice Launch timestamp per pool; 0 = pool unknown to this hook.
    mapping(PoolId => uint256) public launchedAt;
    /// @notice Per-pool launch whitelist (bundle wallets → floor fee on buys).
    mapping(PoolId => mapping(address => bool)) public launchWhitelist;
    /// @notice Whether WETH is currency0 for a pool.
    mapping(PoolId => bool) public baseIsCurrency0;
    /// @notice Accrued LP-compound fees per pool, in WETH.
    mapping(PoolId => uint256) public lpAccruedWeth;
    /// @dev Cached pool key per pool so compound() needs only the id.
    mapping(PoolId => PoolKey) internal poolKeyOf;
    /// @dev compound() reentrancy latch, and the skim exemption for the
    /// hook's own internal swap.
    bool private compounding;

    uint160 internal constant FLAGS = 0x30CC;

    event LaunchRecorded(PoolId indexed poolId, uint256 timestamp);
    event LaunchWhitelistSet(PoolId indexed poolId, uint256 count);
    event ReflectionPaid(PoolId indexed poolId, uint256 wethAmount);
    event TreasuryReflectionPaid(PoolId indexed poolId, uint256 sentryAmount);
    event EarlyExitFeePaid(PoolId indexed poolId, address indexed seller, uint256 wethAmount);
    event LpFeeAccrued(PoolId indexed poolId, uint256 amount);
    event LpCompounded(PoolId indexed poolId, uint256 wethSpent, uint128 liquidityAdded);

    error NotPoolManager();
    error NotLauncher();
    error NotDynamicFee();
    error InvalidFeeConfig();
    error PoolAlreadyLaunched();
    error BadHookAddress();
    error FeeOverflow();
    error NothingToCompound();
    error DecayStillActive();
    error PoolUnknown();
    error Reentrancy();
    error WrongPair();

    constructor(
        address _poolManager,
        address _launcher,
        address _weth,
        address _sentry,
        address _treasury,
        uint24 _startFee,
        uint24 _endFee,
        uint256 _holdDuration,
        uint256 _halfLife,
        uint24 _reflectionShareBps,
        uint24 _lpShareBps,
        uint24 _treasuryShareBps,
        uint24 _earlyExitFee
    ) {
        if (
            _poolManager == address(0) || _launcher == address(0) || _weth == address(0) || _sentry == address(0)
                || _treasury == address(0)
        ) revert InvalidFeeConfig();
        if (_startFee > LPFeeLibrary.MAX_LP_FEE || _endFee > _startFee || _endFee == 0 || _halfLife == 0) {
            revert InvalidFeeConfig();
        }
        // The three legs ARE the whole fee — no app-fee remainder.
        if (uint256(_reflectionShareBps) + uint256(_lpShareBps) + uint256(_treasuryShareBps) != BPS) {
            revert InvalidFeeConfig();
        }
        if (_earlyExitFee > LPFeeLibrary.MAX_LP_FEE) revert InvalidFeeConfig();
        if (uint160(address(this)) & 0x3FFF != FLAGS) revert BadHookAddress();

        poolManager = _poolManager;
        launcher = _launcher;
        weth = _weth;
        sentry = _sentry;
        treasury = _treasury;
        startFee = _startFee;
        endFee = _endFee;
        holdDuration = _holdDuration;
        halfLife = _halfLife;
        reflectionShareBps = _reflectionShareBps;
        lpShareBps = _lpShareBps;
        treasuryShareBps = _treasuryShareBps;
        earlyExitFee = _earlyExitFee;
    }

    modifier onlyPoolManager() {
        if (msg.sender != poolManager) revert NotPoolManager();
        _;
    }

    /* ─────────────────────── Hook entrypoints ───────────────────── */

    /// @dev Only the launcher may create the pool, it must use the dynamic
    /// fee flag, and it must be exactly the WETH/SENTRY pair.
    function beforeInitialize(address sender, PoolKey calldata key, uint160)
        external
        view
        onlyPoolManager
        returns (bytes4)
    {
        if (sender != launcher) revert NotLauncher();
        if (key.fee != LPFeeLibrary.DYNAMIC_FEE_FLAG) revert NotDynamicFee();
        address c0 = Currency.unwrap(key.currency0);
        address c1 = Currency.unwrap(key.currency1);
        if (!((c0 == weth && c1 == sentry) || (c0 == sentry && c1 == weth))) revert WrongPair();
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
        baseIsCurrency0[id] = Currency.unwrap(key.currency0) == weth;
        emit LaunchRecorded(id, block.timestamp);
        return IHooks.afterInitialize.selector;
    }

    /// @dev Force the LP fee to 0 and skim the specified currency's legs.
    function beforeSwap(address, PoolKey calldata key, SwapParams calldata params, bytes calldata)
        external
        onlyPoolManager
        returns (bytes4, BeforeSwapDelta, uint24)
    {
        uint24 lpOverride = LPFeeLibrary.OVERRIDE_FEE_FLAG; // fee bits 0 → LP fee 0
        if (compounding) {
            return (IHooks.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, lpOverride);
        }

        PoolId id = key.toId();
        uint256 specified =
            params.amountSpecified < 0 ? uint256(-params.amountSpecified) : uint256(params.amountSpecified);

        uint256 total = _wethIsSpecified(key, params)
            ? _skimWeth(id, key, params, specified)
            : _skimTreasury(id, key, params, specified);

        if (total == 0) {
            return (IHooks.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, lpOverride);
        }
        return (IHooks.beforeSwap.selector, toBeforeSwapDelta(_toInt128(total), 0), lpOverride);
    }

    /// @dev Skim the unspecified currency's legs (beforeSwap took the other).
    function afterSwap(address, PoolKey calldata key, SwapParams calldata params, BalanceDelta delta, bytes calldata)
        external
        onlyPoolManager
        returns (bytes4, int128)
    {
        if (compounding) return (IHooks.afterSwap.selector, 0);

        PoolId id = key.toId();
        bool wethIs0 = Currency.unwrap(key.currency0) == weth;
        bool wethSpecified = _wethIsSpecified(key, params);

        // The unspecified side is whichever one beforeSwap did not handle.
        int128 unspecDelta;
        if (wethSpecified) {
            unspecDelta = wethIs0 ? delta.amount1() : delta.amount0(); // SENTRY side
        } else {
            unspecDelta = wethIs0 ? delta.amount0() : delta.amount1(); // WETH side
        }
        uint256 unspecAbs = unspecDelta < 0 ? uint256(uint128(-unspecDelta)) : uint256(uint128(unspecDelta));

        uint256 total =
            wethSpecified ? _skimTreasury(id, key, params, unspecAbs) : _skimWeth(id, key, params, unspecAbs);

        if (total == 0) return (IHooks.afterSwap.selector, 0);
        return (IHooks.afterSwap.selector, _toInt128(total));
    }

    /* ───────────────────────────  Skims ─────────────────────────── */

    /// @dev The WETH legs: holder reflections + LP compound, both as
    /// fractions of the curve fee applied to the WETH side of the swap.
    function _skimWeth(PoolId id, PoolKey calldata key, SwapParams calldata params, uint256 wethAmount)
        internal
        returns (uint256 total)
    {
        (uint256 rate, bool earlyExit) = _rateAndMode(id, key, params);
        Currency wethCur = (Currency.unwrap(key.currency0) == weth) ? key.currency0 : key.currency1;

        // Early exit: one flat fee, all of it to the treasury in WETH. None
        // of it reflects, compounds, or splits.
        if (earlyExit) {
            total = (wethAmount * rate) / PIPS;
            if (total == 0) return 0;
            IPoolManager(poolManager).take(wethCur, treasury, total);
            emit EarlyExitFeePaid(id, tx.origin, total);
            return total;
        }

        uint256 wethLegs = reflectionShareBps + lpShareBps;
        total = (wethAmount * rate * wethLegs) / (PIPS * BPS);
        if (total == 0) return 0;

        uint256 lpCut = (total * lpShareBps) / wethLegs;
        uint256 reflection = total - lpCut;

        if (reflection > 0) {
            IPoolManager(poolManager).take(wethCur, sentry, reflection);
            IReflectionToken(sentry).notifyReward();
            emit ReflectionPaid(id, reflection);
        }
        if (lpCut > 0) {
            IPoolManager(poolManager).take(wethCur, address(this), lpCut);
            lpAccruedWeth[id] += lpCut;
            emit LpFeeAccrued(id, lpCut);
        }
    }

    /// @dev The SENTRY leg: the treasury's share of the curve fee, taken
    /// from the token side of the swap and sent to the multisig.
    function _skimTreasury(PoolId id, PoolKey calldata key, SwapParams calldata params, uint256 tokenAmount)
        internal
        returns (uint256 total)
    {
        (uint256 rate, bool earlyExit) = _rateAndMode(id, key, params);
        // The early-exit fee is charged wholly on the WETH side, so the token
        // side takes nothing on those swaps.
        if (earlyExit) return 0;
        total = (tokenAmount * rate * treasuryShareBps) / (PIPS * BPS);
        if (total == 0) return 0;

        Currency tokenCur = (Currency.unwrap(key.currency0) == weth) ? key.currency1 : key.currency0;
        IPoolManager(poolManager).take(tokenCur, treasury, total);
        emit TreasuryReflectionPaid(id, total);
    }

    /* ─────────────────────── Launch whitelist ───────────────────── */

    /// @notice Set the pool's launch whitelist. Launcher-only, and only
    /// before the pool is initialized: once afterInitialize has stamped
    /// launchedAt, the whitelist is immutable forever.
    function setLaunchWhitelist(PoolId poolId, bool _baseIsCurrency0, address[] calldata wallets) external {
        if (msg.sender != launcher) revert NotLauncher();
        if (launchedAt[poolId] != 0) revert PoolAlreadyLaunched();
        baseIsCurrency0[poolId] = _baseIsCurrency0;
        for (uint256 i = 0; i < wallets.length; i++) {
            launchWhitelist[poolId][wallets[i]] = true;
        }
        emit LaunchWhitelistSet(poolId, wallets.length);
    }

    /* ─────────────────────────── Rate ───────────────────────────── */

    /// @dev The rate this swap pays, and whether it is an early exit (a sell
    /// by a wallet still inside the migration lock). An early exit replaces
    /// the curve fee entirely and is charged wholly on the WETH side.
    function _rateAndMode(PoolId id, PoolKey calldata key, SwapParams calldata params)
        internal
        view
        returns (uint256 rate, bool earlyExit)
    {
        bool wethIs0 = Currency.unwrap(key.currency0) == weth;
        bool isBuy = params.zeroForOne == wethIs0;

        if (!isBuy && earlyExitFee > 0 && _isLockedSeller()) {
            return (uint256(earlyExitFee), true);
        }

        uint24 fee = currentFee(id);
        // Launch whitelist is BUY-only: campaign wallets get the floor rate
        // going in, and never a discount on the way out.
        if (fee != endFee && launchWhitelist[id][tx.origin] && params.zeroForOne == baseIsCurrency0[id]) {
            fee = endFee;
        }
        return (uint256(fee), false);
    }

    /// @dev True when tx.origin is a migration wallet whose lock has not
    /// expired. Wrapped in a try/catch so a token that does not implement
    /// the interface can never brick swaps.
    function _isLockedSeller() internal view returns (bool) {
        try IMigrationLock(sentry).migrationLocked(tx.origin) returns (bool locked) {
            if (!locked) return false;
            try IMigrationLock(sentry).unlockTime() returns (uint256 t) {
                return block.timestamp < t;
            } catch {
                return false;
            }
        } catch {
            return false;
        }
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

    /* ────────────────────── LP compounding ──────────────────────── */

    /**
     * @notice Compound the pool's accrued LP fees into permanently-locked
     * full-range liquidity. Permissionless; gated until the decay window
     * has ended. The minted position is owned by this hook and has NO
     * withdrawal path.
     */
    function compound(PoolId id) external returns (uint128 liquidityAdded) {
        if (compounding) revert Reentrancy();
        if (launchedAt[id] == 0) revert PoolUnknown();
        if (currentFee(id) != endFee) revert DecayStillActive();
        if (lpAccruedWeth[id] == 0) revert NothingToCompound();
        compounding = true;
        bytes memory result = IPoolManager(poolManager).unlock(abi.encode(id));
        compounding = false;
        liquidityAdded = abi.decode(result, (uint128));
    }

    /// @dev PoolManager unlock callback: swap half the accrued WETH for
    /// SENTRY, mint full-range liquidity from both sides, settle every delta
    /// from the hook's own balances. Leftover dust rolls into the next
    /// compound. Skims are suppressed for the duration.
    function unlockCallback(bytes calldata data) external onlyPoolManager returns (bytes memory) {
        PoolId id = abi.decode(data, (PoolId));
        PoolKey memory key = poolKeyOf[id];
        bool wethIs0 = Currency.unwrap(key.currency0) == weth;
        Currency base = wethIs0 ? key.currency0 : key.currency1; // WETH
        Currency tokenCur = wethIs0 ? key.currency1 : key.currency0; // SENTRY

        uint256 budget = lpAccruedWeth[id];
        lpAccruedWeth[id] = 0;

        // 1. Swap half the WETH budget → SENTRY through this same pool.
        uint256 half = budget / 2;
        IPoolManager(poolManager).swap(
            key,
            SwapParams({
                zeroForOne: wethIs0,
                amountSpecified: -int256(half),
                sqrtPriceLimitX96: wethIs0 ? TickMath.MIN_SQRT_PRICE + 1 : TickMath.MAX_SQRT_PRICE - 1
            }),
            ""
        );

        // 2. Mint full-range liquidity from the unswapped WETH half plus the
        //    SENTRY credit from step 1.
        (uint160 sqrtP,,,) = StateLibrary.getSlot0(IPoolManager(poolManager), id);
        int24 tickLo = (TickMath.MIN_TICK / key.tickSpacing) * key.tickSpacing;
        int24 tickHi = (TickMath.MAX_TICK / key.tickSpacing) * key.tickSpacing;

        int256 tokenCredit = TransientStateLibrary.currencyDelta(IPoolManager(poolManager), address(this), tokenCur);
        uint256 tokenAvail = tokenCredit > 0 ? uint256(tokenCredit) : 0;
        uint256 baseAvail = budget - half;
        uint256 amt0 = wethIs0 ? baseAvail : tokenAvail;
        uint256 amt1 = wethIs0 ? tokenAvail : baseAvail;
        // 1 wei of slack per side: modifyLiquidity rounds owed amounts up.
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

        // 3. Settle both currencies from the hook's own balances.
        uint256 baseSpent = _settle(base);
        _settle(tokenCur);

        if (baseSpent < budget) lpAccruedWeth[id] += budget - baseSpent;
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
        if (sqrtP <= sqrtLo) {
            return _liquidity0(amt0, sqrtLo, sqrtHi);
        } else if (sqrtP < sqrtHi) {
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

    function _wethIsSpecified(PoolKey calldata key, SwapParams calldata params) internal view returns (bool) {
        bool wethIsCurrency0 = Currency.unwrap(key.currency0) == weth;
        bool specifiedIsCurrency0 = (params.amountSpecified < 0) == params.zeroForOne;
        return specifiedIsCurrency0 == wethIsCurrency0;
    }

    function _toInt128(uint256 x) internal pure returns (int128) {
        if (x > uint256(int256(type(int128).max))) revert FeeOverflow();
        return int128(int256(x));
    }
}
