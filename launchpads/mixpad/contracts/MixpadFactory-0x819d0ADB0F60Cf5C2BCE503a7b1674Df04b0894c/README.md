# MixpadFactory - 0x819d0ADB0F60Cf5C2BCE503a7b1674Df04b0894c

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x819d0ADB0F60Cf5C2BCE503a7b1674Df04b0894c
Role: MixpadFactory.
Contract name: MixpadFactory.
Verified: True (verified at 2026-08-14T21:23:21.670112Z).
Compiler: v0.8.36+commit.8a079791, EVM cancun, optimizer True runs 1.
Main file: src/MixpadFactory.sol.
Source files written: 49 under `sources/`.
Creator: 0x08b343B6f31dE3A0eeF22BE14c534491a9216A17.
Creation tx: 0x6f2830329956f47acca4ae99f9950d3f856276456ae6fb714ffe32fbb2557806.
Proxy type: None; implementations: [].

## Constructor arguments

- `poolManager_` (address): `0x8366a39CC670B4001A1121B8F6A443A643e40951`
- `positionManager_` (address): `0x58daec3116aae6D93017bAAea7749052E8a04fA7`
- `treasury_` (address): `0x08b343B6f31dE3A0eeF22BE14c534491a9216A17`
- `launchFee_` (uint256): `0`
- `graduationThreshold_` (uint256): `1000000000000000000`

## Events

- `Graduated(address,uint256,uint256)`
- `GraduationThresholdUpdated(uint256)`
- `HookUpdated(address)`
- `InitialTickUpdated(int24)`
- `LaunchEnabledUpdated(bool)`
- `LaunchFeeUpdated(uint256)`
- `OwnershipTransferStarted(address,address)`
- `OwnershipTransferred(address,address)`
- `RefundClaimed(address,uint256)`
- `RefundPending(address,uint256)`
- `StateViewUpdated(address)`
- `TokenLaunched(address,address,bytes32,uint256,uint256,uint16)`
- `TreasuryUpdated(address)`

## State-changing functions

- `acceptOwnership()`
- `claimRefund()`
- `launchToken(string,string,string,string,string,tuple,bytes32,uint256,uint128,uint16,uint16,uint16)`
- `launchTokenWithQuote(string,string,string,string,string,tuple,bytes32,address,uint256,uint256,uint128,uint16,uint16,uint16)`
- `recordSwap(address,bool,uint256)`
- `renounceOwnership()`
- `setGraduationThreshold(uint256)`
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
- `defaultGraduationThreshold()`
- `expectedLiquidity()`
- `graduationStatus(address)`
- `hook()`
- `initialTick()`
- `launchEnabled()`
- `launchFee()`
- `launchedTokens(address)`
- `netPoolQuote(address)`
- `owner()`
- `pendingOwner()`
- `pendingRefunds(address)`
- `poolManager()`
- `positionManager()`
- `predictTokenAddress(string,string,string,string,string,tuple,address,bytes32)`
- `stateView()`
- `tokenCreator(address)`
- `treasury()`
