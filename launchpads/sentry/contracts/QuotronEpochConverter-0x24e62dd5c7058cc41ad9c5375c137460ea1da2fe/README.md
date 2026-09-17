# QuotronEpochConverter - 0x24e62dd5c7058cc41ad9c5375c137460ea1da2fe

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x24e62dd5c7058cc41ad9c5375c137460ea1da2fe
Role: QuotronEpochConverter.
Contract name: QuotronEpochConverter.
Verified: True (verified at 2026-08-13T15:25:28.494955Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/v2/QuotronEpochConverter.sol.
Source files written: 19 under `sources/`.
Creator: 0x7171E64E979265aeD6588577D1c6b60A701d7866.
Creation tx: 0xf347e22c9b5aeba37ab77439fdd2f13755485b0a0ff5a6de063826057f8a5c62.
Proxy type: None; implementations: [].

Quotrons epoch converter for reward drops.

## Constructor arguments

- `poolManager_` (address): `0x8366a39CC670B4001A1121B8F6A443A643e40951`
- `v3Router_` (address): `0xCaf681a66D020601342297493863E78C959E5cb2`
- `hook_` (address): `0x62E200Cc8e4D95cf622f40Dd70f407C883EcB0cc`
- `reflections_` (address): `0xe04fba61FD54Ba78Dd450A30d8Af40167aF5d3Ec`
- `weth_` (address): `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`
- `usdg_` (address): `0x5fc5360D0400a0Fd4f2af552ADD042D716F1d168`
- `wethUsdgFee_` (uint24): `100`
- `minEpochWeth_` (uint256): `100000000000000000`
- `maxEpochWeth_` (uint256): `100000000000000000000`
- `minEpochInterval_` (uint256): `60`
- `owner_` (address): `0x7171E64E979265aeD6588577D1c6b60A701d7866`

## Events

- `EpochOpened(uint256,uint256)`
- `ExecutorSet(address)`
- `FloorConverted(uint256,uint8,uint256,uint256,uint256)`
- `Paused(bool)`
- `RoutesSealed()`

## State-changing functions

- `convertFloor(uint8,uint256,uint256,uint256,uint256)`
- `openEpoch()`
- `sealRoutes()`
- `setExecutor(address)`
- `setPaused(bool)`
- `setRoute(uint8,address,uint24,int24,address)`
- `transferOwnership(address)`
- `unlockCallback(bytes)`

## View functions

- `budgetTotal()`
- `epochNumber()`
- `executor()`
- `floorBudget(uint256)`
- `hook()`
- `lastEpochAt()`
- `maxEpochWeth()`
- `minEpochInterval()`
- `minEpochWeth()`
- `owner()`
- `paused()`
- `poolManager()`
- `reflections()`
- `routes(uint256)`
- `routesSealed()`
- `usdg()`
- `v3Router()`
- `weth()`
- `wethUsdgFee()`
