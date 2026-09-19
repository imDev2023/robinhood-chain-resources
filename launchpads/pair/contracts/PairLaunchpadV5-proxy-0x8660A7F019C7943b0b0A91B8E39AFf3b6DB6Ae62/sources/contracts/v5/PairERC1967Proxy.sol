// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {ERC1967Proxy as OpenZeppelinERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

/// @notice Artifact wrapper used by deterministic deployment tooling.
contract PairERC1967Proxy is OpenZeppelinERC1967Proxy {
    constructor(address implementation, bytes memory data)
        OpenZeppelinERC1967Proxy(implementation, data) {}
}