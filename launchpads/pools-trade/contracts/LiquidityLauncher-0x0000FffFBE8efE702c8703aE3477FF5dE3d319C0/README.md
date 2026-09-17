# LiquidityLauncher - 0x0000FffFBE8efE702c8703aE3477FF5dE3d319C0

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x0000FffFBE8efE702c8703aE3477FF5dE3d319C0
Role: LiquidityLauncher.
Contract name: LiquidityLauncher.
Verified: True (sources from `smart-contracts`, flag from `addresses`).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/LiquidityLauncher.sol.
Source files written: 25 under `sources/`.
Creator: 0x4e59b44847b379578588920cA78FbF26c0B4956C.
Creation tx: 0xbf68c51ed936a2a33fa3450ccf245bad1df199a15392bfd754935ba4d6728ccc.
Proxy type: None; implementations: [].

## Constructor arguments

- `_permit2` (address): `0x000000000022D473030F116dDEE9F6B43aC78BA3`

## Events

- `TokenCreated(address)`
- `TokenDistributed(address,address,uint256)`

## State-changing functions

- `createToken(address,string,string,uint8,uint128,address,bytes)`
- `depositToken(address,uint160)`
- `distributeToken(address,tuple,bytes32)`
- `distributeWithNative(address,bytes,bytes32,uint256)`
- `multicall(bytes[])`
- `permit(address,tuple,bytes)`

## View functions

- `getGraffiti(address)`
- `permit2()`
