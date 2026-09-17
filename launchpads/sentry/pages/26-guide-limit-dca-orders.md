# Sentry - Guide, Limit & DCA Orders

> Source: https://www.sentry.trading/desktop/guide#orders
> Retrieved: 2026-09-02 (Jina Reader)
> Raw capture: `_raw/jina/sentry-desktop-guide.md`

---

## Limit & DCA Orders[](https://www.sentry.trading/desktop/guide#orders "Copy link to this section")

The swap page isn't just market orders. Flip the `Market / Limit / DCA` tabs above the swap form to place orders that execute on their own — price triggers and recurring buys, filled server-side through the exact same best-venue routing as a manual swap.

## Limit orders

Set a trigger price in USD and a direction, and the order engine handles the rest. The two directions on each side give you all four classic order patterns:

*   **Limit buy** — buy when the price drops to your trigger (buy the dip).
*   **Breakout buy** — buy when the price rises to your trigger.
*   **Take profit** — sell when the price reaches your target.
*   **Stop loss** — sell when the price falls to your floor.

The panel shows a live projection of what you'd walk away with at the trigger. Orders can optionally expire, you can cancel any open order from the list under the form, and a push notification tells you the moment an order fills, fails, or expires.

## DCA orders

Dollar-cost average in or out of any token: pick the amount per fill, an interval (`5m`, `15m`, `30m`, `1h`, `4h`, `12h`, or `1d`), and the number of fills. The first fill executes immediately and the rest run on schedule; the order card tracks progress (e.g. `3/10` fills done).

Every fill — limit or DCA — routes through the same aggregator as a manual swap, with the same 1% platform fee and slippage protection. There is no separate fee for using orders.
