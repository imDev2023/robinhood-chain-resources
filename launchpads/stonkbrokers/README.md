# StonkBrokers

Archived 2026-09-19.
Site `stonkbrokers.cash`, X `@ClutchMarkets`, DefiLlama slug `stonkbrokers`, category Launchpad.

**The largest unarchived fee earner on the chain at capture**: $2,542,956 in 30 days, fourth overall, and the single biggest blind spot in the original survey.

It is not only a launchpad.
DefiLlama's methodology describes a DeFi suite whose TVL spans "every Stonklauncher / Safe Launch graduation pool across the V1 ETH pad, V1 quoted lanes, V2 lanes, and r2 pads", plus an NFT AMM and covered calls.

## What is archived

| Role | Address | Contract name |
| --- | --- | --- |
| V3 box locker | `0xFc96CF67eCC55bE4AdABc3AecBe6Ad6349f11223` | `StonkLiquidityLocker` |
| up. CL box locker | `0xc1AfA59e2aBC1C868C51a1F799a7578EaCfEa076` | `StonkUpLockerCL` |
| Token escrow | `0x799AE26fA515ceF145e8bC8636F7fFF87B05Cf62` | `TokenEscrowReserve` |
| Smart LP registry | `0xE8749183Fbf6A657EB58B3a4D3E4B9Cc09560146` | `SmartLpRegistry` |
| STONKBROKER token | `0xe934e36A439C94017B64a3FecE66AF12099aBF50` | `CollectionToken` |
| V3 lock NFT | `0xE460dA1a77CAe75EeD8b355d05b6fCBFA4b2A360` | `StonkLockerOwnershipNFT` |
| up. CL lock NFT | `0x3e45e90d83D87F961561968709D5AB844EB7422f` | `StonkLockerOwnershipNFT` |

All seven verified, 177 `.sol` files.

## The lock, and what is distinctive

StonkBrokers does not hold locked positions in a bare custody contract.
The locked LP is represented by a **`StonkLockerOwnershipNFT`**, so the right attached to a locked position is itself transferable.
That is the same idea as Pools.trade's transferable ERC-721 fee claim, applied to the lock rather than to the fee stream, and it is the only place in the survey where both a V3 venue and a Slipstream ("up.") venue are locked through one design.

Constructor arguments name a `_protocolFeeRecipient` shared across both lockers, `0x55642A3F10F1Af5145D3d59021B1D6b03BB8692c`, and two different `initialOwner` values, so the two lanes are not administered by one key.

## Gaps

**The launch factory itself is not archived.**
The DefiLlama TVL adapter only names TVL-bearing contracts, so the lockers and escrow came through and "Stonklauncher" / "Safe Launch" did not.
Finding it is the first job of any follow-up: read the locker's callers, or walk the pointer ring as `PLAYBOOK.md` section 4 describes.

Also open: fee split, creator share, graduation terms, launch counts, and the owner surface on each locker.
No docs capture, screenshots or socials.
