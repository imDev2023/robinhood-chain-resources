# PV2RwaVault-Implementation-Live

`0xcd5a5eaefbc504ccded34b882889383255d6f9e3`

Group: PonsVault v2.
Unverified. Current implementation behind the RWA beacon.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | no |
| Creator | `0x64946A452d9e1f5F47Cef448CAB6aD5322f1a9F9` |
| Creation tx | `0x741e50b2f11d2627fd2ed4d9bfe7c6bd5c3845a91b0e8893effb80edc90c82a4` |

## Identification

Not verified on Blockscout. Runtime bytecode is in `bytecode.hex` (23484 bytes), fetched with `eth_getCode` at the 2026-09-02 head.

Function selectors found in the bytecode: 46. Matched against every verified Pons ABI in this archive plus the names the docs use:

- `description()`
- `isNativeQuote()`
- `roundCount()`
- `template()`
- `token()`

Unmatched selectors are recoverable from `bytecode.hex` with the same PUSH4 scan.
