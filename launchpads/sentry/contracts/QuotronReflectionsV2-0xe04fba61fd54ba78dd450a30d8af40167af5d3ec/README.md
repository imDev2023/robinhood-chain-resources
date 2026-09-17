# QuotronReflectionsV2 - 0xe04fba61fd54ba78dd450a30d8af40167af5d3ec

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xe04fba61fd54ba78dd450a30d8af40167af5d3ec
Role: QuotronReflectionsV2.
Contract name: QuotronReflectionsV2.
Verified: True (verified at 2026-08-13T15:22:29.623079Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/v2/QuotronReflectionsV2.sol.
Source files written: 2 under `sources/`.
Creator: 0x7171E64E979265aeD6588577D1c6b60A701d7866.
Creation tx: 0x801cd3e38534b8a86f05466331ecadc81849db774929e3f1e0c07d6204bb4649.
Proxy type: None; implementations: [].

Quotrons reflections, second generation.

## Constructor arguments

- `quotron_` (address): `0x5a86828Efd322bfb16d93cFeD16EE9BC14940D7F`
- `brokers_` (address): `0x539CdD042c2f3d93EbC5BE7DfFf0c79F3B4fAbF0`
- `legacyPaxg_` (address): `0xc700C81925D1d1C10F996fA7c0Dee83a54C4Bb8D`

## Events

- `Claimed(uint256,address,address,uint256)`
- `FeesNotified(uint8,uint256,uint256,uint256,uint256)`
- `FloorPotClaimed(uint8,uint256,uint256)`
- `InflowsPaused(bool)`
- `LegacyCredited(uint256,address,uint256)`
- `Poked(uint256,uint256,uint256)`
- `WiringSealed(address,address)`

## State-changing functions

- `claim(uint256[])`
- `creditLegacy(uint256,address,uint256)`
- `notifyFees(uint8,uint256)`
- `onHardwire(uint256,address)`
- `onHardwiredTransfer(uint256,address,address)`
- `poke(uint256)`
- `sealAttributes()`
- `sealWiring()`
- `setAttributes(uint16[],uint8[])`
- `setFloorStocks(address[10])`
- `setInflowsPaused(bool)`
- `setMigrator(address)`
- `setNotifier(address)`
- `transferOwnership(address)`

## View functions

- `BASKET_BPS()`
- `BASKET_FIRST_ID()`
- `BASKET_LAST_ID()`
- `BOOST_DEN()`
- `BOOST_NUM()`
- `FLOOR_BASKET()`
- `FLOOR_GOLD()`
- `GOLD_BPS()`
- `GOLD_ID()`
- `attrCount()`
- `attributesOf(uint256)`
- `attributesSealed()`
- `basketAcc(address)`
- `basketClaimed(uint256,address)`
- `basketPending(uint256,address)`
- `brokers()`
- `floorStocks(uint256)`
- `floors(uint256)`
- `goldClaimed(address)`
- `goldPendingPaxg()`
- `goldPendingStock(address)`
- `goldPot(address)`
- `inflowsPaused()`
- `legacyCredit(uint256,address)`
- `migrator()`
- `notifier()`
- `owner()`
- `packedAttr(uint256)`
- `paxg()`
- `pending(uint256)`
- `quotron()`
- `stocksSet()`
- `terminals(uint256)`
- `tierWeights(uint256)`
- `weightOf(uint256)`
- `wiringSealed()`
