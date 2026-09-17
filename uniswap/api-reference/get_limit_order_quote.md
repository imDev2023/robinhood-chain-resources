<!-- generated from openapi-trading-api.json | captured: 2026-08-22 -->
# Get a limit order quote

`POST https://trade-api.gateway.uniswap.org/v1/limit_order_quote`  
operationId: `get_limit_order_quote` · tags: swapping

Get a quote for a limit order according to the provided configuration.

## Request body (application/json)

- `swapper` (required): string. (optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`
- `limitPrice`: string
- `amount` (required): string. The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0
- `orderDeadline`: number
- `type` (required): string = `EXACT_INPUT`, `EXACT_OUTPUT`. The handling of the `amount` field. `EXACT_INPUT` means the requester will send the specified `amount` of input tokens and get a quote with a variable quantity of output tokens. `EXACT_OUTPUT` means the requester will receive the specified `amount` of output tokens and get a quote with a variable quantity of input tokens
- `tokenIn` (required): string. The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `tokenOut` (required): string. The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `tokenInChainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)
- `tokenOutChainId` (required): number = `1`, `10`, `56`, `130`, `137`, `143`, `196`, `324`, `480`, `1868`, `4217`, `4326`, `4663`, `5042`, `8453`, `10143`, `42161`, `42220`, `43114`, `57073`, `59144`, `81457`, `7777777`, `1301`, `84532`, `11155111`. The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs)

## Responses

### 200: Limit Order Quote request successful.

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

### 400: RequestValidationError, Bad Input

- `errorCode`: string
- `detail`: string

### 401: UnauthorizedError eg. Account is blocked.

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

