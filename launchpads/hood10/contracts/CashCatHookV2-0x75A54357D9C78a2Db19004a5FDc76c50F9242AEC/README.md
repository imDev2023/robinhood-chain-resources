# CashCatHookV2 - 0x75A54357D9C78a2Db19004a5FDc76c50F9242AEC

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x75A54357D9C78a2Db19004a5FDc76c50F9242AEC
Role: CashCatHookV2.
Contract name: CashCatHookV2.
Verified: True (verified at 2026-08-08T17:27:33.048891Z).
Compiler: v0.8.28+commit.7893614a, EVM cancun, optimizer True runs 800.
Main file: src/v4/CashCatHookV2.sol.
Source files on disk: 33 under `sources/`.
Creator: 0x4e59b44847b379578588920cA78FbF26c0B4956C.
Creation tx: 0x8e562b482dec207c8387292b9625726da23a44e580f80257a9d6b6c8b3c5be1e.
Proxy type: None; implementations: [].
External libraries: none.

## Context, not part of the HOOD10 Launchpad

The letscash.fun v4 hook, and the contract that actually charges the HOOD10 index token's 5% tax.
`currentFeeRate(HOOD10 poolId, 0x0)` returns 50000 pips (5%) and `poolConfigs(poolId)` names the fee recipient as the EOA 0x639D6Faa4DAf85d4ccc4291D1134C83867df5d82 (`_raw/rpc/hood10-token-state.txt`).
`owner` 0xd2DEfBd13aFF22d6989e8C14b4517eC308079e91, `treasury` 0x67cCBFb238047d62736265B3093a5989836794b0, `MAX_FEE_RATE` 100000.

## Constructor arguments

- `poolManager_` (address): `0x8366a39CC670B4001A1121B8F6A443A643e40951`
- `factory_` (address): `0x5bd1Fbe78a78fe8236fa00CF48fbEBA74ae34661`
- `treasury_` (address): `0x6D3d822F6e625c59804F47cf2Cc1d53B8301016F`
- `owner_` (address): `0xD2DeFbd13aFF22D6989E8C14B4517Ec308079E91`

## Events

- `CreatorFeesClaimed(bytes32,address,uint256)`
- `CreatorUpdated(bytes32,address,address)`
- `FeeAccrued(bytes32,uint256)`
- `FeesSwept(bytes32,address,uint256,uint256)`
- `OwnershipTransferStarted(address,address)`
- `OwnershipTransferred(address,address)`
- `PlatformDelivered(address,address,address,uint256)`
- `PlatformPayoutCollected(address,address,uint256)`
- `PlatformPayoutDeferred(address,uint256)`
- `PoolRegistered(bytes32,address,tuple)`
- `SinkUpdated(address,address,address)`
- `TreasuryUpdated(address,address)`

## State-changing functions

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
- `claim(bytes32)`
- `claim(bytes32,address)`
- `claim(bytes32,address,uint256)`
- `collectPlatform(address)`
- `deliverPlatform(address,uint256,address)`
- `register(bytes32,address,address,uint16,uint24)`
- `renounceOwnership()`
- `setSink(address,address)`
- `setTreasury(address)`
- `sweep(bytes32)`
- `transferOwnership(address)`
- `unlockCallback(bytes)`
- `updateCreator(bytes32,address)`

## View functions

- `BPS_DENOMINATOR()`
- `FEE_DENOMINATOR()`
- `MAX_FEE_RATE()`
- `currentFeeRate(bytes32,address)`
- `factory()`
- `getHookPermissions()`
- `owner()`
- `pending(bytes32)`
- `pendingOwner()`
- `platformDestination(address)`
- `platformTab(address)`
- `poolConfigs(bytes32)`
- `poolManager()`
- `seeded(bytes32)`
- `sinkFor(address)`
- `tab(bytes32)`
- `treasury()`
