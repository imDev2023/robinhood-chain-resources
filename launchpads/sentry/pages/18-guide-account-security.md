# Sentry - Guide, Account Security

> Source: https://www.sentry.trading/desktop/guide#account-security
> Retrieved: 2026-09-02 (Jina Reader)
> Raw capture: `_raw/jina/sentry-desktop-guide.md`

---

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
