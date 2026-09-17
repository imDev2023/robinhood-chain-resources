# PV1BuybackBurnVaultFactory

`0x3926af4490b4ba5af78D785DD9BA527b383c1B1e`

Group: PonsVault v1.
Verified. Deploys V1 Buyback and Burn vaults as beacon proxies.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | yes |
| Contract name | `PonsBuybackBurnVaultFactory` |
| Compiler | v0.8.26+commit.8a97fa7a |
| Optimizer | True, runs 99999 |
| EVM version | cancun |
| License | none |
| Proxy type | basic_implementation |
| Implementation | `0x6396c3cD9eA6fD621e7f41DaD72ca56dFe069414` |
| Creator | `0x45e9E2A1BB0798dd3722c24f6bb31112dAf6DcD5` |
| Creation tx | `0x993a5b0d42b040b06b9055c3c393e6e0fcd33c58234f197ab203bda10d9102e9` |

## Functions that matter for launching

- `createVault(address token, address locker, bytes config)`
- `lockUpgrades()`
- `upgradeVaultImplementation(address newImplementation)`

## Reads that matter

- `isUpgradesLocked()`
- `vaultCount()`
- `vaultOf(address token)`
- `vaults(uint256 )`

## Events

- `UpgradesLocked()`
- `VaultCreated(address token, address vault, address creator)`

Full ABI in `abi.json`. Verified sources in `sources/`. Raw Blockscout response in `metadata.json`.
Counts: 6 state-changing functions, 9 views, 4 events, 2 custom errors.
