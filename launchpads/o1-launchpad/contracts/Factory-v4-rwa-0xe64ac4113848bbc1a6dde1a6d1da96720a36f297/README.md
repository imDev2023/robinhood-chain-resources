# Factory-v4-rwa - 0xe64ac4113848bbc1a6dde1a6d1da96720a36f297

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xe64ac4113848bbc1a6dde1a6d1da96720a36f297
Role: Factory-v4-rwa.
Contract name: RWAERC20LaunchpadFactory.
Verified: True (verified at 2026-07-24T21:56:18.220793Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/RWAERC20LaunchpadFactory.sol.
Source files written: 47 under `sources/`.
Creator: 0xc103Fce99EA5aDAcDdECE634EA6D036a42e757aE.
Creation tx: 0x28140cdf681334118e852f8ff2cf65f564615a21f6cb2c32156956304e29a717.
Proxy type: None; implementations: [].

## Constructor arguments

- `_poolManager` (address): `0x8366a39CC670B4001A1121B8F6A443A643e40951`
- `_hook` (address): `0x778b0c4EeA7D35D66513B587bA87FC9084b0EaCC`
- `_tokenDeployer` (address): `0x6544AF3524a8d9135Eb5765CECE6E514d85D615b`
- `cfg` (tuple): `['1000000000000000000000000000', '200', ['100', '5000', '3000', '2000', '9900', '16', '0xc103Fce99EA5aDAcDdECE634EA6D036a42e757aE'], [['0', '8388607', '10000']]]`

## Events

- `AnnouncementRegistryUpdated(address)`
- `BandTemplateUpdated(uint256)`
- `ConfigVersionUpdated(uint64)`
- `FeeDefaultsUpdated(address,uint16,uint16,uint32)`
- `LaunchCreationEnabledUpdated(bool)`
- `LaunchFeePaid(address,address,address,uint256)`
- `LaunchSupplyUpdated(uint256,uint256)`
- `Launched(address,bytes32,address,address,uint256,int24)`
- `NativeLaunchFeeUpdated(uint256,uint256)`
- `OwnershipTransferStarted(address,address)`
- `OwnershipTransferred(address,address)`
- `PriceUpdaterUpdated(address,address)`
- `QuoteCreationFeeUpdated(address,uint256)`
- `QuoteRegistered(address,uint8,int24)`
- `QuoteRevisionUpdated(address,uint64)`
- `QuoteUnregistered(address)`
- `TickSpacingUpdated(int24,int24)`
- `VestingVaultUpdated(address)`

## State-changing functions

- `acceptOwnership()`
- `batchRegisterQuotes(tuple[])`
- `batchSetQuoteStartTicks(tuple[])`
- `batchUnregisterQuotes(address[])`
- `createLaunch(tuple)`
- `registerQuote(address,int24)`
- `renounceOwnership()`
- `setAnnouncementRegistry(address)`
- `setBandTemplate(tuple[])`
- `setFeeDefaults(tuple)`
- `setLaunchCreationEnabled(bool)`
- `setLaunchSupply(uint256)`
- `setNativeLaunchFee(uint256)`
- `setPriceUpdater(address)`
- `setQuoteStartTick(address,int24)`
- `setQuoteStartTick(address,int24,uint64)`
- `setTickSpacing(int24)`
- `setVestingVault(address)`
- `transferOwnership(address)`
- `unregisterQuote(address)`

## View functions

- `MAX_ALLOCATIONS()`
- `MAX_QUOTE_BATCH_SIZE()`
- `MAX_SUPPLY()`
- `MAX_TOTAL_VEST_STEPS()`
- `MAX_VESTED_ALLOCATIONS()`
- `MAX_VEST_STEPS()`
- `MIN_SUPPLY()`
- `MIN_VESTING_DURATION()`
- `TOKEN_ADDRESS_SUFFIX()`
- `announcementRegistry()`
- `bands()`
- `configVersion()`
- `feeDefaults()`
- `hook()`
- `launchCreationEnabled()`
- `launchSupply()`
- `launchTokenBytecodeHash(tuple,address)`
- `nativeLaunchFee()`
- `owner()`
- `pendingOwner()`
- `poolManager()`
- `priceUpdater()`
- `quoteRevision(address)`
- `quotes(address)`
- `setQuoteCreationFee(address,uint256)`
- `tickSpacing()`
- `tokenDeployer()`
- `usedLaunchSalts(bytes32)`
- `vestingVault()`
