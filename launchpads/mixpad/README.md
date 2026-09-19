# Mixpad

Archived 2026-09-19.
Site `mixpad.fun`, X `@mixpadfun`, DefiLlama slug `mixpad`, category Launchpad, chain Robinhood Chain only.

**Three factories are live, not one**, which the market catalog did not record.

| Role | Address | Contract name | Verified |
| --- | --- | --- | --- |
| Current | `0x819d0ADB0F60Cf5C2BCE503a7b1674Df04b0894c` | `MixpadFactory` | yes |
| Legacy v1 | `0x448Ab965ee15f899b73D078717E632aC3D74ac65` | `MixpadFactory` | yes |
| RWA | `0x27c9089140da7d24a1cd977e080d69b62cc53f4f` | `RwaFactory` | yes |

147 `.sol` files archived under `contracts/`.

## Model

Direct pool seed, no bonding curve.
DefiLlama's methodology, written against the live contracts:

> Each token launches its full supply as a single one-sided Uniswap V4 position (LP burned). Reserves are reconstructed on-chain from the position liquidity and current price via Uniswap V4 StateView.

So Mixpad sits in the same family as Unihood, HOOD10, Noxa and Pools Instant Launch: supply is the liquidity, nothing migrates, and the creator seeds nothing.
The lock is by **LP burn** rather than by a custody contract, which is the same mechanism Flap uses and is unconditional once done.

Quote assets are WETH and USDG, so unlike Unihood it can pair against the chain's stablecoin.
The separate `RwaFactory` extends that to tokenized equities.

## Custody

`MixpadFactory.sol` carries **7 `onlyOwner`** functions across 622 lines; `RwaFactory.sol` carries **6** across 508.
Neither is a proxy, so the code itself cannot be replaced, but the parameter surface is wide.
Those thirteen functions were not enumerated in this pass.

## Gaps

1. The thirteen owner functions are not enumerated, so Mixpad cannot be ranked on custody.
2. Whether the legacy v1 factory is still accepting launches was not checked.
3. Launch counts, fee levels and the creator's share were not read off chain.
4. No docs capture, screenshots or socials.
