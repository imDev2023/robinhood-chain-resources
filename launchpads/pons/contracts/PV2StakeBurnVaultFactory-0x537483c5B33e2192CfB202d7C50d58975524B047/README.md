# PV2StakeBurnVaultFactory

`0x537483c5B33e2192CfB202d7C50d58975524B047`

Group: PonsVault v2.
Unverified beacon factory named in the PonsVault docs, for the himgajria partner desk. No live launch in the 40-launch sample used it.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | no |
| Implementation | `0x65b2eAaA7ae4eCC144494070aD6F2A3AD13A47d9` |
| Creator | `0x897ac30f73Ba92E1EFbC1dF1e67f8b5F4b3ECD2b` |
| Creation tx | `0x8c828f5f2be8241c0d2578eb1a1b9837733a1e26f97c2c1cf15694a54b6ad06d` |

## Identification

Not verified on Blockscout. Runtime bytecode is in `bytecode.hex` (6565 bytes), fetched with `eth_getCode` at the 2026-09-02 head.

Function selectors found in the bytecode: 19. Matched against every verified Pons ABI in this archive plus the names the docs use:

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
- `upgradeVaultImplementation(address)`
- `vaultCount()`
- `vaultOf(address)`
- `vaults(uint256)`

Unmatched selectors are recoverable from `bytecode.hex` with the same PUSH4 scan.
