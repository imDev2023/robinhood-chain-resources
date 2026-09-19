# Unihood

Archived 2026-09-19.
Site `unihood.fun`, X `@unihoodotfun`, DefiLlama slug `unihood`, category Launchpad, chain Robinhood Chain only.

**This is the most tightly constructed launchpad in the survey.**
Across the factory, the hook and the token there is not one `onlyOwner`, not one `Ownable` import and not one proxy.
Every economic number is a `constant` or an `immutable` fixed at deploy.
Nothing in the contract set can be changed by anyone after deployment, including the deployer.

## 1. What is archived

| Contract | Address | Verified | Lines |
| --- | --- | --- | --- |
| `UnihoodFactory` | `0x0485a4392b7300841e644bB1B36562AE7B2A0c82` | yes | 198 |
| `UnihoodHook` | `0xec392C2b716C4B46df67cA6196ff92f7Dc2De8Cc` | yes | 525 |
| `UnihoodToken` | in the factory's sources | yes | 70 |
| `PoolManager` (Uniswap v4, shared) | `0x8366a39CC670B4001A1121B8F6A443A643e40951` | yes | - |
| `StateView` (Uniswap v4, shared) | `0xf3334192d15450cdd385c8b70e03f9a6bd9e673b` | yes | - |

First-party code is 793 lines, all MIT.
Addresses, the deploy block and the `Launched` event signature came from the DefiLlama TVL adapter rather than from Blockscout crawling; see `PLAYBOOK.md` section 4.

## 2. Model

One transaction.
`UnihoodFactory.launch(name, symbol, metaURI)` deploys a fixed-supply token, registers it with the global hook, initializes a native-ETH Uniswap v4 pool at a fixed start tick, places the **entire 1B supply** as a single-sided range from the start tick down to the minimum usable tick, and optionally executes the creator's fee-free first buy from `msg.value`.

There is no bonding curve, no graduation event and no migration.
Supply is the liquidity, so the creator seeds nothing.

The factory's own natspec states the lock outright:

> The factory keeps the launch position forever: it has no function that can remove liquidity, so the position is locked by construction. Nothing ever migrates.

That is a stronger claim than a hook that reverts `removeLiquidity`, because there is no privileged caller to reason about: the function does not exist.

Constants: `TOKEN_SUPPLY` 1e9, `TICK_SPACING` 200, `LP_FEE_PIPS` 0.
The pool's own LP fee is zero; the hook charges everything.

## 3. Fees

The hook charges on the **native ETH side only**, both directions, and splits a 1% base fee three ways:

| Bucket | bps of gross native | Share of the 1% |
| --- | --- | --- |
| Creator | 80 | 80% |
| Platform | 15 | 15% |
| Bid wall | 5 | 5% |

**A creator receives 0.80% of all ETH volume, for the life of the token.**
That is second only to HOOD10's creator-set lane in the whole 22-platform survey, and unlike HOOD10 it has no fee router in the path that an owner can repoint.

Fees accrue as ERC-6909 claims inside the PoolManager and are redeemed through `unlock` on claim, so nothing is swapped or transferred on the swap path.

## 4. Anti-snipe

A three-step decay driven only by the wall clock:

| Window from launch | Total fee |
| --- | --- |
| < 5 s | 15.00% |
| < 15 s | 5.00% |
| thereafter | 1.00% |

Everything above the 1% base accrues to the **bid wall**, not to the platform and not to the creator.
The hook's own comment for this is "snipers build the floor".

The bid wall is a self-executing buy order one tick spacing wide (~2% band) placed just below spot, funded by that surcharge.
External LP is blocked until graduation, so nobody can front-run the wall with their own range.

Because the schedule reads the clock and nothing else, it cannot be gamed with dust swaps, which is the same property that makes Sentry's decay credible (`sentry` s3.3).

## 5. Custody and trust

- **No owner.** No `Ownable`, no `onlyOwner`, no `owner()` in factory, hook or token.
- **Two `platformRecipient` gates, neither reaching a creator.** `setFactory` is one-shot and reverts `FactoryAlreadySet` afterwards; live `factory()` already returns `0x0485a439...`, so it is spent. `claimPlatformFees` moves only the platform's own accrued 15%. Recorded because "no privileged functions" would overstate it: the accurate claim is that no key can alter a creator's terms, redirect their income, or touch the launch position.
- **No proxy.** Blockscout reports `proxy_type: null` for both factory and hook.
- **No fee knobs.** The hook's natspec: "every number below is immutable at deploy".
- **No withdrawal path.** The factory holds the launch position and has no function that removes liquidity.
- Creator `0x64900b69E56583C12900F3458525a3fdB6f274D7`, creation tx `0x570bc9a8518aae9981c079417a67d231244a22b5b1a3afa4016353a69de92525`.

Attribution recorded in the source: the fee-charging flow is "modeled after EthCreatorFeeHookV3 (programmable.family, MIT), adapted for the three-way split, the decay schedule and the self-executing bid wall".

## 6. Quote assets

**Native ETH only.**
Unlike HOOD10, Doppler or Pons there is no quote registry, so a token cannot be paired against USDG or a tokenized stock.
That is the platform's main functional limitation.

## 7. Gaps

Not settled in this pass, and each is a real question rather than an assumption:

1. **Launch count and graduation rate.** The hook references a `gradTick` and "external LP is blocked until graduation", so a graduation concept exists; what it unlocks was not traced.
2. **No docs capture.** `unihood.fun` was not crawled, no `pages/`, no screenshots, no socials.
3. **No decoded production launch.** The `Launched` event signature is known from the adapter but no real call was decoded.
4. **Bid wall behaviour unverified on chain.** The mechanism is read from source, not observed.
5. **No audit.** Consistent with all 21 other platforms on this chain.

## Sources

- `contracts/` built by `scripts/bsfetch.py` and `scripts/mkarchive.py` from Blockscout, 2026-09-19.
- Addresses and deploy block: DefiLlama TVL adapter `DefiLlama-Adapters/projects/unihood/index.js`.
- Verified source natspec is the authority for every mechanism claim above.
