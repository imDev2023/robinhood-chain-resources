# PVSeatSeriesRegistry-B

`0x278FFA5A46283A05635A3d33d820D9Cc7D7E67E2`

Group: PonsVault v2.
Unverified Vault Seats series registry, second instance. Returns 4 series; series 0 is `Pons animals`, shown at /seats/0. Both registries are read by the live /seats page.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | no |
| Creator | `0x897ac30f73Ba92E1EFbC1dF1e67f8b5F4b3ECD2b` |
| Creation tx | `0x55d54284b36836458a841adc8292674674cab1a526b45c5c770457794c61115d` |

## Identification

Not verified on Blockscout. Runtime bytecode in `bytecode.hex` (3533 bytes), fetched with `eth_getCode` at the 2026-09-02 head.

Reads confirmed live against the Alchemy archive RPC:

- `0xd7f2c0ef()` returns the number of series
- `0xdc22cb6a(uint256)` returns a series record: seven addresses (seat NFT, shop, activation, pot, loan vault, fuel token, fuel curve), then name, symbol and two counters

The seven per-series contracts are not given their own directories. The Vault Seats product is adjacent to the launchpad rather than part of the launch path, and each series deploys a fresh set; README section 5 explains the shape and how to enumerate them.
