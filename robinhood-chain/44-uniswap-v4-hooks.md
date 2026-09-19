# Uniswap v4 hooks on Robinhood Chain

> Original writing. Verified 2026-09-19 at L2 block 66,716,100 against the public RPC and Alchemy `robinhood-mainnet`.
> Complements `12-differences-from-ethereum.md`, which lists the Nitro semantics generally; this page covers only what reaches **hook** code.
> Pool and liquidity data is in `45-v4-pools-and-liquidity.md`.

## v4 is deployed and is the dominant venue

Every address below was confirmed to hold code by direct `eth_getCode` on 2026-09-19, not read from a table.

| Contract | Address | Code |
| --- | --- | --- |
| PoolManager | `0x8366a39cc670b4001a1121b8f6a443a643e40951` | 24,009 bytes, verified, tagged `PoolManager` |
| PositionManager | `0x58daec3116aae6d93017baaea7749052e8a04fa7` | 23,877 bytes |
| Universal Router | `0x8876789976decbfcbbbe364623c63652db8c0904` | 24,546 bytes |
| Permit2 | `0x000000000022D473030F116dDEE9F6B43aC78BA3` | 9,152 bytes |
| CREATE2 deployer | `0x4e59b44847b379578588920cA78FbF26c0B4956C` | 69 bytes |

PoolManager's first transaction was 2026-06-03.
As of 2026-09-19 the chain carries 123 v4 pools against 49 v3 pools, so v4 is the primary venue rather than a new arrival.

Two entries deserve comment.

The **CREATE2 deployer** is the canonical Arachnid factory.
v4 encodes a hook's permissions in the low 14 bits of its address, so deploying a hook means mining a salt through this factory.
Without it, hooks cannot be deployed at all. It is also what deployed the PoolManager here.

**EIP-1153 transient storage is available.**
No Robinhood doc states this, but v4's flash accounting is built on transient storage and the PoolManager is demonstrably transacting, so support is implied by a working deployment.
Foundry projects targeting this chain need `evm_version = "cancun"`.

## `block.number` is the trap

Nitro returns an estimate of the **L1** block number from Solidity's `block.number`.
`12-differences-from-ethereum.md` records this generally; the measured magnitude is what matters for hooks.

Measured 2026-09-19 across three windows, comparing the L2 header `number` against `l1BlockNumber`:

| Window | L2 blocks | `block.number` advanced | L2 blocks per tick |
| --- | ---: | ---: | ---: |
| 100 s | 1,000 | 8 | 125.0 |
| 1,210 s | 12,000 | 100 | 120.0 |
| 12,078 s | 120,000 | 1,001 | 119.9 |

L2 block time is 0.10 s and `block.number` ticks roughly once per 12 s.
**About 120 consecutive L2 blocks share one `block.number`.**
At the sampled block, L2 height was 66,716,100 while `block.number` read 26,008,494.

Real L2 height comes from `ArbSys(0x64).arbBlockNumber()`.

### Two widely used hooks are affected

OpenZeppelin's `uniswap-hooks` library is the base every current hook inherits from, and two of its ready-made hooks key state on `block.number`:

- `src/general/AntiSandwichHook.sol:131`
- `src/general/LiquidityPenaltyHook.sol:186`

Neither is wrong. Both assume a chain where `block.number` is the block height.

`LiquidityPenaltyHook` penalises liquidity added and removed within a configured block offset, to deter just-in-time liquidity.
Here an offset of 1 spans about 12 seconds and 120 L2 blocks, so the parameter means something entirely different and ordinary liquidity management inside a 12-second window is treated as JIT.

`AntiSandwichHook` checkpoints pool state at the start of each block and prices against that snapshot.
Here the snapshot persists across roughly 120 L2 blocks of real trading.
Whether that ends up more or less protective has not been analysed and should not be assumed either way.

Both expose the accessor as `internal view virtual` precisely so it can be replaced:

```solidity
interface IArbSys {
    function arbBlockNumber() external view returns (uint256);
}

function _getBlockNumber() internal view override returns (uint48) {
    return uint48(IArbSys(address(0x64)).arbBlockNumber());
}
```

Treat any hook reading `block.number` on this chain as needing the override until shown otherwise, and assert it in a fork test.

## Stock tokens are elastic supply

Robinhood Stock Tokens carry an ERC-8056 `uiMultiplier()` that rises as corporate actions land.
Between 2026-09-03 and 2026-09-19, 18 of the 194 multipliers moved (see `45-v4-pools-and-liquidity.md`).

For hook authors this is the classic rebasing-token hazard.
Uniswap's own security framework lists rebasing and elastic-supply tokens as a token-type hazard that breaks accounting assumptions.
A hook that holds one of these tokens, caches a balance across callbacks, or derives an amount from a stored balance must account for the multiplier moving underneath it.

The dominant quote asset is **USDG**, the Paxos Global Dollar, not a wrapped native token.

## Other Nitro semantics that reach hook code

| Behaviour | Here | Consequence for a hook |
| --- | --- | --- |
| `block.prevrandao`, `block.difficulty` | constant | No randomness. Never derive a fee, ordering or selection from it. |
| `blockhash(n)` | reliable only for recent blocks | Not a randomness source. |
| `block.coinbase` | network fee account | Not a validator or builder address. |
| `gasleft()`, gas estimation | fees carry an L1 data component | Never hardcode gas in a callback. |
| Max contract size | 96 KB code, 192 KB init | A hook too large for Ethereum can deploy here. 24 KB is not the ceiling. |
| Transaction ordering | first-come, first-served at the sequencer | Fee bumping does not reprioritise, so the mempool-reordering assumption behind classic sandwich attacks does not hold in its usual form. Revisit the threat model before assuming an anti-sandwich hook is needed or that it behaves as designed. |
| L1 data fee scales with calldata | yes | Keep `hookData` small; it is calldata the user pays for. |

`block.timestamp` advances normally at 0.1 s block time, so deadline checks such as `BaseCustomAccounting.sol:111` behave.
A deadline measured in blocks would not.

## Tooling notes

Alchemy is first-class for this chain as `robinhood-mainnet`, confirmed 2026-09-19 returning chain id `0x1237`.
Free-tier `eth_getLogs` is still capped at a 10 block range, which matters because finding the hook attached to a pool means reading `Initialize` events from the PoolManager.
Use `alchemy_getAssetTransfers`, the Blockscout PRO API at `api.blockscout.com/4663`, or a Goldsky subgraph for any real scan.

The public RPC `https://rpc.mainnet.chain.robinhood.com` returns **403** to clients without a browser `User-Agent`.
`curl` works; Python `urllib` with its default agent does not.

Contract verification through the public Blockscout instance hits the Cloudflare challenge documented in `32-explorer-and-data-apis.md`, which is what breaks `forge verify-contract`.
Point Foundry's `[etherscan]` block at `https://api.blockscout.com/4663/api` instead.
