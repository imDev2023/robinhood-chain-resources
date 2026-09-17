# HoodV3Migrator - 0x88B4cde518272033F48862CEF728203aF219D02e

Role: HoodV3Migrator-b.
Address: `0x88B4cde518272033F48862CEF728203aF219D02e` on Robinhood Chain (chain id 4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x88B4cde518272033F48862CEF728203aF219D02e
Verified: True (fully verified: True, partially: False).
Compiler: v0.8.28+commit.7893614a, EVM prague, optimizer True runs 5000.
Language: solidity. License: none.
Proxy type: None. Implementations: [].
Main source file: `src/HoodV3Migrator.sol`. Source files written: 9 under `sources/`.
Raw constructor args: `0000000000000000000000006a63d96ef77ae569fcb85934cf1bd1ec7fe9b33d00000000000000000000000073991a25c818bf1f1128deaab1492d45638de0d300000000000000000000000086083371c51654816518c35cc589871c24018a540000000000000000000000000bd7d308f8e1639fab988df18a8011f41eacad73000000000000000000000000b3f3b54e11217f4f73e7a766b7caa187390d700d0000000000000000000000000000000000000000000000000000000000001388`.

Decoded constructor args:
- launchpad_ (address): `0x6a63D96ef77AE569fCb85934Cf1Bd1Ec7FE9B33D`
- nfpm_ (address): `0x73991a25C818Bf1f1128dEAaB1492D45638DE0D3`
- locker_ (address): `0x86083371c51654816518c35Cc589871C24018a54`
- weth_ (address): `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`
- protocol_ (address): `0xB3f3B54E11217F4F73e7a766B7CAA187390d700D`
- creatorShareBps_ (uint16): `5000`

## Functions

- `FEE()` -> uint24 [view]
- `creatorShareBps()` -> uint16 [view]
- `launchpad()` -> address [view]
- `locker()` -> address [view]
- `migrate(address token, address creator)` -> address [payable]
- `nfpm()` -> address [view]
- `protocol()` -> address [view]
- `weth()` -> address [view]

## Events

- `V3Migrated(address token, address pool, uint256 tokenId, uint256 tokenLiquidity, uint256 ethLiquidity)`

Launch-relevant items (create, launch, buy, sell, graduate, migrate, claim, lock, collect) are marked by name above.
See `metadata.json` for the full Blockscout smart-contracts response and `abi.json` for the ABI.
