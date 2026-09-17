# HoodCommunityFactory - 0x6d188c21f99a7578d4E3fD449b67d740ff97eb4d

Role: HoodCommunityFactory.
Address: `0x6d188c21f99a7578d4E3fD449b67d740ff97eb4d` on Robinhood Chain (chain id 4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x6d188c21f99a7578d4E3fD449b67d740ff97eb4d
Verified: True (fully verified: True, partially: False).
Compiler: v0.8.28+commit.7893614a, EVM prague, optimizer True runs 200.
Language: solidity. License: none.
Proxy type: basic_implementation. Implementations: ['0x6b8Efd1713B020Ea0C01557Dc3fCFEa266cc048f'].
Main source file: `src/HoodCommunity.sol`. Source files written: 10 under `sources/`.
Raw constructor args: `0x0000000000000000000000008c529f0a77c07ce0e6796f153d292501ee6f66f60000000000000000000000000bd7d308f8e1639fab988df18a8011f41eacad73000000000000000000000000159089f48b4f0e51f430f7df6fe1064bec0258df00000000000000000000000095b02ad7dd7eb6bdeff56cc57b0bda601862ad83`.

Decoded constructor args:
- launchpad_ (address): `0x8c529f0a77C07CE0e6796f153D292501eE6F66f6`
- weth_ (address): `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`
- owner_ (address): `0x159089F48b4F0e51f430f7df6fe1064bEc0258dF`
- publisher_ (address): `0x95b02Ad7DD7EB6Bdeff56cC57B0Bda601862aD83`

## Functions

- `allCommunityTokens(uint256)` -> address [view]
- `communityCount()` -> uint256 [view]
- `implementation()` -> address [view]
- `isCommunity(address token)` -> bool [view]
- `launchCommunity(string name, string symbol, string metadataURI, bytes32 salt, uint16 tradeFeeBps, uint256 totalSupply_, uint256 devBuyEth, uint256 minDevTokensOut)` -> address, address [payable]
- `launchpad()` -> address [view]
- `owner()` -> address [view]
- `predictRewards(address caller, bytes32 salt)` -> address [view]
- `publisher()` -> address [view]
- `renounceOwnership()` ->  [nonpayable]
- `rewardsOf(address token)` -> address [view]
- `setPublisher(address publisher_)` ->  [nonpayable]
- `transferOwnership(address newOwner)` ->  [nonpayable]
- `weth()` -> address [view]

## Events

- `CommunityLaunched(address token, address rewards, address launcher)`
- `OwnershipTransferred(address previousOwner, address newOwner)`
- `PublisherSet(address publisher)`

Launch-relevant items (create, launch, buy, sell, graduate, migrate, claim, lock, collect) are marked by name above.
See `metadata.json` for the full Blockscout smart-contracts response and `abi.json` for the ABI.
