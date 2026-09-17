> For the complete documentation index, see [llms.txt](https://docs.flap.sh/flap/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://docs.flap.sh/flap/developers/wallet-and-terminal-and-bot-developers/inspect-a-tax-token.md).

# Inspect A Tax Token

## Overview

You can get the tax info of any tax token using the Tax Token Helper contract. Our website uses this contract to get tax info for tokens and show them to users:

<figure><img src="/files/1E5cf0YWIa8QtGJhfdzZ" alt="" width="563"><figcaption></figcaption></figure>

## Tax Token Helper

| Chain             | Tax Token Helper                           |
| ----------------- | ------------------------------------------ |
| BNB Mainnet       | 0x53841c73217735F37BC1775538b03b23feFD8346 |
| BNB Testnet       | 0xD64441e5FcD02D342B8cf6eBA10Ef6E40d0dA90f |
| Robinhood Mainnet | 0xb10bD2672aE63735d677164A54B573a016f0203C |

```solidity
// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

/// @title ITaxTokenHelper
/// @notice Interface for the TaxTokenHelper contract that provides utilities for interacting with tax tokens
/// @dev This helper supports both legacy (TOKEN_TAXED) and new (TOKEN_TAXED_V2) tax token versions
interface ITaxTokenHelper {
    /// @notice Structure containing comprehensive tax token configuration and statistics
    /// @dev All BPS values are in basis points (1 BPS = 0.01%)
    struct TaxTokenInfo {
        /// @notice Marketing tax allocation in basis points (0-10000)
        uint16 marketBps;

        /// @notice Deflation (burn) tax allocation in basis points (0-10000)
        uint16 deflationBps;

        /// @notice Liquidity provision tax allocation in basis points (0-10000)
        uint16 lpBps;

        /// @notice Dividend distribution tax allocation in basis points (0-10000)
        uint16 dividendBps;

        /// @notice Total tax rate applied to transfers in basis points (sum of all allocations)
        uint16 taxRate;

        /// @notice Cumulative amount of tokens burnt (sent to black hole and dead addresses)
        uint256 burntTokenAmount;

        /// @notice Cumulative amount of quote tokens distributed to dividend holders
        uint256 totalQuoteSentToDividend;

        /// @notice Cumulative amount of quote tokens added to liquidity pools
        uint256 totalQuoteAddedToLiquidity;

        /// @notice Cumulative amount of tax tokens added to liquidity pools
        uint256 totalTokenAddedToLiquidity;

        /// @notice Cumulative amount of quote tokens sent to marketing wallet
        uint256 totalQuoteSentToMarketing;

        /// @notice Address receiving marketing tax allocations
        address marketingWallet;

        /// @notice Address of the quote token used for tax swaps (address(0) for native token)
        address quoteToken;

        /// @notice Minimum token balance required to receive dividend distributions
        uint256 minimumShareBalance;
    }

    /// @notice Information about the marketing wallet or vault associated with a tax token
    struct MarketingWalletInfo {
        /// @notice The marketing wallet address, which could be a plain EOA, a Flap Vault, or any smart contract
        address addr;

        /// @notice The vault factory address that created this vault.
        ///         Zero if the marketing wallet is not a Flap Vault or the factory is unknown.
        address factory;

        /// @notice Risk level as assessed by Flap auditors.
        ///         UNVERIFIED(0), LOW_RISK(1), LOW_MEDIUM_RISK(2), MEDIUM_RISK(3), HIGH_RISK(4)
        uint8 riskLevel;

        /// @notice Whether the vault is an official Flap-endorsed vault
        bool isOfficialVault;

        /// @notice Whether the marketing wallet is a registered Flap Vault (via VaultPortal)
        bool isVault;

        /// @notice Whether the marketing wallet is an AI consumer.
        ///         True when the vault category is TYPE_AI_ORACLE_POWERED, or when the address
        ///         is a non-EOA contract that has made at least one request via FlapAIProvider.
        bool isAIConsumer;
    }

    /// @notice Extended tax token info with vault and AI oracle metadata.
    ///         Prefer this over TaxTokenInfo for new integrations.
    struct TaxTokenInfoV2 {
        /// @notice Marketing tax allocation in basis points (0-10000)
        uint16 marketBps;

        /// @notice Deflation (burn) tax allocation in basis points (0-10000)
        uint16 deflationBps;

        /// @notice Liquidity provision tax allocation in basis points (0-10000)
        uint16 lpBps;

        /// @notice Dividend distribution tax allocation in basis points (0-10000)
        uint16 dividendBps;

        /// @notice Tax rate applied on buys, in basis points (e.g., 500 = 5%)
        uint16 buyTaxRate;

        /// @notice Tax rate applied on sells, in basis points (e.g., 500 = 5%).
        ///         Currently equal to buyTaxRate as the contract uses a single taxRate.
        uint16 sellTaxRate;

        /// @notice Cumulative amount of tokens burnt (sent to black hole and dead addresses)
        uint256 burntTokenAmount;

        /// @notice Cumulative amount of quote tokens distributed to dividend holders
        uint256 totalQuoteSentToDividend;

        /// @notice Cumulative amount of quote tokens added to liquidity pools
        uint256 totalQuoteAddedToLiquidity;

        /// @notice Cumulative amount of tax tokens added to liquidity pools
        uint256 totalTokenAddedToLiquidity;

        /// @notice Cumulative amount of quote tokens sent to marketing wallet
        uint256 totalQuoteSentToMarketing;

        /// @notice The token distributed as dividends to shareholders.
        ///         address(0) means the native gas token (e.g., BNB or ETH);
        ///         any other address is the ERC20 reward token.
        address dividendToken;

        /// @notice Address of the quote token used for tax swaps (address(0) for native token)
        address quoteToken;

        /// @notice Minimum token balance required to receive dividend distributions
        uint256 minimumShareBalance;

        /// @notice Information about the marketing wallet / vault that receives tax revenue
        MarketingWalletInfo vaultInfo;
    }

    /// @notice Returns the version of the TaxTokenHelper contract
    /// @return Version string in semantic versioning format
    function version() external pure returns (string memory);

    /// @notice Retrieves comprehensive information about a tax token's configuration and statistics
    /// @dev Returns zero/empty values for non-tax tokens (TOKEN_V2_PERMIT)
    /// @dev For legacy TOKEN_TAXED tokens, only marketBps, taxRate, marketingWallet, quoteToken, and totalQuoteSentToMarketing are populated
    /// @dev For TOKEN_TAXED_V2 tokens, all fields are populated based on TaxProcessor state
    /// @param taxToken Address of the tax token to query
    /// @return info TaxTokenInfo struct containing all tax token configuration and statistics
    function getTaxTokenInfo(address taxToken) external view returns (TaxTokenInfo memory info);

    /// @notice Retrieves extended tax token info including vault and AI oracle metadata
    /// @dev Returns zero/empty values for non-tax tokens (TOKEN_V2_PERMIT)
    /// @dev For legacy TOKEN_TAXED tokens, marketBps, buyTaxRate/sellTaxRate, vaultInfo.addr, quoteToken, and totalQuoteSentToMarketing are populated
    /// @dev For TOKEN_TAXED_V2 tokens, all fields including vaultInfo are populated
    /// @param taxToken Address of the tax token to query
    /// @return info TaxTokenInfoV2 struct containing extended tax token configuration, statistics, and vault metadata
    function getTaxTokenInfoV2(address taxToken) external view returns (TaxTokenInfoV2 memory info);

    /// @notice Retrieves dividend information for a specific user and tax token
    /// @dev Returns (0, 0) if the tax token has no dividend contract configured
    /// @param taxToken Address of the tax token
    /// @param user Address of the user to query dividend information for
    /// @return claimed Total amount of dividends already claimed by the user
    /// @return pending Amount of dividends currently available for withdrawal
    function getDividendInfo(address taxToken, address user) external view returns (uint256 claimed, uint256 pending);

    /// @notice Claims accumulated dividends for the caller (msg.sender)
    /// @dev Reverts if the tax token has no dividend contract configured
    /// @dev For WETH dividends, automatically unwraps to native token
    /// @param taxToken Address of the tax token to claim dividends from
    function claimDividend(address taxToken) external;

    /// @notice Claims accumulated dividends for the caller with optional native token unwrapping
    /// @dev Reverts if the tax token has no dividend contract configured
    /// @param taxToken Address of the tax token to claim dividends from
    /// @param unwrapWETH If true, unwraps WETH dividends to native token; if false, sends WETH
    function claimDividend(address taxToken, bool unwrapWETH) external;

    /// @notice Claims accumulated dividends on behalf of a specified user
    /// @dev Reverts if the tax token has no dividend contract configured
    /// @dev Can be called by anyone to trigger dividend withdrawal for any user
    /// @param taxToken Address of the tax token to claim dividends from
    /// @param unwrapWETH If true, unwraps WETH dividends to native token; if false, sends WETH
    /// @param user Address of the user to claim dividends for
    function claimDividendForUser(address taxToken, bool unwrapWETH, address user) external;
}
```

## getTaxTokenInfo vs getTaxTokenInfoV2

The contract exposes two query functions. Use the table below to decide which one to call.

|                           | `getTaxTokenInfo`                 | `getTaxTokenInfoV2`                                  |
| ------------------------- | --------------------------------- | ---------------------------------------------------- |
| **Return type**           | `TaxTokenInfo`                    | `TaxTokenInfoV2`                                     |
| **Tax rate fields**       | Single `taxRate`                  | Separate `buyTaxRate` and `sellTaxRate`              |
| **Marketing address**     | `marketingWallet` (plain address) | `vaultInfo.addr` + full `MarketingWalletInfo`        |
| **Vault metadata**        | None                              | `isVault`, `factory`, `riskLevel`, `isOfficialVault` |
| **AI oracle flag**        | None                              | `isAIConsumer`                                       |
| **Dividend reward token** | Not available                     | `dividendToken` (`address(0)` = native gas token)    |
| **Recommended for**       | Legacy integrations               | All new integrations                                 |

### Using getTaxTokenInfo

`getTaxTokenInfo` is the original query function. Call it when you only need the core tax breakdown and cumulative statistics:

```solidity
ITaxTokenHelper helper = ITaxTokenHelper(TAX_TOKEN_HELPER);
ITaxTokenHelper.TaxTokenInfo memory info = helper.getTaxTokenInfo(taxToken);

// Tax allocation pie (all in BPS, sum = taxRate)
// info.marketBps      — share going to marketing wallet
// info.deflationBps   — share burnt
// info.lpBps          — share added to liquidity
// info.dividendBps    — share distributed to dividend holders

// Tax rate
// info.taxRate        — total tax charged on every transfer (BPS)

// Cumulative statistics
// info.burntTokenAmount          — tokens sent to black hole + dead address
// info.totalQuoteSentToDividend  — quote tokens paid to dividend holders
// info.totalQuoteAddedToLiquidity
// info.totalTokenAddedToLiquidity
// info.totalQuoteSentToMarketing

// Addresses
// info.marketingWallet           — wallet receiving marketing revenue
// info.quoteToken                — address(0) means native gas token (BNB/ETH)

// Dividend gating
// info.minimumShareBalance       — min token balance to receive dividends
```

{% hint style="info" %}
For V1 tax tokens (`TOKEN_TAXED`), only `marketBps` (always `10000`), `taxRate`, `marketingWallet`, `quoteToken`, and `totalQuoteSentToMarketing` are populated. All other fields are zero.
{% endhint %}

### Using getTaxTokenInfoV2

`getTaxTokenInfoV2` is the recommended function for all new integrations. It returns everything `getTaxTokenInfo` returns, plus richer metadata about the marketing wallet and dividend token.

```solidity
ITaxTokenHelper helper = ITaxTokenHelper(TAX_TOKEN_HELPER);
ITaxTokenHelper.TaxTokenInfoV2 memory info = helper.getTaxTokenInfoV2(taxToken);

// Tax allocation — same BPS fields as TaxTokenInfo
// info.marketBps / deflationBps / lpBps / dividendBps

// Separate buy and sell tax rates (replaces the single taxRate field)
// info.buyTaxRate    — tax on buys (BPS)
// info.sellTaxRate   — tax on sells (BPS, currently equal to buyTaxRate)

// Cumulative statistics — same as TaxTokenInfo
// info.burntTokenAmount / totalQuoteSentToDividend / totalQuoteAddedToLiquidity
// info.totalTokenAddedToLiquidity / totalQuoteSentToMarketing

// Dividend reward token (new in V2)
// info.dividendToken — address(0) = native gas token; otherwise the ERC20 reward token
// info.quoteToken
// info.minimumShareBalance

// Marketing wallet / vault metadata (new in V2)
// info.vaultInfo.addr            — the marketing wallet or vault address
// info.vaultInfo.isVault         — true if registered via VaultPortal
// info.vaultInfo.factory         — vault factory that created it (zero if not a vault)
// info.vaultInfo.riskLevel       — 0 UNVERIFIED · 1 LOW · 2 LOW_MEDIUM · 3 MEDIUM · 4 HIGH
// info.vaultInfo.isOfficialVault — true if Flap-endorsed
// info.vaultInfo.isAIConsumer    — true if vault uses Flap AI Oracle
```

#### Reading vault risk level

`riskLevel` maps to the `IVaultPortalTypes.RiskLevel` enum:

| Value | Meaning                             |
| ----- | ----------------------------------- |
| 0     | UNVERIFIED (default for non-vaults) |
| 1     | LOW\_RISK                           |
| 2     | LOW\_MEDIUM\_RISK                   |
| 3     | MEDIUM\_RISK                        |
| 4     | HIGH\_RISK                          |

#### Detecting AI-powered vaults

`isAIConsumer` is `true` when either:

* The vault's category in VaultPortal is `TYPE_AI_ORACLE_POWERED`, **or**
* The marketing wallet is a smart contract (not an EOA or EIP-7702 delegate) that has submitted at least one request through `FlapAIProvider`.

### V1 tax token caveats

For V1 tax tokens (`TOKEN_TAXED`), both functions populate only a subset of fields: `marketBps` (always `10000`, meaning 100% goes to the marketing/funds-recipient wallet), `buyTaxRate`/`sellTaxRate` (or `taxRate`), `vaultInfo.addr`/`marketingWallet`, `quoteToken`, and `totalQuoteSentToMarketing`.

The `totalQuoteSentToMarketing` field may be zero for older V1 tokens. If that is the case, we provide a backend to get the `totalQuoteSentToMarketing` for V1 Tax tokens:

```
https://t3w1p53k7a.execute-api.eu-west-3.amazonaws.com/donation?token=0x36F2FD027F5f27C59B8C6d64dF64bcC8E8C97777 
```

> Note: you only need this fallback when `totalQuoteSentToMarketing` returned by `getTaxTokenInfo` is zero for V1 Tax tokens. For V2 Tax tokens, the `totalQuoteSentToMarketing` is always accurate.

## how to inspect a tax token's vault

When using `getTaxTokenInfoV2`, vault metadata is already included in the `vaultInfo` field of `TaxTokenInfoV2` — no separate VaultPortal call is needed for the basic case.

For deeper, vault-type-specific data, you can still query VaultPortal directly. Use the VaultPortal `tryGetVault` method to get basic vault information; the returned `description` gives a human-readable summary of the vault. For details on the fields returned by `tryGetVault`, refer to [Get Vault Info](/flap/developers/vault-developers/flap-tax-vault.md#get-vault-info).

If you want vault-type-specific data, compare the `vaultFactory` returned by `tryGetVault` against the known registered vault factories and then query the vault using its own interface. The list of registered vault factories and their interfaces is available at [developers/token-launcher-developers/registered-vaults.md](/flap/developers/token-launcher-developers/registered-vaults.md).

## How to determine whether a token or a factory has low risk

`riskLevel` (the `IVaultPortalTypes.RiskLevel` enum: `UNVERIFIED(0)`, `LOW_RISK(1)`, `LOW_MEDIUM_RISK(2)`, `MEDIUM_RISK(3)`, `HIGH_RISK(4)`) exists at two places: the **vault factory** and the **individual token**. A token's risk level either comes from its factory (inherited automatically at launch) or from its own independent audit — and only one of those two paths emits an event on the token itself.

{% hint style="danger" %}
**If you only index token-level events, you will miss tokens that are low risk purely because their factory is low risk.** When a token is launched from an already-verified, `LOW_RISK` factory, the token inherits that risk level immediately — but **no event is emitted for the token** at that moment. The only way to know is to also track the factory's risk level and combine it with your own list of "which tokens came from which factory." If your indexer only watches for a token-level audit event, a token that is actually `LOW_RISK` (via its factory) will silently look `UNVERIFIED` in your data.
{% endhint %}

### Indexing which factory created a token

Since inheriting risk from a factory emits no event on the token, you need a separate way to know that a given token *came from* a given factory in the first place — otherwise you have nothing to join the factory's risk level against.

* **The event to watch:** `FlapTaxVaultTokenCreated(address indexed token, address indexed vault, address indexed vaultFactory)`, emitted exactly once when the token is launched through `newTokenV6WithVault` / `newTokenV7WithVault`. All three parameters are indexed, so you can filter by `vaultFactory` to find every token launched from a specific factory, or look up a single token to find its `vaultFactory`.
* Keep a `token → vaultFactory` map from this event. Combine it with the `factory → riskLevel` map from `FlapTaxVaultFactoryRegistered` (below) to derive each token's inherited risk level — `token`'s risk = `riskLevel` of `vaultFactory` at the time of creation, unless a later `AuditReportSubmitted` overrides it for that specific token.

### Getting a factory's risk level

* **Indexing:** listen for `FlapTaxVaultFactoryRegistered(address factory, bool enabled, bool official, RiskLevel riskLevel)`. Every emission carries the factory's full current state, not a delta — just overwrite whatever you had stored for that `factory`.
* **Direct query (no indexing needed):** call `VaultPortal.vaultFactories(factory)`, which returns `(bool enabled, bool official, RiskLevel riskLevel, bytes29 reserved)` — a single always-current on-chain read.

{% hint style="warning" %}
There is a separate `FactoryAuditReportSubmitted` event tied to `submitFactoryAuditReport(...)`. Don't use it to track a factory's effective risk level — it only records a historical audit report and does not necessarily reflect the risk level actually used when new tokens are launched from that factory. `FlapTaxVaultFactoryRegistered` is the one that matters for "what risk level will a new token from this factory get right now."
{% endhint %}

### Getting a token's own risk level

A token's own risk level can be set independently of its factory — for example, upgrading a specific token from `UNVERIFIED` to `LOW_RISK` after it passes its own audit, regardless of what its factory's rating is.

* **The event to watch:** `AuditReportSubmitted(address indexed taxToken, address indexed auditor, RiskLevel riskLevel, string ipfsCid)`. This is the only event that fires when a token's own stored risk level changes — including the "not low risk → low risk" transition. Overwrite your stored value for that `taxToken` every time it fires.
* Remember: this event only fires for **independent, per-token** audits. It does **not** fire when a token simply inherits its risk level from its factory at launch (see the warning above) — those tokens need to be picked up via the factory's `FlapTaxVaultFactoryRegistered` event instead.

### Getting the current risk level without indexing anything

If you don't want to run an indexer and just need the current status for one token right now, there are two equivalent single-call options — both always return the live value, whether it came from factory inheritance or an independent audit:

**Option A — `TaxTokenHelper.getTaxTokenInfoV2`** (recommended; see the [`getTaxTokenInfoV2`](#using-gettaxtokeninfov2) section above):

```solidity
ITaxTokenHelper.TaxTokenInfoV2 memory info = ITaxTokenHelper(TAX_TOKEN_HELPER).getTaxTokenInfoV2(taxToken);
uint8 riskLevel = info.vaultInfo.riskLevel; // 0 UNVERIFIED · 1 LOW · 2 LOW_MEDIUM · 3 MEDIUM · 4 HIGH
```

This one call also gets you the rest of the tax breakdown at the same time.

**Option B — direct `VaultPortal.tryGetVault`**, if you don't need the tax breakdown:

```solidity
(bool found, IVaultPortalTypes.VaultInfo memory info) = IVaultPortal(VAULT_PORTAL).tryGetVault(taxToken);
IVaultPortalTypes.RiskLevel riskLevel = info.riskLevel;
```

### Summary

| Question                                                         | Where to look                                                                                                                                |
| ---------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| What's a factory's current risk level?                           | `FlapTaxVaultFactoryRegistered` event, or `VaultPortal.vaultFactories(factory)`                                                              |
| Which factory did a token launch from?                           | `FlapTaxVaultTokenCreated` event (`token → vaultFactory`)                                                                                    |
| Did a specific token's own risk level just change?               | `AuditReportSubmitted` event                                                                                                                 |
| Did a token become low risk just by inheriting from its factory? | **No event on the token** — join `FlapTaxVaultTokenCreated` (which factory) with `FlapTaxVaultFactoryRegistered` (that factory's risk level) |
| I don't want to index anything, just tell me the current status  | `TaxTokenHelper.getTaxTokenInfoV2(token).vaultInfo.riskLevel` or `VaultPortal.tryGetVault(token)`                                            |
