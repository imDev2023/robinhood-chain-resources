// SPDX-License-Identifier: MIT
pragma solidity ^0.8.36;

import {MixpadToken} from "./MixpadToken.sol";

/// @notice Deployed once from MixpadFactory's constructor. Holds
/// type(MixpadToken).creationCode in its own runtime bytecode, keeping it out
/// of MixpadFactory's runtime and below EIP-170's 24,576-byte limit.
///
/// The factory calls creationCode() via staticcall to obtain initcode, then
/// runs CREATE2 itself (so address(this) == factory, matching predictTokenAddress).
/// codeHash() is a cheaper alternative for address prediction that avoids
/// returning the full ~7.7 KB initcode.
contract MixpadTokenDeployer {
    uint256 private constant SUPPLY = 1_000_000_000 ether;

    /// @notice Returns the full MixpadToken initcode for a given set of params.
    /// Called via staticcall from MixpadFactory._deployToken.
    function creationCode(
        string calldata name,
        string calldata symbol,
        string calldata metadataURI,
        string calldata image,
        string calldata description,
        MixpadToken.Socials calldata socials,
        address deployer_
    ) external pure returns (bytes memory) {
        return bytes.concat(
            type(MixpadToken).creationCode,
            abi.encode(name, symbol, metadataURI, image, description, socials, deployer_, SUPPLY)
        );
    }

    /// @notice Returns keccak256(initcode) for CREATE2 address prediction.
    /// Called via staticcall from MixpadFactory.predictTokenAddress.
    /// Returning bytes32 avoids sending the full ~7.7 KB initcode over the wire.
    function codeHash(
        string calldata name,
        string calldata symbol,
        string calldata metadataURI,
        string calldata image,
        string calldata description,
        MixpadToken.Socials calldata socials,
        address deployer_
    ) external pure returns (bytes32) {
        return keccak256(bytes.concat(
            type(MixpadToken).creationCode,
            abi.encode(name, symbol, metadataURI, image, description, socials, deployer_, SUPPLY)
        ));
    }
}
