// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IScaledUIAmount {
    event TransferWithScaledUI(address indexed from, address indexed to, uint256 value, uint256 uiValue);

    // Emitted when the UI multiplier is updated
    event UIMultiplierUpdated(uint256 oldMultiplier, uint256 newMultiplier, uint256 effectiveAtTimestamp);

    // Returns the current UI multiplier
    // Multiplier is represented with 18 decimals (1e18 = 1.0)
    function uiMultiplier() external view returns (uint256);
}
