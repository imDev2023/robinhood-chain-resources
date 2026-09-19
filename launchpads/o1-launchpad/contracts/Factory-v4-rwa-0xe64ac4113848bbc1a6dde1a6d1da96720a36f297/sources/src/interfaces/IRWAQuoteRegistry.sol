// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/// @notice Common management ABI shared by the ERC20 and B20 RWA launch factories.
interface IRWAQuoteRegistry {
    struct QuoteRegistration {
        address quote;
        int24 startTickToken0Frame;
    }

    struct QuoteTickUpdate {
        address quote;
        int24 startTickToken0Frame;
        uint64 expectedRevision;
    }

    function MAX_QUOTE_BATCH_SIZE() external view returns (uint256);
    function nativeLaunchFee() external view returns (uint256);
    function priceUpdater() external view returns (address);
    function launchCreationEnabled() external view returns (bool);
    function quoteRevision(address quote) external view returns (uint64);
    function batchRegisterQuotes(QuoteRegistration[] calldata registrations) external;
    function setQuoteStartTick(address quote, int24 startTickToken0Frame, uint64 expectedRevision) external;
    function batchSetQuoteStartTicks(QuoteTickUpdate[] calldata updates) external;
    function batchUnregisterQuotes(address[] calldata quoteAddresses) external;
    function setNativeLaunchFee(uint256 newFeeWei) external;
    function setPriceUpdater(address updater) external;
    function setLaunchCreationEnabled(bool enabled) external;
}
