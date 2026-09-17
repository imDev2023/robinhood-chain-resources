// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {BaseHook} from "uniswap-hooks/src/base/BaseHook.sol";

import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {IUnlockCallback} from "@uniswap/v4-core/src/interfaces/callback/IUnlockCallback.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {PoolId} from "@uniswap/v4-core/src/types/PoolId.sol";
import {Currency, CurrencyLibrary} from "@uniswap/v4-core/src/types/Currency.sol";
import {BalanceDelta} from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {
    BeforeSwapDelta,
    BeforeSwapDeltaLibrary,
    toBeforeSwapDelta
} from "@uniswap/v4-core/src/types/BeforeSwapDelta.sol";
import {SwapParams, ModifyLiquidityParams} from "@uniswap/v4-core/src/types/PoolOperation.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title LaunchHook
/// @notice The fee engine for every pool this launchpad creates. One deployment
///         serves all pools; per-pool terms live in `poolConfigs`.
///
/// @dev    Three properties drive the whole design:
///
///         1. The fee is ALWAYS taken in the pool's quote asset, never in the
///            launched token. On a buy the quote is the input and the fee comes
///            out in `beforeSwap`; on a sell the quote is the output and it comes
///            out in `afterSwap`. Everything downstream depends on fees arriving
///            in one known currency per pool rather than in long-tail dust.
///
///         2. Nothing is swapped or transferred on the swap path. The fee is
///            minted as an ERC-6909 claim against the PoolManager and settled
///            later in `sweep`. Converting inline would make every trade in one
///            pool depend on the depth of another, so a thin moment somewhere
///            else would revert an unrelated trade.
///
///         3. Liquidity is seeded exactly once, by the factory, and can never be
///            removed: `_beforeRemoveLiquidity` reverts unconditionally, for
///            everyone, forever. There is no admin path around it.
contract LaunchHook is BaseHook, Ownable2Step, ReentrancyGuard, IUnlockCallback {
    using CurrencyLibrary for Currency;
    using SafeERC20 for IERC20;

    // ─────────────────────────────── types ───────────────────────────────

    struct PoolConfig {
        // ── slot 0 ──
        address creator;
        /// @dev Total charged, in pips of the quote side (1e6 = 100%): the
        ///      protocol's fixed share plus the creator's add-on. The creator's
        ///      cut is derived from this at settle time rather than stored as a
        ///      rounded share --- a share held as integer basis points loses up
        ///      to 1bp of the fee on every settle, always against the creator.
        uint24 feeRate;
        bool exists;
        bool quoteIsCurrency0;
        // ── slot 1 ──
        Currency quote;
        uint24 snipeSurgePips;
        uint48 snipeEndBlock;
        uint24 snipeWindow;
    }

    // ─────────────────────────────── errors ───────────────────────────────

    error NotFactory();
    error NotRouter();
    error NotCreator();
    error UnknownPool();
    error AlreadyRegistered();
    error InvalidPoolKey();
    error InvalidFeeConfig();
    error ZeroAddress();
    error LiquidityLocked();
    error LiquidityAlreadySeeded();
    error InexactTransfer(uint256 expected, uint256 received);
    error AmountNotOwed(uint256 requested, uint256 owed);
    error EthTransferFailed();
    error FeeTooLarge();
    error NotSelf();

    /// @dev Enough for a settle against a well-behaved quote -- redemption,
    ///      two balance reads and two SSTOREs -- with generous headroom, and far
    ///      short of what a gas bomb needs to starve the rest of the batch.
    uint256 internal constant SETTLE_GAS_STIPEND = 400_000;

    // ─────────────────────────────── events ───────────────────────────────

    event PoolRegistered(PoolId indexed poolId, address indexed creator, PoolConfig config);
    event FeeAccrued(PoolId indexed poolId, uint256 amount);
    event FeesSettled(PoolId indexed poolId, address indexed caller, uint256 creatorAmount, uint256 platformAmount);
    /// @notice A pool in a batch could not be settled and was stepped over.
    ///         Its fees stay pending and redeemable; nothing is lost.
    event SettleSkipped(PoolId indexed poolId);
    event CreatorFeesClaimed(PoolId indexed poolId, address indexed to, uint256 amount);
    event CreatorUpdated(PoolId indexed poolId, address indexed from, address indexed to);
    event CreatorTransferStarted(PoolId indexed poolId, address indexed from, address indexed to);
    event PlatformCollected(Currency indexed currency, address indexed router, uint256 amount);
    event RouterUpdated(address indexed from, address indexed to);

    // ────────────────────────────── constants ──────────────────────────────

    uint256 public constant BPS = 10_000;
    uint256 public constant PIPS = 1e6;
    /// @notice The launchpad's own fee: 1%, in pips. Fixed for every launch.
    uint24 public constant PROTOCOL_FEE_PIPS = 10_000;
    /// @notice Ceiling on the creator's optional add-on, basis points.
    /// @dev 9%, which with the protocol's fixed 1% is the 10% ceiling below.
    ///      A creator picking the top tier leaves no room for an anti-snipe
    ///      surge, and `register` rejects the combination rather than silently
    ///      clamping -- so the launch form scales the surge to fit.
    uint16 public constant MAX_CREATOR_FEE_BPS = 900;
    /// @notice Hard ceiling on anything this hook will ever charge, surge
    ///         included. Enforced here rather than only in the factory: the
    ///         factory can be replaced, this contract cannot.
    uint256 public constant MAX_FEE_RATE = 100_000; // 10%

    // ─────────────────────────────── state ───────────────────────────────

    address public immutable factory;
    /// @notice The only address allowed to pull platform balances.
    address public feeRouter;

    mapping(PoolId => PoolConfig) public poolConfigs;
    /// @notice True once a pool has taken its single seed add. Every later add
    ///         reverts, factory included, even after a factory upgrade.
    mapping(PoolId => bool) public seeded;
    /// @notice Accrued but unsettled, per pool, in the pool's own quote, held as
    ///         ERC-6909 claims against the PoolManager. Total of both lanes.
    mapping(PoolId => uint256) public pending;
    /// @notice The creator's slice of `pending`, accrued at the BASE rate only.
    ///
    /// @dev    Tracked separately rather than derived at settle because the
    ///         anti-snipe surge makes the two rates diverge per swap. Deriving
    ///         it from one number would hand the creator a proportional cut of
    ///         their own surge -- at a 200bp add-on, two thirds of it -- which
    ///         turns a snipe deterrent into a way to farm the first buyers it
    ///         exists to protect. One extra storage write on the swap path is
    ///         the price of that not being possible.
    mapping(PoolId => uint256) public creatorPending;
    /// @notice Settled but unclaimed creator balance, per pool, in the pool's quote.
    mapping(PoolId => uint256) public creatorTab;
    /// @notice Nominee for a pending creator handover, per pool.
    mapping(PoolId => address) public pendingCreator;
    /// @notice Swept platform balance, per currency. Pulled by the router.
    mapping(Currency => uint256) public platformTab;

    constructor(IPoolManager poolManager_, address factory_, address owner_) BaseHook(poolManager_) Ownable(owner_) {
        if (factory_ == address(0)) revert ZeroAddress();
        factory = factory_;
    }

    receive() external payable {}

    // ───────────────────────────── permissions ─────────────────────────────

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
            beforeDonate: false,
            afterDonate: false,
            beforeSwapReturnDelta: true,
            afterSwapReturnDelta: true,
            afterAddLiquidityReturnDelta: false,
            afterRemoveLiquidityReturnDelta: false
        });
    }

    // ───────────────────────────── registration ─────────────────────────────

    /// @notice Records a pool's terms. Factory-only, once per pool, immutable after.
    function register(
        PoolId poolId,
        address creator,
        Currency quote,
        bool quoteIsCurrency0,
        uint16 creatorFeeBps,
        uint24 snipeSurgePips,
        uint24 snipeWindow
    ) external {
        if (msg.sender != factory) revert NotFactory();
        if (poolConfigs[poolId].exists) revert AlreadyRegistered();
        if (creator == address(0)) revert ZeroAddress();
        if (creatorFeeBps > MAX_CREATOR_FEE_BPS) revert InvalidFeeConfig();
        if (snipeSurgePips != 0 && snipeWindow == 0) revert InvalidFeeConfig();

        // The creator add-on is quoted in bps of the swap; convert to pips and
        // sum with the protocol's fixed 1% to get what the pool actually charges.
        uint256 creatorPips = uint256(creatorFeeBps) * 100;
        uint256 total = uint256(PROTOCOL_FEE_PIPS) + creatorPips;
        if (total + snipeSurgePips > MAX_FEE_RATE) revert InvalidFeeConfig();

        PoolConfig memory cfg = PoolConfig({
            creator: creator,
            feeRate: uint24(total),
            exists: true,
            quoteIsCurrency0: quoteIsCurrency0,
            quote: quote,
            snipeSurgePips: snipeSurgePips,
            snipeEndBlock: uint48(block.number + snipeWindow),
            snipeWindow: snipeWindow
        });
        poolConfigs[poolId] = cfg;
        emit PoolRegistered(poolId, creator, cfg);
    }

    /// @notice The live rate, in pips. This is the selector LaunchToken reads,
    ///         and the one tax scanners reach through it.
    ///
    /// @dev    Typed `bytes32` rather than `PoolId` on purpose: PoolId is a
    ///         user-defined value type over bytes32, so declaring both would be
    ///         an external overload clash.
    /// @notice Who currently owns a pool's fee stream. Read by the launched
    ///         token so that metadata control follows a creator handover rather
    ///         than staying with whoever happened to deploy.
    function creatorOf(bytes32 poolId) external view returns (address) {
        return poolConfigs[PoolId.wrap(poolId)].creator;
    }

    function currentFeeRate(bytes32 poolId, address) external view returns (uint256) {
        PoolConfig memory cfg = poolConfigs[PoolId.wrap(poolId)];
        if (!cfg.exists) revert UnknownPool();
        return _currentRate(cfg);
    }

    /// @dev The surge decays linearly to zero across the anti-snipe window, so
    ///      there is no cliff block for a sniper to sit and wait for.
    function _currentRate(PoolConfig memory cfg) private view returns (uint256 rate) {
        rate = cfg.feeRate;
        uint256 endBlock = cfg.snipeEndBlock;
        if (cfg.snipeSurgePips != 0 && block.number < endBlock) {
            uint256 remaining = endBlock - block.number;
            rate += (uint256(cfg.snipeSurgePips) * remaining) / cfg.snipeWindow;
        }
        if (rate > MAX_FEE_RATE) rate = MAX_FEE_RATE;
    }

    // ──────────────────────────── pool lifecycle ────────────────────────────

    function _beforeInitialize(address sender, PoolKey calldata key, uint160) internal view override returns (bytes4) {
        // Only the factory may open a pool on this hook. Without this, anyone
        // could create an unregistered pool pointing here and every swap in it
        // would revert on UnknownPool: a bricked pool wearing our name.
        if (sender != factory) revert NotFactory();
        if (key.tickSpacing <= 0) revert InvalidPoolKey();
        return BaseHook.beforeInitialize.selector;
    }

    function _beforeAddLiquidity(address sender, PoolKey calldata key, ModifyLiquidityParams calldata, bytes calldata)
        internal
        override
        returns (bytes4)
    {
        if (sender != factory) revert LiquidityLocked();
        PoolId poolId = key.toId();
        if (seeded[poolId]) revert LiquidityAlreadySeeded();
        seeded[poolId] = true;
        return BaseHook.beforeAddLiquidity.selector;
    }

    /// @dev Unconditional. There is no caller, no owner, and no upgrade path
    ///      that can take seeded liquidity back out of one of these pools.
    function _beforeRemoveLiquidity(address, PoolKey calldata, ModifyLiquidityParams calldata, bytes calldata)
        internal
        pure
        override
        returns (bytes4)
    {
        revert LiquidityLocked();
    }

    // ────────────────────────────── the fee path ──────────────────────────────

    function _beforeSwap(address, PoolKey calldata key, SwapParams calldata params, bytes calldata)
        internal
        override
        returns (bytes4, BeforeSwapDelta, uint24)
    {
        PoolId poolId = key.toId();
        PoolConfig memory cfg = poolConfigs[poolId];
        if (!cfg.exists) revert UnknownPool();

        // v4 calls the side the trader pinned down the "specified" currency: the
        // input on an exact-input swap, the output on an exact-output one. Only
        // that side is reachable here; the other one is reachable in afterSwap.
        if (!_feeLandsOnSpecified(params, cfg)) {
            return (BaseHook.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);
        }

        uint256 amount = params.amountSpecified < 0 ? uint256(-params.amountSpecified) : uint256(params.amountSpecified);
        uint256 fee = (amount * _currentRate(cfg)) / PIPS;
        if (fee == 0) return (BaseHook.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);

        _accrue(poolId, cfg, amount, fee);
        return (BaseHook.beforeSwap.selector, toBeforeSwapDelta(_toInt128(fee), 0), 0);
    }

    function _afterSwap(address, PoolKey calldata key, SwapParams calldata params, BalanceDelta delta, bytes calldata)
        internal
        override
        returns (bytes4, int128)
    {
        PoolId poolId = key.toId();
        PoolConfig memory cfg = poolConfigs[poolId];
        if (!cfg.exists) revert UnknownPool();

        // Already taken on the specified side.
        if (_feeLandsOnSpecified(params, cfg)) return (BaseHook.afterSwap.selector, 0);

        int128 unspecified = cfg.quoteIsCurrency0 ? delta.amount0() : delta.amount1();
        uint256 amount = unspecified < 0 ? uint256(-int256(unspecified)) : uint256(int256(unspecified));
        uint256 fee = (amount * _currentRate(cfg)) / PIPS;
        if (fee == 0) return (BaseHook.afterSwap.selector, 0);

        _accrue(poolId, cfg, amount, fee);
        return (BaseHook.afterSwap.selector, _toInt128(fee));
    }

    /// @dev True when the quote is the currency v4 considers "specified" for
    ///      this swap, i.e. when the fee is reachable in beforeSwap.
    function _feeLandsOnSpecified(SwapParams calldata params, PoolConfig memory cfg) private pure returns (bool) {
        bool specifiedIsCurrency0 = (params.amountSpecified < 0) == params.zeroForOne;
        return specifiedIsCurrency0 == cfg.quoteIsCurrency0;
    }

    /// @dev Booked as an ERC-6909 claim rather than pulled out as a real token.
    ///      Costs a mint instead of a transfer, and leaves the asset inside the
    ///      PoolManager where the next swap can still use it.
    /// @param amount   the swap amount the fee was charged on
    /// @param cfg      the pool's terms, for the base creator rate
    function _accrue(PoolId poolId, PoolConfig memory cfg, uint256 amount, uint256 fee) private {
        pending[poolId] += fee;
        // The creator earns on the base rate they agreed, never on the surge.
        uint256 creatorPips = cfg.feeRate - PROTOCOL_FEE_PIPS;
        if (creatorPips != 0) creatorPending[poolId] += (amount * creatorPips) / PIPS;
        poolManager.mint(address(this), cfg.quote.toId(), fee);
        emit FeeAccrued(poolId, fee);
    }

    // ────────────────────────────── settlement ──────────────────────────────

    /// @notice Turn a pool's accrued claims into booked balances in the two fee
    ///         lanes. Permissionless; moves nothing out of this contract.
    ///
    /// @dev    Named `settle` rather than `sweep` on purpose. `FeeRouter.sweep`
    ///         SELLS fees and pays them out; this one only files them. Two
    ///         functions with one name would be read as two halves of the same
    ///         thing, and they are not.
    function settle(PoolId poolId) external nonReentrant returns (uint256 creatorAmount, uint256 platformAmount) {
        return _settle(poolId);
    }

    /// @notice Settle many pools in one transaction.
    ///
    /// @dev    The keeper's job is O(pools), not O(quote assets): `platformTab`
    ///         is written only by `_settle`, and `_settle` is per-pool, so
    ///         without this the crank would need one transaction per pool and
    ///         the revenue pipeline would not run at any real scale. The hook
    ///         cannot be upgraded, so this has to exist before deploy.
    ///
    ///         Pools with nothing pending cost one SLOAD and are skipped, so a
    ///         caller can pass a stale list without wasting a transaction.
    function settleMany(PoolId[] calldata poolIds)
        external
        nonReentrant
        returns (uint256 totalCreator, uint256 totalPlatform)
    {
        for (uint256 i = 0; i < poolIds.length; ++i) {
            if (pending[poolIds[i]] == 0) continue;
            // Each pool is settled in its own call frame so one that cannot be
            // settled cannot stop the rest. It matters because launching is
            // permissionless and any address with code is a launchable quote:
            // without this, anyone could add a pool to the keeper's batch whose
            // quote asset they control, freeze it, and hold every other pool's
            // fees unbooked until an operator worked out which one to exclude.
            //
            // Failure is stepped over, not swallowed: the pool keeps its
            // `pending`, so the fees stay redeemable if the asset ever behaves,
            // and SettleSkipped says which pool needs looking at.
            // A stipend, not all remaining gas. `try` catches a revert but not
            // consumption: a quote asset that BURNS gas instead of reverting
            // takes 63/64 of whatever it is given and leaves the loop unable to
            // finish, which is the same denial the isolation exists to prevent.
            // Bounding the stipend bounds the damage to one pool's slot.
            try this.settleSelf{gas: SETTLE_GAS_STIPEND}(poolIds[i]) returns (uint256 c, uint256 p) {
                totalCreator += c;
                totalPlatform += p;
            } catch {
                emit SettleSkipped(poolIds[i]);
            }
        }
    }

    /// @notice One pool, in its own call frame, for `settleMany` to isolate.
    /// @dev    Not an entry point. `settle` is the external single-pool call;
    ///         this exists only because a revert cannot be caught within one
    ///         frame, and it is deliberately not `nonReentrant` because the
    ///         guard is already held by the `settleMany` that called it.
    function settleSelf(PoolId poolId) external returns (uint256 creatorAmount, uint256 platformAmount) {
        if (msg.sender != address(this)) revert NotSelf();
        return _settle(poolId);
    }

    function _settle(PoolId poolId) private returns (uint256 creatorAmount, uint256 platformAmount) {
        PoolConfig memory cfg = poolConfigs[poolId];
        if (!cfg.exists) revert UnknownPool();

        uint256 amount = pending[poolId];
        if (amount == 0) return (0, 0);
        uint256 creatorAccrued = creatorPending[poolId];
        pending[poolId] = 0;
        creatorPending[poolId] = 0;

        // Book what actually arrived, not what was asked for. A quote asset can
        // be upgradeable, and one that grows a transfer tax later would silently
        // deliver less than was redeemed, at which point the two shares below are
        // liabilities larger than the balance backing them and the first claimant
        // is paid out of another pool's money. Splitting what landed keeps the
        // books exact and puts the shortfall where the fee is, shared between
        // both lanes in the proportion they agreed to.
        uint256 received = amount;
        if (cfg.quote.isAddressZero()) {
            poolManager.unlock(abi.encode(cfg.quote, amount));
        } else {
            IERC20 asset = IERC20(Currency.unwrap(cfg.quote));
            uint256 heldBefore = asset.balanceOf(address(this));
            poolManager.unlock(abi.encode(cfg.quote, amount));
            uint256 heldAfter = asset.balanceOf(address(this));
            // Nothing at all is the one case still refused: the claims are burned
            // by now, so accepting an empty redemption would clear `pending` and
            // give the fees away. Reverting keeps them redeemable if the asset
            // ever delivers again.
            if (heldAfter <= heldBefore) revert InexactTransfer(amount, 0);
            received = heldAfter - heldBefore;
            if (received > amount) received = amount;
        }

        // The creator's lane was accrued at the base rate as the fees came in,
        // so the surge is already excluded. Scale by what actually arrived so a
        // quote asset that under-delivers shorts both lanes in proportion
        // rather than paying the first claimant out of another pool's balance.
        creatorAmount = creatorAccrued == 0 ? 0 : (creatorAccrued * received) / amount;
        if (creatorAmount > received) creatorAmount = received;
        platformAmount = received - creatorAmount;
        creatorTab[poolId] += creatorAmount;
        // Booked, never pushed. Pushing an arbitrary ERC-20 from here would mean
        // decoding whatever it returns on a path a creator's claim runs through.
        platformTab[cfg.quote] += platformAmount;

        emit FeesSettled(poolId, msg.sender, creatorAmount, platformAmount);
    }

    function unlockCallback(bytes calldata data) external returns (bytes memory) {
        if (msg.sender != address(poolManager)) revert NotPoolManager();
        (Currency currency, uint256 amount) = abi.decode(data, (Currency, uint256));
        poolManager.burn(address(this), currency.toId(), amount);
        poolManager.take(currency, address(this), amount);
        return "";
    }

    // ──────────────────────────── creator stream ────────────────────────────

    function claim(PoolId poolId, address to) external nonReentrant returns (uint256 amount) {
        PoolConfig memory cfg = poolConfigs[poolId];
        if (!cfg.exists) revert UnknownPool();
        if (msg.sender != cfg.creator) revert NotCreator();
        if (to == address(0)) revert ZeroAddress();

        // Settle if we can, pay regardless.
        //
        // Booking new fees and paying out already-booked ones are separate
        // things, and tying them together handed the creator's money to the
        // quote asset's good behaviour. `_settle` is all-or-nothing: it reverts
        // if the redemption delivers nothing, and propagates any revert from the
        // quote's own transfer. A quote that blocks INBOUND transfers while
        // outbound still works -- a per-transfer cap, a max-wallet rule, a
        // blacklist added later -- therefore made a fully-backed, already-
        // settled creator balance permanently unreachable. `collectPlatform`
        // never settled first; this now matches it.
        try this.settleSelf(poolId) returns (uint256, uint256) {}
        catch {
            emit SettleSkipped(poolId);
        }
        amount = creatorTab[poolId];
        if (amount == 0) return 0;
        creatorTab[poolId] = 0;
        _pay(cfg.quote, to, amount);
        emit CreatorFeesClaimed(poolId, to, amount);
    }

    /// @notice Begin handing the fee stream to another address.
    ///
    /// @dev    Two steps, for the same reason ownership is: a single call means
    ///         one mistyped address permanently redirects every future fee this
    ///         pool earns, with nobody able to undo it. The nominee has to
    ///         prove it can transact before anything moves.
    function transferCreator(PoolId poolId, address newCreator) external {
        PoolConfig memory cfg = poolConfigs[poolId];
        if (!cfg.exists) revert UnknownPool();
        if (msg.sender != cfg.creator) revert NotCreator();
        pendingCreator[poolId] = newCreator;
        emit CreatorTransferStarted(poolId, cfg.creator, newCreator);
    }

    /// @notice Accept a pending handover. The unclaimed balance travels with it.
    function acceptCreator(PoolId poolId) external {
        address nominee = pendingCreator[poolId];
        if (nominee == address(0) || msg.sender != nominee) revert NotCreator();
        PoolConfig storage cfg = poolConfigs[poolId];
        emit CreatorUpdated(poolId, cfg.creator, nominee);
        cfg.creator = nominee;
        delete pendingCreator[poolId];
    }

    /// @notice Abandon a pending handover, e.g. after a mistyped nominee.
    function cancelCreatorTransfer(PoolId poolId) external {
        if (msg.sender != poolConfigs[poolId].creator) revert NotCreator();
        delete pendingCreator[poolId];
        emit CreatorTransferStarted(poolId, msg.sender, address(0));
    }

    // ──────────────────────────── platform stream ────────────────────────────

    /// @notice Pulled by the router, never pushed from here.
    function collectPlatform(Currency currency, uint256 amount) external nonReentrant returns (uint256) {
        if (msg.sender != feeRouter) revert NotRouter();
        uint256 owed = platformTab[currency];
        if (amount > owed) revert AmountNotOwed(amount, owed);
        platformTab[currency] = owed - amount;
        _pay(currency, feeRouter, amount);
        emit PlatformCollected(currency, feeRouter, amount);
        return amount;
    }

    function setFeeRouter(address newRouter) external onlyOwner {
        if (newRouter == address(0)) revert ZeroAddress();
        emit RouterUpdated(feeRouter, newRouter);
        feeRouter = newRouter;
    }

    // ───────────────────────────────── util ─────────────────────────────────

    function _pay(Currency currency, address to, uint256 amount) private {
        if (amount == 0) return;
        if (currency.isAddressZero()) {
            (bool ok,) = to.call{value: amount}("");
            if (!ok) revert EthTransferFailed();
        } else {
            IERC20(Currency.unwrap(currency)).safeTransfer(to, amount);
        }
    }

    function _toInt128(uint256 x) private pure returns (int128) {
        if (x > uint256(uint128(type(int128).max))) revert FeeTooLarge();
        return int128(uint128(x));
    }
}
