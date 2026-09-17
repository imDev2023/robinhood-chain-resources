// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {PonsLauncherToken} from "../PonsLauncherToken.sol";

/**
 * @title PonsLauncherTokenCode
 * @notice Serves the PonsLauncherToken creation bytecode from a standalone
 * deployed library so the factory runtime stays under the EIP-170 size limit.
 * External library calls delegatecall into this code, so CREATE2 deployments
 * still originate from the factory address.
 */
library PonsLauncherTokenCode {
    function creationCode() external pure returns (bytes memory) {
        return type(PonsLauncherToken).creationCode;
    }
}
