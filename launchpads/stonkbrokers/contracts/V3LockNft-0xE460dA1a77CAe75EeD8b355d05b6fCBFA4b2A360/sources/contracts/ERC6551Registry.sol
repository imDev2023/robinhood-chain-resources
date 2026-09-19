// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/proxy/Clones.sol";

interface IERC6551InitializableAccount {
    function initialize(uint256 chainId, address tokenContract, uint256 tokenId) external;
}

contract ERC6551Registry {
    event AccountCreated(
        address indexed account,
        address indexed implementation,
        bytes32 indexed salt,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId
    );

    function createAccount(
        address implementation,
        bytes32 salt,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId
    ) external returns (address createdAccount) {
        bytes32 finalSalt = _accountSalt(salt, chainId, tokenContract, tokenId);
        createdAccount = Clones.predictDeterministicAddress(implementation, finalSalt, address(this));

        if (createdAccount.code.length == 0) {
            createdAccount = Clones.cloneDeterministic(implementation, finalSalt);
            IERC6551InitializableAccount(createdAccount).initialize(chainId, tokenContract, tokenId);
            emit AccountCreated(createdAccount, implementation, finalSalt, chainId, tokenContract, tokenId);
        }
    }

    function account(
        address implementation,
        bytes32 salt,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId
    ) external view returns (address) {
        bytes32 finalSalt = _accountSalt(salt, chainId, tokenContract, tokenId);
        return Clones.predictDeterministicAddress(implementation, finalSalt, address(this));
    }

    function _accountSalt(
        bytes32 salt,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId
    ) internal pure returns (bytes32) {
        return keccak256(abi.encode(salt, chainId, tokenContract, tokenId));
    }
}
