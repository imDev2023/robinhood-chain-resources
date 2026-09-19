// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./IStonkLiquidityLockerV4Adapter.sol";

/// @notice Placeholder contract for the future full V4 locker integration.
/// Revert-by-default to make gating explicit on frontend + scripts.
contract StonkLiquidityLockerV4Stub is IStonkLiquidityLockerV4Adapter {
    error V4NotReady();

    function isV4Ready() external pure returns (bool) {
        return false;
    }

    function lockV4Position(bytes calldata) external pure {
        revert V4NotReady();
    }
}

