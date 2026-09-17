# Bags - Read State & Discover Tokens

> Source: https://docs.bags.fm/robinhood/read-state
> Retrieved: 2026-09-02 (Mintlify markdown export, curl https://docs.bags.fm/robinhood/read-state.md)

---

# Read State & Discover Tokens

> Query Bags token state with BagsLens, discover tokens through the factory registry and TokenCreated events, derive pool IDs, and read post-migration prices.

In this guide, you'll read on-chain state for Bags tokens on Robinhood Chain: a single-call state snapshot via `BagsLens`, token discovery through the factory registry and events, pool ID derivation, and post-migration price reads. All of these are read-only — no wallet or gas required.

## Prerequisites

Before starting, make sure you have:

* Completed the [Environment Setup](/robinhood/setup) (`publicClient`, addresses, ABIs).
* Read the [Overview](/robinhood/overview) for the token lifecycle.

<Tip>
  The `publicClient` from Setup batches parallel `readContract` calls into single multicall3 requests. Prefer many small reads with `Promise.all` over hand-rolled multicall — batching handles it and keeps you under the public-RPC rate limit.
</Tip>

## 1. Read a Token's State with BagsLens

`BagsLens.getTokenState` returns everything you need about a token in one `eth_call`. It's the recommended entry point for any token view.

```typescript read-state.ts theme={null}
import { publicClient } from "./clients";
import { ROBINHOOD_LAUNCHPAD } from "./addresses";
import { bagsLensAbi } from "./abi";
import type { Address } from "viem";

export async function readTokenState(token: Address) {
  const state = await publicClient.readContract({
    address: ROBINHOOD_LAUNCHPAD.lens,
    abi: bagsLensAbi,
    functionName: "getTokenState",
    args: [token],
  });
  if (!state.exists) return null; // not a Bags token
  return state;
}
```

The returned `TokenState` struct:

| Field                  | Type      | Meaning                                                                                         |
| ---------------------- | --------- | ----------------------------------------------------------------------------------------------- |
| `exists`               | `bool`    | `false` ⇒ not a Bags token                                                                      |
| `migrated`             | `bool`    | `true` ⇒ graduated to a Uniswap v4 pool                                                         |
| `curve`                | `address` | The token's `BagsBondingCurve`                                                                  |
| `feeShare`             | `address` | The token's `BagsFeeShare`                                                                      |
| `poolId`               | `bytes32` | Uniswap v4 pool ID                                                                              |
| `thresholdQuote`       | `uint256` | ETH (wei) needed to graduate                                                                    |
| `realQuoteReserves`    | `uint256` | Real ETH reserves the curve holds right now (wei)                                               |
| `realTokenReserves`    | `uint256` | Tokens left on the curve                                                                        |
| `virtualTokenReserves` | `uint256` | Virtual token reserve (curve math)                                                              |
| `virtualQuoteReserves` | `uint256` | Virtual ETH reserve (curve math)                                                                |
| `priceQuotePerToken`   | `uint256` | Spot price, ETH wei per whole token                                                             |
| `bondingProgressPct`   | `uint256` | Graduation progress: `0`–`99` while bonding, reaching `100` only once `migrated` is `true`      |
| `totalRaised`          | `uint256` | Cumulative ETH raised into the curve over its lifetime, measured against `thresholdQuote` (wei) |

<Warning>
  `priceQuotePerToken` **freezes at migration** — it is only valid while `migrated` is `false`. For migrated tokens, read the live price from the pool (see section 5).
</Warning>

### Batch multiple tokens

For lists, use `getTokenStates` to fetch many tokens in one call:

```typescript theme={null}
const states = await publicClient.readContract({
  address: ROBINHOOD_LAUNCHPAD.lens,
  abi: bagsLensAbi,
  functionName: "getTokenStates",
  args: [tokens], // Address[]
});
```

## 2. Discover Tokens via the Factory Registry

`BagsFactory` maintains an append-only registry of every launch. Because it's append-only, the **tail** of the list is the newest launches.

```typescript list-tokens.ts theme={null}
import { publicClient } from "./clients";
import { ROBINHOOD_LAUNCHPAD } from "./addresses";
import { bagsFactoryAbi, bagsLensAbi } from "./abi";

/** The newest `limit` launches with live state, in one batched round-trip. */
export async function listNewestTokens(limit: number) {
  const total = Number(
    await publicClient.readContract({
      address: ROBINHOOD_LAUNCHPAD.factory,
      abi: bagsFactoryAbi,
      functionName: "allTokensLength",
    })
  );
  if (total === 0) return { items: [], total: 0 };

  const count = Math.min(limit, total);
  const offset = BigInt(total - count); // tail = newest

  const tokens = await publicClient.readContract({
    address: ROBINHOOD_LAUNCHPAD.factory,
    abi: bagsFactoryAbi,
    functionName: "getTokens",
    args: [offset, BigInt(count)],
  });

  const states = await publicClient.readContract({
    address: ROBINHOOD_LAUNCHPAD.lens,
    abi: bagsLensAbi,
    functionName: "getTokenStates",
    args: [tokens],
  });

  // Newest first.
  const items = tokens
    .map((token, i) => ({ token, state: states[i] }))
    .filter((row) => row.state.exists)
    .reverse();
  return { items, total };
}
```

Other registry lookups:

| Call                               | Returns                                                                      |
| ---------------------------------- | ---------------------------------------------------------------------------- |
| `factory.allTokensLength()`        | Total number of launches                                                     |
| `factory.getTokens(offset, limit)` | A page of token addresses                                                    |
| `factory.allTokens(index)`         | Token address at an index                                                    |
| `factory.curveForToken(token)`     | The token's bonding curve                                                    |
| `factory.feeShareForToken(token)`  | The token's fee-share contract                                               |
| `factory.tokenForPoolId(poolId)`   | The token for a given pool ID                                                |
| `factory.creationFee()`            | Current launch fee (wei)                                                     |
| `factory.graduationThreshold()`    | Default graduation threshold (wei) for future launches                       |
| `factory.partnerFeeBps()`          | Current partner share of the protocol fee half (bps), snapshotted per launch |

## 3. Read Immutable Token Info

Name, symbol, and metadata URI never change, so read them once and cache. Non-Bags ERC-20s revert on `metadataURI`, so treat that as absent.

```typescript token-info.ts theme={null}
import { publicClient } from "./clients";
import { bagsTokenAbi } from "./abi";
import type { Address } from "viem";

export async function readTokenInfo(token: Address) {
  const [name, symbol, metadataURI, totalSupply] = await Promise.all([
    publicClient.readContract({ address: token, abi: bagsTokenAbi, functionName: "name" }),
    publicClient.readContract({ address: token, abi: bagsTokenAbi, functionName: "symbol" }),
    publicClient.readContract({ address: token, abi: bagsTokenAbi, functionName: "metadataURI" }).catch(() => ""),
    publicClient.readContract({ address: token, abi: bagsTokenAbi, functionName: "totalSupply" }),
  ]);
  return { name, symbol, metadataURI, totalSupply };
}
```

## 4. Discover via TokenCreated Events

You can also index launches directly from `TokenCreated` logs (useful for backfilling history or building a stream). Start no earlier than the protocol deploy block.

```typescript index-launches.ts theme={null}
import { parseAbiItem } from "viem";
import { publicClient } from "./clients";
import { ROBINHOOD_LAUNCHPAD, ROBINHOOD_DEPLOY_BLOCK } from "./addresses";

const tokenCreatedEvent = parseAbiItem(
  "event TokenCreated(address indexed token, address indexed curve, address indexed creator, address feeShare, address partner, bytes32 poolId, string name, string symbol, string metadataURI)"
);

export async function getLaunches(fromBlock: bigint = ROBINHOOD_DEPLOY_BLOCK) {
  const logs = await publicClient.getLogs({
    address: ROBINHOOD_LAUNCHPAD.factory,
    event: tokenCreatedEvent,
    fromBlock,
    toBlock: "latest",
  });
  return logs.map((log) => ({
    token: log.args.token,
    curve: log.args.curve,
    creator: log.args.creator,
    feeShare: log.args.feeShare,
    partner: log.args.partner,
    poolId: log.args.poolId,
    name: log.args.name,
    symbol: log.args.symbol,
    metadataURI: log.args.metadataURI,
    blockNumber: log.blockNumber,
    txHash: log.transactionHash,
  }));
}
```

<Tip>
  For a live feed, checkpoint the last scanned block and only query `[lastScanned + 1, latest]` on each poll rather than re-scanning from the deploy block every time.
</Tip>

### Indexer notes

* **Trade events are self-contained.** `TokensBought` and `TokensSold` embed the post-trade price, virtual reserves, and full fee breakdown (vault / creator / partner), so you can index curve trades without extra state reads per event.
* **Phase flip.** `Migrated` on the curve is the switch point: stop consuming curve events and start consuming `PoolManager` `Swap` logs (filtered by the token's `poolId`) and the hook's `HookFeeTaken`.
* **Pool-phase volume.** The hook takes 2% of the WETH leg on every pool swap, so gross WETH volume per swap = `HookFeeTaken.amount x 50`.
* **Fee claimers are not in events at launch.** Call `feeShare.getClaimers()` after `TokenCreated`, and watch `ClaimersUpdated` — the list can change.
* **Upgrade monitoring.** `BagsFactory` and `BagsVault` are UUPS proxies, and per-token curves/fee-shares point at two shared beacons. Watch `Upgraded` on the factory/vault proxies and on both beacons (`BagsBondingCurveBeacon`, `BagsFeeShareBeacon` — addresses in the [Contracts Reference](/robinhood/contracts)) to detect implementation changes.

## 5. Post-Migration Price from the Pool

After migration, read the live spot price from the pool's `slot0` via `StateView`. Never fall back to the frozen lens price for migrated tokens.

Add the `StateView` fragment to `abi/periphery.ts`:

```typescript theme={null}
export const stateViewAbi = [
  {
    type: "function",
    name: "getSlot0",
    inputs: [{ name: "poolId", type: "bytes32" }],
    outputs: [
      { name: "sqrtPriceX96", type: "uint160" },
      { name: "tick", type: "int24" },
      { name: "protocolFee", type: "uint24" },
      { name: "lpFee", type: "uint24" },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getLiquidity",
    inputs: [{ name: "poolId", type: "bytes32" }],
    outputs: [{ name: "liquidity", type: "uint128" }],
    stateMutability: "view",
  },
] as const;
```

Then read `slot0` and convert `sqrtPriceX96` to ETH per whole token:

```typescript pool-price.ts theme={null}
import { publicClient } from "./clients";
import { ROBINHOOD_LAUNCHPAD } from "./addresses";
import { stateViewAbi } from "./abi/periphery";
import { isTokenCurrency0 } from "./poolKey";
import type { Address, Hex } from "viem";

const Q96 = 2 ** 96;

/** ETH per whole token from a v4 sqrtPriceX96 price. Returns null on failure. */
export async function readPoolPriceEth(token: Address, poolId: Hex): Promise<number | null> {
  try {
    const [sqrtPriceX96] = await publicClient.readContract({
      address: ROBINHOOD_LAUNCHPAD.stateView,
      abi: stateViewAbi,
      functionName: "getSlot0",
      args: [poolId],
    });

    // price(currency1 per currency0) = (sqrtPriceX96 / 2^96)^2
    const ratio = (Number(sqrtPriceX96) / Q96) ** 2;
    // Orient so the result is ETH (WETH) per token.
    const ethPerToken = isTokenCurrency0(token) ? ratio : 1 / ratio;
    return ethPerToken > 0 ? ethPerToken : null;
  } catch {
    return null;
  }
}
```

<Note>
  `sqrtPriceX96` is a Q64.96 fixed-point number. The `Number()`-based conversion above is fine for display; for high-precision accounting, compute the square in `BigInt` before converting.
</Note>

## 6. Pool ID Derivation

Prefer the `poolId` from `getTokenState` or the `TokenCreated` event. When you must derive it yourself, it's `keccak256(abi.encode(poolKey))` over the sorted key:

```typescript pool-id.ts theme={null}
import { encodeAbiParameters, keccak256, type Address, type Hex } from "viem";
import { bagsPoolKey } from "./poolKey";

export function poolIdForToken(token: Address): Hex {
  const key = bagsPoolKey(token);
  return keccak256(
    encodeAbiParameters(
      [{ type: "address" }, { type: "address" }, { type: "uint24" }, { type: "int24" }, { type: "address" }],
      [key.currency0, key.currency1, key.fee, key.tickSpacing, key.hooks]
    )
  );
}
```

<Warning>
  The derivation must match the factory byte-for-byte or every derived `poolId` is wrong. Cross-check your derived value against the on-chain `poolId` from `getTokenState` for a known token, and prefer the on-chain value whenever it's available.
</Warning>

## Next steps

* Trade against this state with the [Trade Tokens](/robinhood/trade-tokens) guide.
* Read `claimableOf` and the fee-share breakdown in the [Claim Creator Fees](/robinhood/claim-fees) guide.
* See the [Contracts Reference](/robinhood/contracts) for every read function and event.
