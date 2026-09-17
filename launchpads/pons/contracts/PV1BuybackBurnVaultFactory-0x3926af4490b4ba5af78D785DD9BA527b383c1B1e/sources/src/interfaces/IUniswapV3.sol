// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IUniswapV3Factory {
    function getPool(address tokenA, address tokenB, uint24 fee) external view returns (address pool);
}

/// @dev The Robinhood Chain router at 0xCaf681a6... is SwapRouter02, so `ExactInputSingleParams`
///      has no `deadline` field. Verified by selector: it exposes 0x04e45aaf, not 0x414bf389.
interface ISwapRouter02 {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params)
        external
        payable
        returns (uint256 amountOut);
}
