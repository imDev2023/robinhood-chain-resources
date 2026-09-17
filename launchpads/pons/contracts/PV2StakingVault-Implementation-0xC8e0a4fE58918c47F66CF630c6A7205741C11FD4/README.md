# PV2StakingVault-Implementation

`0xC8e0a4fE58918c47F66CF630c6A7205741C11FD4`

Group: PonsVault v2.
Unverified. Beacon implementation for Staking vaults.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | no |
| Creator | `0x897ac30f73Ba92E1EFbC1dF1e67f8b5F4b3ECD2b` |
| Creation tx | `0xdb05086f1cbff548fc864414e038d401897e1014ab3dd29dac13399dc4bd752d` |

## Identification

Not verified on Blockscout. Runtime bytecode is in `bytecode.hex` (10262 bytes), fetched with `eth_getCode` at the 2026-09-02 head.

Function selectors found in the bytecode: 31. Matched against every verified Pons ABI in this archive plus the names the docs use:

- `claim()`
- `description()`
- `isNativeQuote()`
- `pendingRewards(address)`
- `run()`
- `stake(uint256)`
- `stakedOf(address)`
- `template()`
- `token()`
- `unstake(uint256)`

Unmatched selectors are recoverable from `bytecode.hex` with the same PUSH4 scan.
