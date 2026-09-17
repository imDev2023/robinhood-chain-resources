# PV2VaultLauncher

`0x1770c356eB9312079b9A00e26a8CF4b0a1473dBA`

Group: PonsVault v2.
Unverified. `vaultOf`, `templateOf`, `creatorOf`, `registry`, `factory`. This is the launcher the PonsVault docs name, but `/api/v2/status` reports `vaultLauncherWhitelisted: false` and the live launch flow does not route through it. See README section 5.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | no |
| Creator | `0x897ac30f73Ba92E1EFbC1dF1e67f8b5F4b3ECD2b` |
| Creation tx | `0x9245f5b57d8bd16e54473f0e40de9b9927518dcb677c03166bc7136de16a15fd` |

## Identification

Not verified on Blockscout. Runtime bytecode is in `bytecode.hex` (5398 bytes), fetched with `eth_getCode` at the 2026-09-02 head.

Function selectors found in the bytecode: 7. Matched against every verified Pons ABI in this archive plus the names the docs use:

- `creatorOf(address)`
- `factory()`
- `registry()`
- `templateOf(address)`
- `vaultOf(address)`

Unmatched selectors are recoverable from `bytecode.hex` with the same PUSH4 scan.
