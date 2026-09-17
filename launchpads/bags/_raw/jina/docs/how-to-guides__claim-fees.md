> ## Documentation Index
> Fetch the complete documentation index at: https://docs.bags.fm/llms.txt
> Use this file to discover all available pages before exploring further.

# Claim Token Fees

> Complete guide to claim fees for a token using the Bags API with TypeScript and Node.js

In this guide, you'll learn how to claim fees for a specific token using the Bags TypeScript SDK with Node.js. The simplified claim flow only requires a token mint address and your wallet — the API handles the rest.

## Prerequisites

Before starting, make sure you have:

* Completed our [TypeScript and Node.js Setup Guide](/how-to-guides/typescript-node-setup).
* Got your API key from the [Bags Developer Portal](https://dev.bags.fm).
* A Solana wallet with claimable fees (from token launches, liquidity pools, etc.).
* Installed the additional dependencies for this guide:
  ```bash theme={null}
  npm install @solana/web3.js bs58
  ```

## 1. Set Up Environment Variables

This guide requires your wallet's private key. Add it to your base `.env` file:

```bash theme={null}
# .env
BAGS_API_KEY=your_api_key_here
SOLANA_RPC_URL=https://api.mainnet-beta.solana.com
PRIVATE_KEY=your_base58_encoded_private_key_here  # Required for this guide
```

<Note>
  You can export your private key from wallets like Bags, Phantom, or Backpack.
</Note>

## 2. The Fee Claiming Script

Here is a script to claim fees for a specific token. You can save this as `claim-fees.ts`.

The claim flow is straightforward — pass your wallet and the token mint to the SDK and you'll receive ready-to-sign transactions back.

## Endpoints Used Under the Hood

This guide uses these API endpoints via the SDK:

* [`POST /token-launch/claim-txs/v3`](/api-reference/get-claim-transactions-v3) via `sdk.fee.getClaimTransactions()`
* [`GET /token-launch/claimable-positions`](/api-reference/get-claimable-positions) via `sdk.fee.getAllClaimablePositions()`

```typescript theme={null}
// claim-fees.ts
import dotenv from "dotenv";
dotenv.config({ quiet: true });

import { BagsSDK, signAndSendTransaction } from "@bagsfm/bags-sdk";
import { Keypair, Connection, PublicKey } from "@solana/web3.js";
import bs58 from "bs58";

// Initialize SDK
const BAGS_API_KEY = process.env.BAGS_API_KEY;
const SOLANA_RPC_URL = process.env.SOLANA_RPC_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;

if (!BAGS_API_KEY || !SOLANA_RPC_URL || !PRIVATE_KEY) {
    throw new Error("BAGS_API_KEY, SOLANA_RPC_URL, and PRIVATE_KEY are required");
}

const connection = new Connection(SOLANA_RPC_URL);
const sdk = new BagsSDK(BAGS_API_KEY, connection, "processed");

async function claimFeesForToken(tokenMint: string) {
    try {
        if (!PRIVATE_KEY) {
            throw new Error("PRIVATE_KEY is not set");
        }

        const keypair = Keypair.fromSecretKey(bs58.decode(PRIVATE_KEY));
        const commitment = sdk.state.getCommitment();

        console.log(`Claiming fees for token ${tokenMint} with wallet ${keypair.publicKey.toBase58()}`);

        // Get claim transactions — just pass your wallet and token mint
        const claimTransactions = await sdk.fee.getClaimTransactions(
            keypair.publicKey,
            new PublicKey(tokenMint)
        );

        if (!claimTransactions || claimTransactions.length === 0) {
            console.log("No claimable fees found for this token.");
            return;
        }

        console.log(`Generated ${claimTransactions.length} claim transaction(s)`);

        // Sign and send each transaction
        for (let i = 0; i < claimTransactions.length; i++) {
            const transaction = claimTransactions[i];

            try {
                const signature = await signAndSendTransaction(
                    connection,
                    commitment,
                    transaction,
                    keypair
                );
                console.log(`Transaction ${i + 1} confirmed: ${signature}`);
            } catch (txError) {
                console.error(`Failed to send transaction ${i + 1}:`, txError);
            }
        }

        console.log("Fee claiming completed!");
    } catch (error) {
        console.error("Unexpected error:", error);
    }
}

claimFeesForToken("TOKEN_MINT");
```

## 3. How It Works

The SDK's `getClaimTransactions()` method handles all the complexity for you:

1. **You provide**: Your wallet and the token mint
2. **The API automatically**: Looks up your claimable position, determines the position type (virtual pool, DAMM V2, custom fee vault), and builds the appropriate claim transactions
3. **You receive**: An array of versioned transactions ready to sign and send

<Note>
  **Non-SOL (DAMM v2 direct) launches:** Fees for tokens launched directly into a DAMM v2 pool with a non-SOL quote token pay out in that pool's quote mint, and partner/deployer revenue is swept from aggregate vaults. That flow uses `claim-txs/v2` and the vault endpoints instead of the simplified method shown here — see [Launch a Token with a Non-SOL Quote Token](/how-to-guides/launch-token-non-sol-quote).
</Note>

## 4. Checking Claimable Positions (Optional)

If you want to inspect your claimable positions before claiming — for example, to check claimable amounts or see which tokens have fees available — you can use the SDK's `getAllClaimablePositions()` method:

```typescript theme={null}
async function getClaimablePositions(wallet: PublicKey) {
    const positions = await sdk.fee.getAllClaimablePositions(wallet);

    console.log(`Found ${positions.length} claimable position(s)`);

    for (const position of positions) {
        console.log(`\nToken: ${position.baseMint}`);
        console.log(`  Total claimable: ${(position.totalClaimableLamportsUserShare / 1_000_000_000).toFixed(9)} SOL`);
        console.log(`  Custom fee vault: ${position.isCustomFeeVault ? "Yes" : "No"}`);
    }

    return positions;
}
```

This is useful for building UIs that display fee balances, or for deciding which tokens to claim fees for.

## Alternative: Using the Bags CLI

<Note>
  This section requires the Bags CLI. See [Install and Set Up the Bags CLI](/cli/install-and-setup) to get started.
</Note>

The CLI lets you view and claim fees without writing scripts:

**List all claimable positions:**

```bash theme={null}
bags fees list
```

**Claim fees for a specific token:**

```bash theme={null}
bags fees claim TOKEN_MINT_ADDRESS
```

**Claim all available fees across every token:**

```bash theme={null}
bags fees claim-all
```

Add `--skip-confirm` to either claim command to bypass the confirmation prompt (useful for automation).

## 5. Running the Script

Replace `TOKEN_MINT` with the token mint address you want to claim fees for, then run:

```bash theme={null}
npx ts-node claim-fees.ts
```

The script will automatically generate and send claim transactions for the specified token using your wallet.

## 6. Error Handling

Common errors you may encounter:

* **No claimable fees**: The wallet has no fees to claim for the specified token
* **Invalid token mint**: The token mint address is not a valid Solana public key
* **Insufficient SOL**: Your wallet needs SOL for transaction fees
* **Rate limiting**: Respect API rate limits between requests

Check the console output for detailed error messages.
