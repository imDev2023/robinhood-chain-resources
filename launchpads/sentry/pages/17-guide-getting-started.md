# Sentry - Guide, Getting Started

> Source: https://www.sentry.trading/desktop/guide#getting-started
> Retrieved: 2026-09-02 (Jina Reader)
> Raw capture: `_raw/jina/sentry-desktop-guide.md`

---

## Getting Started[](https://www.sentry.trading/desktop/guide#getting-started "Copy link to this section")

Three steps to a funded, ready-to-trade account.

1.   **Create a Sentry Account.** Pick a username (3 to 15 characters: letters, numbers, underscores) and a password (8 characters minimum), or use `Sign in with X` to create the account from your X profile. Your password is sent over TLS, hashed with bcrypt (cost 10) on the server, and only the hash is stored. The plaintext is never written to disk.
2.   **Receive your wallet.** The moment your account is created, the backend generates an EVM wallet and binds it to your account. The same address works on Robinhood Chain, Ink, and Ethereum mainnet. If you'd rather use an existing key, [import one](https://www.sentry.trading/desktop/guide#importing-wallets) instead.
3.   **Fund and trade.** Tap `Receive` to copy your address or get a QR code, and send ETH to it on either chain (or on mainnet, then use the [Bridge](https://www.sentry.trading/desktop/guide#bridging) tile, which settles in seconds). Once funded, hit `Swap` to start trading.
