# LaunchHook - 0xe6234a98fF84220CcDA12985548ddAb36327Aacc

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xe6234a98fF84220CcDA12985548ddAb36327Aacc
Role: LaunchHook.
Contract name: LaunchHook.
Verified: True (verified at 2026-08-29T18:37:47.625005Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 800.
Main file: src/LaunchHook.sol.
Source files on disk: 33 under `sources/`.
Creator: 0x4e59b44847b379578588920cA78FbF26c0B4956C.
Creation tx: 0x8ff15fcd04e8f94eb7904f759774c26d22466ea20b8a596c37e0edb1689be550.
Proxy type: None; implementations: [].
External libraries: none.

## What it does

The fee engine and the liquidity lock.
`beforeInitialize` refuses any pool not opened by the factory, `beforeAddLiquidity` allows exactly one seed add per pool, and `beforeRemoveLiquidity` always reverts, which is what makes the liquidity permanent.
`beforeSwap`/`afterSwap` take the fee on the quote side and book it as ERC-6909 claims against the PoolManager.
`PROTOCOL_FEE_PIPS` is 10000, a fixed 1%; `MAX_CREATOR_FEE_BPS` is 900, a 9% creator add-on; `MAX_FEE_RATE` is 100000, a hard 10% ceiling including the anti-snipe surge.
The surge decays linearly to zero over `snipeWindow` blocks.
`settle` is permissionless and splits accrued fees into `creatorTab` and `platformTab`; only `feeRouter` may call `collectPlatform`.
Live state at capture: `owner` 0xfe2cF227e21C5FC54dcE8Bb65F7C1E1E90236862, `feeRouter` **0xbd40E13889Cd75D8019CfbaA4f3C5562ba242279, which is an EOA, not the FeeRouter contract in this archive** (`_raw/rpc/router-updates.txt`).

## Constructor arguments

None decoded.

## Events

- `CreatorFeesClaimed(bytes32,address,uint256)`
- `CreatorTransferStarted(bytes32,address,address)`
- `CreatorUpdated(bytes32,address,address)`
- `FeeAccrued(bytes32,uint256)`
- `FeesSettled(bytes32,address,uint256,uint256)`
- `OwnershipTransferStarted(address,address)`
- `OwnershipTransferred(address,address)`
- `PlatformCollected(address,address,uint256)`
- `PoolRegistered(bytes32,address,tuple)`
- `RouterUpdated(address,address)`
- `SettleSkipped(bytes32)`

## State-changing functions

- `acceptCreator(bytes32)`
- `acceptOwnership()`
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
- `cancelCreatorTransfer(bytes32)`
- `claim(bytes32,address)`
- `collectPlatform(address,uint256)`
- `register(bytes32,address,address,bool,uint16,uint24,uint24)`
- `renounceOwnership()`
- `setFeeRouter(address)`
- `settle(bytes32)`
- `settleMany(bytes32[])`
- `settleSelf(bytes32)`
- `transferCreator(bytes32,address)`
- `transferOwnership(address)`
- `unlockCallback(bytes)`

## View functions

- `BPS()`
- `MAX_CREATOR_FEE_BPS()`
- `MAX_FEE_RATE()`
- `PIPS()`
- `PROTOCOL_FEE_PIPS()`
- `creatorOf(bytes32)`
- `creatorPending(bytes32)`
- `creatorTab(bytes32)`
- `currentFeeRate(bytes32,address)`
- `factory()`
- `feeRouter()`
- `getHookPermissions()`
- `owner()`
- `pending(bytes32)`
- `pendingCreator(bytes32)`
- `pendingOwner()`
- `platformTab(address)`
- `poolConfigs(bytes32)`
- `poolManager()`
- `seeded(bytes32)`
