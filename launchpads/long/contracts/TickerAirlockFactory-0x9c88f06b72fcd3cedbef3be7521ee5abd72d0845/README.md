# TickerAirlockFactory - 0x9c88f06b72fcd3cedbef3be7521ee5abd72d0845

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x9c88f06b72fcd3cedbef3be7521ee5abd72d0845
Role: TickerAirlockFactory.
Contract name: TickerAirlockFactory.
Verified: True (verified at 2026-07-12T21:23:08.142944Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/TickerAirlockFactory.sol.
Source files written: 15 under `sources/`.
Creator: 0x1Ae51740cE21CAEbB8C92C457Ad7fc1bdAAe5305.
Creation tx: 0xdb6124d8b219fff528978b9599c7e983dc14bb09b81bdb2e6f4592186ee65e17.
Proxy type: None; implementations: [].

First-generation launcher, byte-for-byte the same logic as LongLauncher under an earlier name and a different owner. Used for Long's first launches on 2026-07-12 and 2026-07-13, superseded by LongLauncher on 2026-07-14.

## Constructor arguments

- `airlock_` (address): `0xeb7C034704eF8Dcd2D32324c1545f62fB4aD0862`
- `trustedTokenFactory_` (address): `0x1B37D3a72082029c44B35B604Ea473617580b69a`
- `initialOwner` (address): `0x8aa7A1dFA6635AF2979dA4D2bDd51780842e3F99`

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
