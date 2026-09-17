# V2LaunchAndBuy

`0xe33E9E479dF8802cb0866d5d05258bEc4cF62948`

Group: pons v2.
Optional router that creates a launch and buys into it in one transaction.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | yes |
| Contract name | `PonsV2LaunchAndBuy` |
| Compiler | 0.8.35+commit.47b9dedd |
| Optimizer | True, runs 200 |
| EVM version | cancun |
| License | none |
| Proxy type | none |
| Creator | `0xFdDE5a1E3cDF791Da71E49F817D70C7ceD72CC36` |
| Creation tx | `0x4be522d489114cf455739c26e676f7eb2a74d04c1fabb4f21e906d02802c016d` |

## Constructor arguments

- `factory_` (contract PonsV2LaunchFactory) = `0x7eD598BcEf8bd9Edd8C97A195C6d13f40801EC7e`
- `owner_` (address) = `0xFdDE5a1E3cDF791Da71E49F817D70C7ceD72CC36`

## Functions that matter for launching

- `launchAndBuy(tuple params, uint256 launchConfigId, address pairToken, uint256 quoteIn, uint256 minTokensOut, address recipient, address[] snipeTaxExemptions)` payable

## Events

- `Launched(address token, address curve, address recipient, address launcher, uint256 quoteSpent, uint256 tokensReceived)`

Full ABI in `abi.json`. Verified sources in `sources/`. Raw Blockscout response in `metadata.json`.
Counts: 5 state-changing functions, 3 views, 4 events, 9 custom errors.
