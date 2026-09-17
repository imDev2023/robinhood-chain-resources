// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {PoolKey} from "v4-core/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "v4-core/types/PoolId.sol";
import {SwapParams, ModifyLiquidityParams} from "v4-core/types/PoolOperation.sol";
import {BalanceDelta} from "v4-core/types/BalanceDelta.sol";
import {Currency} from "v4-core/types/Currency.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {IHooks} from "v4-core/interfaces/IHooks.sol";
import {LPFeeLibrary} from "v4-core/libraries/LPFeeLibrary.sol";
import {TransientStateLibrary} from "v4-core/libraries/TransientStateLibrary.sol";
import {TickMath} from "v4-core/libraries/TickMath.sol";

interface IERC20Min {
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

interface ISentryHookWhitelist {
    function setLaunchWhitelist(PoolId poolId, bool baseIsCurrency0, address[] calldata wallets) external;
}

/**
 * @title SentryRelaunchLauncher
 * @notice Makes the SENTRY relaunch atomic. Creating the pool, pairing the
 * supply, and firing the secure buy happen in ONE transaction, so nothing
 * can execute between them.
 *
 * That matters because the launch pool opens deliberately thin (a ~$1,000
 * market cap on 87% of supply). A sniper landing even a small buy between
 * pool creation and the launch buy would take a large fraction of the
 * curve, and the airdrop budget would come up short with no way to refill
 * it except buying back at the sniper's price. Robinhood Chain has no
 * public mempool and orders first-come-first-served, but bots do watch for
 * initialize events and race the next block — one transaction removes that
 * window entirely.
 *
 * Flow (owner calls launch() once):
 *   1. initialize the pool at the launch price
 *   2. mint the single-sided SENTRY range (token-only, no WETH)
 *   3. swap the launch WETH through that range
 *   4. sweep every output back to the owner
 *
 * The contract holds the SENTRY and WETH for the launch beforehand, and
 * has an owner-only sweep so nothing can be stranded. It is the hook's
 * `launcher`, so it also relays setLaunchWhitelist before the pool exists.
 */
contract SentryRelaunchLauncher {
    using PoolIdLibrary for PoolKey;

    address public immutable poolManager;
    address public immutable weth;
    address public immutable sentry;
    address public owner;

    /// @notice The fee hook. Set once, after the hook is CREATE2-deployed
    /// with this contract as its launcher.
    address public hook;

    bool public launched;

    event HookSet(address hook);
    event Launched(PoolId indexed poolId, uint128 liquidity, uint256 wethIn, uint256 sentryOut);
    event Swept(address indexed token, address indexed to, uint256 amount);
    event OwnershipTransferred(address indexed from, address indexed to);

    error NotOwner();
    error NotPoolManager();
    error HookAlreadySet();
    error HookUnset();
    error AlreadyLaunched();
    error ZeroAddress();

    struct LaunchParams {
        uint160 sqrtPriceX96;
        int24 tickSpacing;
        int24 tickLower;
        int24 tickUpper;
        uint128 liquidity;
        uint256 wethIn;
        /// @dev Minimum SENTRY the launch buy must return. Set from a
        /// simulation; a shortfall means the pool was not in the state we
        /// expected and the whole launch reverts.
        uint256 minSentryOut;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    constructor(address _poolManager, address _weth, address _sentry, address _owner) {
        if (_poolManager == address(0) || _weth == address(0) || _sentry == address(0) || _owner == address(0)) {
            revert ZeroAddress();
        }
        poolManager = _poolManager;
        weth = _weth;
        sentry = _sentry;
        owner = _owner;
    }

    /// @notice Bind the hook. One-way: the launcher can never be repointed
    /// at a different hook after the fact.
    function setHook(address _hook) external onlyOwner {
        if (hook != address(0)) revert HookAlreadySet();
        if (_hook == address(0)) revert ZeroAddress();
        hook = _hook;
        emit HookSet(_hook);
    }

    /// @notice Relay the hook's launch whitelist (bundle wallets that pay
    /// the floor rate on buys). Must be called before launch().
    function setLaunchWhitelist(bool baseIsCurrency0, address[] calldata wallets) external onlyOwner {
        if (hook == address(0)) revert HookUnset();
        ISentryHookWhitelist(hook).setLaunchWhitelist(poolKey().toId(), baseIsCurrency0, wallets);
    }

    /// @notice The pool this launcher will create. Deterministic before the
    /// pool exists, so the whitelist can be set against its id.
    function poolKey() public view returns (PoolKey memory) {
        return _poolKey(200);
    }

    function poolKeyWithSpacing(int24 tickSpacing) public view returns (PoolKey memory) {
        return _poolKey(tickSpacing);
    }

    function _poolKey(int24 tickSpacing) internal view returns (PoolKey memory) {
        bool wethIs0 = weth < sentry;
        return PoolKey({
            currency0: Currency.wrap(wethIs0 ? weth : sentry),
            currency1: Currency.wrap(wethIs0 ? sentry : weth),
            fee: LPFeeLibrary.DYNAMIC_FEE_FLAG,
            tickSpacing: tickSpacing,
            hooks: IHooks(hook)
        });
    }

    /**
     * @notice Create the pool, pair the SENTRY, and buy — atomically.
     * The contract must already hold the SENTRY to pair and the WETH to
     * spend. Everything it ends up holding is swept to the owner.
     */
    function launch(LaunchParams calldata p) external onlyOwner returns (uint256 sentryOut) {
        if (hook == address(0)) revert HookUnset();
        if (launched) revert AlreadyLaunched();
        launched = true;

        PoolKey memory key = _poolKey(p.tickSpacing);
        IPoolManager(poolManager).initialize(key, p.sqrtPriceX96);

        sentryOut = abi.decode(IPoolManager(poolManager).unlock(abi.encode(key, p)), (uint256));
        require(sentryOut >= p.minSentryOut, "launch buy short");

        // Sweep everything home: bought SENTRY, any unpaired remainder, and
        // any WETH left over.
        _sweep(sentry);
        _sweep(weth);

        emit Launched(key.toId(), p.liquidity, p.wethIn, sentryOut);
    }

    function unlockCallback(bytes calldata data) external returns (bytes memory) {
        if (msg.sender != poolManager) revert NotPoolManager();
        (PoolKey memory key, LaunchParams memory p) = abi.decode(data, (PoolKey, LaunchParams));
        bool wethIs0 = Currency.unwrap(key.currency0) == weth;

        // 1. Single-sided SENTRY range. With the range entirely on the
        //    SENTRY side of the launch price, modifyLiquidity asks for
        //    token only — no WETH is paired in.
        IPoolManager(poolManager).modifyLiquidity(
            key,
            ModifyLiquidityParams({
                tickLower: p.tickLower,
                tickUpper: p.tickUpper,
                liquidityDelta: int256(uint256(p.liquidity)),
                salt: bytes32(0)
            }),
            ""
        );

        // 1b. Pay for that liquidity NOW, before swapping. The hook takes
        //     its treasury cut in SENTRY mid-swap, and take() moves real
        //     tokens — so the PoolManager has to be physically holding the
        //     paired supply by then, not merely owed it.
        _settle(key.currency0);
        _settle(key.currency1);

        // 2. The launch buy, straight through the range we just minted.
        BalanceDelta delta = IPoolManager(poolManager).swap(
            key,
            SwapParams({
                zeroForOne: wethIs0,
                amountSpecified: -int256(p.wethIn),
                // Selling currency0 pushes the pool price down, selling
                // currency1 pushes it up — the limit has to sit on the side
                // the swap actually travels toward.
                sqrtPriceLimitX96: wethIs0 ? TickMath.MIN_SQRT_PRICE + 1 : TickMath.MAX_SQRT_PRICE - 1
            }),
            ""
        );
        int128 sentryDelta = wethIs0 ? delta.amount1() : delta.amount0();
        uint256 out = sentryDelta > 0 ? uint256(uint128(sentryDelta)) : 0;

        // 3. Settle the swap: pay the WETH in, take the SENTRY out.
        _settle(key.currency0);
        _settle(key.currency1);

        return abi.encode(out);
    }

    function _settle(Currency cur) internal {
        int256 delta = TransientStateLibrary.currencyDelta(IPoolManager(poolManager), address(this), cur);
        if (delta < 0) {
            uint256 owed = uint256(-delta);
            IPoolManager(poolManager).sync(cur);
            IERC20Min(Currency.unwrap(cur)).transfer(poolManager, owed);
            IPoolManager(poolManager).settle();
        } else if (delta > 0) {
            IPoolManager(poolManager).take(cur, address(this), uint256(delta));
        }
    }

    /* ─────────────────────────── Recovery ───────────────────────── */

    /// @notice Send this contract's full balance of `token` to the owner.
    /// Callable any time — the launcher is a staging area, never a vault.
    function sweep(address token) external onlyOwner {
        _sweep(token);
    }

    function _sweep(address token) internal {
        uint256 bal = IERC20Min(token).balanceOf(address(this));
        if (bal == 0) return;
        IERC20Min(token).transfer(owner, bal);
        emit Swept(token, owner, bal);
    }

    function transferOwnership(address to) external onlyOwner {
        if (to == address(0)) revert ZeroAddress();
        emit OwnershipTransferred(owner, to);
        owner = to;
    }
}
