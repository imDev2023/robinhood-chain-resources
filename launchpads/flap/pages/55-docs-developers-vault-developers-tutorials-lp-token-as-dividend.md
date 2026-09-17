# Flap - Using an LP Token or Child Token as the Dividend Token

> Source: https://docs.flap.sh/flap/developers/vault-developers/tutorials/lp-token-as-dividend
> Retrieved: 2026-09-02 (GitBook markdown export, https://docs.flap.sh/flap/developers/vault-developers/tutorials/lp-token-as-dividend.md)

---

> For the complete documentation index, see [llms.txt](https://docs.flap.sh/flap/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://docs.flap.sh/flap/developers/vault-developers/tutorials/lp-token-as-dividend.md).

# Using an LP Token or Child Token as the Dividend Token

{% hint style="warning" %}
**Preview.** This document has not been reviewed yet. Content may be incomplete or inaccurate.
{% endhint %}

This tutorial walks you through implementing a vault factory that uses a **computed dividend token** - a token whose address cannot be known before the tax token is deployed, such as a Uniswap/PancakeSwap LP pair or a child token deployed deterministically from the tax token address.

This feature was introduced in **factory spec v2.3**.

***

## The Problem

When launching a token through VaultPortal, the caller must supply a `dividendToken` address - the ERC-20 token that vault holders receive as dividends. Most of the time this is straightforward (e.g. use WBNB, or USDT).

But some vault designs require a dividend token whose address **depends on the tax token address itself**:

* **LP pair tokens** - the PancakeSwap pair for `(taxToken, WBNB)` has an address derived from `taxToken`.
* **Child tokens / receipt tokens** - a token deployed via CREATE2 keyed on `taxToken`.

At launch time the tax token does not exist yet - VaultPortal predicts its address via CREATE2, but the actual deployment happens inside Portal. The `dividendToken` field is needed *before* that deployment, so there is no way to supply the real LP/child address upfront.

***

## The Solution: `MAGIC_DIVIDEND_COMPUTED`

VaultPortal supports a special sentinel value for `dividendToken`:

```solidity
// IPortal.sol
address constant MAGIC_DIVIDEND_COMPUTED =
    address(0xC0Dec0dec0DeC0Dec0dEc0DEC0DEC0DEC0DEC0dE);
```

When the launcher passes `MAGIC_DIVIDEND_COMPUTED` as `dividendToken`, VaultPortal will:

1. Compute the CREATE2-predicted tax token address.
2. Check that the selected vault factory implements **spec v2.3** (`factorySpecVersion()` returns `"v2.3"` or higher).
3. Call `resolveDividendToken(predictedToken, launchVersion, launchParams)` on the factory.
4. Use the returned address as the actual `dividendToken` forwarded to Portal.

If the factory does not support v2.3, the launch reverts with `FactoryDoesNotSupportComputedDividend()`.

***

## Implementation Guide

### Step 1 - Declare spec v2.3 in your factory

Your factory must extend `VaultFactoryBaseV2` and override `factorySpecVersion()` to return `"v2.3"` (or higher):

```solidity
import {VaultFactoryBaseV2} from "flap-sh/FlapTaxVaults/src/interfaces/VaultFactoryBaseV2.sol";
import {IVaultFactoryDividendV23} from "flap-sh/FlapTaxVaults/src/interfaces/IVaultFactory.sol";

contract MyLPVaultFactory is VaultFactoryBaseV2, IVaultFactoryDividendV23 {

    function factorySpecVersion() external pure override returns (string memory) {
        return "v2.3";
    }

    // ... rest of factory
}
```

{% hint style="warning" %}
You **must** also implement `IVaultFactoryDividendV23`. Declaring `"v2.3"` in `factorySpecVersion()` but not implementing `resolveDividendToken` will cause every `MAGIC_DIVIDEND_COMPUTED` launch to revert.
{% endhint %}

***

### Step 2 - Implement `resolveDividendToken`

`IVaultFactoryDividendV23` requires a single function:

```solidity
interface IVaultFactoryDividendV23 {
    function resolveDividendToken(
        address predictedToken,
        uint8   launchVersion,
        bytes   calldata launchParams
    ) external view returns (address dividendToken);
}
```

| Parameter        | Description                                                                                                   |
| ---------------- | ------------------------------------------------------------------------------------------------------------- |
| `predictedToken` | The CREATE2-predicted address of the tax token (not yet deployed)                                             |
| `launchVersion`  | `DIVIDEND_TOKEN_LAUNCH_VERSION_V6` or `DIVIDEND_TOKEN_LAUNCH_VERSION_V7` depending on the launch wrapper used |
| `launchParams`   | ABI-encoded `NewTokenV6WithVaultParams` or `NewTokenV7WithVaultParams`                                        |

VaultPortal calls this as a **`staticcall`**, so the function must be `view` (no state writes).

#### Example - LP pair dividend

This example resolves the PancakeSwap V2 LP pair of `(predictedToken, WBNB)` as the dividend token:

```solidity
import {IUniswapV2Factory} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";

address constant PANCAKE_FACTORY = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73; // BSC mainnet
address constant WBNB            = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

function resolveDividendToken(
    address predictedToken,
    uint8   /* launchVersion */,
    bytes   calldata /* launchParams */
) external view override returns (address dividendToken) {
    // The LP pair is deterministically computable from the two token addresses.
    // PancakeSwap V2 uses the same CREATE2 formula as Uniswap V2.
    dividendToken = IUniswapV2Factory(PANCAKE_FACTORY).getPair(predictedToken, WBNB);

    // If the pair does not exist yet, compute it via CREATE2.
    if (dividendToken == address(0)) {
        dividendToken = _computePairAddress(predictedToken, WBNB);
    }
}

function _computePairAddress(address tokenA, address tokenB)
    internal pure returns (address)
{
    (address t0, address t1) = tokenA < tokenB
        ? (tokenA, tokenB)
        : (tokenB, tokenA);

    bytes32 salt = keccak256(abi.encodePacked(t0, t1));
    // PancakeSwap V2 init code hash on BSC
    bytes32 initCodeHash =
        0x00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5;

    return address(uint160(uint256(keccak256(abi.encodePacked(
        hex"ff",
        PANCAKE_FACTORY,
        salt,
        initCodeHash
    )))));
}
```

#### Example - Child token dividend

If your vault deploys a child token deterministically from the tax token address:

```solidity
function resolveDividendToken(
    address predictedToken,
    uint8   /* launchVersion */,
    bytes   calldata /* launchParams */
) external view override returns (address dividendToken) {
    // Child token is deployed via CREATE2 with `predictedToken` as the salt
    dividendToken = address(uint160(uint256(keccak256(abi.encodePacked(
        hex"ff",
        address(this),        // deployer is the factory itself
        bytes32(uint256(uint160(predictedToken))),
        CHILD_TOKEN_INIT_HASH
    )))));
}
```

***

### Step 3 - Declare a policy so the UI pre-fills the sentinel

`tokenCreationPolicies()` lets the UI know that `dividendToken` **must** equal `MAGIC_DIVIDEND_COMPUTED`. The UI reads this policy and pre-fills (or locks) the field before the user submits the launch form.

```solidity
import {MAGIC_DIVIDEND_COMPUTED} from "./interfaces/IPortal.sol";
import {FactoryPolicy} from "./interfaces/IVaultSchemasV1.sol";

function tokenCreationPolicies()
    public
    pure
    override
    returns (FactoryPolicy[] memory policies)
{
    policies = new FactoryPolicy[](1);
    policies[0] = FactoryPolicy({
        target:      "dividendToken",
        operator:    "eq",
        value:       abi.encode(MAGIC_DIVIDEND_COMPUTED),
        description: "Dividend token must be set to MAGIC_DIVIDEND_COMPUTED. "
                     "The factory will resolve the real LP token address on-chain."
    });
}
```

{% hint style="info" %}
Policies are **advisory hints for the UI only** - they do not enforce anything on-chain. Always pair a policy with the corresponding `_validateBeforeLaunch` check (Step 4) to enforce the rule on-chain.
{% endhint %}

***

### Step 4 - Enforce the sentinel in `_validateBeforeLaunch`

Override `_validateBeforeLaunch` to reject any launch that does not carry `MAGIC_DIVIDEND_COMPUTED`. This is the on-chain enforcement that backs the UI policy declared above.

```solidity
import {LaunchValidationDataV1} from "./interfaces/IVaultFactory.sol";

function _validateBeforeLaunch(LaunchValidationDataV1 memory data)
    internal
    pure
    override
    returns (bool success, string memory reason)
{
    if (data.dividendToken != MAGIC_DIVIDEND_COMPUTED) {
        return (
            false,
            "dividendToken must be MAGIC_DIVIDEND_COMPUTED for this vault type."
        );
    }
    return (true, "");
}
```

`VaultPortal` calls `onBeforeLaunch(bytes)` (which decodes into `_validateBeforeLaunch`) **before** it calls `resolveDividendToken`. This means the hook sees `dividendToken == MAGIC_DIVIDEND_COMPUTED` - the raw sentinel, not yet the resolved LP address. That is the correct value to check against.

{% hint style="warning" %}
Your factory must return `"v2.3"` from `factorySpecVersion()` for `onBeforeLaunch` to be reached. If you return `"v2.1"` or lower, `VaultPortal` will use the legacy `onBeforeNewTokenV6WithVault` path instead.
{% endhint %}

***

### Step 5 - Launch with `MAGIC_DIVIDEND_COMPUTED`

On the caller side, set `dividendToken` to the sentinel when building the launch params:

```solidity
import {MAGIC_DIVIDEND_COMPUTED} from "flap-sh/FlapTaxVaults/src/interfaces/IPortal.sol";

IVaultPortal.NewTokenV6WithVaultParams memory params = IVaultPortal.NewTokenV6WithVaultParams({
    // ... other fields
    dividendToken: MAGIC_DIVIDEND_COMPUTED,   // <-- the key field
    factory:       address(myLPVaultFactory),
    vaultData:     abi.encode(/* your vault config */),
    // ...
});

vaultPortal.newTokenV6WithVault{value: msg.value}(params);
```

VaultPortal will call `myLPVaultFactory.resolveDividendToken(...)` and substitute the result before forwarding the launch to Portal.

***

## What Happens On-Chain (Flow Summary)

```
Caller
  │  dividendToken = MAGIC_DIVIDEND_COMPUTED
  ▼
VaultPortal.newTokenV6WithVault / newTokenV7WithVault
  │  1. Predict tax token address (CREATE2)
  │  2. Check factory spec >= v2.3
  │  3. staticcall factory.resolveDividendToken(predictedToken, ...)
  │     └─ factory returns real LP / child token address
  │  4. Replace dividendToken with resolved address
  │  5. newVault(predictedToken, quoteToken, creator, vaultData)
  │  6. Forward to Portal.newTokenV6WithVault(params with real dividendToken)
  ▼
Portal deploys tax token, links vault
```

***

## Version Gating

| `factorySpecVersion()` | `MAGIC_DIVIDEND_COMPUTED` supported?                   |
| ---------------------- | ------------------------------------------------------ |
| `""` (legacy / V1)     | ❌ reverts with `FactoryDoesNotSupportComputedDividend` |
| `"v2.1"`, `"v2.2"`     | ❌ reverts                                              |
| `"v2.3"` or higher     | ✅ `resolveDividendToken` is called                     |

Factories that do not implement v2.3 are completely unaffected - the new sentinel only triggers for launches that explicitly pass `MAGIC_DIVIDEND_COMPUTED`.

***

## Checklist

* [ ] Factory extends `VaultFactoryBaseV2` and implements `IVaultFactoryDividendV23`
* [ ] `factorySpecVersion()` returns `"v2.3"` or higher
* [ ] `resolveDividendToken` is `view` and always returns a non-zero address
* [ ] `tokenCreationPolicies()` declares `dividendToken eq MAGIC_DIVIDEND_COMPUTED`
* [ ] `_validateBeforeLaunch` rejects any launch where `dividendToken != MAGIC_DIVIDEND_COMPUTED`
* [ ] Launcher passes `MAGIC_DIVIDEND_COMPUTED` as `dividendToken`
* [ ] Launcher selects the v2.3 factory in the launch params
