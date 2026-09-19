// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/// @notice Transferable ownership receipt NFT for liquidity lock positions.
/// The locker contract is the only authorized minter/burner.
contract StonkLockerOwnershipNFT is ERC721, Ownable {
    address public locker;
    uint256 private _nextTokenId = 1;

    error NotLocker();
    error LockerAlreadySet();
    error LockerZero();

    event LockerSet(address indexed locker);

    constructor(address initialOwner) ERC721("Stonk Locker Position", "SLP") Ownable(initialOwner) {}

    function setLocker(address newLocker) external onlyOwner {
        if (locker != address(0)) revert LockerAlreadySet();
        if (newLocker == address(0)) revert LockerZero();
        locker = newLocker;
        emit LockerSet(newLocker);
    }

    function mint(address to) external returns (uint256 tokenId) {
        if (msg.sender != locker) revert NotLocker();
        tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
    }

    function burn(uint256 tokenId) external {
        if (msg.sender != locker) revert NotLocker();
        _burn(tokenId);
    }
}

