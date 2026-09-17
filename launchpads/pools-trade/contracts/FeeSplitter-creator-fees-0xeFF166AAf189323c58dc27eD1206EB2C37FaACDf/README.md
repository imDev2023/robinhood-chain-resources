# FeeSplitter-creator-fees - 0xeFF166AAf189323c58dc27eD1206EB2C37FaACDf

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xeFF166AAf189323c58dc27eD1206EB2C37FaACDf
Role: FeeSplitter-creator-fees.
Contract name: FeeSplitter.
Verified: True (sources from `smart-contracts`, flag from `addresses`).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/periphery/FeeSplitter.sol.
Source files written: 47 under `sources/`.
Creator: 0x4e59b44847b379578588920cA78FbF26c0B4956C.
Creation tx: 0xe78f52eaff3b455e26667cac1bc57a98201de68a7bb23f8be0df11e1972353bb.
Proxy type: None; implementations: [].

## Constructor arguments

- `_positionManager` (address): `0x58daec3116aae6D93017bAAea7749052E8a04fA7`
- `splits_` (tuple[]): `[['0xd35E9CA72F64C7F93BE30fad67524323396B36D7', '4000', '0', 'true'], ['0xf9526Dd3361fe0ba6b7a99533ed471D3E808E99a', '6000', '10000', 'true']]`

## Events

- `FeesCollected(uint256,address,uint256,uint256)`
- `FeesForwarded(address,address,uint256)`

## State-changing functions

- `collectFees(uint256[])`
- `increaseLiquidity(uint256,uint256,uint128,uint128,bytes)`

## View functions

- `BPS_DENOMINATOR()`
- `MAX_BALANCE_ALLOWED()`
- `getSplits()`
- `onERC721Received(address,address,uint256,bytes)`
- `poolManager()`
- `positionManager()`
