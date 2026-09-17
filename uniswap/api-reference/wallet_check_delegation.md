<!-- generated from openapi-trading-api.json | captured: 2026-08-22 -->
# Get wallet delegations

`POST https://trade-api.gateway.uniswap.org/v1/wallet/check_delegation`  
operationId: `wallet_check_delegation` · tags: utilities

Gets the current delegation status and message for a smart contract wallet across different chains. Returns delegation information for each chain ID in the request.

## Request body (application/json)

- `walletAddresses`: array. Array of wallet addresses to check delegation status for
  - items:
- `chainIds` (required): array. Array of chain IDs to check delegation status for
  - items:
    - enum: `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`

Example:

```json
{
  "walletAddresses": [
    "0xC9bebBA9f481b12cE6f3EA54c4B182c9636ec421"
  ],
  "chainIds": [
    1,
    8453
  ]
}
```

## Responses

### 200: Wallet delegation info request successful.

- `requestId` (required): string. A unique ID for the request
- `delegationDetails` (required): object. Map of wallet addresses to chain IDs to delegation details

Example:

```json
{
  "requestId": "cOxNNjs6iYcEJEA=",
  "delegationDetails": {
    "0xC9bebBA9f481b12cE6f3EA54c4B182c9636ec421": {
      "1": {
        "isWalletDelegatedToUniswap": true,
        "currentDelegationAddress": "0x000000009b1d0af20d8c6d0a44e162d11f9b8f00",
        "latestDelegationAddress": "0x000000009b1d0af20d8c6d0a44e162d11f9b8f00"
      },
      "8453": {
        "isWalletDelegatedToUniswap": true,
        "currentDelegationAddress": "0x000000009b1d0af20d8c6d0a44e162d11f9b8f00",
        "latestDelegationAddress": "0x000000009b1d0af20d8c6d0a44e162d11f9b8f00"
      }
    }
  }
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

