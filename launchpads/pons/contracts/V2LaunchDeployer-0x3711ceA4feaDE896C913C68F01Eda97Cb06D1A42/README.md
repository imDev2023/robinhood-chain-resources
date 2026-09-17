# V2LaunchDeployer

`0x3711ceA4feaDE896C913C68F01Eda97Cb06D1A42`

Group: pons v2.
CREATE2 deployer for each launch's curve and token. predictLaunchAddresses.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | yes |
| Contract name | `PonsV2LaunchDeployer` |
| Compiler | 0.8.35+commit.47b9dedd |
| Optimizer | True, runs 200 |
| EVM version | cancun |
| License | none |
| Proxy type | none |
| Creator | `0xFdDE5a1E3cDF791Da71E49F817D70C7ceD72CC36` |
| Creation tx | `0x849d092ee4ed37d8138636839c28aabd2878e445cb68ba99c4cdafa11a778b2e` |

## Constructor arguments

- `factory_` (address) = `0x7eD598BcEf8bd9Edd8C97A195C6d13f40801EC7e`

## Functions that matter for launching

- `deployLaunch(tuple params)`

## Reads that matter

- `predictLaunchAddresses(tuple params)`

Full ABI in `abi.json`. Verified sources in `sources/`. Raw Blockscout response in `metadata.json`.
Counts: 1 state-changing functions, 2 views, 0 events, 5 custom errors.
