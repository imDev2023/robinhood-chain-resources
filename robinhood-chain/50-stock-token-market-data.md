# Stock Token market data: what answers, measured

> Original writing. Measured 2026-09-23 between 18:40 and 19:20 UTC, mainnet chain 4663 around block 70,753,366.
> Written while building live "stock-market moment" signals for Stock Tokens (the `@mf/stonks` package in the meme-factory project).
> Raw responses: `_raw/stonks-2026-09-23/`.
> Complements `08-stock-token-apis.md` (the issuer's documented schema), `11-chainlink-feed-addresses.md`, `16-token-contracts.md`, `32-explorer-and-data-apis.md` and `45-v4-pools-and-liquidity.md`.

## Headline

The issuer's own REST API, `https://api.robinhood.com/rhj/`, is the cheapest source of Stock Token market moments, and it now serves more than `08` documents.
One keyless call returns every token's trading-halt flag and the day's mint and redeem flow.
`/price-deviations`, empty at the 2026-09-03 capture, now lists tokens trading far from the NYSE close.
Dexscreener remains the tool for pool volume and price, but `tokens/v1` returns only each token's top pool, which undercounts volume by roughly 40% on a busy token.

## 1. Roster: 195 tokens, one addition

`GET https://api.robinhood.com/rhj/assets` returns **195** assets, all `ASSET_STATUS_ACTIVE`, up from 194 on 2026-09-19.
The addition is `QNT`, "Quantinuum Inc. Class A", contract `0xB7EDfE2F33C1aC06830a971dFb559bDe8A2a3d76`.
No symbol was removed and no other address changed against `16-token-contracts.md`.
36 of the 195 carry a `currentMultiplier` other than exactly 1.0.

The payload shape has moved past the `08` schema:

- Each `deployments[]` entry now also carries `networkName` (`"Robinhood Chain"`), `itnEnabled` and `atomicEnabled`, both `false` for every token.
- `tradingCapabilities` is no longer the flat `fractionalTradability` / `allDayTradability` / `extendedHoursFractionalTradability` object. It is nested by session and share type: `market`, `extended` and `overnight`, each with `whole` and `fractional`, each a `TRADING_STATUS_*` value such as `TRADING_STATUS_TRADABLE`.

## 2. `/prices` without a symbol returns every quote, with four undocumented fields

`GET https://api.robinhood.com/rhj/prices` (no `{symbol}`) returned all 195 quotes in one 82 KB response.
`08` only documents the per-symbol form.

Each quote now carries four fields `08` does not list:

| Field | Meaning, as observed |
| --- | --- |
| `dailyHigh`, `dailyLow` | The underlying's session high and low. |
| `mintBurnTokenVolume` | Stock Tokens minted plus redeemed today, in tokens. |
| `mintBurnUsdVolume` | The same flow in USD. META led with $3.11M, NVDA $2.17M, SPY $1.58M. |

**The bulk form zeroes three fields.**
In the bulk response `dailyTradingVolume`, `dailyHigh` and `dailyLow` are `"0"` for all 195 tokens.
The per-symbol form fills them: `/prices/NVDA` returned `dailyTradingVolume` 53,412,925, `dailyHigh` 229.3823, `dailyLow` 224.02 in the same minute.
`isTradingHalt`, `bid`, `ask` and both mint and burn fields are populated in both forms.

Batching symbols does not work: `/prices/AAPL,NVDA` returns `{"code":5,"message":"no whitelisted asset with symbol \"AAPL,NVDA\""}` and `/prices?symbols=AAPL,NVDA` returns `Could not find field "symbols"`.
So a full-roster read of volume and range is 195 calls, well inside the documented 60 requests a second.

## 3. `/price-deviations` is live, and lists a token `/assets` does not

At the 2026-09-03 capture (`38-rhj-price-deviations.md`) this endpoint returned `{"rows":[]}`.
On 2026-09-23 it returned an `asOf` date (2026-09-22) and two rows, each with `nyseClosePrice`, `onchainPrice`, `deviationPct`, `direction` (`DEVIATION_DIRECTION_PREMIUM` or `_DISCOUNT`), `consecutiveDays` and `firstObserved`.

| Symbol | NYSE close | On-chain price | Deviation | Days |
| --- | ---: | ---: | --- | ---: |
| SATS | $95.46 | $1,440.89 | 1,409% premium | 7 |
| WEEK | $99.97 | $49.90 | 50% discount | 7 |

`WEEK`, contract `0xc93a8c440CEa26D7445dF01729f193b27965099f`, is **not** in `/assets`.
Treat `/price-deviations` symbols as possibly outside the active roster rather than joining them blindly.

## 4. `/corporate-actions`: 52 rows, all cash dividends

52 actions: 26 `CORPORATE_ACTION_STATUS_IN_PROGRESS` and 26 `COMPLETED`, every one `CORPORATE_ACTION_TYPE_CASH_DIVIDEND`.
No split or reverse split was listed.
This is still the only forward notice of a multiplier change (`07-building-with-stock-tokens.md`).

## 5. Chainlink: 58 feeds, and the new one is a different product

The directory `https://reference-data-directory.vercel.app/feeds-robinhood-mainnet.json` lists **58** feeds, up from 57 on 2026-09-03.
The addition is `GLD / USD`, proxy `0x470A51258068043bd43dC0a56245625C9fE86eB0`, `assetName` "SPDR Gold Shares • Robinhood Token".

It is not one of the tokenized-equity reference feeds.
It has no "Robinhood" prefix in its name, `docs.attributeType` is `dex_state_price`, `docs.marketHours` is `Crypto`, and it has no `productTypeCode`, where every equity feed says `primaryTokenizedPrice` and `us_equities_24/5`.
On-chain it answers: `description()` "GLD / USD", 8 decimals, `latestRoundData()` 394.30911206 updated 2026-09-23 13:42:56 UTC.
Code that maps feeds to Stock Tokens by `docs.baseAsset` or by name must decide deliberately whether a DEX-state price counts; the reference feeds are the ones named `Robinhood X / USD` or `Robinhood X-USD`.

The 35 equity reference feeds are unchanged.
Walking back rounds is cheap and a useful volatility gauge, since each round is a 0.5% deviation or the 24h heartbeat.
IONQ published 96 rounds in the 12 hours before 19:10 UTC, MSTR 52 and CRCL 53 in 24 hours, while GOOGL published 11 and ORCL 10.

## 6. Dexscreener `tokens/v1` is one pool per token

`GET https://api.dexscreener.com/tokens/v1/robinhood/<up to 30 addresses>` returns **one pair per token**, the top pool, not every pool.
For NVDA it returned one pair with $14.30M of 24h volume, while `token-pairs/v1/robinhood/<NVDA>` returned 30 pairs summing to $24.11M.
The census in `45-v4-pools-and-liquidity.md` was built on `tokens/v1`, so its per-token volume and liquidity totals are top-pool figures, and its "172 pairs with liquidity" is a count of top pools.
For totals, sweep with `tokens/v1` (7 calls for the roster) and follow up with `token-pairs/v1` for the tokens that matter.

The same sweep shows meme tokens quoted against Stock Tokens: the top pool for `P` was `POO / P`.

## 7. Alchemy free tier and viem multicall

viem's `multicall` splits calls into 1 KB chunks by default and sends the chunks as separate `eth_call`s.
Against `robinhood-mainnet.g.alchemy.com` on the free tier, a 35-feed `latestRoundData` sweep sent that way, run a minute after a previous full sweep, drew bodiless HTTP 429s on every retry (the pattern `32` section 8 describes).
With `allowFailure: true` viem then reported every call as failed rather than throwing.
With `batchSize: 0`, which sends one `aggregate3` per step, every later run succeeded (four runs over 15 minutes), including a single call carrying 560 `getRoundData` reads and 125 KB of calldata.
This is consistent with the compute-unit-per-second metering in `32`, but the chunking was not isolated as the only cause.
Check for an all-failed result explicitly; `allowFailure` otherwise turns a throttled RPC into silently empty data.

## 8. Earnings and splits for the underlyings

`https://api.nasdaq.com/api/calendar/earnings?date=YYYY-MM-DD` and `https://api.nasdaq.com/api/calendar/splits` need no key but do need a browser `User-Agent`.
Earnings rows gain `eps` and `surprise` (percent) once a company has reported, so one call per day gives beats and misses as well as the schedule.
Matching rows to the roster by `symbol` works directly; on 2026-09-23 it found COST (reports 2026-09-24 after the close) and BB (before the bell).
