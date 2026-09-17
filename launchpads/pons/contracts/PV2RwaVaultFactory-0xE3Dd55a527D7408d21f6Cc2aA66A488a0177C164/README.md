# PV2RwaVaultFactory

`0xE3Dd55a527D7408d21f6Cc2aA66A488a0177C164`

Group: PonsVault v2.
Unverified beacon factory named in the PonsVault docs. The live launch flow calls `0x7e344f13…` instead.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | no |
| Implementation | `0xbE1d309Fe9B6929333e9c16a9751F8c75c7D7735` |
| Creator | `0x897ac30f73Ba92E1EFbC1dF1e67f8b5F4b3ECD2b` |
| Creation tx | `0xf41b3ad1453288c1a4bdadd2864cd0ed8b0b8be3fe08b25f69c31c5c5c107a7b` |

## Identification

Not verified on Blockscout. Runtime bytecode is in `bytecode.hex` (5716 bytes), fetched with `eth_getCode` at the 2026-09-02 head.

Function selectors found in the bytecode: 20. Matched against every verified Pons ABI in this archive plus the names the docs use:

- `acceptOwnership()`
- `beacon()`
- `createVault(address,address,bytes)`
- `implementation()`
- `lockUpgrades()`
- `owner()`
- `pendingOwner()`
- `renounceOwnership()`
- `template()`
- `transferOwnership(address)`
- `upgradeTo(address)`
- `upgradeVaultImplementation(address)`
- `vaultCount()`
- `vaultOf(address)`
- `vaults(uint256)`

Unmatched selectors are recoverable from `bytecode.hex` with the same PUSH4 scan.
