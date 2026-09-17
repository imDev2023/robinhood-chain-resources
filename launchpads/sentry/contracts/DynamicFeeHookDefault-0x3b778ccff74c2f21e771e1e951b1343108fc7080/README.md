# DynamicFeeHookDefault - 0x3b778ccff74c2f21e771e1e951b1343108fc7080

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x3b778ccff74c2f21e771e1e951b1343108fc7080
Role: DynamicFeeHookDefault.
Contract name: SentryDynamicFeeHook.
Verified: True (verified at 2026-08-09T04:23:11.570028Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/SentryDynamicFeeHook.sol.
Source files written: 12 under `sources/`.
Creator: 0x4e59b44847b379578588920cA78FbF26c0B4956C.
Creation tx: 0x83c5bb0da106aad63116d4aa57373fa2f31f74edc4119b45f785843e214bff64.
Proxy type: None; implementations: [].

SentryDynamicFeeHook, the value returned by `hook()` on the stock factory. Fee curve only, no fee legs; every registered stock base token overrides it through `baseTokenToHook`.

## Constructor arguments

- `_poolManager` (address): `0x8366a39CC670B4001A1121B8F6A443A643e40951`
- `_factory` (address): `0xd0A93885a387e3a8a14dd82776CF9104a3676b3A`
- `_startFee` (uint24): `400000`
- `_endFee` (uint24): `12500`
- `_holdDuration` (uint256): `180`
- `_halfLife` (uint256): `180`

## Events

- `LaunchRecorded(bytes32,uint256)`
- `LaunchWhitelistSet(bytes32,uint256)`

## State-changing functions

- `afterInitialize(address,tuple,uint160,int24)`
- `setLaunchWhitelist(bytes32,bool,address[])`

## View functions

- `baseIsCurrency0(bytes32)`
- `beforeInitialize(address,tuple,uint160)`
- `beforeSwap(address,tuple,tuple,bytes)`
- `currentFee(bytes32)`
- `endFee()`
- `factory()`
- `feeAtElapsed(uint256)`
- `halfLife()`
- `holdDuration()`
- `launchWhitelist(bytes32,address)`
- `launchedAt(bytes32)`
- `poolManager()`
- `startFee()`
