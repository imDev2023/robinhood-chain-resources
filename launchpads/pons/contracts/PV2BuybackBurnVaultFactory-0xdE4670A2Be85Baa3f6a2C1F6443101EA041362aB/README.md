# PV2BuybackBurnVaultFactory

`0xdE4670A2Be85Baa3f6a2C1F6443101EA041362aB`

Group: PonsVault v2.
Unverified beacon factory named in the PonsVault docs. Live Buyback and Burn launches are built by `0x7e344f13…` instead.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | no |
| Implementation | `0xB56579797dD1c6aeA45a6b0F71210a95a3E6D85e` |
| Creator | `0x897ac30f73Ba92E1EFbC1dF1e67f8b5F4b3ECD2b` |
| Creation tx | `0x8663f6848eb4d6b7e3ab70691c8d1181385670203548347cd2ea952af296a48e` |

## Identification

Not verified on Blockscout. Runtime bytecode is in `bytecode.hex` (5378 bytes), fetched with `eth_getCode` at the 2026-09-02 head.

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
