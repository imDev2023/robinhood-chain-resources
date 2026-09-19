// SPDX-License-Identifier: MIT
pragma solidity ^0.8.36;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @notice Fixed-supply ERC-20 deployed by MixpadFactory for every launch.
/// Full supply is minted once to the factory at construction and immediately
/// committed to a Uniswap V4 position; no further minting or burning path
/// exists, no owner exists, and no transfer restriction is ever applied.
///
/// Social links are stored on-chain and set once at construction so any
/// indexer, scanner, or wallet can read them directly from the token
/// contract (token.twitter(), token.website(), ...) with no dependency on
/// an off-chain host. They are immutable after deploy: a compromised or
/// abandoned off-chain backend can never be used to swap in a phishing link
/// post-launch. metadataURI remains available for extended, non-critical
/// metadata that benefits from a flexible JSON schema.
contract MixpadToken is ERC20 {
    uint8 public constant VERSION = 1;

    struct Socials {
        string twitter;
        string telegram;
        string discord;
        string website;
        string tiktok;
    }

    address public immutable deployer;
    address public immutable factory;

    string public metadataURI;
    string public image;
    string public description;

    string public twitter;
    string public telegram;
    string public discord;
    string public website;
    string public tiktok;

    constructor(
        string memory name_,
        string memory symbol_,
        string memory metadataURI_,
        string memory image_,
        string memory description_,
        Socials memory socials_,
        address deployer_,
        uint256 supply_
    ) ERC20(name_, symbol_) {
        deployer = deployer_;
        factory = msg.sender;

        metadataURI = metadataURI_;
        image = image_;
        description = description_;

        twitter = socials_.twitter;
        telegram = socials_.telegram;
        discord = socials_.discord;
        website = socials_.website;
        tiktok = socials_.tiktok;

        _mint(msg.sender, supply_);
    }

    /// @notice EIP-7572 on-chain metadata pointer.
    function contractURI() external view returns (string memory) {
        return metadataURI;
    }
}
