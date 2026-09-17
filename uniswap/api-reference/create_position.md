<!-- generated from openapi-trading-api.json | captured: 2026-08-22 -->
# Create a V3 or V4 LP position

`POST https://trade-api.gateway.uniswap.org/v1/lp/create`  
operationId: `create_position` · tags: liquidity-provisioning

Creates a new LP position in a V3 or V4 pool (including full-range positions). You can create a position in an existing pool by providing `existingPool` parameters, or create a new pool by providing `newPool` parameters (fee, tick spacing, initial price, and optionally hooks for V4). The position's price range is specified via either `priceBounds` or `tickBounds`. The server computes the dependent token amount. If `simulateTransaction` is set to `true`, the response will include the gas fee.

## Request body (application/json)

- `walletAddress` (required): string
- `existingPool`: object. Parameters for an existing pool. Provide either existingPool or newPool, not both
  - `token0Address` (required): string
  - `token1Address` (required): string
  - `poolReference` (required): string. The pool address (V3) or pool ID (V4) identifying the existing pool
- `newPool`: object. Parameters for creating a new pool. Provide either existingPool or newPool, not both
  - `token0Address` (required): string
  - `token1Address` (required): string
  - `fee` (required): integer. The pool fee in basis points
  - `tickSpacing` (required): integer. The tick spacing for the pool
  - `hooks`: object. Optional hooks contract address (V4 only)
  - `initialPrice` (required): string. The initial price of the pool (token1 per token0)
- `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `protocol` (required): string = `V2`, `V3`, `V4`. The protocol of the pool
- `independentToken` (required): object. The token whose amount you are specifying
  - `tokenAddress` (required): string
  - `amount` (required): string. The token amount in raw (base unit) format
- `dependentToken`: object. The other token. The server computes the required amount. If provided, the amount is used as a maximum
  - `tokenAddress` (required): string
  - `amount` (required): string. The token amount in raw (base unit) format
- `priceBounds`: object. Price bounds for the position range. Provide either priceBounds or tickBounds, not both
  - `minPrice` (required): string. The minimum price (token1 per token0) for the position range
  - `maxPrice` (required): string. The maximum price (token1 per token0) for the position range
- `tickBounds`: object. Tick bounds for the position range. Provide either priceBounds or tickBounds, not both
  - `tickLower` (required): integer. The lower tick of the position range
  - `tickUpper` (required): integer. The upper tick of the position range
- `slippageTolerance`: number. Slippage tolerance as a decimal (e.g., 0.5 for 0.5%)
- `deadline`: integer. Unix timestamp after which the transaction will revert
- `simulateTransaction`: boolean. If true, the response will include the gas fee
- `urgency`: string = `NORMAL`, `FAST`, `URGENT`. The urgency level for gas price estimation. Higher urgency results in higher gas price and faster transaction inclusion. Defaults to URGENT if not provided
- `batchPermitData`: object. Batch permit data for V4 positions
  - `domain`: object
  - `values`: object
  - `types`: object
- `signature`: string. The signed permit
- `nativeTokenBalance`: string. The wallet's native token balance, used for wrapping calculations when one of the tokens is the native token

Example:

```json
{
  "walletAddress": "0xC9bebBA9f481b12cE6f3EA54c4B182c9636ec421",
  "existingPool": {
    "token0Address": "0x0000000000000000000000000000000000000000",
    "token1Address": "0x833589fcd6edb6e08f4c7c32d4f71b54bda02913",
    "poolReference": "0x96d4b53a38337a5733179751781178a2613306063c511b78cd02684739288c0a"
  },
  "chainId": 8453,
  "protocol": "V4",
  "independentToken": {
    "tokenAddress": "0x833589fcd6edb6e08f4c7c32d4f71b54bda02913",
    "amount": "3000000"
  },
  "dependentToken": {
    "tokenAddress": "0x0000000000000000000000000000000000000000",
    "amount": "952630553245231"
  },
  "tickBounds": {
    "tickLower": -198950,
    "tickUpper": -198200
  },
  "simulateTransaction": false,
  "nativeTokenBalance": "19345734941139696"
}
```

## Responses

### 200: Create V3/V4 position successful.

- `requestId` (required): string. A unique ID for the request
- `token0` (required): object. A token with its address and amount, used in LP operations
  - `tokenAddress` (required): string
  - `amount` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `token1` (required): object. A token with its address and amount, used in LP operations
  - `tokenAddress` (required): string
  - `amount` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `adjustedMinPrice` (required): string. The actual minimum price after tick adjustment
- `adjustedMaxPrice` (required): string. The actual maximum price after tick adjustment
- `tickLower` (required): integer. The adjusted lower tick
- `tickUpper` (required): integer. The adjusted upper tick
- `create` (required): object
  - `to` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
  - `from` (required): string. The wallet address which will be used to send the token
  - `data` (required): string. The calldata for the transaction
  - `value` (required): string. The quantity of ETH tokens approved for spending by the transaction, denominated in wei. Note that by default Uniswap Labs sets this to the maximum approvable spend
  - `gasLimit`: string. The maximum units of gas that will be consumed by this transaction
  - `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `maxFeePerGas`: string. The sum of the base fee and priority fee. Subtracting `maxPriorityFeePerGas` from this value will yield the base fee to be paid for this transaction
  - `maxPriorityFeePerGas`: string. The maximum tip to the block builder. Adjusted based upon the urgency specified in the request
  - `gasPrice`: string. The cost per unit of gas
- `gasFee`: string. The total estimated gas cost of this transaction (eg. `gasLimit` multiplied by `maxFeePerGas`) in the base unit of the chain

Example:

```json
{
  "requestId": "3e7960b1-496d-4810-b071-a989fc6c82c3",
  "token0": {
    "tokenAddress": "0x0000000000000000000000000000000000000000",
    "amount": "953604746993169"
  },
  "token1": {
    "tokenAddress": "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913",
    "amount": "3000000"
  },
  "adjustedMinPrice": "0.000000002291623505250648965031523285",
  "adjustedMaxPrice": "0.000000002470095393846743765417492756",
  "tickLower": -198950,
  "tickUpper": -198200,
  "create": {
    "to": "0x7C5f5A4bBd8fD63184577525326123B519429bDc",
    "from": "0xC9bebBA9f481b12cE6f3EA54c4B182c9636ec421",
    "data": "0xdd46508f00...",
    "value": "0x0370d2117653fe",
    "chainId": 8453
  }
}
```

### 400: RequestValidationError, Bad Input

- `errorCode`: string
- `detail`: string

### 401: UnauthorizedError eg. Account is blocked.

- `errorCode`: string
- `detail`: string

### 404: ResourceNotFound eg. Cant Find LP Position.

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

