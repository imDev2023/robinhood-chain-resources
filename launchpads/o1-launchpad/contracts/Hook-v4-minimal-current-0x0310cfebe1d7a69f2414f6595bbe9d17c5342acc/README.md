# Hook-v4-minimal-current - 0x0310cfebe1d7a69f2414f6595bbe9d17c5342acc

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x0310cfebe1d7a69f2414f6595bbe9d17c5342acc
Role: Hook-v4-minimal-current.
Contract name: LaunchHook.
Verified: True (verified at 2026-08-31T23:28:38.111353Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/LaunchHook.sol.
Source files written: 27 under `sources/`.
Creator: 0x4e59b44847b379578588920cA78FbF26c0B4956C.
Creation tx: 0x57f71d53dd5b0917b207f47bafb7185cb19f8015e7d5ca86842e8a33d3116b99.
Proxy type: None; implementations: [].

## Constructor arguments

None decoded.

## Events

- `CreatorRightsUpdated(bytes32,address,address,address,address)`
- `FeeComponentCredited(bytes32,bytes32,address,address,uint256)`
- `Initialized(uint64)`
- `PoolRegistered(bytes32,address,address,uint16)`
- `Seeded(bytes32,uint256)`
- `Trade(bytes32,address,address,address,uint256,bytes32)`
- `Wired(address,address)`

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
- `executeLaunchBuy(bytes32,tuple)`
- `initialize(address,address)`
- `registerPool(tuple,tuple,tuple[])`
- `seedLiquidity(tuple,tuple[],bool)`
- `setLaunchBuyAdapter(address)`
- `unlockCallback(bytes)`
- `updateCreatorRights(bytes32,address,address)`

## View functions

- `MAX_BASE_FEE_BPS()`
- `MAX_FEE_COMPONENTS()`
- `MAX_LAUNCH_BUY_ROUTE_DATA_LENGTH()`
- `MAX_TOTAL_FEE_BPS()`
- `deployer()`
- `factory()`
- `feeEscrow()`
- `getHookPermissions()`
- `launchBuyAdapter()`
- `poolConfig(bytes32)`
- `poolFeeComponents(bytes32)`
- `poolManager()`
- `wired()`
