# RwaFactory - 0x27c9089140da7d24a1cd977e080d69b62cc53f4f

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x27c9089140da7d24a1cd977e080d69b62cc53f4f
Role: RwaFactory.
Contract name: RwaFactory.
Verified: True (verified at 2026-08-18T08:06:15.073864Z).
Compiler: v0.8.36+commit.8a079791, EVM cancun, optimizer True runs 1.
Main file: src/RwaFactory.sol.
Source files written: 49 under `sources/`.
Creator: 0x08b343B6f31dE3A0eeF22BE14c534491a9216A17.
Creation tx: 0x1f3b66099118bb508e3bd825ab9ed23bf7a058a05ab0a9206020d53b193b16ea.
Proxy type: None; implementations: [].

## Constructor arguments

- `poolManager_` (address): `0x8366a39CC670B4001A1121B8F6A443A643e40951`
- `positionManager_` (address): `0x58daec3116aae6D93017bAAea7749052E8a04fA7`
- `treasury_` (address): `0x08b343B6f31dE3A0eeF22BE14c534491a9216A17`
- `launchFee_` (uint256): `0`

## Events

- `Graduated(address,uint256,uint256)`
- `HookUpdated(address)`
- `InitialTickUpdated(int24)`
- `LaunchEnabledUpdated(bool)`
- `LaunchFeeUpdated(uint256)`
- `OwnershipTransferStarted(address,address)`
- `OwnershipTransferred(address,address)`
- `StateViewUpdated(address)`
- `TokenLaunched(address,address,bytes32,uint256,uint256,uint16)`
- `TreasuryUpdated(address)`

## State-changing functions

- `acceptOwnership()`
- `launchWithStockBuy(tuple,uint128)`
- `recordSwap(address,bool,uint256)`
- `renounceOwnership()`
- `setHook(address)`
- `setInitialTick(int24)`
- `setLaunchEnabled(bool)`
- `setLaunchFee(uint256)`
- `setStateView(address)`
- `setTreasury(address)`
- `transferOwnership(address)`
- `unlockCallback(bytes)`

## View functions

- `BPS_DENOM()`
- `BURN_ADDRESS()`
- `MAX_GRADUATION_THRESHOLD()`
- `MAX_INITIAL_TICK()`
- `MAX_LAUNCH_FEE()`
- `MIN_GRADUATION_THRESHOLD()`
- `MIN_INITIAL_TICK()`
- `PERMIT2()`
- `POOL_FEE()`
- `SUPPLY()`
- `TICK_SPACING()`
- `VERSION()`
- `graduationStatus(address)`
- `hook()`
- `initialTick()`
- `launchEnabled()`
- `launchFee()`
- `launchedTokens(address)`
- `netPoolQuote(address)`
- `owner()`
- `pendingOwner()`
- `poolManager()`
- `positionManager()`
- `predictTokenAddress(tuple)`
- `stateView()`
- `tokenCreator(address)`
- `treasury()`
