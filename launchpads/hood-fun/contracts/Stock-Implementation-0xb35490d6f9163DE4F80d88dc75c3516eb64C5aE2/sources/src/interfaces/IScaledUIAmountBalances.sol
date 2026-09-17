// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IScaledUIAmountBalances {
    // Returns the UI-adjusted balance of an account
    function balanceOfUI(address account) external view returns (uint256);

    // Returns the UI-adjusted total supply
    function totalSupplyUI() external view returns (uint256);
}
