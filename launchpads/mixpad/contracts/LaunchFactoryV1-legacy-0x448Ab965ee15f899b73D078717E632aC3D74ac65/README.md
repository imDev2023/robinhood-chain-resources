# LaunchFactoryV1-legacy - 0x448Ab965ee15f899b73D078717E632aC3D74ac65

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x448Ab965ee15f899b73D078717E632aC3D74ac65
Role: LaunchFactoryV1-legacy.
Contract name: MixpadFactory.
Verified: True (verified at 2026-08-11T08:33:44.475598Z).
Compiler: v0.8.36+commit.8a079791, EVM cancun, optimizer True runs 1.
Main file: src/MixpadFactory.sol.
Source files written: 49 under `sources/`.
Creator: 0x63D6CaCf401BeAAcd9D223cb2511E2D9d0400368.
Creation tx: 0x508b53f19e5e008457b9a1075ea41b93d70a43f1941c2c76d3d3bfee1a68555b.
Proxy type: None; implementations: [].

## Constructor arguments

- `poolManager_` (address): `0x8366a39CC670B4001A1121B8F6A443A643e40951`
- `positionManager_` (address): `0x58daec3116aae6D93017bAAea7749052E8a04fA7`
- `treasury_` (address): `0x5735E8D52bFb6459c74dCCcd52611cD31a20CDb9`
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
