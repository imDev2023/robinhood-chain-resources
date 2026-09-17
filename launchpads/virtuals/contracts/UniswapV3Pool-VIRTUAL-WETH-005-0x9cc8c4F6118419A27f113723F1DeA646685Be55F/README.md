# UniswapV3Pool-VIRTUAL-WETH-005 - 0x9cc8c4F6118419A27f113723F1DeA646685Be55F

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x9cc8c4F6118419A27f113723F1DeA646685Be55F
Role: UniswapV3Pool-VIRTUAL-WETH-005.
Contract name: UniswapV3Pool.
Verified: True (verified at 2026-07-22T11:48:33.311123Z).
Compiler: v0.7.6+commit.7338295f, EVM istanbul, optimizer True runs 800.
Main file: ./contracts/UniswapV3Pool.sol.
Source files written: 311 under `sources/`.
Creator: 0x1f7d7550B1b028f7571E69A784071F0205FD2EfA.
Creation tx: 0xf4366e05cb430a5b4b0547abb31cfbeb6c89d558522d61d5a3cc018e3874bdb6.
Proxy type: None; implementations: [].

The Dexscreener VIRTUAL/WETH pool from launchpad-research.md, Uniswap V3 fee 500 (0.05 percent). token0 WETH, token1 VIRTUAL.

## Constructor arguments

None decoded.

## Events

- `Burn(address,int24,int24,uint128,uint256,uint256)`
- `Collect(address,address,int24,int24,uint128,uint128)`
- `CollectProtocol(address,address,uint128,uint128)`
- `Flash(address,address,uint256,uint256,uint256,uint256)`
- `IncreaseObservationCardinalityNext(uint16,uint16)`
- `Initialize(uint160,int24)`
- `Mint(address,address,int24,int24,uint128,uint256,uint256)`
- `SetFeeProtocol(uint8,uint8,uint8,uint8)`
- `Swap(address,address,int256,int256,uint160,uint128,int24)`

## State-changing functions

- `burn(int24,int24,uint128)`
- `collect(address,int24,int24,uint128,uint128)`
- `collectProtocol(address,uint128,uint128)`
- `flash(address,uint256,uint256,bytes)`
- `increaseObservationCardinalityNext(uint16)`
- `initialize(uint160)`
- `mint(address,int24,int24,uint128,bytes)`
- `setFeeProtocol(uint8,uint8)`
- `swap(address,bool,int256,uint160,bytes)`

## View functions

- `factory()`
- `fee()`
- `feeGrowthGlobal0X128()`
- `feeGrowthGlobal1X128()`
- `liquidity()`
- `maxLiquidityPerTick()`
- `observations(uint256)`
- `observe(uint32[])`
- `positions(bytes32)`
- `protocolFees()`
- `slot0()`
- `snapshotCumulativesInside(int24,int24)`
- `tickBitmap(int16)`
- `tickSpacing()`
- `ticks(int24)`
- `token0()`
- `token1()`
