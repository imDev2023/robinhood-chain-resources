# PVSeatSeriesRegistry-A

`0x9cc3207EC932f65fd83A514633802B4CdBB888E0`

Group: PonsVault v2.
Unverified Vault Seats series registry. `0xd7f2c0ef` returns 2 series; `0xdc22cb6a(uint256)` returns a record of seven contract addresses plus name, symbol and two counters. Series 1 is `Artificial General Intelligence`, shown at /seats/1.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | no |
| Creator | `0x897ac30f73Ba92E1EFbC1dF1e67f8b5F4b3ECD2b` |
| Creation tx | `0x61b76e9886153b30b000f37865cb044b15c812c43a43df94bf3bf82087e4f76b` |

## Identification

Not verified on Blockscout. Runtime bytecode in `bytecode.hex` (3602 bytes), fetched with `eth_getCode` at the 2026-09-02 head.

Reads confirmed live against the Alchemy archive RPC:

- `0xd7f2c0ef()` returns the number of series
- `0xdc22cb6a(uint256)` returns a series record: seven addresses (seat NFT, shop, activation, pot, loan vault, fuel token, fuel curve), then name, symbol and two counters

The seven per-series contracts are not given their own directories. The Vault Seats product is adjacent to the launchpad rather than part of the launch path, and each series deploys a fresh set; README section 5 explains the shape and how to enumerate them.
