> ## Documentation Index
> Fetch the complete documentation index at: https://docs.bags.fm/llms.txt
> Use this file to discover all available pages before exploring further.

# Install and Set Up the Bags CLI

> Install the Bags CLI, configure your wallet and RPC, authenticate, and start using terminal-based workflows

The Bags CLI (`@bagsfm/bags-cli`) is a terminal tool that wraps the Bags API and SDK into simple commands. It lets you trade tokens, launch tokens, claim fees, manage fee share configs, and more all without writing code.

## Requirements

* **Node.js 18** or later

Verify your Node version:

```bash theme={null}
node --version
```

## Installation

Install globally via npm:

```bash theme={null}
npm install -g @bagsfm/bags-cli
```

Or run directly without installing:

```bash theme={null}
npx @bagsfm/bags-cli --help
```

After installing globally, the `bags` binary is available in your terminal:

```bash theme={null}
bags --help
```

## Quick Start with `bags setup`

The fastest way to get going is the first-run wizard. It configures your RPC endpoint, imports your wallet, and authenticates in a single command:

```bash theme={null}
bags setup
```

The wizard prompts you for:

1. **Solana RPC URL** -- defaults to `https://api.mainnet-beta.solana.com` if left blank
2. **Private key** -- accepts a base58-encoded key or a JSON integer array
3. **Auth mode** -- `wallet` (default) or `manual`
4. **API key** -- only when using `manual` mode
5. **MFA code** -- only in `wallet` mode if your account has MFA enabled

You can also pass everything as flags for non-interactive use:

```bash theme={null}
bags setup \
  --rpc-url https://your-rpc-provider.com \
  --private-key YOUR_BASE58_PRIVATE_KEY \
  --key-name "My CLI Key"
```

Manual mode example:

```bash theme={null}
bags setup \
  --rpc-url https://your-rpc-provider.com \
  --private-key YOUR_BASE58_PRIVATE_KEY \
  --auth-mode manual \
  --api-key YOUR_PUBLIC_API_KEY
```

| Flag                           | Description                              | Default                               |
| ------------------------------ | ---------------------------------------- | ------------------------------------- |
| `--rpc-url <url>`              | Solana RPC endpoint                      | `https://api.mainnet-beta.solana.com` |
| `--private-key <key>`          | Base58 private key or JSON integer array | Prompted interactively                |
| `--auth-mode <wallet\|manual>` | Authentication mode                      | `wallet`                              |
| `--api-key <key>`              | API key to use when `--auth-mode manual` | Prompted in interactive mode          |
| `--key-name <name>`            | Label for the generated API key          | `Bags CLI Key`                        |

In non-interactive environments, `manual` mode fails fast if no API key is provided (via `--api-key` or `--input-json`).

Once setup completes, you'll see a summary with your wallet address, masked API key, auth mode, and RPC URL.

## Manual Setup (Step by Step)

If you prefer to configure each piece individually:

### 1. Create or Import a Wallet

Generate a new Solana keypair:

```bash theme={null}
bags wallet generate
```

Or import an existing key:

<CodeGroup>
  ```bash Base58 key theme={null}
  bags wallet import --key YOUR_BASE58_PRIVATE_KEY
  ```

  ```bash JSON file theme={null}
  bags wallet import --file /path/to/keypair.json
  ```
</CodeGroup>

The keypair is saved to `~/.config/bags/keypair.json`.

### 2. Authenticate

Log in using either auth mode:

```bash theme={null}
bags auth login
```

Manual mode example:

```bash theme={null}
bags auth login --auth-mode manual --api-key YOUR_PUBLIC_API_KEY
```

If your account has MFA enabled, you'll be prompted for the code in `wallet` mode.

| Flag                           | Description                              | Default                       |
| ------------------------------ | ---------------------------------------- | ----------------------------- |
| `--auth-mode <wallet\|manual>` | Authentication mode                      | `wallet`                      |
| `--api-key <key>`              | API key to use when `--auth-mode manual` | Prompted in interactive mode  |
| `--keypair <path>`             | Path to a custom keypair file            | `~/.config/bags/keypair.json` |
| `--key-name <name>`            | Label for the API key                    | `Bags CLI Key`                |

### 3. Configure Settings

Set your preferred RPC endpoint and commitment level:

```bash theme={null}
bags settings set --rpc-url https://your-rpc-provider.com --commitment confirmed
```

### 4. Verify

Check that everything is working:

```bash theme={null}
bags auth status
bags wallet show
```

## Configuration Files

All CLI state lives under `~/.config/bags/`:

| File               | Purpose                                                                                                                   |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------- |
| `keypair.json`     | Your Solana keypair (secret key bytes). Permissions are set to `0600`.                                                    |
| `credentials.json` | API key, key ID (when available), auth mode, wallet address, and authentication timestamp. Permissions are set to `0600`. |
| `config.json`      | CLI settings: RPC URL, commitment level, output mode.                                                                     |

<Warning>
  Never share your `keypair.json` or `credentials.json`. These files contain secrets that grant full access to your wallet and API key.
</Warning>

## Global Options

Every command supports these global flags:

| Flag                  | Description                                                      |
| --------------------- | ---------------------------------------------------------------- |
| `--json`              | Force machine-readable JSON output regardless of settings        |
| `--input-json <json>` | Provide options as a JSON object, merged with any explicit flags |

The `--input-json` flag is useful for scripting. Explicit CLI flags take precedence over values in the JSON object:

```bash theme={null}
bags trade quote --input-json '{"inputMint":"So11...","outputMint":"EPjF...","amount":1000000}'
```

## Output Modes

Control how the CLI formats its output:

```bash theme={null}
bags settings set --output json
```

| Mode     | Description                             |
| -------- | --------------------------------------- |
| `pretty` | Human-friendly colored output (default) |
| `table`  | Tabular format for list data            |
| `json`   | Raw JSON for piping into other tools    |

View your current settings at any time:

```bash theme={null}
bags settings show
```

## Uninstalling

Remove credentials and keypair:

```bash theme={null}
bags auth logout --all
```

Uninstall the package:

```bash theme={null}
npm uninstall -g @bagsfm/bags-cli
```

## Next Steps

* Browse the full [CLI Command Reference](/cli/command-reference) to see every available command.
* Follow any of the [How-to Guides](/how-to-guides/trade-tokens) each guide includes CLI alternatives alongside the SDK examples.
