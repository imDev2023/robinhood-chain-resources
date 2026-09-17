# Robinhood RHJ - Price Deviations

> Source: <https://docs.robinhood.com/rhj/price-deviations/>
> Retrieved: 2026-09-03 (page MDX source extracted from the rhj docs bundle `index-BHBqPiOr.js`; the "Current Deviations" table is a client-side React component whose data source, `https://api.robinhood.com/rhj/price-deviations`, returned `{"rows":[]}` at capture, so the page renders its empty state)
> The server-rendered HTML for this route contains only the placeholder `Loading current price deviations…`. Raw JSON: `_raw/rhj-docs-2026-09-03/api-price-deviations.json`. Component source: `_raw/rhj-docs-2026-09-03/index--rR63sSx.js`.

---

# Price Deviations

A price deviation occurs when a Stock Token trades at a significant premium or discount to the expected price of its underlying asset. Robinhood discloses a deviation on this page when a token's on-chain price differs from its underlying's reference price by 5% or more for seven consecutive trading days.

On-chain token prices can deviate for a variety of factors, including differences in liquidity, variances in mint and burn pricing, and market conditions.

Deviations are assessed at the end of each business day (five days a week), comparing the NYSE closing price for the underlying — benchmarked to the nearest block — against the average on-chain price from a reputable source over the trailing seven-day period.

## Current Deviations

No tokens currently meet the deviation threshold.

---

The table this page renders when the feed is non-empty has seven columns: `Symbol`, `NYSE Close`, `On-chain Price`, `Deviation`, `Direction`, `Consecutive Days`, `First Observed`. `Direction` is one of `Discount`, `At par`, `Premium`, and signs the deviation percentage `-` or `+` respectively. Prices render as `$<amount>`, dates as `YYYY-MM-DD`, and the table is preceded by an `As of <date>` line taken from the payload's `asOf` field. The two other states are `Price deviation data is temporarily unavailable. Please check back later.` on a fetch error and `Loading current price deviations…` while fetching.

---

## How this relates to the on-chain multiplier

*Original writing. Everything above this line is a capture.*

This section compares the page against `07-building-with-stock-tokens.md` (sections "Prices" and "Multiplier Conversion") and against `31-onchain-verification.md` (sections "Chainlink feeds" and "Multipliers at block 53,117,114").

**What it adds.**

`07` says the Chainlink feed price "already includes the corporate-action multiplier (dividends, splits), so the value you read is the token's full price".
`ROBINHOOD-CHAIN.md` section 9 goes further and warns that REST `/rhj/prices` returns the raw underlying-equity quote while the Chainlink feed returns the multiplier-adjusted token price, so the two must be reconciled through `currentMultiplier` before they can be compared.

This page introduces a **third** price surface that neither file records: an "on-chain price from a reputable source", averaged over seven days and compared against the NYSE close of the underlying "benchmarked to the nearest block".
That is a market price, that is, what the token actually changes hands for on a DEX or propAMM, not the oracle price and not the underlying quote.
The multiplier is the exact quantity that separates the second surface from the third: a token whose multiplier has drifted above 1.0 represents more than one underlying share, so a naive token-price-versus-share-price comparison would show a spurious premium equal to the multiplier.
The page does not say whether its comparison is multiplier-adjusted.
That is a material ambiguity in a disclosure whose whole purpose is to declare a 5% divergence, because six of the ten non-unity multipliers in `31` are well under 0.1% and would be invisible, but **CRWD sits at exactly 4.0 and CCL at 1.0215**.
A CRWD token trading at four times the NYSE close of one CRWD share is trading at par; measured without the multiplier it is a 300% premium.

**Where it contradicts nothing, and what it leaves unexplained.**

Nothing here contradicts `07` or `31`.
The feed is empty at capture, which is consistent with `31` finding no token in an anomalous state, but an empty feed is also what an unpopulated feed looks like, so it is weak evidence.

Three things are left unexplained and are worth flagging as unresolved rather than padding them out:

1. Whether the on-chain price and the NYSE close are compared per token or per underlying share, that is, whether `uiMultiplier()` is applied before the 5% test. Given CRWD's 4.0, this is not a hypothetical.
2. Which "reputable source" supplies the on-chain price. It is not named, and it is not obviously the Chainlink feed, since `31` records that only 35 of the 194 Stock Tokens have a Chainlink equity feed at all. For the remaining 159 there is no first-party on-chain price surface in this archive, so the source must be something else and is undisclosed.
3. What follows a disclosed deviation. The page describes publication and nothing else: no redemption right, no halt, no adjustment. `29-terms-of-service.md` and the disclaimer in `06-stock-tokens.md` do not fill this in either.

I did not verify the deviation methodology against any live price, and the empty feed means the table format above is reconstructed from the component source rather than observed rendered.
