# Flap - Token Version Specification

> Source: https://docs.flap.sh/flap/developers/wallet-and-terminal-and-bot-developers/token-version-specification
> Retrieved: 2026-09-02 (GitBook markdown export, https://docs.flap.sh/flap/developers/wallet-and-terminal-and-bot-developers/token-version-specification.md)

---

> For the complete documentation index, see [llms.txt](https://docs.flap.sh/flap/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://docs.flap.sh/flap/developers/wallet-and-terminal-and-bot-developers/token-version-specification.md).

# Token Version Specification

### Overview

The `TokenVersion` field is an enum that indicates which token implementation is being used for a specific token. This field is crucial for determining the capabilities and features available for each token launched through the Portal contract.

### TokenVersion Enum Values

```solidity
    /// @dev Token version
    /// Which token implementation is used
    enum TokenVersion {
        TOKEN_LEGACY_MINT_NO_PERMIT,
        TOKEN_LEGACY_MINT_NO_PERMIT_DUPLICATE, // for historical reasons, both 0 and 1 are the same: TOKEN_LEGACY_MINT_NO_PERMIT
        TOKEN_V2_PERMIT, // 2
        TOKEN_GOPLUS, // 3
        TOKEN_TAXED, // 4: The original tax token (FlapTaxToken)
        TOKEN_TAXED_V2, // 5: The new advanced tax token (FlapTaxTokenV2)
        TOKEN_TAXED_V3, // 6: The next-generation tax token with asymmetric buy/sell rates (FlapTaxTokenV3)
        TOKEN_V3_PERMIT // 7: Non-tax token using TokenV3 implementation with permit support

    }
```

The `TokenVersion` has the following values:

| Value | Name                                    | Description                                                                                                               |
| ----- | --------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| 0     | `TOKEN_LEGACY_MINT_NO_PERMIT`           | Legacy token implementation without permit functionality                                                                  |
| 1     | `TOKEN_LEGACY_MINT_NO_PERMIT_DUPLICATE` | Historical duplicate (identical to value 0)                                                                               |
| 2     | `TOKEN_V2_PERMIT`                       | V2 token implementation with EIP-2612 permit support                                                                      |
| 3     | `TOKEN_GOPLUS`                          | Token implementation with GoPlus security integration                                                                     |
| 4     | `TOKEN_TAXED`                           | Original tax token implementation (FlapTaxToken)                                                                          |
| 5     | `TOKEN_TAXED_V2`                        | Advanced tax token implementation (FlapTaxTokenV2)                                                                        |
| 6     | `TOKEN_TAXED_V3`                        | Next-generation tax token with asymmetric buy/sell rates (FlapTaxTokenV3)                                                 |
| 7     | `TOKEN_V3_PERMIT`                       | Non-tax TokenV3 implementation with permit support, designed for PancakeSwap Infinity CL or Uniswap v4 style integrations |

#### Version Details

* **TOKEN\_LEGACY\_MINT\_NO\_PERMIT (0 & 1)**: The obsolete token implementation. Due to historical reasons, both values 0 and 1 represent the same implementation type.
* **TOKEN\_V2\_PERMIT (2)**: Enhanced token with permit functionality allowing gasless approvals via signed messages (EIP-2612 standard).
* **TOKEN\_GOPLUS (3)**: Token integrated with GoPlus security features for enhanced safety and verification. (Not Used in current deployments)
* **TOKEN\_TAXED (4)**: The first generation tax token (`FlapTaxToken`) that implements tax mechanisms on transfers.
* **TOKEN\_TAXED\_V2 (5)**: The second generation tax token (`FlapTaxTokenV2`) with advanced tax features and improvements over the original tax token.
* **TOKEN\_TAXED\_V3 (6)**: The third generation tax token (`FlapTaxTokenV3`) with asymmetric buy/sell tax rates, commission receiver support, and bidirectional dynamic liquidation threshold. Launched via `newTokenV6`. This is the recommended token type for all new integrations.
* **TOKEN\_V3\_PERMIT (7)**: A zero-tax token (`taxRate = 0`) using the TokenV3 implementation with permit support. This version is intended for launches that combine with PancakeSwap Infinity CL or Uniswap v4 style liquidity flows, and is created via `newTokenV7`.

### How to Get Token Version

There are two primary methods to retrieve the token version for a specific token:

#### Method 1: Index from Events

The protocol emits a `TokenVersionSet` event whenever a token's version is set or updated. You can listen to this event or query historical events to determine a token's version.

**Event Definition:**

```solidity
event TokenVersionSet(address token, TokenVersion version);
```

**Example Usage:**

* Listen for `TokenVersionSet` events on the Portal contract
* Filter events by the token address
* The `version` parameter contains the `TokenVersion` enum value

#### Method 2: Using getTokenV\* Methods

The Portal contract provides multiple view functions to query token state, each returning progressively more fields. All of these methods include the `tokenVersion` field in their return values.

**Available Methods:**

1. **getTokenV5** - Returns `TokenStateV5` structure

   ```solidity
   function getTokenV5(address token) external view returns (TokenStateV5 memory state);
   ```
2. **getTokenV6** - Returns `TokenStateV6` structure

   ```solidity
   function getTokenV6(address token) external view returns (TokenStateV6 memory state);
   ```
3. **getTokenV7** - Returns `TokenStateV7` structure

   ```solidity
   function getTokenV7(address token) external view returns (TokenStateV7 memory state);
   ```
4. **getTokenV8** - Returns `TokenStateV8` structure with asymmetric `buyTaxRate` and `sellTaxRate` (BNB mainnet & testnet only)

   ```solidity
   function getTokenV8(address token) external view returns (TokenStateV8 memory state);
   ```
5. **getTokenV8Safe** - Returns `TokenStateV8Safe` with enum fields as `uint8` for forward compatibility (BNB mainnet & testnet only)

   ```solidity
   function getTokenV8Safe(address token) external view returns (TokenStateV8Safe memory state);
   ```

**All TokenState structures include:**

* `TokenVersion tokenVersion` - The version of the token implementation

**Example Usage:**

```solidity
// Using getTokenV8 on BNB mainnet/testnet (recommended - includes asymmetric tax rates)
TokenStateV8 memory state = portal.getTokenV8(tokenAddress);
TokenVersion version = state.tokenVersion;
uint256 buyTax = state.buyTaxRate;
uint256 sellTax = state.sellTaxRate;

// Using getTokenV7 on other networks
TokenStateV7 memory state = portal.getTokenV7(tokenAddress);
TokenVersion version = state.tokenVersion;
```
