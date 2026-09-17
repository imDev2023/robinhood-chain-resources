# HoodCommunityGuarded - 0xed2d2a46E64Bc84355eE3CD6A02ab470EA42147E

Role: HoodCommunityGuarded.
Address: `0xed2d2a46E64Bc84355eE3CD6A02ab470EA42147E` on Robinhood Chain (chain id 4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xed2d2a46E64Bc84355eE3CD6A02ab470EA42147E
Verified: True (fully verified: True, partially: False).
Compiler: v0.8.28+commit.7893614a, EVM prague, optimizer True runs 200.
Language: solidity. License: none.
Proxy type: basic_implementation. Implementations: ['0xAb0B12005275cA53C649f360119b9C23F60faAb8'].
Main source file: `src/HoodCommunityGuarded.sol`. Source files written: 11 under `sources/`.
Raw constructor args: `0x0000000000000000000000008c529f0a77c07ce0e6796f153d292501ee6f66f60000000000000000000000000bd7d308f8e1639fab988df18a8011f41eacad730000000000000000000000008e96a84adc54d04869ded92661a01f75e283741b00000000000000000000000095b02ad7dd7eb6bdeff56cc57b0bda601862ad83`.

Decoded constructor args:
- launchpad_ (address): `0x8c529f0a77C07CE0e6796f153D292501eE6F66f6`
- weth_ (address): `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`
- owner_ (address): `0x8E96a84AdC54d04869ded92661a01f75e283741B`
- publisher_ (address): `0x95b02Ad7DD7EB6Bdeff56cC57B0Bda601862aD83`

## Functions

- `allCommunityTokens(uint256)` -> address [view]
- `approvedLauncher(address launcher)` -> bool [view]
- `communityCount()` -> uint256 [view]
- `implementation()` -> address [view]
- `isCommunity(address token)` -> bool [view]
- `launchCommunityGuarded(string name, string symbol, string metadataURI, bytes32 salt, uint16 tradeFeeBps, uint256 totalSupply_, bool antiSnipe, bool maxWallet, address[] wallets, uint256[] ethIn, uint256[] minOut)` -> address, address [payable]
- `launchpad()` -> address [view]
- `owner()` -> address [view]
- `predictRewards(address caller, bytes32 salt)` -> address [view]
- `predictToken(bytes32 salt, string name, string symbol, uint256 totalSupply_)` -> address [view]
- `publisher()` -> address [view]
- `renounceOwnership()` ->  [nonpayable]
- `rewardsOf(address token)` -> address [view]
- `setLauncher(address launcher, bool approved)` ->  [nonpayable]
- `setPublisher(address publisher_)` ->  [nonpayable]
- `sweep(address to)` ->  [nonpayable]
- `transferOwnership(address newOwner)` ->  [nonpayable]
- `weth()` -> address [view]

## Events

- `CommunityLaunched(address token, address rewards, address launcher)`
- `LauncherSet(address launcher, bool approved)`
- `OwnershipTransferred(address previousOwner, address newOwner)`
- `PublisherSet(address publisher)`

Launch-relevant items (create, launch, buy, sell, graduate, migrate, claim, lock, collect) are marked by name above.
See `metadata.json` for the full Blockscout smart-contracts response and `abi.json` for the ABI.
