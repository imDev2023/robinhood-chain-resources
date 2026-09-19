// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./IUniswapV3PoolMinimal.sol";

/// @notice Minimal Uniswap v3 TWAP oracle that returns the arithmetic mean tick over a window.
/// Consumers must interpret tick direction based on pool token0/token1 ordering.
contract StonkTwapOracle {
    error BadWindow();

    function getTwapTick(address pool, uint32 secondsAgo) external view returns (int24) {
        if (secondsAgo == 0) revert BadWindow();
        uint32[] memory secs = new uint32[](2);
        secs[0] = secondsAgo;
        secs[1] = 0;

        (int56[] memory tickCumulatives, ) = IUniswapV3PoolMinimal(pool).observe(secs);
        int56 delta = tickCumulatives[1] - tickCumulatives[0];
        int56 mean = delta / int56(uint56(secondsAgo));
        // Uniswap v3 oracle requires rounding toward negative infinity when negative and not exact.
        if (delta < 0 && (delta % int56(uint56(secondsAgo)) != 0)) mean -= 1;
        return int24(mean);
    }
}

