# CompoundingClaimRecipient - 0xf9526Dd3361fe0ba6b7a99533ed471D3E808E99a

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xf9526Dd3361fe0ba6b7a99533ed471D3E808E99a
Role: CompoundingClaimRecipient.
Contract name: CompoundingClaimRecipient.
Verified: True (sources from `smart-contracts`, flag from `addresses`).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/periphery/CompoundingClaimRecipient.sol.
Source files written: 34 under `sources/`.
Creator: 0x4e59b44847b379578588920cA78FbF26c0B4956C.
Creation tx: 0xb5fa8297aa0ce8ebba296db7ee84599035f61606cd62037e98b94ea3c16b20e3.
Proxy type: None; implementations: [].

## Constructor arguments

- `_positionManager` (address): `0x58daec3116aae6D93017bAAea7749052E8a04fA7`
- `_minLiquidityIncrease` (uint128): `100000000000000000000`

## Events

- `AmountsReceived(uint256,uint256,uint256)`
- `Claimed(uint256,uint256,uint256,tuple)`

## State-changing functions

- `claim(uint256,uint256,uint256)`
- `onAmountsReceived(uint256,uint256,uint256)`

## View functions

- `amounts(uint256)`
- `minLiquidityIncrease()`
- `positionManager()`
- `totalAmounts(address)`
