// SPDX-License-Identifier: MIT
pragma solidity ^0.8.36;

import {LiquidityAmounts} from "@uniswap/v3-periphery/contracts/libraries/LiquidityAmounts.sol";

/// @notice Thin wrapper over Uniswap v3-periphery's LiquidityAmounts library,
/// naming the functions the way MixpadFactory calls them. v3-periphery ships
/// the full bidirectional set (amount→liquidity and liquidity→amount), so all
/// three delegates below resolve directly with no hand-rolled math.
library LiquidityMath {
    function getLiquidityForAmount0(uint160 sqrtRatioAX96, uint160 sqrtRatioBX96, uint256 amount0)
        internal
        pure
        returns (uint128 liquidity)
    {
        return LiquidityAmounts.getLiquidityForAmount0(sqrtRatioAX96, sqrtRatioBX96, amount0);
    }

    function getLiquidityForAmount1(uint160 sqrtRatioAX96, uint160 sqrtRatioBX96, uint256 amount1)
        internal
        pure
        returns (uint128 liquidity)
    {
        return LiquidityAmounts.getLiquidityForAmount1(sqrtRatioAX96, sqrtRatioBX96, amount1);
    }

    function getAmountsForLiquidity(
        uint160 sqrtRatioX96,
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint128 liquidity
    ) internal pure returns (uint256 amount0, uint256 amount1) {
        return LiquidityAmounts.getAmountsForLiquidity(sqrtRatioX96, sqrtRatioAX96, sqrtRatioBX96, liquidity);
    }
}
