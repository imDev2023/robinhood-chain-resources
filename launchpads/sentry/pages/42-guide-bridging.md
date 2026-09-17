# Sentry - Guide, Bridging

> Source: https://www.sentry.trading/desktop/guide#bridging
> Retrieved: 2026-09-02 (Jina Reader)
> Raw capture: `_raw/jina/sentry-desktop-guide.md`

---

## Bridging[](https://www.sentry.trading/desktop/guide#bridging "Copy link to this section")

Move ETH between Ethereum mainnet, Ink, and Robinhood Chain without leaving Sentry. The Bridge tile on the wallet page routes through [Relay Protocol](https://relay.link/). Same EVM address on every chain, so there's no recipient entry: you always bridge to yourself. All six directions are supported: mainnet to either L2, either L2 back to mainnet, and Ink ↔ Robinhood.

1.   Send ETH to your Sentry address on **Ethereum mainnet** (your address is the same on every EVM chain). Sentry detects the inbound balance automatically.
2.   Tap the `Bridge` tile on the wallet page. Pick the From and To chains; the sheet quotes the Relay route with the estimated output (routing cost and gas are inside the rate shown).
3.   Hit `Bridge`. Sentry signs the source-chain tx, hands it to Relay, and shows live status pills: `depositing` → `pending` → `success`. A small gas reserve always stays on the source chain so you can't bridge yourself out of gas.
4.   On success, the ETH lands in the same wallet on the destination chain. The bridge shows up in your Activity feed with a link to the full receipt on `relay.link`.
