> ## Documentation Index
> Fetch the complete documentation index at: https://docs.bags.fm/llms.txt
> Use this file to discover all available pages before exploring further.

# Claim Partner Fees

> Complete guide to claim fees from partner configurations using the Bags Dev Dashboard or SDK

In this guide, you'll learn how to check and claim fees from your partner configuration. Partner fees are accumulated from token launches that include your partner configuration. You can claim partner fees using either the Bags Dev Dashboard or the TypeScript SDK.

<Note>
  **Transaction Fees**: Partners pay transaction fees for all source claim steps, and the SOL you’re claiming is only received in the final vault-withdraw transaction. Keep enough SOL up front so every claim transaction can succeed and you collect the funds on that last step.
</Note>

## Method 1: Using the Dev Dashboard

The easiest way to check and claim partner fees is through the Bags Developer Dashboard.

### Step 1: Access the Dashboard

1. Go to [https://dev.bags.fm](https://dev.bags.fm) and log in with your account.

### Step 2: View Claim Stats

1. Navigate to the **Partner Key** table in the dashboard.
2. View your unclaimed fees in the table. The table displays:
   * Your partner config key
   * Claimed fees
   * Unclaimed fees

<img src="https://mintcdn.com/bags/mvj8398Gg1leSEoR/images/claim-partner-fees.png?fit=max&auto=format&n=mvj8398Gg1leSEoR&q=85&s=52ee9db647f51077150c43d5d7226016" alt="Partner Key Table with Stats" width="2010" height="600" data-path="images/claim-partner-fees.png" />

### Step 3: Claim Fees

1. If you have unclaimed fees, click the **"Claim"** button next to your partner key in the table.
2. Confirm the transaction in your connected wallet.
3. Your fees will be claimed and transferred to your wallet.

<Note>
  Make sure your wallet has sufficient SOL balance to pay for the transaction fees.
</Note>

## Method 2: Using the SDK

You can also check and claim partner fees programmatically using the Bags TypeScript SDK.

### Prerequisites

Before starting, make sure you have:

* Completed our [TypeScript and Node.js Setup Guide](/how-to-guides/typescript-node-setup).
* Got your API key from the [Bags Developer Portal](https://dev.bags.fm).
* A Solana wallet with a partner configuration (see [Create Partner Key](/how-to-guides/create-partner-key) guide).
* Installed the additional dependencies for this guide:
  ```bash theme={null}
  npm install @solana/web3.js bs58
  ```

### 1. Set Up Environment Variables

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

### 2. The Partner Fee Claiming Script

Here is a comprehensive script to check partner fee stats and claim fees. You can save this as `claim-partner-fees.ts`.

This script uses the Bags SDK's `partner` service to check claimable fees and generate claim transactions.
The SDK returns claim transactions where **the last transaction must be executed last** because it withdraws funds from the user vault. All preceding transactions fund that vault and could be processed in parallel before the final one, but this guide executes them sequentially for simplicity.

### Endpoints Used Under the Hood

This SDK flow calls these API endpoints:

* [`GET /fee-share/partner-config/stats`](/api-reference/get-partner-stats) via `sdk.partner.getPartnerConfigClaimStats()`
* [`POST /fee-share/partner-config/claim-tx`](/api-reference/get-partner-claim-transactions) via `sdk.partner.getPartnerConfigClaimTransactions()`

`sdk.partner.getPartnerConfig()` is an on-chain account read (PDA fetch), not a Bags HTTP API endpoint.

```typescript theme={null}
import dotenv from "dotenv";
dotenv.config({ quiet: true });

import { BagsSDK, signAndSendTransaction } from "@bagsfm/bags-sdk";
import { Keypair, PublicKey, Connection } from "@solana/web3.js";
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

async function claimPartnerFees(partnerWallet: PublicKey) {
    try {
        if (!PRIVATE_KEY) {
            throw new Error("PRIVATE_KEY is not set");
        }

        const keypair = Keypair.fromSecretKey(bs58.decode(PRIVATE_KEY));

        console.log(`💰 Checking partner fees for wallet: ${partnerWallet.toBase58()}`);

        // Check if partner config exists
        try {
            const partnerConfig = await sdk.partner.getPartnerConfig(partnerWallet);
            console.log("✅ Partner config found!");
            console.log(`   Partner: ${partnerConfig.partner.toBase58()}`);
            console.log(`   BPS: ${partnerConfig.bps}`);
            console.log(`   Total Claimed Fees: ${partnerConfig.totalClaimedFees.toString()}`);
            console.log(`   Total Accumulated Fees: ${partnerConfig.totalAccumulatedFees.toString()}`);
        } catch (error: any) {
            if (error.message?.includes("not found")) {
                console.error("❌ Partner config not found. Please create a partner key first.");
                console.log("   See the [Create Partner Key](/how-to-guides/create-partner-key) guide.");
                return;
            }
            throw error;
        }

        // Get partner claim stats
        console.log("\n📊 Fetching partner claim stats...");
        const stats = await sdk.partner.getPartnerConfigClaimStats(partnerWallet);

        const claimedFees = BigInt(stats.claimedFees);
        const unclaimedFees = BigInt(stats.unclaimedFees);

        console.log(`💰 Claimed Fees: ${claimedFees.toString()} lamports`);
        console.log(`💰 Unclaimed Fees: ${unclaimedFees.toString()} lamports`);

        if (unclaimedFees === 0n) {
            console.log("\n✨ No unclaimed fees available to claim.");
            return;
        }

        const unclaimedFeesSOL = Number(unclaimedFees) / 1_000_000_000; // Convert lamports to SOL
        console.log(`💵 Unclaimed Fees: ${unclaimedFeesSOL.toFixed(9)} SOL`);

        // Get claim transactions
        console.log("\n🎯 Generating claim transactions...");
        const claimTransactions = await sdk.partner.getPartnerConfigClaimTransactions(partnerWallet);

        if (!claimTransactions || claimTransactions.length === 0) {
            console.log("⚠️  No claim transactions available.");
            return;
        }

        console.log(`✨ Generated ${claimTransactions.length} claim transaction(s)`);

        // Sign and send transactions
        // The SDK guarantees the last transaction withdraws from the vault.
        // All preceding transactions fund that vault and could run in parallel,
        // but we send them sequentially here for clarity and to ensure order.
        const commitment = sdk.state.getCommitment();
        console.log("\n🔑 Signing and sending transactions sequentially (you can parallelize pre-vault txs if desired)...");

        for (let i = 0; i < claimTransactions.length; i++) {
            const { transaction, blockhash } = claimTransactions[i];
            const isFinal = i === claimTransactions.length - 1;
            const label = isFinal ? "vault withdraw" : "pre-vault";

            console.log(`\n📝 Processing transaction ${i + 1}/${claimTransactions.length} (${label})...`);
            const signature = await signAndSendTransaction(connection, commitment, transaction, keypair, blockhash);
            console.log(`✅ ${label} transaction sent: ${signature}`);
        }

        console.log("\n🎉 Partner fee claiming completed successfully!");

        // Get updated stats
        const updatedStats = await sdk.partner.getPartnerConfigClaimStats(partnerWallet);
        const newUnclaimedFees = BigInt(updatedStats.unclaimedFees);
        const newUnclaimedFeesSOL = Number(newUnclaimedFees) / 1_000_000_000;

        console.log(`\n📊 Updated Stats:`);
        console.log(`   Unclaimed Fees: ${newUnclaimedFeesSOL.toFixed(9)} SOL`);
    } catch (error) {
        console.error("🚨 Partner fee claiming failed:", error);
        throw error;
    }
}

// Example: Claim partner fees for a specific wallet
// Replace with your partner wallet address
const partnerWallet = new PublicKey("YOUR_PARTNER_WALLET_ADDRESS_HERE");

claimPartnerFees(partnerWallet)
    .then(() => {
        console.log("\n✨ Process completed!");
    })
    .catch((error) => {
        console.error("🚨 Unexpected error occurred:", error);
    });
```

### 3. Understanding Partner Fees

Partner fees are accumulated when token launches include your partner configuration. Here's how it works:

### Partner Fee Accumulation

* **Token Launches**: When tokens are launched with your partner config, fees from trading are automatically accumulated in your partner configuration
* **Fee Share**: The percentage you receive is determined by the partner configuration's BPS (basis points) setting
* **Automatic Tracking**: The SDK tracks all accumulated fees across all token launches that include your partner config

### Claiming Process

1. **Check Stats**: Use `getPartnerConfigClaimStats()` to see how much you can claim
2. **Get Transactions**: Use `getPartnerConfigClaimTransactions()` to generate claim transactions
3. **Sign & Send**: Sign and broadcast the transactions to claim your fees

### Fee Types

* **Claimed Fees**: Fees you've already claimed and received
* **Unclaimed Fees**: Fees that are available to claim but haven't been claimed yet

### 4. Running the Script

To check and claim partner fees, edit the `partnerWallet` variable in `claim-partner-fees.ts` with your partner wallet address.

Then, run the script from your terminal:

```bash theme={null}
npx ts-node claim-partner-fees.ts
```

The script will:

1. Check if your partner config exists
2. Display your partner configuration details
3. Show your claimable fee stats
4. Generate and send claim transactions if fees are available
5. Display updated stats after claiming

### Alternative: Using the Bags CLI

<Note>
  This section requires the Bags CLI. See [Install and Set Up the Bags CLI](/cli/install-and-setup) to get started.
</Note>

Claim partner fees from the terminal without writing scripts:

```bash theme={null}
bags partner claim
```

Add `--skip-confirm` to bypass the confirmation prompt:

```bash theme={null}
bags partner claim --skip-confirm
```

To check your partner stats before claiming:

```bash theme={null}
bags partner stats --partner YOUR_PARTNER_WALLET_PUBKEY
```

### 5. Checking Stats Only

If you just want to check your partner fee stats without claiming, you can use this simplified version:

```typescript theme={null}
async function checkPartnerStats(partnerWallet: PublicKey) {
    const stats = await sdk.partner.getPartnerConfigClaimStats(partnerWallet);
    
    const claimedFees = BigInt(stats.claimedFees);
    const unclaimedFees = BigInt(stats.unclaimedFees);
    
    const claimedFeesSOL = Number(claimedFees) / 1_000_000_000;
    const unclaimedFeesSOL = Number(unclaimedFees) / 1_000_000_000;
    
    console.log(`💰 Claimed Fees: ${claimedFeesSOL.toFixed(9)} SOL`);
    console.log(`💰 Unclaimed Fees: ${unclaimedFeesSOL.toFixed(9)} SOL`);
}
```

### 6. Troubleshooting

Common issues include:

* **Partner Config Not Found**: Ensure you've created a partner key first using the [Create Partner Key](/how-to-guides/create-partner-key) guide
* **No Unclaimed Fees**: If unclaimed fees are 0, there are no fees available to claim at this time
* **Insufficient SOL**: Your wallet needs SOL for transaction fees
* **Invalid Wallet Address**: Ensure the partner wallet address is a valid Solana public key
* **Transaction Failures**: Check that your wallet has sufficient SOL for transaction fees

### 7. Related Guides

* [Create Partner Key](/how-to-guides/create-partner-key) - Learn how to create a partner configuration
* [Launch a Token](/how-to-guides/launch-token) - Learn how to include partner configs in token launches
* [Claim Token Fees](/how-to-guides/claim-fees) - Learn how to claim token fees

For more details, see the [API Reference](/api-reference/introduction).
