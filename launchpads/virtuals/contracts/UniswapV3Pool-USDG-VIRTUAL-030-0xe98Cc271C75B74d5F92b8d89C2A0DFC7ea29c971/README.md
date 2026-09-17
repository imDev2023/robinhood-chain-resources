# UniswapV3Pool-USDG-VIRTUAL-030 - 0xe98Cc271C75B74d5F92b8d89C2A0DFC7ea29c971

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xe98Cc271C75B74d5F92b8d89C2A0DFC7ea29c971
Role: UniswapV3Pool-USDG-VIRTUAL-030.
Contract name: UniswapV3Pool.
Verified: True (verified at 2026-07-02T00:44:45.881181Z).
Compiler: v0.7.6+commit.7338295f, EVM default, optimizer True runs 800.
Main file: contracts/UniswapV3Pool.sol.
Source files written: 31 under `sources/`.
Creator: 0x1f7d7550B1b028f7571E69A784071F0205FD2EfA.
Creation tx: 0xb1b9f9d86ed29709c0c245ebc36a940a6aef89602ef4b99e5d1aedfbca41daba.
Proxy type: None; implementations: [].

Uniswap V3 USDG/VIRTUAL pool, fee 3000 (0.3 percent). token0 USDG, token1 VIRTUAL.

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
