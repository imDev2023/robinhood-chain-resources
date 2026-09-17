<!-- source: https://developers.uniswap.org/docs/api-reference/increase_position | captured: 2026-08-22 | via: Firecrawl (rendered UI) -->
# Increase an LP position

Increases liquidity in an existing position. Specify the independent token and amount; the server derives the dependent token amount from the current pool state. Supports V2 (by token pair), V3, and V4 (by NFT token ID). If `simulateTransaction` is set to `true`, the response will include the gas fee.

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

`chainId`enumrequireddefault:1

1105613013714319632448018684217432646635042845310143421614222043114570735914481457777777713018453211155111

1

The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs).

`protocol`enumrequired

V2V3V4

Select protocol

The protocol of the pool.

`token0Address`stringrequired

`token1Address`stringrequired

`nftTokenId`string

The NFT token ID for V3/V4 positions. Not required for V2.

`independentToken`objectrequired

`slippageTolerance`number

Slippage tolerance as a decimal (e.g., 0.5 for 0.5%).

`deadline`integer

Unix timestamp after which the transaction will revert.

`simulateTransaction`boolean

If true, the response will include the gas fee.

`v4BatchPermitData`object

`signature`string

The signed permit.

`urgency`enum

NORMALFASTURGENT

Select urgency

The urgency level for gas price estimation. Higher urgency results in higher gas price and faster transaction inclusion. Defaults to URGENT if not provided.

## Response

200400401404429500504

Increase position successful.

`requestId`stringrequired

A unique ID for the request.

`token0`objectrequired

A token with its address and amount, used in LP operations.

Show nested schema

`token1`objectrequired

A token with its address and amount, used in LP operations.

Show nested schema

`increase`objectrequired

Show nested schema

`gasFee`string

The total estimated gas cost of this transaction (eg. `gasLimit` multiplied by `maxFeePerGas`) in the base unit of the chain.

[API keys](https://developers.uniswap.org/dashboard)
Help

Feedback
[Status](https://statuspage.incident.io/uniswap-status) Legal

[GitHub](https://github.com/uniswap) [Discord](https://discord.gg/uniswap) [X](https://twitter.com/Uniswap)

POST`/lp/increase`Send

Request

cURL

```
curl --request POST \
  --url 'https://liquidity.api.uniswap.org/lp/increase' \
  --header 'Content-Type: application/json' \
  --header 'x-api-key: <api-key>' \
  --data '{
  "walletAddress": "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045",
  "chainId": 1,
  "protocol": "<enum>",
  "token0Address": "<string>",
  "token1Address": "<string>",
  "independentToken": "<object>"
}'
```

Response

200

```
{
  "requestId": "<string>",
  "token0": {
    "tokenAddress": "<string>",
    "amount": "<string>"
  },
  "token1": {
    "tokenAddress": "<string>",
    "amount": "<string>"
  },
  "increase": {
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