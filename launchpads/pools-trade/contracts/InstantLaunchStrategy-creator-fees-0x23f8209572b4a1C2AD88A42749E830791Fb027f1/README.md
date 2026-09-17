# InstantLaunchStrategy-creator-fees - 0x23f8209572b4a1C2AD88A42749E830791Fb027f1

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x23f8209572b4a1C2AD88A42749E830791Fb027f1
Role: InstantLaunchStrategy-creator-fees.
Contract name: InstantLaunchStrategy.
Verified: True (sources from `smart-contracts`, flag from `addresses`).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/strategies/InstantLaunchStrategy.sol.
Source files written: 64 under `sources/`.
Creator: 0x4e59b44847b379578588920cA78FbF26c0B4956C.
Creation tx: 0xb03ef43e611195705821dee524c8b8ef5f6078342b3562b209aea34f5dbe8d2a.
Proxy type: None; implementations: [].

## Constructor arguments

- `_launcher` (address): `0x0000FffFBE8efE702c8703aE3477FF5dE3d319C0`
- `_positionManager` (address): `0x58daec3116aae6D93017bAAea7749052E8a04fA7`
- `_poolManager` (address): `0x8366a39CC670B4001A1121B8F6A443A643e40951`
- `_feeSplitter` (address): `0xeFF166AAf189323c58dc27eD1206EB2C37FaACDf`
- `_beneficiaryVault` (address): `0xd35E9CA72F64C7F93BE30fad67524323396B36D7`
- `_initialTick` (int24): `198050`

## Events

- `DistributionInitialized(address,address,uint256)`
- `TokenLaunched(bytes32,address,address,tuple)`

## State-changing functions

- `initializeDistribution(address,uint256,bytes,bytes32)`

## View functions

- `LP_FEE()`
- `MAX_INITIAL_TICK()`
- `MIN_LAUNCH_TICK()`
- `TICK_SPACING()`
- `TOTAL_SUPPLY()`
- `beneficiaryVault()`
- `feeSplitter()`
- `initialSqrtPriceX96()`
- `initialTick()`
- `launcher()`
- `poolManager()`
- `positionLiquidity()`
- `positionManager()`
