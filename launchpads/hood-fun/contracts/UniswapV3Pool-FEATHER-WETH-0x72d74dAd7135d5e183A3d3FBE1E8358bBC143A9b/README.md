# UniswapV3Pool - 0x72d74dAd7135d5e183A3d3FBE1E8358bBC143A9b

Role: UniswapV3Pool-FEATHER-WETH.
Address: `0x72d74dAd7135d5e183A3d3FBE1E8358bBC143A9b` on Robinhood Chain (chain id 4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x72d74dAd7135d5e183A3d3FBE1E8358bBC143A9b
Verified: True (fully verified: False, partially: True).
Compiler: v0.7.6+commit.7338295f, EVM istanbul, optimizer True runs 800.
Language: solidity. License: none.
Proxy type: None. Implementations: [].
Main source file: `./contracts/UniswapV3Pool.sol`. Source files written: 31 under `sources/`.
Raw constructor args: `None`.

## Functions

- `burn(int24 tickLower, int24 tickUpper, uint128 amount)` -> uint256, uint256 [nonpayable]
- `collect(address recipient, int24 tickLower, int24 tickUpper, uint128 amount0Requested, uint128 amount1Requested)` -> uint128, uint128 [nonpayable]
- `collectProtocol(address recipient, uint128 amount0Requested, uint128 amount1Requested)` -> uint128, uint128 [nonpayable]
- `factory()` -> address [view]
- `fee()` -> uint24 [view]
- `feeGrowthGlobal0X128()` -> uint256 [view]
- `feeGrowthGlobal1X128()` -> uint256 [view]
- `flash(address recipient, uint256 amount0, uint256 amount1, bytes data)` ->  [nonpayable]
- `increaseObservationCardinalityNext(uint16 observationCardinalityNext)` ->  [nonpayable]
- `initialize(uint160 sqrtPriceX96)` ->  [nonpayable]
- `liquidity()` -> uint128 [view]
- `maxLiquidityPerTick()` -> uint128 [view]
- `mint(address recipient, int24 tickLower, int24 tickUpper, uint128 amount, bytes data)` -> uint256, uint256 [nonpayable]
- `observations(uint256)` -> uint32, int56, uint160, bool [view]
- `observe(uint32[] secondsAgos)` -> int56[], uint160[] [view]
- `positions(bytes32)` -> uint128, uint256, uint256, uint128, uint128 [view]
- `protocolFees()` -> uint128, uint128 [view]
- `setFeeProtocol(uint8 feeProtocol0, uint8 feeProtocol1)` ->  [nonpayable]
- `slot0()` -> uint160, int24, uint16, uint16, uint16, uint8, bool [view]
- `snapshotCumulativesInside(int24 tickLower, int24 tickUpper)` -> int56, uint160, uint32 [view]
- `swap(address recipient, bool zeroForOne, int256 amountSpecified, uint160 sqrtPriceLimitX96, bytes data)` -> int256, int256 [nonpayable]
- `tickBitmap(int16)` -> uint256 [view]
- `tickSpacing()` -> int24 [view]
- `ticks(int24)` -> uint128, int128, uint256, uint256, int56, uint160, uint32, bool [view]
- `token0()` -> address [view]
- `token1()` -> address [view]

## Events

- `Burn(address owner, int24 tickLower, int24 tickUpper, uint128 amount, uint256 amount0, uint256 amount1)`
- `Collect(address owner, address recipient, int24 tickLower, int24 tickUpper, uint128 amount0, uint128 amount1)`
- `CollectProtocol(address sender, address recipient, uint128 amount0, uint128 amount1)`
- `Flash(address sender, address recipient, uint256 amount0, uint256 amount1, uint256 paid0, uint256 paid1)`
- `IncreaseObservationCardinalityNext(uint16 observationCardinalityNextOld, uint16 observationCardinalityNextNew)`
- `Initialize(uint160 sqrtPriceX96, int24 tick)`
- `Mint(address sender, address owner, int24 tickLower, int24 tickUpper, uint128 amount, uint256 amount0, uint256 amount1)`
- `SetFeeProtocol(uint8 feeProtocol0Old, uint8 feeProtocol1Old, uint8 feeProtocol0New, uint8 feeProtocol1New)`
- `Swap(address sender, address recipient, int256 amount0, int256 amount1, uint160 sqrtPriceX96, uint128 liquidity, int24 tick)`

Launch-relevant items (create, launch, buy, sell, graduate, migrate, claim, lock, collect) are marked by name above.
See `metadata.json` for the full Blockscout smart-contracts response and `abi.json` for the ABI.
