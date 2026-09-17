// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.26;

/// @title IWETH
/// @notice Minimal interface for WETH withdraw
/// @author Bags
interface IWETH {
    /// @notice Unwrap WETH into the chain's native token (ETH)
    /// @param amount Amount of WETH to unwrap
    function withdraw(uint256 amount) external;
}
