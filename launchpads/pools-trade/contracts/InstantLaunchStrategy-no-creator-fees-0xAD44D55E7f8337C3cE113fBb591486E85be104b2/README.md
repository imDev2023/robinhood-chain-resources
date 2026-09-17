# InstantLaunchStrategy-no-creator-fees - 0xAD44D55E7f8337C3cE113fBb591486E85be104b2

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xAD44D55E7f8337C3cE113fBb591486E85be104b2
Role: InstantLaunchStrategy-no-creator-fees.
Contract name: InstantLaunchStrategy.
Verified: True (sources from `smart-contracts`, flag from `addresses`).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/strategies/InstantLaunchStrategy.sol.
Source files written: 64 under `sources/`.
Creator: 0x4e59b44847b379578588920cA78FbF26c0B4956C.
Creation tx: 0x9f5bb8ca16a35d9a472e77bd8a18df887325af1d57f2f25c280e7cb3ce1c7389.
Proxy type: None; implementations: [].

## Constructor arguments

- `_launcher` (address): `0x0000FffFBE8efE702c8703aE3477FF5dE3d319C0`
- `_positionManager` (address): `0x58daec3116aae6D93017bAAea7749052E8a04fA7`
- `_poolManager` (address): `0x8366a39CC670B4001A1121B8F6A443A643e40951`
- `_feeSplitter` (address): `0x222D6d4f1ce59b0d48D5505114eC8Addc90A4359`
- `_beneficiaryVault` (address): `0x0000000000000000000000000000000000000000`
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
