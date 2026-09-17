# BagsVaultImpl - 0xeC66D9fc56E92408518De9b8a8697245E932e688

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xeC66D9fc56E92408518De9b8a8697245E932e688
Role: BagsVaultImpl.
Contract name: BagsVault.
Verified: True (verified at 2026-07-12T14:55:22.162352Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/BagsVault.sol.
Source files written: 20 under `sources/`.
Creator: 0xDEf671F11C8a30818eb3D9Cc9476EEEc805f9058.
Creation tx: 0xd713df2c4ce27a0a4b38b197efbf8de45075ebe2f7e77f8ccc02382b3fd28bc7.
Proxy type: None; implementations: [].

Current BagsVault implementation.

## Constructor arguments

None decoded.

## Events

- `Initialized(uint64)`
- `OwnershipTransferStarted(address,address)`
- `OwnershipTransferred(address,address)`
- `Received(address,uint256)`
- `TokenWithdrawn(address,address,uint256)`
- `Upgraded(address)`
- `Withdrawn(address,uint256)`

## State-changing functions

- `acceptOwnership()`
- `initialize(address)`
- `renounceOwnership()`
- `transferOwnership(address)`
- `upgradeToAndCall(address,bytes)`
- `withdraw(address,uint256)`
- `withdrawToken(address,address,uint256)`

## View functions

- `UPGRADE_INTERFACE_VERSION()`
- `balance()`
- `owner()`
- `pendingOwner()`
- `proxiableUUID()`
