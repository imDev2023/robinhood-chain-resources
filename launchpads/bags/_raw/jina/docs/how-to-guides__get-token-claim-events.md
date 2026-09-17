> ## Documentation Index
> Fetch the complete documentation index at: https://docs.bags.fm/llms.txt
> Use this file to discover all available pages before exploring further.

# Get Token Claim Events

> Learn how to retrieve claim events for a token using both offset pagination and time-based filtering

In this guide, you'll learn how to retrieve claim events for a Solana token using the Bags TypeScript SDK. The endpoint supports two query modes: **offset-based pagination** for traditional page-by-page retrieval, and **time-based filtering** for fetching events within a specific time range.

## Prerequisites

Before starting, make sure you have:

* Completed our [TypeScript and Node.js Setup Guide](/how-to-guides/typescript-node-setup).
* Got your API key from the [Bags Developer Portal](https://dev.bags.fm).
* The token mint address you want to analyze.

## Endpoint Used Under the Hood

This guide uses:

* [`GET /fee-share/token/claim-events`](/api-reference/get-token-claim-events) via `sdk.state.getTokenClaimEvents()`

## Query Modes Overview

| Mode     | Use Case                         | Required Parameters            |
| -------- | -------------------------------- | ------------------------------ |
| `offset` | Paginated lists, real-time feeds | `limit`, `offset`              |
| `time`   | Historical analysis, reports     | `from`, `to` (unix timestamps) |

## 1. Offset Mode (Pagination)

Use offset mode to paginate through claim events. This is the default mode and is backward compatible with previous API versions.

### Script: Paginated Claim Events

Save this as `get-claim-events-paginated.ts`:

```typescript get-claim-events-paginated.ts theme={null}
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

async function getClaimEventsWithOffset(tokenMint: string, limit = 100, offset = 0) {
  console.log(`🔍 Fetching claim events for: ${tokenMint}`);
  console.log(`   Mode: offset | Limit: ${limit} | Offset: ${offset}\n`);

  const events = await sdk.state.getTokenClaimEvents(new PublicKey(tokenMint), {
    mode: "offset",
    limit,
    offset,
  });

  events.forEach((event, i) => {
    console.log(`Event ${i + 1}:`);
    console.log(`  Wallet: ${event.wallet}`);
    console.log(`  Amount: ${event.amount} lamports`);
    console.log(`  Creator: ${event.isCreator ? "Yes" : "No"}`);
    console.log(`  Time: ${new Date(event.timestamp).toLocaleString()}`);
    console.log(`  Signature: ${event.signature.slice(0, 20)}...`);
    console.log();
  });

  console.log(`✅ Retrieved ${events.length} claim events`);
  return events;
}

// Example: Fetch first 10 events
getClaimEventsWithOffset("CyXBDcVQuHyEDbG661Jf3iHqxyd9wNHhE2SiQdNrBAGS", 10, 0)
  .catch(console.error);
```

### Run the Script

<CodeGroup>
  ```bash npx theme={null}
  npx ts-node get-claim-events-paginated.ts
  ```

  ```bash bun theme={null}
  bun get-claim-events-paginated.ts
  ```
</CodeGroup>

## 2. Time Mode (Time-Based Filtering)

Use time mode to retrieve all claim events within a specific time range. This is useful for analytics, generating reports, or syncing historical data.

### Script: Time-Based Claim Events

Save this as `get-claim-events-by-time.ts`:

```typescript get-claim-events-by-time.ts theme={null}
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

// Helper to convert date to unix timestamp
function toUnixTimestamp(date: Date): number {
  return Math.floor(date.getTime() / 1000);
}

async function getClaimEventsByTimeRange(tokenMint: string, from: number, to: number) {
  console.log(`📅 Fetching claim events for: ${tokenMint}`);
  console.log(`   Mode: time | From: ${from} | To: ${to}\n`);

  const events = await sdk.state.getTokenClaimEvents(new PublicKey(tokenMint), {
    mode: "time",
    from,
    to,
  });

  // Calculate total claimed
  const totalLamports = events.reduce(
    (sum, e) => sum + BigInt(e.amount),
    BigInt(0)
  );
  const totalSol = Number(totalLamports) / LAMPORTS_PER_SOL;

  console.log(`📊 Summary:`);
  console.log(`   Total events: ${events.length}`);
  console.log(`   Total claimed: ${totalSol.toLocaleString()} SOL`);
  console.log(`   Unique wallets: ${new Set(events.map((e) => e.wallet)).size}`);

  // Show breakdown by day
  const byDay = new Map<string, { count: number; amount: bigint }>();
  events.forEach((event) => {
    const day = new Date(event.timestamp).toLocaleDateString();
    const existing = byDay.get(day) || { count: 0, amount: BigInt(0) };
    byDay.set(day, {
      count: existing.count + 1,
      amount: existing.amount + BigInt(event.amount),
    });
  });

  console.log(`\n📆 Daily breakdown:`);
  byDay.forEach((stats, day) => {
    const sol = Number(stats.amount) / LAMPORTS_PER_SOL;
    console.log(`   ${day}: ${stats.count} claims, ${sol.toLocaleString()} SOL`);
  });

  return events;
}

// Example: Get events from the last 7 days
async function main() {
  const tokenMint = "CyXBDcVQuHyEDbG661Jf3iHqxyd9wNHhE2SiQdNrBAGS";

  const now = new Date();
  const sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);

  const from = toUnixTimestamp(sevenDaysAgo);
  const to = toUnixTimestamp(now);

  console.log(`🗓️  Date range: ${sevenDaysAgo.toLocaleDateString()} → ${now.toLocaleDateString()}\n`);

  await getClaimEventsByTimeRange(tokenMint, from, to);
}

main().catch(console.error);
```

### Run the Script

<CodeGroup>
  ```bash npx theme={null}
  npx ts-node get-claim-events-by-time.ts
  ```

  ```bash bun theme={null}
  bun get-claim-events-by-time.ts
  ```
</CodeGroup>

## Example Output

### Offset Mode Output

```
🔍 Fetching claim events for: CyXBDcVQuHyEDbG661Jf3iHqxyd9wNHhE2SiQdNrBAGS
   Mode: offset | Limit: 10 | Offset: 0

Event 1:
  Wallet: 9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin
  Amount: 1500000000 lamports
  Creator: Yes
  Time: 1/15/2026, 3:45:00 PM
  Signature: 5KtPn1LGuxhKLHHD...

Event 2:
  Wallet: 7nYXhxpZe9VuXMBZE3TVf...
  Amount: 500000000 lamports
  Creator: No
  Time: 1/14/2026, 2:30:00 PM
  Signature: 3RtQm2JGvxhMKIFD...

✅ Retrieved 10 claim events
```

### Time Mode Output

```
🗓️  Date range: 1/9/2026 → 1/16/2026

📅 Fetching claim events for: CyXBDcVQuHyEDbG661Jf3iHqxyd9wNHhE2SiQdNrBAGS
   Mode: time | From: 1736380800 | To: 1736985600

📊 Summary:
   Total events: 47
   Total claimed: 125.5 SOL
   Unique wallets: 12

📆 Daily breakdown:
   1/15/2026: 8 claims, 22.3 SOL
   1/14/2026: 12 claims, 35.1 SOL
   1/13/2026: 7 claims, 18.7 SOL
   1/12/2026: 10 claims, 28.4 SOL
   1/11/2026: 6 claims, 12.2 SOL
   1/10/2026: 4 claims, 8.8 SOL
```

## SDK Function Reference

The `sdk.state.getTokenClaimEvents()` function accepts a token mint and an options object:

```typescript theme={null}
// Offset mode (default)
const events = await sdk.state.getTokenClaimEvents(tokenMint, {
  limit: 100,    // 1-100, default: 100
  offset: 0,     // default: 0
});

// Time mode
const events = await sdk.state.getTokenClaimEvents(tokenMint, {
  mode: "time",
  from: 1736380800,  // unix timestamp (required)
  to: 1736985600,    // unix timestamp (required, must be >= from)
});
```

### Return Type

Each event in the returned array has the following structure:

| Field       | Type      | Description                                               |
| ----------- | --------- | --------------------------------------------------------- |
| `wallet`    | `string`  | Public key of the wallet that claimed fees                |
| `isCreator` | `boolean` | Whether this wallet is the token creator                  |
| `amount`    | `string`  | Amount claimed in lamports (as string for bigint support) |
| `signature` | `string`  | Transaction signature of the claim                        |
| `timestamp` | `string`  | ISO 8601 timestamp of the claim event                     |

## Use Cases

### Offset Mode

* **Paginated UIs**: Display claim events in a table with "Load More" or page navigation
* **Real-time Feeds**: Show the latest claims as they happen
* **Infinite Scroll**: Load more events as the user scrolls

### Time Mode

* **Weekly/Monthly Reports**: Generate reports for specific time periods
* **Analytics Dashboards**: Show claim activity over custom date ranges
* **Auditing**: Review all claims that occurred during a specific period
* **Data Sync**: Sync historical claim data to your database

## Alternative: Using the Bags CLI

<Note>
  This section requires the Bags CLI. See [Install and Set Up the Bags CLI](/cli/install-and-setup) to get started.
</Note>

Query claim events and stats directly from the terminal:

**Offset-based pagination:**

```bash theme={null}
bags fees events TOKEN_MINT --offset 0 --limit 10
```

**Time-based filtering:**

```bash theme={null}
bags fees events TOKEN_MINT --start-time 2025-01-01T00:00:00Z --end-time 2025-06-01T00:00:00Z
```

**Aggregated claim stats:**

```bash theme={null}
bags fees stats TOKEN_MINT
```

Use `--json` to pipe the output into other tools for analysis:

```bash theme={null}
bags fees events TOKEN_MINT --limit 100 --json | jq '.[] | .amount'
```

## Error Handling

Common errors to handle:

| Error            | Cause                      | Solution                                     |
| ---------------- | -------------------------- | -------------------------------------------- |
| 400 Bad Request  | Invalid `tokenMint` format | Verify the mint is a valid base58 public key |
| 400 Bad Request  | `from` > `to` in time mode | Ensure `from` is less than or equal to `to`  |
| 401 Unauthorized | Missing or invalid API key | Check your API key configuration             |

<Note>
  When using time mode, the `from` timestamp must be less than or equal to `to`. The API validates this constraint and returns an error if violated.
</Note>

## Related Guides

* [Get Token Lifetime Fees](/how-to-guides/get-token-lifetime-fees) - Get total fees earned by a token
* [Get Token Creators](/how-to-guides/get-token-creators) - Find token launch creators
* [Claim Fees](/how-to-guides/claim-fees) - Claim your earned fees
