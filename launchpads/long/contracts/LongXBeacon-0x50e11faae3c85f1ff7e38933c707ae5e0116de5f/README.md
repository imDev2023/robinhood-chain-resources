# LongXBeacon - 0x50e11faae3c85f1ff7e38933c707ae5e0116de5f

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x50e11faae3c85f1ff7e38933c707ae5e0116de5f
Role: LongXBeacon.
Contract name: LongXBeacon.
Verified: True (verified at 2026-08-23T13:36:14.858842Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/upgradeable/LongXBeacon.sol.
Source files written: 6 under `sources/`.
Creator: 0x3260e7A806f7D5D6a85C7246FB059099F3bF0f2f.
Creation tx: 0xb163311a536de6785d6adc2cf570b9199f29062de640e874c9210985e63b90e1.
Proxy type: basic_implementation; implementations: ['0xcfB0f21f200045B3c2EF8A20fB36498e32395C88'].

Upgradeable beacon for LongX vaults.

## Constructor arguments

- `implementation_` (address): `0xe9D1e0d8c97BD8A3A758B2090773Fc61B3C25c92`
- `initialOwner` (address): `0xbce0184BACbc66E81398f7a2752eFC5Fae2a55Bc`

## Events

- `OwnershipTransferStarted(address,address)`
- `OwnershipTransferred(address,address)`
- `Upgraded(address)`

## State-changing functions

- `acceptOwnership()`
- `renounceOwnership()`
- `transferOwnership(address)`
- `upgradeTo(address)`

## View functions

- `implementation()`
- `owner()`
- `pendingOwner()`
