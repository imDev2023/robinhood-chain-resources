// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @notice The two selectors a Robinhood Chain Stock Token adds on top of ERC-20.
///
/// @dev    Stock Tokens are otherwise plain 18-decimal ERC-20s. Corporate actions
///         do NOT rebase balances: `uiMultiplier()` scales the effective share
///         count instead (ERC-8056), and the Chainlink feed already multiplies it
///         in. A split therefore leaves the USD value of one *raw* token
///         continuous, which is why a stock-quoted AMM pool is not drained by one.
///
///         `oraclePaused()` is the flag that actually matters to us: Robinhood
///         raises it while a corporate action is being processed and the feed
///         freezes at its last good value. Any minOut computed from a paused feed
///         is a guess, so the sweep refuses to run against one.
interface IStockToken {
    function uiMultiplier() external view returns (uint256);
    function oraclePaused() external view returns (bool);
}
