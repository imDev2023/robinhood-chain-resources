// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/interfaces/IERC1271.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract StonkBroker6551Account is IERC1271 {
    using ECDSA for bytes32;
    using SafeERC20 for IERC20;
    uint256 public chainId;
    address public tokenContract;
    uint256 public tokenId;
    bool private initialized;

    modifier onlyOwner() {
        require(owner() == msg.sender, "not token owner");
        _;
    }

    function initialize(uint256 chainId_, address tokenContract_, uint256 tokenId_) external {
        require(!initialized, "already initialized");
        require(tokenContract_ != address(0), "token contract=0");
        initialized = true;
        chainId = chainId_;
        tokenContract = tokenContract_;
        tokenId = tokenId_;
    }

    function owner() public view returns (address) {
        if (block.chainid != chainId || tokenContract == address(0)) {
            return address(0);
        }
        return IERC721(tokenContract).ownerOf(tokenId);
    }

    function executeCall(address to, uint256 value, bytes calldata data) external payable onlyOwner returns (bytes memory) {
        (bool success, bytes memory result) = to.call{value: value}(data);
        require(success, "call failed");
        return result;
    }

    function executeTokenTransfer(address token, address to, uint256 amount) external onlyOwner {
        IERC20(token).safeTransfer(to, amount);
    }

    function isValidSignature(bytes32 hash, bytes memory signature) external view override returns (bytes4) {
        (address signer, ECDSA.RecoverError err, ) = ECDSA.tryRecover(hash, signature);
        bool isValid = err == ECDSA.RecoverError.NoError && signer != address(0) && signer == owner();
        return isValid ? IERC1271.isValidSignature.selector : bytes4(0xffffffff);
    }

    receive() external payable {}
}
