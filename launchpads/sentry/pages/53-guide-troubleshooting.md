# Sentry - Guide, Troubleshooting

> Source: https://www.sentry.trading/desktop/guide#troubleshooting
> Retrieved: 2026-09-02 (Jina Reader)
> Raw capture: `_raw/jina/sentry-desktop-guide.md`

---

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
