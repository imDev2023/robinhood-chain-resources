# Sentry - Guide, Privacy Policy

> Source: https://www.sentry.trading/desktop/guide#privacy
> Retrieved: 2026-09-02 (Jina Reader)
> Raw capture: `_raw/jina/sentry-desktop-guide.md`

---

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
