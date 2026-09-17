<!-- generated from openapi-trading-api.json | captured: 2026-08-22 -->
# Create swap calldata

`POST https://trade-api.gateway.uniswap.org/v1/swap`  
operationId: `create_swap_transaction` · tags: swapping

Create the calldata for a swap transaction (including wrap/unwrap) against the Uniswap Protocols. If the `quote` parameter includes the fee parameters, then the calldata will include the fee disbursement. The gas estimates will be **more precise** when the the response calldata would be valid if submitted on-chain.

## Parameters

- `x-universal-router-version` (header): The version of the Universal Router to use for the swap journey. *MUST* be consistent throughout the API calls. default `2.0`
- `x-permit2-disabled` (header): Disables the Permit2 approval flow. When set to `true`, `permitData` is returned as `null` and the header is forwarded to the routing layer for correct gas simulation against the Proxy Universal Router contract. When `false` or omitted, the standard Permit2 approval flow is used. This header is intended for integrators whose infrastructure uses a direct approval-then-swap pattern without Permit2. default `False`

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

Example:

```json
{
  "quote": {
    "chainId": 1,
    "input": {
      "amount": "2516",
      "token": "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599"
    },
    "output": {
      "amount": "996320746321162",
      "token": "0x0000000000000000000000000000000000000000",
      "recipient": "0xC9bebBA9f481b12cE6f3EA54c4B182c9636ec421"
    },
    "swapper": "0xC9bebBA9f481b12cE6f3EA54c4B182c9636ec421",
    "route": [
      [
        {
          "type": "v4-pool",
          "address": "0x599326d9cd5e1ea0893305c87d5ec3199e7f05e94d72159f35dea381479a615e",
          "tokenIn": {
            "chainId": 1,
            "decimals": "8",
            "address": "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599",
            "symbol": "WBTC"
          },
          "tokenOut": {
            "chainId": 1,
            "decimals": "18",
            "address": "0x0000000000000000000000000000000000000000",
            "symbol": "ETH"
          },
          "fee": "500",
          "tickSpacing": "10",
          "hooks": "0x0000000000000000000000000000000000000000",
          "liquidity": "82781860385007263",
          "sqrtRatioX96": "125814565506407615477027",
          "tickCurrent": "-267075",
          "amountIn": "2516",
          "amountOut": "993829944455359"
        }
      ]
    ],
    "slippage": 5.5,
    "tradeType": "EXACT_INPUT",
    "quoteId": "62e83902-9455-405d-8c62-cdf8ee9e2042",
    "gasFeeUSD": "1.27511942409885062",
    "gasFeeQuote": "489108586810000",
    "gasUseEstimate": "180350",
    "priceImpact": 0.14,
    "txFailureReasons": [],
    "maxPriorityFeePerGas": "2000000000",
    "maxFeePerGas": "4656513686",
    "gasFee": "489108586810000",
    "routeString": "[V4] 100.00% = WBTC -- 0.05% [0x599326d9cd5e1ea0893305c87d5ec3199e7f05e94d72159f35dea381479a615e]ETH",
    "blockNumber": "22483653",
    "aggregatedOutputs": [
      {
        "amount": "993829944455360",
        "token": "0x0000000000000000000000000000000000000000",
        "recipient": "0xC9bebBA9f481b12cE6f3EA54c4B182c9636ec421",
        "bps": 9975,
        "minAmount": "993829944455360"
      },
      {
        "amount": "2490801865802",
        "token": "0x0000000000000000000000000000000000000000",
        "recipient": "0x000000fee13a103A10D593b9AE06b3e05F2E7E1c",
        "bps": 25,
        "minAmount": "2490801865802",
        "fee": "INTEGRATOR"
      }
    ],
    "portionAmount": "2490801865802",
    "portionBips": 25,
    "portionRecipient": "0x000000fee13a103A10D593b9AE06b3e05F2E7E1c"
  },
  "permitData": {
    "domain": {
      "name": "Permit2",
      "chainId": 1,
      "verifyingContract": "0x000000000022D473030F116dDEE9F6B43aC78BA3"
    },
    "types": {
      "PermitSingle": [
        {
          "name": "details",
          "type": "PermitDetails"
        },
        {
          "name": "spender",
          "type": "address"
        },
        {
          "name": "sigDeadline",
          "type": "uint256"
        }
      ],
      "PermitDetails": [
        {
          "name": "token",
          "type": "address"
        },
        {
          "name": "amount",
          "type": "uint160"
        },
        {
          "name": "expiration",
          "type": "uint48"
        },
        {
          "name": "nonce",
          "type": "uint48"
        }
      ]
    },
    "values": {
      "details": {
        "token": "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599",
        "amount": "1461501637330902918203684832716283019655932542975",
        "expiration": "1749845047",
        "nonce": "1"
      },
      "spender": "0x66a9893cc07d91d95644aedd05d03f95e1dba8af",
      "sigDeadline": "1747254847"
    }
  },
  "signature": "0xb22e7f47d8...",
  "simulateTransaction": true,
  "refreshGasPrice": true,
  "safetyMode": "SAFE",
  "urgency": "normal"
}
```

## Responses

### 200: Create swap successful.

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

Example:

```json
{
  "requestId": "dfc1bd88-c741-4cdb-b118-0dddb690bfef",
  "swap": {
    "data": "0x3593564c00...",
    "value": "0x00",
    "to": "0x66a9893cc07d91d95644aedd05d03f95e1dba8af",
    "from": "0xC9bebBA9f481b12cE6f3EA54c4B182c9636ec421",
    "maxFeePerGas": "4794697230",
    "maxPriorityFeePerGas": "2000000000",
    "gasLimit": "179302",
    "chainId": 1
  },
  "gasFee": "859698802733460"
}
```

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

