// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "./interfaces/IAccessControlsRegistry.sol";

abstract contract AccessControlled is ContextUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable
    address public immutable ACCESS_CONTROLLED_REGISTRY;

    error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);
    error Blocked(address account);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(address registry) {
        require(registry != address(0));
        ACCESS_CONTROLLED_REGISTRY = registry;
    }

    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!IAccessControlsRegistry(ACCESS_CONTROLLED_REGISTRY).hasRole(role, account)) {
            revert AccessControlUnauthorizedAccount(account, role);
        }
    }

    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    modifier onlyNotBlocked(address account) {
        if (IAccessControlsRegistry(ACCESS_CONTROLLED_REGISTRY).isBlocked(account)) {
            revert Blocked(account);
        }
        _;
    }
}
