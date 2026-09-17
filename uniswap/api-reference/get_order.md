<!-- generated from openapi-trading-api.json | captured: 2026-08-22 -->
# Get gasless order status

`GET https://trade-api.gateway.uniswap.org/v1/orders`  
operationId: `get_order` · tags: swapping

Retrieve one or more gasless orders filtered, optionally filered by query param(s). The request must at minimum include one of the following parameters: `orderId`, `orderIds`, `orderStatus`, `swapper`, or `filler`.

## Parameters

- `orderType` (query): The UniswapX order type to retrieve. 
- `orderId` (query): A transaction hash for an order. `orderId` or `orderIds` must be provided, but not both. 
- `orderIds` (query): A list of comma separated orderIds (transaction hashes). `orderId` or `orderIds` must be provided, but not both. 
- `limit` (query):  
- `orderStatus` (query): Filter by order status. 
- `swapper` (query): Filter by swapper address. 
- `sortKey` (query): Order the query results by the sort key. 
- `sort` (query): Sort query. For example: `sort=gt(UNIX_TIMESTAMP)`, `sort=between(1675872827, 1675872930)`, or `lt(1675872930)`. 
- `filler` (query): Filter by filler address. 
- `cursor` (query):  

## Responses

### 200: The request orders matching the query parameters.

- `requestId` (required): string. A unique ID for the request
- `orders` (required): array
  - items:
    - `type` (required): string = `DutchLimit`, `Dutch`, `Dutch_V2`, `Dutch_V3`, `Priority`
    - `encodedOrder` (required): string. An encoded copy of the order details which will be submitted to the filler network along with the signed permit
    - `signature` (required): string
    - `nonce` (required): string. A unique nonce for this order
    - `orderStatus` (required): string = `open`, `expired`, `error`, `cancelled`, `filled`, `unverified`, `insufficient-funds`. The status of the order. Note that all of these are final states with the exception of Open, meaning that no further state changes will occur.   Open - order is not yet filled by a filler.  Expired - order has expired without being filled and is no longer fillable.  Error - a catchall for other final states which are not otherwise specified, where the order will not be filled.  Cancelled - order is cancelled. Note that to cancel an order, a new order must be placed with the same nonce as the prior open order and it must be placed within the same block as the original order.  Filled - order is filled.  Insufficient-funds - the swapper (you) do not have enough funds for the order to be completed and the order is cancelled and will not be filled.  Unverified - order has not been verified yet
    - `orderId` (required): string. A unique ID for the order. Used to track the order's status
    - `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `quoteId`: string. A unique ID for the quote
    - `swapper`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
    - `txHash`: string. The unique hash of the transaction
    - `input`: object
      - `token` (required): string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `startAmount`: string. The intended execution quantity of tokens resulting from this swap
      - `endAmount`: string. The worst case quantity of tokens resulting from this swap
    - `outputs`: array
      - items:
        - `token` (required): string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
        - `startAmount`: string. The intended execution quantity of tokens resulting from this swap
        - `endAmount`: string. The worst case quantity of tokens resulting from this swap
        - `isFeeOutput`: boolean
        - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
    - `settledAmounts`: array
      - items:
        - `tokenOut`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
        - `amountOut`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
        - `tokenIn`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
        - `amountIn`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `cosignature`: string
    - `cosignerData`: object
      - `decayStartTime`: number. The unix timestamp at which the order will be eligible to be filled by alternate fillers at a lower price. Noted that the fill amount will not be lower than the output `endAmount`
      - `decayEndTime`: number. The unix timestamp at which the order will no longer be eligible to be filled by alternate fillers
      - `exclusiveFiller`: string. The address of the filler who has priority to fill the order by the `decayStartTime`
      - `inputOverride`: string
      - `outputOverrides`: array
        - items:
- `cursor`: string

Example:

```json
{
  "orders": [
    {
      "encodedOrder": "0x0000000000...",
      "signature": "0xcc803880b7...",
      "nonce": "1993350603649363012805190338010060803841095487773749076708031661332198422531",
      "orderStatus": "cancelled",
      "chainId": 1,
      "orderId": "0x7030883e6b34144d7f5e731bde66e23eb124f160f857cc5bc33c5c280fa63701",
      "createdAt": 1774555222,
      "settledAmounts": [
        {
          "tokenOut": "0x45e02bc2875A2914C4f585bBF92a6F28bc07CB70",
          "amountOut": "3306647558219378950381",
          "tokenIn": "0xdAC17F958D2ee523a2206206994597C13D831ec7",
          "amountIn": "1211000000"
        }
      ],
      "cosignature": "0x29979349ca...",
      "swapper": "0xb659Bb7b4B3fEc43F071F6f95cF975E1Aa89C6Ed",
      "quoteId": "3a0200d7-be0c-46d5-b19e-82a6c2719480",
      "txHash": "0x0b12fb61cd06dc179f270c4525584d07fc08911f78c4a940997981d01037fff7",
      "type": "Dutch_V2",
      "outputs": [
        {
          "token": "0x45e02bc2875A2914C4f585bBF92a6F28bc07CB70",
          "startAmount": "3301675174569363530964",
          "endAmount": "3285166798696516713309",
          "recipient": "0xb659Bb7b4B3fEc43F071F6f95cF975E1Aa89C6Ed"
        },
        {
          "token": "0x45e02bc2875A2914C4f585bBF92a6F28bc07CB70",
          "startAmount": "8274875124233993811",
          "endAmount": "8233500748612823842",
          "recipient": "0x12c280eE47dDf0372B86E29a7065880108895fe7"
        }
      ],
      "cosignerData": {
        "decayStartTime": 1774555246,
        "decayEndTime": 1774555306,
        "exclusiveFiller": "0x8392876883Cf0e9e7ee24d9b1F606ED88644f23B",
        "inputOverride": "0",
        "outputOverrides": [
          "3306647558219378950381",
          "0"
        ]
      },
      "input": {
        "token": "0xdAC17F958D2ee523a2206206994597C13D831ec7",
        "startAmount": "1211000000",
        "endAmount": "1211000000"
      }
    }
  ],
  "requestId": "cOVivj_DiYcEPqQ="
}
```

### 400: RequestValidationError eg. Token allowance not valid or Insufficient Funds.

- `errorCode`: string
- `detail`: string

### 404: Orders not found.

- `errorCode`: string = `ResourceNotFound`, `QuoteAmountTooLowError`, `TokenBalanceNotAvailable`, `InsufficientBalance`
- `detail`: string

### 429: Ratelimited

- `errorCode`: string
- `detail`: string

### 500: Unexpected error

- `errorCode`: string
- `detail`: string

### 503: Upstream UniswapX service unavailable while fetching orders.

- `errorCode`: string
- `detail`: string

### 504: Request duration limit reached.

- `errorCode`: string
- `detail`: string

