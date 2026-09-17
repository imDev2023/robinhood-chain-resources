<!-- source: https://developers.uniswap.org/docs/protocols/v4-hooks/dualpool/concepts/liquidity-distributions | captured: 2026-08-22 | via: https://developers.uniswap.org/docs/protocols/v4-hooks/dualpool/concepts/liquidity-distributions.md (native markdown) -->
# Liquidity Distributions (/docs/protocols/v4-hooks/dualpool/concepts/liquidity-distributions)

Learn how DualPool operators shape just-in-time liquidity across weighted tick buckets.

When a swap arrives, DualPool does not deploy its capital into a single price range. Each pool carries an owner-configured distribution, a list of tick buckets, each with a weight:

```solidity
struct LiquidityBucket {
    int24 tickLower;
    int24 tickUpper;
    uint16 weightBps;
}
```

During a JIT cycle, the hook budgets each bucket's share of the deployable balance by weight, computes the corresponding liquidity at the current price, and adds one v4 position per bucket. Buckets may overlap, be asymmetric, or be non-contiguous.

A distribution must satisfy:

* 1 to 8 buckets
* Every `weightBps` nonzero, and weights summing to exactly 10,000 bps
* Ticks aligned to the pool's `tickSpacing` and within [`TickMath`](https://github.com/Uniswap/v4-core/blob/main/src/libraries/TickMath.sol) bounds

## Example Shapes
A typical stable-pair distribution concentrates depth at the peg with thinner cover around it:

| Bucket | Tick Range  | Weight |
| ------ | ----------- | ------ |
| Tight  | `[-10, 10]` | 75%    |
| Medium | `[-30, 30]` | 15%    |
| Wide   | `[-60, 60]` | 10%    |

Because buckets are free-form, operators can express more opinionated structures:

* **Ultra-tight**: most weight inside `[-1, 1]` and `[-5, 5]`, maximizing capital efficiency for small swaps near the peg at the cost of sensitivity to drift
* **Barbell**: a tight center plus one-sided tail buckets (e.g. `[50, 250]`) that are out of range at rest but give large swaps something to trade into, without diluting liquidity across unused middle ticks
* **Inventory skew**: overweighting the side that sells the maker's excess asset, so directional flow naturally rebalances the pool
* **Peg defense**: laddering progressively deeper buckets on the vulnerable side of a peg while keeping a small symmetric center

## Pre-Budgeted Allocation
For each bucket, the hook first budgets the balance by weight:

```text
weightedBal0 = bal0 * weightBps / 10_000
weightedBal1 = bal1 * weightBps / 10_000
```

then derives the bucket's liquidity with [`LiquidityAmounts.getLiquidityForAmounts`](https://github.com/Uniswap/v4-periphery/blob/main/src/libraries/LiquidityAmounts.sol) and the exact token requirements with [`SqrtPriceMath`](https://github.com/Uniswap/v4-core/blob/main/src/libraries/SqrtPriceMath.sol). Pre-budgeting (rather than sizing every bucket against the full balance and scaling afterward) keeps deployment, indicative quotes, and execution aligned, and means the hook withdraws from the vaults only what the positions actually require at the current price.

## Rotating Distributions
The owner can replace a pool's distribution at any time with [`setDistribution`](https://github.com/Uniswap/v4-hooks-public/blob/main/src/alf/DualPoolHook.sol#L490), for example rotating between tighter and wider shapes by volatility regime. Updates are blocked while a JIT cycle is in flight, so rotations always happen cleanly between swaps.

## Reading the Distribution
[`getDistribution(poolId)`](https://github.com/Uniswap/v4-hooks-public/blob/main/src/alf/DualPoolHook.sol#L663) exposes the active bucket list: tick bounds and weights. The summed, pre-budgeted liquidity of the buckets in range at the current tick is what backs [`getIndicativeQuote`](https://github.com/Uniswap/v4-hooks-public/blob/main/src/alf/interfaces/IALFHook.sol#L36); out-of-range buckets deploy alongside them but only become active if a swap moves price into their range.

## Where to Go Next
* [Create a pool and configure its first distribution](/docs/protocols/v4-hooks/dualpool/guides/create-pool)
* [See how buckets deploy during a JIT cycle](/docs/protocols/v4-hooks/dualpool/concepts/jit-liquidity)
