# LBPStrategy - 0x05d552391067389EE44fec3924157ed33F976000

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x05d552391067389EE44fec3924157ed33F976000
Role: LBPStrategy.
Contract name: LBPStrategy.
Verified: True (sources from `smart-contracts`, flag from `addresses`).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/strategies/lbp/LBPStrategy.sol.
Source files written: 76 under `sources/`.
Creator: 0x4e59b44847b379578588920cA78FbF26c0B4956C.
Creation tx: 0xab6a15d3b37e1e5db9071bc5fa604c33ad1e0ac617972611e22014b273bc95d1.
Proxy type: None; implementations: [].

## Constructor arguments

- `_positionManager` (address): `0x58daec3116aae6D93017bAAea7749052E8a04fA7`
- `_poolManager` (address): `0x8366a39CC670B4001A1121B8F6A443A643e40951`
- `_initializerFactory` (address): `0x000000001F26a0044BaA66024e7b6599c61963F8`

## Events

- `CurrencySwept(address,uint256)`
- `DistributionInitialized(address,address,uint256)`
- `FundsRecovered(address,address,uint256)`
- `InitializerCreated(address,tuple)`
- `Migrated(address,tuple,uint160,bytes)`
- `MigrationFailed(address,bytes)`
- `TokensSwept(address,uint256)`

## State-changing functions

- `initializeDistribution(address,uint256,bytes,bytes32)`
- `migrate(address)`
- `tryMigrate(address,tuple,tuple)`

## View functions

- `beforeInitialize(address,tuple,uint160)`
- `initializerFactory()`
- `initializers(address)`
- `poolManager()`
- `positionManager()`
- `registeredPoolIds(bytes32)`
