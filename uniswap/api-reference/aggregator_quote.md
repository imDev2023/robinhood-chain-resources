<!-- generated from openapi-trading-api.json | captured: 2026-08-22 -->
# Get a quote

`POST https://trade-api.gateway.uniswap.org/v1/quote`  
operationId: `aggregator_quote` · tags: swapping

Requests a quote according to the specified swap parameters. This endpoint may be used to get a quote for a swap, a bridge, or a wrap/unwrap. The resulting response includes a quote for the swap and the proposed route by which the quote was achieved. The response will also include estimated gas fees for the proposed quote route. If the proposed route is via a Uniswap Protocol pool, the response may include a permit2 message for the swapper to sign prior to making a /swap request. The proposed route will also be simulated. If the simulation fails, the response will include an error message or `txFailureReason`.

Certain routing options may be whitelisted by the requestor through the use of the `protocols` field. Further, the requestor may ask for the best price route or for the fastest price route through the 'routingPreference' field. Note that the fastest price route refers to the speed with which a quote is returned, not the number of transactions that may be required to get from the input token and chain to the output token and chain. Further note that all `routingPreference` values except for `FASTEST` and `BEST_PRICE` are deprecated. For more information on the `protocols` and `routingPreference` fields, see the [Token Trading Workflow](https://uniswap-docs.readme.io/reference/trading-flow#swap-routing) explanation of Swap Routing.

API integrators using this API for the benefit of customer end users may request a service fee be taken from the output token and deposited to a fee collection address. To request this, please reach out to your Uniswap Labs contact. This optional fee is associated to the API key and is always taken from the output token. Note if there is a fee and the `type` is `EXACT_INPUT`, the output amount quoted will **not** include the fee subtraction. If there is a fee and the `type` is `EXACT_OUTPUT`, the input amount quoted will **not** include the fee addition. Instead, in both cases, the fee will be recorded in the `portionBips` and `portionAmount` fields.

Native ETH on UniswapX: UniswapX routes (e.g. `DUTCH_V2`, `DUTCH_V3`, `PRIORITY`) can use native ETH as the input token by setting `tokenIn` to the native currency address (e.g. `0x0000000000000000000000000000000000000000`) and passing `x-erc20eth-enabled: true`. Native ETH input on UniswapX requires wallet support for EIP-7914, a smart wallet activated on your desired network, and a sufficient native allowance (set via /swap_7702 if x-erc20eth-enabled header is set to `true`). If these requirements are not met, UniswapX quotes for native input may be omitted and the response may fall back to `CLASSIC` routing instead.

## Parameters

- `x-universal-router-version` (header): The version of the Universal Router to use for the swap journey. *MUST* be consistent throughout the API calls. default `2.0`
- `x-erc20eth-enabled` (header): Enable native ETH input support for UniswapX via ERC20-ETH (EIP-7914). When set to true and `tokenIn` is the native currency address (e.g. `0x0000000000000000000000000000000000000000`), the API may return UniswapX routes that spend native ETH for supported wallets. default `False`
- `x-permit2-disabled` (header): Disables the Permit2 approval flow. When set to `true`, `permitData` is returned as `null` and the header is forwarded to the routing layer for correct gas simulation against the Proxy Universal Router contract. When `false` or omitted, the standard Permit2 approval flow is used. This header is intended for integrators whose infrastructure uses a direct approval-then-swap pattern without Permit2. default `False`
- `x-universal-router-swapsteps` (header): Opts the request into Universal Router SwapSteps mode. Additive and opt-in: when set to `true`, the response's `ClassicQuote` may include a `swapSteps[]` array describing the Universal Router step sequence (the inputs to `SwapRouter.encodeSwaps`). The field is only populated when the GuideStar quoter wins the hybrid quote race (currently `EXACT_INPUT`; broader coverage will follow once UniRoute's transformer ships). Omitting or setting `false` preserves the existing response shape. default `False`

## Request body (application/json)

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

Example:

```json
{
  "type": "EXACT_INPUT",
  "tokenInChainId": 1,
  "tokenOutChainId": 1,
  "generatePermitAsTransaction": false,
  "autoSlippage": "DEFAULT",
  "routingPreference": "BEST_PRICE",
  "spreadOptimization": "EXECUTION",
  "urgency": "normal",
  "permitAmount": "FULL",
  "amount": "2516",
  "tokenIn": "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599",
  "tokenOut": "0x0000000000000000000000000000000000000000",
  "swapper": "0xC9bebBA9f481b12cE6f3EA54c4B182c9636ec421",
  "protocols": [
    "UNISWAPX_V2",
    "V4",
    "V3",
    "V2"
  ]
}
```

## Responses

### 200: Quote request successful.

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

Example:

```json
{
  "requestId": "34784ef4-065a-4fa2-b77c-521f785fc068",
  "routing": "CLASSIC",
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
  "permitTransaction": null
}
```

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

