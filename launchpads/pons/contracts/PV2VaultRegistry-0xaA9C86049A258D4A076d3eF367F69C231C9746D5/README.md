# PV2VaultRegistry

`0xaA9C86049A258D4A076d3eF367F69C231C9746D5`

Group: PonsVault v2.
Maps a template id to the factory that builds it.

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
| Creator | `0x897ac30f73Ba92E1EFbC1dF1e67f8b5F4b3ECD2b` |
| Creation tx | `0xe205d77a7f7e7069b7c904dc7caf4dfa7cd86c89d9b5fdfd1fa26e372bfc4ea1` |

## Functions that matter for launching

- `lockRegistry()`

## Reads that matter

- `findVault(address token)`
- `locked()`

## Events

- `RegistryLockedForever()`

Full ABI in `abi.json`. Verified sources in `sources/`. Raw Blockscout response in `metadata.json`.
Counts: 6 state-changing functions, 9 views, 5 events, 4 custom errors.
