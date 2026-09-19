// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract BrokerWalletAccount {
    using SafeERC20 for IERC20;
    address public nftContract;
    uint256 public tokenId;
    bool private initialized;

    modifier onlyNftHolder() {
        require(nftContract != address(0), "not initialized");
        require(IERC721(nftContract).ownerOf(tokenId) == msg.sender, "not nft owner");
        _;
    }

    function initialize(address nftContract_, uint256 tokenId_) external {
        require(!initialized, "already initialized");
        require(nftContract_ != address(0), "nft=0");
        initialized = true;
        nftContract = nftContract_;
        tokenId = tokenId_;
    }

    function executeTokenTransfer(address token, address to, uint256 amount) external onlyNftHolder {
        IERC20(token).safeTransfer(to, amount);
    }

    function execute(address target, uint256 value, bytes calldata data) external onlyNftHolder returns (bytes memory) {
        (bool ok, bytes memory result) = target.call{value: value}(data);
        require(ok, "exec failed");
        return result;
    }

    receive() external payable {}
}
