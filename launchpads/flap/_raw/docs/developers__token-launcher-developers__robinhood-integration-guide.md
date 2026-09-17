> For the complete documentation index, see [llms.txt](https://docs.flap.sh/flap/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://docs.flap.sh/flap/developers/token-launcher-developers/robinhood-integration-guide.md).

# Robinhood Chain Integration Guide

> **TL;DR for terminal/bot integrators** — everything you need is in the table below. Skip the rest of the doc unless you need more context.

## Quick Reference

| # | Question                                               | Answer                                                                                                                                                                  |
| - | ------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1 | **Which token versions are supported?**                | Only **2** on Robinhood Chain: **Non-Tax Token** (`TOKEN_V2_PERMIT`) and **Tax Token V3** (`TOKEN_TAXED_V3`). All other token versions revert with `FeatureDisabled()`. |
| 2 | **Which migrator is supported?**                       | **`V2_MIGRATOR`** only, for both token types. `V3_MIGRATOR`, `V4_UNI_MIGRATOR`, `PCS_INFINITY_CL_MIGRATOR` all revert.                                                  |
| 3 | **What DEX are tokens migrated to?**                   | **Uniswap V2** (native fork on Robinhood Chain).                                                                                                                        |
| 4 | **Token implementation address + vanity suffix?**      | See table below.                                                                                                                                                        |
| 5 | **Bonding curve params per token type + quote token?** | See table below.                                                                                                                                                        |

### Deployed contract addresses (Robinhood Chain)

| Name                                                   | Address                                      | Notes                                                         |
| ------------------------------------------------------ | -------------------------------------------- | ------------------------------------------------------------- |
| Portal (proxy)                                         | `0x26605f322f7fF986f381bB9A6e3f5DAb0bEaEb09` | Main entry point for launches, trading, and token state reads |
| Standard Token Impl (Non-Tax Token, `TOKEN_V2_PERMIT`) | `0x88882688a067FE97E11C2185b996286e53132222` | Vanity suffix: `8888` · launched via `newTokenV5`             |
| Tax Token V3 Impl (`TOKEN_TAXED_V3`)                   | `0x7777C8743C88B3aff3cf262135beF2c8b2e83333` | Vanity suffix: `7777` · launched via `newTokenV6`             |
| VaultPortal                                            | `0xe9F7AB7DE8FB8756acbB6a1cd13316a43308197B` | Vault-integrated launch path                                  |
| Tax Token Helper                                       | `0xb10bD2672aE63735d677164A54B573a016f0203C` |                                                               |

Full cross-chain address list: [Deployed Contract Addresses](/flap/developers/deployed-contract-addresses.md).

### Bonding curve parameters

| Token Version | Quote Token               | Curve                 | Graduation Depth |
| ------------- | ------------------------- | --------------------- | ---------------- |
| Non-Tax Token | Native ETH (`address(0)`) | `CURVE_RH_TOSHI_5ETH` | \~5 ETH          |
| Tax Token V3  | Native ETH (`address(0)`) | `CURVE_RH_TOSHI_5ETH` | \~5 ETH          |

Native ETH (`address(0)`) is currently the only enabled quote token on Robinhood Chain, for both token types. Always confirm live config before integrating (see §2 below).

### Required launch params by token type

| Field                                  | Non-Tax Token (`newTokenV5`)    | Tax Token V3 (`newTokenV6`) |
| -------------------------------------- | ------------------------------- | --------------------------- |
| `tokenVersion`                         | n/a (implicit via `newTokenV5`) | `TOKEN_TAXED_V3`            |
| `taxRate` / `buyTaxRate`+`sellTaxRate` | `taxRate = 0`                   | non-zero                    |
| `migratorType`                         | `V2_MIGRATOR`                   | `V2_MIGRATOR`               |
| `quoteToken`                           | `address(0)`                    | `address(0)`                |

***

## 1. Token Versions & Launch Details

### Non-Tax Token

The only entry point that reaches the non-tax implementation on Robinhood Chain is:

```solidity
function newTokenV5(NewTokenV5Params calldata params) external payable returns (address token);
```

```solidity
IPortalTypes.NewTokenV5Params memory p;
p.name = "My Token";
p.symbol = "MTK";
p.meta = "";
p.dexThresh = IPortalCommonTypes.DexThreshType.FOUR_FIFTHS;
p.salt = salt; // vanity salt targeting the 8888 suffix
p.taxRate = 0;
p.migratorType = IPortalTypes.MigratorType.V2_MIGRATOR;
p.quoteToken = address(0);
p.quoteAmt = 0;
p.beneficiary = msg.sender;
p.dexId = IPortalTypes.DEXId.DEX0;
p.lpFeeProfile = IPortalTypes.V3LPFeeProfile.LP_FEE_PROFILE_STANDARD;
p.antiFarmerDuration = 1 days;

address token = portal.newTokenV5(p);
```

Public interface:

```solidity
interface IFlapNonTaxToken {
    function initialize(InitParams memory params) external;
    function removeTransferConstraints() external;      // owner-only, called by the migrator
    function metaURI() external view returns (string memory);
    function maxSupply() external view returns (uint256); // 1,000,000,000 ether for all launches
    function pools() external view returns (address v2, address v3);
    function antiFarmerExpirationTime() external view returns (uint256);
}
```

### Tax Token V3

```solidity
function newTokenV6(NewTokenV6Params calldata params) external payable returns (address token);
```

Robinhood Chain only accepts `tokenVersion == TOKEN_TAXED_V3` with `migratorType == V2_MIGRATOR` on this entry point — any other combination reverts with `FeatureDisabled()`.

***

## 2. Curve

Verify the live configuration on-chain before integrating (applies to both token types, since both currently use the same native-ETH quote config):

```solidity
IPortalTypes.QuoteTokenConfiguration memory config = portal.getQuoteTokenConfiguration(address(0));
require(config.enabled == 1, "native ETH quote not enabled");
require(
    uint8(config.defaultCurve) == uint8(IPortalCommonTypes.CurveType.CURVE_RH_TOSHI_5ETH),
    "unexpected curve"
);
```

### Bonding curve lifecycle (pre-graduation)

While a token is in its pre-graduation phase, **all transfers to or from any registered pool are blocked**. Only wallet-to-wallet transfers are allowed — this prevents any DEX liquidity provisioning or direct pool interaction before the token has graduated.

Buys and sells go through the standard Portal trade path:

```solidity
uint256 tokensOut = portal.swapExactInput{value: ethIn}(
    IPortalTradeV2.ExactInputParams({
        inputToken: address(0),
        outputToken: token,
        inputAmount: ethIn,
        minOutputAmount: 0,
        permitData: ""
    })
);
```

Graduation occurs automatically once the configured `DexThreshType` supply fraction has been sold on the curve (default `FOUR_FIFTHS`, i.e. 80% of supply):

```solidity
IPortalTypes.TokenStateV8Safe memory state = portal.getTokenV8Safe(token);
bool graduated = state.status == IPortalTypes.TokenStatus.DEX;
```

Observed graduation depth for the non-tax token (verified against the live Robinhood RPC, 1 ETH buy steps): graduation consistently occurs at the 6th buy round, just above 5 ETH cumulative spend.

***

## 3. Migration

Both supported token types (Non-Tax, Tax V3) migrate exclusively to **Uniswap V2** via `V2_MIGRATOR` — no other migrator type is accepted on this chain.

**Why the non-tax token is V2-only:** its `mainPool` is set to the Uniswap V2 pair address at initialization. During the post-graduation anti-farmer window, only `mainPool` is exempt from the pool-transfer block (see below). A V3/V4 migration would need to LP into a different, non-exempt pool address, which the anti-farmer check would then block — causing the migration itself to revert.

### Migration flow (non-tax token)

1. **Graduation trigger** — once bonding-curve supply crosses the DEX threshold, the Portal migrates the token's liquidity to a Uniswap V2 pool.
2. **Transfer-constraint release** — the migrator calls `IFlapNonTaxToken(token).removeTransferConstraints()` (owner-only). This starts the anti-farmer expiry countdown (`antiFarmerExpirationTime = now + antiFarmerDuration`).
3. **LP provisioning** — the remaining token balance and collected ETH reserve are added to the Uniswap V2 pair (`mainPool`), which is exempt from the anti-farmer block.

### Anti-farmer enforcement (non-tax token, post-graduation)

| Phase                                               | Behavior                                                                 |
| --------------------------------------------------- | ------------------------------------------------------------------------ |
| Pre-graduation                                      | ALL pool transfers blocked (both directions)                             |
| Anti-farmer window (post-graduation, before expiry) | Transfers to/from `mainPool` allowed; all other registered pools blocked |
| Free (after expiry)                                 | No restrictions — any transfer succeeds                                  |

This is a **hard revert**, not a tax — the non-tax token has no fee mechanism at all.

```solidity
uint256 expiry = IFlapNonTaxToken(token).antiFarmerExpirationTime();
bool antiFarmerActive = expiry != 0 && block.timestamp <= expiry;

(address v2Pool, address v3Pool) = IFlapNonTaxToken(token).pools();
```

**Scope limitation:** the block only applies to pools registered at initialization time — an address outside that set is not tracked and is not blocked. Anti-farmer here raises friction on the known/expected venues; it does not prevent farming through arbitrary unlisted pools.

### Trading after graduation

Once the anti-farmer window has expired (or when routing through `mainPool`, which is always exempt), trading is a normal Uniswap V2 swap. Continuing to route through the Portal also works:

```solidity
uint256 tokensOut = portal.swapExactInput{value: ethIn}(
    IPortalTradeV2.ExactInputParams({
        inputToken: address(0),
        outputToken: token,
        inputAmount: ethIn,
        minOutputAmount: 0,
        permitData: ""
    })
);
```

***

## Reference

* Deployed addresses: [Deployed Contract Addresses](/flap/developers/deployed-contract-addresses.md)
