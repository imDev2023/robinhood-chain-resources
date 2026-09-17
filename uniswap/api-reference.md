<!-- source: https://developers.uniswap.org/docs/api-reference | captured: 2026-08-22 | via: Firecrawl (JS-rendered API reference) -->
# Check swap approvals

Allows the requestor to check if the `walletAddress` has the required approval to transact the `token` up to the `amount` specified. If the `walletAddress` does not have the required approval, the response will include a transaction to approve the token spend. If the `walletAddress` has the required approval, the response will return the approval with a `null` value. If the parameter `includeGasInfo` is set to `true` and an approval is needed, then the response will include both the transaction and the gas fee for the approval transaction.

Certain tokens may require that approval be reset before approving a new spend amount. If this condition is detected for the `walletAddress` and `token`, the response will include the necessary approval cancellation in the `cancel` paragraph. When `cancel` is not applicable, the paragraph will have a `null` value.

Read more

### AI Skill available

```
npx skills add uniswap/uniswap-ai --skill swap-integration
```

Full swap flow integration for apps. Works with Claude Code, Cursor, and other AI coding tools.

## Authorization

`x-api-key`stringrequiredheader

Playground key

You're using a shared playground keyCreate a free account and get your own API keys from the dashboard.

[Get your keys](https://developers.uniswap.org/dashboard)

## Headers

`x-permit2-disabled`booleandefault:false

Disables the Permit2 approval flow. When set to `true`, `permitData` is returned as `null` and the header is forwarded to the routing layer for correct gas simulation against the Proxy Universal Router contract. When `false` or omitted, the standard Permit2 approval flow is used. This header is intended for integrators whose infrastructure uses a direct approval-then-swap pattern without Permit2.

## Body

application/json

`walletAddress`stringrequired

The wallet address which will be used to send the token.

`token`stringrequired

The token which will be sent, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs).

`amount`stringrequired

The quantity of tokens denominated in the token's base units. (For example, for an ERC20 token one token is 1x10^18 base units. For one USDC token one token is 1x10^6 base units.) This value must be greater than 0.

`chainId`enumrequireddefault:1

1105613013714319632448018684217432646635042845310143421614222043114570735914481457777777713018453211155111

1

The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs).

`urgency`enum \| UrgencyWithOverrides

urgency

`includeGasInfo`booleandefault:false

If set to `true`, the response will include the estimated gas fee for the proposed transaction.

`tokenOut`string

The token which will be received, specified by its token address. For a list of supported tokens, see the [FAQ](https://api-docs.uniswap.org/guides/faqs).

`tokenOutChainId`enumdefault:1

1105613013714319632448018684217432646635042845310143421614222043114570735914481457777777713018453211155111

Select tokenOutChainId

The unique ID of the blockchain. For a list of supported chains see the [FAQ](https://api-docs.uniswap.org/guides/faqs).

## Response

200400401404429500504

Check approval successful.

`requestId`stringrequired

A unique ID for the request.

`approval`objectrequired

Show nested schema

`cancel`objectrequired

Show nested schema

`gasFee`string

The total estimated gas cost of this transaction (eg. `gasLimit` multiplied by `maxFeePerGas`) in the base unit of the chain.

`cancelGasFee`string

The total estimated gas cost of this transaction (eg. `gasLimit` multiplied by `maxFeePerGas`) in the base unit of the chain.

[API keys](https://developers.uniswap.org/dashboard)
Help

Feedback
[Status](https://statuspage.incident.io/uniswap-status) Legal

[GitHub](https://github.com/uniswap) [Discord](https://discord.gg/uniswap) [X](https://twitter.com/Uniswap)

POST`/check_approval`Send

Request

cURL

```
curl --request POST \
  --url 'https://trade-api.gateway.uniswap.org/v1/check_approval' \
  --header 'Content-Type: application/json' \
  --header 'x-api-key: <api-key>' \
  --header 'x-permit2-disabled: false' \
  --data '{
  "walletAddress": "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045",
  "token": "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
  "amount": "1000000000",
  "chainId": 1
}'
```

Response

200

```
{
  "requestId": "<string>",
  "approval": {
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
  "cancel": {
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
  "gasFee": "<string>",
  "cancelGasFee": "<string>"
}
```

Expand

Feedback