// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {PoolKey} from "v4-core/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "v4-core/types/PoolId.sol";
import {SwapParams} from "v4-core/types/PoolOperation.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary} from "v4-core/types/BeforeSwapDelta.sol";
import {LPFeeLibrary} from "v4-core/libraries/LPFeeLibrary.sol";
import {IHooks} from "v4-core/interfaces/IHooks.sol";

/**
 * @title SentryDynamicFeeHook
 * @notice Uniswap v4 hook shared by every Sentry v4 launch. Implements a
 * time-decaying LP fee: the pool opens at `startFee` (sniper tax) and
 * decays to a permanent `endFee` floor.
 *
 * Decay: the fee holds FLAT at startFee for `holdDuration` seconds (the
 * sniper window gets no relief), then decays by exponential halving with
 * linear interpolation inside each half-life. With startFee = 40%,
 * endFee = 1.25%, hold = 3 min and halfLife = 3 min: 40% flat for 3
 * minutes, then 40 → 20 → 10 → 5 → 2.5 → 1.25 over the next 15, floor
 * at 18 minutes, forever after. Time-based on purpose: swap-count decay
 * is gameable with dust swaps and price-based decay trusts a price
 * snipers can push around.
 *
 * Only three hook entrypoints are live, encoded in this contract's
 * CREATE2-mined address (flags 0x3080):
 *  - beforeInitialize: only the Sentry factory may create pools on this
 *    hook, and only with the dynamic-fee flag. A pool using this hook is
 *    therefore, by construction, a Sentry launch.
 *  - afterInitialize:  records the pool's launch timestamp.
 *  - beforeSwap:       returns the current fee as a per-swap override.
 *
 * Fees are expressed in hundredths of a bip (pips): 1_000_000 = 100%.
 * 400_000 = 40%, 12_500 = 1.25%.
 */
contract SentryDynamicFeeHook {
    using PoolIdLibrary for PoolKey;

    /* ─────────────────────────── Config ─────────────────────────── */

    address public immutable poolManager;
    address public immutable factory;

    /// @notice Fee at t=0, in pips (e.g. 400_000 = 40%).
    uint24 public immutable startFee;
    /// @notice Permanent fee floor, in pips (e.g. 12_500 = 1.25%).
    uint24 public immutable endFee;
    /// @notice Seconds the fee holds flat at startFee before decay begins
    /// (e.g. 180 = 3 minutes).
    uint256 public immutable holdDuration;
    /// @notice Seconds for the fee to halve once decay begins (e.g. 180).
    uint256 public immutable halfLife;

    /// @notice Launch timestamp per pool; 0 = pool unknown to this hook.
    mapping(PoolId => uint256) public launchedAt;

    /// @notice Per-pool launch whitelist (campaign/bundle wallets). A
    /// whitelisted wallet BUYING during the decay window pays the endFee
    /// floor instead of the decayed fee. Sells are never exempt, and the
    /// whitelist is only writable BEFORE the pool exists (launchedAt == 0),
    /// so it is provably fixed at launch.
    mapping(PoolId => mapping(address => bool)) public launchWhitelist;

    /// @notice Whether currency0 is the base token for a whitelisted pool
    /// (defines which swap direction counts as a "buy").
    mapping(PoolId => bool) public baseIsCurrency0;

    event LaunchRecorded(PoolId indexed poolId, uint256 timestamp);
    event LaunchWhitelistSet(PoolId indexed poolId, uint256 count);

    error NotPoolManager();
    error NotFactory();
    error NotDynamicFee();
    error InvalidFeeConfig();
    error PoolAlreadyLaunched();

    constructor(
        address _poolManager,
        address _factory,
        uint24 _startFee,
        uint24 _endFee,
        uint256 _holdDuration,
        uint256 _halfLife
    ) {
        if (_poolManager == address(0) || _factory == address(0)) revert InvalidFeeConfig();
        if (_startFee > LPFeeLibrary.MAX_LP_FEE || _endFee > _startFee || _endFee == 0 || _halfLife == 0) {
            revert InvalidFeeConfig();
        }
        poolManager = _poolManager;
        factory = _factory;
        startFee = _startFee;
        endFee = _endFee;
        holdDuration = _holdDuration;
        halfLife = _halfLife;
    }

    modifier onlyPoolManager() {
        if (msg.sender != poolManager) revert NotPoolManager();
        _;
    }

    /* ─────────────────────── Hook entrypoints ───────────────────── */

    /// @dev Gate: pools on this hook can only be created by the Sentry
    /// factory, and must use the dynamic-fee flag.
    function beforeInitialize(address sender, PoolKey calldata key, uint160)
        external
        view
        onlyPoolManager
        returns (bytes4)
    {
        if (sender != factory) revert NotFactory();
        if (key.fee != LPFeeLibrary.DYNAMIC_FEE_FLAG) revert NotDynamicFee();
        return IHooks.beforeInitialize.selector;
    }

    function afterInitialize(address, PoolKey calldata key, uint160, int24)
        external
        onlyPoolManager
        returns (bytes4)
    {
        PoolId id = key.toId();
        launchedAt[id] = block.timestamp;
        emit LaunchRecorded(id, block.timestamp);
        return IHooks.afterInitialize.selector;
    }

    function beforeSwap(address, PoolKey calldata key, SwapParams calldata params, bytes calldata)
        external
        view
        onlyPoolManager
        returns (bytes4, BeforeSwapDelta, uint24)
    {
        PoolId id = key.toId();
        uint24 fee = currentFee(id);
        // Launch-whitelisted wallets pay the floor on BUYS during the
        // decay window. tx.origin (not sender) so the exemption follows
        // the signing wallet through any router.
        if (
            fee != endFee && launchWhitelist[id][tx.origin]
                && params.zeroForOne == baseIsCurrency0[id]
        ) {
            fee = endFee;
        }
        return (IHooks.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, fee | LPFeeLibrary.OVERRIDE_FEE_FLAG);
    }

    /* ─────────────────────── Launch whitelist ───────────────────── */

    /// @notice Set a pool's launch whitelist. Factory-only, and only
    /// callable BEFORE the pool is initialized: once afterInitialize has
    /// stamped launchedAt, the whitelist is immutable forever.
    /// @param poolId          The pool (computable before initialization)
    /// @param _baseIsCurrency0 True if the base token sorts as currency0
    /// @param wallets         Campaign/bundle wallets to exempt on buys
    function setLaunchWhitelist(PoolId poolId, bool _baseIsCurrency0, address[] calldata wallets) external {
        if (msg.sender != factory) revert NotFactory();
        if (launchedAt[poolId] != 0) revert PoolAlreadyLaunched();
        baseIsCurrency0[poolId] = _baseIsCurrency0;
        for (uint256 i = 0; i < wallets.length; i++) {
            launchWhitelist[poolId][wallets[i]] = true;
        }
        emit LaunchWhitelistSet(poolId, wallets.length);
    }

    /* ─────────────────────────── Views ──────────────────────────── */

    /// @notice The LP fee this pool charges right now, in pips.
    /// @dev Flat at startFee for holdDuration, then piecewise-linear
    /// interpolation between successive halvings, floored at endFee.
    /// Unknown pools get the floor (they can only exist if launchedAt was
    /// somehow never set, and the floor is the safe value).
    function currentFee(PoolId poolId) public view returns (uint24) {
        uint256 t0 = launchedAt[poolId];
        if (t0 == 0) return endFee;
        if (block.timestamp <= t0) return startFee;
        return _feeAtElapsed(block.timestamp - t0);
    }

    /// @notice Fee at a hypothetical elapsed-seconds-since-launch. Used by
    /// frontends to render the hold + decay curve.
    function feeAtElapsed(uint256 elapsed) external view returns (uint24) {
        return _feeAtElapsed(elapsed);
    }

    function _feeAtElapsed(uint256 elapsed) internal view returns (uint24) {
        if (elapsed <= holdDuration) return startFee;

        uint256 decayElapsed = elapsed - holdDuration;
        uint256 n = decayElapsed / halfLife;
        if (n >= 24) return endFee; // startFee < 2^24, so fully decayed

        uint256 feeHigh = uint256(startFee) >> n;
        if (feeHigh <= endFee) return endFee;

        uint256 feeLow = feeHigh >> 1;
        uint256 rem = decayElapsed % halfLife;
        uint256 fee = feeHigh - ((feeHigh - feeLow) * rem) / halfLife;
        if (fee < endFee) fee = endFee;
        return uint24(fee);
    }
}
