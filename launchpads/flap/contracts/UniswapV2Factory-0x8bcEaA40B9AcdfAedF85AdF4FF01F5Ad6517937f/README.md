# UniswapV2Factory-0x8bcEaA40B9AcdfAedF85AdF4FF01F5Ad6517937f

**Uniswap V2 factory, migration destination, verified**

- Address: `0x8bcEaA40B9AcdfAedF85AdF4FF01F5Ad6517937f`
- Contract name on Blockscout: `UniswapV2Factory`
- Verified: yes
- Proxy type: `none`
- Creator: `0x9701fb0aDe1E269c8f64Ec0C7b3cfADB31A13A52`
- Creation tx: `0x2fc08b6c72d5f2120cec9f3be8ed0b45c210d51adbc87f33b2135886681edaf7`
- Compiler: `v0.5.16+commit.9c3226ce`, optimizer on (999999 runs), EVM `istanbul`
- License: `none`
- Explorer: <https://robinhoodchain.blockscout.com/address/0x8bcEaA40B9AcdfAedF85AdF4FF01F5Ad6517937f>

`V2_MIGRATOR` is the only migrator Robinhood Chain accepts, and this is the factory it uses.
`allPairsLength()` was `40431` on 2026-09-02.
Sampling 3,000 of those pairs, 27 had a Flap vanity token on one side, implying roughly 364 graduated Flap tokens (`_raw/rpc/graduation-sample.txt`).

## Constructor arguments

- `_feeToSetter` (`address`): `0x9701fb0aDe1E269c8f64Ec0C7b3cfADB31A13A52`

## Functions that matter for launching

- `allPairs(uint256)` returns `(address)`  [view]
- `allPairsLength()` returns `(uint256)`  [view]
- `createPair(address,address)` returns `(address)`  [nonpayable]
- `feeTo()` returns `(address)`  [view]
- `feeToSetter()` returns `(address)`  [view]
- `getPair(address,address)` returns `(address)`  [view]
- `setFeeTo(address)`  [nonpayable]
- `setFeeToSetter(address)`  [nonpayable]

## Events

- `PairCreated(address,address,address,uint256)`

## Files in this directory

- `abi.json`
- `address.json`
- `metadata.json`
- `methods-read.json`
- `sources`/
