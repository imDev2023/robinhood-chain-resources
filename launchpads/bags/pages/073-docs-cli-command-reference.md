# Bags - CLI Command Reference

> Source: https://docs.bags.fm/cli/command-reference
> Retrieved: 2026-09-02 (Mintlify markdown export, curl https://docs.bags.fm/cli/command-reference.md)

---

# CLI Command Reference

> Complete reference for every Bags CLI command, subcommand, flag, and option

This page documents every command available in the Bags CLI. All commands support the global `--json` flag for machine-readable output and `--input-json <json>` for scripting.

<Note>
  Make sure you've completed the [Install and Set Up the Bags CLI](/cli/install-and-setup) guide before using these commands.
</Note>

## setup

First-run wizard that configures RPC, imports your wallet, and authenticates in one step using either `wallet` (default) or `manual` auth mode.

```bash theme={null}
bags setup [options]
```

| Flag                           | Description                              | Default                               |
| ------------------------------ | ---------------------------------------- | ------------------------------------- |
| `--rpc-url <url>`              | Solana RPC URL                           | `https://api.mainnet-beta.solana.com` |
| `--private-key <key>`          | Private key (base58 or integer array)    | Prompted                              |
| `--auth-mode <wallet\|manual>` | Authentication mode                      | `wallet`                              |
| `--api-key <key>`              | API key to use when `--auth-mode manual` | Prompted in interactive mode          |
| `--key-name <name>`            | Label for the generated API key          | `Bags CLI Key`                        |

```bash theme={null}
bags setup --rpc-url https://my-rpc.com --private-key YOUR_KEY
```

```bash theme={null}
bags setup --private-key YOUR_KEY --auth-mode manual --api-key YOUR_PUBLIC_API_KEY
```

***

## auth

Agent authentication commands.

### auth login

Authenticate and store credentials locally. Supports `wallet` mode (challenge/signature flow) and `manual` mode (validate provided API key via `sdk.auth.me()`).

```bash theme={null}
bags auth login [options]
```

| Flag                           | Description                              | Default                       |
| ------------------------------ | ---------------------------------------- | ----------------------------- |
| `--auth-mode <wallet\|manual>` | Authentication mode                      | `wallet`                      |
| `--api-key <key>`              | API key to use when `--auth-mode manual` | Prompted in interactive mode  |
| `--keypair <path>`             | Custom keypair file path                 | `~/.config/bags/keypair.json` |
| `--key-name <name>`            | Label for the API key                    | `Bags CLI Key`                |

```bash theme={null}
bags auth login --key-name "Production Key"
```

```bash theme={null}
bags auth login --auth-mode manual --api-key YOUR_PUBLIC_API_KEY
```

```bash theme={null}
bags auth login --input-json '{"authMode":"manual","apiKey":"YOUR_PUBLIC_API_KEY"}'
```

In non-interactive environments, `manual` mode requires `--api-key` (or `--input-json` with `apiKey`) and exits immediately if missing.

### auth status

Display the current authentication state including `authMode` and the masked API key.

```bash theme={null}
bags auth status
```

### auth logout

Remove stored credentials. Optionally delete the local keypair too.

```bash theme={null}
bags auth logout [options]
```

| Flag    | Description                          |
| ------- | ------------------------------------ |
| `--all` | Also delete the local wallet keypair |

```bash theme={null}
bags auth logout --all
```

***

## wallet

Wallet management commands.

### wallet generate

Generate and save a new Solana keypair to `~/.config/bags/keypair.json`.

```bash theme={null}
bags wallet generate [options]
```

| Flag      | Description                        |
| --------- | ---------------------------------- |
| `--force` | Overwrite an existing keypair file |

### wallet import

Import a keypair from a base58 private key or a JSON secret key file.

```bash theme={null}
bags wallet import [options]
```

| Flag             | Description                                     |
| ---------------- | ----------------------------------------------- |
| `--key <base58>` | Base58-encoded private key                      |
| `--file <path>`  | Path to a JSON file containing secret key bytes |

```bash theme={null}
bags wallet import --key YOUR_BASE58_PRIVATE_KEY
```

### wallet show

Show the wallet's public key and SOL balance.

```bash theme={null}
bags wallet show [options]
```

| Flag          | Description                     |
| ------------- | ------------------------------- |
| `--rpc <url>` | Override the configured RPC URL |

### wallet balance

Show SOL balance, or a specific SPL token balance.

```bash theme={null}
bags wallet balance [options]
```

| Flag             | Description                                 |
| ---------------- | ------------------------------------------- |
| `--rpc <url>`    | Override the configured RPC URL             |
| `--token <mint>` | SPL token mint address to check balance for |

```bash theme={null}
bags wallet balance --token EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v
```

***

## settings

CLI configuration commands.

### settings show

Print the current CLI settings (RPC URL, commitment, output mode).

```bash theme={null}
bags settings show
```

### settings set

Update one or more CLI settings.

```bash theme={null}
bags settings set [options]
```

| Flag                   | Description                  | Values                                |
| ---------------------- | ---------------------------- | ------------------------------------- |
| `--rpc-url <url>`      | Default Solana RPC endpoint  | Any valid URL                         |
| `--commitment <level>` | Transaction commitment level | `processed`, `confirmed`, `finalized` |
| `--output <mode>`      | Default output format        | `pretty`, `table`, `json`             |

```bash theme={null}
bags settings set --rpc-url https://my-rpc.com --commitment confirmed --output json
```

***

## trade

Quote and execute token swaps.

### trade quote

Get a swap quote without executing a transaction.

```bash theme={null}
bags trade quote [options]
```

| Flag                      | Description                                                     | Default  |
| ------------------------- | --------------------------------------------------------------- | -------- |
| `--input-mint <address>`  | Input token mint address                                        | Prompted |
| `--output-mint <address>` | Output token mint address                                       | Prompted |
| `--amount <amount>`       | Amount in base units (e.g. lamports)                            | Prompted |
| `--slippage-mode <mode>`  | `auto` or `manual`                                              | `auto`   |
| `--slippage-bps <bps>`    | Slippage tolerance in basis points (required for `manual` mode) | --       |

```bash theme={null}
bags trade quote \
  --input-mint So11111111111111111111111111111111 \
  --output-mint EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v \
  --amount 1000000000
```

### trade swap

Get a quote, then sign and send the swap transaction.

```bash theme={null}
bags trade swap [options]
```

Accepts all the same flags as `trade quote`, plus:

| Flag             | Description                              |
| ---------------- | ---------------------------------------- |
| `--skip-confirm` | Skip the interactive confirmation prompt |

```bash theme={null}
bags trade swap \
  --input-mint So11111111111111111111111111111111 \
  --output-mint EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v \
  --amount 1000000000 \
  --skip-confirm
```

***

## launch

Token launch flows.

### launch create

Create and launch a new token. Handles metadata upload, fee share configuration, lookup table creation, Jito bundles, and the launch transaction automatically.

```bash theme={null}
bags launch create [options]
```

| Flag                        | Description                            | Default                       |
| --------------------------- | -------------------------------------- | ----------------------------- |
| `--name <name>`             | Token name                             | Prompted                      |
| `--symbol <symbol>`         | Token ticker symbol                    | Prompted                      |
| `--description <text>`      | Token description                      | Prompted                      |
| `--image-url <url>`         | URL to the token image                 | Prompted (choose URL or file) |
| `--image <path>`            | Local path to the token image          | Prompted (choose URL or file) |
| `--twitter <url>`           | Twitter/X URL                          | Optional                      |
| `--website <url>`           | Website URL                            | Optional                      |
| `--telegram <url>`          | Telegram URL                           | Optional                      |
| `--initial-buy <lamports>`  | Initial buy amount in lamports         | `10000000` (0.01 SOL)         |
| `--fee-claimers <json>`     | JSON array of fee claimers (see below) | Interactive builder           |
| `--partner <pubkey>`        | Partner wallet address                 | --                            |
| `--partner-config <pubkey>` | Partner config PDA                     | --                            |
| `--skip-confirm`            | Skip the final confirmation prompt     | --                            |

**Fee claimers JSON format:**

Fee claimers can reference social usernames or direct wallet addresses:

```json theme={null}
[
  {"provider": "twitter", "username": "alice", "bps": 3000},
  {"wallet": "WALLET_PUBKEY_HERE", "bps": 2000}
]
```

The creator automatically receives the remaining BPS (in the example above, 50%).

```bash theme={null}
bags launch create \
  --name "My Token" \
  --symbol "MTK" \
  --description "A great token" \
  --image-url "https://example.com/image.png" \
  --initial-buy 10000000 \
  --skip-confirm
```

### launch feed

Get the recent token launch feed.

```bash theme={null}
bags launch feed [options]
```

| Flag          | Description               | Default |
| ------------- | ------------------------- | ------- |
| `--limit <n>` | Number of items to return | `20`    |

### launch creators

Get the creators/deployers for a token.

```bash theme={null}
bags launch creators [options]
```

| Flag               | Description        |
| ------------------ | ------------------ |
| `--mint <address>` | Token mint address |

```bash theme={null}
bags launch creators --mint TOKEN_MINT_ADDRESS
```

***

## fees

Fee claiming and analytics.

### fees list

List all claimable fee positions for your local wallet.

```bash theme={null}
bags fees list
```

Outputs a table with columns: Mint, Claimable Lamports, Custom Vault.

### fees claim

Claim fees for a single token.

```bash theme={null}
bags fees claim [mint] [options]
```

| Flag               | Description                                     |
| ------------------ | ----------------------------------------------- |
| `--mint <address>` | Token mint (alternative to positional argument) |
| `--skip-confirm`   | Skip the confirmation prompt                    |

```bash theme={null}
bags fees claim TOKEN_MINT_ADDRESS --skip-confirm
```

### fees claim-all

Claim all available fees across every token.

```bash theme={null}
bags fees claim-all [options]
```

| Flag             | Description                  |
| ---------------- | ---------------------------- |
| `--skip-confirm` | Skip the confirmation prompt |

### fees lifetime

Get total lifetime fees collected for a token.

```bash theme={null}
bags fees lifetime [mint] [options]
```

| Flag               | Description                                     |
| ------------------ | ----------------------------------------------- |
| `--mint <address>` | Token mint (alternative to positional argument) |
| `--raw`            | Show raw lamports instead of formatted SOL      |

```bash theme={null}
bags fees lifetime TOKEN_MINT_ADDRESS --raw
```

### fees events

Get claim event history for a token. Supports pagination via offset/limit or time-range filtering.

```bash theme={null}
bags fees events [mint] [options]
```

| Flag                 | Description                                     |
| -------------------- | ----------------------------------------------- |
| `--mint <address>`   | Token mint (alternative to positional argument) |
| `--offset <n>`       | Pagination offset                               |
| `--limit <n>`        | Number of events to return                      |
| `--start-time <iso>` | Start timestamp (ISO 8601)                      |
| `--end-time <iso>`   | End timestamp (ISO 8601)                        |

```bash theme={null}
bags fees events TOKEN_MINT --offset 0 --limit 10
bags fees events TOKEN_MINT --start-time 2025-01-01T00:00:00Z --end-time 2025-06-01T00:00:00Z
```

### fees stats

Get aggregated claim statistics for a token.

```bash theme={null}
bags fees stats [mint] [options]
```

| Flag               | Description                                     |
| ------------------ | ----------------------------------------------- |
| `--mint <address>` | Token mint (alternative to positional argument) |

***

## config

Fee share configuration management (admin operations).

### config create

Create a fee share configuration for a token.

```bash theme={null}
bags config create [options]
```

| Flag                    | Description                                         |
| ----------------------- | --------------------------------------------------- |
| `--mint <address>`      | Base token mint                                     |
| `--fee-claimers <json>` | JSON array of `[{"user":"PUBKEY","userBps":10000}]` |
| `--partner <pubkey>`    | Partner wallet address                              |
| `--skip-confirm`        | Skip the confirmation prompt                        |

```bash theme={null}
bags config create \
  --mint TOKEN_MINT \
  --fee-claimers '[{"user":"WALLET_A","userBps":5000},{"user":"WALLET_B","userBps":5000}]' \
  --skip-confirm
```

### config update

Update an existing fee share configuration (requires admin authority).

```bash theme={null}
bags config update [options]
```

| Flag                    | Description                                         |
| ----------------------- | --------------------------------------------------- |
| `--mint <address>`      | Base token mint                                     |
| `--fee-claimers <json>` | New JSON array of `[{"user":"PUBKEY","userBps":N}]` |
| `--skip-confirm`        | Skip the confirmation prompt                        |

### config transfer-admin

Transfer fee share admin authority to a new wallet.

```bash theme={null}
bags config transfer-admin [options]
```

| Flag                   | Description                  |
| ---------------------- | ---------------------------- |
| `--mint <address>`     | Base token mint              |
| `--new-admin <pubkey>` | New admin wallet address     |
| `--skip-confirm`       | Skip the confirmation prompt |

```bash theme={null}
bags config transfer-admin --mint TOKEN_MINT --new-admin NEW_ADMIN_PUBKEY
```

### config admin-list

List all token mints where your wallet is the fee share admin.

```bash theme={null}
bags config admin-list
```

***

## partner

Partner configuration and fee claiming.

### partner create

Create a partner configuration for your local wallet. Each wallet can only have one partner config.

```bash theme={null}
bags partner create [options]
```

| Flag             | Description                  |
| ---------------- | ---------------------------- |
| `--skip-confirm` | Skip the confirmation prompt |

### partner stats

Get statistics for a partner wallet.

```bash theme={null}
bags partner stats [options]
```

| Flag                 | Description               |
| -------------------- | ------------------------- |
| `--partner <pubkey>` | Partner wallet public key |

```bash theme={null}
bags partner stats --partner PARTNER_PUBKEY
```

### partner claim

Claim accumulated partner fees.

```bash theme={null}
bags partner claim [options]
```

| Flag             | Description                  |
| ---------------- | ---------------------------- |
| `--skip-confirm` | Skip the confirmation prompt |

***

## pool

Pool lookup commands.

### pool list

List Bags liquidity pools.

```bash theme={null}
bags pool list [options]
```

| Flag           | Description               | Default |
| -------------- | ------------------------- | ------- |
| `--limit <n>`  | Number of pools to return | `50`    |
| `--offset <n>` | Pagination offset         | `0`     |

### pool get

Get details for a specific pool by token mint.

```bash theme={null}
bags pool get [options]
```

| Flag               | Description        |
| ------------------ | ------------------ |
| `--mint <address>` | Token mint address |

```bash theme={null}
bags pool get --mint TOKEN_MINT_ADDRESS
```

***

## dexscreener

Dexscreener listing order flows.

### dexscreener check

Check if a Dexscreener order is available for a token.

```bash theme={null}
bags dexscreener check [options]
```

| Flag               | Description        |
| ------------------ | ------------------ |
| `--mint <address>` | Token mint address |

### dexscreener order

Create a Dexscreener listing order.

```bash theme={null}
bags dexscreener order [options]
```

| Flag               | Description               |
| ------------------ | ------------------------- |
| `--mint <address>` | Token mint address        |
| `--payload <json>` | Raw JSON payload override |

### dexscreener pay

Submit payment for a Dexscreener order.

```bash theme={null}
bags dexscreener pay [options]
```

| Flag                 | Description                          |
| -------------------- | ------------------------------------ |
| `--order-id <id>`    | Order ID from the `order` command    |
| `--transaction <tx>` | Signed serialized transaction string |
