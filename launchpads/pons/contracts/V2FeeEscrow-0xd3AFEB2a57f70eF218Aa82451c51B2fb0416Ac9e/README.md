# V2FeeEscrow

`0xd3AFEB2a57f70eF218Aa82451c51B2fb0416Ac9e`

Group: pons v2.
Claim-based ledger of protocol and creator balances in ETH and ERC-20.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | yes |
| Contract name | `V2FeeEscrow` |
| Compiler | v0.8.35+commit.47b9dedd |
| Optimizer | True, runs 200 |
| EVM version | cancun |
| License | none |
| Proxy type | none |
| Creator | `0xFdDE5a1E3cDF791Da71E49F817D70C7ceD72CC36` |
| Creation tx | `0xf0a6e026cbd00d98b63df9e4aa65d1554675ef3f33e696f5e13ca0a7c3d124af` |

## Functions that matter for launching

- `claim(uint256 amount)`
- `claim()`
- `claimToken(address token, uint256 amount)`
- `claimToken(address token)`

## Events

- `Claimed(address recipient, uint256 amount)`
- `ClaimedToken(address recipient, address token, uint256 amount)`

Full ABI in `abi.json`. Verified sources in `sources/`. Raw Blockscout response in `metadata.json`.
Counts: 6 state-changing functions, 2 views, 4 events, 6 custom errors.
