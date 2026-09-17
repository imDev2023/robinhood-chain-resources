# FeeRouter - 0xe1c046571e69Ae2408C21605f2ff657A23977C4c

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xe1c046571e69Ae2408C21605f2ff657A23977C4c
Role: FeeRouter.
Contract name: FeeRouter.
Verified: True (verified at 2026-08-31T12:31:23.519180Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 800.
Main file: src/FeeRouter.sol.
Source files on disk: 66 under `sources/`.
Creator: 0xfe2cF227e21C5FC54dcE8Bb65F7C1E1E90236862.
Creation tx: 0x2b047f1407e6c7612b56c87d9329a064ff09188ff2e5ebc3362dec99ed8d69bf.
Proxy type: None; implementations: [].
External libraries: none.

## What it does, and why it is no longer in the path

Written to convert the launchpad's 1% platform fee into WETH and split it `DIVIDEND_SHARE_BPS` = 7000 to `dividendSink` and the rest to `protocolTreasury`, with a sandwich defence built from per-sale depth caps rather than an oracle.
Its live config still reads `dividendSink` 0x9f3edbfAE8014d55E328b6Dd966C6C95E75f6210, `protocolTreasury` 0xfe2cF227e21C5FC54dcE8Bb65F7C1E1E90236862, `bountyBps` 0 (`_raw/rpc/live-state.txt`).

**It is not the hook's fee router any more.**
`LaunchHook.RouterUpdated` fired twice: to this contract at block 49311480 on 2026-08-29, and away from it at block 49485132 the same evening.
Every one of the 117 `PlatformCollected` events since names the EOA 0xbd40E138 as the collector (`_raw/rpc/hook-fee-events.txt`), so the 70/30 split this contract enforces is not what happens today.

## Constructor arguments

- `poolManager_` (address): `0x8366a39CC670B4001A1121B8F6A443A643e40951`
- `hook_` (address): `0xe6234a98fF84220CcDA12985548ddAb36327Aacc`
- `factory_` (address): `0x718633252AA8329495Df8BBa8fF7c9e8378CFC63`
- `quotes_` (address): `0x5D8b610E39156d2cFeF3c1ceCC3c22f4990A1298`
- `weth_` (address): `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`
- `dividendSink_` (address): `0x9f3edbfAE8014d55E328b6Dd966C6C95E75f6210`
- `protocolTreasury_` (address): `0xfe2cF227e21C5FC54dcE8Bb65F7C1E1E90236862`
- `owner_` (address): `0xfe2cF227e21C5FC54dcE8Bb65F7C1E1E90236862`

## Events

- `BountySet(uint16)`
- `CooldownSet(uint32)`
- `KeeperSet(address,bool)`
- `OpenSweepDelaySet(uint32)`
- `OwnershipTransferStarted(address,address)`
- `OwnershipTransferred(address,address)`
- `RouteAdopted(address,bytes32)`
- `RouteSet(address,uint8,address)`
- `SinkSet(address,bool)`
- `Swept(address,uint256,uint256,uint256,uint256,uint256)`
- `TreasurySet(address)`

## State-changing functions

- `acceptOwnership()`
- `adoptLaunchRoute(address)`
- `clearRoute(address)`
- `renounceOwnership()`
- `setBountyBps(uint16)`
- `setKeeper(address,bool)`
- `setOpenSweepDelay(uint32)`
- `setProtocolTreasury(address)`
- `setSink(address,bool)`
- `setSweepCooldown(uint32)`
- `setV3Route(address,address)`
- `setV4Route(address,tuple)`
- `sweep(address,uint256)`
- `sweepUpTo(address,uint256,uint256)`
- `transferOwnership(address)`
- `uniswapV3SwapCallback(int256,int256,bytes)`
- `unlockCallback(bytes)`

## View functions

- `BPS()`
- `DIVIDEND_SHARE_BPS()`
- `MAX_BOUNTY_BPS()`
- `MAX_COOLDOWN()`
- `MAX_OPEN_DELAY()`
- `bountyBps()`
- `deployedAt()`
- `dividendSink()`
- `factory()`
- `hook()`
- `keepers(address)`
- `lastSweepAt(address)`
- `openSweepDelay()`
- `owner()`
- `pendingOwner()`
- `poolManager()`
- `protocolTreasury()`
- `quotes()`
- `routeFor(address)`
- `sinkNotify()`
- `sweepCooldown()`
- `sweepableNow(address)`
- `weth()`
- `wethDepthOf(address)`
