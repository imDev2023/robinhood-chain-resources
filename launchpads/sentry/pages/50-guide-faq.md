# Sentry - Guide, FAQ

> Source: https://www.sentry.trading/desktop/guide#faq
> Retrieved: 2026-09-02 (Jina Reader)
> Raw capture: `_raw/jina/sentry-desktop-guide.md`

---

## FAQ[](https://www.sentry.trading/desktop/guide#faq "Copy link to this section")

Quick answers to the questions we get most. Every answer here is also in the relevant section above, in more depth.

### Do I need a wallet extension to use Sentry?

No. An EVM wallet is generated for you at signup. You can also import your own keys, or use [/swap](https://www.sentry.trading/swap) with your own browser wallet and no account at all.

### Is Sentry custodial?

Generated and imported keys are stored encrypted on Sentry's servers and used only to sign transactions you initiate. You can export every key at any time, which makes the arrangement fully exitable. Connected external wallets (MetaMask, Rabby, WalletConnect) are never custodied at all — Sentry can read them, only you can spend from them. The /swap page is pure self-custody.

### How does the aggregator get me a better price?

It quotes Uniswap V3 (all fee tiers), Uniswap V2, Uniswap v4 Doppler pools, and PancakeSwap V3 simultaneously on Robinhood Chain (and every Uniswap V3 tier on Ink), then executes on whichever returns the most output. You see the winning venue with your quote.

### What does it cost to trade?

1% of the swap input, on both chains, already included in the quote you see, plus network gas (fractions of a cent on both L2s).

### How do I make money from a token I launched?

On current launches (both chains) your share is paid **on every single trade, directly to your wallet** — 1.0% of every swap at the permanent 1.7% fee floor on a WETH launch, and far more during the launch window while the anti-snipe curve is elevated. Nothing to collect. Legacy V3 launches accrue instead: collect via `Wallet`>`My Tokens`, or let Sentry's scheduled sweeps pay you automatically. See [Creator Rewards](https://www.sentry.trading/desktop/guide#creator-rewards).

### How does Sentry stop launch snipers?

Every new pool opens at a **40% trade fee** that decays to a permanent 1.7% floor over ~17 minutes — long enough to outlast the bot frenzy, not just the first block. The fee is settled per swap, so sniper volume pays the creator, deepens the locked liquidity, and funds the protocol in the sniper's own transaction. Full mechanics in [Anti-Snipe Protection](https://www.sentry.trading/desktop/guide#anti-snipe).

### Do whitelisted launch wallets get free or early tokens?

No. Whitelisted wallets buy from the same public pool at the same market price as everyone else — they just pay the 1.7% floor fee instead of the anti-snipe premium, on buys only. Sells are never exempt, the floor fee always applies, and the list is frozen on-chain at pool creation where anyone can verify it.

### Can the liquidity be pulled (“rugged”)?

No. The launch position is held permanently by the SentryLPVault, an immutable contract with no withdrawal function and no upgrade path. The token contract is renounced at deploy, with no mint, pause, or blacklist.

### Did the team keep any supply?

No. 100% of the 1,000,000,000 supply goes into the pool. Any tokens the creator holds were bought on the open market; the optional dev buy is a normal swap at market price.

### Can I set limit orders or DCA?

Yes. The `Market / Limit / DCA` tabs on the swap page cover limit buys, breakout buys, take profit, stop loss, and scheduled recurring buys or sells. Fills execute server-side against live executable prices and push a notification when they land. See [Limit & DCA Orders](https://www.sentry.trading/desktop/guide#orders).

### How does the referral program work?

Generate a code in `Settings`>`Referral Program` and share your link. You earn **the entire 1% platform fee** on every swap your referrals make, paid on-chain to your wallet per swap. See [Referral Program](https://www.sentry.trading/desktop/guide#referrals).

### What is the SENTRY token?

The platform's own token (WETH-paired on Robinhood Chain). Holding it pays you **WETH reflections on every SENTRY trade**, and 40% of the protocol's revenue from every launch on the platform is compounded into permanently locked SENTRY liquidity. See [The SENTRY Token](https://www.sentry.trading/desktop/guide#sentry-token).

### What's the difference between boosting and featuring?

Boosting (⚡) puts a token at the front of the Trending marquee AND fires a push notification to every subscribed user; it's stackable by anyone. Featuring (⭐) pins the token in one of three gold slots on the runner bar; it's placement only, no notifications. Both run $25 to $125.

### Why did I get a notification about a token I never starred?

Boost alerts and big moves on boosted tokens are broadcast to all subscribers. Watchlist alerts are only for tokens you starred. The single toggle in Settings controls all push for the device.

### How many tokens can I watchlist?

Five. Each alerts you on 10%+ moves within an hour, re-checked every 10 minutes, with no cooldown while it keeps moving.

### How do I register a .hood or .ink name?

Switch the app to the matching chain, then `Ecosystem`>`Domains`>`Register a name`. Search the label, pick years (1 to 5 for .hood, up to 10 for .ink), and confirm the live ETH quote.

### Can I use my domain NFT as my profile picture?

Yes. `Wallet`>`NFTs`> tap the domain >`Set as PFP`. It renders as a hexagon to show verified ownership.

### What does changing my username cost?

$10, charged in ETH from your primary wallet. Your old handle is released immediately and anyone can claim it.

### I lost my password. Can support reset it?

Only if your account has a **verified email** (added in `Settings`>`Account`>`Verification Status`): contact the team and prove control of that email — plus your 2FA code if enabled — and your password can be reset. Without a verified email there is nothing to prove identity against, so there is no reset. Either way, export your private keys while you have access; the keys, not the password, are your funds.

### Does 2FA protect passkey logins?

No. 2FA gates password logins only. A passkey is already two factors (device + biometric), and X sign-in proves control of the linked X account.

### How fast is bridging?

Usually seconds, via Relay. The Activity tab tracks every bridge with a receipt link.

### Are Bankr tokens Sentry tokens?

No. Bankr is a separate launchpad. Sentry lists Bankr tokens (the grid badge shows the launchpad) and routes trades to their Uniswap v4 pools with the same 1% fee, but their launch mechanics are Bankr's, not the Sentry sequence described in [Launch Mechanics](https://www.sentry.trading/desktop/guide#launch-mechanics).

### How do I integrate Ink wrapped-xStock pairs?

Use `SentryStockRouterInk` at `0x1b4D919149912c9781b086C8242729EE317631C8` against the canonical Uniswap v4 PoolManager. Pair the ERC-4626 wrapper, never the raw xStock. Addresses, ABIs, pool keys, and the quote hop are in [Ink xStocks (Developers)](https://www.sentry.trading/desktop/guide#ink-xstocks).

### Where can I verify any of this?

Everything is on-chain. Explorers and public subgraphs are listed in [Chains & Contracts](https://www.sentry.trading/desktop/guide#chains-contracts), and the [Ecosystem Stats](https://www.sentry.trading/desktop/guide#stats) section reads live protocol totals from those same public sources.

### Can my AI assistant read this guide?

Yes. The whole guide ships as a single markdown file at [sentry.trading/sentry-guide.md](https://www.sentry.trading/sentry-guide.md). Download it and drop it into any AI chat as context.
