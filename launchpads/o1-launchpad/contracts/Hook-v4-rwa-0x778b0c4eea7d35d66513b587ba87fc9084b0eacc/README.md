# Hook-v4-rwa - 0x778b0c4eea7d35d66513b587ba87fc9084b0eacc

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x778b0c4eea7d35d66513b587ba87fc9084b0eacc
Role: Hook-v4-rwa.
Contract name: LaunchHook.
Verified: True (verified at 2026-07-24T21:54:21.221428Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/LaunchHook.sol.
Source files written: 25 under `sources/`.
Creator: 0x4e59b44847b379578588920cA78FbF26c0B4956C.
Creation tx: 0x51f168e597ff1f627573e1968b57f0751302f0d4bc4d274a14a111e9a55a08eb.
Proxy type: None; implementations: [].

## Constructor arguments

- `_poolManager` (address): `0x8366a39CC670B4001A1121B8F6A443A643e40951`
- `_deployer` (address): `0xc103Fce99EA5aDAcDdECE634EA6D036a42e757aE`

## Events

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
- `initialize(address,address)`
- `registerPool(tuple,tuple)`
- `seedLiquidity(tuple,tuple[],bool)`
- `unlockCallback(bytes)`

## View functions

- `MAX_BASE_FEE_BPS()`
- `MAX_TOTAL_FEE_BPS()`
- `deployer()`
- `factory()`
- `feeEscrow()`
- `getHookPermissions()`
- `poolConfig(bytes32)`
- `poolManager()`
- `wired()`
