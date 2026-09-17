// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {BaseHook} from "uniswap-hooks/base/BaseHook.sol";
import {Ownable2Step, Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ExactTransfer} from "./lib/ExactTransfer.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {IHooks} from "v4-core/src/interfaces/IHooks.sol";
import {IUnlockCallback} from "v4-core/src/interfaces/callback/IUnlockCallback.sol";
import {Hooks} from "v4-core/src/libraries/Hooks.sol";
import {SafeCast} from "v4-core/src/libraries/SafeCast.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {PoolId} from "v4-core/src/types/PoolId.sol";
import {Currency, CurrencyLibrary} from "v4-core/src/types/Currency.sol";
import {BalanceDelta} from "v4-core/src/types/BalanceDelta.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary, toBeforeSwapDelta} from "v4-core/src/types/BeforeSwapDelta.sol";
import {SwapParams, ModifyLiquidityParams} from "v4-core/src/types/PoolOperation.sol";

/// @title CashCatHookV2
/// @notice The fee engine for CashCat pools. Takes the trading fee from the
///         quote side of every swap — skimmed from the quote input on buys and
///         the quote output on sells, for both exact-input and exact-output
///         swaps — so fees only ever exist in the asset the pool is priced in.
///         One flat rate for the life of the pool.
///
///         Fees move in two lanes: `sweep(poolId)` is permissionless and books
///         the platform share while crediting the creator share to the
///         creator's unclaimed balance; `claim(poolId)` — fee recipient only —
///         sweeps, then pays the whole balance out.
///
///         Trust model — not upgradeable. Only the factory can register pools
///         or add liquidity. Unclaimed creator balances can only ever move to
///         the creator; the owner can only redirect the platform's own share.
contract CashCatHookV2 is BaseHook, Ownable2Step, ReentrancyGuard, IUnlockCallback {
    using SafeCast for int256;
    using SafeERC20 for IERC20;
    using CurrencyLibrary for Currency;

    struct PoolConfig {
        address creator; // receives the fee stream; can hand off via updateCreator
        uint16 creatorFeeBps; // creator's share of fees, fixed at launch
        uint24 feeRate; // the pool's fee, pips of the quote side (1e6 = 100%)
        bool exists;
        // What this pool trades and pays out in. Native ETH is the zero
        // address, as everywhere else in v4. Fixed at registration: a pool's
        // denomination is part of what a holder bought.
        //
        // Last on purpose. Declared after `creator` it would start a third
        // storage slot, and the fee path reads this struct on every swap, so
        // the launchpad would pay an extra SLOAD per trade forever. Two slots.
        Currency quote;
    }

    error NotFactory();
    error UnknownPool();
    error NotCreator();
    /// @dev The pool holds a balance and the amount asked for is not part of it.
    error AmountNotOwed(uint256 requested, uint256 owed);
    error AlreadyRegistered();
    error InvalidPoolKey();
    error InvalidFeeConfig();
    error ZeroAddress();
    error EthTransferFailed();
    error LiquidityLocked();
    error LiquidityAlreadySeeded();
    error DonationsLocked();
    error PartialFillRejected();
    error EmptyFillRejected();
    /// @dev `collectPlatform` pushes, and only ether is ever pushed. A
    ///      non-native balance leaves through `deliverPlatform` instead.
    error NotNativeCurrency(Currency currency);
    error InvalidSink();
    /// @dev A payout to this contract clears the ledger entry without moving
    ///      the balance, leaving the amount owed to nobody and reachable by
    ///      nothing.
    error SelfPayment();
    /// @dev Only a currency's registered sink may pull its booked balance.
    error NotTheSink();
    error InsufficientPlatformBalance();
    /// @dev A quote asset delivered nothing at all against a redemption. A
    ///      short delivery is divided as it arrives; an empty one has nothing to
    ///      divide, and clearing the pending balance against it would give the
    ///      fees away.
    error InexactTransfer(uint256 expected, uint256 received);

    event PoolRegistered(PoolId indexed poolId, address indexed creator, PoolConfig config);
    /// @notice The exact fee taken by a single swap, in the pool's own quote —
    ///         indexers mirror fees from this rather than inferring them from
    ///         swap amounts. Which asset that is comes from the pool's config,
    ///         not from this event; a pool's denomination is fixed at
    ///         registration and never changes.
    event FeeAccrued(PoolId indexed poolId, uint256 amount);
    event FeesSwept(PoolId indexed poolId, address indexed caller, uint256 creatorAmount, uint256 platformAmount);
    /// @notice A creator's unclaimed balance was paid out. `recipient` is where
    ///         it went, which the claimer chooses and which need not be the
    ///         stamped creator — the parameter was called `creator` while that
    ///         was the only place it could go. Renaming it leaves the event
    ///         signature untouched, since parameter names are not part of it.
    event CreatorFeesClaimed(PoolId indexed poolId, address indexed recipient, uint256 amount);
    event CreatorUpdated(PoolId indexed poolId, address indexed oldCreator, address indexed newCreator);
    event TreasuryUpdated(address indexed oldTreasury, address indexed newTreasury);
    event SinkUpdated(Currency indexed currency, address indexed oldSink, address indexed newSink);
    event PlatformPayoutDeferred(Currency indexed currency, uint256 amount);
    event PlatformPayoutCollected(Currency indexed currency, address indexed treasury, uint256 amount);
    /// @notice A booked balance was moved out by its sink, straight to wherever
    ///         the sale settles.
    event PlatformDelivered(
        Currency indexed currency, address indexed sink, address indexed to, uint256 amount
    );

    uint256 public constant BPS_DENOMINATOR = 10_000;
    uint256 public constant FEE_DENOMINATOR = 1e6;
    /// @dev Hard ceiling on any fee rate: 10%, the figure the product actually
    ///      advertises.
    ///
    ///      Enforced here rather than only in the factory. The factory is
    ///      upgradeable and this contract is not, so this is the number that is
    ///      actually a ceiling: no factory implementation, present or future,
    ///      can register a pool above it.
    uint256 public constant MAX_FEE_RATE = 100_000;

    /// @notice The only address allowed to register pools and add liquidity.
    address public immutable factory;
    /// @notice Receives the platform share of native-quoted pools. The live one
    ///         is the ETH-only revenue splitter. Owner-settable.
    address public treasury;
    /// @notice Where the platform share of a non-native pool goes, per currency.
    ///
    /// @dev    A sink rather than a conversion done here. Swapping inside a
    ///         sweep would make every trade in one pool depend on the depth of
    ///         another, and a thin moment there would revert the trade. The
    ///         balance books here instead, and the sink moves it later with
    ///         `deliverPlatform` — which pays a destination directly, so the
    ///         sink never holds it and a freeze on the sink strands nothing.
    ///
    ///         Per currency, not one global sink. A single sink address would
    ///         have to be a contract that accepts every quote asset the
    ///         launchpad ever lists, which is a promise about contracts that do
    ///         not exist yet.
    ///
    ///         Unset, the fee parks in `platformTab` and waits. The previous
    ///         default was to pay the treasury instead, on the reasoning that
    ///         money arriving in the wrong denomination beats money parked
    ///         waiting for a contract nobody deployed. That reasoning was fine
    ///         when the treasury was an ordinary address. It is not fine now:
    ///         the treasury is the ETH-only splitter, which accounts in ether
    ///         and has no ERC-20 recovery path, so the transfer *succeeds* and
    ///         the tokens are gone. Not stuck pending a fix — gone, with the
    ///         sweep having recorded it as a payout. Parking is recoverable and
    ///         a wrong-denomination push is not, so parking wins.
    mapping(Currency => address) public sinkFor;

    mapping(PoolId => PoolConfig) public poolConfigs;
    /// @notice True once a pool has received its single seed liquidity add.
    ///         Every later add reverts — even from the factory, even after a
    ///         factory upgrade — so a launched pool's depth is frozen for good.
    mapping(PoolId => bool) public seeded;
    /// @notice Fees collected but not yet swept, per pool, in the pool's own
    ///         quote and held as claims against the pool manager.
    mapping(PoolId => uint256) public pending;
    /// @notice The creator lane's swept-but-unclaimed balance, per pool, in
    ///         the pool's own quote.
    mapping(PoolId => uint256) public tab;
    /// @notice Platform fees held here rather than pushed: every non-native fee,
    ///         plus any native fee the treasury refused. Moved out by
    ///         `collectPlatform`, which anyone may call.
    ///
    /// @dev    Per currency, and that is load-bearing rather than tidy. A single
    ///         total would count parked USDG as ETH, and `collectPlatform` would
    ///         then try to pay a stablecoin balance out in ether: the ETH would
    ///         be overpaid or the call would revert, and the stablecoin would be
    ///         reachable by nobody.
    mapping(Currency => uint256) public platformTab;

    constructor(IPoolManager poolManager_, address factory_, address treasury_, address owner_)
        BaseHook(poolManager_)
        Ownable(owner_)
    {
        if (factory_ == address(0) || treasury_ == address(0)) revert ZeroAddress();
        // The one path `setTreasury` cannot cover. This address is CREATE2
        // mined and therefore known before deployment, so a hook constructed
        // pointing at itself would book every native platform share as
        // collected while nothing left — and `_tryPayNative` swallows the
        // failure by design, so it would never announce itself.
        if (treasury_ == address(this)) revert SelfPayment();
        factory = factory_;
        treasury = treasury_;
    }

    function getHookPermissions() public pure override returns (Hooks.Permissions memory) {
        return Hooks.Permissions({
            beforeInitialize: true,
            afterInitialize: false,
            beforeAddLiquidity: true,
            afterAddLiquidity: false,
            beforeRemoveLiquidity: true,
            afterRemoveLiquidity: false,
            beforeSwap: true,
            afterSwap: true,
            beforeDonate: true,
            afterDonate: false,
            beforeSwapReturnDelta: true,
            afterSwapReturnDelta: true,
            afterAddLiquidityReturnDelta: false,
            afterRemoveLiquidityReturnDelta: false
        });
    }

    // —————————————————————————— registration ——————————————————————————

    /// @notice Called by the factory before pool initialization.
    function register(PoolId poolId, address creator, Currency quote, uint16 creatorFeeBps, uint24 feeRate)
        external
    {
        if (msg.sender != factory) revert NotFactory();
        if (poolConfigs[poolId].exists) revert AlreadyRegistered();
        if (creator == address(0)) revert ZeroAddress();
        if (creatorFeeBps > BPS_DENOMINATOR || feeRate == 0 || feeRate > MAX_FEE_RATE) {
            revert InvalidFeeConfig();
        }
        PoolConfig memory config =
            PoolConfig({creator: creator, creatorFeeBps: creatorFeeBps, feeRate: feeRate, exists: true, quote: quote});
        poolConfigs[poolId] = config;
        emit PoolRegistered(poolId, creator, config);
    }

    /// @notice The pool's fee rate, in pips of the quote side.
    ///
    /// @dev    A pool charges one rate for its whole life. There is no opening
    ///         premium, no decay and no exemption.
    ///
    ///         The signature keeps `swapper` so callers and indexers do not have
    ///         to change, and so a future rate that does depend on who is
    ///         swapping has somewhere to go.
    function currentFeeRate(PoolId poolId, address) public view returns (uint256) {
        PoolConfig memory config = poolConfigs[poolId];
        if (!config.exists) revert UnknownPool();
        return config.feeRate;
    }

    /// @dev The fee owed on an ETH leg of `ethAmount` at `rate`.
    ///
    ///      An exact-input swap names the whole ETH leg — the trader's spend on
    ///      a buy, the pool's payout on a sell — so the fee is a share of it. An
    ///      exact-output swap names only the part the trader keeps, and the fee
    ///      is settled on top of it, so that amount has to be grossed up to the
    ///      leg it implies. Charging the named amount directly in both cases
    ///      would let an exact-output trade pay `1 - rate` of what the same
    ///      trade pays exact-input: a rounding error at 1%, and a tenth of the
    ///      bill forgiven at the highest rate on the menu.
    ///
    ///      `rate` never reaches FEE_DENOMINATOR: `register` caps it at
    ///      MAX_FEE_RATE, so the divisor stays positive.
    function _feeFor(uint256 ethAmount, uint256 rate, bool exactOutput) private pure returns (uint256) {
        return exactOutput
            ? (ethAmount * rate) / (FEE_DENOMINATOR - rate)
            : (ethAmount * rate) / FEE_DENOMINATOR;
    }

    // —————————————————————————— hook callbacks ——————————————————————————

    /// @dev Only the factory may create pools with this hook, only with the
    ///      currency the pool registered under as currency0, and a zero LP fee
    ///      (all fees flow through the hook).
    ///
    ///      The currency check is against the registered config rather than a
    ///      hardcoded zero address. A pool registered as USDG that initialised
    ///      against ETH would take fees in one asset and pay them in another,
    ///      so the two are required to agree here, once, before the pool exists.
    function _beforeInitialize(address sender, PoolKey calldata key, uint160) internal view override returns (bytes4) {
        if (sender != factory) revert NotFactory();
        PoolConfig storage config = poolConfigs[key.toId()];
        if (!config.exists) revert UnknownPool();
        if (Currency.unwrap(key.currency0) != Currency.unwrap(config.quote) || key.fee != 0) {
            revert InvalidPoolKey();
        }
        return this.beforeInitialize.selector;
    }

    /// @dev The factory seeds liquidity exactly once, at launch. The one-shot
    ///      gate is enforced here, not merely by convention: the first add
    ///      marks the pool seeded and every subsequent add reverts — so no
    ///      future factory upgrade can change a launched pool's depth, and
    ///      combined with the removal gate a pool's liquidity is frozen the
    ///      moment it launches.
    function _beforeAddLiquidity(address sender, PoolKey calldata key, ModifyLiquidityParams calldata, bytes calldata)
        internal
        override
        returns (bytes4)
    {
        if (sender != factory) revert NotFactory();
        PoolId poolId = key.toId();
        if (seeded[poolId]) revert LiquidityAlreadySeeded();
        seeded[poolId] = true;
        return this.beforeAddLiquidity.selector;
    }

    /// @dev Liquidity in CashCat pools is locked at the pool level: every
    ///      removal reverts, no matter who owns the position — including the
    ///      factory, and including any future upgrade of it. This hook is not
    ///      upgradeable, so the lock is absolute.
    function _beforeRemoveLiquidity(address, PoolKey calldata, ModifyLiquidityParams calldata, bytes calldata)
        internal
        pure
        override
        returns (bytes4)
    {
        revert LiquidityLocked();
    }

    /// @dev Donations are blocked: the seed position can never be modified, so
    ///      donated value would accrue as fees nobody can ever collect — a
    ///      black hole with a standard entrypoint. All value entering a
    ///      CashCat pool moves through swaps, where the fee engine models it.
    function _beforeDonate(address, PoolKey calldata, uint256, uint256, bytes calldata)
        internal
        pure
        override
        returns (bytes4)
    {
        revert DonationsLocked();
    }

    /// @dev ETH is the specified currency on exact-in buys and exact-out sells:
    ///      the fee is known pre-swap and skimmed here.
    function _beforeSwap(address sender, PoolKey calldata key, SwapParams calldata params, bytes calldata)
        internal
        override
        returns (bytes4, BeforeSwapDelta, uint24)
    {
        bool ethSpecified = (params.amountSpecified < 0) == params.zeroForOne;
        if (!ethSpecified) return (this.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);

        PoolId poolId = key.toId();
        uint256 amount = uint256(
            params.amountSpecified < 0 ? -params.amountSpecified : params.amountSpecified
        );
        uint256 fee = _feeFor(amount, currentFeeRate(poolId, sender), params.amountSpecified > 0);
        // exactly one FeeAccrued per swap, on the hook that owns its fee side —
        // emitted even when the fee rounds to zero, so an off-chain indexer can
        // map events to swaps one-to-one by order within a transaction
        emit FeeAccrued(poolId, fee);
        if (fee == 0) return (this.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);

        // The claim id must be the pool's own currency, because `_sweep` burns
        // the same id back. Hardcoding native here while burning the real
        // currency there leaves the swap unsettled and the fee unreachable.
        poolManager.mint(address(this), poolConfigs[poolId].quote.toId(), fee);
        pending[poolId] += fee;
        return (this.beforeSwap.selector, toBeforeSwapDelta(int256(fee).toInt128(), 0), 0);
    }

    /// @dev ETH is the unspecified currency on exact-out buys and exact-in
    ///      sells: the fee is taken from the actual ETH moved by the swap.
    function _afterSwap(address sender, PoolKey calldata key, SwapParams calldata params, BalanceDelta delta, bytes calldata)
        internal
        override
        returns (bytes4, int128)
    {
        bool ethSpecified = (params.amountSpecified < 0) == params.zeroForOne;
        if (ethSpecified) {
            // _beforeSwap charged the fee on the full specified ETH amount; a
            // price-limited swap that only partially fills would therefore be
            // taxed on ETH that never traded. Refuse those outright: on a full
            // fill the pool moves exactly the post-fee specified amount, so
            // anything less means the price limit cut the swap short.
            uint256 specified = uint256(
                params.amountSpecified < 0 ? -params.amountSpecified : params.amountSpecified
            );
            uint256 chargedOnSpecified =
                _feeFor(specified, currentFeeRate(key.toId(), sender), params.amountSpecified > 0);
            int128 amt0 = delta.amount0();
            uint256 poolEthMoved = uint256(uint128(amt0 < 0 ? -amt0 : amt0));
            uint256 fullFill =
                params.amountSpecified < 0 ? specified - chargedOnSpecified : specified + chargedOnSpecified;
            if (poolEthMoved != fullFill) revert PartialFillRejected();
            return (this.afterSwap.selector, 0);
        }

        PoolId poolId = key.toId();
        uint256 ethMoved;
        {
            int128 amount0 = delta.amount0();
            ethMoved = uint256(uint128(amount0 < 0 ? -amount0 : amount0));
        }
        // A swap that moved neither side traded against no liquidity, and a pool
        // has none at two prices: exactly on the start tick, where the seed
        // position is not yet active and a pool rests until its first buy, and
        // above it, where the position never reached. A sell aimed upward from
        // there consumes nothing on the way, so it needs no token and no
        // balance, pays no fee, and still leaves the price wherever the caller's
        // limit pointed. Refused, so a pool's quoted price is always one some
        // trade actually paid for.
        //
        // Both sides, not just the quote: a sell too small to be worth any quote
        // at all still moves its own side and is a real, if pointless, trade.
        // Only a swap that moved nothing in either direction is being used
        // purely to write a price.
        //
        // The sibling case, a fill that is short rather than empty, is charged
        // in proportion here and rejected outright on the specified side, where
        // the fee was taken before the swap ran.
        if (ethMoved == 0 && delta.amount1() == 0) revert EmptyFillRejected();
        uint256 fee = _feeFor(ethMoved, currentFeeRate(poolId, sender), params.amountSpecified > 0);
        // one FeeAccrued per swap, even at zero — see _beforeSwap
        emit FeeAccrued(poolId, fee);
        if (fee == 0) return (this.afterSwap.selector, 0);

        poolManager.mint(address(this), poolConfigs[poolId].quote.toId(), fee);
        pending[poolId] += fee;
        return (this.afterSwap.selector, int256(fee).toInt128());
    }

    // —————————————————————————— fee payout ——————————————————————————

    /// @notice Converts a pool's pending fees to ETH: platform share straight
    ///         to the treasury, creator share onto the creator's unclaimed
    ///         balance (paid out via `claim`). Callable by anyone.
    function sweep(PoolId poolId) external nonReentrant returns (uint256 creatorAmount, uint256 platformAmount) {
        return _sweep(poolId);
    }

    /// @notice Pays the creator everything they are owed for a pool: sweeps
    ///         first, then sends their full unclaimed balance as ETH to `to`.
    ///         Only the current fee recipient can call this, and they choose
    ///         where it lands.
    ///
    /// @dev    Naming a destination is what makes the stream recoverable when
    ///         the recipient itself cannot take ETH. `updateCreator` accepts any
    ///         non-zero address, so a stream can be handed to a contract with no
    ///         payable fallback — a token, an NFT, a vault. Paying the recipient
    ///         and only the recipient, that reverts on every attempt, and the
    ///         previous creator cannot undo it because they are no longer the
    ///         creator. Sweeping stays open to anyone meanwhile, so the amount
    ///         nobody can reach grows with every trade.
    ///
    ///         A contract that can make a call can now claim to somewhere that
    ///         can hold the proceeds. One that can do neither was never
    ///         recoverable by any means.
    function claim(PoolId poolId, address to) public nonReentrant returns (uint256 amount) {
        PoolConfig storage config = poolConfigs[poolId];
        if (!config.exists) revert UnknownPool();
        if (msg.sender != config.creator) revert NotCreator();
        if (to == address(0)) revert ZeroAddress();

        _sweep(poolId);

        amount = tab[poolId];
        tab[poolId] = 0;
        _pay(config.quote, to, amount);
        emit CreatorFeesClaimed(poolId, to, amount);
    }

    /// @notice Claims to the caller.
    function claim(PoolId poolId) external returns (uint256 amount) {
        return claim(poolId, msg.sender);
    }

    /// @notice Claims part of what a pool owes, so a creator can take their
    ///         balance in pieces rather than one move.
    ///
    /// @dev    Same reason the splitter has one. A quote that caps the size of
    ///         a single transfer kills an all-or-nothing lane the moment the
    ///         balance passes the cap: the payout attempts one oversized
    ///         transfer, the token refuses, the revert rolls back the write
    ///         that would have reduced it, and the figure is still there next
    ///         time. Naming a destination does not help, because the refusal is
    ///         about the amount rather than the recipient.
    ///
    ///         Nobody has to attack it for that to happen. A pool crosses the
    ///         cap on its own accrual as soon as it earns more than one
    ///         transfer's worth between claims.
    ///
    ///         Sweeps first like the whole-balance claim, so the figure being
    ///         drawn against is current rather than whatever was banked last.
    function claim(PoolId poolId, address to, uint256 amount) public nonReentrant returns (uint256) {
        PoolConfig storage config = poolConfigs[poolId];
        if (!config.exists) revert UnknownPool();
        if (msg.sender != config.creator) revert NotCreator();
        if (to == address(0)) revert ZeroAddress();

        _sweep(poolId);

        uint256 booked = tab[poolId];
        // Distinct from the whole-balance overload, which pays zero without
        // complaint: naming a figure the pool does not hold is a mistake at the
        // call site rather than an empty tab.
        if (amount == 0 || amount > booked) revert AmountNotOwed(amount, booked);

        tab[poolId] = booked - amount;
        _pay(config.quote, to, amount);
        emit CreatorFeesClaimed(poolId, to, amount);
        return amount;
    }

    function _sweep(PoolId poolId) private returns (uint256 creatorAmount, uint256 platformAmount) {
        PoolConfig memory config = poolConfigs[poolId];
        if (!config.exists) revert UnknownPool();

        uint256 amount = pending[poolId];
        if (amount == 0) return (0, 0);
        pending[poolId] = 0;

        // Redeem the claims for the real asset into this contract, and book what
        // arrives rather than what was asked for.
        //
        // The two shares below become liabilities the moment they are booked, so
        // if less arrives than was redeemed the hook owes more than it holds and
        // the first claimant is paid out of another pool's balance. Ether always
        // moves exactly. An approved quote does today, but a quote asset can be
        // upgradeable, and a transfer that later taxes or rebases would be
        // silent here.
        //
        // Measured and divided, not refused. Refusing looks safer and is worse:
        // `claim` sweeps first, so a token that started taxing would lock every
        // creator out of fees already booked, and every pool on that quote would
        // accrue forever with no way to bank it. Splitting what actually arrived
        // keeps the books exact, keeps payouts working, and makes the shortfall
        // land where the fee itself does — shared between the two lanes in the
        // proportion they agreed.
        //
        // That holds while anything arrives. An asset delivering nothing at all
        // is the one case still refused below, and it costs what refusing costs:
        // `claim` sweeps first, so a balance banked before the fault is held up
        // with the sweep. The alternative is worse — the claims are burned by
        // then, so accepting an empty redemption would clear `pending` and give
        // the fees away, where reverting keeps them redeemable if the asset ever
        // delivers again.
        uint256 received = amount;
        if (config.quote.isAddressZero()) {
            poolManager.unlock(abi.encode(config.quote, amount));
        } else {
            IERC20 asset = IERC20(Currency.unwrap(config.quote));
            uint256 heldBefore = asset.balanceOf(address(this));
            poolManager.unlock(abi.encode(config.quote, amount));
            uint256 heldAfter = asset.balanceOf(address(this));
            // An asset that delivered nothing at all has nothing to divide, and
            // dividing zero would clear `pending` for free.
            if (heldAfter <= heldBefore) revert InexactTransfer(amount, 0);
            received = heldAfter - heldBefore;
            if (received > amount) received = amount;
        }

        creatorAmount = (received * config.creatorFeeBps) / BPS_DENOMINATOR;
        platformAmount = received - creatorAmount;
        tab[poolId] += creatorAmount;

        // Native fees push to the treasury, which is what the treasury is for.
        // A failure parks rather than reverting, so a broken treasury can never
        // hold creator payouts hostage.
        //
        // Non-native fees never push from here at all. They are booked to
        // `platformTab` and moved by `collectPlatform`, for two reasons that
        // both bit this contract:
        //
        //   The destination. Falling back to the treasury when no sink was set
        //   sent USDG to the ETH-only revenue splitter, which accounts in ether
        //   and cannot give an ERC-20 back. The transfer succeeded, so nothing
        //   parked and nothing reverted — the money was simply gone, recorded
        //   as paid.
        //
        //   The push itself. Pushing an arbitrary ERC-20 inside a sweep means
        //   decoding whatever that token returns, on a path a creator's claim
        //   runs through. A token returning one byte reverted the decode and
        //   with it the claim; a token that moved the balance and returned
        //   false got the amount credited to `platformTab` as well, payable a
        //   second time out of ether backing creator balances. Neither is
        //   reachable if the sweep does not make the call.
        if (platformAmount > 0) {
            if (config.quote.isAddressZero() && _tryPayNative(treasury, platformAmount)) {
                emit PlatformPayoutCollected(config.quote, treasury, platformAmount);
            } else {
                platformTab[config.quote] += platformAmount;
                emit PlatformPayoutDeferred(config.quote, platformAmount);
            }
        }
        emit FeesSwept(poolId, msg.sender, creatorAmount, platformAmount);
    }

    function unlockCallback(bytes calldata data) external returns (bytes memory) {
        if (msg.sender != address(poolManager)) revert NotPoolManager();
        (Currency currency, uint256 amount) = abi.decode(data, (Currency, uint256));
        poolManager.burn(address(this), currency.toId(), amount);
        poolManager.take(currency, address(this), amount);
        return "";
    }

    // —————————————————————————— stream management ——————————————————————————

    /// @notice Lets a creator hand their fee stream to a new address (e.g. a
    ///         multisig). The unclaimed balance travels with the stream.
    ///
    /// @dev    One-way, and only the new address can hand it on again. Nothing
    ///         here checks that the address can do anything with the stream —
    ///         only that it is not zero — because nothing on chain can tell a
    ///         multisig from a contract that will never call this hook, and
    ///         refusing contracts would refuse the case this exists for.
    ///
    ///         A recipient that cannot receive ETH can still claim to an address
    ///         that can. One that can neither receive ETH nor make a call keeps
    ///         the stream and can never spend it.
    function updateCreator(PoolId poolId, address newCreator) external {
        PoolConfig storage config = poolConfigs[poolId];
        if (!config.exists) revert UnknownPool();
        if (msg.sender != config.creator) revert NotCreator();
        if (newCreator == address(0)) revert ZeroAddress();
        emit CreatorUpdated(poolId, config.creator, newCreator);
        config.creator = newCreator;
    }

    /// @notice Sends the booked native platform balance to the treasury.
    ///         Callable by anyone.
    ///
    /// @dev    Native only. A non-native balance is never pushed anywhere: its
    ///         sink pulls it with `deliverPlatform`, which hands it straight to
    ///         wherever the sale settles. Pushing it to the sink first would let
    ///         it be frozen there, and repointing the sink afterwards would only
    ///         protect fees that had not arrived yet.
    function collectPlatform(Currency currency) external nonReentrant returns (uint256 amount) {
        if (!currency.isAddressZero()) revert NotNativeCurrency(currency);
        amount = platformTab[currency];
        if (amount == 0) return 0;

        platformTab[currency] = 0;
        _pay(currency, treasury, amount);
        emit PlatformPayoutCollected(currency, treasury, amount);
    }

    /// @notice Hands a booked non-native balance straight to wherever its sink
    ///         is settling a sale, at that sink's request.
    ///
    /// @dev    The sink arranges the sale and this pays for it, so the asset
    ///         moves from here to the counterparty in one transaction and never
    ///         rests at the sink. Today that counterparty is a Uniswap pool
    ///         being swapped against; the hook does not care which.
    ///
    ///         That matters for a regulated stablecoin. A balance sitting in the
    ///         sink can be frozen there, and repointing `sinkFor` afterwards only
    ///         protects fees that have not arrived yet — whatever accumulated is
    ///         gone. Nothing accumulates now, so changing the sink is a complete
    ///         remedy rather than a partial one.
    ///
    ///         This contract can still be frozen itself, and that is irreducible:
    ///         an issuer can always refuse the address holding the money.
    function deliverPlatform(Currency currency, uint256 amount, address to)
        external
        nonReentrant
        returns (uint256 delivered)
    {
        if (currency.isAddressZero()) revert InvalidSink();
        if (msg.sender != sinkFor[currency]) revert NotTheSink();
        if (to == address(0)) revert ZeroAddress();

        uint256 booked = platformTab[currency];
        if (amount == 0 || amount > booked) revert InsufficientPlatformBalance();
        platformTab[currency] = booked - amount;

        _pay(currency, to, amount);
        delivered = amount;
        emit PlatformDelivered(currency, msg.sender, to, amount);
    }

    /// @notice Where a collected platform fee of `currency` would be sent, or
    ///         zero if it cannot be collected yet.
    function platformDestination(Currency currency) external view returns (address) {
        if (currency.isAddressZero()) return treasury;
        return sinkFor[currency];
    }

    /// @notice Sets where the platform share of a non-native pool goes.
    ///
    /// @dev    The native slot is not settable here: ether has a treasury, and
    ///         accepting a sink for it would create two answers to the same
    ///         question. Clearing a sink back to zero is allowed — it parks
    ///         subsequent fees rather than stranding them.
    function setSink(Currency currency, address newSink) external onlyOwner {
        if (currency.isAddressZero()) revert InvalidSink();
        if (newSink != address(0) && newSink.code.length == 0) revert InvalidSink();
        emit SinkUpdated(currency, sinkFor[currency], newSink);
        sinkFor[currency] = newSink;
    }

    /// @notice Redirects the platform's share only; creator balances are unaffected.
    function setTreasury(address newTreasury) external onlyOwner {
        if (newTreasury == address(0)) revert ZeroAddress();
        // The native sweep pushes to the treasury through `_tryPayNative`,
        // which swallows a failure by design so a broken treasury cannot hold
        // creator payouts hostage. A treasury set to this contract does not
        // fail — the transfer succeeds against itself — so every platform
        // share would be booked as collected while never leaving. Refused here
        // rather than there, because there it must not revert.
        if (newTreasury == address(this)) revert SelfPayment();
        emit TreasuryUpdated(treasury, newTreasury);
        treasury = newTreasury;
    }

    /// @dev One balance per currency stands behind every pool's creator tab
    ///      and the platform's own book. A transfer debiting more than the
    ///      amount it settles takes the difference from another of those, so
    ///      the debit is required to be exact. Callers zero their tab before
    ///      paying, so the check runs after that and unwinds both together
    ///      when it fails.
    ///
    ///      What a caller reports is the amount settled, not what the payee
    ///      received. Those differ only for an asset taxing the recipient, and
    ///      the settled amount is what left this contract and what its books
    ///      were reduced by.
    function _pay(Currency currency, address to, uint256 amount) private {
        if (amount == 0) return;
        // Paying this contract is not a payment. The ledger entry is cleared
        // and the balance does not move, so the amount stops being owed to
        // anyone while still sitting here — and nothing here can send it out
        // again, because every exit is keyed to a ledger that no longer names
        // it. Refused on both branches: the ERC-20 path would be caught by
        // `payExact`, the native path had nothing checking it.
        if (to == address(this)) revert SelfPayment();
        if (currency.isAddressZero()) {
            (bool ok,) = to.call{value: amount}("");
            if (!ok) revert EthTransferFailed();
        } else {
            ExactTransfer.payExact(IERC20(Currency.unwrap(currency)), to, amount);
        }
    }

    /// @dev The native treasury push, which must not be allowed to revert the
    ///      sweep it sits inside.
    ///
    ///      Native only. Handling every shape of ERC-20 return data in a
    ///      context that must not revert would mean re-implementing SafeERC20
    ///      badly, on a path a creator's claim runs through. Non-native balances
    ///      are booked instead and moved by `deliverPlatform`, which uses
    ///      SafeERC20 and is allowed to revert.
    function _tryPayNative(address to, uint256 amount) private returns (bool) {
        (bool ok,) = to.call{value: amount}("");
        return ok;
    }

    receive() external payable {}
}
