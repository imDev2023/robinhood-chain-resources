# BuybackAndBurnClaimRecipient - 0xa1ba4CC12654D2b188e3ba77dc86c75cA47f1A4e

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xa1ba4CC12654D2b188e3ba77dc86c75cA47f1A4e
Role: BuybackAndBurnClaimRecipient.
Contract name: BuybackAndBurnClaimRecipient.
Verified: True (sources from `smart-contracts`, flag from `addresses`).
Compiler: v0.8.36+commit.8a079791, EVM osaka, optimizer True runs 200.
Main file: src/periphery/BuybackAndBurnClaimRecipient.sol.
Source files written: 35 under `sources/`.
Creator: 0x4e59b44847b379578588920cA78FbF26c0B4956C.
Creation tx: 0x6b2343592b21af7cde2b9dc8438b36f55b5359c1a814b5344331807657283fae.
Proxy type: None; implementations: [].

## Constructor arguments

- `_positionManager` (address): `0x58daec3116aae6D93017bAAea7749052E8a04fA7`
- `_minCurrency1BurnAmount` (uint256): `500000000000000000000000`

## Events

- `AmountsReceived(uint256,uint256,uint256)`
- `Claimed(uint256,uint256,uint256,tuple)`
- `TokensBurned(uint256,address,uint256)`

## State-changing functions

- `claim(uint256,uint256,uint256)`
- `onAmountsReceived(uint256,uint256,uint256)`

## View functions

- `amounts(uint256)`
- `currency()`
- `minCurrency1BurnAmount()`
- `positionManager()`
- `totalAmounts(address)`
