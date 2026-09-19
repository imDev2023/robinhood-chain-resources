# Coinbarrel

Archived 2026-09-19.
Site `coinbarrel.com`, X `@UseCoinbarrel`, DefiLlama slug `coinbarrel`, category Launchpad.
$124,515 in 30 days at the 2026-09-02 pull.

## What is archived

| Role | Address | Contract name | Verified |
| --- | --- | --- | --- |
| V4 custody | `0x418ece71c4ece08b71db8c53d59b6bc345efc659` | `PermanentV4PositionCustody` | yes |
| V3 custody | `0x0e88ba639f062feaa5f36a8d5f689d3e93bce593` | not verified | **no** |

## The lock

DefiLlama's methodology calls the V4 contract an "ownerless custody contract", and the archived source bears that out: `PermanentV4PositionCustody.sol` is 81 lines with **no `onlyOwner` and no owner**.
Positions are enumerated from PositionManager `Transfer` events into the custody and re-verified with `ownerOf`.

The name is the design: positions go in and there is no path out.
That puts Coinbarrel in the small group, with Unihood, hood.fun and Pools.trade, whose lock needs no trust in an operator.

It runs **five hook generations** per the adapter's comment, so the custody is shared across a sequence of launch designs.

## Gaps

1. **The launch factory is not archived**, only the custody. Same shape of gap as StonkBrokers: the TVL adapter names TVL-bearing contracts and nothing else.
2. **The V3 custody is unverified.** A PUSH4 scan would identify it; not run in this pass.
3. The five hook generations are not identified.
4. Fee split, creator share, quote assets and launch counts unread.
5. No docs capture, screenshots or socials.
