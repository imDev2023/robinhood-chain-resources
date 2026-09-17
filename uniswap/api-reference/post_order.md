<!-- generated from openapi-trading-api.json | captured: 2026-08-22 -->
# Create a gasless order

`POST https://trade-api.gateway.uniswap.org/v1/order`  
operationId: `post_order` · tags: swapping

The order endpoint is used to submit a UniswapX intent. If the `routing` field in the response to a quote is any of `DUTCH_V2`, `DUTCH_V3`, `LIMIT_ORDER`, or `PRIORITY` this endpoint is used to submit your order to the UniswapX protocol to be filled by the filler network. These orders are gasless because the filler will pay the gas to complete the transaction.

The order will be validated and, if valid, will be submitted to the filler network. The network will try to fill the order at the quoted `startAmount`. If the order is not filled at the `startAmount` by the `deadline`, the amount will start decaying until the `endAmount` is reached. The order will remain `open` until it is either filled, canceled, or has expired by remaining unfilled beyond the `decayEndTime`.

For simplicity, the order request is identical to the quote response except for the addition of the signed permit.

Native ETH on UniswapX: If the quote you are submitting uses native ETH as the input token (e.g. `tokenIn` is `0x0000000000000000000000000000000000000000`), include `x-erc20eth-enabled: true`. Native ETH input on UniswapX requires wallet support for EIP-7914 and sufficient native allowance. For 7702-delegated smart contract wallets, you can generate the required approval call(s) via `/swap_7702` when needed.

## Parameters

- `x-erc20eth-enabled` (header): Enable native ETH input support for UniswapX via ERC20-ETH (EIP-7914). When set to true and `tokenIn` is the native currency address (e.g. `0x0000000000000000000000000000000000000000`), the API may return UniswapX routes that spend native ETH for supported wallets. default `False`

## Request body (application/json)

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

## Responses

### 201: Encoded order submitted.

- `requestId` (required): string. A unique ID for the request
- `orderId` (required): string. A unique ID for the order. Used to track the order's status
- `orderStatus` (required): string = `open`, `expired`, `error`, `cancelled`, `filled`, `unverified`, `insufficient-funds`. The status of the order. Note that all of these are final states with the exception of Open, meaning that no further state changes will occur.   Open - order is not yet filled by a filler.  Expired - order has expired without being filled and is no longer fillable.  Error - a catchall for other final states which are not otherwise specified, where the order will not be filled.  Cancelled - order is cancelled. Note that to cancel an order, a new order must be placed with the same nonce as the prior open order and it must be placed within the same block as the original order.  Filled - order is filled.  Insufficient-funds - the swapper (you) do not have enough funds for the order to be completed and the order is cancelled and will not be filled.  Unverified - order has not been verified yet

### 400: RequestValidationError, Bad Input

- `errorCode`: string
- `detail`: string

### 401: UnauthorizedError eg. Account is blocked.

- `errorCode`: string
- `detail`: string

### 429: Ratelimited

- `errorCode`: string
- `detail`: string

### 500: Unexpected error

- `errorCode`: string
- `detail`: string

### 503: Failed to post order to the upstream UniswapX service.

- `errorCode`: string
- `detail`: string

### 504: Request duration limit reached.

- `errorCode`: string
- `detail`: string

