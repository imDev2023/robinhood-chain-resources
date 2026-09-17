# PV2RwaVaultBeaconOwner

`0x64946a452d9e1f5f47cef448cab6ad5322f1a9f9`

Group: PonsVault v2.
Unverified. Owns the RWA beacon. Deployed by the same EOA as every other PonsVault contract, `0x897ac30f73…`.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | no |
| Implementation | `0xcd5a5EaEfBc504CcDed34B882889383255D6f9e3` |
| Creator | `0x897ac30f73Ba92E1EFbC1dF1e67f8b5F4b3ECD2b` |
| Creation tx | `0x741e50b2f11d2627fd2ed4d9bfe7c6bd5c3845a91b0e8893effb80edc90c82a4` |

## Identification

Not verified on Blockscout. Runtime bytecode is in `bytecode.hex` (6970 bytes), fetched with `eth_getCode` at the 2026-09-02 head.

Function selectors found in the bytecode: 17. Matched against every verified Pons ABI in this archive plus the names the docs use:

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
