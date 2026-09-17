<!-- source: https://developers.uniswap.org/docs/get-started/concepts/glossary | captured: 2026-08-22 | via: https://developers.uniswap.org/docs/get-started/concepts/glossary.md (native markdown) -->
# Glossary (/docs/get-started/concepts/glossary)

Common terms for the Uniswap protocol, its AMM design, permissionless architecture, and protocol versions.

## Core Protocol Concepts
* An **automated market maker (AMM)** is a smart contract on Ethereum that holds liquidity reserves. Users can trade against these reserves at prices determined by a fixed formula. Anyone may contribute liquidity to these smart contracts, earning pro-rata trading fees in return.

* The **Uniswap protocol** is a set of immutable onchain smart contracts that implement AMM-based trading and liquidity across protocol versions.

* The **constant product formula** is the AMM model used in early Uniswap versions. In v1 and v2, it is commonly written as `x * y = k`, where **k** is the invariant.

* A **pool** is a contract deployed by the v4 factory that pairs two ERC-20 assets. Different pools may have different fees despite containing the same token pair. Pools were previously called Pairs before the introduction of multiple fee options.

* **Liquidity** is the token capital stored in a Uniswap pool contract that traders can swap against.

* A **liquidity provider (LP)** is someone who deposits ERC-20 tokens into a liquidity pool. Liquidity providers take on price risk and are compensated with trading fees.

* **Concentrated liquidity** is liquidity allocated to a specific price range.

* A **position** is an instance of liquidity defined by lower and upper ticks and the liquidity amount assigned to that range.

* A **swap** is the act of exchanging one token for another through a liquidity pool.

* **Swap fees** are fees collected during swaps and distributed to liquidity providers according to pool rules.

* **Protocol fees** are fees directed to the protocol itself rather than to liquidity providers.

* **Price impact** is the difference between the mid-price and the execution price **caused by your trade size relative to the pool’s liquidity**. This is an expected result of the constant product formula in AMMs.

* **Slippage** is the total difference between the expected price at the time of submitting a transaction and the actual execution price, which may include price impact and other market movements that occur before the transaction is mined.

* **Impermanent loss** is the opportunity cost experienced by liquidity providers when token prices change relative to simply holding the tokens.

* **Tick** is a boundary between discrete price points.

* **Tick interval** is the price space between the two nearest active ticks.

* **Range** is any interval between two ticks.

* **Range order** approximates a limit order by providing a single asset as liquidity across a specified range and converting exposure as spot price crosses that range.

* **Reserves** refer to liquidity balances in a pool context, especially in constant-product models.

## Smart Contract Architecture
* [**Core Contracts**](https://github.com/Uniswap/v4-core) are foundational protocol contracts that implement pool state transitions and settlement logic. A new core deployment corresponds to a new protocol version.

* [**Periphery Contracts**](https://github.com/Uniswap/v4-periphery) are external smart contracts that simplify interactions with the protocol (e.g., routers and position managers).

* [**Universal Router**](https://github.com/Uniswap/universal-router) is a routing contract that enables complex, multi-step token operations across different Uniswap systems in a single transaction.

* **Factory** is a smart contract that initializes pool instances for token pairs according to version-specific rules.

## Uniswap v4 Concepts
* **Singleton Architecture** is a design introduced in v4 where all pools are managed within a single contract, reducing deployment costs and enabling advanced composability.

* **PoolManager** is the central contract in v4 responsible for managing all pools within the singleton architecture.

* **Hooks** are customizable smart contracts that execute logic before or after pool actions such as swaps or liquidity modifications.

* **Flash accounting** is a v4 settlement mechanism that allows temporary token imbalances during execution, provided balances net to zero by transaction end. This is distinct from a **flash swap**.

## Token Standards
* **ERC-20** is a standard for fungible tokens on Ethereum. Uniswap integrates broadly with standard ERC-20 implementations.

* **ERC-721** is a standard for non-fungible tokens. In v3, positions are represented as ERC-721 NFTs; in v4, position flows are managed through `PositionManager` and can be represented with token IDs in periphery workflows.

* **ERC-6909** is a multi-token standard used in v4 to represent internal claims within the singleton architecture.

## Trading Infrastructure
* **flash swap** is a v2 pattern where tokens are received before repayment, provided borrowed tokens are returned in the same transaction. This is distinct from v4 **flash accounting**.

* **Routing** in API responses is the execution mechanism for a quote, described by the `routing` field (for example `CLASSIC`, `DUTCH_V2`, `DUTCH_V3`, or `PRIORITY`).

## Ecosystem Terms
* **Unichain** is an EVM-compatible chain designed to support high-performance DeFi applications and Uniswap-native infrastructure.

* **UNI token** is the governance token that enables participation in Uniswap governance decisions.

## API Terms
These terms are used throughout the Uniswap API docs:

* **Uniswap protocols** in API context refer to pool-based routing across Uniswap v2, Uniswap v3, and Uniswap v4 liquidity (v1 is not supported by the API).

* **Classic** in API routing terminology means a pool-based route through Uniswap protocol liquidity (v2/v3/v4), not UniswapX RFQ routing.

* **UniswapX** refers to the intent-based RFQ swap mechanism. UniswapX has two versions: **UniswapX\_V2** and **UniswapX\_V3**. In API responses, the `routing` field will return **DUTCH\_V2** or **DUTCH\_V3** (respectively) for UniswapX quotes. These are also known as **DutchQuoteV2** and **DutchQuoteV3** in some API payloads and tooling. Additionally, on Base and Unichain chains, the `routing` field may return **PRIORITY** for UniswapX\_V2 quotes, which can also be referred to as **PriorityQuote**.

* **Permit2** is a smart contract that simplifies sharing and managing token approvals. [All Uniswap workflows utilize Permit2](/docs/trading/swapping-api/concepts/permit2), with Uniswap protocols using AllowanceTransfer and UniswapX using SignatureTransfer. In short, users sign Permit2 messages that allow the Permit2 contract to spend tokens from the user's wallet. Permit2 messages can include permissions that limit spending to one transaction, a specific time window, or a specific token amount.
