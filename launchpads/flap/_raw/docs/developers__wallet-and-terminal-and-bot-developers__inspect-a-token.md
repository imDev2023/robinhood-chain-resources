> For the complete documentation index, see [llms.txt](https://docs.flap.sh/flap/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://docs.flap.sh/flap/developers/wallet-and-terminal-and-bot-developers/inspect-a-token.md).

# Inspect A Token

## Inspect A Token

We have multiple methods for querying the state of a token. The latest ones are `getTokenV8` and `getTokenV8Safe` (currently only available on BNB mainnet and BNB testnet). For other networks, use `getTokenV7`. To avoid the broken code problem, we still reserve the legacy methods `getTokenV2` and `getTokenV3`. We always recommend using the newest available method for your network.

```solidity

/// @notice the state of a token (with dex related fields)
struct TokenStateV2 {
    TokenStatus status; // the status of the token
    uint256 reserve; // the reserve of the token
    uint256 circulatingSupply; // the circulatingSupply of the token
    uint256 price; // the price of the token
    TokenVersion tokenVersion; // the version of the token implementation this token is using
    uint256 r; // the r of the curve of the token
    uint256 dexSupplyThresh; // the cirtulating supply threshold for adding the token to the DEX
}

/// @notice the state of a token (with all V2 fields plus quoteTokenAddress and nativeToQuoteSwapEnabled)
struct TokenStateV3 {
    /// The status of the token (see TokenStatus enum)
    TokenStatus status;
    /// The reserve amount of the quote token held by the bonding curve
    uint256 reserve;
    /// The circulating supply of the token
    uint256 circulatingSupply;
    /// The current price of the token (in quote token units, 18 decimals)
    uint256 price;
    /// The version of the token implementation (see TokenVersion enum)
    TokenVersion tokenVersion;
    /// The curve parameter 'r' used for the bonding curve
    uint256 r;
    /// The circulating supply threshold for adding the token to the DEX
    uint256 dexSupplyThresh;
    /// The address of the quote token (address(0) if native gas token)
    address quoteTokenAddress;
    /// Whether native-to-quote swap is enabled for this token
    bool nativeToQuoteSwapEnabled;
}

/// @notice the state of a token (with all V3 fields plus extensionID and 'r' curve parameter only)
struct TokenStateV4 {
    /// The status of the token (see TokenStatus enum)
    TokenStatus status;
    /// The reserve amount of the quote token held by the bonding curve
    uint256 reserve;
    /// The circulating supply of the token
    uint256 circulatingSupply;
    /// The current price of the token (in quote token units, 18 decimals)
    uint256 price;
    /// The version of the token implementation (see TokenVersion enum)
    TokenVersion tokenVersion;
    /// The curve parameter 'r' used for the bonding curve
    uint256 r;
    /// The circulating supply threshold for adding the token to the DEX
    uint256 dexSupplyThresh;
    /// The address of the quote token (address(0) if native gas token)
    address quoteTokenAddress;
    /// Whether native-to-quote swap is enabled for this token
    bool nativeToQuoteSwapEnabled;
    /// The extension ID used by the token (bytes32(0) if no extension)
    bytes32 extensionID;
}

/// @notice the state of a token (with all V4 fields plus all curve parameters)
struct TokenStateV5 {
    /// The status of the token (see TokenStatus enum)
    TokenStatus status;
    /// The reserve amount of the quote token held by the bonding curve
    uint256 reserve;
    /// The circulating supply of the token
    uint256 circulatingSupply;
    /// The current price of the token (in quote token units, 18 decimals)
    uint256 price;
    /// The version of the token implementation (see TokenVersion enum)
    TokenVersion tokenVersion;
    /// The curve parameter 'r' used for the bonding curve
    uint256 r;
    /// The curve parameter 'h' - virtual token reserve
    uint256 h;
    /// The curve parameter 'k' - square of virtual liquidity
    uint256 k;
    /// The circulating supply threshold for adding the token to the DEX
    uint256 dexSupplyThresh;
    /// The address of the quote token (address(0) if native gas token)
    address quoteTokenAddress;
    /// Whether native-to-quote swap is enabled for this token
    bool nativeToQuoteSwapEnabled;
    /// The extension ID used by the token (bytes32(0) if no extension)
    bytes32 extensionID;
}

/// @notice the state of a token (with all V5 fields plus taxRate, pool, and progress)
struct TokenStateV6 {
    /// The status of the token (see TokenStatus enum)
    TokenStatus status;
    /// The reserve amount of the quote token held by the bonding curve
    uint256 reserve;
    /// The circulating supply of the token
    uint256 circulatingSupply;
    /// The current price of the token (in quote token units, 18 decimals)
    uint256 price;
    /// The version of the token implementation (see TokenVersion enum)
    TokenVersion tokenVersion;
    /// The curve parameter 'r' used for the bonding curve
    uint256 r;
    /// The curve parameter 'h' - virtual token reserve
    uint256 h;
    /// The curve parameter 'k' - square of virtual liquidity
    uint256 k;
    /// The circulating supply threshold for adding the token to the DEX
    uint256 dexSupplyThresh;
    /// The address of the quote token (address(0) if native gas token)
    address quoteTokenAddress;
    /// Whether native-to-quote swap is enabled for this token
    bool nativeToQuoteSwapEnabled;
    /// The extension ID used by the token (bytes32(0) if no extension)
    bytes32 extensionID;
    /// The tax rate in basis points (0 if not a tax token)
    uint256 taxRate;
    /// The DEX pool address (address(0) if not listed on DEX)
    address pool;
    /// The progress towards DEX listing (0 to 1e18, where 1e18 = 100%)
    uint256 progress;
}

/// @notice the state of a token (with all V6 fields plus lpFeeProfile)
struct TokenStateV7 {
    /// The status of the token (see TokenStatus enum)
    TokenStatus status;
    /// The reserve amount of the quote token held by the bonding curve
    uint256 reserve;
    /// The circulating supply of the token
    uint256 circulatingSupply;
    /// The current price of the token (in quote token units, 18 decimals)
    uint256 price;
    /// The version of the token implementation (see TokenVersion enum)
    TokenVersion tokenVersion;
    /// The curve parameter 'r' used for the bonding curve
    uint256 r;
    /// The curve parameter 'h' - virtual token reserve
    uint256 h;
    /// The curve parameter 'k' - square of virtual liquidity
    uint256 k;
    /// The circulating supply threshold for adding the token to the DEX
    uint256 dexSupplyThresh;
    /// The address of the quote token (address(0) if native gas token)
    address quoteTokenAddress;
    /// Whether native-to-quote swap is enabled for this token
    bool nativeToQuoteSwapEnabled;
    /// The extension ID used by the token (bytes32(0) if no extension)
    bytes32 extensionID;
    /// The tax rate in basis points (0 if not a tax token)
    uint256 taxRate;
    /// The DEX pool address (address(0) if not listed on DEX)
    address pool;
    /// The progress towards DEX listing (0 to 1e18, where 1e18 = 100%)
    uint256 progress;
    /// The V3 LP fee profile for the token
    V3LPFeeProfile lpFeeProfile;
    /// The Dex Id
    DEXId dexId;
}

struct TokenStateV8 {
    /// The status of the token (see TokenStatus enum)
    TokenStatus status;
    /// The reserve amount of the quote token held by the bonding curve
    uint256 reserve;
    /// The circulating supply of the token
    uint256 circulatingSupply;
    /// The current price of the token (in quote token units, 18 decimals)
    uint256 price;
    /// The version of the token implementation (see TokenVersion enum)
    TokenVersion tokenVersion;
    /// The curve parameter 'r' used for the bonding curve
    uint256 r;
    /// The curve parameter 'h' - virtual token reserve
    uint256 h;
    /// The curve parameter 'k' - square of virtual liquidity
    uint256 k;
    /// The circulating supply threshold for adding the token to the DEX
    uint256 dexSupplyThresh;
    /// The address of the quote token (address(0) if native gas token)
    address quoteTokenAddress;
    /// Whether native-to-quote swap is enabled for this token
    bool nativeToQuoteSwapEnabled;
    /// The extension ID used by the token (bytes32(0) if no extension)
    bytes32 extensionID;
    /// The buy tax rate in basis points (0 if not a tax token)
    uint256 buyTaxRate;
    /// The sell tax rate in basis points (0 if not a tax token)
    uint256 sellTaxRate;
    /// The DEX pool address (address(0) if not listed on DEX)
    address pool;
    /// The progress towards DEX listing (0 to 1e18, where 1e18 = 100%)
    uint256 progress;
    /// The V3 LP fee profile for the token
    V3LPFeeProfile lpFeeProfile;
    /// The Dex Id
    DEXId dexId;
}

/// @notice A forward-compatible version of TokenStateV8, where enum-typed fields are returned
///         as uint8 instead of their Solidity enum types.
struct TokenStateV8Safe {
    uint8 status;
    uint256 reserve;
    uint256 circulatingSupply;
    uint256 price;
    uint8 tokenVersion;
    uint256 r;
    uint256 h;
    uint256 k;
    uint256 dexSupplyThresh;
    address quoteTokenAddress;
    bool nativeToQuoteSwapEnabled;
    bytes32 extensionID;
    uint256 buyTaxRate;
    uint256 sellTaxRate;
    address pool;
    uint256 progress;
    uint8 lpFeeProfile;
    uint8 dexId;
}

/// @notice Get token state
/// @param token  The address of the token
/// @return state  The state of the token
function getTokenV2(address token) external view returns (TokenStateV2 memory state);
/// @notice Get token state (V3)
/// @param token  The address of the token
/// @return state  The state of the token (V3)
function getTokenV3(address token) external view returns (TokenStateV3 memory state);
/// @notice Get token state (V4)
/// @param token  The address of the token
/// @return state  The state of the token (V4) with only 'r' curve parameter
function getTokenV4(address token) external view returns (TokenStateV4 memory state);
/// @notice Get token state (V5)
/// @param token  The address of the token
/// @return state  The state of the token (V5) with all curve parameters (r, h, k)
function getTokenV5(address token) external view returns (TokenStateV5 memory state); 

/// @notice Get token state (V6)
/// @param token  The address of the token
/// @return state  The state of the token (V6) with all V5 fields plus taxRate, pool, and progress
function getTokenV6(address token) external view returns (TokenStateV6 memory state);
/// @notice Get token state (V7)
/// @param token  The address of the token
/// @return state  The state of the token (V7) with all V6 fields plus lpFeeProfile
function getTokenV7(address token) external view returns (TokenStateV7 memory state);
/// @notice Get token state (V8)
/// @param token  The address of the token
/// @return state  The state of the token (V8) with asymmetric buyTaxRate and sellTaxRate
function getTokenV8(address token) external view returns (TokenStateV8 memory state);
/// @notice Get token state (V8Safe)
/// @dev Returns enum-typed fields (TokenStatus, TokenVersion, V3LPFeeProfile, DEXId) as uint8
///      instead of their Solidity enum types, preventing ABI-decoding reverts when new enum
///      variants are introduced. Use this method when you need forward/backward compatibility
///      with future contract upgrades that may add new enum values.
/// @param token  The address of the token
/// @return state  The state of the token with enum fields encoded as uint8
function getTokenV8Safe(address token) external view returns (TokenStateV8Safe memory state);


/// @dev Token version
/// Which token implementation is used
enum TokenVersion {
    TOKEN_LEGACY_MINT_NO_PERMIT,
    TOKEN_LEGACY_MINT_NO_PERMIT_DUPLICATE, // for historical reasons, both 0 and 1 are the same: TOKEN_LEGACY_MINT_NO_PERMIT
    TOKEN_V2_PERMIT, // 2
    TOKEN_GOPLUS, // 3
    TOKEN_TAXED, // 4: The original tax token (FlapTaxToken)
    TOKEN_TAXED_V2 // 5: The new advanced tax token (FlapTaxTokenV2)

}

/// @dev the quote token, i.e, the token as the reserve
enum QuoteTokenType {
    NATIVE_GAS_TOKEN, // The native gas token
    ERC20_TOKEN_WITH_PERMIT, //  The ERC20 token with permit
    ERC20_TOKEN_WITHOUT_PERMIT // The ERC20 token without permit

}

/// @notice the status of a token
/// The token has 5 statuses:
//    - Tradable: The token can be traded(buy/sell)
//    - InDuel: (obsolete) The token is in a battle, it can only be bought but not sold.
//    - Killed: (obsolete) The token is killed, it can not be traded anymore. Can only be redeemed for another token.
//    - DEX: The token has been added to the DEX
//    - Staged: The token is staged but not yet created (address is predetermined)
enum TokenStatus {
    Invalid, // The token does not exist
    Tradable,
    InDuel, // obsolete
    Killed, // obsolete
    DEX,
    Staged // The token is staged (address determined, but not yet created)

}


/// @notice the V3 LP fee profile
/// @dev determines the LP fee tier to use when migrating tokens to Uniswap V3 or Pancake V3
enum V3LPFeeProfile {
    LP_FEE_PROFILE_STANDARD, // Standard fee tier:  0.25% on PancakeSwap, 0.3% on Uniswap
    LP_FEE_PROFILE_LOW, // Low fee tier: typically, 0.01% on PancakeSwap, 0.05% on Uniswap
    LP_FEE_PROFILE_HIGH // High fee tier (1% for exotic pairs)

}

/// @notice the DEX ID
/// @dev determines the DEX we want to migrate to
/// On BSC:
///   - only DEX0 will be enabled, which is PancakeSwap
/// On xLayer:
///   - only DEX0 will be enabled, which is PotatoSwap
/// On Monad:
///   - DEX0 is Uniswap
///   - DEX1 is PancakeSwap
///   - DEX2 is Monday
/// Note that, currently, we only support at most 3 DEXes
/// We may add more DEXes in the future if needed
enum DEXId {
    DEX0,
    DEX1,
    DEX2
}
```

## What is the difference between getTokenV2, getTokenV3, getTokenV4, getTokenV5, getTokenV6, getTokenV7, getTokenV8 and getTokenV8Safe?

Each version of the `getToken` method returns progressively more information about a token's state. The protocol maintains backward compatibility by preserving all legacy methods while recommending the latest available version for new integrations.

### Version Comparison Table

| Version    | New Fields Added                                 | Use Case                                         |
| ---------- | ------------------------------------------------ | ------------------------------------------------ |
| **V2**     | Base fields only                                 | Legacy - basic token state                       |
| **V3**     | `quoteTokenAddress`, `nativeToQuoteSwapEnabled`  | Multi-quote token support                        |
| **V4**     | `extensionID`                                    | Extension/plugin support (e.g., Farcaster)       |
| **V5**     | `h`, `k`                                         | Complete bonding curve parameters                |
| **V6**     | `taxRate`, `pool`, `progress`                    | Tax tokens, DEX pool info, progress tracking     |
| **V7**     | `lpFeeProfile`, `dexId`                          | Multi-DEX support with custom fee tiers          |
| **V8**     | `buyTaxRate`, `sellTaxRate` (replaces `taxRate`) | Asymmetric tax rates for Tax Token V3            |
| **V8Safe** | Same as V8, but enum fields returned as `uint8`  | Forward-compatible; safe against new enum values |

### Recommendation

Use `getTokenV8` / `getTokenV8Safe` on BNB mainnet and BNB testnet. For other networks, use `getTokenV7`. `getTokenV8Safe` is recommended when you need forward/backward compatibility with future contract upgrades that may add new enum variants.

`getTokenV5` is supported on all mainnets (BSC, xLayer, Monad, Morph). `V6` is available on all mainnets except Morph, while `V7` is available on all mainnets except Morph and Base.

{% hint style="info" %}
`getTokenV8` and `getTokenV8Safe` are currently only available on BNB mainnet and BNB testnet.
{% endhint %}

We will gradually make `getTokenV8` and `getTokenV8Safe` available on other mainnets in the future.
