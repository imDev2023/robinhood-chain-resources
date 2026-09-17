# Long - Dune dashboard, LONG on Robinhood Chain

> Source: https://dune.com/natan_benish2001/long-on-robinhood-chain
> Retrieved: 2026-09-02 (Jina Reader)
> Raw capture: `_raw/jina/dune-dashboard.md`, `_raw/dune/query-*.md`, `_raw/dune/query-urls.txt`

---

## What it is

The team's own analytics, published by the co-founder under the Dune handle `natan_benish2001` and updated 27 days before capture.
Every widget is backed by a public query, and all 17 of them are captured verbatim as `pages/34` to `pages/50`.
The dashboard itself is `pages/33-dune-dashboard-long-on-robinhood-chain.md` and `screenshots/08-dune-dashboard.png`.

## How the queries define a Long launch

`query_8032167` (`pages/35`) is the foundation: it lists every `LaunchCreated` event from the two launchers, `0x22e99278...` (LongLauncher) and `0x9c88f06b...` (TickerAirlockFactory), with the asset, numeraire, creator, ticker and transaction hash.
`query_8032178` (`pages/36`) maps each launch to its Uniswap v4 pool id.
`query_8032229` (`pages/38`) collects every swap and flags `is_buyback` rows, which are the Rehype hook's own swaps (`sender = fee manager`), so that user volume can be reported separately from gross volume.
`query_8032188` and `query_8391616` (`pages/37`, `pages/50`) price the numeraires: Chainlink aggregators for the stocks that have a feed, and on-chain Rialto, Arcus and Robinhood settlement prints for those that do not.

## Numbers that rendered

The `Stock Token Leaderboard` table did render (`pages/33`).
Top rows, gross volume in USD across all Long pools per stock token: NVDA $128.0M (30.1% of the total, 599,172 swaps, 32,000 traders, 821 tokens), SPCX $33.1M, HIMS $28.9M, MU $27.5M, AAPL $25.0M, TSM $20.7M, MSTR $16.9M, GLD $15.5M, GME $15.3M, MSFT $12.1M.
WETH is only $4.2M, under 1% of the total, which confirms that Long volume is stock-token volume.

The `Top assets` table in `pages/42` lists AI at $105.5M gross volume, BONER $27.0M, MOO $25.4M, SPACEHOOD $21.7M, AU $15.8M, SAYLORMOON $15.6M, CLIPPY $10.0M.

The headline counters (total RWA volume, 24h volume, tokens launched, traders, stock TVL) are drawn client-side and did not come through any capture method.
