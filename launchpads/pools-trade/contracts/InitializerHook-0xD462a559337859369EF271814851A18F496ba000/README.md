# InitializerHook - 0xD462a559337859369EF271814851A18F496ba000

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xD462a559337859369EF271814851A18F496ba000
Role: InitializerHook.
Contract name: InitializerHook.
Verified: True (sources from `smart-contracts`, flag from `addresses`).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/periphery/hooks/InitializerHook.sol.
Source files written: 24 under `sources/`.
Creator: 0x4e59b44847b379578588920cA78FbF26c0B4956C.
Creation tx: 0xa5ea683b9196f0c53d3410bfa065fc0c81ca062ac06c100d8fa0e9a2ac0718e3.
Proxy type: None; implementations: [].

## Constructor arguments

- `_poolManager` (address): `0x8366a39CC670B4001A1121B8F6A443A643e40951`
- `_authorized` (address): `0x05d552391067389EE44fec3924157ed33F976000`

## Events

None.

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

## View functions

- `authorized()`
- `getHookPermissions()`
- `poolManager()`
- `supportsInterface(bytes4)`
