// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {IUnlockCallback} from "@uniswap/v4-core/src/interfaces/callback/IUnlockCallback.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {PoolId} from "@uniswap/v4-core/src/types/PoolId.sol";
import {Currency, CurrencyLibrary} from "@uniswap/v4-core/src/types/Currency.sol";
import {BalanceDelta} from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {ModifyLiquidityParams, SwapParams} from "@uniswap/v4-core/src/types/PoolOperation.sol";
import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {LiquidityAmounts} from "v4-periphery/src/libraries/LiquidityAmounts.sol";
import {FullMath} from "@uniswap/v4-core/src/libraries/FullMath.sol";
import {FixedPointMathLib} from "solmate/src/utils/FixedPointMathLib.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {LaunchGeometry} from "./LaunchGeometry.sol";
import {LaunchToken} from "./LaunchToken.sol";
import {LaunchHook} from "./LaunchHook.sol";
import {IQuoteRegistry, QuoteTier} from "./interfaces/IQuoteRegistry.sol";

/// @title LaunchFactory
/// @notice Deploys a token and its pool in one transaction, seeds the entire
///         supply as a single locked one-sided position, and hands the terms to
///         the hook. The token trades from the same block it is created in.
///
/// @dev    There is no separate bonding-curve contract and no graduation
///         migration, because in v4 a one-sided concentrated position already
///         IS a bonding curve: the supply sits in a range above (or below) the
///         opening price and buyers walk the price through it. Skipping the
///         migration also removes the window that snipers farm on pads that
///         move funds from a curve into a pool.
///
///         Which side "above" means depends on currency ordering, which v4 fixes
///         by address. Both orderings are handled in `_openingSqrtPrice`.
/// @dev The one call this contract needs from WETH. Declared here rather than
///      imported so the factory does not depend on the fee router's header for
///      a single function selector.
interface IWETH {
    function deposit() external payable;
}

/// @notice What the caller wants done beyond opening the pool.
///
/// @dev    Carried as one memory pointer rather than three parameters. Threaded
///         separately, `buyAmount`, `minTokensOut` and a calldata `Hop[]` are
///         four live stack slots in a frame that already holds a LaunchParams
///         pointer and three return values, and the compiler runs out at
///         sixteen. Grouping them is also the truer shape: they are one
///         instruction -- buy this much, through here, and refuse below that.
struct Order {
    uint256 buyAmount;
    uint256 minTokensOut;
    Hop[] route;
    /// @dev Set only by `launchAndBuyWithEth`. Funding is then ether, and the
    ///      quote is reached by routing or by wrapping.
    ///
    ///      Inferred from `msg.value` instead, it silently changed the meaning
    ///      of the ORIGINAL `launchAndBuy`: a WETH-quoted call carrying stray
    ///      value stopped reverting and started buying with the stray value,
    ///      ignoring the approved quote entirely. Intent has to be stated, not
    ///      guessed from a field that can be non-zero by accident.
    bool fromEther;
}

/// @notice One leg of a route from native ether to the quote asset.
///
/// @dev    A destination plus the pool that reaches it, which is exactly a v4
///         PathKey. Named separately because this contract must not depend on
///         periphery for a struct this small.
struct Hop {
    Currency currencyOut;
    uint24 fee;
    int24 tickSpacing;
    IHooks hooks;
}

contract LaunchFactory is Ownable2Step, ReentrancyGuard, IUnlockCallback {
    using CurrencyLibrary for Currency;
    using SafeERC20 for IERC20;

    // ─────────────────────────────── types ───────────────────────────────

    struct LaunchParams {
        string name;
        string symbol;
        string metadataURI;
        /// @notice Free choice. Vanity on its own: what sets the economics is
        ///         how much supply sits in what range.
        uint256 supply;
        /// @notice Anything with an address. WETH, a Stock Token, a memecoin.
        Currency quote;
        /// @notice What the WHOLE supply is worth at the opening price, in the
        ///         quote's own base units.
        ///
        /// @dev    A target valuation rather than ticks, because ticks cannot be
        ///         computed by the caller: the opening price depends on whether
        ///         the token sorts above or below the quote, and the token's
        ///         address does not exist until this transaction runs. It also
        ///         depends on the decimal gap between the two -- an 18-decimal
        ///         token against 6-decimal USDG prices twelve orders of
        ///         magnitude away from where a caller passing raw ticks would
        ///         land. Both are things only the factory knows.
        uint256 openFdv;
        /// @notice How far the price travels before the supply is exhausted,
        ///         in ticks. Decimal- and ordering-independent, so this one IS
        ///         safe for the caller to compute: ln(multiple)/ln(1.0001).
        int24 rangeTicks;
        int24 tickSpacing;
        /// @notice The creator's optional add-on fee, 0..MAX_CREATOR_FEE_BPS.
        ///         Immutable. The hook holds the ceiling and enforces it; naming
        ///         the number here only created something to go stale, which it
        ///         promptly did when the ceiling moved to 900.
        uint16 creatorFeeBps;
        /// @notice Extra pips charged at block 0, decaying to zero over the window.
        uint24 snipeSurgePips;
        uint24 snipeWindow;
    }

    struct Launch {
        address token;
        address creator;
        Currency quote;
        PoolId poolId;
        int24 tickLower;
        int24 tickUpper;
        /// @dev Recorded so the pool key can be rebuilt from the launch alone.
        ///      Without it the FeeRouter cannot adopt a pad-launched token as a
        ///      route, and every such token would have to be wired by hand.
        int24 tickSpacing;
        uint128 liquidity;
        uint64 launchedAt;
    }

    // ─────────────────────────────── errors ───────────────────────────────

    error ZeroAddress();
    error ZeroSupply();
    error BadTickRange();
    error BadTickSpacing();
    error QuoteNotLaunchable(address quote);
    error NotPoolManager();
    error SupplyTooLarge();
    error NoLiquidity();
    error NothingToBuy();
    error RouteTooLong(uint256 hops);
    error RouteHookNotAllowed(address hooks);
    error RouteDoesNotReachQuote(Currency arrivedAt, Currency quote);
    error RouteProducedNothing();
    error TooLittleBought(uint256 got, uint256 min);
    error WrongValue(uint256 sent, uint256 expected);
    error RefundFailed();
    error LaunchPaused();

    // ─────────────────────────────── events ───────────────────────────────

    event Launched(
        PoolId indexed poolId,
        address indexed token,
        address indexed creator,
        Currency quote,
        uint256 supply,
        uint128 liquidity,
        int24 tickLower,
        int24 tickUpper
    );
    event PausedSet(bool paused);

    // ────────────────────────────── constants ──────────────────────────────

    /// @notice Liquidity is protocol-owned and can never be removed, so an LP
    ///         fee would accrue into a position nobody can ever collect from.
    ///         Everything is charged as a hook fee instead, where it is
    ///         accounted, splittable, and actually reaches someone.
    uint24 public constant LP_FEE = 0;

    // ─────────────────────────────── state ───────────────────────────────

    /// @notice Ceiling on route length.
    ///
    /// @dev    Every hop is a swap inside an unlock that already seeds
    ///         liquidity, and gas here is paid by a creator who cannot see the
    ///         bill until it lands. Four reaches every asset this pad offers
    ///         with two to spare.
    uint256 public constant MAX_ROUTE_HOPS = 4;

    IPoolManager public immutable poolManager;
    LaunchHook public immutable hook;
    IQuoteRegistry public immutable quotes;

    bool public paused;
    mapping(PoolId => Launch) public launches;
    mapping(address => PoolId) public poolOfToken;
    /// @dev Every launch, in order. A mapping cannot be enumerated, so without
    ///      this the board -- the product's main screen -- has no on-chain
    ///      source and the frontend needs an indexer just to know what exists.
    ///      One SSTORE per launch buys "the site works if the RPC works".
    PoolId[] private _allLaunches;

    constructor(IPoolManager poolManager_, LaunchHook hook_, IQuoteRegistry quotes_, address owner_) Ownable(owner_) {
        if (address(poolManager_) == address(0) || address(hook_) == address(0) || address(quotes_) == address(0)) {
            revert ZeroAddress();
        }
        poolManager = poolManager_;
        hook = hook_;
        quotes = quotes_;
    }

    // ──────────────────────────────── launch ────────────────────────────────

    function launch(LaunchParams calldata p) external nonReentrant returns (address token, PoolId poolId) {
        (token, poolId,) = _launch(p, Order({buyAmount: 0, minTokensOut: 0, route: new Hop[](0), fromEther: false}));
    }

    /// @notice Open the pool and take the first position in it, in one call.
    ///
    /// @dev    The point is the absence of a gap. A launch followed by a
    ///         separate buy leaves blocks in between, and on a chain that
    ///         produces one every tenth of a second that is a real window for
    ///         anyone watching for the `Launched` event — the creator's own
    ///         first buy becomes a race they can lose. Here the swap happens in
    ///         the same unlock that seeded the liquidity, so there is no moment
    ///         at which the pool exists and this has not run.
    ///
    ///         It buys no privilege beyond ordering. The hook charges this swap
    ///         exactly what it charges everyone, and since the anti-snipe surge
    ///         is at its maximum in this very block, being first is at its most
    ///         expensive here.
    ///
    /// @param  buyAmount      how much of the QUOTE asset to spend. Native
    ///                        quotes take it from `msg.value`; an ERC-20 quote
    ///                        is pulled from the caller, who must have approved
    ///                        this contract first.
    /// @param  minTokensOut   slippage floor. Zero is safe here in a way it is
    ///                        not elsewhere: the pool is created in this same
    ///                        call, so there is no price for anyone to have
    ///                        moved. A buy larger than the range can absorb is
    ///                        clamped to its capacity rather than partially
    ///                        filled, so the floor has nothing left to catch.
    function launchAndBuy(LaunchParams calldata p, uint256 buyAmount, uint256 minTokensOut)
        external
        payable
        nonReentrant
        returns (address token, PoolId poolId, uint256 bought)
    {
        if (buyAmount == 0) revert NothingToBuy();
        // Negated into an int256 for the swap. Past int128 the sign flips and
        // the trade silently becomes exact-OUTPUT, which is a different
        // instruction than the one the caller wrote. Unreachable with a
        // well-behaved quote, free to refuse.
        if (buyAmount > uint256(uint128(type(int128).max))) revert WrongValue(buyAmount, 0);
        return _launch(p, Order({buyAmount: buyAmount, minTokensOut: minTokensOut, route: new Hop[](0), fromEther: false}));
    }

    /// @notice Open the pool and take the first position, paying in ether.
    ///
    /// @dev    The same call as `launchAndBuy`, minus the requirement to already
    ///         hold the thing the pool is priced in. A pad whose whole point is
    ///         that a coin can be bonded to anything cannot also require its
    ///         creators to go and acquire that anything first: bonding to
    ///         HOOD10 meant holding HOOD10, and the creator's own first buy —
    ///         the one trade that is supposed to be atomic with the launch —
    ///         became a two-transaction errand with a price move in the middle.
    ///
    ///         The route runs inside the SAME unlock that seeds the liquidity,
    ///         so the ether-to-quote leg and the quote-to-token leg and the
    ///         creation of the pool are one atomic step. Intermediate
    ///         currencies never need settling: v4 accumulates deltas across the
    ///         unlock and they cancel, so only ether goes in and only the token
    ///         comes out.
    ///
    /// @param  route  hops from native ether to `p.quote`, in order, the last
    ///                arriving AT `p.quote`. Empty when the quote is ether
    ///                itself, or WETH — which is wrapped rather than swapped,
    ///                there being no ether/WETH pool to route through.
    ///
    ///                Caller-supplied and unvalidated beyond its destination,
    ///                deliberately: this contract has no view of which venues
    ///                are deep, and a hardcoded table would be wrong the day a
    ///                better pool opens. A bad route cannot steal — v4 keys
    ///                every delta to the unlocker, which is this contract — it
    ///                can only buy badly, which is what `minTokensOut` is for.
    ///                Pass one and mean it: unlike `launchAndBuy`, where the
    ///                pool is created in the same call and has no price to be
    ///                moved, the route here crosses live pools that anyone can
    ///                move in the block before.
    function launchAndBuyWithEth(LaunchParams calldata p, Hop[] calldata route, uint256 minTokensOut)
        external
        payable
        nonReentrant
        returns (address token, PoolId poolId, uint256 bought)
    {
        if (msg.value == 0) revert NothingToBuy();
        if (msg.value > uint256(uint128(type(int128).max))) revert WrongValue(msg.value, 0);
        if (route.length > MAX_ROUTE_HOPS) revert RouteTooLong(route.length);

        // Every hop must be a plain pool.
        //
        // A hop's `hooks` address is called by the pool manager DURING our
        // swap, which is inside our unlock, with the manager unlocked and the
        // pad pool already seeded. Deltas are keyed per-caller, so such a hook
        // cannot spend this contract's balances -- but it can open its own
        // position in the pool we just created, ahead of the creator's buy in
        // the very transaction that creates it, and close it after. That is a
        // sandwich of the creator's own launch, executed from inside it.
        //
        // Today the cost of refusing this is zero: every venue this pad routes
        // through -- ether/USDG, ether/CASHCAT, ether/HOOD10, USDG/stock -- is
        // hookless. So the class is closed rather than reasoned about, which is
        // the right trade in a contract that can never be changed. A future
        // version can allow an allowlist if a hooked pool is ever worth it.
        for (uint256 i = 0; i < route.length; ++i) {
            if (address(route[i].hooks) != address(0)) revert RouteHookNotAllowed(address(route[i].hooks));
        }

        // Where the route must end. Checked here rather than trusted, because
        // everything downstream assumes the swap into the pad pool is paid in
        // the pool's own quote: a route landing anywhere else would settle a
        // currency the pool never asked for and revert deep inside the unlock
        // with nothing legible about why.
        if (route.length == 0) {
            // No hops means the quote is reachable without one: ether itself,
            // or WETH, which is wrapped in `_seedLiquidity` rather than traded.
            if (!p.quote.isAddressZero() && Currency.unwrap(p.quote) != quotes.weth()) {
                revert RouteDoesNotReachQuote(p.quote, p.quote);
            }
        } else if (Currency.unwrap(route[route.length - 1].currencyOut) != Currency.unwrap(p.quote)) {
            revert RouteDoesNotReachQuote(route[route.length - 1].currencyOut, p.quote);
        }

        return _launch(p, Order({buyAmount: msg.value, minTokensOut: minTokensOut, route: route, fromEther: true}));
    }

    function _launch(LaunchParams calldata p, Order memory o)
        internal
        returns (address token, PoolId poolId, uint256 bought)
    {
        if (paused) revert LaunchPaused();
        if (p.supply == 0) revert ZeroSupply();
        if (p.supply > uint256(type(uint128).max)) revert SupplyTooLarge();
        if (p.tickSpacing <= 0 || p.tickSpacing > TickMath.MAX_TICK_SPACING) revert BadTickSpacing();
        if (p.rangeTicks <= 0) revert BadTickRange();
        if (p.openFdv == 0) revert BadTickRange();

        _assertQuoteLaunchable(p.quote);

        o.buyAmount = _fund(p.quote, o.buyAmount, o.route.length, o.fromEther);

        token = _mint(p);

        // Everything the pool's shape implies, worked out in one place and
        // carried as a single memory pointer. Held as separate locals, the
        // ordering flag, the key, the id and the two tick bounds were five live
        // slots that the seed-and-buy call had no room left beside.
        Plan memory pl = _plan(p, token);
        poolId = pl.poolId;

        _register(poolId, p, pl.quoteIsCurrency0);
        poolManager.initialize(pl.key, LaunchGeometry.openingSqrtPrice(pl.quoteIsCurrency0, pl.tickLower, pl.tickUpper));

        launches[poolId] = Launch({
            token: token,
            creator: msg.sender,
            quote: p.quote,
            poolId: poolId,
            tickLower: pl.tickLower,
            tickUpper: pl.tickUpper,
            tickSpacing: p.tickSpacing,
            liquidity: 0,
            launchedAt: uint64(block.timestamp)
        });

        uint128 liquidity;
        uint256 spent;
        {
            (liquidity, spent, bought) = _seedLiquidity(pl, p, token, o);
            if (bought < o.minTokensOut) revert TooLittleBought(bought, o.minTokensOut);
        }

        // Converting a token amount into a liquidity figure rounds down, so a
        // few wei of supply are left over. Burn them rather than keep them: the
        // factory is not a custodian, and dust that accumulated here across
        // thousands of launches would be a balance nobody could account for.
        // Burning also keeps `totalSupply` equal to what is actually in the
        // pool, so every circulating-supply figure downstream is exact.
        uint256 dust = IERC20(token).balanceOf(address(this));
        if (dust != 0) LaunchToken(token).burn(dust);

        LaunchToken(token).initializePool(PoolId.unwrap(poolId));

        launches[poolId].liquidity = liquidity;
        poolOfToken[token] = poolId;
        _allLaunches.push(poolId);

        emit Launched(poolId, token, msg.sender, p.quote, p.supply, liquidity, pl.tickLower, pl.tickUpper);

        // Last, because refunding an ERC-20 quote calls code the caller chose.
        // Done earlier it handed that code a slot inside this transaction with
        // the pool already live but `poolOfToken` and `_allLaunches` not yet
        // written -- no theft was possible, v4 keys deltas by msg.sender, but a
        // guaranteed trade before `Launched` is announced is a privilege worth
        // not giving away for free.
        if (o.route.length != 0) {
            // `spent` came back in ether, so the remainder is ether. Refunding
            // it through `_refundUnspent` would hand the caller the difference
            // measured in ether but denominated in the quote asset.
            _refund(CurrencyLibrary.ADDRESS_ZERO, msg.sender, msg.value - spent);
        } else {
            _refundUnspent(p.quote, o.buyAmount, spent);
        }
    }

    // ───────────────────────────── enumeration ─────────────────────────────

    /// @notice How many tokens this factory has launched.
    function launchCount() external view returns (uint256) {
        return _allLaunches.length;
    }

    function launchIdAt(uint256 index) external view returns (PoolId) {
        return _allLaunches[index];
    }

    /// @notice A page of launches, newest first.
    ///
    /// @dev    Newest first because that is the only order a board ever wants,
    ///         and paginating from the tail keeps the read cheap however many
    ///         launches accumulate. Returns fewer than `limit` at the end of the
    ///         list rather than reverting, so a caller can walk to exhaustion
    ///         without knowing the total first.
    function launchSlice(uint256 offset, uint256 limit) external view returns (Launch[] memory page) {
        uint256 total = _allLaunches.length;
        if (offset >= total) return new Launch[](0);
        uint256 n = total - offset;
        if (n > limit) n = limit;
        page = new Launch[](n);
        for (uint256 i = 0; i < n; ++i) {
            page[i] = launches[_allLaunches[total - 1 - offset - i]];
        }
    }

    // ──────────────────────────── seeding internals ────────────────────────────





    /// @dev Everything one unlock needs. A struct because the buy pushed the
    ///      tuple past what abi.decode into locals can hold without the stack
    ///      running out.
    struct Seed {
        PoolKey key;
        int24 tickLower;
        int24 tickUpper;
        uint128 liquidity;
        address token;
        Currency quote;
        bool quoteIsCurrency0;
        uint256 buyAmount;
        address buyer;
        /// @dev Hops from native ether to `quote`. Empty means `buyAmount` is
        ///      already denominated in `quote` and was taken before the unlock.
        Hop[] route;
        /// @dev The most the pad swap can absorb. Computed outside because the
        ///      range is known there; enforced inside because with a route the
        ///      quote amount is not known until the last hop returns.
        uint256 capacity;
    }

    function _seedLiquidity(Plan memory pl, LaunchParams calldata p, address token, Order memory o)
        internal
        returns (uint128 liquidity, uint256 spent, uint256 bought)
    {
        uint160 lower = TickMath.getSqrtPriceAtTick(pl.tickLower);
        uint160 upper = TickMath.getSqrtPriceAtTick(pl.tickUpper);

        // p.supply read straight from calldata rather than copied to a local:
        // the copy was one live slot in a frame that has none to spare.
        liquidity = pl.quoteIsCurrency0
            ? LiquidityAmounts.getLiquidityForAmount1(lower, upper, p.supply)
            : LiquidityAmounts.getLiquidityForAmount0(lower, upper, p.supply);
        if (liquidity == 0) revert NoLiquidity();

        // Never ask the pool for more than the range holds.
        //
        // The hook takes its fee on the amount REQUESTED, before the pool knows
        // how much will fill, and v4 folds that into the caller's debt. So an
        // order larger than the range can absorb is charged a fee on the part
        // that never traded -- the unspent quote comes back, the fee on it does
        // not. Clamping to capacity means the swap always fills whole, and the
        // question never arises. The excess is refunded by the caller as if it
        // had simply not been spent, which is exactly what happened.
        uint256 capacity = LaunchGeometry.quoteCapacity(lower, upper, liquidity, pl.quoteIsCurrency0);
        // Clamped into a LOCAL, never back into `o`.
        //
        // `Order` is memory, and memory is by reference across an internal
        // call, so writing the clamp to `o.buyAmount` reached back into
        // `_launch` and changed the number `_refundUnspent` compares against.
        // An oversized buy then refunded only what the range could absorb and
        // left the rest -- 0.93 WETH in the case that found this -- sitting in
        // a contract that is supposed to custody nothing. The previous version
        // clamped a by-value parameter and was correct by accident of its
        // signature; making the argument a struct removed that accident.
        //
        // With a route the clamp cannot happen here at all: the quote amount is
        // whatever the last hop returns, which is not known until the unlock.
        uint256 spendable = o.buyAmount;
        if (spendable != 0 && o.route.length == 0 && spendable > capacity) spendable = capacity;

        bytes memory out = poolManager.unlock(
            abi.encode(
                Seed({
                    key: pl.key,
                    tickLower: pl.tickLower,
                    tickUpper: pl.tickUpper,
                    liquidity: liquidity,
                    token: token,
                    quote: p.quote,
                    quoteIsCurrency0: pl.quoteIsCurrency0,
                    buyAmount: spendable,
                    buyer: msg.sender,
                    route: o.route,
                    capacity: capacity
                })
            )
        );
        (spent, bought) = abi.decode(out, (uint256, uint256));
    }

    function unlockCallback(bytes calldata data) external returns (bytes memory) {
        if (msg.sender != address(poolManager)) revert NotPoolManager();
        Seed memory sd = abi.decode(data, (Seed));

        (BalanceDelta delta,) = poolManager.modifyLiquidity(
            sd.key,
            ModifyLiquidityParams({
                tickLower: sd.tickLower,
                tickUpper: sd.tickUpper,
                liquidityDelta: int256(uint256(sd.liquidity)),
                salt: bytes32(0)
            }),
            ""
        );

        // Only the token side is ever owed on a one-sided seed, but settle both
        // legs rather than assume: an off-by-one tick would otherwise strand a
        // dust debt and revert the unlock with a currency-not-settled error that
        // says nothing about the cause.
        if (delta.amount0() < 0) _settle(sd.key.currency0, uint256(uint128(-delta.amount0())));
        if (delta.amount1() < 0) _settle(sd.key.currency1, uint256(uint128(-delta.amount1())));

        if (sd.buyAmount == 0) return abi.encode(uint256(0), uint256(0));

        // Ether in, quote out, before the pad pool is touched.
        //
        // Each hop's output is the next hop's input and is never settled: v4
        // accumulates deltas across the whole unlock, so an intermediate
        // currency ends the call owing and owed the same amount and cancels
        // itself. Only ether is ever paid in and only the launched token is
        // ever taken out.
        uint256 quoteIn = sd.buyAmount;
        // What the route actually produced, kept separate from what the pad
        // swap is allowed to spend. Clamping one variable lost the difference:
        // quote the route bought above the range's capacity simply vanished
        // from the accounting, and the unlock closed with an unsettled balance.
        uint256 routed;
        uint256 etherSpent;
        if (sd.route.length != 0) {
            Currency from = CurrencyLibrary.ADDRESS_ZERO;
            for (uint256 i = 0; i < sd.route.length; ++i) {
                uint256 took;
                (from, quoteIn, took) = _hop(from, sd.route[i], quoteIn);
                // Only the first hop spends ether; later hops spend the credit
                // the previous one produced, which nets inside the unlock.
                if (i == 0) etherSpent = took;
            }
            if (quoteIn == 0) revert RouteProducedNothing();

            // Enforced here rather than at the entry point, because until the
            // last hop returns there is no quote figure to compare. Anything
            // over what the range can hold would be charged a fee on quote that
            // never trades, so it is left unspent and returned below as the
            // quote asset -- the caller ends up holding some of what they were
            // buying with, which is the honest outcome of asking for more than
            // the pool had to sell.
            routed = quoteIn;
            if (quoteIn > sd.capacity) quoteIn = sd.capacity;
        }

        // The creator's buy, in the same unlock that just created the market.
        //
        // This is the whole point of doing it here: there is no gap between the
        // pool existing and this executing, so there is no block for anyone to
        // act in. It is not a privileged trade -- the hook charges it exactly
        // what it charges everyone, anti-snipe surge included, because the surge
        // is highest in the very block this runs.
        (BalanceDelta bd) = poolManager.swap(
            sd.key,
            SwapParams({
                zeroForOne: sd.quoteIsCurrency0,
                amountSpecified: -int256(quoteIn), // negative == exact input
                // Paying quote for token. When the quote is currency0 that is a
                // zeroForOne swap, which moves the price DOWN, so the limit is
                // the floor; the other way round it moves up and the limit is
                // the ceiling. Inverted, every buy reverts with
                // PriceLimitAlreadyExceeded before it starts.
                sqrtPriceLimitX96: sd.quoteIsCurrency0 ? TickMath.MIN_SQRT_PRICE + 1 : TickMath.MAX_SQRT_PRICE - 1
            }),
            ""
        );

        // The returned delta is already net of whatever the hook took.
        int128 quoteDelta = sd.quoteIsCurrency0 ? bd.amount0() : bd.amount1();
        int128 tokenDelta = sd.quoteIsCurrency0 ? bd.amount1() : bd.amount0();

        uint256 spent = quoteDelta < 0 ? uint256(uint128(-quoteDelta)) : 0;
        uint256 bought = tokenDelta > 0 ? uint256(uint128(tokenDelta)) : 0;

        // Straight to the buyer, so the factory never custodies the tokens.
        if (bought != 0) poolManager.take(Currency.wrap(sd.token), sd.buyer, bought);

        if (sd.route.length != 0) {
            // The quote is NOT settled here, and settling it is what broke the
            // first version of this: the route did not put quote tokens in this
            // contract, it put a CREDIT in the pool manager. Paying the pad
            // swap by transferring tokens the factory does not hold reverts
            // with an insufficient balance against a contract that never
            // custodies anything. The route's positive quote delta and the pad
            // swap's negative one cancel where they were created, inside the
            // unlock, and only the two ends of the whole operation cross the
            // boundary.
            //
            // Ether is one of those ends, settled once for the entire route --
            // for what the first hop took, not for what was offered.
            _settle(CurrencyLibrary.ADDRESS_ZERO, etherSpent);
            // The other, when the range could not absorb everything the route
            // bought. Sent to the buyer rather than left here.
            uint256 leftover = routed - spent;
            if (leftover != 0) poolManager.take(sd.quote, sd.buyer, leftover);
            // Reported in ether, not quote: it is what the caller actually
            // parted with, and reporting the quote leg would leave the refund
            // comparing two different currencies.
            return abi.encode(etherSpent, bought);
        }

        // No route: the quote is held by this contract -- pulled from the
        // caller, wrapped from ether, or arriving as msg.value -- so the pad
        // swap's debt is paid by moving it.
        if (spent != 0) _settle(sd.quote, spent);

        return abi.encode(spent, bought);
    }

    /// @dev One leg of the route. Returns where it arrived and with how much.
    ///
    ///      Exact-input throughout: the caller committed a quantity of ether,
    ///      not a target quantity of quote, so every hop spends all of what the
    ///      last one produced. The price limit is set to the far end of the
    ///      range rather than to a real bound -- there is nothing sensible to
    ///      bound a single leg by, and the only figure that means anything to
    ///      the caller is how many tokens come out at the end, which
    ///      `minTokensOut` already governs.
    function _hop(Currency from, Hop memory h, uint256 amountIn)
        internal
        returns (Currency arrivedAt, uint256 amountOut, uint256 consumed)
    {
        bool zeroForOne = Currency.unwrap(from) < Currency.unwrap(h.currencyOut);
        PoolKey memory key = PoolKey({
            currency0: zeroForOne ? from : h.currencyOut,
            currency1: zeroForOne ? h.currencyOut : from,
            fee: h.fee,
            tickSpacing: h.tickSpacing,
            hooks: h.hooks
        });

        BalanceDelta d = poolManager.swap(
            key,
            SwapParams({
                zeroForOne: zeroForOne,
                amountSpecified: -int256(amountIn),
                sqrtPriceLimitX96: zeroForOne ? TickMath.MIN_SQRT_PRICE + 1 : TickMath.MAX_SQRT_PRICE - 1
            }),
            ""
        );

        int128 out = zeroForOne ? d.amount1() : d.amount0();
        amountOut = out > 0 ? uint256(uint128(out)) : 0;
        // What the pool actually took, which is not always what was offered: an
        // exact-input swap stops at the price limit, and a pool thin enough to
        // run out inside the limit consumes less. Settling the offered amount
        // instead left a credit the unlock could not close, and the whole
        // launch reverted with CurrencyNotSettled -- a thin routing pool
        // bricking a launch that had nothing wrong with it.
        int128 inDelta = zeroForOne ? d.amount0() : d.amount1();
        consumed = inDelta < 0 ? uint256(uint128(-inDelta)) : 0;
        arrivedAt = h.currencyOut;
    }

    /// @dev Whether ether reaches this quote by wrapping rather than by trading.
    ///
    ///      True only for WETH. There is no ether/WETH pool to route through --
    ///      wrapping is a deposit, not a swap -- so a WETH-quoted launch funded
    ///      in ether is handled by calling the token rather than the pool
    ///      manager, and its route is legitimately empty.
    function _wrapsToQuote(Currency quote) internal view returns (bool) {
        return !quote.isAddressZero() && Currency.unwrap(quote) == quotes.weth();
    }



    /// @dev The pool's shape, derived once the token has an address.
    struct Plan {
        PoolKey key;
        PoolId poolId;
        int24 tickLower;
        int24 tickUpper;
        bool quoteIsCurrency0;
    }

    function _plan(LaunchParams calldata p, address token) internal view returns (Plan memory pl) {
        // v4 orders a pool's currencies by address, so which side the token
        // lands on is decided by the address the compiler just handed us.
        pl.quoteIsCurrency0 = Currency.unwrap(p.quote) < token;
        pl.key = PoolKey({
            currency0: pl.quoteIsCurrency0 ? p.quote : Currency.wrap(token),
            currency1: pl.quoteIsCurrency0 ? Currency.wrap(token) : p.quote,
            fee: LP_FEE,
            tickSpacing: p.tickSpacing,
            hooks: IHooks(address(hook))
        });
        pl.poolId = pl.key.toId();
        // Now that the token has an address, the ordering and the decimal gap
        // are both known, so the opening price can be computed rather than
        // guessed by the caller.
        (pl.tickLower, pl.tickUpper) = LaunchGeometry.range(pl.quoteIsCurrency0, p.supply, p.openFdv, p.rangeTicks, p.tickSpacing);
    }

    /// @dev Its own frame purely for the stack: marshalling seven arguments
    ///      alongside everything `_launch` still has live does not fit.
    function _register(PoolId poolId, LaunchParams calldata p, bool quoteIsCurrency0) internal {
        hook.register(poolId, msg.sender, p.quote, quoteIsCurrency0, p.creatorFeeBps, p.snipeSurgePips, p.snipeWindow);
    }

    /// @dev Deploy the token.
    ///
    ///      A seven-argument constructor call is a lot of live stack, and with
    ///      the route threaded through `_launch` it was the allocation that
    ///      pushed that frame past sixteen slots. Its own frame has room.
    function _mint(LaunchParams calldata p) internal returns (address) {
        return address(
            new LaunchToken(
                p.name, p.symbol, p.metadataURI, msg.sender, address(hook), _totalBps(p.creatorFeeBps), p.supply
            )
        );
    }

    /// @dev Settle how the buy is funded, and return what it has to spend.
    ///
    ///      Three ways in. An ether-quoted pool spends `msg.value`. A WETH-
    ///      quoted pool funded in ether wraps it, there being no ether/WETH pool
    ///      to route through. Anything else with a route spends `msg.value` too
    ///      and converts it inside the unlock. Only a routeless ERC-20 quote
    ///      pulls from the caller, which is the original `launchAndBuy` path
    ///      and the only one that requires them to hold the quote at all.
    ///
    ///      Extracted from `_launch` because adding the route parameter pushed
    ///      that frame past sixteen slots, and a compiler error is a poor reason
    ///      to inline a decision this legible.
    function _fund(Currency quote, uint256 buyAmount, uint256 hops, bool fromEther) internal returns (uint256) {
        if (!fromEther) return _takePayment(quote, buyAmount);
        if (hops != 0) return buyAmount;
        if (_wrapsToQuote(quote)) {
            // Funded in ether against a WETH pool: wrap exactly what arrived.
            IWETH(quotes.weth()).deposit{value: msg.value}();
            return msg.value;
        }
        // Native quote: msg.value is already the quote asset.
        return buyAmount;
    }

    /// @dev Take the money before the pool exists, so the swap inside the unlock
    ///      has something to settle with. The `transferFrom` is an external call
    ///      to an address the caller chose, but it runs before any pool exists
    ///      and behind the entry point's reentrancy guard.
    /// @return how much actually arrived, which is not always what was asked for.
    function _takePayment(Currency quote, uint256 buyAmount) internal returns (uint256) {
        if (buyAmount == 0) {
            if (msg.value != 0) revert WrongValue(msg.value, 0);
            return 0;
        }
        if (quote.isAddressZero()) {
            if (msg.value < buyAmount) revert WrongValue(msg.value, buyAmount);
            return buyAmount;
        }
        if (msg.value != 0) revert WrongValue(msg.value, 0);

        // Credit what arrived, not what was asked for. A quote that takes a cut
        // on transfer delivers less than `buyAmount`, and everything downstream
        // -- the swap size, the settle, the refund -- is denominated in this
        // number. Taking it on trust made the whole call revert for exactly the
        // class of asset the contract elsewhere says it accepts.
        IERC20 asset = IERC20(Currency.unwrap(quote));
        uint256 before = asset.balanceOf(address(this));
        asset.safeTransferFrom(msg.sender, address(this), buyAmount);
        return asset.balanceOf(address(this)) - before;
    }

    /// @dev A pool whose range is exhausted mid-buy fills only part of the order.
    ///      Hand the remainder back rather than leave it here, where it would be
    ///      an unaccounted balance belonging to whoever asked next.
    function _refundUnspent(Currency quote, uint256 buyAmount, uint256 spent) internal {
        _refund(quote, msg.sender, buyAmount - spent);
        if (quote.isAddressZero() && msg.value > buyAmount) _refund(quote, msg.sender, msg.value - buyAmount);
    }

    function _refund(Currency currency, address to, uint256 amount) internal {
        if (amount == 0) return;
        if (currency.isAddressZero()) {
            (bool ok,) = to.call{value: amount}("");
            if (!ok) revert RefundFailed();
            return;
        }
        IERC20(Currency.unwrap(currency)).safeTransfer(to, amount);
    }

    function _settle(Currency currency, uint256 amount) internal {
        if (amount == 0) return;
        // Native ether is paid with the call itself; there is nothing to sync
        // and no token contract to transfer from.
        if (currency.isAddressZero()) {
            poolManager.settle{value: amount}();
            return;
        }
        poolManager.sync(currency);
        IERC20(Currency.unwrap(currency)).safeTransfer(address(poolManager), amount);
        poolManager.settle();
    }

    // ───────────────────────────── quote checks ─────────────────────────────

    /// @dev Launching is permissionless in denomination: the registry's tier
    ///      governs what the fee router will later SELL, not what a creator may
    ///      quote a pool in. The only hard refusals here are assets that would
    ///      corrupt v4's accounting rather than merely be illiquid.
    function _assertQuoteLaunchable(Currency quote) internal view {
        address a = Currency.unwrap(quote);
        // Native ETH is a legitimate quote in v4 and needs no probing.
        if (a == address(0)) return;
        if (a.code.length == 0) revert QuoteNotLaunchable(a);
        if (quotes.classify(quote) == QuoteTier.UNSUPPORTED) revert QuoteNotLaunchable(a);

        // Must at least look like an ERC-20. Fee-on-transfer and rebasing
        // quotes cannot be detected statically and are NOT rejected here ---
        // the hook defends against them instead, by booking what a redemption
        // actually delivered rather than what it asked for, so a shortfall is
        // shared between the two fee lanes rather than paid out of another
        // pool's balance.
        try IERC20Metadata(a).decimals() returns (uint8) {}
        catch {
            revert QuoteNotLaunchable(a);
        }
    }

    // ────────────────────────────────── util ──────────────────────────────────

    /// @dev What the token advertises to tax scanners: protocol 1% plus the
    ///      creator add-on, in basis points.
    ///
    ///      Read off the hook rather than duplicated as a constant here. The
    ///      hook is the contract that actually charges it and cannot be
    ///      replaced; a second copy in the factory, which can be, would be free
    ///      to drift out of agreement with the number traders really pay.
    function _totalBps(uint16 creatorFeeBps) internal view returns (uint24) {
        return uint24(uint256(hook.PROTOCOL_FEE_PIPS()) / 100 + creatorFeeBps);
    }

    function setPaused(bool paused_) external onlyOwner {
        paused = paused_;
        emit PausedSet(paused_);
    }
}
