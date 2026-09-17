# Sentry - Settings and the referral program

> Source: https://www.sentry.trading/desktop/tokens (Settings gear)
> Retrieved: 2026-09-02 (agent-browser after a wallet login)
> Raw capture: `_raw/ab/read-authed-settings.txt`

---

Screenshots: `screenshots/45-settings-authed.png`, `screenshots/46-settings-referrals.png`.

Settings is a modal, not a route: `/desktop/settings` redirects to Discover in both the logged-out and logged-in states.

```text
Skip to tokens list

DiscoverSocialCreateProfileTools

Creator tools

Bundle wallets

More tools soon

# Robinhood bundle wallets

Creator tools are not available for this account.

SENTRY$0.00320

Guide·Disclaimers·Terms·Privacy

Sentry is a product of Mavrk, Inc.

## Settings

AccountX connection, username, and social links

WalletImport, primary wallet, key exports, domains, Spend addresses

SecurityBiometric login, password, two-factor

PreferencesSwap input, Quick Buy, notifications

Referral ProgramGenerate your referral code, or enter a friend's

Guide·Disclaimers·Terms·Privacy·

Sentry is a product of Mavrk, Inc.
```

## Referral Program panel, verbatim

> Generate your referral code and invite friends. Anyone who signs up with your code - or trades through your buy links - earns you 1% of every trade they make, paid in ETH to your Sentry wallet on every swap. One code per account, yours forever.

> Leave blank for a random code.

> Have a referral code? Enter it once and that referrer earns a share of the platform fee on your swaps. Your own swap costs never change.

The subgraph's `routerStats_collection` shows how small this is in practice: 0.00213 WETH of referral payments against 2.98 WETH of router fees, all time (`_raw/api/goldsky-sentry-robinhood-protocol.json`).
