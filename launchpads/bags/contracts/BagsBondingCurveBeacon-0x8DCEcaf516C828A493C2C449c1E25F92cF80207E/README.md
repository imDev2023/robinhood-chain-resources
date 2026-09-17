# BagsBondingCurveBeacon - 0x8DCEcaf516C828A493C2C449c1E25F92cF80207E

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x8DCEcaf516C828A493C2C449c1E25F92cF80207E
Role: BagsBondingCurveBeacon.
Contract name: BagsBeacon.
Verified: True (verified at 2026-07-12T15:02:45.314782Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/BagsBeacon.sol.
Source files written: 6 under `sources/`.
Creator: 0xDEf671F11C8a30818eb3D9Cc9476EEEc805f9058.
Creation tx: 0x92443b0859761700b0f0e57e4f59f909eb4bcfae51782ad996c7c00b72b28ec0.
Proxy type: basic_implementation; implementations: ['0x419890a21711c3D3Af46B58548376420B9723275'].

UpgradeableBeacon for every per-token BagsBondingCurve. `implementation()` = 0x419890a21711c3D3Af46B58548376420B9723275, owner 0xDEf671F11C8a30818eb3D9Cc9476EEEc805f9058. Never retargeted since deploy.

## Constructor arguments

- `implementation_` (address): `0x419890a21711c3D3Af46B58548376420B9723275`
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
