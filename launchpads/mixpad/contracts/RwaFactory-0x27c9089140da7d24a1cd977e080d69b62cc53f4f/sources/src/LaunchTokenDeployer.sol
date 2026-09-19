// SPDX-License-Identifier: MIT
pragma solidity ^0.8.36;

import {LaunchToken} from "./LaunchToken.sol";

contract LaunchTokenDeployer {
    uint256 private constant SUPPLY = 1_000_000_000 ether;

    function creationCode(
        string calldata name,
        string calldata symbol,
        string calldata metadataURI,
        string calldata image,
        string calldata description,
        LaunchToken.Socials calldata socials,
        address deployer_
    ) external pure returns (bytes memory) {
        return bytes.concat(
            type(LaunchToken).creationCode,
            abi.encode(name, symbol, metadataURI, image, description, socials, deployer_, SUPPLY)
        );
    }

    function codeHash(
        string calldata name,
        string calldata symbol,
        string calldata metadataURI,
        string calldata image,
        string calldata description,
        LaunchToken.Socials calldata socials,
        address deployer_
    ) external pure returns (bytes32) {
        return keccak256(bytes.concat(
            type(LaunchToken).creationCode,
            abi.encode(name, symbol, metadataURI, image, description, socials, deployer_, SUPPLY)
        ));
    }
}
