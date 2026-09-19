# token.select

Archived 2026-09-19.
Site `token.select`, X `@selectfdn`, DefiLlama slug `token.select`, category Launchpad.
$101,970 in 30 days at the 2026-09-02 pull.

## What is archived

| Role | Address | Contract name |
| --- | --- | --- |
| Factory proxy | `0xA94AA60e9c7f193BF678608D5837F0FD51794635` | `ERC1967Proxy` |
| Factory implementation | `0x6353c5a486e7818CA509009d20404e81C99bf700` | `TokenSelectFactory` |

Both verified, 32 `.sol` files.

## Model

Uniswap **V3**, not v4, which makes it one of the few non-v4 pads in the survey alongside hood.fun, Noxa and RaiseHood.

DefiLlama's methodology names the structure precisely:

> Launched tokens are enumerated from the factory's `NewTokenSelectToken` events and each token's `lpVault` is read on-chain, so vaults added later are included automatically. Only the whitelisted WETH side is counted.

So each launch gets its **own `lpVault`** holding that token's V3 position, rather than one shared custody.
That is a per-launch isolation property no other pad in the survey has, and it means one token's lock cannot be affected by another's.

The market catalog describes the model as "fixed price contributor funding, migrates into Uniswap", which would put it with RaiseHood and DexLaunch in the presale group rather than the instant-pool group.
That description was **not verified against the contracts** in this pass.

## Custody

The factory is an **ERC-1967 proxy**, so the launch logic is replaceable.
The proxy admin was not read.

## Gaps

1. Whether it is really a presale model, unconfirmed against the contracts.
2. Proxy admin and upgrade history unread.
3. The `lpVault` contract itself is not archived, only the factory that deploys them.
4. Fee split, creator share, lock permanence and launch counts unread.
5. No docs capture, screenshots or socials.
