# BagsV4HookOld - 0x208378dDc05eD5De1833624a30EB9C1d26f86EcC

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x208378dDc05eD5De1833624a30EB9C1d26f86EcC
Role: BagsV4HookOld.
Contract name: BagsV4Hook.
Verified: True (verified at 2026-07-10T15:35:32.360906Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/BagsV4Hook.sol.
Source files written: 33 under `sources/`.
Creator: 0x4e59b44847b379578588920cA78FbF26c0B4956C.
Creation tx: 0x091d6cc451e19e9e8f9c8e0488df807de8c9f909936ebae9745264761d1ea83e.
Proxy type: None; implementations: [].

Earlier BagsV4Hook deployment through the CREATE2 deployer, not referenced by the live factory.

## Constructor arguments

- `_poolManager` (address): `0x8366a39CC670B4001A1121B8F6A443A643e40951`
- `weth` (address): `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`
- `vault_` (address): `0x26e421917aeA64B615A3127A2BA3AC3051C3ab80`
- `initialOwner` (address): `0xC6c66AeEbe18e3d1027a4b0b38cE0071616D6464`

## Events

- `FactorySet(address)`
- `FeesSwept(bytes32,uint256,uint256)`
- `HookFeeTaken(bytes32,uint256)`
- `OwnershipTransferred(address,address)`
- `PoolMinted(bytes32,address,address)`
- `PoolRegistered(bytes32,address,address)`

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
- `register(bytes32,address,address)`
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
