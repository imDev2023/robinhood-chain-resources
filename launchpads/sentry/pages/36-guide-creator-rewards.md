# Sentry - Guide, Creator Rewards

> Source: https://www.sentry.trading/desktop/guide#creator-rewards
> Retrieved: 2026-09-02 (Jina Reader)
> Raw capture: `_raw/jina/sentry-desktop-guide.md`

---

## Creator Rewards[](https://www.sentry.trading/desktop/guide#creator-rewards "Copy link to this section")

Launch a token and you earn from every single trade it ever does, forever.

## The split

*   **Current launches (v4, both chains — identical contracts and numbers):** at the permanent 1.7% floor a WETH launch pays the creator **1.0% of every trade**, which is 59% of the fee, with 0.2% compounded into the token's own liquidity and 0.5% to the protocol. Launches with reflections enabled and stock-paired launches pay the creator **0.5%** (29% of the fee), because 0.8% goes to holders instead.
*   **Legacy V3 launches:****70% to the creator**, 30% to the Sentry treasury on Robinhood Chain (raised from 65% on July 8, 2026); **65% / 35%** on Ink.

The splits are enforced by the contracts and readable on-chain. How the fees reach you depends on the launch generation: on v4 launches the fee hook **pays your share out on every single trade**, directly to your wallet, with nothing to collect — during the launch window that includes the anti-snipe fee, so early frenzy volume pays creators the most. Stock-paired launches pay you **in the base stock** (sell a CHILL-style token's volume and you accumulate NFLX). Legacy V3 launches accrue fees inside the locked position until collected, as described below.

## Current launches: paid per trade, nothing to collect

On every current launch (v4, both chains), your share is settled **inside each swap transaction** and lands in your fee recipient wallet immediately. There is no claim step, no collection schedule, and no balance sitting anywhere waiting on you — if your token traded five seconds ago, you were paid five seconds ago. Your `My Tokens` card tracks the running totals.

## Collecting fees on legacy V3 launches

1.   Open `Wallet`>`My Tokens`. Each token you launched shows a card with its live stats.
2.   Tap `View` / `Refresh` to read the accrued, uncollected fees straight from the pool (read-only, no transaction).
3.   On Robinhood Chain, tap `Collect Fees`. Collection pulls the accrued fees out of the locked position and pays your share directly to your fee recipient wallet in the same transaction.

## Fee recipient management

*   **At launch:** optionally direct fees to any address with the creator-fee-recipient field on the Create form. You stay the recorded creator.
*   **After launch:** the current recipient can **transfer fee rights exactly once** via the `Transfer Fees` action on the My Tokens card. It's a one-time, irreversible handoff, built for handing a community takeover its fee stream. Sentry can also reassign recipients in verified community-takeover cases.
