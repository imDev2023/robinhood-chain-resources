# LockableUniswapV3Initializer - 0xde8886a0019ea060b8378ee37b8a23b8117f29a3

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xde8886a0019ea060b8378ee37b8a23b8117f29a3
Role: LockableUniswapV3Initializer.
Verified: True (verified at 2026-07-01T19:42:28.613708Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 0.
Main file: src/initializers/LockableUniswapV3Initializer.sol.
Source files written: 45 under `sources/`.
Creator: 0x583ffb503dDBB222672c89Af42AF17593ba91928.
Creation tx: 0x6506158f635a07a87b010d5326f0b87a4e920448d8ae1d57f3bee8e12c0934ea.
Proxy type: None; implementations: [].

## Constructor arguments

- `airlock_` (address): `0xeb7C034704eF8Dcd2D32324c1545f62fB4aD0862`
- `factory_` (address): `0x1f7d7550B1b028f7571E69A784071F0205FD2EfA`

## Events

- Collect
- Create
- Lock

## State-changing functions

- `collectFees(address)`
- `exitLiquidity(address)`
- `initialize(address,address,uint256,bytes32,bytes)`
- `uniswapV3MintCallback(uint256,uint256,bytes)`

## View functions

- `airlock()`
- `factory()`
- `getState(address)`
