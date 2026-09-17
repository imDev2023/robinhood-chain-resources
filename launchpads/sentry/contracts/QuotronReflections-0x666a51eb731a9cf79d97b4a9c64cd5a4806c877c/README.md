# QuotronReflections - 0x666a51eb731a9cf79d97b4a9c64cd5a4806c877c

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x666a51eb731a9cf79d97b4a9c64cd5a4806c877c
Role: QuotronReflections.
Contract name: QuotronReflections.
Verified: True (verified at 2026-08-12T13:03:00.618304Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/QuotronReflections.sol.
Source files written: 2 under `sources/`.
Creator: 0x7171E64E979265aeD6588577D1c6b60A701d7866.
Creation tx: 0xf10740e0fef14825c5376afc9aa32837fb153308889ae1843725fbe3be073243.
Proxy type: None; implementations: [].

Quotrons reflections, first generation.

## Constructor arguments

- `quotron_` (address): `0x40686524e56AfF0F1446958725dCF6e6dA5381E6`
- `brokers_` (address): `0x539CdD042c2f3d93EbC5BE7DfFf0c79F3B4fAbF0`

## Events

- `Claimed(uint256,address,address,uint256)`
- `FeesNotified(uint8,uint256,uint256,uint256,uint256)`
- `FloorPotClaimed(uint8,uint256,uint256)`
- `GoldPulled(address,uint256,address)`
- `PaxgDeposited(uint256)`
- `Poked(uint256,uint256,uint256)`

## State-changing functions

- `claim(uint256[])`
- `depositPaxg(uint256)`
- `notifyFees(uint8,uint256)`
- `onHardwire(uint256,address)`
- `onHardwiredTransfer(uint256,address,address)`
- `poke(uint256)`
- `pullGoldPot(address,uint256,address)`
- `sealAttributes()`
- `setAttributes(uint16[],uint8[])`
- `setFloorStocks(address[10])`
- `setHook(address)`
- `setKeeper(address)`
- `setPaxg(address)`

## View functions

- `BASKET_BPS()`
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
- `goldPendingPaxg()`
- `goldPot(address)`
- `hook()`
- `keeper()`
- `owner()`
- `packedAttr(uint256)`
- `paxg()`
- `paxgClaimed()`
- `paxgDeposited()`
- `pending(uint256)`
- `quotron()`
- `stocksSet()`
- `terminals(uint256)`
- `tierWeights(uint256)`
- `weightOf(uint256)`
