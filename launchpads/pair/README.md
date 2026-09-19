# PAIR

Archived 2026-09-19.
Site `pair.fund`, X `@pairdotfund`, DefiLlama slug listed under Launchpad.

PAIR was the hardest of the twelve to place, and the reason is now settled: **DefiLlama lists it with an empty `chains` array**, so it appears in the chain fee table while being absent from every chain-filtered catalog query.
That is a DefiLlama data defect, not a gap in the original survey.

It is live on Robinhood Chain.

## What is archived

| Role | Address | Contract name |
| --- | --- | --- |
| Launchpad proxy | `0x8660A7F019C7943b0b0A91B8E39AFf3b6DB6Ae62` | `PairERC1967Proxy` |
| Launchpad implementation | `0x8000B64B62837a1511E302c62354E1Bc39b5641a` | `PairLaunchpadV5Upgradeable` |
| Hook | `0xd1BcbCCa41f3bdb6b4812652959c6dF725ea2Ac0` | `DualPoolHook` |
| USDG quote token | `0x5fc5360D0400a0Fd4f2af552ADD042D716F1d168` | `ERC1967Proxy` |

All verified, 141 `.sol` files.

## Two things the names already tell you

**`PairLaunchpadV5Upgradeable` behind an ERC-1967 proxy.** The launch logic is replaceable, and the contract is on its fifth version. That is the same exposure as Bags, Virtuals and Sentry, and the opposite of Unihood and hood.fun. The proxy admin was not read in this pass and is the first thing a follow-up should read.

**`DualPoolHook`.** A launch appears to run two pools rather than one. No other platform in the 22 does this, and what the second pool is for is the most interesting open question in this archive. The hook is not a proxy, so whatever it does is fixed.

## How it was found

The address came from the frontend bundle at `pair.fund/assets/index-BDOzzxau.js`, per `PLAYBOOK.md` section 4 on reading bundles.
A caution worth recording: the **most frequent** address in the bundle (386 occurrences) was USDG, the chain's stablecoin, not the factory.
Frequency ranking picked the wrong contract and only reading each candidate's name off chain corrected it.

## Gaps

Everything economic.
Fee levels, creator share, the lock, the two-pool design, launch counts, the proxy admin, and whether USDG is the only quote.
No docs capture, screenshots or socials.
