# Gas and Fees

> Source: <https://docs.robinhood.com/chain/gas-and-fees>
> Retrieved: 2026-08-12 (Tavily extract, advanced depth)

---

# Gas & Fees

Robinhood Chain uses ETH as its native gas token. Transaction fees are denominated in ETH, the same as on Ethereum.

Because Robinhood Chain is a Layer-2 that posts its data to Ethereum, a transaction fee has two components:

* **L2 execution fee** — the cost of executing your transaction on Robinhood Chain. This works like Ethereum gas (gas used × L2 gas price) and is typically very low and stable.
* **L1 data fee** — the cost of posting your transaction's data to Ethereum for data availability. This varies with Ethereum network congestion and is proportional to the size of your transaction's calldata.

## How fees are charged

Both components are bundled into the gas your transaction pays — you don't pay them separately. Standard fee estimation (`eth_estimateGas`, wallet fee previews) automatically accounts for both, so most developers don't need to handle them manually.

## Optimizing fees

Because the L1 data fee scales with calldata size, the most effective way to reduce fees is to minimize transaction calldata:

* Pack function arguments tightly.
* Avoid unnecessary data in calls.
* Batch operations where possible (see [Account Abstraction](/chain/account-abstraction) for batched UserOperations).

## Further reading

* [Differences from Ethereum](/chain/differences-from-ethereum)
* [Connecting to Robinhood Chain](/chain/connecting) — ETH as the native gas token
* [Protocol Contracts](/chain/protocol-contracts) — ArbGasInfo and NodeInterface precompiles
* [Arbitrum: gas and fees](https://docs.arbitrum.io/how-arbitrum-works/gas-fees)
