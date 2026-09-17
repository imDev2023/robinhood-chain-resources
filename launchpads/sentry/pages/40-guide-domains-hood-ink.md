# Sentry - Guide, Domains: .hood & .ink

> Source: https://www.sentry.trading/desktop/guide#zns-domains
> Retrieved: 2026-09-02 (Jina Reader)
> Raw capture: `_raw/jina/sentry-desktop-guide.md`

---

## Domains: .hood & .ink[](https://www.sentry.trading/desktop/guide#zns-domains "Copy link to this section")

Claim a human-readable name for your wallet via [ZNS](https://zns.bio/): `.hood` on Robinhood Chain, `.ink` on Ink. Once registered, your address shows up around the app as `yourname.hood` instead of `0x71…7866`.

1.   Open `Ecosystem`>`Domains`>`Register a name` (or `Settings`>`Register ZNS`). The modal registers the TLD matching your active chain.
2.   Type the name you want: just the label, no suffix (“sergio”, not “sergio.hood”). Pick a duration: **1 to 5 years** for `.hood`; **1, 2, 3, 5, or 10 years** for `.ink`.
3.   Hit `Search availability`. If the name is free, the modal pulls a live price quote from the registry contract and shows the total ETH cost for your selected duration.
4.   Hit `Register`. Your primary EVM wallet signs the registration and pays the ETH fee; the domain NFT lands in that wallet.

## What a domain does

*   Your address displays as the domain across Sentry: wallet header, wallet switcher, send confirmations, holder lists.
*   Typing a domain into the Send flow resolves it to the owner's address.
*   The domain is an ERC-721 in your wallet's NFTs tab, and you can [set it as your PFP](https://www.sentry.trading/desktop/guide#profile).

## Premier .hood auctions

Sentry holds a set of one-of-one premier `.hood` names (satoshi, btc, eth, gm, stonks, degen, 777, and more) and auctions them in the Ecosystem tab. Every auction opens at **0.25 ETH**, and the clock only starts when someone bids: the first bid triggers a **7-day countdown**. Each new bid must beat the leader by at least **5%**, and bids in the final 10 minutes extend the deadline by 10 minutes (anti-snipe). Bids are escrowed on-chain from your in-app wallet; when you're outbid you're refunded automatically and in full. When the countdown ends, the name NFT transfers to the winner automatically.
