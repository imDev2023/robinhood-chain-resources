# Multicall3-Virtuals - 0x3Eb3394F5D89465A77f73a83d3675B0Ed051F852

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x3Eb3394F5D89465A77f73a83d3675B0Ed051F852
Role: Multicall3-Virtuals.
Contract name: Multicall3.
Verified: True (verified at 2026-07-02T07:10:18.625223Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM paris, optimizer True runs 200.
Main file: contracts/launchpadv2/multicall3.sol.
Source files written: 5 under `sources/`.
Creator: 0xe4a0015B4c12f84bF9B8b9DB56b7ef0Bc539D88F.
Creation tx: 0x96e91db9bfbb6f1dd6c3162ba006e886ad0b22375004b10944d514590aac067e.
Proxy type: None; implementations: [].

Multicall3 deployed by the Virtuals deployer for the frontend.

## Constructor arguments

None decoded.

## Events

- `AdminGranted(address)`
- `AdminRevoked(address)`
- `OwnershipTransferred(address,address)`
- `TokenApproved(address,address,uint256)`
- `TokenTransferred(address,address,uint256)`

## State-changing functions

- `aggregate(tuple[])`
- `aggregate3(tuple[])`
- `aggregate3Value(tuple[])`
- `approveToken(address,address,uint256)`
- `batchApproveTokens(address[],address[],uint256[])`
- `batchTransferTokens(address[],address[],uint256[])`
- `batchWithdrawERC20Tokens(address[],address[],uint256[])`
- `blockAndAggregate(tuple[])`
- `grantAdmin(address)`
- `revokeAdmin(address)`
- `transferOwnership(address)`
- `transferToken(address,address,uint256)`
- `tryAggregate(bool,tuple[])`
- `tryBlockAndAggregate(bool,tuple[])`
- `withdrawERC20Token(address,address,uint256)`
- `withdrawETH(address,uint256)`

## View functions

- `admins(address)`
- `getBasefee()`
- `getBlockHash(uint256)`
- `getBlockNumber()`
- `getChainId()`
- `getCurrentBlockCoinbase()`
- `getCurrentBlockGasLimit()`
- `getCurrentBlockTimestamp()`
- `getEthBalance(address)`
- `getLastBlockHash()`
- `getTokenBalance(address)`
- `isAdmin(address)`
- `owner()`
