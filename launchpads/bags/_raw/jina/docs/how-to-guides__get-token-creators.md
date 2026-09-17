> ## Documentation Index
> Fetch the complete documentation index at: https://docs.bags.fm/llms.txt
> Use this file to discover all available pages before exploring further.

# Get Token Creators

> Learn how to retrieve token launch creators/deployers with provider details using the Bags TypeScript SDK and Node.js

In this guide, you'll learn how to retrieve token launch creators/deployers using the Bags TypeScript SDK with Node.js. This includes provider, display name, wallet address, royalty percentage, and profile image.

## Prerequisites

Before starting, make sure you have:

* Completed our [TypeScript and Node.js Setup Guide](/how-to-guides/typescript-node-setup).
* Got your API key from the [Bags Developer Portal](https://dev.bags.fm).
* The token mint address you want to analyze.

## 1. The Token Creators Script

Here is a comprehensive script to fetch token creator information. Save this as `get-token-creators.ts`.

This script retrieves detailed information about the primary creator and any additional launch participants, including provider, display name, wallet, profile picture, and royalty percentage.

## Endpoint Used Under the Hood

This guide uses:

* [`GET /token-launch/creator/v3`](/api-reference/get-token-launch-creators) via `sdk.state.getTokenCreators()`

```typescript theme={null}
import dotenv from "dotenv";
dotenv.config({ quiet: true });

import { BagsSDK } from "@bagsfm/bags-sdk";
import { PublicKey, Connection } from "@solana/web3.js";

// Initialize SDK
const BAGS_API_KEY = process.env.BAGS_API_KEY;
const SOLANA_RPC_URL = process.env.SOLANA_RPC_URL;

if (!BAGS_API_KEY || !SOLANA_RPC_URL) {
    throw new Error("BAGS_API_KEY and SOLANA_RPC_URL are required");
}

const connection = new Connection(SOLANA_RPC_URL);
const sdk = new BagsSDK(BAGS_API_KEY, connection, "processed");

async function getTokenCreators(tokenMint: string) {
    try {
        console.log(`🔍 Fetching token creators for: ${tokenMint}`);
        
        const creators = await sdk.state.getTokenCreators(new PublicKey(tokenMint));
        
        console.log(`📊 Found ${creators.length} creator(s)/deployer(s)`);

        const primaryCreator = creators.find(c => c.isCreator);

        if (!primaryCreator) {
            throw new Error("❌ No primary creator found for this token!");
        }

        console.log("✨ Primary Creator Details:");
        console.log(`👤 Display Name: ${primaryCreator.providerUsername ?? primaryCreator.username ?? "N/A"}`);
        console.log(`🔗 Provider: ${primaryCreator.provider ?? "unknown"}`);
        console.log(`👛 Wallet: ${primaryCreator.wallet}`);
        console.log(`🎨 Profile Picture: ${primaryCreator.pfp}`);
        console.log(`💰 Royalty: ${primaryCreator.royaltyBps / 100}%`);

        const others = creators.filter(c => !c.isCreator);
        if (others.length > 0) {
            console.log("\n🤝 Other Launch Participants:");
            others.forEach((participant, idx) => {
                console.log(`\n#${idx + 1}`);
                console.log(`👤 Display Name: ${participant.providerUsername ?? participant.username ?? "N/A"}`);
                console.log(`🔗 Provider: ${participant.provider ?? "unknown"}`);
                console.log(`👛 Wallet: ${participant.wallet}`);
                console.log(`🎨 Profile Picture: ${participant.pfp}`);
                console.log(`💰 Royalty: ${participant.royaltyBps / 100}%`);
            });
        } else {
            console.log("\n📝 No additional launch participants found for this token");
        }

        console.log("\n✅ Successfully retrieved token creators!");
    }
    catch (error) {
        console.error("🚨 Error fetching token creators:", error);
    }
}

getTokenCreators("CyXBDcVQuHyEDbG661Jf3iHqxyd9wNHhE2SiQdNrBAGS");
```

## 2. Run Your Script

To analyze a token's creators, edit the `getTokenCreators` function call at the bottom of the script with the actual mint address you want to analyze.

Then, run the script from your terminal:

```bash theme={null}
npx ts-node get-token-creators.ts
```

## What You'll See

The script will output detailed information about the token's launch creators/deployers:

Example output:

```
🔍 Fetching token creators for: CyXBDcVQuHyEDbG661Jf3iHqxyd9wNHhE2SiQdNrBAGS
📊 Found 2 creator(s)/deployer(s)
✨ Primary Creator Details:
👤 Display Name: tokenCreatorOnTwitter
🔗 Provider: twitter
👛 Wallet: 8xX...abc
🎨 Profile Picture: https://example.com/pfp.jpg
💰 Royalty: 5%

🤝 Other Launch Participants:
#1
👤 Display Name: feeShareUser
🔗 Provider: github
👛 Wallet: 3yz...def
🎨 Profile Picture: https://example.com/pfp2.jpg
💰 Royalty: 2%

✅ Successfully retrieved token creators!
```

## Understanding the Data

* **isCreator**: Identifies the primary token creator. There can be multiple creators/deployers, but at most one will have `isCreator: true`.
* **provider**: The social/login provider associated with the creator (e.g., `twitter`, `tiktok`, `kick`, `github`). Use this to show a platform logo. May be `unknown` or `null`.
* **providerUsername**: The username on the provider platform, when available. Prefer this for display. The plain `username` is a Bags internal username and may be absent.
* **wallet**: The creator's wallet address.
* **pfp**: URL to the profile image, when available.
* **royaltyBps**: Royalty in basis points. Divide by 100 to display as a percentage.
* **twitterUsername** *(optional)*: The creator's Twitter/X username, if available.
* **bagsUsername** *(optional)*: The creator's Bags platform username, if available.
* **isAdmin** *(optional)*: Whether this user is an admin of the token.

### Key Information Retrieved:

* **Display Name**: `providerUsername` if present, otherwise `username`
* **Provider**: Source platform for displaying logos and context
* **Wallet**: Wallet address string
* **Profile Picture**: URL string
* **Royalty**: Percentage derived from `royaltyBps / 100`

## Alternative: Using the Bags CLI

<Note>
  This section requires the Bags CLI. See [Install and Set Up the Bags CLI](/cli/install-and-setup) to get started.
</Note>

Get token creators directly from the terminal:

```bash theme={null}
bags launch creators --mint TOKEN_MINT_ADDRESS
```

Use `--json` for machine-readable output:

```bash theme={null}
bags launch creators --mint TOKEN_MINT_ADDRESS --json
```

## Use Cases

This information is valuable for:

* **Due Diligence**: Research token creators before investing
* **Creator Discovery**: Find and follow successful token creators
* **Fee Analysis**: Understand how token fees are distributed
* **Partnership Opportunities**: Identify potential collaborators
* **Portfolio Research**: Learn about the teams behind your investments

For token performance metrics, also check out our [Get Token Lifetime Fees](/how-to-guides/get-token-lifetime-fees) guide.
