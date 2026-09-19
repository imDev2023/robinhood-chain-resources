// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @notice Test oracle that returns a configurable tick per pool.
contract MockTwapOracle {
    mapping(address => int24) public tickByPool;

    function setTick(address pool, int24 tick) external {
        tickByPool[pool] = tick;
    }

    function getTwapTick(address pool, uint32 /* secondsAgo */) external view returns (int24) {
        return tickByPool[pool];
    }
}

