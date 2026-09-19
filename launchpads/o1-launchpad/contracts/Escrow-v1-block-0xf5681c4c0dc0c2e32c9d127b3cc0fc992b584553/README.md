# Escrow-v1-block - 0xf5681c4c0dc0c2e32c9d127b3cc0fc992b584553

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xf5681c4c0dc0c2e32c9d127b3cc0fc992b584553
Role: Escrow-v1-block.
Contract name: FeeEscrow.
Verified: True (verified at 2026-08-12T06:28:30.816841Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/FeeEscrow.sol.
Source files written: 17 under `sources/`.
Creator: 0x05edc8Ce423533fF0bA6A2d286c6f3cd6fe05406.
Creation tx: 0x5cb5e89929832597990dbea79a7d162e4b46d5b5ff323d09d47ac029e89927bf.
Proxy type: None; implementations: [].

## Constructor arguments

- `_poolManager` (address): `0x8366a39CC670B4001A1121B8F6A443A643e40951`
- `_hook` (address): `0xe960E6C80C74cFDF03c91E7AF4e1F5f53f096a44`

## Events

- `Claimed(address,address,uint256)`
- `Credited(address,address,uint256)`

## State-changing functions

- `claim(address,address)`
- `claimTo(address,address)`
- `credit(address,address,uint256)`
- `unlockCallback(bytes)`

## View functions

- `hook()`
- `owed(address,address)`
- `poolManager()`
