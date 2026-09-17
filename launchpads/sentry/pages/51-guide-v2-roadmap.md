# Sentry - Guide, V2 Roadmap

> Source: https://www.sentry.trading/desktop/guide#roadmap
> Retrieved: 2026-09-02 (Jina Reader)
> Raw capture: `_raw/jina/sentry-desktop-guide.md`

---

## V2 Roadmap[](https://www.sentry.trading/desktop/guide#roadmap "Copy link to this section")

What V1 explicitly leaves out, and how it lands when it ships.

## Solana surface

V1 hides the Solana side entirely behind a feature flag. The wallet still exists on the account, the keys are still encrypted at rest, and the import/export plumbing is intact — only the UI is suppressed. Once we're happy with the Ink-only experience, the flag flips and the rest of the surface re-enters: SOL appears in the price ticker, Solana wallets show in Send/Receive, the Solana segment returns to Set Primary, Register SNS reappears in Settings, and Solana token deploys come back to Create.

## Cross-chain swaps via Relay

Today the Bridge tile moves ETH between mainnet, Ink, and Robinhood Chain in all six directions. Stage 2 expands that through the Relay aggregator: pay in any token on any chain, receive on Ink or Robinhood (or vice-versa), routed through Relay's liquidity. Same swap form, just a wider chain picker.

## Cross-chain composer

Stage 3 is the unifier: one transaction that, e.g., bridges ETH from mainnet, swaps it for SENTRY on Ink, and stakes the result — composed and signed once. Sentry handles the routing under the hood; you just pick the start state and the end state.
