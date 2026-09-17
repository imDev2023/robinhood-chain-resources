# RehypeDopplerHookInitializer - 0x5f9eb5f6726fe88d5e39867967f5b833d2fa3215

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x5f9eb5f6726fe88d5e39867967f5b833d2fa3215
Role: RehypeDopplerHookInitializer.
Verified: True (verified at 2026-08-17T15:26:01.358865Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 0.
Main file: src/dopplerHooks/RehypeDopplerHookInitializer.sol.
Source files written: 67 under `sources/`.
Creator: 0xE923E166B265e7E309Ed73Eb118eB8fddce9774d.
Creation tx: 0x016c882499e7f06df6cd5cd58a0685657c4f8300d238bd0f3a2da737b8fe6220.
Proxy type: None; implementations: [].

## Constructor arguments

- `initializer` (address): `0x4e3468951D49f2EEa976eD0D6e75fFCb44a9a544`
- `poolManager_` (address): `0x8366a39CC670B4001A1121B8F6A443A643e40951`
- `bundler_` (address): `0xf45588E8e0B1df9dB9ae7E20eCE5726AE931357c`

## Events

- AirlockOwnerFeesClaimed
- Collect
- FeeBeneficiariesSet
- FeeScheduleSet
- FeeUpdated
- Release
- UpdateBeneficiary

## State-changing functions

- `claimAirlockOwnerFees(address)`
- `collectFees(bytes32)`
- `collectFees(address)`
- `onGraduation(address,tuple,bytes)`
- `onInitialization(address,tuple,bytes)`
- `onSwap(address,tuple,tuple,int256,bytes)`
- `setFeeDistribution(bytes32,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256)`
- `updateBeneficiary(bytes32,address)`

## View functions

- `INITIALIZER()`
- `bundler()`
- `getCumulatedFees0(bytes32)`
- `getCumulatedFees1(bytes32)`
- `getFeeDistributionInfo(bytes32)`
- `getFeeRoutingMode(bytes32)`
- `getFeeSchedule(bytes32)`
- `getHookFees(bytes32)`
- `getLastCumulatedFees0(bytes32,address)`
- `getLastCumulatedFees1(bytes32,address)`
- `getPoolInfo(bytes32)`
- `getPoolKey(bytes32)`
- `getPosition(bytes32)`
- `getShares(bytes32,address)`
- `poolManager()`
- `quoter()`
