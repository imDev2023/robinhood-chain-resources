# Backrunning on chain 4663, measured

> Original writing. Measured 2026-09-19 over blocks 66,412,888 to 67,276,887, a contiguous 24.0 hours, via a dRPC archive endpoint.
> 2,962,730 Uniswap v4 `Swap` events across 17,873 pools and 1,970,580 transactions. 8,555 of 8,555 log windows fetched, none failed.
> Complements `44-uniswap-v4-hooks.md`, which covers what reaches hook code, and `45-v4-pools-and-liquidity.md`, which has the pool census.

## Headline

The sequencer feed publishes sealed blocks about 107 ms before RPC serves them, against a 0.10 s block time. That is roughly one block of lead: enough to react to someone else's trade, not enough to get in front of it. Sandwiching is therefore unreachable here, which is settled separately.

Reacting to a trade *is* reachable, and it happens:

> **About 0.41% of large trades carry a backrun-shaped reaction one block later.** 95% CI [0.220%, 0.608%].

It is concentrated rather than spread evenly. Of the 847 pools with enough large trades to test individually, 64 (7.6%) show the effect against 19 (2.2%) showing the opposite, where chance alone would give about 2.5% on each side.

## The shape, which is the actual evidence

Excess opposing flow around large trades, forward window minus the mirrored backward window, paired within each victim:

| lag (blocks) | excess | 95% CI |
| ---: | ---: | --- |
| **1** | **+0.00136** | **[+0.00072, +0.00200]** |
| 2 | −0.00097 | [−0.00159, −0.00036] |
| 3 | −0.00144 | [−0.00203, −0.00084] |
| 4 | −0.00126 | [−0.00193, −0.00059] |

Positive at exactly one block, negative at every lag after. A reaction to a trade you have just seen can only land at the earliest lag the chain allows, and one block is exactly what a 107 ms lead against 0.10 s blocks buys. Beyond that, ordinary momentum takes over and flow continues in the victim's direction instead of against it. An artefact of method would not flip sign at precisely the predicted lag.

## Method, in one paragraph

Counting "opposing trades that follow a trade" proves nothing; market makers generate that signature harmlessly all day. So the measurement is an asymmetry: a backrunner can act one block *after* a trade but never one block *before* it, while innocent flow is symmetric in lag. Lag −k is therefore the control arm, drawn from the same pools, addresses and hours. Conditioning on the victim being a top-decile trade for its pool and counting only sub-decile flow around it keeps the reactor out of the victim sample. Both controls pass: randomising trade directions gives −0.00003 with a CI containing zero, and injecting synthetic backruns at known rates gives a response linear to within 5% across a twentyfold range, which is what converts the raw excess into the 0.41% figure.

## What this does not say

- It measures a *signature*, not value extracted. Nothing here prices the trade.
- It identifies nobody. The v4 `Swap` event's sender is the router, not the trader.
- It cannot distinguish a feed reader from a fast RPC poller; both react at the earliest available block.
- 0.41% is a floor. The calibration assumes an idealised reactor, exactly one block later and always opposing, so real backruns that are later, partial or split produce less excess each and the true rate is higher.
- It says nothing about extraction that never touches a v4 pool.

## For integrators

Backrunning here is arbitrage-shaped. It mostly pushes a pool's price back toward the market, so the cost falls on liquidity providers as adverse selection rather than on the trader as a worse fill. That is the ordinary cost of providing AMM liquidity on any chain, not a chain-4663 pathology.

A Uniswap v4 hook cannot prevent it: the reaction is a separate transaction in a later block, and every hook callback has already returned by then. Mitigations that do work, such as volatility-keyed dynamic fees or LVR-aware pricing, are substantial mechanisms and should be weighed against a rate this small.

## Provenance

Settled as ADR-0003 in the `v4-hooks` project (`docs/adr/0003-backrunning-on-4663.md`), with the reproducible survey in `research/measurements/backrun-survey/`.
