# Sentry - Guide, Disclaimers

> Source: https://www.sentry.trading/desktop/guide#disclaimers
> Retrieved: 2026-09-02 (Jina Reader)
> Raw capture: `_raw/jina/sentry-desktop-guide.md`

---

## Disclaimers[](https://www.sentry.trading/desktop/guide#disclaimers "Copy link to this section")

The legal and operational limits of what Sentry is. Read these before using the app — they apply to every action you take through it.

## Sentry is software, not a financial service

Sentry is a non-custodial trading interface and token-launch tool. We don't custody user funds, we don't broker trades, we don't issue tokens, and we don't provide investment advice. All swaps are executed on public on-chain DEXes; all token deploys go to immutable, renounced contracts as documented in [Launch Mechanics](https://www.sentry.trading/desktop/guide#launch-mechanics).

## Tokens are user-deployed and unvetted

Anyone with a funded Sentry Account can deploy a token through the Create flow. The fact that a token appears in our trending list, search picker, or featured slots does **not** constitute endorsement, recommendation, or warranty by Sentry. We don't audit deployed contracts beyond the bundled launch sequence, we don't verify project identities, and we don't filter out tokens we'd consider speculative or low-quality. Evaluate anything you trade — the launch mechanics protect you against rug-pull patterns in the contract, but they don't protect you against a project simply failing.

## No investment advice

Nothing in this app, this guide, or any official Sentry channel (X, Telegram) is investment advice. Trades are user-initiated. Token prices are volatile and can go to zero. You are solely responsible for evaluating any token you trade or deploy, and for any tax consequences of those actions in your jurisdiction.

## Self-custody means you carry the risk

Non-custodial software means _you_ control the keys — and you carry the consequences of that control. We can't reset a forgotten password, we can't reverse a transaction you sent, we can't recover funds sent to a wrong address, and we can't undo a trade. That's the whole point of self-custody, but it's worth stating explicitly.

## Third-party services

Sentry routes through several independent infrastructure providers: Uniswap V3 for Ink swaps; canonical Uniswap V3, Uniswap V2, Uniswap v4, and PancakeSwap V3 contracts for Robinhood Chain swaps; [Relay Protocol](https://relay.link/) for cross-chain bridging; [ZNS](https://zns.bio/) for `.hood` and `.ink` domain registrations; DexScreener and GeckoTerminal for market data and chart candles; Goldsky for subgraph indexing; and Blockscout explorers for on-chain reads. These are independent third parties operating their own contracts and infrastructure. Sentry is not responsible for their availability, behavior, or security beyond the integration layer, and market data shown in the app is provided as-is by those sources.

## Platform fees

Sentry earns revenue from a 1% platform fee on in-app swaps on both chains, from the treasury's share of locked-LP trading fees on launched tokens (30% on Robinhood Chain, 35% on Ink; the majority goes to each token's creator), and from paid visibility products (boosts and featured slots) and paid username changes. Swap quotes shown in the app are net of the platform fee. Full details in [Platform Fees](https://www.sentry.trading/desktop/guide#fees).

## Paid placement is not endorsement

Boosted and featured tokens are paid placements purchasable by anyone, not picks by Sentry. A lightning bolt or a gold featured slot means someone paid for visibility; it says nothing about the token's quality, safety, or prospects.
