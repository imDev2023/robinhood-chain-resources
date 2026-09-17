# LongLauncher - 0x22e99278308b393ea1260859b181ad7e78f5eeed

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x22e99278308b393ea1260859b181ad7e78f5eeed
Role: LongLauncher.
Contract name: LongLauncher.
Verified: True (verified at 2026-07-14T11:23:57.423653Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/LongLauncher.sol.
Source files written: 15 under `sources/`.
Creator: 0x1Ae51740cE21CAEbB8C92C457Ad7fc1bdAAe5305.
Creation tx: 0x717af93c071b39247b5cec72930b990b917439143f6621d08797090732947cf9.
Proxy type: None; implementations: [].

The launcher the app calls (`tickerFactory` in the app's chain config). Forwards `Airlock.create` unchanged after checking the ticker is not reserved, then reserves the normalized ticker for 24 hours. Takes no fee.

## Constructor arguments

- `airlock_` (address): `0xeb7C034704eF8Dcd2D32324c1545f62fB4aD0862`
- `trustedTokenFactory_` (address): `0x1B37D3a72082029c44B35B604Ea473617580b69a`
- `initialOwner` (address): `0x9B7f0d4dcF6a4BaED39B2F4f5Aeae6cA082BED47`

## Events

- `ERC20Swept(address,address,uint256)`
- `LaunchCreated(address,address,address,address,address,bytes32,uint48,uint48,string)`
- `NativeSwept(address,uint256)`
- `OwnershipTransferStarted(address,address)`
- `OwnershipTransferred(address,address)`
- `Paused(address)`
- `Unpaused(address)`

## State-changing functions

- `acceptOwnership()`
- `create(tuple)`
- `pause()`
- `sweepERC20(address,address,uint256)`
- `sweepNative(address,uint256)`
- `transferOwnership(address)`
- `unpause()`

## View functions

- `AIRLOCK()`
- `RESERVATION_DURATION()`
- `TRUSTED_TOKEN_FACTORY()`
- `getTickerRecord(string)`
- `isTickerAvailable(string)`
- `owner()`
- `paused()`
- `pendingOwner()`
- `renounceOwnership()`
- `tickerKey(string)`
