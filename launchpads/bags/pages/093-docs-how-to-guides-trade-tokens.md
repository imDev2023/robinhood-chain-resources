# Bags - Trade Tokens

> Source: https://docs.bags.fm/how-to-guides/trade-tokens
> Retrieved: 2026-09-02 (Mintlify markdown export, curl https://docs.bags.fm/how-to-guides/trade-tokens.md)

---

# Trade Tokens

> Complete guide to get trade quotes and execute token swaps using the Bags API with TypeScript and Node.js

In this guide, you'll learn how to get trade quotes and execute token swaps using the Bags TypeScript SDK with Node.js. The trade service allows you to swap tokens across various DEXs and liquidity pools on Solana.

## Prerequisites

Before starting, make sure you have:

* Completed our [TypeScript and Node.js Setup Guide](/how-to-guides/typescript-node-setup).
* Got your API key from the [Bags Developer Portal](https://dev.bags.fm).
* A Solana wallet with tokens to swap and SOL for transaction fees.
* Installed the additional dependencies for this guide:
  ```bash theme={null}
  npm install @solana/web3.js bs58
  ```

<Note>
  **Transaction Fees**: Trading tokens requires Solana transactions. Make sure your wallet has sufficient SOL balance to pay for transaction fees.
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

## 2. The Token Trading Script

Here is a complete script to get a trade quote and execute a swap. Save it as `trade-tokens.ts`.

The script follows this flow:

1. Get a trade quote
2. Review the quote details
3. Create a swap transaction
4. Sign and send the transaction

## Endpoints Used Under the Hood

This guide uses:

* [`GET /trade/quote`](/api-reference/get-trade-quote) via `sdk.trade.getQuote()`
* [`POST /trade/swap`](/api-reference/create-swap-transaction) via `sdk.trade.createSwapTransaction()`

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

async function executeSwap(
    inputMint: PublicKey,
    outputMint: PublicKey,
    amount: number,
    slippageMode: "auto" | "manual" = "auto",
    slippageBps?: number
) {
    try {
        if (!PRIVATE_KEY) {
            throw new Error("PRIVATE_KEY is not set");
        }

        const keypair = Keypair.fromSecretKey(bs58.decode(PRIVATE_KEY));
        const commitment = sdk.state.getCommitment();

        console.log(`💱 Getting trade quote...`);
        console.log(`   Input: ${inputMint.toBase58()}`);
        console.log(`   Output: ${outputMint.toBase58()}`);
        console.log(`   Amount: ${amount}`);
        console.log(`   Slippage Mode: ${slippageMode}`);

        // Step 1: Get a trade quote
        const quote = await sdk.trade.getQuote({
            inputMint: inputMint,
            outputMint: outputMint,
            amount: amount,
            slippageMode: slippageMode,
            slippageBps: slippageBps,
        });

        console.log("\n📊 Quote Details:");
        console.log(`   Request ID: ${quote.requestId}`);
        console.log(`   Input Amount: ${quote.inAmount}`);
        console.log(`   Output Amount: ${quote.outAmount}`);
        console.log(`   Min Output Amount: ${quote.minOutAmount}`);
        console.log(`   Price Impact: ${quote.priceImpactPct}%`);
        console.log(`   Slippage: ${quote.slippageBps / 100}%`);
        console.log(`   Route Plan: ${quote.routePlan.length} leg(s)`);

        // Display route plan details
        if (quote.routePlan.length > 0) {
            console.log("\n🛣️  Route Plan:");
            quote.routePlan.forEach((leg, index) => {
                console.log(`   Leg ${index + 1}:`);
                console.log(`      Venue: ${leg.venue}`);
                console.log(`      Input: ${leg.inAmount} (${leg.inputMint})`);
                console.log(`      Output: ${leg.outAmount} (${leg.outputMint})`);
            });
        }

        // Display platform fee if present
        if (quote.platformFee) {
            console.log("\n💰 Platform Fee:");
            console.log(`   Amount: ${quote.platformFee.amount}`);
            console.log(`   Fee BPS: ${quote.platformFee.feeBps}`);
            console.log(`   Fee Account: ${quote.platformFee.feeAccount}`);
        }

        // Step 2: Create swap transaction
        console.log("\n🎯 Creating swap transaction...");
        const swapResult = await sdk.trade.createSwapTransaction({
            quoteResponse: quote,
            userPublicKey: keypair.publicKey,
        });

        console.log(`   Compute Unit Limit: ${swapResult.computeUnitLimit}`);
        console.log(`   Prioritization Fee: ${swapResult.prioritizationFeeLamports} lamports`);

        // Step 3: Sign and send transaction
        console.log("\n🔑 Signing and sending swap transaction...");
        const signature = await signAndSendTransaction(connection, commitment, swapResult.transaction, keypair);

        console.log("\n🎉 Swap executed successfully!");
        console.log(`   Transaction Signature: ${signature}`);
        console.log(`   View on Solana Explorer: https://solscan.io/tx/${signature}`);

        return {
            signature,
            quote,
            swapResult,
        };
    } catch (error) {
        console.error("🚨 Swap execution failed:", error);
        throw error;
    }
}

// Example: Swap 100,000 tokens (adjust decimals based on token)
// Replace with your actual token mint addresses
const INPUT_MINT = new PublicKey("YOUR_INPUT_TOKEN_MINT_ADDRESS");
const OUTPUT_MINT = new PublicKey("YOUR_OUTPUT_TOKEN_MINT_ADDRESS");
const AMOUNT = 100_000; // Amount in token's smallest unit (e.g., if token has 6 decimals, 100000 = 0.1 tokens)

// Execute swap with auto slippage
executeSwap(INPUT_MINT, OUTPUT_MINT, AMOUNT, "auto")
    .then((result) => {
        console.log("\n✨ Swap completed successfully!");
    })
    .catch((error) => {
        console.error("🚨 Unexpected error occurred:", error);
    });

// Example: Execute swap with manual slippage (1% = 100 bps)
// executeSwap(INPUT_MINT, OUTPUT_MINT, AMOUNT, "manual", 100)
//     .then((result) => {
//         console.log("\n✨ Swap completed successfully!");
//     })
//     .catch((error) => {
//         console.error("🚨 Unexpected error occurred:", error);
//     });
```

## 3. Understanding Trade Quotes

A trade quote provides information about a potential swap before you execute it:

### Quote Parameters

* **inputMint**: The token you want to swap from (PublicKey)
* **outputMint**: The token you want to swap to (PublicKey)
* **amount**: The amount to swap (in the token's smallest unit, e.g., lamports for SOL)
* **slippageMode**: Either `"auto"` (automatic slippage calculation) or `"manual"` (you specify slippage)
* **slippageBps**: Basis points for slippage tolerance (0-10000, where 10000 = 100%). Required when `slippageMode` is `"manual"`

### Quote Response

The quote response includes:

* **inAmount**: The input amount (as string)
* **outAmount**: The expected output amount (as string)
* **minOutAmount**: The minimum output amount considering slippage
* **priceImpactPct**: The price impact percentage (as string)
* **slippageBps**: The slippage tolerance in basis points
* **routePlan**: Array of route legs showing the swap path through different venues
* **platformFee**: Optional platform fee information
* **requestId**: Unique identifier for the quote request

### Route Plan

The route plan shows how your swap will be executed across different venues (DEXs, liquidity pools, etc.). Each leg represents one step in the swap path.

## 4. Slippage Modes

### Auto Slippage

When using `slippageMode: "auto"`, the SDK automatically calculates an appropriate slippage tolerance based on market conditions. This is recommended for most use cases.

```typescript theme={null}
const quote = await sdk.trade.getQuote({
    inputMint: inputMint,
    outputMint: outputMint,
    amount: amount,
    slippageMode: "auto",
});
```

### Manual Slippage

When using `slippageMode: "manual"`, you must specify `slippageBps`. This gives you full control over slippage tolerance.

```typescript theme={null}
const quote = await sdk.trade.getQuote({
    inputMint: inputMint,
    outputMint: outputMint,
    amount: amount,
    slippageMode: "manual",
    slippageBps: 100, // 1% slippage tolerance
});
```

**Slippage BPS Examples:**

* `50` = 0.5% slippage tolerance
* `100` = 1% slippage tolerance
* `500` = 5% slippage tolerance
* `1000` = 10% slippage tolerance

## 5. Swap Transaction Details

When you create a swap transaction, you receive:

* **transaction**: A `VersionedTransaction` ready to be signed and sent
* **computeUnitLimit**: The compute unit limit for the transaction
* **lastValidBlockHeight**: The last valid block height for the transaction
* **prioritizationFeeLamports**: The prioritization fee in lamports

The transaction is already configured with compute units and prioritization fees, so you can sign and send it directly.

## 6. Running the Script

To execute a swap, edit the script with your token mint addresses and amount:

1. Set `INPUT_MINT` to the token you want to swap from
2. Set `OUTPUT_MINT` to the token you want to swap to
3. Set `AMOUNT` to the amount in the token's smallest unit (consider token decimals)

Then, run the script from your terminal:

```bash theme={null}
npx ts-node trade-tokens.ts
```

## 7. Getting a Quote Only

If you just want to check a quote without executing a swap:

```typescript theme={null}
async function getQuoteOnly(inputMint: PublicKey, outputMint: PublicKey, amount: number) {
    const quote = await sdk.trade.getQuote({
        inputMint: inputMint,
        outputMint: outputMint,
        amount: amount,
        slippageMode: "auto",
    });

    console.log(`Expected output: ${quote.outAmount}`);
    console.log(`Min output (with slippage): ${quote.minOutAmount}`);
    console.log(`Price impact: ${quote.priceImpactPct}%`);
    
    return quote;
}
```

## Alternative: Using the Bags CLI

<Note>
  This section requires the Bags CLI. See [Install and Set Up the Bags CLI](/cli/install-and-setup) to get started.
</Note>

You can get quotes and execute swaps directly from the terminal without writing any code:

**Get a quote:**

```bash theme={null}
bags trade quote \
  --input-mint So11111111111111111111111111111111 \
  --output-mint EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v \
  --amount 1000000000
```

**Execute a swap:**

```bash theme={null}
bags trade swap \
  --input-mint So11111111111111111111111111111111 \
  --output-mint EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v \
  --amount 1000000000 \
  --skip-confirm
```

**With manual slippage (1%):**

```bash theme={null}
bags trade swap \
  --input-mint INPUT_MINT \
  --output-mint OUTPUT_MINT \
  --amount 1000000000 \
  --slippage-mode manual \
  --slippage-bps 100
```

If you omit flags, the CLI prompts for each value interactively. Use `--json` to get machine-readable output for scripting.

## 8. Error Handling

The script includes comprehensive error handling for:

* **Invalid Token Mints**: Ensure the mint addresses are valid Solana public keys
* **Insufficient Liquidity**: The quote may fail if there's not enough liquidity for the swap
* **Invalid Amount**: The amount must be a positive number
* **Slippage Errors**: If using manual slippage, ensure `slippageBps` is between 0 and 10000
* **Transaction Failures**: Network issues or insufficient SOL for fees

## 9. Troubleshooting

Common issues include:

* **No Quote Available**: Check that both tokens have sufficient liquidity and are tradeable
* **High Price Impact**: Large swaps may have high price impact. Consider splitting into smaller swaps
* **Insufficient SOL**: Your wallet needs SOL for transaction fees
* **Invalid Amount**: Make sure the amount is in the token's smallest unit (not in human-readable format)

For more details, see the [API Reference](/api-reference/introduction).
