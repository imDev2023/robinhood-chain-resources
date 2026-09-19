// SPDX-License-Identifier: MIT
pragma solidity ^0.8.36;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract LaunchToken is ERC20 {
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

    function contractURI() external view returns (string memory) {
        return metadataURI;
    }
}
