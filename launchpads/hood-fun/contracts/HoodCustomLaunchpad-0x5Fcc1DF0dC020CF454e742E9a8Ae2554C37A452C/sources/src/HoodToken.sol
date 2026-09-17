// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title HoodToken
/// @notice ERC-20 launched through the hood.fun bonding curve.
/// @dev The full supply is minted to the launchpad at creation. Until the curve
///      graduates and the launchpad calls `unlock()`, tokens can only move to or
///      from the launchpad itself. This closes the four.meme exploit class where
///      pre-graduation tokens were parked in a not-yet-created DEX pair to seed
///      liquidity at a manipulated price.
contract HoodToken is ERC20 {
    address public immutable launchpad;
    bool public unlocked;

    error TransfersLockedUntilGraduation();
    error OnlyLaunchpad();

    constructor(string memory name_, string memory symbol_, uint256 supply_) ERC20(name_, symbol_) {
        launchpad = msg.sender;
        _mint(msg.sender, supply_);
    }

    function unlock() external {
        if (msg.sender != launchpad) revert OnlyLaunchpad();
        unlocked = true;
    }

    function _update(address from, address to, uint256 value) internal override {
        if (!unlocked && from != address(0) && from != launchpad && to != launchpad) {
            revert TransfersLockedUntilGraduation();
        }
        super._update(from, to, value);
    }
}
