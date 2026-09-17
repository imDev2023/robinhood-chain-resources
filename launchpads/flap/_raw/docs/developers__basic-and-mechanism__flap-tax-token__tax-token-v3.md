> For the complete documentation index, see [llms.txt](https://docs.flap.sh/flap/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://docs.flap.sh/flap/developers/basic-and-mechanism/flap-tax-token/tax-token-v3.md).

# Tax Token V3

{% hint style="info" %}
`FlapTaxTokenV3` (`TOKEN_TAXED_V3`) is the recommended token type for all new integrations. It is launched via the `newTokenV6` entry point on Portal v5.9.0+.
{% endhint %}

## Overview

Tax Token V3 introduces four major capabilities over V1/V2:

1. **Asymmetric buy/sell tax rates** — independent rates for buys and sells.
2. **Commission receiver** — a permanent, protocol-enforced fee share for third-party launchpad integrators.
3. **Unified launcher (`newTokenV6`)** — single entry point for all current token types.
4. **Bidirectional dynamic liquidation threshold** — self-correcting threshold that prevents permanent drift in either direction.

***

## 1. Asymmetric buy / sell tax rates

`FlapTaxTokenV3` supports independent buy and sell tax rates, enabling configurations such as a low buy tax (to encourage accumulation) and a higher sell tax (to discourage dumping), or the reverse.

### Reading tax rates on-chain

```solidity
IFlapTaxTokenV3 token = IFlapTaxTokenV3(tokenAddress);

uint16 buy  = token.buyTaxRate();   // e.g. 300  (3%)
uint16 sell = token.sellTaxRate();  // e.g. 1000 (10%)
uint16 eff  = token.taxRate();      // max(buy, sell) — backward-compatible single rate
```

`taxRate()` always returns `max(buyTaxRate, sellTaxRate)`. This preserves compatibility with existing off-chain systems and aggregators that only understand a single tax rate: they will always see the worst-case value and will never under-report the tax.

### Indexing tax rates from events

Two events are emitted at launch for every V3 tax token:

| Event                                                                       | Contents               | Purpose                                                                              |
| --------------------------------------------------------------------------- | ---------------------- | ------------------------------------------------------------------------------------ |
| `FlapTokenTaxSet(address token, uint256 tax)`                               | `max(buyTax, sellTax)` | Backward-compatible single-rate event; existing indexers continue to work unchanged. |
| `FlapTokenAsymmetricTaxSet(address token, uint256 buyTax, uint256 sellTax)` | Both rates             | New event for systems that support asymmetric rates.                                 |

For symmetric V1/V2 tokens the two events carry the same value. For V3 tokens, always prefer `FlapTokenAsymmetricTaxSet` when available.

**Example log output (buy=300, sell=1000):**

```
FlapTokenTaxSet(token, 1000)                // max of buy and sell
FlapTokenAsymmetricTaxSet(token, 300, 1000) // full asymmetric detail
```

{% hint style="info" %}
Old indexers that only listen to `FlapTokenTaxSet` remain fully functional — they will display the effective (worst-case) rate.
{% endhint %}

### Inspecting a token with `getTokenV8`

The `getTokenV8` helper returns the full token state including separate buy and sell tax rates:

```solidity
IPortalLens.TokenStateV8 memory state = portal.getTokenV8(tokenAddress);

state.buyTaxRate   // e.g. 300  (3%)
state.sellTaxRate  // e.g. 1000 (10%)
state.status       // TokenStatus enum (BondingCurve, DEX, …)
state.price        // current bonding curve price
state.progress     // progress toward DEX graduation (0–1e18)
```

`getTokenV8` is the recommended state query endpoint for any system that needs to display asymmetric tax information. It is a view function and can be called by any EOA or contract.

***

## 2. Commission receiver

### What it is

The commission receiver feature allows any third-party launchpad operator or integrator to earn a **permanent, protocol-enforced fee share** from every tax token they deploy through Flap. Tokens launched with a commission receiver will be visible on Flap and the commission accrues automatically on every taxable transaction (bonding curve buy, DEX buy, and DEX sell), for the entire lifetime of the tax.

### How to enable it

Set `commissionReceiver` to any non-zero address in `NewTokenV6Params`. Only `TOKEN_TAXED_V3` tokens support commission — passing a non-zero receiver for a non-tax token reverts.

```solidity
IPortalTypes.NewTokenV6Params memory params = IPortalTypes.NewTokenV6Params({
    // … other fields …
    tokenVersion:        IPortalTypes.TokenVersion.TOKEN_TAXED_V3,
    commissionReceiver:  0xYourLaunchpadAddress,  // receives commission
    // NOTE: commissionBps is NOT set here — the protocol calculates it
});
```

### How the commission rate is determined

The commission rate is **calculated entirely by the protocol** at token creation time via `_commissionForTax(effectiveTaxRate)`. The integrator cannot specify it. The formula is:

```
effectiveTaxRate = max(buyTaxRate, sellTaxRate)

if effectiveTaxRate <= 100 bps (1%):
    commissionBps = 600  (6% of the post-fee remainder)
else:
    commissionBps = floor(10000 * 6 / effectiveTaxRate)
```

This means commission is inversely proportional to the tax rate:

| Effective tax rate | Commission bps | Commission % |
| ------------------ | -------------- | ------------ |
| 1% (100 bps)       | 600            | 6.0%         |
| 2% (200 bps)       | 300            | 3.0%         |
| 3% (300 bps)       | 200            | 2.0%         |
| 5% (500 bps)       | 120            | 1.2%         |
| 10% (1000 bps)     | 60             | 0.6%         |

{% hint style="info" %}
The maximum possible commission is **6%** of the post-protocol-fee tax remainder, achievable only when the effective tax rate is ≤ 1%.
{% endhint %}

### Reading commission configuration

```solidity
ITaxProcessor processor = ITaxProcessor(IFlapTaxTokenV3(token).taxProcessor());

address receiver = processor.commissionReceiver();     // address(0) if disabled
uint16  bps      = processor.commissionBps();          // rate the protocol set
uint256 pending  = processor.commissionQuoteBalance(); // accrued, not yet dispatched
```

Call `processor.dispatch()` to push accumulated balances (fee, commission, marketing, dividends) to their respective receivers.

***

## 3. `newTokenV6` — unified token launcher

`newTokenV6` is the single entry point for creating **all** current token types. The specific token implementation is selected via the `tokenVersion` field:

| `tokenVersion`    | Enum value | Token type                  | Allowed tax rates                          | Commission  |
| ----------------- | ---------- | --------------------------- | ------------------------------------------ | ----------- |
| `TOKEN_V2_PERMIT` | 1          | Standard ERC-20 with permit | none (must be 0)                           | not allowed |
| `TOKEN_TAXED`     | 2          | FlapTaxToken V1             | symmetric only; `mktBps` must be 10000     | not allowed |
| `TOKEN_TAXED_V2`  | 4          | FlapTaxTokenV2              | symmetric only; `mktBps` must not be 10000 | not allowed |
| `TOKEN_TAXED_V3`  | **6**      | FlapTaxTokenV3              | asymmetric allowed; any valid distribution | supported   |

{% hint style="warning" %}
`TOKEN_TAXED` and `TOKEN_TAXED_V2` are deprecated and will be removed in a future release. New integrations should always use `TOKEN_TAXED_V3`.
{% endhint %}

### Salt computation

When computing the vanity salt off-chain, always use the **`tokenImplTaxedV3` implementation address** as the clone base, regardless of the `mktBps` or distribution parameters you intend to use:

```solidity
// Always use tokenImplTaxedV3 for TOKEN_TAXED_V3 salt vanity search
bytes32 salt = _findVanitySalt(VanityType.VANITY_7777, tokenImplTaxedV3, portalAddress);
```

### Launching with a vault: `IVaultPortal.newTokenV6WithVault`

`IVaultPortal` exposes `newTokenV6WithVault` for integrators that want to attach a revenue vault to a `TOKEN_TAXED_V3` token in the same transaction. Only `TOKEN_TAXED_V3` is accepted — any other `tokenVersion` reverts with `OnlyV3TaxTokenAllowed`.

```solidity
IVaultPortalTypes.NewTokenV6WithVaultParams memory params = IVaultPortalTypes.NewTokenV6WithVaultParams({
    // … same fields as NewTokenV6Params (without beneficiary) …
    tokenVersion:  IPortalTypes.TokenVersion.TOKEN_TAXED_V3,
    vaultFactory:  0xYourVaultFactory, // any factory; unregistered → UNVERIFIED
    vaultData:     abi.encode(/* vault-specific init data */)
});

address token = vaultPortal.newTokenV6WithVault(params);
```

The vault address can be retrieved after creation via `IVaultPortal.getVault(token)`.

### Dividend token

`FlapTaxTokenV3` always deploys a Dividend contract, regardless of the `dividendBps` value. This means you can launch a token with `dividendBps == 0` and still have a fully functional share-tracking contract attached.

#### Supported dividend token modes

There are three modes for the `dividendToken` field:

| Mode                         | `dividendToken` value                                                | Description                                                                                                                                                                   |
| ---------------------------- | -------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Case 1 — Launching Token** | `0xfEEDFEEDfeEDFEedFEEdFEEDFeEdfEEdFeEdFEEd` (`MAGIC_DIVIDEND_SELF`) | The tax token itself is distributed as dividend. Holders earn more of the same token.                                                                                         |
| **Case 2 — Quote Token**     | `address(0)` (native) or `quoteToken` address                        | The quote token (e.g. WBNB, USDT) is distributed as dividend. This is the simplest and most common setup.                                                                     |
| **Case 3 — Any ERC-20**      | Any ERC-20 contract address                                          | Any token with sufficient DEX liquidity can be used. The protocol swaps the collected quote token into the dividend token automatically on every dispatch via `SwapRegistry`. |

{% hint style="info" %}
**`MAGIC_DIVIDEND_SELF`** (`0xfEEDFEEDfeEDFEedFEEdFEEDFeEdfEEdFeEdFEEd`) is a sentinel address recognised by the Portal. When you pass this value, the protocol resolves it to the actual tax token address after the token is created.
{% endhint %}

#### Case 3 eligibility — SwapRegistry

For Case 3, the protocol checks at launch time that a valid swap path exists from the quote token to the chosen dividend token. If the pair is not supported, the transaction reverts with `DividendSwapNotSupported`.

You can check eligibility before launching:

```solidity
ISwapRegistry registry = ISwapRegistry(swapRegistryAddress);

// Simple boolean check
bool supported = registry.isSwapSupported(quoteToken, dividendToken);

// Detailed check — returns (supported, errorCode, errorMessage)
(bool ok, uint8 code, string memory reason) =
    registry.isSwapSupportedWithDetailedErrors(quoteToken, dividendToken);
```

**Trust status** — the `SwapRegistry` assigns a trust level to every dividend token:

| Value  | Meaning                                                                                                     |
| ------ | ----------------------------------------------------------------------------------------------------------- |
| `0x00` | Unknown — token is not vetted; the Flap UI shows a warning to users                                         |
| `0x01` | Whitelisted — token is audited/vetted by Flap                                                               |
| `0x02` | Blacklisted — token is known-malicious; dividend conversion is silently skipped (no revert during dispatch) |

```solidity
uint8 trust = registry.getTrustStatus(dividendToken);
bool  blacklisted = registry.isBlacklisted(dividendToken);
```

#### Tracker-only mode (`dividendBps == 0`)

When `dividendBps == 0`, no tax revenue is automatically routed to the Dividend contract, but the contract is still deployed and tracks holder share balances. This is useful for off-chain reward systems that read share data on-chain but push rewards via their own pipeline.

In tracker-only mode, `dividendToken` may be `MAGIC_DIVIDEND_SELF` (`0xfEEDFEEDfeEDFEedFEEdFEEDFeEdfEEdFeEdFEEd`) or any ERC-20 — the swap-path check is skipped because no automatic conversion occurs. Integrators can call `dividend.deposit(token, amount)` manually at any time to distribute any ERC-20 to current share holders.

**`dividendBps` summary:**

| `dividendBps` | Behaviour                                                                                                                     |
| ------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `> 0`         | Tax revenue is automatically routed to the Dividend contract. `dividendToken` must be Case 1, 2, or an eligible Case 3 token. |
| `== 0`        | No automatic payout. Dividend contract exists and tracks shares only. Any `dividendToken` value is accepted.                  |

#### Retrieving the dividend contract

```solidity
address dividendContract = IFlapTaxTokenV3(token).dividendContract();
address sameAddress      = ITaxProcessor(IFlapTaxTokenV3(token).taxProcessor()).dividendAddress();
// dividendContract == sameAddress always holds; both are non-zero for all V3 tokens
```

#### Code examples

```solidity
// Case 1 — tax token itself as dividend
params.quoteToken    = address(0);  // BNB
params.dividendBps   = 500;         // 5%
params.dividendToken = 0xfEEDFEEDfeEDFEedFEEdFEEDFeEdfEEdFeEdFEEd; // MAGIC_DIVIDEND_SELF

// Case 2 — native quote token (address(0) resolves to WBNB)
params.quoteToken    = address(0);
params.dividendBps   = 500;
params.dividendToken = address(0);  // OK — same as quoteToken

// Case 2 — ERC-20 quote token
params.quoteToken    = USDT;
params.dividendBps   = 500;
params.dividendToken = USDT;        // must match quoteToken for Case 2

// Case 3 — any ERC-20 (must be supported by SwapRegistry)
params.quoteToken    = address(0);  // BNB
params.dividendBps   = 500;
params.dividendToken = CAKE;        // any ERC-20 with a registered swap path

// Tracker-only — any dividendToken accepted, no swap-path check
params.dividendBps   = 0;
params.dividendToken = MY_TOKEN;    // no payout, just share tracking
```

#### SwapRegistry deployed addresses

| Network               | SwapRegistry Address                         |
| --------------------- | -------------------------------------------- |
| **BNB Chain Mainnet** | `0x644A8f560138418bAD4EdEFC7c17878a3c2fBEB6` |
| **BNB Chain Testnet** | `0xEd62Df92e52b89C8100F8EC3B8Eefea073df3408` |

***

## 4. Bidirectional dynamic liquidation threshold

### Background

Tax tokens accumulate their own tokens from buy/sell taxes and periodically liquidate (sell) the accumulated balance to the DEX to convert it to the quote token. The **liquidation threshold** governs how many tokens must accumulate before a liquidation is triggered.

### The V1 problem

`FlapTaxTokenV1` had a one-directional threshold: it could only decrease (making liquidations more frequent) but could never recover upward. In adverse market conditions this caused the threshold to drift to its minimum floor permanently, resulting in constant small liquidations that negatively impacted price.

### V3 fix: bidirectional adjustment

`FlapTaxTokenV3` introduces a **fully bidirectional** threshold that self-corrects in both directions after every liquidation. The `TaxProcessor` records a reference expected output amount (`liqExpectedOutputAmount`) at initialization and compares actual DEX swap output against it after each liquidation, returning an `int8 liqThresholdDirection` to the token:

| `liqThresholdDirection` | Market condition                                  | Threshold action                                                        |
| ----------------------- | ------------------------------------------------- | ----------------------------------------------------------------------- |
| `> 0` (positive)        | Swap output **below** reference — price is weak   | Increase threshold by 1% (wait for more tokens before next liquidation) |
| `< 0` (negative)        | Swap output **above** reference — price is strong | Decrease threshold by 1% (liquidate smaller amounts more frequently)    |
| `== 0`                  | Output matched reference                          | No change                                                               |

The threshold is bounded between two implementation-level immutables shared by all clones:

```solidity
FlapTaxTokenV3.MIN_LIQ_THRESHOLD    // hard floor — threshold never goes below this
FlapTaxTokenV3.START_LIQ_THRESHOLD  // starting value and hard ceiling for recovery
```

An individual token also retains `initialLiquidationThreshold` (set to `START_LIQ_THRESHOLD` at creation), which acts as the recovery ceiling. The threshold gradually climbs back toward `initialLiquidationThreshold` as market conditions improve, up to +1% per liquidation event.

### Inspecting the current threshold

```solidity
uint256 threshold  = IFlapTaxTokenV3(token).liquidationThreshold();
uint256 initial    = IFlapTaxTokenV3(token).initialLiquidationThreshold();
uint256 minLimit   = IFlapTaxTokenV3(token).MIN_LIQ_THRESHOLD();
uint256 startLimit = IFlapTaxTokenV3(token).START_LIQ_THRESHOLD();
```

***

## 5. Deployed contract addresses

### `FlapTaxTokenV3` implementation (clone base)

Use this address when computing vanity salts off-chain.

| Network               | Address                                      |
| --------------------- | -------------------------------------------- |
| **BNB Chain Mainnet** | `0x024f18294970B5c76c0691b87f138A0317156422` |
| **BNB Chain Testnet** | `0xE6Ff967a887084c16D0fD71548CF709542cc1557` |

### Example: launching a `TOKEN_TAXED_V3` token

```solidity
address tokenImplTaxedV3 = 0x024f18294970B5c76c0691b87f138A0317156422; // BSC mainnet
bytes32 salt = _findVanitySalt(VanityType.VANITY_7777, tokenImplTaxedV3, address(portal));

IPortalTypes.NewTokenV6Params memory params = IPortalTypes.NewTokenV6Params({
    name:                "My Token",
    symbol:              "MTK",
    meta:                "ipfs://...",
    dexThresh:           IPortalCommonTypes.DexThreshType.FOUR_FIFTHS,
    salt:                salt,
    migratorType:        IPortalTypes.MigratorType.V2_MIGRATOR,
    quoteToken:          address(0),         // BNB
    quoteAmt:            0,
    beneficiary:         msg.sender,
    permitData:          "",
    extensionID:         bytes32(0),
    extensionData:       "",
    dexId:               IPortalTypes.DEXId.DEX0,
    lpFeeProfile:        IPortalTypes.V3LPFeeProfile.LP_FEE_PROFILE_STANDARD,
    buyTaxRate:          300,                // 3% buy tax
    sellTaxRate:         1000,               // 10% sell tax (asymmetric)
    taxDuration:         365 days,
    antiFarmerDuration:  1 days,
    mktBps:              10000,              // 100% of remainder → beneficiary
    deflationBps:        0,
    dividendBps:         0,
    lpBps:               0,
    minimumShareBalance: 0,
    dividendToken:       address(0),         // native → resolved to WETH
    commissionReceiver:  0xYourAddress,      // enable commission
    tokenVersion:        IPortalTypes.TokenVersion.TOKEN_TAXED_V3
});

address token = portal.newTokenV6(params);
```
