// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IACPHookMetadata
/// @notice Required metadata interface for hooks used with MultiHookRouter.
///         Declares which selectors a hook requires to function correctly.
interface IACPHookMetadata {
    /// @notice Returns the selectors this hook requires to function correctly.
    /// @dev If a hook is configured for any of these selectors on the router,
    ///      it must be configured for ALL of them. Return empty array if no
    ///      cross-selector dependencies exist.
    function requiredSelectors() external view returns (bytes4[] memory);
}
