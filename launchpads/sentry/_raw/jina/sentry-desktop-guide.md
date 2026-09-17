Title: Sentry

URL Source: https://www.sentry.trading/desktop/guide

Published Time: Wed, 02 Sep 2026 01:35:42 GMT

Markdown Content:
**Guide**Welcome

## Sentry — User Guide

How to use sentry.trading

## Welcome[](https://www.sentry.trading/desktop/guide#welcome "Copy link to this section")

Sentry is a non-custodial trading app for **Robinhood Chain** and **Ink** (Kraken's Layer 2) — and the most complete launch platform on either chain, end to end. Swap through a multi-venue aggregator with limit and DCA orders, launch tokens with permanently locked liquidity, the strongest anti-snipe protection in the space, and creator fees paid out on every single trade, pair launches against tokenized stocks like NVDA and NFLX, bridge ETH between mainnet and either chain, register `.hood` and `.ink` domains, lock team tokens, post and DM on a built-in social layer, and manage everything from one account. A chain selector in the header switches the whole app between chains, and your EVM address is the same on both.

The app gives you a generated EVM wallet the moment you sign up: no browser extension, no seed phrase to copy, no setup friction. You can also import your existing wallets, switch between them, and export the keys at any time. No account at all? The standalone [sentry.trading/swap](https://www.sentry.trading/swap) page works with your own browser wallet.

## What Sentry is (and isn't)

Sentry is **non-custodial software**. We don't custody user funds in a fiduciary capacity, we don't broker trades, we don't issue tokens, and we don't provide investment advice. Your wallet is yours: you can [export the private key](https://www.sentry.trading/desktop/guide#exporting-keys) any time and walk away. All swaps are routed through public on-chain DEXes; all token deploys go to immutable, renounced contracts the instant they ship. See [Launch Mechanics](https://www.sentry.trading/desktop/guide#launch-mechanics) for the full sequence, [Disclaimers](https://www.sentry.trading/desktop/guide#disclaimers) for the platform's limits, and [Privacy](https://www.sentry.trading/desktop/guide#privacy) for what data we collect (and don't).

## Getting Started[](https://www.sentry.trading/desktop/guide#getting-started "Copy link to this section")

Three steps to a funded, ready-to-trade account.

1.   **Create a Sentry Account.** Pick a username (3 to 15 characters: letters, numbers, underscores) and a password (8 characters minimum), or use `Sign in with X` to create the account from your X profile. Your password is sent over TLS, hashed with bcrypt (cost 10) on the server, and only the hash is stored. The plaintext is never written to disk.
2.   **Receive your wallet.** The moment your account is created, the backend generates an EVM wallet and binds it to your account. The same address works on Robinhood Chain, Ink, and Ethereum mainnet. If you'd rather use an existing key, [import one](https://www.sentry.trading/desktop/guide#importing-wallets) instead.
3.   **Fund and trade.** Tap `Receive` to copy your address or get a QR code, and send ETH to it on either chain (or on mainnet, then use the [Bridge](https://www.sentry.trading/desktop/guide#bridging) tile, which settles in seconds). Once funded, hit `Swap` to start trading.

## Account Security[](https://www.sentry.trading/desktop/guide#account-security "Copy link to this section")

Passwords, passkeys, two-factor authentication, X sign-in, external wallet connections, and email-based recovery. All of it lives in the Settings sheet (`Settings`>`Security` and `Settings`>`Account`).

## Passkeys (biometric login)

Register a passkey (Face ID, Windows Hello, fingerprint) from `Settings`>`Set up biometric login`. After that you can sign in with the passkey alone, no username or password typed. You can register one passkey per device and remove any of them individually from the same Settings row.

## Two-factor authentication (TOTP)

*   **Enable:**`Settings`>`Two-Factor Authentication`. Scan the QR code with any authenticator app (Google Authenticator, 1Password, Authy) and confirm with a 6-digit code.
*   **Backup codes:** on enable you receive **10 single-use backup codes**. They are shown once; store them safely. Any backup code can substitute for a TOTP code at login. Regenerating a fresh batch requires a live TOTP code.
*   **Scope:** 2FA gates **password logins only**. Passkey and Sign-in-with-X logins skip the code step: a passkey is already two factors by construction (device + biometric), and the X path proves control of the linked X account.
*   **Disable:** requires your password plus a valid code, and signs out every other device.

## Changing your password

`Settings`>`Change Password`. Requires your current password (accounts created via X set their first password here without one). On success, every _other_ session is revoked; the device you changed it on stays signed in.

## Verified email & password recovery

Sentry asks for no email at signup — but you can **verify one afterward** in `Settings`>`Account`>`Verification Status` (enter the address, confirm a 6-digit code). Beyond counting toward your [verification checkmark](https://www.sentry.trading/desktop/guide#social), a verified email makes your account **recoverable**: if you lose your password, reach out through an official channel and the team can reset it after you prove control of that email. With TOTP 2FA enabled, your authenticator is part of that proof too — enable both for the strongest recovery posture.

## Sign in with X

You can create an account with X, sign in with X, or link X to an existing account from `Settings`>`Connect X`. Linking also enables launching tokens by tweeting at [@sentrylauncher](https://x.com/sentrylauncher) from your own wallet, and puts your X handle on your [PNL cards](https://www.sentry.trading/desktop/guide#charts-pnl).

## Connect a wallet (MetaMask, Rabby, WalletConnect)

Sentry also works with wallets it never holds keys for. From `Settings`>`Security`>`Connect a wallet`, link an external wallet — any installed browser extension (MetaMask, Rabby, and friends are auto-discovered) or any mobile wallet over WalletConnect — to your account with a one-time **Sign-In-With-Ethereum** signature. No transaction, no gas, nothing to approve on-chain.

*   **Wallet-native login:** you can also sign in to Sentry with just a wallet — the login screen's wallet option creates (or resumes) a full Sentry account bound to that address, no password required.
*   **Self-custody, clearly separated:** external wallets show up in your wallet list alongside your Sentry wallets, with balances and holdings tracked the same way — but Sentry never has their keys. Anything that moves funds is signed in _your_ wallet, prompted through the extension or WalletConnect.
*   **What stays on your Sentry wallets:** features where Sentry signs for you in the background — limit and DCA order fills, the Telegram trading bot — keep running from your Sentry custodial wallets, because an external wallet can't sign while you're away.
*   **Unlink any time** from the same Settings row. Unlinking removes the connection; the wallet itself is untouched.

## Username & PFP[](https://www.sentry.trading/desktop/guide#profile "Copy link to this section")

Your handle and avatar follow you across the app: the header, trades, PNL cards, and creator attribution on tokens you launch.

## Changing your username

*   `Settings`>`Change Username`. A rename costs **$10, charged in ETH** at the live rate from your primary in-app wallet. You choose whether the payment settles on Ink or Robinhood Chain (both are native ETH).
*   The new name must be available and pass the same rules as signup (3 to 15 characters, letters/numbers/underscores).
*   Your old name is **released immediately** and anyone can claim it. Wallets, sessions, passkeys, and 2FA are untouched, and tokens you deployed re-point their creator attribution to the new name.

## Profile pictures

*   **Upload an image:** PNG/JPG/WebP/GIF, resized in-app. Uploaded avatars render as a circle.
*   **Set an NFT as your PFP:** open `Wallet`>`NFTs`, tap an NFT you own, and choose `Set as PFP`. Ownership is verified on-chain when you set it; no transaction is sent and nothing is spent. NFT PFPs render as a **hexagon** to signal verified ownership. Your `.hood` and `.ink` domain NFTs qualify.
*   Tap the same NFT again and choose `Remove PFP` to clear it. While set, the NFT takes priority over an uploaded image.
*   With nothing set, you get a deterministic color gradient generated from your name.

## Your Wallets[](https://www.sentry.trading/desktop/guide#your-wallets "Copy link to this section")

One generated EVM wallet by default, plus up to four imported wallets. Each wallet has a label, and one of them is your **primary** at any time.

## Generated wallets

Created automatically on sign-up. The private key is generated server-side, encrypted with AES-256-GCM, and stored encrypted-at-rest. The plaintext key never leaves the signing path: when you make a swap, the backend decrypts the key in memory just long enough to sign the transaction, then drops it.

These wallets are first-class: fund them, swap from them, send from them, deploy tokens with them, register domains with them, and [export the private key](https://www.sentry.trading/desktop/guide#exporting-keys) to move to your own custody whenever you want. Generated wallets can't be deleted; they live with the account.

## Imported wallets

Bring your own. Open the account switcher (tap your address pill) or `Settings`>`Import Wallet`, paste a private key (`0x`-prefixed EVM hex), and the wallet shows up alongside your generated one. You can rename any wallet inline (pencil icon) and delete imported, non-primary wallets (trash icon). Deleting removes Sentry's copy of the key; the funds stay on-chain and are still yours via the original key.

## External wallets (self-custody)

Beyond generated and imported wallets, you can connect wallets Sentry never holds keys for: MetaMask, Rabby, or any wallet over WalletConnect, linked with a one-time signature from `Settings`>`Security`>`Connect a wallet`. They appear in your wallet list with balances and holdings tracked like any other wallet, but every transaction from them is signed in your own wallet app — Sentry can read, never spend. Features where Sentry signs for you in the background (limit and DCA order fills, the Telegram bot) stay on your Sentry wallets. Full details in [Account Security](https://www.sentry.trading/desktop/guide#account-security).

## Holdings quality-of-life

*   **Custom tokens:** track any ERC-20 in Holdings by pasting its contract address (the `+` button above Holdings). Up to 20 per chain, stored on your device. Tokens you swap into are tracked automatically.
*   **Dust filter:** holdings worth under $0.01 are hidden by default, with a toggle at the bottom of the list showing how many are hidden.

## Importing a Wallet[](https://www.sentry.trading/desktop/guide#importing-wallets "Copy link to this section")

Bring an existing key into the app. Once imported, it behaves exactly like a generated wallet — you can swap, send, deploy, and export.

1.   Open the wallet rail (right side on desktop, Wallet tab on mobile) and tap the `Import Key` action.
2.   Paste your private key. Sentry accepts `0x`-prefixed EVM hex (64 hex chars after the prefix). The address is derived locally and shown to you before you confirm — sanity-check it matches what you expected.
3.   Optionally label it (e.g. “Cold Wallet”, “Trading”). Confirm. The newly imported wallet automatically becomes **primary** — switch back to your generated wallet anytime via [Set Primary](https://www.sentry.trading/desktop/guide#set-primary) in the Settings hub.

## Settings Hub[](https://www.sentry.trading/desktop/guide#settings "Copy link to this section")

Account-level actions live behind a single `Settings` button: the gear icon in the top bar, next to Activity on mobile and after the screenshot button on desktop. One place for the things you don't do every day.

Settings is organized into five sections. Tap one to drill in; the back arrow returns you to the list.

*   **Account** — **Change Username** (rename your @ handle for $10 in ETH), **Profile Info** (About blurb and profile links), **Verification Status** (link X, verify an email, optionally link Telegram — this is where your checkmark lives), and **Connect Telegram** (link the trading bot). [See Social & Messages](https://www.sentry.trading/desktop/guide#social).
*   **Wallet** — **Import Wallet**, **Set Primary Wallet**, **Export EVM Key** (one-time view, password-gated), and **Spend Addresses** (your saved off-ramp destinations). [See Your Wallets](https://www.sentry.trading/desktop/guide#your-wallets).
*   **Security** — **Biometric login** (passkeys), **Change Password**, **Two-Factor Authentication** (TOTP + backup codes), and **Connect a wallet** (MetaMask, Rabby, WalletConnect). [See Account Security](https://www.sentry.trading/desktop/guide#account-security).
*   **Preferences** — **Decimals** (write amounts as 1,234.56 or 1.234,56 — matches an EU/LATAM phone keypad), **Swap input** (price inputs in USD or token units), **Quick Buy** (set how much the one-tap 💰 Quick Buy button spends, in USD, converted to ETH at buy time), and **Notifications** (the push toggle for this device).
*   **Referral Program** — your code, invite link, and live referral stats. [Details](https://www.sentry.trading/desktop/guide#referrals).

## Set Primary[](https://www.sentry.trading/desktop/guide#set-primary "Copy link to this section")

The **primary** wallet is the one the app uses by default for swaps, sends, and deploys.

Open `Settings` (gear icon in the header on mobile, or the rail toolbar on desktop), then `Set Primary Wallet`. The modal lists every wallet you own, generated and imported. Pick one and hit Save; the old primary is automatically unflagged.

Newly imported wallets become primary automatically; this modal is how you switch back to a different one (or back to the generated wallet). Generated wallets cannot be deleted — they're tied to the lifetime of your account.

## Exporting Private Keys[](https://www.sentry.trading/desktop/guide#exporting-keys "Copy link to this section")

Move any wallet — generated or imported — to your own custody. The export shows the plaintext private key one time, after you re-confirm your password.

1.   Open `Settings`>`Export EVM Key`. The export modal shows which wallet you're about to reveal — label, address, source (generated vs imported).
2.   Re-enter your account password. The backend re-runs `bcrypt.compare` against your stored hash before it decrypts and returns anything.
3.   On success, the key is shown in a one-shot reveal panel. Tap the eye icon to toggle visibility, the copy icon to put it on the clipboard, or the “Done — close and forget” button to wipe it from React state.

## Trading & The Aggregator[](https://www.sentry.trading/desktop/guide#trading-ink "Copy link to this section")

Sentry's swap engine is an aggregator. Every quote fans out across all live DEX venues on the active chain in parallel and executes on the single venue that returns the most output. Price impact is already reflected in the quote, because each quote is a real simulation against live pool state.

## Venues quoted per chain

*   **Robinhood Chain (4663), four venues:** canonical **Uniswap V3** (all four fee tiers: 0.01% / 0.05% / 0.3% / 1%), **Uniswap V2** (live pair reserves), **Uniswap v4** (Sentry launch pools — WETH-paired and stock-paired — plus the Doppler hook pools where Bankr-launched tokens trade), and **PancakeSwap V3** (0.01% / 0.05% / 0.25% / 1%). Stock-paired tokens quote through the multihop route automatically (ETH → USDG → stock → token and back), so they buy and sell with ETH like any other coin.
*   **Ink (57073):****Uniswap V3** (the governance-recognized deployment on Ink), fanning across every live fee tier (0.01% up to 5%). Every Sentry-launched Ink pool was migrated here in August 2026; the liquidity stayed locked throughout and moved at the same price. Trading on Ink is also routable through Relay, so you can buy these tokens with ETH from any supported chain.

The winning venue is shown alongside the quote. Because the fan-out compares every pool a token trades in, you automatically get the deepest pool's pricing and the lowest realistic price impact without picking a venue yourself.

## Anatomy of the swap form

*   **You Pay** — the input. Defaults to ETH. Tap `MAX` to pull your full balance minus a small gas reserve (0.0005 ETH), or use a quick-buy preset.
*   **You Receive** — pick any token from the picker, or paste any contract address to resolve a token on-chain, even one never launched through Sentry.
*   **Quote details** — appears once you've typed an amount. Shows minimum received (after slippage), your slippage tolerance, and the venue/fee tier the aggregator picked.
*   **Slippage** — defaults to 1%. Tap the value to switch between 0.5% / 1% / 3%. “Minimum received” is the quoted output minus your tolerance; if the pool can't deliver at least that at execution, the transaction reverts and nothing is traded.
*   **USD or token input** — flip the input denomination in `Settings`>`Swap input`.

## Quick-buy presets

On the BUY direction, four chips appear under the You-Pay field: `0.05 ETH`, `0.1 ETH`, `0.5 ETH`, `1 ETH`. Tap one to drop that amount into the input.

## Sells

Flip the direction with the arrow button. The first sell of any token requires a one-time on-chain approval (the router needs permission to pull tokens from your wallet); the app handles this transparently. You'll see “Approving token…” before the swap kicks off. Sells to ETH always unwrap WETH, so you receive native ETH with no leftover WETH balance.

## Bankr and other launchpads' tokens

Sentry lists and trades tokens from other launchpads too. On Robinhood Chain, **Bankr** tokens (which trade in Uniswap v4 Doppler pools) appear in the tokens grid with a launchpad badge and route through Sentry's v4 router with the same 1% fee. They are tradeable through Sentry, not launched by it, so their launch mechanics are Bankr's own.

## Guest swaps: no account needed

[sentry.trading/swap](https://www.sentry.trading/swap) is a standalone swap page that works without a Sentry account, using your own browser wallet (MetaMask, Rabby, any injected wallet). Connect, pick a chain and token, and swap; gas comes from your connected wallet and the same 1% platform fee applies. The URL updates live as you pick tokens (`/swap?chain=robinhood&token=0x…`), so you can share a link that drops someone straight into a preloaded swap. Token pages have a Share button that produces the same kind of deep link.

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

## Watchlist & Alerts[](https://www.sentry.trading/desktop/guide#watchlist "Copy link to this section")

Star the tokens you care about and let the app ping you when they move.

*   Tap the **star** on any token detail page to watch it. Up to **5 tokens** per account.
*   Watched tokens trigger **targeted push notifications** when they move **10% or more within an hour**, up or down.
*   Movement is re-checked every 10 minutes, and there is deliberately no cooldown: a token that keeps running keeps alerting. Your device shows only the latest alert per token, so they replace rather than pile up.
*   Tapping an alert opens the swap page with that token preloaded.

Watchlist alerts require push notifications to be enabled on the device — see [Push Notifications](https://www.sentry.trading/desktop/guide#notifications).

## Push Notifications[](https://www.sentry.trading/desktop/guide#notifications "Copy link to this section")

Real push, straight to your device, even with the app closed. One toggle per device in `Settings`>`Notifications`.

## What you receive with notifications on

*   **Boost alerts:** whenever anyone boosts a token, all subscribed users get one push (“⚡TOKEN just got boosted on Sentry”).
*   **Big moves on boosted tokens:** while a token has an active boost, moves of 10%+ within an hour are pushed to all subscribers.
*   **Watchlist moves:** 10%+ hourly moves on tokens you starred, sent only to you.
*   **New messages:** when someone DMs you in Social, you get a push saying who it's from — never the message contents (those are encrypted end-to-end).
*   **New followers:** when someone follows you, a push tells you who — tapping it opens their profile.
*   **Posts from people you follow:** off by default. Turn on the **bell** next to the Follow button on a profile to get pushed whenever that account posts.
*   **Official posts:** posts from the official `@cruelhand` account on the Social feed are pushed to all subscribers.

Turning the toggle off unsubscribes the device immediately. There are no per-category toggles; the per-token control is the watchlist star, and boost alerts are all-or-nothing with the master switch.

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

## Boosts & Featured Slots[](https://www.sentry.trading/desktop/guide#boosts-featured "Copy link to this section")

Two paid visibility products on the Tokens page. Prices are set in USD and charged in ETH at the live rate from your in-app wallet. Anyone can boost or feature any token; you don't need to be its creator. Purchases are final.

## Boosts (the ⚡ multiplier)

*   **50x pack** — $25 · 12 hours
*   **100x pack** — $50 · 12 hours
*   **500x pack** — $125 · 12 hours

A boosted token jumps to the **front of the Trending marquee** on the runner bar with a golden highlight, a lightning bolt, and its multiplier (e.g. ⚡150x). Boosts are **stackable with no cap**: anyone can add packs at any time, the displayed multiplier is the sum of all active packs, and each pack runs 12 hours from its own purchase. The number climbs as people stack and decays as packs expire. Boosts go live instantly; there is no queue.

## Featured slots (the ⭐ pinned spots)

*   **6 hours** — $25
*   **12 hours** — $50
*   **24 hours** — $125

Three slots, pinned at the left of the volume runner bar on the Tokens page. Featured tokens display as logo plus gold symbol only (deliberately no price delta, so a paid placement never advertises its own dip). One live slot per token. If all three slots are taken, your purchase queues and activates automatically when a slot frees up; the purchase modal shows the live board and your start time before you pay. Unsold slots may show house picks; paid slots always displace them.

Featuring is placement only: it does not send push notifications. If you want the notification blast, boost.

## Referral Program[](https://www.sentry.trading/desktop/guide#referrals "Copy link to this section")

Bring traders to Sentry and earn **the full 1% platform fee** on every swap they make — paid on-chain, per swap, forever. Self-serve, no application, no review. Find it in `Settings`>`Referral Program`.

## Becoming a referrer

1.   Open `Settings`>`Referral Program` and pick a vanity code (3 to 12 letters/numbers, availability checked live) — or leave it blank for a random code. One code per account, yours forever.
2.   Share your invite link (one-tap copy), or just share token buy links — once you have a code, **your code rides along on every buy link you share automatically**.
3.   Anyone who signs up through your link, enters your code in Settings, or trades through your buy links becomes your referral. Your card shows live stats: referrals, their total volume, and your fees earned.

## Entering a code

Have someone's code? Enter it once in the same Settings pane. It's immutable after that (and self-referral is rejected). Your own swap costs **never change** — the referrer's share comes out of Sentry's fee, not on top of it.

## Creating Tokens[](https://www.sentry.trading/desktop/guide#creating-tokens "Copy link to this section")

Deploy your own ERC-20 on the active chain via the Sentry Launch Factory. The form opens from `Create` (center of the bottom nav on mobile, top nav on desktop). Your in-app wallet signs and pays gas, which is fractions of a cent on both chains. Launching is free apart from gas. For the on-chain mechanics (renouncement, LP lock, no pre-mine, no admin keys), see [Launch Mechanics](https://www.sentry.trading/desktop/guide#launch-mechanics).

1.   **Fill the form.** Coin name (up to 32 characters), symbol (up to 10), and a logo image (required). Optional: website, X, and Telegram links, and whether to display your username as the creator.
2.   **Optional dev buy.** Commit ETH (entered in USD or ETH) that buys your token immediately after the pool opens, at the same market price anyone else would get. If you skip it, the app automatically executes a tiny seed buy (0.00001 ETH from your wallet) right after the deploy, so the token registers a first trade and prices on chart sites, which only start tracking a token after its first swap.
3.   **Optional launch extras.** You can set a separate **creator fee recipient** at launch (route fees to a team multisig while you stay the recorded creator). Your launching wallet is automatically added to the [launch whitelist](https://www.sentry.trading/desktop/guide#anti-snipe) so your own dev buy pays the 1.7% floor, not the anti-snipe rate; accounts with **Bundle Buy** enabled can arm a front-run-proof multi-wallet buy whose wallets are whitelisted the same way. On Ink, wallets linked to a KYC'd Kraken account can use the **Kraken Verified** launch type.
4.   **Hit Deploy.** The factory deploys the ERC-20, creates the pool (a **Uniswap v4** dynamic-fee pool — paired with WETH on either chain, or with a tokenized stock on Robinhood Chain), mints the liquidity position into the immutable LP vault, and executes the dev buy, all in one flow. Your token then appears in the tokens grid and the advanced table, with your metadata and logo.

## Launch Mechanics[](https://www.sentry.trading/desktop/guide#launch-mechanics "Copy link to this section")

Exactly what happens on-chain when a token is deployed through Sentry. This page is the source of truth — if anything in marketing copy disagrees with the mechanics here, the mechanics win.

## What happens at deploy

1.   **Token contract is deployed.** A standard ERC-20 with a fixed supply of **1,000,000,000 tokens** (18 decimals) minted in the deploy transaction. No proxy pattern, no upgrade mechanism, no mint function, no pause function, no blacklist function.
2.   **Contract is immediately renounced.** Ownership is transferred to the dead address in the same transaction. After this block, no one, not the deployer and not Sentry, can mint additional tokens, change parameters, or interact with the contract in any privileged way. It is, by EVM definition, immutable.
3.   **The LP is created and locked.** 100% of the supply is deposited as a single-sided position. New launches on both chains live in a **Uniswap v4** dynamic-fee pool: the trade fee starts at 40% at launch (an anti-snipe tax that makes block-zero bots pay dearly), holds there for 3 minutes, then halves every 3 minutes until it reaches a permanent **1.7% floor** about 17 minutes in. The position is held permanently by the **SentryLPVault**, an immutable contract with no withdrawal function of any kind. It is not a proxy and cannot be upgraded. No timer, no unlock, ever.
4.   **Trading opens to everyone in the same transaction.** Once the LP exists, the token is tradable by anyone. There is no presale and no privileged buying window — nobody, creator included, can buy before the pool is public. The creator's optional dev buy (or the automatic 0.00001 ETH seed buy from the creator's wallet if there isn't one) runs as a separate swap right after the deploy, at the same market price any other buyer would get. The optional **launch whitelist** changes the _fee_ a listed wallet pays during the anti-snipe window, never its access or its price — see [Anti-Snipe Protection](https://www.sentry.trading/desktop/guide#anti-snipe).

## What is NOT in a Sentry launch

*   **No pre-loaded tokens.** Every token that ends up in a wallet got there via a public on-chain swap against the LP. Nothing was airdropped, allocated, or pre-distributed.
*   **No team allocation.** Sentry doesn't reserve any portion of the supply for itself, the deployer, or any other party. 100% goes into the LP.
*   **No dev wallet holding tokens.** The deployer's EOA has zero tokens in it the moment the deploy completes — they can only acquire tokens by buying from the public LP at market price, same as everyone else.
*   **No admin keys.** The renounced contract has no owner, no governor, no upgrader. There is no role that can change anything.
*   **No timed LP unlock.** The vault's custody of the position is not on a timer that releases it back to the deployer later. It's permanent, and the vault has no code path that could return it.

## Locked LP still earns fees, and creators get the majority

Locking the LP takes withdrawal off the table, not the trading fees. On every current launch — both chains, same contracts, same numbers — the pool's own LP fee is set to zero and the hook settles every leg _per swap_, so nothing accrues to the position and there is nothing to claim later. At the 1.7% floor a WETH launch pays **1.0% to the creator**, 0.2% compounded back into the token's own liquidity, and 0.5% to the protocol. Launches with reflections enabled, and stock-paired launches, instead pay 0.8% to holders, 0.5% to the creator, 0.2% into liquidity, and 0.2% to the protocol. The protocol leg doesn't just sit in a wallet either: it routes through the on-chain Treasury Splitter — 60% operations, **40% compounded into permanently locked SENTRY liquidity** (see [The SENTRY Token](https://www.sentry.trading/desktop/guide#sentry-token)).

Legacy **V3-era** launches (from before the v4 stack) work the older way: fees accrue to the locked position on both sides of the pair, and collecting them splits **70% / 30%** between the creator and the Sentry treasury on Robinhood Chain (**65% / 35%** on Ink). Every split is enforced by the contract and readable on-chain. Full details in [Creator Rewards](https://www.sentry.trading/desktop/guide#creator-rewards).

## The optional dev buy

The Create form lets the deployer optionally swap ETH for tokens at deploy time. This is just a normal swap: same router and same slippage rules as any subsequent buy, executed against the freshly-created LP at the same market price the very next buyer would pay. It is not a privileged allocation; it's a public swap that happens right after the deploy. Because the launching wallet is whitelisted, the dev buy pays the 1.7% floor fee rather than the anti-snipe rate — the price is the market's, only the fee differs.

## Verifying it yourself on the explorer

Don't take any of this on faith — for any Sentry-deployed token, the entire sequence is verifiable on [explorer.inkonchain.com](https://explorer.inkonchain.com/) (Ink) or [robinhoodchain.blockscout.com](https://robinhoodchain.blockscout.com/) (Robinhood Chain):

*   **Token contract:** search the address. The owner read returns the dead address. There are no `Mint` events after the deploy block.
*   **The pool:** holds the entire supply at deploy. Subsequent swaps move balances around, but the pool itself is immutable V3 code.
*   **LP position NFT:** the position is held by the Sentry Launch Factory contract, not by the deployer's EOA, and the factory has no function that can transfer it out.
*   **Deploy transaction:** bundles the ERC-20 deploy, ownership renouncement, LP creation, and lock into one tx. The Sentry factory contract is the caller; the deployer EOA only signs the transaction that triggers the bundle.

## Anti-Snipe Protection[](https://www.sentry.trading/desktop/guide#anti-snipe "Copy link to this section")

Robinhood Chain has some of the most aggressive sniper bots anywhere. Most launchpads treat sniping as a bug to patch after the fact. Sentry treats it as an economics problem, solved in the pool itself: for the first minutes of every launch, sniping is **unprofitable by construction** — and every fee a sniper does pay goes to the creator, the holders' pool depth, and the protocol, not to the sniper's exit.

## The decay fee curve

Every v4 launch pool opens with a **40% trade fee** that holds for 3 minutes, then halves every 3 minutes (smoothly, not in steps) until it reaches the permanent **1.7% floor** about 17 minutes in:

| Time since launch | Trade fee |
| --- | --- |
| 0 – 3 min | **40%** |
| 6 min | 20% |
| 9 min | 10% |
| 12 min | 5% |
| 15 min | 2.5% |
| ~17 min onward | **1.7% — permanent floor** |

A block-zero bot buying 1 ETH pays 0.4 ETH in fees on the way in — and the curve is still elevated when it tries to flip, so the round trip only profits if the token does a large multiple in minutes. The math that makes sniping free money everywhere else simply doesn't clear here.

## Snipers pay the creator

The fee isn't burned and it doesn't accrue to some claimable pot — the hook settles it **within the sniper's own transaction**. On a reflection or stock-paired launch, a 40% opening-window fee splits into **20% of the trade to the creator's wallet**, 10% into permanently locked liquidity, and 10% to the protocol treasury (itself split 60% operations / 40% into permanently locked [SENTRY](https://www.sentry.trading/desktop/guide#sentry-token) liquidity). On a plain WETH launch the creator's cut is even larger — about 23.5% of every sniped trade. Launch frenzy volume is exactly when the curve is highest, so the more aggressively a launch gets sniped, **the more its creator earns and the deeper its locked liquidity gets**. Sniping a Sentry launch is donating to it.

## Why a time curve, and why 17 minutes

*   **Time-based, not swap-count-based:** a fee that decays per swap can be gamed down with dust swaps. The clock can't be.
*   **Time-based, not price-based:** a fee tied to price trusts a number snipers can push around. The clock can't be manipulated.
*   **Minutes, not seconds:** some launchpads open with a huge fee that collapses within seconds. That stops exactly one block of bots — snipers just wait it out and hit a still-empty chart. Seventeen minutes outlasts the entire frenzy window, which is precisely the stretch where a new token needs protecting.

## The launch whitelist

The anti-snipe fee has one deliberate exception. At launch, the creator can whitelist wallets (the launching wallet is always included automatically). During the decay window, whitelisted wallets pay the **1.7% floor instead of the curve rate — on buys only**. That lets a team actually acquire its supply at launch without feeding 40% of its capital to the fee curve: of a 1 ETH whitelisted buy, roughly 0.98 ETH ends up as real pool depth, versus 0.6 ETH unwhitelisted.

*   **It is not early access.** Whitelisted wallets buy from the same public pool, at the same market price, in the same blocks as everyone else. They just skip the anti-snipe premium.
*   **It is never free.** The floor fee — including its reflection and liquidity components — still applies to every whitelisted buy.
*   **Sells are never exempt.** The exemption checks trade direction; it cannot be used to dodge a sell fee during the window.
*   **It is frozen at launch.** The list is written to the hook before the pool initializes and rejects all changes afterward. Nobody — not the creator, not Sentry — can add a wallet after the fact, and anyone can verify the list on-chain.
*   **It survives routers.** Matching is on the transaction origin, so a whitelisted wallet gets the floor whether it buys through the app, the public swap page, or any router.

## Creator Rewards[](https://www.sentry.trading/desktop/guide#creator-rewards "Copy link to this section")

Launch a token and you earn from every single trade it ever does, forever.

## The split

*   **Current launches (v4, both chains — identical contracts and numbers):** at the permanent 1.7% floor a WETH launch pays the creator **1.0% of every trade**, which is 59% of the fee, with 0.2% compounded into the token's own liquidity and 0.5% to the protocol. Launches with reflections enabled and stock-paired launches pay the creator **0.5%** (29% of the fee), because 0.8% goes to holders instead.
*   **Legacy V3 launches:****70% to the creator**, 30% to the Sentry treasury on Robinhood Chain (raised from 65% on July 8, 2026); **65% / 35%** on Ink.

The splits are enforced by the contracts and readable on-chain. How the fees reach you depends on the launch generation: on v4 launches the fee hook **pays your share out on every single trade**, directly to your wallet, with nothing to collect — during the launch window that includes the anti-snipe fee, so early frenzy volume pays creators the most. Stock-paired launches pay you **in the base stock** (sell a CHILL-style token's volume and you accumulate NFLX). Legacy V3 launches accrue fees inside the locked position until collected, as described below.

## Current launches: paid per trade, nothing to collect

On every current launch (v4, both chains), your share is settled **inside each swap transaction** and lands in your fee recipient wallet immediately. There is no claim step, no collection schedule, and no balance sitting anywhere waiting on you — if your token traded five seconds ago, you were paid five seconds ago. Your `My Tokens` card tracks the running totals.

## Collecting fees on legacy V3 launches

1.   Open `Wallet`>`My Tokens`. Each token you launched shows a card with its live stats.
2.   Tap `View` / `Refresh` to read the accrued, uncollected fees straight from the pool (read-only, no transaction).
3.   On Robinhood Chain, tap `Collect Fees`. Collection pulls the accrued fees out of the locked position and pays your share directly to your fee recipient wallet in the same transaction.

## Fee recipient management

*   **At launch:** optionally direct fees to any address with the creator-fee-recipient field on the Create form. You stay the recorded creator.
*   **After launch:** the current recipient can **transfer fee rights exactly once** via the `Transfer Fees` action on the My Tokens card. It's a one-time, irreversible handoff, built for handing a community takeover its fee stream. Sentry can also reassign recipients in verified community-takeover cases.

## Tokenized Stocks as Base Pairs[](https://www.sentry.trading/desktop/guide#stock-pairs "Copy link to this section")

On Robinhood Chain and Ink you can launch a token paired against a tokenized stock instead of ETH. On Robinhood that is a Robinhood-issued stock; on Ink it is a Backed wrapped xStock (wNVDAx, wAAPLx, …). Your coin trades directly against that stock, and holders earn it as a reflection on every trade. Buyers can still pay with ETH — the router hops through USDG into the wrapper.

## What a stock-paired launch is

A normal Sentry launch pairs your token against ETH. A stock-paired launch instead pairs it against one of the tokenized stocks that live on Robinhood Chain (Apple, Netflix, Nvidia, and roughly a hundred others). The stock becomes the **base asset** of your pool: the thing your token is priced in and traded against. Everything else about a Sentry launch is unchanged: fixed 1 billion supply, contract renounced, 100% of supply locked as single-sided liquidity that the factory holds forever.

## How to launch one

1.   On Robinhood Chain, open **Create** and choose the**Stock Base Pair** launch type.
2.   Pick the base stock from the list. Each entry shows the company logo, name, ticker, and contract address. Every entry is verified on-chain as a genuine Robinhood issuance, and the list is limited to stocks with a real, liquid on-chain market (about twenty megacaps and ETFs — AAPL, NVDA, TSLA, META, SPY, QQQ and friends) so that every launch is actually tradeable with ETH. Stocks whose pools can't fill trades at a fair price are excluded automatically until Robinhood deepens them.
3.   Name your token and launch. Your token deploys, its pool against the chosen stock is created, and the full supply is locked as liquidity in the same transaction.

## The fees, and who earns what

Every trade in a stock-paired pool pays the launch fee curve (40% decaying to the permanent 1.7% floor — see [Anti-Snipe Protection](https://www.sentry.trading/desktop/guide#anti-snipe)), and all of it is denominated **in the base stock**. So creators are paid in the stock, and holders earn the stock. Once the pool is at the floor, every trade splits like this:

| Leg | Share of the fee | At the 1.7% floor | Goes to |
| --- | --- | --- | --- |
| **Holder reflections** | ~47% | 0.8% of the trade | All holders, pro-rata, in the base stock — claimable from the token contract any time |
| **Creator** | ~29% | 0.5% of the trade | The creator's fee wallet, paid within the swap itself — nothing to claim |
| **Liquidity reinvest** | ~12% | 0.2% of the trade | Compounded into permanently locked full-range liquidity — the pool gets deeper with every trade |
| **Treasury** | ~12% | 0.2% of the trade | The Sentry treasury splitter (60% operations, 40% into locked SENTRY liquidity) |

## Stock reflections for holders

Holding a stock-paired token earns you the base stock. On every buy and sell, just under half of the pool fee (0.8% of the trade at the permanent floor) is set aside in the stock and attributed to holders in proportion to how much of the token they hold at that moment. It accrues continuously and survives transfers. You claim your accrued stock directly from the token's contract whenever you want. This is real, on-chain, and automatic: there is no snapshot to catch and no team distributing manually.

## Buying and selling with ETH

You do not need to hold the base stock to trade a stock-paired token. When you buy with ETH, Sentry routes it for you in a single transaction:

`ETH → USDG → base stock → your token`

You send ETH and receive the token; the stock leg happens inside the transaction and you never have to manage it. Selling works the same way in reverse: by default you receive **ETH** back (token → stock → USDG → ETH in one transaction), with a toggle to receive the base stock instead if you prefer to hold it. Both directions work in the in-app swap and on the public swap page at [sentry.trading/swap](https://www.sentry.trading/swap), and you can also pay with the base stock directly if you already hold it.

## Viewing and claiming your stock reflections

Your accrued stock is visible and claimable in two places, depending on how you hold the token:

1.   **In the app:** open the token's page. A **Reflections** card shows your claimable balance in the base stock (for example `0.0450 NFLX`) with a `Claim` button. One tap sends the stock straight to your wallet.
2.   **With a connected wallet on [sentry.trading/swap](https://www.sentry.trading/swap):** connect the wallet that holds the token and a reflections card appears under the swap form whenever you have something to claim. The claim is signed by your own wallet, directly against the token contract — Sentry never touches the funds.
3.   **After claiming:** the stock appears in your in-app wallet automatically, with its real logo and live USD value, like any other asset. You can hold it, LP it, or swap it.

## Ink: wrapped xStocks

On Ink the base asset is a **Backed wrapped xStock** (wNVDAx, wAAPLx, and six others) — an ERC-4626 wrapper over the raw rebasing xStock. Always pair and trade the wrapper, never the raw token. The launch factory is the same v4 proxy as WETH launches; ETH still works as the pay asset, but the hop is different:

`ETH → WETH → USDT0 → USDG → wrapped xStock → your token`

*   The Ink stock-pair floor is **2.00%**, not the 1.7% WETH / Robinhood-stock floor.
*   Creators on Ink are paid in **WETH** (the router peels 75% of the live curve before the v4 swap). Holders still earn the wrapper as reflections (the remaining 25%).
*   Direct `PoolManager.swap` on these pools reverts — the hook is router-gated. Integrators must use `SentryStockRouterInk`.

Addresses, ABIs, pool keys, and a quote/swap walkthrough live in [Ink xStocks (Developers)](https://www.sentry.trading/desktop/guide#ink-xstocks).

## Good to know

*   **Tokenized stocks are geo-restricted by Robinhood.** Access to the underlying stock tokens follows Robinhood's own regional rules. Sentry does not promote any way around those restrictions.
*   **The base stock is on Robinhood's rails.** Robinhood can pause a stock token or upgrade its logic; a paused stock would freeze its pools, and corporate actions like stock splits are handled by Robinhood, not by Sentry.
*   **Ink wrappers are Backed xStocks.** Backed can halt a wrapper or the underlying xStock; a halt would freeze the Foundation USDG book and any Sentry pool paired against that wrapper.
*   **Prices move fast.** A stock-paired token starts at a small market cap, so early trades move the price sharply in both directions.

## Token Locker[](https://www.sentry.trading/desktop/guide#token-locker "Copy link to this section")

A trustless timelock for team, treasury, or vesting tokens on Robinhood Chain. Available at [sentry.trading/lock](https://www.sentry.trading/lock) and in the wallet's Locks view.

*   The Sentry Token Locker has **no owner, no admin functions, no fees, and no early-withdrawal path**. It records exactly what it receives and releases it to the beneficiary only after the unlock time.
*   Lock any ERC-20: pick token and amount, choose a preset duration (1 week, 1 month, 3 months, 6 months, 1 year) or a custom date, and optionally name a different beneficiary.
*   Locks can be **extended** (forward only, never shortened), and the beneficiary can be transferred to a new address.
*   USD values are shown per lock, and matured locks show a Withdraw button for the beneficiary.

## The SENTRY Token[](https://www.sentry.trading/desktop/guide#sentry-token "Copy link to this section")

SENTRY is the platform's own token, trading against WETH in a Uniswap v4 pool on Robinhood Chain — and it's built as a flywheel: **every launch and every trade on the platform feeds SENTRY, and SENTRY pays its holders in WETH**.

## The token

*   **Contract:**`0x1EcA20cfa4AF2e2fA2F4CE2bF8d97bFa184FD4D7` — fixed 1 billion supply, renounced, verified on Blockscout.
*   **Distribution:** 10% treasury, 3% founder (publicly disclosed), 87% launched into the public WETH pool. Holders of the original SENTRY were migrated via airdrop at the relaunch (July 28, 2026).
*   **Liquidity:** permanently locked, same custody model as every Sentry launch — no withdrawal path, ever.

## Hold SENTRY, earn WETH

SENTRY runs on the same per-swap fee-hook architecture as the launchpad, tuned for holders. The pool fee decays from 40% at relaunch to a permanent **2% floor**, and every trade splits it three ways, settled inside the swap itself:

| Leg | Share of the fee | At the 2% floor | Goes to |
| --- | --- | --- | --- |
| **Holder reflections** | 37.5% | 0.75% of the trade | **WETH, to all SENTRY holders pro-rata** — claimable any time, no snapshots, no deadlines |
| **Liquidity compound** | 37.5% | 0.75% of the trade | Permanently locked SENTRY/WETH liquidity — the pool deepens with every trade |
| **Treasury** | 25% | 0.5% of the trade | The Sentry treasury |

Reflections use the same dividend-accounting standard as stock-paired launches: **zero transfer tax**, fully DEX-compatible, accrual proportional to your holdings at the moment of each trade. Your claimable WETH shows on the SENTRY token page in the app.

## The flywheel: the whole platform feeds the token

The protocol's share of _every launch's_ trading fees — every WETH launch, every stock launch, every sniped block-zero buy on any token — routes to the on-chain **Treasury Splitter**, which cuts it 60/40:

*   **60%** funds platform operations.
*   **40% market-buys SENTRY and mints permanently locked SENTRY liquidity.** WETH proceeds compound into locked SENTRY/WETH liquidity; stock-launch proceeds route through USDG and WETH into locked SENTRY/stock liquidity. Locked means locked — the splitter has no removal function.

The loop closes cleanly: platform volume creates protocol fees → 40% of those become permanent SENTRY buy pressure and ever-deeper locked liquidity → SENTRY's own trading volume pays holders WETH on every swap. More launches, more trading, more snipers taxed — all of it accrues to the token and its holders, structurally, on-chain, with nothing to claim on faith.

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

## The Ecosystem Tab[](https://www.sentry.trading/desktop/guide#ecosystem "Copy link to this section")

The fifth tab in the bottom nav (sparkles icon): on-chain rituals and integrations. Contents follow the active chain.

*   **Daily GM** (Ink) — an on-chain GM streak. One free GM every 24 hours.
*   **GM+** (Ink) — the premium GM at 0.0005 ETH per call, same 24-hour cadence.
*   **Lending** (Ink) — supply assets to Tydro (an Aave v3 deployment on Ink) straight from the app.
*   **Domains** (both chains) — registration and the premier `.hood` auctions. [Details](https://www.sentry.trading/desktop/guide#zns-domains).

## Bridging[](https://www.sentry.trading/desktop/guide#bridging "Copy link to this section")

Move ETH between Ethereum mainnet, Ink, and Robinhood Chain without leaving Sentry. The Bridge tile on the wallet page routes through [Relay Protocol](https://relay.link/). Same EVM address on every chain, so there's no recipient entry: you always bridge to yourself. All six directions are supported: mainnet to either L2, either L2 back to mainnet, and Ink ↔ Robinhood.

1.   Send ETH to your Sentry address on **Ethereum mainnet** (your address is the same on every EVM chain). Sentry detects the inbound balance automatically.
2.   Tap the `Bridge` tile on the wallet page. Pick the From and To chains; the sheet quotes the Relay route with the estimated output (routing cost and gas are inside the rate shown).
3.   Hit `Bridge`. Sentry signs the source-chain tx, hands it to Relay, and shows live status pills: `depositing` → `pending` → `success`. A small gas reserve always stays on the source chain so you can't bridge yourself out of gas.
4.   On success, the ETH lands in the same wallet on the destination chain. The bridge shows up in your Activity feed with a link to the full receipt on `relay.link`.

## Spend[](https://www.sentry.trading/desktop/guide#spend "Copy link to this section")

Move ETH out of Sentry and into an app you actually spend from. The Spend tile on the wallet page converts native ETH from any chain Sentry custodies (Ethereum mainnet, Ink, or Robinhood Chain) into whatever the destination app credits, and delivers it straight to a deposit address you saved. One transaction, no manual bridging, no intermediate swap.

## Supported apps

| App | You receive | Addresses you save |
| --- | --- | --- |
| Avici | USDC on Base or Solana | Your EVM and/or Solana deposit address |
| Robinhood | AVAX, ETH, BNB, SOL, BTC | One EVM address (covers AVAX, ETH and BNB), plus Solana and Bitcoin |
| Venmo | BTC, SOL, PYUSD on Arbitrum | One per coin and network |
| PayPal | BTC, SOL, PYUSD on Arbitrum | One per coin and network |
| Cash App | BTC | Your Bitcoin deposit address |

## How to use it

1.   Tap `Spend` on the wallet page and pick the app. Each app has its own screen and its own saved addresses.
2.   Add a destination the first time: copy the deposit address out of the other app (Avici: Add Money · Robinhood, Venmo and PayPal: Crypto → Transfer → Receive · Cash App: Bitcoin → Deposit Bitcoin), paste it, and give it a label. Robinhood and Cash App take one address per network and expand it into every asset that network can receive; Venmo and PayPal take one address per coin, so you pick the coin first.
3.   Choose the source chain, type an amount in dollars, and the sheet quotes what will actually arrive. Hit Spend.
4.   Sentry signs one transaction on the source chain. Delivery is tracked live: `depositing` → `pending` → `success`. The destination app credits the deposit on its own side, usually within moments of the fill.

## What happens behind the scenes

None of these apps support Ink or Robinhood Chain, and funds sent to them on an unsupported network are unrecoverable. So Spend never does a plain transfer across chains. It routes through [Relay Protocol](https://relay.link/) as a single intent: you sign one deposit on the source chain, and Relay's solver network delivers the destination asset — including the Solana and Bitcoin legs, which need nothing further from you.

Destinations are scoped to one wallet. Every EVM sub-wallet under your account keeps its own address book per app, so switching wallets switches the whole list, and a spend from one wallet can never route to another wallet's saved address. Saved addresses are masked by default; tap the eye icon to reveal them for a check.

Spend is the only place in Sentry where funds leave your own keyspace, so the backend refuses a raw address on the execute path: it will only deliver to an entry you explicitly saved. Bitcoin addresses are checksum-validated (bech32, bech32m and base58check, mainnet only) and Solana addresses are validated as real ed25519 public keys, because a typo on either network is unrecoverable.

## Platform Fees[](https://www.sentry.trading/desktop/guide#fees "Copy link to this section")

Everything Sentry charges, in one table-shaped list. No hidden fees.

*   **Swaps (in-app and guest, both chains):** 1% of the input; quotes shown are already net of it. If a referral code is attached to your account, the full 1% goes to your referrer instead of Sentry — your cost is identical either way.
*   **Limit & DCA orders:** no extra fee — fills are normal swaps with the same 1%.
*   **Token launches:** free beyond gas. Sentry's revenue is the protocol leg of launch trading fees (0.5% of each trade at the floor on a WETH launch; 30% / 35% of collected fees on legacy V3 launches).
*   **Where the protocol leg goes:** through the on-chain Treasury Splitter — 60% operations, 40% market-buys SENTRY and mints permanently locked SENTRY liquidity. See [The SENTRY Token](https://www.sentry.trading/desktop/guide#sentry-token).
*   **Bridging:** no Sentry fee. Relay's routing cost is inside the quoted rate.
*   **Spend (Avici, Robinhood, Venmo, PayPal, Cash App):** 0.25% (25 bps) of the input, charged in source-chain ETH and already inside the quoted output. Relay's routing cost is in the same quote.
*   **Sending, receiving, key export, wallet import:** free (network gas only).
*   **Token locker:** no fees.
*   **Domain registration:** the ZNS registry price, quoted live; no Sentry markup.
*   **Boosts:** $25 / $50 / $125 for 50x / 100x / 500x packs (12 hours, stackable).
*   **Featured slots:** $25 / $50 / $125 for 6 / 12 / 24 hours.
*   **Username change:** $10.

Boosts, featured slots, and username changes are priced in USD and charged in ETH at the live rate at purchase time.

## Chains & Contracts[](https://www.sentry.trading/desktop/guide#chains-contracts "Copy link to this section")

Every contract Sentry deploys or routes through, per chain. Verify anything on the linked explorers — none of these addresses are secrets.

## Robinhood Chain (chain id 4663)

*   **Launch Factory (WETH pairs):**`0x472286b7d5c1B2A3cE1132eF73d3BcCF446C5cc1` — Uniswap v4, current.
*   **Launch Factory (stock pairs):**`0xd0A93885a387e3a8a14dd82776CF9104a3676b3A` — tokenized-stock base assets.
*   **Sentry LP Vault:**`0x0F0E601041Ec765B8bAB8c166840E291253F2Df0` — immutable LP custodian. Not a proxy; no withdrawal path exists.
*   **SENTRY token:**`0x1EcA20cfa4AF2e2fA2F4CE2bF8d97bFa184FD4D7` — the platform token; WETH-paired v4 pool, pays WETH reflections to holders.
*   **SENTRY fee hook:**`0xA695f84C86367d5aEA445e8289DBC7C4C4E530cc` — 40% → 2% floor decay; 37.5% WETH reflections / 37.5% LP compound / 25% treasury.
*   **Treasury Splitter:**`0x75450496fe333A93e1327368aa3c4130BF008697` — splits the platform fee leg 60% treasury / 40% into permanently locked SENTRY liquidity.
*   **Fee hook — WETH `launch()`:**`0x35c0098836FA0d10A015A95bf02C16387814f0CC`
*   **Fee hook — WETH `launchWithReflections()`:**`0x730AbADbB4f328520e5350F59126fbE1D67F70cc`
*   **Fee hook — stock pairs:**`0x5DaA88b65Bd47199eC92d3cDe01B56348e1270CC`
*   **Fee hook — stock pairs, legacy V2:**`0x7e6E258851575bD3F69e7A01981066A26329b0cC` — superseded; still serves the pools launched on it.
*   **Sentry Token Locker:**`0xbd0E7a242A323E5e4799Abe09b7516D9dA5ea81D` — trustless timelock, no owner, no fees, no admin withdrawal path.
*   **Sentry Swap Router (V2 + V3):**`0x8bfDC6Cc38DB45BDaf2F254415251b109058a97C`
*   **Sentry Swap Router (Uniswap v4):**`0x5811a5c7c4f73290cc9aa2235245bc9f48523662`
*   **Sentry Swap Router (stock multihop):**`0x641F05602B3dee5B35bAc08A1269827f2E84445D`
*   **Sentry Swap Router (PancakeSwap V3):**`0x4415F2360bfD9B1bF55500Cb28fA41dF95CB2d2b`
*   **Uniswap v4 PoolManager:**`0x8366a39CC670B4001A1121B8F6A443A643e40951`
*   **Uniswap V3 Factory (canonical):**`0x1f7d7550B1b028f7571E69A784071F0205FD2EfA`
*   **WETH9:**`0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`
*   **ZNS (.hood) registry:**`0x8f95ed212F37cDc19f5C0716c24966D9019939Ee`
*   **Legacy Launch Factory (Uniswap V3, retired):**`0x9e8f6f8214b01Fd4Cf1d73FB1fb7cf9f811036Cb` — its 93 LP positions were swept into the LP Vault; no new launches.
*   **Pool fee:** v4 launches use a dynamic fee that decays from 40% at launch to a permanent `1.7%` floor. Legacy V3 pools are the fixed `1%` tier.
*   **Fee split at the floor:** on a WETH `launch()`, the 1.7% is 1.0% creator / 0.2% back into the token's own liquidity / 0.5% platform. Reflection and stock launches also pay 0.8% to holders, leaving 0.5% creator and 0.2% platform. Legacy V3 pools split collected fees 70/30 creator/treasury (`creatorFeeBps` = 7000).
*   **Explorer:**[robinhoodchain.blockscout.com](https://robinhoodchain.blockscout.com/)
*   **Sentry subgraph (Goldsky):**[sentry-robinhood](https://api.goldsky.com/api/public/project_cmm7vh5xwsa8m01qmdr7w7u62/subgraphs/sentry-robinhood/1.2.0/gn) — public GraphQL API indexing every launch, pool, swap, and router trade.

## Ink (chain id 57073)

Ink runs the **same v4 launch stack as Robinhood Chain** — same factory implementation, same fee hooks, same 40% → 1.7% decay curve, same per-swap fee splits, same immutable LP vault custody. The only difference: Ink also supports stock-paired launches against Backed wrapped xStocks (Foundation v3 USDG books → Sentry v4 CAMPAIGN / wXSTOCK pool). WETH launches are unchanged.

*   **Launch Factory (v4, WETH and wrapped-xStock pairs):**`0xcF44b151aee1Ef69677f24cadED4d2d61b0D45BD`
*   **Fee hook — WETH `launch()`:**`0x976697AdCF27D0962d3B0b6304D5975bA647B0Cc`
*   **Fee hook — WETH `launchWithReflections()`:**`0x68ad7d7e2905656B7d89e56a43a6872F8487B0cC`
*   **Fee hook — CAMPAIGN / wXSTOCK:**`0x18195c33D8150B2e7f5166FC79e29a6C2B1fB0CC`
*   **SentryStockRouterInk:**`0x1b4D919149912c9781b086C8242729EE317631C8` — ETH hop (WETH→USDT0→USDG via Velodrome) + 75% WETH peel to the initialized Quotron proxies. Required for every stock-pair swap.
*   **SentryInkRouterV4 (WETH pairs only):**`0x5275de614E06DbA10546171c1e6d2a30A87844b7` — do not use this for wrapped-xStock launches.
*   **Sentry LP Vault:**`0x86585D4474C78c1C0fA1f8771682E9aD020787eC` — immutable LP custodian, no withdrawal path.
*   **Uniswap v4 PoolManager (canonical):**`0x360E68faCcca8cA495c1B759Fd9EEe466db9FB32`
*   **Uniswap v4 StateView:**`0x76fd297e2d437cd7f76d50f01afe6160f86e9990`
*   **Uniswap v4 Quoter:**`0x3972C00f7ed4885e145823eb7C655375d275A1C5` — allowlisted on the xStock hook so quotes simulate the 25% reflection skim.
*   **WETH9:**`0x4200000000000000000000000000000000000006`
*   **USDT0:**`0x0200C29006150606B650577BBE7B6248F58470c1` — 6 decimals; Velodrome hop.
*   **USDG (Ink):**`0xe343167631d89B6Ffc58B88d6b7fB0228795491D` — hop asset for ETH → wrapped xStock.
*   **Official Uniswap V3 Factory:**`0x640887A9ba3A9C53Ed27D0F7e8246A4F933f3424`
*   **Uniswap V3 SwapRouter02:**`0x177778F19E89dD1012BdBe603F144088A95C4B53`
*   **Uniswap V3 QuoterV2:**`0x96b572D2d880cf2Fa2563651BD23ADE6f5516652`
*   **Uniswap V3 Position Manager:**`0xC0836E5B058BBE22ae2266e1AC488A1A0fD8DCE8`
*   **Velodrome Slipstream SwapRouter:**`0x63951637d667f23D5251DEdc0f9123D22d8595be`
*   **Velodrome Slipstream Quoter:**`0x3FA596fAC2D6f7d16E01984897Ac04200Cb9cA05`
*   **Stock-paired launches:** same factory proxy; pair against Backed wrappers (wNVDAx, wAAPLx, …), never the raw rebasing xStock. ETH trades go through SentryStockRouterInk. Full integrator reference: [Ink xStocks (Developers)](https://www.sentry.trading/desktop/guide#ink-xstocks).
*   **ZNS (.ink) registry:**`0xFb2Cd41a8aeC89EFBb19575C6c48d872cE97A0A5`
*   **Legacy Launch Factory (V3):**`0xDc37e11B68052d1539fa23386eE58Ac444bf5BE1` — pre-v4 launches; positions self-custodied permanently, fees split 65/35 creator/treasury (`creatorFeeBps` = 6500).
*   **Explorer:**[explorer.inkonchain.com](https://explorer.inkonchain.com/)
*   **Sentry subgraph (Goldsky):**[sentry-ink](https://api.goldsky.com/api/public/project_cmm7vh5xwsa8m01qmdr7w7u62/subgraphs/sentry-ink/1.6.0/gn) — public GraphQL API indexing every Ink launch, pool, and swap.

## Ink xStocks (Developers)[](https://www.sentry.trading/desktop/guide#ink-xstocks "Copy link to this section")

Integrator reference for Backed wrapped-xStock pairs on Ink (chain id 57073). Use this if you are building a bot, router, indexer, or another frontend that needs to quote, swap, or launch against wNVDAx / wAAPLx / … .

## How a trade is routed

The v4 launch pool is always `CAMPAIGN / wXSTOCK`. ETH never sits in that pool. `SentryStockRouterInk` is the contract that lets a user spend or receive ETH:

ETH
  → peel 75% of the live decay fee as WETH
      60% creator  (0.90% of swap at the 2.00% floor)
      20% Quotron terminal pot (0.30%)
      20% Quotron growth sink  (0.30%)
  → WETH  → USDT0     Velodrome Slipstream, tickSpacing 100
  → USDT0 → USDG      Velodrome Slipstream, tickSpacing 1
  → USDG  → wXSTOCK   Foundation Uniswap V3, fee 500 (0.05%)
  → wXSTOCK → CAMPAIGN  Sentry v4 hook pool (dynamic fee, tickSpacing 200)
Sells reverse the hop; the WETH peel comes off the ETH proceeds. Wrapper-direct buys and sells skip the Velodrome legs: the router still peels 75% of the curve in the wrapper, converts that slice to WETH for creator / pots, and swaps the rest through the hook pool. The hook itself only skims the remaining 25% in the wrapper as holder reflections (or treasury during the first 10 minutes).

The 1% Sentry app fee charged on sentry.trading / the PWA API is **not** taken by this router. Integrators calling the contract directly pay only the on-chain curve (router peel + hook skim) plus venue hop fees.

## Core addresses

| Contract | Address | Notes |
| --- | --- | --- |
| **SentryStockRouterInk** | `0x1b4D919149912c9781b086C8242729EE317631C8` | Required swap router for every stock-pair trade |
| **Uniswap v4 PoolManager** | `0x360E68faCcca8cA495c1B759Fd9EEe466db9FB32` | Canonical Ink PoolManager |
| **CAMPAIGN / wXSTOCK hook** | `0x18195c33D8150B2e7f5166FC79e29a6C2B1fB0CC` | Flags `0x30CC`; router-gated; 40% → 2.00% floor |
| **Launch Factory v4** | `0xcF44b151aee1Ef69677f24cadED4d2d61b0D45BD` | Same proxy as WETH launches; `addStockBaseToken` registered the 8 wrappers |
| **Sentry LP Vault** | `0x86585D4474C78c1C0fA1f8771682E9aD020787eC` | Owns every v4 launch position; no withdraw |
| **v4 Quoter** | `0x3972C00f7ed4885e145823eb7C655375d275A1C5` | Allowlisted on the hook so quotes include the 25% skim |
| **v4 StateView** | `0x76fd297e2d437cd7f76d50f01afe6160f86e9990` | Slot0 / liquidity reads |
| **WETH9** | `0x4200000000000000000000000000000000000006` | 18 decimals |
| **USDT0** | `0x0200C29006150606B650577BBE7B6248F58470c1` | 6 decimals |
| **USDG** | `0xe343167631d89B6Ffc58B88d6b7fB0228795491D` | Foundation book quote asset |
| **Uni V3 Factory** | `0x640887A9ba3A9C53Ed27D0F7e8246A4F933f3424` | Official Ink Uniswap V3 |
| **Uni V3 SwapRouter02** | `0x177778F19E89dD1012BdBe603F144088A95C4B53` | USDG ↔ wrapper hop |
| **Uni V3 QuoterV2** | `0x96b572D2d880cf2Fa2563651BD23ADE6f5516652` | USDG ↔ wrapper quotes |
| **Velodrome SwapRouter** | `0x63951637d667f23D5251DEdc0f9123D22d8595be` | Old CL factory `0x04625B04…`; takes `tickSpacing`, not a Uni fee |
| **Velodrome Quoter** | `0x3FA596fAC2D6f7d16E01984897Ac04200Cb9cA05` | Same factory / tickSpacing ABI |
| **Velo WETH/USDT0 pool** | `0xaC7fC3e9b9d3377a90650fe62B858fF56bD841C9` | tickSpacing 100 |
| **Velo USDT0/USDG pool** | `0x31826a86cd62c6fa12a0a8441ec4c8bcfee8a453` | tickSpacing 1 |
| **Quotron terminal pot** | `0x0Aa7abB778DC11Dcaa1dBB16B72c70dD6f2d7A07` | 20% of the WETH peel; initialized ERC1967 proxy |
| **Quotron growth sink** | `0x73F5111EE91672c114923793C03B5c868d9C5E03` | 20% of the WETH peel; initialized ERC1967 proxy |

RPC: `https://rpc-gel.inkonchain.com`. Explorer: [explorer.inkonchain.com](https://explorer.inkonchain.com/). Do not use `SentryInkRouterV4` (`0x5275de614E06DbA10546171c1e6d2a30A87844b7`) for these pairs — that router is WETH-launch only.

## Registered wrappers

Eight Foundation wrappers are registered as launch bases. Each has a USDG book on official Uniswap V3 at fee `500` (0.05%). Logos and the live on-chain set: public `GET https://sentry.trading/api/pwa/evm/stocks?chain=ink`.

| Wrapper | Name | Wrapper (pair this) | Foundation V3 USDG pool | Raw xStock (do not pair) |
| --- | --- | --- | --- | --- |
| **wNVDAx** | NVIDIA | `0xa8ddb5Cd96b5222AFe198316E9A57CAA642850D5` | `0x01951DDb43A451500bfAF652d40C07309fAD4727` | `0xc845b2894dBDdD03858fd2D643b4eF725fE0849d` |
| **wAAPLx** | Apple | `0x943BF64D566c32A2Bcd41AC92FB63C111cC9De8f` | `0x8986Bb68391ad5b0aFd7605e8075b273ca0189D6` | `0x9d275685dC284C8eb1c79F6ABa7A63dc75EC890A` |
| **wTSLAx** | Tesla | `0xc3FdBe3A68EE5dE461D30415a8165cf9Aefe1171` | `0x09444CbDfF5CD4437150a1f26865a3Ed85D8ED5E` | `0x8aD3c73F833d3F9A523AB01476625f269AeB7cF0` |
| **wSPCXx** | SpaceX | `0x8e2eeD8b8B5E13Ea7BF38e50d7821d2C57309072` | `0xDf1531451f6D97f847B27FaC671738D113db1406` | `0x68FA48b1c2FE52b3d776e1953e0E782b5044CE28` |
| **wSPYx** | S&P 500 ETF | `0xE7E553Cd128F0011777323A0b44a7b96EA1CB540` | `0x06fB000Fe9C6505Eb3b2CdF52445d8C7d5690F47` | `0x90A2A4c76B5D8C0Bc892a69EA28aa775A8f2dD48` |
| **wPLTRx** | Palantir | `0x4A2df09536F62341C9f946427D16414C04e21342` | `0xe5D0EB7705889631adCB2550db0f8447D5cb6506` | `0x6D482CeC5F9dd1F05CCEE9Fd3Ff79B246170F8e2` |
| **wNFLXx** | Netflix | `0x7d87fD6A379714194a797c0bBB8B40c30D250856` | `0x111D25ac72aD434D895F6f1ac8184AB5175e99ff` | `0xa6A65ac27E76cD53cb790473e4345C46e5Ebf961` |
| **wMSTRx** | Strategy | `0x30987adF0B11dc698438a99BA04ec3a1AB2c7EaB` | `0x169F2ab4D25aBa4F9b2743658f8549641c9D069D` | `0xAE2f842eF90c0d5213259AB82639d5bBF649B08E` |

Wrappers are 18-decimal ERC-4626 vaults. `asset()` returns the raw xStock; `convertToAssets` / `convertToShares` give the share price if you need to mark the wrapper vs the rebase token. Sentry never holds or swaps the raw token.

## Swap router ABI

Approve the router before any token-in call (`sellExact*` or`buyExactStockForToken`). ETH-in sends `msg.value`. Pass `address(0)` as `recipient` to send to `msg.sender`.

// SentryStockRouterInk — 0x1b4D919149912c9781b086C8242729EE317631C8
function buyExactEthForStockToken(address token, address stock, uint256 minOut, address recipient) payable returns (uint256);
function sellExactStockTokenForEth(address token, address stock, uint256 amountIn, uint256 minOut) returns (uint256);
function buyExactStockForToken(address token, address stock, uint256 amountIn, uint256 minOut, address recipient) returns (uint256);
function sellExactTokenForStock(address token, address stock, uint256 amountIn, uint256 minOut) returns (uint256);
function wethFeePips(address token, bool isBuy) view returns (uint24);

event StockSwap(address indexed sender, address indexed token, address indexed stock, bool isBuy, uint256 amountIn, uint256 amountOut, uint256 wethFee);// ethers v6
const ROUTER = '0x1b4D919149912c9781b086C8242729EE317631C8';
const abi = [
  'function buyExactEthForStockToken(address token, address stock, uint256 minOut, address recipient) payable returns (uint256)',
  'function sellExactStockTokenForEth(address token, address stock, uint256 amountIn, uint256 minOut) returns (uint256)',
  'function buyExactStockForToken(address token, address stock, uint256 amountIn, uint256 minOut, address recipient) returns (uint256)',
  'function sellExactTokenForStock(address token, address stock, uint256 amountIn, uint256 minOut) returns (uint256)',
  'function wethFeePips(address token, bool isBuy) view returns (uint24)',
];
const router = new ethers.Contract(ROUTER, abi, signer);

// Buy campaign token with ETH
await router.buyExactEthForStockToken(
  campaignToken,
  wrapper,          // e.g. wNVDAx
  minOut,
  ethers.ZeroAddress,
  { value: ethers.parseEther('0.01') },
);

// Sell campaign token for ETH (approve router first)
await token.approve(ROUTER, amountIn);
await router.sellExactStockTokenForEth(campaignToken, wrapper, amountIn, minOut);
## Factory + hook discovery

Resolve the pool from the factory — do not hardcode currency order. The hook address is on the pool key.

// SentryLaunchFactoryV4 — 0xcF44b151aee1Ef69677f24cadED4d2d61b0D45BD
function launches(address token) view returns (address baseToken, address creator, address hook, int24 tickLower, int24 tickUpper);
function poolKeyOf(address token) view returns (tuple(address currency0, address currency1, uint24 fee, int24 tickSpacing, address hooks));
function poolIdOf(address token) view returns (bytes32);
function isStockBase(address) view returns (bool);
function feeRecipientOf(address token) view returns (address);
function launch(string name, string symbol, address baseToken) returns (address);
function launchWithFeeRecipient(string name, string symbol, address baseToken, address feeRecipient) returns (address);
function launchWithWhitelist(string name, string symbol, address baseToken, address feeRecipient, address[] whitelist) returns (address);

// SentryInkXStockFeeHook — 0x18195c33D8150B2e7f5166FC79e29a6C2B1fB0CC
function currentFee(bytes32 poolId) view returns (uint24);   // pips, 1e6 = 100%
function endFee() view returns (uint24);                     // 20000 = 2.00%
function launchWhitelist(bytes32 poolId, address wallet) view returns (bool);
function swapRouter() view returns (address);

// Pool key every CAMPAIGN / wXSTOCK launch uses
// fee          = 8388608   // Uniswap v4 DYNAMIC_FEE_FLAG (0x800000)
// tickSpacing  = 200
// hooks        = 0x18195c33D8150B2e7f5166FC79e29a6C2B1fB0CC
// currency0/1  = sorted(token, wrapper)
`baseToken == address(0)` on `launches(token)` means the address is not a Sentry v4 launch. If `baseToken` is one of the eight wrappers, route through `SentryStockRouterInk`, not the WETH v4 router.

## Quoting

Quote the hop yourself (the router has no `quote` function). Subtract `wethFeePips(token, isBuy)` from the ETH notionals — that is 75% of the live hook curve, in pips. Whitelisted `tx.origin` buyers pay `endFee` instead of the decay, matching the hook.

// Buy quote (ETH → token)
feePips  = router.wethFeePips(token, true)          // e.g. 15000 at the floor
afterFee = ethIn * (1_000_000 - feePips) / 1_000_000
usdt0    = veloQuoter.quoteExactInputSingle({ tokenIn: WETH,  tokenOut: USDT0, amountIn: afterFee, tickSpacing: 100, sqrtPriceLimitX96: 0 })
usdg     = veloQuoter.quoteExactInputSingle({ tokenIn: USDT0, tokenOut: USDG,  amountIn: usdt0,    tickSpacing: 1,   sqrtPriceLimitX96: 0 })
wrapper  = uniV3Quoter.quoteExactInputSingle({ tokenIn: USDG, tokenOut: wXSTOCK, amountIn: usdg, fee: 500, sqrtPriceLimitX96: 0 })
tokenOut = v4Quoter.quoteExactInputSingle({
  poolKey: factory.poolKeyOf(token),                // or {currency0, currency1, fee: 8388608, tickSpacing: 200, hooks}
  zeroForOne: wrapper == currency0,
  exactAmount: wrapper,
  hookData: '0x',
})

// Sell quote is the reverse; apply wethFeePips(token, false) to the WETH out.

// Velodrome quoter — 0x3FA596fAC2D6f7d16E01984897Ac04200Cb9cA05
function quoteExactInputSingle((address tokenIn, address tokenOut, uint256 amountIn, int24 tickSpacing, uint160 sqrtPriceLimitX96))
  returns (uint256 amountOut, uint160 sqrtPriceX96After, uint32 initializedTicksCrossed, uint256 gasEstimate);

// Uni V3 QuoterV2 — 0x96b572D2d880cf2Fa2563651BD23ADE6f5516652
function quoteExactInputSingle((address tokenIn, address tokenOut, uint256 amountIn, uint24 fee, uint160 sqrtPriceLimitX96))
  returns (uint256 amountOut, uint160 sqrtPriceX96After, uint32 initializedTicksCrossed, uint256 gasEstimate);

// Uni v4 Quoter — 0x3972C00f7ed4885e145823eb7C655375d275A1C5
function quoteExactInputSingle(((address currency0, address currency1, uint24 fee, int24 tickSpacing, address hooks) poolKey, bool zeroForOne, uint128 exactAmount, bytes hookData) params)
  returns (uint256 amountOut, uint256 gasEstimate);
## Fees on the curve

Decay is 40% flat for 3 minutes, then a 3-minute half-life, to a permanent **2.00%** floor (20,000 pips). Reflections unlock 10 minutes after launch. At the floor every trade splits like this — all of it out of the 2.00%, never on top:

| Leg | Share of the 2.00% | Of the trade | Asset / destination |
| --- | --- | --- | --- |
| **Creator** | 60% of the 75% WETH peel | 0.90% | WETH to `feeRecipientOf(token)` |
| **Terminal pot** | 20% of the WETH peel | 0.30% | WETH via `donate()` |
| **Growth sink** | 20% of the WETH peel | 0.30% | WETH via `donate()` |
| **Holder reflections** | The hook's 25% | 0.50% | wXSTOCK via `notifyReward()` on the campaign token |

During the opening window the same 25% hook skim is sent to treasury so snipers are not paid as “holders.” Launch-whitelist wallets pay `endFee` on buys only; sells are never exempt.

## Holder reflections ABI

Campaign tokens are dividend tokens. Zero transfer tax — claim anytime from the token itself.

function rewardToken() view returns (address);                    // the wrapper
function withdrawableDividendOf(address) view returns (uint256);
function accumulativeDividendOf(address) view returns (uint256);
function withdrawnDividends(address) view returns (uint256);
function claim() returns (uint256);
## Launching from another app

Call `launch` / `launchWithFeeRecipient` / `launchWithWhitelist` on the v4 factory with `baseToken` set to a registered wrapper. The factory routes stock bases to the xStock hook automatically. Do not use `launchWithReflections` for these pairs — that entrypoint is the WETH reflection hook. Confirm the base first:

factory.isStockBase(wrapper) == true
GET https://sentry.trading/api/pwa/evm/stocks?chain=ink   // live registered set
## Index + verify

*   **Subgraph:**[sentry-ink/1.5.0](https://api.goldsky.com/api/public/project_cmm7vh5xwsa8m01qmdr7w7u62/subgraphs/sentry-ink/1.6.0/gn) — launches, pool keys, swaps, and `WethFeePaid` from the stock router (creator fees on these tokens are WETH, not the wrapper).
*   **Router events:**`StockSwap` and `WethFeePaid` on `0x1b4D919149912c9781b086C8242729EE317631C8`.
*   **User walkthrough** (non-integrator): [Stocks as Base Pairs](https://www.sentry.trading/desktop/guide#stock-pairs).

## Ecosystem Stats[](https://www.sentry.trading/desktop/guide#stats "Copy link to this section")

Live protocol metrics, straight from public on-chain data — the same subgraphs and contracts anyone can query. No dashboards of trust, just indexed chain history.

Sentry App sentry.trading · live

Accounts created-
Daily active users (≥1 transaction, 24h)-
Push notification subscribers-

Robinhood Chain chain id 4663 · live from the Sentry subgraph

Tokens launched-
Pools created-
Swaps-
Total volume-
LP fees generated-
Fees collected-
Paid to creators-
Swaps routed via Sentry (all venues)-
Routed volume (all venues)-
App fees earned-

Ink chain id 57073 · live from the Sentry subgraph + factory events

Tokens launched via Sentry-
Swaps (Sentry pools)-
Total volume (Sentry pools)-
LP fees generated (Sentry pools)-
Fee collections-
Creator payouts-
Paid to creators-

## Brand Kit[](https://www.sentry.trading/desktop/guide#brand-kit "Copy link to this section")

The real files, the same ones the app itself ships. If you're writing about Sentry, listing it, or building on top of it, take them from here rather than screenshotting the header.

[**Download the full kit**Marks, app icons, banners and the usage rules · ZIP, ~9 MB ZIP](https://www.sentry.trading/brand/sentry-brand-kit.zip)

### Using it

*   Leave clear space of half the mark’s width on every side.
*   Below 24px cap height, use the mark on its own instead of the lockup.
*   Put the mark on black, on the mint plate, or knocked out of a photo with enough contrast.
*   Don’t rotate the mark. The pupil sits off-centre on purpose.
*   Don’t add a stroke, glow or drop shadow. The glass already carries the depth.
*   Don’t stretch the lockup, rebuild the plate as a flat fill, or use the retired gold crest.

## Navigating the App[](https://www.sentry.trading/desktop/guide#navigating "Copy link to this section")

Two layouts. Desktop has a fixed top nav and a right-side wallet rail. Mobile has a bottom tab bar and a stacked single-column layout.

## Desktop

*   **Top nav:** Sentry logo and the chain selector, then `Discover`, `Social`, `Create`, `Profile`, and `Tools`. The active page gets an underlined yellow accent.
*   **Top nav (icons, far right):** trade history (clock), screenshot this page (camera), and `Settings` (gear). All three are reachable from every page.
*   **Profile tab:** your profile header, net worth / ETH / token value / estimated PnL, a portfolio value chart, allocation donut, your assets, and your activity calendar.
*   **Right rail:** Always-visible wallet panel on Discover. Shows your portfolio total, the wallet address, action tiles (Send / Swap / Receive / Bridge), and your token holdings. Its header carries the username pill and a `»` button that collapses the rail — handy for clean screenshots. When logged out it shows a yellow `LOGIN` button instead.
*   **Tokens page views:**`All` (merged grid of Sentry and Bankr launches with launchpad badges), `Sentry` (the advanced terminal table with multi-timeframe volume, transactions, and holders), and `Bankr` (Robinhood Chain only).
*   **Token detail:** Click any row to open the token's detail view in-place: chart, stats, holders, socials, and the live trades feed.
*   **In-rail swap:** Tap a row's Swap button or the Swap action tile to flip the rail into swap mode with the token preselected.

## Mobile

*   **Bottom nav:** Wallet · Swap · Create · Tokens · Ecosystem. Create sits in the center and opens the launch sheet from anywhere; the other tabs navigate.
*   **Header:** Avatar + username on the left (tap for the account and wallet switcher); rotating price ticker centered; Activity (clock), `Settings` (gear), and search icons on the right.
*   **Wallet page:** action tiles (Send / Swap / Receive / Bridge), Holdings with the dust filter, and tabs for NFTs (including Set-as-PFP), My Tokens (your creator dashboard), and Locks.
*   **Tokens page furniture:** featured hero cards up top (auto-curated by market cap), then the volume runner bar with the paid [featured slots](https://www.sentry.trading/desktop/guide#boosts-featured) on the left and the Trending marquee (with any boosted tokens first) on the right.
*   **Modals:** clicking the backdrop dismisses; modals layer on top of each other so closing the inner one returns you to the parent.

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

## V2 Roadmap[](https://www.sentry.trading/desktop/guide#roadmap "Copy link to this section")

What V1 explicitly leaves out, and how it lands when it ships.

## Solana surface

V1 hides the Solana side entirely behind a feature flag. The wallet still exists on the account, the keys are still encrypted at rest, and the import/export plumbing is intact — only the UI is suppressed. Once we're happy with the Ink-only experience, the flag flips and the rest of the surface re-enters: SOL appears in the price ticker, Solana wallets show in Send/Receive, the Solana segment returns to Set Primary, Register SNS reappears in Settings, and Solana token deploys come back to Create.

## Cross-chain swaps via Relay

Today the Bridge tile moves ETH between mainnet, Ink, and Robinhood Chain in all six directions. Stage 2 expands that through the Relay aggregator: pay in any token on any chain, receive on Ink or Robinhood (or vice-versa), routed through Relay's liquidity. Same swap form, just a wider chain picker.

## Cross-chain composer

Stage 3 is the unifier: one transaction that, e.g., bridges ETH from mainnet, swaps it for SENTRY on Ink, and stakes the result — composed and signed once. Sentry handles the routing under the hood; you just pick the start state and the end state.

## Team[](https://www.sentry.trading/desktop/guide#team "Copy link to this section")

The people building Sentry. Reach the team at [team@sentry.trading](mailto:team@sentry.trading).

![Image 1: Sergio Luna](https://www.sentry.trading/team/sergio-luna.png)

Sergio Luna

Founder & CEO

Founder and CEO of Sentry. Founder and CEO of Mavrk, Inc., the company that builds the product.

## Troubleshooting[](https://www.sentry.trading/desktop/guide#troubleshooting "Copy link to this section")

### Swap fails with “insufficient funds”

Check your ETH balance vs the swap amount + gas. The MAX button auto-deducts a small gas reserve, but very large swaps near your full balance can still tip over.

### Token doesn't appear in the picker

The picker lists the catalog of tokens launched via Sentry (plus Bankr tokens on Robinhood Chain). To trade any other token, paste its contract address into the search and the picker resolves it from the chain directly.

### I'm not getting push notifications

Check `Settings`>`Notifications` is ON for this device. On iPhone, push only works when Sentry is installed to the Home Screen (iOS 16.4+), not in a Safari tab. If the toggle says “Blocked by your browser”, re-allow notifications for sentry.trading in your browser's site settings.

### My boost or featured slot isn't showing yet

Boosts go live instantly. Featured slots go live instantly when a slot is open; if all three are taken, your purchase is queued and activates automatically when a slot expires. The purchase modal showed your start time at checkout.

### Bridge stuck on “pending”

Relay finalizes most bridges in seconds, but congestion on either chain can extend that to minutes. The Bridge sheet polls until success or failure and updates the status pill — you can safely close the sheet, the Activity tab will show the final state with a `relay.link` link to the full receipt.

### Export Key says “Wallet decrypt failed”

This means the encryption key the backend has doesn't match the one used to encrypt that wallet — usually due to env-var drift between deploys. Reach out and we'll fix it; your wallet isn't lost, just temporarily unreadable.

### I logged out and can't find the login button

It's in two places. Desktop: the rail toolbar shows a yellow `LOGIN` button when you're signed out. Mobile: the wallet page shows an empty-state card with a Login CTA. Either one routes you back into the connection screen.

### I forgot my password

If your account has a **verified email**, reach out through an official channel — the team can reset your password after you prove control of that email (plus your 2FA code if enabled). If not, recovery isn't possible: there's nothing on file to verify you against. If you're still signed in on any device, export your private keys and verify an email now, before you need either.

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

## Resources[](https://www.sentry.trading/desktop/guide#resources "Copy link to this section")

*   [sentry-guide.md](https://www.sentry.trading/sentry-guide.md) — this entire guide as one markdown file, made to hand to AI assistants
*   [Ink xStocks (Developers)](https://www.sentry.trading/desktop/guide#ink-xstocks) — PoolManager, `SentryStockRouterInk`, wrapper registry, and ABIs for integrating CAMPAIGN / wXSTOCK pairs
*   [Relay Protocol](https://relay.link/) — the cross-chain router behind the Bridge tile
*   [ZNS Connect](https://zns.bio/) — the `.ink` domain registry
*   [Ink Chain](https://inkonchain.com/) — official Ink documentation
*   [Ink Explorer](https://explorer.inkonchain.com/) — verify any transaction on Ink
*   [Robinhood Chain Explorer](https://robinhoodchain.blockscout.com/) — verify any transaction on Robinhood Chain
*   [Robinhood Chain Docs](https://docs.robinhood.com/chain/) — official chain documentation
*   [Sentry Robinhood subgraph](https://api.goldsky.com/api/public/project_cmm7vh5xwsa8m01qmdr7w7u62/subgraphs/sentry-robinhood/1.2.0/gn) — public GraphQL API for every launch, pool, and swap
*   [@SentryBuyBot](https://t.me/SentryBuyBot) — Telegram buy alerts for any Robinhood Chain token, with paid featured slots
*   [@sentrylauncher](https://x.com/sentrylauncher) on X — updates and announcements
*   [Sentry Telegram](https://t.me/sentrylauncher) — community + support

## Terms of Service[](https://www.sentry.trading/desktop/guide#tos "Copy link to this section")

Last updated · July 2026

## 1. Acceptance of these terms

By accessing or using Sentry (sentry.trading, the Sentry web app, the Sentry PWA, or any associated interface), you agree to be bound by these Terms of Service. If you do not agree, do not use the service.

## 2. What Sentry is

Sentry is non-custodial software that provides:

*   A swap interface that aggregates quotes across public on-chain DEX venues (Uniswap V3, Uniswap V2, Uniswap v4 Doppler pools, and PancakeSwap V3 on Robinhood Chain; Uniswap V3 on Ink) and executes on the best route.
*   A token-launch tool that deploys ERC-20 contracts and creates locked V3 liquidity positions on the user's behalf on either chain.
*   A token-locking interface to the Sentry Token Locker, a trustless timelock contract on Robinhood Chain.
*   A bridging interface that routes ETH between Ethereum mainnet, Ink, and Robinhood Chain via Relay Protocol.
*   A domain-registration interface for ZNS _.hood_ and _.ink_ domains, premier-name auctions, and display resolution for both TLDs.
*   Paid visibility products (token boosts and featured slots), paid username changes, push notifications, and a token watchlist.
*   Encrypted server-side custody of user-elected private keys, used solely to sign user-initiated transactions.

**Fees.** In-app and guest swaps carry a 1% platform fee taken from the swap input on both supported chains; quotes shown in the interface are net of this fee. Sentry additionally receives the treasury share of trading fees accrued by locked launch liquidity (30% on Robinhood Chain, 35% on Ink; the majority belongs to each token's creator), proceeds from boosts, featured slots, and premier domain auctions, and the $10 username-change fee. Sentry does not charge fees for bridging, sending, token locking, or key export beyond network gas. Boost, featured-slot, and username-change purchases are final and non-refundable.

Sentry is **not** a broker, dealer, exchange, custodian, money transmitter, or investment advisor. Sentry does not custody user funds in a fiduciary capacity, does not facilitate fiat on-ramps or off-ramps, and does not provide investment advice or portfolio management.

## 3. Eligibility

You may use Sentry only if you are at least 18 years old (or the age of majority in your jurisdiction, whichever is greater), legally permitted to use the service in your jurisdiction, and not located in or a national of any country subject to U.S. sanctions or embargoes. By using Sentry, you represent that you meet these requirements.

## 4. Your account and your keys

Sentry accounts are created with a username and password. The password is hashed with bcrypt server-side; the plaintext is never stored. You are solely responsible for safeguarding your password. Password recovery is available only for accounts with a verified email address (added voluntarily in Settings), after identity is proven against that email and any enabled two-factor method; accounts without a verified email cannot be recovered.

Generated and imported wallets are stored as AES-256-GCM-encrypted ciphertext. You may export the plaintext private key for any wallet at any time via the Settings hub. The exported key gives you full custody — Sentry retains no ability to override or recover keys you have exported.

## 5. User-deployed tokens

Tokens deployed through Sentry's Create flow are deployed by the user and owned by the public market the moment the deploy transaction confirms. The launch sequence (renouncement, LP lock, no pre-mine — see [Launch Mechanics](https://www.sentry.trading/desktop/guide#launch-mechanics)) is mechanical and identical for every token; Sentry does not select, vet, audit, or endorse any individual token.

The fact that a token appears in Sentry's trending list, search picker, or featured slots does not constitute endorsement, recommendation, or warranty. You are solely responsible for evaluating any token you trade or deploy.

## 6. No investment advice

Nothing in the Sentry app, the Guide, this Terms of Service, the Privacy Policy, or any official Sentry communication channel (X, Telegram, email) constitutes investment advice, financial advice, legal advice, or tax advice. All trades and deploys are user-initiated. Token prices are highly volatile and may go to zero. You are solely responsible for any tax consequences of activity conducted through Sentry in your jurisdiction.

## 7. Risk disclosure

Use of Sentry involves risks including but not limited to:

*   **Smart-contract risk.** Bugs in deployed contracts (Sentry's factories, the underlying DEX contracts, Relay, ZNS, or third-party token contracts) may result in partial or total loss of funds.
*   **Market risk.** Token prices are volatile and may fall to zero, and liquidity may disappear without warning.
*   **Counterparty risk.** Third-party tokens deployed through Sentry are user-deployed and unvetted. The launch mechanics do not guarantee project quality, team integrity, or future market behavior.
*   **Regulatory risk.** The legal and regulatory treatment of token trading, token issuance, and DeFi protocols is evolving and varies by jurisdiction.
*   **Operational risk.** Software bugs, RPC failures, indexer lag, or service interruptions may affect your ability to interact with the app.
*   **Self-custody risk.** Lost passwords, lost keys, mistaken transactions, and signed transactions to malicious contracts are not recoverable by Sentry.

## 8. Prohibited uses

You agree not to use Sentry for any unlawful purpose, including but not limited to: money laundering, sanctions evasion, terrorism financing, fraud, market manipulation, deploying tokens that infringe intellectual property, or activity that violates the laws of your jurisdiction.

## 9. Disclaimer of warranties

Sentry is provided “AS IS” and “AS AVAILABLE” without warranty of any kind, express or implied, including but not limited to the implied warranties of merchantability, fitness for a particular purpose, non-infringement, or uninterrupted availability. Sentry does not warrant that the service will meet your requirements, that operation will be uninterrupted or error-free, or that any token or transaction will perform as expected.

## 10. Limitation of liability

To the maximum extent permitted by law, Sentry, its operators, and its contributors shall not be liable for any indirect, incidental, special, consequential, exemplary, or punitive damages — including but not limited to loss of profits, loss of data, loss of tokens, loss of access, or loss of cryptocurrency value — arising out of or in connection with your use of Sentry. Aggregate liability for any direct damages shall not exceed the greater of one hundred U.S. dollars ($100) or the total fees you paid Sentry directly in the twelve months preceding the claim.

## 11. Indemnification

You agree to indemnify and hold Sentry, its operators, and its contributors harmless from any claim, demand, loss, or damage arising from your use of the service, your breach of these terms, or your violation of any law or third-party right.

## 12. Modifications

Sentry may update these terms from time to time. Material changes will be announced on Sentry's X or Telegram channel and reflected in the “Last updated” date above. Continued use of the service after a change constitutes acceptance of the updated terms.

## 13. Termination

Sentry may suspend or terminate access to the service at its sole discretion, including for violation of these terms. Termination of access does not affect your on-chain assets — you can export private keys at any time prior to termination, and funds in any wallet you hold the keys for remain under your control regardless of your access to the Sentry interface.

## 14. Governing law

These terms are governed by the laws of the State of Texas, United States, without regard to conflict-of-law principles. Any dispute arising from these terms or your use of Sentry shall be resolved in the state or federal courts located in Travis County, Texas, and you consent to personal jurisdiction there.

## 15. Contact

Questions about these terms can be directed to [@sentrylauncher](https://x.com/sentrylauncher) on X or the [Sentry Telegram](https://t.me/sentrylauncher).

## Privacy Policy[](https://www.sentry.trading/desktop/guide#privacy "Copy link to this section")

Last updated · July 2026

## 1. The summary

Sentry is non-custodial software with a deliberately small data surface. We collect only what we need to authenticate your account, sign transactions you initiate, and catalog tokens you deploy. We don't require an email or phone number (an email is stored only if you voluntarily verify one for your checkmark and account recovery), and we don't collect browsing history, device fingerprints, ad-tracking data, or payment information. We don't sell anything to anyone, and we don't share with third parties beyond the public on-chain RPCs and decentralized infrastructure providers needed to actually execute the actions you ask the app to take.

## 2. What we collect

*   **Username** — display label you pick at sign-up. Visible in the app.
*   **Password hash** — bcrypt(password, cost=10). The plaintext password is never stored or logged.
*   **Wallet addresses** — the public addresses of your generated and imported wallets. These are public on-chain anyway.
*   **Encrypted private keys** — AES-256-GCM ciphertext of generated and imported wallet keys. Stored as `<iv>:<authTag>:<ciphertext>`. The encryption key lives in our hosting provider's environment, not in the database.
*   **Session IDs** — random identifiers issued at login, expire after 24 hours, used to authenticate API requests.
*   **Deploy metadata** — for tokens you deploy through Create: name, symbol, logo URL, optional socials (X, Telegram, website), contract address. This populates the public token catalog.
*   **Avatar data** — an uploaded avatar image, or the chain/contract/token-id reference of an NFT you set as your PFP.
*   **Passkey credentials and 2FA secrets** — WebAuthn public keys for passkeys you register, and your TOTP secret (AES-256-GCM encrypted) plus hashed backup codes if you enable 2FA.
*   **Verified email (optional)** — only if you verify one in Verification Status: the address itself, used for your verification checkmark and as the identity anchor for password recovery. Remove it any time from the same pane.
*   **X account link** — if you connect X: your X user id and handle, and an encrypted OAuth token. We request read-only scopes.
*   **Push subscriptions** — if you enable notifications: the browser push endpoint for each subscribed device. Deleted when you toggle notifications off.
*   **Watchlist and purchases** — tokens you star, and ledger rows for boosts, featured slots, premier-domain bids, and username changes you buy (price, tx hash, timestamps).
*   **First-party product analytics** — page views, time on page, clicks, and key product events (e.g. swap completed), collected by our own backend to understand how the app is used. No third-party analytics SDK is involved and the data is not sold or shared.

## 3. What we do NOT collect

*   **Email or phone number at sign-up.** Neither is required to create or use an account. An email is stored only if you voluntarily verify one later (see above); accounts without one have no recovery path by design.
*   **Real name, date of birth, or government ID.** Sentry has no KYC layer.
*   **Payment information.** Sentry doesn't process fiat or accept credit cards.
*   **Browsing history outside the app.** No third-party trackers, no ad pixels, no session-replay tools.
*   **Device fingerprints.** No canvas fingerprinting, no audio fingerprinting, no font fingerprinting.
*   **Third-party behavioral analytics.** No mouse-movement tracking, no session replay, no session-recording heatmaps, no advertising SDKs. (We do collect first-party product analytics, described above, on our own infrastructure. The activity calendar on your Profile is built from that first-party data and is only ever shown to you.)

## 4. How we use what we collect

*   **Authentication.** Username + password hash compare on login.
*   **Transaction signing.** Encrypted private keys are decrypted in memory only at signing time, used to sign the specific transaction you authorized, then dropped.
*   **Public token catalog.** Deploy metadata populates the trending and search lists in the app.
*   **Service operation.** Session IDs gate authenticated API calls.

We do not use your data for advertising, profiling, or machine-learning training, and we don't sell or rent it to anyone.

## 5. Third parties

Sentry routes through several decentralized infrastructure providers. Each one sees a narrow slice of your activity, and each one has its own privacy posture independent of Sentry.

*   **Chain RPCs (Ink, Robinhood Chain, Ethereum mainnet)** — see the public on-chain transactions Sentry broadcasts on your behalf, the same way any wallet's RPC would.
*   **Goldsky subgraphs (Ink DEX, Sentry Robinhood)** — Sentry queries these public GraphQL APIs for token, swap, and volume data. The endpoint sees the IP of the request, not your account.
*   **DexScreener and GeckoTerminal** — market stats and chart candles are fetched directly from your browser, so those services see your IP address and the token/pool you are viewing (the same as visiting their websites). They never see your account, wallets, or keys.
*   **Blockscout explorers** — holder counts, top-holder lists, and activity are read via our backend from the public Ink and Robinhood Chain explorers; Blockscout sees our server's requests, not yours.
*   **Relay Protocol** — for cross-chain bridges. Relay sees the source and destination addresses (already public on-chain) and the bridge amounts.
*   **ZNS Connect** — for `.ink` domain registrations and `.ink`/`.hood` name resolution. ZNS sees the domain you register and the wallet that registered it (both already public on-chain).
*   **Supabase** — Sentry uses Supabase for the token-catalog database and for token logo image hosting. Supabase sees the same data Sentry stores (it IS the database).
*   **X (Twitter)** — only if you connect X. The OAuth flow happens on x.com; Sentry receives your X user id, handle, and a read-scoped token.
*   **Browser push services** — only if you enable notifications. Push is delivered through your browser vendor's push service (Apple, Google, or Mozilla), which sees encrypted payloads addressed to your device endpoint.
*   **Vercel Analytics** — basic page-view analytics (URL, referrer, viewport size, country). No personally identifiable data, no session recording, no individual-user profiling.

## 6. Cookies

Sentry uses a single first-party session cookie to keep you logged in. We do not set third-party cookies, advertising cookies, or tracking cookies. The session cookie is HttpOnly, Secure, and SameSite=Lax.

## 7. Data retention

Account data (username, password hash, encrypted keys, session IDs) is retained for the lifetime of the account. Deploy metadata is retained as long as the token exists in the public catalog. You can request deletion of your account by reaching out via the contact channels below — note that on-chain history (the wallet addresses, swap transactions, token deploys) is permanent and outside Sentry's control.

## 8. Security

Passwords are hashed with bcrypt at cost 10. Private keys are encrypted at rest with AES-256-GCM (256-bit key, 128-bit random IV per write, 128-bit auth tag). All API traffic is TLS-encrypted. The encryption key for stored ciphertexts is held in the backend service's hosting environment, separate from the database.

## 9. Your rights

*   **Export your private keys** at any time via the Settings hub. This gives you full custody of any wallet on your account.
*   **Delete your account** by reaching out via the contact channels below.
*   **Access the data we hold** on your account by request. We'll send you an export of everything documented above.

## 10. Children

Sentry is not directed at children under 18. We don't knowingly collect data from anyone under 18. If you believe a minor has signed up, contact us and we'll delete the account.

## 11. International users

Sentry is operated from the United States. By using the service from outside the US, you consent to the transfer of your data to and storage in the US.

## 12. Changes to this policy

We may update this policy. Material changes will be reflected in the “Last updated” date above and announced on Sentry's X or Telegram channel.

## 13. Contact

Questions about this policy or requests under it can be directed to [@sentrylauncher](https://x.com/sentrylauncher) on X or the [Sentry Telegram](https://t.me/sentrylauncher).

Links/Buttons:
- [Skip to tokens list](https://www.sentry.trading/desktop/guide#tokens-list)
- [Discover](https://www.sentry.trading/desktop/tokens)
- [Social](https://www.sentry.trading/desktop/social)
- [Profile](https://www.sentry.trading/desktop/portfolio)
- [Tools](https://www.sentry.trading/desktop/tools)
- [](https://www.sentry.trading/desktop/guide#tos)
- [sentry.trading/swap](https://www.sentry.trading/swap)
- [sentry.trading/sentry-guide.md](https://www.sentry.trading/sentry-guide.md)
- [export the private key](https://www.sentry.trading/desktop/guide#exporting-keys)
- [Launch Mechanics](https://www.sentry.trading/desktop/guide#launch-mechanics)
- [Disclaimers](https://www.sentry.trading/desktop/guide#disclaimers)
- [Privacy](https://www.sentry.trading/desktop/guide#privacy)
- [import one](https://www.sentry.trading/desktop/guide#importing-wallets)
- [Bridge](https://www.sentry.trading/desktop/guide#bridging)
- [Account Security](https://www.sentry.trading/desktop/guide#account-security)
- [verification checkmark](https://www.sentry.trading/desktop/guide#social)
- [@sentrylauncher](https://x.com/sentrylauncher)
- [PNL cards](https://www.sentry.trading/desktop/guide#charts-pnl)
- [Set Primary](https://www.sentry.trading/desktop/guide#set-primary)
- [Details](https://www.sentry.trading/desktop/guide#referrals)
- [Platform Fees](https://www.sentry.trading/desktop/guide#fees)
- [Watchlist & Alerts](https://www.sentry.trading/desktop/guide#watchlist)
- [Push Notifications](https://www.sentry.trading/desktop/guide#notifications)
- [Telegram trading bot](https://www.sentry.trading/desktop/guide#telegram-bots)
- [launch whitelist](https://www.sentry.trading/desktop/guide#anti-snipe)
- [The SENTRY Token](https://www.sentry.trading/desktop/guide#sentry-token)
- [Creator Rewards](https://www.sentry.trading/desktop/guide#creator-rewards)
- [explorer.inkonchain.com](https://explorer.inkonchain.com/)
- [robinhoodchain.blockscout.com](https://robinhoodchain.blockscout.com/)
- [Ink xStocks (Developers)](https://www.sentry.trading/desktop/guide#ink-xstocks)
- [sentry.trading/lock](https://www.sentry.trading/lock)
- [ZNS](https://zns.bio/)
- [Relay Protocol](https://relay.link/)
- [sentry-robinhood](https://api.goldsky.com/api/public/project_cmm7vh5xwsa8m01qmdr7w7u62/subgraphs/sentry-robinhood/1.2.0/gn)
- [sentry-ink](https://api.goldsky.com/api/public/project_cmm7vh5xwsa8m01qmdr7w7u62/subgraphs/sentry-ink/1.6.0/gn)
- [Download the full kitMarks, app icons, banners and the usage rules · ZIP, ~9 MB ZIP](https://www.sentry.trading/brand/sentry-brand-kit.zip)
- [LockupSVG · default](https://www.sentry.trading/brand/sentry-lockup.svg)
- [MarkSVG · mint](https://www.sentry.trading/brand/sentry-mark.svg)
- [Mark, whiteSVG · on colour](https://www.sentry.trading/brand/sentry-mark-white.svg)
- [Lockup, monoSVG · inherits colour](https://www.sentry.trading/brand/sentry-lockup-monochrome.svg)
- [App icon, circlePNG · 1024](https://www.sentry.trading/brand/sentry-icon-circle-1024.png)
- [App icon, maskablePNG · 1024](https://www.sentry.trading/brand/sentry-icon-maskable-1024.png)
- [Animated logoGIF · 512](https://www.sentry.trading/brand/sentry-logo-512.gif)
- [FaviconICO · 16–256](https://www.sentry.trading/brand/favicon.ico)
- [BannerPNG · 1500×500](https://www.sentry.trading/brand/sentry-banner-1500x500.png)
- [Banner, framedPNG · 1500×500](https://www.sentry.trading/brand/sentry-banner-framed-1500x500.png)
- [Banner, animatedGIF · 1500×500](https://www.sentry.trading/brand/sentry-banner-1500x500.gif)
- [Banner, squarePNG · 1500×1500](https://www.sentry.trading/brand/sentry-banner-1500x1500.png)
- [team@sentry.trading](mailto:team@sentry.trading)
- [@cruelhandeth](https://x.com/cruelhandeth)
- [LinkedIn](https://www.linkedin.com/in/sergioalessandroluna/)
- [sergio@sentry.trading](mailto:sergio@sentry.trading)
- [Ink Chain](https://inkonchain.com/)
- [Robinhood Chain Docs](https://docs.robinhood.com/chain/)
- [@SentryBuyBot](https://t.me/SentryBuyBot)
- [Sentry Telegram](https://t.me/sentrylauncher)
- [Guide](https://www.sentry.trading/desktop/guide)
