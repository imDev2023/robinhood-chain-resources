# Sentry - The Domains tab and the Filters modal

> Source: https://www.sentry.trading/desktop/tokens (Domains, Filters)
> Retrieved: 2026-09-02 (agent-browser)

---

Screenshots: `screenshots/14-domains-tab.png`, `screenshots/15-filters.png`.

## Domains

The Discover header has three tabs: `TOKENS`, `DOMAINS`, `FILTERS`.

The Domains tab reads:

> REGISTER A .HOOD DOMAIN. Your onchain name on Robinhood - resolves everywhere in the app, sets your identity on the portfolio page.

> DOMAIN MARKETPLACE. Premier .hood names up for auction. First bid starts a 7-day clock; raises beat the leader by 5%+, and late bids extend the deadline. Bids are escrowed and refunded automatically when outbid.

The auction table columns are DOMAIN, STATUS, BID, BIDS, ENDS, with `000.hood` listed `OPEN FOR BIDS` at 0.2500 ETH, 0 bids, `Awaiting first bid`.
The registry the modal writes to is ZNS Connect, `0x8f95ed212F37cDc19f5C0716c24966D9019939Ee` on Robinhood Chain.

## Filters

The Filters modal offers `PAIRS: WETH | STOCKS` and `SORT BY: VOLUME | MARKET CAP | 24H % | NEWEST`.
The WETH and STOCKS split is the same split as the two live launch factories.
