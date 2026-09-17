<!-- generated from openapi-trading-api.json | captured: 2026-08-22 -->
# Increase an LP position

`POST https://trade-api.gateway.uniswap.org/v1/lp/increase`  
operationId: `increase_position` · tags: liquidity-provisioning

Increases liquidity in an existing position. Specify the independent token and amount; the server derives the dependent token amount from the current pool state. Supports V2 (by token pair), V3, and V4 (by NFT token ID). If `simulateTransaction` is set to `true`, the response will include the gas fee.

## Request body (application/json)

- `walletAddress` (required): string
- `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `protocol` (required): string = `V2`, `V3`, `V4`. The protocol of the pool
- `token0Address` (required): string
- `token1Address` (required): string
- `nftTokenId`: string. The NFT token ID for V3/V4 positions. Not required for V2
- `independentToken` (required): object. The token whose amount you are specifying
  - `tokenAddress` (required): string
  - `amount` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `slippageTolerance`: number. Slippage tolerance as a decimal (e.g., 0.5 for 0.5%)
- `deadline`: integer. Unix timestamp after which the transaction will revert
- `simulateTransaction`: boolean. If true, the response will include the gas fee
- `v4BatchPermitData`: object. Batch permit data for V4 positions
  - `domain`: object
  - `values`: object
  - `types`: object
- `signature`: string. The signed permit
- `urgency`: string = `NORMAL`, `FAST`, `URGENT`. The urgency level for gas price estimation. Higher urgency results in higher gas price and faster transaction inclusion. Defaults to URGENT if not provided

Example:

```json
{
  "walletAddress": "0xC9bebBA9f481b12cE6f3EA54c4B182c9636ec421",
  "chainId": 8453,
  "protocol": "V3",
  "token0Address": "0x0000000000000000000000000000000000000000",
  "token1Address": "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913",
  "nftTokenId": "4986936",
  "independentToken": {
    "tokenAddress": "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913",
    "amount": "3000000"
  },
  "simulateTransaction": true
}
```

## Responses

### 200: Increase position successful.

- `requestId` (required): string. A unique ID for the request
- `token0` (required): object. A token with its address and amount, used in LP operations
  - `tokenAddress` (required): string
  - `amount` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `token1` (required): object. A token with its address and amount, used in LP operations
  - `tokenAddress` (required): string
  - `amount` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `increase` (required): object
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
  "requestId": "ff287fc0-3a81-42a2-a2fd-cce6a5f16821",
  "token0": {
    "tokenAddress": "0x4200000000000000000000000000000000000006",
    "amount": "923764813384463"
  },
  "token1": {
    "tokenAddress": "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913",
    "amount": "3000000"
  },
  "increase": {
    "to": "0x03a520b32C04BF3bEEf7BEb72E919cf822Ed34f1",
    "from": "0xC9bebBA9f481b12cE6f3EA54c4B182c9636ec421",
    "data": "0xac9650d800...",
    "value": "0x034828c18ec9f4",
    "chainId": 8453,
    "gasLimit": "288938",
    "gasPrice": "9000000"
  },
  "gasFee": "2668712200733"
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

