Title: Gas & Fees

URL Source: https://docs.robinhood.com/chain/gas-and-fees

Markdown Content:
[Skip to content](https://docs.robinhood.com/chain/gas-and-fees#vocs-content)

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

Gas & Fees

On this page

[Ask in ChatGPT](https://chatgpt.com/?hints=search&q=Please%20research%20and%20analyze%20this%20page%3A%20https%3A%2F%2Fdocs.robinhood.com%2Fchain%2Fgas-and-fees%20so%20I%20can%20ask%20you%20questions%20about%20it.%20Once%20you%20have%20read%20it%2C%20prompt%20me%20with%20any%20questions%20I%20have.%20Do%20not%20post%20content%20from%20the%20page%20in%20your%20response.%20Any%20of%20my%20follow%20up%20questions%20must%20reference%20the%20site%20I%20gave%20you.)

## On this page

*   [How fees are charged](https://docs.robinhood.com/chain/gas-and-fees#how-fees-are-charged)
*   [Optimizing fees](https://docs.robinhood.com/chain/gas-and-fees#optimizing-fees)
*   [Further reading](https://docs.robinhood.com/chain/gas-and-fees#further-reading)

# Gas & Fees[](https://docs.robinhood.com/chain/gas-and-fees#gas--fees)

Robinhood Chain uses ETH as its native gas token. Transaction fees are denominated in ETH, the same as on Ethereum.

Because Robinhood Chain is a Layer-2 that posts its data to Ethereum, a transaction fee has two components:

*   **L2 execution fee** — the cost of executing your transaction on Robinhood Chain. This works like Ethereum gas (gas used × L2 gas price) and is typically very low and stable.
*   **L1 data fee** — the cost of posting your transaction's data to Ethereum for data availability. This varies with Ethereum network congestion and is proportional to the size of your transaction's calldata.

## How fees are charged[](https://docs.robinhood.com/chain/gas-and-fees#how-fees-are-charged)

Both components are bundled into the gas your transaction pays — you don't pay them separately. Standard fee estimation (`eth_estimateGas`, wallet fee previews) automatically accounts for both, so most developers don't need to handle them manually.

## Optimizing fees[](https://docs.robinhood.com/chain/gas-and-fees#optimizing-fees)

Because the L1 data fee scales with calldata size, the most effective way to reduce fees is to minimize transaction calldata:

*   Pack function arguments tightly.
*   Avoid unnecessary data in calls.
*   Batch operations where possible (see [Account Abstraction](https://docs.robinhood.com/chain/account-abstraction) for batched UserOperations).

## Further reading[](https://docs.robinhood.com/chain/gas-and-fees#further-reading)

*   [Differences from Ethereum](https://docs.robinhood.com/chain/differences-from-ethereum)
*   [Connecting to Robinhood Chain](https://docs.robinhood.com/chain/connecting) — ETH as the native gas token
*   [Protocol Contracts](https://docs.robinhood.com/chain/protocol-contracts) — ArbGasInfo and NodeInterface precompiles
*   [Arbitrum: gas and fees](https://docs.arbitrum.io/how-arbitrum-works/gas-fees)

[Differences from Ethereum Previous shift←](https://docs.robinhood.com/chain/differences-from-ethereum)[Transaction Finality Next shift→](https://docs.robinhood.com/chain/transaction-finality)

Your Privacy Choices![Image 7](https://cdn.robinhood.com/assets/generated_assets/hoodchain_docsite/privacy-options.svg)
