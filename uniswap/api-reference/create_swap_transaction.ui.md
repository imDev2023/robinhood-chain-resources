<!-- source: https://developers.uniswap.org/docs/api-reference/create_swap_transaction | captured: 2026-08-22 | via: Firecrawl (rendered UI) -->
# Create swap calldata

Create the calldata for a swap transaction (including wrap/unwrap) against the Uniswap Protocols. If the `quote` parameter includes the fee parameters, then the calldata will include the fee disbursement. The gas estimates will be **more precise** when the the response calldata would be valid if submitted on-chain.

### AI Skill available

```
npx skills add uniswap/uniswap-ai --skill swap-integration
```

Full swap flow integration for apps. Works with Claude Code, Cursor, and other AI coding tools.

Also available:

```
npx skills add uniswap/uniswap-ai --skill swap-planner
```

Get a QuoteThis endpoint requires a quote response from the Quote API.

Fetch get a quote

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

`x-permit2-disabled`booleandefault:false

Disables the Permit2 approval flow. When set to `true`, `permitData` is returned as `null` and the header is forwarded to the routing layer for correct gas simulation against the Proxy Universal Router contract. When `false` or omitted, the standard Permit2 approval flow is used. This header is intended for integrators whose infrastructure uses a direct approval-then-swap pattern without Permit2.

## Body

application/json

`quote`ClassicQuote \| WrapUnwrapQuote \| BridgeQuoterequired

ClassicQuote

`signature`string

The signed permit.

`includeGasInfo`booleandefault:false

Use `refreshGasPrice` instead.

`refreshGasPrice`booleandefault:false

If true, the gas price will be re-fetched from the network.

`simulateTransaction`booleandefault:false

If true, the transaction will be simulated. If the simulation results on an onchain error, endpoint will return an error.

`permitData`object

`safetyMode`enum

SAFE

Select safetyMode

Swap safety mode will automatically sweep the transaction for the native token and return it to the sender wallet address. This is to prevent accidental loss of funds in the event that the token amount is set in the transaction value instead of as part of the calldata.

`deadline`number

The unix timestamp at which the order will be reverted if not filled.

`urgency`enum \| UrgencyWithOverrides

urgency

## Response

200400401404429500504

Create swap successful.

`requestId`stringrequired

A unique ID for the request.

`swap`objectrequired

Show nested schema

`gasFee`string

The total estimated gas cost of this transaction (eg. `gasLimit` multiplied by `maxFeePerGas`) in the base unit of the chain.

[API keys](https://developers.uniswap.org/dashboard)
Help

Feedback
[Status](https://statuspage.incident.io/uniswap-status) Legal

[GitHub](https://github.com/uniswap) [Discord](https://discord.gg/uniswap) [X](https://twitter.com/Uniswap)

POST`/swap`Send

Request

cURL

```
curl --request POST \
  --url 'https://trade-api.gateway.uniswap.org/v1/swap' \
  --header 'Content-Type: application/json' \
  --header 'x-api-key: <api-key>' \
  --header 'x-universal-router-version: 2.0' \
  --header 'x-permit2-disabled: false'
```

Response

200

```
{
  "requestId": "<string>",
  "swap": {
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
  "gasFee": "<string>"
}
```

Feedback