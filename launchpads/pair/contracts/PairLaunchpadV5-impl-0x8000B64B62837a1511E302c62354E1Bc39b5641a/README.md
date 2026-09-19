# PairLaunchpadV5-impl - 0x8000B64B62837a1511E302c62354E1Bc39b5641a

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x8000B64B62837a1511E302c62354E1Bc39b5641a
Role: PairLaunchpadV5-impl.
Contract name: PairLaunchpadV5Upgradeable.
Verified: True (verified at 2026-09-13T15:10:18.110125Z).
Compiler: 0.8.26+commit.8a97fa7a, EVM paris, optimizer True runs 1.
Main file: contracts/v5/PairLaunchpadV5Upgradeable.sol.
Source files written: 43 under `sources/`.
Creator: 0x18Fe9694a335C8b42D228147eDdAC524748300eA.
Creation tx: 0x74bb557257f9a5d866fe4a0e9e141cf30c958211c1332a6b302eab7bd41268d9.
Proxy type: None; implementations: [].

## Constructor arguments

- `legacyLaunchHelper_` (address): `0x7B908161001B8239F35b600080FDFe6080604052`

## Events

- `ActiveLaunchV2ModeRegistryInstalled(address,address)`
- `CustomQuoteLaunchV2CapabilitySet(bool)`
- `CustomQuoteLaunchV2Configured(address,address,address,address)`
- `CustomQuoteLaunchV2DependenciesRotated(address,address,address,address,address)`
- `InitialDeveloperBuy(address,address,address,uint256,uint256)`
- `Initialized(uint64)`
- `LaunchGraduated(address,uint256,uint256)`
- `LaunchV2ActivatorConfigured(address)`
- `LaunchV2CapabilitySet(bool)`
- `LaunchV2CommunityTakeover(address,address,address,address,uint64,uint64,uint8,uint8)`
- `LaunchV2Configured(address,address,address,address,address)`
- `LaunchV2Created(address,address,address,bytes32,uint256)`
- `LaunchV2CreatedWithMode(address,address,address,bytes32,uint256,uint8)`
- `LaunchV2DependenciesRotated(address,address,address,address,address)`
- `LaunchV2FeeSharingCapabilitySet(bool)`
- `LaunchV2FeeSharingConfigured(address,address,address,address)`
- `LaunchV2FeeSharingCreated(address,address,address,bytes32,uint256)`
- `LaunchV2FeeSharingDependenciesRotated(address,address,address,address)`
- `LaunchV2ModeTransitioned(address,address,uint64,uint8)`
- `MultiPairLaunchCreated(address,address,uint256,uint256,uint256,string)`
- `OwnershipTransferred(address,address)`
- `PairPoolCreated(address,address,bytes32,uint256,uint16,uint256,int24,int24,uint160,uint256)`
- `RoundingDustPermanentlyLocked(address,uint256)`
- `Upgraded(address)`

## State-changing functions

- `communityTakeoverLaunchV2(address,address)`
- `communityTakeoverLaunchV2(address,address,uint8)`
- `configureCustomQuoteLaunchV2(address,address,address,address)`
- `configureLaunchV2(address,address,address,address,address)`
- `configureLaunchV2ActivationQuotes(address[])`
- `configureLaunchV2Activator(address)`
- `configureLaunchV2FeeSharing(address,address,address,address)`
- `configureLaunchV2TokenRegistry(address)`
- `initialize(address,address,address,address,address,address,address,address,address,address,address,address,uint256,uint256)`
- `initializeActiveCustomQuotePool(address,address,uint160)`
- `installActiveLaunchV2ModeRegistry(address)`
- `installEnabledActiveLaunchV2ModeRegistry(address)`
- `launchTokenMulti(tuple)`
- `launchV2(tuple)`
- `launchV2Token(tuple)`
- `launchV2TokenWithCustomQuotes(tuple)`
- `launchV2WithEpoch1Mode(tuple,uint8)`
- `launchV2WithFeeSharing(tuple,address[],uint16[])`
- `recoverLaunchV2ActivationInventory(address,address,uint256)`
- `registerCustomQuoteLaunchV2Vault(address,address)`
- `registerLaunchV2Vault(address,address)`
- `rotateCustomQuoteLaunchV2(address,address,address,address)`
- `rotateLaunchV2Dependencies(address,address,address,address,address)`
- `rotateLaunchV2FeeSharingDependencies(address,address,address,address)`
- `setCustomQuoteLaunchV2Enabled(bool)`
- `setDeveloperBuyAdapter(address)`
- `setFeeConversionLocker(address)`
- `setLaunchFee(uint256)`
- `setLaunchV2Enabled(bool)`
- `setLaunchV2FeeSharingEnabled(bool)`
- `setMaxOracleAge(uint256)`
- `syncGraduation(address)`
- `transferOwnership(address)`
- `transitionLaunchV2Mode(address,address,uint8)`
- `upgradeToAndCall(address,bytes)`
- `withdrawLaunchFees()`

## View functions

- `BPS_DENOMINATOR()`
- `ETH_GRAD_TARGET_WEI()`
- `MAX_DEV_BUY_BPS()`
- `MAX_PAIRS()`
- `MAX_USABLE_TICK()`
- `MIN_USABLE_TICK()`
- `POOL_FEE()`
- `SQRT_10_X18()`
- `TICK_SPACING()`
- `TOTAL_SUPPLY()`
- `UPGRADE_INTERFACE_VERSION()`
- `activeLaunchV2ModeRegistry()`
- `calculateV4LaunchRange(address,address,uint8,uint256,uint256,uint256)`
- `customQuoteLaunchV2Coordinator()`
- `customQuoteLaunchV2Enabled()`
- `customQuoteLaunchV2VaultOf(address)`
- `deriveLaunchEconomics(uint256)`
- `developerBuyAdapter()`
- `ethPriceFeed()`
- `feeConversionLocker()`
- `getLaunchPool(address,uint256)`
- `getLaunchPoolCount(address)`
- `graduationStatus(address)`
- `launchFeeWei()`
- `launchV2Activator()`
- `launchV2Aggregator()`
- `launchV2BuybackExecutor()`
- `launchV2CommunityTakeoverEligible(address)`
- `launchV2Coordinator()`
- `launchV2Enabled()`
- `launchV2FeeSharingAggregator()`
- `launchV2FeeSharingCoordinator()`
- `launchV2FeeSharingEnabled()`
- `launchV2FeeSharingHook()`
- `launchV2FeeSharingTokenFactory()`
- `launchV2FeeSharingVersion()`
- `launchV2Hook()`
- `launchV2ModeRegistry()`
- `launchV2ModeSelectionVersion()`
- `launchV2TokenFactory()`
- `launchV2VaultOf(address)`
- `launchedTokens(uint256)`
- `launches(address)`
- `legacyLaunchHelper()`
- `locker()`
- `maxOracleAge()`
- `owner()`
- `pairHook()`
- `permit2()`
- `poolManager()`
- `positionIdByPoolId(bytes32)`
- `positionManager()`
- `projectTokenByPoolId(bytes32)`
- `protectionBlocks()`
- `protocolTreasury()`
- `proxiableUUID()`
- `quoteTokenByPoolId(bytes32)`
- `stateView()`
- `stockRegistry()`
- `universalRouter()`
