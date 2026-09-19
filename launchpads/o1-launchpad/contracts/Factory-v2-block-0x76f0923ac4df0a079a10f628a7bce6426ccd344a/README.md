# Factory-v2-block - 0x76f0923ac4df0a079a10f628a7bce6426ccd344a

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x76f0923ac4df0a079a10f628a7bce6426ccd344a
Role: Factory-v2-block.
Contract name: ERC20LaunchpadFactory.
Verified: True (verified at 2026-07-08T14:56:04.937003Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/ERC20LaunchpadFactory.sol.
Source files written: 45 under `sources/`.
Creator: 0x05edc8Ce423533fF0bA6A2d286c6f3cd6fe05406.
Creation tx: 0x4949b12fa576b14851100a6b749554653cb795b7698bb2ffe65b8aebbbf1fd23.
Proxy type: None; implementations: [].

## Constructor arguments

- `_poolManager` (address): `0x8366a39CC670B4001A1121B8F6A443A643e40951`
- `_hook` (address): `0xca4b035a5DBFa2a00fC5dcb08fD1c5A22d0eAA44`
- `_tokenDeployer` (address): `0x92A323CdF7CeB87D29a1bB0B618706F448b00160`
- `cfg` (tuple): `['1000000000000000000000000000', '200', ['100', '5000', '3000', '2000', '9900', '8', '0x05edc8Ce423533fF0bA6A2d286c6f3cd6fe05406'], [['0', '8388607', '10000']]]`

## Events

- `AnnouncementRegistryUpdated(address)`
- `BandTemplateUpdated(uint256)`
- `ConfigVersionUpdated(uint64)`
- `FeeDefaultsUpdated(address,uint16,uint16,uint32)`
- `LaunchSupplyUpdated(uint256,uint256)`
- `Launched(address,bytes32,address,address,uint256,int24)`
- `OwnershipTransferStarted(address,address)`
- `OwnershipTransferred(address,address)`
- `QuoteRegistered(address,uint8,int24)`
- `QuoteUnregistered(address)`
- `TickSpacingUpdated(int24,int24)`
- `VestingVaultUpdated(address)`

## State-changing functions

- `acceptOwnership()`
- `createLaunch(tuple)`
- `registerQuote(address,int24)`
- `renounceOwnership()`
- `setAnnouncementRegistry(address)`
- `setBandTemplate(tuple[])`
- `setFeeDefaults(tuple)`
- `setLaunchSupply(uint256)`
- `setQuoteStartTick(address,int24)`
- `setTickSpacing(int24)`
- `setVestingVault(address)`
- `transferOwnership(address)`
- `unregisterQuote(address)`

## View functions

- `MAX_ALLOCATIONS()`
- `MAX_SUPPLY()`
- `MAX_TOTAL_VEST_STEPS()`
- `MAX_VESTED_ALLOCATIONS()`
- `MAX_VEST_STEPS()`
- `MIN_SUPPLY()`
- `MIN_VESTING_DURATION()`
- `announcementRegistry()`
- `bands()`
- `configVersion()`
- `feeDefaults()`
- `hook()`
- `launchSupply()`
- `owner()`
- `pendingOwner()`
- `poolManager()`
- `quotes(address)`
- `tickSpacing()`
- `tokenDeployer()`
- `usedLaunchSalts(bytes32)`
- `vestingVault()`
