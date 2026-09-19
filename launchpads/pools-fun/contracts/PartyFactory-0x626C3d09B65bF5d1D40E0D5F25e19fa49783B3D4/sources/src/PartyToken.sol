// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title PartyToken
/// @notice Minimal fixed-supply ERC20 launched by PartyFactory via CREATE2.
/// @dev No owner, no mint, no transfer hooks. The full supply is minted once to
///      `recipient` (the factory) in the constructor. The caller-bound CREATE2
///      salt is mined off-chain so this token sorts below the paired asset (token0).
contract PartyToken is ERC20 {
    /// @notice IPFS (or https) URI of the token's metadata JSON.
    string public metadataUri;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 supply_,
        address recipient_,
        string memory metadataUri_
    ) ERC20(name_, symbol_) {
        metadataUri = metadataUri_;
        _mint(recipient_, supply_);
    }

    /// @notice Alias for `metadataUri`, mirroring the ERC721 tokenURI convention.
    function tokenURI() external view returns (string memory) {
        return metadataUri;
    }
}
