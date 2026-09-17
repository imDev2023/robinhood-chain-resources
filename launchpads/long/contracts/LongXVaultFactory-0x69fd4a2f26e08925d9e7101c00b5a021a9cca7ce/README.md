# LongXVaultFactory - 0x69fd4a2f26e08925d9e7101c00b5a021a9cca7ce

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x69fd4a2f26e08925d9e7101c00b5a021a9cca7ce
Role: LongXVaultFactory.
Contract name: LongXVaultFactory.
Verified: True (verified at 2026-08-24T09:16:42.807192Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/upgradeable/LongXVaultFactory.sol.
Source files written: 32 under `sources/`.
Creator: 0x3260e7A806f7D5D6a85C7246FB059099F3bF0f2f.
Creation tx: 0xbb4555b8e505a7742ad0a95b4a9c681b2d47aa055366ae12ed73d06910647f83.
Proxy type: None; implementations: [].

Factory for LongX leveraged-token vaults (beacon proxies). Created the NVDAx3L vault.

## Constructor arguments

- `beacon_` (address): `0x50e11fAAe3C85f1ff7E38933c707AE5E0116dE5f`
- `initialOwner` (address): `0xbce0184BACbc66E81398f7a2752eFC5Fae2a55Bc`

## Events

- `OwnershipTransferStarted(address,address)`
- `OwnershipTransferred(address,address)`
- `VaultCreated(address,address,string,string)`

## State-changing functions

- `acceptOwnership()`
- `createVault(address,address,uint16,uint8,tuple,string,string)`
- `renounceOwnership()`
- `transferOwnership(address)`

## View functions

- `allVaults()`
- `beacon()`
- `owner()`
- `pendingOwner()`
- `vaultCount()`
- `vaults(uint256)`
