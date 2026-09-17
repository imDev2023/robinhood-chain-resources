# LongXVaultUpgradeableOld - 0xe9d1e0d8c97bd8a3a758b2090773fc61b3c25c92

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xe9d1e0d8c97bd8a3a758b2090773fc61b3c25c92
Role: LongXVaultUpgradeableOld.
Contract name: LongXVaultUpgradeable.
Verified: True (verified at 2026-08-22T14:18:25.996811Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/upgradeable/LongXVaultUpgradeable.sol.
Source files written: 19 under `sources/`.
Creator: 0x3260e7A806f7D5D6a85C7246FB059099F3bF0f2f.
Creation tx: 0xf21eeab997f7bea9d31eeed0e7fc1822aec23ec1be06fc0aff388f80f9e09701.
Proxy type: None; implementations: [].

LongX vault implementation, the first verified deployment, the beacon's constructor argument.

## Constructor arguments

None decoded.

## Events

- `AdminTransferStarted(address,address)`
- `AdminTransferred(address,address)`
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
- `Initialized(uint64)`
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

- `acceptAdmin()`
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
- `initialize(address,address,uint16,uint8,tuple,string,string)`
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
- `transferAdmin(address)`
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
- `pendingAdmin()`
- `pendingSlashDeposit()`
- `priceDecimals()`
- `rebalanceClearedAtBatch()`
- `rebalanceOpSerial()`
- `requestStatus(uint256)`
- `requests(uint256)`
- `rescuerBountyBps()`
- `routeType()`
- `router()`
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
