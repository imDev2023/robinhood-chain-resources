# PositionManager - 0x58daec3116aae6D93017bAAea7749052E8a04fA7

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x58daec3116aae6D93017bAAea7749052E8a04fA7
Role: PositionManager.
Contract name: PositionManager.
Verified: True (sources from `smart-contracts`, flag from `addresses`).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 30000.
Main file: src/pkgs/v4-periphery/src/PositionManager.sol.
Source files written: 71 under `sources/`.
Creator: 0x4e59b44847b379578588920cA78FbF26c0B4956C.
Creation tx: 0x228c18ada6cb46b4fbcc18f4ec1519953415393e256fa8349aafbd5a2db037c8.
Proxy type: None; implementations: [].

## Constructor arguments

None decoded.

## Events

- `Approval(address,address,uint256)`
- `ApprovalForAll(address,address,bool)`
- `Subscription(uint256,address)`
- `Transfer(address,address,uint256)`
- `Unsubscription(uint256,address)`

## State-changing functions

- `approve(address,uint256)`
- `initializePool(tuple,uint160)`
- `modifyLiquidities(bytes,uint256)`
- `modifyLiquiditiesWithoutUnlock(bytes,bytes[])`
- `multicall(bytes[])`
- `permit(address,tuple,bytes)`
- `permit(address,uint256,uint256,uint256,bytes)`
- `permitBatch(address,tuple,bytes)`
- `permitForAll(address,address,bool,uint256,uint256,bytes)`
- `revokeNonce(uint256)`
- `safeTransferFrom(address,address,uint256)`
- `safeTransferFrom(address,address,uint256,bytes)`
- `setApprovalForAll(address,bool)`
- `subscribe(uint256,address,bytes)`
- `transferFrom(address,address,uint256)`
- `unlockCallback(bytes)`
- `unsubscribe(uint256)`

## View functions

- `DOMAIN_SEPARATOR()`
- `WETH9()`
- `balanceOf(address)`
- `getApproved(uint256)`
- `getPoolAndPositionInfo(uint256)`
- `getPositionLiquidity(uint256)`
- `isApprovedForAll(address,address)`
- `msgSender()`
- `name()`
- `nextTokenId()`
- `nonces(address,uint256)`
- `ownerOf(uint256)`
- `permit2()`
- `poolKeys(bytes25)`
- `poolManager()`
- `positionInfo(uint256)`
- `subscriber(uint256)`
- `supportsInterface(bytes4)`
- `symbol()`
- `tokenDescriptor()`
- `tokenURI(uint256)`
- `unsubscribeGasLimit()`
