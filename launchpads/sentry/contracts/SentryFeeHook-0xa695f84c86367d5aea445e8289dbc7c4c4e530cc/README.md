# SentryFeeHook - 0xa695f84c86367d5aea445e8289dbc7c4c4e530cc

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xa695f84c86367d5aea445e8289dbc7c4c4e530cc
Role: SentryFeeHook.
Contract name: SentrySentryFeeHook.
Verified: True (verified at 2026-07-28T15:49:34.205789Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/SentrySentryFeeHook.sol.
Source files written: 29 under `sources/`.
Creator: 0x4e59b44847b379578588920cA78FbF26c0B4956C.
Creation tx: 0x7e44cc1da1a99eeed770f86990c2a3423a3ef75c2dee02f2b24775899a7227f5.
Proxy type: None; implementations: [].

Bespoke v4 hook for the SENTRY/WETH pool, with an 80% early-exit fee on sellers still inside the migration lock.

## Constructor arguments

- `_poolManager` (address): `0x8366a39CC670B4001A1121B8F6A443A643e40951`
- `_launcher` (address): `0x0ba59e256b7657163A06eB900605688Bb1E74b42`
- `_weth` (address): `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`
- `_sentry` (address): `0x1EcA20cfa4AF2e2fA2F4CE2bF8d97bFa184FD4D7`
- `_treasury` (address): `0xFFC93474D99f07e8d0F1c7c8c5B93BaA2feDDd07`
- `_startFee` (uint24): `400000`
- `_endFee` (uint24): `20000`
- `_holdDuration` (uint256): `180`
- `_halfLife` (uint256): `180`
- `_reflectionShareBps` (uint24): `3750`
- `_lpShareBps` (uint24): `3750`
- `_treasuryShareBps` (uint24): `2500`
- `_earlyExitFee` (uint24): `800000`

## Events

- `EarlyExitFeePaid(bytes32,address,uint256)`
- `LaunchRecorded(bytes32,uint256)`
- `LaunchWhitelistSet(bytes32,uint256)`
- `LpCompounded(bytes32,uint256,uint128)`
- `LpFeeAccrued(bytes32,uint256)`
- `ReflectionPaid(bytes32,uint256)`
- `TreasuryReflectionPaid(bytes32,uint256)`

## State-changing functions

- `afterInitialize(address,tuple,uint160,int24)`
- `afterSwap(address,tuple,tuple,int256,bytes)`
- `beforeSwap(address,tuple,tuple,bytes)`
- `compound(bytes32)`
- `setLaunchWhitelist(bytes32,bool,address[])`
- `unlockCallback(bytes)`

## View functions

- `baseIsCurrency0(bytes32)`
- `beforeInitialize(address,tuple,uint160)`
- `currentFee(bytes32)`
- `earlyExitFee()`
- `endFee()`
- `feeAtElapsed(uint256)`
- `halfLife()`
- `holdDuration()`
- `launchWhitelist(bytes32,address)`
- `launchedAt(bytes32)`
- `launcher()`
- `lpAccruedWeth(bytes32)`
- `lpShareBps()`
- `poolManager()`
- `reflectionShareBps()`
- `sentry()`
- `startFee()`
- `treasury()`
- `treasuryShareBps()`
- `weth()`
