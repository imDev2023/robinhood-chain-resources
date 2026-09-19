# PartyFactory - 0x626C3d09B65bF5d1D40E0D5F25e19fa49783B3D4

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x626C3d09B65bF5d1D40E0D5F25e19fa49783B3D4
Role: PartyFactory.
Contract name: PartyFactory.
Verified: True (verified at 2026-08-11T10:17:17.144598Z).
Compiler: v0.8.25+commit.b61c2a91, EVM cancun, optimizer True runs 200.
Main file: src/PartyFactory.sol.
Source files written: 25 under `sources/`.
Creator: 0xd86EC279AD4871483f6c3D7ce54AD00067f120E9.
Creation tx: 0xcdc584625acf1d74fccb7b1b1b41527d23586d262e616944c56141ccdb191f1d.
Proxy type: None; implementations: [].

## Constructor arguments

- `sushiV3Factory_` (address): `0xE51960f1B45f1C9FB6D166E6a884F866fC70433B`
- `npm_` (address): `0x51d0e5188afe12d502e29D982d20C190e7816107`
- `weth_` (address): `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`
- `usdg_` (address): `0x5fc5360D0400a0Fd4f2af552ADD042D716F1d168`
- `owner_` (address): `0xd86EC279AD4871483f6c3D7ce54AD00067f120E9`

## Events

- `FallbackTickUsed(address,int24)`
- `InitialFdvSet(uint256)`
- `LockerSet(address)`
- `OwnershipTransferStarted(address,address)`
- `OwnershipTransferred(address,address)`
- `PairedAssetCurveRemoved(address)`
- `PairedAssetCurveSet(address,address,uint32,int24)`
- `PausedSet(bool)`
- `SequencerUptimeFeedSet(address)`
- `TokenLaunched(address,address,address,address,address,address,int24,string,uint256)`

## State-changing functions

- `acceptOwnership()`
- `launch(string,string,string,bytes32,address,int24,uint256,address,address,uint256,uint256)`
- `removePairedAssetCurve(address)`
- `setInitialFdvUsd(uint256)`
- `setLocker(address)`
- `setPairedAssetCurve(address,address,uint32,int24)`
- `setPaused(bool)`
- `setSequencerUptimeFeed(address)`
- `transferOwnership(address)`
- `uniswapV3SwapCallback(int256,int256,bytes)`

## View functions

- `FEE()`
- `MAX_FDV_USD()`
- `MAX_PRICE_AGE()`
- `MIN_FDV_USD()`
- `MIN_PRICE_AGE()`
- `SEQUENCER_GRACE_PERIOD()`
- `TICK_SPACING()`
- `TOTAL_SUPPLY()`
- `allowedPairedAsset(address)`
- `computeTokenAddress(address,bytes32,string,string,string)`
- `getPairedAssetCurve(address)`
- `initialFdvUsd()`
- `locker()`
- `maxUsableTick()`
- `npm()`
- `owner()`
- `paused()`
- `pendingOwner()`
- `renounceOwnership()`
- `sequencerUptimeFeed()`
- `startTickFor(address)`
- `sushiFactory()`
- `usdg()`
- `validatePairedAssetCurve(address,address,uint32,int24)`
- `weth()`
