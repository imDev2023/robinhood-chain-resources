<!-- source: https://developers.uniswap.org/docs/api-reference/create_classic_position | captured: 2026-08-22 | via: Firecrawl (rendered UI) -->
# Create a classic (V2) LP position

Creates a full-range liquidity position in a Uniswap V2 pool. Specify the independent token and amount; the server computes the dependent token amount based on the current pool ratio. If `simulateTransaction` is set to `true`, the response will include the gas fee for the creation transaction.

### AI Skill available

```
npx skills add uniswap/uniswap-ai --skill liquidity-planner
```

Plan LP positions with deep links. Works with Claude Code, Cursor, and other AI coding tools.

## Authorization

`x-api-key`stringrequiredheader

Playground key

You're using a shared playground keyCreate a free account and get your own API keys from the dashboard.

[Get your keys](https://developers.uniswap.org/dashboard)

## Body

application/json

`walletAddress`stringrequired

`poolParameters`objectrequired

`independentToken`objectrequired

`dependentToken`object

`slippageTolerance`number

Slippage tolerance as a decimal (e.g., 0.5 for 0.5%).

`deadline`integer

Transaction deadline in seconds.

`simulateTransaction`boolean

If true, the response will include the gas fee.

`urgency`enum

NORMALFASTURGENT

Select urgency

The urgency level for gas price estimation. Higher urgency results in higher gas price and faster transaction inclusion. Defaults to URGENT if not provided.

`includeApprovalSimulation`boolean

If true, the response will include approval simulation data.

## Response

200400401404429500504

Create classic (V2) position successful.

`requestId`stringrequired

A unique ID for the request.

`independentToken`objectrequired

A token with its address and amount, used in LP operations.

Show nested schema

`dependentToken`objectrequired

A token with its address and amount, used in LP operations.

Show nested schema

`create`objectrequired

Show nested schema

`gasFee`string

The total estimated gas cost of this transaction (eg. `gasLimit` multiplied by `maxFeePerGas`) in the base unit of the chain.

[API keys](https://developers.uniswap.org/dashboard)
Help

Feedback
[Status](https://statuspage.incident.io/uniswap-status) Legal

[GitHub](https://github.com/uniswap) [Discord](https://discord.gg/uniswap) [X](https://twitter.com/Uniswap)

POST`/lp/create_classic`Send

Request

cURL

```
curl --request POST \
  --url 'https://liquidity.api.uniswap.org/lp/create_classic' \
  --header 'Content-Type: application/json' \
  --header 'x-api-key: <api-key>' \
  --data '{
  "walletAddress": "<string>",
  "poolParameters": "<object>",
  "independentToken": "<object>"
}'
```

Response

200

```
{
  "requestId": "<string>",
  "independentToken": {
    "tokenAddress": "<string>",
    "amount": "<string>"
  },
  "dependentToken": {
    "tokenAddress": "<string>",
    "amount": "<string>"
  },
  "create": {
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

Expand

Feedback