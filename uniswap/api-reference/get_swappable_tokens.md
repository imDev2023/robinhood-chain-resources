<!-- generated from openapi-trading-api.json | captured: 2026-08-22 -->
# Get bridgable tokens

`GET https://trade-api.gateway.uniswap.org/v1/swappable_tokens`  
operationId: `get_swappable_tokens` · tags: utilities

Returns the list of destination bridge chains for a given token on a given chain.

## Parameters

- `tokenIn` (query, required):  
- `tokenInChainId` (query, required):  default `1`

## Responses

### 200: Get swappable tokens successful.

- `requestId` (required): string. A unique ID for the request
- `tokens` (required): array
  - items:
    - `address` (required): string
    - `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `name` (required): string. The name of the token
    - `symbol` (required): string. The symbol of the token
    - `project` (required): object
      - `logo` (required): object
        - `url` (required): string
      - `safetyLevel` (required): string = `BLOCKED`, `MEDIUM_WARNING`, `STRONG_WARNING`, `VERIFIED`
      - `isSpam` (required): boolean. Whether the token is considered a spam token
    - `isSpam`: boolean. Whether the token is considered a spam token
    - `decimals` (required): number. The number of decimals supported by the token. This number is used to convert token amounts to the token's common representation

Example:

```json
{
  "requestId": "cL_1ih66iYcEJ2g=",
  "tokens": [
    {
      "name": "USD Coin",
      "symbol": "USDC",
      "address": "0x0b2C639c533813f4Aa9D7837CAf62653d097Ff85",
      "chainId": 10,
      "project": {
        "logo": {
          "url": "https://coin-images.coingecko.com/coins/images/6319/large/USDC.png?1769615602"
        },
        "safetyLevel": "VERIFIED",
        "isSpam": false
      },
      "decimals": 6
    },
    {
      "name": "Bridged USDC",
      "symbol": "USDC.e",
      "address": "0x7F5c764cBc14f9669B88837ca1490cCa17c31607",
      "chainId": 10,
      "project": {
        "logo": {
          "url": "https://coin-images.coingecko.com/coins/images/31580/large/USDC-icon.png?1696530397"
        },
        "safetyLevel": "VERIFIED",
        "isSpam": false
      },
      "decimals": 6
    },
    {
      "name": "USD Coin",
      "symbol": "USDC",
      "address": "0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359",
      "chainId": 137,
      "project": {
        "logo": {
          "url": "https://coin-images.coingecko.com/coins/images/6319/large/USDC.png?1769615602"
        },
        "safetyLevel": "VERIFIED",
        "isSpam": false
      },
      "decimals": 6
    }
  ]
}
```

### 400: RequestValidationError, Bad Input

- `errorCode`: string
- `detail`: string

### 401: UnauthorizedError eg. Account is blocked.

- `errorCode`: string
- `detail`: string

### 404: ResourceNotFound eg. No quotes available or Gas fee/price not available

- `errorCode`: string = `ResourceNotFound`, `QuoteAmountTooLowError`, `TokenBalanceNotAvailable`, `InsufficientBalance`
- `detail`: string

### 429: Ratelimited

- `errorCode`: string
- `detail`: string

### 500: Unexpected error

- `errorCode`: string
- `detail`: string

### 504: Request duration limit reached.

- `errorCode`: string
- `detail`: string

