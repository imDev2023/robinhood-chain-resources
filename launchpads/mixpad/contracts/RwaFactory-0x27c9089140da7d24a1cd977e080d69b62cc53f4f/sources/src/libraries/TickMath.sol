// SPDX-License-Identifier: MIT
pragma solidity ^0.8.36;

// v4-core renamed getSqrtRatioAtTick → getSqrtPriceAtTick. This wrapper
// exposes the v3 name so all Mixpad callers compile without changes while
// the underlying math remains exactly as published in @uniswap/v4-core.
import {TickMath as V4TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";

library TickMath {
    function getSqrtRatioAtTick(int24 tick) internal pure returns (uint160) {
        return V4TickMath.getSqrtPriceAtTick(tick);
    }
}
