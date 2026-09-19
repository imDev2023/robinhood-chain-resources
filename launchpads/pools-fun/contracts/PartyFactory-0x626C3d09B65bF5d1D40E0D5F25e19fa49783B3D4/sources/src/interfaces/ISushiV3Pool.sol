// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/// @notice Minimal SushiSwap V3 pool interface (subset of Uniswap V3 core).
interface ISushiV3Pool {
    function initialize(uint160 sqrtPriceX96) external;

    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );

    function liquidity() external view returns (uint128);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function fee() external view returns (uint24);

    function tickSpacing() external view returns (int24);

    /// @param recipient Address receiving the output tokens.
    /// @param zeroForOne true = swap token0 for token1.
    /// @param amountSpecified >0 exact input, <0 exact output.
    /// @param sqrtPriceLimitX96 Price limit; the callback must pay the owed input.
    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);

    /// @notice All-time fee growth per unit of liquidity (X128); wraps by design.
    function feeGrowthGlobal0X128() external view returns (uint256);

    function feeGrowthGlobal1X128() external view returns (uint256);

    /// @notice Per-tick state; the feeGrowthOutside legs feed uncollected-fee previews.
    function ticks(int24 tick)
        external
        view
        returns (
            uint128 liquidityGross,
            int128 liquidityNet,
            uint256 feeGrowthOutside0X128,
            uint256 feeGrowthOutside1X128,
            int56 tickCumulativeOutside,
            uint160 secondsPerLiquidityOutsideX128,
            uint32 secondsOutside,
            bool initialized
        );

    /// @notice Cumulative tick/liquidity observations as of `secondsAgos` in the past.
    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);

    /// @notice Raw observation slot; used to find the oldest checkpoint's age.
    function observations(uint256 index)
        external
        view
        returns (
            uint32 blockTimestamp,
            int56 tickCumulative,
            uint160 secondsPerLiquidityCumulativeX128,
            bool initialized
        );
}
