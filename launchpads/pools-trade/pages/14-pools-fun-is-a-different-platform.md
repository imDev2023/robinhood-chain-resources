# Pools.trade - "pools fun" and the PartyFactory lead are a different platform

> Source: on-chain verified source of 0x626C3d09B65bF5d1D40E0D5F25e19fa49783B3D4 on Robinhood Chain
> Retrieved: 2026-09-03 (Blockscout `smart-contracts`; raw at `_raw/leads/blockscout-partyfactory-sc.json` and `_raw/leads/blockscout-partyfactory-address.json`)

---

`SCRAPING-PLAN.md` section 5.10 asks whether the Reddit post in `_market/pages/19-reddit-nobonding.md`, which describes "pools fun" with a `PartyFactory` at `0x626C3d09B65bF5d1D40E0D5F25e19fa49783B3D4`, is the same project as pools.trade.

It is not.
They are two unrelated launchpads with confusingly similar names.

## The evidence

`0x626C3d09B65bF5d1D40E0D5F25e19fa49783B3D4` is a verified contract on Robinhood Chain named `PartyFactory`, compiler `v0.8.25+commit.b61c2a91`, created by `0xd86EC279AD4871483f6c3D7ce54AD00067f120E9`.
Its own natspec names the platform:

```solidity
/// @title PartyFactory
/// @notice Deploys pools.fun tokens (CREATE2, always token0), seeds a single-sided
///         full-range SushiSwap V3 position, registers the LP with the permanent
///         locker, and optionally performs a dev buy. The launch curve is protocol
///         state, never caller input: per paired asset the owner registers a
///         Chainlink USD feed and a fallback tick; launches derive the start tick
///         live from the feed (targeting `initialFdvUsd`) and degrade gracefully
///         to the fallback tick when the feed or sequencer is unusable. The factory
///         never retains custody of pool assets - LP NFTs go straight to the locker.
contract PartyFactory is Ownable2Step, IUniswapV3SwapCallback {
    uint256 public constant TOTAL_SUPPLY = 1_000_000_000e18;
    uint24 public constant FEE = 10000;      // 1%
    int24 public constant TICK_SPACING = 200;
    ...
    ISushiV3Factory public immutable sushiFactory;
```

The domain in the source is `pools.fun`, not `pools.trade`.

## Side by side

| | pools.fun (`PartyFactory`) | pools.trade (this archive) |
| --- | --- | --- |
| launch contract | `PartyFactory` `0x626C3d09B65bF5d1D40E0D5F25e19fa49783B3D4` | `LiquidityLauncher` `0x0000FffFBE8efE702c8703aE3477FF5dE3d319C0` |
| deployer | EOA `0xd86EC279AD4871483f6c3D7ce54AD00067f120E9` | Uniswap's deploy key `0x32f4B2e69EbD7746596AF8699DAC1908F43107aD` through the canonical CREATE2 proxy |
| DEX | SushiSwap V3 | Uniswap v4 |
| pool fee | 1% (`FEE = 10000`) | 0.25% (`LP_FEE() = 2500`) |
| tick spacing | 200 | 25 |
| starting FDV | an owner-tunable `initialFdvUsd` target, converted to a start tick live from a Chainlink USD feed, bounded to $100 to $1,000,000,000; the Reddit report puts the live value near $10K | about $6.0K for Instant Launch, about $1.0K floor rising to a $10K graduation target for Crowd Launch, both fixed at deployment or at launch |
| supply | 1,000,000,000 | 1,000,000,000 |
| liquidity lock | LP NFT sent to a `PartyLocker` | LP position held permanently by a `FeeSplitter` |
| fee recycling | stated 25% of protocol fees buy and burn the top three tokens daily | 100% of the LP fee splits between the creator and auto-compounding into the same locked position |
| appears in Uniswap's `deployments.json` | no | yes, all 42 chain-4663 records |

The only things the two share are the word "pools", a 1B fixed supply and a permanent liquidity lock, which are common to most of this chain's launchpads.

## Naming

`_market/pages/19-reddit-nobonding.md` should be read as a post about pools.fun.
It is dated 17 days before the 2026-09-02 capture, that is around 2026-08-16, well after pools.trade went live on 2026-08-05, so the two were live at the same time and the confusion is real rather than a stale reference.

pools.fun is not in `launchpad-research.md` and has no directory in this archive.
It is a candidate for the "platforms found but not archived" list in the final comparison session.
