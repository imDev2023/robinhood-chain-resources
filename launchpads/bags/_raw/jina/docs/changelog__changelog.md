> ## Documentation Index
> Fetch the complete documentation index at: https://docs.bags.fm/llms.txt
> Use this file to discover all available pages before exploring further.

# Changelog

> Product updates and announcements

> For instant change notifications, join and subscribe to our Telegram channel: [Bags Dev Notifications](https://t.me/bags_dev).

<Update label="DAMM v2 Direct Launches" description="Non-SOL quote tokens">
  **Launch tokens quoted in non-SOL assets:**

  You can now launch a token directly into a Meteora DAMM v2 pool quoted in a badged non-SOL mint (xStocks, Ondo tokenized equities, and other supported quote tokens) — no bonding curve and no migration. Fees accrue and are claimed in the pool's quote token.

  **Documentation Updates:**

  * Added [Launch a Token with a Non-SOL Quote Token](/how-to-guides/launch-token-non-sol-quote) how-to guide covering the launch flow, creator fee claiming, and partner/deployer vault sweeping.
  * Added [Get Claim Transactions (v2)](/api-reference/get-claim-transactions) to the Fee Claiming API reference navigation.

  **SDK Methods:**

  * `sdk.tokenLaunch.getDammV2SupportedQuoteTokens()` — list supported quote mints.
  * `sdk.tokenLaunch.createDammV2LaunchTransaction()` — build the launch bundle.
  * `sdk.tokenLaunch.getDammV2Launches()` — list confirmed direct launches.
  * `sdk.tokenLaunch.getDammV2VaultClaimables()` / `sdk.tokenLaunch.claimDammV2Vault()` — sweep partner/deployer vaults.
</Update>

<Update label="January 2026" description="v1.2.0">
  **Get Token Claim Events - Time-Based Filtering:**

  The `/fee-share/token/claim-events` endpoint now supports two query modes:

  * **Offset Mode** (default, backward compatible): Use `mode=offset` with `limit` and `offset` for traditional pagination.
  * **Time Mode** (new): Use `mode=time` with `from` and `to` unix timestamps to retrieve all events within a specific time range.

  **Example - Time Mode:**

  ```
  GET /fee-share/token/claim-events?tokenMint=...&mode=time&from=1704067200&to=1706745600
  ```

  **New Parameters:**

  * `mode`: Query mode (`offset` or `time`). Defaults to `offset` for backward compatibility.
  * `from`: Start unix timestamp (required for time mode).
  * `to`: End unix timestamp (required for time mode, must be >= `from`).

  **Documentation Updates:**

  * Updated [Get Token Claim Events](/api-reference/get-token-claim-events) API reference with new parameters.
  * Added [Get Token Claim Events](/how-to-guides/get-token-claim-events) how-to guide with examples for both modes.

  **Backward Compatibility:**

  * Existing integrations using offset/limit without specifying `mode` will continue to work unchanged.
</Update>

<Update label="Token Launch v2" description="v1.1.0">
  **Token Launch v2 - Fee Sharing Required:**

  * Token Launch v2 now requires fee sharing configuration for all token launches. Launches without shared fees are no longer supported.

  * All fees must be explicitly allocated using basis points. Creators must always set their BPS explicitly, even when receiving 100% of fees.

  * When sharing fees, both creators and fee claimers must have their BPS set explicitly in the configuration.

    **New Features**

  * **Multiple Fee Claimers**: Support for sharing fees with multiple fee claimers (not just 2 users), up to a maximum of 100 fee earners per token launch (including the creator). Each fee claimer can be identified by social provider (twitter, kick, github) and username.

  * **Partner Configuration**: New partner key system allows platforms and partnerships to receive fees from multiple token launches. See [Create Partner Key](/how-to-guides/create-partner-key) and [Claim Partner Fees](/how-to-guides/claim-partner-fees) guides.

  * **Lookup Tables (LUTs)**: Automatic LUT creation and management for fee share configs with more than 15 fee claimers. The SDK handles LUT creation, slot waiting, and extension automatically.

  * **Trade Service**: New trade endpoints for getting quotes and executing token swaps. See [Trade Tokens](/how-to-guides/trade-tokens) guide.

  **SDK Updates:**

  * `createBagsFeeShareConfig` now supports `partner` and `partnerConfig` parameters for partner fee sharing.
  * `createBagsFeeShareConfig` now supports `additionalLookupTables` parameter for configs with >15 fee claimers.
  * New `getConfigCreationLookupTableTransactions()` helper function for LUT creation.
  * New `waitForSlotsToPass()` utility function for waiting between LUT creation and extension.
  * New `getPartnerConfigCreationTransaction()` for creating partner keys.
  * New `getPartnerConfigClaimTransactions()` for claiming partner fees.
  * New `getQuote()` and `createSwapTransaction()` for token trading.
  * Updated `getClaimTransaction()` to return `Transaction[]` instead of `VersionedTransaction[]`.

  **Documentation Updates:**

  * Updated [Launch a Token](/how-to-guides/launch-token) guide with v2 flow and multiple fee claimer support.
  * Removed `launch-token-with-shared-fees` guide (functionality merged into main launch guide).
  * Added [Create Partner Key](/how-to-guides/create-partner-key) guide with dev dashboard and SDK methods.
  * Added [Claim Partner Fees](/how-to-guides/claim-partner-fees) guide with dev dashboard and SDK methods.
  * Added [Trade Tokens](/how-to-guides/trade-tokens) guide for swap functionality.
  * Updated [Claim Fees](/how-to-guides/claim-fees) guide with new SDK functions and detailed position type explanations.
  * Updated core principles: Program IDs (added Fee Share V2), Lookup Tables (LUT requirements), Tipping (updated endpoints), File Uploads (corrected endpoint).

  **Breaking Changes:**

  * Token launches now require fee sharing configuration. The old flow without fee sharing is no longer supported.
  * Fee claimers must be identified using supported social providers: `twitter`, `kick`, and `github`.
  * Maximum of 100 fee earners (including the creator) per token launch.
</Update>

<Update label="September 2025" description="v0.1.8">
  **Endpoint Updates (7-day deprecation):**

  * `/fee-share/wallet/v2` replaces `/fee-share/wallet/twitter` (now supporting GitHub, Kick, TikTok, Twitter).
  * `/token-launch/creator/v3` replaces `/token-launch/creator/v2` (response type includes more details).
  * Old endpoints will be removed in **7 days**.

  **API Enhancements:**

  * Optional tip support on launch-related endpoints. Add an optional tip using `tipWallet` (Base58 encoded Solana public key) and `tipLamports` (lamports) on:\
    `/token-launch/create-config`, `/token-launch/create-launch-transaction`, `/token-launch/fee-share/create-config`.

  * No mandatory IPFS upload for token info creation. `/token-launch/create-token-info` now accepts `imageUrl` and/or `metadataUrl`. When `metadataUrl` is provided, we skip IPFS upload and use the provided URL as-is.

    **SDK v1.0.8:**

  * Adds `getLaunchWalletV2`.

  * `getAllClaimablePositions` is more efficient, with new `chunkSize` arg to reduce RPC rate limits.

  * All downstream functions now support **commitment**.

  * General performance & stability improvements.

  **Other Improvements:**

  * Total fees earned reporting is now more accurate.
  * No more fees for token creation via API (only pay Solana tx cost).
  * Better error responses across the board.
</Update>
