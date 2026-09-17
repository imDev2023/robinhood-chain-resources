<!-- generated from openapi-trading-api.json | captured: 2026-08-22 -->
# Get pool state

`POST https://trade-api.gateway.uniswap.org/v1/lp/pool_info`  
operationId: `pool_info` · tags: utilities

Fetches detailed information about one or more liquidity pools across Uniswap v2, v3, and v4. Returns pool state including token addresses, reserves, liquidity, current tick, sqrtRatioX96, fee tier, tick spacing, and hook addresses (V4).

Provide one of `poolParameters` or `poolReferences` (not both):
- `poolParameters`: Look up pools by token pair. Provide token addresses and optional fee/tickSpacing/hooks to find matching pools.
- `poolReferences`: Look up specific known pools by their reference identifier (pool address for v3, pool ID for v4, pair address for v2). Limited to 20 references per request; larger batches are rejected with an HTTP 400 error.

Pool reserves (`token0Reserves`/`token1Reserves`) are returned for v2 pools and, best-effort, for v4 pools. v4 reserves are the fee-excluded core principal computed from on-chain pool state: uncollected LP fees, donations, and hook-held assets are excluded, and for pools whose hooks perform custom accounting the value approximates swappable reserves.

## Request body (application/json)

- `protocol` (required): string = `V2`, `V3`, `V4`. The protocol of the pool
- `poolParameters`: object
  - `tokenAddressA` (required): string. The address of the first token in the pair
  - `tokenAddressB` (required): string. The address of the second token in the pair
  - `fee`: number. The fee of the pool, if the pool has a fee value. Must be provided for V3 or V4 pools
  - `tickSpacing`: number. The width of ticks in this pool (e.g. the price range between two ticks) specified in basis points. Must be provided for V3 or V4 pools
  - `hookAddress`: string. The address of the hook for the pool, if any
- `poolReferences`: array. Array of pool reference identifiers to query. Each reference should include the protocol, chainId, and either the pool address (v3), pool id (v4), or pair address (v2). At most 20 references may be provided per request; requests exceeding this limit are rejected with an HTTP 400 error
  - items:
    - `protocol` (required): string = `V2`, `V3`, `V4`. The protocol of the pool
    - `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `referenceIdentifier`: string
- `chainId`: number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `pageSize`: number
- `currentPage`: number

Example:

```json
{
  "protocol": "V4",
  "chainId": 1,
  "poolParameters": {
    "tokenAddressA": "0x0000000000000000000000000000000000000000",
    "tokenAddressB": "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48",
    "fee": 3000,
    "tickSpacing": 60
  }
}
```

## Responses

### 200: Pool information response successful.

- `requestId`: string. A unique ID for the request
- `pools`: array. Array of pool information objects
  - items:
    - `poolReferenceIdentifier`: string. The unique identifier for the pool reference, which can be a pool address, pool id, or pair address depending on the protocol
    - `poolProtocol`: string = `V2`, `V3`, `V4`. The protocol of the pool
    - `tokenAddressA`: string
    - `tokenAddressB`: string
    - `tickSpacing`: number. The width of ticks in this pool (e.g. the price range between two ticks) specified in basis points. For more information see the [Uniswap V3 Whitepaper](https://app.uniswap.org/whitepaper-v3.pdf)
    - `fee`: string. The fee of the pool in basis points
    - `hookAddress`: string. The address of the hook for the pool, if any
    - `chainId`: number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `tokenAmountA`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `tokenAmountB`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `tokenDecimalsA`: number. The number of decimals for token A
    - `tokenDecimalsB`: number. The number of decimals for token B
    - `poolLiquidity`: string. The amount of liquidity in the pool at a given tick. For more information see the [Uniswap V3 Whitepaper](https://app.uniswap.org/whitepaper-v3.pdf)
    - `sqrtRatioX96`: string. The square root of the ratio of the token0 and token1 in the pool, as a Q64.64 number. For more information see the [Uniswap V3 Whitepaper](https://app.uniswap.org/whitepaper-v3.pdf)
    - `currentTick`: number. The current tick of the pool. For more information see the [Uniswap V3 Whitepaper](https://app.uniswap.org/whitepaper-v3.pdf)
    - `token0Reserves`: string. Pool reserves of token0, denominated in the token's base units. Populated for v2 pools (pair reserves) and v4 pools. For v4 pools this is the fee-excluded core principal computed from on-chain pool state: uncollected LP fees, donations, and hook-held assets are excluded, and for pools whose hooks perform custom accounting the value is an approximation of swappable reserves. Computed best-effort and omitted if unavailable. Not returned for v3 pools
    - `token1Reserves`: string. Pool reserves of token1, denominated in the token's base units. Populated for v2 pools (pair reserves) and v4 pools. For v4 pools this is the fee-excluded core principal computed from on-chain pool state: uncollected LP fees, donations, and hook-held assets are excluded, and for pools whose hooks perform custom accounting the value is an approximation of swappable reserves. Computed best-effort and omitted if unavailable. Not returned for v3 pools
- `pageSize`: number
- `currentPage`: number

Example:

```json
{
  "requestId": "1b68b6fa-3946-4c5b-ac60-e5fb9d614a1b",
  "pools": [
    {
      "poolReferenceIdentifier": "0xdce6394339af00981949f5f3baf27e3610c76326a700af57e4b3e3ae4977f78d",
      "poolProtocol": "V4",
      "tokenAddressA": "0x0000000000000000000000000000000000000000",
      "tokenAddressB": "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
      "tickSpacing": 60,
      "fee": 3000,
      "hookAddress": "0x0000000000000000000000000000000000000000",
      "chainId": 1,
      "tokenDecimalsA": "18",
      "tokenDecimalsB": "6",
      "poolLiquidity": "1007803497966589811",
      "sqrtRatioX96": "3796141369585623258184840",
      "currentTick": -198932,
      "token0Reserves": "224201965836985417",
      "token1Reserves": "1004698471"
    }
  ],
  "currentPage": 1,
  "pageSize": 1
}
```

### 400: RequestValidationError, Bad Input

- `errorCode`: string
- `detail`: string

### 401: UnauthorizedError eg. Account is blocked.

- `errorCode`: string
- `detail`: string

### 404: ResourceNotFound eg. No pool information on given chain

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

