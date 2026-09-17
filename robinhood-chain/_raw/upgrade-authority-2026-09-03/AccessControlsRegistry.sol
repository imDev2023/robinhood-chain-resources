// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Roles.sol";

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/proxy/beacon/IBeacon.sol";

import "./interfaces/IAccessControlsRegistry.sol";

contract AccessControlsRegistry is IBeacon, IAccessControlsRegistry, AccessControl {
    address public override implementation;
    bool public override paused;

    error BeaconInvalidImplementation(address implementation);

    event Upgraded(address indexed implementation);

    mapping(address => bool) public override isBlocked;

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(BEACON_UPGRADER_ROLE, msg.sender);
    }

    function pause() external onlyRole(PAUSER_ROLE) {
        paused = true;
        emit Paused();
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        paused = false;
        emit Unpaused();
    }

    function upgradeTo(address newImplementation) external onlyRole(BEACON_UPGRADER_ROLE) {
        if (newImplementation.code.length == 0) {
            revert BeaconInvalidImplementation(newImplementation);
        }
        implementation = newImplementation;
        emit Upgraded(newImplementation);
    }

    function blockAccounts(address[] calldata accounts) external override onlyRole(BLOCKER_ROLE) {
        for (uint256 i = 0; i < accounts.length; i++) {
            isBlocked[accounts[i]] = true;
            emit Blocked(accounts[i]);
        }
    }

    function unblockAccounts(address[] calldata accounts) external override onlyRole(BLOCKER_ROLE) {
        for (uint256 i = 0; i < accounts.length; i++) {
            isBlocked[accounts[i]] = false;
            emit Unblocked(accounts[i]);
        }
    }
}
