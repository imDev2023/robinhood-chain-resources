> For the complete documentation index, see [llms.txt](https://docs.flap.sh/flap/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://docs.flap.sh/flap/developers/wallet-and-terminal-and-bot-developers/index-token-created-events.md).

# Index Token Created Events

This page describes how to index newly launched tokens by consuming events emitted by the `Portal` contract.

## Overview

For backward compatibility, a token launch can emit multiple events instead of a single one. Always index `TokenCreated`, then enrich the token record with any optional events that appear in the same transaction.

{% hint style="info" %}
`TokenCreated` only includes the IPFS CID of the metadata. To resolve and parse token metadata, see [Parse Token Meta](/flap/developers/wallet-and-terminal-and-bot-developers/parse-token-meta.md).
{% endhint %}

## Events to index

**Required**

* `TokenCreated`: emitted for every token launch.

**Optional (apply defaults if missing)**

* `TokenCurveSet`: if missing, curve defaults to the first item in `CurveType` (legacy curve, `curveParameter = 16 ether`).
* `TokenCurveSetV2`: starting from v4.7.0, always emitted even for legacy curve.
* `TokenDexSupplyThreshSet`: if missing, defaults to the first item in `DexThreshType` (6.67e8 ether).
* `TokenQuoteSet`: if missing, defaults to native gas token (zero address).
* `TokenMigratorSet`: if missing, defaults to `V3_MIGRATOR`.
* `TokenVersionSet`: if missing, defaults to legacy token version (see [Token version specification](/flap/developers/wallet-and-terminal-and-bot-developers/token-version-specification.md)).
* `FlapTokenTaxSet`: if missing, tax is 0 (non-tax token).
* `FlapTokenStaged`: emitted when a token is staged but not yet created (two-step token launch).
* `TokenExtensionEnabled`: emitted when an extension is enabled for a token.
* `TokenDexPreferenceSet`: if missing, defaults to DEX0 with STANDARD fee profile.
* `FlapTokenAsymmetricTaxSet`: emitted alongside `FlapTokenTaxSet` for Tax Token V3 launches; carries separate buy and sell tax rates. If missing, treat buy and sell rates as equal to the value from `FlapTokenTaxSet`.

## Event reference (arguments and meaning)

### `TokenCreated`

Emitted for every token launch.

* `ts`: block timestamp when the token is created.
* `creator`: address that initiated the token creation.
* `nonce`: portal nonce for this creation (unique per `Portal`).
* `token`: deployed token address.
* `name`: token name.
* `symbol`: token symbol.
* `meta`: IPFS CID of the token metadata JSON.

### `FlapTokenStaged`

Emitted when a token is staged (two-step launch) but not yet created.

* `ts`: block timestamp when staging happens.
* `creator`: address that staged the token.
* `token`: predetermined token address (not yet deployed).

### `TokenCurveSet`

Emitted when the bonding curve configuration is set for legacy curve format.

* `token`: token address.
* `curve`: curve contract address.
* `curveParameter`: curve parameter for the legacy curve (defaults to `16 ether` if missing).

### `TokenCurveSetV2`

Emitted when the bonding curve parameters are set in the newer format.

* `token`: token address.
* `r`: virtual ETH reserve parameter.
* `h`: virtual token reserve parameter.
* `k`: square of virtual liquidity parameter.

### `TokenDexSupplyThreshSet`

Emitted when the DEX listing supply threshold is set.

* `token`: token address.
* `dexSupplyThresh`: circulating supply threshold for DEX listing (defaults to the first `DexThreshType` if missing).

### `TokenQuoteSet`

Emitted when the quote token is set.

* `token`: token address.
* `quoteToken`: quote token address (zero address means native gas token).

### `TokenMigratorSet`

Emitted when the migrator type is set.

* `token`: token address.
* `migratorType`: migrator enum value (`V3_MIGRATOR` or `V2_MIGRATOR`).

### `TokenVersionSet`

Emitted when the token implementation version is set.

* `token`: token address.
* `version`: token version enum value (see [Token version specification](/flap/developers/wallet-and-terminal-and-bot-developers/token-version-specification.md)).

### `FlapTokenTaxSet`

Emitted when a tax is set for a token.

* `token`: token address.
* `tax`: tax rate in basis points (0 means non-tax token).

### `TokenExtensionEnabled`

Emitted when an extension is enabled for a token.

* `token`: token address.
* `extensionID`: extension identifier (bytes32).
* `extensionAddress`: extension contract address.
* `version`: extension interface version.

### `TokenDexPreferenceSet`

Emitted when DEX preference and fee profile are set.

* `token`: token address.
* `dexId`: preferred DEX ID (`DEX0`, `DEX1`, `DEX2`).
* `lpFeeProfile`: preferred V3 LP fee profile (`STANDARD`, `LOW`, `HIGH`).

### `FlapTokenAsymmetricTaxSet`

Emitted for Tax Token V3 (`TOKEN_TAXED_V3`) launches alongside `FlapTokenTaxSet`. Carries the full asymmetric buy and sell tax rates.

* `token`: token address.
* `buyTax`: buy tax rate in basis points.
* `sellTax`: sell tax rate in basis points.

{% hint style="info" %}
`FlapTokenTaxSet` is always emitted for all tax tokens and carries `max(buyTax, sellTax)` for backward compatibility. `FlapTokenAsymmetricTaxSet` is only emitted for V3 tokens. Prefer `FlapTokenAsymmetricTaxSet` when available to get the full asymmetric rate detail.
{% endhint %}

## Suggested indexing flow

1. Listen to `TokenCreated` events on `Portal`.
2. In the same transaction, collect optional events for the same token address.
3. Apply defaults for any missing optional events.
4. Persist the token record and metadata CID.
