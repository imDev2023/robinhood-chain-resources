# DopplerHookInitializer - 0x4e3468951d49f2eea976ed0d6e75ffcb44a9a544

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x4e3468951d49f2eea976ed0d6e75ffcb44a9a544
Role: DopplerHookInitializer.
Verified: True (verified at 2026-07-01T20:06:20.801426Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 0.
Main file: src/initializers/DopplerHookInitializer.sol.
Source files written: 78 under `sources/`.
Creator: 0xdD429645eB203cAbffA48e56350f7F639e0a342b.
Creation tx: 0xd32e8ebbb51adc6b05d0608e3eaf289d8d648f4df42175990bbba2fcfbe700b1.
Proxy type: None; implementations: [].

## Constructor arguments

- `airlock_` (address): `0xeb7C034704eF8Dcd2D32324c1545f62fB4aD0862`
- `poolManager_` (address): `0x8366a39CC670B4001A1121B8F6A443A643e40951`

## Events

- Collect
- Create
- DelegateAuthority
- Graduate
- Lock
- ModifyLiquidity
- Release
- SetDopplerHook
- SetDopplerHookState
- Swap
- UpdateBeneficiary

## State-changing functions

- `afterAddLiquidity(address,tuple,tuple,int256,int256,bytes)`
- `afterDonate(address,tuple,uint256,uint256,bytes)`
- `afterInitialize(address,tuple,uint160,int24)`
- `afterRemoveLiquidity(address,tuple,tuple,int256,int256,bytes)`
- `afterSwap(address,tuple,tuple,int256,bytes)`
- `beforeAddLiquidity(address,tuple,tuple,bytes)`
- `beforeDonate(address,tuple,uint256,uint256,bytes)`
- `beforeInitialize(address,tuple,uint160)`
- `beforeRemoveLiquidity(address,tuple,tuple,bytes)`
- `beforeSwap(address,tuple,tuple,bytes)`
- `collectFees(bytes32)`
- `delegateAuthority(address)`
- `exitLiquidity(address)`
- `graduate(address)`
- `initialize(address,address,uint256,bytes32,bytes)`
- `setDopplerHook(address,address,bytes,bytes)`
- `setDopplerHookState(address[],uint256[])`
- `unlockCallback(bytes)`
- `updateBeneficiary(bytes32,address)`
- `updateDynamicLPFee(address,uint24)`

## View functions

- `airlock()`
- `getAuthority(address)`
- `getBeneficiaries(address)`
- `getCumulatedFees0(bytes32)`
- `getCumulatedFees1(bytes32)`
- `getHookPermissions()`
- `getLastCumulatedFees0(bytes32,address)`
- `getLastCumulatedFees1(bytes32,address)`
- `getPoolKey(bytes32)`
- `getShares(bytes32,address)`
- `getState(address)`
- `isDopplerHookEnabled(address)`
- `poolManager()`
