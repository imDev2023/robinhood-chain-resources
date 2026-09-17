<!-- generated from openapi-trading-api.json | captured: 2026-08-22 -->
# Trading API schemas

## senderWalletAddress

The wallet address which will be used to send the token.


## receiverWalletAddress

(optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`.


## contractAddress

The address of a contract which will be used to facilitate the swap.


## cosignerAddress

The address of a cosigner who will run the auction and ensure the best executable price within the given parameters. Currently the cosigner is always Uniswap Labs.


## inputToken

The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs).


## outputToken

The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs).


## tokenAmount

The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0.


## tokenSymbol

The symbol of the token.


## generatePermitAsTransaction

Indicates whether you want to receive a permit2 transaction to sign and submit onchain, or a permit message to sign. When set to `true`, the quote response returns the Permit2 as a calldata which the user signs and broadcasts. When set to `false` (the default), the quote response returns the Permit2 as a message which the user signs but does not need to broadcast. When using a 7702-delegated wallet, set this field to `true`. Except for this scenario, it is recommended that this field is set to false. Note that a Permit2 calldata (e.g. `true`), will provide indefinite permission for Permit2 to spend a token, in contrast to a Permit2 message (e.g. `false`) which is only valid for 30 days. Further, a Permit2 calldata (e.g. `true`) requires the user to pay gas to submit the transaction, whereas the Permit2 message (e.g. `false` ) does not require the user to submit a transaction and requires no gas.


## slippageTolerance

The slippage tolerance as a percentage up to a maximum of two decimal places. For Uniswap Protocols (v2, v3, v4), the slippage tolerance is the maximum amount the price can change between the time the transaction is submitted and the time it is executed. The slippage tolerance is a percentage of the total value of the swap.

When submitting a quote, note that slippage tolerance works differently in UniswapX swaps where it does not set a limit on the Spread in an order. See [here](https://api-docs.uniswap.org/guides/faqs#why-do-uniswapx-quotes-have-more-slippage-than-the-tolerance-i-set) for more information.

Note that if the trade type is `EXACT_INPUT`, then the slippage is in terms of the output token. If the trade type is `EXACT_OUTPUT`, then the slippage is in terms of the input token.

When submitting a request, `slippageTolerance` may not be set when `autoSlippage` is defined. One of `slippageTolerance` or `autoSlippage` must be defined.


## SwapStatus



- enum: `PENDING`, `SUCCESS`, `NOT_FOUND`, `FAILED`, `EXPIRED`

## GetSwapsResponse



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

## GetSupportedChainsResponse



- `requestId` (required): string. A unique ID for the request
- `chains` (required): array
  - items:
    - `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `chainName` (required): string
    - `contractAddresses` (required): array
      - items:
        - `name` (required): string
        - `version`: string. Only present where it distinguishes deployments: contract release lines (e.g. UniversalRouter 2.0/2.1.1/2.2.0, CaliburEntry tags) and same-named contracts (Quoter V3 vs V4)
        - `address` (required): string
    - `protocols` (required): array
      - items:
        - enum: `V2`, `V3`, `V4`, `UniswapX`
    - `actions` (required): array
      - items:
        - enum: `SWAP`, `LP`

## SupportedChain



- `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `chainName` (required): string
- `contractAddresses` (required): array
  - items:
    - `name` (required): string
    - `version`: string. Only present where it distinguishes deployments: contract release lines (e.g. UniversalRouter 2.0/2.1.1/2.2.0, CaliburEntry tags) and same-named contracts (Quoter V3 vs V4)
    - `address` (required): string
- `protocols` (required): array
  - items:
    - enum: `V2`, `V3`, `V4`, `UniswapX`
- `actions` (required): array
  - items:
    - enum: `SWAP`, `LP`

## ChainContractAddress



- `name` (required): string
- `version`: string. Only present where it distinguishes deployments: contract release lines (e.g. UniversalRouter 2.0/2.1.1/2.2.0, CaliburEntry tags) and same-named contracts (Quoter V3 vs V4)
- `address` (required): string

## GetSwappableTokensResponse



- `requestId` (required): string. A unique ID for the request
- `tokens` (required): array
  - items:
    - `address` (required): string
    - `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `name` (required): string. The name of the token
    - `symbol` (required): string. The symbol of the token
    - `project` (required): object
      - `logo` (required): object
        - `url` (required): string
      - `safetyLevel` (required): string = `BLOCKED`, `MEDIUM_WARNING`, `STRONG_WARNING`, `VERIFIED`
      - `isSpam` (required): boolean. Whether the token is considered a spam token
    - `isSpam`: boolean. Whether the token is considered a spam token
    - `decimals` (required): number. The number of decimals supported by the token. This number is used to convert token amounts to the token's common representation

## CreateSwapRequest

The parameters **signature** and **permitData** should only be included if *permitData* was returned from **/quote**.

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
- `signature`: string. The signed permit
- `includeGasInfo`: boolean. Use `refreshGasPrice` instead
- `refreshGasPrice`: boolean. If true, the gas price will be re-fetched from the network
- `simulateTransaction`: boolean. If true, the transaction will be simulated. If the simulation results on an onchain error, endpoint will return an error
- `permitData`: object
  - `domain`: object
  - `values`: object
  - `types`: object
- `safetyMode`: string = `SAFE`. Swap safety mode will automatically sweep the transaction for the native token and return it to the sender wallet address. This is to prevent accidental loss of funds in the event that the token amount is set in the transaction value instead of as part of the calldata
- `deadline`: number. The unix timestamp at which the order will be reverted if not filled
- `urgency`: object. The urgency impacts the estimated gas price of the transaction. The higher the urgency, the higher the gas price, and the faster the transaction is likely to be selected from the mempool. Send the bare string form (e.g. `"normal"`) for the common case, or the object form `{ level, overrides }` to supply caller caps for `maxPriorityFeePerGas`, `maxFeePerGas`, and `gasLimit`
  - oneOf: `` string
    - enum: `normal`, `fast`, `urgent`
  - oneOf: `` object
    - `level` (required): string = `normal`, `fast`, `urgent`
    - `overrides`: object. Caller-supplied caps applied on top of the gas service's computed quote. All fields are absolute wei (decimal string). `maxPriorityFeePerGas` and `maxFeePerGas` are treated as caps - they lower the quote, never raise it. `gasLimit`, if set, replaces the limit calculation entirely
      - `maxPriorityFeePerGas`: string. Maximum priority fee in wei (decimal string)
      - `maxFeePerGas`: string. Maximum total fee per gas in wei (decimal string)
      - `gasLimit`: string. Gas limit cap (in gas units, decimal string)

## CreateSwap5792Request



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
  - oneOf: `` object
    - `encodedOrder` (required): string. An encoded copy of the order details which will be submitted to the filler network along with the signed permit
    - `orderId` (required): string. A unique ID for the order. Used to track the order's status
    - `orderInfo` (required): object
      - `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `nonce` (required): string. A unique nonce for this order
      - `reactor` (required): string. The address of a contract which will be used to facilitate the swap
      - `swapper` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
      - `deadline` (required): number. The unix timestamp at which the order will be reverted if not filled
      - `additionalValidationContract`: string. Unused and deprecated
      - `additionalValidationData`: string. Unused and deprecated
      - `decayStartTime`: number. The unix timestamp at which the order will be eligible to be filled by alternate fillers at a lower price. Noted that the fill amount will not be lower than the output `endAmount`
      - `decayEndTime`: number. The unix timestamp at which the order will no longer be eligible to be filled by alternate fillers
      - `exclusiveFiller` (required): string. The address of the filler who has priority to fill the order by the `decayStartTime`
      - `exclusivityOverrideBps` (required): string. The portion of the order which is eligible to be filled by the `exclusiveFiller`, specified in basis points
      - `input` (required): object
        - `startAmount` (required): string. The intended execution quantity of tokens resulting from this swap
        - `endAmount` (required): string. The worst case quantity of tokens resulting from this swap
        - `token`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `outputs` (required): array
        - items:
          - `startAmount` (required): string. The intended execution quantity of tokens resulting from this swap
          - `endAmount` (required): string. The worst case quantity of tokens resulting from this swap
          - `token` (required): string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
          - `recipient` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
    - `input`: object
      - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - `token`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `maximumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `output`: object
      - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
      - `minimumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `portionBips`: number. The portion of the swap that will be taken as a fee stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 87.5 for 0.875%). The fee will be taken from the output token
    - `portionAmount`: string. The portion of the swap that will be taken as a fee in the base units of the token. The fee will be taken from the output token
    - `portionRecipient`: string. The wallet address which will receive the fee
    - `quoteId`: string. A unique ID for the quote
    - `slippageTolerance`: number. The slippage tolerance as a percentage up to a maximum of two decimal places. For Uniswap Protocols (v2, v3, v4), the slippage tolerance is the maximum amount the price can change between the time the transaction is submitted and the time it is executed. The slippage tolerance is a percentage of the total value of the swap.  When submitting a quote, note that slippage tolerance works differently in UniswapX swaps where it does not set a limit on the Spread in an order. See [here](https://api-docs.uniswap.org/guides/faqs#why-do-uniswapx-quotes-have-more-slippage-than-the-tolerance-i-set) for more information.  Note that if the trade type is `EXACT_INPUT`, then the slippage is in terms of the output token. If the trade type is `EXACT_OUTPUT`, then the slippage is in terms of the input token.  When submitting a request, `slippageTolerance` may not be set when `autoSlippage` is defined. One of `slippageTolerance` or `autoSlippage` must be defined
    - `classicGasUseEstimateUSD`: string. The gas fee you would pay if you opted for a CLASSIC swap over a Uniswap X order in terms of USD
    - `aggregatedOutputs`: array
      - items:
        - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
        - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
        - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
        - `bps`: number. The portion of the swap stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 12.5)
        - `minAmount`: string. The minimum portion of the swap, stated in the base unit of the token, which will be output to the recipient
        - `fee`: string = `INTEGRATOR`. Set to INTEGRATOR when this output is an integrator fee (as specified by the `integratorFees` array in the /quote request); omitted for the core output of the swap
  - oneOf: `UniswapX V2 Quote` object
    - `priceDifference`: number. The expected value lost versus frictionless execution at current prices, as a percent between -100 and 100. Negative values indicate price improvement. For UniswapX orders this prefers USD parity, computed as 1 - (outputUSD + classicGasUseEstimateUSD) / inputUSD over the auction start amounts (the gas estimate is added back because the filler's gas is baked into the output), and falls back to comparing the execution price against the mid price implied by the classic quote (its execution price divided by 1 - priceImpact). Absent when neither source is available
    - `encodedOrder` (required): string. An encoded copy of the order details which will be submitted to the filler network along with the signed permit
    - `orderId` (required): string. A unique ID for the order. Used to track the order's status
    - `orderInfo` (required): object
      - `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `nonce` (required): string. A unique nonce for this order
      - `reactor` (required): string. The address of a contract which will be used to facilitate the swap
      - `swapper` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
      - `deadline` (required): number. The unix timestamp at which the order will be reverted if not filled
      - `additionalValidationContract`: string. Unused and deprecated
      - `additionalValidationData`: string. Unused and deprecated
      - `input` (required): object
        - `startAmount` (required): string. The intended execution quantity of tokens resulting from this swap
        - `endAmount` (required): string. The worst case quantity of tokens resulting from this swap
        - `token`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `outputs` (required): array
        - items:
          - `startAmount` (required): string. The intended execution quantity of tokens resulting from this swap
          - `endAmount` (required): string. The worst case quantity of tokens resulting from this swap
          - `token` (required): string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
          - `recipient` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
      - `cosigner`: string. The address of a cosigner who will run the auction and ensure the best executable price within the given parameters. Currently the cosigner is always Uniswap Labs
    - `input`: object
      - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - `token`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `maximumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `output`: object
      - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
      - `minimumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `portionBips`: number. The portion of the swap that will be taken as a fee stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 87.5 for 0.875%). The fee will be taken from the output token
    - `portionAmount`: string. The portion of the swap that will be taken as a fee in the base units of the token. The fee will be taken from the output token
    - `portionRecipient`: string. The wallet address which will receive the fee
    - `quoteId`: string. A unique ID for the quote
    - `slippageTolerance`: number. The slippage tolerance as a percentage up to a maximum of two decimal places. For Uniswap Protocols (v2, v3, v4), the slippage tolerance is the maximum amount the price can change between the time the transaction is submitted and the time it is executed. The slippage tolerance is a percentage of the total value of the swap.  When submitting a quote, note that slippage tolerance works differently in UniswapX swaps where it does not set a limit on the Spread in an order. See [here](https://api-docs.uniswap.org/guides/faqs#why-do-uniswapx-quotes-have-more-slippage-than-the-tolerance-i-set) for more information.  Note that if the trade type is `EXACT_INPUT`, then the slippage is in terms of the output token. If the trade type is `EXACT_OUTPUT`, then the slippage is in terms of the input token.  When submitting a request, `slippageTolerance` may not be set when `autoSlippage` is defined. One of `slippageTolerance` or `autoSlippage` must be defined
    - `deadlineBufferSecs`: number
    - `classicGasUseEstimateUSD`: string. The gas fee you would pay if you opted for a CLASSIC swap over a Uniswap X order in terms of USD
    - `aggregatedOutputs`: array
      - items:
        - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
        - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
        - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
        - `bps`: number. The portion of the swap stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 12.5)
        - `minAmount`: string. The minimum portion of the swap, stated in the base unit of the token, which will be output to the recipient
        - `fee`: string = `INTEGRATOR`. Set to INTEGRATOR when this output is an integrator fee (as specified by the `integratorFees` array in the /quote request); omitted for the core output of the swap
  - oneOf: `UniswapX V3 Quote` object
    - `priceDifference`: number. The expected value lost versus frictionless execution at current prices, as a percent between -100 and 100. Negative values indicate price improvement. For UniswapX orders this prefers USD parity, computed as 1 - (outputUSD + classicGasUseEstimateUSD) / inputUSD over the auction start amounts (the gas estimate is added back because the filler's gas is baked into the output), and falls back to comparing the execution price against the mid price implied by the classic quote (its execution price divided by 1 - priceImpact). Absent when neither source is available
    - `encodedOrder` (required): string. An encoded copy of the order details which will be submitted to the filler network along with the signed permit
    - `orderId` (required): string. A unique ID for the order. Used to track the order's status
    - `orderInfo` (required): object
      - `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `nonce` (required): string. A unique nonce for this order
      - `reactor` (required): string. The address of a contract which will be used to facilitate the swap
      - `swapper` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
      - `deadline` (required): number. The unix timestamp at which the order will be reverted if not filled
      - `additionalValidationContract`: string. Unused and deprecated
      - `additionalValidationData`: string. Unused and deprecated
      - `input` (required): object
        - `startAmount` (required): string. The intended execution quantity of tokens resulting from this swap
        - `maxAmount` (required): string
        - `adjustmentPerGweiBaseFee` (required): string
        - `curve` (required): object
        - `token` (required): string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `outputs` (required): array
        - items:
          - `startAmount` (required): string. The intended execution quantity of tokens resulting from this swap
          - `minAmount`: string. The minimum portion of the swap, stated in the base unit of the token, which will be output to the recipient
          - `recipient` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
          - `adjustmentPerGweiBaseFee` (required): string
          - `curve` (required): object
          - `token` (required): string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `cosigner`: string. The address of a cosigner who will run the auction and ensure the best executable price within the given parameters. Currently the cosigner is always Uniswap Labs
      - `startingBaseFee`: string
    - `input`: object
      - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - `token`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `maximumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `output`: object
      - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
      - `minimumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `portionBips`: number. The portion of the swap that will be taken as a fee stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 87.5 for 0.875%). The fee will be taken from the output token
    - `portionAmount`: string. The portion of the swap that will be taken as a fee in the base units of the token. The fee will be taken from the output token
    - `portionRecipient`: string. The wallet address which will receive the fee
    - `quoteId`: string. A unique ID for the quote
    - `slippageTolerance`: number. The slippage tolerance as a percentage up to a maximum of two decimal places. For Uniswap Protocols (v2, v3, v4), the slippage tolerance is the maximum amount the price can change between the time the transaction is submitted and the time it is executed. The slippage tolerance is a percentage of the total value of the swap.  When submitting a quote, note that slippage tolerance works differently in UniswapX swaps where it does not set a limit on the Spread in an order. See [here](https://api-docs.uniswap.org/guides/faqs#why-do-uniswapx-quotes-have-more-slippage-than-the-tolerance-i-set) for more information.  Note that if the trade type is `EXACT_INPUT`, then the slippage is in terms of the output token. If the trade type is `EXACT_OUTPUT`, then the slippage is in terms of the input token.  When submitting a request, `slippageTolerance` may not be set when `autoSlippage` is defined. One of `slippageTolerance` or `autoSlippage` must be defined
    - `deadlineBufferSecs`: number
    - `classicGasUseEstimateUSD`: string. The gas fee you would pay if you opted for a CLASSIC swap over a Uniswap X order in terms of USD
    - `expectedAmountIn`: string
    - `expectedAmountOut`: string
    - `aggregatedOutputs`: array
      - items:
        - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
        - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
        - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
        - `bps`: number. The portion of the swap stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 12.5)
        - `minAmount`: string. The minimum portion of the swap, stated in the base unit of the token, which will be output to the recipient
        - `fee`: string = `INTEGRATOR`. Set to INTEGRATOR when this output is an integrator fee (as specified by the `integratorFees` array in the /quote request); omitted for the core output of the swap
  - oneOf: `UniswapX Priority Quote` object
    - `priceDifference`: number. The expected value lost versus frictionless execution at current prices, as a percent between -100 and 100. Negative values indicate price improvement. For UniswapX orders this prefers USD parity, computed as 1 - (outputUSD + classicGasUseEstimateUSD) / inputUSD over the auction start amounts (the gas estimate is added back because the filler's gas is baked into the output), and falls back to comparing the execution price against the mid price implied by the classic quote (its execution price divided by 1 - priceImpact). Absent when neither source is available
    - `encodedOrder` (required): string. An encoded copy of the order details which will be submitted to the filler network along with the signed permit
    - `orderId` (required): string. A unique ID for the order. Used to track the order's status
    - `orderInfo` (required): object
      - `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `nonce` (required): string. A unique nonce for this order
      - `reactor` (required): string. The address of a contract which will be used to facilitate the swap
      - `swapper` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
      - `deadline` (required): number. The unix timestamp at which the order will be reverted if not filled
      - `additionalValidationContract`: string. Unused and deprecated
      - `additionalValidationData`: string. Unused and deprecated
      - `auctionStartBlock` (required): string
      - `baselinePriorityFeeWei` (required): string
      - `input` (required): object
        - `amount` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
        - `token` (required): string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
        - `mpsPerPriorityFeeWei` (required): string
      - `outputs` (required): array
        - items:
          - `amount` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
          - `token` (required): string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
          - `recipient` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
          - `mpsPerPriorityFeeWei` (required): string. The scaling factor of the priority fee based on the output token amount
      - `cosigner` (required): string. The address of a cosigner who will run the auction and ensure the best executable price within the given parameters. Currently the cosigner is always Uniswap Labs
    - `input`: object
      - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - `token`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `maximumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `output`: object
      - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
      - `minimumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `portionBips`: number. The portion of the swap that will be taken as a fee stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 87.5 for 0.875%). The fee will be taken from the output token
    - `portionAmount`: string. The portion of the swap that will be taken as a fee in the base units of the token. The fee will be taken from the output token
    - `portionRecipient`: string. The wallet address which will receive the fee
    - `quoteId`: string. A unique ID for the quote
    - `slippageTolerance`: number. The slippage tolerance as a percentage up to a maximum of two decimal places. For Uniswap Protocols (v2, v3, v4), the slippage tolerance is the maximum amount the price can change between the time the transaction is submitted and the time it is executed. The slippage tolerance is a percentage of the total value of the swap.  When submitting a quote, note that slippage tolerance works differently in UniswapX swaps where it does not set a limit on the Spread in an order. See [here](https://api-docs.uniswap.org/guides/faqs#why-do-uniswapx-quotes-have-more-slippage-than-the-tolerance-i-set) for more information.  Note that if the trade type is `EXACT_INPUT`, then the slippage is in terms of the output token. If the trade type is `EXACT_OUTPUT`, then the slippage is in terms of the input token.  When submitting a request, `slippageTolerance` may not be set when `autoSlippage` is defined. One of `slippageTolerance` or `autoSlippage` must be defined
    - `deadlineBufferSecs`: number
    - `classicGasUseEstimateUSD`: string. The gas fee you would pay if you opted for a CLASSIC swap over a Uniswap X order in terms of USD
    - `expectedAmountIn`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `expectedAmountOut`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `aggregatedOutputs`: array
      - items:
        - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
        - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
        - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
        - `bps`: number. The portion of the swap stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 12.5)
        - `minAmount`: string. The minimum portion of the swap, stated in the base unit of the token, which will be output to the recipient
        - `fee`: string = `INTEGRATOR`. Set to INTEGRATOR when this output is an integrator fee (as specified by the `integratorFees` array in the /quote request); omitted for the core output of the swap
- `permitData`: object. the permit2 message object for the customer to sign to permit spending by the permit2 contract
  - `domain`: object
  - `values`: object
  - `types`: object
- `deadline`: number. The unix timestamp at which the order will be reverted if not filled
- `urgency`: object. The urgency impacts the estimated gas price of the transaction. The higher the urgency, the higher the gas price, and the faster the transaction is likely to be selected from the mempool. Send the bare string form (e.g. `"normal"`) for the common case, or the object form `{ level, overrides }` to supply caller caps for `maxPriorityFeePerGas`, `maxFeePerGas`, and `gasLimit`
  - oneOf: `` string
    - enum: `normal`, `fast`, `urgent`
  - oneOf: `` object
    - `level` (required): string = `normal`, `fast`, `urgent`
    - `overrides`: object. Caller-supplied caps applied on top of the gas service's computed quote. All fields are absolute wei (decimal string). `maxPriorityFeePerGas` and `maxFeePerGas` are treated as caps - they lower the quote, never raise it. `gasLimit`, if set, replaces the limit calculation entirely
      - `maxPriorityFeePerGas`: string. Maximum priority fee in wei (decimal string)
      - `maxFeePerGas`: string. Maximum total fee per gas in wei (decimal string)
      - `gasLimit`: string. Gas limit cap (in gas units, decimal string)
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
- `approvalOnly`: boolean. Return only the ERC-20 approval call(s) for the quote's input token — no swap transaction. Required (and only supported) for UniswapX quotes, whose swap is an off-chain signed order

## CreateSwap7702Request



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
- `permitData`: object. the permit2 message object for the customer to sign to permit spending by the permit2 contract
  - `domain`: object
  - `values`: object
  - `types`: object
- `smartContractDelegationAddress`: string
- `includeGasInfo`: boolean
- `deadline`: number. The unix timestamp at which the order will be reverted if not filled
- `urgency`: object. The urgency impacts the estimated gas price of the transaction. The higher the urgency, the higher the gas price, and the faster the transaction is likely to be selected from the mempool. Send the bare string form (e.g. `"normal"`) for the common case, or the object form `{ level, overrides }` to supply caller caps for `maxPriorityFeePerGas`, `maxFeePerGas`, and `gasLimit`
  - oneOf: `` string
    - enum: `normal`, `fast`, `urgent`
  - oneOf: `` object
    - `level` (required): string = `normal`, `fast`, `urgent`
    - `overrides`: object. Caller-supplied caps applied on top of the gas service's computed quote. All fields are absolute wei (decimal string). `maxPriorityFeePerGas` and `maxFeePerGas` are treated as caps - they lower the quote, never raise it. `gasLimit`, if set, replaces the limit calculation entirely
      - `maxPriorityFeePerGas`: string. Maximum priority fee in wei (decimal string)
      - `maxFeePerGas`: string. Maximum total fee per gas in wei (decimal string)
      - `gasLimit`: string. Gas limit cap (in gas units, decimal string)
- `simulateTransaction`: boolean

## Swap4337Request

Request body for building an ERC-4337 UserOperation that executes a swap.

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

## Swap4337Response

Response containing the partially-populated ERC-4337 UserOperation. Paymaster fields and `signature` must be filled in by the wallet before submission.

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

## CheckApproval4337Request

Request body for building an ERC-4337 UserOperation that performs a token approval, optionally gas-sponsored.

- `sender` (required): string
- `token` (required): string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `amount` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `urgency`: object. The urgency impacts the estimated gas price of the transaction. The higher the urgency, the higher the gas price, and the faster the transaction is likely to be selected from the mempool. Send the bare string form (e.g. `"normal"`) for the common case, or the object form `{ level, overrides }` to supply caller caps for `maxPriorityFeePerGas`, `maxFeePerGas`, and `gasLimit`
  - oneOf: `` string
    - enum: `normal`, `fast`, `urgent`
  - oneOf: `` object
    - `level` (required): string = `normal`, `fast`, `urgent`
    - `overrides`: object. Caller-supplied caps applied on top of the gas service's computed quote. All fields are absolute wei (decimal string). `maxPriorityFeePerGas` and `maxFeePerGas` are treated as caps - they lower the quote, never raise it. `gasLimit`, if set, replaces the limit calculation entirely
      - `maxPriorityFeePerGas`: string. Maximum priority fee in wei (decimal string)
      - `maxFeePerGas`: string. Maximum total fee per gas in wei (decimal string)
      - `gasLimit`: string. Gas limit cap (in gas units, decimal string)
- `tokenOut`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `tokenOutChainId`: number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `walletExecutionContext`: object. Wallet execution context based on CAIP-25 Standard. Provides information about wallet capabilities and scopes
  - `scopes` (required): object. Map of scope identifiers to their scope data
  - `properties`: object. Properties describing the wallet
    - `walletInfo`: object. Information about the wallet
      - `uuid`: string. Unique identifier for the wallet
      - `name`: string. Name of the wallet
      - `rdns`: string. Reverse domain name identifier for the wallet
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

## CheckApproval4337Response

Response containing the approval ERC-4337 UserOperation. `userOperation` is omitted when no approval is required.

- `requestId` (required): string. A unique ID for the request
- `userOperation`: object. ERC-4337 v0.8 UserOperation
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
- `gasSponsored` (required): boolean. Whether gas for this approval will be sponsored
- `gasSponsorshipRejectionReason`: string. Reason gas sponsorship was not granted. Present only when `gasSponsored` is `false`
- `paymasterServiceContext`: object. EIP-7677 paymasterService.context bundle. The wallet forwards this verbatim to the paymaster RPC (or — for ERC-4337 — to /wallet/encode_4337). `sponsorship` is opaque AES-256-GCM ciphertext whose integrity is enforced cryptographically on the uniRPC side
  - `sponsorship` (required): string

## UniversalRouterVersion



- enum: `2.0`, `2.1.1`, `2.2.0`

## Address




## ClassicGasUseEstimateUSD

The gas fee you would pay if you opted for a CLASSIC swap over a Uniswap X order in terms of USD.


## CreateSwapResponse



- `requestId` (required): string. A unique ID for the request
- `swap` (required): object
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

## CreateSwap5792Response



- `requestId` (required): string. A unique ID for the request
- `from` (required): string
- `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `calls` (required): array
  - items:
    - `to` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
    - `data` (required): string. The calldata for the transaction
    - `value` (required): string. The quantity of ETH tokens approved for spending by the transaction, denominated in wei. Note that by default Uniswap Labs sets this to the maximum approvable spend
    - `gasLimit`: string. The maximum units of gas that will be consumed by this transaction
    - `maxFeePerGas`: string. The sum of the base fee and priority fee. Subtracting `maxPriorityFeePerGas` from this value will yield the base fee to be paid for this transaction
    - `maxPriorityFeePerGas`: string. The maximum tip to the block builder. Adjusted based upon the urgency specified in the request
    - `gasPrice`: string. The cost per unit of gas
- `gasFee`: string. The total estimated gas cost of this transaction (eg. `gasLimit` multiplied by `maxFeePerGas`) in the base unit of the chain
- `paymasterService`: object. EIP-7677 paymasterService capability. Present only when this swap is sponsored. The wallet forwards `context` as-is to the URL; the trading service does not expect the wallet to inspect or modify it
  - `url` (required): string. uniRPC paymaster endpoint, e.g. https://unirpc.uniswap.org/paymaster/v1/<chainId>
  - `context` (required): object. EIP-7677 paymasterService.context bundle. The wallet forwards this verbatim to the paymaster RPC (or — for ERC-4337 — to /wallet/encode_4337). `sponsorship` is opaque AES-256-GCM ciphertext whose integrity is enforced cryptographically on the uniRPC side
    - `sponsorship` (required): string

## PaymasterServiceCapability

EIP-7677 paymasterService capability. Present only when this swap is sponsored. The wallet forwards `context` as-is to the URL; the trading service does not expect the wallet to inspect or modify it.

- `url` (required): string. uniRPC paymaster endpoint, e.g. https://unirpc.uniswap.org/paymaster/v1/<chainId>
- `context` (required): object. EIP-7677 paymasterService.context bundle. The wallet forwards this verbatim to the paymaster RPC (or — for ERC-4337 — to /wallet/encode_4337). `sponsorship` is opaque AES-256-GCM ciphertext whose integrity is enforced cryptographically on the uniRPC side
  - `sponsorship` (required): string

## PaymasterServiceContext

EIP-7677 paymasterService.context bundle. The wallet forwards this verbatim to the paymaster RPC (or — for ERC-4337 — to /wallet/encode_4337). `sponsorship` is opaque AES-256-GCM ciphertext whose integrity is enforced cryptographically on the uniRPC side.

- `sponsorship` (required): string

## CreateSwap7702Response



- `requestId` (required): string. A unique ID for the request
- `swap` (required): object
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

## QuoteResponse



- `requestId` (required): string. A unique ID for the request
- `quote` (required): object
  - oneOf: `` object
    - `encodedOrder` (required): string. An encoded copy of the order details which will be submitted to the filler network along with the signed permit
    - `orderId` (required): string. A unique ID for the order. Used to track the order's status
    - `orderInfo` (required): object
      - `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `nonce` (required): string. A unique nonce for this order
      - `reactor` (required): string. The address of a contract which will be used to facilitate the swap
      - `swapper` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
      - `deadline` (required): number. The unix timestamp at which the order will be reverted if not filled
      - `additionalValidationContract`: string. Unused and deprecated
      - `additionalValidationData`: string. Unused and deprecated
      - `decayStartTime`: number. The unix timestamp at which the order will be eligible to be filled by alternate fillers at a lower price. Noted that the fill amount will not be lower than the output `endAmount`
      - `decayEndTime`: number. The unix timestamp at which the order will no longer be eligible to be filled by alternate fillers
      - `exclusiveFiller` (required): string. The address of the filler who has priority to fill the order by the `decayStartTime`
      - `exclusivityOverrideBps` (required): string. The portion of the order which is eligible to be filled by the `exclusiveFiller`, specified in basis points
      - `input` (required): object
        - `startAmount` (required): string. The intended execution quantity of tokens resulting from this swap
        - `endAmount` (required): string. The worst case quantity of tokens resulting from this swap
        - `token`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `outputs` (required): array
        - items:
          - `startAmount` (required): string. The intended execution quantity of tokens resulting from this swap
          - `endAmount` (required): string. The worst case quantity of tokens resulting from this swap
          - `token` (required): string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
          - `recipient` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
    - `input`: object
      - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - `token`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `maximumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `output`: object
      - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
      - `minimumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `portionBips`: number. The portion of the swap that will be taken as a fee stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 87.5 for 0.875%). The fee will be taken from the output token
    - `portionAmount`: string. The portion of the swap that will be taken as a fee in the base units of the token. The fee will be taken from the output token
    - `portionRecipient`: string. The wallet address which will receive the fee
    - `quoteId`: string. A unique ID for the quote
    - `slippageTolerance`: number. The slippage tolerance as a percentage up to a maximum of two decimal places. For Uniswap Protocols (v2, v3, v4), the slippage tolerance is the maximum amount the price can change between the time the transaction is submitted and the time it is executed. The slippage tolerance is a percentage of the total value of the swap.  When submitting a quote, note that slippage tolerance works differently in UniswapX swaps where it does not set a limit on the Spread in an order. See [here](https://api-docs.uniswap.org/guides/faqs#why-do-uniswapx-quotes-have-more-slippage-than-the-tolerance-i-set) for more information.  Note that if the trade type is `EXACT_INPUT`, then the slippage is in terms of the output token. If the trade type is `EXACT_OUTPUT`, then the slippage is in terms of the input token.  When submitting a request, `slippageTolerance` may not be set when `autoSlippage` is defined. One of `slippageTolerance` or `autoSlippage` must be defined
    - `classicGasUseEstimateUSD`: string. The gas fee you would pay if you opted for a CLASSIC swap over a Uniswap X order in terms of USD
    - `aggregatedOutputs`: array
      - items:
        - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
        - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
        - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
        - `bps`: number. The portion of the swap stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 12.5)
        - `minAmount`: string. The minimum portion of the swap, stated in the base unit of the token, which will be output to the recipient
        - `fee`: string = `INTEGRATOR`. Set to INTEGRATOR when this output is an integrator fee (as specified by the `integratorFees` array in the /quote request); omitted for the core output of the swap
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
  - oneOf: `UniswapX V2 Quote` object
    - `priceDifference`: number. The expected value lost versus frictionless execution at current prices, as a percent between -100 and 100. Negative values indicate price improvement. For UniswapX orders this prefers USD parity, computed as 1 - (outputUSD + classicGasUseEstimateUSD) / inputUSD over the auction start amounts (the gas estimate is added back because the filler's gas is baked into the output), and falls back to comparing the execution price against the mid price implied by the classic quote (its execution price divided by 1 - priceImpact). Absent when neither source is available
    - `encodedOrder` (required): string. An encoded copy of the order details which will be submitted to the filler network along with the signed permit
    - `orderId` (required): string. A unique ID for the order. Used to track the order's status
    - `orderInfo` (required): object
      - `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `nonce` (required): string. A unique nonce for this order
      - `reactor` (required): string. The address of a contract which will be used to facilitate the swap
      - `swapper` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
      - `deadline` (required): number. The unix timestamp at which the order will be reverted if not filled
      - `additionalValidationContract`: string. Unused and deprecated
      - `additionalValidationData`: string. Unused and deprecated
      - `input` (required): object
        - `startAmount` (required): string. The intended execution quantity of tokens resulting from this swap
        - `endAmount` (required): string. The worst case quantity of tokens resulting from this swap
        - `token`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `outputs` (required): array
        - items:
          - `startAmount` (required): string. The intended execution quantity of tokens resulting from this swap
          - `endAmount` (required): string. The worst case quantity of tokens resulting from this swap
          - `token` (required): string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
          - `recipient` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
      - `cosigner`: string. The address of a cosigner who will run the auction and ensure the best executable price within the given parameters. Currently the cosigner is always Uniswap Labs
    - `input`: object
      - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - `token`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `maximumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `output`: object
      - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
      - `minimumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `portionBips`: number. The portion of the swap that will be taken as a fee stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 87.5 for 0.875%). The fee will be taken from the output token
    - `portionAmount`: string. The portion of the swap that will be taken as a fee in the base units of the token. The fee will be taken from the output token
    - `portionRecipient`: string. The wallet address which will receive the fee
    - `quoteId`: string. A unique ID for the quote
    - `slippageTolerance`: number. The slippage tolerance as a percentage up to a maximum of two decimal places. For Uniswap Protocols (v2, v3, v4), the slippage tolerance is the maximum amount the price can change between the time the transaction is submitted and the time it is executed. The slippage tolerance is a percentage of the total value of the swap.  When submitting a quote, note that slippage tolerance works differently in UniswapX swaps where it does not set a limit on the Spread in an order. See [here](https://api-docs.uniswap.org/guides/faqs#why-do-uniswapx-quotes-have-more-slippage-than-the-tolerance-i-set) for more information.  Note that if the trade type is `EXACT_INPUT`, then the slippage is in terms of the output token. If the trade type is `EXACT_OUTPUT`, then the slippage is in terms of the input token.  When submitting a request, `slippageTolerance` may not be set when `autoSlippage` is defined. One of `slippageTolerance` or `autoSlippage` must be defined
    - `deadlineBufferSecs`: number
    - `classicGasUseEstimateUSD`: string. The gas fee you would pay if you opted for a CLASSIC swap over a Uniswap X order in terms of USD
    - `aggregatedOutputs`: array
      - items:
        - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
        - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
        - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
        - `bps`: number. The portion of the swap stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 12.5)
        - `minAmount`: string. The minimum portion of the swap, stated in the base unit of the token, which will be output to the recipient
        - `fee`: string = `INTEGRATOR`. Set to INTEGRATOR when this output is an integrator fee (as specified by the `integratorFees` array in the /quote request); omitted for the core output of the swap
  - oneOf: `UniswapX V3 Quote` object
    - `priceDifference`: number. The expected value lost versus frictionless execution at current prices, as a percent between -100 and 100. Negative values indicate price improvement. For UniswapX orders this prefers USD parity, computed as 1 - (outputUSD + classicGasUseEstimateUSD) / inputUSD over the auction start amounts (the gas estimate is added back because the filler's gas is baked into the output), and falls back to comparing the execution price against the mid price implied by the classic quote (its execution price divided by 1 - priceImpact). Absent when neither source is available
    - `encodedOrder` (required): string. An encoded copy of the order details which will be submitted to the filler network along with the signed permit
    - `orderId` (required): string. A unique ID for the order. Used to track the order's status
    - `orderInfo` (required): object
      - `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `nonce` (required): string. A unique nonce for this order
      - `reactor` (required): string. The address of a contract which will be used to facilitate the swap
      - `swapper` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
      - `deadline` (required): number. The unix timestamp at which the order will be reverted if not filled
      - `additionalValidationContract`: string. Unused and deprecated
      - `additionalValidationData`: string. Unused and deprecated
      - `input` (required): object
        - `startAmount` (required): string. The intended execution quantity of tokens resulting from this swap
        - `maxAmount` (required): string
        - `adjustmentPerGweiBaseFee` (required): string
        - `curve` (required): object
        - `token` (required): string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `outputs` (required): array
        - items:
          - `startAmount` (required): string. The intended execution quantity of tokens resulting from this swap
          - `minAmount`: string. The minimum portion of the swap, stated in the base unit of the token, which will be output to the recipient
          - `recipient` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
          - `adjustmentPerGweiBaseFee` (required): string
          - `curve` (required): object
          - `token` (required): string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `cosigner`: string. The address of a cosigner who will run the auction and ensure the best executable price within the given parameters. Currently the cosigner is always Uniswap Labs
      - `startingBaseFee`: string
    - `input`: object
      - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - `token`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `maximumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `output`: object
      - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
      - `minimumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `portionBips`: number. The portion of the swap that will be taken as a fee stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 87.5 for 0.875%). The fee will be taken from the output token
    - `portionAmount`: string. The portion of the swap that will be taken as a fee in the base units of the token. The fee will be taken from the output token
    - `portionRecipient`: string. The wallet address which will receive the fee
    - `quoteId`: string. A unique ID for the quote
    - `slippageTolerance`: number. The slippage tolerance as a percentage up to a maximum of two decimal places. For Uniswap Protocols (v2, v3, v4), the slippage tolerance is the maximum amount the price can change between the time the transaction is submitted and the time it is executed. The slippage tolerance is a percentage of the total value of the swap.  When submitting a quote, note that slippage tolerance works differently in UniswapX swaps where it does not set a limit on the Spread in an order. See [here](https://api-docs.uniswap.org/guides/faqs#why-do-uniswapx-quotes-have-more-slippage-than-the-tolerance-i-set) for more information.  Note that if the trade type is `EXACT_INPUT`, then the slippage is in terms of the output token. If the trade type is `EXACT_OUTPUT`, then the slippage is in terms of the input token.  When submitting a request, `slippageTolerance` may not be set when `autoSlippage` is defined. One of `slippageTolerance` or `autoSlippage` must be defined
    - `deadlineBufferSecs`: number
    - `classicGasUseEstimateUSD`: string. The gas fee you would pay if you opted for a CLASSIC swap over a Uniswap X order in terms of USD
    - `expectedAmountIn`: string
    - `expectedAmountOut`: string
    - `aggregatedOutputs`: array
      - items:
        - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
        - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
        - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
        - `bps`: number. The portion of the swap stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 12.5)
        - `minAmount`: string. The minimum portion of the swap, stated in the base unit of the token, which will be output to the recipient
        - `fee`: string = `INTEGRATOR`. Set to INTEGRATOR when this output is an integrator fee (as specified by the `integratorFees` array in the /quote request); omitted for the core output of the swap
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
  - oneOf: `UniswapX Priority Quote` object
    - `priceDifference`: number. The expected value lost versus frictionless execution at current prices, as a percent between -100 and 100. Negative values indicate price improvement. For UniswapX orders this prefers USD parity, computed as 1 - (outputUSD + classicGasUseEstimateUSD) / inputUSD over the auction start amounts (the gas estimate is added back because the filler's gas is baked into the output), and falls back to comparing the execution price against the mid price implied by the classic quote (its execution price divided by 1 - priceImpact). Absent when neither source is available
    - `encodedOrder` (required): string. An encoded copy of the order details which will be submitted to the filler network along with the signed permit
    - `orderId` (required): string. A unique ID for the order. Used to track the order's status
    - `orderInfo` (required): object
      - `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `nonce` (required): string. A unique nonce for this order
      - `reactor` (required): string. The address of a contract which will be used to facilitate the swap
      - `swapper` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
      - `deadline` (required): number. The unix timestamp at which the order will be reverted if not filled
      - `additionalValidationContract`: string. Unused and deprecated
      - `additionalValidationData`: string. Unused and deprecated
      - `auctionStartBlock` (required): string
      - `baselinePriorityFeeWei` (required): string
      - `input` (required): object
        - `amount` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
        - `token` (required): string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
        - `mpsPerPriorityFeeWei` (required): string
      - `outputs` (required): array
        - items:
          - `amount` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
          - `token` (required): string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
          - `recipient` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
          - `mpsPerPriorityFeeWei` (required): string. The scaling factor of the priority fee based on the output token amount
      - `cosigner` (required): string. The address of a cosigner who will run the auction and ensure the best executable price within the given parameters. Currently the cosigner is always Uniswap Labs
    - `input`: object
      - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - `token`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `maximumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `output`: object
      - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
      - `minimumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `portionBips`: number. The portion of the swap that will be taken as a fee stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 87.5 for 0.875%). The fee will be taken from the output token
    - `portionAmount`: string. The portion of the swap that will be taken as a fee in the base units of the token. The fee will be taken from the output token
    - `portionRecipient`: string. The wallet address which will receive the fee
    - `quoteId`: string. A unique ID for the quote
    - `slippageTolerance`: number. The slippage tolerance as a percentage up to a maximum of two decimal places. For Uniswap Protocols (v2, v3, v4), the slippage tolerance is the maximum amount the price can change between the time the transaction is submitted and the time it is executed. The slippage tolerance is a percentage of the total value of the swap.  When submitting a quote, note that slippage tolerance works differently in UniswapX swaps where it does not set a limit on the Spread in an order. See [here](https://api-docs.uniswap.org/guides/faqs#why-do-uniswapx-quotes-have-more-slippage-than-the-tolerance-i-set) for more information.  Note that if the trade type is `EXACT_INPUT`, then the slippage is in terms of the output token. If the trade type is `EXACT_OUTPUT`, then the slippage is in terms of the input token.  When submitting a request, `slippageTolerance` may not be set when `autoSlippage` is defined. One of `slippageTolerance` or `autoSlippage` must be defined
    - `deadlineBufferSecs`: number
    - `classicGasUseEstimateUSD`: string. The gas fee you would pay if you opted for a CLASSIC swap over a Uniswap X order in terms of USD
    - `expectedAmountIn`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `expectedAmountOut`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `aggregatedOutputs`: array
      - items:
        - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
        - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
        - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
        - `bps`: number. The portion of the swap stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 12.5)
        - `minAmount`: string. The minimum portion of the swap, stated in the base unit of the token, which will be output to the recipient
        - `fee`: string = `INTEGRATOR`. Set to INTEGRATOR when this output is an integrator fee (as specified by the `integratorFees` array in the /quote request); omitted for the core output of the swap
  - oneOf: `Chained Quote` object
    - `priceDifference`: number. The expected value lost versus frictionless execution at current prices, as a percent between -100 and 100. Negative values indicate price improvement. For chained trades this compounds the per-step values multiplicatively as 1 - product of (1 - stepValue/100) over the value-moving steps. Absent if any of those steps is missing its value
    - `swapper` (required): string. The wallet address which will be used to send the token
    - `input` (required): object
      - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - `token`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `maximumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `output` (required): object
      - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
      - `minimumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `tokenInChainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `tokenOutChainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `tradeType` (required): string = `EXACT_INPUT`, `EXACT_OUTPUT`. The handling of the `amount` field. `EXACT_INPUT` means the requester will send the specified `amount` of input tokens and get a quote with a variable quantity of output tokens. `EXACT_OUTPUT` means the requester will receive the specified `amount` of output tokens and get a quote with a variable quantity of input tokens
    - `quoteId` (required): string. A unique ID for the quote
    - `gasEstimates`: array. Gas estimates for each step in the chained flow
      - items:
    - `timeEstimateMs`: number. Estimated time in milliseconds to complete the entire chained flow
    - `gasUseEstimate`: string. The maximum units of gas that will be consumed by this transaction
    - `gasFeeUSD`: string. The total estimated gas cost of this transaction (eg. `gasLimit` multiplied by `maxFeePerGas`) denominated in USDC
    - `gasFeeQuote`: string. The total estimated gas cost of this transaction (eg. gasLimit multiplied by maxFeePerGas) in the quoted currency (e.g. output token) in the base units of the quoted currency
    - `gasPrice`: string. The cost per unit of gas
    - `maxFeePerGas`: string. The sum of the base fee and priority fee. Subtracting `maxPriorityFeePerGas` from this value will yield the base fee to be paid for this transaction
    - `maxPriorityFeePerGas`: string. The maximum tip to the block builder. Adjusted based upon the urgency specified in the request
    - `gasFee`: string. The total estimated gas cost of this transaction (eg. `gasLimit` multiplied by `maxFeePerGas`) in the base unit of the chain
    - `protocols`: array. The protocols to use for the swap/order. If the `protocols` field is defined, then you can only set the `routingPreference` to `BEST_PRICE`. Note that the value `UNISWAPX` is deprecated and will be removed in a future release
      - items:
        - enum: `V2`, `V3`, `V4`, `UNISWAPX`, `UNISWAPX_V2`, `UNISWAPX_V3`, `UNISWAPX_LATEST`
    - `hooksOptions`: string = `V4_HOOKS_INCLUSIVE`, `V4_HOOKS_ONLY`, `V4_NO_HOOKS`. The hook options to use for V4 pool quotes. `V4_HOOKS_INCLUSIVE` will get quotes for V4 pools with or without hooks. `V4_HOOKS_ONLY` will only get quotes for V4 pools with hooks. `V4_NO_HOOKS` will only get quotes for V4 pools without hooks. Defaults to `V4_HOOKS_INCLUSIVE` if `V4` is included in `protocols` and `hookOptions` is not set. This field is ignored if `V4` is not passed in `protocols`
    - `gasStrategies` (required): array. Gas strategies for the chained flow
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
    - `steps`: array. Truncated plan steps for the chained transaction flow
      - items:
        - `priceDifference`: number. The expected value lost versus frictionless execution at current prices, as a percent between -100 and 100. Negative values indicate price improvement. The value for this step alone, computed according to the step's order type; the chained quote's top-level value compounds these
        - `stepType` (required): string = `DUTCH_LIMIT`, `CLASSIC`, `DUTCH_V2`, `LIMIT_ORDER`, `WRAP`, `UNWRAP`, `BRIDGE`, `PRIORITY`, `DUTCH_V3`, `QUICKROUTE`, `CHAINED`, `VAULT_DEPOSIT`, `VAULT_WITHDRAW`, `APPROVAL_TXN`, `APPROVAL_PERMIT`, `RESET_APPROVAL_TXN`. The type of step in a plan, including swap types and approval types
        - `tokenIn`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
        - `tokenInChainId`: number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
        - `tokenOut`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
        - `tokenOutChainId`: number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
        - `slippage`: number. The slippage tolerance as a percentage up to a maximum of two decimal places. For Uniswap Protocols (v2, v3, v4), the slippage tolerance is the maximum amount the price can change between the time the transaction is submitted and the time it is executed. The slippage tolerance is a percentage of the total value of the swap.  When submitting a quote, note that slippage tolerance works differently in UniswapX swaps where it does not set a limit on the Spread in an order. See [here](https://api-docs.uniswap.org/guides/faqs#why-do-uniswapx-quotes-have-more-slippage-than-the-tolerance-i-set) for more information.  Note that if the trade type is `EXACT_INPUT`, then the slippage is in terms of the output token. If the trade type is `EXACT_OUTPUT`, then the slippage is in terms of the input token.  When submitting a request, `slippageTolerance` may not be set when `autoSlippage` is defined. One of `slippageTolerance` or `autoSlippage` must be defined
    - `slippageTolerance`: number. The slippage tolerance as a percentage up to a maximum of two decimal places. For Uniswap Protocols (v2, v3, v4), the slippage tolerance is the maximum amount the price can change between the time the transaction is submitted and the time it is executed. The slippage tolerance is a percentage of the total value of the swap.  When submitting a quote, note that slippage tolerance works differently in UniswapX swaps where it does not set a limit on the Spread in an order. See [here](https://api-docs.uniswap.org/guides/faqs#why-do-uniswapx-quotes-have-more-slippage-than-the-tolerance-i-set) for more information.  Note that if the trade type is `EXACT_INPUT`, then the slippage is in terms of the output token. If the trade type is `EXACT_OUTPUT`, then the slippage is in terms of the input token.  When submitting a request, `slippageTolerance` may not be set when `autoSlippage` is defined. One of `slippageTolerance` or `autoSlippage` must be defined
    - `autoSlippage`: string = `DEFAULT`. The auto slippage strategy to employ. For Uniswap Protocols (v2, v3, v4) the auto slippage will be automatically calculated when this field is set to `DEFAULT`. Auto slippage cannot be calculated for UniswapX swaps.  Note that if the trade type is `EXACT_INPUT`, then the slippage is in terms of the output token. If the trade type is `EXACT_OUTPUT`, then the slippage is in terms of the input token.  When submitting a request, `autoSlippage` may not be set when `slippageTolerance` is defined. One of `slippageTolerance` or `autoSlippage` must be defined
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
          - `estimatedSharesOut` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
        - oneOf: `` object
          - `type` (required): string = `EXACT_ASSETS_WITHDRAW`
          - `requestedAssetsOut` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
          - `estimatedSharesIn` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
        - oneOf: `` object
          - `type` (required): string = `MAX_SHARES_WITHDRAW`
          - `maxRedeemableSharesIn` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
          - `previewAssetsOut` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `earnPreview`: object. Action-specific preview amounts computed while normalizing an Earn intent
      - oneOf: `` object
        - `type` (required): string = `DEPOSIT`
        - `depositAssets` (required): array. Vault underlying assets that will be deposited after any swap, bridge, wrap, or unwrap steps
        - `estimatedSharesOut` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - oneOf: `` object
        - `type` (required): string = `EXACT_ASSETS_WITHDRAW`
        - `requestedAssetsOut` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
        - `estimatedSharesIn` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - oneOf: `` object
        - `type` (required): string = `MAX_SHARES_WITHDRAW`
        - `maxRedeemableSharesIn` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
        - `previewAssetsOut` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `routing` (required): string = `CLASSIC`, `DUTCH_LIMIT`, `DUTCH_V2`, `DUTCH_V3`, `BRIDGE`, `LIMIT_ORDER`, `PRIORITY`, `WRAP`, `UNWRAP`, `CHAINED`. The routing for the proposed transaction
- `isTokenApprovalApplicable`: boolean. Whether an ERC-20 token approval is applicable to this swap's input. `true` when the routing pulls the input token via an allowance, so an approval may be required — verify (or orchestrate) it via `/check_approval`. `false` when no approval is ever needed for this route (e.g. native-currency input, wrap/unwrap, or a native-gas-token input paid as native value). Reflects the routing mechanism, not the swapper's current on-chain allowance. If absent, assume an approval is applicable
- `permitTransaction`: object
  - `to` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
  - `from` (required): string. The wallet address which will be used to send the token
  - `data` (required): string. The calldata for the transaction
  - `value` (required): string. The quantity of ETH tokens approved for spending by the transaction, denominated in wei. Note that by default Uniswap Labs sets this to the maximum approvable spend
  - `gasLimit`: string. The maximum units of gas that will be consumed by this transaction
  - `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `maxFeePerGas`: string. The sum of the base fee and priority fee. Subtracting `maxPriorityFeePerGas` from this value will yield the base fee to be paid for this transaction
  - `maxPriorityFeePerGas`: string. The maximum tip to the block builder. Adjusted based upon the urgency specified in the request
  - `gasPrice`: string. The cost per unit of gas
- `permitData` (required): object. the permit2 message object for the customer to sign to permit spending by the permit2 contract
  - `domain`: object
  - `values`: object
  - `types`: object
- `permitGasFee`: string. The total estimated gas cost of this transaction (eg. `gasLimit` multiplied by `maxFeePerGas`) in the base unit of the chain
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

## SponsorshipInfo

Gas sponsorship information for the quoted swap. When `sponsored` is `true`, gas fees for executing this swap will be covered by the sponsor described in `sponsorMetadata`, under the campaign described in `campaign`. When `sponsored` is `false`, `rejectionReason` describes why sponsorship was not granted.

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

## CampaignDetails

Display information about the sponsorship campaign covering gas fees for the swap.

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

## CampaignAllowance

A per-wallet cap and remaining utilization, e.g. "5 of 5 free swaps remaining".

- `unit`: string = `FREE_SWAPS`, `USD_CENT`. Unit the allowance is denominated in
- `total`: string. Total per-wallet allowance
- `remaining`: string. Allowance still available to this wallet

## SponsorMetadata

Display information about the sponsor covering gas fees for the swap.

- `name`: string. Display name of the sponsor
- `icon`: string. URL of the sponsor's icon

## Eip7702Authorization

Signed EIP-7702 authorization tuple.

- `address` (required): string. Contract address to delegate to
- `chainId` (required): string. Hex-encoded chain ID
- `nonce` (required): string. Hex-encoded nonce
- `r` (required): string. ECDSA r value
- `s` (required): string. ECDSA s value
- `yParity` (required): string. ECDSA y parity

## UserOperation

ERC-4337 v0.8 UserOperation.

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

## Encode4337Request

Request body for encoding an ERC-4337 UserOperation.

- `calls` (required): array. Batch of transactions to encode into the UserOperation
  - items:
    - `to` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
    - `data` (required): string. The calldata for the transaction
    - `value` (required): string. The quantity of ETH tokens approved for spending by the transaction, denominated in wei. Note that by default Uniswap Labs sets this to the maximum approvable spend
    - `gasLimit`: string. The maximum units of gas that will be consumed by this transaction
    - `maxFeePerGas`: string. The sum of the base fee and priority fee. Subtracting `maxPriorityFeePerGas` from this value will yield the base fee to be paid for this transaction
    - `maxPriorityFeePerGas`: string. The maximum tip to the block builder. Adjusted based upon the urgency specified in the request
    - `gasPrice`: string. The cost per unit of gas
- `sender` (required): string
- `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `paymasterUrl`: string. JSON-RPC URL of a paymaster service for gas sponsorship
- `paymasterServiceContext`: object. Opaque context forwarded to the paymaster (e.g. `{ "policyId": "..." }`)
- `eip7702Auth`: object. Signed EIP-7702 authorization tuple
  - `address` (required): string. Contract address to delegate to
  - `chainId` (required): string. Hex-encoded chain ID
  - `nonce` (required): string. Hex-encoded nonce
  - `r` (required): string. ECDSA r value
  - `s` (required): string. ECDSA s value
  - `yParity` (required): string. ECDSA y parity

## Encode4337Response

Response containing the encoded ERC-4337 UserOperation with gas and sponsorship details.

- `requestId` (required): string. Unique identifier for this request
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
- `sponsorMetadata`: object. Display information about the sponsor covering gas fees for the swap
  - `name`: string. Display name of the sponsor
  - `icon`: string. URL of the sponsor's icon
- `gasSponsored` (required): boolean. Whether gas for this operation is sponsored by a paymaster
- `gasSponsorshipRejectionReason`: string. Reason gas sponsorship was not granted. Present only when `gasSponsored` is `false`

## LimitOrderQuoteResponse



- `requestId` (required): string. A unique ID for the request
- `quote` (required): object
  - `encodedOrder` (required): string. An encoded copy of the order details which will be submitted to the filler network along with the signed permit
  - `orderId` (required): string. A unique ID for the order. Used to track the order's status
  - `orderInfo` (required): object
    - `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `nonce` (required): string. A unique nonce for this order
    - `reactor` (required): string. The address of a contract which will be used to facilitate the swap
    - `swapper` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
    - `deadline` (required): number. The unix timestamp at which the order will be reverted if not filled
    - `additionalValidationContract`: string. Unused and deprecated
    - `additionalValidationData`: string. Unused and deprecated
    - `decayStartTime`: number. The unix timestamp at which the order will be eligible to be filled by alternate fillers at a lower price. Noted that the fill amount will not be lower than the output `endAmount`
    - `decayEndTime`: number. The unix timestamp at which the order will no longer be eligible to be filled by alternate fillers
    - `exclusiveFiller` (required): string. The address of the filler who has priority to fill the order by the `decayStartTime`
    - `exclusivityOverrideBps` (required): string. The portion of the order which is eligible to be filled by the `exclusiveFiller`, specified in basis points
    - `input` (required): object
      - `startAmount` (required): string. The intended execution quantity of tokens resulting from this swap
      - `endAmount` (required): string. The worst case quantity of tokens resulting from this swap
      - `token`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `outputs` (required): array
      - items:
        - `startAmount` (required): string. The intended execution quantity of tokens resulting from this swap
        - `endAmount` (required): string. The worst case quantity of tokens resulting from this swap
        - `token` (required): string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
        - `recipient` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
  - `input`: object
    - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `token`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `maximumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
  - `output`: object
    - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
    - `minimumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
  - `portionBips`: number. The portion of the swap that will be taken as a fee stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 87.5 for 0.875%). The fee will be taken from the output token
  - `portionAmount`: string. The portion of the swap that will be taken as a fee in the base units of the token. The fee will be taken from the output token
  - `portionRecipient`: string. The wallet address which will receive the fee
  - `quoteId`: string. A unique ID for the quote
  - `slippageTolerance`: number. The slippage tolerance as a percentage up to a maximum of two decimal places. For Uniswap Protocols (v2, v3, v4), the slippage tolerance is the maximum amount the price can change between the time the transaction is submitted and the time it is executed. The slippage tolerance is a percentage of the total value of the swap.  When submitting a quote, note that slippage tolerance works differently in UniswapX swaps where it does not set a limit on the Spread in an order. See [here](https://api-docs.uniswap.org/guides/faqs#why-do-uniswapx-quotes-have-more-slippage-than-the-tolerance-i-set) for more information.  Note that if the trade type is `EXACT_INPUT`, then the slippage is in terms of the output token. If the trade type is `EXACT_OUTPUT`, then the slippage is in terms of the input token.  When submitting a request, `slippageTolerance` may not be set when `autoSlippage` is defined. One of `slippageTolerance` or `autoSlippage` must be defined
  - `classicGasUseEstimateUSD`: string. The gas fee you would pay if you opted for a CLASSIC swap over a Uniswap X order in terms of USD
  - `aggregatedOutputs`: array
    - items:
      - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
      - `bps`: number. The portion of the swap stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 12.5)
      - `minAmount`: string. The minimum portion of the swap, stated in the base unit of the token, which will be output to the recipient
      - `fee`: string = `INTEGRATOR`. Set to INTEGRATOR when this output is an integrator fee (as specified by the `integratorFees` array in the /quote request); omitted for the core output of the swap
- `routing` (required): string = `LIMIT_ORDER`
- `permitData` (required): object. the permit2 message object for the customer to sign to permit spending by the permit2 contract
  - `domain`: object
  - `values`: object
  - `types`: object

## QuoteRequest



- `type` (required): string = `EXACT_INPUT`, `EXACT_OUTPUT`. The handling of the `amount` field. `EXACT_INPUT` means the requester will send the specified `amount` of input tokens and get a quote with a variable quantity of output tokens. `EXACT_OUTPUT` means the requester will receive the specified `amount` of output tokens and get a quote with a variable quantity of input tokens
- `amount` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `tokenInChainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `tokenOutChainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `tokenIn` (required): string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `tokenOut` (required): string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `generatePermitAsTransaction`: boolean. Indicates whether you want to receive a permit2 transaction to sign and submit onchain, or a permit message to sign. When set to `true`, the quote response returns the Permit2 as a calldata which the user signs and broadcasts. When set to `false` (the default), the quote response returns the Permit2 as a message which the user signs but does not need to broadcast. When using a 7702-delegated wallet, set this field to `true`. Except for this scenario, it is recommended that this field is set to false. Note that a Permit2 calldata (e.g. `true`), will provide indefinite permission for Permit2 to spend a token, in contrast to a Permit2 message (e.g. `false`) which is only valid for 30 days. Further, a Permit2 calldata (e.g. `true`) requires the user to pay gas to submit the transaction, whereas the Permit2 message (e.g. `false` ) does not require the user to submit a transaction and requires no gas
- `swapper` (required): string. The wallet address which will be used to send the token
- `slippageTolerance`: number. The slippage tolerance as a percentage up to a maximum of two decimal places. For Uniswap Protocols (v2, v3, v4), the slippage tolerance is the maximum amount the price can change between the time the transaction is submitted and the time it is executed. The slippage tolerance is a percentage of the total value of the swap.  When submitting a quote, note that slippage tolerance works differently in UniswapX swaps where it does not set a limit on the Spread in an order. See [here](https://api-docs.uniswap.org/guides/faqs#why-do-uniswapx-quotes-have-more-slippage-than-the-tolerance-i-set) for more information.  Note that if the trade type is `EXACT_INPUT`, then the slippage is in terms of the output token. If the trade type is `EXACT_OUTPUT`, then the slippage is in terms of the input token.  When submitting a request, `slippageTolerance` may not be set when `autoSlippage` is defined. One of `slippageTolerance` or `autoSlippage` must be defined
- `autoSlippage`: string = `DEFAULT`. The auto slippage strategy to employ. For Uniswap Protocols (v2, v3, v4) the auto slippage will be automatically calculated when this field is set to `DEFAULT`. Auto slippage cannot be calculated for UniswapX swaps.  Note that if the trade type is `EXACT_INPUT`, then the slippage is in terms of the output token. If the trade type is `EXACT_OUTPUT`, then the slippage is in terms of the input token.  When submitting a request, `autoSlippage` may not be set when `slippageTolerance` is defined. One of `slippageTolerance` or `autoSlippage` must be defined
- `routingPreference`: string = `BEST_PRICE`, `FASTEST`. The `routingPreference` specifies the preferred strategy to determine the quote. If the `routingPreference` is `BEST_PRICE`, then the quote will propose a route through the specified whitelisted protocols (or all, if none are specified) that provides the best price. When the `routingPreference` is `FASTEST`, the quote will propose the first route which is found to complete the swap
- `protocols`: array. The protocols to use for the swap/order. If the `protocols` field is defined, then you can only set the `routingPreference` to `BEST_PRICE`. Note that the value `UNISWAPX` is deprecated and will be removed in a future release
  - items:
    - enum: `V2`, `V3`, `V4`, `UNISWAPX`, `UNISWAPX_V2`, `UNISWAPX_V3`, `UNISWAPX_LATEST`
- `hooksOptions`: string = `V4_HOOKS_INCLUSIVE`, `V4_HOOKS_ONLY`, `V4_NO_HOOKS`. The hook options to use for V4 pool quotes. `V4_HOOKS_INCLUSIVE` will get quotes for V4 pools with or without hooks. `V4_HOOKS_ONLY` will only get quotes for V4 pools with hooks. `V4_NO_HOOKS` will only get quotes for V4 pools without hooks. Defaults to `V4_HOOKS_INCLUSIVE` if `V4` is included in `protocols` and `hookOptions` is not set. This field is ignored if `V4` is not passed in `protocols`
- `spreadOptimization`: string = `EXECUTION`, `PRICE`. For UniswapX swaps, when set to `EXECUTION`, quotes optimize for looser spreads at higher fill rates. When set to `PRICE`, quotes optimize for tighter spreads at lower fill rates. This field is not applicable to Uniswap Protocols (v2, v3, v4), bridging, or wrapping/unwrapping and will be ignored if set
- `urgency`: object. The urgency impacts the estimated gas price of the transaction. The higher the urgency, the higher the gas price, and the faster the transaction is likely to be selected from the mempool. Send the bare string form (e.g. `"normal"`) for the common case, or the object form `{ level, overrides }` to supply caller caps for `maxPriorityFeePerGas`, `maxFeePerGas`, and `gasLimit`
  - oneOf: `` string
    - enum: `normal`, `fast`, `urgent`
  - oneOf: `` object
    - `level` (required): string = `normal`, `fast`, `urgent`
    - `overrides`: object. Caller-supplied caps applied on top of the gas service's computed quote. All fields are absolute wei (decimal string). `maxPriorityFeePerGas` and `maxFeePerGas` are treated as caps - they lower the quote, never raise it. `gasLimit`, if set, replaces the limit calculation entirely
      - `maxPriorityFeePerGas`: string. Maximum priority fee in wei (decimal string)
      - `maxFeePerGas`: string. Maximum total fee per gas in wei (decimal string)
      - `gasLimit`: string. Gas limit cap (in gas units, decimal string)
- `permitAmount`: string = `FULL`, `EXACT`. For Uniswap Protocols (v2, v3, v4) swaps, specify the input token spend allowance (e.g. quantity) to be set in the permit. `FULL` can be used to specify an unlimited token quantity, and may prevent the wallet from needing to sign another permit for the same token in the future. `EXACT` can be used to specify the exact input token quantity for this request. Defaults to `FULL`
- `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
- `integratorFees`: array. Optional integrator fee configuration. When provided, the specified fee is applied to the swap instead of the default partner fee service. Only one fee entry is currently supported
  - items:
    - `bips` (required): number. Fee amount in basis points (1 bip = 0.01%). Must be greater than 0 and at most 500
    - `recipient` (required): string. Ethereum address that receives the fee
- `walletExecutionContext`: object. Wallet execution context based on CAIP-25 Standard. Provides information about wallet capabilities and scopes
  - `scopes` (required): object. Map of scope identifiers to their scope data
  - `properties`: object. Properties describing the wallet
    - `walletInfo`: object. Information about the wallet
      - `uuid`: string. Unique identifier for the wallet
      - `name`: string. Name of the wallet
      - `rdns`: string. Reverse domain name identifier for the wallet
- `earnIntent`: object. Earn vault intent supplied on /quote and repeated on /plan. Earn currently supports the allowlisted Mainnet Morpho vaults
  - `action` (required): string = `deposit`, `withdraw`. The Earn vault action to quote or plan
  - `vault` (required): string
  - `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `withdrawMode`: string = `EXACT_ASSETS`, `MAX_SHARES`. The ERC-4626 withdraw mode. EXACT_ASSETS withdraws the requested asset amount; MAX_SHARES redeems the owner's currently redeemable shares

## LimitOrderQuoteRequest



- `swapper` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
- `limitPrice`: string
- `amount` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `orderDeadline`: number
- `type` (required): string = `EXACT_INPUT`, `EXACT_OUTPUT`. The handling of the `amount` field. `EXACT_INPUT` means the requester will send the specified `amount` of input tokens and get a quote with a variable quantity of output tokens. `EXACT_OUTPUT` means the requester will receive the specified `amount` of output tokens and get a quote with a variable quantity of input tokens
- `tokenIn` (required): string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `tokenOut` (required): string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `tokenInChainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `tokenOutChainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)

## GetOrdersResponse



- `requestId` (required): string. A unique ID for the request
- `orders` (required): array
  - items:
    - `type` (required): string = `DutchLimit`, `Dutch`, `Dutch_V2`, `Dutch_V3`, `Priority`
    - `encodedOrder` (required): string. An encoded copy of the order details which will be submitted to the filler network along with the signed permit
    - `signature` (required): string
    - `nonce` (required): string. A unique nonce for this order
    - `orderStatus` (required): string = `open`, `expired`, `error`, `cancelled`, `filled`, `unverified`, `insufficient-funds`. The status of the order. Note that all of these are final states with the exception of Open, meaning that no further state changes will occur.   Open - order is not yet filled by a filler.  Expired - order has expired without being filled and is no longer fillable.  Error - a catchall for other final states which are not otherwise specified, where the order will not be filled.  Cancelled - order is cancelled. Note that to cancel an order, a new order must be placed with the same nonce as the prior open order and it must be placed within the same block as the original order.  Filled - order is filled.  Insufficient-funds - the swapper (you) do not have enough funds for the order to be completed and the order is cancelled and will not be filled.  Unverified - order has not been verified yet
    - `orderId` (required): string. A unique ID for the order. Used to track the order's status
    - `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `quoteId`: string. A unique ID for the quote
    - `swapper`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
    - `txHash`: string. The unique hash of the transaction
    - `input`: object
      - `token` (required): string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `startAmount`: string. The intended execution quantity of tokens resulting from this swap
      - `endAmount`: string. The worst case quantity of tokens resulting from this swap
    - `outputs`: array
      - items:
        - `token` (required): string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
        - `startAmount`: string. The intended execution quantity of tokens resulting from this swap
        - `endAmount`: string. The worst case quantity of tokens resulting from this swap
        - `isFeeOutput`: boolean
        - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
    - `settledAmounts`: array
      - items:
        - `tokenOut`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
        - `amountOut`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
        - `tokenIn`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
        - `amountIn`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `cosignature`: string
    - `cosignerData`: object
      - `decayStartTime`: number. The unix timestamp at which the order will be eligible to be filled by alternate fillers at a lower price. Noted that the fill amount will not be lower than the output `endAmount`
      - `decayEndTime`: number. The unix timestamp at which the order will no longer be eligible to be filled by alternate fillers
      - `exclusiveFiller`: string. The address of the filler who has priority to fill the order by the `decayStartTime`
      - `inputOverride`: string
      - `outputOverrides`: array
        - items:
- `cursor`: string

## OrderResponse



- `requestId` (required): string. A unique ID for the request
- `orderId` (required): string. A unique ID for the order. Used to track the order's status
- `orderStatus` (required): string = `open`, `expired`, `error`, `cancelled`, `filled`, `unverified`, `insufficient-funds`. The status of the order. Note that all of these are final states with the exception of Open, meaning that no further state changes will occur.   Open - order is not yet filled by a filler.  Expired - order has expired without being filled and is no longer fillable.  Error - a catchall for other final states which are not otherwise specified, where the order will not be filled.  Cancelled - order is cancelled. Note that to cancel an order, a new order must be placed with the same nonce as the prior open order and it must be placed within the same block as the original order.  Filled - order is filled.  Insufficient-funds - the swapper (you) do not have enough funds for the order to be completed and the order is cancelled and will not be filled.  Unverified - order has not been verified yet

## OrderRequest



- `signature` (required): string. The signed permit
- `quote` (required): object
  - oneOf: `UniswapX V2 Quote` object
    - `priceDifference`: number. The expected value lost versus frictionless execution at current prices, as a percent between -100 and 100. Negative values indicate price improvement. For UniswapX orders this prefers USD parity, computed as 1 - (outputUSD + classicGasUseEstimateUSD) / inputUSD over the auction start amounts (the gas estimate is added back because the filler's gas is baked into the output), and falls back to comparing the execution price against the mid price implied by the classic quote (its execution price divided by 1 - priceImpact). Absent when neither source is available
    - `encodedOrder` (required): string. An encoded copy of the order details which will be submitted to the filler network along with the signed permit
    - `orderId` (required): string. A unique ID for the order. Used to track the order's status
    - `orderInfo` (required): object
      - `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `nonce` (required): string. A unique nonce for this order
      - `reactor` (required): string. The address of a contract which will be used to facilitate the swap
      - `swapper` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
      - `deadline` (required): number. The unix timestamp at which the order will be reverted if not filled
      - `additionalValidationContract`: string. Unused and deprecated
      - `additionalValidationData`: string. Unused and deprecated
      - `input` (required): object
        - `startAmount` (required): string. The intended execution quantity of tokens resulting from this swap
        - `endAmount` (required): string. The worst case quantity of tokens resulting from this swap
        - `token`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `outputs` (required): array
        - items:
          - `startAmount` (required): string. The intended execution quantity of tokens resulting from this swap
          - `endAmount` (required): string. The worst case quantity of tokens resulting from this swap
          - `token` (required): string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
          - `recipient` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
      - `cosigner`: string. The address of a cosigner who will run the auction and ensure the best executable price within the given parameters. Currently the cosigner is always Uniswap Labs
    - `input`: object
      - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - `token`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `maximumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `output`: object
      - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
      - `minimumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `portionBips`: number. The portion of the swap that will be taken as a fee stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 87.5 for 0.875%). The fee will be taken from the output token
    - `portionAmount`: string. The portion of the swap that will be taken as a fee in the base units of the token. The fee will be taken from the output token
    - `portionRecipient`: string. The wallet address which will receive the fee
    - `quoteId`: string. A unique ID for the quote
    - `slippageTolerance`: number. The slippage tolerance as a percentage up to a maximum of two decimal places. For Uniswap Protocols (v2, v3, v4), the slippage tolerance is the maximum amount the price can change between the time the transaction is submitted and the time it is executed. The slippage tolerance is a percentage of the total value of the swap.  When submitting a quote, note that slippage tolerance works differently in UniswapX swaps where it does not set a limit on the Spread in an order. See [here](https://api-docs.uniswap.org/guides/faqs#why-do-uniswapx-quotes-have-more-slippage-than-the-tolerance-i-set) for more information.  Note that if the trade type is `EXACT_INPUT`, then the slippage is in terms of the output token. If the trade type is `EXACT_OUTPUT`, then the slippage is in terms of the input token.  When submitting a request, `slippageTolerance` may not be set when `autoSlippage` is defined. One of `slippageTolerance` or `autoSlippage` must be defined
    - `deadlineBufferSecs`: number
    - `classicGasUseEstimateUSD`: string. The gas fee you would pay if you opted for a CLASSIC swap over a Uniswap X order in terms of USD
    - `aggregatedOutputs`: array
      - items:
        - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
        - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
        - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
        - `bps`: number. The portion of the swap stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 12.5)
        - `minAmount`: string. The minimum portion of the swap, stated in the base unit of the token, which will be output to the recipient
        - `fee`: string = `INTEGRATOR`. Set to INTEGRATOR when this output is an integrator fee (as specified by the `integratorFees` array in the /quote request); omitted for the core output of the swap
  - oneOf: `UniswapX V3 Quote` object
    - `priceDifference`: number. The expected value lost versus frictionless execution at current prices, as a percent between -100 and 100. Negative values indicate price improvement. For UniswapX orders this prefers USD parity, computed as 1 - (outputUSD + classicGasUseEstimateUSD) / inputUSD over the auction start amounts (the gas estimate is added back because the filler's gas is baked into the output), and falls back to comparing the execution price against the mid price implied by the classic quote (its execution price divided by 1 - priceImpact). Absent when neither source is available
    - `encodedOrder` (required): string. An encoded copy of the order details which will be submitted to the filler network along with the signed permit
    - `orderId` (required): string. A unique ID for the order. Used to track the order's status
    - `orderInfo` (required): object
      - `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `nonce` (required): string. A unique nonce for this order
      - `reactor` (required): string. The address of a contract which will be used to facilitate the swap
      - `swapper` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
      - `deadline` (required): number. The unix timestamp at which the order will be reverted if not filled
      - `additionalValidationContract`: string. Unused and deprecated
      - `additionalValidationData`: string. Unused and deprecated
      - `input` (required): object
        - `startAmount` (required): string. The intended execution quantity of tokens resulting from this swap
        - `maxAmount` (required): string
        - `adjustmentPerGweiBaseFee` (required): string
        - `curve` (required): object
        - `token` (required): string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `outputs` (required): array
        - items:
          - `startAmount` (required): string. The intended execution quantity of tokens resulting from this swap
          - `minAmount`: string. The minimum portion of the swap, stated in the base unit of the token, which will be output to the recipient
          - `recipient` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
          - `adjustmentPerGweiBaseFee` (required): string
          - `curve` (required): object
          - `token` (required): string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `cosigner`: string. The address of a cosigner who will run the auction and ensure the best executable price within the given parameters. Currently the cosigner is always Uniswap Labs
      - `startingBaseFee`: string
    - `input`: object
      - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - `token`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `maximumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `output`: object
      - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
      - `minimumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `portionBips`: number. The portion of the swap that will be taken as a fee stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 87.5 for 0.875%). The fee will be taken from the output token
    - `portionAmount`: string. The portion of the swap that will be taken as a fee in the base units of the token. The fee will be taken from the output token
    - `portionRecipient`: string. The wallet address which will receive the fee
    - `quoteId`: string. A unique ID for the quote
    - `slippageTolerance`: number. The slippage tolerance as a percentage up to a maximum of two decimal places. For Uniswap Protocols (v2, v3, v4), the slippage tolerance is the maximum amount the price can change between the time the transaction is submitted and the time it is executed. The slippage tolerance is a percentage of the total value of the swap.  When submitting a quote, note that slippage tolerance works differently in UniswapX swaps where it does not set a limit on the Spread in an order. See [here](https://api-docs.uniswap.org/guides/faqs#why-do-uniswapx-quotes-have-more-slippage-than-the-tolerance-i-set) for more information.  Note that if the trade type is `EXACT_INPUT`, then the slippage is in terms of the output token. If the trade type is `EXACT_OUTPUT`, then the slippage is in terms of the input token.  When submitting a request, `slippageTolerance` may not be set when `autoSlippage` is defined. One of `slippageTolerance` or `autoSlippage` must be defined
    - `deadlineBufferSecs`: number
    - `classicGasUseEstimateUSD`: string. The gas fee you would pay if you opted for a CLASSIC swap over a Uniswap X order in terms of USD
    - `expectedAmountIn`: string
    - `expectedAmountOut`: string
    - `aggregatedOutputs`: array
      - items:
        - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
        - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
        - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
        - `bps`: number. The portion of the swap stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 12.5)
        - `minAmount`: string. The minimum portion of the swap, stated in the base unit of the token, which will be output to the recipient
        - `fee`: string = `INTEGRATOR`. Set to INTEGRATOR when this output is an integrator fee (as specified by the `integratorFees` array in the /quote request); omitted for the core output of the swap
  - oneOf: `UniswapX Priority Quote` object
    - `priceDifference`: number. The expected value lost versus frictionless execution at current prices, as a percent between -100 and 100. Negative values indicate price improvement. For UniswapX orders this prefers USD parity, computed as 1 - (outputUSD + classicGasUseEstimateUSD) / inputUSD over the auction start amounts (the gas estimate is added back because the filler's gas is baked into the output), and falls back to comparing the execution price against the mid price implied by the classic quote (its execution price divided by 1 - priceImpact). Absent when neither source is available
    - `encodedOrder` (required): string. An encoded copy of the order details which will be submitted to the filler network along with the signed permit
    - `orderId` (required): string. A unique ID for the order. Used to track the order's status
    - `orderInfo` (required): object
      - `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `nonce` (required): string. A unique nonce for this order
      - `reactor` (required): string. The address of a contract which will be used to facilitate the swap
      - `swapper` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
      - `deadline` (required): number. The unix timestamp at which the order will be reverted if not filled
      - `additionalValidationContract`: string. Unused and deprecated
      - `additionalValidationData`: string. Unused and deprecated
      - `auctionStartBlock` (required): string
      - `baselinePriorityFeeWei` (required): string
      - `input` (required): object
        - `amount` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
        - `token` (required): string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
        - `mpsPerPriorityFeeWei` (required): string
      - `outputs` (required): array
        - items:
          - `amount` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
          - `token` (required): string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
          - `recipient` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
          - `mpsPerPriorityFeeWei` (required): string. The scaling factor of the priority fee based on the output token amount
      - `cosigner` (required): string. The address of a cosigner who will run the auction and ensure the best executable price within the given parameters. Currently the cosigner is always Uniswap Labs
    - `input`: object
      - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - `token`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `maximumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `output`: object
      - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
      - `minimumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `portionBips`: number. The portion of the swap that will be taken as a fee stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 87.5 for 0.875%). The fee will be taken from the output token
    - `portionAmount`: string. The portion of the swap that will be taken as a fee in the base units of the token. The fee will be taken from the output token
    - `portionRecipient`: string. The wallet address which will receive the fee
    - `quoteId`: string. A unique ID for the quote
    - `slippageTolerance`: number. The slippage tolerance as a percentage up to a maximum of two decimal places. For Uniswap Protocols (v2, v3, v4), the slippage tolerance is the maximum amount the price can change between the time the transaction is submitted and the time it is executed. The slippage tolerance is a percentage of the total value of the swap.  When submitting a quote, note that slippage tolerance works differently in UniswapX swaps where it does not set a limit on the Spread in an order. See [here](https://api-docs.uniswap.org/guides/faqs#why-do-uniswapx-quotes-have-more-slippage-than-the-tolerance-i-set) for more information.  Note that if the trade type is `EXACT_INPUT`, then the slippage is in terms of the output token. If the trade type is `EXACT_OUTPUT`, then the slippage is in terms of the input token.  When submitting a request, `slippageTolerance` may not be set when `autoSlippage` is defined. One of `slippageTolerance` or `autoSlippage` must be defined
    - `deadlineBufferSecs`: number
    - `classicGasUseEstimateUSD`: string. The gas fee you would pay if you opted for a CLASSIC swap over a Uniswap X order in terms of USD
    - `expectedAmountIn`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `expectedAmountOut`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `aggregatedOutputs`: array
      - items:
        - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
        - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
        - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
        - `bps`: number. The portion of the swap stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 12.5)
        - `minAmount`: string. The minimum portion of the swap, stated in the base unit of the token, which will be output to the recipient
        - `fee`: string = `INTEGRATOR`. Set to INTEGRATOR when this output is an integrator fee (as specified by the `integratorFees` array in the /quote request); omitted for the core output of the swap
- `routing` (required): string = `CLASSIC`, `DUTCH_LIMIT`, `DUTCH_V2`, `DUTCH_V3`, `BRIDGE`, `LIMIT_ORDER`, `PRIORITY`, `WRAP`, `UNWRAP`, `CHAINED`. The routing for the proposed transaction

## Urgency

The urgency impacts the estimated gas price of the transaction. The higher the urgency, the higher the gas price, and the faster the transaction is likely to be selected from the mempool. Send the bare string form (e.g. `"normal"`) for the common case, or the object form `{ level, overrides }` to supply caller caps for `maxPriorityFeePerGas`, `maxFeePerGas`, and `gasLimit`.

- oneOf: `` string
  - enum: `normal`, `fast`, `urgent`
- oneOf: `` object
  - `level` (required): string = `normal`, `fast`, `urgent`
  - `overrides`: object. Caller-supplied caps applied on top of the gas service's computed quote. All fields are absolute wei (decimal string). `maxPriorityFeePerGas` and `maxFeePerGas` are treated as caps - they lower the quote, never raise it. `gasLimit`, if set, replaces the limit calculation entirely
    - `maxPriorityFeePerGas`: string. Maximum priority fee in wei (decimal string)
    - `maxFeePerGas`: string. Maximum total fee per gas in wei (decimal string)
    - `gasLimit`: string. Gas limit cap (in gas units, decimal string)

## UrgencyOverrides

Caller-supplied caps applied on top of the gas service's computed quote. All fields are absolute wei (decimal string). `maxPriorityFeePerGas` and `maxFeePerGas` are treated as caps - they lower the quote, never raise it. `gasLimit`, if set, replaces the limit calculation entirely.

- `maxPriorityFeePerGas`: string. Maximum priority fee in wei (decimal string)
- `maxFeePerGas`: string. Maximum total fee per gas in wei (decimal string)
- `gasLimit`: string. Gas limit cap (in gas units, decimal string)

## UrgencyWithOverrides

High-level fee tier selection with optional caller-supplied caps. Use this form when you need to override one or more gas fields; otherwise send the bare `Urgency` string.

- `level` (required): string = `normal`, `fast`, `urgent`
- `overrides`: object. Caller-supplied caps applied on top of the gas service's computed quote. All fields are absolute wei (decimal string). `maxPriorityFeePerGas` and `maxFeePerGas` are treated as caps - they lower the quote, never raise it. `gasLimit`, if set, replaces the limit calculation entirely
  - `maxPriorityFeePerGas`: string. Maximum priority fee in wei (decimal string)
  - `maxFeePerGas`: string. Maximum total fee per gas in wei (decimal string)
  - `gasLimit`: string. Gas limit cap (in gas units, decimal string)

## Protocols

The protocols to use for the swap/order. If the `protocols` field is defined, then you can only set the `routingPreference` to `BEST_PRICE`. Note that the value `UNISWAPX` is deprecated and will be removed in a future release.

- items:
  - enum: `V2`, `V3`, `V4`, `UNISWAPX`, `UNISWAPX_V2`, `UNISWAPX_V3`, `UNISWAPX_LATEST`

## HooksOptions

The hook options to use for V4 pool quotes. `V4_HOOKS_INCLUSIVE` will get quotes for V4 pools with or without hooks. `V4_HOOKS_ONLY` will only get quotes for V4 pools with hooks. `V4_NO_HOOKS` will only get quotes for V4 pools without hooks. Defaults to `V4_HOOKS_INCLUSIVE` if `V4` is included in `protocols` and `hookOptions` is not set. This field is ignored if `V4` is not passed in `protocols`.

- enum: `V4_HOOKS_INCLUSIVE`, `V4_HOOKS_ONLY`, `V4_NO_HOOKS`

## Err400



- `errorCode`: string
- `detail`: string

## Err401



- `errorCode`: string
- `detail`: string

## Err404



- `errorCode`: string = `ResourceNotFound`, `QuoteAmountTooLowError`, `TokenBalanceNotAvailable`, `InsufficientBalance`
- `detail`: string

## Err422



- `errorCode`: string
- `detail`: string

## Err429



- `errorCode`: string
- `detail`: string

## Err500



- `errorCode`: string
- `detail`: string

## Err503



- `errorCode`: string
- `detail`: string

## Err504



- `errorCode`: string
- `detail`: string

## ChainId

The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs).

- enum: `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`

## includeGasInfo

If set to `true`, the response will include the estimated gas fee for the proposed transaction.


## gasLimit

The maximum units of gas that will be consumed by this transaction.


## maxFeePerGas

The sum of the base fee and priority fee. Subtracting `maxPriorityFeePerGas` from this value will yield the base fee to be paid for this transaction.


## maxPriorityFeePerGas

The maximum tip to the block builder. Adjusted based upon the urgency specified in the request.


## gasPrice

The cost per unit of gas.


## gasFee

The total estimated gas cost of this transaction (eg. `gasLimit` multiplied by `maxFeePerGas`) in the base unit of the chain.


## gasFeeUSD

The total estimated gas cost of this transaction (eg. `gasLimit` multiplied by `maxFeePerGas`) denominated in USDC.


## gasFeeInCurrency

The total estimated gas cost of this transaction (eg. gasLimit multiplied by maxFeePerGas) in the quoted currency (e.g. output token) in the base units of the quoted currency.


## OrderInput



- `token` (required): string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `startAmount`: string. The intended execution quantity of tokens resulting from this swap
- `endAmount`: string. The worst case quantity of tokens resulting from this swap

## OrderOutput



- `token` (required): string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `startAmount`: string. The intended execution quantity of tokens resulting from this swap
- `endAmount`: string. The worst case quantity of tokens resulting from this swap
- `isFeeOutput`: boolean
- `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`

## CosignerData



- `decayStartTime`: number. The unix timestamp at which the order will be eligible to be filled by alternate fillers at a lower price. Noted that the fill amount will not be lower than the output `endAmount`
- `decayEndTime`: number. The unix timestamp at which the order will no longer be eligible to be filled by alternate fillers
- `exclusiveFiller`: string. The address of the filler who has priority to fill the order by the `decayStartTime`
- `inputOverride`: string
- `outputOverrides`: array
  - items:

## SettledAmount



- `tokenOut`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `amountOut`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `tokenIn`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `amountIn`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0

## OrderType



- enum: `DutchLimit`, `Dutch`, `Dutch_V2`, `Dutch_V3`, `Priority`

## OrderTypeQuery



- enum: `Dutch_V2`, `Dutch_V3`, `Limit`, `Priority`

## UniswapXOrder



- `type` (required): string = `DutchLimit`, `Dutch`, `Dutch_V2`, `Dutch_V3`, `Priority`
- `encodedOrder` (required): string. An encoded copy of the order details which will be submitted to the filler network along with the signed permit
- `signature` (required): string
- `nonce` (required): string. A unique nonce for this order
- `orderStatus` (required): string = `open`, `expired`, `error`, `cancelled`, `filled`, `unverified`, `insufficient-funds`. The status of the order. Note that all of these are final states with the exception of Open, meaning that no further state changes will occur.   Open - order is not yet filled by a filler.  Expired - order has expired without being filled and is no longer fillable.  Error - a catchall for other final states which are not otherwise specified, where the order will not be filled.  Cancelled - order is cancelled. Note that to cancel an order, a new order must be placed with the same nonce as the prior open order and it must be placed within the same block as the original order.  Filled - order is filled.  Insufficient-funds - the swapper (you) do not have enough funds for the order to be completed and the order is cancelled and will not be filled.  Unverified - order has not been verified yet
- `orderId` (required): string. A unique ID for the order. Used to track the order's status
- `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `quoteId`: string. A unique ID for the quote
- `swapper`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
- `txHash`: string. The unique hash of the transaction
- `input`: object
  - `token` (required): string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `startAmount`: string. The intended execution quantity of tokens resulting from this swap
  - `endAmount`: string. The worst case quantity of tokens resulting from this swap
- `outputs`: array
  - items:
    - `token` (required): string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `startAmount`: string. The intended execution quantity of tokens resulting from this swap
    - `endAmount`: string. The worst case quantity of tokens resulting from this swap
    - `isFeeOutput`: boolean
    - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
- `settledAmounts`: array
  - items:
    - `tokenOut`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `amountOut`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `tokenIn`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `amountIn`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `cosignature`: string
- `cosignerData`: object
  - `decayStartTime`: number. The unix timestamp at which the order will be eligible to be filled by alternate fillers at a lower price. Noted that the fill amount will not be lower than the output `endAmount`
  - `decayEndTime`: number. The unix timestamp at which the order will no longer be eligible to be filled by alternate fillers
  - `exclusiveFiller`: string. The address of the filler who has priority to fill the order by the `decayStartTime`
  - `inputOverride`: string
  - `outputOverrides`: array
    - items:

## SortKey



- enum: `createdAt`

## OrderIds




## OrderStatus

The status of the order. Note that all of these are final states with the exception of Open, meaning that no further state changes will occur. 
 Open - order is not yet filled by a filler.
 Expired - order has expired without being filled and is no longer fillable.
 Error - a catchall for other final states which are not otherwise specified, where the order will not be filled.
 Cancelled - order is cancelled. Note that to cancel an order, a new order must be placed with the same nonce as the prior open order and it must be placed within the same block as the original order.
 Filled - order is filled.
 Insufficient-funds - the swapper (you) do not have enough funds for the order to be completed and the order is cancelled and will not be filled.
 Unverified - order has not been verified yet.

- enum: `open`, `expired`, `error`, `cancelled`, `filled`, `unverified`, `insufficient-funds`

## Permit

the permit2 message object for the customer to sign to permit spending by the permit2 contract.

- `domain`: object
- `values`: object
- `types`: object

## NullablePermit

the permit2 message object for the customer to sign to permit spending by the permit2 contract.

- `domain`: object
- `values`: object
- `types`: object

## TokenProject



- `logo` (required): object
  - `url` (required): string
- `safetyLevel` (required): string = `BLOCKED`, `MEDIUM_WARNING`, `STRONG_WARNING`, `VERIFIED`
- `isSpam` (required): boolean. Whether the token is considered a spam token

## TokenProjectLogo



- `url` (required): string

## DutchInput



- `startAmount` (required): string. The intended execution quantity of tokens resulting from this swap
- `endAmount` (required): string. The worst case quantity of tokens resulting from this swap
- `token`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)

## DutchOutput



- `startAmount` (required): string. The intended execution quantity of tokens resulting from this swap
- `endAmount` (required): string. The worst case quantity of tokens resulting from this swap
- `token` (required): string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `recipient` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`

## Curve



- `relativeBlocks`: array
  - items:
- `relativeAmounts`: array
  - items:

## DutchInputV3



- `startAmount` (required): string. The intended execution quantity of tokens resulting from this swap
- `maxAmount` (required): string
- `adjustmentPerGweiBaseFee` (required): string
- `curve` (required): object
  - `relativeBlocks`: array
    - items:
  - `relativeAmounts`: array
    - items:
- `token` (required): string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)

## DutchOutputV3



- `startAmount` (required): string. The intended execution quantity of tokens resulting from this swap
- `minAmount`: string. The minimum portion of the swap, stated in the base unit of the token, which will be output to the recipient
- `recipient` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
- `adjustmentPerGweiBaseFee` (required): string
- `curve` (required): object
  - `relativeBlocks`: array
    - items:
  - `relativeAmounts`: array
    - items:
- `token` (required): string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)

## DutchOrderInfo



- `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `nonce` (required): string. A unique nonce for this order
- `reactor` (required): string. The address of a contract which will be used to facilitate the swap
- `swapper` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
- `deadline` (required): number. The unix timestamp at which the order will be reverted if not filled
- `additionalValidationContract`: string. Unused and deprecated
- `additionalValidationData`: string. Unused and deprecated
- `decayStartTime`: number. The unix timestamp at which the order will be eligible to be filled by alternate fillers at a lower price. Noted that the fill amount will not be lower than the output `endAmount`
- `decayEndTime`: number. The unix timestamp at which the order will no longer be eligible to be filled by alternate fillers
- `exclusiveFiller` (required): string. The address of the filler who has priority to fill the order by the `decayStartTime`
- `exclusivityOverrideBps` (required): string. The portion of the order which is eligible to be filled by the `exclusiveFiller`, specified in basis points
- `input` (required): object
  - `startAmount` (required): string. The intended execution quantity of tokens resulting from this swap
  - `endAmount` (required): string. The worst case quantity of tokens resulting from this swap
  - `token`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `outputs` (required): array
  - items:
    - `startAmount` (required): string. The intended execution quantity of tokens resulting from this swap
    - `endAmount` (required): string. The worst case quantity of tokens resulting from this swap
    - `token` (required): string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `recipient` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`

## DutchOrderInfoV2



- `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `nonce` (required): string. A unique nonce for this order
- `reactor` (required): string. The address of a contract which will be used to facilitate the swap
- `swapper` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
- `deadline` (required): number. The unix timestamp at which the order will be reverted if not filled
- `additionalValidationContract`: string. Unused and deprecated
- `additionalValidationData`: string. Unused and deprecated
- `input` (required): object
  - `startAmount` (required): string. The intended execution quantity of tokens resulting from this swap
  - `endAmount` (required): string. The worst case quantity of tokens resulting from this swap
  - `token`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `outputs` (required): array
  - items:
    - `startAmount` (required): string. The intended execution quantity of tokens resulting from this swap
    - `endAmount` (required): string. The worst case quantity of tokens resulting from this swap
    - `token` (required): string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `recipient` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
- `cosigner`: string. The address of a cosigner who will run the auction and ensure the best executable price within the given parameters. Currently the cosigner is always Uniswap Labs

## DutchOrderInfoV3



- `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `nonce` (required): string. A unique nonce for this order
- `reactor` (required): string. The address of a contract which will be used to facilitate the swap
- `swapper` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
- `deadline` (required): number. The unix timestamp at which the order will be reverted if not filled
- `additionalValidationContract`: string. Unused and deprecated
- `additionalValidationData`: string. Unused and deprecated
- `input` (required): object
  - `startAmount` (required): string. The intended execution quantity of tokens resulting from this swap
  - `maxAmount` (required): string
  - `adjustmentPerGweiBaseFee` (required): string
  - `curve` (required): object
    - `relativeBlocks`: array
      - items:
    - `relativeAmounts`: array
      - items:
  - `token` (required): string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `outputs` (required): array
  - items:
    - `startAmount` (required): string. The intended execution quantity of tokens resulting from this swap
    - `minAmount`: string. The minimum portion of the swap, stated in the base unit of the token, which will be output to the recipient
    - `recipient` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
    - `adjustmentPerGweiBaseFee` (required): string
    - `curve` (required): object
      - `relativeBlocks`: array
      - `relativeAmounts`: array
    - `token` (required): string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `cosigner`: string. The address of a cosigner who will run the auction and ensure the best executable price within the given parameters. Currently the cosigner is always Uniswap Labs
- `startingBaseFee`: string

## DutchQuote



- `encodedOrder` (required): string. An encoded copy of the order details which will be submitted to the filler network along with the signed permit
- `orderId` (required): string. A unique ID for the order. Used to track the order's status
- `orderInfo` (required): object
  - `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `nonce` (required): string. A unique nonce for this order
  - `reactor` (required): string. The address of a contract which will be used to facilitate the swap
  - `swapper` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
  - `deadline` (required): number. The unix timestamp at which the order will be reverted if not filled
  - `additionalValidationContract`: string. Unused and deprecated
  - `additionalValidationData`: string. Unused and deprecated
  - `decayStartTime`: number. The unix timestamp at which the order will be eligible to be filled by alternate fillers at a lower price. Noted that the fill amount will not be lower than the output `endAmount`
  - `decayEndTime`: number. The unix timestamp at which the order will no longer be eligible to be filled by alternate fillers
  - `exclusiveFiller` (required): string. The address of the filler who has priority to fill the order by the `decayStartTime`
  - `exclusivityOverrideBps` (required): string. The portion of the order which is eligible to be filled by the `exclusiveFiller`, specified in basis points
  - `input` (required): object
    - `startAmount` (required): string. The intended execution quantity of tokens resulting from this swap
    - `endAmount` (required): string. The worst case quantity of tokens resulting from this swap
    - `token`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `outputs` (required): array
    - items:
      - `startAmount` (required): string. The intended execution quantity of tokens resulting from this swap
      - `endAmount` (required): string. The worst case quantity of tokens resulting from this swap
      - `token` (required): string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `recipient` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
- `input`: object
  - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
  - `token`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `maximumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `output`: object
  - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
  - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
  - `minimumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `portionBips`: number. The portion of the swap that will be taken as a fee stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 87.5 for 0.875%). The fee will be taken from the output token
- `portionAmount`: string. The portion of the swap that will be taken as a fee in the base units of the token. The fee will be taken from the output token
- `portionRecipient`: string. The wallet address which will receive the fee
- `quoteId`: string. A unique ID for the quote
- `slippageTolerance`: number. The slippage tolerance as a percentage up to a maximum of two decimal places. For Uniswap Protocols (v2, v3, v4), the slippage tolerance is the maximum amount the price can change between the time the transaction is submitted and the time it is executed. The slippage tolerance is a percentage of the total value of the swap.  When submitting a quote, note that slippage tolerance works differently in UniswapX swaps where it does not set a limit on the Spread in an order. See [here](https://api-docs.uniswap.org/guides/faqs#why-do-uniswapx-quotes-have-more-slippage-than-the-tolerance-i-set) for more information.  Note that if the trade type is `EXACT_INPUT`, then the slippage is in terms of the output token. If the trade type is `EXACT_OUTPUT`, then the slippage is in terms of the input token.  When submitting a request, `slippageTolerance` may not be set when `autoSlippage` is defined. One of `slippageTolerance` or `autoSlippage` must be defined
- `classicGasUseEstimateUSD`: string. The gas fee you would pay if you opted for a CLASSIC swap over a Uniswap X order in terms of USD
- `aggregatedOutputs`: array
  - items:
    - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
    - `bps`: number. The portion of the swap stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 12.5)
    - `minAmount`: string. The minimum portion of the swap, stated in the base unit of the token, which will be output to the recipient
    - `fee`: string = `INTEGRATOR`. Set to INTEGRATOR when this output is an integrator fee (as specified by the `integratorFees` array in the /quote request); omitted for the core output of the swap

## DutchQuoteV2



- `priceDifference`: number. The expected value lost versus frictionless execution at current prices, as a percent between -100 and 100. Negative values indicate price improvement. For UniswapX orders this prefers USD parity, computed as 1 - (outputUSD + classicGasUseEstimateUSD) / inputUSD over the auction start amounts (the gas estimate is added back because the filler's gas is baked into the output), and falls back to comparing the execution price against the mid price implied by the classic quote (its execution price divided by 1 - priceImpact). Absent when neither source is available
- `encodedOrder` (required): string. An encoded copy of the order details which will be submitted to the filler network along with the signed permit
- `orderId` (required): string. A unique ID for the order. Used to track the order's status
- `orderInfo` (required): object
  - `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `nonce` (required): string. A unique nonce for this order
  - `reactor` (required): string. The address of a contract which will be used to facilitate the swap
  - `swapper` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
  - `deadline` (required): number. The unix timestamp at which the order will be reverted if not filled
  - `additionalValidationContract`: string. Unused and deprecated
  - `additionalValidationData`: string. Unused and deprecated
  - `input` (required): object
    - `startAmount` (required): string. The intended execution quantity of tokens resulting from this swap
    - `endAmount` (required): string. The worst case quantity of tokens resulting from this swap
    - `token`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `outputs` (required): array
    - items:
      - `startAmount` (required): string. The intended execution quantity of tokens resulting from this swap
      - `endAmount` (required): string. The worst case quantity of tokens resulting from this swap
      - `token` (required): string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `recipient` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
  - `cosigner`: string. The address of a cosigner who will run the auction and ensure the best executable price within the given parameters. Currently the cosigner is always Uniswap Labs
- `input`: object
  - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
  - `token`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `maximumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `output`: object
  - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
  - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
  - `minimumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `portionBips`: number. The portion of the swap that will be taken as a fee stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 87.5 for 0.875%). The fee will be taken from the output token
- `portionAmount`: string. The portion of the swap that will be taken as a fee in the base units of the token. The fee will be taken from the output token
- `portionRecipient`: string. The wallet address which will receive the fee
- `quoteId`: string. A unique ID for the quote
- `slippageTolerance`: number. The slippage tolerance as a percentage up to a maximum of two decimal places. For Uniswap Protocols (v2, v3, v4), the slippage tolerance is the maximum amount the price can change between the time the transaction is submitted and the time it is executed. The slippage tolerance is a percentage of the total value of the swap.  When submitting a quote, note that slippage tolerance works differently in UniswapX swaps where it does not set a limit on the Spread in an order. See [here](https://api-docs.uniswap.org/guides/faqs#why-do-uniswapx-quotes-have-more-slippage-than-the-tolerance-i-set) for more information.  Note that if the trade type is `EXACT_INPUT`, then the slippage is in terms of the output token. If the trade type is `EXACT_OUTPUT`, then the slippage is in terms of the input token.  When submitting a request, `slippageTolerance` may not be set when `autoSlippage` is defined. One of `slippageTolerance` or `autoSlippage` must be defined
- `deadlineBufferSecs`: number
- `classicGasUseEstimateUSD`: string. The gas fee you would pay if you opted for a CLASSIC swap over a Uniswap X order in terms of USD
- `aggregatedOutputs`: array
  - items:
    - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
    - `bps`: number. The portion of the swap stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 12.5)
    - `minAmount`: string. The minimum portion of the swap, stated in the base unit of the token, which will be output to the recipient
    - `fee`: string = `INTEGRATOR`. Set to INTEGRATOR when this output is an integrator fee (as specified by the `integratorFees` array in the /quote request); omitted for the core output of the swap

## DutchQuoteV3



- `priceDifference`: number. The expected value lost versus frictionless execution at current prices, as a percent between -100 and 100. Negative values indicate price improvement. For UniswapX orders this prefers USD parity, computed as 1 - (outputUSD + classicGasUseEstimateUSD) / inputUSD over the auction start amounts (the gas estimate is added back because the filler's gas is baked into the output), and falls back to comparing the execution price against the mid price implied by the classic quote (its execution price divided by 1 - priceImpact). Absent when neither source is available
- `encodedOrder` (required): string. An encoded copy of the order details which will be submitted to the filler network along with the signed permit
- `orderId` (required): string. A unique ID for the order. Used to track the order's status
- `orderInfo` (required): object
  - `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `nonce` (required): string. A unique nonce for this order
  - `reactor` (required): string. The address of a contract which will be used to facilitate the swap
  - `swapper` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
  - `deadline` (required): number. The unix timestamp at which the order will be reverted if not filled
  - `additionalValidationContract`: string. Unused and deprecated
  - `additionalValidationData`: string. Unused and deprecated
  - `input` (required): object
    - `startAmount` (required): string. The intended execution quantity of tokens resulting from this swap
    - `maxAmount` (required): string
    - `adjustmentPerGweiBaseFee` (required): string
    - `curve` (required): object
      - `relativeBlocks`: array
        - items:
      - `relativeAmounts`: array
        - items:
    - `token` (required): string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `outputs` (required): array
    - items:
      - `startAmount` (required): string. The intended execution quantity of tokens resulting from this swap
      - `minAmount`: string. The minimum portion of the swap, stated in the base unit of the token, which will be output to the recipient
      - `recipient` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
      - `adjustmentPerGweiBaseFee` (required): string
      - `curve` (required): object
        - `relativeBlocks`: array
        - `relativeAmounts`: array
      - `token` (required): string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `cosigner`: string. The address of a cosigner who will run the auction and ensure the best executable price within the given parameters. Currently the cosigner is always Uniswap Labs
  - `startingBaseFee`: string
- `input`: object
  - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
  - `token`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `maximumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `output`: object
  - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
  - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
  - `minimumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `portionBips`: number. The portion of the swap that will be taken as a fee stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 87.5 for 0.875%). The fee will be taken from the output token
- `portionAmount`: string. The portion of the swap that will be taken as a fee in the base units of the token. The fee will be taken from the output token
- `portionRecipient`: string. The wallet address which will receive the fee
- `quoteId`: string. A unique ID for the quote
- `slippageTolerance`: number. The slippage tolerance as a percentage up to a maximum of two decimal places. For Uniswap Protocols (v2, v3, v4), the slippage tolerance is the maximum amount the price can change between the time the transaction is submitted and the time it is executed. The slippage tolerance is a percentage of the total value of the swap.  When submitting a quote, note that slippage tolerance works differently in UniswapX swaps where it does not set a limit on the Spread in an order. See [here](https://api-docs.uniswap.org/guides/faqs#why-do-uniswapx-quotes-have-more-slippage-than-the-tolerance-i-set) for more information.  Note that if the trade type is `EXACT_INPUT`, then the slippage is in terms of the output token. If the trade type is `EXACT_OUTPUT`, then the slippage is in terms of the input token.  When submitting a request, `slippageTolerance` may not be set when `autoSlippage` is defined. One of `slippageTolerance` or `autoSlippage` must be defined
- `deadlineBufferSecs`: number
- `classicGasUseEstimateUSD`: string. The gas fee you would pay if you opted for a CLASSIC swap over a Uniswap X order in terms of USD
- `expectedAmountIn`: string
- `expectedAmountOut`: string
- `aggregatedOutputs`: array
  - items:
    - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
    - `bps`: number. The portion of the swap stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 12.5)
    - `minAmount`: string. The minimum portion of the swap, stated in the base unit of the token, which will be output to the recipient
    - `fee`: string = `INTEGRATOR`. Set to INTEGRATOR when this output is an integrator fee (as specified by the `integratorFees` array in the /quote request); omitted for the core output of the swap

## PriorityInput



- `amount` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `token` (required): string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `mpsPerPriorityFeeWei` (required): string

## PriorityOutput



- `amount` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `token` (required): string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `recipient` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
- `mpsPerPriorityFeeWei` (required): string. The scaling factor of the priority fee based on the output token amount

## PriorityOrderInfo



- `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `nonce` (required): string. A unique nonce for this order
- `reactor` (required): string. The address of a contract which will be used to facilitate the swap
- `swapper` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
- `deadline` (required): number. The unix timestamp at which the order will be reverted if not filled
- `additionalValidationContract`: string. Unused and deprecated
- `additionalValidationData`: string. Unused and deprecated
- `auctionStartBlock` (required): string
- `baselinePriorityFeeWei` (required): string
- `input` (required): object
  - `amount` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
  - `token` (required): string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `mpsPerPriorityFeeWei` (required): string
- `outputs` (required): array
  - items:
    - `amount` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `token` (required): string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `recipient` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
    - `mpsPerPriorityFeeWei` (required): string. The scaling factor of the priority fee based on the output token amount
- `cosigner` (required): string. The address of a cosigner who will run the auction and ensure the best executable price within the given parameters. Currently the cosigner is always Uniswap Labs

## PriorityQuote



- `priceDifference`: number. The expected value lost versus frictionless execution at current prices, as a percent between -100 and 100. Negative values indicate price improvement. For UniswapX orders this prefers USD parity, computed as 1 - (outputUSD + classicGasUseEstimateUSD) / inputUSD over the auction start amounts (the gas estimate is added back because the filler's gas is baked into the output), and falls back to comparing the execution price against the mid price implied by the classic quote (its execution price divided by 1 - priceImpact). Absent when neither source is available
- `encodedOrder` (required): string. An encoded copy of the order details which will be submitted to the filler network along with the signed permit
- `orderId` (required): string. A unique ID for the order. Used to track the order's status
- `orderInfo` (required): object
  - `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `nonce` (required): string. A unique nonce for this order
  - `reactor` (required): string. The address of a contract which will be used to facilitate the swap
  - `swapper` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
  - `deadline` (required): number. The unix timestamp at which the order will be reverted if not filled
  - `additionalValidationContract`: string. Unused and deprecated
  - `additionalValidationData`: string. Unused and deprecated
  - `auctionStartBlock` (required): string
  - `baselinePriorityFeeWei` (required): string
  - `input` (required): object
    - `amount` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `token` (required): string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `mpsPerPriorityFeeWei` (required): string
  - `outputs` (required): array
    - items:
      - `amount` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - `token` (required): string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `recipient` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
      - `mpsPerPriorityFeeWei` (required): string. The scaling factor of the priority fee based on the output token amount
  - `cosigner` (required): string. The address of a cosigner who will run the auction and ensure the best executable price within the given parameters. Currently the cosigner is always Uniswap Labs
- `input`: object
  - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
  - `token`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `maximumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `output`: object
  - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
  - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
  - `minimumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `portionBips`: number. The portion of the swap that will be taken as a fee stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 87.5 for 0.875%). The fee will be taken from the output token
- `portionAmount`: string. The portion of the swap that will be taken as a fee in the base units of the token. The fee will be taken from the output token
- `portionRecipient`: string. The wallet address which will receive the fee
- `quoteId`: string. A unique ID for the quote
- `slippageTolerance`: number. The slippage tolerance as a percentage up to a maximum of two decimal places. For Uniswap Protocols (v2, v3, v4), the slippage tolerance is the maximum amount the price can change between the time the transaction is submitted and the time it is executed. The slippage tolerance is a percentage of the total value of the swap.  When submitting a quote, note that slippage tolerance works differently in UniswapX swaps where it does not set a limit on the Spread in an order. See [here](https://api-docs.uniswap.org/guides/faqs#why-do-uniswapx-quotes-have-more-slippage-than-the-tolerance-i-set) for more information.  Note that if the trade type is `EXACT_INPUT`, then the slippage is in terms of the output token. If the trade type is `EXACT_OUTPUT`, then the slippage is in terms of the input token.  When submitting a request, `slippageTolerance` may not be set when `autoSlippage` is defined. One of `slippageTolerance` or `autoSlippage` must be defined
- `deadlineBufferSecs`: number
- `classicGasUseEstimateUSD`: string. The gas fee you would pay if you opted for a CLASSIC swap over a Uniswap X order in terms of USD
- `expectedAmountIn`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `expectedAmountOut`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `aggregatedOutputs`: array
  - items:
    - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
    - `bps`: number. The portion of the swap stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 12.5)
    - `minAmount`: string. The minimum portion of the swap, stated in the base unit of the token, which will be output to the recipient
    - `fee`: string = `INTEGRATOR`. Set to INTEGRATOR when this output is an integrator fee (as specified by the `integratorFees` array in the /quote request); omitted for the core output of the swap

## BridgeQuote



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

## SafetyLevel



- enum: `BLOCKED`, `MEDIUM_WARNING`, `STRONG_WARNING`, `VERIFIED`

## TradeType

The handling of the `amount` field. `EXACT_INPUT` means the requester will send the specified `amount` of input tokens and get a quote with a variable quantity of output tokens. `EXACT_OUTPUT` means the requester will receive the specified `amount` of output tokens and get a quote with a variable quantity of input tokens.

- enum: `EXACT_INPUT`, `EXACT_OUTPUT`

## Routing

The routing for the proposed transaction.

- enum: `CLASSIC`, `DUTCH_LIMIT`, `DUTCH_V2`, `DUTCH_V3`, `BRIDGE`, `LIMIT_ORDER`, `PRIORITY`, `WRAP`, `UNWRAP`, `CHAINED`

## PlanStepType

The type of step in a plan, including swap types and approval types.

- enum: `DUTCH_LIMIT`, `CLASSIC`, `DUTCH_V2`, `LIMIT_ORDER`, `WRAP`, `UNWRAP`, `BRIDGE`, `PRIORITY`, `DUTCH_V3`, `QUICKROUTE`, `CHAINED`, `VAULT_DEPOSIT`, `VAULT_WITHDRAW`, `APPROVAL_TXN`, `APPROVAL_PERMIT`, `RESET_APPROVAL_TXN`

## AggregatedOutput

An array of all outputs of the proposed transaction. This includes the swap as well as any fees collected by the API integrator. This does not include pool fees when routing is through a Uniswap Protocol pool.

- `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
- `bps`: number. The portion of the swap stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 12.5)
- `minAmount`: string. The minimum portion of the swap, stated in the base unit of the token, which will be output to the recipient
- `fee`: string = `INTEGRATOR`. Set to INTEGRATOR when this output is an integrator fee (as specified by the `integratorFees` array in the /quote request); omitted for the core output of the swap

## Quote



- oneOf: `` object
  - `encodedOrder` (required): string. An encoded copy of the order details which will be submitted to the filler network along with the signed permit
  - `orderId` (required): string. A unique ID for the order. Used to track the order's status
  - `orderInfo` (required): object
    - `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `nonce` (required): string. A unique nonce for this order
    - `reactor` (required): string. The address of a contract which will be used to facilitate the swap
    - `swapper` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
    - `deadline` (required): number. The unix timestamp at which the order will be reverted if not filled
    - `additionalValidationContract`: string. Unused and deprecated
    - `additionalValidationData`: string. Unused and deprecated
    - `decayStartTime`: number. The unix timestamp at which the order will be eligible to be filled by alternate fillers at a lower price. Noted that the fill amount will not be lower than the output `endAmount`
    - `decayEndTime`: number. The unix timestamp at which the order will no longer be eligible to be filled by alternate fillers
    - `exclusiveFiller` (required): string. The address of the filler who has priority to fill the order by the `decayStartTime`
    - `exclusivityOverrideBps` (required): string. The portion of the order which is eligible to be filled by the `exclusiveFiller`, specified in basis points
    - `input` (required): object
      - `startAmount` (required): string. The intended execution quantity of tokens resulting from this swap
      - `endAmount` (required): string. The worst case quantity of tokens resulting from this swap
      - `token`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `outputs` (required): array
      - items:
        - `startAmount` (required): string. The intended execution quantity of tokens resulting from this swap
        - `endAmount` (required): string. The worst case quantity of tokens resulting from this swap
        - `token` (required): string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
        - `recipient` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
  - `input`: object
    - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `token`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `maximumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
  - `output`: object
    - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
    - `minimumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
  - `portionBips`: number. The portion of the swap that will be taken as a fee stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 87.5 for 0.875%). The fee will be taken from the output token
  - `portionAmount`: string. The portion of the swap that will be taken as a fee in the base units of the token. The fee will be taken from the output token
  - `portionRecipient`: string. The wallet address which will receive the fee
  - `quoteId`: string. A unique ID for the quote
  - `slippageTolerance`: number. The slippage tolerance as a percentage up to a maximum of two decimal places. For Uniswap Protocols (v2, v3, v4), the slippage tolerance is the maximum amount the price can change between the time the transaction is submitted and the time it is executed. The slippage tolerance is a percentage of the total value of the swap.  When submitting a quote, note that slippage tolerance works differently in UniswapX swaps where it does not set a limit on the Spread in an order. See [here](https://api-docs.uniswap.org/guides/faqs#why-do-uniswapx-quotes-have-more-slippage-than-the-tolerance-i-set) for more information.  Note that if the trade type is `EXACT_INPUT`, then the slippage is in terms of the output token. If the trade type is `EXACT_OUTPUT`, then the slippage is in terms of the input token.  When submitting a request, `slippageTolerance` may not be set when `autoSlippage` is defined. One of `slippageTolerance` or `autoSlippage` must be defined
  - `classicGasUseEstimateUSD`: string. The gas fee you would pay if you opted for a CLASSIC swap over a Uniswap X order in terms of USD
  - `aggregatedOutputs`: array
    - items:
      - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
      - `bps`: number. The portion of the swap stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 12.5)
      - `minAmount`: string. The minimum portion of the swap, stated in the base unit of the token, which will be output to the recipient
      - `fee`: string = `INTEGRATOR`. Set to INTEGRATOR when this output is an integrator fee (as specified by the `integratorFees` array in the /quote request); omitted for the core output of the swap
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
- oneOf: `UniswapX V2 Quote` object
  - `priceDifference`: number. The expected value lost versus frictionless execution at current prices, as a percent between -100 and 100. Negative values indicate price improvement. For UniswapX orders this prefers USD parity, computed as 1 - (outputUSD + classicGasUseEstimateUSD) / inputUSD over the auction start amounts (the gas estimate is added back because the filler's gas is baked into the output), and falls back to comparing the execution price against the mid price implied by the classic quote (its execution price divided by 1 - priceImpact). Absent when neither source is available
  - `encodedOrder` (required): string. An encoded copy of the order details which will be submitted to the filler network along with the signed permit
  - `orderId` (required): string. A unique ID for the order. Used to track the order's status
  - `orderInfo` (required): object
    - `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `nonce` (required): string. A unique nonce for this order
    - `reactor` (required): string. The address of a contract which will be used to facilitate the swap
    - `swapper` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
    - `deadline` (required): number. The unix timestamp at which the order will be reverted if not filled
    - `additionalValidationContract`: string. Unused and deprecated
    - `additionalValidationData`: string. Unused and deprecated
    - `input` (required): object
      - `startAmount` (required): string. The intended execution quantity of tokens resulting from this swap
      - `endAmount` (required): string. The worst case quantity of tokens resulting from this swap
      - `token`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `outputs` (required): array
      - items:
        - `startAmount` (required): string. The intended execution quantity of tokens resulting from this swap
        - `endAmount` (required): string. The worst case quantity of tokens resulting from this swap
        - `token` (required): string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
        - `recipient` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
    - `cosigner`: string. The address of a cosigner who will run the auction and ensure the best executable price within the given parameters. Currently the cosigner is always Uniswap Labs
  - `input`: object
    - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `token`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `maximumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
  - `output`: object
    - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
    - `minimumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
  - `portionBips`: number. The portion of the swap that will be taken as a fee stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 87.5 for 0.875%). The fee will be taken from the output token
  - `portionAmount`: string. The portion of the swap that will be taken as a fee in the base units of the token. The fee will be taken from the output token
  - `portionRecipient`: string. The wallet address which will receive the fee
  - `quoteId`: string. A unique ID for the quote
  - `slippageTolerance`: number. The slippage tolerance as a percentage up to a maximum of two decimal places. For Uniswap Protocols (v2, v3, v4), the slippage tolerance is the maximum amount the price can change between the time the transaction is submitted and the time it is executed. The slippage tolerance is a percentage of the total value of the swap.  When submitting a quote, note that slippage tolerance works differently in UniswapX swaps where it does not set a limit on the Spread in an order. See [here](https://api-docs.uniswap.org/guides/faqs#why-do-uniswapx-quotes-have-more-slippage-than-the-tolerance-i-set) for more information.  Note that if the trade type is `EXACT_INPUT`, then the slippage is in terms of the output token. If the trade type is `EXACT_OUTPUT`, then the slippage is in terms of the input token.  When submitting a request, `slippageTolerance` may not be set when `autoSlippage` is defined. One of `slippageTolerance` or `autoSlippage` must be defined
  - `deadlineBufferSecs`: number
  - `classicGasUseEstimateUSD`: string. The gas fee you would pay if you opted for a CLASSIC swap over a Uniswap X order in terms of USD
  - `aggregatedOutputs`: array
    - items:
      - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
      - `bps`: number. The portion of the swap stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 12.5)
      - `minAmount`: string. The minimum portion of the swap, stated in the base unit of the token, which will be output to the recipient
      - `fee`: string = `INTEGRATOR`. Set to INTEGRATOR when this output is an integrator fee (as specified by the `integratorFees` array in the /quote request); omitted for the core output of the swap
- oneOf: `UniswapX V3 Quote` object
  - `priceDifference`: number. The expected value lost versus frictionless execution at current prices, as a percent between -100 and 100. Negative values indicate price improvement. For UniswapX orders this prefers USD parity, computed as 1 - (outputUSD + classicGasUseEstimateUSD) / inputUSD over the auction start amounts (the gas estimate is added back because the filler's gas is baked into the output), and falls back to comparing the execution price against the mid price implied by the classic quote (its execution price divided by 1 - priceImpact). Absent when neither source is available
  - `encodedOrder` (required): string. An encoded copy of the order details which will be submitted to the filler network along with the signed permit
  - `orderId` (required): string. A unique ID for the order. Used to track the order's status
  - `orderInfo` (required): object
    - `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `nonce` (required): string. A unique nonce for this order
    - `reactor` (required): string. The address of a contract which will be used to facilitate the swap
    - `swapper` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
    - `deadline` (required): number. The unix timestamp at which the order will be reverted if not filled
    - `additionalValidationContract`: string. Unused and deprecated
    - `additionalValidationData`: string. Unused and deprecated
    - `input` (required): object
      - `startAmount` (required): string. The intended execution quantity of tokens resulting from this swap
      - `maxAmount` (required): string
      - `adjustmentPerGweiBaseFee` (required): string
      - `curve` (required): object
        - `relativeBlocks`: array
        - `relativeAmounts`: array
      - `token` (required): string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `outputs` (required): array
      - items:
        - `startAmount` (required): string. The intended execution quantity of tokens resulting from this swap
        - `minAmount`: string. The minimum portion of the swap, stated in the base unit of the token, which will be output to the recipient
        - `recipient` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
        - `adjustmentPerGweiBaseFee` (required): string
        - `curve` (required): object
        - `token` (required): string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `cosigner`: string. The address of a cosigner who will run the auction and ensure the best executable price within the given parameters. Currently the cosigner is always Uniswap Labs
    - `startingBaseFee`: string
  - `input`: object
    - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `token`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `maximumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
  - `output`: object
    - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
    - `minimumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
  - `portionBips`: number. The portion of the swap that will be taken as a fee stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 87.5 for 0.875%). The fee will be taken from the output token
  - `portionAmount`: string. The portion of the swap that will be taken as a fee in the base units of the token. The fee will be taken from the output token
  - `portionRecipient`: string. The wallet address which will receive the fee
  - `quoteId`: string. A unique ID for the quote
  - `slippageTolerance`: number. The slippage tolerance as a percentage up to a maximum of two decimal places. For Uniswap Protocols (v2, v3, v4), the slippage tolerance is the maximum amount the price can change between the time the transaction is submitted and the time it is executed. The slippage tolerance is a percentage of the total value of the swap.  When submitting a quote, note that slippage tolerance works differently in UniswapX swaps where it does not set a limit on the Spread in an order. See [here](https://api-docs.uniswap.org/guides/faqs#why-do-uniswapx-quotes-have-more-slippage-than-the-tolerance-i-set) for more information.  Note that if the trade type is `EXACT_INPUT`, then the slippage is in terms of the output token. If the trade type is `EXACT_OUTPUT`, then the slippage is in terms of the input token.  When submitting a request, `slippageTolerance` may not be set when `autoSlippage` is defined. One of `slippageTolerance` or `autoSlippage` must be defined
  - `deadlineBufferSecs`: number
  - `classicGasUseEstimateUSD`: string. The gas fee you would pay if you opted for a CLASSIC swap over a Uniswap X order in terms of USD
  - `expectedAmountIn`: string
  - `expectedAmountOut`: string
  - `aggregatedOutputs`: array
    - items:
      - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
      - `bps`: number. The portion of the swap stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 12.5)
      - `minAmount`: string. The minimum portion of the swap, stated in the base unit of the token, which will be output to the recipient
      - `fee`: string = `INTEGRATOR`. Set to INTEGRATOR when this output is an integrator fee (as specified by the `integratorFees` array in the /quote request); omitted for the core output of the swap
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
- oneOf: `UniswapX Priority Quote` object
  - `priceDifference`: number. The expected value lost versus frictionless execution at current prices, as a percent between -100 and 100. Negative values indicate price improvement. For UniswapX orders this prefers USD parity, computed as 1 - (outputUSD + classicGasUseEstimateUSD) / inputUSD over the auction start amounts (the gas estimate is added back because the filler's gas is baked into the output), and falls back to comparing the execution price against the mid price implied by the classic quote (its execution price divided by 1 - priceImpact). Absent when neither source is available
  - `encodedOrder` (required): string. An encoded copy of the order details which will be submitted to the filler network along with the signed permit
  - `orderId` (required): string. A unique ID for the order. Used to track the order's status
  - `orderInfo` (required): object
    - `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `nonce` (required): string. A unique nonce for this order
    - `reactor` (required): string. The address of a contract which will be used to facilitate the swap
    - `swapper` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
    - `deadline` (required): number. The unix timestamp at which the order will be reverted if not filled
    - `additionalValidationContract`: string. Unused and deprecated
    - `additionalValidationData`: string. Unused and deprecated
    - `auctionStartBlock` (required): string
    - `baselinePriorityFeeWei` (required): string
    - `input` (required): object
      - `amount` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - `token` (required): string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `mpsPerPriorityFeeWei` (required): string
    - `outputs` (required): array
      - items:
        - `amount` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
        - `token` (required): string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
        - `recipient` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
        - `mpsPerPriorityFeeWei` (required): string. The scaling factor of the priority fee based on the output token amount
    - `cosigner` (required): string. The address of a cosigner who will run the auction and ensure the best executable price within the given parameters. Currently the cosigner is always Uniswap Labs
  - `input`: object
    - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `token`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `maximumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
  - `output`: object
    - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
    - `minimumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
  - `portionBips`: number. The portion of the swap that will be taken as a fee stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 87.5 for 0.875%). The fee will be taken from the output token
  - `portionAmount`: string. The portion of the swap that will be taken as a fee in the base units of the token. The fee will be taken from the output token
  - `portionRecipient`: string. The wallet address which will receive the fee
  - `quoteId`: string. A unique ID for the quote
  - `slippageTolerance`: number. The slippage tolerance as a percentage up to a maximum of two decimal places. For Uniswap Protocols (v2, v3, v4), the slippage tolerance is the maximum amount the price can change between the time the transaction is submitted and the time it is executed. The slippage tolerance is a percentage of the total value of the swap.  When submitting a quote, note that slippage tolerance works differently in UniswapX swaps where it does not set a limit on the Spread in an order. See [here](https://api-docs.uniswap.org/guides/faqs#why-do-uniswapx-quotes-have-more-slippage-than-the-tolerance-i-set) for more information.  Note that if the trade type is `EXACT_INPUT`, then the slippage is in terms of the output token. If the trade type is `EXACT_OUTPUT`, then the slippage is in terms of the input token.  When submitting a request, `slippageTolerance` may not be set when `autoSlippage` is defined. One of `slippageTolerance` or `autoSlippage` must be defined
  - `deadlineBufferSecs`: number
  - `classicGasUseEstimateUSD`: string. The gas fee you would pay if you opted for a CLASSIC swap over a Uniswap X order in terms of USD
  - `expectedAmountIn`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
  - `expectedAmountOut`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
  - `aggregatedOutputs`: array
    - items:
      - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
      - `bps`: number. The portion of the swap stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 12.5)
      - `minAmount`: string. The minimum portion of the swap, stated in the base unit of the token, which will be output to the recipient
      - `fee`: string = `INTEGRATOR`. Set to INTEGRATOR when this output is an integrator fee (as specified by the `integratorFees` array in the /quote request); omitted for the core output of the swap
- oneOf: `Chained Quote` object
  - `priceDifference`: number. The expected value lost versus frictionless execution at current prices, as a percent between -100 and 100. Negative values indicate price improvement. For chained trades this compounds the per-step values multiplicatively as 1 - product of (1 - stepValue/100) over the value-moving steps. Absent if any of those steps is missing its value
  - `swapper` (required): string. The wallet address which will be used to send the token
  - `input` (required): object
    - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `token`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `maximumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
  - `output` (required): object
    - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
    - `minimumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
  - `tokenInChainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `tokenOutChainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `tradeType` (required): string = `EXACT_INPUT`, `EXACT_OUTPUT`. The handling of the `amount` field. `EXACT_INPUT` means the requester will send the specified `amount` of input tokens and get a quote with a variable quantity of output tokens. `EXACT_OUTPUT` means the requester will receive the specified `amount` of output tokens and get a quote with a variable quantity of input tokens
  - `quoteId` (required): string. A unique ID for the quote
  - `gasEstimates`: array. Gas estimates for each step in the chained flow
    - items:
  - `timeEstimateMs`: number. Estimated time in milliseconds to complete the entire chained flow
  - `gasUseEstimate`: string. The maximum units of gas that will be consumed by this transaction
  - `gasFeeUSD`: string. The total estimated gas cost of this transaction (eg. `gasLimit` multiplied by `maxFeePerGas`) denominated in USDC
  - `gasFeeQuote`: string. The total estimated gas cost of this transaction (eg. gasLimit multiplied by maxFeePerGas) in the quoted currency (e.g. output token) in the base units of the quoted currency
  - `gasPrice`: string. The cost per unit of gas
  - `maxFeePerGas`: string. The sum of the base fee and priority fee. Subtracting `maxPriorityFeePerGas` from this value will yield the base fee to be paid for this transaction
  - `maxPriorityFeePerGas`: string. The maximum tip to the block builder. Adjusted based upon the urgency specified in the request
  - `gasFee`: string. The total estimated gas cost of this transaction (eg. `gasLimit` multiplied by `maxFeePerGas`) in the base unit of the chain
  - `protocols`: array. The protocols to use for the swap/order. If the `protocols` field is defined, then you can only set the `routingPreference` to `BEST_PRICE`. Note that the value `UNISWAPX` is deprecated and will be removed in a future release
    - items:
      - enum: `V2`, `V3`, `V4`, `UNISWAPX`, `UNISWAPX_V2`, `UNISWAPX_V3`, `UNISWAPX_LATEST`
  - `hooksOptions`: string = `V4_HOOKS_INCLUSIVE`, `V4_HOOKS_ONLY`, `V4_NO_HOOKS`. The hook options to use for V4 pool quotes. `V4_HOOKS_INCLUSIVE` will get quotes for V4 pools with or without hooks. `V4_HOOKS_ONLY` will only get quotes for V4 pools with hooks. `V4_NO_HOOKS` will only get quotes for V4 pools without hooks. Defaults to `V4_HOOKS_INCLUSIVE` if `V4` is included in `protocols` and `hookOptions` is not set. This field is ignored if `V4` is not passed in `protocols`
  - `gasStrategies` (required): array. Gas strategies for the chained flow
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
  - `steps`: array. Truncated plan steps for the chained transaction flow
    - items:
      - `priceDifference`: number. The expected value lost versus frictionless execution at current prices, as a percent between -100 and 100. Negative values indicate price improvement. The value for this step alone, computed according to the step's order type; the chained quote's top-level value compounds these
      - `stepType` (required): string = `DUTCH_LIMIT`, `CLASSIC`, `DUTCH_V2`, `LIMIT_ORDER`, `WRAP`, `UNWRAP`, `BRIDGE`, `PRIORITY`, `DUTCH_V3`, `QUICKROUTE`, `CHAINED`, `VAULT_DEPOSIT`, `VAULT_WITHDRAW`, `APPROVAL_TXN`, `APPROVAL_PERMIT`, `RESET_APPROVAL_TXN`. The type of step in a plan, including swap types and approval types
      - `tokenIn`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `tokenInChainId`: number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `tokenOut`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `tokenOutChainId`: number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `slippage`: number. The slippage tolerance as a percentage up to a maximum of two decimal places. For Uniswap Protocols (v2, v3, v4), the slippage tolerance is the maximum amount the price can change between the time the transaction is submitted and the time it is executed. The slippage tolerance is a percentage of the total value of the swap.  When submitting a quote, note that slippage tolerance works differently in UniswapX swaps where it does not set a limit on the Spread in an order. See [here](https://api-docs.uniswap.org/guides/faqs#why-do-uniswapx-quotes-have-more-slippage-than-the-tolerance-i-set) for more information.  Note that if the trade type is `EXACT_INPUT`, then the slippage is in terms of the output token. If the trade type is `EXACT_OUTPUT`, then the slippage is in terms of the input token.  When submitting a request, `slippageTolerance` may not be set when `autoSlippage` is defined. One of `slippageTolerance` or `autoSlippage` must be defined
  - `slippageTolerance`: number. The slippage tolerance as a percentage up to a maximum of two decimal places. For Uniswap Protocols (v2, v3, v4), the slippage tolerance is the maximum amount the price can change between the time the transaction is submitted and the time it is executed. The slippage tolerance is a percentage of the total value of the swap.  When submitting a quote, note that slippage tolerance works differently in UniswapX swaps where it does not set a limit on the Spread in an order. See [here](https://api-docs.uniswap.org/guides/faqs#why-do-uniswapx-quotes-have-more-slippage-than-the-tolerance-i-set) for more information.  Note that if the trade type is `EXACT_INPUT`, then the slippage is in terms of the output token. If the trade type is `EXACT_OUTPUT`, then the slippage is in terms of the input token.  When submitting a request, `slippageTolerance` may not be set when `autoSlippage` is defined. One of `slippageTolerance` or `autoSlippage` must be defined
  - `autoSlippage`: string = `DEFAULT`. The auto slippage strategy to employ. For Uniswap Protocols (v2, v3, v4) the auto slippage will be automatically calculated when this field is set to `DEFAULT`. Auto slippage cannot be calculated for UniswapX swaps.  Note that if the trade type is `EXACT_INPUT`, then the slippage is in terms of the output token. If the trade type is `EXACT_OUTPUT`, then the slippage is in terms of the input token.  When submitting a request, `autoSlippage` may not be set when `slippageTolerance` is defined. One of `slippageTolerance` or `autoSlippage` must be defined
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
        - `estimatedSharesOut` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - oneOf: `` object
        - `type` (required): string = `EXACT_ASSETS_WITHDRAW`
        - `requestedAssetsOut` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
        - `estimatedSharesIn` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - oneOf: `` object
        - `type` (required): string = `MAX_SHARES_WITHDRAW`
        - `maxRedeemableSharesIn` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
        - `previewAssetsOut` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
  - `earnPreview`: object. Action-specific preview amounts computed while normalizing an Earn intent
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

## LPToken

A token with its address and amount, used in LP operations.

- `tokenAddress` (required): string
- `amount` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0

## LPAction

The LP operation that the approval is needed for.

- enum: `CREATE`, `INCREASE`, `DECREASE`, `MIGRATE`

## GasUrgency

The urgency level for gas price estimation. Higher urgency results in higher gas price and faster transaction inclusion. Defaults to URGENT if not provided.

- enum: `NORMAL`, `FAST`, `URGENT`

## V2PoolParameters

Parameters identifying a V2 pool.

- `token0Address` (required): string
- `token1Address` (required): string
- `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)

## ApprovalTransactionRequest

An approval transaction with metadata about whether it is a cancellation and which LP action it supports.

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

## CreatePositionExistingPoolParameters

Parameters for creating a position in an existing pool.

- `token0Address` (required): string
- `token1Address` (required): string
- `poolReference` (required): string. The pool address (V3) or pool ID (V4) identifying the existing pool

## CreatePoolParameters

Parameters for creating a new pool along with a position.

- `token0Address` (required): string
- `token1Address` (required): string
- `fee` (required): integer. The pool fee in basis points
- `tickSpacing` (required): integer. The tick spacing for the pool
- `hooks`: object. Optional hooks contract address (V4 only)
- `initialPrice` (required): string. The initial price of the pool (token1 per token0)

## PositionPriceBounds

Price bounds for a concentrated liquidity position.

- `minPrice` (required): string. The minimum price (token1 per token0) for the position range
- `maxPrice` (required): string. The maximum price (token1 per token0) for the position range

## PositionTickBounds

Tick bounds for a concentrated liquidity position.

- `tickLower` (required): integer. The lower tick of the position range
- `tickUpper` (required): integer. The upper tick of the position range

## CreateToken

A token address and amount used in position creation.

- `tokenAddress` (required): string
- `amount` (required): string. The token amount in raw (base unit) format

## LPApprovalRequest



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

## LPApprovalResponse



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

## ApprovalRequest



- `walletAddress` (required): string. The wallet address which will be used to send the token
- `token` (required): string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `amount` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `urgency`: object. The urgency impacts the estimated gas price of the transaction. The higher the urgency, the higher the gas price, and the faster the transaction is likely to be selected from the mempool. Send the bare string form (e.g. `"normal"`) for the common case, or the object form `{ level, overrides }` to supply caller caps for `maxPriorityFeePerGas`, `maxFeePerGas`, and `gasLimit`
  - oneOf: `` string
    - enum: `normal`, `fast`, `urgent`
  - oneOf: `` object
    - `level` (required): string = `normal`, `fast`, `urgent`
    - `overrides`: object. Caller-supplied caps applied on top of the gas service's computed quote. All fields are absolute wei (decimal string). `maxPriorityFeePerGas` and `maxFeePerGas` are treated as caps - they lower the quote, never raise it. `gasLimit`, if set, replaces the limit calculation entirely
      - `maxPriorityFeePerGas`: string. Maximum priority fee in wei (decimal string)
      - `maxFeePerGas`: string. Maximum total fee per gas in wei (decimal string)
      - `gasLimit`: string. Gas limit cap (in gas units, decimal string)
- `includeGasInfo`: boolean. If set to `true`, the response will include the estimated gas fee for the proposed transaction
- `tokenOut`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `tokenOutChainId`: number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)

## ApprovalResponse



- `requestId` (required): string. A unique ID for the request
- `approval` (required): object
  - `to` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
  - `from` (required): string. The wallet address which will be used to send the token
  - `data` (required): string. The calldata for the transaction
  - `value` (required): string. The quantity of ETH tokens approved for spending by the transaction, denominated in wei. Note that by default Uniswap Labs sets this to the maximum approvable spend
  - `gasLimit`: string. The maximum units of gas that will be consumed by this transaction
  - `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `maxFeePerGas`: string. The sum of the base fee and priority fee. Subtracting `maxPriorityFeePerGas` from this value will yield the base fee to be paid for this transaction
  - `maxPriorityFeePerGas`: string. The maximum tip to the block builder. Adjusted based upon the urgency specified in the request
  - `gasPrice`: string. The cost per unit of gas
- `cancel` (required): object
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
- `cancelGasFee`: string. The total estimated gas cost of this transaction (eg. `gasLimit` multiplied by `maxFeePerGas`) in the base unit of the chain

## PermissionsRequest



- `walletAddress` (required): string. The wallet address which will be used to send the token
- `tokens` (required): array. Tokens to check permissions for. Maximum of 2 per request
  - items:
- `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)

## PermissionsResponse



- `requestId` (required): string. A unique ID for the request
- `results` (required): array
  - items:
    - `token` (required): string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `isPermissioned` (required): boolean. Whether the token requires a permissioned adapter to trade
    - `isAllowlisted`: boolean. Only provided when isPermissioned is true. Indicates whether the wallet is allowed to swap this token
    - `adapterTokenAddress`: string. Address of the permissioned adapter token to use in place of the underlying token. Always provided when isPermissioned is true
    - `kycUrl`: string. URL the wallet holder must visit to complete KYC and become allowlisted. Always provided when isAllowlisted is false
    - `issuer`: string. KYC provider display name (e.g. "Superstate"). Always provided when isPermissioned is true

## PermissionsResult



- `token` (required): string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `isPermissioned` (required): boolean. Whether the token requires a permissioned adapter to trade
- `isAllowlisted`: boolean. Only provided when isPermissioned is true. Indicates whether the wallet is allowed to swap this token
- `adapterTokenAddress`: string. Address of the permissioned adapter token to use in place of the underlying token. Always provided when isPermissioned is true
- `kycUrl`: string. URL the wallet holder must visit to complete KYC and become allowlisted. Always provided when isAllowlisted is false
- `issuer`: string. KYC provider display name (e.g. "Superstate"). Always provided when isPermissioned is true

## ClassicQuote



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
        - items:
      - `minHopPriceX36`: array
        - items:
    - oneOf: `` object
      - `type` (required): string = `V2_SWAP_EXACT_OUT`
      - `recipient` (required): string
      - `amountOut` (required): string
      - `amountInMax` (required): string
      - `path` (required): array
        - items:
      - `minHopPriceX36`: array
        - items:
    - oneOf: `` object
      - `type` (required): string = `V3_SWAP_EXACT_IN`
      - `recipient` (required): string
      - `amountIn` (required): string
      - `amountOutMin` (required): string
      - `path` (required): string. Hex-encoded packed V3 path (e.g. `0xa0b8...000bb8c02aaa...`)
      - `minHopPriceX36`: array
        - items:
    - oneOf: `` object
      - `type` (required): string = `V3_SWAP_EXACT_OUT`
      - `recipient` (required): string
      - `amountOut` (required): string
      - `amountInMax` (required): string
      - `path` (required): string. Hex-encoded packed V3 path (e.g. `0xa0b8...000bb8c02aaa...`)
      - `minHopPriceX36`: array
        - items:
    - oneOf: `` object
      - `type` (required): string = `V4_SWAP`
      - `v4Actions` (required): array
        - items:
          - oneOf: `` object
            - `action` (required): string = `SWAP_EXACT_IN`
            - `currencyIn` (required): string
            - `path` (required): array
            - `amountIn` (required): string
            - `amountOutMinimum` (required): string
            - `minHopPriceX36`: array
          - oneOf: `` object
            - `action` (required): string = `SWAP_EXACT_IN_SINGLE`
            - `poolKey` (required): object
            - `zeroForOne` (required): boolean
            - `amountIn` (required): string
            - `amountOutMinimum` (required): string
            - `hookData` (required): string
            - `minHopPriceX36`: string
          - oneOf: `` object
            - `action` (required): string = `SWAP_EXACT_OUT`
            - `currencyOut` (required): string
            - `path` (required): array
            - `amountOut` (required): string
            - `amountInMaximum` (required): string
            - `minHopPriceX36`: array
          - oneOf: `` object
            - `action` (required): string = `SWAP_EXACT_OUT_SINGLE`
            - `poolKey` (required): object
            - `zeroForOne` (required): boolean
            - `amountOut` (required): string
            - `amountInMaximum` (required): string
            - `hookData` (required): string
            - `minHopPriceX36`: string
          - oneOf: `` object
            - `action` (required): string = `SETTLE`
            - `currency` (required): string
            - `amount` (required): string
          - oneOf: `` object
            - `action` (required): string = `SETTLE_ALL`
            - `currency` (required): string
            - `maxAmount` (required): string
          - oneOf: `` object
            - `action` (required): string = `TAKE`
            - `currency` (required): string
            - `recipient` (required): string
            - `amount` (required): string
          - oneOf: `` object
            - `action` (required): string = `TAKE_ALL`
            - `currency` (required): string
            - `minAmount` (required): string
          - oneOf: `` object
            - `action` (required): string = `TAKE_PORTION`
            - `currency` (required): string
            - `recipient` (required): string
            - `bips` (required): string
    - oneOf: `` object
      - `type` (required): string = `WRAP_ETH`
      - `recipient` (required): string
      - `amount` (required): string
    - oneOf: `` object
      - `type` (required): string = `UNWRAP_WETH`
      - `recipient` (required): string
      - `amountMin` (required): string

## SwapStep

Universal Router swap step. Discriminated by the `type` field.

- oneOf: `` object
  - `type` (required): string = `V2_SWAP_EXACT_IN`
  - `recipient` (required): string
  - `amountIn` (required): string
  - `amountOutMin` (required): string
  - `path` (required): array
    - items:
  - `minHopPriceX36`: array
    - items:
- oneOf: `` object
  - `type` (required): string = `V2_SWAP_EXACT_OUT`
  - `recipient` (required): string
  - `amountOut` (required): string
  - `amountInMax` (required): string
  - `path` (required): array
    - items:
  - `minHopPriceX36`: array
    - items:
- oneOf: `` object
  - `type` (required): string = `V3_SWAP_EXACT_IN`
  - `recipient` (required): string
  - `amountIn` (required): string
  - `amountOutMin` (required): string
  - `path` (required): string. Hex-encoded packed V3 path (e.g. `0xa0b8...000bb8c02aaa...`)
  - `minHopPriceX36`: array
    - items:
- oneOf: `` object
  - `type` (required): string = `V3_SWAP_EXACT_OUT`
  - `recipient` (required): string
  - `amountOut` (required): string
  - `amountInMax` (required): string
  - `path` (required): string. Hex-encoded packed V3 path (e.g. `0xa0b8...000bb8c02aaa...`)
  - `minHopPriceX36`: array
    - items:
- oneOf: `` object
  - `type` (required): string = `V4_SWAP`
  - `v4Actions` (required): array
    - items:
      - oneOf: `` object
        - `action` (required): string = `SWAP_EXACT_IN`
        - `currencyIn` (required): string
        - `path` (required): array
        - `amountIn` (required): string
        - `amountOutMinimum` (required): string
        - `minHopPriceX36`: array
      - oneOf: `` object
        - `action` (required): string = `SWAP_EXACT_IN_SINGLE`
        - `poolKey` (required): object
        - `zeroForOne` (required): boolean
        - `amountIn` (required): string
        - `amountOutMinimum` (required): string
        - `hookData` (required): string
        - `minHopPriceX36`: string
      - oneOf: `` object
        - `action` (required): string = `SWAP_EXACT_OUT`
        - `currencyOut` (required): string
        - `path` (required): array
        - `amountOut` (required): string
        - `amountInMaximum` (required): string
        - `minHopPriceX36`: array
      - oneOf: `` object
        - `action` (required): string = `SWAP_EXACT_OUT_SINGLE`
        - `poolKey` (required): object
        - `zeroForOne` (required): boolean
        - `amountOut` (required): string
        - `amountInMaximum` (required): string
        - `hookData` (required): string
        - `minHopPriceX36`: string
      - oneOf: `` object
        - `action` (required): string = `SETTLE`
        - `currency` (required): string
        - `amount` (required): string
      - oneOf: `` object
        - `action` (required): string = `SETTLE_ALL`
        - `currency` (required): string
        - `maxAmount` (required): string
      - oneOf: `` object
        - `action` (required): string = `TAKE`
        - `currency` (required): string
        - `recipient` (required): string
        - `amount` (required): string
      - oneOf: `` object
        - `action` (required): string = `TAKE_ALL`
        - `currency` (required): string
        - `minAmount` (required): string
      - oneOf: `` object
        - `action` (required): string = `TAKE_PORTION`
        - `currency` (required): string
        - `recipient` (required): string
        - `bips` (required): string
- oneOf: `` object
  - `type` (required): string = `WRAP_ETH`
  - `recipient` (required): string
  - `amount` (required): string
- oneOf: `` object
  - `type` (required): string = `UNWRAP_WETH`
  - `recipient` (required): string
  - `amountMin` (required): string

## V2SwapExactInStep



- `type` (required): string = `V2_SWAP_EXACT_IN`
- `recipient` (required): string
- `amountIn` (required): string
- `amountOutMin` (required): string
- `path` (required): array
  - items:
- `minHopPriceX36`: array
  - items:

## V2SwapExactOutStep



- `type` (required): string = `V2_SWAP_EXACT_OUT`
- `recipient` (required): string
- `amountOut` (required): string
- `amountInMax` (required): string
- `path` (required): array
  - items:
- `minHopPriceX36`: array
  - items:

## V3SwapExactInStep



- `type` (required): string = `V3_SWAP_EXACT_IN`
- `recipient` (required): string
- `amountIn` (required): string
- `amountOutMin` (required): string
- `path` (required): string. Hex-encoded packed V3 path (e.g. `0xa0b8...000bb8c02aaa...`)
- `minHopPriceX36`: array
  - items:

## V3SwapExactOutStep



- `type` (required): string = `V3_SWAP_EXACT_OUT`
- `recipient` (required): string
- `amountOut` (required): string
- `amountInMax` (required): string
- `path` (required): string. Hex-encoded packed V3 path (e.g. `0xa0b8...000bb8c02aaa...`)
- `minHopPriceX36`: array
  - items:

## V4SwapStep



- `type` (required): string = `V4_SWAP`
- `v4Actions` (required): array
  - items:
    - oneOf: `` object
      - `action` (required): string = `SWAP_EXACT_IN`
      - `currencyIn` (required): string
      - `path` (required): array
        - items:
          - `intermediateCurrency` (required): string
          - `fee` (required): integer
          - `tickSpacing` (required): integer
          - `hooks` (required): string
          - `hookData` (required): string
      - `amountIn` (required): string
      - `amountOutMinimum` (required): string
      - `minHopPriceX36`: array
        - items:
    - oneOf: `` object
      - `action` (required): string = `SWAP_EXACT_IN_SINGLE`
      - `poolKey` (required): object
        - `currency0` (required): string
        - `currency1` (required): string
        - `fee` (required): integer
        - `tickSpacing` (required): integer
        - `hooks` (required): string
      - `zeroForOne` (required): boolean
      - `amountIn` (required): string
      - `amountOutMinimum` (required): string
      - `hookData` (required): string
      - `minHopPriceX36`: string
    - oneOf: `` object
      - `action` (required): string = `SWAP_EXACT_OUT`
      - `currencyOut` (required): string
      - `path` (required): array
        - items:
          - `intermediateCurrency` (required): string
          - `fee` (required): integer
          - `tickSpacing` (required): integer
          - `hooks` (required): string
          - `hookData` (required): string
      - `amountOut` (required): string
      - `amountInMaximum` (required): string
      - `minHopPriceX36`: array
        - items:
    - oneOf: `` object
      - `action` (required): string = `SWAP_EXACT_OUT_SINGLE`
      - `poolKey` (required): object
        - `currency0` (required): string
        - `currency1` (required): string
        - `fee` (required): integer
        - `tickSpacing` (required): integer
        - `hooks` (required): string
      - `zeroForOne` (required): boolean
      - `amountOut` (required): string
      - `amountInMaximum` (required): string
      - `hookData` (required): string
      - `minHopPriceX36`: string
    - oneOf: `` object
      - `action` (required): string = `SETTLE`
      - `currency` (required): string
      - `amount` (required): string
    - oneOf: `` object
      - `action` (required): string = `SETTLE_ALL`
      - `currency` (required): string
      - `maxAmount` (required): string
    - oneOf: `` object
      - `action` (required): string = `TAKE`
      - `currency` (required): string
      - `recipient` (required): string
      - `amount` (required): string
    - oneOf: `` object
      - `action` (required): string = `TAKE_ALL`
      - `currency` (required): string
      - `minAmount` (required): string
    - oneOf: `` object
      - `action` (required): string = `TAKE_PORTION`
      - `currency` (required): string
      - `recipient` (required): string
      - `bips` (required): string

## WrapEthStep



- `type` (required): string = `WRAP_ETH`
- `recipient` (required): string
- `amount` (required): string

## UnwrapWethStep



- `type` (required): string = `UNWRAP_WETH`
- `recipient` (required): string
- `amountMin` (required): string

## V4Action

V4 action. Discriminated by the `action` field.

- oneOf: `` object
  - `action` (required): string = `SWAP_EXACT_IN`
  - `currencyIn` (required): string
  - `path` (required): array
    - items:
      - `intermediateCurrency` (required): string
      - `fee` (required): integer
      - `tickSpacing` (required): integer
      - `hooks` (required): string
      - `hookData` (required): string
  - `amountIn` (required): string
  - `amountOutMinimum` (required): string
  - `minHopPriceX36`: array
    - items:
- oneOf: `` object
  - `action` (required): string = `SWAP_EXACT_IN_SINGLE`
  - `poolKey` (required): object
    - `currency0` (required): string
    - `currency1` (required): string
    - `fee` (required): integer
    - `tickSpacing` (required): integer
    - `hooks` (required): string
  - `zeroForOne` (required): boolean
  - `amountIn` (required): string
  - `amountOutMinimum` (required): string
  - `hookData` (required): string
  - `minHopPriceX36`: string
- oneOf: `` object
  - `action` (required): string = `SWAP_EXACT_OUT`
  - `currencyOut` (required): string
  - `path` (required): array
    - items:
      - `intermediateCurrency` (required): string
      - `fee` (required): integer
      - `tickSpacing` (required): integer
      - `hooks` (required): string
      - `hookData` (required): string
  - `amountOut` (required): string
  - `amountInMaximum` (required): string
  - `minHopPriceX36`: array
    - items:
- oneOf: `` object
  - `action` (required): string = `SWAP_EXACT_OUT_SINGLE`
  - `poolKey` (required): object
    - `currency0` (required): string
    - `currency1` (required): string
    - `fee` (required): integer
    - `tickSpacing` (required): integer
    - `hooks` (required): string
  - `zeroForOne` (required): boolean
  - `amountOut` (required): string
  - `amountInMaximum` (required): string
  - `hookData` (required): string
  - `minHopPriceX36`: string
- oneOf: `` object
  - `action` (required): string = `SETTLE`
  - `currency` (required): string
  - `amount` (required): string
- oneOf: `` object
  - `action` (required): string = `SETTLE_ALL`
  - `currency` (required): string
  - `maxAmount` (required): string
- oneOf: `` object
  - `action` (required): string = `TAKE`
  - `currency` (required): string
  - `recipient` (required): string
  - `amount` (required): string
- oneOf: `` object
  - `action` (required): string = `TAKE_ALL`
  - `currency` (required): string
  - `minAmount` (required): string
- oneOf: `` object
  - `action` (required): string = `TAKE_PORTION`
  - `currency` (required): string
  - `recipient` (required): string
  - `bips` (required): string

## V4SwapExactIn



- `action` (required): string = `SWAP_EXACT_IN`
- `currencyIn` (required): string
- `path` (required): array
  - items:
    - `intermediateCurrency` (required): string
    - `fee` (required): integer
    - `tickSpacing` (required): integer
    - `hooks` (required): string
    - `hookData` (required): string
- `amountIn` (required): string
- `amountOutMinimum` (required): string
- `minHopPriceX36`: array
  - items:

## V4SwapExactInSingle



- `action` (required): string = `SWAP_EXACT_IN_SINGLE`
- `poolKey` (required): object
  - `currency0` (required): string
  - `currency1` (required): string
  - `fee` (required): integer
  - `tickSpacing` (required): integer
  - `hooks` (required): string
- `zeroForOne` (required): boolean
- `amountIn` (required): string
- `amountOutMinimum` (required): string
- `hookData` (required): string
- `minHopPriceX36`: string

## V4SwapExactOut



- `action` (required): string = `SWAP_EXACT_OUT`
- `currencyOut` (required): string
- `path` (required): array
  - items:
    - `intermediateCurrency` (required): string
    - `fee` (required): integer
    - `tickSpacing` (required): integer
    - `hooks` (required): string
    - `hookData` (required): string
- `amountOut` (required): string
- `amountInMaximum` (required): string
- `minHopPriceX36`: array
  - items:

## V4SwapExactOutSingle



- `action` (required): string = `SWAP_EXACT_OUT_SINGLE`
- `poolKey` (required): object
  - `currency0` (required): string
  - `currency1` (required): string
  - `fee` (required): integer
  - `tickSpacing` (required): integer
  - `hooks` (required): string
- `zeroForOne` (required): boolean
- `amountOut` (required): string
- `amountInMaximum` (required): string
- `hookData` (required): string
- `minHopPriceX36`: string

## V4Settle



- `action` (required): string = `SETTLE`
- `currency` (required): string
- `amount` (required): string

## V4SettleAll



- `action` (required): string = `SETTLE_ALL`
- `currency` (required): string
- `maxAmount` (required): string

## V4Take



- `action` (required): string = `TAKE`
- `currency` (required): string
- `recipient` (required): string
- `amount` (required): string

## V4TakeAll



- `action` (required): string = `TAKE_ALL`
- `currency` (required): string
- `minAmount` (required): string

## V4TakePortion



- `action` (required): string = `TAKE_PORTION`
- `currency` (required): string
- `recipient` (required): string
- `bips` (required): string

## SwapPoolKey



- `currency0` (required): string
- `currency1` (required): string
- `fee` (required): integer
- `tickSpacing` (required): integer
- `hooks` (required): string

## SwapPathKey



- `intermediateCurrency` (required): string
- `fee` (required): integer
- `tickSpacing` (required): integer
- `hooks` (required): string
- `hookData` (required): string

## WrapUnwrapQuote



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

## TokenInRoute



- `address`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `chainId`: number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `symbol`: string. The symbol of the token
- `decimals`: string. The number of decimals supported by the token. This number is used to convert token amounts to the token's common representation
- `buyFeeBps`: string. A fee charged by the token specified in basis points. Field is not present if the token does not charge a fee
- `sellFeeBps`: string. A fee charged by the token specified in basis points. Field is not present if the token does not charge a fee

## V2Reserve

The remaining reserve of this token in the pool.

- `token`: object
  - `address`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `chainId`: number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `symbol`: string. The symbol of the token
  - `decimals`: string. The number of decimals supported by the token. This number is used to convert token amounts to the token's common representation
  - `buyFeeBps`: string. A fee charged by the token specified in basis points. Field is not present if the token does not charge a fee
  - `sellFeeBps`: string. A fee charged by the token specified in basis points. Field is not present if the token does not charge a fee
- `quotient`: string. The quantity of this token remaining in the pool, specified in the base units of the token

## V2PoolInRoute



- `type`: string
- `address`: string. The address of a contract which will be used to facilitate the swap
- `tokenIn`: object
  - `address`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `chainId`: number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `symbol`: string. The symbol of the token
  - `decimals`: string. The number of decimals supported by the token. This number is used to convert token amounts to the token's common representation
  - `buyFeeBps`: string. A fee charged by the token specified in basis points. Field is not present if the token does not charge a fee
  - `sellFeeBps`: string. A fee charged by the token specified in basis points. Field is not present if the token does not charge a fee
- `tokenOut`: object
  - `address`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `chainId`: number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `symbol`: string. The symbol of the token
  - `decimals`: string. The number of decimals supported by the token. This number is used to convert token amounts to the token's common representation
  - `buyFeeBps`: string. A fee charged by the token specified in basis points. Field is not present if the token does not charge a fee
  - `sellFeeBps`: string. A fee charged by the token specified in basis points. Field is not present if the token does not charge a fee
- `reserve0`: object. The remaining reserve of this token in the pool
  - `token`: object
    - `address`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `chainId`: number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `symbol`: string. The symbol of the token
    - `decimals`: string. The number of decimals supported by the token. This number is used to convert token amounts to the token's common representation
    - `buyFeeBps`: string. A fee charged by the token specified in basis points. Field is not present if the token does not charge a fee
    - `sellFeeBps`: string. A fee charged by the token specified in basis points. Field is not present if the token does not charge a fee
  - `quotient`: string. The quantity of this token remaining in the pool, specified in the base units of the token
- `reserve1`: object. The remaining reserve of this token in the pool
  - `token`: object
  - `quotient`: string. The quantity of this token remaining in the pool, specified in the base units of the token
- `amountIn`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `amountOut`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0

## V3PoolInRoute



- `type`: string
- `address`: string. The address of a contract which will be used to facilitate the swap
- `tokenIn`: object
  - `address`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `chainId`: number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `symbol`: string. The symbol of the token
  - `decimals`: string. The number of decimals supported by the token. This number is used to convert token amounts to the token's common representation
  - `buyFeeBps`: string. A fee charged by the token specified in basis points. Field is not present if the token does not charge a fee
  - `sellFeeBps`: string. A fee charged by the token specified in basis points. Field is not present if the token does not charge a fee
- `tokenOut`: object
  - `address`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `chainId`: number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `symbol`: string. The symbol of the token
  - `decimals`: string. The number of decimals supported by the token. This number is used to convert token amounts to the token's common representation
  - `buyFeeBps`: string. A fee charged by the token specified in basis points. Field is not present if the token does not charge a fee
  - `sellFeeBps`: string. A fee charged by the token specified in basis points. Field is not present if the token does not charge a fee
- `sqrtRatioX96`: string. The square root of the ratio of the token0 and token1 in the pool, as a Q64.64 number. For more information see the [Uniswap V3 Whitepaper](https://app.uniswap.org/whitepaper-v3.pdf)
- `liquidity`: string. The amount of liquidity in the pool at a given tick. For more information see the [Uniswap V3 Whitepaper](https://app.uniswap.org/whitepaper-v3.pdf)
- `tickCurrent`: string. The current tick of the pool. For more information see the [Uniswap V3 Whitepaper](https://app.uniswap.org/whitepaper-v3.pdf)
- `fee`: string. The fee of the pool in basis points
- `amountIn`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `amountOut`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0

## V4PoolInRoute



- `type` (required): string
- `address` (required): string. The address of a contract which will be used to facilitate the swap
- `tokenIn` (required): object
  - `address`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `chainId`: number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `symbol`: string. The symbol of the token
  - `decimals`: string. The number of decimals supported by the token. This number is used to convert token amounts to the token's common representation
  - `buyFeeBps`: string. A fee charged by the token specified in basis points. Field is not present if the token does not charge a fee
  - `sellFeeBps`: string. A fee charged by the token specified in basis points. Field is not present if the token does not charge a fee
- `tokenOut` (required): object
  - `address`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `chainId`: number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `symbol`: string. The symbol of the token
  - `decimals`: string. The number of decimals supported by the token. This number is used to convert token amounts to the token's common representation
  - `buyFeeBps`: string. A fee charged by the token specified in basis points. Field is not present if the token does not charge a fee
  - `sellFeeBps`: string. A fee charged by the token specified in basis points. Field is not present if the token does not charge a fee
- `sqrtRatioX96` (required): string. The square root of the ratio of the token0 and token1 in the pool, as a Q64.64 number. For more information see the [Uniswap V3 Whitepaper](https://app.uniswap.org/whitepaper-v3.pdf)
- `liquidity` (required): string. The amount of liquidity in the pool at a given tick. For more information see the [Uniswap V3 Whitepaper](https://app.uniswap.org/whitepaper-v3.pdf)
- `tickCurrent` (required): string. The current tick of the pool. For more information see the [Uniswap V3 Whitepaper](https://app.uniswap.org/whitepaper-v3.pdf)
- `fee` (required): string. The fee of the pool in basis points
- `tickSpacing` (required): number. The width of ticks in this pool (e.g. the price range between two ticks) specified in basis points. For more information see the [Uniswap V3 Whitepaper](https://app.uniswap.org/whitepaper-v3.pdf)
- `hooks` (required): string. The address of the hook for the pool, if any. If the pool has no hook, this field will be the null address (e.g. 0x0000000000000000000000000000000000000000)
- `amountIn`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `amountOut`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0

## TransactionHash

The unique hash of the transaction.


## QuoteInput



- `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `token`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `maximumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0

## QuoteOutput



- `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
- `minimumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0

## RequestId

A unique ID for the request.


## PermitAmount

For Uniswap Protocols (v2, v3, v4) swaps, specify the input token spend allowance (e.g. quantity) to be set in the permit. `FULL` can be used to specify an unlimited token quantity, and may prevent the wallet from needing to sign another permit for the same token in the future. `EXACT` can be used to specify the exact input token quantity for this request. Defaults to `FULL`.

- enum: `FULL`, `EXACT`

## IntegratorFee

A fee configuration specifying the fee amount in basis points and the recipient address.

- `bips` (required): number. Fee amount in basis points (1 bip = 0.01%). Must be greater than 0 and at most 500
- `recipient` (required): string. Ethereum address that receives the fee

## SpreadOptimization

For UniswapX swaps, when set to `EXECUTION`, quotes optimize for looser spreads at higher fill rates. When set to `PRICE`, quotes optimize for tighter spreads at lower fill rates. This field is not applicable to Uniswap Protocols (v2, v3, v4), bridging, or wrapping/unwrapping and will be ignored if set.

- enum: `EXECUTION`, `PRICE`

## AutoSlippage

The auto slippage strategy to employ. For Uniswap Protocols (v2, v3, v4) the auto slippage will be automatically calculated when this field is set to `DEFAULT`. Auto slippage cannot be calculated for UniswapX swaps.

Note that if the trade type is `EXACT_INPUT`, then the slippage is in terms of the output token. If the trade type is `EXACT_OUTPUT`, then the slippage is in terms of the input token.

When submitting a request, `autoSlippage` may not be set when `slippageTolerance` is defined. One of `slippageTolerance` or `autoSlippage` must be defined.

- enum: `DEFAULT`

## RoutingPreference

The `routingPreference` specifies the preferred strategy to determine the quote. If the `routingPreference` is `BEST_PRICE`, then the quote will propose a route through the specified whitelisted protocols (or all, if none are specified) that provides the best price. When the `routingPreference` is `FASTEST`, the quote will propose the first route which is found to complete the swap.

- enum: `BEST_PRICE`, `FASTEST`

## ProtocolItems

The protocol to use for the swap/order. Use `UNISWAPX_LATEST` to route through the latest UniswapX protocol supported on the request chain.

- enum: `V2`, `V3`, `V4`, `UNISWAPX`, `UNISWAPX_V2`, `UNISWAPX_V3`, `UNISWAPX_LATEST`

## ProtocolItemsAmm

The protocol of the pool.

- enum: `V2`, `V3`, `V4`

## encodedOrder

An encoded copy of the order details which will be submitted to the filler network along with the signed permit.


## orderId

A unique ID for the order. Used to track the order's status.


## quoteId

A unique ID for the quote.


## portionBips

The portion of the swap that will be taken as a fee stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 87.5 for 0.875%). The fee will be taken from the output token.


## portionAmount

The portion of the swap that will be taken as a fee in the base units of the token. The fee will be taken from the output token.


## portionAmountReceiverAddress

The wallet address which will receive the fee.


## poolFee

The fee of the pool in basis points.


## additionalValidationContract

Unused and deprecated.


## additionalValidationData

Unused and deprecated.


## deadline

The unix timestamp at which the order will be reverted if not filled.


## nonce

A unique nonce for this order.


## sqrtRatioX96

The square root of the ratio of the token0 and token1 in the pool, as a Q64.64 number. For more information see the [Uniswap V3 Whitepaper](https://app.uniswap.org/whitepaper-v3.pdf).


## liquidity

The amount of liquidity in the pool at a given tick. For more information see the [Uniswap V3 Whitepaper](https://app.uniswap.org/whitepaper-v3.pdf).


## tickCurrent

The current tick of the pool. For more information see the [Uniswap V3 Whitepaper](https://app.uniswap.org/whitepaper-v3.pdf).


## lpTickCurrent

The current tick of the pool. For more information see the [Uniswap V3 Whitepaper](https://app.uniswap.org/whitepaper-v3.pdf).


## tickSpacing

The width of ticks in this pool (e.g. the price range between two ticks) specified in basis points. For more information see the [Uniswap V3 Whitepaper](https://app.uniswap.org/whitepaper-v3.pdf).


## isSpam

Whether the token is considered a spam token.


## startAmount

The intended execution quantity of tokens resulting from this swap.


## endAmount

The worst case quantity of tokens resulting from this swap.


## minAmount

The minimum portion of the swap, stated in the base unit of the token, which will be output to the recipient.


## bps

The portion of the swap stated in basis points. Fractional basis points are supported with up to two decimal places (e.g. 12.5).


## bpsFee

A fee charged by the token specified in basis points. Field is not present if the token does not charge a fee.


## TransactionRequest



- `to` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
- `from` (required): string. The wallet address which will be used to send the token
- `data` (required): string. The calldata for the transaction
- `value` (required): string. The quantity of ETH tokens approved for spending by the transaction, denominated in wei. Note that by default Uniswap Labs sets this to the maximum approvable spend
- `gasLimit`: string. The maximum units of gas that will be consumed by this transaction
- `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `maxFeePerGas`: string. The sum of the base fee and priority fee. Subtracting `maxPriorityFeePerGas` from this value will yield the base fee to be paid for this transaction
- `maxPriorityFeePerGas`: string. The maximum tip to the block builder. Adjusted based upon the urgency specified in the request
- `gasPrice`: string. The cost per unit of gas

## TransactionRequest5792



- `to` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
- `data` (required): string. The calldata for the transaction
- `value` (required): string. The quantity of ETH tokens approved for spending by the transaction, denominated in wei. Note that by default Uniswap Labs sets this to the maximum approvable spend
- `gasLimit`: string. The maximum units of gas that will be consumed by this transaction
- `maxFeePerGas`: string. The sum of the base fee and priority fee. Subtracting `maxPriorityFeePerGas` from this value will yield the base fee to be paid for this transaction
- `maxPriorityFeePerGas`: string. The maximum tip to the block builder. Adjusted based upon the urgency specified in the request
- `gasPrice`: string. The cost per unit of gas

## TransactionFailureReason



- enum: `SIMULATION_ERROR`, `UNSUPPORTED_SIMULATION`, `SIMULATION_UNAVAILABLE`, `SLIPPAGE_TOO_LOW`, `TRANSFER_FROM_FAILED`

## SwapSafetyMode

Swap safety mode will automatically sweep the transaction for the native token and return it to the sender wallet address. This is to prevent accidental loss of funds in the event that the token amount is set in the transaction value instead of as part of the calldata.

- enum: `SAFE`

## CreateClassicPositionRequest

Request to create a full-range V2 liquidity position.

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

## CreateClassicPositionResponse



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

## CreatePositionRequest



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

## CreatePositionResponse



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

## IncreasePositionRequest



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

## IncreasePositionResponse



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

## DecreasePositionRequest



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

## DecreasePositionResponse



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

## ClaimFeesRequest



- `protocol` (required): string = `V2`, `V3`, `V4`. The protocol of the pool
- `walletAddress` (required): string
- `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `tokenId` (required): string. The NFT token ID identifying the position
- `simulateTransaction`: boolean. If true, the response will include the gas fee
- `collectAsWeth`: boolean. If true, native tokens will be collected as WETH instead of unwrapping to ETH

## ClaimFeesResponse



- `requestId` (required): string. A unique ID for the request
- `token0` (required): object. A token with its address and amount, used in LP operations
  - `tokenAddress` (required): string
  - `amount` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `token1` (required): object. A token with its address and amount, used in LP operations
  - `tokenAddress` (required): string
  - `amount` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `claim` (required): object
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

## PoolInfoRequest



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

## PoolInfoResponse



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

## PoolInformation



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

## PoolParameters



- `tokenAddressA` (required): string. The address of the first token in the pair
- `tokenAddressB` (required): string. The address of the second token in the pair
- `fee`: number. The fee of the pool, if the pool has a fee value. Must be provided for V3 or V4 pools
- `tickSpacing`: number. The width of ticks in this pool (e.g. the price range between two ticks) specified in basis points. Must be provided for V3 or V4 pools
- `hookAddress`: string. The address of the hook for the pool, if any

## PoolReferenceByProtocol



- `protocol` (required): string = `V2`, `V3`, `V4`. The protocol of the pool
- `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `referenceIdentifier`: string

## WalletEncode7702RequestBody



- `calls` (required): array. Array of transaction requests to be encoded. All transactions must have the same chainId
  - items:
    - `to` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
    - `from` (required): string. The wallet address which will be used to send the token
    - `data` (required): string. The calldata for the transaction
    - `value` (required): string. The quantity of ETH tokens approved for spending by the transaction, denominated in wei. Note that by default Uniswap Labs sets this to the maximum approvable spend
    - `gasLimit`: string. The maximum units of gas that will be consumed by this transaction
    - `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `maxFeePerGas`: string. The sum of the base fee and priority fee. Subtracting `maxPriorityFeePerGas` from this value will yield the base fee to be paid for this transaction
    - `maxPriorityFeePerGas`: string. The maximum tip to the block builder. Adjusted based upon the urgency specified in the request
    - `gasPrice`: string. The cost per unit of gas
- `smartContractDelegationAddress` (required): string
- `walletAddress` (required): string

## Encode7702ResponseBody



- `requestId` (required): string. A unique ID for the request
- `encoded` (required): object
  - `to` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
  - `from` (required): string. The wallet address which will be used to send the token
  - `data` (required): string. The calldata for the transaction
  - `value` (required): string. The quantity of ETH tokens approved for spending by the transaction, denominated in wei. Note that by default Uniswap Labs sets this to the maximum approvable spend
  - `gasLimit`: string. The maximum units of gas that will be consumed by this transaction
  - `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `maxFeePerGas`: string. The sum of the base fee and priority fee. Subtracting `maxPriorityFeePerGas` from this value will yield the base fee to be paid for this transaction
  - `maxPriorityFeePerGas`: string. The maximum tip to the block builder. Adjusted based upon the urgency specified in the request
  - `gasPrice`: string. The cost per unit of gas

## WalletCheckDelegationRequestBody



- `walletAddresses`: array. Array of wallet addresses to check delegation status for
  - items:
- `chainIds` (required): array. Array of chain IDs to check delegation status for
  - items:
    - enum: `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`

## DelegationDetails



- `isWalletDelegatedToUniswap` (required): boolean. Whether the current delegation address is a Uniswap delegation address
- `currentDelegationAddress` (required): string. The current delegation address of the wallet. May be null if the wallet does not currently delegate to any address
- `latestDelegationAddress` (required): string. The latest delegation address that the wallet could upgrade to

## ChainDelegationMap

Map of chain IDs to delegation details for a specific wallet.


## WalletCheckDelegationResponseBody



- `requestId` (required): string. A unique ID for the request
- `delegationDetails` (required): object. Map of wallet addresses to chain IDs to delegation details

## CreatePlanRequest



- `routing` (required): string = `CHAINED`. The routing type for the plan. Currently only CHAINED is supported for multi-step execution plans
- `quote` (required): object. A quote for a chained transaction flow that spans multiple steps, potentially across multiple chains
  - `priceDifference`: number. The expected value lost versus frictionless execution at current prices, as a percent between -100 and 100. Negative values indicate price improvement. For chained trades this compounds the per-step values multiplicatively as 1 - product of (1 - stepValue/100) over the value-moving steps. Absent if any of those steps is missing its value
  - `swapper` (required): string. The wallet address which will be used to send the token
  - `input` (required): object
    - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `token`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `maximumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
  - `output` (required): object
    - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
    - `minimumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
  - `tokenInChainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `tokenOutChainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `tradeType` (required): string = `EXACT_INPUT`, `EXACT_OUTPUT`. The handling of the `amount` field. `EXACT_INPUT` means the requester will send the specified `amount` of input tokens and get a quote with a variable quantity of output tokens. `EXACT_OUTPUT` means the requester will receive the specified `amount` of output tokens and get a quote with a variable quantity of input tokens
  - `quoteId` (required): string. A unique ID for the quote
  - `gasEstimates`: array. Gas estimates for each step in the chained flow
    - items:
  - `timeEstimateMs`: number. Estimated time in milliseconds to complete the entire chained flow
  - `gasUseEstimate`: string. The maximum units of gas that will be consumed by this transaction
  - `gasFeeUSD`: string. The total estimated gas cost of this transaction (eg. `gasLimit` multiplied by `maxFeePerGas`) denominated in USDC
  - `gasFeeQuote`: string. The total estimated gas cost of this transaction (eg. gasLimit multiplied by maxFeePerGas) in the quoted currency (e.g. output token) in the base units of the quoted currency
  - `gasPrice`: string. The cost per unit of gas
  - `maxFeePerGas`: string. The sum of the base fee and priority fee. Subtracting `maxPriorityFeePerGas` from this value will yield the base fee to be paid for this transaction
  - `maxPriorityFeePerGas`: string. The maximum tip to the block builder. Adjusted based upon the urgency specified in the request
  - `gasFee`: string. The total estimated gas cost of this transaction (eg. `gasLimit` multiplied by `maxFeePerGas`) in the base unit of the chain
  - `protocols`: array. The protocols to use for the swap/order. If the `protocols` field is defined, then you can only set the `routingPreference` to `BEST_PRICE`. Note that the value `UNISWAPX` is deprecated and will be removed in a future release
    - items:
      - enum: `V2`, `V3`, `V4`, `UNISWAPX`, `UNISWAPX_V2`, `UNISWAPX_V3`, `UNISWAPX_LATEST`
  - `hooksOptions`: string = `V4_HOOKS_INCLUSIVE`, `V4_HOOKS_ONLY`, `V4_NO_HOOKS`. The hook options to use for V4 pool quotes. `V4_HOOKS_INCLUSIVE` will get quotes for V4 pools with or without hooks. `V4_HOOKS_ONLY` will only get quotes for V4 pools with hooks. `V4_NO_HOOKS` will only get quotes for V4 pools without hooks. Defaults to `V4_HOOKS_INCLUSIVE` if `V4` is included in `protocols` and `hookOptions` is not set. This field is ignored if `V4` is not passed in `protocols`
  - `gasStrategies` (required): array. Gas strategies for the chained flow
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
  - `steps`: array. Truncated plan steps for the chained transaction flow
    - items:
      - `priceDifference`: number. The expected value lost versus frictionless execution at current prices, as a percent between -100 and 100. Negative values indicate price improvement. The value for this step alone, computed according to the step's order type; the chained quote's top-level value compounds these
      - `stepType` (required): string = `DUTCH_LIMIT`, `CLASSIC`, `DUTCH_V2`, `LIMIT_ORDER`, `WRAP`, `UNWRAP`, `BRIDGE`, `PRIORITY`, `DUTCH_V3`, `QUICKROUTE`, `CHAINED`, `VAULT_DEPOSIT`, `VAULT_WITHDRAW`, `APPROVAL_TXN`, `APPROVAL_PERMIT`, `RESET_APPROVAL_TXN`. The type of step in a plan, including swap types and approval types
      - `tokenIn`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `tokenInChainId`: number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `tokenOut`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `tokenOutChainId`: number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
      - `slippage`: number. The slippage tolerance as a percentage up to a maximum of two decimal places. For Uniswap Protocols (v2, v3, v4), the slippage tolerance is the maximum amount the price can change between the time the transaction is submitted and the time it is executed. The slippage tolerance is a percentage of the total value of the swap.  When submitting a quote, note that slippage tolerance works differently in UniswapX swaps where it does not set a limit on the Spread in an order. See [here](https://api-docs.uniswap.org/guides/faqs#why-do-uniswapx-quotes-have-more-slippage-than-the-tolerance-i-set) for more information.  Note that if the trade type is `EXACT_INPUT`, then the slippage is in terms of the output token. If the trade type is `EXACT_OUTPUT`, then the slippage is in terms of the input token.  When submitting a request, `slippageTolerance` may not be set when `autoSlippage` is defined. One of `slippageTolerance` or `autoSlippage` must be defined
  - `slippageTolerance`: number. The slippage tolerance as a percentage up to a maximum of two decimal places. For Uniswap Protocols (v2, v3, v4), the slippage tolerance is the maximum amount the price can change between the time the transaction is submitted and the time it is executed. The slippage tolerance is a percentage of the total value of the swap.  When submitting a quote, note that slippage tolerance works differently in UniswapX swaps where it does not set a limit on the Spread in an order. See [here](https://api-docs.uniswap.org/guides/faqs#why-do-uniswapx-quotes-have-more-slippage-than-the-tolerance-i-set) for more information.  Note that if the trade type is `EXACT_INPUT`, then the slippage is in terms of the output token. If the trade type is `EXACT_OUTPUT`, then the slippage is in terms of the input token.  When submitting a request, `slippageTolerance` may not be set when `autoSlippage` is defined. One of `slippageTolerance` or `autoSlippage` must be defined
  - `autoSlippage`: string = `DEFAULT`. The auto slippage strategy to employ. For Uniswap Protocols (v2, v3, v4) the auto slippage will be automatically calculated when this field is set to `DEFAULT`. Auto slippage cannot be calculated for UniswapX swaps.  Note that if the trade type is `EXACT_INPUT`, then the slippage is in terms of the output token. If the trade type is `EXACT_OUTPUT`, then the slippage is in terms of the input token.  When submitting a request, `autoSlippage` may not be set when `slippageTolerance` is defined. One of `slippageTolerance` or `autoSlippage` must be defined
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
        - `estimatedSharesOut` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - oneOf: `` object
        - `type` (required): string = `EXACT_ASSETS_WITHDRAW`
        - `requestedAssetsOut` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
        - `estimatedSharesIn` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
      - oneOf: `` object
        - `type` (required): string = `MAX_SHARES_WITHDRAW`
        - `maxRedeemableSharesIn` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
        - `previewAssetsOut` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
  - `earnPreview`: object. Action-specific preview amounts computed while normalizing an Earn intent
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
- `walletExecutionContext`: object. Wallet execution context based on CAIP-25 Standard. Provides information about wallet capabilities and scopes
  - `scopes` (required): object. Map of scope identifiers to their scope data
  - `properties`: object. Properties describing the wallet
    - `walletInfo`: object. Information about the wallet
      - `uuid`: string. Unique identifier for the wallet
      - `name`: string. Name of the wallet
      - `rdns`: string. Reverse domain name identifier for the wallet
- `urgency`: object. The urgency impacts the estimated gas price of the transaction. The higher the urgency, the higher the gas price, and the faster the transaction is likely to be selected from the mempool. Send the bare string form (e.g. `"normal"`) for the common case, or the object form `{ level, overrides }` to supply caller caps for `maxPriorityFeePerGas`, `maxFeePerGas`, and `gasLimit`
  - oneOf: `` string
    - enum: `normal`, `fast`, `urgent`
  - oneOf: `` object
    - `level` (required): string = `normal`, `fast`, `urgent`
    - `overrides`: object. Caller-supplied caps applied on top of the gas service's computed quote. All fields are absolute wei (decimal string). `maxPriorityFeePerGas` and `maxFeePerGas` are treated as caps - they lower the quote, never raise it. `gasLimit`, if set, replaces the limit calculation entirely
      - `maxPriorityFeePerGas`: string. Maximum priority fee in wei (decimal string)
      - `maxFeePerGas`: string. Maximum total fee per gas in wei (decimal string)
      - `gasLimit`: string. Gas limit cap (in gas units, decimal string)
- `earnIntent`: object. Earn vault intent supplied on /quote and repeated on /plan. Earn currently supports the allowlisted Mainnet Morpho vaults
  - `action` (required): string = `deposit`, `withdraw`. The Earn vault action to quote or plan
  - `vault` (required): string
  - `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `withdrawMode`: string = `EXACT_ASSETS`, `MAX_SHARES`. The ERC-4626 withdraw mode. EXACT_ASSETS withdraws the requested asset amount; MAX_SHARES redeems the owner's currently redeemable shares

## UpdatePlanRequest



- `steps` (required): array. Array of steps with proofs to attach. Only steps being updated need to be included
  - items:
    - `stepIndex` (required): number. The index of the step being updated (0-based)
    - `proof` (required): object. Proof of step completion. Must provide either txHash or signature
      - `txHash`: string. The unique hash of the transaction
      - `signature`: string. The signature for a message signing step

## StepUpdate

Represents a single step update with proof. Note: orderId is not accepted in update requests; it is system-generated after receiving a signature.

- `stepIndex` (required): number. The index of the step being updated (0-based)
- `proof` (required): object. Proof of step completion. Must provide either txHash or signature
  - `txHash`: string. The unique hash of the transaction
  - `signature`: string. The signature for a message signing step

## PlanResponse



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

## PlanStep



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

## PlanStepProof

Proof of execution for a plan step, provided after the step is completed.

- `txHash`: string. The unique hash of the transaction
- `signature`: string. The signature for a message signing step
- `orderId`: string. The order ID for a gasless order step

## PlanStatus

The overall status of the plan execution. ACTIVE means the plan is ready to begin (all steps NOT_READY). AWAITING_ACTION means at least one step requires user action. IN_PROGRESS means at least one step is executing. COMPLETED means all steps have been successfully executed. FAILED means the plan cannot be completed.

- enum: `ACTIVE`, `AWAITING_ACTION`, `IN_PROGRESS`, `COMPLETED`, `FAILED`

## PlanStepStatus

The status of an individual step. NOT_READY means prerequisites are not met. AWAITING_ACTION means the step is ready for user action. IN_PROGRESS means the step is being executed. COMPLETE means the step finished successfully. STEP_ERROR means the step failed.

- enum: `NOT_READY`, `AWAITING_ACTION`, `IN_PROGRESS`, `COMPLETE`, `STEP_ERROR`

## PlanStepMethod

The execution method for the step. SEND_TX is a standard transaction. SIGN_MSG is for signing a message (e.g., permit). SEND_CALLS is for batch transaction execution (EIP-5792).

- enum: `SEND_TX`, `SIGN_MSG`, `SEND_CALLS`

## PlanStepPayloadType

The type of payload data. TX is a standard transaction object. EIP_712 is a typed structured data for signing. EIP_5792 is a batch of transaction calls.

- enum: `TX`, `EIP_712`, `EIP_5792`

## TruncatedPlanStep

A truncated representation of a plan step containing only routing information.

- `priceDifference`: number. The expected value lost versus frictionless execution at current prices, as a percent between -100 and 100. Negative values indicate price improvement. The value for this step alone, computed according to the step's order type; the chained quote's top-level value compounds these
- `stepType` (required): string = `DUTCH_LIMIT`, `CLASSIC`, `DUTCH_V2`, `LIMIT_ORDER`, `WRAP`, `UNWRAP`, `BRIDGE`, `PRIORITY`, `DUTCH_V3`, `QUICKROUTE`, `CHAINED`, `VAULT_DEPOSIT`, `VAULT_WITHDRAW`, `APPROVAL_TXN`, `APPROVAL_PERMIT`, `RESET_APPROVAL_TXN`. The type of step in a plan, including swap types and approval types
- `tokenIn`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `tokenInChainId`: number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `tokenOut`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `tokenOutChainId`: number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `slippage`: number. The slippage tolerance as a percentage up to a maximum of two decimal places. For Uniswap Protocols (v2, v3, v4), the slippage tolerance is the maximum amount the price can change between the time the transaction is submitted and the time it is executed. The slippage tolerance is a percentage of the total value of the swap.  When submitting a quote, note that slippage tolerance works differently in UniswapX swaps where it does not set a limit on the Spread in an order. See [here](https://api-docs.uniswap.org/guides/faqs#why-do-uniswapx-quotes-have-more-slippage-than-the-tolerance-i-set) for more information.  Note that if the trade type is `EXACT_INPUT`, then the slippage is in terms of the output token. If the trade type is `EXACT_OUTPUT`, then the slippage is in terms of the input token.  When submitting a request, `slippageTolerance` may not be set when `autoSlippage` is defined. One of `slippageTolerance` or `autoSlippage` must be defined

## ChainedQuote

A quote for a chained transaction flow that spans multiple steps, potentially across multiple chains.

- `priceDifference`: number. The expected value lost versus frictionless execution at current prices, as a percent between -100 and 100. Negative values indicate price improvement. For chained trades this compounds the per-step values multiplicatively as 1 - product of (1 - stepValue/100) over the value-moving steps. Absent if any of those steps is missing its value
- `swapper` (required): string. The wallet address which will be used to send the token
- `input` (required): object
  - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
  - `token`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `maximumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `output` (required): object
  - `amount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
  - `token`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
  - `recipient`: string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
  - `minimumAmount`: string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `tokenInChainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `tokenOutChainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `tradeType` (required): string = `EXACT_INPUT`, `EXACT_OUTPUT`. The handling of the `amount` field. `EXACT_INPUT` means the requester will send the specified `amount` of input tokens and get a quote with a variable quantity of output tokens. `EXACT_OUTPUT` means the requester will receive the specified `amount` of output tokens and get a quote with a variable quantity of input tokens
- `quoteId` (required): string. A unique ID for the quote
- `gasEstimates`: array. Gas estimates for each step in the chained flow
  - items:
- `timeEstimateMs`: number. Estimated time in milliseconds to complete the entire chained flow
- `gasUseEstimate`: string. The maximum units of gas that will be consumed by this transaction
- `gasFeeUSD`: string. The total estimated gas cost of this transaction (eg. `gasLimit` multiplied by `maxFeePerGas`) denominated in USDC
- `gasFeeQuote`: string. The total estimated gas cost of this transaction (eg. gasLimit multiplied by maxFeePerGas) in the quoted currency (e.g. output token) in the base units of the quoted currency
- `gasPrice`: string. The cost per unit of gas
- `maxFeePerGas`: string. The sum of the base fee and priority fee. Subtracting `maxPriorityFeePerGas` from this value will yield the base fee to be paid for this transaction
- `maxPriorityFeePerGas`: string. The maximum tip to the block builder. Adjusted based upon the urgency specified in the request
- `gasFee`: string. The total estimated gas cost of this transaction (eg. `gasLimit` multiplied by `maxFeePerGas`) in the base unit of the chain
- `protocols`: array. The protocols to use for the swap/order. If the `protocols` field is defined, then you can only set the `routingPreference` to `BEST_PRICE`. Note that the value `UNISWAPX` is deprecated and will be removed in a future release
  - items:
    - enum: `V2`, `V3`, `V4`, `UNISWAPX`, `UNISWAPX_V2`, `UNISWAPX_V3`, `UNISWAPX_LATEST`
- `hooksOptions`: string = `V4_HOOKS_INCLUSIVE`, `V4_HOOKS_ONLY`, `V4_NO_HOOKS`. The hook options to use for V4 pool quotes. `V4_HOOKS_INCLUSIVE` will get quotes for V4 pools with or without hooks. `V4_HOOKS_ONLY` will only get quotes for V4 pools with hooks. `V4_NO_HOOKS` will only get quotes for V4 pools without hooks. Defaults to `V4_HOOKS_INCLUSIVE` if `V4` is included in `protocols` and `hookOptions` is not set. This field is ignored if `V4` is not passed in `protocols`
- `gasStrategies` (required): array. Gas strategies for the chained flow
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
- `steps`: array. Truncated plan steps for the chained transaction flow
  - items:
    - `priceDifference`: number. The expected value lost versus frictionless execution at current prices, as a percent between -100 and 100. Negative values indicate price improvement. The value for this step alone, computed according to the step's order type; the chained quote's top-level value compounds these
    - `stepType` (required): string = `DUTCH_LIMIT`, `CLASSIC`, `DUTCH_V2`, `LIMIT_ORDER`, `WRAP`, `UNWRAP`, `BRIDGE`, `PRIORITY`, `DUTCH_V3`, `QUICKROUTE`, `CHAINED`, `VAULT_DEPOSIT`, `VAULT_WITHDRAW`, `APPROVAL_TXN`, `APPROVAL_PERMIT`, `RESET_APPROVAL_TXN`. The type of step in a plan, including swap types and approval types
    - `tokenIn`: string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `tokenInChainId`: number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `tokenOut`: string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `tokenOutChainId`: number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `slippage`: number. The slippage tolerance as a percentage up to a maximum of two decimal places. For Uniswap Protocols (v2, v3, v4), the slippage tolerance is the maximum amount the price can change between the time the transaction is submitted and the time it is executed. The slippage tolerance is a percentage of the total value of the swap.  When submitting a quote, note that slippage tolerance works differently in UniswapX swaps where it does not set a limit on the Spread in an order. See [here](https://api-docs.uniswap.org/guides/faqs#why-do-uniswapx-quotes-have-more-slippage-than-the-tolerance-i-set) for more information.  Note that if the trade type is `EXACT_INPUT`, then the slippage is in terms of the output token. If the trade type is `EXACT_OUTPUT`, then the slippage is in terms of the input token.  When submitting a request, `slippageTolerance` may not be set when `autoSlippage` is defined. One of `slippageTolerance` or `autoSlippage` must be defined
- `slippageTolerance`: number. The slippage tolerance as a percentage up to a maximum of two decimal places. For Uniswap Protocols (v2, v3, v4), the slippage tolerance is the maximum amount the price can change between the time the transaction is submitted and the time it is executed. The slippage tolerance is a percentage of the total value of the swap.  When submitting a quote, note that slippage tolerance works differently in UniswapX swaps where it does not set a limit on the Spread in an order. See [here](https://api-docs.uniswap.org/guides/faqs#why-do-uniswapx-quotes-have-more-slippage-than-the-tolerance-i-set) for more information.  Note that if the trade type is `EXACT_INPUT`, then the slippage is in terms of the output token. If the trade type is `EXACT_OUTPUT`, then the slippage is in terms of the input token.  When submitting a request, `slippageTolerance` may not be set when `autoSlippage` is defined. One of `slippageTolerance` or `autoSlippage` must be defined
- `autoSlippage`: string = `DEFAULT`. The auto slippage strategy to employ. For Uniswap Protocols (v2, v3, v4) the auto slippage will be automatically calculated when this field is set to `DEFAULT`. Auto slippage cannot be calculated for UniswapX swaps.  Note that if the trade type is `EXACT_INPUT`, then the slippage is in terms of the output token. If the trade type is `EXACT_OUTPUT`, then the slippage is in terms of the input token.  When submitting a request, `autoSlippage` may not be set when `slippageTolerance` is defined. One of `slippageTolerance` or `autoSlippage` must be defined
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
- `earnPreview`: object. Action-specific preview amounts computed while normalizing an Earn intent
  - oneOf: `` object
    - `type` (required): string = `DEPOSIT`
    - `depositAssets` (required): array. Vault underlying assets that will be deposited after any swap, bridge, wrap, or unwrap steps
    - `estimatedSharesOut` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
  - oneOf: `` object
    - `type` (required): string = `EXACT_ASSETS_WITHDRAW`
    - `requestedAssetsOut` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `estimatedSharesIn` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
  - oneOf: `` object
    - `type` (required): string = `MAX_SHARES_WITHDRAW`
    - `maxRedeemableSharesIn` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
    - `previewAssetsOut` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0

## WalletExecutionContext

Wallet execution context based on CAIP-25 Standard. Provides information about wallet capabilities and scopes.

- `scopes` (required): object. Map of scope identifiers to their scope data
- `properties`: object. Properties describing the wallet
  - `walletInfo`: object. Information about the wallet
    - `uuid`: string. Unique identifier for the wallet
    - `name`: string. Name of the wallet
    - `rdns`: string. Reverse domain name identifier for the wallet

## ScopeData

Data defining a wallet scope including accounts, methods, capabilities, chains, and client context.

- `accounts` (required): array. Array of account addresses associated with this scope
  - items:
- `methods` (required): array. Array of methods allowed in this scope
  - items:
- `capabilities`: object. Additional capabilities for this scope
- `chains`: array. Array of chain identifiers allowed in this scope
  - items:
- `clientContext`: object. Uni client-specific context describing how this wallet integrates with the application
  - `directPrivateKeyAccess`: boolean. Whether the wallet has direct private key access
  - `nextEvmUpgradeAddress`: string. Address for the next EVM upgrade

## ClientContext

Uni client-specific context describing how this wallet integrates with the application.

- `directPrivateKeyAccess`: boolean. Whether the wallet has direct private key access
- `nextEvmUpgradeAddress`: string. Address for the next EVM upgrade

## WalletProperties

Properties describing the wallet.

- `walletInfo`: object. Information about the wallet
  - `uuid`: string. Unique identifier for the wallet
  - `name`: string. Name of the wallet
  - `rdns`: string. Reverse domain name identifier for the wallet

## WalletInfo

Information about the wallet.

- `uuid`: string. Unique identifier for the wallet
- `name`: string. Name of the wallet
- `rdns`: string. Reverse domain name identifier for the wallet

## GasStrategy

Gas strategy configuration for transaction fee estimation.

- `limitInflationFactor` (required): number. Factor to inflate the gas limit estimate
- `priceInflationFactor` (required): number. Factor to inflate the gas price estimate
- `percentileThresholdFor1559Fee` (required): number. Percentile threshold for EIP-1559 fee calculation
- `thresholdToInflateLastBlockBaseFee`: number. Threshold to inflate the last block base fee
- `baseFeeMultiplier`: number. Multiplier for the base fee
- `baseFeeHistoryWindow`: number. Number of blocks to consider for base fee history
- `minPriorityFeeRatioOfBaseFee`: number. Minimum priority fee as a ratio of base fee
- `minPriorityFeeGwei`: number. Minimum priority fee in Gwei
- `maxPriorityFeeGwei`: number. Maximum priority fee in Gwei

## EarnAction

The Earn vault action to quote or plan.

- enum: `deposit`, `withdraw`

## EarnWithdrawMode

The ERC-4626 withdraw mode. EXACT_ASSETS withdraws the requested asset amount; MAX_SHARES redeems the owner's currently redeemable shares.

- enum: `EXACT_ASSETS`, `MAX_SHARES`

## EarnDestinationGasMode

Backend-selected funding mode for destination-chain gas on standard cross-chain Earn deposits. WALLET_BALANCE means the swapper has enough destination native gas; SELF_FUNDED means the route bridges native gas and reserves part of it for the remaining destination transactions.

- enum: `WALLET_BALANCE`, `SELF_FUNDED`

## EarnIntent

Earn vault intent supplied on /quote and repeated on /plan. Earn currently supports the allowlisted Mainnet Morpho vaults.

- `action` (required): string = `deposit`, `withdraw`. The Earn vault action to quote or plan
- `vault` (required): string
- `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `withdrawMode`: string = `EXACT_ASSETS`, `MAX_SHARES`. The ERC-4626 withdraw mode. EXACT_ASSETS withdraws the requested asset amount; MAX_SHARES redeems the owner's currently redeemable shares

## EarnPreview

Action-specific preview amounts computed while normalizing an Earn intent.

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

## EarnDepositPreview

Deposit preview. Asset amounts are vault-underlying assets, and share amounts are vault shares.

- `type` (required): string = `DEPOSIT`
- `depositAssets` (required): array. Vault underlying assets that will be deposited after any swap, bridge, wrap, or unwrap steps
  - items:
    - `token` (required): string
    - `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
    - `amount` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `estimatedSharesOut` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0

## EarnExactAssetsWithdrawPreview

Exact-assets withdraw preview. Assets are vault-underlying assets, and shares are vault shares.

- `type` (required): string = `EXACT_ASSETS_WITHDRAW`
- `requestedAssetsOut` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `estimatedSharesIn` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0

## EarnMaxSharesWithdrawPreview

Max-shares withdraw preview. Assets are vault-underlying assets, and shares are vault shares.

- `type` (required): string = `MAX_SHARES_WITHDRAW`
- `maxRedeemableSharesIn` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `previewAssetsOut` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0

## EarnPreviewDepositAsset

A vault deposit input asset amount after all pre-vault routing has completed.

- `token` (required): string
- `chainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `amount` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0

## EarnQuoteIntent

Validated Earn intent returned by /quote and /plan. Internal vault execution metadata is kept off the public contract.

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
