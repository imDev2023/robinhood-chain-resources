# Escrow-v4-minimal-current - 0xc5444b417a04a7e1b9c1e327c7d499803c14e5ef

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xc5444b417a04a7e1b9c1e327c7d499803c14e5ef
Role: Escrow-v4-minimal-current.
Contract name: FeeEscrow.
Verified: True (verified at 2026-08-31T23:34:49.550975Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/FeeEscrow.sol.
Source files written: 17 under `sources/`.
Creator: 0xaa8d6f5A785304628bA68aA54A1941702665d58C.
Creation tx: 0x92a6a7962a1ae877d8d76c5ac6fdaec0df1e607a2bfb0c0ff7a5f0fe06c55137.
Proxy type: None; implementations: [].

## Constructor arguments

- `poolManagerAddress` (address): `0x8366a39CC670B4001A1121B8F6A443A643e40951`
- `launchHook` (address): `0x0310cFEbE1D7A69f2414f6595bBe9d17c5342aCc`

## Events

- `Claimed(address,address,address,uint256)`
- `Credited(address,address,uint256)`

## State-changing functions

- `claimFor(address,address)`
- `claimTo(address,address)`
- `credit(address,address,uint256)`
- `unlockCallback(bytes)`

## View functions

- `hook()`
- `owed(address,address)`
- `poolManager()`
