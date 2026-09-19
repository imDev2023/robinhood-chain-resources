# Factory-v4-minimal-current - 0xce9c48cfa068947f77738c81be406b53338e5b0d

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xce9c48cfa068947f77738c81be406b53338e5b0d
Role: Factory-v4-minimal-current.
Contract name: RWAERC20LaunchpadFactory.
Verified: True (verified at 2026-08-31T23:36:24.403175Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/RWAERC20LaunchpadFactory.sol.
Source files written: 46 under `sources/`.
Creator: 0xaa8d6f5A785304628bA68aA54A1941702665d58C.
Creation tx: 0x332d8f485db53f473b2a305ae45ff8ad7fb02b7f1f30e4ff55d30236d2b3a6da.
Proxy type: None; implementations: [].

## Constructor arguments

- `poolManagerAddress` (address): `0x8366a39CC670B4001A1121B8F6A443A643e40951`
- `launchHook` (address): `0x0310cFEbE1D7A69f2414f6595bBe9d17c5342aCc`
- `launchTokenDeployer` (address): `0xf86dfDb678D8E5d932100Ef479A59fa65a82a5Eb`
- `initialFactoryConfiguration` (tuple): `['1000000000000000000000000000', '200', ['100', '9900', '20', [['0x43524541544f5200000000000000000000000000000000000000000000000000', '0', '0x0000000000000000000000000000000000000000', '50'], ['0x504c4154464f524d000000000000000000000000000000000000000000000000', '1', '0xaa8d6f5A785304628bA68aA54A1941702665d58C', '30'], ['0x5245464552524552000000000000000000000000000000000000000000000000', '2', '0x0000000000000000000000000000000000000000', '20']]], [['0', '8388607', '10000']]]`

## Events

- `AnnouncementRegistrySet(address)`
- `BandTemplateUpdated(uint256)`
- `ConfigVersionUpdated(uint64)`
- `CreatorAdminRevoked(address)`
- `CreatorAdminTransferCancelled(address,address)`
- `CreatorAdminTransferStarted(address,address)`
- `CreatorAdminTransferred(address,address)`
- `CreatorFeeRecipientUpdated(address,address,address)`
- `CreatorRightsReassigned(address,address,address,address,address,address)`
- `CreatorRightsTransferCancelled(address,address,address)`
- `CreatorRightsTransferProposed(address,address,address)`
- `CreatorRightsTransferred(address,address,address,address,address)`
- `FeeComponentConfigured(uint64,uint8,bytes32,uint8,address,uint16)`
- `FeeConfigurationUpdated(uint64,uint16,uint16,uint32)`
- `LaunchBuyAdapterUpdated(address,address)`
- `LaunchBuyExecuted(address,bytes32,address,address,uint256,uint256,address)`
- `LaunchCreationEnabledUpdated(bool)`
- `LaunchSupplyUpdated(uint256,uint256)`
- `Launched(address,bytes32,address,address,uint256,int24)`
- `NativeLaunchFeePaid(address,address,uint256)`
- `NativeLaunchFeeUpdated(uint256,uint256)`
- `OwnershipTransferStarted(address,address)`
- `OwnershipTransferred(address,address)`
- `PriceUpdaterUpdated(address,address)`
- `QuoteRegistered(address,uint8,int24,uint64)`
- `QuoteStartTickUpdated(address,int24,int24,uint64)`
- `QuoteUnregistered(address,uint64)`
- `TickSpacingUpdated(int24,int24)`

## State-changing functions

- `acceptCreatorAdmin()`
- `acceptCreatorRightsTransfer(address)`
- `acceptOwnership()`
- `adminReassignCreatorRights(address,address,address)`
- `batchRegisterQuotes(tuple[])`
- `batchSetQuoteStartTicks(tuple[])`
- `batchUnregisterQuotes(address[])`
- `cancelCreatorAdminTransfer()`
- `cancelCreatorRightsTransfer(address)`
- `createLaunch(tuple)`
- `createLaunchAndBuy(tuple,tuple)`
- `proposeCreatorRightsTransfer(address,address)`
- `registerQuote(address,int24)`
- `renounceOwnership()`
- `revokeCreatorAdmin()`
- `safeTransferCreatorRights(address,address,bytes)`
- `setAnnouncementRegistry(address)`
- `setBandTemplate(tuple[])`
- `setCreatorFeeRecipient(address,address)`
- `setFeeConfiguration(tuple)`
- `setLaunchBuyAdapter(address)`
- `setLaunchCreationEnabled(bool)`
- `setLaunchSupply(uint256)`
- `setNativeLaunchFee(uint256)`
- `setPriceUpdater(address)`
- `setQuoteStartTick(address,int24,uint64)`
- `setTickSpacing(int24)`
- `transferCreatorAdmin(address)`
- `transferOwnership(address)`
- `unregisterQuote(address)`
- `updateTokenContractURI(address,string)`
- `updateTokenExtraMetadata(address,string,string)`
- `updateTokenName(address,string)`
- `updateTokenSymbol(address,string)`

## View functions

- `MAX_FEE_COMPONENTS()`
- `MAX_QUOTE_BATCH_SIZE()`
- `MAX_SUPPLY()`
- `MIN_SUPPLY()`
- `TOKEN_ADDRESS_SUFFIX()`
- `announcementRegistry()`
- `antiSnipeStartTotalBps()`
- `antiSnipeWindowSeconds()`
- `bandTemplate()`
- `baseFeeBps()`
- `configVersion()`
- `creatorAdmin()`
- `creatorRights(address)`
- `currentCreatorOf(address)`
- `feeComponentCount()`
- `feeComponents(uint256)`
- `hook()`
- `isLaunchSaltUsed(bytes32)`
- `launchBuyAdapter()`
- `launchCreationEnabled()`
- `launchSupply()`
- `launchTokenBytecodeHash(tuple)`
- `nativeLaunchFee()`
- `owner()`
- `pendingCreatorAdmin()`
- `pendingOwner()`
- `platformFeeRecipient()`
- `poolManager()`
- `priceUpdater()`
- `quoteConfig(address)`
- `quoteRevision(address)`
- `tickSpacing()`
- `tokenDeployer()`
