Title: Run a Robinhood Chain full node

URL Source: https://docs.robinhood.com/chain/run-a-full-node

Markdown Content:
[Skip to content](https://docs.robinhood.com/chain/run-a-full-node#vocs-content)

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

Run a full node

On this page

[Ask in ChatGPT](https://chatgpt.com/?hints=search&q=Please%20research%20and%20analyze%20this%20page%3A%20https%3A%2F%2Fdocs.robinhood.com%2Fchain%2Frun-a-full-node%20so%20I%20can%20ask%20you%20questions%20about%20it.%20Once%20you%20have%20read%20it%2C%20prompt%20me%20with%20any%20questions%20I%20have.%20Do%20not%20post%20content%20from%20the%20page%20in%20your%20response.%20Any%20of%20my%20follow%20up%20questions%20must%20reference%20the%20site%20I%20gave%20you.)

## On this page

*   [Hardware requirements](https://docs.robinhood.com/chain/run-a-full-node#hardware-requirements)
*   [Prerequisites](https://docs.robinhood.com/chain/run-a-full-node#prerequisites)
*   [RPC Providers](https://docs.robinhood.com/chain/run-a-full-node#rpc-providers)
*   [Running the node](https://docs.robinhood.com/chain/run-a-full-node#running-the-node)

    *   [Mainnet](https://docs.robinhood.com/chain/run-a-full-node#mainnet)
    *   [Testnet](https://docs.robinhood.com/chain/run-a-full-node#testnet)

*   [Running a validator](https://docs.robinhood.com/chain/run-a-full-node#running-a-validator)
*   [Syncing](https://docs.robinhood.com/chain/run-a-full-node#syncing)
*   [Database Snapshots](https://docs.robinhood.com/chain/run-a-full-node#database-snapshots)
*   [Node configuration](https://docs.robinhood.com/chain/run-a-full-node#node-configuration)
*   [Troubleshooting](https://docs.robinhood.com/chain/run-a-full-node#troubleshooting)

    *   [General checks](https://docs.robinhood.com/chain/run-a-full-node#general-checks)
    *   [Syncing issues](https://docs.robinhood.com/chain/run-a-full-node#syncing-issues)
    *   [Connectivity issues](https://docs.robinhood.com/chain/run-a-full-node#connectivity-issues)

*   [Support](https://docs.robinhood.com/chain/run-a-full-node#support)

# Run a Robinhood Chain full node[](https://docs.robinhood.com/chain/run-a-full-node#run-a-robinhood-chain-full-node)

Robinhood Chain is an Arbitrum Chain running Arbitrum Nitro. This guide walks through deploying and syncing your own full node.

Running a node is time consuming, resource intensive, and potentially costly. If you don't already know why you need your own node, you probably don't.

If you just need an RPC endpoint, use the public endpoints or a provider:

*   Public Mainnet: `https://rpc.mainnet.chain.robinhood.com`
*   Alchemy: `https://robinhood-mainnet.g.alchemy.com/v2/{API_KEY}`

Download the config files for your target network:

*   **Mainnet:** chain info [robinhood-chain-info.json](https://cdn.robinhood.com/assets/generated_assets/hoodchain_docsite/chain-node-configs/robinhood-chain-info.json) and genesis [robinhood-genesis.json](https://cdn.robinhood.com/assets/generated_assets/hoodchain_docsite/chain-node-configs/robinhood-genesis.json)
*   **Testnet:** chain info [robinhood-chain-testnet-info.json](https://cdn.robinhood.com/assets/generated_assets/hoodchain_docsite/chain-node-configs/robinhood-chain-testnet-info.json)

Testnet does not use a custom genesis file, so its start command omits the `--init.genesis-json-file` flag.

## Hardware requirements[](https://docs.robinhood.com/chain/run-a-full-node#hardware-requirements)

| Component | Requirement |
| --- | --- |
| CPU | Modern multi-core (8+) CPU with strong single-core performance |
| RAM | 64 GB RAM (128 GB recommended) |
| Storage | Locally attached NVMe SSD; (2 × current chain size) + 20% buffer. Several TBs of data |
| Node Type | Full node (Archive nodes require substantially more disk capacity) |

## Prerequisites[](https://docs.robinhood.com/chain/run-a-full-node#prerequisites)

Because Robinhood Chain posts its data to Ethereum, your node needs access to an Ethereum (L1) endpoint — your own or via a provider.

You need both:

*   An L1 execution RPC endpoint
*   An L1 beacon (consensus) endpoint — required to read blob data

If you run your own L1 node, it must be fully synced before Robinhood Chain can finish syncing.

You'll also need Docker installed and running.

## RPC Providers[](https://docs.robinhood.com/chain/run-a-full-node#rpc-providers)

In addition to running your own full node, you can connect to Robinhood Chain via a managed RPC provider. The following providers support Robinhood Chain:

| Provider | Link |
| --- | --- |
| Quicknode | [https://www.quicknode.com/chains/robinhood](https://www.quicknode.com/chains/robinhood) |
| Blockdaemon | [https://docs.blockdaemon.com/docs/how-to-connect-to-robinhood](https://docs.blockdaemon.com/docs/how-to-connect-to-robinhood) |
| dRPC | [https://drpc.org/chainlist/robinhood-testnet-rpc](https://drpc.org/chainlist/robinhood-testnet-rpc) |
| Validation Cloud | [https://www.validationcloud.io/robinhood](https://www.validationcloud.io/robinhood) |
| Chainstack | [https://chainstack.com/build-better-with-robinhood-chain/](https://chainstack.com/build-better-with-robinhood-chain/) |
| GlobalStake | [https://GlobalStake.io](https://globalstake.io/) |

## Running the node[](https://docs.robinhood.com/chain/run-a-full-node#running-the-node)

Start the node with Docker, supplying your L1 endpoints and the Robinhood Chain config. The commands differ by network: Mainnet initializes from a custom genesis file, while Testnet does not.

Place the config files you downloaded above into a local directory (e.g. `$HOME/rh/config`) and mount it into the container at `/home/nitro/config`, which the commands reference. Mount your data directory to `/home/nitro/.arbitrum` — the `nitro-node` image runs as the `nitro` user, so mounting elsewhere leaves the node unable to persist chain data. Substitute your own L1 endpoints for `parent-chain.connection.url` and `parent-chain.blob-client.beacon-url`.

### Mainnet[](https://docs.robinhood.com/chain/run-a-full-node#mainnet)

```
DATA_DIR="$HOME/rh/robinhood-nitro-data"
docker run --rm -it \
    -v "$DATA_DIR":/home/nitro/.arbitrum \
    -v "$HOME/rh/config":/home/nitro/config \
    -p 8547:8547 -p 8548:8548 \
    offchainlabs/nitro-node:v3.11.2-3599aca \
      --chain.info-files=/home/nitro/config/robinhood-chain-info.json \
      --parent-chain.connection.url=... \
      --parent-chain.blob-client.beacon-url=... \
      --init.genesis-json-file=/home/nitro/config/robinhood-genesis.json \
      --http.addr=0.0.0.0 --http.port=8547 \
      --http.api=net,web3,eth
```

To subscribe to the sequencer feed for low-latency updates, add `--node.feed.input.url=wss://feed.mainnet.chain.robinhood.com`. The feed URL must be `wss://`, not `https://`.

### Testnet[](https://docs.robinhood.com/chain/run-a-full-node#testnet)

Testnet has no custom genesis, so its start command omits the `--init.genesis-json-file` flag.

```
DATA_DIR="$HOME/rh/robinhood-nitro-data"
docker run --rm -it \
    -v "$DATA_DIR":/home/nitro/.arbitrum \
    -v "$HOME/rh/config":/home/nitro/config \
    -p 8547:8547 -p 8548:8548 \
    offchainlabs/nitro-node:v3.11.2-3599aca \
      --chain.info-files=/home/nitro/config/robinhood-chain-testnet-info.json \
      --parent-chain.connection.url=... \
      --parent-chain.blob-client.beacon-url=... \
      --http.addr=0.0.0.0 --http.port=8547 \
      --http.api=net,web3,eth
```

For the testnet sequencer feed, add `--node.feed.input.url=wss://feed.testnet.chain.robinhood.com`.

Once running, confirm the node responds:

```
curl -d '{"id":0,"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["latest",false]}' \
  -H "Content-Type: application/json" http://localhost:8547
```

Initial sync can take a long time and will consume significant L1 request quota — monitor your L1 provider usage.

## Running a validator[](https://docs.robinhood.com/chain/run-a-full-node#running-a-validator)

Robinhood Chain utilizes BoLD for dispute resolution through a permissioned set of validators. Operating a validator necessitates being included in the allowlist and staking a 1 WETH bond (defensive validators are highly encouraged).

## Syncing[](https://docs.robinhood.com/chain/run-a-full-node#syncing)

Check sync progress with `eth_syncing`. A fully synced node returns `false`:

```
curl -d '{"id":0,"jsonrpc":"2.0","method":"eth_syncing","params":[]}' \
  -H "Content-Type: application/json" http://localhost:8547
```

You can also watch the node logs for block production messages.

If you try to send transactions before the node is fully synced, you may see `nonce has already been used` — wait for sync to complete.

## Database Snapshots[](https://docs.robinhood.com/chain/run-a-full-node#database-snapshots)

Database snapshots let you sync a new node faster by starting from a recent state instead of from genesis. Browse available snapshots:

*   Robinhood Chain (Mainnet): [https://snapshot-explorer.arbitrum.io/?chain=Robinhood+Chain](https://snapshot-explorer.arbitrum.io/?chain=Robinhood+Chain)
*   Robinhood Chain Testnet: [https://snapshot-explorer.arbitrum.io/?chain=Robinhood+Chain+Sepolia](https://snapshot-explorer.arbitrum.io/?chain=Robinhood+Chain+Sepolia)

To restore from a snapshot, pass its URL to the node with `--init.url=<snapshot-url>` on first start (see [Running the node](https://docs.robinhood.com/chain/run-a-full-node#running-the-node)). Snapshots currently published are pruned full-node snapshots; archive nodes must sync from scratch. For how the snapshot system works, see the [Arbitrum Nitro database snapshots documentation](https://docs.arbitrum.io/run-arbitrum-node/nitro/nitro-database-snapshots).

## Node configuration[](https://docs.robinhood.com/chain/run-a-full-node#node-configuration)

Robinhood Chain requires the chain info file provided by Robinhood, passed to the node via `--chain.info-files` (see Running the node). On Mainnet, also pass the custom genesis configuration via `--init.genesis-json-file`; Testnet does not use a custom genesis.

Robinhood Chain runs ArbOS 61. Confirm the current Nitro/ArbOS version before starting. On ArbOS upgrades, un-upgraded nodes stop cleanly and resume after updating — with no data loss.

## Troubleshooting[](https://docs.robinhood.com/chain/run-a-full-node#troubleshooting)

### General checks[](https://docs.robinhood.com/chain/run-a-full-node#general-checks)

*   View logs via `docker logs -f <container>` to identify errors.
*   Confirm the container status is healthy and not in a restart loop.
*   Verify network connectivity to L1 execution and beacon endpoints from the host.
*   Confirm your L1 node is fully synced; an unsynced L1 will stall L2 syncing.

### Syncing issues[](https://docs.robinhood.com/chain/run-a-full-node#syncing-issues)

*   Check the L1 connection and beacon URL; most failures are due to unreachable beacon endpoints.
*   Ensure the server clock is accurate using `ntp` or `chrony`.

Sync is slow:

*   Verify disk I/O performance; networked storage will significantly throttle sync speed.

### Connectivity issues[](https://docs.robinhood.com/chain/run-a-full-node#connectivity-issues)

*   Verify container ports (8547 for HTTP, 8548 for WS) are correctly mapped and open.
*   Ensure `--http.addr=0.0.0.0` is set to allow external RPC access.

## Support[](https://docs.robinhood.com/chain/run-a-full-node#support)

[Robinhood Chain Support](mailto:chain-developers-group@robinhood.com)

[Data Streams Previous shift←](https://docs.robinhood.com/chain/data-streams)[Governance Next shift→](https://docs.robinhood.com/chain/governance)

Your Privacy Choices![Image 7](https://cdn.robinhood.com/assets/generated_assets/hoodchain_docsite/privacy-options.svg)
