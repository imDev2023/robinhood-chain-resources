# UniswapV2Factory - 0x8bcEaA40B9AcdfAedF85AdF4FF01F5Ad6517937f

Role: UniswapV2Factory.
Address: `0x8bcEaA40B9AcdfAedF85AdF4FF01F5Ad6517937f` on Robinhood Chain (chain id 4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x8bcEaA40B9AcdfAedF85AdF4FF01F5Ad6517937f
Verified: True (fully verified: True, partially: False).
Compiler: v0.5.16+commit.9c3226ce, EVM istanbul, optimizer True runs 999999.
Language: solidity. License: none.
Proxy type: None. Implementations: [].
Main source file: `contracts/UniswapV2Factory.sol`. Source files written: 11 under `sources/`.
Raw constructor args: `0000000000000000000000009701fb0ade1e269c8f64ec0c7b3cfadb31a13a52`.

Decoded constructor args:
- _feeToSetter (address): `0x9701fb0aDe1E269c8f64Ec0C7b3cfADB31A13A52`

## Functions

- `allPairs(uint256)` -> address [view]
- `allPairsLength()` -> uint256 [view]
- `createPair(address tokenA, address tokenB)` -> address [nonpayable]
- `feeTo()` -> address [view]
- `feeToSetter()` -> address [view]
- `getPair(address, address)` -> address [view]
- `setFeeTo(address _feeTo)` ->  [nonpayable]
- `setFeeToSetter(address _feeToSetter)` ->  [nonpayable]

## Events

- `PairCreated(address token0, address token1, address pair, uint256)`

Launch-relevant items (create, launch, buy, sell, graduate, migrate, claim, lock, collect) are marked by name above.
See `metadata.json` for the full Blockscout smart-contracts response and `abi.json` for the ABI.
