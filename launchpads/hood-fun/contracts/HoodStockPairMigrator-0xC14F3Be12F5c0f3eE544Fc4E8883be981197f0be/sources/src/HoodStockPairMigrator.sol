// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IWETH} from "./interfaces/IUniswapV2.sol";
import {IHoodMigrator, INonfungiblePositionManager} from "./interfaces/IV3Migration.sol";
import {TickMath} from "./libraries/TickMath.sol";

/// Uniswap v3 SwapRouter02 (exactInput, encoded path) — swaps the raised WETH into
/// the coin's chosen quote token before seeding the pool. NOTE: SwapRouter02's params
/// have NO `deadline` field (unlike the original SwapRouter) — including one corrupts
/// the calldata and the swap reverts. Matches the live RH router 0xCaf681…
interface ISwapRouter {
    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }
    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);
}

/// Uniswap v3 factory — resolves the WETH/quote pool whose TWAP prices the swap.
interface IV3Factory {
    function getPool(address tokenA, address tokenB, uint24 fee) external view returns (address);
}

/// Uniswap v3 pool oracle surface — `observe` gives the cumulative ticks used to
/// derive a time-weighted average price that a single transaction cannot move.
interface IV3PoolOracle {
    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);
}

/// Minimal Uniswap v3 pool surface — read the live price to reject a squatted pool.
interface IV3PoolSlot0 {
    function slot0()
        external
        view
        returns (uint160 sqrtPriceX96, int24, uint16, uint16, uint16, uint8, bool);
}

/// Reads a coin's creator from the launchpad (so only the creator can pick the pair).
interface ICurve {
    function curves(address token)
        external
        view
        returns (uint128, uint128, uint128, uint128, address creator, uint48, bool graduated, bool, uint16);
    /// The whitelisted platform that launched a coin — used to scope an authorized
    /// selector to only the coins it actually launched (audit finding).
    function tokenPlatform(address token) external view returns (address);
}

/// @title HoodStockPairMigrator
/// @notice Drop-in successor to HoodV3Migrator that adds OPT-IN "choose your pair":
///         a coin's creator may pick a quote token — WETH (default), USDG, or any
///         tokenized stock — to pair against when the coin graduates. It seeds a
///         full-range Uniswap v3 pool and locks the LP forever, exactly like the
///         base migrator.
///
///         ⚠️ GLOBAL + CRITICAL-PATH: the launchpad routes EVERY migration through
///         the one migrator it points at, so any coin that did NOT opt in migrates
///         coin/WETH with byte-identical behavior to HoodV3Migrator. The opt-in path
///         is fully additive.
///
///         SAFETY — a coin can NEVER fail to migrate:
///           • The quote path (wrap ETH → swap WETH→quote → seed coin/quote) runs in
///             a try/catch self-call. If ANYTHING fails — the quote pool is too thin
///             (QuoterV2 depth guard), a swap reverts, an oracle hiccups — the whole
///             attempt rolls back and the coin migrates coin/WETH as normal.
///           • The depth guard: the WETH→quote swap must return ≥ (1 - maxSlippageBps)
///             of QuoterV2's estimate, or it reverts → WETH fallback. So a shallow
///             stock can be *offered* to everyone without letting a raise get wrecked.
contract HoodStockPairMigrator is IHoodMigrator, ReentrancyGuard, Ownable {
    uint24 public constant FEE = 10000; // 1% tier for the coin/quote pool
    int24 internal constant MIN_TICK = -887200;
    int24 internal constant MAX_TICK = 887200;
    uint256 internal constant BPS = 10_000;
    /// @dev Fix 1 tolerance (ported from HoodV3MigratorV2): a fresh pool inits at the
    ///      intended price exactly; a squatted/manipulated pool sits far off → rejected.
    uint256 internal constant PRICE_TOLERANCE_BPS = 100; // 1%
    /// @dev Minimum stored observations before a pool's TWAP is trusted. A pool at the
    ///      default cardinality of 1 keeps no series and its `observe` degenerates to
    ///      spot (see `setQuotePath`).
    uint16 internal constant MIN_OBSERVATION_CARDINALITY = 60;

    address public immutable launchpad;
    INonfungiblePositionManager public immutable nfpm;
    address public immutable locker;
    IWETH public immutable weth;
    address public immutable protocol;
    uint16 public immutable creatorShareBps;
    ISwapRouter public immutable swapRouter;
    IV3Factory public immutable v3Factory;

    /// Per-coin chosen quote token (set by the coin's creator pre-graduation).
    /// 0 or == weth → default coin/WETH migration.
    mapping(address token => address quote) public quoteOf;
    /// Owner-configured Uniswap v3 swap path WETH → quote (encoded token,fee,token…).
    /// A quote is only selectable once its path is set. "Allow all stocks" = set a
    /// path for each. Empty path (except WETH) → not allowed → WETH fallback.
    mapping(address quote => bytes path) public pathFor;
    /// Max acceptable slippage on the WETH→quote seed swap vs the near-spot estimate.
    uint16 public maxSlippageBps = 1000; // 10% default (AUDIT: was 15%, ceiling now 10%)
    /// @notice TWAP window used to price the WETH→quote swap.
    /// @dev AUDIT #2: the guard used to take its reference from a QuoterV2 SPOT quote
    ///      on the very pool the swap then executed against, so a manipulated price
    ///      moved the reference with it and `minOut` gave no protection. Migration is
    ///      ATOMIC with the graduating buy (`HoodCustomLaunchpad._buy` calls `_migrate`
    ///      in the same tx), so an attacker who fills the curve can bracket the swap
    ///      inside one transaction — no mempool access needed. A time-weighted price
    ///      over this window cannot be moved by a single transaction, so it is a
    ///      manipulation-resistant reference.
    uint32 public twapWindow = 1800; // 30 min
    /// Contracts allowed to pick the pair on a coin's behalf — needed for COMMUNITY
    /// coins, whose on-chain creator is the rewards VAULT (not an EOA), so the
    /// community factory sets the stock pair at launch. Owner-managed.
    mapping(address => bool) public authorizedSelector;

    event V3Migrated(address indexed token, address indexed pool, uint256 tokenId, uint256 tokenLiq, uint256 quoteLiq);
    event QuoteSelected(address indexed token, address indexed quote);
    event QuotePathSet(address indexed quote, bytes path);
    event QuoteMigrateFellBack(address indexed token, address indexed quote);

    error NotLaunchpad();
    error NotInternal();
    error PriceOverflow();
    error NotCreator();
    error AlreadyGraduated();
    error QuoteNotAllowed();
    error BadPath();
    error InsufficientTwapHistory();
    error PoolSquatted(uint160 got, uint160 want); // Fix 1: pool at an unexpected price
    error RescueFailed();

    modifier onlyLaunchpad() {
        if (msg.sender != launchpad) revert NotLaunchpad();
        _;
    }

    constructor(
        address launchpad_,
        address nfpm_,
        address locker_,
        address weth_,
        address protocol_,
        uint16 creatorShareBps_,
        address swapRouter_,
        address v3Factory_,
        address owner_
    ) Ownable(owner_) {
        require(creatorShareBps_ <= 10_000, "BAD_BPS");
        require(
            launchpad_ != address(0) && nfpm_ != address(0) && locker_ != address(0) && weth_ != address(0)
                && protocol_ != address(0) && swapRouter_ != address(0) && v3Factory_ != address(0),
            "ZERO_ADDR"
        );
        launchpad = launchpad_;
        nfpm = INonfungiblePositionManager(nfpm_);
        locker = locker_;
        weth = IWETH(weth_);
        protocol = protocol_;
        creatorShareBps = creatorShareBps_;
        swapRouter = ISwapRouter(swapRouter_);
        v3Factory = IV3Factory(v3Factory_);
    }

    // -------------------------------------------------------------- config

    /// @notice Whitelist a quote token by setting the WETH→quote v3 path (owner).
    ///         Pass empty bytes to remove. WETH needs no path (it's the default).
    /// @dev AUDIT #2: the path is now restricted to a SINGLE hop — exactly
    ///      `WETH | fee | quote` (43 packed bytes) — for two reasons. It shrinks the
    ///      manipulation surface to one pool, and it means that one pool is also the
    ///      pool whose TWAP prices the swap, so the reference and the execution venue
    ///      are the same market. Multi-hop routes were also measurably lossy in
    ///      practice (a two-hop NVDA route only cleared a 50% guard where the direct
    ///      pool clears 10%). The pool must already exist.
    function setQuotePath(address quote, bytes calldata path) external onlyOwner {
        if (path.length != 0) {
            if (path.length != 43) revert BadPath();
            (address tokenIn, uint24 fee, address tokenOut) = _decodeSingleHop(path);
            if (tokenIn != address(weth) || tokenOut != quote) revert BadPath();
            address pool = v3Factory.getPool(address(weth), quote, fee);
            if (pool == address(0)) revert BadPath();
            // AUDIT #2 — the TWAP is only meaningful if the pool actually RETAINS
            // history. A pool left at the default `observationCardinality == 1` does
            // not store a series: `observe` still returns a value, but it is the
            // current tick extrapolated — i.e. spot, the very thing an attacker can
            // move atomically. That would silently reduce this guard back to the
            // vulnerable design while appearing to work. Require real history, and
            // require the pool to already serve the configured window. Operators must
            // call `increaseObservationCardinalityNext` on the pool and let it warm
            // before a quote can be whitelisted.
            (,,, uint16 cardinality,,,) = IV3PoolSlot0(pool).slot0();
            if (cardinality < MIN_OBSERVATION_CARDINALITY) revert InsufficientTwapHistory();
            uint32[] memory probe = new uint32[](2);
            probe[0] = twapWindow;
            probe[1] = 0;
            IV3PoolOracle(pool).observe(probe); // reverts if the window isn't covered
        }
        pathFor[quote] = path;
        emit QuotePathSet(quote, path);
    }

    /// @notice TWAP window for the swap's price reference (owner). Bounded so it can
    ///         neither be set to a manipulable near-spot value nor to a window longer
    ///         than pools reliably retain observations for.
    function setTwapWindow(uint32 secs) external onlyOwner {
        require(secs >= 300 && secs <= 3600, "BAD_WINDOW");
        twapWindow = secs;
    }

    /// @dev AUDIT: the ceiling was 50%, which is also the ceiling on how much of an
    ///      opted raise a bad swap path (or an adverse fill) could give up. Tightened
    ///      to 10% so the worst case on the opt-in path is materially bounded.
    function setMaxSlippageBps(uint16 bps) external onlyOwner {
        require(bps <= 1000, "TOO_LOOSE");
        maxSlippageBps = bps;
    }


    // ---- Fix 4 (from HoodV3MigratorV2): rescue funds stuck IN THIS CONTRACT only.
    // Between migrations this holds ~nothing (mint/swap dust at most). These recover
    // misdirected tokens/ETH. They CANNOT reach locked LP — that NFT lives in the
    // Locker, a separate contract this migrator neither owns nor controls.
    function rescueTokens(address token, uint256 amount, address to) external onlyOwner {
        require(to != address(0), "ZERO_TO");
        require(IERC20(token).transfer(to, amount), "TRANSFER_FAILED");
    }

    function rescueETH(address to) external onlyOwner nonReentrant {
        require(to != address(0), "ZERO_TO");
        (bool ok,) = to.call{value: address(this).balance}("");
        if (!ok) revert RescueFailed();
    }

    /// @notice Authorize a contract (e.g. the community factory) to pick pairs on a
    ///         coin's behalf — for community coins whose creator is the vault.
    function setAuthorizedSelector(address who, bool ok) external onlyOwner {
        authorizedSelector[who] = ok;
    }

    /// @notice Pick the token to pair against at graduation. Callable by the coin's
    ///         creator (regular coins) OR an authorized selector (community factory,
    ///         since a community coin's creator is the vault). Must be pre-graduation;
    ///         `quote` must have a configured path.
    function selectQuote(address token, address quote) external {
        (,,,, address creator,, bool graduated,,) = ICurve(launchpad).curves(token);
        // AUDIT: an authorized selector used to be able to set the pair on ANY coin,
        // not just the ones it launched. Scope it to coins whose launchpad platform IS
        // that selector, so e.g. the community factory can only pick pairs for its own
        // community coins. The creator keeps unconditional control of their own coin.
        bool isCreator = msg.sender == creator;
        bool isScopedSelector =
            authorizedSelector[msg.sender] && ICurve(launchpad).tokenPlatform(token) == msg.sender;
        if (!isCreator && !isScopedSelector) revert NotCreator();
        if (graduated) revert AlreadyGraduated();
        if (quote != address(0) && quote != address(weth) && pathFor[quote].length == 0) revert QuoteNotAllowed();
        quoteOf[token] = quote;
        emit QuoteSelected(token, quote);
    }

    // -------------------------------------------------------------- migrate

    /// @inheritdoc IHoodMigrator
    function migrate(address token, address creator)
        external
        payable
        override
        onlyLaunchpad
        nonReentrant
        returns (address pool)
    {
        address quote = quoteOf[token];
        // opt-in path: try to seed coin/quote; on ANY failure fall back to coin/WETH.
        if (quote != address(0) && quote != address(weth) && pathFor[quote].length > 0) {
            try this.quoteMigrate(token, creator, quote, msg.value) returns (address p) {
                return p;
            } catch {
                emit QuoteMigrateFellBack(token, quote);
                // fall through — the reverted self-call rolled back any partial swap,
                // and the ETH is still held here for the WETH seed below.
            }
        }
        return _seedWeth(token, creator, msg.value);
    }

    /// @dev EXTERNAL but self-only: isolates the quote path so try/catch can roll it
    ///      back atomically (partial swap included) and fall back to WETH.
    function quoteMigrate(address token, address creator, address quote, uint256 ethIn)
        external
        returns (address pool)
    {
        if (msg.sender != address(this)) revert NotInternal();

        // 1. wrap the raised ETH, swap WETH → quote against a TWAP-derived floor.
        weth.deposit{value: ethIn}();
        bytes memory path = pathFor[quote];
        // AUDIT #2 — MANIPULATION-RESISTANT REFERENCE. Price the expected output from
        // the pool's time-weighted average over `twapWindow`, not from a spot quote.
        // Because `_migrate` runs inside the graduating buy's transaction, an attacker
        // who fills the curve can move the pool immediately before the swap and restore
        // it immediately after, all atomically. A spot reference moves with that push
        // and the floor becomes meaningless; a TWAP over many blocks does not, so the
        // floor still binds and a manipulated swap simply misses it → WETH fallback.
        // `observe` reverts on a pool without enough history, which also serves as the
        // dead-pool check (→ WETH fallback).
        uint256 twapExpected = _twapQuote(quote, path, ethIn);
        require(twapExpected > 0, "NO_QUOTE");
        uint256 minOut = (twapExpected * (BPS - maxSlippageBps)) / BPS;

        IERC20(address(weth)).approve(address(swapRouter), ethIn);
        uint256 quoteAmount = swapRouter.exactInput(
            ISwapRouter.ExactInputParams({
                path: path,
                recipient: address(this),
                amountIn: ethIn,
                amountOutMinimum: minOut // too-thin fill reverts → WETH fallback
            })
        );

        // 2. seed the coin/quote full-range pool + lock, same as the WETH path.
        uint256 tokenAmount = IERC20(token).balanceOf(address(this));
        pool = _seed(token, quote, tokenAmount, quoteAmount, creator);
    }

    /// @dev The default coin/WETH migration — byte-identical to HoodV3Migrator so
    ///      non-opted coins are unaffected by this migrator swap.
    function _seedWeth(address token, address creator, uint256 ethIn) internal returns (address pool) {
        weth.deposit{value: ethIn}();
        uint256 tokenAmount = IERC20(token).balanceOf(address(this));
        pool = _seed(token, address(weth), tokenAmount, ethIn, creator);
    }

    /// @dev Shared full-range seed + lock. `quoteToken`/`quoteAmount` is WETH for the
    ///      default path or the chosen stock/USDG for the opt-in path.
    function _seed(address token, address quoteToken, uint256 tokenAmount, uint256 quoteAmount, address creator)
        internal
        returns (address pool)
    {
        (address t0, address t1, uint256 a0, uint256 a1) = token < quoteToken
            ? (token, quoteToken, tokenAmount, quoteAmount)
            : (quoteToken, token, quoteAmount, tokenAmount);

        uint160 intended = _sqrtPriceX96(a0, a1);
        pool = nfpm.createAndInitializePoolIfNecessary(t0, t1, FEE, intended);

        // Fix 1 (from HoodV3MigratorV2) — reject a squatted/manipulated pool.
        // createAndInitializePoolIfNecessary silently returns a PRE-EXISTING pool at
        // whatever price it was initialized to; minting into a garbage-priced pool
        // would deposit a skewed ratio and leave value stealable. Require the live
        // price is within tolerance of the price WE intended, else revert (migration
        // safely retries after the Safe normalizes the pool). Applies to BOTH the
        // coin/WETH default and the coin/stock opt-in pool.
        (uint160 current,,,,,,) = IV3PoolSlot0(pool).slot0();
        uint256 lo = (uint256(intended) * (BPS - PRICE_TOLERANCE_BPS)) / BPS;
        uint256 hi = (uint256(intended) * (BPS + PRICE_TOLERANCE_BPS)) / BPS;
        if (current < lo || current > hi) revert PoolSquatted(current, intended);

        IERC20(t0).approve(address(nfpm), a0);
        IERC20(t1).approve(address(nfpm), a1);
        (uint256 tokenId,,,) = nfpm.mint(
            INonfungiblePositionManager.MintParams({
                token0: t0,
                token1: t1,
                fee: FEE,
                tickLower: MIN_TICK,
                tickUpper: MAX_TICK,
                amount0Desired: a0,
                amount1Desired: a1,
                // Fix 2 — slippage floor (99%, tolerant of full-range rounding dust);
                // Fix 1's exact price check is the real guard, this is the backstop.
                amount0Min: (a0 * 99) / 100,
                amount1Min: (a1 * 99) / 100,
                recipient: address(this),
                deadline: block.timestamp
            })
        );
        nfpm.safeTransferFrom(address(this), locker, tokenId, abi.encode(creator, protocol, creatorShareBps));
        emit V3Migrated(token, pool, tokenId, tokenAmount, quoteAmount);
    }

    /// @dev Expected `quote` out for `ethIn` WETH, priced off the pool's TWAP.
    ///      Single-hop by construction (`setQuotePath` enforces it), so the pool that
    ///      prices the swap IS the pool the swap executes against.
    function _twapQuote(address quote, bytes memory path, uint256 ethIn) internal view returns (uint256) {
        (,uint24 fee,) = _decodeSingleHop(path);
        address pool = v3Factory.getPool(address(weth), quote, fee);
        if (pool == address(0)) return 0;

        uint32 window = twapWindow;
        uint32[] memory secondsAgos = new uint32[](2);
        secondsAgos[0] = window;
        secondsAgos[1] = 0;
        // Reverts if the pool lacks `window` seconds of observations — caught by the
        // caller's try/catch and turned into a WETH fallback.
        (int56[] memory tickCumulatives,) = IV3PoolOracle(pool).observe(secondsAgos);

        int56 delta = tickCumulatives[1] - tickCumulatives[0];
        int24 avgTick = int24(delta / int56(uint56(window)));
        // round toward negative infinity, matching Uniswap's OracleLibrary
        if (delta < 0 && (delta % int56(uint56(window)) != 0)) avgTick--;

        return _quoteAtTick(avgTick, ethIn, address(weth), quote);
    }

    /// @dev Uniswap OracleLibrary.getQuoteAtTick, using OZ mulDiv for the 512-bit math.
    function _quoteAtTick(int24 tick, uint256 baseAmount, address baseToken, address quoteToken)
        internal
        pure
        returns (uint256 quoteAmount)
    {
        uint160 sqrtRatioX96 = TickMath.getSqrtRatioAtTick(tick);
        if (sqrtRatioX96 <= type(uint128).max) {
            uint256 ratioX192 = uint256(sqrtRatioX96) * sqrtRatioX96;
            quoteAmount = baseToken < quoteToken
                ? Math.mulDiv(ratioX192, baseAmount, 1 << 192)
                : Math.mulDiv(1 << 192, baseAmount, ratioX192);
        } else {
            uint256 ratioX128 = Math.mulDiv(sqrtRatioX96, sqrtRatioX96, 1 << 64);
            quoteAmount = baseToken < quoteToken
                ? Math.mulDiv(ratioX128, baseAmount, 1 << 128)
                : Math.mulDiv(1 << 128, baseAmount, ratioX128);
        }
    }

    /// @dev Decode a packed single-hop v3 path: `tokenIn(20) | fee(3) | tokenOut(20)`.
    function _decodeSingleHop(bytes memory path)
        internal
        pure
        returns (address tokenIn, uint24 fee, address tokenOut)
    {
        require(path.length == 43, "BAD_PATH_LEN");
        assembly {
            tokenIn := shr(96, mload(add(path, 32)))
            fee := shr(232, mload(add(path, 52)))
            tokenOut := shr(96, mload(add(path, 55)))
        }
    }

    function _sqrtPriceX96(uint256 amount0, uint256 amount1) internal pure returns (uint160) {
        uint256 ratioX192 = Math.mulDiv(amount1, 1 << 192, amount0);
        uint256 sqrtP = Math.sqrt(ratioX192);
        if (sqrtP > type(uint160).max) revert PriceOverflow();
        return uint160(sqrtP);
    }
}
