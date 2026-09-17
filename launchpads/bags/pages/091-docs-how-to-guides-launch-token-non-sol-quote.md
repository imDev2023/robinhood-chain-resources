# Bags - Launch a Token with a Non-SOL Quote Token

> Source: https://docs.bags.fm/how-to-guides/launch-token-non-sol-quote
> Retrieved: 2026-09-02 (Mintlify markdown export, curl https://docs.bags.fm/how-to-guides/launch-token-non-sol-quote.md)

---

# Launch a Token with a Non-SOL Quote Token

> Launch a Solana token directly into a Meteora DAMM v2 pool quoted in a non-SOL token (xStocks, Ondo tokenized equities, and other badged mints) using the Bags TypeScript SDK.

Most Bags launches are quoted in SOL and start on a DBC bonding curve that later graduates to a DAMM v2 pool. A **non-SOL quote launch** is different: the token is created straight into a single-sided Meteora DAMM v2 pool quoted in a badged non-SOL mint (for example an xStock or an Ondo tokenized equity). There is no bonding curve and no migration step.

## How it differs from a standard launch

* **No DBC bonding curve and no migration.** The pool exists and is fully seeded the moment the launch transaction lands.
* **No fee share config key.** You do not call the fee share config endpoint. Fee routing is handled by the launch itself (fee-share position custody).
* **Fees are collected in the quote token, not SOL.** A flat 2% base fee accrues in the pool's quote mint. All amounts (initial buy, claimable fees, vault balances) are denominated in that quote mint's base units.
* **Liquidity is permanently locked.** The launch creates two positions (50% / 50%) that are permanently locked and deposited into fee-share position custody. The creator claims accrued fees, not liquidity.

<Note>
  Standard SOL-quoted launches are covered in [Launch a Token](/how-to-guides/launch-token). This guide is only for launching directly into a DAMM v2 pool with a non-SOL quote token.
</Note>

## Prerequisites

Before starting, make sure you have:

* Completed our [TypeScript and Node.js Setup Guide](/how-to-guides/typescript-node-setup).
* Got your API key from the [Bags Developer Portal](https://dev.bags.fm).
* A Solana wallet with some SOL for transaction fees and rent.
* If you want to perform an initial buy at launch, a balance of the **quote token** in your wallet (the initial buy is spent in the quote token, not SOL).
* A token image URL (recommended) or image file.
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

## 2. Pick a Quote Token

Non-SOL launches must use a supported (badged) quote mint. Fetch the current list and pick one. Each entry includes the mint, its owning token program, decimals, and metadata.

```typescript theme={null}
const quoteTokens = await sdk.tokenLaunch.getDammV2SupportedQuoteTokens();

for (const token of quoteTokens) {
    console.log(`${token.symbol ?? "(no symbol)"} — ${token.mint} (${token.decimals} decimals)`);
}
```

<Warning>
  Quote mint decimals vary per token (for example, xStocks use 8 decimals and Ondo mints use 9). The `initialBuyQuoteAmount` you pass later is in the quote mint's **base units**, so always use the `decimals` value returned here to convert from a human amount.
</Warning>

## 3. The Launch Script

Here is the complete script. Save it as `launch-token-non-sol-quote.ts`.

The flow is:

1. Pick a supported quote token
2. Create metadata (`createTokenInfoAndMetadata`)
3. Build the launch transaction bundle (`createDammV2LaunchTransaction`)
4. Sign and submit the bundle in order

## Endpoints Used Under the Hood

This SDK flow calls these documented endpoints:

* [`GET /token-launch/damm-v2/supported-quote-tokens`](/api-reference/get-damm-v2-supported-quote-tokens) via `sdk.tokenLaunch.getDammV2SupportedQuoteTokens()`
* [`POST /token-launch/create-token-info`](/api-reference/create-token-info) via `sdk.tokenLaunch.createTokenInfoAndMetadata()`
* [`POST /token-launch/damm-v2/create-transaction`](/api-reference/create-damm-v2-launch-transaction) via `sdk.tokenLaunch.createDammV2LaunchTransaction()`
* [`GET /token-launch/damm-v2/launches`](/api-reference/get-damm-v2-launches) via `sdk.tokenLaunch.getDammV2Launches()`

```typescript theme={null}
// launch-token-non-sol-quote.ts
import dotenv from "dotenv";
dotenv.config({ quiet: true });

import { BagsSDK, signAndSendTransaction } from "@bagsfm/bags-sdk";
import { Keypair, Connection, PublicKey, VersionedTransaction } from "@solana/web3.js";
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

// The launch bundle is returned as ordered, base58-encoded transactions with a `type`
// label. LUT_SETUP, CREATE_TOKEN, and LAUNCH complete the launch; LUT_DEACTIVATE and
// LUT_CLOSE are optional cleanup that reclaim the lookup-table rent afterwards.
const CORE_LAUNCH_STEPS = ["LUT_SETUP", "CREATE_TOKEN", "LAUNCH"] as const;

async function launchToken(launchParams: {
    imageUrl: string;
    name: string;
    symbol: string;
    description: string;
    quoteMint: string;          // From getDammV2SupportedQuoteTokens()
    twitterUrl?: string;
    websiteUrl?: string;
    telegramUrl?: string;
    // Optional: initial buy amount, in the quote mint's BASE UNITS (not SOL, not whole tokens)
    initialBuyQuoteAmount?: number;
    // Optional: wallet that receives the creator fee position (defaults to the launch wallet)
    feeClaimerWallet?: PublicKey;
    // Optional: an existing partner config wallet to attach to the custody
    partner?: PublicKey;
}) {
    if (!PRIVATE_KEY) {
        throw new Error("PRIVATE_KEY is not set");
    }

    const keypair = Keypair.fromSecretKey(bs58.decode(PRIVATE_KEY));
    const commitment = sdk.state.getCommitment();

    console.log(`🚀 Launching $${launchParams.symbol} with wallet ${keypair.publicKey.toBase58()}`);

    // Step 1: Create metadata
    console.log("📝 Step 1: Creating token info and metadata...");
    const tokenInfo = await sdk.tokenLaunch.createTokenInfoAndMetadata({
        imageUrl: launchParams.imageUrl,
        name: launchParams.name,
        description: launchParams.description,
        symbol: launchParams.symbol?.toUpperCase()?.replace("$", ""),
        twitter: launchParams.twitterUrl,
        website: launchParams.websiteUrl,
        telegram: launchParams.telegramUrl,
    });

    console.log("🪙 Token mint:", tokenInfo.tokenMint);

    // Step 2: Build the DAMM v2 direct launch bundle
    console.log("🎯 Step 2: Building the launch transaction bundle...");
    const { transactions, launch } = await sdk.tokenLaunch.createDammV2LaunchTransaction({
        metadataUrl: tokenInfo.tokenMetadata,
        tokenMint: new PublicKey(tokenInfo.tokenMint),
        wallet: keypair.publicKey,
        quoteMint: new PublicKey(launchParams.quoteMint),
        feeClaimerWallet: launchParams.feeClaimerWallet,
        initialBuyQuoteAmount: launchParams.initialBuyQuoteAmount,
        partner: launchParams.partner,
    });

    console.log("🏊 Pool:", launch.pool);
    console.log("💵 Launch price (quote per token):", launch.launchPriceQuotePerToken);
    console.log("📊 Implied launch FDV (USD):", launch.impliedLaunchFdvUsd);

    // Step 3: Sign and submit the bundle IN ORDER.
    // Each item is a base58-encoded transaction already partially signed by the server;
    // your wallet co-signs. Submit LUT_SETUP, then CREATE_TOKEN, then LAUNCH.
    console.log("📡 Step 3: Signing and submitting the launch bundle...");
    for (const step of CORE_LAUNCH_STEPS) {
        const item = transactions.find((tx) => tx.type === step);
        if (!item) continue; // CREATE_TOKEN is skipped on rebuilds where the mint already landed

        const transaction = VersionedTransaction.deserialize(bs58.decode(item.transaction));
        const signature = await signAndSendTransaction(connection, commitment, transaction, keypair);
        console.log(`✅ ${step} confirmed: ${signature}`);
    }

    console.log("🎉 Token launched successfully!");
    console.log(`🌐 View your token at: https://bags.fm/${tokenInfo.tokenMint}`);

    return { tokenMint: tokenInfo.tokenMint, launch };
}

// Example: launch a token quoted in a non-SOL badged mint, with no initial buy.
// Replace quoteMint with a mint returned by getDammV2SupportedQuoteTokens().
launchToken({
    imageUrl: "https://img.freepik.com/premium-vector/white-abstract-vactor-background-design_665257-153.jpg",
    name: "My Equity Token",
    symbol: "MET",
    description: "A token quoted in a non-SOL asset",
    quoteMint: "REPLACE_WITH_SUPPORTED_QUOTE_MINT",
});
```

### Understanding the launch bundle

`createDammV2LaunchTransaction` returns:

* **`transactions`** — an ordered array of `{ type, transaction }`, where `transaction` is a base58-encoded, partially-signed transaction. The `type` is one of:
  * `LUT_SETUP` — creates the address lookup table the launch transaction depends on.
  * `CREATE_TOKEN` — creates the SPL mint and metadata (omitted on rebuilds where the mint already exists).
  * `LAUNCH` — the single atomic transaction that creates the pool, locks both positions, deposits them into custody, and performs the optional initial buy.
  * `LUT_DEACTIVATE` / `LUT_CLOSE` — optional cleanup to reclaim the lookup-table rent after the launch (see below).
* **`launch`** — details about the launch: `pool`, `quoteMint`, `quoteTokenProgram`, `treasuryPositionNftMint`, `feeClaimerPositionNftMint`, `feeClaimerWallet`, `lookupTable`, `positionCustody`, `custodyAuthority`, `launchPriceQuotePerToken`, and `impliedLaunchFdvUsd`.

<Note>
  Unlike the classic SOL launch helper, `createDammV2LaunchTransaction` returns base58 strings (not `VersionedTransaction` objects). Deserialize each with `VersionedTransaction.deserialize(bs58.decode(item.transaction))` before signing, as shown above.
</Note>

### Optional: reclaim the lookup-table rent

The `LUT_SETUP` step pays rent for an address lookup table. After the launch confirms you can reclaim that rent with the `LUT_DEACTIVATE` and `LUT_CLOSE` transactions. These are not server-signed and use a fixed blockhash, so refresh the blockhash before signing, and note that `LUT_CLOSE` is only valid roughly 513 slots after `LUT_DEACTIVATE` lands. This cleanup is optional and can be skipped.

## 4. Verify the Launch

Confirmed launches appear in the DAMM v2 direct launches feed. You can filter by the quote mint you used:

```typescript theme={null}
const { launches } = await sdk.tokenLaunch.getDammV2Launches({
    quoteMint: new PublicKey("REPLACE_WITH_SUPPORTED_QUOTE_MINT"),
    limit: 20,
});

console.log(`Found ${launches.length} launch(es)`);
```

## 5. Claim Creator Fees

Creator fees on a non-SOL launch accrue in the pool's **quote mint** and are claimed from the fee-share position custody. The claim flow is:

1. `GET /token-launch/claimable-positions` to find the claimable position for your wallet.
2. `POST /token-launch/claim-txs/v2` with the position's `dammPositionInfo` to build the claim transaction.

<Warning>
  The simplified `sdk.fee.getClaimTransactions()` method (which calls `claim-txs/v3`) does **not** currently build custody claims for non-SOL DAMM v2 direct launches. Use the `claim-txs/v2` endpoint with the `dammPositionInfo` object returned by `claimable-positions`, as shown below.
</Warning>

```typescript theme={null}
const BASE_URL = "https://public-api-v2.bags.fm/api/v1";

async function claimCreatorFees(tokenMint: string, keypair: Keypair) {
    const commitment = sdk.state.getCommitment();

    // 1. Find the claimable DAMM v2 direct position for this wallet + token
    const positionsRes = await fetch(
        `${BASE_URL}/token-launch/claimable-positions?wallet=${keypair.publicKey.toBase58()}`,
        { headers: { "x-api-key": BAGS_API_KEY! } }
    );
    const { response: positions } = await positionsRes.json();

    const position = positions.find(
        (p: any) => p.launchType === "DAMM_V2_DIRECT" && p.baseMint === tokenMint
    );

    if (!position) {
        console.log("No claimable fees for this token.");
        return;
    }

    console.log(`💰 Claimable: ${position.claimableDisplayAmount} (in quote token)`);

    // 2. Build claim transactions. The position's `dammPositionInfo` already contains every
    //    field claim-txs/v2 needs, so post it directly as the request body.
    const claimRes = await fetch(`${BASE_URL}/token-launch/claim-txs/v2`, {
        method: "POST",
        headers: {
            "x-api-key": BAGS_API_KEY!,
            "content-type": "application/json",
        },
        body: JSON.stringify(position.dammPositionInfo),
    });
    const { response: claimTxs } = await claimRes.json();

    // 3. Sign and send each returned transaction
    for (const { tx } of claimTxs) {
        const transaction = VersionedTransaction.deserialize(bs58.decode(tx));
        const signature = await signAndSendTransaction(connection, commitment, transaction, keypair);
        console.log(`✅ Claim confirmed: ${signature}`);
    }
}
```

<Note>
  Claimed amounts are paid out in the pool's quote mint, not SOL. Convert using the quote mint's decimals when displaying balances.
</Note>

## 6. Claim Partner and Deployer Fees

Partners and deployers do not hold a DAMM v2 position directly. Their revenue share accrues into a per-wallet **aggregate vault** (one per quote mint) that is swept with the vault endpoints. These claims are gas-sponsored: the gas sponsor pays the transaction fee and your wallet co-signs as the authorizer.

```typescript theme={null}
async function sweepVaults(keypair: Keypair) {
    const commitment = sdk.state.getCommitment();

    // 1. List every non-empty vault balance for this wallet
    const vaults = await sdk.tokenLaunch.getDammV2VaultClaimables(keypair.publicKey);

    if (vaults.length === 0) {
        console.log("No vault balances to claim.");
        return;
    }

    // 2. Sweep each vault
    for (const vault of vaults) {
        console.log(`💰 ${vault.kind} vault: ${vault.claimableDisplayAmount} (quote mint ${vault.quoteMint})`);

        const { transaction } = await sdk.tokenLaunch.claimDammV2Vault({
            kind: vault.kind,                          // "partner" | "deployer"
            wallet: keypair.publicKey,
            quoteMint: new PublicKey(vault.quoteMint),
        });

        // claimDammV2Vault returns a VersionedTransaction (already decoded)
        const signature = await signAndSendTransaction(connection, commitment, transaction, keypair);
        console.log(`✅ Vault swept: ${signature}`);
    }
}
```

## 7. Run Your Script

Edit the `launchToken(...)` call at the bottom of the script with your token details and a `quoteMint` from step 2, then run:

```bash theme={null}
npx ts-node launch-token-non-sol-quote.ts
```

## 8. Troubleshooting

Common issues:

* **Token already launched**: The token mint must still be in `PRE_LAUNCH` status. Each mint from `createTokenInfoAndMetadata()` can only be launched once.
* **Quote mint not supported**: Only mints returned by `getDammV2SupportedQuoteTokens()` can be used. Re-fetch the list, as it can change.
* **Insufficient quote balance for initial buy**: `initialBuyQuoteAmount` is spent from your wallet's quote-token balance at build time. Make sure you hold at least that amount, in base units.
* **Insufficient SOL**: Your wallet still needs SOL to pay transaction fees and rent, even though trading is quoted in a non-SOL token.
* **Wrong decimals**: `initialBuyQuoteAmount`, claimable amounts, and vault balances are all in the quote mint's base units. Convert using the `decimals` from `getDammV2SupportedQuoteTokens()`.

For more details, see the [API Reference](/api-reference/introduction).
