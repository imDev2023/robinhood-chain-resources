# Uniswap Trading API reference (generated from OpenAPI)

Base URL: `https://trade-api.gateway.uniswap.org/v1`. Auth: `x-api-key` header (get keys at https://developers.uniswap.org/dashboard). Liquidity API base: `https://liquidity.api.uniswap.org`.

Source: the OpenAPI 3.0 spec embedded in the developers.uniswap.org API reference app, captured 2026-08-22 and saved verbatim as `openapi-trading-api.json`. The `*.ui.md` files are rendered-page captures of the same endpoints.

| Method | Path | operationId | Summary |
| --- | --- | --- | --- |
| POST | `/check_approval` | [`check_approval`](check_approval.md) | Check swap approvals |
| POST | `/permissions` | [`permissions`](permissions.md) | Check token KYC permissions |
| POST | `/quote` | [`aggregator_quote`](aggregator_quote.md) | Get a quote |
| POST | `/order` | [`post_order`](post_order.md) | Create a gasless order |
| GET | `/orders` | [`get_order`](get_order.md) | Get gasless order status |
| POST | `/swap` | [`create_swap_transaction`](create_swap_transaction.md) | Create swap calldata |
| GET | `/swaps` | [`get_swaps`](get_swaps.md) | Get swap status |
| GET | `/swappable_tokens` | [`get_swappable_tokens`](get_swappable_tokens.md) | Get bridgable tokens |
| GET | `/supported_chains` | [`get_supported_chains`](get_supported_chains.md) | Get supported chains |
| POST | `/limit_order_quote` | [`get_limit_order_quote`](get_limit_order_quote.md) | Get a limit order quote |
| POST | `/lp/check_approval` | [`check_lp_approval`](check_lp_approval.md) | Check LP token approvals |
| POST | `/lp/create` | [`create_position`](create_position.md) | Create a V3 or V4 LP position |
| POST | `/lp/increase` | [`increase_position`](increase_position.md) | Increase an LP position |
| POST | `/lp/decrease` | [`decrease_position`](decrease_position.md) | Decrease an LP position |
| POST | `/lp/claim_fees` | [`claim_fees`](claim_fees.md) | Claim LP position fees |
| POST | `/lp/create_classic` | [`create_classic_position`](create_classic_position.md) | Create a classic (V2) LP position |
| POST | `/lp/pool_info` | [`pool_info`](pool_info.md) | Get pool state |
| POST | `/wallet/encode_7702` | [`wallet_encode_7702`](wallet_encode_7702.md) | Encode wallet transactions |
| POST | `/wallet/check_delegation` | [`wallet_check_delegation`](wallet_check_delegation.md) | Get wallet delegations |
| POST | `/swap_5792` | [`create_swap_5792_transaction`](create_swap_5792_transaction.md) | Create swap EIP 5792 calldata |
| POST | `/swap_7702` | [`create_swap_7702_transaction`](create_swap_7702_transaction.md) | Create swap EIP 7702 calldata |
| POST | `/swap_4337` | [`create_swap_4337_transaction`](create_swap_4337_transaction.md) | Create swap ERC-4337 UserOperation |
| POST | `/check_approval_4337` | [`check_approval_4337`](check_approval_4337.md) | Create approval ERC-4337 UserOperation |
| POST | `/plan` | [`create_plan`](create_plan.md) | Create an execution plan |
| GET | `/plan/{planId}` | [`get_plan`](get_plan.md) | Get an execution plan |
| PATCH | `/plan/{planId}` | [`update_plan`](update_plan.md) | Update an execution plan |
| POST | `/wallet/encode_4337` | [`encode_4337`](encode_4337.md) | Encode ERC-4337 UserOperation |

All 234 schema definitions: [schemas.md](schemas.md).
