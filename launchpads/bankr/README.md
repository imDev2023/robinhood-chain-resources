# Bankr

Archived 2026-09-19.
Site `bankr.bot`, X `@bankrbot`.

**Bankr is a Doppler integrator, not an independent protocol**, exactly as `PLAYBOOK.md` section 0 rule 1 predicts.
Its contract set is the Doppler set plus a thin launcher, so most of its behaviour is already documented in `launchpads/doppler/`.

Integrator address `0xf60633d02690e2a15a54ab919925f3d038df163e`.

## Scale

**90,404 assets on chain 4663**, read live from `indexer-prod.doppler.lol` on 2026-09-19, up from 88,764 at the 2026-09-02 capture.
The chain's Doppler total is now 153,855, up from 109,177.
Bankr is 58.8% of all Doppler launches on this chain, down from 81.1% as other integrators grew.

That still makes it, by launch count, one of the largest launch venues on Robinhood Chain, and it earns nothing on DefiLlama's fee table because it is absent from it entirely.

## What is archived

| Role | Address | Contract name |
| --- | --- | --- |
| Liquidity migrator | `0xba2f330edb16cd8056f5988d8ce19bbc63475a0e` | `NoOpMigrator` |
| Pool initializer | `0x4e3468951d49f2eea976ed0d6e75ffcb44a9a544` | `DopplerHookInitializer` |
| BNKR numeraire | `0x0bd7d308f8e1639fab988df18a8011f41eacad73` | `TransparentUpgradeableProxy` |

## Two findings

**Bankr never migrates.** Its liquidity migrator is `NoOpMigrator`, the same contract behind Doppler's 0-of-109,177 migration rate. Every Bankr launch stays in its launch pool permanently, so "graduation" is not a concept here. That is the same posture as Doppler and Long.

**Governance is burned.** Every sampled asset carries `governance: 0x000000000000000000000000000000000000dead`, so launched tokens have no governance contract at all.

**BNKR itself is upgradeable.** The numeraire every Bankr launch is priced against is a `TransparentUpgradeableProxy`, so the quote asset's code can be replaced. The proxy admin was not read in this pass.

## Gaps

1. The four-way fee split described in the market catalog (creator, locked liquidity, protocol, BNKR buybacks) was **not verified on chain**. That split is the reason Bankr was a priority target and it remains unconfirmed.
2. Bankr's own launcher contract, the thin wrapper above Doppler, is not identified.
3. BNKR's proxy admin and upgrade history not read.
4. No docs capture, screenshots or socials.
