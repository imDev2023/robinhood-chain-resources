> For the complete documentation index, see [llms.txt](https://docs.flap.sh/flap/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://docs.flap.sh/flap/developers/wallet-and-terminal-and-bot-developers/bonding-curve-in-developers-perspective.md).

# Bonding Curve In Developers' Perspective

## How to find the reserve/price/fdv from the circulating supply of a token?

### Option1: Read from the Chain

You can directly read the information about a token through the `getTokenV2` call to the on chain contract.

```solidity
/// @notice Get token state (V5)
/// @param token  The address of the token
/// @return state  The state of the token (V5) with all curve parameters (r, h, k)
function getTokenV5(address token) external view returns (TokenStateV5 memory state);

/// @dev Token version
/// Which token implementation is used
enum TokenVersion {
    TOKEN_LEGACY_MINT_NO_PERMIT,
    TOKEN_LEGACY_MINT_NO_PERMIT_DUPLICATE, // for historical reasons, both 0 and 1 are the same: TOKEN_LEGACY_MINT_NO_PERMIT
    TOKEN_V2_PERMIT,
    TOKEN_GOPLUS
}
/// @notice the status of a token
/// The token has 4 statuses:
//    - Tradable: The token can be traded(buy/sell)
//    - InDuel: (obsolete) The token is in a battle, it can only be bought but not sold.
//    - Killed: (obsolete) The token is killed, it can not be traded anymore. Can only be redeemed for another token.
//    - DEX: The token has been added to the DEX
enum TokenStatus {
    Invalid, // The token does not exist
    Tradable,
    InDuel, // obsolete
    Killed, // obsolete
    DEX
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


```

### Option 2: Derive price/fdv/reserve from the current circulating supply

{% hint style="warning" %}
Check [Bonding Curve](/flap/developers/basic-and-mechanism/bonding-curve.md#bonding-curves-on-different-chains)for the r of each deployment\
\
We don't recomend that you hardcode the bonding curve parameters in your application. Instead, you should use `getTokenV5` method from the Portal contract to get the parameters for each token. The parameters are immutable for each token, so you only need to fetch them once and cache them in your application.
{% endhint %}

Whenever a user buys or sells token on the bonding curve, the following event would be emitted:

```solidity
/// @notice emitted when the circulating supply of a token changes
/// @param token The address of the token
/// @param newSupply The new circulating supply
event FlapTokenCirculatingSupplyChanged(address token, uint256 newSupply);

```

You can simply index this event to get the latest circulating supply of any token. With the circulating supply of the token, you can get the reserve, price and FDV with the following `typescript` snippet:

```typescript

import { Decimal } from "decimal.js";

const BILLION: Decimal = new Decimal("1000000000");


// The latest curve is CDPV2
export class CDPV2 {
    // the initial virtual reserve
    private r: number;
    private h: number;
    private k: number;


    static defaultDexSupplyThreshold() {
        return new Decimal(8e8);
    }

    static getCurve(r: number, h?: number, k?: number): CDPV2 {
        if (h == null) {
            return new CDPV2(r, 0, 1e9 * r);
        }
        return new CDPV2(r, h, k);
    }

    constructor(r: number, h: number = 0, k: number = 0) {
        this.r = r;
        this.h = h;
        this.k = k;
    }

    estimateSupply(reserve: string): Decimal {
        // s = 1e9 + h - k/(r + eth)
        if (!reserve) return new Decimal(0);
        return new Decimal(BILLION).add(this.h).sub(
            new Decimal(this.k).div(new Decimal(reserve).add(this.r))
        );
    }

    estimateReserve(amount: string): Decimal {
        // eth = k/(h + 1e9 - s) - r
        if (!amount) return new Decimal(0);
        return new Decimal(this.k)
            .div(new Decimal(BILLION).add(this.h).sub(new Decimal(amount)))
            .sub(this.r);
    }

    mc(reserve: string): Decimal {
        return this.fdv(this.totalSupply(reserve).toString());
    }

    price(supply: string): Decimal {
        // Price: k/(h + 1e9 - s)^2
        const denominator = new Decimal(BILLION).add(this.h).sub(new Decimal(supply || 0));
        return new Decimal(this.k).div(denominator.pow(2));
    }

    fdv(supply: string): Decimal {
        return this.price(supply).mul(new Decimal(BILLION));
    }
}
```

## How to calculate the progress of a token

The progress is defined as the ratio of the current reserve to the required reserve for the token to migrate.

You need the following information to calculate the progress:

* `Circulating Supply`: The current circulating supply of the token. You can either index the `FlapTokenCirculatingSupplyChanged` event, or use the `getTokenV5` method to get the `circulatingSupply` of the token, or simply use the `balanceOf(portal)` to estimate the circulating supply (This estimation is accurate as long as no one directly sends token to our contract).
* `Curve Parameters`: You can use the `getTokenV5` to get the curve parameters: `r`, `h` and `k`. Or you can index the `TokenCurveSetV2` event. The curve parameters are immutable for a token, you only need to get them once.
* `Dex Threshold`: You can use the `getTokenV5` to get the `dexThreshold` of the token, or index the `TokenDexThresholdSet` event. The dex threshold is immutable, you only need to get it once. It represents the circulating supply at which the token will be migrated.

The latter two variables are immutable for a token, you only need to get them once. We highly recommend that you to use the the `getTokenV5` method to get all the parameters at once.

With all the above information, you can calculate the prorgress of the token:

* We first construct a `Curve` instance using the curve parameters. Note the curve parameteres are in 18 decimals, so we need to divide them by `1e18` to get the actual values (or use formatEther from viem).
* We first calculate the `required reserve` for the token to migrate
* Then we derive the `current reserve`
* The progress is the ratio betweeen `current reserve` and `required reserve`

```typescript


// assume we have all the following parameters from  getTokenV5 
// Note: all parameters are in 18 decimals 

// curve parameters  
let r,h,k: bigint;

// circulating supply
let circulatingSupply: bigint; 

// dex threshold 
let dexThreshold: bigint;  




const curve =  CDPV2.getCurve( 
    Number( formatEther(r) ), 
    Number( formatEther(h) ), 
    Number( formatEther(k) ) 
); 



// The reserve required at the dex threshold 
const reserveRequired = curve.estimateReserve(
    formatEther(dexThreshold)
);

// The current reserve at the current circulating supply
const currentReserve = curve.estimateReserve(
    formatEther(circulatingSupply)
);


// The progress can be calculated as:
const progress = currentReserve / reserveRequired; 

```
