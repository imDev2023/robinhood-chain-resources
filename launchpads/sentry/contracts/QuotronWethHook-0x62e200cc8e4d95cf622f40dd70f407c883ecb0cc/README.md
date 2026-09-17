# QuotronWethHook - 0x62e200cc8e4d95cf622f40dd70f407c883ecb0cc

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x62e200cc8e4d95cf622f40dd70f407c883ecb0cc
Role: QuotronWethHook.
Contract name: QuotronWethHook.
Verified: True (verified at 2026-08-13T15:24:10.052704Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/v2/QuotronWethHook.sol.
Source files written: 19 under `sources/`.
Creator: 0x4e59b44847b379578588920cA78FbF26c0B4956C.
Creation tx: 0x048c383f1cc346a29e53fce209a4c411224b4a8be25913b7ce60eda63152f2b5.
Proxy type: None; implementations: [].

Quotrons Uniswap v4 fee hook on the QUOTRON/WETH pool.

## Constructor arguments

- `poolManager_` (address): `0x8366a39CC670B4001A1121B8F6A443A643e40951`
- `quotron_` (address): `0x5a86828Efd322bfb16d93cFeD16EE9BC14940D7F`
- `weth_` (address): `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`
- `whitelist_` (address): `0x94CfC3798Ca6320Ac5e6af04484EFE90bD04aC81`
- `keeper_` (address): `0xd1dE50B724de2e243D3f6f3C3ef1806BABD39e58`
- `owner_` (address): `0x7171E64E979265aeD6588577D1c6b60A701d7866`

## Events

- `BuyerMarked(address,uint256)`
- `CanonicalRouterConfigured(address)`
- `FeeTaken(bytes32,address,uint256,uint256,uint256,uint256,uint256,uint256)`
- `LaunchFeesFinalized()`
- `Paused(bool)`
- `PoolRegistered(bytes32,bool)`
- `PotPulled(uint8,address,uint256)`
- `SinksSealed(address,address,address,address)`

## State-changing functions

- `afterSwap(address,tuple,tuple,int256,bytes)`
- `beforeSwap(address,tuple,tuple,bytes)`
- `configureAndSealSinks(address,address,address,address)`
- `configureCanonicalRouter(address)`
- `finalizeLaunchFees()`
- `pullBurn(uint256)`
- `pullLp(uint256)`
- `pullReflections(uint256)`
- `registerPool(tuple)`
- `setPaused(bool)`
- `transferOwnership(address)`

## View functions

- `afterInitialize(address,tuple,uint160,int24)`
- `beforeInitialize(address,tuple,uint160)`
- `burnPot()`
- `burnSink()`
- `canonicalRouter()`
- `creator()`
- `currentFeeBps(address)`
- `isTransferRestricted(address)`
- `keeper()`
- `launchFeesFinalized()`
- `lpPot()`
- `lpSink()`
- `markedTimeRemaining(address)`
- `markedUntil(address)`
- `owner()`
- `paused()`
- `poolManager()`
- `poolRegistered()`
- `quotron()`
- `reflectionPot()`
- `reflectionSink()`
- `registeredPool()`
- `sinksSealed()`
- `weth()`
- `wethIsCurrency0()`
- `whitelist()`
