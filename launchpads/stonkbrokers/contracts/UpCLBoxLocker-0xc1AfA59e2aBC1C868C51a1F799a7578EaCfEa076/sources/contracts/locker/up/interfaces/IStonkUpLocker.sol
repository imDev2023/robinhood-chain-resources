// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @notice Shared vocabulary for the up33 Safety Deposit Box lockers.
/// Fee modes are deliberately identical to `IStonkLiquidityLocker` so the
/// existing box UI, fee sink and accounting conventions carry over unchanged.
interface IStonkUpLocker {
    enum FeeMode {
        /// @dev 0.5% of principal taken once, at lock time.
        UpfrontHalfPercent,
        /// @dev 1% of principal taken on each vested withdrawal.
        WithdrawOnePercent,
        /// @dev 20% of every yield payout (swap fees AND gauge emissions).
        CollectTwentyPercent
    }
}
