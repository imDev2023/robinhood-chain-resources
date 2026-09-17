# Flap - Launch token through VaultPortal

> Source: https://docs.flap.sh/flap/developers/token-launcher-developers/launch-token-through-vaultportal
> Retrieved: 2026-09-02 (GitBook markdown export, https://docs.flap.sh/flap/developers/token-launcher-developers/launch-token-through-vaultportal.md)

---

> For the complete documentation index, see [llms.txt](https://docs.flap.sh/flap/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://docs.flap.sh/flap/developers/token-launcher-developers/launch-token-through-vaultportal.md).

# Launch token through VaultPortal

`VaultPortal` builds on top of `Portal` to add Vault functionality for vault-backed token launches. It creates the token and its associated Vault in a single transaction.

Use `VaultPortal` when you need a Vault-backed launch. For launches without a Vault, use `Portal` instead.

For the `VaultPortal` contract address, see [VaultPortal deployed addresses](/flap/developers/vault-developers/flap-tax-vault.md#deployed-addresses).

## Key interfaces

### Recommended: `newTokenV6WithVault`

The preferred entry point for new integrations is `newTokenV6WithVault`, which supports `TOKEN_TAXED_V3` (Tax Token V3) with a vault in a single transaction:

```solidity
/// @notice Create a new tax token via Portal's newTokenV6 with an associated vault in a single transaction
/// @dev Only TOKEN_TAXED_V3 is currently supported as tokenVersion; any other version reverts with FeatureDisabled.
/// @param params The parameters for creating the tax token and vault (mirrors NewTokenV6Params, minus beneficiary)
/// @return token The address of the newly created tax token
function newTokenV6WithVault(NewTokenV6WithVaultParams calldata params) external payable returns (address token);
```

`NewTokenV6WithVaultParams` mirrors `NewTokenV6Params` (without `beneficiary`) and adds vault-specific fields:

```solidity
struct NewTokenV6WithVaultParams {
    string name;
    string symbol;
    string meta;
    IPortalTypes.DexThreshType dexThresh;
    bytes32 salt;
    IPortalTypes.MigratorType migratorType;
    address quoteToken;
    uint256 quoteAmt;
    bytes permitData;
    bytes32 extensionID;
    bytes extensionData;
    IPortalTypes.DEXId dexId;
    IPortalTypes.V3LPFeeProfile lpFeeProfile;
    // V3 tax fields
    uint16 buyTaxRate;
    uint16 sellTaxRate;
    uint64 taxDuration;
    uint64 antiFarmerDuration;
    uint16 mktBps;
    uint16 deflationBps;
    uint16 dividendBps;
    uint16 lpBps;
    uint256 minimumShareBalance;
    address dividendToken;
    address commissionReceiver;
    IPortalTypes.TokenVersion tokenVersion; // must be TOKEN_TAXED_V3
    // vault fields
    address vaultFactory;
    bytes vaultData;
}
```

{% hint style="info" %}
`newTokenV6WithVault` only accepts `TOKEN_TAXED_V3`. Passing any other `tokenVersion` reverts with `FeatureDisabled`. For new integrations, always use Tax Token V3 with `newTokenV6WithVault`.
{% endhint %}

{% hint style="warning" %}
Legacy tax token versions (`TOKEN_TAXED`, `TOKEN_TAXED_V2`) are not supported by `newTokenV6WithVault` and are not recommended for new launches. The old `newTaxTokenWithVault` entry point is deprecated and should not be used for new or existing integrations.
{% endhint %}

### New: `newTokenV7WithVault`

`newTokenV7WithVault` is the VaultPortal wrapper around `Portal.newTokenV7`. It creates the vault first, then rewrites the active `MARKETING_OR_VAULT` fee receiver to that vault before forwarding the launch to `Portal`.

```solidity
/// @notice Create a new token via a V7-style fee-config API with an associated vault.
/// @dev Supports TOKEN_V3_PERMIT (non-tax) and TOKEN_TAXED_V3 (tax). The wrapper creates the vault first,
///      then rewrites MARKETING_OR_VAULT receivers to that vault before calling Portal.newTokenV7.
/// @param params The parameters for creating the token and vault (mirrors upstream newTokenV7 launch UX)
/// @return token The address of the newly created token
function newTokenV7WithVault(NewTokenV7WithVaultParams calldata params) external payable returns (address token);
```

`NewTokenV7WithVaultParams` mirrors `Portal`'s `NewTokenV7Params` and adds vault-specific fields:

```solidity
struct NewTokenV7WithVaultParams {
    string name;
    string symbol;
    string meta;
    IPortalTypes.DexThreshType dexThresh;
    bytes32 salt;
    IPortalTypes.MigratorType migratorType;
    address quoteToken;
    uint256 quoteAmt;
    bytes permitData;
    bytes32 extensionID;
    bytes extensionData;
    IPortalTypes.TokenVersion tokenVersion;
    IPortalTypes.DEXId dexId;
    uint64 antiFarmerDuration;
    uint16 buyTaxRate;
    uint16 sellTaxRate;
    uint64 taxDuration;
    address commissionReceiver;
    IPortalTypes.FeeConfig[4] feeConfigs;
    address vaultFactory;
    bytes vaultData;
}
```

### Current `newTokenV7WithVault` behavior

The interface comment describes both `TOKEN_V3_PERMIT` and `TOKEN_TAXED_V3`, but the current implementation in `FlapTaxVaults/src/VaultPortalLaunch.sol` is narrower:

* it currently reverts with `FeatureDisabled()` unless `tokenVersion == TOKEN_V3_PERMIT`
* `quoteToken` must be `address(0)` or the wrapper reverts with `UnsupportedQuoteToken(...)`
* exactly one active `MARKETING_OR_VAULT` slot is required
* active `feeConfigs` must sum to exactly `10000` bps
* after validation, the wrapper overwrites that single `MARKETING_OR_VAULT` slot's `marketingAddress` with the freshly created vault address
* the current source hard-codes an allowlist of supported vault factories for this path

{% hint style="warning" %}
The supplied interface and simulation script describe a broader V7-with-vault design, but the current source implementation is stricter. When integrating, follow the behavior enforced in `FlapTaxVaults/src/VaultPortalLaunch.sol` rather than assuming every upstream `newTokenV7` combination is already live through `VaultPortal`.
{% endhint %}

### Deprecated: `newTaxTokenWithVault`

`newTaxTokenWithVault` still exists in the ABI for compatibility, but the current `VaultPortal` implementation no longer supports it. The function always reverts and should be treated as deprecated.

```solidity
/// @notice Deprecated. Use newTokenV6WithVault instead.
/// @dev This function previously created a V1/V2 tax token via Portal's newTokenV5.
///      It is no longer supported. Calling it will always revert.
/// @param params Unused - kept for ABI compatibility only.
function newTaxTokenWithVault(NewTaxTokenWithVaultParams calldata params)
    external
    payable
    returns (address token);
```

{% hint style="danger" %}
Do not integrate `newTaxTokenWithVault`. Use `newTokenV6WithVault` for `TOKEN_TAXED_V3`, or `newTokenV7WithVault` for the V7 vault-backed flow.
{% endhint %}

## How to launch with `newTokenV6WithVault`

1. **Choose a registered vault factory.** Vault factories are registered in `VaultPortal`. Each factory defines its own `vaultData` schema. See [Registered vaults](/flap/developers/token-launcher-developers/registered-vaults.md).
2. **Prepare metadata and core token parameters.** Use the same metadata flow as `Portal` (see [launch-token-through-portal.md](/flap/developers/token-launcher-developers/launch-token-through-portal.md)). Set `tokenVersion = TOKEN_TAXED_V3` and both `buyTaxRate`/`sellTaxRate` > 0.
3. **Encode `vaultData` for the selected factory.** The `vaultData` bytes are factory-specific. Always follow the factory's schema (see [Registered vaults](/flap/developers/token-launcher-developers/registered-vaults.md)).
4. **Call `newTokenV6WithVault`.** The contract emits `FlapTaxVaultTokenCreated` with the token, vault, and vault factory addresses.

Example:

```typescript
import { encodeAbiParameters, parseEther, zeroAddress } from "viem";

const params = {
    name: "My Token",
    symbol: "MTK",
    meta: "<ipfs-cid>",
    dexThresh: DexThreshType.TWO_THIRDS,
    salt, // must produce 7777 vanity suffix
    migratorType: MigratorType.V2_MIGRATOR,
    quoteToken: zeroAddress,
    quoteAmt: parseEther("0.01"),
    permitData: "0x",
    extensionID: "0x0000000000000000000000000000000000000000000000000000000000000000",
    extensionData: "0x",
    dexId: DEXId.DEX0,
    lpFeeProfile: V3LPFeeProfile.LP_FEE_PROFILE_STANDARD,
    buyTaxRate: 300,
    sellTaxRate: 1000,
    taxDuration: 365n * 24n * 60n * 60n,
    antiFarmerDuration: 60n * 60n,
    mktBps: 10000,
    deflationBps: 0,
    dividendBps: 0,
    lpBps: 0,
    minimumShareBalance: 0n,
    dividendToken: zeroAddress,
    commissionReceiver: zeroAddress,
    tokenVersion: TokenVersion.TOKEN_TAXED_V3,
    vaultFactory: vaultFactoryAddress,
    vaultData: encodeAbiParameters(
        [
            // replace with the selected vault factory's expected schema
        ],
        []
    ),
};

const hash = await walletClient.writeContract({
    address: vaultPortalAddress,
    abi: vaultPortalAbi,
    functionName: "newTokenV6WithVault",
    args: [params],
    value: parseEther("0.01"),
});
```

{% hint style="info" %}
Each vault factory can define a different `vaultData` schema. Always validate the factory and its expected payload before encoding.
{% endhint %}

## How to launch with `newTokenV7WithVault`

1. **Choose a supported vault factory.** The current implementation validates the V7-with-vault path against a hard-coded factory allowlist inside `VaultPortalLaunch`. Verify your factory is supported before integrating this path.
2. **Prepare metadata and V7 token parameters.** Use the same metadata flow as `Portal` (see [launch-token-through-portal.md](/flap/developers/token-launcher-developers/launch-token-through-portal.md)).
3. **Configure `feeConfigs` with exactly one vault receiver slot.** Provide exactly one active `MARKETING_OR_VAULT` slot. Its address is only a placeholder at input time - `VaultPortal` will replace it with the newly created vault address before forwarding to `Portal.newTokenV7`.
4. **Encode `vaultData` for the selected factory.** The schema is factory-specific. See [Registered vaults](/flap/developers/token-launcher-developers/registered-vaults.md) and the factory's own docs.
5. **Call `newTokenV7WithVault`.** On success, `VaultPortal` stores the launched token → vault mapping and emits `FlapTaxVaultTokenCreated`.

Example based on `FlapTaxVaults/script/testnets/bsc_test/simulation/001-simulate-new-token-v7-with-flap-xvault.sol`:

```solidity
function launchV7WithVault(IVaultPortal vaultPortal, bytes32 salt, address vaultFactoryAddress)
    external
    payable
    returns (address token)
{
    IVaultPortalTypes.NewTokenV7WithVaultParams memory params;

    params.name = "My V7 Vault Token";
    params.symbol = "MV7";
    params.meta = "<ipfs-cid>";
    params.dexThresh = IPortalTypes.DexThreshType.FOUR_FIFTHS;
    params.salt = salt; // TOKEN_V3_PERMIT currently requires the 8888 suffix
    params.migratorType = IPortalTypes.MigratorType.PCS_INFINITY_CL_MIGRATOR;
    params.quoteToken = address(0);
    params.quoteAmt = 0.1 ether;
    params.permitData = "";
    params.extensionID = bytes32(0);
    params.extensionData = "";
    params.tokenVersion = IPortalTypes.TokenVersion.TOKEN_V3_PERMIT;
    params.dexId = IPortalTypes.DEXId.DEX0;
    params.antiFarmerDuration = 0;
    params.buyTaxRate = 0;
    params.sellTaxRate = 0;
    params.taxDuration = 0;
    params.commissionReceiver = address(0);
    params.vaultFactory = vaultFactoryAddress;
    params.vaultData = abi.encode(/* vault init data */);

    params.feeConfigs[0] = IPortalTypes.FeeConfig({
        feeType: IPortalTypes.FeeType.MARKETING_OR_VAULT,
        bps: 10000,
        marketingAddress: msg.sender, // placeholder; replaced with the created vault address
        dividendToken: address(0),
        minimumShareBalance: 0
    });
    params.feeConfigs[1] = IPortalTypes.FeeConfig({
        feeType: IPortalTypes.FeeType.NONE,
        bps: 0,
        marketingAddress: address(0),
        dividendToken: address(0),
        minimumShareBalance: 0
    });
    params.feeConfigs[2] = IPortalTypes.FeeConfig({
        feeType: IPortalTypes.FeeType.NONE,
        bps: 0,
        marketingAddress: address(0),
        dividendToken: address(0),
        minimumShareBalance: 0
    });
    params.feeConfigs[3] = IPortalTypes.FeeConfig({
        feeType: IPortalTypes.FeeType.NONE,
        bps: 0,
        marketingAddress: address(0),
        dividendToken: address(0),
        minimumShareBalance: 0
    });

    token = vaultPortal.newTokenV7WithVault{value: msg.value}(params);
}
```

Key notes:

* `newTokenV7WithVault` does not expose a standalone `beneficiary`; the vault-bound receiver comes from the single active `MARKETING_OR_VAULT` slot.
* If you configure zero or more than one active `MARKETING_OR_VAULT` slot, the wrapper reverts with `InvalidFeeConfig()`.
* The wrapper predicts the token address before vault creation, so your salt must already match the correct vanity suffix for the chosen token implementation.
* The current V7-with-vault implementation only accepts `quoteToken = address(0)`.

## Find the salt (vanity suffix)

`VaultPortal` uses CREATE2 through `Portal`, so the `salt` must produce a token address with the required suffix.

Follow the same salt-finding flow as [launch-token-through-portal.md](/flap/developers/token-launcher-developers/launch-token-through-portal.md), using the implementation that matches the launch path:

* `newTokenV6WithVault` with `TOKEN_TAXED_V3`: use **Tax Token V3 Impl** (`tokenImplTaxedV3`), suffix `7777`
* `newTokenV7WithVault` with `TOKEN_V3_PERMIT`: use **Standard Token V3 Impl** (`tokenImplV3` / Standard Token V3 Impl), suffix `8888`

## Salt locking

Portal supports locking a vanity salt so that only you can use it to launch a token. This works seamlessly with `VaultPortal` - lock the salt directly on Portal, then launch through VaultPortal as normal.

```solidity
function lockAndLaunch(
    IPortal portal,
    IVaultPortal vaultPortal,
    bytes32 mySalt,
    IPortalTypes.TokenVersion tokenVersion,
    IVaultPortalTypes.NewTokenV6WithVaultParams memory params,
    uint256 quoteAmt
) external payable returns (address token) {
    // 1. Lock the salt on Portal directly
    portal.lockSalt{value: msg.value}(mySalt, tokenVersion);

    // 2. Launch through VaultPortal - the lock is honoured automatically
    token = vaultPortal.newTokenV6WithVault{value: quoteAmt}(params);
}
```

No changes to `NewTokenV6WithVaultParams` are needed. VaultPortal communicates the real caller back to Portal automatically during the launch transaction.

The same salt-lock behavior also applies to `newTokenV7WithVault`.

## Reading vault info

You can query vault information after launch:

* `getVault(taxToken)` returns the full vault info and reverts if not found.
* `tryGetVault(taxToken)` returns `(found, info)` without reverting.

## IVaultPortal.sol

Full interface reference for developers:

```solidity
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import {IPortalTypes} from "src/interfaces/IPortal.sol";

/// @title IVaultPortalTypes
/// @notice Type definitions for the VaultPortal contract
/// @dev Contains all structs and custom types used by VaultPortal
interface IVaultPortalTypes {
    /// @notice Risk level classification for vault audits (8 bits)
    /// @dev Used to represent the security assessment of a vault or factory
    enum RiskLevel {
        UNVERIFIED, // 0 - Not yet verified/audited
        LOW_RISK, // 1 - Low risk
        LOW_MEDIUM_RISK, // 2 - Low to medium risk
        MEDIUM_RISK, // 3 - Medium risk
        HIGH_RISK // 4 - High risk

    }

    /// @notice Category classification for vaults (8 bits)
    /// @dev Used to categorize vaults by their type or functionality
    enum VaultCategory {
        NONE, // 0 - Not in any category (default)
        TYPE_AI_ORACLE_POWERED // 1 - AI Oracle powered vaults

    }

    /// @notice Information about a registered vault factory
    /// @dev Packed into a single storage slot for gas efficiency
    /// @param enabled Whether this factory can be used to create new vaults
    /// @param official Whether vaults created by this factory are marked as official/endorsed
    /// @param riskLevel The risk level classification from audit
    /// @param category The category classification for vaults from this factory (1 byte)
    /// @param reserved Reserved space for future upgrades (28 bytes)
    struct VaultFactoryInfo {
        bool enabled;
        bool official;
        RiskLevel riskLevel;
        VaultCategory category;
        bytes28 reserved;
    }

    /// @notice Packed vault information stored in contract storage
    /// @dev Uses three storage slots (64 bytes total)
    /// @param vault The address of the vault contract (20 bytes)
    /// @param vaultFactory The address of the vault factory that created this vault (20 bytes)
    /// @param adapter The address of the adapter contract for legacy vaults (20 bytes)
    /// @param isOfficial Whether this vault is marked as official/endorsed (1 byte)
    /// @param riskLevel The risk level classification from audit (1 byte)
    /// @param category The category classification for this vault (1 byte)
    struct VaultedTaxTokenInfo {
        // slot 0
        address vault;
        bool isOfficial;
        RiskLevel riskLevel;
        VaultCategory category;
        bytes9 reserved0;
        // slot 1
        address vaultFactory;
        bytes12 reserved1;
        // slot 2
        address adapter;
        bytes12 reserved2;
    }

    /// @notice Audit report for a tax token
    /// @param auditor The address of the auditor who submitted this report
    /// @param riskLevel The risk level classification from this audit
    /// @param ipfsCid The IPFS CID of the audit report document
    struct AuditReport {
        address auditor;
        RiskLevel riskLevel;
        string ipfsCid;
    }

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
    /// @param vaultFactory The address of the vault factory to use for creating the vault (any factory is allowed; unregistered/disabled factories result in unverified vaults)
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

    /// @notice Parameters required to create a new V3 tax token with an associated vault
    /// @dev tokenVersion must be TOKEN_TAXED_V3; if it is not, the implementation reverts with FeatureDisabled
    struct NewTokenV6WithVaultParams {
        string name;
        string symbol;
        string meta;
        IPortalTypes.DexThreshType dexThresh;
        bytes32 salt;
        IPortalTypes.MigratorType migratorType;
        address quoteToken;
        uint256 quoteAmt;
        bytes permitData;
        bytes32 extensionID;
        bytes extensionData;
        IPortalTypes.DEXId dexId;
        IPortalTypes.V3LPFeeProfile lpFeeProfile;
        // V3 tax fields
        uint16 buyTaxRate;
        uint16 sellTaxRate;
        uint64 taxDuration;
        uint64 antiFarmerDuration;
        uint16 mktBps;
        uint16 deflationBps;
        uint16 dividendBps;
        uint16 lpBps;
        uint256 minimumShareBalance;
        address dividendToken;
        address commissionReceiver;
        /// The token version to use (must be TOKEN_TAXED_V3, otherwise reverts with FeatureDisabled)
        IPortalTypes.TokenVersion tokenVersion;
        // vault fields
        address vaultFactory;
        bytes vaultData;
    }

    /// @notice Parameters required to create a V7-style token with an associated vault.
    /// @dev Mirrors upstream `newTokenV7`, then swaps every MARKETING_OR_VAULT receiver to the
    ///      freshly created vault before calling `Portal.newTokenV7`.
    struct NewTokenV7WithVaultParams {
        string name;
        string symbol;
        string meta;
        IPortalTypes.DexThreshType dexThresh;
        bytes32 salt;
        IPortalTypes.MigratorType migratorType;
        address quoteToken;
        uint256 quoteAmt;
        bytes permitData;
        bytes32 extensionID;
        bytes extensionData;
        IPortalTypes.TokenVersion tokenVersion;
        IPortalTypes.DEXId dexId;
        uint64 antiFarmerDuration;
        uint16 buyTaxRate;
        uint16 sellTaxRate;
        uint64 taxDuration;
        address commissionReceiver;
        IPortalTypes.FeeConfig[4] feeConfigs;
        address vaultFactory;
        bytes vaultData;
    }

    /* ========== EVENTS ========== */

    /// @notice Emitted when a new tax token with an associated vault is successfully created
    /// @param token The address of the newly deployed tax token
    /// @param vault The address of the newly created vault that will receive tax revenue
    /// @param vaultFactory The vault factory address that was used to create the vault
    event FlapTaxVaultTokenCreated(address indexed token, address indexed vault, address indexed vaultFactory);

    /// @notice Emitted when a vault factory is registered or its configuration is updated
    /// @param factory The address of the vault factory being registered/updated
    /// @param enabled Whether the factory is enabled for creating new vaults
    /// @param official Whether vaults from this factory should be marked as official
    /// @param riskLevel The risk level classification for vaults from this factory
    event FlapTaxVaultFactoryRegistered(address factory, bool enabled, bool official, RiskLevel riskLevel);

    /// @notice Emitted when a vault factory's category is set during registration or update
    /// @param factory The address of the vault factory
    /// @param category The category classification for vaults from this factory
    event FlapTaxVaultFactoryCategorySet(address factory, VaultCategory category);

    /// @notice Emitted when an adapter is registered for a legacy tax token
    /// @param taxToken The address of the tax token
    /// @param adapter The address of the adapter contract
    event AdapterRegistered(address indexed taxToken, address indexed adapter);

    /// @notice Emitted when a new audit report is submitted
    /// @param taxToken The address of the tax token being audited
    /// @param auditor The address of the auditor
    /// @param riskLevel The risk level classification from this audit
    /// @param ipfsCid The IPFS CID of the audit report
    event AuditReportSubmitted(address indexed taxToken, address indexed auditor, RiskLevel riskLevel, string ipfsCid);

    /// @notice Emitted when a new audit report is submitted for a vault factory
    /// @param factory The address of the vault factory being audited
    /// @param auditor The address of the auditor
    /// @param riskLevel The risk level classification from this audit
    /// @param ipfsCid The IPFS CID of the audit report
    event FactoryAuditReportSubmitted(
        address indexed factory, address indexed auditor, RiskLevel riskLevel, string ipfsCid
    );

    /// @notice Emitted when a vault's category is updated
    /// @param taxToken The address of the tax token
    /// @param category The new category
    event VaultCategoryUpdated(address indexed taxToken, VaultCategory category);

    /// @notice Emitted when a factory's category is updated
    /// @param factory The address of the vault factory
    /// @param category The new category
    event FactoryCategoryUpdated(address indexed factory, VaultCategory category);

    /* ========== ERRORS ========== */

    /// @notice Thrown when the provided tax rate is invalid (0 or > 1000 basis points)
    /// @param taxRate The invalid tax rate that was provided
    error InvalidTaxRate(uint256 taxRate);

    /// @notice Thrown when mktBps is invalid (must be > 0)
    error InvalidMktBps();

    /// @notice Thrown when V7-style fee configs are malformed.
    /// @dev Used for wrapper-level validation such as missing MARKETING_OR_VAULT buckets.
    error InvalidFeeConfig();

    /// @notice Thrown when an unsupported quote token is specified
    /// @param quoteToken The address of the unsupported quote token
    error UnsupportedQuoteToken(address quoteToken);

    /// @notice Thrown when attempting to use a vault factory that is not registered
    /// @param factory The address of the unregistered vault factory
    error VaultFactoryNotRegistered(address factory);

    /// @notice Thrown when the predicted token address does not match the required vanity suffix
    /// @param predictedAddress The predicted address that failed the vanity check
    error InvalidVanity(address predictedAddress);

    /// @notice Thrown when trying to get vault info for a token that has no associated vault
    /// @param taxToken The address of the tax token with no vault
    error VaultNotFound(address taxToken);

    /// @notice Thrown when token address does not match predicted address
    error TokenAddressMismatch();

    /// @notice Thrown when BNB transfer fails
    error BnbTransferFailed();

    /// @notice Thrown when a non-V3 tax token version is specified (only TOKEN_TAXED_V3 is allowed)
    error OnlyV3TaxTokenAllowed();

    /// @notice Thrown when a requested feature is not yet enabled
    error FeatureDisabled();

    /// @notice Thrown when portal address is zero
    error ZeroPortalAddress();

    /// @notice Thrown when token implementation address is zero
    error ZeroTokenImplAddress();

    /// @notice Thrown when trying to perform an operation on a non-existent token
    /// @param taxToken The address of the non-existent tax token
    error TokenNotFound(address taxToken);

    /// @notice error when user is rate limited from creating tokens
    /// @param user The address that is rate limited
    /// @param lastCreationTime The timestamp of the user's last successful token creation
    error RateLimitExceeded(address user, uint256 lastCreationTime);
}

/// @title IVaultPortal
/// @notice Interface for the VaultPortal contract that manages vault-backed token launches
/// @dev VaultPortal acts as a registry and factory orchestrator for different vault types
/// @dev It coordinates token launches with their associated revenue vaults
interface IVaultPortal is IVaultPortalTypes {
    /* ========== FUNCTIONS ========== */

    /// @notice Get information about a registered vault factory
    /// @param factory The address of the vault factory
    /// @return enabled Whether this factory can be used to create new vaults
    /// @return official Whether vaults created by this factory are marked as official/endorsed
    /// @return riskLevel The risk level classification for vaults from this factory
    /// @return reserved Reserved space for future upgrades (29 bytes)
    function vaultFactories(address factory)
        external
        view
        returns (bool enabled, bool official, RiskLevel riskLevel, bytes29 reserved);
    /* ========== FUNCTIONS ========== */

    /// @notice Deprecated. Use newTokenV6WithVault instead.
    /// @dev This function previously created a V1/V2 tax token via Portal's newTokenV5.
    ///      It is no longer supported. Calling it will always revert.
    /// @param params Unused - kept for ABI compatibility only.
    function newTaxTokenWithVault(NewTaxTokenWithVaultParams calldata params)
        external
        payable
        returns (address token);

    /// @notice Create a new tax token via Portal's newTokenV6 with an associated vault in a single transaction
    /// @dev Only TOKEN_TAXED_V3 is currently supported as tokenVersion; any other version reverts with FeatureDisabled.
    /// @param params The parameters for creating the tax token and vault (mirrors NewTokenV6Params, minus beneficiary)
    /// @return token The address of the newly created tax token
    function newTokenV6WithVault(NewTokenV6WithVaultParams calldata params) external payable returns (address token);

    /// @notice Create a new token via a V7-style fee-config API with an associated vault.
    /// @dev Supports TOKEN_V3_PERMIT (non-tax) and TOKEN_TAXED_V3 (tax). The wrapper creates the vault first,
    ///      then rewrites MARKETING_OR_VAULT receivers to that vault before calling Portal.newTokenV7.
    /// @param params The parameters for creating the token and vault (mirrors upstream newTokenV7 launch UX)
    /// @return token The address of the newly created token
    function newTokenV7WithVault(NewTokenV7WithVaultParams calldata params) external payable returns (address token);

    /// @notice Predict the address of a tax token V1 given a salt
    /// @dev Uses CREATE2 deterministic address prediction
    /// @dev Useful for generating valid salts that produce the required vanity suffix
    /// @param salt The salt for deterministic deployment
    /// @return predictedAddress The predicted address of the tax token
    function predictTaxTokenV1Address(bytes32 salt) external view returns (address predictedAddress);

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

    /// @notice Register a new vault factory or update an existing one (backward-compatible overload)
    /// @dev Only accounts with VAULT_ADMIN_ROLE can call this function
    /// @dev Allows enabling/disabling factories and updating their official/riskLevel status
    /// @dev Category defaults to VaultCategory.NONE
    /// @param factory The address of the vault factory to register/update
    /// @param enabled Whether the factory should be enabled for creating new vaults
    /// @param official Whether vaults from this factory should be marked as official
    /// @param riskLevel The risk level classification for vaults from this factory
    function registerVaultFactory(address factory, bool enabled, bool official, RiskLevel riskLevel) external;

    /// @notice Register a new vault factory or update an existing one with a specific category
    /// @dev Only accounts with VAULT_ADMIN_ROLE can call this function
    /// @dev Allows enabling/disabling factories and updating their official/riskLevel/category status
    /// @param factory The address of the vault factory to register/update
    /// @param enabled Whether the factory should be enabled for creating new vaults
    /// @param official Whether vaults from this factory should be marked as official
    /// @param riskLevel The risk level classification for vaults from this factory
    /// @param category The category classification for vaults from this factory
    function registerVaultFactory(
        address factory,
        bool enabled,
        bool official,
        RiskLevel riskLevel,
        VaultCategory category
    ) external;

    /// @notice Register an adapter for a legacy tax token vault
    /// @dev Only accounts with AUDITOR_ROLE can call this function
    /// @dev The adapter must implement the VaultBase interface for compatibility
    /// @param taxToken The address of the tax token
    /// @param adapter The address of the adapter contract
    function registerAdapter(address taxToken, address adapter) external;

    /// @notice Submit a new audit report for a tax token
    /// @dev Only accounts with AUDITOR_ROLE can call this function
    /// @dev The tax token must exist (have a vault or adapter registered)
    /// @dev This may change the risk level of the token
    /// @param taxToken The address of the tax token being audited
    /// @param riskLevel The risk level classification from this audit
    /// @param ipfsCid The IPFS CID of the audit report document
    function submitAuditReport(address taxToken, RiskLevel riskLevel, string calldata ipfsCid) external;

    /// @notice Submit a new audit report for a vault factory
    /// @dev Only accounts with VAULT_ADMIN_ROLE can call this function
    /// @dev The factory should be registered or have existing audit reports
    /// @param factory The address of the vault factory being audited
    /// @param riskLevel The risk level classification from this audit
    /// @param ipfsCid The IPFS CID of the audit report document
    function submitFactoryAuditReport(address factory, RiskLevel riskLevel, string calldata ipfsCid) external;

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

    /// @notice Get the category of a vault
    /// @param taxToken The tax token address
    /// @return category The category of the vault
    function getVaultCategory(address taxToken) external view returns (VaultCategory category);

    /// @notice Get the category of a vault factory
    /// @param factory The vault factory address
    /// @return category The category of the factory
    function getFactoryCategory(address factory) external view returns (VaultCategory category);

    /// @notice Set the category of a vault
    /// @dev Only accounts with VAULT_ADMIN_ROLE can call this function
    /// @param taxToken The tax token address
    /// @param category The new category
    function setVaultCategory(address taxToken, VaultCategory category) external;

    /// @notice Set the category of a vault factory
    /// @dev Only accounts with VAULT_ADMIN_ROLE can call this function
    /// @param factory The vault factory address
    /// @param category The new category
    function setFactoryCategory(address factory, VaultCategory category) external;
}

```
