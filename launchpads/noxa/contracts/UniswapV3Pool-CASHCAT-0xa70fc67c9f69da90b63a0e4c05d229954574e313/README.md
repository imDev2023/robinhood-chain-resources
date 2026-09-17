# UniswapV3Pool-CASHCAT - 0xa70fc67c9f69da90b63a0e4c05d229954574e313

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xa70fc67c9f69da90b63a0e4c05d229954574e313
Role: UniswapV3Pool-CASHCAT.
Contract name: UniswapV3Pool.
Verified: True.
Compiler: v0.7.6+commit.7338295f, EVM default, optimizer True runs 800.
Main file: contracts/UniswapV3Pool.sol.
Source files written: 31 under `sources/`.
Creator: 0x1f7d7550B1b028f7571E69A784071F0205FD2EfA.
Creation tx: 0x0e6d23f0babd02ede4aefaa923486591d783e1180c277c71e2f2a39fc74a4661.
Proxy type: None; implementations: [].

The 1% Uniswap V3 pool a V1 launch lands in.

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
