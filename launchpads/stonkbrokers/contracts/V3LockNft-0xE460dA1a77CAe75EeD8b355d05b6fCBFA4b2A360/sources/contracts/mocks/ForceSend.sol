// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @notice Forces ETH into a target using selfdestruct.
contract ForceSend {
    constructor() payable {}

    function boom(address payable to) external {
        selfdestruct(to);
    }
}

