# Sentry - sentry-guide.md, the machine-readable guide

> Source: https://www.sentry.trading/sentry-guide.md
> Retrieved: 2026-09-02 (curl)
> Raw capture: `_raw/sentry-guide.md`

---

Sentry publishes its whole guide as one markdown file, dated `Last updated: August 27, 2026`, explicitly written to be handed to an AI assistant.
It is the same material as the rendered guide pages above, minus the Ecosystem Stats, Brand Kit, Team, V2 Roadmap and Troubleshooting sections, and plus a fuller Ink xStocks integrator reference.
Every economic number in this archive's README was checked against the chain rather than taken from this file; where the two disagree the README says so.

# Sentry — Complete User Guide

> Canonical source: https://sentry.trading/guide · This file: https://sentry.trading/sentry-guide.md
> Last updated: August 27, 2026
>
> This document is the full, machine-readable version of the Sentry user guide. It is written
> to be handed to an AI assistant as context. Everything here describes the live product at
> sentry.trading and is verified against the deployed contracts and application code.

---

## 1. What Sentry is

Sentry is a non-custodial trading app for **Robinhood Chain** (chain id 4663) and **Ink**
(Kraken's Layer 2, chain id 57073). From one account you can:

- Swap any token, with quotes aggregated across multiple DEX venues for the best price.
- Launch your own token with locked liquidity and earn the majority of its trading fees.
- Bridge ETH between Ethereum mainnet, Ink, and Robinhood Chain in seconds via Relay.
- Spend ETH out to Avici, Robinhood, Venmo, PayPal, or Cash App as USDC, BTC, SOL, PYUSD,
  AVAX, ETH, or BNB, delivered to a deposit address you saved.
- Register `.ink` and `.hood` domain names and bid on premier names in auctions.
- Lock team or treasury tokens in a trustless timelock.
- Set an NFT you own as your profile picture, star tokens to a watchlist, and get push
  notifications on big moves.

A chain selector in the header switches the whole app between chains. Your EVM address is the
same on both chains (and on Ethereum mainnet).

Sentry is software, not a financial service. It does not custody funds in a fiduciary
capacity, broker trades, issue tokens, or give investment advice. Generated wallet keys are
stored encrypted (AES-256-GCM) and used only to sign transactions you initiate; you can
export any private key at any time and leave.

---

## 2. Accounts and sign-in

### Creating an account
- Sign up with a **username and password**. Username: 3 to 32 characters, letters, numbers,
  and underscores only. Password: 8 characters minimum.
- Passwords are hashed with bcrypt (cost 10) server-side. The plaintext is never stored.
- The moment the account exists, Sentry generates an EVM wallet for you and binds it to the
  account. No browser extension or seed phrase is needed.
- Sessions last 24 hours; you sign in again after that.

### Sign in with X (Twitter)
- You can create an account or sign in with X via OAuth. X-created accounts start with no
  password; you can set one later from Settings → Change Password.
- Existing accounts can **link** an X account in Settings. Linking lets tweets at
  @sentrylauncher launch tokens from your own wallet, and puts your X handle on your PNL cards.

### Passkeys (biometric login)
- Register a passkey (Face ID, Windows Hello, fingerprint) from Settings. Sign in later with
  the passkey alone, no username needed.
- You can register multiple passkeys (one per device) and remove them individually.

### Two-factor authentication (TOTP)
- Enable 2FA in Settings → Two-Factor Authentication. Scan the QR with any authenticator app
  (Google Authenticator, 1Password, Authy). Codes are 6 digits, 30-second window.
- On enable you get **10 single-use backup codes** (format `XXXX-XXXX`). Store them safely;
  they are shown once. Regenerating backup codes requires a fresh TOTP code.
- 2FA gates **password logins only**. Passkey and Sign-in-with-X logins skip the code step:
  a passkey is already two factors by construction, and the X path proves control of the
  linked X account.
- Disabling 2FA requires your password plus a code, and signs out all other devices.

### Changing your password
- Settings → Change Password. Requires your current password (X-only accounts set their
  first password without one). On success all **other** sessions are revoked; your current
  device stays signed in.

### Password recovery (verified email required)
- Sentry collects no email or phone at signup, so a fresh account has no reset path. But you
  can **verify an email** afterward in Settings → Account → Verification Status (6-digit
  code, 15-minute expiry). A verified email makes the account recoverable: contact the team
  through an official channel and prove control of that email — plus your TOTP code if 2FA
  is enabled — and your password can be reset.
- No verified email, no recovery, by design. Either way, treat your password like a seed
  phrase and export your private keys early — the keys, not the password, are your funds.

### Connect a wallet (MetaMask, Rabby, WalletConnect)
- Settings → Security → **Connect a wallet** links an external self-custody wallet to your
  account with a one-time Sign-In-With-Ethereum signature (no transaction, no gas). Any
  installed extension is auto-discovered; mobile wallets connect over WalletConnect.
- You can also **sign in to Sentry with just a wallet** — the login screen's wallet option
  creates (or resumes) a full wallet-native account, no password required.
- External wallets appear in your wallet list with balances and holdings tracked like any
  other wallet, but Sentry never holds their keys: every transaction is signed in your own
  wallet app. Features where Sentry signs in the background for you (limit/DCA order fills,
  the Telegram trading bot) stay on your Sentry custodial wallets.
- Unlink any time from the same Settings row.

### Telegram link (optional)
- Verification Status also offers an optional Telegram link. It doesn't affect the
  checkmark; it connects your account to the Telegram trading bot and shows on your
  profile.

### Changing your username
- Settings → Change Username. A rename costs **$10, charged in ETH** at the live rate from
  your primary in-app wallet (you pick Ink or Robinhood Chain for the payment; both settle
  in native ETH).
- The new name must be available and pass the same rules as signup. Your old name is
  **released immediately** and anyone can claim it. Wallets, sessions, 2FA, and passkeys are
  untouched; tokens you deployed re-point their creator attribution to the new name.

---

## 3. Profile pictures (including NFT PFPs)

- **Upload an image**: any PNG/JPG/WebP/GIF up to 256 KB (the app resizes for you). Uploaded
  avatars render as a circle.
- **Set an NFT as your PFP**: open the Wallet page → NFTs tab, tap an NFT you own, and choose
  **Set as PFP**. Sentry verifies ownership on-chain at set time; no transaction is required
  and nothing is spent. NFT PFPs render as a **hexagon** to signal verified ownership.
  `.hood` and `.ink` domain NFTs are ERC-721s and qualify.
- Tap the same NFT again and choose **Remove PFP** to clear it. An NFT PFP takes priority
  over an uploaded image while set.
- With no avatar set, you get a deterministic color gradient generated from your name.
- Your avatar shows up across the app, including on your PNL cards and your on-chart trade
  markers.

---

## 4. Wallets

### Generated wallets
- One EVM wallet is generated at signup. The key is created server-side, encrypted with
  AES-256-GCM, and stored encrypted at rest. It is decrypted in memory only to sign
  transactions you initiate.
- Generated wallets are full-featured: fund, swap, send, deploy, lock, register domains,
  and export the key whenever you want. They cannot be deleted (they live with the account).

### Imported wallets
- Import up to **4 additional EVM wallets** (paste a `0x`-prefixed 64-hex-char private key).
  The derived address is shown before you confirm. A newly imported wallet automatically
  becomes your **primary** wallet.
- Imported, non-primary wallets can be deleted. Deleting removes Sentry's copy of the key;
  funds stay on-chain and are still yours via the original key.

### Primary wallet
- The primary wallet is what swaps, sends, and deploys default to. Change it in
  Settings → Set Primary Wallet.

### Exporting private keys
- Settings → Export EVM Key. Requires your account password. The key is revealed once in a
  one-shot panel (`0x`-prefixed hex, importable into MetaMask, Rabby, Rainbow, etc.).
- Anyone with the key controls the wallet. Never paste it into chats or websites.

### Holdings quality-of-life
- **Custom tokens**: track any ERC-20 in your Holdings by pasting its contract address
  (up to 20 per chain, stored on your device). Tokens you swap into are auto-tracked.
- **Dust filter**: holdings worth under $0.01 are hidden by default, with a toggle showing
  how many are hidden.

---

## 5. Trading and the swap aggregator

### How routing works
Sentry's swap engine is an aggregator. When you request a quote it fans out across every
live venue on the active chain **in parallel** and executes on the single venue that returns
the most output tokens:

**On Robinhood Chain (4663), four venues are quoted:**
1. **Uniswap V3** (canonical): all four fee tiers (0.01%, 0.05%, 0.3%, 1%).
2. **Uniswap V2**: the WETH pair, using live reserves.
3. **Uniswap v4**: Doppler hook pools, which is where Bankr-launched tokens trade.
4. **PancakeSwap V3**: its own fee tiers (0.01%, 0.05%, 0.25%, 1%).

**On Ink (57073):** swaps route through **Uniswap V3** (the governance-recognized
deployment on Ink), fanning across every live fee tier (0.01% to 5%). Every Sentry-launched
Ink pool was migrated there in August 2026 — liquidity stayed locked throughout and moved
at the same price, so holders and creators were unaffected apart from a new pool address.
These pools are also routable through Relay, so the tokens can be bought with ETH from any
Relay-supported chain.

Because the winning quote is a real quoter simulation against live pool state, price impact
is already reflected in the number you see. The picked venue is shown with the quote.

### Fees on swaps
- **A 1% platform fee applies to in-app swaps on both chains.** It is taken on the input
  side and every quote you see is **already net of the fee**. There are no other Sentry
  charges on top; you pay the DEX pool fee (baked into the quote) and network gas.

### Slippage and minimum received
- Slippage tolerance: 0.5%, 1% (default), or 3%, adjustable on the swap form.
- "Minimum received" = quoted output minus your slippage tolerance. If the pool cannot
  deliver at least that amount at execution, the transaction reverts and nothing is traded.

### Buys, sells, approvals
- Quick-buy presets on the buy side: 0.05 / 0.1 / 0.5 / 1 ETH chips.
- The MAX button reserves a small amount of ETH for gas (0.0005 ETH) so you cannot strand
  yourself gas-less.
- The first sell of a token requires a one-time on-chain approval; the app handles it
  automatically ("Approving token…" then the swap).
- Sells to ETH always unwrap WETH, so you receive native ETH.
- You can price your input in **USD or token units**; flip the mode in Settings → Swap input.
- Some Ink tokens are paired against **USDT0** instead of WETH; the swap form settles those
  in USDT0 automatically.

### Trading any token
- Paste any contract address into the token picker and Sentry resolves it on-chain, even if
  it was never launched through Sentry.
- **Bankr tokens** (a separate launchpad on Robinhood Chain that uses Uniswap v4 Doppler
  pools) are listed and fully tradeable inside Sentry. They are not launchable through
  Sentry; they are displayed and routed like any other token, with the same 1% fee.

### Limit and DCA orders
The swap page has **Market / Limit / DCA** tabs above the form. Limit and DCA orders are
described client-side and filled server-side through the same best-venue aggregator routing
as a market swap (same 1% platform fee, no extra order fee).

- **Limit orders**: set a trigger price in USD and a direction. Four patterns: limit buy
  (fills when price ≤ trigger), breakout buy (fills when price ≥ trigger), take profit
  (sell ≥ trigger), stop loss (sell ≤ trigger).
- **Honest triggers**: the engine re-quotes every open order at its actual size against live
  pool state every few seconds, fees included. An order triggers only when your size could
  genuinely fill at that price — a ticker price on a thin pool can't fake a fill.
- The panel projects what you'd receive at the trigger. Orders can optionally expire; open
  orders can be cancelled any time; push notifications fire when an order fills, fails, or
  expires.
- **DCA orders**: amount per fill, interval (5m / 15m / 30m / 1h / 4h / 12h / 1d), and
  number of fills. The first fill executes immediately, the rest run on schedule, and the
  order card tracks progress (e.g. 3/10 fills done).

### Guest swaps (no account needed) at /swap
- https://sentry.trading/swap is a standalone swap page that works **without an account**,
  using your own browser wallet (MetaMask, Rabby, any injected wallet). Connect, pick chain
  and token, swap. Gas comes from your connected wallet, and the same 1% platform fee
  applies.
- The URL is deep-linkable and updates live as you pick tokens:
  `https://sentry.trading/swap?chain=robinhood&token=0x...`. Share it to send someone
  straight into a preloaded swap.

---

## 6. Charts, token pages, and PNL cards

### Token detail pages
- Open any token from the Tokens list. You get price/mcap chart, multi-timeframe percentage
  chips, 24h buy/sell pressure (Robinhood), price, FDV, 24h volume, liquidity, pool TVL,
  total supply, holder count, top-10 holders with role tags (Creator / Pool / Locked), pool
  age, social links, and a live trades feed.
- **Share button**: copies a canonical deep link
  (`https://sentry.trading/tokens?chain=<chain>&token=0x...`) that opens the token page on
  any device.

### Charts
- **Robinhood Chain** tokens get Sentry's custom candlestick chart: timeframes 1m, 5m, 15m,
  30m, 1h, 4h, 12h, 1d; price or market-cap axis; OHLC crosshair legend; and a live edge
  that folds in swaps from Sentry's own subgraph within seconds.
- If you have traded the token, your own buys and sells are drawn on the candles as arrow
  markers with your avatar, plus a dashed average-entry line.
- **Ink** tokens currently use an embedded DexScreener chart.

### PNL cards
- On the custom chart (Robinhood), two share exports appear once you have trades on the
  token:
  - **Share**: a chart screenshot with a PNL banner composited on top.
  - **PNL**: a standalone 1600x836 PNL card with your profit/loss in USD and percent, buy
    and sell counts (a diamond marks never-sold), average entry expressed as market cap,
    your Sentry handle and avatar, and your linked X handle.
- Both flows let you copy the image, download it, or post it to X in one tap.

---

## 7. Favorites (watchlist) and alerts

- Tap the **star** on any token detail page to watch it. Up to **5 tokens** per account.
- Watched tokens trigger **targeted push notifications** when they move **10% or more in an
  hour** (up or down). Movement is re-checked every 10 minutes and there is deliberately no
  cooldown: a token that keeps running keeps alerting. Your device shows only the latest
  alert per token.
- Tapping an alert opens the swap page with that token preloaded.

---

## 8. Push notifications

- Enable in Settings → Notifications (one toggle per device), or from the one-time prompt.
  On iOS, install the PWA to your Home Screen first (iOS 16.4+); Safari tabs cannot receive
  push.
- What you receive with notifications ON:
  1. **Boost alerts**: whenever anyone boosts a token, all subscribers get one push
     ("⚡TOKEN just got boosted on Sentry").
  2. **Big moves on boosted tokens**: while a token has an active boost, moves of 10%+ in an
     hour are pushed to all subscribers.
  3. **Watchlist moves**: 10%+ hourly moves on tokens you starred, sent only to you.
- Turning the toggle off unsubscribes the device immediately. There are no per-category
  toggles; the only per-token control is the watchlist star.

---

## 9. Boosts and Featured slots

Both are bought inside the app (tap **Featured** on the tokens page runner bar, or the boost
modal from a token). Prices are set in USD and charged in ETH at the live rate from your
in-app wallet. Purchases are final. Anyone can boost or feature any token; you do not need
to be its creator.

### Boosts (the ⚡ multiplier)
| Pack | Price | Duration |
|------|-------|----------|
| 50x  | $25   | 12 hours |
| 100x | $50   | 12 hours |
| 500x | $125  | 12 hours |

- A boosted token jumps to the **front of the Trending marquee** with a golden highlight, a
  lightning bolt, and its multiplier shown (e.g. ⚡150x).
- Boosts are **stackable with no cap**: anyone can add packs at any time and the displayed
  multiplier is the sum of all active packs. Each pack runs 12 hours from its own purchase,
  so the number climbs as people stack and decays as packs expire.
- Boosts go live instantly (no queue) and there is no limit on how many tokens are boosted.
- **Every boost purchase fires a push notification to every subscribed user**, and while
  boosted, the token's 10%+ hourly moves are also pushed to everyone. Boosting is placement
  plus a notification blast.

### Featured slots (the ⭐ pinned spots)
| Duration | Price |
|----------|-------|
| 6 hours  | $25   |
| 12 hours | $50   |
| 24 hours | $125  |

- **3 slots**, pinned at the left of the volume runner bar on the Tokens page. Featured
  tokens display as logo plus gold symbol only (deliberately no price delta, so a paid
  placement never advertises its own dip).
- One live slot per token. If all 3 slots are taken, your purchase **queues** and activates
  automatically when a slot frees up; the modal shows the live board and your start time
  before you pay.
- Unsold slots may show house picks; paid slots always displace house fill.
- Featuring is placement only. It does not send push notifications (boosts do).

---

## 9b. Referral program

- Self-serve, no application: Settings → **Referral Program**. Pick a vanity code (3-12
  letters/numbers, live availability check) or take a random one. One code per account,
  permanent.
- **The referral share is 100 bps — the entire 1% platform fee** on every swap your
  referrals make. Sentry keeps nothing on referred volume. The swap routers pay the share
  on-chain, per swap, straight to the referrer's Sentry-generated wallet.
- Who counts as your referral: anyone who signs up through your invite link, enters your
  code in Settings, or trades through a buy link you shared (once you have a code, it rides
  along on every buy link you share automatically as `?ref=`).
- Live stats on your card: referral count, their total volume, and fees earned.
- Entering a code: once, immutable, self-referral rejected. The referred user's swap costs
  never change — the share comes out of Sentry's fee, not on top of it.

---

## 10. Launching a token

### The Create flow
1. Open **Create** (center of the bottom nav on mobile, top nav on desktop).
2. Fill in: coin name (up to 32 chars), symbol (up to 10 chars), and a logo image
   (required). Optional: website, X, and Telegram links, and whether to show your username
   as the creator.
3. Optional **dev buy**: commit ETH (entered in USD or ETH) that buys your token immediately
   after the pool opens, at the same market price anyone else would get. If you skip it, the
   app automatically executes a tiny seed buy (0.00001 ETH from your wallet) right after the
   deploy so the token registers its first trade; chart sites only start tracking a token
   after its first swap.
4. On Robinhood Chain you can optionally set a separate **creator fee recipient** address at
   launch (useful for routing fees to a team multisig; you remain the recorded creator).
5. On Ink, an additional **Kraken Verified** launch type exists for wallets linked to a
   KYC'd Kraken account.
6. Hit Deploy. Your in-app wallet signs and pays gas (fractions of a cent on both chains).
   Launching is free apart from gas; Sentry's revenue comes from its share of the locked
   LP's trading fees.

### What happens on-chain (the launch mechanics)
Every Sentry launch is the same immutable sequence, verifiable on the explorer:
1. **ERC-20 deploys** with a fixed supply of **1,000,000,000 tokens** (18 decimals),
   no mint function, no pause, no blacklist, no proxy.
2. **Ownership is renounced** in the same transaction (owner = dead address). No one,
   including Sentry, retains any privileged access.
3. **100% of supply goes into a liquidity pool** as a single-sided position. New launches
   on both chains use a Uniswap v4 dynamic-fee pool — paired against WETH on either chain,
   or against a tokenized stock on Robinhood Chain.
4. **The position is locked permanently**: it is held by the SentryLPVault, an immutable
   contract with no withdrawal function and no upgrade path. No timer, no unlock, ever.
5. **Trading opens to everyone in the same transaction.** No presale, no team allocation,
   no pre-loaded wallets, no privileged buying window — nobody, creator included, can buy
   before the pool is public. The creator's dev buy (or the automatic 0.00001 ETH seed buy
   from the creator's wallet if none was requested) runs as a separate swap right after the
   deploy, at the same market price any other buyer would get. The optional launch
   whitelist (below) changes the *fee* a listed wallet pays during the anti-snipe window,
   never its access or its price.

### Anti-snipe protection (the decay fee)

Robinhood Chain has aggressive launch-sniping bots. Sentry's answer is structural, built
into the pool itself, not a patch: every v4 launch pool opens at a **40% trade fee** that
holds for 3 minutes, then halves every 3 minutes (smoothly interpolated) down to a
permanent **1.7% floor** reached about 17 minutes in:

| Time since launch | Trade fee |
|---|---|
| 0-3 min | **40%** |
| 6 min | 20% |
| 9 min | 10% |
| 12 min | 5% |
| 15 min | 2.5% |
| ~17 min onward | **1.7% permanent floor** |

- **Sniping is unprofitable by construction**: a block-zero 1 ETH buy pays 0.4 ETH in fees
  in, and the curve is still elevated on the flip, so the round trip only clears if the
  token does a large multiple in minutes.
- **Snipers pay the creator.** The fee is settled inside the sniper's own transaction. On a
  reflection or stock-paired launch, a 40% opening-window fee splits 20% of the trade to
  the creator's wallet, 10% into permanently locked liquidity, 10% to the treasury. On a
  plain WETH launch the creator's cut is ~23.5% of every sniped trade. The harder a launch
  is sniped, the more its creator earns and the deeper its locked liquidity gets.
- **Why time-based**: swap-count decay is gameable with dust swaps; price-based decay
  trusts a price snipers can push. The clock can't be manipulated.
- **Why ~17 minutes, not seconds**: a huge fee that collapses in seconds stops one block of
  bots — snipers wait it out. Seventeen minutes outlasts the entire frenzy window.

### The launch whitelist

The creator can whitelist wallets at launch (the launching wallet is always included
automatically). During the decay window, whitelisted wallets pay the **1.7% floor instead
of the curve rate — on buys only**. Of a 1 ETH whitelisted buy, roughly 0.98 ETH becomes
real pool depth versus 0.6 ETH unwhitelisted, so teams can actually acquire supply at
launch without feeding their capital to the fee curve.

- **Not early access**: whitelisted wallets buy from the same public pool at the same
  market price as everyone else; they only skip the anti-snipe premium.
- **Never free**: the 1.7% floor (including its reflection and liquidity legs) always
  applies.
- **Sells are never exempt**: the exemption checks trade direction.
- **Frozen at launch**: the list is written to the fee hook before the pool initializes and
  is immutable afterward — nobody, Sentry included, can add a wallet later, and anyone can
  verify the list on-chain.
- **Survives routers**: matching is on transaction origin, so it applies through the app,
  the public swap page, or any router.
- Dev buys and bundle-buy wallets (up to 50, for accounts with Bundle Buy enabled) are
  whitelisted the same way.

---

## 10b. Tokenized stocks as base pairs (Robinhood Chain)

A stock-paired launch pairs your token against one of the tokenized stocks on Robinhood
Chain (AAPL, NVDA, TSLA, META, NFLX, SPY, QQQ, and more — the list is limited to roughly
twenty megacaps and ETFs with real, liquid on-chain markets) instead of ETH. The stock is
the pool's base asset: what your token is priced in and traded against. Everything else is
a normal Sentry launch: 1B fixed supply, renounced contract, 100% of supply locked as
single-sided liquidity forever. You don't need to own any of the stock to launch — the
stock side fills as buyers trade in.

### Fees (all denominated in the base stock)

Every trade pays the launch fee curve (40% → 1.7% floor, see the anti-snipe section). At
the permanent floor, each trade splits:

| Leg | Share of fee | At the 1.7% floor | Goes to |
|---|---|---|---|
| Holder reflections | ~47% | 0.8% of the trade | All holders pro-rata, in the stock, claimable any time |
| Creator | ~29% | 0.5% of the trade | Creator's fee wallet, paid within the swap itself |
| Liquidity reinvest | ~12% | 0.2% of the trade | Permanently locked full-range liquidity |
| Treasury | ~12% | 0.2% of the trade | Sentry treasury splitter |

Every leg comes out of the curve fee, never on top. Reflections switch on 10 minutes after
launch; during the opening window a 40% fee splits 20% creator / 10% treasury / 10% locked
liquidity (the only buyers then are snipers and whitelisted launch wallets).

### Reflections mechanics

- The token has **zero transfer tax** — reflections use dividend accounting on balance
  changes, so the token stays fully compatible with every DEX, router, and aggregator.
- Reflections accrue continuously, pro-rata to holdings, survive transfers, never expire,
  and are claimed directly from the token contract (in-app Reflections card, or a
  connected wallet on /swap). The pool, factory, vault, and burn addresses never earn.
- WETH launches can opt into the same model with `launchWithReflections` — holders earn
  WETH instead of a stock.

### Trading with ETH

You never need to hold the base stock. Buys route ETH → USDG → stock → your token in a
single transaction (sells reverse it, with a toggle to receive the stock instead of ETH).
Both directions work in-app and on the public /swap page, and you can pay with the base
stock directly if you already hold it.

### Ink: wrapped xStocks

On Ink the base asset is a Backed **wrapped** xStock (wNVDAx, wAAPLx, and six others) —
an ERC-4626 wrapper over the raw rebasing xStock. Always pair and trade the wrapper,
never the raw token. The hop is `ETH → WETH → USDT0 → USDG → wrapper → your token`.
The Ink stock-pair floor is **2.00%** (not the 1.7% WETH / Robinhood-stock floor).
Creators on Ink are paid in **WETH** (the router peels 75% of the live curve); holders
earn the wrapper as reflections (the remaining 25%). Direct `PoolManager.swap` on these
pools reverts — the hook is router-gated.

Integrator addresses, ABIs, pool keys, and the quote hop: section 19b and
https://sentry.trading/guide#ink-xstocks.

---

## 11. Creator rewards (earning from your token)

### The split
On every **current (v4) launch — both chains, identical contracts and numbers** — the
pool's own LP fee is zero and the fee hook settles every leg per swap, so nothing accrues
to the position. At the permanent 1.7% floor a WETH launch pays 1.0% of every trade to the
creator (59% of the fee), 0.2% back into the token's own liquidity, and 0.5% to the
protocol. Launches with reflections enabled, and stock-paired launches, pay 0.8% to
holders, 0.5% to the creator, 0.2% into liquidity, and 0.2% to the protocol.

Legacy V3-era launches (from before the v4 stack) work the older way: the locked position
accrues the pool's trading fees on both sides of the pair, and collecting splits them:

| Chain | Creator | Treasury |
|-------|---------|----------|
| Robinhood Chain, legacy V3 | **70%** | 30% |
| Ink, legacy V3 | **65%** | 35% |

(Robinhood was raised from 65% to 70% on July 8, 2026. These are live on-chain values,
readable as `creatorFeeBps` on each legacy factory, and they govern the legacy V3 positions
held in the LP vault.)

### Collecting your fees
- **Current (v4) launches: nothing to collect.** The fee hook pays your share inside each
  swap transaction, directly to your fee recipient wallet. If your token traded five
  seconds ago, you were paid five seconds ago. The My Tokens card tracks running totals.
- **Legacy V3 launches on Robinhood Chain**: open Wallet → **My Tokens**. Each token shows
  its accrued, uncollected fees (tap View/Refresh for live numbers) and a
  **Collect Fees** button. Collection pulls the accrued fees out of the locked position and
  pays your share straight to your fee recipient wallet in the same transaction.
- Sentry also runs **scheduled automatic sweeps** that collect any legacy position with
  meaningful accrued fees, so creator payouts flow even if you never press the button.
  Either way the on-chain split is identical.

### Fee recipient management (Robinhood)
- At launch you can direct fees to any address (`creator fee recipient`).
- After launch, the current recipient can **transfer fee rights exactly once** via the
  "Transfer Fees" action on the My Tokens card. This is a one-time, irreversible handoff
  (e.g. to a community wallet after a CTO). Sentry can also reassign recipients in verified
  community-takeover cases.

### Volume via Sentry
- Your My Tokens card shows **"Volume via Sentry"**: the 30-day and all-time ETH volume of
  your token that was executed through the Sentry app or sentry.trading swap links. Share
  your token's `/swap?chain=...&token=...` link so your community's swaps count.

---

## 12. The token locker (/lock)

- https://sentry.trading/lock, plus the Locks view in the wallet, interfaces with the
  **Sentry Token Locker** on Robinhood Chain: a trustless timelock with **no owner, no admin
  functions, no fees, and no early-withdrawal path**. The contract records exactly what it
  receives and releases it to the beneficiary only after the unlock time.
- Lock any ERC-20: pick token and amount, choose a preset duration (1 week, 1 month,
  3 months, 6 months, 1 year) or a custom date, and optionally name a different beneficiary.
- Locks can be **extended** (forward only, never shortened) and the beneficiary can be
  transferred to a new address.
- Note: launch LP is already locked by the factory automatically. The locker is for team,
  treasury, or vesting tokens.

---

## 12b. The SENTRY token

SENTRY is the platform's own token, trading against WETH in a Uniswap v4 pool on Robinhood
Chain — built as a flywheel: every launch and every trade on the platform feeds SENTRY, and
SENTRY pays its holders in WETH.

- **Contract**: `0x1EcA20cfa4AF2e2fA2F4CE2bF8d97bFa184FD4D7` (fixed 1B supply, renounced,
  verified). Fee hook: `0xA695f84C86367d5aEA445e8289DBC7C4C4E530cc`.
- **Distribution**: 10% treasury, 3% founder (publicly disclosed), 87% launched into the
  public WETH pool. Original SENTRY holders were migrated via airdrop at the July 28, 2026
  relaunch.
- **Liquidity**: permanently locked, same custody model as every Sentry launch.

### Hold SENTRY, earn WETH

The pool fee decayed from 40% at relaunch to a permanent **2% floor**. Every trade splits
the fee, settled inside the swap itself:

| Leg | Share of fee | At the 2% floor | Goes to |
|---|---|---|---|
| Holder reflections | 37.5% | 0.75% of the trade | **WETH to all holders pro-rata** — claimable any time, no snapshots, no deadlines |
| Liquidity compound | 37.5% | 0.75% of the trade | Permanently locked SENTRY/WETH liquidity |
| Treasury | 25% | 0.5% of the trade | The Sentry treasury |

Reflections use the same zero-transfer-tax dividend-accounting standard as stock-paired
launches — fully DEX-compatible, accrual proportional to holdings at each trade. Claimable
WETH shows on the SENTRY token page in the app.

### The flywheel

The protocol's share of every launch's trading fees — every WETH launch, every stock
launch, every sniped block-zero buy — routes to the on-chain **Treasury Splitter**
(`0x75450496fe333A93e1327368aa3c4130BF008697`), which cuts it 60/40:

- **60%** funds platform operations.
- **40% market-buys SENTRY and mints permanently locked SENTRY liquidity** (WETH proceeds
  compound into SENTRY/WETH; stock proceeds route via USDG and WETH into SENTRY/stock).
  The splitter has no removal function.

Platform volume → protocol fees → permanent SENTRY buy pressure + ever-deeper locked
liquidity → SENTRY's own volume pays holders WETH on every swap. Structural, on-chain,
verifiable.

---

## 13. Domains: .ink and .hood

### Registering
- Ecosystem tab → Domains → **Register a name** (also Settings → Register ZNS). The modal
  registers `.hood` names when you are on Robinhood Chain and `.ink` names on Ink.
- Pick a name (just the label, no suffix) and a duration: **1 to 5 years** for `.hood`,
  **1, 2, 3, 5, or 10 years** for `.ink`.
- Price scales with name length (shorter = more expensive) and is charged **per year**. The
  modal quotes the exact ETH total live from the registry before you confirm; the quote is
  the final number.
- Registration is an on-chain transaction signed by your in-app wallet; the domain NFT lands
  in that wallet.

### What a domain does
- Your address displays as `yourname.hood` / `yourname.ink` across Sentry: wallet header,
  wallet switcher, send confirmations, holder lists.
- Typing a domain into the Send flow resolves it to the owner's address.
- The domain is an ERC-721 in your wallet's NFTs tab, and you can set it as your PFP.

### Premier name auctions (.hood)
- Sentry holds a set of one-of-one premier `.hood` names (satoshi, btc, eth, gm, stonks,
  trump, musk, degen, 777, and more) and auctions them in the Ecosystem tab.
- Every auction opens at **0.25 ETH**. The clock only starts when someone bids: the first
  bid triggers a **7-day countdown**. Each new bid must beat the leader by **at least 5%**.
  Bids in the final 10 minutes extend the deadline by 10 minutes (anti-snipe).
- Bids are escrowed on-chain from your in-app wallet; when you are outbid you are refunded
  automatically and in full. When the countdown ends the name NFT transfers to the winner
  automatically.

---

## 14. The Ecosystem tab

The fifth tab in the bottom nav (Sparkles icon). Contents depend on the active chain:
- **Daily GM** (Ink): an on-chain GM streak. One free GM per 24 hours.
- **GM+** (Ink): a premium GM at 0.0005 ETH per call, same 24-hour cadence.
- **Lending** (Ink): supply assets to Tydro (an Aave v3 deployment on Ink) straight from
  the app.
- **Domains** (both chains): registration and the premier auctions (see section 13).

---

## 15. Bridging

- The Bridge tile moves **ETH** between **Ethereum mainnet, Ink, and Robinhood Chain**. All
  six directions are supported. Same wallet address on every chain, so there is no recipient
  entry: you always bridge to yourself.
- Routing is via **Relay Protocol**. Most bridges finalize in **seconds**. The sheet quotes
  the estimated output (fees and gas included in the rate shown), then shows live status:
  depositing → pending → success, with a link to the full receipt on relay.link.
- A small gas reserve is always kept on the source chain so you cannot bridge yourself out
  of gas.
- Typical funding path: send ETH to your Sentry address on mainnet from any exchange, then
  bridge to Robinhood Chain or Ink in the app.

---

## 16. Spend (off-ramp to Avici, Robinhood, Venmo, PayPal, and Cash App)

The Spend tile on the wallet page converts native ETH from any chain Sentry custodies
(Ethereum mainnet, Ink, Robinhood Chain) into whatever a consumer app credits, and delivers
it straight to a deposit address you saved there. One signed transaction, no manual bridging
and no intermediate swap.

### Supported destinations

| App | You receive | Addresses you save |
|-----|-------------|--------------------|
| Avici | USDC on Base or Solana | Your EVM and/or Solana deposit address |
| Robinhood | AVAX, ETH, BNB, SOL, BTC | One EVM address (covers AVAX, ETH, BNB), plus Solana and Bitcoin |
| Venmo | BTC, SOL, PYUSD (Arbitrum) | One per coin and network |
| PayPal | BTC, SOL, PYUSD (Arbitrum) | One per coin and network |
| Cash App | BTC | Your Bitcoin deposit address |

### How to use it

1. Tap **Spend** on the wallet page and pick the app. Each app has its own screen and its own
   saved addresses.
2. Add a destination: copy the deposit address from the other app (Avici: Add Money ·
   Robinhood, Venmo, PayPal: Crypto → Transfer → Receive · Cash App: Bitcoin → Deposit
   Bitcoin), paste it, and label it. Robinhood and Cash App take **one address per network**
   and expand it into every asset that network receives; Venmo and PayPal take **one address
   per coin**, so you pick the coin first.
3. Choose the source chain, type an amount in dollars, and the sheet quotes what will
   actually arrive.
4. Hit Spend. Sentry signs one transaction on the source chain and tracks delivery live:
   depositing → pending → success. The destination app credits the deposit on its own side.

### What the backend does

- None of these apps support Ink or Robinhood Chain, and funds sent to them on an unsupported
  network are unrecoverable. Spend therefore never does a plain cross-chain transfer: it
  routes through **Relay Protocol** as a single intent. You sign one deposit on the source
  chain; Relay's solver network delivers the destination asset, including the Solana and
  Bitcoin legs, which require nothing further from you.
- The one exception is a same-chain, same-asset send (mainnet ETH to a mainnet ETH
  destination). That is a plain transfer, so Sentry sends it directly rather than minting a
  Relay intent that would never report a fill.
- **Destinations are per wallet.** Every EVM sub-wallet under your account keeps its own
  address book per app. Switching wallets switches the whole list, and a spend from one
  wallet cannot route to another wallet's saved address.
- **Saved addresses only.** Spend is the only place in Sentry where funds leave your own
  keyspace, so the execute endpoint refuses a raw address in the request: it delivers only to
  an entry you explicitly saved. That caps the blast radius of a compromised session at the
  destinations you chose.
- **Addresses are validated hard**, because a typo is unrecoverable: Bitcoin by full checksum
  (bech32, bech32m, and base58check, mainnet only), Solana as a real ed25519 public key, EVM
  by EIP-55 checksum normalization.
- **Addresses are masked in the UI** by default and revealed with the eye toggle, so
  screenshots and screen recordings do not expose where you off-ramp.

### Cost

- Sentry charges **0.25% (25 bps)** on Spend. Relay bills it in the source-chain ETH and it is
  already reflected in the quoted output. Bridging between your own wallets remains free.
- Relay's routing cost is inside the same quote.
- Most of the real cost is **fixed per fill**, not proportional: roughly $0.05 on
  PYUSD-Arbitrum, $0.17 on Solana, $0.55 on Bitcoin, regardless of size. A $2 test therefore
  shows a large percentage; at real size it disappears.
- Bitcoin waits on a network confirmation, so it settles in minutes where the others take
  seconds.

### Care

Deposit addresses are **not interchangeable between apps**, even when the asset matches: a
PayPal Bitcoin address and a Venmo Bitcoin address are both valid Bitcoin addresses pointing
at different accounts. Nothing can detect a mix-up. Label each entry clearly and send a small
amount first when adding one.

---

## 17. Navigating the app

### Mobile (PWA)
- **Bottom nav**: Wallet · Swap · Create · Tokens · Ecosystem. Create opens the launch sheet
  from anywhere.
- **Header**: your avatar and username on the left (tap for the account/wallet switcher), a
  rotating price ticker in the center, and Activity (clock icon), Settings (gear), and
  Search on the right.
- **Wallet page**: portfolio total, action tiles (Send / Swap / Receive / Bridge), Holdings
  with the dust filter, plus tabs for NFTs, My Tokens (creator dashboard), and Locks.

### Desktop
- **Top nav**: Tokens, Create, Guide, plus the chain selector.
- **Right rail**: always-visible wallet with the same actions; tapping a token row's Swap
  flips the rail into swap mode. The rail toolbar has screenshot, Settings, and Logout.
- **Tokens page views**: All (merged grid of Sentry + Bankr launches with launchpad badges),
  Sentry (advanced terminal table with multi-timeframe stats), Bankr (Robinhood only).

### Tokens page furniture
- **Featured hero cards** at the top (auto-curated by market cap) plus the paid featured
  slots and Trending marquee on the **volume runner bar** (see section 9).

---

## 18. Fees summary (everything Sentry charges)

| Action | Fee |
|--------|-----|
| Swaps (in-app and guest, both chains) | 1% of input, quotes shown net; if a referral code is attached, the full 1% goes to the referrer instead of Sentry |
| Limit / DCA orders | No extra fee — fills are normal swaps with the same 1% |
| Token launch | Free (gas only); Sentry earns 30% (Robinhood) / 35% (Ink) of the locked LP's trading fees |
| Creator fee share | Current v4 launches: paid per swap (1.0% of every trade at the floor on WETH launches). Legacy V3: 70% (Robinhood) / 65% (Ink) of collected LP fees |
| Bridging | No Sentry fee (Relay's routing cost is inside the quoted rate) |
| Spend (Avici, Robinhood, Venmo, PayPal, Cash App) | 0.25% (25 bps) of input, charged in source-chain ETH and already inside the quoted output |
| Sending / receiving | No Sentry fee (network gas only) |
| Token locker | No fees |
| Key export, import, account | Free |
| Domain registration | ZNS registry price (quoted live); no Sentry markup |
| Boosts | $25 / $50 / $125 (50x / 100x / 500x, 12h, stackable) |
| Featured slots | $25 / $50 / $125 (6h / 12h / 24h) |
| Username change | $10 |

Boosts, featured slots, and username changes are charged in ETH at the live USD rate.

---

## 19. Chains and contracts

### Robinhood Chain (chain id 4663)
- Launch Factory (WETH pairs): `0x472286b7d5c1B2A3cE1132eF73d3BcCF446C5cc1`
- Launch Factory (stock pairs): `0xd0A93885a387e3a8a14dd82776CF9104a3676b3A`
- Sentry LP Vault (immutable LP custodian, no withdrawal path): `0x0F0E601041Ec765B8bAB8c166840E291253F2Df0`
- Treasury Splitter (60% treasury / 40% locked SENTRY liquidity): `0x75450496fe333A93e1327368aa3c4130BF008697`
- Fee hook, WETH `launch()`: `0x35c0098836FA0d10A015A95bf02C16387814f0CC`
- Fee hook, WETH `launchWithReflections()`: `0x730AbADbB4f328520e5350F59126fbE1D67F70cc`
- Fee hook, stock pairs: `0x5DaA88b65Bd47199eC92d3cDe01B56348e1270CC`
- Fee hook, stock pairs legacy V2 (superseded; still serves pools launched on it): `0x7e6E258851575bD3F69e7A01981066A26329b0cC`
- Sentry Token Locker: `0xbd0E7a242A323E5e4799Abe09b7516D9dA5ea81D`
- Sentry Swap Router (V2+V3): `0x8bfDC6Cc38DB45BDaf2F254415251b109058a97C`
- Sentry Swap Router (Uniswap v4): `0x5811a5c7c4f73290cc9aa2235245bc9f48523662`
- Sentry Swap Router (stock multihop): `0x641F05602B3dee5B35bAc08A1269827f2E84445D`
- Sentry Swap Router (PancakeSwap V3): `0x4415F2360bfD9B1bF55500Cb28fA41dF95CB2d2b`
- Uniswap v4 PoolManager: `0x8366a39CC670B4001A1121B8F6A443A643e40951`
- Uniswap V3 Factory (canonical): `0x1f7d7550B1b028f7571E69A784071F0205FD2EfA`
- WETH9: `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`
- ZNS (.hood) registry: `0x8f95ed212F37cDc19f5C0716c24966D9019939Ee`
- Legacy Launch Factory (Uniswap V3, retired — 93 LP positions swept into the
  LP Vault, no new launches): `0x9e8f6f8214b01Fd4Cf1d73FB1fb7cf9f811036Cb`
- Explorer: https://robinhoodchain.blockscout.com
- Sentry subgraph (Goldsky, public GraphQL):
  https://api.goldsky.com/api/public/project_cmm7vh5xwsa8m01qmdr7w7u62/subgraphs/sentry-robinhood/1.2.0/gn

### Ink (chain id 57073)
Ink runs the **same v4 launch stack as Robinhood Chain** — same factory implementation,
same WETH fee hooks, same 40% → 1.7% decay curve on WETH pairs, same immutable LP vault
custody. Ink also supports stock-paired launches against Backed wrapped xStocks
(Foundation v3 USDG books → Sentry v4 CAMPAIGN / wXSTOCK pool, 40% → 2.00% floor).

- Launch Factory (v4, WETH and wrapped-xStock pairs): `0xcF44b151aee1Ef69677f24cadED4d2d61b0D45BD`
- Fee hook, WETH `launch()`: `0x976697AdCF27D0962d3B0b6304D5975bA647B0Cc`
- Fee hook, WETH `launchWithReflections()`: `0x68ad7d7e2905656B7d89e56a43a6872F8487B0cC`
- Fee hook, CAMPAIGN / wXSTOCK: `0x18195c33D8150B2e7f5166FC79e29a6C2B1fB0CC`
- SentryStockRouterInk (WETH→USDT0→USDG via Velodrome + 75% WETH peel to initialized Quotron proxies): `0x1b4D919149912c9781b086C8242729EE317631C8`
- SentryInkRouterV4 (WETH pairs only — do not use for wrapped-xStock launches): `0x5275de614E06DbA10546171c1e6d2a30A87844b7`
- Sentry LP Vault (immutable, no withdrawal path): `0x86585D4474C78c1C0fA1f8771682E9aD020787eC`
- Uniswap v4 PoolManager (canonical): `0x360E68faCcca8cA495c1B759Fd9EEe466db9FB32`
- Uniswap v4 StateView: `0x76fd297e2d437cd7f76d50f01afe6160f86e9990`
- Uniswap v4 Quoter (allowlisted on the xStock hook): `0x3972C00f7ed4885e145823eb7C655375d275A1C5`
- WETH9: `0x4200000000000000000000000000000000000006`
- USDT0 (6 decimals): `0x0200C29006150606B650577BBE7B6248F58470c1`
- USDG (Ink, hop asset for ETH → wrapped xStock): `0xe343167631d89B6Ffc58B88d6b7fB0228795491D`
- Velodrome Slipstream SwapRouter: `0x63951637d667f23D5251DEdc0f9123D22d8595be`
- Velodrome Slipstream Quoter: `0x3FA596fAC2D6f7d16E01984897Ac04200Cb9cA05`
- ZNS (.ink) registry: `0xFb2Cd41a8aeC89EFBb19575C6c48d872cE97A0A5`
- Legacy Launch Factory (V3, pre-v4 launches; positions self-custodied permanently,
  65/35 creator/treasury): `0xDc37e11B68052d1539fa23386eE58Ac444bf5BE1`
- Uniswap V3 on Ink (where every legacy Ink LP lives since the August 2026 migration):
  factory `0x640887A9ba3A9C53Ed27D0F7e8246A4F933f3424`,
  position manager `0xC0836E5B058BBE22ae2266e1AC488A1A0fD8DCE8`,
  SwapRouter02 `0x177778F19E89dD1012BdBe603F144088A95C4B53`,
  QuoterV2 `0x96b572D2d880cf2Fa2563651BD23ADE6f5516652`
- Explorer: https://explorer.inkonchain.com
- Sentry Ink subgraph (Goldsky, public GraphQL):
  https://api.goldsky.com/api/public/project_cmm7vh5xwsa8m01qmdr7w7u62/subgraphs/sentry-ink/1.5.0/gn
- Wrapped-xStock integrator reference: section 19b and https://sentry.trading/guide#ink-xstocks

New pools on both chains are Uniswap v4 with a dynamic fee that decays from 40% to a
permanent 1.7% floor (2.00% on Ink wrapped-xStock pairs); legacy V3 pools are the 1% fee
tier. Fee splits are enforced by the contracts and readable on-chain.

---

## 19b. Ink wrapped xStocks — integrator reference

Web: https://sentry.trading/guide#ink-xstocks

For bots, routers, indexers, and other frontends that need to quote, swap, or launch
against Backed wrapped xStocks on Ink (chain id 57073).

**Pair the ERC-4626 wrapper, never the raw rebasing xStock.** Raw tokens (NVDAx, AAPLx, …)
rebase; Sentry pools, Foundation USDG books, and `SentryStockRouterInk` are wired to the
wrappers. Direct `PoolManager.swap` on a CAMPAIGN / wXSTOCK pool reverts — the hook is
router-gated.

### Route

```
ETH
  → peel 75% of the live decay fee as WETH
      60% creator  (0.90% of swap at the 2.00% floor)
      20% Quotron terminal pot (0.30%)
      20% Quotron growth sink  (0.30%)
  → WETH  → USDT0     Velodrome Slipstream, tickSpacing 100
  → USDT0 → USDG      Velodrome Slipstream, tickSpacing 1
  → USDG  → wXSTOCK   Foundation Uniswap V3, fee 500 (0.05%)
  → wXSTOCK → CAMPAIGN  Sentry v4 hook pool (dynamic fee, tickSpacing 200)
```

Sells reverse the hop; the WETH peel comes off the ETH proceeds. Wrapper-direct buys and
sells skip Velodrome: the router still peels 75% of the curve in the wrapper, converts
that slice to WETH for creator / pots, and swaps the rest through the hook pool. The hook
skims the remaining 25% in the wrapper as holder reflections (or treasury during the first
10 minutes).

The 1% Sentry app fee charged on sentry.trading / the PWA API is **not** taken by this
router. Integrators calling the contract directly pay only the on-chain curve plus venue
hop fees.

RPC: `https://rpc-gel.inkonchain.com`. Do not use `SentryInkRouterV4`
(`0x5275de614E06DbA10546171c1e6d2a30A87844b7`) for these pairs.

### Core addresses

| Contract | Address | Notes |
|---|---|---|
| SentryStockRouterInk | `0x1b4D919149912c9781b086C8242729EE317631C8` | Required swap router for every stock-pair trade |
| Uniswap v4 PoolManager | `0x360E68faCcca8cA495c1B759Fd9EEe466db9FB32` | Canonical Ink PoolManager |
| CAMPAIGN / wXSTOCK hook | `0x18195c33D8150B2e7f5166FC79e29a6C2B1fB0CC` | Flags `0x30CC`; router-gated; 40% → 2.00% floor |
| Launch Factory v4 | `0xcF44b151aee1Ef69677f24cadED4d2d61b0D45BD` | Same proxy as WETH launches |
| Sentry LP Vault | `0x86585D4474C78c1C0fA1f8771682E9aD020787eC` | Owns every v4 launch position |
| v4 Quoter | `0x3972C00f7ed4885e145823eb7C655375d275A1C5` | Allowlisted so quotes include the 25% skim |
| v4 StateView | `0x76fd297e2d437cd7f76d50f01afe6160f86e9990` | Slot0 / liquidity reads |
| WETH9 | `0x4200000000000000000000000000000000000006` | 18 decimals |
| USDT0 | `0x0200C29006150606B650577BBE7B6248F58470c1` | 6 decimals |
| USDG | `0xe343167631d89B6Ffc58B88d6b7fB0228795491D` | Foundation book quote asset |
| Uni V3 Factory | `0x640887A9ba3A9C53Ed27D0F7e8246A4F933f3424` | Official Ink Uniswap V3 |
| Uni V3 SwapRouter02 | `0x177778F19E89dD1012BdBe603F144088A95C4B53` | USDG ↔ wrapper hop |
| Uni V3 QuoterV2 | `0x96b572D2d880cf2Fa2563651BD23ADE6f5516652` | USDG ↔ wrapper quotes |
| Velodrome SwapRouter | `0x63951637d667f23D5251DEdc0f9123D22d8595be` | Takes `tickSpacing`, not a Uni fee |
| Velodrome Quoter | `0x3FA596fAC2D6f7d16E01984897Ac04200Cb9cA05` | Same factory / tickSpacing ABI |
| Velo WETH/USDT0 pool | `0xaC7fC3e9b9d3377a90650fe62B858fF56bD841C9` | tickSpacing 100 |
| Velo USDT0/USDG pool | `0x31826a86cd62c6fa12a0a8441ec4c8bcfee8a453` | tickSpacing 1 |
| Quotron terminal pot | `0x0Aa7abB778DC11Dcaa1dBB16B72c70dD6f2d7A07` | 20% of the WETH peel |
| Quotron growth sink | `0x73F5111EE91672c114923793C03B5c868d9C5E03` | 20% of the WETH peel |

### Registered wrappers (pair these)

Live on-chain set: `GET https://sentry.trading/api/pwa/evm/stocks?chain=ink`.
Each wrapper has a Foundation Uniswap V3 USDG book at fee `500` (0.05%). Wrappers are
18-decimal ERC-4626 vaults (`asset()` returns the raw xStock).

| Wrapper | Name | Wrapper address (pair this) | Foundation V3 USDG pool | Raw xStock (do not pair) |
|---|---|---|---|---|
| wNVDAx | NVIDIA | `0xa8ddb5Cd96b5222AFe198316E9A57CAA642850D5` | `0x01951DDb43A451500bfAF652d40C07309fAD4727` | `0xc845b2894dBDdD03858fd2D643b4eF725fE0849d` |
| wAAPLx | Apple | `0x943BF64D566c32A2Bcd41AC92FB63C111cC9De8f` | `0x8986Bb68391ad5b0aFd7605e8075b273ca0189D6` | `0x9d275685dC284C8eb1c79F6ABa7A63dc75EC890A` |
| wTSLAx | Tesla | `0xc3FdBe3A68EE5dE461D30415a8165cf9Aefe1171` | `0x09444CbDfF5CD4437150a1f26865a3Ed85D8ED5E` | `0x8aD3c73F833d3F9A523AB01476625f269AeB7cF0` |
| wSPCXx | SpaceX | `0x8e2eeD8b8B5E13Ea7BF38e50d7821d2C57309072` | `0xDf1531451f6D97f847B27FaC671738D113db1406` | `0x68FA48b1c2FE52b3d776e1953e0E782b5044CE28` |
| wSPYx | S&P 500 ETF | `0xE7E553Cd128F0011777323A0b44a7b96EA1CB540` | `0x06fB000Fe9C6505Eb3b2CdF52445d8C7d5690F47` | `0x90A2A4c76B5D8C0Bc892a69EA28aa775A8f2dD48` |
| wPLTRx | Palantir | `0x4A2df09536F62341C9f946427D16414C04e21342` | `0xe5D0EB7705889631adCB2550db0f8447D5cb6506` | `0x6D482CeC5F9dd1F05CCEE9Fd3Ff79B246170F8e2` |
| wNFLXx | Netflix | `0x7d87fD6A379714194a797c0bBB8B40c30D250856` | `0x111D25ac72aD434D895F6f1ac8184AB5175e99ff` | `0xa6A65ac27E76cD53cb790473e4345C46e5Ebf961` |
| wMSTRx | Strategy | `0x30987adF0B11dc698438a99BA04ec3a1AB2c7EaB` | `0x169F2ab4D25aBa4F9b2743658f8549641c9D069D` | `0xAE2f842eF90c0d5213259AB82639d5bBF649B08E` |

### SentryStockRouterInk ABI

```
function buyExactEthForStockToken(address token, address stock, uint256 minOut, address recipient) payable returns (uint256);
function sellExactStockTokenForEth(address token, address stock, uint256 amountIn, uint256 minOut) returns (uint256);
function buyExactStockForToken(address token, address stock, uint256 amountIn, uint256 minOut, address recipient) returns (uint256);
function sellExactTokenForStock(address token, address stock, uint256 amountIn, uint256 minOut) returns (uint256);
function wethFeePips(address token, bool isBuy) view returns (uint24);

event StockSwap(address indexed sender, address indexed token, address indexed stock, bool isBuy, uint256 amountIn, uint256 amountOut, uint256 wethFee);
```

Approve the router before any token-in call. ETH-in sends `msg.value`. Pass `address(0)`
as `recipient` to send to `msg.sender`.

```js
const ROUTER = '0x1b4D919149912c9781b086C8242729EE317631C8';
const abi = [
  'function buyExactEthForStockToken(address token, address stock, uint256 minOut, address recipient) payable returns (uint256)',
  'function sellExactStockTokenForEth(address token, address stock, uint256 amountIn, uint256 minOut) returns (uint256)',
  'function buyExactStockForToken(address token, address stock, uint256 amountIn, uint256 minOut, address recipient) returns (uint256)',
  'function sellExactTokenForStock(address token, address stock, uint256 amountIn, uint256 minOut) returns (uint256)',
  'function wethFeePips(address token, bool isBuy) view returns (uint24)',
];
const router = new ethers.Contract(ROUTER, abi, signer);

await router.buyExactEthForStockToken(
  campaignToken, wrapper, minOut, ethers.ZeroAddress,
  { value: ethers.parseEther('0.01') },
);
```

### Factory + hook discovery

```
function launches(address token) view returns (address baseToken, address creator, address hook, int24 tickLower, int24 tickUpper);
function poolKeyOf(address token) view returns (tuple(address currency0, address currency1, uint24 fee, int24 tickSpacing, address hooks));
function poolIdOf(address token) view returns (bytes32);
function isStockBase(address) view returns (bool);
function feeRecipientOf(address token) view returns (address);
function launch(string name, string symbol, address baseToken) returns (address);
function launchWithFeeRecipient(string name, string symbol, address baseToken, address feeRecipient) returns (address);
function launchWithWhitelist(string name, string symbol, address baseToken, address feeRecipient, address[] whitelist) returns (address);

function currentFee(bytes32 poolId) view returns (uint24);   // pips, 1e6 = 100%
function endFee() view returns (uint24);                     // 20000 = 2.00%
function launchWhitelist(bytes32 poolId, address wallet) view returns (bool);
function swapRouter() view returns (address);
```

Every CAMPAIGN / wXSTOCK launch pool key:

- `fee` = `8388608` (Uniswap v4 `DYNAMIC_FEE_FLAG`, `0x800000`)
- `tickSpacing` = `200`
- `hooks` = `0x18195c33D8150B2e7f5166FC79e29a6C2B1fB0CC`
- `currency0` / `currency1` = `sorted(token, wrapper)`

`launches(token).baseToken == address(0)` means it is not a Sentry v4 launch. If
`baseToken` is one of the eight wrappers, route through `SentryStockRouterInk`.

### Quoting

The router has no `quote` function. Subtract `wethFeePips(token, isBuy)` from ETH
notionals (75% of the live hook curve, in pips). Whitelisted `tx.origin` buyers pay
`endFee` on buys, matching the hook.

```
// Buy: ETH → token
feePips  = router.wethFeePips(token, true)          // 15000 at the floor
afterFee = ethIn * (1_000_000 - feePips) / 1_000_000
usdt0    = veloQuoter.quoteExactInputSingle({ tokenIn: WETH,  tokenOut: USDT0, amountIn: afterFee, tickSpacing: 100, sqrtPriceLimitX96: 0 })
usdg     = veloQuoter.quoteExactInputSingle({ tokenIn: USDT0, tokenOut: USDG,  amountIn: usdt0,    tickSpacing: 1,   sqrtPriceLimitX96: 0 })
wrapper  = uniV3Quoter.quoteExactInputSingle({ tokenIn: USDG, tokenOut: wXSTOCK, amountIn: usdg, fee: 500, sqrtPriceLimitX96: 0 })
tokenOut = v4Quoter.quoteExactInputSingle({
  poolKey: factory.poolKeyOf(token),
  zeroForOne: wrapper == currency0,
  exactAmount: wrapper,
  hookData: '0x',
})
```

Quoter ABIs:

```
// Velodrome 0x3FA596fAC2D6f7d16E01984897Ac04200Cb9cA05
function quoteExactInputSingle((address tokenIn, address tokenOut, uint256 amountIn, int24 tickSpacing, uint160 sqrtPriceLimitX96))
  returns (uint256 amountOut, uint160 sqrtPriceX96After, uint32 initializedTicksCrossed, uint256 gasEstimate);

// Uni V3 QuoterV2 0x96b572D2d880cf2Fa2563651BD23ADE6f5516652
function quoteExactInputSingle((address tokenIn, address tokenOut, uint256 amountIn, uint24 fee, uint160 sqrtPriceLimitX96))
  returns (uint256 amountOut, uint160 sqrtPriceX96After, uint32 initializedTicksCrossed, uint256 gasEstimate);

// Uni v4 Quoter 0x3972C00f7ed4885e145823eb7C655375d275A1C5
function quoteExactInputSingle(((address currency0, address currency1, uint24 fee, int24 tickSpacing, address hooks) poolKey, bool zeroForOne, uint128 exactAmount, bytes hookData) params)
  returns (uint256 amountOut, uint256 gasEstimate);
```

Ink's PoolManager has no idle float. If you write your own unlock callback, **pre-settle
input** (`sync → transfer → settle`) *before* `pm.swap`. The official router already does
this. The hook `take()`s mid-swap; a post-settle router will underflow.

### Fees at the 2.00% floor

Decay: 40% flat for 3 minutes, 3-minute half-life, permanent **2.00%** floor (20,000 pips).
Reflections unlock 10 minutes after launch. All legs come out of the 2.00%:

| Leg | Share | Of the trade | Asset / destination |
|---|---|---|---|
| Creator | 60% of the 75% WETH peel | 0.90% | WETH to `feeRecipientOf(token)` |
| Terminal pot | 20% of the WETH peel | 0.30% | WETH via `donate()` |
| Growth sink | 20% of the WETH peel | 0.30% | WETH via `donate()` |
| Holder reflections | The hook's 25% | 0.50% | wXSTOCK via `notifyReward()` on the campaign token |

Launch-whitelist wallets pay `endFee` on buys only; sells are never exempt.

### Holder reflections ABI

```
function rewardToken() view returns (address);
function withdrawableDividendOf(address) view returns (uint256);
function accumulativeDividendOf(address) view returns (uint256);
function withdrawnDividends(address) view returns (uint256);
function claim() returns (uint256);
```

### Launching from another app

Call `launch` / `launchWithFeeRecipient` / `launchWithWhitelist` on the v4 factory with
`baseToken` set to a registered wrapper. Do not use `launchWithReflections` for these
pairs — that entrypoint is the WETH reflection hook. Confirm `factory.isStockBase(wrapper)`
first.

### Index

- Subgraph: https://api.goldsky.com/api/public/project_cmm7vh5xwsa8m01qmdr7w7u62/subgraphs/sentry-ink/1.5.0/gn
- Router events: `StockSwap` and `WethFeePaid` on `0x1b4D919149912c9781b086C8242729EE317631C8`
  (creator fees on these tokens are WETH, not the wrapper)

---

## 20. FAQ

**Q: Do I need a wallet extension to use Sentry?**
No. An EVM wallet is generated for you at signup. You can also import your own keys, or use
/swap with your own browser wallet and no account at all.

**Q: Is Sentry custodial?**
Generated and imported keys are stored encrypted on Sentry's servers and used only to sign
transactions you initiate. You can export every key at any time, which makes the arrangement
fully exitable. The /swap page is pure self-custody.

**Q: How does the aggregator get me a better price?**
It quotes Uniswap V3 (all fee tiers), Uniswap V2, Uniswap v4 Doppler pools, and PancakeSwap
V3 simultaneously on Robinhood Chain (every Uniswap V3 tier on Ink) and executes on whichever
returns the most output. You see the winning venue with your quote.

**Q: What does it cost to trade?**
1% of the swap input, on both chains, already included in the quote you see. Plus network
gas, which is fractions of a cent on both L2s.

**Q: How do I make money from a token I launched?**
On current Robinhood Chain launches your share is paid on every single trade, directly to
your wallet — 1.0% of every swap at the permanent 1.7% floor on a WETH launch, and far more
during the launch window while the anti-snipe curve is elevated. Nothing to collect. Legacy
V3 launches accrue instead: collect in Wallet → My Tokens, or
let Sentry's scheduled sweeps pay you automatically.

**Q: How does Sentry stop launch snipers?**
Every new pool opens at a 40% trade fee that decays to a permanent 1.7% floor over ~17
minutes — long enough to outlast the bot frenzy, not just the first block. The fee settles
per swap, so sniper volume pays the creator, deepens the locked liquidity, and funds the
protocol inside the sniper's own transaction. See the anti-snipe section under "Launching a
token".

**Q: Do whitelisted launch wallets get free or early tokens?**
No. They buy from the same public pool at the same market price as everyone else — they
just pay the 1.7% floor fee instead of the anti-snipe premium, on buys only. Sells are
never exempt, and the list is frozen on-chain at pool creation where anyone can verify it.

**Q: Can the liquidity be pulled ("rugged")?**
No. The launch position is held permanently by the SentryLPVault, an immutable contract
with no withdrawal function and no upgrade path. The token contract is renounced at deploy,
with no mint, pause, or blacklist.

**Q: Did the team keep any supply?**
No. 100% of the 1,000,000,000 supply goes into the pool. Any tokens the creator holds were
bought on the open market (the optional dev buy is a normal swap at market price).

**Q: What is the difference between boosting and featuring?**
Boosting (⚡) puts a token at the front of the Trending marquee AND fires a push notification
to every subscribed user; it is stackable by anyone. Featuring (⭐) pins the token in one of
three gold slots on the runner bar; it is placement only, with no notifications. Both cost
$25 to $125.

**Q: Why did I get a notification about a token I never starred?**
Boost alerts and big moves on boosted tokens are broadcast to all subscribers. Watchlist
alerts are only for tokens you starred. One toggle in Settings controls all push.

**Q: How many tokens can I watchlist?**
5. Each alerts you on 10%+ moves within an hour, checked every 10 minutes, no cooldown.

**Q: How do I register sergio.hood?**
Switch the app to Robinhood Chain, open Ecosystem → Domains → Register a name, search
"sergio", pick years (1 to 5), and confirm the quoted ETH price. On Ink the same flow
registers .ink names (1 to 10 years).

**Q: Can I use my .hood domain NFT as my profile picture?**
Yes. Wallet → NFTs → tap the domain → Set as PFP. It renders as a hexagon.

**Q: What does changing my username cost?**
$10, charged in ETH from your primary wallet. Your old handle is released immediately.

**Q: I lost my password. Can support reset it?**
Only if your account has a verified email (Settings → Account → Verification Status):
contact the team, prove control of that email — plus your 2FA code if enabled — and your
password can be reset. Without a verified email there is no reset path, by design. Either
way, export your private keys while you have access; the keys, not the password, are your
funds.

**Q: Does 2FA protect passkey logins?**
No. 2FA gates password logins only. A passkey is already two factors (device + biometric).

**Q: How fast is bridging?**
Usually seconds, via Relay. The Activity tab tracks every bridge with a receipt link.

**Q: Are Bankr tokens Sentry tokens?**
No. Bankr is a separate launchpad. Sentry lists Bankr tokens (grid badge shows the
launchpad) and routes trades to their Uniswap v4 pools with the same 1% fee, but their
launch mechanics are Bankr's, not the Sentry sequence described above.

**Q: How do I integrate Ink wrapped-xStock pairs?**
Use `SentryStockRouterInk` at `0x1b4D919149912c9781b086C8242729EE317631C8` against the
canonical Uniswap v4 PoolManager. Pair the ERC-4626 wrapper, never the raw xStock.
Addresses, ABIs, pool keys, and the quote hop are in section 19b and
https://sentry.trading/guide#ink-xstocks.

**Q: Where can I verify any of this?**
Everything is on-chain. Explorers: robinhoodchain.blockscout.com and
explorer.inkonchain.com. Public subgraphs are linked in section 19. The Ecosystem Stats
section of the in-app guide reads live protocol totals from the same public sources.

---

## 21. Support and links

- App: https://sentry.trading
- Guide (web): https://sentry.trading/guide
- Ink xStocks integrator docs: https://sentry.trading/guide#ink-xstocks
- This file: https://sentry.trading/sentry-guide.md
- X: https://x.com/sentrylauncher
- Telegram: https://t.me/sentrylauncher
- Buy alerts bot: https://t.me/SentryBuyBot
- Email: team@sentry.trading
- Founder: Sergio Luna, Founder & CEO of Sentry and of Mavrk, Inc. — sergio@sentry.trading · https://x.com/cruelhandeth
- Relay (bridging): https://relay.link
- ZNS (domains): https://zns.bio

*Nothing in this guide is investment advice. Tokens launched through Sentry are
user-deployed and unvetted; the launch mechanics prevent contract-level rug pulls but do not
guarantee any project's quality or price. Trade accordingly.*
