<!-- generated from openapi-trading-api.json | captured: 2026-08-22 -->
# Decrease an LP position

`POST https://trade-api.gateway.uniswap.org/v1/lp/decrease`  
operationId: `decrease_position` · tags: liquidity-provisioning

Decreases liquidity in an existing position by a specified percentage. The server derives all position state (liquidity, fees, ticks) from on-chain data. Supports V2 (by token pair), V3, and V4 (by NFT token ID). If `simulateTransaction` is set to `true`, the response will include the gas fee.

## Request body (application/json)

- `walletAddress` (required): string
- `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `protocol` (required): string = `V2`, `V3`, `V4`. The protocol of the pool
- `token0Address` (required): string
- `token1Address` (required): string
- `nftTokenId`: string. The NFT token ID for V3/V4 positions. Not required for V2
- `liquidityPercentageToDecrease` (required): integer. The percentage of liquidity to remove (1-100)
- `slippageTolerance`: number. Slippage tolerance as a decimal (e.g., 0.5 for 0.5%)
- `deadline`: integer. Unix timestamp after which the transaction will revert
- `simulateTransaction`: boolean. If true, the response will include the gas fee
- `withdrawAsWeth`: boolean. If true, native tokens will be withdrawn as WETH instead of unwrapping to ETH
- `urgency`: string = `NORMAL`, `FAST`, `URGENT`. The urgency level for gas price estimation. Higher urgency results in higher gas price and faster transaction inclusion. Defaults to URGENT if not provided

Example:

```json
{
  "walletAddress": "0x...",
  "chainId": 130,
  "protocol": "V4",
  "token0Address": "0x0000000000000000000000000000000000000000",
  "token1Address": "0x078D782b760474a361dDA0AF3839290b0EF57AD6",
  "nftTokenId": "1833079",
  "liquidityPercentageToDecrease": 25,
  "simulateTransaction": false
}
```

## Responses

### 200: Decrease position successful.

- `requestId` (required): string. A unique ID for the request
- `token0` (required): object. A token with its address and amount, used in LP operations
  - `tokenAddress` (required): string
  - `amount` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `token1` (required): object. A token with its address and amount, used in LP operations
  - `tokenAddress` (required): string
  - `amount` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `decrease` (required): object
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
  "requestId": "cMHfBjMJCYcEJQg=",
  "token0": {
    "tokenAddress": "0x0000000000000000000000000000000000000000",
    "amount": "218729726079859"
  },
  "token1": {
    "tokenAddress": "0x078D782b760474a361dDA0AF3839290b0EF57AD6",
    "amount": "506124"
  },
  "decrease": {
    "to": "0x4529A01c7A0410167c5740C487A8DE60232617bf",
    "from": "0xC9bebBA9f481b12cE6f3EA54c4B182c9636ec421",
    "data": "0xdd46508f00...",
    "value": "0x00",
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

