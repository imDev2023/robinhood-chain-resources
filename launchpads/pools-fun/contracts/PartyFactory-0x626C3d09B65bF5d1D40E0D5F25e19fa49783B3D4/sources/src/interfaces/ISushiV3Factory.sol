// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/// @notice Minimal SushiSwap V3 (Uniswap-V3-fork) factory interface used by pools.fun.
interface ISushiV3Factory {
    function getPool(address tokenA, address tokenB, uint24 fee) external view returns (address pool);

    function createPool(address tokenA, address tokenB, uint24 fee) external returns (address pool);

    function feeAmountTickSpacing(uint24 fee) external view returns (int24);
}
