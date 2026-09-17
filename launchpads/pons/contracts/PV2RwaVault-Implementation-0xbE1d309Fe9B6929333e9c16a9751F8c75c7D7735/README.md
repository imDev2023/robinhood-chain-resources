# PV2RwaVault-Implementation

`0xbE1d309Fe9B6929333e9c16a9751F8c75c7D7735`

Group: PonsVault v2.
Unverified. Beacon implementation for RWA Dividend vaults.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | no |
| Creator | `0x897ac30f73Ba92E1EFbC1dF1e67f8b5F4b3ECD2b` |
| Creation tx | `0xc0ed9f861aa676ceb172a0b98bb694a7290862d38c6546c40b046ae7996827c0` |

## Identification

Not verified on Blockscout. Runtime bytecode is in `bytecode.hex` (18191 bytes), fetched with `eth_getCode` at the 2026-09-02 head.

Function selectors found in the bytecode: 37. Matched against every verified Pons ABI in this archive plus the names the docs use:

- `description()`
- `isNativeQuote()`
- `roundCount()`
- `template()`
- `token()`

Unmatched selectors are recoverable from `bytecode.hex` with the same PUSH4 scan.
