# PV2StakeBurnVault-Implementation

`0x65b2eAaA7ae4eCC144494070aD6F2A3AD13A47d9`

Group: PonsVault v2.
Unverified. Beacon implementation for Stake and Burn vaults.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | no |
| Creator | `0x897ac30f73Ba92E1EFbC1dF1e67f8b5F4b3ECD2b` |
| Creation tx | `0xd1a6bbd62246f3284ed942c6966a12d143a7b368754420946139828a98b7a09e` |

## Identification

Not verified on Blockscout. Runtime bytecode is in `bytecode.hex` (18098 bytes), fetched with `eth_getCode` at the 2026-09-02 head.

Function selectors found in the bytecode: 47. Matched against every verified Pons ABI in this archive plus the names the docs use:

- `claim()`
- `description()`
- `factory()`
- `isNativeQuote()`
- `pendingRewards(address)`
- `stake(uint256)`
- `stakedOf(address)`
- `template()`
- `token()`
- `unstake(uint256)`

Unmatched selectors are recoverable from `bytecode.hex` with the same PUSH4 scan.
