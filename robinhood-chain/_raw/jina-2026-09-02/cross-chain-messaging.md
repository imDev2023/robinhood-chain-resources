Title: Cross-Chain Messaging

URL Source: https://docs.robinhood.com/chain/cross-chain-messaging

Markdown Content:
[Skip to content](https://docs.robinhood.com/chain/cross-chain-messaging#vocs-content)

[![Image 1: Logo](https://cdn.robinhood.com/assets/generated_assets/hoodchain_docsite/feather-light.svg)![Image 2: Logo](https://cdn.robinhood.com/assets/generated_assets/hoodchain_docsite/feather-dark.svg)](https://docs.robinhood.com/chain)

Get Started

[About Robinhood Chain](https://docs.robinhood.com/chain)[Connecting to Robinhood Chain](https://docs.robinhood.com/chain/connecting)[Add network to your wallet](https://docs.robinhood.com/chain/add-network-to-wallet)[Bridging](https://docs.robinhood.com/chain/bridging)

Stock Tokens

[Overview](https://docs.robinhood.com/chain/stock-tokens)[Building with Stock Tokens](https://docs.robinhood.com/chain/building-with-stock-tokens)[Stock Token APIs](https://docs.robinhood.com/chain/stock-token-apis)

Core Concepts

[Differences from Ethereum](https://docs.robinhood.com/chain/differences-from-ethereum)[Gas & Fees](https://docs.robinhood.com/chain/gas-and-fees)[Transaction Finality](https://docs.robinhood.com/chain/transaction-finality)

[Token Contracts](https://docs.robinhood.com/chain/contracts)[Protocol Contracts](https://docs.robinhood.com/chain/protocol-contracts)

Build

[Deploy a Contract](https://docs.robinhood.com/chain/deploy-smart-contracts)[Account Abstraction](https://docs.robinhood.com/chain/account-abstraction)[Cross-Chain Messaging](https://docs.robinhood.com/chain/cross-chain-messaging)[Oracles & Price Feeds](https://docs.robinhood.com/chain/oracles-and-price-feeds)[Data Streams](https://docs.robinhood.com/chain/data-streams)

[Run a full node](https://docs.robinhood.com/chain/run-a-full-node)[Governance](https://docs.robinhood.com/chain/governance)

Brand Guidelines

[Overview](https://docs.robinhood.com/chain/brand-guidelines)

Notices & Upgrades

[Overview](https://docs.robinhood.com/chain/notices-and-upgrades)

[Report an issue](https://docs.robinhood.com/chain/report-issue)[Terms of Service](https://docs.robinhood.com/chain/terms-of-service)

Search...

[![Image 3: Logo](https://cdn.robinhood.com/assets/generated_assets/hoodchain_docsite/feather-light.svg)![Image 4: Logo](https://cdn.robinhood.com/assets/generated_assets/hoodchain_docsite/feather-dark.svg)](https://docs.robinhood.com/chain)

[![Image 5: Logo](https://cdn.robinhood.com/assets/generated_assets/hoodchain_docsite/feather-light.svg)![Image 6: Logo](https://cdn.robinhood.com/assets/generated_assets/hoodchain_docsite/feather-dark.svg)](https://docs.robinhood.com/chain)

Menu

Cross-Chain Messaging

On this page

[Ask in ChatGPT](https://chatgpt.com/?hints=search&q=Please%20research%20and%20analyze%20this%20page%3A%20https%3A%2F%2Fdocs.robinhood.com%2Fchain%2Fcross-chain-messaging%20so%20I%20can%20ask%20you%20questions%20about%20it.%20Once%20you%20have%20read%20it%2C%20prompt%20me%20with%20any%20questions%20I%20have.%20Do%20not%20post%20content%20from%20the%20page%20in%20your%20response.%20Any%20of%20my%20follow%20up%20questions%20must%20reference%20the%20site%20I%20gave%20you.)

## On this page

*   [Key contracts](https://docs.robinhood.com/chain/cross-chain-messaging#key-contracts)
*   [Register Robinhood Chain with the Arbitrum SDK](https://docs.robinhood.com/chain/cross-chain-messaging#register-robinhood-chain-with-the-arbitrum-sdk)
*   [L1 → L2 messaging (retryable tickets)](https://docs.robinhood.com/chain/cross-chain-messaging#l1--l2-messaging-retryable-tickets)
*   [L2 → L1 messaging](https://docs.robinhood.com/chain/cross-chain-messaging#l2--l1-messaging)

    *   [1. Initiate the message (on Robinhood Chain)](https://docs.robinhood.com/chain/cross-chain-messaging#1-initiate-the-message-on-robinhood-chain)
    *   [2. Execute the message (on Ethereum)](https://docs.robinhood.com/chain/cross-chain-messaging#2-execute-the-message-on-ethereum)

*   [Further reading](https://docs.robinhood.com/chain/cross-chain-messaging#further-reading)

# Cross-Chain Messaging[](https://docs.robinhood.com/chain/cross-chain-messaging#cross-chain-messaging)

Robinhood Chain supports arbitrary message passing between Ethereum (L1) and Robinhood Chain (L2). This is the lower-level primitive beneath [Bridging](https://docs.robinhood.com/chain/bridging) — where bridging moves assets, cross-chain messaging passes arbitrary calls and data, letting you call an L2 contract from Ethereum or trigger an L1 action from L2.

Messaging works in two directions:

*   L1 → L2 via retryable tickets, submitted through the Delayed Inbox. Typically completes in minutes.
*   L2 → L1 via the ArbSys precompile. Subject to the 7-day challenge period before it can be executed on Ethereum.

Robinhood Chain is an Arbitrum Chain, so messaging uses the standard Arbitrum Nitro mechanisms. We recommend the Arbitrum SDK (`@arbitrum/sdk`) rather than encoding messages by hand.

## Key contracts[](https://docs.robinhood.com/chain/cross-chain-messaging#key-contracts)

| Contract | Layer | Address |
| --- | --- | --- |
| Delayed Inbox | Ethereum (L1) | **`0x1A07cc4BD17E0118BdB54D70990D2158AbAD7a2D`** |
| Bridge | Ethereum (L1) | **`0xDf8755334ce7A73cCF6b581C02eA649AE3E864b3`** |
| Outbox | Ethereum (L1) | **`0xf0ce991ea4A0d2400A4AB49b20ae333f6Dce3DE9`** |
| Rollup | Ethereum (L1) | **`0x23A19d23e89166adedbDcB432518AB01e4272D94`** |
| ArbSys | Robinhood Chain (L2) | **`0x0000000000000000000000000000000000000064`** |

## Register Robinhood Chain with the Arbitrum SDK[](https://docs.robinhood.com/chain/cross-chain-messaging#register-robinhood-chain-with-the-arbitrum-sdk)

Because Robinhood Chain is a custom Arbitrum chain, register it once before using the SDK:

```
import { registerCustomArbitrumNetwork } from "@arbitrum/sdk";
 
registerCustomArbitrumNetwork({
  name: "Robinhood Chain",
  chainId: 4663,
  parentChainId: 1, // Ethereum mainnet
  confirmPeriodBlocks: 45818,
  ethBridge: {
    bridge: "0xDf8755334ce7A73cCF6b581C02eA649AE3E864b3",
    inbox: "0x1A07cc4BD17E0118BdB54D70990D2158AbAD7a2D",
    sequencerInbox: "0xBd0D173EEb87D57A09521c24388a12789F33ba96",
    outbox: "0xf0ce991ea4A0d2400A4AB49b20ae333f6Dce3DE9",
    rollup: "0x23A19d23e89166adedbDcB432518AB01e4272D94",
  },
});
```

## L1 → L2 messaging (retryable tickets)[](https://docs.robinhood.com/chain/cross-chain-messaging#l1--l2-messaging-retryable-tickets)

To send a message from Ethereum to a contract on Robinhood Chain, create a retryable ticket through the Delayed Inbox. The Arbitrum SDK handles gas estimation and submission:

```
import { ParentToChildMessageCreator } from "@arbitrum/sdk";
 
const messageCreator = new ParentToChildMessageCreator(parentSigner); // an Ethereum signer
 
const tx = await messageCreator.createRetryableTicket(
  {
    to: "0x...",        // target contract on Robinhood Chain
    data: "0x...",      // calldata
    l2CallValue: 0n,
    from: await parentSigner.getAddress(),
  },
  childProvider          // a Robinhood Chain provider
);
 
await tx.wait();
```

If the L2 execution fails (for example, due to insufficient gas), the ticket is not lost — it can be redeemed manually within 7 days.

Address aliasing: When an L1 contract calls an L2 contract via a retryable ticket, the `msg.sender` seen on Robinhood Chain is not the original L1 address — it is the aliased address (the L1 address plus a fixed offset). Account for this in any access-control logic that checks the caller. Use the SDK's `applyAlias` / `undoAlias` helpers to convert between the two.

## L2 → L1 messaging[](https://docs.robinhood.com/chain/cross-chain-messaging#l2--l1-messaging)

Sending a message from Robinhood Chain to Ethereum is a two-step process: initiate on L2, then execute on L1 after the challenge period.

### 1. Initiate the message (on Robinhood Chain)[](https://docs.robinhood.com/chain/cross-chain-messaging#1-initiate-the-message-on-robinhood-chain)

Interact with the ArbSys precompile via the SDK to trigger the L2 transaction. This method removes the necessity for custom wrapper contracts:

```
import { ArbSys__factory } from "@arbitrum/sdk";
 
const arbSys = ArbSys__factory.connect(
  "0x0000000000000000000000000000000000000064",
  childSigner            // a Robinhood Chain signer
);
 
const tx = await arbSys.sendTxToL1(
  destinationL1Address,   // target contract on Ethereum
  data,                   // calldata
  { value: 0n }
);
const receipt = await tx.wait();
```

If one of your own contracts needs to trigger an L2→L1 message, it can call `ArbSys(0x…64).sendTxToL1(...)` directly. For sending a standalone message, the SDK call above is enough.

### 2. Execute the message (on Ethereum)[](https://docs.robinhood.com/chain/cross-chain-messaging#2-execute-the-message-on-ethereum)

Once the 7-day challenge period concludes, final execution occurs on L1 by claiming the message through the Outbox. The SDK simplifies this workflow:

```
import { ChildTransactionReceipt } from "@arbitrum/sdk";
 
const childReceipt = new ChildTransactionReceipt(receipt);
const [message] = await childReceipt.getChildToParentMessages(parentSigner);
 
// This promise resolves only after the challenge window expires
await message.waitUntilReadyToExecute(childProvider);
await message.execute(parentSigner);
```

## Further reading[](https://docs.robinhood.com/chain/cross-chain-messaging#further-reading)

*   [Arbitrum SDK](https://docs.arbitrum.io/sdk)
*   [Arbitrum cross-chain messaging docs](https://docs.arbitrum.io/how-arbitrum-works/l1-to-l2-messaging)
*   [Bridging](https://docs.robinhood.com/chain/bridging) — for moving assets rather than messages

[Account Abstraction Previous shift←](https://docs.robinhood.com/chain/account-abstraction)[Oracles & Price Feeds Next shift→](https://docs.robinhood.com/chain/oracles-and-price-feeds)

Your Privacy Choices![Image 7](https://cdn.robinhood.com/assets/generated_assets/hoodchain_docsite/privacy-options.svg)
