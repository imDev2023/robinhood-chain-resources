Title: Transaction Finality

URL Source: https://docs.robinhood.com/chain/transaction-finality

Markdown Content:
[Skip to content](https://docs.robinhood.com/chain/transaction-finality#vocs-content)

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

Transaction Finality

On this page

[Ask in ChatGPT](https://chatgpt.com/?hints=search&q=Please%20research%20and%20analyze%20this%20page%3A%20https%3A%2F%2Fdocs.robinhood.com%2Fchain%2Ftransaction-finality%20so%20I%20can%20ask%20you%20questions%20about%20it.%20Once%20you%20have%20read%20it%2C%20prompt%20me%20with%20any%20questions%20I%20have.%20Do%20not%20post%20content%20from%20the%20page%20in%20your%20response.%20Any%20of%20my%20follow%20up%20questions%20must%20reference%20the%20site%20I%20gave%20you.)

## On this page

*   [Stages of finality](https://docs.robinhood.com/chain/transaction-finality#stages-of-finality)
*   [Choosing a confirmation level](https://docs.robinhood.com/chain/transaction-finality#choosing-a-confirmation-level)
*   [Withdrawals to Ethereum](https://docs.robinhood.com/chain/transaction-finality#withdrawals-to-ethereum)
*   [Reorganizations](https://docs.robinhood.com/chain/transaction-finality#reorganizations)
*   [Further reading](https://docs.robinhood.com/chain/transaction-finality#further-reading)

# Transaction Finality[](https://docs.robinhood.com/chain/transaction-finality#transaction-finality)

Robinhood Chain transactions reach finality in stages. Understanding them helps you choose the right confirmation level for your application — fast soft confirmations for everyday UX, full Ethereum finality for high-value operations.

## Stages of finality[](https://docs.robinhood.com/chain/transaction-finality#stages-of-finality)

| Stage | What happens | Typical latency | Guarantee |
| --- | --- | --- | --- |
| Soft confirmation | The sequencer accepts, orders, and executes your transaction and returns a receipt. | Sub-second | The sequencer has committed to your transaction's inclusion and ordering. Reversible only if the sequencer posts a batch with a different transaction order. |
| Posted to Ethereum | The sequencer batches transactions and posts the batch to the Ethereum (L1) Inbox. | Minutes | Ordering is now fixed — your transaction can only be reorganized if Ethereum itself reorganizes. |
| Ethereum finality | The L1 block containing the batch reaches finality on Ethereum. | ~13 minutes after posting | Full finality — your transaction inherits Ethereum's security and is irreversible. |

## Choosing a confirmation level[](https://docs.robinhood.com/chain/transaction-finality#choosing-a-confirmation-level)

*   Everyday UX (most apps): the soft confirmation from the sequencer is fast and reliable — sufficient for typical interactions.
*   High-value or irreversible actions: wait until the transaction is posted to Ethereum, or for full Ethereum finality, before treating it as settled.

## Withdrawals to Ethereum[](https://docs.robinhood.com/chain/transaction-finality#withdrawals-to-ethereum)

Finality is distinct from the withdrawal delay. Moving assets from Robinhood Chain back to Ethereum via the canonical bridge is subject to a 7-day challenge period — a requirement of Arbitrum's fraud-proof system, separate from transaction finality. See [Bridging](https://docs.robinhood.com/chain/bridging) for details.

## Reorganizations[](https://docs.robinhood.com/chain/transaction-finality#reorganizations)

Once a transaction is posted to Ethereum, it cannot be reorganized unless Ethereum itself reorganizes. Before posting, soft-confirmed transactions rely on the sequencer for the order it returned — in normal operation this is reliable, but it is not yet backed by Ethereum's security.

## Further reading[](https://docs.robinhood.com/chain/transaction-finality#further-reading)

*   [Differences from Ethereum](https://docs.robinhood.com/chain/differences-from-ethereum)
*   [Bridging](https://docs.robinhood.com/chain/bridging) — the 7-day withdrawal challenge period
*   [Arbitrum: transaction lifecycle](https://docs.arbitrum.io/how-arbitrum-works/transaction-lifecycle)

[Gas & Fees Previous shift←](https://docs.robinhood.com/chain/gas-and-fees)[Token Contracts Next shift→](https://docs.robinhood.com/chain/contracts)

Your Privacy Choices![Image 7](https://cdn.robinhood.com/assets/generated_assets/hoodchain_docsite/privacy-options.svg)
