# PV1VaultRegistry

`0x770c1AA562f7DfA60934959585DaECf2d9AD32be`

Group: PonsVault v1.
V1 vault registry.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | yes |
| Contract name | `PonsVaultRegistry` |
| Compiler | v0.8.26+commit.8a97fa7a |
| Optimizer | True, runs 99999 |
| EVM version | cancun |
| License | none |
| Proxy type | none |
| Creator | `0x45e9E2A1BB0798dd3722c24f6bb31112dAf6DcD5` |
| Creation tx | `0x9b0972682c69f12947de8cf277d8247bd92e2801b0fda01a5bdf58a2dc0b9406` |

## Functions that matter for launching

- `lockRegistry()`

## Reads that matter

- `findVault(address token)`
- `locked()`

## Events

- `RegistryLockedForever()`

Full ABI in `abi.json`. Verified sources in `sources/`. Raw Blockscout response in `metadata.json`.
Counts: 6 state-changing functions, 9 views, 5 events, 4 custom errors.
