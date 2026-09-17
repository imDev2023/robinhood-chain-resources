> For the complete documentation index, see [llms.txt](https://docs.flap.sh/flap/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://docs.flap.sh/flap/developers/preview/flap-ai-oracle.md).

# Flap AI Oracle

## 1. Overview & Roadmap

### Overview

Three simple steps — build your prompt on-chain, let us handle the AI, and get back a verified decision.

**FlapAIProvider** is a standardized on-chain AI oracle plugin built for the Flap ecosystem. It gives Vault contracts (and any smart contract) access to verifiable LLM reasoning via a **commit-and-reveal** scheme inspired by Chainlink VRF.

FlapAIProvider separates concerns of AI-powered smart contracts cleanly:

* **On-chain (commit):** The consumer calls `reason()` with a prompt and pays a BNB fee. The contract records the request and emits an event.
* **Off-chain:** The oracle backend listens for the event, feeds the prompt to the selected LLM, and obtains a numeric choice.
* **On-chain (reveal):** The oracle calls `fulfillReasoning()` with the result and an IPFS CID linking to the full reasoning proof. The consumer's callback is invoked automatically.

Every request is permanently auditable: the IPFS CID stored on-chain pins the raw LLM inputs, outputs, temperature, model version, and salt that produced the decision.

### Architecture

![Flap AI Oracle](/files/bFKz6LZ5DRLhHJBCtmjA)

```mermaid
flowchart TD
    subgraph on-chain["🔗 On-Chain"]
        Vault(["🏦 Your Vault"])
        Provider(["⚙️ FlapAIProvider"])
    end

    subgraph off-chain["☁️ Off-Chain"]
        Oracle(["🤖 Oracle Backend"])
        LLM(["🧠 LLM Model"])
        Tools(["🔧 Tools\n(ave_token_tool, etc.)"])
        IPFS(["📦 IPFS\n(proof storage)"])
    end

    Vault -->|"① pay fee + send prompt"| Provider
    Provider -->|"② emit request event"| Oracle
    Oracle -->|"③ forward prompt"| LLM
    LLM -->|"④ request tool data"| Tools
    Tools -->|"⑤ return data"| LLM
    LLM -->|"⑥ return choice"| Oracle
    Oracle -->|"⑦ upload reasoning proof"| IPFS
    Oracle -->|"⑧ fulfill / refund"| Provider
    Provider -->|"⑨ callback with result\n— or — BNB refund"| Vault
```

### Roadmap

| Release          | Features                                                                                                                                                                                         |
| ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **v1 (current)** | Commit-and-reveal reasoning, multi-model registry, IPFS proof anchoring, refund fallback, `FlapAIConsumerBase` integration base, **tool calling** support (currently `ave_token_tool` available) |
| **v2 (next)**    | Additional tools, multi-step reasoning workflows, and enhanced oracle features                                                                                                                   |

> **Note:** The LLM can only return a single numeric choice in the range `[0, numOfChoices)`.

***

## 2. Deployed Addresses & Supported Models

### Deployed Addresses

| Network     | Chain ID | Address                                                                                                                        | AI Explorer                                        | Max Gas Limit |
| ----------- | -------- | ------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------- | ------------- |
| BSC Testnet | 97       | [`0xFfddcE44e8cFf7703Fd85118524bfC8B2f70b744`](https://testnet.bscscan.com/address/0xFfddcE44e8cFf7703Fd85118524bfC8B2f70b744) | [AI Scan BNB](https://flap.sh/ai/bnb-testnet/scan) | 2,000,000     |
| BNB Mainnet | 56       | [`0xaEe3a7Ca6fe6b53f6c32a3e8407eC5A9dF8B7E39`](https://bscscan.com/address/0xaEe3a7Ca6fe6b53f6c32a3e8407eC5A9dF8B7E39)         | [AI Scan BNB](https://flap.sh/ai/bnb/scan)         | 2,000,000     |

**Max Gas Limit:** The maximum gas limit supported for a `fulfillReasoning` callback.

{% hint style="warning" %}
**Testnet note:** Since AI inference is expensive, our testnet LLM backend operates with a limited budget. Fulfillment may not respond if funds are exhausted. If you'd like to test on testnet, feel free to reach out to us. Note that some tools may not be supported on testnet (e.g. `ave_token_tool`).
{% endhint %}

### Supported Models

The following models are available on both BSC Testnet and BNB Mainnet:

| Model ID | Name                          | Price per Request      |
| -------- | ----------------------------- | ---------------------- |
| `0`      | `google/gemini-3-flash`       | ~~0.01 BNB~~ 0.005 BNB |
| `1`      | `anthropic/claude-sonnet-4.6` | 0.05 BNB               |
| `2`      | `deepseek/deepseek-r1`        | 0.03 BNB               |
| `3`      | `deepseek/deepseek-v4-flash`  | 0.01 BNB               |

Query any model on-chain at any time:

```solidity
IFlapAIProvider.Model memory m = IFlapAIProvider(flapAIProvider).getModel(modelId);
// m.name, m.price, m.enabled
```

***

## 3. Tool Calling Support

FlapAIProvider supports **tool calling**, allowing the LLM to fetch real-time external data before making a decision. The oracle backend automatically executes tool calls embedded in your prompt and injects the results into the LLM context.

### Available Tools

Currently, the following tool is supported:

#### `ave_token_tool`

Fetches comprehensive market data for a Flap token, including:

* Current price and market cap
* Price change percentages
* Trading volume (24h, 7d)
* Holder count
* Liquidity status

**Usage example in prompt:**

```solidity
string memory prompt = string(abi.encodePacked(
    "I am managing a vault for token 0x1234...5678. ",
    "My main goal is to use my fund for market making. ",
    "Check the market data (use ave_token_tool) of this token and decide: ",
    "(0) buy tokens to support the floor, ",
    "(1) sell holdings to gain more funds for future market making, ",
    "(2) generate volumes only (buy and sell immediately)."
));
```

The oracle will automatically detect the tool request, fetch the token data, and provide it to the LLM before it makes a choice.

{% hint style="info" %}
**Need additional tools?** If you need specific data sources or APIs to implement your vault strategy, feel free to reach out to us. We're actively expanding the tool library based on community needs.
{% endhint %}

***

## 4. How to Integrate

### Step 1 — Extend `FlapAIConsumerBase`

Your contract must inherit `FlapAIConsumerBase` and implement three members:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {FlapAIConsumerBase, IFlapAIProvider} from "src/plugins/AIProvider/IFlapAIProvider.sol";

contract MyVault is FlapAIConsumerBase {
    // Track the outstanding request.
    uint256 private _lastRequestId;

    // Required: expose the pending request ID (0 = none).
    function lastRequestId() public view override returns (uint256) {
        return _lastRequestId;
    }

    // Required: handle the LLM's decision.
    // At most 1M gas is forwarded, so keep it efficient and avoid complex logic or external calls.
    function _fulfillReasoning(uint256 requestId, uint8 choice) internal override {
        require(requestId == _lastRequestId, "unknown request");
        _lastRequestId = 0;

        if (choice == 0) {
            _executeBuy();
        } else if (choice == 1) {
            _executeSell();
        } else {
            // noop
        }
    }

    // Required: handle a refund / failed request.
    function _onFlapAIRequestRefunded(uint256 requestId) internal override {
        require(requestId == _lastRequestId, "unknown request");
        _lastRequestId = 0;
        // Re-enable any paused operations or retry logic here.
    }
}
```

### Step 2 — Submit a Reasoning Request

The vault triggers `reason()` inside `receive()`. An internal `_shouldReason()` method encapsulates the go/no-go logic (balance threshold, cooldown, etc.) so the `receive()` body stays clean:

```solidity
receive() external payable {
    // Only one request at a time.
    if (_lastRequestId != 0) return;

    // Delegate the go/no-go decision to an internal helper.
    if (!_shouldReason()) return;

    uint256 MODEL_ID = 0; // google/gemini-3-flash
    uint8   NUM_CHOICES = 3;

    // Build a self-contained prompt that defines all choices.
    string memory prompt = string(abi.encodePacked(
        "You are a DeFi vault manager. The vault holds 10 BNB. ",
        "Current price is $300. 7-day trend is +15%. ",
        "Choose one action:\n",
        "0 = buy more BNB\n",
        "1 = sell all BNB\n",
        "2 = do nothing\n",
        "Respond with only the number of your choice."
    ));

    // Fetch the required fee from the registry.
    IFlapAIProvider provider = IFlapAIProvider(_getFlapAIProvider());
    uint256 fee = provider.getModel(MODEL_ID).price;

    _lastRequestId = provider.reason{value: fee}(MODEL_ID, prompt, NUM_CHOICES);
}

/// @dev Override to implement your go/no-go logic (e.g. balance threshold, cooldown).
function _shouldReason() internal view virtual returns (bool);
```

> **Cost note:** `reason()` does **not** refund excess `msg.value`. Overpayment becomes protocol revenue. Always pass exactly `model.price` (or query it on-chain first).

### Step 3 — Verify a Fulfilled Request

After the oracle calls back, the full reasoning proof is available on-chain forever:

```solidity
string memory cid = IFlapAIProvider(_getFlapAIProvider()).getReasoningCid(requestId);
// Fetch from IPFS: https://ipfs.io/ipfs/<cid>
```

### Step 4 — Override `_getFlapAIProvider()` for Testing

In tests or on unsupported chains, override the address resolver:

```solidity
function _getFlapAIProvider() internal view override returns (address) {
    return address(mockProvider); // your test double
}
```

### Full Example — Minimal Consumer

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {FlapAIConsumerBase, IFlapAIProvider} from "src/plugins/AIProvider/IFlapAIProvider.sol";
import {VaultBase} from "src/interfaces/VaultBase.sol";

/// @notice Minimal example consumer that lets an LLM decide between buy / sell / noop.
contract MinimalVault is VaultBase, FlapAIConsumerBase {
    uint256 public lastRequestId;
    uint8   public lastChoice;

    uint256 constant MODEL_ID    = 0;   // google/gemini-3-flash
    uint8   constant NUM_CHOICES = 3;
    uint256 constant THRESHOLD   = 1 ether; // only ask AI when vault holds > 1 BNB

    /// @notice Accept incoming tax revenue from the token.
    /// @dev Triggers AI reasoning when _shouldReason() approves.
    receive() external payable {
        // Only send one request at a time; skip if one is already pending.
        if (lastRequestId != 0) return;

        // Delegate the go/no-go decision to an internal helper.
        if (!_shouldReason()) return;

        IFlapAIProvider provider = IFlapAIProvider(_getFlapAIProvider());
        uint256 fee = provider.getModel(MODEL_ID).price;

        // Build a self-contained prompt that describes the vault state and
        // the meaning of every numbered choice.
        string memory prompt = string(abi.encodePacked(
            "You are a DeFi vault manager for a tax token on BNB Chain. ",
            "The vault currently holds ", _uint2str(address(this).balance / 1 ether), " BNB. ",
            "The threshold to act is 1 BNB. ",
            "Decide what to do with the accumulated BNB:\n",
            "0 = buyback tokens using all available BNB\n",
            "1 = hold and accumulate more BNB\n",
            "2 = distribute BNB to token holders\n",
            "Respond with only the number of your choice."
        ));

        lastRequestId = provider.reason{value: fee}(MODEL_ID, prompt, NUM_CHOICES);
    }

    /// @dev Override to implement your trigger logic (e.g. balance threshold, cooldown).
    function _shouldReason() internal view override returns (bool) {}

    function _fulfillReasoning(uint256 requestId, uint8 choice) internal override {
        require(requestId == lastRequestId);
        lastRequestId = 0;
        lastChoice = choice;

        if (choice == 0) {
            // TODO: execute buyback via _getPortal()
        } else if (choice == 1) {
            // hold — do nothing
        } else if (choice == 2) {
            // TODO: distribute BNB to token holders
        }
    }

    function _onFlapAIRequestRefunded(uint256 requestId) internal override {
        require(requestId == lastRequestId);
        lastRequestId = 0;
        // Next receive() call will retry automatically.
    }

    /// @inheritdoc VaultBase
    function description() public view override returns (string memory) {
        return string(abi.encodePacked(
            "Minimal AI vault. Balance: ", _uint2str(address(this).balance / 1 ether), " BNB. ",
            "Last choice: ", _uint2str(lastChoice), "."
        ));
    }

    // ----------------------------------------------------------------
    //  Internal helpers
    // ----------------------------------------------------------------

    function _uint2str(uint256 v) internal pure returns (string memory) {
        if (v == 0) return "0";
        uint256 tmp = v;
        uint256 digits;
        while (tmp != 0) { digits++; tmp /= 10; }
        bytes memory buf = new bytes(digits);
        while (v != 0) { buf[--digits] = bytes1(uint8(48 + v % 10)); v /= 10; }
        return string(buf);
    }
}
```

***

## 5. References

### `IFlapAIProvider.sol`

```solidity
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

    /// @notice Reverts when `reason()` is called with a registered but currently disabled model.
    /// @param modelId The disabled model ID.
    error FlapAIProviderModelNotEnabled(uint256 modelId);

    /// @notice Reverts when `setCallbackGasLimit()` is called with a value below the minimum of 1_000_000.
    /// @param provided The gas limit value that was passed.
    /// @param minimum  The minimum allowed gas limit (1_000_000).
    error FlapAIProviderCallbackGasLimitTooLow(uint256 provided, uint256 minimum);

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

    // ----------------------------------------------------------------
    //  Functions
    // ----------------------------------------------------------------

    /// @notice Submit an AI reasoning request to the oracle.
    /// @dev Validates that:
    ///        1. `modelId` is a registered model (reverts FlapAIProviderModelNotRegistered).
    ///        2. The model is enabled (reverts FlapAIProviderModelNotEnabled).
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
    ///      Does NOT revert for disabled models — callers can inspect the `enabled` field.
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

```
