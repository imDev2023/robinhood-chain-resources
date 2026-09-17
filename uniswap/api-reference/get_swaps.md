<!-- generated from openapi-trading-api.json | captured: 2026-08-22 -->
# Get swap status

`GET https://trade-api.gateway.uniswap.org/v1/swaps`  
operationId: `get_swaps` · tags: swapping

Get the status of swap or bridge transactions. Accepts on-chain transaction hashes (`txHashes`), ERC-4337 userOperation hashes (`userOpHashes`), or both. At least one of the two must contain at least one item.

## Parameters

- `txHashes` (query): On-chain transaction hashes. At least one of `txHashes` or `userOpHashes` must be provided. 
- `userOpHashes` (query): ERC-4337 UserOperation hashes. At least one of `txHashes` or `userOpHashes` must be provided. 
- `chainId` (query):  default `1`
- `swapper` (query): Filter by swapper address. 

## Responses

### 200: Get swap successful.

- `requestId` (required): string. A unique ID for the request
- `swaps`: array
  - items:
    - `swapType`: string = `CLASSIC`, `DUTCH_LIMIT`, `DUTCH_V2`, `DUTCH_V3`, `BRIDGE`, `LIMIT_ORDER`, `PRIORITY`, `WRAP`, `UNWRAP`, `CHAINED`. The routing for the proposed transaction
    - `status`: string = `PENDING`, `SUCCESS`, `NOT_FOUND`, `FAILED`, `EXPIRED`
    - `txHash`: string. The unique hash of the transaction
    - `swapId`: string
    - `userOpHash`: string. The unique hash of the transaction
    - `hashType`: string = `TX`, `USER_OP`. Identifies whether the row was resolved from a transaction hash or a userOperation hash. Omitted on transaction rows; absence is equivalent to `TX`
    - `paymaster`: string
    - `sponsorship`: object. Display information about the sponsor covering gas fees for the swap
      - `name`: string. Display name of the sponsor
      - `icon`: string. URL of the sponsor's icon

Example:

```json
{
  "requestId": "cL8S8hNtCYcEJLg=",
  "swaps": [
    {
      "status": "SUCCESS",
      "swapType": "CLASSIC",
      "txHash": "0xc286f0adc6a9d6d26d6114df251d9b09d8bfafb2e00af5953193f6af92e110db"
    }
  ]
}
```

### 400: RequestValidationError, Bad Input

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

