# UnihoodHook - 0xec392C2b716C4B46df67cA6196ff92f7Dc2De8Cc

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xec392C2b716C4B46df67cA6196ff92f7Dc2De8Cc
Role: UnihoodHook.
Contract name: UnihoodHook.
Verified: True (verified at 2026-08-03T08:05:24.088971Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 800.
Main file: src/UnihoodHook.sol.
Source files written: 29 under `sources/`.
Creator: 0x4e59b44847b379578588920cA78FbF26c0B4956C.
Creation tx: 0x22d00b63cc4dcba4775e5c1ea39bb5c1855284fa25333b5d77977d149a5c62e1.
Proxy type: None; implementations: [].

## Constructor arguments

- `poolManager_` (address): `0x8366a39CC670B4001A1121B8F6A443A643e40951`
- `platformRecipient_` (address): `0x64900b69E56583C12900F3458525a3fdB6f274D7`
- `gradTick_` (int24): `172800`
- `wallThreshold_` (uint128): `5000000000000000`

## Events

- `CreatorFeesClaimed(bytes32,address,uint256)`
- `FeeRecipientUpdated(bytes32,address,address)`
- `Graduated(bytes32,int24)`
- `PlatformFeesClaimed(address,uint256)`
- `PoolRegistered(bytes32,address,address)`
- `SwapFees(bytes32,address,bool,uint16,uint256,uint256,uint256,uint256)`
- `WallPlaced(bytes32,int24,int24,uint256,uint128)`
- `WallTokensCaptured(bytes32,uint256)`

## State-changing functions

- `afterAddLiquidity(address,tuple,tuple,int256,int256,bytes)`
- `afterDonate(address,tuple,uint256,uint256,bytes)`
- `afterInitialize(address,tuple,uint160,int24)`
- `afterRemoveLiquidity(address,tuple,tuple,int256,int256,bytes)`
- `afterSwap(address,tuple,tuple,int256,bytes)`
- `beforeAddLiquidity(address,tuple,tuple,bytes)`
- `beforeDonate(address,tuple,uint256,uint256,bytes)`
- `beforeInitialize(address,tuple,uint160)`
- `beforeRemoveLiquidity(address,tuple,tuple,bytes)`
- `beforeSwap(address,tuple,tuple,bytes)`
- `claimCreatorFees(bytes32)`
- `claimPlatformFees(address)`
- `registerPool(tuple,address,address)`
- `setFactory(address)`
- `setFeeRecipient(bytes32,address)`
- `unlockCallback(bytes)`

## View functions

- `BASE_FEE_BPS()`
- `BASIS_POINTS()`
- `CREATOR_FEE_BPS()`
- `LP_FEE_PIPS()`
- `PLATFORM_FEE_BPS()`
- `SNIPE_FEE_1_BPS()`
- `SNIPE_FEE_2_BPS()`
- `SNIPE_WINDOW_1_SECONDS()`
- `SNIPE_WINDOW_2_SECONDS()`
- `TICK_SPACING()`
- `WALL_FEE_BPS()`
- `WALL_WIDTH_TICKS()`
- `currentFeeBps(bytes32)`
- `factory()`
- `feeDisclosure()`
- `getHookPermissions()`
- `gradTick()`
- `platformAccrued()`
- `platformRecipient()`
- `poolManager()`
- `pools(bytes32)`
- `totalNativeFeesAccrued()`
- `wallThreshold()`
