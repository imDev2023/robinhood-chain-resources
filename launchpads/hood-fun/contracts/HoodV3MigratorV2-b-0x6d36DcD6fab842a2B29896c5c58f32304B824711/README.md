# HoodV3MigratorV2 - 0x6d36DcD6fab842a2B29896c5c58f32304B824711

Role: HoodV3MigratorV2-b.
Address: `0x6d36DcD6fab842a2B29896c5c58f32304B824711` on Robinhood Chain (chain id 4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x6d36DcD6fab842a2B29896c5c58f32304B824711
Verified: True (fully verified: True, partially: False).
Compiler: v0.8.28+commit.7893614a, EVM prague, optimizer True runs 200.
Language: solidity. License: none.
Proxy type: None. Implementations: [].
Main source file: `src/HoodV3MigratorV2.sol`. Source files written: 11 under `sources/`.
Raw constructor args: `0x0000000000000000000000003d1c455f81ec131cc91b000b42fccbf45a13202600000000000000000000000073991a25c818bf1f1128deaab1492d45638de0d30000000000000000000000005e27754b2cdf4fe3715451d2d3d267801e0f49340000000000000000000000000bd7d308f8e1639fab988df18a8011f41eacad73000000000000000000000000b3f3b54e11217f4f73e7a766b7caa187390d700d0000000000000000000000000000000000000000000000000000000000001f40000000000000000000000000b3f3b54e11217f4f73e7a766b7caa187390d700d`.

Decoded constructor args:
- launchpad_ (address): `0x3D1C455f81EC131cc91b000b42fCCbF45A132026`
- nfpm_ (address): `0x73991a25C818Bf1f1128dEAaB1492D45638DE0D3`
- locker_ (address): `0x5e27754b2cdF4Fe3715451d2D3D267801e0F4934`
- weth_ (address): `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`
- protocol_ (address): `0xB3f3B54E11217F4F73e7a766B7CAA187390d700D`
- creatorShareBps_ (uint16): `8000`
- owner_ (address): `0xB3f3B54E11217F4F73e7a766B7CAA187390d700D`

## Functions

- `FEE()` -> uint24 [view]
- `creatorShareBps()` -> uint16 [view]
- `launchpad()` -> address [view]
- `locker()` -> address [view]
- `migrate(address token, address creator)` -> address [payable]
- `nfpm()` -> address [view]
- `owner()` -> address [view]
- `protocol()` -> address [view]
- `renounceOwnership()` ->  [nonpayable]
- `rescueETH(address to)` ->  [nonpayable]
- `rescueTokens(address token, uint256 amount, address to)` ->  [nonpayable]
- `transferOwnership(address newOwner)` ->  [nonpayable]
- `weth()` -> address [view]

## Events

- `OwnershipTransferred(address previousOwner, address newOwner)`
- `V3Migrated(address token, address pool, uint256 tokenId, uint256 tokenLiquidity, uint256 ethLiquidity)`

Launch-relevant items (create, launch, buy, sell, graduate, migrate, claim, lock, collect) are marked by name above.
See `metadata.json` for the full Blockscout smart-contracts response and `abi.json` for the ABI.
