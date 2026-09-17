# Doppler - app command palette and settings menu

> Source: https://app.doppler.lol/ (search icon, and the Menu control)
> Retrieved: 2026-09-02 (agent-browser, session lp-doppler)

---

Two small surfaces in the app header, both captured because they are the only places the app exposes settings.

## Command palette

Screenshot: `screenshots/22-app-search.png`.
Opened from the search icon in the left rail.
A single input with the placeholder `Search tokens, navigate...`, then three grouped sections:

- **NAVIGATE**: Home, Portfolio
- **QUICK ACTIONS**: Create Token, Switch to Dark Mode, Copy Current URL
- **SOCIAL & COMMUNITY**: the same X, Telegram and Docs links as the footer

Token search is the primary use; typing filters live against the same feed the home page renders.

## Settings menu

Screenshot: `screenshots/21-app-menu.png`.
Opened from the `Menu` control.
Two settings, nothing else:

- **Instant buy**, an Off / On pair with a gear icon, plus an `Amount (USD)` row of `$10`, `$25`, `$50` and a `+` for a custom amount.
  Every one of these controls is **disabled** with no wallet connected.
  This is what powers the `Quick buy` button on every feed row.
- **Theme**, a System / Light / Dark picker.
  System is the default.

There is no slippage setting, no RPC setting and no account section here.
Per-trade slippage is set on the token page's own Buy panel (`pages/56-app-token-johndog-robinhood.md`).
