// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @notice ERC721 representing a long call option position.
/// Minting/burning is controlled by the covered-call vault.
contract StonkOptionPositionNFT is ERC721, Ownable {
    uint256 public nextId = 1;

    struct Position {
        address vault;
        address writer;
        address underlying;
        address quote;
        address pool;
        uint32 twapSeconds;
        int24 strikeTick;
        uint256 underlyingAmount;
        uint256 strikeQuoteAmount;
        uint256 premiumQuoteAmount;
        uint256 expiry;
        bool exercised;
    }

    mapping(uint256 => Position) public positions;

    event PositionMinted(uint256 indexed tokenId, address indexed vault, address indexed buyer);
    event PositionExercised(uint256 indexed tokenId);

    constructor(address initialOwner) ERC721("Stonk Options", "STONK-OPT") Ownable(initialOwner) {}

    function mint(
        address to,
        Position calldata p
    ) external onlyOwner returns (uint256 tokenId) {
        require(p.vault != address(0), "vault=0");
        require(to != address(0), "to=0");
        tokenId = nextId++;
        positions[tokenId] = p;
        _safeMint(to, tokenId);
        emit PositionMinted(tokenId, p.vault, to);
    }

    function markExercised(uint256 tokenId) external onlyOwner {
        Position storage p = positions[tokenId];
        require(_ownerOf(tokenId) != address(0), "no token");
        require(!p.exercised, "already");
        p.exercised = true;
        emit PositionExercised(tokenId);
    }
}

