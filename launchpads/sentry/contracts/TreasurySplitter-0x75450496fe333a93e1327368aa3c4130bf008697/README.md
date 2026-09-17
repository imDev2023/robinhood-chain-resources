# TreasurySplitter - 0x75450496fe333a93e1327368aa3c4130bf008697

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x75450496fe333a93e1327368aa3c4130bf008697
Role: TreasurySplitter.
Contract name: SentryTreasurySplitter.
Verified: True (verified at 2026-07-29T20:45:29.980403Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/SentryTreasurySplitter.sol.
Source files written: 29 under `sources/`.
Creator: 0xbF551eED83c7eaEE63854a2013Eb94f18600B7C5.
Creation tx: 0x0cbdb74b15902d2e04ba60497e69cae39beedd50d75c9e445f8b1e38dc6cf4a7.
Proxy type: None; implementations: [].

Receives the protocol leg of every launch fee and splits it `forwardBps` 6000 to the treasury wallet, remainder into permanently locked SENTRY liquidity.

## Constructor arguments

- `_poolManager` (address): `0x8366a39CC670B4001A1121B8F6A443A643e40951`
- `_weth` (address): `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`
- `_usdg` (address): `0x5fc5360D0400a0Fd4f2af552ADD042D716F1d168`
- `_v3Router` (address): `0xCaf681a66D020601342297493863E78C959E5cb2`
- `_treasuryWallet` (address): `0xcaAfCf8E55f3B5e3D5F7957987db232f08d2367c`
- `_forwardBps` (uint16): `6000`

## Events

- `KeeperUpdated(address,address)`
- `OwnershipTransferred(address,address)`
- `PairPoolInitialized(address,uint160)`
- `PendingSwept(address,uint256)`
- `SentryConfigured(address)`
- `Split(address,uint256,uint256)`
- `StockCompounded(address,uint256,uint256,uint128)`
- `StockConfigSet(address)`
- `TreasuryWalletUpdated(address,address)`
- `WethCompounded(uint256,uint256,uint128)`

## State-changing functions

- `compoundStock(address,uint256,uint256)`
- `compoundWeth(uint256)`
- `configureSentry(address,tuple)`
- `initializePairPool(address,uint160)`
- `setKeeper(address)`
- `setStockConfig(address,tuple)`
- `setTreasuryWallet(address)`
- `split(address)`
- `sweepPending(address)`
- `transferOwnership(address)`
- `unlockCallback(bytes)`

## View functions

- `forwardBps()`
- `keeper()`
- `owner()`
- `pairKeyOf(address)`
- `pending(address)`
- `poolManager()`
- `sentry()`
- `sentryConfigured()`
- `sentryWethKeyView()`
- `stockConfig(address)`
- `treasuryWallet()`
- `usdg()`
- `v3Router()`
- `weth()`
