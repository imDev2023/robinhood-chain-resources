# Factory-v1-block - 0x8b40fc20c405d47d725c9723d056a1c6f62bbccf

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x8b40fc20c405d47d725c9723d056a1c6f62bbccf
Role: Factory-v1-block.
Contract name: ERC20LaunchpadFactory.
Verified: True (verified at 2026-07-04T19:54:53.687439Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/ERC20LaunchpadFactory.sol.
Source files written: 45 under `sources/`.
Creator: 0x05edc8Ce423533fF0bA6A2d286c6f3cd6fe05406.
Creation tx: 0xe020eff0e8aa462c3a0755cd8cea89ad6210fd92e4c459cb7c64dcdf3fb78bd5.
Proxy type: None; implementations: [].

## Constructor arguments

- `_poolManager` (address): `0x8366a39CC670B4001A1121B8F6A443A643e40951`
- `_hook` (address): `0xe960E6C80C74cFDF03c91E7AF4e1F5f53f096a44`
- `_tokenDeployer` (address): `0x0C1B1421620B0255e6E0a1d6A0E280507F4cE34C`
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
