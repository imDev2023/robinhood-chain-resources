# Sentry - Guide, Creating Tokens

> Source: https://www.sentry.trading/desktop/guide#creating-tokens
> Retrieved: 2026-09-02 (Jina Reader)
> Raw capture: `_raw/jina/sentry-desktop-guide.md`

---

## Creating Tokens[](https://www.sentry.trading/desktop/guide#creating-tokens "Copy link to this section")

Deploy your own ERC-20 on the active chain via the Sentry Launch Factory. The form opens from `Create` (center of the bottom nav on mobile, top nav on desktop). Your in-app wallet signs and pays gas, which is fractions of a cent on both chains. Launching is free apart from gas. For the on-chain mechanics (renouncement, LP lock, no pre-mine, no admin keys), see [Launch Mechanics](https://www.sentry.trading/desktop/guide#launch-mechanics).

1.   **Fill the form.** Coin name (up to 32 characters), symbol (up to 10), and a logo image (required). Optional: website, X, and Telegram links, and whether to display your username as the creator.
2.   **Optional dev buy.** Commit ETH (entered in USD or ETH) that buys your token immediately after the pool opens, at the same market price anyone else would get. If you skip it, the app automatically executes a tiny seed buy (0.00001 ETH from your wallet) right after the deploy, so the token registers a first trade and prices on chart sites, which only start tracking a token after its first swap.
3.   **Optional launch extras.** You can set a separate **creator fee recipient** at launch (route fees to a team multisig while you stay the recorded creator). Your launching wallet is automatically added to the [launch whitelist](https://www.sentry.trading/desktop/guide#anti-snipe) so your own dev buy pays the 1.7% floor, not the anti-snipe rate; accounts with **Bundle Buy** enabled can arm a front-run-proof multi-wallet buy whose wallets are whitelisted the same way. On Ink, wallets linked to a KYC'd Kraken account can use the **Kraken Verified** launch type.
4.   **Hit Deploy.** The factory deploys the ERC-20, creates the pool (a **Uniswap v4** dynamic-fee pool — paired with WETH on either chain, or with a tokenized stock on Robinhood Chain), mints the liquidity position into the immutable LP vault, and executes the dev buy, all in one flow. Your token then appears in the tokens grid and the advanced table, with your metadata and logo.
