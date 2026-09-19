# Factory-v3-timestamp - 0x411f21283d3e492bc395027329e08f9f4f560ba5

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x411f21283d3e492bc395027329e08f9f4f560ba5
Role: Factory-v3-timestamp.
Contract name: ERC20LaunchpadFactory.
Verified: True (verified at 2026-07-10T14:22:14.116017Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/ERC20LaunchpadFactory.sol.
Source files written: 45 under `sources/`.
Creator: 0x05edc8Ce423533fF0bA6A2d286c6f3cd6fe05406.
Creation tx: 0xae6fe6425a00458615d9b7ca412a319350345b080797f81cd145ca675d823ee4.
Proxy type: None; implementations: [].

## Constructor arguments

- `_poolManager` (address): `0x8366a39CC670B4001A1121B8F6A443A643e40951`
- `_hook` (address): `0x441F773B3bb1Ed4c6457D0528624112e43C02acc`
- `_tokenDeployer` (address): `0x7dA2f15e0bbc564fbde55a4E23147f490061BbAb`
- `cfg` (tuple): `['1000000000000000000000000000', '200', ['100', '5000', '3000', '2000', '9900', '16', '0x05edc8Ce423533fF0bA6A2d286c6f3cd6fe05406'], [['0', '8388607', '10000']]]`

## Events

- `AnnouncementRegistryUpdated(address)`
- `BandTemplateUpdated(uint256)`
- `ConfigVersionUpdated(uint64)`
- `FeeDefaultsUpdated(address,uint16,uint16,uint32)`
- `LaunchFeePaid(address,address,address,uint256)`
- `LaunchSupplyUpdated(uint256,uint256)`
- `Launched(address,bytes32,address,address,uint256,int24)`
- `OwnershipTransferStarted(address,address)`
- `OwnershipTransferred(address,address)`
- `QuoteCreationFeeUpdated(address,uint256)`
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
- `setQuoteCreationFee(address,uint256)`
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
