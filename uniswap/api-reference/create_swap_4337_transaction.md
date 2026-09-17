<!-- generated from openapi-trading-api.json | captured: 2026-08-22 -->
# Create swap ERC-4337 UserOperation

`POST https://trade-api.gateway.uniswap.org/v1/swap_4337`  
operationId: `create_swap_4337_transaction` · tags: swapping

Builds and returns a partially-populated ERC-4337 v0.8 UserOperation for executing a swap (including wrap/unwrap and bridging) against the Uniswap Protocols. The response includes any required ERC-20 approval and Permit2 calls bundled into the UserOperation's `callData`. Paymaster fields are left empty for the wallet to populate via `pm_sponsorUserOperation` before signing and submitting to the bundler. The `signature` field contains a dummy value that the wallet must replace before submission.

## Parameters

- `x-universal-router-version` (header): The version of the Universal Router to use for the swap journey. *MUST* be consistent throughout the API calls. default `2.0`

## Request body (application/json)

- `quote` (required): object
  - oneOf: `Classic Quote` object
    - `priceDifference`: number. The expected value lost versus frictionless execution at current prices, as a percent between -100 and 100. Negative values indicate price improvement. For classic swaps this equals priceImpact, the pool-based impact reported by routing
    - `input`: object
      - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - `token`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `maximumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `output`: object
      - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
      - `minimumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `swapper`: string. The wallet address which will be used to send the token
    - `chainId`: number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `slippage`: number. The slippage tolerance as a percentage up to a maximum of two decimal places. For Uniswap Protocols (v2, v3, v4), the slippage tolerance is the maximum amount the price can change between the time the transaction is submitted and the time it is executed. The slippage tolerance is a percentage of the total value of the swap.  When submitting a quote, note that slippage tolerance works differently in UniswapX swaps where it does not set a limit on the Spread in an order. See [here](https://api-docs.uniswap.org/guides/faqs#why-do-uniswapx-quotes-have-more-slippage-than-the-tolerance-i-set) for more information.  Note that if the trade type is `EXACT_INPUT`, then the slippage is in terms of the output token. If the trade type is `EXACT_OUTPUT`, then the slippage is in terms of the input token.  When submitting a request, `slippageTolerance` may not be set when `autoSlippage` is defined. One of `slippageTolerance` or `autoSlippage` must be defined
    - `tradeType`: string = `EXACT_INPUT`, `EXACT_OUTPUT`. The handling of the `amount` field. `EXACT_INPUT` means the requester will send the specified `amount` of input tokens and get a quote with a variable quantity of output tokens. `EXACT_OUTPUT` means the requester will receive the specified `amount` of output tokens and get a quote with a variable quantity of input tokens
    - `gasFee`: string. The total estimated gas cost of this transaction (eg. `gasLimit` multiplied by `maxFeePerGas`) in the base unit of the chain
    - `gasFeeUSD`: string. The total estimated gas cost of this transaction (eg. `gasLimit` multiplied by `maxFeePerGas`) denominated in USDC
    - `gasFeeQuote`: string. The total estimated gas cost of this transaction (eg. gasLimit multiplied by maxFeePerGas) in the quoted currency (e.g. output token) in the base units of the quoted currency
    - `route`: array
      - items:
        - items:
          - oneOf: `V2 Route` object
            - `type`: string
            - `address`: string. The address of a contract which will be used to facilitate the swap
            - `tokenIn`: object
            - `tokenOut`: object
            - `reserve0`: object. The remaining reserve of this token in the pool
            - `reserve1`: object. The remaining reserve of this token in the pool
            - `amountIn`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
            - `amountOut`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
          - oneOf: `V3 Route` object
            - `type`: string
            - `address`: string. The address of a contract which will be used to facilitate the swap
            - `tokenIn`: object
            - `tokenOut`: object
            - `sqrtRatioX96`: string. The square root of the ratio of the token0 and token1 in the pool, as a Q64.64 number. For more information see the [Uniswap V3 Whitepaper](https://app.uniswap.org/whitepaper-v3.pdf)
            - `liquidity`: string. The amount of liquidity in the pool at a given tick. For more information see the [Uniswap V3 Whitepaper](https://app.uniswap.org/whitepaper-v3.pdf)
            - `tickCurrent`: string. The current tick of the pool. For more information see the [Uniswap V3 Whitepaper](https://app.uniswap.org/whitepaper-v3.pdf)
            - `fee`: string. The fee of the pool in basis points
            - `amountIn`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
            - `amountOut`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
          - oneOf: `V4 Route` object
            - `type` (required): string
            - `address` (required): string. The address of a contract which will be used to facilitate the swap
            - `tokenIn` (required): object
            - `tokenOut` (required): object
            - `sqrtRatioX96` (required): string. The square root of the ratio of the token0 and token1 in the pool, as a Q64.64 number. For more information see the [Uniswap V3 Whitepaper](https://app.uniswap.org/whitepaper-v3.pdf)
            - `liquidity` (required): string. The amount of liquidity in the pool at a given tick. For more information see the [Uniswap V3 Whitepaper](https://app.uniswap.org/whitepaper-v3.pdf)
            - `tickCurrent` (required): string. The current tick of the pool. For more information see the [Uniswap V3 Whitepaper](https://app.uniswap.org/whitepaper-v3.pdf)
            - `fee` (required): string. The fee of the pool in basis points
            - `tickSpacing` (required): number. The width of ticks in this pool (e.g. the price range between two ticks) specified in basis points. For more information see the [Uniswap V3 Whitepaper](https://app.uniswap.org/whitepaper-v3.pdf)
            - `hooks` (required): string. The address of the hook for the pool, if any. If the pool has no hook, this field will be the null address (e.g. 0x0000000000000000000000000000000000000000)
            - `amountIn`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
            - `amountOut`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `portionBips`: number. The portion of the swap that will be taken as a fee stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 87.5 for 0.875%). The fee will be taken from the output token
    - `portionAmount`: string. The portion of the swap that will be taken as a fee in the base units of the token. The fee will be taken from the output token
    - `portionRecipient`: string. The wallet address which will receive the fee
    - `routeString`: string. The route in string format
    - `quoteId`: string. A unique ID for the quote
    - `gasUseEstimate`: string. The estimated gas use. It does NOT include the additional gas for token approvals
    - `blockNumber`: string. The current block number
    - `gasPrice`: string. The cost per unit of gas
    - `maxFeePerGas`: string. The sum of the base fee and priority fee. Subtracting `maxPriorityFeePerGas` from this value will yield the base fee to be paid for this transaction
    - `maxPriorityFeePerGas`: string. The maximum tip to the block builder. Adjusted based upon the urgency specified in the request
    - `txFailureReasons`: array. The reason(s) why the transaction failed during simulation
      - items:
        - enum: `SIMULATION_ERROR`, `UNSUPPORTED_SIMULATION`, `SIMULATION_UNAVAILABLE`, `SLIPPAGE_TOO_LOW`, `TRANSFER_FROM_FAILED`
    - `priceImpact`: number. The impact the trade has on the market price of the pool, between 0-100 percent
    - `aggregatedOutputs`: array
      - items:
        - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
        - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
        - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
        - `bps`: number. The portion of the swap stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 12.5)
        - `minAmount`: string. The minimum portion of the swap, stated in the base unit of the token, which will be output to the recipient
        - `fee`: string = `INTEGRATOR`. Set to INTEGRATOR when this output is an integrator fee (as specified by the `integratorFees` array in the /quote request); omitted for the core output of the swap
    - `swapSteps`: array. Universal Router swap step sequence. Additive, opt-in via the `x-universal-router-swapsteps` header. When present, mirrors the inputs to `SwapRouter.encodeSwaps`. Only emitted when GuideStar wins the hybrid quoter race (`EXACT_INPUT` today; broader coverage once UniRoute's transformer ships)
      - items:
        - oneOf: `` object
          - `type` (required): string = `V2_SWAP_EXACT_IN`
          - `recipient` (required): string
          - `amountIn` (required): string
          - `amountOutMin` (required): string
          - `path` (required): array
          - `minHopPriceX36`: array
        - oneOf: `` object
          - `type` (required): string = `V2_SWAP_EXACT_OUT`
          - `recipient` (required): string
          - `amountOut` (required): string
          - `amountInMax` (required): string
          - `path` (required): array
          - `minHopPriceX36`: array
        - oneOf: `` object
          - `type` (required): string = `V3_SWAP_EXACT_IN`
          - `recipient` (required): string
          - `amountIn` (required): string
          - `amountOutMin` (required): string
          - `path` (required): string. Hex-encoded packed V3 path (e.g. `0xa0b8...000bb8c02aaa...`)
          - `minHopPriceX36`: array
        - oneOf: `` object
          - `type` (required): string = `V3_SWAP_EXACT_OUT`
          - `recipient` (required): string
          - `amountOut` (required): string
          - `amountInMax` (required): string
          - `path` (required): string. Hex-encoded packed V3 path (e.g. `0xa0b8...000bb8c02aaa...`)
          - `minHopPriceX36`: array
        - oneOf: `` object
          - `type` (required): string = `V4_SWAP`
          - `v4Actions` (required): array
        - oneOf: `` object
          - `type` (required): string = `WRAP_ETH`
          - `recipient` (required): string
          - `amount` (required): string
        - oneOf: `` object
          - `type` (required): string = `UNWRAP_WETH`
          - `recipient` (required): string
          - `amountMin` (required): string
  - oneOf: `Wrap/Unwrap Quote` object
    - `priceDifference`: number. The expected value lost versus frictionless execution at current prices, as a percent between -100 and 100. Negative values indicate price improvement. Always 0, since wraps and unwraps are 1:1
    - `swapper`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
    - `input`: object
      - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - `token`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `maximumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `output`: object
      - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
      - `minimumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `chainId`: number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `tradeType`: string = `EXACT_INPUT`, `EXACT_OUTPUT`. The handling of the `amount` field. `EXACT_INPUT` means the requester will send the specified `amount` of input tokens and get a quote with a variable quantity of output tokens. `EXACT_OUTPUT` means the requester will receive the specified `amount` of output tokens and get a quote with a variable quantity of input tokens
    - `gasFee`: string. The total estimated gas cost of this transaction (eg. `gasLimit` multiplied by `maxFeePerGas`) in the base unit of the chain
    - `gasFeeUSD`: string. The total estimated gas cost of this transaction (eg. `gasLimit` multiplied by `maxFeePerGas`) denominated in USDC
    - `gasFeeQuote`: string. The total estimated gas cost of this transaction (eg. gasLimit multiplied by maxFeePerGas) in the quoted currency (e.g. output token) in the base units of the quoted currency
    - `gasUseEstimate`: string. The maximum units of gas that will be consumed by this transaction
    - `gasPrice`: string. The cost per unit of gas
    - `maxFeePerGas`: string. The sum of the base fee and priority fee. Subtracting `maxPriorityFeePerGas` from this value will yield the base fee to be paid for this transaction
    - `maxPriorityFeePerGas`: string. The maximum tip to the block builder. Adjusted based upon the urgency specified in the request
  - oneOf: `Bridge Quote` object
    - `priceDifference`: number. The expected value lost versus frictionless execution at current prices, as a percent between -100 and 100. Negative values indicate price improvement. For bridges this is the relayer fee as a percent of the input, 1 - amountOut / amountIn, computed on raw amounts since the same asset with the same decimals is bridged on both chains
    - `quoteId`: string. A unique ID for the quote
    - `chainId`: number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `destinationChainId`: number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `swapper`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
    - `input`: object
      - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - `token`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `maximumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `output`: object
      - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
      - `minimumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `tradeType`: string = `EXACT_INPUT`, `EXACT_OUTPUT`. The handling of the `amount` field. `EXACT_INPUT` means the requester will send the specified `amount` of input tokens and get a quote with a variable quantity of output tokens. `EXACT_OUTPUT` means the requester will receive the specified `amount` of output tokens and get a quote with a variable quantity of input tokens
    - `quoteTimestamp`: number
    - `gasPrice`: string. The cost per unit of gas
    - `maxFeePerGas`: string. The sum of the base fee and priority fee. Subtracting `maxPriorityFeePerGas` from this value will yield the base fee to be paid for this transaction
    - `maxPriorityFeePerGas`: string. The maximum tip to the block builder. Adjusted based upon the urgency specified in the request
    - `gasFee`: string. The total estimated gas cost of this transaction (eg. `gasLimit` multiplied by `maxFeePerGas`) in the base unit of the chain
    - `gasUseEstimate`: string. The maximum units of gas that will be consumed by this transaction
    - `gasFeeUSD`: string. The total estimated gas cost of this transaction (eg. `gasLimit` multiplied by `maxFeePerGas`) denominated in USDC
    - `portionBips`: number. The portion of the swap that will be taken as a fee stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 87.5 for 0.875%). The fee will be taken from the output token
    - `portionAmount`: string. The portion of the swap that will be taken as a fee in the base units of the token. The fee will be taken from the output token
    - `portionRecipient`: string. The wallet address which will receive the fee
    - `estimatedFillTimeMs`: number. The estimated time it will take to fill the order in milliseconds
    - `exclusiveRelayer`: string. The address of the exclusive filler (the relayer)
    - `exclusivityDeadline`: number. The deadline (unix timestamp) by which the exclusive relayer must fill the order before other relayers can fill it
    - `fillDeadline`: number. The deadline by which, if the order is not filled, the order will be reverted
- `sender` (required): string
- `permitData`: object. the permit2 message object for the customer to sign to permit spending by the permit2 contract
  - `domain`: object
  - `values`: object
  - `types`: object
- `deadline`: number. The unix timestamp at which the order will be reverted if not filled
- `eip7702Auth`: object. Signed EIP-7702 authorization tuple
  - `address` (required): string. Contract address to delegate to
  - `chainId` (required): string. Hex-encoded chain ID
  - `nonce` (required): string. Hex-encoded nonce
  - `r` (required): string. ECDSA r value
  - `s` (required): string. ECDSA s value
  - `yParity` (required): string. ECDSA y parity
- `sponsorshipInfo`: object. Gas sponsorship information for the quoted swap. When `sponsored` is `true`, gas fees for executing this swap will be covered by the sponsor described in `sponsorMetadata`, under the campaign described in `campaign`. When `sponsored` is `false`, `rejectionReason` describes why sponsorship was not granted
  - `sponsored`: boolean. Whether gas for this swap is sponsored
  - `rejectionReason`: string. Reason gas sponsorship was not granted. Present only when `sponsored` is `false`
  - `campaign`: object. Display information about the sponsorship campaign covering gas fees for the swap
    - `name`: string. Machine-readable campaign identifier
    - `description`: string. Subheader text for the campaign
    - `headline`: string. Human-readable headline for the campaign
    - `thumbnailUrl`: string. URL of the campaign's thumbnail image
    - `allowances`: array. Per-wallet caps and utilization, one entry per dimension (free-swap count and/or cost)
      - items:
        - `unit`: string = `FREE_SWAPS`, `USD_CENT`. Unit the allowance is denominated in
        - `total`: string. Total per-wallet allowance
        - `remaining`: string. Allowance still available to this wallet
    - `eligibleChains`: array. Chain IDs the campaign covers, for the eligible-chains modal
      - items:
  - `sponsorMetadata`: object. Display information about the sponsor covering gas fees for the swap
    - `name`: string. Display name of the sponsor
    - `icon`: string. URL of the sponsor's icon

## Responses

### 200: UserOperation encoded successfully.

- `requestId` (required): string. A unique ID for the request
- `userOperation` (required): object. ERC-4337 v0.8 UserOperation
  - `sender` (required): string. Smart account address that will execute the operation
  - `nonce` (required): string. Anti-replay nonce from the EntryPoint
  - `callData` (required): string. ABI-encoded call data for the batch execution
  - `callGasLimit` (required): string. Gas limit for the main execution call
  - `verificationGasLimit` (required): string. Gas limit for the verification step
  - `preVerificationGas` (required): string. Gas to cover bundler overhead and L1 data costs
  - `maxFeePerGas` (required): string. EIP-1559 max fee per gas
  - `maxPriorityFeePerGas` (required): string. EIP-1559 max priority fee per gas
  - `factory`: string. Account factory address (present for first-time account deployment)
  - `factoryData`: string. Calldata for the account factory
  - `paymaster`: string. Paymaster contract address (present when gas is sponsored)
  - `paymasterVerificationGasLimit`: string. Gas limit for paymaster verification
  - `paymasterPostOpGasLimit`: string. Gas limit for paymaster post-operation
  - `paymasterData`: string. Paymaster-specific data
  - `signature` (required): string. Dummy signature placeholder; the client signs the UserOperation after receiving this response
  - `eip7702Auth`: object. Signed EIP-7702 authorization tuple
    - `address` (required): string. Contract address to delegate to
    - `chainId` (required): string. Hex-encoded chain ID
    - `nonce` (required): string. Hex-encoded nonce
    - `r` (required): string. ECDSA r value
    - `s` (required): string. ECDSA s value
    - `yParity` (required): string. ECDSA y parity
- `gasSponsored` (required): boolean. Whether gas for this operation will be sponsored by a paymaster
- `gasSponsorshipRejectionReason`: string. Reason gas sponsorship was not granted. Present only when `gasSponsored` is `false`
- `paymasterServiceContext`: object. EIP-7677 paymasterService.context bundle. The wallet forwards this verbatim to the paymaster RPC (or — for ERC-4337 — to /wallet/encode_4337). `sponsorship` is opaque AES-256-GCM ciphertext whose integrity is enforced cryptographically on the uniRPC side
  - `sponsorship` (required): string

### 400: RequestValidationError, Bad Input

- `errorCode`: string
- `detail`: string

### 401: UnauthorizedError eg. Account is blocked or  Fee is not enabled.

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

