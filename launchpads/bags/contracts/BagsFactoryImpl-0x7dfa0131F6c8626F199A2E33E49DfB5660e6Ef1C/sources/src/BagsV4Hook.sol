// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.26;

// OpenZeppelin
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";

// Uniswap v4 Core
import {BalanceDelta, BalanceDeltaLibrary} from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary, toBeforeSwapDelta} from "@uniswap/v4-core/src/types/BeforeSwapDelta.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {LPFeeLibrary} from "@uniswap/v4-core/src/libraries/LPFeeLibrary.sol";
import {PoolId} from "@uniswap/v4-core/src/types/PoolId.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {ModifyLiquidityParams, SwapParams} from "@uniswap/v4-core/src/types/PoolOperation.sol";

// OpenZeppelin Uniswap Hooks
import {BaseHook} from "@openzeppelin/uniswap-hooks/src/base/BaseHook.sol";

// Local interfaces
import {IBagsV4Hook} from "src/interfaces/IBagsV4Hook.sol";
import {IWETH} from "src/interfaces/IWETH.sol";

/// @title BagsV4Hook
/// @notice Shared Uniswap v4 hook for all Bags pools: full-range only, liquidity locked forever,
///         LP fee overridden to 0, and a 2% hook fee on the WETH leg of every swap with per-pool accounting.
/// @dev Deployed once per chain via CREATE2 with a mined salt so that
///      `uint160(address(this)) & 0x3FFF == 0x2ECC` (matches {getHookPermissions}).
///      Pools are registered by the factory; unregistered pools cannot be initialized against this hook
///      because their `bondingCurve` is the zero address.
/// @author Bags
contract BagsV4Hook is BaseHook, Ownable, IBagsV4Hook {
    using SafeERC20 for IERC20;

    /// @dev Hook fee in basis points charged on the WETH leg of each swap (2%)
    uint256 internal constant CUSTOM_LP_FEE = 200; // 2% (base 10_000)
    /// @dev Basis points denominator for fee calculation (10_000 = 100%)
    uint256 internal constant CUSTOM_LP_FEE_BASE = 10_000; // 100%

    /// @dev Enforced tick spacing for full range pools
    int24 internal constant TICK_SPACING = 60;
    /// @dev Min tick for full range with tick spacing of 60
    int24 internal constant MIN_TICK = -887220;
    /// @dev Max tick for full range with tick spacing of 60
    int24 internal constant MAX_TICK = -MIN_TICK;

    /// @notice WETH token address used to determine the fee currency (same for all pools on a chain)
    address public immutable WETH;
    /// @notice Bags platform vault (receives the protocol half of swept fees, minus any partner cut, as native)
    address public immutable VAULT;

    /// @notice Factory authorized to register pools (owner-mutable so a factory redeploy
    ///         never forces re-mining the hook address)
    address public factory;

    /// @notice Per-pool configuration and fee accounting
    mapping(PoolId => PoolConfig) public pools;

    /// @notice Deploys the shared hook with chain infrastructure addresses
    /// @dev The BaseHook constructor validates that the deployed address encodes {getHookPermissions}
    ///      (mask 0x2ECC); the deploy script must CREATE2-mine a matching salt.
    /// @param _poolManager Uniswap v4 PoolManager
    /// @param weth WETH address for the target chain
    /// @param vault_ Bags platform vault address
    /// @param initialOwner Owner allowed to set the factory
    constructor(
        IPoolManager _poolManager,
        address weth,
        address vault_,
        address initialOwner
    ) BaseHook(_poolManager) Ownable(initialOwner) {
        if (weth == address(0)) revert BagsV4Hook_ZeroAddressWETH();
        if (vault_ == address(0)) revert BagsV4Hook_ZeroAddressVault();
        WETH = weth;
        VAULT = vault_;
    }

    /// @notice Accept native transfers (required for the WETH unwrap round-trip in {sweep})
    receive() external payable {}

    // ====================================================================
    // EXTERNAL FUNCTIONS
    // ====================================================================

    /// @notice Set the factory authorized to register pools
    /// @dev Owner-only and mutable: a factory redeploy must never force re-mining the hook address.
    ///      Already-registered pools are unaffected by a factory swap.
    /// @param factory_ Factory address
    function setFactory(
        address factory_
    ) external override onlyOwner {
        if (factory_ == address(0)) revert BagsV4Hook_ZeroAddressFactory();
        factory = factory_;
        emit FactorySet(factory_);
    }

    /// @notice Register a pool's bonding curve, fee share, and partner config (one-time per pool)
    /// @dev Only callable by the factory. Registration authorizes `bondingCurve` to initialize the
    ///      pool, routes the creator half of swept fees to `feeShare`, and snapshots the partner
    ///      config so post-graduation sweeps use the same rate the curve snapshotted at launch.
    /// @param poolId Pool identifier (keccak256 of the PoolKey computed by the factory)
    /// @param bondingCurve Bonding curve authorized to initialize the pool
    /// @param feeShare Creator-side fee recipient for the pool
    /// @param partner Optional partner address (zero for none); paid from the protocol half
    /// @param partnerFeeBps Partner share in bps of the protocol half (snapshotted at register)
    function register(
        PoolId poolId,
        address bondingCurve,
        address feeShare,
        address partner,
        uint16 partnerFeeBps
    ) external override {
        if (msg.sender != factory) revert BagsV4Hook_NotFactory(msg.sender);
        if (bondingCurve == address(0)) revert BagsV4Hook_ZeroAddressBondingCurve();
        if (feeShare == address(0)) revert BagsV4Hook_ZeroAddressFeeShare();
        if (partnerFeeBps > CUSTOM_LP_FEE_BASE) revert BagsV4Hook_InvalidPartnerFeeBps(partnerFeeBps);
        PoolConfig storage config = pools[poolId];
        if (config.bondingCurve != address(0)) revert BagsV4Hook_AlreadyRegistered(poolId);
        config.bondingCurve = bondingCurve;
        config.feeShare = feeShare;
        config.partner = partner;
        config.partnerFeeBps = partnerFeeBps;
        emit PoolRegistered(poolId, bondingCurve, feeShare, partner, partnerFeeBps);
    }

    /// @notice Sweep a pool's accrued WETH fees: protocol half native to the vault (minus the
    ///         pool's snapshotted partner cut), creator half + partner cut as WETH to its fee share
    /// @dev Permissionless. Per-pool accounting: sweeping pool A can never move pool B's accrual.
    ///      Zeroes the accrual before any transfer. No-op when nothing is pending; reverts for
    ///      unregistered pool ids so a mistyped/misconfigured keeper fails loudly instead of
    ///      silently succeeding forever. The partner cut is carved out of the PROTOCOL half (never
    ///      the creator half) and credited to the partner's pull-ledger on the fee share, so a
    ///      reverting partner address can never block sweeps.
    /// @param poolId Pool identifier
    function sweep(
        PoolId poolId
    ) external override {
        PoolConfig storage config = pools[poolId];
        if (config.bondingCurve == address(0)) revert BagsV4Hook_PoolNotRegistered(poolId);
        uint256 fees = config.pendingFees;
        if (fees == 0) return;
        config.pendingFees = 0;

        // Split 50/50 between the protocol (VAULT + partner) and creator side (feeShare)
        uint256 protocolHalf = fees / 2;
        uint256 creatorShare = fees - protocolHalf;

        // Carve the pool's snapshotted partner share out of the protocol half
        uint256 partnerShare;
        if (config.partner != address(0) && config.partnerFeeBps != 0) {
            partnerShare = Math.mulDiv(protocolHalf, config.partnerFeeBps, CUSTOM_LP_FEE_BASE);
        }
        uint256 bagsShare = protocolHalf - partnerShare;

        // Bags share must be native: unwrap WETH then send native to VAULT
        if (bagsShare > 0) {
            IWETH(WETH).withdraw(bagsShare);
            (bool okVault,) = VAULT.call{value: bagsShare}("");
            if (!okVault) revert BagsV4Hook_VaultTransferFailed(VAULT, bagsShare);
        }

        // Creator share and partner cut stay as WETH and are ledgered by BagsFeeShare
        address feeShare = config.feeShare;
        if (creatorShare + partnerShare > 0) {
            IERC20(WETH).safeTransfer(feeShare, creatorShare + partnerShare);
        }
        if (creatorShare > 0) {
            // solhint-disable-next-line avoid-low-level-calls
            (bool ok,) = feeShare.call(abi.encodeWithSignature("notifyFee(uint256)", creatorShare));
            if (!ok) revert BagsV4Hook_NotifyFeeFailed(feeShare, creatorShare);
        }
        if (partnerShare > 0) {
            // solhint-disable-next-line avoid-low-level-calls
            (bool ok,) = feeShare.call(abi.encodeWithSignature("notifyPartnerFee(uint256)", partnerShare));
            if (!ok) revert BagsV4Hook_NotifyFeeFailed(feeShare, partnerShare);
        }

        emit FeesSwept(poolId, bagsShare, creatorShare, partnerShare);
    }

    // ====================================================================
    // PUBLIC FUNCTIONS
    // ====================================================================

    /// @notice Hook permissions encoded in the deployed hook address
    /// @dev Requires `uint160(address(this)) & 0x3FFF == 0x2ECC`.
    /// @return permissions Hook permissions struct
    function getHookPermissions() public pure override(BaseHook, IBagsV4Hook) returns (Hooks.Permissions memory) {
        return Hooks.Permissions({
            beforeInitialize: true,
            afterInitialize: false,
            beforeAddLiquidity: true,
            afterAddLiquidity: true,
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

    // ====================================================================
    // INTERNAL FUNCTIONS
    // ====================================================================

    /// @dev Only the registered bonding curve may initialize its pool. Unregistered pools have
    ///      `bondingCurve == address(0)`, so nobody can attach this hook to a rogue pool.
    function _beforeInitialize(
        address sender,
        PoolKey calldata key,
        uint160
    ) internal view override returns (bytes4) {
        // Enforce tick spacing to be exactly 60
        if (key.tickSpacing != TICK_SPACING) {
            revert BagsV4Hook_LiquidityLocked();
        }
        // Only the registered bonding curve may trigger pool initialization
        if (sender != pools[key.toId()].bondingCurve) {
            revert BagsV4Hook_UnauthorizedInitializer();
        }

        return this.beforeInitialize.selector;
    }

    /// @dev Allow adding liquidity only for the single full-range migration mint
    function _beforeAddLiquidity(
        address,
        PoolKey calldata key,
        ModifyLiquidityParams calldata params,
        bytes calldata
    ) internal view override returns (bytes4) {
        // Enforce full-range ticks and single mint
        if (params.tickLower != MIN_TICK || params.tickUpper != MAX_TICK) revert BagsV4Hook_LiquidityLocked();
        if (pools[key.toId()].minted) revert BagsV4Hook_LiquidityLocked();
        return this.beforeAddLiquidity.selector;
    }

    /// @dev Records the single full-range mint latch and emits {PoolMinted}
    function _afterAddLiquidity(
        address,
        PoolKey calldata key,
        ModifyLiquidityParams calldata,
        BalanceDelta,
        BalanceDelta,
        bytes calldata
    ) internal override returns (bytes4, BalanceDelta) {
        PoolId poolId = key.toId();
        // Single full-range mint latch
        pools[poolId].minted = true;
        emit PoolMinted(poolId, Currency.unwrap(key.currency0), Currency.unwrap(key.currency1));
        return (this.afterAddLiquidity.selector, BalanceDeltaLibrary.ZERO_DELTA);
    }

    /// @dev Removing liquidity (including collect-only operations) is blocked; liquidity is permanently locked.
    function _beforeRemoveLiquidity(
        address,
        PoolKey calldata,
        ModifyLiquidityParams calldata,
        bytes calldata
    ) internal pure override returns (bytes4) {
        revert BagsV4Hook_LiquidityLocked();
    }

    /// @dev Force LP fee to 0 on every swap. Settle hook fee delta via poolManager.take().
    function _beforeSwap(
        address,
        PoolKey calldata key,
        SwapParams calldata params,
        bytes calldata
    ) internal override returns (bytes4, BeforeSwapDelta, uint24) {
        bool exactIn = params.amountSpecified < 0; // v4: exactIn when amountSpecified < 0

        // Determine specified currency (input for exactIn, output for exactOut)
        Currency specifiedCurrency = exactIn
            ? (params.zeroForOne ? key.currency0 : key.currency1)
            : (params.zeroForOne ? key.currency1 : key.currency0);

        // We charge fees only in WETH. If WETH is the specified currency:
        // - exactIn: we net it out from the amount swapped and collect it to the hook via specified delta
        // - exactOut: not supported (would require changing semantics of exact output)
        if (Currency.unwrap(specifiedCurrency) == WETH) {
            if (!exactIn) revert BagsV4Hook_ExactOutputWETHSpecifiedUnsupported();

            uint256 base = uint256(-params.amountSpecified);
            uint256 fee = Math.mulDiv(base, CUSTOM_LP_FEE, CUSTOM_LP_FEE_BASE);
            if (fee == 0) {
                return (this.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, LPFeeLibrary.OVERRIDE_FEE_FLAG);
            }

            // Settle hook's fee delta immediately by taking WETH to this contract
            poolManager.take(specifiedCurrency, address(this), fee);

            PoolId poolId = key.toId();
            pools[poolId].pendingFees += SafeCast.toUint128(fee);
            emit HookFeeTaken(poolId, fee);

            // Positive specified delta:
            // - reduces amount swapped (amountToSwap += +fee for exactIn, making it less negative)
            // - credits hook with +fee in specified currency, paid by the caller during settlement
            return (
                this.beforeSwap.selector,
                toBeforeSwapDelta(SafeCast.toInt128(SafeCast.toInt256(fee)), 0),
                LPFeeLibrary.OVERRIDE_FEE_FLAG
            );
        }

        // Otherwise, no beforeSwap deltas; fee (in WETH) will be collected via afterSwap's unspecified delta.
        return (this.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, LPFeeLibrary.OVERRIDE_FEE_FLAG);
    }

    /// @dev Charge 2% fee in WETH on the WETH leg of every swap (both buys and sells), paid by the caller via
    /// hook deltas. Settle hook fee delta via poolManager.take().
    function _afterSwap(
        address,
        PoolKey calldata key,
        SwapParams calldata params,
        BalanceDelta delta,
        bytes calldata
    ) internal override returns (bytes4, int128) {
        bool exactIn = params.amountSpecified < 0;

        // Determine unspecified currency (output for exactIn, input for exactOut)
        Currency unspecifiedCurrency = exactIn
            ? (params.zeroForOne ? key.currency1 : key.currency0)
            : (params.zeroForOne ? key.currency0 : key.currency1);

        // If unspecified currency isn't WETH, then WETH must have been the specified currency
        // (in which case fee is handled in beforeSwap) OR the hook is misconfigured.
        if (Currency.unwrap(unspecifiedCurrency) != WETH) {
            bool poolHasWETH = Currency.unwrap(key.currency0) == WETH || Currency.unwrap(key.currency1) == WETH;
            if (!poolHasWETH) revert BagsV4Hook_PoolMissingWETH();
            return (this.afterSwap.selector, 0);
        }

        // Fee is returned as hook delta in unspecified currency (WETH).
        int128 wethAmount = (Currency.unwrap(key.currency0) == WETH) ? delta.amount0() : delta.amount1();
        if (wethAmount == 0) return (this.afterSwap.selector, 0);

        uint256 base = uint256(int256(wethAmount > 0 ? wethAmount : -wethAmount));
        uint256 fee = Math.mulDiv(base, CUSTOM_LP_FEE, CUSTOM_LP_FEE_BASE);
        if (fee == 0) return (this.afterSwap.selector, 0);

        // Settle hook's fee delta immediately by taking WETH to this contract
        poolManager.take(unspecifiedCurrency, address(this), fee);

        PoolId poolId = key.toId();
        pools[poolId].pendingFees += SafeCast.toUint128(fee);
        emit HookFeeTaken(poolId, fee);

        return (this.afterSwap.selector, SafeCast.toInt128(SafeCast.toInt256(fee)));
    }
}
