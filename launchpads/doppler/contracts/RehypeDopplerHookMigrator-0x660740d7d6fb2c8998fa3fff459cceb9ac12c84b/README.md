# RehypeDopplerHookMigrator - 0x660740d7d6fb2c8998fa3fff459cceb9ac12c84b

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x660740d7d6fb2c8998fa3fff459cceb9ac12c84b
Role: RehypeDopplerHookMigrator.
Verified: True (verified at 2026-08-10T21:33:31.535259Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 0.
Main file: src/dopplerHooks/RehypeDopplerHookMigrator.sol.
Source files written: 69 under `sources/`.
Creator: 0x11536E93dCEE32d5FaB0950865fc02204D6AC354.
Creation tx: 0x17f08a11b651c80e55bd33e493b70d1f7f18bf4f38d64563838be3cfc460ef08.
Proxy type: None; implementations: [].

## Constructor arguments

- `migrator` (address): `0x7BF319d8e969f7596B1Bc171Da9ce322f67Ae0c4`
- `poolManager_` (address): `0x8366a39CC670B4001A1121B8F6A443A643e40951`

## Events

- AirlockOwnerFeesClaimed

## State-changing functions

- `claimAirlockOwnerFees(address)`
- `collectFees(address)`
- `onAfterSwap(address,tuple,tuple,int256,bytes)`
- `onBeforeSwap(address,tuple,tuple,bytes)`
- `onInitialization(address,tuple,bytes)`
- `setFeeDistribution(bytes32,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256)`

## View functions

- `MIGRATOR()`
- `getFeeDistributionInfo(bytes32)`
- `getFeeRoutingMode(bytes32)`
- `getHookFees(bytes32)`
- `getPoolInfo(bytes32)`
- `getPosition(bytes32)`
- `poolManager()`
- `quoter()`
