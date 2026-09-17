// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @notice Reflections engine callbacks + views the Quotron404 core and
/// the frontend depend on. Implemented by QuotronReflections.
interface IQuotronReflections {
    /// @dev Called by Quotron404 when an id is hardwired (burn done).
    function onHardwire(uint256 id, address owner) external;

    /// @dev Called by Quotron404 when a HARDWIRED id changes owner —
    /// checkpoints accrual and re-reads the new owner's Broker boost.
    function onHardwiredTransfer(uint256 id, address from, address to) external;

    /// @notice Pending reflections for a terminal, in its floor's stock.
    function pending(uint256 id) external view returns (uint256 amount, address stockToken);

    /// @notice Claim reflections for owned hardwired ids.
    function claim(uint256[] calldata ids) external;

    /// @notice Live weight (tier base x Broker boost) for a hardwired id.
    function weightOf(uint256 id) external view returns (uint256);

    /// @notice Re-price a stale Broker boost. Callable by anyone.
    function poke(uint256 id) external;
}
