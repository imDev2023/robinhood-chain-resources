Title: Bridging

URL Source: https://docs.robinhood.com/chain/bridging

Published Time: Tue, 20 Jan 2026 13:48:38 GMT

Markdown Content:
[Skip to content](https://docs.robinhood.com/chain/bridging#vocs-content)

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

Bridging

On this page

[Ask in ChatGPT](https://chatgpt.com/?hints=search&q=Please%20research%20and%20analyze%20this%20page%3A%20https%3A%2F%2Fdocs.robinhood.com%2Fchain%2Fbridging%20so%20I%20can%20ask%20you%20questions%20about%20it.%20Once%20you%20have%20read%20it%2C%20prompt%20me%20with%20any%20questions%20I%20have.%20Do%20not%20post%20content%20from%20the%20page%20in%20your%20response.%20Any%20of%20my%20follow%20up%20questions%20must%20reference%20the%20site%20I%20gave%20you.)

## On this page

*   [Canonical bridge](https://docs.robinhood.com/chain/bridging#canonical-bridge)

    *   [Depositing (Ethereum → Robinhood Chain)](https://docs.robinhood.com/chain/bridging#depositing-ethereum--robinhood-chain)
    *   [Withdrawing (Robinhood Chain → Ethereum)](https://docs.robinhood.com/chain/bridging#withdrawing-robinhood-chain--ethereum)
    *   [For developers](https://docs.robinhood.com/chain/bridging#for-developers)

    

# Bridging[](https://docs.robinhood.com/chain/bridging#bridging)

Robinhood Chain supports moving assets through its canonical bridge plus several cross-chain routes from partners. The canonical bridge is the trustless default for moving funds between Ethereum and Robinhood Chain; the additional routes offer faster transfers and broader network coverage.

| Route | Type | Speed | Best for |
| --- | --- | --- | --- |
| [Arbitrum canonical bridge](https://portal.arbitrum.io/bridge?destinationChain=robinhood-chain&sourceChain=ethereum) | Trustless L1↔L2 | Deposit ~10 min · Withdrawal ~7 days (challenge period) | Move ETH and ERC-20s between Ethereum and Robinhood Chain |
| LayerZero OFT / [Stargate](https://stargate.finance/) | Messaging + Omnichain token (OFT) transfer | Minutes (varies with source-chain finality) | Fast token movement across chains, moving WBTC, USDG, and other OFTs |
| Chainlink CCIP / [Transporter](https://app.transporter.io/?to=robinhood&tab=token) | Messaging + token transfer | Minutes (varies with source-chain finality) | Fast, secure cross-chain transfers and applications: move tokens & send messages (e.g. bridge SyrupUSDG and deposit it into a lending market) |
| [Relay](https://relay.link/bridge/robinhood) | Intents-based bridge | Seconds | Fast, low-cost transfers — and bridge-and-execute (trigger an action on the destination chain) in one step |
| [Across](https://across.to/?to=robinhood) | Intents-based bridge | Seconds | Fast, capital-efficient asset bridging across chains |
| [LiFi](https://li.fi/) / [0x](https://0x.org/) | Cross-chain swap aggregators | Seconds–minutes | Swap-and-bridge in one step |

## Canonical bridge[](https://docs.robinhood.com/chain/bridging#canonical-bridge)

The canonical bridge is the native bridge for Robinhood Chain. It is trustless and requires no third-party validators — security is inherited directly from Ethereum.

### Depositing (Ethereum → Robinhood Chain)[](https://docs.robinhood.com/chain/bridging#depositing-ethereum--robinhood-chain)

Deposits typically confirm within 10 minutes. To bridge ETH or ERC-20 tokens from Ethereum to Robinhood Chain, use the [Arbitrum canonical bridge](https://portal.arbitrum.io/bridge?destinationChain=robinhood-chain&sourceChain=ethereum)

**If a deposit doesn't arrive**
Deposits use Arbitrum's retryable ticket system. If the Robinhood Chain (L2) leg of a deposit fails — for example, due to insufficient gas — the funds are not lost. The deposit can be manually redeemed from the bridge interface within 7 days.

### Withdrawing (Robinhood Chain → Ethereum)[](https://docs.robinhood.com/chain/bridging#withdrawing-robinhood-chain--ethereum)

Withdrawing from Robinhood Chain is a three-step process:

1.   Initiate the withdrawal on Robinhood Chain (L2).
2.   Wait for the 7-day challenge period, a standard requirement of Arbitrum's fraud proof system.
3.   Claim your funds by submitting a transaction on Ethereum (L1). This final step is required and incurs L1 gas costs.

### For developers[](https://docs.robinhood.com/chain/bridging#for-developers)

To bridge programmatically, interact with the Delayed Inbox contract on Ethereum L1. Contract addresses are available on the [Protocol Contracts](https://docs.robinhood.com/chain/protocol-contracts) page.

Note that a bridged ERC-20's contract address on Robinhood Chain differs from its address on Ethereum. To resolve the corresponding L2 address, call `calculateL2TokenAddress` on the L2 Gateway Router, or refer to the [Protocol Contracts](https://docs.robinhood.com/chain/protocol-contracts) page.

[Add network to your wallet Previous shift←](https://docs.robinhood.com/chain/add-network-to-wallet)[Overview Next shift→](https://docs.robinhood.com/chain/stock-tokens)

Your Privacy Choices![Image 7](https://cdn.robinhood.com/assets/generated_assets/hoodchain_docsite/privacy-options.svg)
