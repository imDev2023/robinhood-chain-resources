# Permit2

`0x000000000022D473030F116dDEE9F6B43aC78BA3`

Group: Uniswap.
Used by the graduation executor to move the pair token into the position manager.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | yes |
| Contract name | `Permit2` |
| Compiler | v0.8.17+commit.8df45f5f |
| Optimizer | True, runs 1000000 |
| EVM version | london |
| License | none |
| Proxy type | none |

## Functions that matter for launching

- `lockdown(tuple[] approvals)`

## Events

- `Lockdown(address owner, address token, address spender)`

Full ABI in `abi.json`. Verified sources in `sources/`. Raw Blockscout response in `metadata.json`.
Counts: 12 state-changing functions, 3 views, 5 events, 11 custom errors.
