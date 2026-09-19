// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/// @notice Common quote-management ABI shared by the managed ERC20 and B20 launch factories.
interface IRWAQuoteRegistry {
    struct QuoteRegistration {
        address quoteToken;
        int24 startTickToken0Frame;
    }

    struct QuoteTickUpdate {
        address quoteToken;
        int24 newStartTickToken0Frame;
        uint64 expectedRevision;
    }

    function MAX_QUOTE_BATCH_SIZE() external view returns (uint256 maximumBatchSize);
    function nativeLaunchFee() external view returns (uint256 launchFee);
    function priceUpdater() external view returns (address updater);
    function launchCreationEnabled() external view returns (bool creationEnabled);
    function quoteConfig(address quoteToken)
        external
        view
        returns (bool registered, uint8 quoteDecimals, int24 startTickToken0Frame);
    function quoteRevision(address quoteToken) external view returns (uint64 revision);
    function registerQuote(address quoteToken, int24 startTickToken0Frame) external;
    function batchRegisterQuotes(QuoteRegistration[] calldata quoteRegistrations) external;
    function setQuoteStartTick(address quoteToken, int24 newStartTickToken0Frame, uint64 expectedRevision) external;
    function batchSetQuoteStartTicks(QuoteTickUpdate[] calldata quoteTickUpdates) external;
    function unregisterQuote(address quoteToken) external;
    function batchUnregisterQuotes(address[] calldata quoteTokens) external;
    function setNativeLaunchFee(uint256 newNativeLaunchFee) external;
    function setPriceUpdater(address newPriceUpdater) external;
    function setLaunchCreationEnabled(bool creationEnabled) external;
}
