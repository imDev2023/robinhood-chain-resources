# Flap - Flap Tax Vault

> Source: https://docs.flap.sh/flap/developers/vault-developers/flap-tax-vault
> Retrieved: 2026-09-02 (GitBook markdown export, https://docs.flap.sh/flap/developers/vault-developers/flap-tax-vault.md)

---

> For the complete documentation index, see [llms.txt](https://docs.flap.sh/flap/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://docs.flap.sh/flap/developers/vault-developers/flap-tax-vault.md).

# Flap Tax Vault

## Table of Contents

* [Overview](#overview)
* [VaultPortal](#vaultportal)
  * [Deployed Addresses](#deployed-addresses)
  * [Get Vault Info](#get-vault-info)
  * [Get Audit Reports for A token](#get-audit-reports-for-a-token)
  * [Launch A Token With A Vault](#launch-a-token-with-a-vault)

## Overview

When you use a smart contract as the "Funds Recipient Wallet", our system will try to parse it as a `vault`.

<figure><img src="/files/Gf0smSj0FV1iSDfp1BRc" alt="" width="563"><figcaption></figcaption></figure>

If you implement your smart contract following our Vault Specification, your Vault's information can be shown on our website.

<figure><img src="/files/fWlNiIFnJUavq8foLPwr" alt="" width="563"><figcaption></figcaption></figure>

Furthermore, if your vault is verified by our team or our auditing partners, your vault's "unverified" risk level can be updated to the corresponding risk level based on the audit results. And all audit reports will be uploaded to ipfs and available on our website for users to check. Users will be able to do their own research on the vaults before investing in your token.

{% hint style="info" %}
You can now create and deploy your own tax vaults **without any permission or registration**. Users can also use any vault they want when launching tokens. Vault factories no longer need to be registered in the VaultPortal before they can be used. See the [Vault & VaultFactory specification](/flap/developers/vault-developers/vault-and-vaultfactory-specification.md) page for full details on how to build your own vaults and vault factories.
{% endhint %}

{% hint style="success" %}
If you are a developer, you can build a vault factory that deploys vaults following our Vault Specification. Once your vault factory is verified by our team or our auditing partners, all vaults deployed from your factory will have the same risk level as your factory. This way, you don't need to submit each vault for verification individually. Besides, you can charge a fee for each vault deployed from your factory to build your business upon Flap. Please refer to the [Vault & VaultFactory specification](/flap/developers/vault-developers/vault-and-vaultfactory-specification.md) page for more details.
{% endhint %}

## VaultPortal

The `VaultPortal` is a registry that manages vault factories and their deployed vaults. It provides a unified interface for interacting with vaults across different chains.

### Deployed Addresses

| Chain       | VaultPortal Address                        |
| ----------- | ------------------------------------------ |
| BNB mainnet | 0x90497450f2a706f1951b5bdda52B4E5d16f34C06 |
| BNB testnet | 0x027e3704fC5C16522e9393d04C60A3ac5c0d775f |

The ABI of the VaultPortal contract is as follows:

{% file src="/files/GankgjlEVKt1RdWhSGQw" %}

### Get Vault Info

We have two methods for fetching the vault info of a token:

* `tryGetVault(address taxToken)` : This method first tries to find the vault created through the VaultPortal. If not found, it will try to find the vault by searching all registered vault factories and manually verified vaults. **You should use this method for most cases to avoid unnecessary reverts.**
* `getVault(address taxToken)` : This method returns vault that created through the VaultPortal.

```solidity

/// @notice Complete vault information returned to external callers
/// @dev This struct is used for view functions and includes human-readable description
/// @param vault The address of the vault contract
/// @param vaultFactory The address of the vault factory that created this vault (zero address if unknown)
/// @param description Human-readable description of the vault's purpose and functionality
/// @param isOfficial Whether this vault is marked as official/endorsed by the protocol
/// @param riskLevel The risk level classification from audit
struct VaultInfo {
    address vault;
    address vaultFactory;
    string description;
    bool isOfficial;
    RiskLevel riskLevel;
}

/// @notice Get the complete vault information for a tax token
/// @dev Reverts if no vault is found for the given tax token
/// @dev Attempts to fetch the vault's description by calling its description() function
/// @param taxToken The address of the tax token
/// @return info The VaultInfo struct containing complete vault details
function getVault(address taxToken) external view returns (VaultInfo memory info);

/// @notice Attempt to get vault information for a tax token without reverting
/// @dev First checks the internal mapping, then falls back to searching the Portal
/// @dev For fallback results, isOfficial and isVerified will always be false
/// @param taxToken The address of the tax token
/// @return found Whether a vault was found for this tax token
/// @return info The VaultInfo struct (empty if not found)
function tryGetVault(address taxToken) external view returns (bool found, VaultInfo memory info);

```

### Get Audit Reports for A token

For each token, you can get its audit reports with pagination support using the getAuditReports method. If the token itself has no audit reports, it will fall back to its vault's factory's audit reports.

```solidity


/// @notice Audit report for a tax token
/// @param auditor The address of the auditor who submitted this report
/// @param riskLevel The risk level classification from this audit
/// @param ipfsCid The IPFS CID of the audit report document
struct AuditReport {
    address auditor;
    RiskLevel riskLevel;
    string ipfsCid;
}

/// @notice Get recent audit reports for a tax token with pagination
/// @dev Returns reports starting from the most recent (end of array)
/// @dev If the token has no audit reports, falls back to its factory's audit reports
/// @param taxToken The address of the tax token
/// @param offset The number of reports to skip from the end (0 = most recent)
/// @param limit The maximum number of reports to return
/// @return reports The array of audit reports
/// @return total The total number of audit reports for this token
function getAuditReports(address taxToken, uint256 offset, uint256 limit)
    external
    view
    returns (AuditReport[] memory reports, uint256 total);
```

### Launch A Token With A Vault

How to launch a token using a vault?

Vault is a system built outside of the main Flap Bonding Curve Protocol. To launch a token with a vault, you need to use the `VaultPortal` contract:

```solidity
pragma solidity ^0.8.13;

import {IPortalTypes} from "./IPortal.sol";

/// @title IVaultPortalTypes
/// @notice Type definitions for the VaultPortal contract
/// @dev Contains all structs and custom types used by VaultPortal
interface IVaultPortalTypes {
   /// @notice Parameters required to create a new tax token with an associated vault
    /// @dev All parameters are passed as a single struct to avoid stack-too-deep errors
    /// @param name The name of the tax token (e.g., "MyToken")
    /// @param symbol The symbol of the tax token (e.g., "MTK")
    /// @param meta Metadata URI or string for additional token information
    /// @param dexThresh The DEX supply threshold type
    /// @param salt A unique salt for deterministic address generation (must produce vanity suffix)
    /// @param taxRate The tax rate in basis points (e.g., 100 = 1%, max 1000 = 10%)
    /// @param migratorType The migrator type (see MigratorType enum)
    /// @param quoteToken The token used for initial liquidity (address(0) for native token)
    /// @param quoteAmt The amount of quote token to provide as initial liquidity
    /// @param permitData The optional permit data for the quote token
    /// @param extensionID The ID of the extension to be used for the new token if not zero
    /// @param extensionData Additional extension specific data
    /// @param dexId The preferred DEX ID for the token
    /// @param lpFeeProfile The preferred V3 LP fee profile for the token
    /// @param taxDuration Tax duration in seconds (max: 100 years)
    /// @param antiFarmerDuration Anti-farmer duration in seconds (max: 1 year)
    /// @param mktBps Market allocation basis points (to beneficiary)
    /// @param deflationBps Deflation basis points (burned)
    /// @param dividendBps Dividend basis points (to dividend contract)
    /// @param lpBps Liquidity provision basis points (LP to dead address)
    /// @param minimumShareBalance Minimum balance for dividend eligibility
    /// @param vaultFactory The address of the vault factory to use for creating the vault
    /// @param vaultData Encoded data specific to the vault type being created
    struct NewTaxTokenWithVaultParams {
        string name;
        string symbol;
        string meta;
        IPortalTypes.DexThreshType dexThresh;
        bytes32 salt;
        uint16 taxRate;
        IPortalTypes.MigratorType migratorType;
        address quoteToken;
        uint256 quoteAmt;
        bytes permitData;
        bytes32 extensionID;
        bytes extensionData;
        IPortalTypes.DEXId dexId;
        IPortalTypes.V3LPFeeProfile lpFeeProfile;
        uint64 taxDuration;
        uint64 antiFarmerDuration;
        uint16 mktBps;
        uint16 deflationBps;
        uint16 dividendBps;
        uint16 lpBps;
        uint256 minimumShareBalance;
        address vaultFactory;
        bytes vaultData;
    }
}
```

The parameters are similar to the `newTokenV5` of the `Portal` contract, with two additional parameters at the end: `vaultFactory` and `vaultData`.
