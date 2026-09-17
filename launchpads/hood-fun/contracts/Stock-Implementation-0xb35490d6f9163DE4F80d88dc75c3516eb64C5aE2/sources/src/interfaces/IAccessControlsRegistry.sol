// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/IAccessControl.sol";

interface IAccessControlsRegistry is IAccessControl {
    event Blocked(address indexed account);
    event Unblocked(address indexed account);
    event Paused();
    event Unpaused();

    function isBlocked(address account) external view returns (bool);
    function blockAccounts(address[] calldata accounts) external;
    function unblockAccounts(address[] calldata accounts) external;

    function pause() external;
    function unpause() external;
    function paused() external view returns (bool);
}
