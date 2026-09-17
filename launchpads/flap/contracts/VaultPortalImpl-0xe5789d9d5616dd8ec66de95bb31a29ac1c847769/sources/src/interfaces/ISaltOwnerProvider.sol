// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

/// @title ISaltOwnerProvider
/// @notice Callback interface that VaultPortal implements so Portal can resolve the real end-user
///         when checking salt locks.
/// @dev Portal performs a staticcall to `getSaltOwner()` on the caller (VaultPortal) whenever
///      the caller is a contract and a salt-lock is in effect.  VaultPortal sets
///      `_pendingSaltOwner` to `msg.sender` immediately before calling Portal and clears it
///      afterwards, so the returned value is always the true initiating user or address(0) when
///      no launch is in progress.
interface ISaltOwnerProvider {
    /// @notice Returns the address of the real end-user who initiated the current launch.
    /// @dev    Set by VaultPortal to `msg.sender` immediately before calling Portal.
    ///         Returns address(0) if no launch is in progress.
    function getSaltOwner() external view returns (address);
}

