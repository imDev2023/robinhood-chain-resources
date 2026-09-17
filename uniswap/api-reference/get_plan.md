<!-- generated from openapi-trading-api.json | captured: 2026-08-22 -->
# Get an execution plan

`GET https://trade-api.gateway.uniswap.org/v1/plan/{planId}`  
operationId: `get_plan` · tags: chained-swapping

Retrieves an existing execution plan by its ID. Returns the full plan with current status and all steps. If forceRefresh is set to true, the plan will be refreshed to check for any updates to step statuses. Note: Completed plans cannot be refreshed.

## Parameters

- `planId` (path, required): The unique identifier of the plan to retrieve. 
- `forceRefresh` (query): Whether to force refresh the plan status. Defaults to false. Completed plans cannot be refreshed. 

## Responses

### 200: Get plan successful.

- `requestId` (required): string. A unique ID for the request
- `planId` (required): string. A unique identifier for this execution plan
- `swapper` (required): string. The wallet address which will be used to send the token
- `recipient` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
- `quoteId` (required): string. A unique ID for the quote
- `status` (required): string = `ACTIVE`, `AWAITING_ACTION`, `IN_PROGRESS`, `COMPLETED`, `FAILED`. The overall status of the plan execution. ACTIVE means the plan is ready to begin (all steps NOT_READY). AWAITING_ACTION means at least one step requires user action. IN_PROGRESS means at least one step is executing. COMPLETED means all steps have been successfully executed. FAILED means the plan cannot be completed
- `steps` (required): array. The sequential steps that need to be executed to complete the plan
  - items:
    - `stepIndex` (required): number. The index of this step in the plan (0-based)
    - `method` (required): string = `SEND_TX`, `SIGN_MSG`, `SEND_CALLS`. The execution method for the step. SEND_TX is a standard transaction. SIGN_MSG is for signing a message (e.g., permit). SEND_CALLS is for batch transaction execution (EIP-5792)
    - `payloadType` (required): string = `TX`, `EIP_712`, `EIP_5792`. The type of payload data. TX is a standard transaction object. EIP_712 is a typed structured data for signing. EIP_5792 is a batch of transaction calls
    - `payload` (required): object. The payload data for this step. The structure depends on the payloadType
    - `status` (required): string = `NOT_READY`, `AWAITING_ACTION`, `IN_PROGRESS`, `COMPLETE`, `STEP_ERROR`. The status of an individual step. NOT_READY means prerequisites are not met. AWAITING_ACTION means the step is ready for user action. IN_PROGRESS means the step is being executed. COMPLETE means the step finished successfully. STEP_ERROR means the step failed
    - `proof`: object. Proof of execution for a plan step, provided after the step is completed
      - `txHash`: string. The unique hash of the transaction
      - `signature`: string. The signature for a message signing step
      - `orderId`: string. The order ID for a gasless order step
    - `tokenIn`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `tokenOut`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `tokenInChainId`: number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `tokenOutChainId`: number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `tokenInAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `tokenOutAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `swapper`: string. The wallet address which will be used to send the token
    - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
    - `stepType`: string = `DUTCH_LIMIT`, `CLASSIC`, `DUTCH_V2`, `LIMIT_ORDER`, `WRAP`, `UNWRAP`, `BRIDGE`, `PRIORITY`, `DUTCH_V3`, `QUICKROUTE`, `CHAINED`, `VAULT_DEPOSIT`, `VAULT_WITHDRAW`, `APPROVAL_TXN`, `APPROVAL_PERMIT`, `RESET_APPROVAL_TXN`. The type of step in a plan, including swap types and approval types
    - `gasUseEstimate`: string. The maximum units of gas that will be consumed by this transaction
    - `gasFeeUSD`: string. The total estimated gas cost of this transaction (eg. `gasLimit` multiplied by `maxFeePerGas`) denominated in USDC
    - `gasFeeQuote`: string. The total estimated gas cost of this transaction (eg. gasLimit multiplied by maxFeePerGas) in the quoted currency (e.g. output token) in the base units of the quoted currency
    - `gasPrice`: string. The cost per unit of gas
    - `maxFeePerGas`: string. The sum of the base fee and priority fee. Subtracting `maxPriorityFeePerGas` from this value will yield the base fee to be paid for this transaction
    - `maxPriorityFeePerGas`: string. The maximum tip to the block builder. Adjusted based upon the urgency specified in the request
    - `gasFee`: string. The total estimated gas cost of this transaction (eg. `gasLimit` multiplied by `maxFeePerGas`) in the base unit of the chain
    - `routingStepKey`: string. An optional key identifying the routing strategy used for this step
    - `slippage`: number. The slippage tolerance as a percentage up to a maximum of two decimal places. For Uniswap Protocols (v2, v3, v4), the slippage tolerance is the maximum amount the price can change between the time the transaction is submitted and the time it is executed. The slippage tolerance is a percentage of the total value of the swap.  When submitting a quote, note that slippage tolerance works differently in UniswapX swaps where it does not set a limit on the Spread in an order. See [here](https://api-docs.uniswap.org/guides/faqs#why-do-uniswapx-quotes-have-more-slippage-than-the-tolerance-i-set) for more information.  Note that if the trade type is `EXACT_INPUT`, then the slippage is in terms of the output token. If the trade type is `EXACT_OUTPUT`, then the slippage is in terms of the input token.  When submitting a request, `slippageTolerance` may not be set when `autoSlippage` is defined. One of `slippageTolerance` or `autoSlippage` must be defined
- `currentStepIndex` (required): number. The index of the current step that needs to be executed (0-based)
- `expectedOutput` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `gasFee`: string. The total estimated gas cost of this transaction (eg. `gasLimit` multiplied by `maxFeePerGas`) in the base unit of the chain
- `gasFeeQuote`: string. The total estimated gas cost of this transaction (eg. gasLimit multiplied by maxFeePerGas) in the quoted currency (e.g. output token) in the base units of the quoted currency
- `gasFeeUSD`: string. The total estimated gas cost of this transaction (eg. `gasLimit` multiplied by `maxFeePerGas`) denominated in USDC
- `gasUseEstimate`: string. The maximum units of gas that will be consumed by this transaction
- `timeEstimateMs`: number. Estimated time in milliseconds to complete the entire plan
- `gasStrategies`: array. Gas strategies used for the plan
  - items:
    - `limitInflationFactor` (required): number. Factor to inflate the gas limit estimate
    - `priceInflationFactor` (required): number. Factor to inflate the gas price estimate
    - `percentileThresholdFor1559Fee` (required): number. Percentile threshold for EIP-1559 fee calculation
    - `thresholdToInflateLastBlockBaseFee`: number. Threshold to inflate the last block base fee
    - `baseFeeMultiplier`: number. Multiplier for the base fee
    - `baseFeeHistoryWindow`: number. Number of blocks to consider for base fee history
    - `minPriorityFeeRatioOfBaseFee`: number. Minimum priority fee as a ratio of base fee
    - `minPriorityFeeGwei`: number. Minimum priority fee in Gwei
    - `maxPriorityFeeGwei`: number. Maximum priority fee in Gwei
- `protocols`: array. The protocols to use for the swap/order. If the `protocols` field is defined, then you can only set the `routingPreference` to `BEST_PRICE`. Note that the value `UNISWAPX` is deprecated and will be removed in a future release
  - items:
    - enum: `V2`, `V3`, `V4`, `UNISWAPX`, `UNISWAPX_V2`, `UNISWAPX_V3`, `UNISWAPX_LATEST`
- `hooksOptions`: string = `V4_HOOKS_INCLUSIVE`, `V4_HOOKS_ONLY`, `V4_NO_HOOKS`. The hook options to use for V4 pool quotes. `V4_HOOKS_INCLUSIVE` will get quotes for V4 pools with or without hooks. `V4_HOOKS_ONLY` will only get quotes for V4 pools with hooks. `V4_NO_HOOKS` will only get quotes for V4 pools without hooks. Defaults to `V4_HOOKS_INCLUSIVE` if `V4` is included in `protocols` and `hookOptions` is not set. This field is ignored if `V4` is not passed in `protocols`
- `createdAt`: string. Timestamp when the plan was created
- `updatedAt`: string. Timestamp when the plan was last updated
- `completedAt`: string. Timestamp when the plan completed
- `lastUserActionAt`: string. Timestamp of the last user action on this plan
- `slippageTolerance`: number. The slippage tolerance as a percentage up to a maximum of two decimal places. For Uniswap Protocols (v2, v3, v4), the slippage tolerance is the maximum amount the price can change between the time the transaction is submitted and the time it is executed. The slippage tolerance is a percentage of the total value of the swap.  When submitting a quote, note that slippage tolerance works differently in UniswapX swaps where it does not set a limit on the Spread in an order. See [here](https://api-docs.uniswap.org/guides/faqs#why-do-uniswapx-quotes-have-more-slippage-than-the-tolerance-i-set) for more information.  Note that if the trade type is `EXACT_INPUT`, then the slippage is in terms of the output token. If the trade type is `EXACT_OUTPUT`, then the slippage is in terms of the input token.  When submitting a request, `slippageTolerance` may not be set when `autoSlippage` is defined. One of `slippageTolerance` or `autoSlippage` must be defined
- `autoSlippage`: string = `DEFAULT`. The auto slippage strategy to employ. For Uniswap Protocols (v2, v3, v4) the auto slippage will be automatically calculated when this field is set to `DEFAULT`. Auto slippage cannot be calculated for UniswapX swaps.  Note that if the trade type is `EXACT_INPUT`, then the slippage is in terms of the output token. If the trade type is `EXACT_OUTPUT`, then the slippage is in terms of the input token.  When submitting a request, `autoSlippage` may not be set when `slippageTolerance` is defined. One of `slippageTolerance` or `autoSlippage` must be defined
- `walletExecutionContext`: object. Wallet execution context based on CAIP-25 Standard. Provides information about wallet capabilities and scopes
  - `scopes` (required): object. Map of scope identifiers to their scope data
  - `properties`: object. Properties describing the wallet
    - `walletInfo`: object. Information about the wallet
      - `uuid`: string. Unique identifier for the wallet
      - `name`: string. Name of the wallet
      - `rdns`: string. Reverse domain name identifier for the wallet
- `earnIntent`: object. Validated Earn intent returned by /quote and /plan. Internal vault execution metadata is kept off the public contract
  - `action` (required): string = `deposit`, `withdraw`. The Earn vault action to quote or plan
  - `vault` (required): string
  - `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `withdrawMode`: string = `EXACT_ASSETS`, `MAX_SHARES`. The ERC-4626 withdraw mode. EXACT_ASSETS withdraws the requested asset amount; MAX_SHARES redeems the owner's currently redeemable shares
  - `destinationGasMode`: string = `WALLET_BALANCE`, `SELF_FUNDED`. Backend-selected funding mode for destination-chain gas on standard cross-chain Earn deposits. WALLET_BALANCE means the swapper has enough destination native gas; SELF_FUNDED means the route bridges native gas and reserves part of it for the remaining destination transactions
  - `underlyingAsset` (required): string
  - `requestedAssets`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
  - `preview`: object. Action-specific preview amounts computed while normalizing an Earn intent
    - oneOf: `` object
      - `type` (required): string = `DEPOSIT`
      - `depositAssets` (required): array. Vault underlying assets that will be deposited after any swap, bridge, wrap, or unwrap steps
        - items:
          - `token` (required): string
          - `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
          - `amount` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - `estimatedSharesOut` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - oneOf: `` object
      - `type` (required): string = `EXACT_ASSETS_WITHDRAW`
      - `requestedAssetsOut` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - `estimatedSharesIn` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - oneOf: `` object
      - `type` (required): string = `MAX_SHARES_WITHDRAW`
      - `maxRedeemableSharesIn` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - `previewAssetsOut` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0

### 400: RequestValidationError, Bad Input

- `errorCode`: string
- `detail`: string

### 401: UnauthorizedError eg. Account is blocked.

- `errorCode`: string
- `detail`: string

### 404: ResourceNotFound eg. No quotes available or Gas fee/price not available

- `errorCode`: string = `ResourceNotFound`, `QuoteAmountTooLowError`, `TokenBalanceNotAvailable`, `InsufficientBalance`
- `detail`: string

### 422: UnprocessableEntity eg. Plan is already completed and cannot be updated.

- `errorCode`: string
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

