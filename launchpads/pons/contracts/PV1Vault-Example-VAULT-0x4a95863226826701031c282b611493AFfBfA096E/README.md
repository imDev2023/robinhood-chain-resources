# PV1Vault-Example-VAULT

`0x4a95863226826701031c282b611493AFfBfA096E`

Group: PonsVault v1.
BeaconProxy. The live Buyback and Burn vault for the VAULT token.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | yes |
| Contract name | `BeaconProxy` |
| Compiler | v0.8.26+commit.8a97fa7a |
| Optimizer | True, runs 10000 |
| EVM version | cancun |
| License | none |
| Proxy type | eip1967_beacon |
| Implementation | `0x6396c3cD9eA6fD621e7f41DaD72ca56dFe069414` |
| Creator | `0x3926af4490B4BA5Af78d785DD9Ba527B383C1B1e` |
| Creation tx | `0x5d99d7dae0a908e00eeb122d95379a647f7b7a9996c8118b3abb99b28db8c97f` |

## Constructor arguments

- `beacon` (address) = `0x95bEf3Ba39ED9C5aDb265A714ce90c3E102e9B7E`
- `data` (bytes) = `0x6a430618000000000000000000000000fdae23ce76018da62507bb5ef20e6ef5450e8312000000000000000000000000736d76699c26d0d966744cae304c000d471f7f350000000000000000000000009dde735093d92eaad379be685e62c6d449628f640000000000000000000000000000000000000000000000000000000000000fa000000000000000000000000015acd9471590ba79f06524c2bd1cac47a688f0600000000000000000000000000000000000000000000000000058d15e17628000`

## Functions that matter for launching


## Events

- `AdminChanged(address previousAdmin, address newAdmin)`
- `BeaconUpgraded(address beacon)`
- `Upgraded(address implementation)`

Full ABI in `abi.json`. Verified sources in `sources/`. Raw Blockscout response in `metadata.json`.
Counts: 0 state-changing functions, 0 views, 3 events, 0 custom errors.
