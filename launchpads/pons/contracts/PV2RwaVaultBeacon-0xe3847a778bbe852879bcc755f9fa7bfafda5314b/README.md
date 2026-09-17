# PV2RwaVaultBeacon

`0xe3847a778bbe852879bcc755f9fa7bfafda5314b`

Group: PonsVault v2.
UpgradeableBeacon for RWA Dividend vaults. `implementation()` = `0xcd5a5eae…`, `owner()` = `0x64946a45…`.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | no |
| Implementation | `0xcd5a5EaEfBc504CcDed34B882889383255D6f9e3` |
| Creator | `0x64946A452d9e1f5F47Cef448CAB6aD5322f1a9F9` |
| Creation tx | `0x741e50b2f11d2627fd2ed4d9bfe7c6bd5c3845a91b0e8893effb80edc90c82a4` |

## Identification

Not verified on Blockscout. Runtime bytecode is in `bytecode.hex` (1159 bytes), fetched with `eth_getCode` at the 2026-09-02 head.

Function selectors found in the bytecode: 5. Matched against every verified Pons ABI in this archive plus the names the docs use:

- `implementation()`
- `owner()`
- `renounceOwnership()`
- `transferOwnership(address)`
- `upgradeTo(address)`

Unmatched selectors are recoverable from `bytecode.hex` with the same PUSH4 scan.
