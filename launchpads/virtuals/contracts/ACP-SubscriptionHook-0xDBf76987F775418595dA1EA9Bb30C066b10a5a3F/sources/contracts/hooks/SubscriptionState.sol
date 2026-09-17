// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

/// @title SubscriptionState
/// @notice Pure state contract for subscription expiry data. Role-based access control
///         allows multiple subscription hooks to write to the same state contract.
/// @dev Follows EIP-5643 pattern — flat mapping of (client, provider, packageId) → expiry.
///      Uses WRITER_ROLE so multiple hooks can share state.
contract SubscriptionState is AccessControl {
    // ──────────────────── Constants ────────────────────

    /// @notice Role required to write subscription data (granted to subscription hooks)
    bytes32 public constant WRITER_ROLE = keccak256("WRITER_ROLE");

    // ──────────────────── Storage ────────────────────

    /// @notice Maps keccak256(client, provider, packageId) → expiry timestamp
    mapping(bytes32 subId => uint256 expiry) public subscriptionExpiry;

    // ──────────────────── Errors ────────────────────

    /// @notice Reverts when the new expiry does not extend the current subscription
    error SubscriptionNotExtended();

    // ──────────────────── Constructor ────────────────────

    /// @param admin_ The address that receives DEFAULT_ADMIN_ROLE (can grant/revoke WRITER_ROLE)
    constructor(address admin_) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin_);
    }

    // ──────────────────── Write Functions ────────────────────

    /// @notice Activates or extends a subscription. Validates monotonic expiry.
    /// @param client The client address
    /// @param provider The provider address
    /// @param packageId The subscription package ID
    /// @param expiry The subscription expiry timestamp
    function activateSubscription(
        address client,
        address provider,
        uint256 packageId,
        uint256 expiry
    ) external onlyRole(WRITER_ROLE) {
        bytes32 key = _subKey(client, provider, packageId);
        if (expiry <= subscriptionExpiry[key]) revert SubscriptionNotExtended();
        subscriptionExpiry[key] = expiry;
    }

    // ──────────────────── View Functions ────────────────────

    /// @notice Returns the subscription expiry for a client-provider-package tuple
    /// @param client The client address
    /// @param provider The provider address
    /// @param packageId The subscription package ID
    /// @return The expiry timestamp
    function getSubscriptionExpiry(
        address client,
        address provider,
        uint256 packageId
    ) external view returns (uint256) {
        return subscriptionExpiry[_subKey(client, provider, packageId)];
    }

    // ──────────────────── ERC-165 ────────────────────

    /// @notice ERC-165 interface support (required by AccessControl)
    /// @param interfaceId The interface identifier
    /// @return True if the interface is supported
    function supportsInterface(
        bytes4 interfaceId
    ) public view override returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    // ──────────────────── Internal ────────────────────

    /// @dev Computes the storage key for a subscription
    function _subKey(
        address client,
        address provider,
        uint256 packageId
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(client, provider, packageId));
    }
}
