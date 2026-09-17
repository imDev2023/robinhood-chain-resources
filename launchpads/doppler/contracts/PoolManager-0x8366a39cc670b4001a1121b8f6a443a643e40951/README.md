# PoolManager - 0x8366a39cc670b4001a1121b8f6a443a643e40951

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x8366a39cc670b4001a1121b8f6a443a643e40951
Role: PoolManager.
Contract name: PoolManager.
Verified: True (verified at 2026-05-22T18:31:17.890895Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 44444444.
Main file: src/pkgs/v4-core/src/PoolManager.sol.
Source files written: 45 under `sources/`.
Creator: 0x4e59b44847b379578588920cA78FbF26c0B4956C.
Creation tx: 0x4fb28d4935866f462582c6c931c6f2705e55f5be5eb178c7d8d9329a95c44c41.
Proxy type: None; implementations: [].

Uniswap v4 singleton. Not a Doppler contract; every Doppler v4 pool on this chain is created here. Constructor argument of DopplerDeployer, DopplerHookInitializer, DopplerHookMigrator, UniswapV4Initializer, StreamableFeesLockerV2, Quoter and DopplerLensQuoter.

## Constructor arguments

None decoded.

## Events

- `Approval(address,address,uint256,uint256)`
- `Donate(bytes32,address,uint256,uint256)`
- `Initialize(bytes32,address,address,uint24,int24,address,uint160,int24)`
- `ModifyLiquidity(bytes32,address,int24,int24,int256,bytes32)`
- `OperatorSet(address,address,bool)`
- `OwnershipTransferred(address,address)`
- `ProtocolFeeControllerUpdated(address)`
- `ProtocolFeeUpdated(bytes32,uint24)`
- `Swap(bytes32,address,int128,int128,uint160,uint128,int24,uint24)`
- `Transfer(address,address,address,uint256,uint256)`

## State-changing functions

- `approve(address,uint256,uint256)`
- `burn(address,uint256,uint256)`
- `clear(address,uint256)`
- `collectProtocolFees(address,address,uint256)`
- `donate(tuple,uint256,uint256,bytes)`
- `initialize(tuple,uint160)`
- `mint(address,uint256,uint256)`
- `modifyLiquidity(tuple,tuple,bytes)`
- `setOperator(address,bool)`
- `setProtocolFee(tuple,uint24)`
- `setProtocolFeeController(address)`
- `settle()`
- `settleFor(address)`
- `swap(tuple,tuple,bytes)`
- `sync(address)`
- `take(address,address,uint256)`
- `transfer(address,uint256,uint256)`
- `transferFrom(address,address,uint256,uint256)`
- `transferOwnership(address)`
- `unlock(bytes)`
- `updateDynamicLPFee(tuple,uint24)`

## View functions

- `allowance(address,address,uint256)`
- `balanceOf(address,uint256)`
- `extsload(bytes32)`
- `extsload(bytes32,uint256)`
- `extsload(bytes32[])`
- `exttload(bytes32)`
- `exttload(bytes32[])`
- `isOperator(address,address)`
- `owner()`
- `protocolFeeController()`
- `protocolFeesAccrued(address)`
- `supportsInterface(bytes4)`
