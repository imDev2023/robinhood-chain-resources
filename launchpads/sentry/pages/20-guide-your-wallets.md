# Sentry - Guide, Your Wallets

> Source: https://www.sentry.trading/desktop/guide#your-wallets
> Retrieved: 2026-09-02 (Jina Reader)
> Raw capture: `_raw/jina/sentry-desktop-guide.md`

---

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
