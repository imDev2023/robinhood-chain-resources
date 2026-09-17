# Sentry - Token detail pages, sixteen captured views

> Source: https://www.sentry.trading/desktop/tokens (token rows)
> Retrieved: 2026-09-02 (agent-browser screenshots)

---

A token page shows the pair, the creator handle, 5m / 1h / 6h / 24h change, a TradingView chart with social markers, 24h buy and sell pressure, price, FDV, 24h volume, liquidity, pool TVL and total supply, plus Share, comment, watchlist, boost, vote and Swap actions.

| screenshot | token | pair | note |
| --- | --- | --- | --- |
| `screenshots/02-sentry-token-quotron.png` | QUOTRON, Quotrons | WETH | by @cruelhand, $12.93M FDV, 837 txns in 24h, the largest market on the list |
| `screenshots/17-token-01-.png` | HOME, Hood Of Meme | WETH | by @cruelhandeth, no market data yet, the launch decoded in `_raw/blockscout/tx-0xee98627a...json` |
| `screenshots/18-token-02-.png` | CHILL, Netflix and Chill | NFLX stock pair | by @cruelhand, $62.3K FDV, the highest-volume Sentry launch at 10,697 WETH |
| `screenshots/19-token-03-.png` | SENTRY | WETH | by @sentrydev, $4.08M FDV |
| `screenshots/20-token-04-.png` | ROBIN, Robin | WETH | by @sentrydev, verified badge |
| `screenshots/21-token-05-.png` | WIF, RobinWifHat | WETH | by @cruelhand, $3.39M FDV |
| `screenshots/22-token-06-.png` | BSENTRY, Baby Sentry | WETH with reflections | by @poipojopo, the launch decoded in `_raw/blockscout/tx-0x95d32514...json` |
| `screenshots/23-token-07-.png` | BIGCHUNG, Big Chungus | WETH | by @nobody |
| `screenshots/24-token-08-.png` | SARD, Sardines | WETH | by @sardines |
| `screenshots/25-token-09-.png` | BOINK | WETH | by @boink, verified badge |
| `screenshots/26-token-10-.png` | 6900, RHC6900 | WETH | by @lyon |
| `screenshots/27-token-11-.png` | MIRA | WETH | by @nobody |
| `screenshots/28-token-12-.png` | STEST, Sentry Test | WETH | by @sentrydev, one lifetime txn |
| `screenshots/29-token-13-.png` | HOME, Hood Of Meme | WETH | second capture of the same page |
| `screenshots/30-token-14-.png` | SILVER INU | SLV stock pair | by @ryoshiresearch, the launch decoded in `_raw/blockscout/tx-0x561a23fa...json` |
| `screenshots/31-token-15-.png` | SILVER INU | SLV stock pair | a second Silver Inu deployment, `0x54a39956A2eA5669049Af0fa54eB6C1ffEB4845a` |

The full 183-row token database behind these pages is captured verbatim in `_raw/api/supabase-sentry_tokens_robinhood.json`, and the Ink equivalent in `_raw/api/supabase-sentry_tokens_ink.json`.
