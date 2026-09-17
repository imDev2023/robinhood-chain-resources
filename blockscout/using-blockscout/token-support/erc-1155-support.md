> ## Documentation Index
> Fetch the complete documentation index at: https://docs.blockscout.com/llms.txt
> Use this file to discover all available pages before exploring further.

# ERC-1155 Support: Multi-Token Indexing

> How Blockscout recognizes ERC-1155 contracts and indexes fungible and non-fungible balances, parses batched transfers, and tracks minting events.

[ERC-1155](https://eips.ethereum.org/EIPS/eip-1155) contracts are designed to support multiple token types within a single contract. This standard is being adopted rapidly for efficiency and optimization, and is being used to bundle multi-token transactions and approvals while supporting both fungible and non-fungible tokens.

Recognition and labelling for ERC-1155 contracts, indexing instance balances for both fts and nfts, parsing single and batched transactions, and monitoring and displaying minting events are included.

## GnosisChain Example

ERC-1155s are supported for the Gnosis Chain and any new ERC-1155 instances are recognized on deployment. For ERC-1155 contracts created prior to the enhanced support, a new single or batched transfer, mint, or token instance creation triggers contract recognition.

[https://gnosis.blockscout.com/token/0x93d0c9a35c43f6BC999416A06aaDF21E68B29EBA?tab=token\_transfers](https://gnosis.blockscout.com/token/0x93d0c9a35c43f6BC999416A06aaDF21E68B29EBA?tab=token_transfers)

<img src="https://mintcdn.com/blockscout/GHvuDaE4gRKuNH6O/images/unique-1.png?fit=max&auto=format&n=GHvuDaE4gRKuNH6O&q=85&s=65e402af5ceb3ce2639e3418a60aea48" alt="Unique One ERC1155" width="2406" height="1654" data-path="images/unique-1.png" />
