// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {IUnlockCallback} from "@uniswap/v4-core/src/interfaces/callback/IUnlockCallback.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {PoolId} from "@uniswap/v4-core/src/types/PoolId.sol";
import {Currency, CurrencyLibrary} from "@uniswap/v4-core/src/types/Currency.sol";
import {BalanceDelta} from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {SwapParams} from "@uniswap/v4-core/src/types/PoolOperation.sol";
import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {StateLibrary} from "@uniswap/v4-core/src/libraries/StateLibrary.sol";
import {FullMath} from "@uniswap/v4-core/src/libraries/FullMath.sol";
import {FixedPoint96} from "@uniswap/v4-core/src/libraries/FixedPoint96.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {LaunchHook} from "./LaunchHook.sol";
import {LaunchFactory} from "./LaunchFactory.sol";
import {IQuoteRegistry, QuotePolicy} from "./interfaces/IQuoteRegistry.sol";
import {IDividendSink} from "./interfaces/IDividendSink.sol";

interface IWETH is IERC20 {
    function deposit() external payable;
}

interface IUniswapV3Pool {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);
}

/// @title FeeRouter
/// @notice Turns the launchpad's fee income into WETH and splits it 70/30
///         between the HOOD10 dividend sink and the protocol.
///
/// @dev    The whole model in one line: WETH passes through, everything with a
///         route sells on Uniswap under a size cap, and anything else waits.
///
///         THE SIZE CAP IS THE SANDWICH DEFENCE. Anyone may fire the crank, so
///         the worry is an attacker calling it themselves: push the quote's
///         price down, make us sell into the hole, buy back cheap. But
///         sandwiching only pays when the trade being front-run is LARGE
///         relative to the pool -- the attacker must move the price, eat their
///         own slippage both ways, and pay gas, and their profit scales with the
///         victim's size while their costs do not shrink. Cap each sale at a
///         fraction of the target pool's own depth and the arithmetic never
///         works out for them, whatever the price is, without anyone having to
///         know it. The cooldown stops the cap being defeated by calling
///         `sweep` repeatedly in one block.
///
///         WAITING IS THE ANSWER FOR THE REST, and it is deliberate rather than
///         lazy. An earlier version auctioned unroutable assets on a descending
///         price. It worked, but no launchpad does that, and the incumbent on
///         this chain had already settled the question the other way: fees it
///         cannot convert park in the tab until a sink exists, on the reasoning
///         that parking is recoverable and a bad conversion is not. A parked
///         tab is not lost -- registering a route later sweeps everything that
///         accumulated.
///
///         `adoptLaunchRoute` then shrinks what can park at all. A token this
///         pad launched against WETH already has a WETH pool that this pad
///         created, with permanently locked liquidity; the route is derivable
///         rather than configured, so it registers itself the first time
///         somebody sweeps it.
///
///         The bounty always comes out of the protocol's 30%, never the
///         dividend 70%.
contract FeeRouter is Ownable2Step, ReentrancyGuard, IUnlockCallback {
    using CurrencyLibrary for Currency;
    using SafeERC20 for IERC20;
    using StateLibrary for IPoolManager;

    // ─────────────────────────────── types ───────────────────────────────

    enum RouteKind {
        NONE,
        V4,
        V3
    }

    struct Route {
        RouteKind kind;
        address v3Pool;
        PoolKey v4Key;
    }

    // ─────────────────────────────── errors ───────────────────────────────

    error ZeroAddress();
    error NotSweepable(address quote);
    error NoRoute(address quote);
    error BadRoute();
    error NotPoolManager();
    error BelowMinSweep(uint256 amount, uint256 min);
    error Cooling(address quote, uint256 readyAt);
    error NoDepth(address quote);
    error InsufficientOutput(uint256 got, uint256 minOut);
    error BountyTooHigh(uint16 bps);
    error CooldownTooLong(uint32 seconds_);
    error PartialFill(address quote, uint256 unspent);
    error NotAPadLaunch(address token);
    error NotWethQuoted(address token);
    error NotKeeper(address caller, uint256 openAt);
    error ExceedsPoolShare(uint256 wethOut, uint256 allowed);
    error DelayTooLong(uint32 seconds_);
    error RouteAlreadySet(address quote);

    // ─────────────────────────────── events ───────────────────────────────

    event Swept(
        Currency indexed quote, uint256 amountIn, uint256 wethOut, uint256 dividend, uint256 protocol, uint256 bounty
    );
    event RouteSet(Currency indexed quote, RouteKind kind, address pool);
    event RouteAdopted(Currency indexed quote, PoolId poolId);
    event SinkSet(address indexed sink, bool notify);
    event TreasurySet(address indexed treasury);
    event BountySet(uint16 bps);
    event CooldownSet(uint32 seconds_);
    event KeeperSet(address indexed keeper, bool allowed);
    event OpenSweepDelaySet(uint32 seconds_);

    // ────────────────────────────── constants ──────────────────────────────

    uint256 public constant BPS = 10_000;
    /// @notice The dividend lane's share of the protocol fee: 0.7 of the 1%.
    uint16 public constant DIVIDEND_SHARE_BPS = 7_000;
    /// @notice Ceiling on the crank bounty, as a share of the protocol's 30%.
    uint16 public constant MAX_BOUNTY_BPS = 1_000;
    /// @dev A cooldown longer than this would let a stall hold fees past several
    ///      of HOOD10's two-hour settlement epochs.
    uint32 public constant MAX_COOLDOWN = 1 hours;

    // ─────────────────────────────── state ───────────────────────────────

    IPoolManager public immutable poolManager;
    LaunchHook public immutable hook;
    LaunchFactory public immutable factory;
    IQuoteRegistry public immutable quotes;
    IWETH public immutable weth;

    address public dividendSink;
    /// @notice Whether to call `onDividend` after transferring. False for the
    ///         live HOOD10 engine, which exposes no such hook.
    bool public sinkNotify;
    address public protocolTreasury;
    /// @notice Zero by default: the protocol runs its own crank, so a bounty
    ///         would only move WETH from the treasury to the treasury and pay
    ///         gas to do it. Kept as a lever rather than deleted --- if the
    ///         keeper ever stops, raising this hands the job to anybody.
    uint16 public bountyBps;
    /// @dev Timestamps rather than blocks: this chain's block times are
    ///      sub-second and explicitly irregular, so a block count is not a
    ///      duration.
    uint32 public sweepCooldown = 60;

    /// @notice How long an asset's fees must sit unswept before ANYONE may
    ///         sweep them, rather than only a keeper.
    ///
    /// @dev    This is the fix for the size cap being attacker-settable. The cap
    ///         is a fraction of the route pool's depth read at call time, and
    ///         the depth is measured on the side being sold -- so dumping the
    ///         quote into that pool immediately before the sweep both worsens
    ///         the price and WIDENS the cap, which is exactly backwards. There
    ///         is no oracle to appeal to and no honest way to size a sale
    ///         against state the caller has just written.
    ///
    ///         So the trigger is taken away instead. A sandwich needs its
    ///         victim's transaction to be summonable on demand; a keeper-gated
    ///         sweep is not. Liveness is kept by the delay: if the keeper dies,
    ///         the asset opens to anyone and the pad still converts, just later
    ///         and with the cap and cooldown as the only bounds -- which is the
    ///         behaviour this contract had for every caller before.
    uint32 public openSweepDelay = 12 hours;
    uint32 public constant MAX_OPEN_DELAY = 7 days;

    /// @notice Addresses trusted to sweep at any time. The protocol runs its own
    ///         crank, which is why `bountyBps` defaults to zero.
    mapping(address => bool) public keepers;

    /// @dev The anchor for the open-sweep clock on an asset nobody has swept
    ///      yet. Without it `lastSweepAt` is zero, the delay elapses at unix
    ///      epoch plus twelve hours, and every asset is open to anyone from the
    ///      moment it is deployed -- which is the hole this gate exists to fill.
    uint256 public immutable deployedAt;

    mapping(Currency => Route) private _routes;
    mapping(Currency => uint256) public lastSweepAt;

    constructor(
        IPoolManager poolManager_,
        LaunchHook hook_,
        LaunchFactory factory_,
        IQuoteRegistry quotes_,
        address weth_,
        address dividendSink_,
        address protocolTreasury_,
        address owner_
    ) Ownable(owner_) {
        if (
            address(poolManager_) == address(0) || address(hook_) == address(0) || address(factory_) == address(0)
                || address(quotes_) == address(0) || weth_ == address(0) || dividendSink_ == address(0)
                || protocolTreasury_ == address(0)
        ) revert ZeroAddress();
        deployedAt = block.timestamp;
        poolManager = poolManager_;
        hook = hook_;
        factory = factory_;
        quotes = quotes_;
        weth = IWETH(weth_);
        dividendSink = dividendSink_;
        protocolTreasury = protocolTreasury_;
    }

    receive() external payable {}

    // ──────────────────────────────── sweep ────────────────────────────────

    /// @notice Convert one currency's booked platform fees to WETH and pay out.
    ///         Permissionless; the caller is paid the bounty.
    /// @param  minWethOut optional extra floor of the caller's own. The size cap
    ///                    is what protects the protocol; this only lets an
    ///                    honest keeper add its own off-chain judgement.
    function sweep(Currency quote, uint256 minWethOut)
        external
        returns (uint256 amountIn, uint256 wethOut, uint256 dividend, uint256 protocolAmount, uint256 bounty)
    {
        return sweepUpTo(quote, minWethOut, type(uint256).max);
    }

    /// @notice A sweep the caller can size down.
    ///
    /// @dev    `sweep` takes whatever the caps allow, which made a refusal
    ///         permanent rather than a retry: a pool too thin to absorb the
    ///         capped amount reverts `PartialFill` or `ExceedsPoolShare`, and
    ///         since the tab only grows, the next attempt asks for MORE and
    ///         fails again. That fee lane stalled until an owner guessed a lower
    ///         `maxSweepNotional` from a different contract. Letting the caller
    ///         name a ceiling turns the stall into a retry, and is what makes a
    ///         genuinely thin venue -- TSLA holds well under a WETH -- convert
    ///         at all rather than never.
    function sweepUpTo(Currency quote, uint256 minWethOut, uint256 maxAmountIn)
        public
        nonReentrant
        returns (uint256 amountIn, uint256 wethOut, uint256 dividend, uint256 protocolAmount, uint256 bounty)
    {
        QuotePolicy memory policy = quotes.policyFor(quote);
        if (!policy.sweepable) revert NotSweepable(Currency.unwrap(quote));

        bool isNative = quote.isAddressZero();
        if (isNative || Currency.unwrap(quote) == address(weth)) {
            // Nothing is sold, so there is nothing to size or to time.
            amountIn = _collect(quote, policy, maxAmountIn);
            if (isNative) weth.deposit{value: amountIn}();
            wethOut = amountIn;
        } else {
            Route memory route = _routes[quote];
            if (route.kind == RouteKind.NONE) {
                // A token this pad launched against WETH carries its own route;
                // take it now rather than making somebody wire it by hand.
                _tryAdoptLaunchRoute(quote);
                route = _routes[quote];
                if (route.kind == RouteKind.NONE) revert NoRoute(Currency.unwrap(quote));
            }

            // Anyone may sweep an asset the keeper has neglected; only a keeper
            // may choose the moment. See `openSweepDelay`.
            if (!keepers[msg.sender]) {
                uint256 since = lastSweepAt[quote] == 0 ? deployedAt : lastSweepAt[quote];
                uint256 openAt = since + openSweepDelay;
                if (block.timestamp < openAt) revert NotKeeper(msg.sender, openAt);
            }

            uint256 readyAt = lastSweepAt[quote] + sweepCooldown;
            if (block.timestamp < readyAt) revert Cooling(Currency.unwrap(quote), readyAt);
            lastSweepAt[quote] = block.timestamp;

            uint256 cap = _depthCap(quote, route, policy);
            if (cap == 0) revert NoDepth(Currency.unwrap(quote));
            if (maxAmountIn < cap) cap = maxAmountIn;

            amountIn = _collect(quote, policy, cap);
            wethOut = _sell(quote, route, amountIn, policy);
        }

        if (wethOut < minWethOut) revert InsufficientOutput(wethOut, minWethOut);

        (dividend, protocolAmount, bounty) = _distribute(wethOut, msg.sender);
        emit Swept(quote, amountIn, wethOut, dividend, protocolAmount, bounty);
    }

    /// @notice What a sweep would actually sell right now. Zero means a sweep
    ///         would refuse: parked for want of a route or depth, or still
    ///         under the minimum.
    ///
    /// @dev    This has to agree with `sweep` or it is worse than useless --- a
    ///         caller shown a sellable figure and then handed BelowMinSweep has
    ///         been lied to, so the minimum is checked here too.
    /// @notice The WETH depth this router measures for a quote's route.
    ///
    /// @dev    Exposed because the bound built on it could not otherwise be
    ///         tested. `_capPoolShare` only fires when the primary size cap is
    ///         wrong, so a behavioural test cannot distinguish a correct depth
    ///         reading from a catastrophically wrong one -- the two guards I
    ///         wrote for the v4 fix passed verbatim against the broken code they
    ///         were meant to lock out, which makes them worse than no test:
    ///         they assert that something was checked.
    ///
    ///         Also the number an operator wants before firing a sweep, and the
    ///         one that would have made the original bug visible from outside.
    function wethDepthOf(Currency quote) external view returns (uint256) {
        Route memory route = _routes[quote];
        if (route.kind == RouteKind.NONE) {
            (bool found, PoolKey memory key) = _derivedLaunchRoute(quote);
            if (!found) return 0;
            route = Route({kind: RouteKind.V4, v3Pool: address(0), v4Key: key});
        }
        return _poolWethBalance(route);
    }

    function sweepableNow(Currency quote) external view returns (uint256) {
        QuotePolicy memory policy = quotes.policyFor(quote);
        if (!policy.sweepable) return 0;

        uint256 booked = hook.platformTab(quote);
        if (booked < policy.minSweep) return 0;

        if (quote.isAddressZero() || Currency.unwrap(quote) == address(weth)) return booked;

        Route memory route = _routes[quote];
        if (route.kind == RouteKind.NONE) {
            (bool found, PoolKey memory key) = _derivedLaunchRoute(quote);
            if (!found) return 0;
            route = Route({kind: RouteKind.V4, v3Pool: address(0), v4Key: key});
        }

        uint256 cap = _depthCap(quote, route, policy);
        uint256 available = booked;
        if (available > cap) available = cap;
        if (available > policy.maxSweepNotional) available = policy.maxSweepNotional;
        return available;
    }

    // ─────────────────────── routes this pad already owns ───────────────────────

    /// @notice Register a pad-launched, WETH-quoted token as its own route.
    ///         Permissionless: nothing here is a choice, it is a lookup.
    function adoptLaunchRoute(Currency quote) external {
        // Only ever FILL a gap, never replace a decision. This is permissionless
        // and was also unconditional, so `clearRoute` -- documented as the
        // response to a pool that has gone thin or hostile -- was undone by the
        // next caller, and an owner-curated route was overwritable by anyone.
        if (_routes[quote].kind != RouteKind.NONE) revert RouteAlreadySet(Currency.unwrap(quote));

        (bool found, PoolKey memory key) = _derivedLaunchRoute(quote);
        if (!found) {
            PoolId poolId = factory.poolOfToken(Currency.unwrap(quote));
            if (PoolId.unwrap(poolId) == bytes32(0)) revert NotAPadLaunch(Currency.unwrap(quote));
            revert NotWethQuoted(Currency.unwrap(quote));
        }
        _routes[quote] = Route({kind: RouteKind.V4, v3Pool: address(0), v4Key: key});
        emit RouteAdopted(quote, key.toId());
        emit RouteSet(quote, RouteKind.V4, address(0));
    }

    function _tryAdoptLaunchRoute(Currency quote) internal {
        (bool found, PoolKey memory key) = _derivedLaunchRoute(quote);
        if (!found) return;
        _routes[quote] = Route({kind: RouteKind.V4, v3Pool: address(0), v4Key: key});
        emit RouteAdopted(quote, key.toId());
        emit RouteSet(quote, RouteKind.V4, address(0));
    }

    /// @dev Rebuilds the pool key for a token this factory launched against
    ///      WETH. Safe to trust because the pool was created by our own factory,
    ///      carries our own hook, and its liquidity can never be removed --- and
    ///      the size cap applies to it exactly as to any other route.
    function _derivedLaunchRoute(Currency quote) internal view returns (bool found, PoolKey memory key) {
        address token = Currency.unwrap(quote);
        if (token == address(0)) return (false, key);

        PoolId poolId = factory.poolOfToken(token);
        if (PoolId.unwrap(poolId) == bytes32(0)) return (false, key);

        (,, Currency launchQuote,,,, int24 tickSpacing,,) = factory.launches(poolId);
        if (Currency.unwrap(launchQuote) != address(weth)) return (false, key);

        bool wethIsCurrency0 = address(weth) < token;
        key = PoolKey({
            currency0: wethIsCurrency0 ? Currency.wrap(address(weth)) : quote,
            currency1: wethIsCurrency0 ? quote : Currency.wrap(address(weth)),
            fee: factory.LP_FEE(),
            tickSpacing: tickSpacing,
            hooks: IHooks(address(hook))
        });
        // Cheap consistency check: if the rebuilt key does not hash to the pool
        // the factory recorded, something is wrong and we route nowhere.
        if (PoolId.unwrap(key.toId()) != PoolId.unwrap(poolId)) return (false, key);
        return (true, key);
    }

    // ──────────────────────────── the size cap ────────────────────────────

    /// @dev Sized against the quote side, which is the side being sold, so this
    ///      figure GROWS when someone dumps quote into the route pool. It is
    ///      kept because it is the right shape for an honest sweep -- do not
    ///      sell more than a sliver of the venue -- but it is explicitly not
    ///      load-bearing against a manipulator. What stops that is the keeper
    ///      gate above, plus `_capPoolShare` below, which bounds the WETH
    ///      actually taken out and therefore shrinks under exactly the
    ///      manipulation that inflates this.
    function _depthCap(Currency quote, Route memory route, QuotePolicy memory policy) internal view returns (uint256) {
        if (policy.maxPoolFractionBps == 0) return 0;
        uint256 depth = route.kind == RouteKind.V3 ? _depthV3(quote, route.v3Pool) : _depthV4(quote, route.v4Key);
        return (depth * policy.maxPoolFractionBps) / BPS;
    }

    /// @dev The bound that survives manipulation: never take more than
    ///      `maxPoolFractionBps` of the WETH the route pool actually holds.
    ///
    ///      Draining the pool's WETH is the one thing every profitable attack
    ///      here has to do, and unlike the quote-side depth it cannot be
    ///      inflated by giving the pool more of what we are selling.
    /// @param heldBefore the pool's WETH balance BEFORE the swap. Reading it
    ///        after would measure the balance our own sale just drained, so the
    ///        allowance would shrink by exactly the amount being checked and a
    ///        sale of precisely the permitted share would fail.
    function _capPoolShare(QuotePolicy memory policy, uint256 heldBefore, uint256 wethOut) internal pure {
        uint256 allowed = (heldBefore * policy.maxPoolFractionBps) / BPS;
        if (wethOut > allowed) revert ExceedsPoolShare(wethOut, allowed);
    }

    /// @dev How much WETH the venue we are about to sell into actually holds.
    ///
    ///      For a v3 pool `balanceOf` is the answer: the pool custodies its own
    ///      reserves. For v4 it is not, and reading it there measured the WHOLE
    ///      EXCHANGE -- the singleton holds every pool's tokens together, so
    ///      this returned ~985 WETH for a pad pool whose WETH side opens at
    ///      1.36. `_capPoolShare` then permitted 9.85 WETH out of it at the
    ///      ecosystem tier: a bound seven times larger than the thing it bounds
    ///      is not a bound, and v4 is the only route class this router adopts
    ///      by itself.
    ///
    ///      `_depthV4` was written for exactly this and already reconstructs a
    ///      single pool's reserve from its liquidity and price. The quote side
    ///      used it; the WETH side did not.
    function _poolWethBalance(Route memory route) internal view returns (uint256) {
        if (route.kind == RouteKind.V3) return IERC20(address(weth)).balanceOf(route.v3Pool);
        return _depthV4(Currency.wrap(address(weth)), route.v4Key);
    }

    /// @dev A v3 pool holds its own reserves, so its balance IS its depth.
    function _depthV3(Currency quote, address pool) internal view returns (uint256) {
        return IERC20(Currency.unwrap(quote)).balanceOf(pool);
    }

    /// @dev A v4 pool does not: the singleton holds every pool's tokens
    ///      together, so `balanceOf` would measure the whole exchange. The
    ///      pool's own depth has to be reconstructed from its in-range liquidity
    ///      and current price --- the virtual reserve the curve behaves like at
    ///      this tick.
    function _depthV4(Currency quote, PoolKey memory key) internal view returns (uint256) {
        PoolId id = key.toId();
        uint128 liquidity = poolManager.getLiquidity(id);
        if (liquidity == 0) return 0;
        (uint160 sqrtPriceX96,,,) = poolManager.getSlot0(id);
        if (sqrtPriceX96 == 0) return 0;

        bool quoteIsCurrency0 = Currency.unwrap(key.currency0) == Currency.unwrap(quote);

        // Bounded by the position, when the position is one this pad created.
        //
        // L*sqrtP/2^96 and L*2^96/sqrtP are the FULL-RANGE reserves. Every pool
        // this factory launches is a single CONCENTRATED position, and the
        // amounts for one of those carry the range's own endpoint:
        //
        //   amount1 = L * (min(P,B) - A) / 2^96
        //   amount0 = L * 2^96 * (B - max(P,A)) / B / max(P,A)
        //
        // The full-range form drops the endpoint term, so it overstates by
        // L*A/2^96 -- which is the opening valuation, and is a CONSTANT rather
        // than a fraction. Measured on a pool with the shipping geometry: 1.861
        // WETH reported against 0.495 truly held, an overstatement of 1.3665
        // against an openFdv of 1.36. It does not shrink as the pool fills; it
        // stays exactly the same size while the real balance grows past it.
        //
        // That direction only ever permits. `_capPoolShare` is supposed to be
        // the bound that survives a manipulated depth reading, and on a young
        // pool the allowance it computes can exceed the venue's entire holdings
        // -- so it cannot fire at any sweep size, which is the same condition
        // the balanceOf(poolManager) bug produced and this function was changed
        // to fix.
        //
        // Reading the launch's own ticks is exact: this reproduces the pool
        // manager's balance delta to the wei. A route the owner set by hand to
        // some other protocol's pool has no launch record, and falls back to the
        // full-range form -- still an overstatement there, but that route was a
        // deliberate act rather than something adopted automatically.
        (,,,, int24 tickLower, int24 tickUpper,,,) = factory.launches(id);
        if (tickLower != tickUpper) {
            uint160 a = TickMath.getSqrtPriceAtTick(tickLower);
            uint160 b = TickMath.getSqrtPriceAtTick(tickUpper);
            if (quoteIsCurrency0) {
                uint160 lo = sqrtPriceX96 < a ? a : sqrtPriceX96;
                if (lo >= b) return 0;
                return FullMath.mulDiv(uint256(liquidity) << 96, b - lo, b) / lo;
            }
            uint160 hi = sqrtPriceX96 > b ? b : sqrtPriceX96;
            if (hi <= a) return 0;
            return FullMath.mulDiv(liquidity, hi - a, FixedPoint96.Q96);
        }

        return quoteIsCurrency0
            ? FullMath.mulDiv(liquidity, FixedPoint96.Q96, sqrtPriceX96)
            : FullMath.mulDiv(liquidity, sqrtPriceX96, FixedPoint96.Q96);
    }

    // ────────────────────────────── selling ──────────────────────────────

    function _sell(Currency quote, Route memory route, uint256 amountIn, QuotePolicy memory policy)
        internal
        returns (uint256 wethOut)
    {
        IERC20 asset = IERC20(Currency.unwrap(quote));
        uint256 wethBefore = IERC20(address(weth)).balanceOf(address(this));
        uint256 quoteBefore = asset.balanceOf(address(this));
        uint256 poolWethBefore = _poolWethBalance(route);

        if (route.kind == RouteKind.V4) {
            poolManager.unlock(abi.encode(quote, amountIn));
        } else {
            _sellV3(quote, route.v3Pool, amountIn);
        }

        wethOut = IERC20(address(weth)).balanceOf(address(this)) - wethBefore;

        // An exact-input swap into a pool that runs out of liquidity fills only
        // part of the order and hands the rest back. That remainder would sit
        // here unaccounted and unreachable --- the hook's tab was already
        // debited for the full amount. Refuse the sweep instead: the fees stay
        // booked, and the next (smaller) one goes through.
        uint256 spent = quoteBefore - asset.balanceOf(address(this));
        if (spent != amountIn) revert PartialFill(Currency.unwrap(quote), amountIn - spent);

        // Bound what we took out of the venue, measured on the side the venue
        // had to pay. Checked after the fact because the amount out is not
        // knowable before the swap without trusting a price.
        _capPoolShare(policy, poolWethBefore, wethOut);
    }

    /// @dev The deepest liquidity for several quote assets on this chain still
    ///      sits in v3 pools, so routing that only spoke v4 would strand them.
    function _sellV3(Currency quote, address pool, uint256 amountIn) internal {
        bool zeroForOne = IUniswapV3Pool(pool).token0() == Currency.unwrap(quote);
        IUniswapV3Pool(pool)
            .swap(
                address(this),
                zeroForOne,
                int256(amountIn), // positive == exact input
                zeroForOne ? TickMath.MIN_SQRT_PRICE + 1 : TickMath.MAX_SQRT_PRICE - 1,
                abi.encode(quote)
            );
    }

    function uniswapV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata data) external {
        Currency quote = abi.decode(data, (Currency));
        // The pool is identified from our own registry, never from the caller,
        // so an arbitrary contract cannot invoke this and drain the balance.
        Route memory route = _routes[quote];
        if (route.kind != RouteKind.V3 || msg.sender != route.v3Pool) revert BadRoute();

        if (amount0Delta > 0) {
            IERC20(IUniswapV3Pool(msg.sender).token0()).safeTransfer(msg.sender, uint256(amount0Delta));
        }
        if (amount1Delta > 0) {
            IERC20(IUniswapV3Pool(msg.sender).token1()).safeTransfer(msg.sender, uint256(amount1Delta));
        }
    }

    function unlockCallback(bytes calldata data) external returns (bytes memory) {
        if (msg.sender != address(poolManager)) revert NotPoolManager();
        (Currency quote, uint256 amountIn) = abi.decode(data, (Currency, uint256));

        PoolKey memory key = _routes[quote].v4Key;
        bool zeroForOne = Currency.unwrap(key.currency0) == Currency.unwrap(quote);

        BalanceDelta delta = poolManager.swap(
            key,
            SwapParams({
                zeroForOne: zeroForOne,
                amountSpecified: -int256(amountIn),
                sqrtPriceLimitX96: zeroForOne ? TickMath.MIN_SQRT_PRICE + 1 : TickMath.MAX_SQRT_PRICE - 1
            }),
            ""
        );

        int128 owed0 = delta.amount0();
        int128 owed1 = delta.amount1();
        if (owed0 < 0) _settle(key.currency0, uint256(uint128(-owed0)));
        if (owed1 < 0) _settle(key.currency1, uint256(uint128(-owed1)));
        if (owed0 > 0) poolManager.take(key.currency0, address(this), uint256(uint128(owed0)));
        if (owed1 > 0) poolManager.take(key.currency1, address(this), uint256(uint128(owed1)));
        return "";
    }

    function _settle(Currency currency, uint256 amount) internal {
        if (amount == 0) return;
        if (currency.isAddressZero()) {
            poolManager.settle{value: amount}();
        } else {
            poolManager.sync(currency);
            IERC20(Currency.unwrap(currency)).safeTransfer(address(poolManager), amount);
            poolManager.settle();
        }
    }

    // ─────────────────────────── collect and pay out ───────────────────────────

    function _collect(Currency quote, QuotePolicy memory policy, uint256 cap) internal returns (uint256 amount) {
        uint256 available = hook.platformTab(quote);
        if (available < policy.minSweep) revert BelowMinSweep(available, policy.minSweep);
        amount = available;
        if (amount > cap) amount = cap;
        if (amount > policy.maxSweepNotional) amount = policy.maxSweepNotional;
        hook.collectPlatform(quote, amount);
    }

    function _distribute(uint256 wethOut, address bountyTo)
        internal
        returns (uint256 dividend, uint256 protocolAmount, uint256 bounty)
    {
        dividend = (wethOut * DIVIDEND_SHARE_BPS) / BPS;
        uint256 protocolGross = wethOut - dividend;
        bounty = (protocolGross * bountyBps) / BPS;
        protocolAmount = protocolGross - bounty;

        // Plain transfer, deliberately. An ERC-20 transfer does not invoke
        // recipient code, so the dividend lane cannot be broken by anything the
        // sink does --- which is what makes an unverified, externally-operated
        // engine a safe destination.
        IERC20(address(weth)).safeTransfer(dividendSink, dividend);
        if (sinkNotify) IDividendSink(dividendSink).onDividend(dividend);

        if (protocolAmount > 0) IERC20(address(weth)).safeTransfer(protocolTreasury, protocolAmount);
        if (bounty > 0) IERC20(address(weth)).safeTransfer(bountyTo, bounty);
    }

    // ─────────────────────────────── config ───────────────────────────────

    function routeFor(Currency quote) external view returns (Route memory) {
        return _routes[quote];
    }

    function setV4Route(Currency quote, PoolKey calldata key) external onlyOwner {
        address w = address(weth);
        bool touchesWeth = Currency.unwrap(key.currency0) == w || Currency.unwrap(key.currency1) == w;
        bool touchesQuote = Currency.unwrap(key.currency0) == Currency.unwrap(quote)
            || Currency.unwrap(key.currency1) == Currency.unwrap(quote);
        if (!touchesWeth || !touchesQuote) revert BadRoute();
        _routes[quote] = Route({kind: RouteKind.V4, v3Pool: address(0), v4Key: key});
        emit RouteSet(quote, RouteKind.V4, address(0));
    }

    function setV3Route(Currency quote, address pool) external onlyOwner {
        address t0 = IUniswapV3Pool(pool).token0();
        address t1 = IUniswapV3Pool(pool).token1();
        address w = address(weth);
        address q = Currency.unwrap(quote);
        if (!((t0 == q && t1 == w) || (t1 == q && t0 == w))) revert BadRoute();
        PoolKey memory empty;
        _routes[quote] = Route({kind: RouteKind.V3, v3Pool: pool, v4Key: empty});
        emit RouteSet(quote, RouteKind.V3, pool);
    }

    /// @notice Drop a route so the asset parks instead. The intended response to
    ///         a pool that has gone thin or hostile --- parked fees are not lost,
    ///         and a later route sweeps everything that accumulated meanwhile.
    function clearRoute(Currency quote) external onlyOwner {
        delete _routes[quote];
        emit RouteSet(quote, RouteKind.NONE, address(0));
    }

    function setKeeper(address who, bool allowed) external onlyOwner {
        if (who == address(0)) revert ZeroAddress();
        keepers[who] = allowed;
        emit KeeperSet(who, allowed);
    }

    function setOpenSweepDelay(uint32 seconds_) external onlyOwner {
        if (seconds_ > MAX_OPEN_DELAY) revert DelayTooLong(seconds_);
        openSweepDelay = seconds_;
        emit OpenSweepDelaySet(seconds_);
    }

    function setSweepCooldown(uint32 seconds_) external onlyOwner {
        if (seconds_ > MAX_COOLDOWN) revert CooldownTooLong(seconds_);
        sweepCooldown = seconds_;
        emit CooldownSet(seconds_);
    }

    function setSink(address sink, bool notify) external onlyOwner {
        if (sink == address(0)) revert ZeroAddress();
        dividendSink = sink;
        sinkNotify = notify;
        emit SinkSet(sink, notify);
    }

    function setProtocolTreasury(address treasury) external onlyOwner {
        if (treasury == address(0)) revert ZeroAddress();
        protocolTreasury = treasury;
        emit TreasurySet(treasury);
    }

    function setBountyBps(uint16 bps) external onlyOwner {
        if (bps > MAX_BOUNTY_BPS) revert BountyTooHigh(bps);
        bountyBps = bps;
        emit BountySet(bps);
    }
}
