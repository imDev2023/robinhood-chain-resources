# Pools.trade - Connect a wallet gate

> Source: https://pools.trade/create
> Retrieved: 2026-09-03 (agent-browser accessibility snapshot with the headless-wallet observer injected)

---

Screenshot: `screenshots/13-connect-wallet-modal.png`.

The whole of `pools.trade` is readable without a wallet.
Discovery, token pages, charts, trade history and the first step of the create modal all render for an anonymous visitor.
The gate is a single button, `Connect a wallet`, at the bottom of the create modal, and it also gates `/portfolio` and every buy or sell panel.

There is no Sign-In-With-Ethereum step, no server nonce and no signature.
Connecting an EIP-6963 provider and returning an account from `eth_requestAccounts` is enough to reach the full create wizard, the portfolio and the trade panels.
That is a much lighter gate than the Privy SIWE flows on Doppler and Sentry.

## Wallet picker as rendered

```text
- heading "Connect a wallet" [level=2]
- button "Robinhood Crypto"
- button "Uniswap Mobile"
- button "Headless Wallet Detected"
- button "WalletConnect"
- link "Terms of Service" [url=https://uniswap.org/terms-of-service]
- link "Privacy Policy" [url=https://uniswap.org/privacy-policy]
```

`Robinhood Crypto` and `Uniswap Mobile` are the two named first-party connectors.
`Headless Wallet Detected` is the observer from `~/.claude/skills/headless-wallet` announcing itself over EIP-6963; the picker enumerates announced providers, so any EIP-6963 wallet appears here by its own name.

## Method used

```bash
S=~/.claude/skills/headless-wallet/scripts
node $S/make-observer.mjs --chain 4663 --address 0xTEST_WALLET_ADDRESS_REDACTED \
  --out "$PWD/_raw/tools/hw-observer.js"
export AGENT_BROWSER_SESSION=lp-pools-trade
agent-browser open https://pools.trade/create --init-script "$PWD/_raw/tools/hw-observer.js"
agent-browser click @e2      # Connect a wallet
agent-browser click @e5      # Headless Wallet Detected
```

The observer forwards reads to chain 4663 and records then rejects every `eth_sendTransaction`.
Nothing was ever broadcast.

## What could not be reached

The shared test wallet holds 0.00100 ETH, worth about $2.40 at capture.
Both review screens quote a network cost above that: `$7.14` for a Crowd Launch and `$2.83` for an Instant Launch.
The final button therefore reads `Add funds` rather than `Launch`, and the launch transaction is never built, so no `eth_sendTransaction` payload was captured from the interface.

That gap is closed from the other side instead.
The 50 most recent `LiquidityLauncher` transactions decode into the exact same call, and `_raw/blockscout/decoded-launcher-recent-50.txt` holds them.
A decoded production launch is better evidence than a captured form submission, and it is what section 3 of `README.md` is built from.
