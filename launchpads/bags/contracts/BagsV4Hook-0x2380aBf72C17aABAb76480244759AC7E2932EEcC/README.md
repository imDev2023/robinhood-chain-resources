# BagsV4Hook - 0x2380aBf72C17aABAb76480244759AC7E2932EEcC

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x2380aBf72C17aABAb76480244759AC7E2932EEcC
Role: BagsV4Hook.
Contract name: BagsV4Hook.
Verified: True (verified at 2026-07-12T14:55:44.849827Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/BagsV4Hook.sol.
Source files written: 33 under `sources/`.
Creator: 0x4e59b44847b379578588920cA78FbF26c0B4956C.
Creation tx: 0xb80eb1539ede1990e616f262b0f2bf753016eb5b2d7f1731a6159c7c6f02edfc.
Proxy type: None; implementations: [].

Live singleton hook set in the factory (`factory.hook()` on 2026-09-02).

## Constructor arguments

None decoded.

## Events

- `FactorySet(address)`
- `FeesSwept(bytes32,uint256,uint256,uint256)`
- `HookFeeTaken(bytes32,uint256)`
- `OwnershipTransferred(address,address)`
- `PoolMinted(bytes32,address,address)`
- `PoolRegistered(bytes32,address,address,address,uint16)`

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
- `register(bytes32,address,address,address,uint16)`
- `renounceOwnership()`
- `setFactory(address)`
- `sweep(bytes32)`
- `transferOwnership(address)`

## View functions

- `VAULT()`
- `WETH()`
- `factory()`
- `getHookPermissions()`
- `owner()`
- `poolManager()`
- `pools(bytes32)`
