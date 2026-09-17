# FeeHookWeth - 0x35c0098836fa0d10a015a95bf02c16387814f0cc

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x35c0098836fa0d10a015a95bf02c16387814f0cc
Role: FeeHookWeth.
Contract name: SentryStockFeeHookV3.
Verified: True (verified at 2026-07-25T12:38:09.962444Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/SentryStockFeeHookV3.sol.
Source files written: 29 under `sources/`.
Creator: 0x4e59b44847b379578588920cA78FbF26c0B4956C.
Creation tx: 0x7121aa9c73954e5dd6581fb94d0407c69f59a5a87248334a9beeb2b1b4501a25.
Proxy type: None; implementations: [].

Uniswap v4 hook for plain WETH launches. Contract name SentryStockFeeHookV3.

## Constructor arguments

- `_poolManager` (address): `0x8366a39CC670B4001A1121B8F6A443A643e40951`
- `_factory` (address): `0x472286b7d5c1B2A3cE1132eF73d3BcCF446C5cc1`
- `_startFee` (uint24): `400000`
- `_endFee` (uint24): `17000`
- `_holdDuration` (uint256): `180`
- `_halfLife` (uint256): `180`
- `_reflectionStartDelay` (uint256): `0`
- `_earlyCreatorBps` (uint24): `5882`
- `_earlyTreasuryBps` (uint24): `0`
- `_lateReflectionBps` (uint24): `0`
- `_lateCreatorBps` (uint24): `5882`
- `_lateLpBps` (uint24): `1176`

## Events

- `AppFeePaid(address,address,bool,uint256,uint256)`
- `LaunchRecorded(bytes32,uint256)`
- `LaunchWhitelistSet(bytes32,uint256)`
- `LpCompounded(bytes32,uint256,uint128)`
- `LpFeeAccrued(bytes32,uint256)`
- `ReflectionPaid(address,address,uint256)`

## State-changing functions

- `afterInitialize(address,tuple,uint160,int24)`
- `afterSwap(address,tuple,tuple,int256,bytes)`
- `beforeSwap(address,tuple,tuple,bytes)`
- `compound(bytes32)`
- `setLaunchWhitelist(bytes32,bool,address[])`
- `unlockCallback(bytes)`

## View functions

- `baseIsCurrency0(bytes32)`
- `baseSideRegistered(bytes32)`
- `beforeInitialize(address,tuple,uint160)`
- `currentFee(bytes32)`
- `earlyCreatorBps()`
- `earlyTreasuryBps()`
- `endFee()`
- `factory()`
- `feeAtElapsed(uint256)`
- `halfLife()`
- `holdDuration()`
- `lateCreatorBps()`
- `lateLpBps()`
- `lateReflectionBps()`
- `launchWhitelist(bytes32,address)`
- `launchedAt(bytes32)`
- `lpAccruedBase(bytes32)`
- `poolManager()`
- `reflectionStartDelay()`
- `startFee()`
