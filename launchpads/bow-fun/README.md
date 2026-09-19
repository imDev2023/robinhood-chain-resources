# bow.fun

Archived 2026-09-19.
Site `bow.fun`, DefiLlama slug listed as `bow.fun`, category Launchpad.
$31,264 in 30 days, $431,612 all time, at the 2026-09-02 pull.

Start date 2026-07-11, per DefiLlama's adapter.

## What is archived

| Role | Address | Verified |
| --- | --- | --- |
| Factory | `0xC70E510E14710Ea535CAB7b2414860aF63FEab79` | **no** |

Unverified, so no sources.
Function surface recovered by PUSH4 scan of the 16,318-byte runtime, written to `_raw/rpc/`.

**bow.fun publishes its deployed contracts** at `bow.fun/docs.html#deployed-contracts`, cited by DefiLlama's adapter. That page was not fetched in this pass and is the cheapest next step: it should name every contract without any further chain work.

## What the selectors show

A Uniswap **V3** launchpad with a locker and a migration step.

**Launch path:** `launchpad`, `launches`, `launchFee`, `setLaunchFee`, `setLaunchEnabled`, `predictToken`, `migrated`, `locker`, `pool`, `setPool`, `v3Factory`, `npm`, `router`, `weth`, `token0`, `token1`.

`migrated()` plus `locker()` means a real graduation event into a locked V3 position, the same shape as hood.fun.

**Metadata on chain:** `logoURI`, `website`, `twitter`, `telegram`, `tokenURI`, `setMetadata`, `metadataSet`.
Social metadata is stored on chain rather than in a backend, which is unusual in this set.

**Anti-snipe:** `maxWallet`, `limitWindow`.
A per-wallet cap over a window, like RaiseHood and Flap, not a fee curve.

**Owner surface:** `owner`, `transferOwnership`, `renounceOwnership`, `setLaunchEnabled`, `setLaunchFee`, `setTreasury`, `setPool`, `treasury`.

`setLaunchEnabled(bool)` is the same kill switch Noxa's V1 used before that platform went quiet, so it is worth checking the flag's current value before treating bow.fun as live.

## Gaps

Unverified contract, so everything is inferred from selectors.
`bow.fun/docs.html` unfetched.
Fee split, creator share, lock permanence and launch counts unknown.
No docs capture, screenshots or socials.
