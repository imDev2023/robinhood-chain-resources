<!-- generated from openapi-trading-api.json | captured: 2026-08-22 -->
# Create a classic (V2) LP position

`POST https://trade-api.gateway.uniswap.org/v1/lp/create_classic`  
operationId: `create_classic_position` · tags: liquidity-provisioning

Creates a full-range liquidity position in a Uniswap V2 pool. Specify the independent token and amount; the server computes the dependent token amount based on the current pool ratio. If `simulateTransaction` is set to `true`, the response will include the gas fee for the creation transaction.

## Request body (application/json)

- `walletAddress` (required): string
- `poolParameters` (required): object. Parameters identifying a V2 pool
  - `token0Address` (required): string
  - `token1Address` (required): string
  - `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `independentToken` (required): object. A token with its address and amount, used in LP operations
  - `tokenAddress` (required): string
  - `amount` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `dependentToken`: object. A token with its address and amount, used in LP operations
  - `tokenAddress` (required): string
  - `amount` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `slippageTolerance`: number. Slippage tolerance as a decimal (e.g., 0.5 for 0.5%)
- `deadline`: integer. Transaction deadline in seconds
- `simulateTransaction`: boolean. If true, the response will include the gas fee
- `urgency`: string = `NORMAL`, `FAST`, `URGENT`. The urgency level for gas price estimation. Higher urgency results in higher gas price and faster transaction inclusion. Defaults to URGENT if not provided
- `includeApprovalSimulation`: boolean. If true, the response will include approval simulation data

Example:

```json
{
  "walletAddress": "0x...",
  "poolParameters": {
    "token0Address": "0x0000000000000000000000000000000000000000",
    "token1Address": "0xc02fe7317d4eb8753a02c35fe019786854a92001",
    "chainId": 130
  },
  "independentToken": {
    "tokenAddress": "0xc02fe7317d4eb8753a02c35fe019786854a92001",
    "amount": "1000000000000000"
  },
  "dependentToken": {
    "tokenAddress": "0x0000000000000000000000000000000000000000",
    "amount": "1227700073369630"
  },
  "simulateTransaction": false
}
```

## Responses

### 200: Create classic (V2) position successful.

- `requestId` (required): string. A unique ID for the request
- `independentToken` (required): object. A token with its address and amount, used in LP operations
  - `tokenAddress` (required): string
  - `amount` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `dependentToken` (required): object. A token with its address and amount, used in LP operations
  - `tokenAddress` (required): string
  - `amount` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
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
  "requestId": "cMJXBil3CYcEJjQ=",
  "independentToken": {
    "tokenAddress": "0xc02fE7317D4eb8753a02c35fe019786854A92001",
    "amount": "1000000000000000"
  },
  "dependentToken": {
    "tokenAddress": "0x0000000000000000000000000000000000000000",
    "amount": "1227700073369630"
  },
  "create": {
    "to": "0x284F11109359a7e1306C3e447ef14D38400063FF",
    "from": "0xC9bebBA9f481b12cE6f3EA54c4B182c9636ec421",
    "data": "0xf305d71900...",
    "value": "0x045c9632c3901e",
    "chainId": 130
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

