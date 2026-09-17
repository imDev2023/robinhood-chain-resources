# HoodV3MigratorV2 - 0x86c6FAF889eBAC8621BBb6dd8CA86aa6d51c9e6C

Role: HoodV3MigratorV2-a.
Address: `0x86c6FAF889eBAC8621BBb6dd8CA86aa6d51c9e6C` on Robinhood Chain (chain id 4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x86c6FAF889eBAC8621BBb6dd8CA86aa6d51c9e6C
Verified: True (fully verified: True, partially: False).
Compiler: v0.8.28+commit.7893614a, EVM prague, optimizer True runs 200.
Language: solidity. License: none.
Proxy type: None. Implementations: [].
Main source file: `src/HoodV3MigratorV2.sol`. Source files written: 11 under `sources/`.
Raw constructor args: `0x0000000000000000000000008c529f0a77c07ce0e6796f153d292501ee6f66f600000000000000000000000073991a25c818bf1f1128deaab1492d45638de0d3000000000000000000000000d2a7c92fcb240c755919e9230c8db066e9ca15000000000000000000000000000bd7d308f8e1639fab988df18a8011f41eacad73000000000000000000000000159089f48b4f0e51f430f7df6fe1064bec0258df0000000000000000000000000000000000000000000000000000000000001f40000000000000000000000000159089f48b4f0e51f430f7df6fe1064bec0258df`.

Decoded constructor args:
- launchpad_ (address): `0x8c529f0a77C07CE0e6796f153D292501eE6F66f6`
- nfpm_ (address): `0x73991a25C818Bf1f1128dEAaB1492D45638DE0D3`
- locker_ (address): `0xD2a7C92FcB240c755919E9230c8DB066E9Ca1500`
- weth_ (address): `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`
- protocol_ (address): `0x159089F48b4F0e51f430f7df6fe1064bEc0258dF`
- creatorShareBps_ (uint16): `8000`
- owner_ (address): `0x159089F48b4F0e51f430f7df6fe1064bEc0258dF`

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
