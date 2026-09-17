# LongLaunchHelper - 0xa97faace9a0222af631d8b25fc8c6df46d6555f4

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xa97faace9a0222af631d8b25fc8c6df46d6555f4
Role: LongLaunchHelper.
Contract name: LongLaunchHelper.
Verified: True (verified at 2026-08-29T14:46:38.447000Z).
Compiler: 0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: contracts/LongLaunchHelper.sol.
Source files written: 1 under `sources/`.
Creator: 0x0e9f0E44dE744D5Ee86b8b8E3145d6901336D686.
Creation tx: 0xa7572fc394f8f2f00173fdb0bbd896e83819eff887e0c34541191c84c8fe41a6.
Proxy type: None; implementations: [].

Helper deployed 2026-08-29 that wraps LongLauncher, PoolManager and DopplerHookInitializer. See section 5 of README.md for what it does.

## Constructor arguments

- `launcher_` (address): `0x22e99278308B393ea1260859B181AD7E78f5eeED`
- `poolManager_` (address): `0x8366a39CC670B4001A1121B8F6A443A643e40951`
- `hook_` (address): `0x4e3468951D49f2EEa976eD0D6e75fFCb44a9a544`
- `tickSpacing_` (int24): `8`

## Events

- `BoughtFor(address,address,uint256,uint256)`
- `LaunchedAndBought(address,address,uint256,uint256)`

## State-changing functions

- `launchAndBuyExactOut(tuple,uint256)`
- `launchAndBuyExactOutWithToken(tuple,address,uint256,uint256)`
- `unlockCallback(bytes)`

## View functions

- `hook()`
- `launcher()`
- `poolManager()`
- `tickSpacing()`
