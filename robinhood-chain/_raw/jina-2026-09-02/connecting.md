Title: Connecting to Robinhood Chain

URL Source: https://docs.robinhood.com/chain/connecting

Published Time: Tue, 20 Jan 2026 13:48:38 GMT

Markdown Content:
[Skip to content](https://docs.robinhood.com/chain/connecting#vocs-content)

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

Connecting to Robinhood Chain

On this page

# Connecting to Robinhood Chain[](https://docs.robinhood.com/chain/connecting#connecting-to-robinhood-chain)

Robinhood Chain is an Arbitrum Layer-2 Chain built on Ethereum, using Ethereum blobs for data availability and ETH as the native gas token. Developers can add the network to their wallet using the configuration details below.

## Network Configuration[](https://docs.robinhood.com/chain/connecting#network-configuration)

| Property | Robinhood Chain | Robinhood Chain Testnet |
| --- | --- | --- |
| Chain ID | 4663 | 46630 |
| Currency Symbol | ETH | ETH |
| Block Explorer | [robinhoodchain.blockscout.com](https://robinhoodchain.blockscout.com/) | [explorer.testnet.chain.robinhood.com](https://explorer.testnet.chain.robinhood.com/) |

## Developer Endpoints[](https://docs.robinhood.com/chain/connecting#developer-endpoints)

Alchemy is the recommended infrastructure provider for building on Robinhood Chain. [Sign up for a free Alchemy account](https://dashboard.alchemy.com/) and create an app on Robinhood Chain to get your API key.

| Endpoint | Mainnet URL | Testnet URL |
| --- | --- | --- |
| RPC | `https://robinhood-mainnet.g.alchemy.com/v2/{API_KEY}` | `https://robinhood-testnet.g.alchemy.com/v2/{API_KEY}` |
| Websocket | `wss://robinhood-mainnet.g.alchemy.com/v2/{API_KEY}` | `wss://robinhood-testnet.g.alchemy.com/v2/{API_KEY}` |

For historical reads and indexing, use an archive endpoint — available through providers such as Alchemy.

### Other Providers[](https://docs.robinhood.com/chain/connecting#other-providers)

Robinhood Chain is also supported by QuickNode, Blockdaemon, dRPC, and Validation Cloud. Sign up directly with your provider to get an endpoint.

QuickNode endpoints follow: `https://{ENDPOINT}.robinhood-mainnet.quiknode.pro/{TOKEN}`

## Supported Services[](https://docs.robinhood.com/chain/connecting#supported-services)

| Service | Description |
| --- | --- |
| Node API | Access standard JSON-RPC and Websocket endpoints for reading and writing to Robinhood Chain. |
| Data API | Instant, reliable access to indexed blockchain data like token balances, transaction history, NFTs, and portfolio activity |
| Gasless Transaction Infrastructure | Create and manage programmable wallets with built-in support for gas sponsorship, batched transactions, flexible policies, and spending controls. |

For more details on each service, visit the [Alchemy documentation](https://www.alchemy.com/docs/reference/robinhood-chain-api-quickstart).

## Public Endpoints[](https://docs.robinhood.com/chain/connecting#public-endpoints)

The following public endpoints are available but are rate-limited and not recommended for production use. For production, use a provider (see above).

| Endpoint | Mainnet URL | Testnet URL |
| --- | --- | --- |
| RPC | `https://rpc.mainnet.chain.robinhood.com` | `https://rpc.testnet.chain.robinhood.com` |
| Sequencer Feed | `wss://feed.mainnet.chain.robinhood.com` | `wss://feed.testnet.chain.robinhood.com` |
| Sequencer | `https://sequencer.mainnet.chain.robinhood.com` | `https://sequencer.testnet.chain.robinhood.com` |

## Bridge to Robinhood Chain[](https://docs.robinhood.com/chain/connecting#bridge-to-robinhood-chain)

To move funds onto Robinhood Chain, use the canonical Arbitrum bridge or one of several cross-chain routes. See [Bridging](https://docs.robinhood.com/chain/bridging) for all options and supported assets.

## Connect a Wallet[](https://docs.robinhood.com/chain/connecting#connect-a-wallet)

To connect to Robinhood Chain via a wallet, follow the instructions [here](https://docs.robinhood.com/chain/add-network-to-wallet).

[About Robinhood Chain Previous shift←](https://docs.robinhood.com/chain)[Add network to your wallet Next shift→](https://docs.robinhood.com/chain/add-network-to-wallet)

Your Privacy Choices![Image 7](https://cdn.robinhood.com/assets/generated_assets/hoodchain_docsite/privacy-options.svg)
