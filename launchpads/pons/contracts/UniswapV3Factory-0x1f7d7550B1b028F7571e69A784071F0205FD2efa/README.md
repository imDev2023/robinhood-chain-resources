# UniswapV3Factory

`0x1f7d7550B1b028F7571e69A784071F0205FD2efa`

Group: Uniswap.
V1 launches open a Uniswap V3 pool here.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | yes |
| Contract name | `UniswapV3Factory` |
| Compiler | v0.7.6+commit.7338295f |
| Optimizer | True, runs 800 |
| EVM version | istanbul |
| License | none |
| Proxy type | none |
| Creator | `0x9701fb0aDe1E269c8f64Ec0C7b3cfADB31A13A52` |
| Creation tx | `0x8add72fbcad4bf7732336de35dcd06b582c1501d0832c4710a30850a7cff8977` |

## Functions that matter for launching

- `createPool(address tokenA, address tokenB, uint24 fee)`
- `enableFeeAmount(uint24 fee, int24 tickSpacing)`

## Reads that matter

- `feeAmountTickSpacing(uint24 )`

## Events

- `FeeAmountEnabled(uint24 fee, int24 tickSpacing)`
- `PoolCreated(address token0, address token1, uint24 fee, int24 tickSpacing, address pool)`

Full ABI in `abi.json`. Verified sources in `sources/`. Raw Blockscout response in `metadata.json`.
Counts: 3 state-changing functions, 4 views, 3 events, 0 custom errors.
