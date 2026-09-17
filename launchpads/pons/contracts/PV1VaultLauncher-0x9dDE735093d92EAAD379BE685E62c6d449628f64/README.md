# PV1VaultLauncher

`0x9dDE735093d92EAAD379BE685E62c6d449628f64`

Group: PonsVault v1.
Verified. Constructor points at the V1 pons factory, the V1 locker and the V1 vault registry.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | yes |
| Contract name | `PonsVaultLauncher` |
| Compiler | v0.8.26+commit.8a97fa7a |
| Optimizer | True, runs 99999 |
| EVM version | cancun |
| License | none |
| Proxy type | none |
| Creator | `0x45e9E2A1BB0798dd3722c24f6bb31112dAf6DcD5` |
| Creation tx | `0xa80e85067e226720057ded42c167011871bba2a28d550f9929990fb828986ac6` |

## Constructor arguments

- `_launchpad` (contract IPonsLaunchpad) = `0xA5aAb3F0c6EeadF30Ef1D3Eb997108E976351feB`
- `_locker` (address) = `0x736D76699C26D0d966744cAe304C000d471f7F35`
- `_registry` (contract PonsVaultRegistry) = `0x770c1AA562f7DfA60934959585DaECf2d9AD32be`

## Functions that matter for launching

- `launchWithVault(tuple metadata, uint256 launchConfigId, uint256 dexId, bytes32 salt, bytes32 templateId, bytes vaultConfig)` payable
- `sweepToCreator(address token)`

## Reads that matter

- `creatorOf(address token)`
- `launchpad()`
- `locker()`
- `vaultOf(address token)`

## Events

- `Launched(address token, address vault, address creator, bytes32 templateId)`
- `SweptToCreator(address token, address creator, uint256 amount)`

Full ABI in `abi.json`. Verified sources in `sources/`. Raw Blockscout response in `metadata.json`.
Counts: 3 state-changing functions, 6 views, 2 events, 5 custom errors.
