# RelaunchLauncher - 0x0ba59e256b7657163a06eb900605688bb1e74b42

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x0ba59e256b7657163a06eb900605688bb1e74b42
Role: RelaunchLauncher.
Contract name: SentryRelaunchLauncher.
Verified: True (verified at 2026-07-28T15:49:01.356888Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/SentryRelaunchLauncher.sol.
Source files written: 23 under `sources/`.
Creator: 0xbF551eED83c7eaEE63854a2013Eb94f18600B7C5.
Creation tx: 0x4460fd2b5355dc910e39e96f35e4d31c41a1489228916a4e0cac17e9b8b858b9.
Proxy type: None; implementations: [].

Deployer of the SENTRY relaunch pool; `launcher()` on the SENTRY hook.

## Constructor arguments

- `_poolManager` (address): `0x8366a39CC670B4001A1121B8F6A443A643e40951`
- `_weth` (address): `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`
- `_sentry` (address): `0x1EcA20cfa4AF2e2fA2F4CE2bF8d97bFa184FD4D7`
- `_owner` (address): `0xbF551eED83c7eaEE63854a2013Eb94f18600B7C5`

## Events

- `HookSet(address)`
- `Launched(bytes32,uint128,uint256,uint256)`
- `OwnershipTransferred(address,address)`
- `Swept(address,address,uint256)`

## State-changing functions

- `launch(tuple)`
- `setHook(address)`
- `setLaunchWhitelist(bool,address[])`
- `sweep(address)`
- `transferOwnership(address)`
- `unlockCallback(bytes)`

## View functions

- `hook()`
- `launched()`
- `owner()`
- `poolKey()`
- `poolKeyWithSpacing(int24)`
- `poolManager()`
- `sentry()`
- `weth()`
