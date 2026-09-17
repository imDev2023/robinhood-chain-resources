// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.26;

import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {PoolId} from "@uniswap/v4-core/src/types/PoolId.sol";

/// @title IBagsV4Hook
/// @notice Interface for the shared Bags Uniswap v4 hook used by all Bags pools post-migration
/// @author Bags
interface IBagsV4Hook {
    /// @notice Per-pool configuration and fee accounting
    /// @param bondingCurve Sole address authorized to initialize the pool
    /// @param feeShare Creator-side fee recipient for this pool
    /// @param pendingFees WETH fees accrued for this pool and not yet swept
    /// @param minted One-shot full-range mint latch
    /// @param partner Optional partner address (zero for none); paid from the protocol half
    /// @param partnerFeeBps Partner share in bps of the protocol half (snapshotted at register)
    struct PoolConfig {
        address bondingCurve;
        address feeShare;
        uint128 pendingFees;
        bool minted;
        address partner;
        uint16 partnerFeeBps;
    }

    /// @notice Emitted when a pool is registered by the factory
    /// @param poolId Pool identifier
    /// @param bondingCurve Bonding curve authorized to initialize the pool
    /// @param feeShare Creator-side fee recipient for the pool
    /// @param partner Optional partner address (zero for none)
    /// @param partnerFeeBps Partner share in bps of the protocol half
    event PoolRegistered(
        PoolId indexed poolId,
        address indexed bondingCurve,
        address indexed feeShare,
        address partner,
        uint16 partnerFeeBps
    );
    /// @notice Emitted when the factory address is updated
    /// @param factory New factory address
    event FactorySet(address indexed factory);
    /// @notice Emitted when a pool's single full-range position is minted
    /// @param poolId Pool identifier
    /// @param currency0 Address of currency0
    /// @param currency1 Address of currency1
    event PoolMinted(PoolId indexed poolId, address indexed currency0, address indexed currency1);
    /// @notice Emitted every time the hook takes its WETH fee on a swap
    /// @param poolId Pool identifier
    /// @param amount WETH fee amount taken
    event HookFeeTaken(PoolId indexed poolId, uint256 amount);
    /// @notice Emitted after sweeping a pool's accrued WETH fees
    /// @param poolId Pool identifier
    /// @param bagsShare Protocol share sent to the vault (unwrapped to native, after partner cut)
    /// @param creatorShare Creator share sent to the pool's fee share (as WETH)
    /// @param partnerShare Partner cut of the protocol half sent to the fee share (as WETH)
    event FeesSwept(PoolId indexed poolId, uint256 bagsShare, uint256 creatorShare, uint256 partnerShare);

    /// @notice Zero address provided for WETH
    error BagsV4Hook_ZeroAddressWETH();
    /// @notice Zero address provided for Bags vault
    error BagsV4Hook_ZeroAddressVault();
    /// @notice Zero address provided for factory
    error BagsV4Hook_ZeroAddressFactory();
    /// @notice Zero address provided for bonding curve
    error BagsV4Hook_ZeroAddressBondingCurve();
    /// @notice Zero address provided for fee share
    error BagsV4Hook_ZeroAddressFeeShare();
    /// @notice Caller is not the registered factory
    error BagsV4Hook_NotFactory(address caller);
    /// @notice Pool has already been registered
    error BagsV4Hook_AlreadyRegistered(PoolId poolId);
    /// @notice Pool has not been registered by the factory
    error BagsV4Hook_PoolNotRegistered(PoolId poolId);
    /// @notice Liquidity is locked and cannot be added (outside the single mint) or removed
    error BagsV4Hook_LiquidityLocked();
    /// @notice Only the registered bonding curve can initialize the pool
    error BagsV4Hook_UnauthorizedInitializer();
    /// @notice Exact output swaps where WETH is the specified currency are unsupported
    error BagsV4Hook_ExactOutputWETHSpecifiedUnsupported();
    /// @notice Pool does not contain WETH - hook misconfigured
    error BagsV4Hook_PoolMissingWETH();
    /// @notice Native transfer to the Bags vault failed
    error BagsV4Hook_VaultTransferFailed(address vault, uint256 amount);
    /// @notice FeeShare notify failed
    error BagsV4Hook_NotifyFeeFailed(address feeShare, uint256 amount);
    /// @notice Partner fee bps exceeds the 10_000 denominator
    error BagsV4Hook_InvalidPartnerFeeBps(uint16 partnerFeeBps);

    /// @notice WETH token address used to determine the fee currency
    /// @return weth WETH address
    function WETH() external view returns (address weth);
    /// @notice Bags platform vault (receives the protocol half of swept fees, minus any partner cut, as native)
    /// @return vault Bags vault address
    function VAULT() external view returns (address vault);
    /// @notice Factory authorized to register pools
    /// @return factoryAddress Factory address
    function factory() external view returns (address factoryAddress);
    /// @notice Per-pool configuration and fee accounting
    /// @param poolId Pool identifier
    /// @return bondingCurve Bonding curve authorized to initialize the pool
    /// @return feeShare Creator-side fee recipient
    /// @return pendingFees WETH fees accrued and not yet swept
    /// @return minted True once the single full-range mint happened
    /// @return partner Optional partner address (zero for none)
    /// @return partnerFeeBps Partner share in bps of the protocol half
    function pools(
        PoolId poolId
    )
        external
        view
        returns (
            address bondingCurve,
            address feeShare,
            uint128 pendingFees,
            bool minted,
            address partner,
            uint16 partnerFeeBps
        );

    /// @notice Set the factory authorized to register pools
    /// @param factory_ Factory address
    function setFactory(
        address factory_
    ) external;
    /// @notice Register a pool's bonding curve, fee share, and partner config (one-time per pool)
    /// @param poolId Pool identifier
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
    ) external;
    /// @notice Sweep a pool's accrued WETH fees: half native to the vault, half WETH to its fee share
    /// @dev Reverts with {BagsV4Hook_PoolNotRegistered} for unknown pool ids; no-op when the
    ///      registered pool has nothing pending.
    /// @param poolId Pool identifier
    function sweep(
        PoolId poolId
    ) external;

    /// @notice Hook permissions encoded in the deployed hook address (mask 0x2ECC)
    /// @return permissions Hook permissions struct
    function getHookPermissions() external pure returns (Hooks.Permissions memory permissions);
}
