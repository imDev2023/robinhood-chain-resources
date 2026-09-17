<!-- generated from openapi-trading-api.json | captured: 2026-08-22 -->
# Check LP token approvals

`POST https://trade-api.gateway.uniswap.org/v1/lp/check_approval`  
operationId: `check_lp_approval` · tags: liquidity-provisioning

Checks whether the wallet has the required token approvals to perform an LP action (create, increase, decrease, or migrate). Returns any needed approval transactions. If `simulateTransaction` is set to `true`, the response will include gas fees for the approval transactions.

The `action` field specifies which LP operation the approval is for. Different actions may require different approvals (e.g., V2 decrease requires approval of the LP token, V3 migrate requires approval of the V3 NFT).

## Request body (application/json)

- `walletAddress` (required): string
- `protocol` (required): string = `V2`, `V3`, `V4`. The protocol of the pool
- `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `lpTokens` (required): array. The tokens requiring approval, each with address and amount
  - items:
    - `tokenAddress` (required): string
    - `amount` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `action` (required): string = `CREATE`, `INCREASE`, `DECREASE`, `MIGRATE`. The LP operation that the approval is needed for
- `includeGasInfo`: boolean. If true, the response will include gas fee estimates for each approval transaction
- `simulateTransaction`: boolean. If true, approval transactions will be simulated to verify they succeed
- `generatePermitAsTransaction`: boolean. If true, permits are returned as on-chain transactions rather than off-chain signatures
- `urgency`: string = `NORMAL`, `FAST`, `URGENT`. The urgency level for gas price estimation. Higher urgency results in higher gas price and faster transaction inclusion. Defaults to URGENT if not provided
- `v3NftTokenId`: integer. The V3 NFT position token ID. Required when approving a V3 position for migration

Example:

```json
{
  "walletAddress": "0x...",
  "protocol": "V2",
  "chainId": 1,
  "lpTokens": [
    {
      "tokenAddress": "0x455e53cbb86018ac2b8092fdcd39d8444affc3f6",
      "amount": "1000000000000000000"
    },
    {
      "tokenAddress": "0xdac17f958d2ee523a2206206994597c13d831ec7",
      "amount": "100650"
    }
  ],
  "action": "CREATE"
}
```

## Responses

### 200: LP approval check successful.

- `requestId` (required): string. A unique ID for the request
- `transactions`: array. The approval transactions needed. Empty if all approvals are already in place
  - items:
    - `transaction` (required): object
      - `to` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
      - `from` (required): string. The wallet address which will be used to send the token
      - `data` (required): string. The calldata for the transaction
      - `value` (required): string. The quantity of ETH tokens approved for spending by the transaction, denominated in wei. Note that by default Uniswap Labs sets this to the maximum approvable spend
      - `gasLimit`: string. The maximum units of gas that will be consumed by this transaction
      - `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `maxFeePerGas`: string. The sum of the base fee and priority fee. Subtracting `maxPriorityFeePerGas` from this value will yield the base fee to be paid for this transaction
      - `maxPriorityFeePerGas`: string. The maximum tip to the block builder. Adjusted based upon the urgency specified in the request
      - `gasPrice`: string. The cost per unit of gas
    - `cancelApproval` (required): boolean. Whether this transaction cancels a previous approval
    - `action` (required): string = `CREATE`, `INCREASE`, `DECREASE`, `MIGRATE`. The LP operation that the approval is needed for
    - `gasFee`: string. The total estimated gas cost of this transaction (eg. `gasLimit` multiplied by `maxFeePerGas`) in the base unit of the chain
- `v4BatchPermitData`: object. Batch permit data for V4 positions, if applicable
  - `domain`: object
  - `values`: object
  - `types`: object
- `v3NftPermitData`: object. NFT permit data for V3 positions, if applicable
  - `domain`: object
  - `values`: object
  - `types`: object

Example:

```json
{
  "requestId": "cMDelitrCYcEJow=",
  "transactions": [
    {
      "transaction": {
        "to": "0x455e53CBB86018Ac2B8092FdCd39d8444aFFC3F6",
        "from": "0xC9bebBA9f481b12cE6f3EA54c4B182c9636ec421",
        "data": "0x095ea7b300...",
        "value": "0x00",
        "chainId": 1
      },
      "cancelApproval": false,
      "action": "CREATE"
    },
    {
      "transaction": {
        "to": "0xdAC17F958D2ee523a2206206994597C13D831ec7",
        "from": "0xC9bebBA9f481b12cE6f3EA54c4B182c9636ec421",
        "data": "0x095ea7b300...",
        "value": "0x00",
        "chainId": 1
      },
      "cancelApproval": false,
      "action": "CREATE"
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

### 404: ResourceNotFound eg. Token allowance not found or Gas info not found.

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

