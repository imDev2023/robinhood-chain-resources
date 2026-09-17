# PV2StakingVaultFactory-Live

`0x3422A17c3A85f751Acb7F978f7333F93ea39CB48`

Group: PonsVault v2.
Unverified. The Staking vault factory the live ponsvault.com launch flow actually calls, as of 2026-09-02. Shares the beacon owned by the documented factory `0x1488473464…`. 16 vaults built.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | no |
| Implementation | `0xC8e0a4fE58918c47F66CF630c6A7205741C11FD4` |
| Creator | `0x897ac30f73Ba92E1EFbC1dF1e67f8b5F4b3ECD2b` |
| Creation tx | `0xb63e77be3f5279dad111e722caabec173ee6fb0b557cb0efa9a460da33375b2c` |

## Identification

Not verified on Blockscout. Runtime bytecode is in `bytecode.hex` (7087 bytes), fetched with `eth_getCode` at the 2026-09-02 head.

Function selectors found in the bytecode: 13. Matched against every verified Pons ABI in this archive plus the names the docs use:

- `beacon()`
- `createVault(address,address,bytes)`
- `implementation()`
- `template()`
- `vaultCount()`
- `vaultOf(address)`
- `vaults(uint256)`

Unmatched selectors are recoverable from `bytecode.hex` with the same PUSH4 scan.
