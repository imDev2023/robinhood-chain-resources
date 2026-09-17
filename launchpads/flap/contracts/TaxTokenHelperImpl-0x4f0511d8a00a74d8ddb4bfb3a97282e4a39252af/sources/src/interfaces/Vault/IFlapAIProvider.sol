// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// ============================================================
//                    IFlapAIProvider Interface
// ============================================================

/// @title IFlapAIProvider
/// @notice Oracle interface for the FlapAIProvider commit-and-reveal AI reasoning service.
/// @dev The FlapAIProvider operates as a commit-and-reveal oracle inspired by Chainlink VRF.
///      Consumers (Vault contracts) submit a reasoning request on-chain by calling `reason()`,
///      which emits an event. The off-chain oracle backend picks up the event, feeds the prompt
///      to an LLM, and posts the result back via `fulfillReasoning()`. If the backend cannot
///      process the request, it calls `refundRequest()` to return the BNB fee and notify the
///      consumer. Consumers must extend `FlapAIConsumerBase` to receive callbacks securely.
///
///      TOOL CALLING: The oracle backend supports tool calling, allowing the LLM to fetch
///      real-time external data (e.g. token market data, prices) before producing its choice.
///      Consumers embed tool invocations in the prompt using a structured format; the backend
///      executes the tools and injects their results into the LLM context automatically.
///      For the full list of supported tools, see:
///        https://docs.flap.sh/flap/developers/preview/flap-ai-oracle
///
///      Example — `ave_token_info` tool:
///        "I am managing a vault for token 0x....7777, "
///        "my main goal is to use my fund to market making for this token. "
///        "Check the market data (use ave_token_info tool) of this token and then decide what to do: "
///        "(0) buy tokens to support the floor "
///        "(1) sell my holdings to gain more funds for future market making "
///        "(2) generate volumes only (i.e: buy and then sell immediately)."
interface IFlapAIProvider {
    // ----------------------------------------------------------------
    //  Structs
    // ----------------------------------------------------------------

    /// @notice Represents a registered LLM model.
    /// @param name   Human-readable name of the model (e.g. "gpt-4").
    /// @param price  Per-request fee in native currency (BNB), in wei.
    /// @param enabled Whether the model currently accepts new requests.
    struct Model {
        string name;
        uint256 price;
        bool enabled;
    }

    /// @notice Lifecycle state of an AI reasoning request.
    /// @dev NONE      = default, request was never created.
    ///      PENDING   = request submitted on-chain, awaiting oracle fulfillment.
    ///      FULFILLED = oracle fulfilled the request and consumer callback succeeded.
    ///      UNDELIVERED = oracle fulfilled but consumer callback reverted (result stored but not delivered).
    ///      REFUNDED  = oracle refunded the request fee to the consumer.
    enum RequestStatus {
        NONE,
        PENDING,
        FULFILLED,
        UNDELIVERED,
        REFUNDED
    }

    /// @notice Stores all data for a single AI reasoning request.
    /// @dev Tightly packed into two 32-byte storage slots:
    ///      Slot 0 (immutable after `reason()`): consumer (160) + modelId (16) + numOfChoices (8) + timestamp (64) = 248 bits
    ///      Slot 1 (written by oracle): feePaid (128) + status (8) + choice (8) + reserved (112) = 256 bits
    ///      Separating immutable fields from mutable oracle results means `fulfillReasoning` and
    ///      `refundRequest` only issue a single SSTORE to slot 1, leaving slot 0 untouched.
    /// @param consumer     Address of the consuming contract that submitted the request.
    /// @param modelId      ID of the LLM model used (max 65535 distinct models).
    /// @param numOfChoices Number of choices the LLM can pick from (valid range 0..numOfChoices-1).
    /// @param timestamp    `block.timestamp` when the request was submitted via `reason()`.
    /// @param feePaid      BNB amount paid with the request (full `msg.value`), capped at uint128.
    /// @param status       Current lifecycle status of the request.
    /// @param choice       The LLM's chosen action index; only valid when status is FULFILLED or UNDELIVERED.
    /// @param reserved     Reserved for future upgrades.
    struct Request {
        // slot 0 — immutable after reason()
        address consumer; // 160 bits
        uint16 modelId; //  16 bits
        uint8 numOfChoices; //   8 bits
        uint64 timestamp; //  64 bits
        // slot 1 — written by fulfillReasoning() / refundRequest()
        uint128 feePaid; // 128 bits
        RequestStatus status; //   8 bits
        uint8 choice; //   8 bits
        uint112 reserved; // 112 bits
    }

    /// @notice Rate limit configuration for a consumer
    /// @param enabled Whether rate limiting is active for this consumer
    /// @param lastRequestTime Timestamp of the consumer's last request (uint64)
    /// @param cooldown Minimum seconds between requests (uint32)
    /// @param reserved Reserved bits for future use (uint152)
    struct RateLimit {
        bool enabled; // 1 byte
        uint64 lastRequestTime; // 8 bytes
        uint32 cooldown; // 4 bytes
        uint152 reserved; // 19 bytes
        // Total: 32 bytes, exactly 1 storage slot
    }

    // ----------------------------------------------------------------
    //  Custom Errors
    // ----------------------------------------------------------------

    /// @notice Read-only summary of a request, used exclusively by explorer view functions.
    /// @dev Avoids multiple RPC calls per request in list views by bundling all fields —
    ///      including the IPFS CID — into a single return value.
    /// @param requestId   The unique request ID.
    /// @param consumer    Address of the consuming contract that submitted the request.
    /// @param modelId     ID of the LLM model used.
    /// @param numOfChoices Number of choices the LLM could pick from.
    /// @param timestamp   `block.timestamp` when the request was submitted.
    /// @param feePaid     BNB amount paid with the request (in wei).
    /// @param status      Current lifecycle status of the request.
    /// @param choice      The LLM's chosen action index; only meaningful when status is FULFILLED or UNDELIVERED.
    /// @param reasoningCid IPFS CID of the reasoning proof; non-empty only when status is FULFILLED or UNDELIVERED.
    struct RequestView {
        uint256 requestId;
        address consumer;
        uint16 modelId;
        uint8 numOfChoices;
        uint64 timestamp;
        uint128 feePaid;
        RequestStatus status;
        uint8 choice;
        string reasoningCid;
    }

    /// @notice Reverts when the prompt byte length exceeds `maxPromptLength`.
    /// @param promptLength   Actual length of the provided prompt in bytes.
    /// @param maxPromptLength Current maximum allowed prompt length.
    error FlapAIProviderPromptExceedsMaxLength(uint256 promptLength, uint256 maxPromptLength);

    /// @notice Reverts when `numOfChoices` is zero; there must be at least one choice.
    /// @param numOfChoices The invalid zero value that was passed.
    error FlapAIProviderInvalidNumOfChoices(uint8 numOfChoices);

    /// @notice Reverts when `fulfillReasoning` or `refundRequest` is called on a request that is not PENDING.
    /// @param requestId The request ID that is not in the PENDING state.
    error FlapAIProviderRequestNotPending(uint256 requestId);

    /// @notice Reverts when the oracle's `choice` is >= `numOfChoices`.
    /// @param choice       The out-of-range choice returned by the oracle.
    /// @param numOfChoices The number of valid choices for the request.
    error FlapAIProviderChoiceOutOfRange(uint8 choice, uint8 numOfChoices);

    /// @notice Reverts when the BNB sent with `reason()` is less than the model's required price.
    /// @param sent     Amount of BNB sent (in wei).
    /// @param required Minimum required fee for the selected model (in wei).
    error FlapAIProviderInsufficientFee(uint256 sent, uint256 required);

    /// @notice Reverts when `reason()` or `getModel()` is called with a `modelId` that was never registered.
    /// @param modelId The unregistered model ID.
    error FlapAIProviderModelNotRegistered(uint256 modelId);

    /// @notice Reverts when `reason()` is called with a `modelId` that exceeds the maximum value of uint16 (65535).
    /// @dev The `Request` struct stores `modelId` as `uint16`; passing a value above 65535 would silently
    ///      truncate the stored ID, causing the emitted event and the stored request to disagree.
    /// @param modelId The out-of-range model ID that was passed.
    error FlapAIProviderModelIdTooLarge(uint256 modelId);

    /// @notice Reverts when `setCallbackGasLimit()` is called with a value below the minimum of 1_000_000.
    /// @param provided The gas limit value that was passed.
    /// @param minimum  The minimum allowed gas limit (1_000_000).
    error FlapAIProviderCallbackGasLimitTooLow(uint256 provided, uint256 minimum);

    /// @notice Reverts when `registerModel()` is called with a `modelId` that has already been registered.
    /// @dev Even if the model is currently disabled, its ID can never be reused.
    /// @param modelId The already-registered model ID.
    error FlapAIProviderModelAlreadyRegistered(uint256 modelId);

    /// @notice Reverts when the BNB withdrawal transfer fails inside `withdrawStuckFee()` or fee forwarding.
    error FlapAIProviderWithdrawFailed();

    /// @notice Reverts when a zero address is passed where a non-zero address is required.
    error FlapAIProviderZeroAddress();

    /// @notice Reverts when a consumer attempts to make a request before their rate limit cooldown has elapsed.
    /// @param consumer The consumer address that is rate limited.
    /// @param waitTime Seconds remaining until the next request is allowed.
    error FlapAIProviderRateLimitExceeded(address consumer, uint32 waitTime);

    /// @notice Reverts when `retryUndelivered` is called on a request that is not UNDELIVERED.
    /// @param requestId The request ID that is not in the UNDELIVERED state.
    error FlapAIProviderRequestNotUndelivered(uint256 requestId);

    // ----------------------------------------------------------------
    //  Events
    // ----------------------------------------------------------------

    /// @notice Emitted when a new AI reasoning request is submitted.
    /// @param requestId    Unique identifier for this request.
    /// @param consumer     Address of the consuming contract.
    /// @param modelId      ID of the LLM model selected.
    /// @param prompt       The full prompt string sent to the oracle.
    /// @param numOfChoices Number of choices the LLM can return.
    /// @param feePaid      BNB amount paid with the request (full msg.value).
    event FlapAIProviderRequestMade(
        uint256 requestId, address consumer, uint256 modelId, string prompt, uint8 numOfChoices, uint256 feePaid
    );

    /// @notice Emitted when the oracle successfully fulfills a request and the consumer callback succeeds.
    /// @param requestId              The fulfilled request ID.
    /// @param consumer               Address of the consuming contract.
    /// @param choice                 The choice returned by the LLM (0..numOfChoices-1).
    /// @param reasoningDetailsIpfsCid IPFS CID of the full reasoning proof stored on IPFS.
    event FlapAIProviderRequestFulfilled(
        uint256 requestId, address consumer, uint8 choice, string reasoningDetailsIpfsCid
    );

    /// @notice Emitted when the oracle fulfills a request but the consumer callback reverts.
    /// @param requestId              The request ID whose consumer callback failed.
    /// @param consumer               Address of the consuming contract.
    /// @param choice                 The choice returned by the LLM.
    /// @param reasoningDetailsIpfsCid IPFS CID of the reasoning proof (still stored on-chain).
    /// @param reason                 The revert data from the consumer callback.
    event FlapAIProviderRequestUndelivered(
        uint256 requestId, address consumer, uint8 choice, string reasoningDetailsIpfsCid, bytes reason
    );

    /// @notice Emitted when the oracle refunds a pending request.
    /// @param requestId    The refunded request ID.
    /// @param consumer     Address of the consuming contract that receives the refund.
    /// @param refundAmount BNB amount refunded (equals the original feePaid).
    event FlapAIProviderRequestRefunded(uint256 requestId, address consumer, uint256 refundAmount);

    /// @notice Emitted when the oracle marks a request as refunded but the consumer callback
    ///         reverts or runs out of gas, leaving the BNB stranded in the provider.
    /// @param requestId    The refunded request ID.
    /// @param consumer     Address of the consuming contract whose callback failed.
    /// @param refundAmount BNB amount that could not be delivered (equals the original feePaid).
    /// @param reason       The revert data from the consumer callback (empty on OOG).
    event FlapAIProviderRefundUndelivered(uint256 requestId, address consumer, uint256 refundAmount, bytes reason);

    /// @notice Emitted when the maximum prompt length is updated.
    /// @param oldMaxPromptLength Previous maximum prompt length in bytes.
    /// @param newMaxPromptLength New maximum prompt length in bytes.
    event FlapAIProviderMaxPromptLengthUpdated(uint256 oldMaxPromptLength, uint256 newMaxPromptLength);

    /// @notice Emitted when the consumer callback gas limit is updated.
    /// @param oldCallbackGasLimit Previous gas limit for consumer callbacks.
    /// @param newCallbackGasLimit New gas limit for consumer callbacks.
    event FlapAIProviderCallbackGasLimitUpdated(uint256 oldCallbackGasLimit, uint256 newCallbackGasLimit);

    /// @notice Emitted when a new LLM model is registered.
    /// @param modelId ID of the newly registered model.
    /// @param name    Human-readable name of the model.
    /// @param price   Per-request fee in native BNB (wei).
    event FlapAIProviderModelRegistered(uint256 modelId, string name, uint256 price);

    /// @notice Emitted when an existing model is replaced with new parameters.
    /// @dev Replaces the model's name and price in-place, keeping the same ID so that integrators
    ///      with hardcoded model IDs continue to work seamlessly.
    /// @param modelId ID of the replaced model.
    /// @param name    New human-readable name of the model.
    /// @param price   New per-request fee in native BNB (wei).
    event FlapAIProviderModelReplaced(uint256 indexed modelId, string name, uint256 price);

    /// @notice Emitted when accumulated BNB fees are withdrawn by an admin.
    /// @param recipient Address that received the fees.
    /// @param amount    Amount of BNB withdrawn (in wei).
    event FlapAIProviderFeesWithdrawn(address indexed recipient, uint256 amount);

    /// @notice Emitted when a consumer's rate limit configuration is updated.
    /// @param consumer Address of the consumer whose rate limit was configured.
    /// @param enabled  Whether rate limiting is now active for this consumer.
    /// @param cooldown Minimum seconds between requests (only relevant when enabled=true).
    event FlapAIProviderRateLimitConfigured(address indexed consumer, bool enabled, uint32 cooldown);

    /// @notice Emitted whenever a request response is successfully tracked (fulfillment or retry).
    /// @param requestId The ID of the fulfilled request.
    event TrackRequestResponse(uint256 indexed requestId);

    // ----------------------------------------------------------------
    //  Functions
    // ----------------------------------------------------------------

    /// @notice Submit an AI reasoning request to the oracle.
    /// @dev Validates that:
    ///        1. `modelId <= type(uint16).max` (reverts FlapAIProviderModelIdTooLarge).
    ///        2. `modelId` is a registered model (reverts FlapAIProviderModelNotRegistered).
    ///        3. `numOfChoices > 0` (reverts FlapAIProviderInvalidNumOfChoices).
    ///        4. `bytes(prompt).length <= maxPromptLength` (reverts FlapAIProviderPromptExceedsMaxLength).
    ///        5. `msg.value >= model.price` (reverts FlapAIProviderInsufficientFee).
    ///      Any excess BNB beyond the model price is intentionally NOT refunded — it becomes protocol revenue.
    ///      Emits {FlapAIProviderRequestMade}.
    ///
    ///      TOOL CALLING: The oracle supports tool calling so the LLM can pull live data before
    ///      reasoning. Declare the tools you want available inside the prompt string. The backend
    ///      will execute any tool calls the LLM makes and feed the results back automatically.
    ///      For the complete list of supported tools visit:
    ///        https://docs.flap.sh/flap/developers/preview/flap-ai-oracle
    ///
    ///      Example using `ave_token_info` to fetch live market data for a token:
    ///        "I am managing a vault for token 0x....7777, "
    ///        "my main goal is to use my fund to market making for this token. "
    ///        "Check the market data (use ave_token_info tool) of this token and then decide what to do: "
    ///        "(0) buy tokens to support the floor "
    ///        "(1) sell my holdings to gain more funds for future market making "
    ///        "(2) generate volumes only (i.e: buy and then sell immediately)."
    /// @param modelId      ID of the LLM model to use for this request.
    /// @param prompt       Combined system + user prompt. The consumer must embed the choice meanings
    ///                     (e.g., "0 = buy, 1 = sell") inside the prompt string. Tool descriptions
    ///                     may also be included here to enable tool calling (see @dev above).
    /// @param numOfChoices Number of choices the LLM may return (valid responses are 0..numOfChoices-1).
    /// @return requestId   Unique uint256 identifier for this request. Store it to correlate with the callback.
    function reason(uint256 modelId, string calldata prompt, uint8 numOfChoices)
        external
        payable
        returns (uint256 requestId);

    /// @notice Return the full Model struct for a registered model.
    /// @dev Reverts with `FlapAIProviderModelNotRegistered` if the `modelId` was never registered.
    /// @param modelId ID of the model to query.
    /// @return model  The Model struct containing `name`, `price`, and `enabled`.
    function getModel(uint256 modelId) external view returns (Model memory model);

    /// @notice Fulfill a pending AI reasoning request.
    /// @dev Restricted to the oracle backend (FULFILLER_ROLE). Validates:
    ///        1. Request status is PENDING (reverts FlapAIProviderRequestNotPending).
    ///        2. `choice < request.numOfChoices` (reverts FlapAIProviderChoiceOutOfRange).
    ///      Stores `reasoningDetailsIpfsCid` on-chain, then calls `fulfillReasoning(requestId, choice)`
    ///      on the consumer inside a try/catch:
    ///        - On success: status → FULFILLED, emits {FlapAIProviderRequestFulfilled}.
    ///        - On consumer revert: status → UNDELIVERED, emits {FlapAIProviderRequestUndelivered}.
    ///      The IPFS CID is always stored regardless of callback outcome.
    /// @param requestId              The ID of the pending request to fulfill.
    /// @param choice                 The LLM's chosen action (must be < numOfChoices).
    /// @param reasoningDetailsIpfsCid IPFS CID of the full reasoning proof document.
    function fulfillReasoning(uint256 requestId, uint8 choice, string calldata reasoningDetailsIpfsCid) external;

    /// @notice Refund a pending request when the oracle cannot process it.
    /// @dev Restricted to the oracle backend (FULFILLER_ROLE). Validates that the request is PENDING.
    ///      Sets status to REFUNDED, transfers the original `feePaid` BNB back to the consumer,
    ///      then calls `onFlapAIRequestRefunded{gas: 1_000_000}(requestId)` on the consumer.
    ///      Emits {FlapAIProviderRequestRefunded}.
    /// @param requestId The ID of the pending request to refund.
    function refundRequest(uint256 requestId) external;

    /// @notice Manually retry the consumer callback for an UNDELIVERED request.
    /// @dev Callable by anyone. Validates that the request status is UNDELIVERED, then re-invokes
    ///      `fulfillReasoning(requestId, choice)` on the consumer with no gas cap, allowing the
    ///      consumer to use as much gas as the transaction provides.
    ///      Unlike the initial fulfillment, no try/catch is used — if the callback reverts the
    ///      entire transaction reverts and the request remains UNDELIVERED.
    ///      On success: status → FULFILLED, fee forwarded to feeReceiver,
    ///      emits {FlapAIProviderRequestFulfilled}.
    /// @param requestId The ID of the UNDELIVERED request to retry.
    function retryUndelivered(uint256 requestId) external;

    /// @notice Returns the current maximum allowed prompt length in bytes.
    /// @return The current `_maxPromptLength` value (default: 6000).
    function maxPromptLength() external view returns (uint256);

    /// @notice Update the maximum allowed prompt length in bytes.
    /// @dev Restricted to DEFAULT_ADMIN_ROLE. Emits {FlapAIProviderMaxPromptLengthUpdated}.
    /// @param newMaxPromptLength The new maximum prompt length in bytes.
    function setMaxPromptLength(uint256 newMaxPromptLength) external;

    /// @notice Returns the gas limit forwarded to consumer callbacks (`fulfillReasoning` and `onFlapAIRequestRefunded`).
    /// @return The current `_maxCallbackGas` value (default: 1_000_000).
    function callbackGasLimit() external view returns (uint256);

    /// @notice Update the gas limit forwarded to consumer callbacks.
    /// @dev Restricted to DEFAULT_ADMIN_ROLE. Reverts with `FlapAIProviderCallbackGasLimitTooLow` if
    ///      `newCallbackGasLimit` is less than 1_000_000. Emits {FlapAIProviderCallbackGasLimitUpdated}.
    /// @param newCallbackGasLimit The new gas limit for consumer callbacks (must be >= 1_000_000).
    function setCallbackGasLimit(uint256 newCallbackGasLimit) external;

    // ----------------------------------------------------------------
    //  Admin
    // ----------------------------------------------------------------

    /// @notice Register a new LLM model in the provider registry.
    /// @dev Only callable by `DEFAULT_ADMIN_ROLE`. A `modelId` that has already been registered
    ///      (even if disabled) can never be re-registered. Emits {FlapAIProviderModelRegistered}.
    /// @param modelId ID to assign to the new model (must be unused).
    /// @param name    Human-readable name (e.g., "gpt-4").
    /// @param price   Per-request fee in BNB (wei). May be 0 for free models.
    function registerModel(uint256 modelId, string calldata name, uint256 price) external;

    /// @notice Replace an existing model's parameters in-place.
    /// @dev Only callable by `DEFAULT_ADMIN_ROLE`. Updates the model's name and price while preserving
    ///      its ID, so integrators who have hardcoded a model ID continue to work seamlessly when the
    ///      underlying LLM is upgraded (e.g., swapping gpt-4 for gpt-5 under the same ID).
    ///      Existing PENDING requests for this model are unaffected and can still be fulfilled or refunded.
    ///      Emits {FlapAIProviderModelReplaced}.
    /// @param modelId ID of the model to replace (must be registered).
    /// @param name    New human-readable name for the model (e.g., "gpt-5").
    /// @param price   New per-request fee in BNB (wei). May be 0 for free models.
    function replaceModel(uint256 modelId, string calldata name, uint256 price) external;

    /// @notice Withdraw stuck BNB (undelivered fees or refunds) to a specified recipient.
    /// @dev Only callable by `DEFAULT_ADMIN_ROLE`. Emits {FlapAIProviderFeesWithdrawn}.
    /// @param recipient Address to receive the withdrawn BNB (must be non-zero).
    /// @param amount    Amount of BNB to withdraw (in wei).
    function withdrawStuckFee(address payable recipient, uint256 amount) external;

    /// @notice Configure rate limiting for a specific consumer.
    /// @dev Only callable by `DEFAULT_ADMIN_ROLE`. Emits {FlapAIProviderRateLimitConfigured}.
    ///      When rate limiting is enabled, consumers must wait at least `cooldown` seconds
    ///      between requests or the `reason()` call will revert with `FlapAIProviderRateLimitExceeded`.
    /// @param consumer The consumer address to configure (must be non-zero).
    /// @param enabled  Whether to enable rate limiting for this consumer.
    /// @param cooldown Minimum seconds between requests (ignored if enabled=false).
    function setConsumerRateLimit(address consumer, bool enabled, uint32 cooldown) external;

    /// @notice Returns the rate limit configuration for a consumer.
    /// @param consumer The consumer address to query.
    /// @return enabled Whether rate limiting is active for this consumer.
    /// @return lastRequestTime Timestamp of the consumer's last request (0 if never requested).
    /// @return cooldown Minimum seconds between requests.
    function getConsumerRateLimit(address consumer)
        external
        view
        returns (bool enabled, uint64 lastRequestTime, uint32 cooldown);

    // ----------------------------------------------------------------
    //  Explorer View Functions
    // ----------------------------------------------------------------

    /// @notice Returns the total number of reasoning requests ever submitted.
    /// @dev Equivalent to `_nextRequestId - 1`. Used by the explorer to compute pagination metadata.
    /// @return total The total request count.
    function getTotalRequests() external view returns (uint256 total);

    /// @notice Returns the total number of reasoning requests submitted by a specific consumer.
    /// @dev Used to compute per-consumer pagination metadata.
    /// @param consumer The consumer address to query.
    /// @return total The number of requests made by `consumer`.
    function getTotalRequestsByConsumer(address consumer) external view returns (uint256 total);

    /// @notice Returns a single `RequestView` for the given request ID.
    /// @dev Populates `reasoningCid` for all statuses (non-empty only when FULFILLED or UNDELIVERED).
    ///      Returns a zero-valued struct if `requestId` was never created.
    /// @param requestId The request ID to look up.
    /// @return view_    The populated `RequestView` for the given request.
    function getRequest(uint256 requestId) external view returns (RequestView memory view_);

    /// @notice Returns up to `limit` requests in newest-first order, starting at `offset` from the end.
    /// @dev `offset = 0, limit = 10` returns the 10 most recent requests.
    ///      Returns an empty array if `offset >= getTotalRequests()`.
    ///      Clamps the result to available entries — never reverts out-of-bounds.
    ///      `reasoningCid` is populated inline for each entry.
    /// @param offset Zero-based offset from the most recent request (0 = most recent).
    /// @param limit  Maximum number of entries to return.
    /// @return views Array of `RequestView` in newest-first order.
    function getRecentRequests(uint256 offset, uint256 limit) external view returns (RequestView[] memory views);

    /// @notice Returns up to `limit` requests by a specific consumer in newest-first order.
    /// @dev Same pagination semantics as `getRecentRequests` but scoped to a single consumer.
    ///      Returns an empty array if `offset >= getTotalRequestsByConsumer(consumer)`.
    /// @param consumer The consumer address to filter by.
    /// @param offset   Zero-based offset from the consumer's most recent request.
    /// @param limit    Maximum number of entries to return.
    /// @return views   Array of `RequestView` in newest-first order for the given consumer.
    function getRequestsByConsumer(address consumer, uint256 offset, uint256 limit)
        external
        view
        returns (RequestView[] memory views);
}

// ============================================================
//                FlapAIConsumerBase Abstract Contract
// ============================================================

/// @title FlapAIConsumerBase
/// @notice Base contract for contracts consuming FlapAIProvider responses.
/// @dev Inheritors must override:
///        - `_fulfillReasoning(uint256 requestId, uint8 choice)`: executes the action chosen by the LLM.
///        - `_onFlapAIRequestRefunded(uint256 requestId)`: handles refund cleanup or retry logic.
///        - `lastRequestId()`: returns the consumer's most recent pending request ID (0 if none).
///      The `onlyFlapAIProvider` modifier is applied automatically to the external entry-points
///      `fulfillReasoning` and `onFlapAIRequestRefunded`, ensuring that only the FlapAIProvider
///      contract can invoke them. The provider address is resolved at runtime via
///      `_getFlapAIProvider()` using `block.chainid`, so no constructor parameter is needed.
abstract contract FlapAIConsumerBase {
    // ----------------------------------------------------------------
    //  Custom Errors
    // ----------------------------------------------------------------

    /// @notice Reverts when a function guarded by `onlyFlapAIProvider` is called by a non-provider address.
    error FlapAIConsumerOnlyProvider();

    /// @notice Reverts when `_getFlapAIProvider()` is queried on an unsupported chain.
    /// @param chainId The unsupported chain ID.
    error FlapAIConsumerUnsupportedChain(uint256 chainId);

    // ----------------------------------------------------------------
    //  Modifier
    // ----------------------------------------------------------------

    /// @dev Guards external entry-points so only the FlapAIProvider contract can call them.
    ///      Reverts with `FlapAIConsumerOnlyProvider` if called by any other address.
    modifier onlyFlapAIProvider() {
        if (msg.sender != _getFlapAIProvider()) revert FlapAIConsumerOnlyProvider();
        _;
    }

    // ----------------------------------------------------------------
    //  Provider Address Resolution
    // ----------------------------------------------------------------

    /// @notice Returns the FlapAIProvider proxy address for the current chain.
    /// @dev Uses `block.chainid` to resolve the stable proxy address:
    ///        - Chain 56  (BSC Mainnet): returns `address(0)` — placeholder, update when deployed.
    ///        - Chain 97  (BSC Testnet): returns `address(0)` — placeholder, update when deployed.
    ///        - Any other chain: reverts with `FlapAIConsumerUnsupportedChain`.
    ///      Subclasses may override this function to support additional chains or test environments.
    /// @return The address of the FlapAIProvider proxy on the current chain.
    function _getFlapAIProvider() internal view virtual returns (address) {
        uint256 id = block.chainid;
        if (id == 56) {
            return 0xaEe3a7Ca6fe6b53f6c32a3e8407eC5A9dF8B7E39;
        } else if (id == 97) {
            return 0xFfddcE44e8cFf7703Fd85118524bfC8B2f70b744;
        } else {
            revert FlapAIConsumerUnsupportedChain(id);
        }
    }

    // ----------------------------------------------------------------
    //  Consumer State (abstract)
    // ----------------------------------------------------------------

    /// @notice Returns the request ID of the most recent AI reasoning request made by this consumer.
    /// @dev Must be overridden by the consuming contract. Returns `0` if no request has been made yet.
    ///      This allows the provider backend and frontends to look up the consumer's outstanding request
    ///      without iterating through the provider's full request history.
    /// @return The last submitted request ID, or 0 if none.
    function lastRequestId() public view virtual returns (uint256);

    // ----------------------------------------------------------------
    //  External Entry-Points (access-controlled)
    // ----------------------------------------------------------------

    /// @notice Called by the FlapAIProvider to deliver the LLM's chosen action.
    /// @dev Only callable by the FlapAIProvider contract (enforced by `onlyFlapAIProvider`).
    ///      Delegates to the internal virtual `_fulfillReasoning` for override-able logic.
    ///      This external/internal split prevents inheritors from inadvertently removing the
    ///      access control check while still overriding the business logic.
    /// @param requestId The ID of the fulfilled request.
    /// @param choice    The LLM's chosen action (index in 0..numOfChoices-1).
    function fulfillReasoning(uint256 requestId, uint8 choice) external onlyFlapAIProvider {
        _fulfillReasoning(requestId, choice);
    }

    /// @notice Called by the FlapAIProvider when a request is refunded.
    /// @dev Only callable by the FlapAIProvider contract (enforced by `onlyFlapAIProvider`).
    ///      Delegates to the internal virtual `_onFlapAIRequestRefunded`.
    ///      The provider calls this with `{value: feePaid}` so the BNB refund is delivered here
    ///      rather than via a bare ETH transfer (which would trigger `receive()`/`fallback()`).
    ///      The provider also applies an explicit gas cap to prevent unbounded gas consumption.
    /// @param requestId The ID of the refunded request.
    function onFlapAIRequestRefunded(uint256 requestId) external payable onlyFlapAIProvider {
        _onFlapAIRequestRefunded(requestId);
    }

    // ----------------------------------------------------------------
    //  Internal Virtual Hooks (to be overridden)
    // ----------------------------------------------------------------

    /// @notice Internal hook invoked when the FlapAIProvider delivers the LLM's choice.
    /// @dev Must be overridden by the consuming contract to execute the action corresponding to `choice`.
    ///      The consumer contract is responsible for mapping each `choice` index to its intended action,
    ///      consistent with the meanings encoded in the original prompt.
    /// @param requestId The ID of the fulfilled request.
    /// @param choice    The LLM's chosen action index.
    function _fulfillReasoning(uint256 requestId, uint8 choice) internal virtual;

    /// @notice Internal hook invoked when the FlapAIProvider refunds a request.
    /// @dev Must be overridden by the consuming contract to perform cleanup or retry logic
    ///      (e.g., reset a pending-action flag, re-enable a paused operation).
    ///      `msg.value` equals the original `feePaid` — the BNB refund is delivered with this call.
    /// @param requestId The ID of the refunded request.
    function _onFlapAIRequestRefunded(uint256 requestId) internal virtual;
}

