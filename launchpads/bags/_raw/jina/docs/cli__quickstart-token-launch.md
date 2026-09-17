> ## Documentation Index
> Fetch the complete documentation index at: https://docs.bags.fm/llms.txt
> Use this file to discover all available pages before exploring further.

# Quickstart: Launch a Token

> Go from zero to a live token on Solana in three commands using the Bags CLI

This guide shows the fastest path from an empty terminal to a launched token. Three commands, no code.

## Prerequisites

* **Node.js 18+** installed ([download](https://nodejs.org))
* A **Solana wallet private key** (base58-encoded, exportable from Bags, Phantom, or Backpack)
* Some **SOL** in the wallet for transaction fees and the initial buy

## Step 1 -- Install the CLI

```bash theme={null}
npm install -g @bagsfm/bags-cli
```

## Step 2 -- Set up your wallet and authenticate

Run the setup wizard. It configures your RPC, imports your wallet, and authenticates all in one command:

```bash theme={null}
bags setup --rpc-url YOUR_RPC_URL --private-key YOUR_BASE58_PRIVATE_KEY
```

<Note>
  If you leave `--rpc-url` blank, it defaults to `https://api.mainnet-beta.solana.com`. For production launches, use a dedicated RPC provider for better reliability.
</Note>

<Note>
  `bags setup` uses `wallet` auth mode by default. If you already have an API key, use `--auth-mode manual --api-key YOUR_PUBLIC_API_KEY`.
</Note>

You'll see a summary once setup completes:

```
Setup complete!
  Wallet:  YourWa11etPubkeyHere...
  API Key: abc123...wxyz
  RPC:     https://your-rpc-provider.com
```

## Step 3 -- Launch your token

```bash theme={null}
bags launch create \
  --name "My Token" \
  --symbol "MTK" \
  --description "My first token on Bags" \
  --image-url "https://example.com/logo.png" \
  --initial-buy 10000000 \
  --skip-confirm
```

That's it. The CLI handles metadata upload, fee share configuration, Jito bundle tips, and the launch transaction automatically.

<Note>
  The `--initial-buy` value is in **lamports** (1 SOL = 1,000,000,000 lamports). The example above uses 10,000,000 lamports = 0.01 SOL.
</Note>

Once the launch succeeds, you'll see output like:

```
tokenMint:    AbC123...xYz
metadataUrl:  https://arweave.net/...
configKey:    DeF456...uVw
signature:    5KtPn1LGux...
```

View your token at `https://bags.fm/YOUR_TOKEN_MINT`.

***

## The full sequence

```bash theme={null}
# 1. Install
npm install -g @bagsfm/bags-cli

# 2. Setup (wallet + auth)
bags setup --rpc-url YOUR_RPC_URL --private-key YOUR_BASE58_PRIVATE_KEY

# 3. Launch
bags launch create \
  --name "My Token" \
  --symbol "MTK" \
  --description "My first token on Bags" \
  --image-url "https://example.com/logo.png" \
  --initial-buy 10000000 \
  --skip-confirm
```

## Optional: Share fees with others

Add `--fee-claimers` to split fees with other users by social handle or wallet address:

```bash theme={null}
bags launch create \
  --name "My Token" \
  --symbol "MTK" \
  --description "A token with shared fees" \
  --image-url "https://example.com/logo.png" \
  --initial-buy 10000000 \
  --fee-claimers '[{"provider":"twitter","username":"ramyobags","bps":3000}]' \
  --skip-confirm
```

The creator automatically keeps the remaining share (70% in this example). See the [Launch a Token](/how-to-guides/launch-token) guide for the full fee sharing details.

## Optional: Use a local image file

If you have the image on disk instead of a URL:

```bash theme={null}
bags launch create \
  --name "My Token" \
  --symbol "MTK" \
  --description "My first token on Bags" \
  --image /path/to/logo.png \
  --initial-buy 10000000 \
  --skip-confirm
```

## Optional: Interactive mode

Omit the flags and the CLI walks you through each field interactively:

```bash theme={null}
bags launch create
```

You'll be prompted for the token name, symbol, description, image, initial buy amount, and whether to share fees -- step by step.

## What's next?

* [Claim fees](/how-to-guides/claim-fees) earned from your token: `bags fees claim TOKEN_MINT`
* [Trade tokens](/how-to-guides/trade-tokens): `bags trade swap --input-mint ... --output-mint ... --amount ...`
* [CLI Command Reference](/cli/command-reference) for every available command
* [Install and Set Up the Bags CLI](/cli/install-and-setup) for detailed configuration options
