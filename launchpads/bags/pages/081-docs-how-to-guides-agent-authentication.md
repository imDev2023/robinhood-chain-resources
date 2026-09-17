# Bags - Agent Authentication and Skill Workflow

> Source: https://docs.bags.fm/how-to-guides/agent-authentication
> Retrieved: 2026-09-02 (Mintlify markdown export, curl https://docs.bags.fm/how-to-guides/agent-authentication.md)

---

# Agent Authentication and Skill Workflow

> How AI agents authenticate with wallet signatures, obtain API keys, and use the Bags skill endpoint workflow

This guide explains the full Agent V2 authentication flow and how the Bags skill uses your credentials to run fee claiming, trading, and token launch workflows.

## Prerequisites

Before starting, make sure you have:

* Node.js 18+ and npm
* `curl` and `jq`
* A local Solana keypair file for your agent
* Dependencies for signing:

```bash theme={null}
npm install @solana/web3.js bs58 tweetnacl
```

## Endpoints Used in This Guide

* [`POST /agent/v2/auth/init`](/api-reference/agent-auth-init)
* [`POST /agent/v2/auth/callback`](/api-reference/agent-auth-callback)

## 1. Create or Load an Agent Wallet

Create a local keypair (once), then print your wallet address.

```bash theme={null}
mkdir -p ~/.config/bags

node -e '
  const fs = require("fs");
  const { Keypair } = require("@solana/web3.js");
  const keypairPath = `${process.env.HOME}/.config/bags/keypair.json`;

  if (!fs.existsSync(keypairPath)) {
    const kp = Keypair.generate();
    fs.writeFileSync(keypairPath, JSON.stringify(Array.from(kp.secretKey)));
  }

  const secret = Uint8Array.from(JSON.parse(fs.readFileSync(keypairPath, "utf8")));
  const wallet = Keypair.fromSecretKey(secret).publicKey.toBase58();
  process.stdout.write(wallet);
'

chmod 600 ~/.config/bags/keypair.json
```

Save the address as `BAGS_WALLET`:

```bash theme={null}
BAGS_WALLET=$(node -e '
  const fs = require("fs");
  const { Keypair } = require("@solana/web3.js");
  const keypairPath = `${process.env.HOME}/.config/bags/keypair.json`;
  const secret = Uint8Array.from(JSON.parse(fs.readFileSync(keypairPath, "utf8")));
  process.stdout.write(Keypair.fromSecretKey(secret).publicKey.toBase58());
')
```

## 2. Initialize Authentication Challenge

Request a challenge message and nonce:

```bash theme={null}
INIT_RESPONSE=$(curl -s -X POST "https://public-api-v2.bags.fm/api/v1/agent/v2/auth/init" \
  -H "Content-Type: application/json" \
  -d "{\"address\":\"$BAGS_WALLET\"}")

echo "$INIT_RESPONSE" | jq
```

Expected shape:

```json theme={null}
{
  "success": true,
  "response": {
    "message": "<base58-encoded-message>",
    "nonce": "<uuid>"
  }
}
```

## 3. Sign the Challenge Message

The `message` returned by init is base58-encoded. Decode it to bytes, sign using your Ed25519 key, then base58-encode the signature.

```bash theme={null}
CHALLENGE_MESSAGE=$(echo "$INIT_RESPONSE" | jq -r '.response.message')
CHALLENGE_NONCE=$(echo "$INIT_RESPONSE" | jq -r '.response.nonce')

SIGNATURE=$(node -e '
  const fs = require("fs");
  const bs58mod = require("bs58");
  const bs58 = bs58mod.default || bs58mod;
  const nacl = require("tweetnacl");

  const keypairPath = `${process.env.HOME}/.config/bags/keypair.json`;
  const messageB58 = process.argv[1];

  const secret = Uint8Array.from(JSON.parse(fs.readFileSync(keypairPath, "utf8")));
  const messageBytes = bs58.decode(messageB58);
  const signatureBytes = nacl.sign.detached(messageBytes, secret);

  process.stdout.write(bs58.encode(signatureBytes));
' "$CHALLENGE_MESSAGE")
```

## 4. Complete Signature Callback

Send the signature payload:

```bash theme={null}
CALLBACK_RESPONSE=$(curl -s -X POST "https://public-api-v2.bags.fm/api/v1/agent/v2/auth/callback" \
  -H "Content-Type: application/json" \
  -d "{
    \"signature\": \"$SIGNATURE\",
    \"address\": \"$BAGS_WALLET\",
    \"nonce\": \"$CHALLENGE_NONCE\",
    \"keyName\": \"My Agent Key\"
  }")

echo "$CALLBACK_RESPONSE" | jq
```

Two outcomes are possible:

1. API key returned immediately
2. MFA required (`mfaRequired: true`) and `authCode` returned

## 5. Handle MFA Callback (If Required)

If callback returns `mfaRequired: true`, call the same endpoint again with your MFA code:

```bash theme={null}
AUTH_CODE=$(echo "$CALLBACK_RESPONSE" | jq -r '.response.authCode')
MFA_CODE="123456"

MFA_RESPONSE=$(curl -s -X POST "https://public-api-v2.bags.fm/api/v1/agent/v2/auth/callback" \
  -H "Content-Type: application/json" \
  -d "{
    \"authCode\": \"$AUTH_CODE\",
    \"mfaCode\": \"$MFA_CODE\",
    \"keyName\": \"My Agent Key\"
  }")

echo "$MFA_RESPONSE" | jq
```

## 6. Store Credentials Securely

Save returned credentials in a local file:

```bash theme={null}
API_KEY=$(echo "$CALLBACK_RESPONSE" | jq -r '.response.apiKey // empty')
KEY_ID=$(echo "$CALLBACK_RESPONSE" | jq -r '.response.keyId // empty')

if [ -z "$API_KEY" ]; then
  API_KEY=$(echo "$MFA_RESPONSE" | jq -r '.response.apiKey')
  KEY_ID=$(echo "$MFA_RESPONSE" | jq -r '.response.keyId')
fi

mkdir -p ~/.config/bags
cat > ~/.config/bags/credentials.json << EOF
{
  "api_key": "$API_KEY",
  "key_id": "$KEY_ID",
  "wallet_address": "$BAGS_WALLET",
  "wallet_keypair_path": "$HOME/.config/bags/keypair.json",
  "authenticated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

chmod 600 ~/.config/bags/credentials.json
```

## How the Skill Works After Authentication

Once `api_key` is stored, the skill follows a consistent pattern:

1. Read `~/.config/bags/credentials.json`
2. Call a domain endpoint with `x-api-key`
3. If a transaction is returned, sign with local keypair
4. Submit through [`POST /solana/send-transaction`](/api-reference/send-transaction)

### Skill Modules and Their Endpoints

| Skill module | Purpose                             | Main endpoints                                                                                                                                                                                                                                          |
| ------------ | ----------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| AUTH.md      | Wallet-signature auth + MFA         | `/agent/v2/auth/init`, `/agent/v2/auth/callback`                                                                                                                                                                                                        |
| FEES.md      | Discover and claim earnings         | [`GET /token-launch/claimable-positions`](/api-reference/get-claimable-positions), [`POST /token-launch/claim-txs/v3`](/api-reference/get-claim-transactions-v3)                                                                                        |
| TRADING.md   | Quote and swap tokens               | [`GET /trade/quote`](/api-reference/get-trade-quote), [`POST /trade/swap`](/api-reference/create-swap-transaction)                                                                                                                                      |
| LAUNCH.md    | Create token metadata and launch tx | [`POST /token-launch/create-token-info`](/api-reference/create-token-info), [`POST /fee-share/config`](/api-reference/create-fee-share-configuration), [`POST /token-launch/create-launch-transaction`](/api-reference/create-token-launch-transaction) |
| WALLETS.md   | Local wallet ops and signing        | Uses API tx endpoints plus local signer script                                                                                                                                                                                                          |
| HEARTBEAT.md | Periodic health checks              | Reuses claimable positions + optional claim/trade flows                                                                                                                                                                                                 |

## Alternative: Using the Bags CLI

<Note>
  This section requires the Bags CLI. See [Install and Set Up the Bags CLI](/cli/install-and-setup) to get started.
</Note>

The CLI handles authentication in two modes:

* `wallet` (default): init/sign/callback (+ MFA when required)
* `manual`: validate a provided API key via `sdk.auth.me()`

Instead of writing scripts with `curl` and `jq`, you can authenticate in a single command:

**Quick setup (wallet + auth in one step):**

```bash theme={null}
bags setup --private-key YOUR_BASE58_PRIVATE_KEY --key-name "My Agent Key"
```

**Quick setup (manual API key mode):**

```bash theme={null}
bags setup --private-key YOUR_BASE58_PRIVATE_KEY --auth-mode manual --api-key YOUR_PUBLIC_API_KEY
```

**Or step by step:**

```bash theme={null}
# 1. Import your wallet
bags wallet import --key YOUR_BASE58_PRIVATE_KEY

# 2. Authenticate (handles challenge, signature, and MFA automatically)
bags auth login --key-name "My Agent Key"

# 3. Verify authentication
bags auth status
```

Manual step-by-step variant:

```bash theme={null}
bags auth login --auth-mode manual --api-key YOUR_PUBLIC_API_KEY
bags auth status
```

**Manage credentials:**

```bash theme={null}
# Log out (remove API key)
bags auth logout

# Log out and delete the local keypair
bags auth logout --all
```

The CLI stores credentials in `~/.config/bags/credentials.json` with `0600` permissions and includes `authMode` metadata (`wallet` or `manual`). Existing credentials without `authMode` are treated as `wallet`.

## Security and Reliability Notes

* Nonces are single-use and expire quickly (re-run init if expired).
* Never expose secret key bytes in logs.
* Keep keypair and credentials files at `chmod 600`.
* API key is shown once on successful callback; store it immediately.
* For retries, regenerate a fresh nonce and signature rather than replaying old payloads.

## Common Errors

* `Nonce not found or expired`: run init again, sign the new message, retry callback.
* `Invalid signature`: ensure you sign decoded message bytes, not the plain base58 string.
* `Invalid or expired auth code`: rerun signature callback to get a fresh `authCode`.
* `Too many requests`: wait and retry (auth endpoints are rate-limited).

## Related Skill Sources

* [Bags skill repository](https://github.com/bagsfm/bags-skill)
* [Bags skill entrypoint (SKILL.md)](https://bags.fm/SKILL.md)
* [Bags skill metadata (skill.json)](https://bags.fm/skill.json)
