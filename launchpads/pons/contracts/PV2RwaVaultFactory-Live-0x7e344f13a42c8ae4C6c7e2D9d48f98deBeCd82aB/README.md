# PV2RwaVaultFactory-Live

`0x7e344f13a42c8ae4C6c7e2D9d48f98deBeCd82aB`

Group: PonsVault v2.
Unverified. The vault factory the live flow calls for both RWA Dividend and Buyback and Burn launches. `template()` returns `rwa`. 20 vaults built.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | no |
| Implementation | `0xcd5a5EaEfBc504CcDed34B882889383255D6f9e3` |
| Creator | `0x897ac30f73Ba92E1EFbC1dF1e67f8b5F4b3ECD2b` |
| Creation tx | `0x395179e7b34170d70c9942c8ee856f0aa63f66385adadfe8f09a0d9d5462519a` |

## Identification

Not verified on Blockscout. Runtime bytecode is in `bytecode.hex` (8378 bytes), fetched with `eth_getCode` at the 2026-09-02 head.

Function selectors found in the bytecode: 14. Matched against every verified Pons ABI in this archive plus the names the docs use:

- `beacon()`
- `createVault(address,address,bytes)`
- `implementation()`
- `template()`
- `vaultCount()`
- `vaultOf(address)`
- `vaults(uint256)`

Unmatched selectors are recoverable from `bytecode.hex` with the same PUSH4 scan.
