// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @notice Optional notification interface for a dividend sink.
///
/// @dev    The router ALWAYS delivers by plain `WETH.transfer(sink, amount)`,
///         and only calls `onDividend` afterwards when the sink is configured as
///         notifying. That ordering is deliberate: an ERC-20 transfer does not
///         invoke recipient code, so delivery cannot be broken by whatever the
///         sink does -- or fails to do -- with the notification.
///
///         It is what lets the live HOOD10 dividend engine
///         (0x9f3edbfA..6210, unverified, feeToken() == WETH) be a valid sink
///         with no adapter at all: configure it non-notifying and the router's
///         entire coupling to it is one ERC-20 transfer.
interface IDividendSink {
    function feeToken() external view returns (address);
    function onDividend(uint256 amount) external;
}
