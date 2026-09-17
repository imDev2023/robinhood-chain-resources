# QuotronWethLpVault - 0x4b7a4f53d9b7e4b4941bc9cf74e852d55444ccbe

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x4b7a4f53d9b7e4b4941bc9cf74e852d55444ccbe
Role: QuotronWethLpVault.
Contract name: QuotronWethLpVault.
Verified: True (verified at 2026-08-13T15:26:49.721739Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/v2/QuotronWethLpVault.sol.
Source files written: 17 under `sources/`.
Creator: 0x7171E64E979265aeD6588577D1c6b60A701d7866.
Creation tx: 0x67b7373a871152fbe9419c0c28c5485e32f9b2e8b4c637a6bdfcf8fa42260c21.
Proxy type: None; implementations: [].

Quotrons LP custodian.

## Constructor arguments

- `poolManager_` (address): `0x8366a39CC670B4001A1121B8F6A443A643e40951`
- `hook_` (address): `0x62E200Cc8e4D95cf622f40Dd70f407C883EcB0cc`
- `quotron_` (address): `0x5a86828Efd322bfb16d93cFeD16EE9BC14940D7F`
- `weth_` (address): `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`
- `poolKey_` (tuple): `['0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73', '0x5a86828Efd322bfb16d93cFeD16EE9BC14940D7F', '8388608', '60', '0x62E200Cc8e4D95cf622f40Dd70f407C883EcB0cc']`
- `owner_` (address): `0x7171E64E979265aeD6588577D1c6b60A701d7866`

## Events

- `ExecutorSet(address)`
- `LiquidityLocked(bytes32,int24,int24,int256,uint256)`
- `Paused(bool)`
- `WethPulled(uint256)`

## State-changing functions

- `compound(uint256,int24,int24,int256,uint256,uint256)`
- `setExecutor(address)`
- `setPaused(bool)`
- `transferOwnership(address)`
- `unlockCallback(bytes)`

## View functions

- `executor()`
- `hook()`
- `managedWeth()`
- `owner()`
- `paused()`
- `poolId()`
- `poolKey()`
- `poolManager()`
- `positionNonce()`
- `quotron()`
- `weth()`
- `wethIsCurrency0()`
