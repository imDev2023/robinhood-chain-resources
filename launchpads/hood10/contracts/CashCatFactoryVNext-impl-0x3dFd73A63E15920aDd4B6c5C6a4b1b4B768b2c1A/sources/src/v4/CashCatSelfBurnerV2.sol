// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {IUnlockCallback} from "v4-core/src/interfaces/callback/IUnlockCallback.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "v4-core/src/types/PoolId.sol";
import {Currency, CurrencyLibrary} from "v4-core/src/types/Currency.sol";
import {BalanceDelta} from "v4-core/src/types/BalanceDelta.sol";
import {SwapParams} from "v4-core/src/types/PoolOperation.sol";
import {TickMath} from "v4-core/src/libraries/TickMath.sol";
import {StateLibrary} from "v4-core/src/libraries/StateLibrary.sol";
import {FullMath} from "v4-core/src/libraries/FullMath.sol";
import {FixedPoint96} from "v4-core/src/libraries/FixedPoint96.sol";
import {CurrencySettler} from "./lib/CurrencySettler.sol";
import {CashCatHookV2} from "./CashCatHookV2.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ExactTransfer} from "./lib/ExactTransfer.sol";
import {CashCatToken} from "./CashCatToken.sol";

/// @title CashCatSelfBurnerV2
/// @notice Fee recipient for self-burn launches: the creator share of every
///         fee market-buys the launched token on its own pool and destroys it
///         — a real burn that reduces totalSupply on-chain, not a dead-address
///         park. Anyone can pull the trigger; nobody — creator, platform, or
///         owner — can redirect the flow. The contract has no owner and no
///         withdrawal path by construction.
/// @dev The burn buy trades through the pool like any other swap, so it pays
///      the pool's fee too — a slice of every burn feeds the next one and the
///      platform's CASHCAT burn. Burns carry no slippage guard on purpose
///      (moving the price up is the point), so what keeps the buy too small to
///      be worth sandwiching is its size relative to the pool's depth: see
///      `DEPTH_FEE_MULTIPLE`. The absolute cap and the one-burn-per-block gate
///      do a different job — they bound how fast a backlog drains and how much
///      is exposed to any single call, not whether a sandwich pays. A backlog
///      of accrued fees drains over blocks rather than arriving all at once.
contract CashCatSelfBurnerV2 is IUnlockCallback, ReentrancyGuard {
    using CurrencyLibrary for Currency;
    using CurrencySettler for Currency;
    using PoolIdLibrary for PoolKey;
    using StateLibrary for IPoolManager;
    using SafeERC20 for IERC20;

    error NotFactory();
    error NotPoolManager();
    error UnknownPool();
    error AlreadyRegistered();
    error NothingToBurn();
    error BountyPayFailed();
    error BurnedThisBlock();
    error PoolKeyMismatch();
    /// @dev The pool does not pay its fees here, so this burner could never
    ///      fund a burn for it.
    error NotFeeRecipient();
    /// @dev The swap took a different amount out of this contract than it
    ///      reported spending. One balance backs every pool's fuel here, so the
    ///      difference would be drawn from a pool that had nothing to do with
    ///      this burn.
    error InexactSettlement(uint256 debited, uint256 spent);

    /// @dev `ethSpent` is what reached the pool, which is not what was pulled
    ///      from the tank — the fee and any unspent remainder are not in it. The
    ///      parameter was called `ethIn` while a variable of that name meant
    ///      something else a few lines away. Renaming it leaves the event
    ///      signature untouched, since parameter names are not part of it.
    event Burned(PoolId indexed poolId, address indexed token, uint256 ethSpent, uint256 tokensBurned, uint256 bounty);

    /// @notice Most fuel a single burn call may spend, on a pool quoted in
    ///         native ether. Backlogs drain over multiple blocks instead.
    ///
    /// @dev    Applies to native pools only, and that is deliberate rather than
    ///         an oversight carried over from V1.
    ///
    ///         The figure is eighteen-decimal ether. Against a six-decimal
    ///         stablecoin the same literal is a hundred billion units, so it
    ///         could never bind, and there is no honest way to rewrite it: the
    ///         economic size of "a tenth of an ether" in another asset needs a
    ///         price, and reading one here would put an oracle in the burn
    ///         path for a bound that is not the one doing the work.
    ///
    ///         What does the work is `_depthCap`, which is a share of the
    ///         pool's own depth and therefore decimals-agnostic and priced in
    ///         the pool's own terms. Issue #20 established exactly this: an
    ///         absolute cap says nothing about whether a buy is worth
    ///         sandwiching, because what matters is its size relative to the
    ///         pool. So a non-native pool is bounded by `_depthCap` alone,
    ///         which is the bound that carries the security argument.
    ///
    ///         Half an ether rather than a tenth, because a tenth was not a
    ///         second opinion on `_depthCap` — it was overriding it. At the 1%
    ///         tier the depth cap is a quarter of a percent of the reserve, so
    ///         a tenth of an ether becomes the binding limit above forty ether
    ///         of depth, and by four hundred it permits a tenth of what the
    ///         depth cap has already found safe. A pool does not become more
    ///         fragile as it grows, and throttling the burn as it does only
    ///         leaves fuel sitting in the tank.
    ///
    ///         It stays as a ceiling rather than being removed, so a fault in
    ///         `_depthCap` cannot spend an unbounded amount in one call. The
    ///         depth cap still applies underneath and still binds first on any
    ///         pool thin enough for size to matter. `BurnSandwich` measures
    ///         both: a sandwich loses money at every tier and depth tried, the
    ///         cap is the same fraction of the pool at every size, and the
    ///         price cannot be pushed up to squeeze it shut.
    uint256 public constant MAX_BURN_PER_CALL = 0.5 ether;
    /// @notice How much of the pool's depth a burn may take, as a fraction of
    ///         the pool's own fee rate. A buy of `rate / DEPTH_FEE_MULTIPLE` of
    ///         the quote side moves the price by about `2 * rate / MULTIPLE`,
    ///         against the `2 * rate` a round trip through the pool costs — so
    ///         at four, the fee is four times the impact and sandwiching the buy
    ///         loses money.
    ///
    ///         The factor of two is worth stating explicitly: on a
    ///         constant-product curve, spending a fraction `f` of the input
    ///         reserve moves the price by about `2f`, not `f`. At a multiple of
    ///         four the buy takes `rate/4` of the reserve and moves the price
    ///         about `rate/2`, against the `2 * rate` a round trip costs.
    ///
    ///         Sized against depth rather than in ETH because that is what
    ///         decides the question. A launch pool starts thin — the seeded
    ///         curve behaves like a constant-product pair holding a little over
    ///         one ETH — so a fixed tenth of an ETH is a seven percent trade
    ///         there and a rounding error on a deep pool. The ratio holds at
    ///         every size; a fixed number of ETH cannot.
    ///
    ///         Scaled by the live rate rather than assuming one. A config may
    ///         charge any rate, and a fixed fraction safe at one percent is not
    ///         safe at a quarter of that: the buy would stay the same share of
    ///         depth while the fee protecting it shrank. Read from the pool
    ///         rather than held here, so a pool's own rate is always the one
    ///         that sizes its burns.
    ///
    ///         At zero the pool charges nothing, nothing makes a sandwich cost
    ///         anything, and this yields zero — a burn cannot proceed. The
    ///         factory refuses a self-burn config with a zero base rate so that
    ///         is not a state a pool can be left in permanently.
    uint256 public constant DEPTH_FEE_MULTIPLE = 4;
    /// @notice Share paid to whoever triggers the burn, in bps — of the ETH the
    ///         burn buy actually consumed, not of the fuel drawn to size it.
    ///         Because a hundredth is held back as a reservation before the buy,
    ///         a completely filled burn earns 1% of the remaining 99%, or about
    ///         0.99% of the fuel drawn. What the fee does not come to goes back
    ///         to the pool's tank as fuel for the next burn.
    ///
    ///         The bounty is what makes burns self-driving: the moment a pool's
    ///         accrued fees cover gas plus profit, keeper bots race to fire it —
    ///         no operator, no cron, no trust. Anyone (including the platform's
    ///         visitors) can collect it.
    uint256 public constant BOUNTY_BPS = 100; // 1% of what the burn buy spent
    /// @notice Basis-points denominator, 10_000 = 100%.
    uint256 public constant BPS_DENOMINATOR = 10_000;

    IPoolManager public immutable poolManager;
    CashCatHookV2 public immutable hook;
    address public immutable factory;

    mapping(PoolId => PoolKey) private _keys;
    /// @notice Claimed fuel waiting to burn, per pool (a claim larger than the
    ///         per-call cap drains across successive blocks).
    mapping(PoolId => uint256) public unburned;
    /// @dev Keyed on block.number, which on an Orbit chain tracks the parent
    ///      chain's block number — so "once per block" is coarser (stricter)
    ///      than one L2 block. That only slows drain cadence, never loosens it.
    mapping(PoolId => uint256) private _lastBurnBlock;

    constructor(IPoolManager poolManager_, CashCatHookV2 hook_, address factory_) {
        poolManager = poolManager_;
        hook = hook_;
        factory = factory_;
    }

    /// @notice The factory wires each self-burn pool in at launch.
    /// @dev An entry has to survive two ways of being wrong, and the factory
    ///      that builds it is replaceable while this registry is not.
    ///      Registration is one-shot and this contract has no owner, so a bad
    ///      entry would be permanent — both halves are checked here rather than
    ///      taken on trust.
    ///
    ///      The id and the key must name the same pool. `burn` claims a pool's
    ///      fees by id and then spends them swapping through the stored key, so
    ///      a pair that disagreed would buy and destroy one token with another
    ///      token's fee stream — silently, since neither side can tell on its
    ///      own.
    ///
    ///      And the pool must pay its fees here. A pool wired to a different
    ///      recipient can never fund a burn: `claim` answers only its own
    ///      recipient, so an entry for one would sit in this registry looking
    ///      live and revert on every call. Asked at registration, the launch
    ///      that built the mismatch fails instead of the burn that inherits it.
    function register(PoolId poolId, PoolKey calldata key) external {
        if (msg.sender != factory) revert NotFactory();
        if (PoolId.unwrap(key.toId()) != PoolId.unwrap(poolId)) revert PoolKeyMismatch();
        (address feeRecipient,,,,) = hook.poolConfigs(poolId);
        if (feeRecipient != address(this)) revert NotFeeRecipient();
        if (Currency.unwrap(_keys[poolId].currency1) != address(0)) revert AlreadyRegistered();
        _keys[poolId] = key;
    }

    /// @notice Claims the pool's accrued creator share from the hook and
    ///         buys + burns the token with it. Callable by anyone; pays the
    ///         caller the bounty. Each call spends at most a share of the
    ///         pool's own depth — which is what keeps the buy too small to be
    ///         worth sandwiching — and never more than MAX_BURN_PER_CALL, at
    ///         most once per pool per block. Larger backlogs drain across
    ///         blocks.
    /// @dev Guarded, like every other function in the system that hands a
    ///      caller ETH. Paying the bounty gives `msg.sender` control, and the
    ///      only things standing between that and a second entry today are the
    ///      one-burn-per-block gate and the fact that every effect lands before
    ///      the transfer. Both are true and neither is the point: they are
    ///      properties of how this happens to be written, and a later change to
    ///      either would remove the protection silently. The guard says so
    ///      directly instead.
    ///
    ///      `unlockCallback` is deliberately left unguarded, matching the hook
    ///      and the distributor. The pool manager calls it back while this frame
    ///      still holds the lock, so guarding it too would refuse the contract's
    ///      own swap.
    function burn(PoolId poolId) external nonReentrant returns (uint256 tokensBurned) {
        PoolKey memory key = _keys[poolId];
        if (Currency.unwrap(key.currency1) == address(0)) revert UnknownPool();
        if (_lastBurnBlock[poolId] == block.number) revert BurnedThisBlock();
        _lastBurnBlock[poolId] = block.number;

        // Pull everything claimable into the per-pool fuel tank, then spend at
        // most the per-call cap.
        //
        // The tank is credited with what arrived, not with what the hook says
        // it settled. Those differ for a quote asset that taxes the recipient:
        // the hook clears the whole tab and its payout deliberately tolerates a
        // short credit, so the returned figure is the amount owed rather than
        // the amount delivered. Crediting the reported number would book fuel
        // this contract does not hold, against a balance shared with every
        // other self-burn pool.
        //
        // Measured, matching what the hook itself does one step upstream and
        // what this contract already does on the way out.
        if (hook.pending(poolId) > 0 || hook.tab(poolId) > 0) {
            // Paid in whatever the pool is quoted in, which is currency0.
            bool nativeQuote = key.currency0.isAddressZero();
            uint256 heldBeforeClaim = nativeQuote
                ? address(this).balance
                : IERC20(Currency.unwrap(key.currency0)).balanceOf(address(this));
            hook.claim(poolId);
            uint256 heldAfterClaim = nativeQuote
                ? address(this).balance
                : IERC20(Currency.unwrap(key.currency0)).balanceOf(address(this));
            // Direction checked before the subtraction, so a balance that
            // somehow fell across the claim says so by name rather than
            // panicking on an underflow. Not reachable — this contract grants
            // no allowances and `burn` is guarded — but this is the one
            // measurement in the release that would otherwise fail namelessly.
            if (heldAfterClaim < heldBeforeClaim) {
                revert InexactSettlement(heldBeforeClaim - heldAfterClaim, 0);
            }
            unburned[poolId] += heldAfterClaim - heldBeforeClaim;
        }
        uint256 fuel = unburned[poolId];
        if (fuel == 0) revert NothingToBurn();
        uint256 ethIn = fuel;
        // The absolute cap is denominated in ether and only means anything on
        // a pool quoted in it. See the constant.
        if (key.currency0.isAddressZero() && ethIn > MAX_BURN_PER_CALL) ethIn = MAX_BURN_PER_CALL;
        // and never more than a small share of what the pool actually holds,
        // so the buy stays too small to be worth sandwiching whatever the pool
        // is worth. A pool resting exactly on its launch price has no liquidity
        // active to size against and waits for a buy — see `_depthCap`.
        uint256 depthCap = _depthCap(poolId);
        if (ethIn > depthCap) ethIn = depthCap;
        if (ethIn == 0) revert NothingToBurn();
        unburned[poolId] = fuel - ethIn;

        // Set aside the most the caller could earn, so the buy is sized against
        // what is certainly free to spend. This is a reservation, not the fee.
        uint256 reserve = (ethIn * BOUNTY_BPS) / BPS_DENOMINATOR;
        uint256 burnEth = ethIn - reserve;
        /*
         * What the settlement cost this contract, against what the swap says
         * it spent.
         *
         * The quote leaves through the pool manager's sync/settle protocol
         * rather than a plain transfer, so `payExact` does not apply. The
         * manager credits what it received, so a token delivering less than it
         * was sent leaves the swap unsatisfied and reverts there; a token
         * taking more from this contract than it delivers does not, and the
         * excess would be drawn from another pool's `unburned`.
         *
         * The unlock is the only place the settlement happens, so measuring
         * across it captures the whole movement.
         */
        bool quoteIsToken = !key.currency0.isAddressZero();
        uint256 heldBeforeSwap =
            quoteIsToken ? IERC20(Currency.unwrap(key.currency0)).balanceOf(address(this)) : 0;
        (uint256 tokensOut, uint256 ethSpent) =
            abi.decode(poolManager.unlock(abi.encode(key, burnEth)), (uint256, uint256));
        if (quoteIsToken) {
            uint256 debited =
                heldBeforeSwap - IERC20(Currency.unwrap(key.currency0)).balanceOf(address(this));
            if (debited != ethSpent) revert InexactSettlement(debited, ethSpent);
        }
        // Earned on what actually bought and burned, not on what was set aside.
        // The sibling burner has always done it this way, and the difference
        // only shows if a buy ever stops short: paid on the reservation, a
        // caller collects the whole fee for a burn that barely happened, and
        // the tank drains through fees rather than through burning. The hook
        // rejects a price-limited partial fill on this swap shape today, so
        // that cannot happen — but it is a property of the hook, not of this
        // contract, and this contract is the one paying.
        uint256 bounty = (ethSpent * BOUNTY_BPS) / BPS_DENOMINATOR;
        // Everything neither spent nor earned goes back to the tank, so the
        // burner's ETH balance and its accounting can never diverge. Covers the
        // ordinary case too: a full buy leaves the slice of the reservation the
        // fee did not come to.
        unburned[poolId] += ethIn - ethSpent - bounty;
        // `tokensOut` is guaranteed non-zero: the callback refuses a swap that
        // bought nothing, at the point that becomes known
        tokensBurned = tokensOut;
        if (bounty > 0) {
            if (key.currency0.isAddressZero()) {
                (bool paid,) = msg.sender.call{value: bounty}("");
                if (!paid) revert BountyPayFailed();
            } else {
                // One balance of the quote backs every pool's `unburned` fuel,
                // and this pool's has already been adjusted by the time the
                // bounty moves. A transfer debiting more than the bounty would
                // take the difference from another pool's tank, so the debit is
                // required to be exact; failing it unwinds the whole burn.
                ExactTransfer.payExact(
                    IERC20(Currency.unwrap(key.currency0)), msg.sender, bounty
                );
            }
        }
        emit Burned(poolId, Currency.unwrap(key.currency1), ethSpent, tokensBurned, bounty);
    }

    /// @dev The ETH side of the active range, divided down. A concentrated
    ///      position behaves locally like a constant-product pair holding
    ///      `liquidity / sqrtPrice` of the ETH side, which is the quantity a
    ///      buy's price impact is measured against.
    ///
    ///      This is liquidity active at the pool's current tick, and a launch
    ///      pool has exactly one range: `[minUsableTick, startTick]`, opened at
    ///      `startTick`. A position covers `lower <= tick < upper`, so a pool
    ///      resting exactly on its launch price reads as zero and no burn can be
    ///      sized — until any buy at all moves the price back inside the range.
    ///      Reaching that price takes a token the pool never emitted, since a
    ///      swap rounds in the pool's favour on the way out, so selling back
    ///      everything it gave stops a wei short of it.
    function _depthCap(PoolId poolId) private view returns (uint256) {
        (uint160 sqrtPriceX96,,,) = poolManager.getSlot0(poolId);
        if (sqrtPriceX96 == 0) return 0;
        uint128 liquidity = poolManager.getLiquidity(poolId);
        if (liquidity == 0) return 0;
        uint256 reserveEth = FullMath.mulDiv(liquidity, FixedPoint96.Q96, sqrtPriceX96);
        // the rate this pool charges right now, which is what a sandwich would
        // have to pay twice over
        uint256 rate = hook.currentFeeRate(poolId, address(this));
        return FullMath.mulDiv(reserveEth, rate, DEPTH_FEE_MULTIPLE * hook.FEE_DENOMINATOR());
    }

    function unlockCallback(bytes calldata data) external returns (bytes memory) {
        if (msg.sender != address(poolManager)) revert NotPoolManager();
        (PoolKey memory key, uint256 ethIn) = abi.decode(data, (PoolKey, uint256));

        BalanceDelta delta = poolManager.swap(
            key,
            SwapParams({
                zeroForOne: true,
                amountSpecified: -int256(ethIn),
                sqrtPriceLimitX96: TickMath.MIN_SQRT_PRICE + 1
            }),
            ""
        );
        uint256 tokensOut = uint256(uint128(delta.amount1()));
        // What the pool asks for is settled without a ceiling on it, unlike the
        // sibling distributor, which refuses a swap settling more than the input
        // it was handed. That guard is there because a launcher chooses the
        // venue a round buys on: an arbitrary pool carries an arbitrary hook,
        // and a hook can move a swap's delta. This burner never trades anywhere
        // but the pool it was registered against, and `register` proves that key
        // hashes to a pool id the factory created — so the hook on the other
        // side of this swap is the CashCat hook, which takes its fee inside the
        // specified amount and cannot settle beyond it. The asymmetry is the
        // trust boundary, not an omission.
        // Nothing bought means nothing to burn, and the moment that is known is
        // here — before settling ETH, taking zero tokens and burning zero of
        // them, all of which is thrown away when this reverts anyway. Reverting
        // inside the callback also rolls back the caller's fuel deduction, so a
        // pool that cannot fill still cannot be milked for bounties. The pool
        // manager runs this without a try/catch, so the error arrives at the
        // caller exactly as it would have from `burn`.
        if (tokensOut == 0) revert NothingToBurn();
        uint256 ethSpent = uint256(uint128(-delta.amount0()));
        key.currency0.settle(poolManager, address(this), ethSpent, false);
        // take the tokens here, then destroy them for real — totalSupply drops
        key.currency1.take(poolManager, address(this), tokensOut, false);
        CashCatToken(Currency.unwrap(key.currency1)).burn(tokensOut);
        return abi.encode(tokensOut, ethSpent);
    }

    /// @notice The pool key a self-burn pool trades through.
    function poolKeyOf(PoolId poolId) external view returns (PoolKey memory) {
        return _keys[poolId];
    }

    receive() external payable {} // the hook pays claims in native ETH
}
