# Sentry - Guide, Spend

> Source: https://www.sentry.trading/desktop/guide#spend
> Retrieved: 2026-09-02 (Jina Reader)
> Raw capture: `_raw/jina/sentry-desktop-guide.md`

---

## Spend[](https://www.sentry.trading/desktop/guide#spend "Copy link to this section")

Move ETH out of Sentry and into an app you actually spend from. The Spend tile on the wallet page converts native ETH from any chain Sentry custodies (Ethereum mainnet, Ink, or Robinhood Chain) into whatever the destination app credits, and delivers it straight to a deposit address you saved. One transaction, no manual bridging, no intermediate swap.

## Supported apps

| App | You receive | Addresses you save |
| --- | --- | --- |
| Avici | USDC on Base or Solana | Your EVM and/or Solana deposit address |
| Robinhood | AVAX, ETH, BNB, SOL, BTC | One EVM address (covers AVAX, ETH and BNB), plus Solana and Bitcoin |
| Venmo | BTC, SOL, PYUSD on Arbitrum | One per coin and network |
| PayPal | BTC, SOL, PYUSD on Arbitrum | One per coin and network |
| Cash App | BTC | Your Bitcoin deposit address |

## How to use it

1.   Tap `Spend` on the wallet page and pick the app. Each app has its own screen and its own saved addresses.
2.   Add a destination the first time: copy the deposit address out of the other app (Avici: Add Money · Robinhood, Venmo and PayPal: Crypto → Transfer → Receive · Cash App: Bitcoin → Deposit Bitcoin), paste it, and give it a label. Robinhood and Cash App take one address per network and expand it into every asset that network can receive; Venmo and PayPal take one address per coin, so you pick the coin first.
3.   Choose the source chain, type an amount in dollars, and the sheet quotes what will actually arrive. Hit Spend.
4.   Sentry signs one transaction on the source chain. Delivery is tracked live: `depositing` → `pending` → `success`. The destination app credits the deposit on its own side, usually within moments of the fill.

## What happens behind the scenes

None of these apps support Ink or Robinhood Chain, and funds sent to them on an unsupported network are unrecoverable. So Spend never does a plain transfer across chains. It routes through [Relay Protocol](https://relay.link/) as a single intent: you sign one deposit on the source chain, and Relay's solver network delivers the destination asset — including the Solana and Bitcoin legs, which need nothing further from you.

Destinations are scoped to one wallet. Every EVM sub-wallet under your account keeps its own address book per app, so switching wallets switches the whole list, and a spend from one wallet can never route to another wallet's saved address. Saved addresses are masked by default; tap the eye icon to reveal them for a check.

Spend is the only place in Sentry where funds leave your own keyspace, so the backend refuses a raw address on the execute path: it will only deliver to an entry you explicitly saved. Bitcoin addresses are checksum-validated (bech32, bech32m and base58check, mainnet only) and Solana addresses are validated as real ed25519 public keys, because a typo on either network is unrecoverable.
