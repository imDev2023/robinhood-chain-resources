// SPDX-License-Identifier: BUSL-1.1
// Copyright (c) 2026 long.xyz. All rights reserved.
pragma solidity ^0.8.26;

import {PoolKey} from "v4-core/src/types/PoolKey.sol";

/// @notice Beneficiary entry stored by the initializer's FeesManager.
struct BeneficiaryData {
    address beneficiary;
    uint96 shares; // WAD, all shares must sum to 1e18
}

/// @notice Multicurve range definition used in InitData.
struct Curve {
    int24 tickLower;
    int24 tickUpper;
    uint16 numPositions;
    uint256 shares; // WAD share of totalTokensOnBondingCurve
}

/// @notice abi-encoded into CreateParams.poolInitializerData for DopplerHookInitializer.
struct InitData {
    uint24 fee; // becomes the dynamic LP fee when dopplerHook != 0
    int24 tickSpacing;
    int24 farTick;
    Curve[] curves;
    BeneficiaryData[] beneficiaries;
    address dopplerHook;
    bytes onInitializationDopplerHookCalldata;
    bytes graduationDopplerHookCalldata;
}

/// @notice External surface of the deployed DopplerHookInitializer at
/// 0x4e3468951D49f2EEa976eD0D6e75fFCb44a9a544 (pool initializer + v4 hook + FeesManager).
/// Signatures verified against the Blockscout-verified source.
interface IDopplerHookInitializer {
    /// @notice Emitted on every updateBeneficiary call, INCLUDING silent no-ops from
    /// non-beneficiary callers — the event stream alone cannot prove a slot moved.
    /// @dev All three params are non-indexed (ABI verified against live logs).
    event UpdateBeneficiary(bytes32 poolId, address oldBeneficiary, address newBeneficiary);

    /// @dev Auto-getter of `mapping(address => PoolState)`; dynamic arrays
    /// (beneficiaries, adjustedCurves) are skipped by the compiler-generated getter.
    function getState(address asset)
        external
        view
        returns (
            address numeraire,
            uint256 totalTokensOnBondingCurve,
            address dopplerHook,
            bytes memory graduationDopplerHookCalldata,
            uint8 status, // 0 Uninitialized, 1 Initialized, 2 Locked, 3 Graduated, 4 Exited
            PoolKey memory poolKey,
            int24 farTick
        );

    function getBeneficiaries(address asset) external view returns (BeneficiaryData[] memory);

    /// @notice Only callable by the pool's doppler hook (rehype plugin).
    function updateDynamicLPFee(address asset, uint24 lpFee) external;

    // ------------------------------------------------------------ FeesManager
    /// @notice Collects pool LP fees from the locked curve positions into the
    /// initializer, then releases the CALLER's beneficiary share (if any).
    function collectFees(bytes32 poolId) external returns (uint128 fees0, uint128 fees1);

    /// @notice Pays the CALLER's pending fees, then moves the CALLER's beneficiary slot
    /// to `newBeneficiary`.
    /// @dev NO access control: called by a non-beneficiary it is a silent no-op that
    /// still emits {UpdateBeneficiary}. If `newBeneficiary` already holds shares in the
    /// pool, the two positions MERGE IRREVERSIBLY — always preflight
    /// `getShares(poolId, newBeneficiary) == 0`. Payouts may include native ETH sent via
    /// a raw call, so contract destinations must be able to receive it or claims brick.
    function updateBeneficiary(bytes32 poolId, address newBeneficiary) external;

    function getCumulatedFees0(bytes32 poolId) external view returns (uint256);
    function getCumulatedFees1(bytes32 poolId) external view returns (uint256);
    function getLastCumulatedFees0(bytes32 poolId, address beneficiary) external view returns (uint256);
    function getLastCumulatedFees1(bytes32 poolId, address beneficiary) external view returns (uint256);
    function getShares(bytes32 poolId, address beneficiary) external view returns (uint256);
    function getPoolKey(bytes32 poolId)
        external
        view
        returns (PoolKey memory);
}
