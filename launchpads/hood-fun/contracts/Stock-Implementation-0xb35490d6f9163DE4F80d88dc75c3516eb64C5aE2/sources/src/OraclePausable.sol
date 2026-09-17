// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IOraclePausable.sol";

abstract contract OraclePausable is IOraclePausable {
    /// @custom:storage-location erc7201:robinhood.storage.OraclePausable
    struct OraclePausableStorage {
        bool oraclePaused;
    }

    bytes32 private constant OraclePausableStorageLocation =
        0x50204cc2d5276a366b2f6a19361d0f388c29e773a6f6aa2c92cfb0dc04a5fe00;

    function _getOraclePausableStorage() private pure returns (OraclePausableStorage storage $) {
        assembly {
            $.slot := OraclePausableStorageLocation
        }
    }

    function oraclePaused() public view returns (bool) {
        OraclePausableStorage storage $ = _getOraclePausableStorage();
        return $.oraclePaused;
    }

    function _pauseOracle() internal {
        OraclePausableStorage storage $ = _getOraclePausableStorage();
        $.oraclePaused = true;
        emit OraclePaused();
    }

    function _unpauseOracle() internal {
        OraclePausableStorage storage $ = _getOraclePausableStorage();
        $.oraclePaused = false;
        emit OracleUnpaused();
    }
}
