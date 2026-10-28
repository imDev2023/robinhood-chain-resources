# TradingView's widgets for a token's underlying market, checked

> Original writing, checked 2026-10-28 for the Stoker project (Solana), where each tokenized stock's page now charts the stock it tracks.
> How TradingView's free widgets are embedded today (web components), where their attributes are documented and where they are not, how to find the right symbol for a stock, a fund or a coin without guessing from a name, and the look-alike symbols that bite.
> Complements `50-stock-token-market-data.md` (the issuer's own prices for Robinhood Chain's stock tokens): the same mapping charts the 195 tokenized equities here, since each carries its underlying's ticker.

## 1. The widgets are web components now

TradingView's widget docs (`https://www.tradingview.com/widget-docs/`) offer two formats: the recommended web component and the older iframe embed (`s3.tradingview.com/external-embedding/embed-widget-*.js` with a JSON block inside the script tag).
A web component is one module script plus a custom element, for example `<script type="module" src="https://widgets.tradingview-widget.com/w/en/tv-advanced-chart.js"></script>` and `<tv-advanced-chart symbol="NASDAQ:NVDA" interval="1D"></tv-advanced-chart>`.
The element fills its container, so the container needs a height.
It follows the page's `color-scheme` CSS property for light and dark (a `theme` attribute pins one), reads its colours and font from `--tv-widget-*` custom properties on any ancestor (`--tv-widget-background-color`, `--tv-widget-text-color`, `--tv-widget-accent-color`, `--tv-widget-font-family` and more, listed on the docs' "Set styles and themes" page), and a `transparent` attribute drops its background.
Symbol links inside a widget can be pointed at your own pages with `symbol-url="https://example.com/stocks/{tvexchange}/{tvsymbol}"` or intercepted with the `tv-link-open` event; the attribution and TradingView's own links cannot be changed without an agreement.
The Advanced Chart, Screener, Heatmap and Economic Calendar components embed TradingView's hosted widget as an iframe inside the shadow root (the style tokens still reach it); the Mini Chart and the tickers draw in the page.

## 2. Where the attributes are, and where they are not

The embed code in the docs' wizard shows only after a TradingView sign-up, and the module scripts answer HTTP 403 to `curl`, whatever the `User-Agent`.
The docs page itself renders a live preview of the element, so a browser session gives the attribute list: `customElements.get("tv-advanced-chart").observedAttributes` read on 2026-10-28 is `white-label, symbol, interval, time-frame, hide-legend, timezone, chart-type, extended-hours, hide-volume, studies, compare-symbols, watchlist, allow-symbol-change, hide-top-toolbar, show-drawing-toolbar, hide-snapshot-button, show-date-ranges, show-details, show-hotlist, show-popup-button, popup-width, popup-height, store-settings`; a boolean attribute is on when present (`show-date-ranges=""`).
The preview's element read `<tv-advanced-chart allow-symbol-change="" symbol="NASDAQ:AAPL" interval="1D" timezone="Etc/UTC" chart-type="candles" studies="[]" compare-symbols="[]" popup-width="1000" popup-height="650">`.
In the UI test suite of a site that embeds one, serve the module script an empty body (Playwright `route.fulfill`), so the element is never defined, the frame stays on its own loading state and no live data lands in a pixel baseline; an aborted request logs a failed load to the console instead.

## 3. Finding the symbol without guessing from a name

The symbol search the site itself uses, `https://symbol-search.tradingview.com/symbol_search/v3/?text=NVDA&hl=0&lang=en&search_type=stocks&domain=production&sort_by_country=US`, answers `curl` when the request carries `Origin: https://www.tradingview.com` and a browser `User-Agent`; one request a few hundred milliseconds apart went through for 150 tickers.
Each result has `symbol`, `exchange`, `prefix` (use `prefix` when present, else `exchange`, as the venue half of `VENUE:TICKER`), `type` (`stock`, `fund`, `dr`, `spot`, `index`), `typespecs`, `country` and `is_primary_listing`.
`search_type=stocks` returns no funds: SPY, QQQ, GLD and the ETFs come back only as Argentine CEDEARs (`BCBA:`) unless `search_type=funds` is asked, where they are `AMEX:SPY`, `NASDAQ:QQQ`, `AMEX:GLD` (TradingView writes NYSE Arca's funds as `AMEX`, Cboe's as `CBOE`, for example `CBOE:DRAM`).
A bare ticker is ambiguous: `BOT` is Botanix on ASX for the stock search, and RoboStrategy (`NASDAQ:BOT`, a closed-end fund) only when searched by name.
For a coin, `search_type=crypto` lists its markets by exchange; TradingView's own index across exchanges is the `CRYPTO` venue (`CRYPTO:SOLUSD`, `CRYPTO:BTCUSD`), present for the larger coins and absent for many (JUP, PENGU, TRUMP have only exchange pairs, such as `COINBASE:PENGUUSD` or `KRAKEN:JUPUSD`).

## 4. Look-alikes

The `CRYPTO` index is keyed by ticker, so a ticker two projects share names the older one: `CRYPTO:METUSD` is Metronome, not Meteora (`COINBASE:METUSD` is), `CRYPTO:SKRUSD` is Saakuru, not Seeker (`COINBASE:SKRUSD`), and `CRYPTO:BPUSD` is BunnyPark, not Backpack.
A wrapped coin may have an index of its own or not: `CRYPTO:WBTCUSD` exists, Coinbase's cbBTC has none (only a Pyth oracle feed, `PYTH:CBBTCUSD`, and DEX pairs), so cbBTC charts as Bitcoin.
Pyth's oracle feeds appear in the stock search too (`PYTH:NVDA`, type `stock`, typespecs `crypto, oracle`): a feed, not the exchange market.
A collectible or a small Solana token often appears only as a DEX pair on another chain (`UNISWAP4BASE:SV151ETH_DA4118.USD` for a Solana collectible's Base twin): not the asset itself.
So the map from a token to its chart is data checked by hand, keyed by the issuer and its ticker for a tokenized stock and by mint for a coin, with nothing derived from a token's name; the Stoker map (`apps/api/src/quotes/markets.ts` in `imDev2023/Stoker-Markets`) holds 95 stocks and about 40 coins checked this way.

## 5. For Robinhood Chain

Robinhood's stock tokens carry their underlying's ticker, and `50-stock-token-market-data.md` records the issuer's own prices and halt flags.
The same per-ticker check gives each token its TradingView symbol (the primary US listing from the stock or fund search), and a `<tv-advanced-chart>` on a token's page then shows the stock's own market beside the token's on-chain price, which trades around the clock while the stock trades in market hours.
