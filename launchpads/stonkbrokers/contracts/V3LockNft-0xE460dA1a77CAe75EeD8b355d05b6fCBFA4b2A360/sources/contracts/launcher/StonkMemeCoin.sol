// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @notice Simple ERC20 for launcher-created meme coins.
/// Supply is minted once at creation; no further minting.
contract StonkMemeCoin is ERC20 {
    string public metadataURI; // IPFS/Arweave JSON pointer for UI

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupplyWei,
        address initialRecipient,
        string memory metadataURI_
    ) ERC20(name_, symbol_) {
        require(initialRecipient != address(0), "recipient=0");
        metadataURI = metadataURI_;
        _mint(initialRecipient, totalSupplyWei);
    }
}

