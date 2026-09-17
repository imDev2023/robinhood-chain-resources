# Flap - Index & Query a Stocks Vault

> Source: https://docs.flap.sh/flap/developers/wallet-and-terminal-and-bot-developers/indexing-vaults/index-and-query-a-stocks-vault
> Retrieved: 2026-09-02 (GitBook markdown export, https://docs.flap.sh/flap/developers/wallet-and-terminal-and-bot-developers/indexing-vaults/index-and-query-a-stocks-vault.md)

---

> For the complete documentation index, see [llms.txt](https://docs.flap.sh/flap/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://docs.flap.sh/flap/developers/wallet-and-terminal-and-bot-developers/indexing-vaults/index-and-query-a-stocks-vault.md).

# Index & Query a Stocks Vault

A **Stocks Vault** pays dividends in one or more Real-World Assets (RWA) - in practice tokenized equities such as NVDAon, AAPLon, TSLAon, MSFTon. This sub-chapter builds on the generic flow in [Indexing Vault Factories & Vaults](/flap/developers/wallet-and-terminal-and-bot-developers/indexing-vaults.md) and covers the two things specific to Stocks Vaults: how to index the **token + vault** each factory produces, and how to read the **dividend stock token(s)** that vault distributes.

There are **three factory versions** in production. All three are Stocks Vaults and all three surface through the same `FlapTaxVaultTokenCreated` event on `VaultPortal`. They differ only in how you read the dividend asset(s).

## Factory addresses

Factory addresses are per-chain. Maintain the allowlist keyed by chain.

**BNB Mainnet**

| Version | Factory contract    | Vault Factory address                        | Dividend model          |
| ------- | ------------------- | -------------------------------------------- | ----------------------- |
| v1      | `RWAVaultFactory`   | `0xf8aC088F06D155f3C3F531f1Ef80B14f1604530a` | Single RWA asset        |
| v2      | `RWAVaultFactory`   | `0x40a9a2FDa017E0923EA0B403F2f063f9E51168Fb` | Single RWA asset        |
| v3      | `IndexVaultFactory` | `0x5418f7e8fF90354DB0eCD48c8b710219244Eb3C5` | Composite basket (1..N) |

**Robinhood Mainnet**

| Version | Factory contract    | Factory address                              | Dividend model          |
| ------- | ------------------- | -------------------------------------------- | ----------------------- |
| v3      | `IndexVaultFactory` | `0xe6ca297D1d963b6F00d5b216986123CAeB883AF6` | Composite basket (1..N) |

v1 and v2 are read the same way (both deploy an `RWAVault` paying a single asset). v3 (`IndexVaultFactory`) pays a **basket** of 1..N assets chosen at creation time.

## Step 1 - Index the token & vault

Start from the generic signal and branch on `vaultFactory`:

```solidity
event FlapTaxVaultTokenCreated(
    address indexed token,
    address indexed vault,
    address indexed vaultFactory
);
```

Persist `(token, vault, vaultFactory)`. When `vaultFactory` matches one of the three addresses above, record the vault as a Stocks Vault and remember the **version** - it decides how you read the dividend token in Step 2.

### v3 also emits the basket directly

`IndexVaultFactory` (v3) emits its own creation event carrying the dividend token and its underlying subset, so you can capture them at index time and skip the follow-up call in Step 2:

```solidity
/// @param taxToken The tax token this vault backs
/// @param vault    The IndexVault proxy
/// @param basket   The IndexBasketToken (the ERC-20 dividend token holders receive)
/// @param subset   The underlying stock tokens selected for this vault's basket
event IndexVaultCreated(
    address indexed taxToken,
    address indexed creator,
    address vault,
    address basket,
    address[] subset
);
```

## Step 2 - Read the dividend stock token(s)

This is the part that differs by version.

### v1 & v2 - single token via `rwaAsset`

For v1/v2 the vault is an `RWAVault` and pays exactly one RWA stock token. Read it from the vault:

```solidity
interface IRWAVault {
    /// @notice The single RWA dividend token this vault is configured for.
    ///         Returns address(0) until it is resolved (see note below).
    function rwaAsset() external view returns (address);
}

address token = IRWAVault(vault).rwaAsset();
```

{% hint style="warning" %}
**`rwaAsset` resolves lazily.** The vault is created *before* the tax token exists, so `rwaAsset` starts as `address(0)` and is only cached the first time the token receives tax revenue (or when anyone calls `resolveRwaAsset()`). If you read `address(0)`, retry later, or call `resolveRwaAsset()` once the token has launched to prime it.
{% endhint %}

### v3 - basket via `supportedAssets()`

For v3 the vault is an `IndexVault` and pays a **basket**. `rwaAsset` does not exist on v3. Read instead:

```solidity
interface IIndexVault {
    /// @notice The underlying stock tokens this vault distributes (the subset chosen at creation).
    function supportedAssets() external view returns (address[] memory);

    /// @notice The IndexBasketToken - the ERC-20 that dividend holders actually receive.
    ///         Holders can unwrap it into the underlying subset tokens.
    function basketToken() external view returns (address);
}

address[] memory tokens = IIndexVault(vault).supportedAssets();
```

`supportedAssets()` returns the immutable subset baked in at creation - the same list carried by `IndexVaultCreated.subset`, so you can capture it at index time and skip the call.

{% hint style="info" %}
For v3, dividends are paid in the vault's own `IndexBasketToken` (an ERC-20 basket), not directly in the underlying stocks. Read `basketToken()` when you need the address that appears in holders' dividend balances; read `supportedAssets()` for the underlying stock tokens it unwraps into.
{% endhint %}

## Suggested indexing flow (Stocks Vault)

1. Index `FlapTaxVaultTokenCreated` on `VaultPortal`; persist `(token, vault, vaultFactory)`.
2. Branch when `vaultFactory` is one of the three Stocks factories; record the version.
3. Resolve the dividend stock token(s):
   * **v1 / v2**: `rwaAsset()` on the vault (retry while it returns `address(0)`).
   * **v3**: `supportedAssets()` on the vault (underlying stocks) and `basketToken()` (the token holders receive), or capture them from `IndexVaultCreated` at index time.
