// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IScaledUIAmountNewUIMultiplier {
    // Returns the pending UI multiplier scheduled to take effect at effectiveAt
    // Multiplier is represented with 18 decimals (1e18 = 1.0)
    function newUIMultiplier() external view returns (uint256);

    // Returns the timestamp at which the pending multiplier becomes effective
    function effectiveAt() external view returns (uint256);
}
