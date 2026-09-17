# PV2StakingVaultBeacon

`0xef9f80d2f51ec6aecab284e778f328e9f0982a6f`

Group: PonsVault v2.
UpgradeableBeacon for Staking vaults. `implementation()` = `0xC8e0a4fE…`, `owner()` = `0x1488473464…`.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | no |
| Implementation | `0xC8e0a4fE58918c47F66CF630c6A7205741C11FD4` |
| Creator | `0x1488473464F2C6E6c5C412f05d805c619322E7EB` |
| Creation tx | `0xd3453bf8a403bd7d43947727c92fa1656049a3852acdd649d7b23864d75242a3` |

## Identification

Not verified on Blockscout. Runtime bytecode is in `bytecode.hex` (1130 bytes), fetched with `eth_getCode` at the 2026-09-02 head.

Function selectors found in the bytecode: 5. Matched against every verified Pons ABI in this archive plus the names the docs use:

- `implementation()`
- `owner()`
- `renounceOwnership()`
- `transferOwnership(address)`
- `upgradeTo(address)`

Unmatched selectors are recoverable from `bytecode.hex` with the same PUSH4 scan.
