<!-- source: https://developers.uniswap.org/docs/api-reference/aggregator_quote | captured: 2026-08-22 | via: Firecrawl (rendered UI) -->
# Get a quote

Requests a quote according to the specified swap parameters. This endpoint may be used to get a quote for a swap, a bridge, or a wrap/unwrap. The resulting response includes a quote for the swap and the proposed route by which the quote was achieved. The response will also include estimated gas fees for the proposed quote route. If the proposed route is via a Uniswap Protocol pool, the response may include a permit2 message for the swapper to sign prior to making a /swap request. The proposed route will also be simulated. If the simulation fails, the response will include an error message or `txFailureReason`.

Certain routing options may be whitelisted by the requestor through the use of the `protocols` field. Further, the requestor may ask for the best price route or for the fastest price route through the 'routingPreference' field. Note that the fastest price route refers to the speed with which a quote is returned, not the number of transactions that may be required to get from the input token and chain to the output token and chain. Further note that all `routingPreference` values except for `FASTEST` and `BEST_PRICE` are deprecated. For more information on the `protocols` and `routingPreference` fields, see the [Token Trading Workflow](https://uniswap-docs.readme.io/reference/trading-flow#swap-routing) explanation of Swap Routing.

API integrators using this API for the benefit of customer end users may request a service fee be taken from the output token and deposited to a fee collection address. To request this, please reach out to your Uniswap Labs contact. This optional fee is associated to the API key and is always taken from the output token. Note if there is a fee and the `type` is `EXACT_INPUT`, the output amount quoted will **not** include the fee subtraction. If there is a fee and the `type` is `EXACT_OUTPUT`, the input amount quoted will **not** include the fee addition. Instead, in both cases, the fee will be recorded in the `portionBips` and `portionAmount` fields.

Native ETH on UniswapX: UniswapX routes (e.g. `DUTCH_V2`, `DUTCH_V3`, `PRIORITY`) can use native ETH as the input token by setting `tokenIn` to the native currency address (e.g. `0x0000000000000000000000000000000000000000`) and passing `x-erc20eth-enabled: true`. Native ETH input on UniswapX requires wallet support for EIP-7914, a smart wallet activated on your desired network, and a sufficient native allowance (set via /swap\_7702 if x-erc20eth-enabled header is set to `true`). If these requirements are not met, UniswapX quotes for native input may be omitted and the response may fall back to `CLASSIC` routing instead.

Read more

### AI Skill available

```
npx skills add uniswap/uniswap-ai --skill swap-integration
```

Full swap flow integration for apps. Works with Claude Code, Cursor, and other AI coding tools.

Also available:

```
npx skills add uniswap/uniswap-ai --skill swap-planner
```

## Authorization

`x-api-key`stringrequiredheader

Playground key

You're using a shared playground keyCreate a free account and get your own API keys from the dashboard.

[Get your keys](https://developers.uniswap.org/dashboard)

## Headers

`x-universal-router-version`enumdefault:2.0

2.02.1.12.2.0

Select x-universal-router-version

The version of the Universal Router to use for the swap journey. \*MUST\* be consistent throughout the API calls.

`x-erc20eth-enabled`booleandefault:false

Enable native ETH input support for UniswapX via ERC20-ETH (EIP-7914). When set to true and `tokenIn` is the native currency address (e.g. `0x0000000000000000000000000000000000000000`), the API may return UniswapX routes that spend native ETH for supported wallets.

`x-permit2-disabled`booleandefault:false

Disables the Permit2 approval flow. When set to `true`, `permitData` is returned as `null` and the header is forwarded to the routing layer for correct gas simulation against the Proxy Universal Router contract. When `false` or omitted, the standard Permit2 approval flow is used. This header is intended for integrators whose infrastructure uses a direct approval-then-swap pattern without Permit2.

## Body

application/json

`type`enumrequireddefault:EXACT\_INPUT

EXACT\_INPUTEXACT\_OUTPUT

EXACT\_INPUT

The handling of the `amount` field. `EXACT_INPUT` means the requester will send the specified `amount` of input tokens and get a quote with a variable quantity of output tokens. `EXACT_OUTPUT` means the requester will receive the specified `amount` of output tokens and get a quote with a variable quantity of input tokens.

`amount`stringrequired

The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0.

`tokenInChainId`enumrequireddefault:1

1105613013714319632448018684217432646635042845310143421614222043114570735914481457777777713018453211155111

1

The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs).

`tokenOutChainId`enumrequireddefault:1

1105613013714319632448018684217432646635042845310143421614222043114570735914481457777777713018453211155111

1

The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs).

`tokenIn`stringrequired

The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs).

`tokenOut`stringrequired

The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs).

`generatePermitAsTransaction`booleandefault:false

Indicates whether you want to receive a permit2 transaction to sign and submit onchain, or a permit message to sign. When set to `true`, the quote response returns the Permit2 as a calldata which the user signs and broadcasts. When set to `false` (the default), the quote response returns the Permit2 as a message which the user signs but does not need to broadcast. When using a 7702-delegated wallet, set this field to `true`. Except for this scenario, it is recommended that this field is set to false. Note that a Permit2 calldata (e.g. `true`), will provide indefinite permission for Permit2 to spend a token, in contrast to a Permit2 message (e.g. `false`) which is only valid for 30 days. Further, a Permit2 calldata (e.g. `true`) requires the user to pay gas to submit the transaction, whereas the Permit2 message (e.g. `false` ) does not require the user to submit a transaction and requires no gas.

`swapper`stringrequired

The wallet address which will be used to send the token.

`slippageTolerance`number

The slippage tolerance as a percentage up to a maximum of two decimal places. For Uniswap Protocols (v2, v3, v4), the slippage tolerance is the maximum amount the price can change between the time the transaction is submitted and the time it is executed. The slippage tolerance is a percentage of the total value of the swap.

When submitting a quote, note that slippage tolerance works differently in UniswapX swaps where it does not set a limit on the Spread in an order. See [here](https://api-docs.uniswap.org/guides/faqs#why-do-uniswapx-quotes-have-more-slippage-than-the-tolerance-i-set) for more information.

Note that if the trade type is `EXACT_INPUT`, then the slippage is in terms of the output token. If the trade type is `EXACT_OUTPUT`, then the slippage is in terms of the input token.

When submitting a request, `slippageTolerance` may not be set when `autoSlippage` is defined. One of `slippageTolerance` or `autoSlippage` must be defined.

`autoSlippage`enum

DEFAULT

Select autoSlippage

The auto slippage strategy to employ. For Uniswap Protocols (v2, v3, v4) the auto slippage will be automatically calculated when this field is set to `DEFAULT`. Auto slippage cannot be calculated for UniswapX swaps.

Note that if the trade type is `EXACT_INPUT`, then the slippage is in terms of the output token. If the trade type is `EXACT_OUTPUT`, then the slippage is in terms of the input token.

When submitting a request, `autoSlippage` may not be set when `slippageTolerance` is defined. One of `slippageTolerance` or `autoSlippage` must be defined.

`routingPreference`enumdefault:BEST\_PRICE

BEST\_PRICEFASTEST

Select routingPreference

The `routingPreference` specifies the preferred strategy to determine the quote. If the `routingPreference` is `BEST_PRICE`, then the quote will propose a route through the specified whitelisted protocols (or all, if none are specified) that provides the best price. When the `routingPreference` is `FASTEST`, the quote will propose the first route which is found to complete the swap.

`protocols`enum\[\]

V2V3V4UNISWAPXUNISWAPX\_V2UNISWAPX\_V3UNISWAPX\_LATEST

The protocols to use for the swap/order. If the `protocols` field is defined, then you can only set the `routingPreference` to `BEST_PRICE`. Note that the value `UNISWAPX` is deprecated and will be removed in a future release.

`hooksOptions`enum

V4\_HOOKS\_INCLUSIVEV4\_HOOKS\_ONLYV4\_NO\_HOOKS

Select hooksOptions

The hook options to use for V4 pool quotes. `V4_HOOKS_INCLUSIVE` will get quotes for V4 pools with or without hooks. `V4_HOOKS_ONLY` will only get quotes for V4 pools with hooks. `V4_NO_HOOKS` will only get quotes for V4 pools without hooks. Defaults to `V4_HOOKS_INCLUSIVE` if `V4` is included in `protocols` and `hookOptions` is not set. This field is ignored if `V4` is not passed in `protocols`.

`spreadOptimization`enumdefault:EXECUTION

EXECUTIONPRICE

Select spreadOptimization

For UniswapX swaps, when set to `EXECUTION`, quotes optimize for looser spreads at higher fill rates. When set to `PRICE`, quotes optimize for tighter spreads at lower fill rates. This field is not applicable to Uniswap Protocols (v2, v3, v4), bridging, or wrapping/unwrapping and will be ignored if set.

`urgency`enum \| UrgencyWithOverrides

urgency

`permitAmount`enumdefault:FULL

FULLEXACT

Select permitAmount

For Uniswap Protocols (v2, v3, v4) swaps, specify the input token spend allowance (e.g. quantity) to be set in the permit. `FULL` can be used to specify an unlimited token quantity, and may prevent the wallet from needing to sign another permit for the same token in the future. `EXACT` can be used to specify the exact input token quantity for this request. Defaults to `FULL`.

`recipient`string

(optional) The wallet address which will receive the output of the swap. If not provided, the output is returned to the `swapper`.

`integratorFees`object\[\]

## Response

200400401404429500504

Quote request successful.

`requestId`stringrequired

A unique ID for the request.

`quote`DutchQuote \| ClassicQuote \| WrapUnwrapQuote \| DutchQuoteV2 \| DutchQuoteV3 \| BridgeQuote \| PriorityQuote \| ChainedQuoterequired

Show nested schema

`routing`enumrequired

The routing for the proposed transaction.

`isTokenApprovalApplicable`boolean

Whether an ERC-20 token approval is applicable to this swap's input. `true` when the routing pulls the input token via an allowance, so an approval may be required — verify (or orchestrate) it via `/check_approval`. `false` when no approval is ever needed for this route (e.g. native-currency input, wrap/unwrap, or a native-gas-token input paid as native value). Reflects the routing mechanism, not the swapper's current on-chain allowance. If absent, assume an approval is applicable.

`permitTransaction`object

Show nested schema

`permitData`objectrequired

the permit2 message object for the customer to sign to permit spending by the permit2 contract.

Show nested schema

`permitGasFee`string

The total estimated gas cost of this transaction (eg. `gasLimit` multiplied by `maxFeePerGas`) in the base unit of the chain.

[API keys](https://developers.uniswap.org/dashboard)
Help

Feedback
[Status](https://statuspage.incident.io/uniswap-status) Legal

[GitHub](https://github.com/uniswap) [Discord](https://discord.gg/uniswap) [X](https://twitter.com/Uniswap)

POST`/quote`Send

Request

cURL

```
curl --request POST \
  --url 'https://trade-api.gateway.uniswap.org/v1/quote' \
  --header 'Content-Type: application/json' \
  --header 'x-api-key: <api-key>' \
  --header 'x-universal-router-version: 2.0' \
  --header 'x-erc20eth-enabled: false' \
  --header 'x-permit2-disabled: false' \
  --data '{
  "type": "EXACT_INPUT",
  "amount": "1000000000",
  "tokenInChainId": 1,
  "tokenOutChainId": 1,
  "tokenIn": "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
  "tokenOut": "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
  "swapper": "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045",
  "slippageTolerance": 0.5
}'
```

Response

200

```
{
  "requestId": "<string>",
  "quote": {
    "encodedOrder": "<string>",
    "orderId": "<string>",
    "orderInfo": {
      "chainId": "<number>",
      "nonce": "<string>",
      "reactor": "<string>",
      "swapper": "<string>",
      "deadline": "<number>",
      "additionalValidationContract": "<string>",
      "additionalValidationData": "<string>",
      "decayStartTime": "<number>",
      "decayEndTime": "<number>",
      "exclusiveFiller": "<string>",
      "exclusivityOverrideBps": "<string>",
      "input": {
        "startAmount": "<string>",
        "endAmount": "<string>",
        "token": "<string>"
      },
      "outputs": [\
        {\
          "startAmount": "<string>",\
          "endAmount": "<string>",\
          "token": "<string>",\
          "recipient": "<string>"\
        }\
      ]
    },
    "input": {
      "amount": "<string>",
      "token": "<string>",
      "maximumAmount": "<string>"
    },
    "output": {
      "amount": "<string>",
      "token": "<string>",
      "recipient": "<string>",
      "minimumAmount": "<string>"
    },
    "portionBips": "<number>",
    "portionAmount": "<string>",
    "portionRecipient": "<string>",
    "quoteId": "<string>",
    "slippageTolerance": "<number>",
    "classicGasUseEstimateUSD": "<string>",
    "aggregatedOutputs": [\
      {\
        "token": "<string>",\
        "amount": "<string>",\
        "recipient": "<string>",\
        "bps": "<number>",\
        "minAmount": "<string>",\
        "fee": "<string>"\
      }\
    ]
  },
  "routing": "<string>",
  "isTokenApprovalApplicable": "<boolean>",
  "permitTransaction": {
    "to": "<string>",
    "from": "<string>",
    "data": "<string>",
    "value": "<string>",
    "gasLimit": "<string>",
    "chainId": "<number>",
    "maxFeePerGas": "<string>",
    "maxPriorityFeePerGas": "<string>",
    "gasPrice": "<string>"
  },
  "permitData": {
    "domain": {},
    "values": {},
    "types": {}
  },
  "permitGasFee": "<string>"
}
```

Expand

Feedback