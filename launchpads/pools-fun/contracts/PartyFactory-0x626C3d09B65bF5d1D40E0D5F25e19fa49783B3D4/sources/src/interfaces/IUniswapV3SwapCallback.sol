// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/// @notice Callback invoked by a V3 pool on `swap`; the caller must pay the owed input.
interface IUniswapV3SwapCallback {
    function uniswapV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata data) external;
}
