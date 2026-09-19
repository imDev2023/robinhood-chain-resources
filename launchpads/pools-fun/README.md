# pools.fun

Archived 2026-09-19.
Unrelated to **Pools.trade**, which is Uniswap Labs' launch flow archived in `launchpads/pools-trade/`.
The name collision is the reason this one was missed: the original survey's catalog flagged it as "not in `launchpad-research.md`, so nobody owns it".

## What is archived

| Role | Address | Contract name | Verified |
| --- | --- | --- | --- |
| Factory | `0x626C3d09B65bF5d1D40E0D5F25e19fa49783B3D4` | `PartyFactory` | yes |

25 `.sol` files, including `PartyToken.sol`.

## Model

Per the market catalog, sourced from a Reddit thread rather than from the contracts: no bonding curve, direct **SushiSwap V3** pools, and 25% of fees used to buy and burn the top three tokens daily.
2,439 tokens launched on day one.

The SushiSwap V3 route is unique in the survey; every other pad uses Uniswap V3, Uniswap v4, or a V2 fork.

**None of that is verified against the archived source in this pass.**

## Custody

`PartyFactory.sol` carries **7 `onlyOwner`** functions across 601 lines.
It is not a proxy, so the code is fixed, but the parameter surface is wide and was not enumerated.

## Gaps

Everything economic, plus: the daily buy-and-burn is unconfirmed, the seven owner functions are unenumerated, the locker (if any) is not identified, and launch counts past day one are unknown.
No docs capture, screenshots or socials.
