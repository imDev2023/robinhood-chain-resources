Title: Differences from Ethereum

URL Source: https://docs.robinhood.com/chain/differences-from-ethereum

Markdown Content:
[Skip to content](https://docs.robinhood.com/chain/differences-from-ethereum#vocs-content)

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

Differences from Ethereum

On this page

[Ask in ChatGPT](https://chatgpt.com/?hints=search&q=Please%20research%20and%20analyze%20this%20page%3A%20https%3A%2F%2Fdocs.robinhood.com%2Fchain%2Fdifferences-from-ethereum%20so%20I%20can%20ask%20you%20questions%20about%20it.%20Once%20you%20have%20read%20it%2C%20prompt%20me%20with%20any%20questions%20I%20have.%20Do%20not%20post%20content%20from%20the%20page%20in%20your%20response.%20Any%20of%20my%20follow%20up%20questions%20must%20reference%20the%20site%20I%20gave%20you.)

## On this page

*   [Block numbers](https://docs.robinhood.com/chain/differences-from-ethereum#block-numbers)
*   [Randomness](https://docs.robinhood.com/chain/differences-from-ethereum#randomness)
*   [Block hashes](https://docs.robinhood.com/chain/differences-from-ethereum#block-hashes)
*   [block.coinbase](https://docs.robinhood.com/chain/differences-from-ethereum#blockcoinbase)
*   [Gas & fees](https://docs.robinhood.com/chain/differences-from-ethereum#gas--fees)
*   [Address aliasing](https://docs.robinhood.com/chain/differences-from-ethereum#address-aliasing)
*   [Contract size limit](https://docs.robinhood.com/chain/differences-from-ethereum#contract-size-limit)
*   [Arbitrum precompiles](https://docs.robinhood.com/chain/differences-from-ethereum#arbitrum-precompiles)
*   [Transaction finality](https://docs.robinhood.com/chain/differences-from-ethereum#transaction-finality)
*   [Transaction screening](https://docs.robinhood.com/chain/differences-from-ethereum#transaction-screening)
*   [Transaction ordering](https://docs.robinhood.com/chain/differences-from-ethereum#transaction-ordering)
*   [Further reading](https://docs.robinhood.com/chain/differences-from-ethereum#further-reading)

# Differences from Ethereum[](https://docs.robinhood.com/chain/differences-from-ethereum#differences-from-ethereum)

Robinhood Chain is EVM-compatible — contracts written in Solidity or Vyper deploy without modification, and standard tooling works out of the box. However, as an Arbitrum Nitro Layer-2, a few behaviors differ from Ethereum mainnet. Understanding these prevents subtle bugs.

## Block numbers[](https://docs.robinhood.com/chain/differences-from-ethereum#block-numbers)

`block.number` returns an estimate of the L1 (Ethereum) block number, not the Robinhood Chain block number, and updates only periodically. Do not use it to measure L2 time precisely or as a per-block counter.

To get the actual Robinhood Chain block number, use the **ArbSys** precompile:

`uint256 l2Block = ArbSys(0x0000000000000000000000000000000000000064).arbBlockNumber();`

## Randomness[](https://docs.robinhood.com/chain/differences-from-ethereum#randomness)

`block.prevrandao` / `block.difficulty` return a constant value on Robinhood Chain and are not a source of randomness. Never use them for randomness — use a dedicated oracle (e.g. Chainlink VRF) instead.

## Block hashes[](https://docs.robinhood.com/chain/differences-from-ethereum#block-hashes)

`blockhash(n)` is supported but is only reliable for recent blocks. Do not rely on it for older blocks or as a randomness source.

## block.coinbase[](https://docs.robinhood.com/chain/differences-from-ethereum#blockcoinbase)

`block.coinbase` returns the network fee account, not a miner/validator address.

## Gas & fees[](https://docs.robinhood.com/chain/differences-from-ethereum#gas--fees)

Transaction fees have two components: L2 execution gas plus an L1 data (calldata) fee for posting the transaction to Ethereum. Gas estimation and `gasleft()` behave differently than on Ethereum as a result. Query gas pricing via the ArbGasInfo precompile. See [Gas & Fees](https://docs.robinhood.com/chain/gas-and-fees) for details.

## Address aliasing[](https://docs.robinhood.com/chain/differences-from-ethereum#address-aliasing)

When an L1 contract sends a message to a contract on Robinhood Chain, the `msg.sender` seen on L2 is the aliased L1 address (the original address plus a fixed offset), not the original. Account for this in access-control logic. See [Cross-Chain Messaging](https://docs.robinhood.com/chain/cross-chain-messaging).

## Contract size limit[](https://docs.robinhood.com/chain/differences-from-ethereum#contract-size-limit)

Robinhood Chain allows larger contracts than Ethereum — a maximum code size of 96 KB (vs. Ethereum's 24 KB) and a max init code size of 192 KB. Contracts that exceed Ethereum's limit can deploy here.

## Arbitrum precompiles[](https://docs.robinhood.com/chain/differences-from-ethereum#arbitrum-precompiles)

Robinhood Chain provides Arbitrum-specific precompiles (ArbSys, ArbGasInfo, ArbAddressTable, and others) for L2-specific functionality. See the [Protocol Contracts](https://docs.robinhood.com/chain/protocol-contracts) page for the full list and addresses.

## Transaction finality[](https://docs.robinhood.com/chain/differences-from-ethereum#transaction-finality)

Transactions receive a fast soft confirmation from the sequencer, then achieve hard finality once posted to and confirmed on Ethereum. See [Transaction Finality](https://docs.robinhood.com/chain/transaction-finality) for the full model.

## Transaction screening[](https://docs.robinhood.com/chain/differences-from-ethereum#transaction-screening)

Robinhood Chain maintains compliance standards through sequencer-level screening. While rare, this mechanism can influence smart-contract execution; for instance, any transaction associated with a sanctioned address will be excluded from inclusion. Standard read operations—such as `eth_call`, `eth_getLogs`, or balance queries—remain fully accessible and unaffected. Since a blocked transfer is never processed, it simply appears as though the event never occurred, ensuring indexers remain synchronized with the actual state.

Read more here: [Advanced Compliance Filtering](https://docs.arbitrum.io/launch-arbitrum-chain/configure-your-chain/advanced/compliance-filtering)

## Transaction ordering[](https://docs.robinhood.com/chain/differences-from-ethereum#transaction-ordering)

On Ethereum, miners or validators order transactions based on priority fees, where higher payments typically secure earlier inclusion. Robinhood Chain employs a **first-come, first-served** model based on sequencer arrival time. Priority gas auctions do not exist here; consequently, increasing your fee will not shift your transaction ahead of others already in the queue.

## Further reading[](https://docs.robinhood.com/chain/differences-from-ethereum#further-reading)

*   [Gas & Fees](https://docs.robinhood.com/chain/gas-and-fees)
*   [Transaction Finality](https://docs.robinhood.com/chain/transaction-finality)
*   [Cross-Chain Messaging](https://docs.robinhood.com/chain/cross-chain-messaging)
*   [Arbitrum: Solidity differences](https://docs.arbitrum.io/build-decentralized-apps/arbitrum-vs-ethereum/solidity-support)

[Stock Token APIs Previous shift←](https://docs.robinhood.com/chain/stock-token-apis)[Gas & Fees Next shift→](https://docs.robinhood.com/chain/gas-and-fees)

Your Privacy Choices![Image 7](https://cdn.robinhood.com/assets/generated_assets/hoodchain_docsite/privacy-options.svg)
