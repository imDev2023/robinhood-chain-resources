# DopplerHookMigrator - 0x7bf319d8e969f7596b1bc171da9ce322f67ae0c4

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x7bf319d8e969f7596b1bc171da9ce322f67ae0c4
Role: DopplerHookMigrator.
Verified: True (verified at 2026-07-01T19:43:20.755320Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 0.
Main file: src/migrators/DopplerHookMigrator.sol.
Source files written: 53 under `sources/`.
Creator: 0x39c61afDC68423483847afB2E5c592A80Dd6095F.
Creation tx: 0x7e76a2e3198ecc5aa710e634ff9fcffc443cb1a5ad084e29268341a9c836bbac.
Proxy type: None; implementations: [].

## Constructor arguments

- `airlock_` (address): `0xeb7C034704eF8Dcd2D32324c1545f62fB4aD0862`
- `poolManager_` (address): `0x8366a39CC670B4001A1121B8F6A443A643e40951`
- `locker_` (address): `0x7B6147AC3F615bdb764e7EbD5f517dac1AD163B8`
- `topUpDistributor` (address): `0x46adee7595d48b1Ec53090e9bc78e1E69Fa0eF06`

## Events

- DelegateAuthority
- DistributeSplit
- Migrate
- SetDopplerHook
- SetDopplerHookState
- Swap

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
- `delegateAuthority(address)`
- `initialize(address,address,bytes)`
- `migrate(uint160,address,address,address)`
- `setDopplerHook(address,address,bytes)`
- `setDopplerHookState(address[],uint256[])`
- `updateDynamicLPFee(address,uint24)`

## View functions

- `TOP_UP_DISTRIBUTOR()`
- `airlock()`
- `getAssetData(address,address)`
- `getAuthority(address)`
- `getHookPermissions()`
- `getPair(address)`
- `isDopplerHookEnabled(address)`
- `locker()`
- `poolManager()`
- `splitConfigurationOf(address,address)`
