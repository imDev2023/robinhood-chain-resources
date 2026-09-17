# Sentry - Create a new coin, the launch form behind the login gate

> Source: https://www.sentry.trading/desktop/create
> Retrieved: 2026-09-02 (agent-browser with a headless EIP-6963 wallet, signed in)
> Raw capture: `_raw/ab/read-create-authed.txt, _raw/ab/read-create-stock.txt, _raw/tools/hw-observer.js`

---

This is the wallet-gated view. It was reached with the tier 0 headless EIP-6963 provider from the `headless-wallet` skill, which announces a wallet, forwards reads to the chain, parks the SIWE challenge for an out-of-page signer, and records and rejects any `eth_sendTransaction`.
The SIWE challenge Sentry issues is bound to `Chain ID: 4663`, carries a single-use nonce and expires five minutes after issue.
No transaction was ever broadcast, and the deploy attempt captured here stopped at the client-side logo validation.

Screenshots: `screenshots/10-create.png`, `screenshots/38-create-form.png`, `screenshots/39-create-form-stock-pair.png`, `screenshots/40-create-form-lower.png`, `screenshots/41-create-stock-selector.png`, `screenshots/42-create-deploy-attempt.png`.

```text
Skip to tokens list

DiscoverSocialCreateProfileTools

Create a new coin

INK0xTEST...REDACTED

Coin info

Deploy your coin on Ink chain

Coin Name

Coin Symbol

Coin LogoTap to upload logo

Launch Type

StandardStock Base Pair

Telegram Coin EmojiCreate custom TG coin emoji · $20Learn more

Dev Buy (USD)Switch to ETH

Social linksOptional

Creator fee recipientOptional · defaults to your wallet

Deploy on Robinhood

kBTC$77,259.00

Guide·Disclaimers·Terms·Privacy

Sentry is a product of Mavrk, Inc.

## How do you like to swap?

Pick how you'd rather enter swap amounts. Most people prefer dollars — we'll do the math behind the scenes either way. You can change this anytime in Settings.

USD$10.00Token0.005 ETH

Slippage, balances, and on-chain transaction sizes are unaffected — this just changes how the input field is labelled.

## Turn on notifications 🔔

Get a heads-up when tokens get boosted and when boosted tokens make big moves — straight to this device, even when the app is closed.

Enable notificationsNot now

You can turn this on or off anytime in Settings.
```

## With Launch Type set to Stock Base Pair

```text
Skip to tokens list

DiscoverSocialCreateProfileTools

Create a new coin

INK0xTEST...REDACTED

Coin info

Deploy your coin on Ink chain

Coin Name

Coin Symbol

Coin LogoTap to upload logo

Launch Type

StandardStock Base Pair

Base Stock PairSelect a tokenized stock…

Your token launches paired with this stock. Holders earn the stock reflections on every trade.

Telegram Coin EmojiCreate custom TG coin emoji · $20Learn more

Dev Buy (USD)Switch to ETH

Social linksOptional

Creator fee recipientOptional · defaults to your wallet

Deploy on Robinhood

SENTRY$0.00320

Guide·Disclaimers·Terms·Privacy

Sentry is a product of Mavrk, Inc.
```

## Fields, in the order the form presents them

| field | required | notes |
| --- | --- | --- |
| Coin Name | yes | placeholder `My Token`; the guide caps it at 32 characters |
| Coin Symbol | yes | placeholder `TKN`; the guide caps it at 10 characters |
| Coin Logo | yes | `Tap to upload logo`; submitting without one returns the client-side error `Token logo is required.` |
| Launch Type | yes | `STANDARD` or `STOCK BASE PAIR`, a two-button toggle, Standard preselected |
| Base Stock Pair | only for a stock launch | `Select a tokenized stock...`, with the copy `Your token launches paired with this stock. Holders earn the stock reflections on every trade.` |
| Telegram Coin Emoji | no | `Create custom TG coin emoji - $20` |
| Dev Buy (USD) | no | with a `Switch to ETH` toggle |
| Social links | no | website, X and Telegram |
| Creator fee recipient | no | `Optional - defaults to your wallet` |

The submit button reads `DEPLOY ON ROBINHOOD` and a second, disabled control names the deploying wallet.

## The tokenized stocks the form offers

Nineteen stocks and ETFs are selectable in the picker (`screenshots/41-create-stock-selector.png`):

Apple AAPL `0xaF3D...93f9`, AMD `0x8692...3fdC`, Amazon AMZN `0x12f1...bF54`, Alphabet Class A GOOGL `0x2e08...4FE3`, Intel INTC `0xc72b...9681`, Meta Platforms META `0xc0D6...2f35`, Microsoft MSFT `0xe932...2e74`, Micron MU `0xfF08...4afD`, Netflix NFLX `0xE044...91E8`, NVIDIA NVDA `0xd060...9EEC`, Oracle ORCL `0xb099...EE03`, Palantir PLTR `0x894E...4F2A`, Invesco QQQ `0xD5f3...de68`, iShares Silver Trust SLV `0x411e...D89f`, SNDK `0xB90A...6400`, SpaceX Class A SPCX `0x4a0E...5eEa`, SPDR S&P 500 SPY `0x117c...4C0C`, Tesla TSLA `0x322F...3b2d`, United States Oil Fund USO `0xa30F...D344`.

The stock factory itself accepts far more: `getSupportedBaseTokens()` returned 88 addresses on 2026-09-02 (`_raw/rpc/derived-state-2026-09-02.txt`). The form is a curated subset of what the contract will take.

## A defect worth recording

With the network selector on Robinhood, the form's own header badge reads `INK` and the subtitle reads `Deploy your coin on Ink chain`, while the submit button correctly reads `Deploy on Robinhood` and the launch would go to the Robinhood factory.
The chain label in the Create card does not follow the network selector.
