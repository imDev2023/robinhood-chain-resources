# LaunchFactory - 0x718633252AA8329495Df8BBa8fF7c9e8378CFC63

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x718633252AA8329495Df8BBa8fF7c9e8378CFC63
Role: LaunchFactory.
Contract name: LaunchFactory.
Verified: True (verified at 2026-08-31T12:31:16.930797Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 800.
Main file: src/LaunchFactory.sol.
Source files on disk: 60 under `sources/`.
Creator: 0xfe2cF227e21C5FC54dcE8Bb65F7C1E1E90236862.
Creation tx: 0x6f4fdf8495709c5038c260ca5c00fef2182bd699264cd45647e98be7342436cc.
Proxy type: None; implementations: [].
External libraries: ['src/LaunchGeometry.sol:LaunchGeometry @ 0xEb0C797DaDd23A7AD0d00187A976143C8AF8972A'].

## What it does

The whole launch path.
`launch`, `launchAndBuy` and `launchAndBuyWithEth` deploy a `LaunchToken`, open a Uniswap v4 pool keyed to `LaunchHook`, seed the entire supply as one locked one-sided position, register the pool's terms on the hook, and optionally execute the creator's first buy inside the same `unlock`.
There is no bonding curve contract and no graduation migration: the one-sided concentrated position is the curve.
`LP_FEE` is 0, so nothing accrues to the position and every fee is charged by the hook instead.
Quote assets are not allowlisted: `_assertQuoteLaunchable` refuses only a non-contract, an asset the QuoteRegistry classifies `UNSUPPORTED`, and anything whose `decimals()` reverts.
Live state at capture: `owner` 0xfe2cF227e21C5FC54dcE8Bb65F7C1E1E90236862, `paused` false, 81 `Launched` events (`_raw/rpc/launch-counts.txt`).

## Constructor arguments

- `poolManager_` (address): `0x8366a39CC670B4001A1121B8F6A443A643e40951`
- `hook_` (address): `0xe6234a98fF84220CcDA12985548ddAb36327Aacc`
- `quotes_` (address): `0x5D8b610E39156d2cFeF3c1ceCC3c22f4990A1298`
- `owner_` (address): `0xfe2cF227e21C5FC54dcE8Bb65F7C1E1E90236862`

## Events

- `Launched(bytes32,address,address,address,uint256,uint128,int24,int24)`
- `OwnershipTransferStarted(address,address)`
- `OwnershipTransferred(address,address)`
- `PausedSet(bool)`

## State-changing functions

- `acceptOwnership()`
- `launch(tuple)`
- `launchAndBuy(tuple,uint256,uint256)`
- `launchAndBuyWithEth(tuple,tuple[],uint256)`
- `renounceOwnership()`
- `setPaused(bool)`
- `transferOwnership(address)`
- `unlockCallback(bytes)`

## View functions

- `LP_FEE()`
- `MAX_ROUTE_HOPS()`
- `hook()`
- `launchCount()`
- `launchIdAt(uint256)`
- `launchSlice(uint256,uint256)`
- `launches(bytes32)`
- `owner()`
- `paused()`
- `pendingOwner()`
- `poolManager()`
- `poolOfToken(address)`
- `quotes()`
