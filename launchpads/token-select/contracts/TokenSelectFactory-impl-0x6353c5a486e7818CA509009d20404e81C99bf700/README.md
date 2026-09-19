# TokenSelectFactory-impl - 0x6353c5a486e7818CA509009d20404e81C99bf700

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x6353c5a486e7818CA509009d20404e81C99bf700
Role: TokenSelectFactory-impl.
Contract name: TokenSelectFactory.
Verified: True (verified at 2026-08-01T20:39:06.493108Z).
Compiler: 0.8.26+commit.8a97fa7a, EVM paris, optimizer True runs 200.
Main file: contracts/TokenSelectFactory.sol.
Source files written: 24 under `sources/`.
Creator: 0x3Bd13d3F4dC1f152b2c64B1f19eADe52f8070513.
Creation tx: 0x028b17b3403cc1ad2c44fc03b8f6b10c5508a03ab4bf2022f89fe0910e34da4c.
Proxy type: None; implementations: [].

## Constructor arguments

None decoded.

## Events

- `AdminChanged(address,address)`
- `BatchClaimCompleted(address,uint256,uint256,bool)`
- `BeaconUpgraded(address)`
- `DeploymentFeeUpdated(uint256,uint256)`
- `EthPoolRatioUpdated(uint256,uint256)`
- `FeesCollected(uint256,uint256,uint256,uint256,uint256)`
- `Initialized(uint8)`
- `LpVaultDeployed(address)`
- `MigrationAdminUpdated(address,address)`
- `MigrationFeePercentageUpdated(uint256,uint256)`
- `MigrationFeeUpdated(uint256,uint256)`
- `MinETHLiquidityUpdated(uint256,uint256)`
- `NewTokenSelectToken(address,address,string,string,uint256,uint256,uint256)`
- `OwnershipTransferred(address,address)`
- `ReferrerAdded(address)`
- `ReferrerAdminUpdated(address,address)`
- `ReferrerRemoved(address)`
- `RefundsEnabled(address)`
- `RewardFeesUpdated(uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256)`
- `SelectPoolFeesCollected(address,uint256,uint256)`
- `SelectPoolSeeded(address,uint256,uint256)`
- `SelectTokenUpdated(address,address)`
- `StreamManagerUpdated(address,address)`
- `TokenDeployerUpdated(address,address)`
- `TreasuryUpdated(address,address)`
- `Upgraded(address)`

## State-changing functions

- `addReferrer(address)`
- `batchClaimRewards(address[])`
- `collectAndTransferFees(uint256,uint256)`
- `collectSelectPoolFees(address)`
- `createTokenSelectToken(tuple,address)`
- `deployLpVault()`
- `enableRefunds(address)`
- `initialize(address,address,address)`
- `migrate(address,int24)`
- `removeReferrer(address)`
- `renounceOwnership()`
- `retrySelectPool(address,int24)`
- `setDeploymentFee(uint256)`
- `setEthPoolRatioBps(uint256)`
- `setMigrationAdmin(address)`
- `setMigrationFee(uint256)`
- `setMigrationFeePercentage(uint256)`
- `setMinETHLiquidity(uint256)`
- `setReferrerAdmin(address)`
- `setRewardFees(uint256,uint256,uint256,uint256)`
- `setSelectToken(address)`
- `setStreamManager(address)`
- `setTokenSelectDeployer(address)`
- `setTreasury(address)`
- `transferOwnership(address)`
- `upgradeTo(address)`
- `upgradeToAndCall(address,bytes)`

## View functions

- `authorizedReferrers(address)`
- `creatorFeeNoReferrer()`
- `creatorFeeWithReferrer()`
- `deployedTokens(uint256)`
- `deploymentFee()`
- `ethPoolRatioBps()`
- `getAllDeployedTokens()`
- `getAllocationLimits()`
- `getDeployedTokensCount()`
- `getDeployedTokensRange(uint256,uint256)`
- `lpVault()`
- `migrationAdmin()`
- `migrationFee()`
- `migrationFeePercentage()`
- `minETHLiquidity()`
- `owner()`
- `positionManager()`
- `proxiableUUID()`
- `referrerAdmin()`
- `referrerFee()`
- `selectPoolPositionIds(address)`
- `selectToken()`
- `serviceChargeRate()`
- `streamManager()`
- `tokenAskLPPositions(address)`
- `tokenCreators(address)`
- `tokenDeployer()`
- `tokenIndex(address)`
- `tokenLPPositions(address)`
- `tokenSelectTokens(address)`
- `treasury()`
- `validateTokenParams(tuple)`
- `weth()`
