# Bags - Launch a Token

> Source: https://docs.bags.fm/how-to-guides/launch-token
> Retrieved: 2026-09-02 (Mintlify markdown export, curl https://docs.bags.fm/how-to-guides/launch-token.md)

---

# Launch a Token

> Complete step-by-step guide to launch a Solana token using the Bags API v2 with TypeScript and Node.js

In this guide, you'll learn how to launch a Solana token using the Bags TypeScript SDK with Node.js. Token Launch v2 requires fee sharing configuration, where all fees are shared with the creator's wallet by default. You can optionally share fees with additional fee claimers.

<Note>
  Want to quote your token in a non-SOL asset (xStocks, Ondo tokenized equities, and other badged mints) instead of SOL? See [Launch a Token with a Non-SOL Quote Token](/how-to-guides/launch-token-non-sol-quote).
</Note>

## Prerequisites

Before starting, make sure you have:

* Completed our [TypeScript and Node.js Setup Guide](/how-to-guides/typescript-node-setup).
* Got your API key from the [Bags Developer Portal](https://dev.bags.fm).
* A Solana wallet with some SOL for transactions.
* A token image URL (recommended) or image file.
* Installed the additional dependencies for this guide:
  ```bash theme={null}
  npm install @solana/web3.js bs58
  ```

<Note>
  **Optional**: If you want to include a partner configuration in your token launch, you'll need to create a partner key first. See the [Create Partner Key](/how-to-guides/create-partner-key) guide for details. Once you have a partner key, you can include it when launching tokens using the `partner` and `partnerConfig` parameters.
</Note>

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

## 2. The Token Launch Script

Here is the complete script for launching a token. Save it as `launch-token.ts`.

The script follows the Token Launch v2 flow:

1. Create metadata
2. Create config (fee share configuration)
3. Get token creation transaction
4. Sign transaction
5. Broadcast transaction

## Endpoints Used Under the Hood

This SDK flow calls these documented endpoints:

* [`POST /token-launch/create-token-info`](/api-reference/create-token-info) via `sdk.tokenLaunch.createTokenInfoAndMetadata()`
* [`GET /token-launch/fee-share/wallet/v2`](/api-reference/get-fee-share-wallet) via `sdk.state.getLaunchWalletV2()` for social username fee-claimer lookup
* [`POST /fee-share/config`](/api-reference/create-fee-share-configuration) via `sdk.config.createBagsFeeShareConfig()`
* [`POST /token-launch/create-launch-transaction`](/api-reference/create-token-launch-transaction) via `sdk.tokenLaunch.createLaunchTransaction()`

This guide also uses SDK Solana helper methods for Jito bundle/tip workflows. Those helper endpoints are currently undocumented in this docs set, so they are intentionally not linked here.

```typescript theme={null}
import dotenv from "dotenv";
dotenv.config({ quiet: true });

import {
    BagsSDK,
    BAGS_FEE_SHARE_V2_MAX_CLAIMERS_NON_LUT,
    waitForSlotsToPass,
    signAndSendTransaction,
    createTipTransaction,
    sendBundleAndConfirm,
} from "@bagsfm/bags-sdk";
import type { SupportedSocialProvider } from "@bagsfm/bags-sdk";
import { Keypair, LAMPORTS_PER_SOL, PublicKey, Connection, VersionedTransaction } from "@solana/web3.js";
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

const FALLBACK_JITO_TIP_LAMPORTS = 0.015 * LAMPORTS_PER_SOL;

/**
 * Create a tip transaction, sign bundle transactions, and send via Jito
 * @param unsignedTransactions - Array of unsigned VersionedTransaction instances
 * @param keypair - The keypair to sign all transactions
 * @returns The confirmed bundle ID
 */
async function sendBundleWithTip(
    unsignedTransactions: VersionedTransaction[],
    keypair: Keypair
): Promise<string> {
    const commitment = sdk.state.getCommitment();

    // Get blockhash from the first bundle transaction
    const bundleBlockhash = unsignedTransactions[0]?.message.recentBlockhash;

    if (!bundleBlockhash) {
        throw new Error("Bundle transactions must have a blockhash");
    }

    let jitoTip = FALLBACK_JITO_TIP_LAMPORTS;

    // Get recommended Jito tip
    const recommendedJitoTip = await sdk.solana.getJitoRecentFees().catch((err) => {
        console.log("⚠️ Failed to get Jito recent fees, using fallback:", err.message);
        return null;
    });
    
    // Calculate tip amount (use 95th percentile or fallback to default)
    if (recommendedJitoTip?.landed_tips_95th_percentile) {
        jitoTip = Math.floor(recommendedJitoTip.landed_tips_95th_percentile * LAMPORTS_PER_SOL);
    }
    console.log(`💰 Jito tip: ${jitoTip / LAMPORTS_PER_SOL} SOL`);

    // Create tip transaction
    const tipTransaction = await createTipTransaction(connection, commitment, keypair.publicKey, jitoTip, {
        blockhash: bundleBlockhash,
    });

    // Sign all transactions (tip first, then the rest)
    const signedTransactions = [tipTransaction, ...unsignedTransactions].map((tx) => {
        tx.sign([keypair]);
        return tx;
    });

    console.log(`📦 Sending bundle via Jito...`);

    // Send bundle and wait for confirmation
    const bundleId = await sendBundleAndConfirm(signedTransactions, sdk);

    console.log(`✅ Bundle confirmed! Bundle ID: ${bundleId}`);
    return bundleId;
}

async function getOrCreateFeeShareConfig(
    tokenMint: PublicKey,
    creatorWallet: PublicKey,
    keypair: Keypair,
    feeClaimers: Array<{ user: PublicKey; userBps: number }>,
    partner?: PublicKey, // Optional: Partner wallet address
    partnerConfig?: PublicKey // Optional: Partner config PDA (see Create Partner Key guide)
): Promise<PublicKey> {
    const commitment = sdk.state.getCommitment();

    // Check if lookup tables are needed (when there are more than MAX_CLAIMERS_NON_LUT claimers)
    let additionalLookupTables: PublicKey[] | undefined;
    
    if (feeClaimers.length > BAGS_FEE_SHARE_V2_MAX_CLAIMERS_NON_LUT) {
        console.log(`📋 Creating lookup tables for ${feeClaimers.length} fee claimers (exceeds ${BAGS_FEE_SHARE_V2_MAX_CLAIMERS_NON_LUT} limit)...`);
        
        // Get LUT creation transactions
        const lutResult = await sdk.config.getConfigCreationLookupTableTransactions({
            payer: creatorWallet,
            baseMint: tokenMint,
            feeClaimers: feeClaimers,
        });

        if (!lutResult) {
            throw new Error("Failed to create lookup table transactions");
        }

        // Execute the LUT creation transaction first
        console.log("🔧 Executing lookup table creation transaction...");
        await signAndSendTransaction(connection, commitment, lutResult.creationTransaction, keypair);

        // Wait for one slot to pass (required before extending LUT)
        console.log("⏳ Waiting for one slot to pass...");
        await waitForSlotsToPass(connection, commitment, 1);

        // Execute all extend transactions
        console.log(`🔧 Executing ${lutResult.extendTransactions.length} lookup table extend transaction(s)...`);
        for (const extendTx of lutResult.extendTransactions) {
            await signAndSendTransaction(connection, commitment, extendTx, keypair);
        }

        additionalLookupTables = lutResult.lutAddresses;
        console.log("✅ Lookup tables created successfully!");
    }

    try {
        // Try to create the config (with LUTs if needed)
        const configResult = await sdk.config.createBagsFeeShareConfig({
            payer: creatorWallet,
            baseMint: tokenMint,
            feeClaimers: feeClaimers,
            partner: partner,
            partnerConfig: partnerConfig,
            additionalLookupTables: additionalLookupTables,
        });

        console.log("🔧 Creating fee share config...");

        // Send bundle txs
        if (configResult.bundles && configResult.bundles.length > 0) {
            console.log(`📦 Sending ${configResult.bundles.length} bundle(s) via Jito...`);
            for (const bundle of configResult.bundles) {
                // Send the bundle with tip transaction and wait for confirmation
                await sendBundleWithTip(bundle, keypair);
            }
        }

        // Sign and send all returned transactions
        for (const tx of configResult.transactions || []) {
            await signAndSendTransaction(connection, commitment, tx, keypair);
        }

        console.log("✅ Fee share config created successfully!");
        return configResult.meteoraConfigKey;
    } catch (error: any) {
        console.error("🚨 Failed getting or creating fee share config:", error);
        throw error;
    }
}

async function launchToken(launchParams: {
    imageUrl: string;
    name: string;
    symbol: string;
    description: string;
    twitterUrl?: string;
    websiteUrl?: string;
    telegramUrl?: string;
    initialBuyAmountLamports: number;
    // Optional: Share fees with fee claimers
    // Each entry should have provider, username, and the percentage (bps) they receive
    feeClaimers?: Array<{
        provider: SupportedSocialProvider;
        username: string;
        bps: number; // Basis points (10000 = 100%)
    }>;
    // Optional: Partner configuration for fee sharing
    // See the Create Partner Key guide for details: /how-to-guides/create-partner-key
    partner?: PublicKey; // Partner wallet address
    partnerConfig?: PublicKey; // Partner config PDA (can be derived using deriveBagsFeeShareV2PartnerConfigPda)
}) {
    try {
        if (!PRIVATE_KEY) {
            throw new Error("PRIVATE_KEY is not set");
        }

        const keypair = Keypair.fromSecretKey(bs58.decode(PRIVATE_KEY));
        const commitment = sdk.state.getCommitment();

        console.log(`🚀 Creating token $${launchParams.symbol} with wallet ${keypair.publicKey.toBase58()}`);

        // Step 1: Create metadata
        console.log("📝 Step 1: Creating token info and metadata...");
        const tokenInfoResponse = await sdk.tokenLaunch.createTokenInfoAndMetadata({
            imageUrl: launchParams.imageUrl,
            name: launchParams.name,
            description: launchParams.description,
            symbol: launchParams.symbol?.toUpperCase()?.replace("$", ""),
            twitter: launchParams.twitterUrl,
            website: launchParams.websiteUrl,
            telegram: launchParams.telegramUrl,
        });

        console.log("✨ Successfully created token info and metadata!");
        console.log("🪙 Token mint:", tokenInfoResponse.tokenMint);

        // Step 2: Get or create fee share config
        console.log("⚙️  Step 2: Getting or creating fee share config...");

        const tokenMint = new PublicKey(tokenInfoResponse.tokenMint);
        
        // Build fee claimers array
        // IMPORTANT: Creator must always be included explicitly with their BPS set
        let feeClaimers: Array<{ user: PublicKey; userBps: number }> = [];
        
        if (launchParams.feeClaimers && launchParams.feeClaimers.length > 0) {
            // Calculate creator's share (remaining after all fee claimers)
            const feeClaimersBps = launchParams.feeClaimers.reduce((sum, fc) => sum + fc.bps, 0);
            const creatorBps = 10000 - feeClaimersBps;
            
            if (creatorBps < 0) {
                throw new Error("Total fee claimer BPS cannot exceed 10000 (100%)");
            }
            
            // Add creator first with explicit BPS (required - creator must always be explicit)
            if (creatorBps > 0) {
                feeClaimers.push({ user: keypair.publicKey, userBps: creatorBps });
                console.log(`💰 Creator will receive ${creatorBps / 100}% of fees (explicitly set)`);
            }
            
            // Add fee claimers
            for (const feeClaimer of launchParams.feeClaimers) {
                console.log(
                    `🔍 Looking up fee claimer wallet for ${feeClaimer.provider}:${feeClaimer.username}`
                );
                const feeClaimerResult = await sdk.state.getLaunchWalletV2(
                    feeClaimer.username,
                    feeClaimer.provider
                );
                feeClaimers.push({
                    user: feeClaimerResult.wallet,
                    userBps: feeClaimer.bps,
                });
                console.log(
                    `✨ Found fee claimer wallet: ${feeClaimerResult.wallet.toString()} (${feeClaimer.bps / 100}%)`
                );
            }
        } else {
            // No fee claimers - creator gets all fees (must be set explicitly to max BPS)
            console.log("💰 All fees will go to creator wallet (explicitly set to 10000 bps)");
            feeClaimers = [{ user: keypair.publicKey, userBps: 10000 }];
        }

        const configKey = await getOrCreateFeeShareConfig(
            tokenMint,
            keypair.publicKey,
            keypair,
            feeClaimers,
            launchParams.partner,
            launchParams.partnerConfig
        );

        console.log("🔑 Config Key:", configKey.toString());

        // Step 3: Get token creation transaction
        console.log("🎯 Step 3: Creating token launch transaction...");
        const tokenLaunchTransaction = await sdk.tokenLaunch.createLaunchTransaction({
            metadataUrl: tokenInfoResponse.tokenMetadata,
            tokenMint: tokenMint,
            launchWallet: keypair.publicKey,
            initialBuyLamports: launchParams.initialBuyAmountLamports,
            configKey: configKey,
        });

        // Step 4 & 5: Sign and broadcast transaction
        console.log("📡 Step 4 & 5: Signing and broadcasting transaction...");
        const signature = await signAndSendTransaction(connection, commitment, tokenLaunchTransaction, keypair);

        console.log("🎉 Token launched successfully!");
        console.log("🪙 Token Mint:", tokenInfoResponse.tokenMint);
        console.log("🔑 Launch Signature:", signature);
        console.log("📄 Metadata URI:", tokenInfoResponse.tokenMetadata);
        console.log(`🌐 View your token at: https://bags.fm/${tokenInfoResponse.tokenMint}`);
    } catch (error) {
        console.error("🚨 Token launch failed:", error);
        throw error;
    }
}

// Example: Launch token with shared fees among multiple users
// (40% creator, 30% fee claimer 1, 30% fee claimer 2)
launchToken({
    imageUrl: "https://img.freepik.com/premium-vector/white-abstract-vactor-background-design_665257-153.jpg",
    name: "Multi-Share Token",
    symbol: "MST",
    description: "This token shares fees with multiple fee claimers",
    twitterUrl: "https://x.com/multisharetoken",
    websiteUrl: "https://multisharetoken.com",
    initialBuyAmountLamports: 0.01 * LAMPORTS_PER_SOL,
    feeClaimers: [
        {
            provider: "twitter",
            username: "feeclaimer1",
            bps: 3000, // 30% to first fee claimer
        },
        {
            provider: "twitter",
            username: "feeclaimer2",
            bps: 3000, // 30% to second fee claimer
        },
        // Creator automatically gets remaining 40%
    ],
});

// Example: Launch token without sharing fees (all fees go to creator)
// launchToken({
//     imageUrl: "https://img.freepik.com/premium-vector/white-abstract-vactor-background-design_665257-153.jpg",
//     name: "My Token",
//     symbol: "MTK",
//     description: "This is my token description",
//     twitterUrl: "https://x.com/mytoken",
//     websiteUrl: "https://mytoken.com",
//     initialBuyAmountLamports: 0.01 * LAMPORTS_PER_SOL, // 0.01 SOL
// });
```

## 3. Understanding Fee Sharing

Token Launch v2 requires fee sharing configuration with explicit BPS (basis points) allocation. **Important rules:**

### Key Rules

1. **Creators must always explicitly set their BPS**: To receive all fees, creators must give themselves the maximum BPS (10000) explicitly, no matter what. Creator fees must always be set explicitly in the fee claimers array.

2. **When sharing fees**: Give fee claimers their BPS and then **explicitly also give the creator their BPS**. Both the creator and all fee claimers must have their BPS values set explicitly in the configuration.

3. **Total BPS must equal 10000**: The sum of all BPS values (creator + all fee claimers) must equal exactly 10,000 (100%).

4. **Maximum fee earners**: You can have up to 100 fee earners (including the creator) per token launch.

5. **Supported platforms**: Fee claimers can be identified using supported social platforms: `twitter`, `kick`, and `github`.

6. **Lookup Tables (LUTs)**: When you have more than 15 fee claimers, you need to create lookup tables before creating the fee share config. The script automatically handles this by:
   * Calling `getConfigCreationLookupTableTransactions()` to get LUT creation transactions
   * Executing the LUT creation transaction
   * Waiting for one slot to pass (required by Solana)
   * Executing all LUT extend transactions
   * Passing the LUT addresses to `createBagsFeeShareConfig` via `additionalLookupTables`

### Partner Configuration

You can include a partner configuration in your fee share setup by providing:

* `partner`: The partner wallet address (PublicKey)
* `partnerConfig`: The partner config PDA (PublicKey) - can be derived using the helper function shown in the examples

Partners receive a share of fees from token launches that include their partner configuration. This is useful for platforms or partnerships that want to collect fees from multiple token launches.

<Note>
  To create a partner key, see the [Create Partner Key](/how-to-guides/create-partner-key) guide.
</Note>

## Alternative: Using the Bags CLI

<Note>
  This section requires the Bags CLI. See [Install and Set Up the Bags CLI](/cli/install-and-setup) to get started.
</Note>

The CLI wraps the entire multi-step launch flow (metadata upload, fee share config, lookup tables, Jito bundles, and launch transaction) into a single command:

**Launch with all fees to creator:**

```bash theme={null}
bags launch create \
  --name "My Token" \
  --symbol "MTK" \
  --description "A great token" \
  --image-url "https://example.com/image.png" \
  --initial-buy 10000000 \
  --skip-confirm
```

**Launch with fee sharing:**

```bash theme={null}
bags launch create \
  --name "My Token" \
  --symbol "MTK" \
  --description "A great token" \
  --image-url "https://example.com/image.png" \
  --initial-buy 10000000 \
  --fee-claimers '[{"provider":"twitter","username":"ramyobags","bps":3000},{"provider":"twitter","username":"bob","bps":2000}]' \
  --skip-confirm
```

The creator automatically receives the remaining BPS (in the example above, 50%).

**Launch with a partner:**

```bash theme={null}
bags launch create \
  --name "My Token" \
  --symbol "MTK" \
  --description "A great token" \
  --image-url "https://example.com/image.png" \
  --initial-buy 10000000 \
  --partner PARTNER_WALLET_PUBKEY \
  --partner-config PARTNER_CONFIG_PDA \
  --skip-confirm
```

If you omit the flags, the CLI guides you through an interactive wizard that lets you add fee claimers one at a time (by social username or wallet address) and set their BPS allocation.

## 4. Run Your Script

To launch your token, edit the `launchToken` function call at the bottom of `launch-token.ts` with your token's details, especially the `imageUrl`.

Then, run the script from your terminal:

```bash theme={null}
npx ts-node launch-token.ts
```

## 5. Troubleshooting

The script includes comprehensive error handling. Common issues include:

* **API Key Issues**: Ensure your API key is valid.
* **Private Key Format**: Your private key must be base58 encoded.
* **Insufficient SOL**: Your wallet needs SOL for transaction fees.
* **Image URL**: The URL to your token image must be accessible and valid.
* **Invalid Fee Claimer**: Ensure the fee claimer provider and username are valid and the user has a registered wallet.

For more details, see the [API Reference](/api-reference/introduction).
