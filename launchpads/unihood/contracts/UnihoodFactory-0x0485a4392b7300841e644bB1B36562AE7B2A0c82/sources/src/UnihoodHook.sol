// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {IUnlockCallback} from "@uniswap/v4-core/src/interfaces/callback/IUnlockCallback.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {FullMath} from "@uniswap/v4-core/src/libraries/FullMath.sol";
import {SafeCast} from "@uniswap/v4-core/src/libraries/SafeCast.sol";
import {StateLibrary} from "@uniswap/v4-core/src/libraries/StateLibrary.sol";
import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {BalanceDelta} from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {
    BeforeSwapDelta, BeforeSwapDeltaLibrary, toBeforeSwapDelta
} from "@uniswap/v4-core/src/types/BeforeSwapDelta.sol";
import {LiquidityAmounts} from "@uniswap/v4-periphery/src/libraries/LiquidityAmounts.sol";

import {BaseHook} from "./base/BaseHook.sol";

/// @title UnihoodHook
/// @notice One global hook for every UNIHOOD pool on Robinhood Chain. The pool's LP fee is 0;
///         this hook charges the full swap fee on the native-ETH side and routes it into three
///         buckets: creator, bid wall, platform. During the anti-snipe window the total fee decays
///         15% -> 5% -> 1%; everything above the 1% base goes to the bid wall ("snipers build the
///         floor"). External LP is blocked until graduation. The hook is non-upgradeable and has
///         no fee knobs: every number below is immutable at deploy.
/// @dev Fee-charging flow (both RETURNS_DELTA flags) is modeled after EthCreatorFeeHookV3
///      (programmable.family, MIT), adapted for the three-way split, the decay schedule and the
///      self-executing bid wall. Fees accrue as ERC-6909 claims inside the PoolManager and are
///      redeemed through unlock on claim.
contract UnihoodHook is BaseHook, IUnlockCallback {
    using PoolIdLibrary for PoolKey;
    using StateLibrary for IPoolManager;
    using SafeCast for *;

    // ---------------------------------------------------------------- constants

    uint16 public constant BASIS_POINTS = 10_000;
    /// @notice Normal total swap fee: 1% of the native amount, every swap, both directions.
    uint16 public constant BASE_FEE_BPS = 100;
    /// @notice Creator share, in bps of the gross native amount (80% of the 1% base fee).
    uint16 public constant CREATOR_FEE_BPS = 80;
    /// @notice Bid-wall share, in bps of the gross native amount (5% of the 1% base fee).
    uint16 public constant WALL_FEE_BPS = 5;
    /// @notice Platform share, in bps of the gross native amount (15% of the 1% base fee).
    uint16 public constant PLATFORM_FEE_BPS = 15;

    /// @notice Anti-snipe schedule from launch: <5s total fee 15%, <15s total fee 5%, then 1%.
    ///         The whole surcharge above the 1% base accrues to the bid wall.
    uint64 public constant SNIPE_WINDOW_1_SECONDS = 5;
    uint64 public constant SNIPE_WINDOW_2_SECONDS = 15;
    uint16 public constant SNIPE_FEE_1_BPS = 1500;
    uint16 public constant SNIPE_FEE_2_BPS = 500;

    uint24 public constant LP_FEE_PIPS = 0;
    int24 public constant TICK_SPACING = 200;
    /// @notice Bid wall width: one tick spacing (~2% price band) right below spot.
    int24 public constant WALL_WIDTH_TICKS = 200;

    Currency private constant NATIVE = Currency.wrap(address(0));
    uint256 private constant NATIVE_ID = 0;

    // ---------------------------------------------------------------- storage

    struct PoolState {
        address token;
        address creator;
        address feeRecipient;
        uint64 launchTime;
        bool graduated;
        uint128 creatorAccrued;
        uint128 wallBudget;
        uint128 wallLiquidity;
        int24 wallTickLower;
        uint128 wallTokenInventory;
    }

    /// @notice Tick at or below which a pool counts as graduated (set per deploy, e.g. ~$60k mcap; latches once, never reverts).
    int24 public immutable gradTick;
    /// @notice Native claims the wall bucket must reach before the hook (re)builds the wall.
    uint128 public immutable wallThreshold;
    /// @notice Immutable platform treasury; claims the platform bucket and wires the factory.
    address public immutable platformRecipient;

    /// @notice The only address allowed to register pools, initialize them and swap fee-free
    ///         (its only swap is the launch dev-buy). One-shot wired after deploy.
    address public factory;

    mapping(bytes32 poolId => PoolState state) public pools;
    uint256 public platformAccrued;
    uint256 public totalNativeFeesAccrued;

    // ---------------------------------------------------------------- errors / events

    error AlreadyRegistered(bytes32 poolId);
    error FactoryAlreadySet();
    error InvalidPoolShape();
    error LaunchModeLiquidityLocked(bytes32 poolId);
    error NotFactory(address caller);
    error NotFeeRecipient(address caller, address expected);
    error NotPlatformRecipient(address caller);
    error PartialFillUnsupported(uint256 expected, uint256 actual);
    error PoolNotRegistered(bytes32 poolId);
    error Reentrancy();
    error UnauthorizedInitializer(address caller);
    error ZeroAddress();

    event PoolRegistered(bytes32 indexed poolId, address indexed token, address indexed creator);
    event SwapFees(
        bytes32 indexed poolId,
        address indexed sender,
        bool indexed isBuy,
        uint16 appliedFeeBps,
        uint256 grossNativeAmount,
        uint256 creatorFee,
        uint256 wallFee,
        uint256 platformFee
    );
    event Graduated(bytes32 indexed poolId, int24 tick);
    event WallPlaced(bytes32 indexed poolId, int24 tickLower, int24 tickUpper, uint256 nativeAmount, uint128 liquidity);
    event WallTokensCaptured(bytes32 indexed poolId, uint256 tokenAmount);
    event CreatorFeesClaimed(bytes32 indexed poolId, address indexed recipient, uint256 amount);
    event PlatformFeesClaimed(address indexed recipient, uint256 amount);
    event FeeRecipientUpdated(bytes32 indexed poolId, address indexed previousRecipient, address indexed newRecipient);

    modifier nonReentrant() {
        assembly {
            if tload(0) {
                mstore(0x00, 0xab143c06) // Reentrancy()
                revert(0x1c, 0x04)
            }
            tstore(0, 1)
        }
        _;
        assembly {
            tstore(0, 0)
        }
    }

    constructor(IPoolManager poolManager_, address platformRecipient_, int24 gradTick_, uint128 wallThreshold_)
        BaseHook(poolManager_)
    {
        if (platformRecipient_ == address(0)) revert ZeroAddress();
        platformRecipient = platformRecipient_;
        gradTick = gradTick_;
        wallThreshold = wallThreshold_;
    }

    /// @notice One-shot wiring of the factory, callable once by the platform treasury.
    ///         (Not the constructor sender: CREATE2-proxy deploys make msg.sender the proxy.)
    function setFactory(address factory_) external {
        if (msg.sender != platformRecipient || factory_ == address(0)) revert NotFactory(msg.sender);
        if (factory != address(0)) revert FactoryAlreadySet();
        factory = factory_;
    }

    // ---------------------------------------------------------------- registration

    /// @notice Records a launch. Only the factory, once per pool, exact pool shape enforced.
    function registerPool(PoolKey calldata key, address token, address creator)
        external
        returns (bytes32 poolId)
    {
        if (msg.sender != factory) revert NotFactory(msg.sender);
        if (
            Currency.unwrap(key.currency0) != address(0) || Currency.unwrap(key.currency1) != token
                || token == address(0) || address(key.hooks) != address(this) || key.fee != LP_FEE_PIPS
                || key.tickSpacing != TICK_SPACING
        ) revert InvalidPoolShape();

        poolId = PoolId.unwrap(key.toId());
        PoolState storage s = pools[poolId];
        if (s.token != address(0)) revert AlreadyRegistered(poolId);

        s.token = token;
        s.creator = creator;
        s.feeRecipient = creator;
        s.launchTime = uint64(block.timestamp);
        emit PoolRegistered(poolId, token, creator);
    }

    // ---------------------------------------------------------------- hook permissions

    function getHookPermissions() public pure override returns (Hooks.Permissions memory) {
        return Hooks.Permissions({
            beforeInitialize: true,
            afterInitialize: false,
            beforeAddLiquidity: true,
            afterAddLiquidity: false,
            beforeRemoveLiquidity: false,
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

    // ---------------------------------------------------------------- hook callbacks

    function _beforeInitialize(address sender, PoolKey calldata key, uint160) internal view override returns (bytes4) {
        bytes32 poolId = PoolId.unwrap(key.toId());
        if (pools[poolId].token == address(0)) revert PoolNotRegistered(poolId);
        if (sender != factory) revert UnauthorizedInitializer(sender);
        return this.beforeInitialize.selector;
    }

    /// @dev Launch Mode: only the factory (launch position) and the hook itself (bid wall) may add
    ///      liquidity until graduation. Afterwards the market is fully open. Note the pool's LP fee
    ///      is 0, so external LP adds depth but earns no swap fees; that is disclosed, not hidden.
    function _beforeAddLiquidity(
        address sender,
        PoolKey calldata key,
        IPoolManager.ModifyLiquidityParams calldata,
        bytes calldata
    ) internal view override returns (bytes4) {
        bytes32 poolId = PoolId.unwrap(key.toId());
        PoolState storage s = pools[poolId];
        if (s.token == address(0)) revert PoolNotRegistered(poolId);
        if (sender != factory && sender != address(this) && !s.graduated) {
            revert LaunchModeLiquidityLocked(poolId);
        }
        return this.beforeAddLiquidity.selector;
    }

    function _beforeSwap(address sender, PoolKey calldata key, IPoolManager.SwapParams calldata params, bytes calldata)
        internal
        override
        returns (bytes4, BeforeSwapDelta, uint24)
    {
        bytes32 poolId = PoolId.unwrap(key.toId());
        PoolState storage s = pools[poolId];
        if (s.token == address(0)) revert PoolNotRegistered(poolId);

        // The launch dev-buy (factory is the swap sender, same tx as launch) is fee-free.
        if (sender == factory) return (this.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);

        bool nativeIsSpecified = params.zeroForOne == (params.amountSpecified < 0);
        if (!nativeIsSpecified) return (this.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);

        uint256 nativeAmount = _absolute(params.amountSpecified);
        uint256 totalFee =
            _chargeNative(poolId, s, sender, nativeAmount, params.amountSpecified > 0, params.zeroForOne);
        if (totalFee == 0) return (this.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);
        return (this.beforeSwap.selector, toBeforeSwapDelta(totalFee.toInt256().toInt128(), 0), 0);
    }

    function _afterSwap(
        address sender,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        BalanceDelta delta,
        bytes calldata
    ) internal override returns (bytes4, int128) {
        bytes32 poolId = PoolId.unwrap(key.toId());
        PoolState storage s = pools[poolId];
        if (s.token == address(0)) revert PoolNotRegistered(poolId);

        int128 hookDelta = 0;
        bool nativeIsSpecified = params.zeroForOne == (params.amountSpecified < 0);
        uint16 appliedFeeBps = sender == factory ? 0 : _currentFeeBps(s.launchTime);

        if (nativeIsSpecified) {
            // Fee was charged in beforeSwap. A partial fill would break that accounting, so the
            // actual pool-side native amount must equal the requested amount +/- the exact fee.
            uint256 requested = _absolute(params.amountSpecified);
            (uint256 cf, uint256 wf, uint256 pf) = params.amountSpecified > 0
                ? _feesForNet(requested, appliedFeeBps)
                : _feesForGross(requested, appliedFeeBps);
            uint256 expectedTotal = cf + wf + pf;
            uint256 expectedPoolNative =
                params.amountSpecified > 0 ? requested + expectedTotal : requested - expectedTotal;
            uint256 actualPoolNative = _absolute(int256(delta.amount0()));
            if (actualPoolNative != expectedPoolNative) {
                revert PartialFillUnsupported(expectedPoolNative, actualPoolNative);
            }
        } else if (sender != factory) {
            uint256 nativeAmount = _absolute(int256(delta.amount0()));
            uint256 totalFee =
                _chargeNative(poolId, s, sender, nativeAmount, params.amountSpecified > 0, params.zeroForOne);
            if (totalFee != 0) hookDelta = totalFee.toInt256().toInt128();
        }

        (, int24 tick,,) = poolManager.getSlot0(PoolId.wrap(poolId));
        if (!s.graduated && tick <= gradTick) {
            s.graduated = true;
            emit Graduated(poolId, tick);
        }

        if (s.wallBudget >= wallThreshold) _rebuildWall(poolId, key, s, tick);

        return (this.afterSwap.selector, hookDelta);
    }

    // ---------------------------------------------------------------- bid wall

    /// @dev Runs inside the swap's unlock: withdraws the previous wall (recovering unspent ETH and
    ///      capturing any tokens it bought on the way down) and re-places the whole ETH budget as a
    ///      single-sided range one spacing below spot. Captured tokens stay sequestered in the hook
    ///      forever: supply that left the market.
    function _rebuildWall(bytes32 poolId, PoolKey calldata key, PoolState storage s, int24 currentTick) private {
        uint256 budget = s.wallBudget;

        if (s.wallLiquidity != 0) {
            (BalanceDelta removed,) = poolManager.modifyLiquidity(
                key,
                IPoolManager.ModifyLiquidityParams({
                    tickLower: s.wallTickLower,
                    tickUpper: s.wallTickLower + WALL_WIDTH_TICKS,
                    liquidityDelta: -int256(uint256(s.wallLiquidity)),
                    salt: bytes32(0)
                }),
                ""
            );
            s.wallLiquidity = 0;
            if (removed.amount0() > 0) {
                uint256 recoveredNative = uint256(uint128(removed.amount0()));
                poolManager.mint(address(this), NATIVE_ID, recoveredNative);
                budget += recoveredNative;
            }
            if (removed.amount1() > 0) {
                uint256 capturedTokens = uint256(uint128(removed.amount1()));
                poolManager.mint(address(this), key.currency1.toId(), capturedTokens);
                s.wallTokenInventory += capturedTokens.toUint128();
                emit WallTokensCaptured(poolId, capturedTokens);
            }
        }

        int24 tickLower = _floorToSpacing(currentTick) + TICK_SPACING;
        int24 tickUpper = tickLower + WALL_WIDTH_TICKS;
        if (tickUpper > TickMath.maxUsableTick(TICK_SPACING)) {
            s.wallBudget = budget.toUint128();
            return;
        }

        uint128 liquidity = LiquidityAmounts.getLiquidityForAmount0(
            TickMath.getSqrtPriceAtTick(tickLower), TickMath.getSqrtPriceAtTick(tickUpper), budget
        );
        if (liquidity == 0) {
            s.wallBudget = budget.toUint128();
            return;
        }

        (BalanceDelta added,) = poolManager.modifyLiquidity(
            key,
            IPoolManager.ModifyLiquidityParams({
                tickLower: tickLower,
                tickUpper: tickUpper,
                liquidityDelta: int256(uint256(liquidity)),
                salt: bytes32(0)
            }),
            ""
        );
        uint256 spentNative = uint256(uint128(-added.amount0()));
        poolManager.burn(address(this), NATIVE_ID, spentNative);

        s.wallBudget = (budget - spentNative).toUint128();
        s.wallLiquidity = liquidity;
        s.wallTickLower = tickLower;
        emit WallPlaced(poolId, tickLower, tickUpper, spentNative, liquidity);
    }

    // ---------------------------------------------------------------- claims

    /// @notice Pays out everything accrued to the pool's fee recipient (the creator by default).
    function claimCreatorFees(bytes32 poolId) external nonReentrant returns (uint256 amount) {
        PoolState storage s = pools[poolId];
        if (s.token == address(0)) revert PoolNotRegistered(poolId);
        if (msg.sender != s.feeRecipient) revert NotFeeRecipient(msg.sender, s.feeRecipient);

        amount = s.creatorAccrued;
        if (amount == 0) return 0;
        s.creatorAccrued = 0;
        totalNativeFeesAccrued -= amount;
        _redeemNative(msg.sender, amount);
        emit CreatorFeesClaimed(poolId, msg.sender, amount);
    }

    /// @notice Lets the creator (current recipient) redirect future claims to another wallet.
    function setFeeRecipient(bytes32 poolId, address newRecipient) external {
        PoolState storage s = pools[poolId];
        if (s.token == address(0)) revert PoolNotRegistered(poolId);
        if (msg.sender != s.feeRecipient) revert NotFeeRecipient(msg.sender, s.feeRecipient);
        if (newRecipient == address(0)) revert ZeroAddress();
        emit FeeRecipientUpdated(poolId, s.feeRecipient, newRecipient);
        s.feeRecipient = newRecipient;
    }

    function claimPlatformFees(address recipient) external nonReentrant returns (uint256 amount) {
        if (msg.sender != platformRecipient) revert NotPlatformRecipient(msg.sender);
        if (recipient == address(0)) revert ZeroAddress();
        amount = platformAccrued;
        if (amount == 0) return 0;
        platformAccrued = 0;
        totalNativeFeesAccrued -= amount;
        _redeemNative(recipient, amount);
        emit PlatformFeesClaimed(recipient, amount);
    }

    function unlockCallback(bytes calldata data) external onlyPoolManager returns (bytes memory) {
        (address recipient, uint256 amount) = abi.decode(data, (address, uint256));
        poolManager.burn(address(this), NATIVE_ID, amount);
        poolManager.take(NATIVE, recipient, amount);
        return "";
    }

    // ---------------------------------------------------------------- views

    /// @notice Total swap fee in bps that a non-factory swap pays right now.
    function currentFeeBps(bytes32 poolId) external view returns (uint16) {
        PoolState storage s = pools[poolId];
        if (s.token == address(0)) revert PoolNotRegistered(poolId);
        return _currentFeeBps(s.launchTime);
    }

    /// @notice Immutable fee disclosure: total base fee and its three-way split, in bps of gross.
    function feeDisclosure()
        external
        pure
        returns (uint16 baseFeeBps, uint16 creatorFeeBps, uint16 wallFeeBps, uint16 platformFeeBps)
    {
        return (BASE_FEE_BPS, CREATOR_FEE_BPS, WALL_FEE_BPS, PLATFORM_FEE_BPS);
    }

    // ---------------------------------------------------------------- internals

    function _chargeNative(
        bytes32 poolId,
        PoolState storage s,
        address sender,
        uint256 nativeAmount,
        bool amountIsNet,
        bool isBuy
    ) private returns (uint256 totalFee) {
        uint16 appliedFeeBps = _currentFeeBps(s.launchTime);
        (uint256 creatorFee, uint256 wallFee, uint256 platformFee) =
            amountIsNet ? _feesForNet(nativeAmount, appliedFeeBps) : _feesForGross(nativeAmount, appliedFeeBps);
        totalFee = creatorFee + wallFee + platformFee;
        if (totalFee == 0) return 0;

        s.creatorAccrued += creatorFee.toUint128();
        s.wallBudget += wallFee.toUint128();
        platformAccrued += platformFee;
        totalNativeFeesAccrued += totalFee;

        emit SwapFees(
            poolId,
            sender,
            isBuy,
            appliedFeeBps,
            nativeAmount + (amountIsNet ? totalFee : 0),
            creatorFee,
            wallFee,
            platformFee
        );
        poolManager.mint(address(this), NATIVE_ID, totalFee);
    }

    function _redeemNative(address recipient, uint256 amount) private {
        poolManager.unlock(abi.encode(recipient, amount));
    }

    function _currentFeeBps(uint64 launchTime) private view returns (uint16) {
        uint256 elapsed = block.timestamp - launchTime;
        if (elapsed < SNIPE_WINDOW_1_SECONDS) return SNIPE_FEE_1_BPS;
        if (elapsed < SNIPE_WINDOW_2_SECONDS) return SNIPE_FEE_2_BPS;
        return BASE_FEE_BPS;
    }

    /// @dev Splits the fee on a gross native amount. Wall gets its base share plus the whole
    ///      anti-snipe surcharge; creator takes the rounding remainder.
    function _splitFromGross(uint256 gross, uint16 appliedFeeBps)
        private
        pure
        returns (uint256 creatorFee, uint256 wallFee, uint256 platformFee)
    {
        uint256 totalFee = FullMath.mulDiv(gross, appliedFeeBps, BASIS_POINTS);
        platformFee = FullMath.mulDiv(gross, PLATFORM_FEE_BPS, BASIS_POINTS);
        wallFee = FullMath.mulDiv(gross, WALL_FEE_BPS + (appliedFeeBps - BASE_FEE_BPS), BASIS_POINTS);
        if (platformFee > totalFee) platformFee = totalFee;
        if (wallFee > totalFee - platformFee) wallFee = totalFee - platformFee;
        creatorFee = totalFee - platformFee - wallFee;
    }

    function _feesForGross(uint256 grossNativeAmount, uint16 appliedFeeBps)
        private
        pure
        returns (uint256 creatorFee, uint256 wallFee, uint256 platformFee)
    {
        if (appliedFeeBps == 0) return (0, 0, 0);
        return _splitFromGross(grossNativeAmount, appliedFeeBps);
    }

    function _feesForNet(uint256 netNativeAmount, uint16 appliedFeeBps)
        private
        pure
        returns (uint256 creatorFee, uint256 wallFee, uint256 platformFee)
    {
        if (appliedFeeBps == 0) return (0, 0, 0);
        uint256 gross = FullMath.mulDivRoundingUp(netNativeAmount, BASIS_POINTS, BASIS_POINTS - appliedFeeBps);
        uint256 totalFee = gross - netNativeAmount;
        platformFee = FullMath.mulDiv(gross, PLATFORM_FEE_BPS, BASIS_POINTS);
        wallFee = FullMath.mulDiv(gross, WALL_FEE_BPS + (appliedFeeBps - BASE_FEE_BPS), BASIS_POINTS);
        if (platformFee > totalFee) platformFee = totalFee;
        if (wallFee > totalFee - platformFee) wallFee = totalFee - platformFee;
        creatorFee = totalFee - platformFee - wallFee;
    }

    function _floorToSpacing(int24 tick) private pure returns (int24) {
        int24 compressed = tick / TICK_SPACING;
        if (tick < 0 && tick % TICK_SPACING != 0) compressed--;
        return compressed * TICK_SPACING;
    }

    function _absolute(int256 value) private pure returns (uint256) {
        if (value >= 0) return uint256(value);
        return uint256(-(value + 1)) + 1;
    }
}
