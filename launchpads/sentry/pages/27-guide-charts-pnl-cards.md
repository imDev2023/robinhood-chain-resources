# Sentry - Guide, Charts & PNL Cards

> Source: https://www.sentry.trading/desktop/guide#charts-pnl
> Retrieved: 2026-09-02 (Jina Reader)
> Raw capture: `_raw/jina/sentry-desktop-guide.md`

---

## Charts & PNL Cards[](https://www.sentry.trading/desktop/guide#charts-pnl "Copy link to this section")

Every token gets a detail page: chart, multi-timeframe stats, liquidity and holder data, social links, and a live trades feed.

## The token page

*   Price and market cap chart with timeframe percentage chips.
*   Price, FDV, 24h volume, liquidity, pool TVL, total supply, holder count, and pool age.
*   Top-10 holders with role tags (Creator / Pool / Locked) so you can see at a glance where supply sits.
*   24h buy/sell pressure bar (Robinhood Chain).
*   A live trades feed: every swap in the pool with direction, size, USD value, and the trader's address.
*   A **Share** button that copies a deep link (`/tokens?chain=…&token=0x…`) that opens the token page on any device.
*   The **watchlist star** — see [Watchlist & Alerts](https://www.sentry.trading/desktop/guide#watchlist).

## The custom chart (Robinhood Chain)

Robinhood Chain tokens get Sentry's own candlestick chart: timeframes 1m, 5m, 15m, 30m, 1h, 4h, 12h, and 1d, a price/market-cap axis toggle, an OHLC crosshair legend, and a live edge that folds in swaps from Sentry's own subgraph within seconds. If you have traded the token, your own buys and sells are drawn on the candles as arrow markers with your avatar, plus a dashed average-entry line. Ink tokens currently use an embedded DexScreener chart.

## PNL cards

Once you have trades on a token, two share exports appear in the chart toolbar:

*   **Share** — a chart screenshot with a PNL banner composited on top (your markers included).
*   **PNL** — a standalone card with your profit/loss in USD and percent, buy and sell counts (a diamond marks never-sold positions), your average entry expressed as market cap, your Sentry handle and avatar, and your linked X handle.

Both let you copy the image, download it, or post it to X in one tap.
