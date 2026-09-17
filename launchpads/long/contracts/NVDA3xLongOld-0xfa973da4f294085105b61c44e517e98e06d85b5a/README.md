# NVDA3xLongOld - 0xfa973da4f294085105b61c44e517e98e06d85b5a

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xfa973da4f294085105b61c44e517e98e06d85b5a
Role: NVDA3xLongOld.
Contract name: LongXVault.
Verified: True (verified at 2026-08-20T03:57:23.632365Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/LongXVault.sol.
Source files written: 17 under `sources/`.
Creator: 0x3260e7A806f7D5D6a85C7246FB059099F3bF0f2f.
Creation tx: 0x80fdfc7098414ee358f886480ef3e66affa122b1a9b226d24e24c3cba6ec9845.
Proxy type: None; implementations: [].

Earlier standalone `NVDA 3x Long` contract from 2026-08-20, before the beacon-proxy factory existed.

## Constructor arguments

- `usdg_` (address): `0x5fc5360D0400a0Fd4f2af552ADD042D716F1d168`
- `bridge_` (address): `0x94bAB9693Ba2f6358507eFfcbd372b0660AFfF9d`
- `assetIndex_` (uint16): `3`
- `routeType_` (uint8): `0`
- `cfg` (tuple): `['0x4eB0754678263aB4e0E873d678dCC059Bd1B39c8', '15', '4', '2', '2740000000000000000', '3350000000000000000', '0', '50', '10000000', '60', '0x0000000000000000000000000000000000000000', '0', '0x10726acb0a5887f3b7e528570f13f2fe27ad32cb73722d2cf8ab8c25278ef91acdff1233f65f040a', '15', '25', '650', '30', '0', '0', '10000000000', '0x8aa7A1dFA6635AF2979dA4D2bDd51780842e3F99']`
- `name_` (string): `NVDA 3x Long`
- `symbol_` (string): `NVDAx3`

## Events

- `Approval(address,address,uint256)`
- `BondReleased(address,uint256)`
- `BondSlashed(address,uint256,uint8)`
- `CapRaised(uint256,uint256)`
- `Claimed(uint256,address,uint256)`
- `DepositForwarded(uint256)`
- `ExecutorBountyPaid(address,uint256)`
- `FeesWithdrawn(address,uint256)`
- `ForceUnwound(uint32,uint64)`
- `ForeignPositionChallenged(address,uint16,int256,uint64)`
- `ForeignPositionClosed(uint16,int256,uint32,uint8,uint64)`
- `GenesisSettled(uint256,uint48,uint256)`
- `KeyParked(address,uint64,int128,uint256,uint64)`
- `LeaseAcquired(address,bytes,uint256,bytes32,uint256,uint64,uint64)`
- `LeaseExpired(address,uint64,uint256,bool)`
- `MintFeeTaken(uint256)`
- `MintRequested(uint256,address,address,uint256)`
- `NAVProven(uint64,uint256,int256,uint256)`
- `Paused(address)`
- `PositionDiverged(address,uint64,int128,int256)`
- `RebalanceOpConfirmed(uint64)`
- `Rebalanced(uint64,uint256,bool,uint48,uint32,uint8,uint64)`
- `RedeemReduce(uint48,uint32,uint256)`
- `RedeemRequested(uint256,address,address,uint256)`
- `RequestSettled(uint256,uint256,uint256)`
- `RescuerBountyPaid(address,uint256)`
- `SlashDepositForwarded(uint256)`
- `Swept(uint128)`
- `Transfer(address,address,uint256)`
- `Unpaused(address)`
- `UnwoundRedemption(address,uint256,uint256)`
- `VaultOrderRecorded(uint64,uint48,uint8)`
- `WithdrawClamped(uint256,uint256)`
- `WithdrawInitiated(uint64)`

## State-changing functions

- `acquireLease(bytes,tuple,tuple,tuple[])`
- `approve(address,uint256)`
- `challenge(tuple,tuple)`
- `challengeForeignPosition(tuple,tuple,uint8,int128[16],int128[16],uint8)`
- `claim(uint256)`
- `confirmBridgeOps()`
- `confirmRebalanceOp()`
- `expireLease(tuple,tuple,tuple[])`
- `forceCloseForeign(tuple,tuple,uint8,int128[16],int128[16],uint8)`
- `forceUnwind(uint32,uint64)`
- `parkKey(tuple,tuple,tuple[])`
- `pause()`
- `proveState(tuple,tuple,uint256,tuple[])`
- `raiseCap(uint256)`
- `rebalance(tuple,tuple)`
- `redeemUnwound(uint256)`
- `releaseBond()`
- `requestMint(uint256,address)`
- `requestRedeem(uint256,address)`
- `settleGenesis(uint256)`
- `sweepWithdrawals(uint128)`
- `syncAccountIndex()`
- `transfer(address,uint256)`
- `transferFrom(address,address,uint256)`
- `unpause()`
- `withdrawFees(uint256)`

## View functions

- `DEAD_ADDRESS()`
- `DEAD_SHARES()`
- `DEFAULT_CHALLENGE_BATCHES()`
- `DEFAULT_EXECUTION_BATCHES()`
- `MIN_GENESIS_USDG()`
- `ORDER_TYPE_MARKET()`
- `accountIndex()`
- `accountOpened()`
- `admin()`
- `allowance(address,address)`
- `apiKeyIndex()`
- `assetIndex()`
- `balanceOf(address)`
- `bandHi1e18()`
- `bandLo1e18()`
- `bondBps()`
- `bondHeld()`
- `bondReleaseBatch()`
- `bridge()`
- `bridgeOpsClearedAtBatch()`
- `challengeBatches()`
- `challengeOpen()`
- `currentLeverage1e18(tuple,tuple)`
- `decimals()`
- `equityCapUsdg()`
- `escrowedMintUsdg()`
- `estimatedBond()`
- `executionBatches()`
- `executorBountyBps()`
- `exitHaircutBps()`
- `expectedL1Owner()`
- `feePoolUsdg()`
- `keyState()`
- `lastBridgeOpSerial()`
- `lastNavTimestamp()`
- `lastProvenBatch()`
- `lastRedeemWithdrawSerial()`
- `leaseBond()`
- `leaseExpiryBatch()`
- `leaseStartBatch()`
- `leasedKey()`
- `lessee()`
- `liabilityAnchorCap()`
- `maxSlippageBps()`
- `minOrderNotional6()`
- `mintFeeBps()`
- `name()`
- `navPerToken()`
- `nextRequestId()`
- `nextSettleId()`
- `owedRedeemUsdg()`
- `owedShortfall()`
- `parkAnchorBatch()`
- `parkBond()`
- `parkKeySerial()`
- `parkLessee()`
- `parkPositionSize()`
- `parkPubKey()`
- `paused()`
- `pendingSlashDeposit()`
- `priceDecimals()`
- `rebalanceClearedAtBatch()`
- `rebalanceOpSerial()`
- `requestStatus(uint256)`
- `requests(uint256)`
- `rescuerBountyBps()`
- `routeType()`
- `sizeDecimals()`
- `symbol()`
- `targetLeverage1e18()`
- `targetMarket()`
- `totalSupply()`
- `unwound()`
- `usdg()`
- `vaultBuyAllowance()`
- `vaultFullCloseIssued()`
- `vaultSellAllowance()`
- `verifier()`
