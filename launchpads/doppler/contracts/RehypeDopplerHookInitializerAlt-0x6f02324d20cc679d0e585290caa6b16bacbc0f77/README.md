# RehypeDopplerHookInitializerAlt - 0x6f02324d20cc679d0e585290caa6b16bacbc0f77

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x6f02324d20cc679d0e585290caa6b16bacbc0f77
Role: RehypeDopplerHookInitializerAlt.
Contract name: RehypeDopplerHookInitializer.
Verified: True (verified at 2026-07-01T19:43:17.715004Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 0.
Main file: src/dopplerHooks/RehypeDopplerHookInitializer.sol.
Source files written: 67 under `sources/`.
Creator: 0xF7483Cb279eb3AfB8db553787363C2990836b459.
Creation tx: 0xcf07d91c0e5d3ec94b271c90727d03a53b2c308b3b2f5b196e0e0573144b5099.
Proxy type: None; implementations: [].

A second RehypeDopplerHookInitializer deployment, distinct from the canonical 0x5f9eb5f6726fe88d5e39867967f5b833d2fa3215 in the Doppler docs. Not whitelisted as an Airlock module (getModuleState returns 0), but enabled as a Doppler hook (DopplerHookInitializer.isDopplerHookEnabled returns 3), and attached as `dopplerHook` on every Long launch. app.doppler.lol calls getState(address) on it. Corrected 2026-09-02 from the Long session (resources/launchpads/long/_raw/rpc/hook-state-top-tokens.txt).

## Constructor arguments

- `initializer` (address): `0x4e3468951D49f2EEa976eD0D6e75fFCb44a9a544`
- `poolManager_` (address): `0x8366a39CC670B4001A1121B8F6A443A643e40951`

## Events

- `AirlockOwnerFeesClaimed(bytes32,address,uint128,uint128)`
- `FeeScheduleSet(bytes32,uint32,uint24,uint24,uint32)`
- `FeeUpdated(bytes32,uint24)`

## State-changing functions

- `claimAirlockOwnerFees(address)`
- `collectFees(address)`
- `onGraduation(address,tuple,bytes)`
- `onInitialization(address,tuple,bytes)`
- `onSwap(address,tuple,tuple,int256,bytes)`

## View functions

- `INITIALIZER()`
- `getFeeDistributionInfo(bytes32)`
- `getFeeRoutingMode(bytes32)`
- `getFeeSchedule(bytes32)`
- `getHookFees(bytes32)`
- `getPoolInfo(bytes32)`
- `getPosition(bytes32)`
- `poolManager()`
- `quoter()`
