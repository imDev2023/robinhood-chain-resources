# Sentry - Guide, Telegram Bots

> Source: https://www.sentry.trading/desktop/guide#telegram-bots
> Retrieved: 2026-09-02 (Jina Reader)
> Raw capture: `_raw/jina/sentry-desktop-guide.md`

---

Screenshots: `screenshots/07-guide-telegram-bots.png`.

## Telegram Bots[](https://www.sentry.trading/desktop/guide#telegram-bots "Copy link to this section")

Sentry runs two official Telegram bots: **@SentryTG_Bot** (trade, launch, and broadcast from a chat) and **@SentryBuyBot** (buy alerts for your project's group). Both are free to add; they use the same engine, routes, and fees as the app.

## @SentryTG_Bot — Sentry Telegram Trading

*   **Trade from DMs** on Robinhood and Ink: paste any contract address to buy (USD presets), sell with percent buttons, track positions and live PNL, view history, and withdraw — powered by the same best-venue routing and 1% platform fee as the app.
*   **Your wallet, two surfaces.** Press START to create a dedicated trading wallet, or link your Sentry account from **Settings → Account → Connect Telegram**. Linking adopts your bot wallet into the app — it appears in your wallet list, where you can export its key. Start in the bot first and link later; nothing is lost either way.
*   **Launch tokens** with the Token Deployment Wizard: name, symbol, logo, links, and an optional dev buy — launched through the Sentry factory with LP locked and creator fees accruing to you, exactly like launching in the app.
*   **Coin Emoji ($20):** mint an animated spinning coin of your token's logo into the public _Sentry Tokens_ emoji packs. The trading bot shows it on your token's cards, and @SentryBuyBot turns buy alerts into a wall of your spinning coin. Available in the wizard, after any launch, and in the app's create form. Paid in ETH from your wallet to the Sentry App Fees wallet.
*   **Broadcast:** linked accounts can post a message (100 characters) to the Sentry Social feed, cross-post to their linked X account with the Sentry share card, and post the card to their own Telegram channel. To link a channel, add the bot to it as an **admin with permission to post**, then confirm it in Connect Telegram (or the megaphone on your Social profile). Ownership is verified — only the channel's owner or an admin can link it.

## @SentryBuyBot — buy alerts for your group

*   Add **@SentryBuyBot** to your project's group and use its menu to track your Sentry-launched token. Every buy posts an alert with the amount, price, market cap, buyer, and quick links to the chart and a one-tap Buy.
*   Customize alerts per group: your own photo, GIF, or video on top, a custom emoji for the buy-size wall, and a minimum buy filter. Send media as a regular compressed photo/video (not "as a file") so it plays inline.
*   Tokens with a minted **Coin Emoji** automatically upgrade: the emoji wall becomes a wall of your spinning coin — one coin per $25 of buy size.
*   Extras: featured-slot placements in the alert footer and biggest-buy competitions for your community.

## Telegram Bots Privacy Policy

_Effective August 2, 2026 — applies to @SentryTG\_Bot and @SentryBuyBot._

*   **What we collect.** Your Telegram user id, username, and first name; messages and photos you send _to_ the bots (commands, token addresses, logos); group and channel ids where a bot is added; per-group alert configuration. For trading: the custodial wallet created for you (address plus its private key, stored encrypted with AES-256-GCM), your trades, positions, launches, orders, and — if you link one — your Sentry account id.
*   **How it's used.** Solely to operate the services: executing the transactions you request on-chain, posting the alerts and broadcasts you configure, processing service fees, rate limiting, and aggregate product analytics. We do not sell your data.
*   **What the bots can't see.** @SentryTG_Bot works in private chats only. @SentryBuyBot runs with Telegram's group privacy enabled — it receives only commands, replies to it, and mentions, not your group's conversation.
*   **Sharing.** Data is shared only with the infrastructure that runs the service (hosting, RPC providers, Telegram's own APIs, and our database) and only as needed to operate it. Anything you do on-chain is, by nature, public.
*   **Control & retention.** Unlink your Telegram account, unlink your channel, or remove the bot from your group at any time — the associated automation stops immediately. Trading records are kept for the life of the service; custodial keys remain encrypted at rest and are used only to sign the actions you initiate.
*   **Contact.** Reach the team through sentry.trading or the official Sentry channels listed in Resources.
