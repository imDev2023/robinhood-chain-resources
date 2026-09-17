# Flap - Indexing Vault Factories & Vaults

> Source: https://docs.flap.sh/flap/developers/wallet-and-terminal-and-bot-developers/indexing-vaults
> Retrieved: 2026-09-02 (GitBook markdown export, https://docs.flap.sh/flap/developers/wallet-and-terminal-and-bot-developers/indexing-vaults.md)

---

> For the complete documentation index, see [llms.txt](https://docs.flap.sh/flap/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://docs.flap.sh/flap/developers/wallet-and-terminal-and-bot-developers/indexing-vaults.md).

# Indexing Vault Factories & Vaults

This chapter teaches the generic pattern for indexing every vault created through `VaultPortal` - the factory that produced it, and the vault itself. It is vault-type agnostic on purpose: one event covers all vaults, and you branch on the factory to enrich each record.

Vault-type-specific guides (which dividend asset a vault pays, how to read its composition, which extra events it emits) are the sub-chapters that follow, such as [Index & Query a Stocks Vault](/flap/developers/wallet-and-terminal-and-bot-developers/indexing-vaults/index-and-query-a-stocks-vault.md). Each vault type is documented the same way.

## Overview

A tax token can be launched together with a revenue vault in a single transaction through `VaultPortal.newTaxTokenWithVault` / `newTokenV6WithVault`. No matter which factory produced the vault, `VaultPortal` emits one universal signal:

```solidity
/// @notice Emitted when a new tax token with an associated vault is successfully created
/// @param token        The address of the newly deployed tax token
/// @param vault         The address of the newly created vault that will receive tax revenue
/// @param vaultFactory  The vault factory address that was used to create the vault
event FlapTaxVaultTokenCreated(
    address indexed token,
    address indexed vault,
    address indexed vaultFactory
);
```

All three arguments are indexed, so you can filter by `token`, `vault`, or `vaultFactory` directly at the log level.

{% hint style="info" %}
`FlapTaxVaultTokenCreated` is emitted by `VaultPortal` - not by the individual factories. Index it on the `VaultPortal` address for the chain you are following (see [Deployed Contract Addresses](/flap/developers/deployed-contract-addresses.md)). Individual factories may emit their own richer events; those are documented per vault type in the sub-chapters.
{% endhint %}

## Suggested indexing flow

1. **Listen** to `FlapTaxVaultTquokenCreated` on `VaultPortal`.
2. **Persist** `(token, vault, vaultFactory)` plus the block/tx context.
3. **Classify** the vault by its `vaultFactory` address (see [Identify the vault type](#identify-the-vault-type)).
4. **Enrich** the record with vault-type-specific data by reading from the vault/factory, or by calling `VaultPortal.getVault` / `tryGetVault` for a generic summary.

Because the vault type is fully determined by `vaultFactory`, adding support for a new vault type is additive: keep indexing the same event, and add a new branch for the new factory address. Each vault type is documented in its own sub-chapter.

## Identify the vault type

**The `vaultFactory` address is the type key.** How you decode a vault (which dividend asset it pays, which extra events it emits) is determined entirely by the factory that produced it, so maintain a per-chain allowlist mapping each known `vaultFactory` address to a vault type and its decoding logic. A `vaultFactory` that is not in your allowlist is a vault type you do not decode yet - flag it so you know to add a decoding branch. The Stocks (RWA / Index) factory addresses are listed in [Index & Query a Stocks Vault](/flap/developers/wallet-and-terminal-and-bot-developers/indexing-vaults/index-and-query-a-stocks-vault.md).

## Enrich via VaultPortal (generic summary)

If you only need a generic summary and do not want to talk to each factory, `VaultPortal` exposes two view helpers:

```solidity
struct VaultInfo {
    address vault;
    address vaultFactory;   // zero address if unknown
    string  description;    // human-readable, from the vault's description()
    bool    isOfficial;     // endorsed by the protocol
    RiskLevel riskLevel;    // audit risk classification
}

/// @notice Complete vault information for a tax token. Reverts if no vault is found.
function getVault(address taxToken) external view returns (VaultInfo memory info);

/// @notice Non-reverting variant. Falls back to searching the Portal.
///         For fallback results, isOfficial is always false.
/// @return found Whether a vault was found for this tax token
/// @return info  The VaultInfo struct (empty if not found)
function tryGetVault(address taxToken) external view returns (bool found, VaultInfo memory info);
```

Prefer `tryGetVault` in an indexer: it never reverts, so a token with no vault simply returns `found = false` instead of failing your batch call. `getVault` reverts with `VaultNotFound(taxToken)` when there is no vault.

{% hint style="info" %}
`VaultInfo.description` is produced by the vault's own `description()` method and is intended for display. It is not a stable schema - do not parse it for machine-readable fields. Read typed values from the vault/factory instead (see the per-vault-type sub-chapters).
{% endhint %}

## Vault types

* [Index & Query a Stocks Vault](/flap/developers/wallet-and-terminal-and-bot-developers/indexing-vaults/index-and-query-a-stocks-vault.md) - RWA / tokenized-stock vaults, across all three factory versions.
