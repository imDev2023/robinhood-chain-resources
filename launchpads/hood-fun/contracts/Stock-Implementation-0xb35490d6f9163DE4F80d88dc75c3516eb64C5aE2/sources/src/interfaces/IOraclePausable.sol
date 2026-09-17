// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IOraclePausable {
    event OraclePaused();
    event OracleUnpaused();

    function oraclePaused() external view returns (bool);
}
