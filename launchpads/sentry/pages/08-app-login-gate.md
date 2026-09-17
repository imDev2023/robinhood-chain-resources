# Sentry - The login gate: account, X, or wallet

> Source: https://www.sentry.trading/desktop/tokens (Login)
> Retrieved: 2026-09-02 (agent-browser)

---

Captured with the tier 0 observer provider described in `pages/07-app-create-form.md`. The private key never entered the page: the challenge was parked on `window.__HW.pending`, signed by `_raw/tools/sign-siwe.py` in a separate process, and only the signature was handed back.

Screenshots: `screenshots/13-login-modal.png`, `screenshots/34-login-modal.png`, `screenshots/35-login-picker.png`, `screenshots/36-login-account-form.png`, `screenshots/37-login-modal.png`.

Logged out, every authenticated route (`/desktop/create`, `/desktop/portfolio`, `/desktop/tools`, `/desktop/leaderboard`, `/desktop/referrals`, `/desktop/settings`, and the `/mobile/*` equivalents) client-side redirects to `/desktop/tokens`.

Pressing `Login` opens a full-screen landing panel (`screenshots/34-login-modal.png`) reading `Find Trade Launch the next $DOGE $SHIB $PEPE $BONK $SPX $WIF $FARTCOIN $FLOKI $MOG $POPCAT`, with `LOGIN`, `Explore`, and links to Terms and Privacy.

`LOGIN` opens the picker (`screenshots/35-login-picker.png`) with exactly three routes in:

- **Sentry Account** - username plus password. The form (`screenshots/36-login-account-form.png`) is Username, Password, a `Create a new Sentry Account` checkbox and a `LOGIN` button. The guide says usernames are 3 to 32 characters of letters, numbers and underscores, passwords at least 8 characters, hashed with bcrypt cost 10, and sessions last 24 hours.
- **Continue with X** - OAuth. X-created accounts start with no password.
- **Connect wallet** - `MetaMask, Rabby, Phantom, WalletConnect`. Choosing it enumerates injected wallets over EIP-6963 and shows a `WalletConnect` entry alongside them.

## What the wallet route actually asks for

The wallet route issues a SIWE `personal_sign` challenge. Decoded from the parked request:

```text
www.sentry.trading wants you to sign in with your Ethereum account:
0xTEST_WALLET_ADDRESS_REDACTED

Sign in to Sentry. This does not cost gas and does not give Sentry permission to move your funds.

URI: https://www.sentry.trading
Version: 1
Chain ID: 4663
Nonce: 6a70db81ff1f603686655a39d4ab0fc9
Issued At: 2026-09-02T20:21:15.529Z
Expiration Time: 2026-09-02T20:26:15.529Z
```

The nonce is server-issued and single-use and the window is five minutes, so a captured signature cannot be replayed.
There is no balance precheck on the login path: the shared test wallet, holding 0.001 ETH on chain 4663, signed in and reached the Create form without any funding prompt.

Once signed in, the top nav gains `Create`, `Profile`, `Tools`, a trade-history clock, a screenshot camera and a Settings gear.
