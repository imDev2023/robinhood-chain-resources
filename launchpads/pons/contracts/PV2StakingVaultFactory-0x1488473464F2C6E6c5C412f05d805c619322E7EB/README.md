# PV2StakingVaultFactory

`0x1488473464F2C6E6c5C412f05d805c619322E7EB`

Group: PonsVault v2.
Unverified beacon factory named in the PonsVault docs. It owns the live Staking beacon `0xef9f80d2…`, but the live launch flow calls `0x3422A17c…` instead.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | no |
| Implementation | `0xC8e0a4fE58918c47F66CF630c6A7205741C11FD4` |
| Creator | `0x897ac30f73Ba92E1EFbC1dF1e67f8b5F4b3ECD2b` |
| Creation tx | `0xd3453bf8a403bd7d43947727c92fa1656049a3852acdd649d7b23864d75242a3` |

## Identification

Not verified on Blockscout. Runtime bytecode is in `bytecode.hex` (5088 bytes), fetched with `eth_getCode` at the 2026-09-02 head.

Function selectors found in the bytecode: 18. Matched against every verified Pons ABI in this archive plus the names the docs use:

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
