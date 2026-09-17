# Bags - Get Token Lifetime Fees

> Source: https://docs.bags.fm/how-to-guides/get-token-lifetime-fees
> Retrieved: 2026-09-02 (Mintlify markdown export, curl https://docs.bags.fm/how-to-guides/get-token-lifetime-fees.md)

---

# Get Token Lifetime Fees

> Learn how to retrieve the total lifetime fees earned by a Solana token using the Bags API with TypeScript and Node.js

In this guide, you'll learn how to retrieve the total lifetime fees earned by a Solana token using the Bags TypeScript SDK with Node.js. This is useful for tracking token performance and earnings over time.

## Prerequisites

Before starting, make sure you have:

* Completed our [TypeScript and Node.js Setup Guide](/how-to-guides/typescript-node-setup).
* Got your API key from the [Bags Developer Portal](https://dev.bags.fm).
* The token mint address you want to analyze.

## 1. The Token Lifetime Fees Script

Here is a simple script to fetch token lifetime fees. Save this as `get-token-lifetime-fees.ts`.

This script uses the updated SDK API to retrieve lifetime fees for any token and displays them in a user-friendly format.

## Endpoint Used Under the Hood

This guide uses:

* [`GET /token-launch/lifetime-fees`](/api-reference/get-token-lifetime-fees) via `sdk.state.getTokenLifetimeFees()`

```typescript theme={null}
import dotenv from "dotenv";
dotenv.config({ quiet: true });

import { BagsSDK } from "@bagsfm/bags-sdk";
import { LAMPORTS_PER_SOL, PublicKey, Connection } from "@solana/web3.js";

// Initialize SDK
const BAGS_API_KEY = process.env.BAGS_API_KEY;
const SOLANA_RPC_URL = process.env.SOLANA_RPC_URL;

if (!BAGS_API_KEY || !SOLANA_RPC_URL) {
    throw new Error("BAGS_API_KEY and SOLANA_RPC_URL are required");
}

const connection = new Connection(SOLANA_RPC_URL);
const sdk = new BagsSDK(BAGS_API_KEY, connection, "processed");

async function getTokenLifetimeFees(tokenMint: string) {
    const feesLamports = await sdk.state.getTokenLifetimeFees(new PublicKey(tokenMint));

    console.log("💰 Token lifetime fees:", (feesLamports / LAMPORTS_PER_SOL).toLocaleString(), "SOL");
}

getTokenLifetimeFees("CyXBDcVQuHyEDbG661Jf3iHqxyd9wNHhE2SiQdNrBAGS");
```

## 2. Run Your Script

To analyze a token's lifetime fees, edit the `getTokenLifetimeFees` function call at the bottom of the script with the actual mint address you want to analyze.

Then, run the script from your terminal:

```bash theme={null}
npx ts-node get-token-lifetime-fees.ts
```

## What You'll See

The script will output the total lifetime fees earned by the token in SOL, formatted with proper number localization for easy reading.

Example output:

```
💰 Token lifetime fees: 1,234.567890 SOL
```

## Alternative: Using the Bags CLI

<Note>
  This section requires the Bags CLI. See [Install and Set Up the Bags CLI](/cli/install-and-setup) to get started.
</Note>

Get lifetime fees for a token directly from the terminal:

```bash theme={null}
bags fees lifetime TOKEN_MINT_ADDRESS
```

To display the result in raw lamports instead of SOL:

```bash theme={null}
bags fees lifetime TOKEN_MINT_ADDRESS --raw
```

## Use Cases

This information is valuable for:

* **Token Performance Analysis**: Track how much revenue a token has generated
* **Investment Research**: Evaluate token success based on fee generation
* **Portfolio Management**: Monitor earnings from tokens you've created or invested in
* **Market Analysis**: Compare performance across different tokens

For more advanced token analytics, check out our [Get Token Creators](/how-to-guides/get-token-creators) guide.
