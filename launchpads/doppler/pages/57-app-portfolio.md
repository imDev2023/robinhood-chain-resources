# Doppler - app portfolio

> Source: https://app.doppler.lol/portfolio
> Retrieved: 2026-09-02 (agent-browser read, session lp-doppler)

---

Screenshot: `screenshots/20-app-portfolio.png`.
Wallet-gated.
With no wallet connected the page renders the empty shell only.

Header tiles: Total value, Claimable fees, Total assets, 24h PnL, Tokens created.
Table columns: Token, Price, Balance, % Port, Est.
Value, Fees, 24h PnL, 24h.
Every column is sortable.
Empty state: `Wallet not connected` / `Get started by connecting your wallet` / `Connect`.

`Claimable fees` and the `Fees` column are how a creator collects the beneficiary share of pool fees described in `pages/55-app-create-standard-launch-robinhood.md`.
Neither could be captured without a wallet; see the Gaps section of `README.md`.
