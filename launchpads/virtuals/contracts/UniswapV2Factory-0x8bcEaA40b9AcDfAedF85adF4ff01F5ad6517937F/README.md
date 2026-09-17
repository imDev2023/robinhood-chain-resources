# UniswapV2Factory - 0x8bcEaA40b9AcDfAedF85adF4ff01F5ad6517937F

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x8bcEaA40b9AcDfAedF85adF4ff01F5ad6517937F
Role: UniswapV2Factory.
Contract name: UniswapV2Factory.
Verified: True (verified at 2026-05-22T18:41:20.093146Z).
Compiler: v0.5.16+commit.9c3226ce, EVM istanbul, optimizer True runs 999999.
Main file: contracts/UniswapV2Factory.sol.
Source files written: 11 under `sources/`.
Creator: 0x9701fb0aDe1E269c8f64Ec0C7b3cfADB31A13A52.
Creation tx: 0x2fc08b6c72d5f2120cec9f3be8ed0b45c210d51adbc87f33b2135886681edaf7.
Proxy type: None; implementations: [].

Uniswap V2 factory used for every graduated pool (third-party).

## Constructor arguments

- `_feeToSetter` (address): `0x9701fb0aDe1E269c8f64Ec0C7b3cfADB31A13A52`

## Events

- `PairCreated(address,address,address,uint256)`

## State-changing functions

- `createPair(address,address)`
- `setFeeTo(address)`
- `setFeeToSetter(address)`

## View functions

- `allPairs(uint256)`
- `allPairsLength()`
- `feeTo()`
- `feeToSetter()`
- `getPair(address,address)`
