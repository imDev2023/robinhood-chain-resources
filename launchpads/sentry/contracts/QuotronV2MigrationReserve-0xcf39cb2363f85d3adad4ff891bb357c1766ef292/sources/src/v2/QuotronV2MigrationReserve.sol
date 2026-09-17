// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title QuotronV2MigrationReserve
/// @notice Immutable, withdrawal-less holder for the exact V2 supply committed by
/// the migration snapshot. Quotron404V2 debits this address internally as
/// claims complete; no owner or arbitrary withdrawal path exists.
contract QuotronV2MigrationReserve {
    address public immutable quotron;

    constructor(address quotron_) {
        require(quotron_ != address(0), "zero");
        quotron = quotron_;
    }
}
