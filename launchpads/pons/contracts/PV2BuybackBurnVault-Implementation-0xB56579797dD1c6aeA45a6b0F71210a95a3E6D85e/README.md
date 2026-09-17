# PV2BuybackBurnVault-Implementation

`0xB56579797dD1c6aeA45a6b0F71210a95a3E6D85e`

Group: PonsVault v2.
Unverified. Beacon implementation for Buyback and Burn vaults.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | no |
| Creator | `0x897ac30f73Ba92E1EFbC1dF1e67f8b5F4b3ECD2b` |
| Creation tx | `0xc38f505c78e24b3e6e1306de83481ae5d3ac0d382c1e57805432eaca9b35ac1a` |

## Identification

Not verified on Blockscout. Runtime bytecode is in `bytecode.hex` (11466 bytes), fetched with `eth_getCode` at the 2026-09-02 head.

Function selectors found in the bytecode: 24. Matched against every verified Pons ABI in this archive plus the names the docs use:

- `description()`
- `factory()`
- `isNativeQuote()`
- `template()`
- `token()`

Unmatched selectors are recoverable from `bytecode.hex` with the same PUSH4 scan.
