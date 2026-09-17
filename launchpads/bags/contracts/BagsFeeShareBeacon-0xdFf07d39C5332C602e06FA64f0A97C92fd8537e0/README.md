# BagsFeeShareBeacon - 0xdFf07d39C5332C602e06FA64f0A97C92fd8537e0

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xdFf07d39C5332C602e06FA64f0A97C92fd8537e0
Role: BagsFeeShareBeacon.
Contract name: BagsBeacon.
Verified: True (verified at 2026-07-13T19:24:17.883308Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/BagsBeacon.sol.
Source files written: 6 under `sources/`.
Creator: 0xDEf671F11C8a30818eb3D9Cc9476EEEc805f9058.
Creation tx: 0x1823fe1812e2b0eeb1c6bf6c4384759f619ba12812b955c6aebd42fc72c7c326.
Proxy type: basic_implementation; implementations: ['0xD169EBd0aa9E42F2410f92740D00cD2228d98a1A'].

UpgradeableBeacon for every per-token BagsFeeShare. `implementation()` = 0xD169EBd0aa9E42F2410f92740D00cD2228d98a1A, owner 0xDEf671F11C8a30818eb3D9Cc9476EEEc805f9058. Never retargeted since deploy.

## Constructor arguments

- `implementation_` (address): `0xD169EBd0aa9E42F2410f92740D00cD2228d98a1A`
- `initialOwner` (address): `0xDEf671F11C8a30818eb3D9Cc9476EEEc805f9058`

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
