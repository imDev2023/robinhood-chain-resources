// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { IERC1271 } from "@openzeppelin/contracts/interfaces/IERC1271.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/**
 * @title MockERC1271Wallet
 * @dev A mock smart contract wallet implementing EIP-1271 for testing purposes
 * @notice This contract simulates a smart contract wallet that can validate signatures
 * on behalf of itself, allowing testing of EIP-1271 signature verification.
 * @custom:security-contact smart-contract-security@paxos.com
 */
contract MockERC1271Wallet is IERC1271 {
    using ECDSA for bytes32;

    // EIP-1271 magic value to return on successful signature validation
    bytes4 private constant MAGICVALUE = 0x1626ba7e;

    // The owner of this wallet who can sign on behalf of the contract
    address public owner;

    // Mapping to track which signatures should be considered valid
    mapping(bytes32 => bool) public validSignatures;

    /**
     * @dev Constructor sets the owner of the wallet
     * @param _owner The address that can sign on behalf of this contract
     */
    constructor(address _owner) {
        owner = _owner;
    }

    /**
     * @notice EIP-1271 signature validation function
     * @dev Validates signatures by checking if they were signed by the owner
     * or if the signature hash has been pre-approved
     * @param hash The hash of the data that was signed
     * @param signature The signature bytes to validate
     * @return magicValue The EIP-1271 magic value if valid, otherwise 0xffffffff
     */
    function isValidSignature(
        bytes32 hash,
        bytes memory signature
    ) external view override returns (bytes4 magicValue) {
        // Check if this specific signature has been pre-approved
        if (validSignatures[keccak256(abi.encodePacked(hash, signature))]) {
            return MAGICVALUE;
        }

        // Try to recover the signer from the signature
        // Use tryRecover to handle malformed signatures gracefully
        (address recovered, ECDSA.RecoverError error) = hash.tryRecover(signature);

        // If recovery failed or signer doesn't match owner, signature is invalid
        if (error != ECDSA.RecoverError.NoError || recovered != owner) {
            return 0xffffffff;
        }

        // Valid signature
        return MAGICVALUE;
    }

    /**
     * @notice Pre-approve a signature for testing edge cases
     * @dev Allows testing scenarios where a signature is valid even if ECDSA recovery fails
     * @param hash The hash of the data
     * @param signature The signature to approve
     */
    function approveSignature(bytes32 hash, bytes memory signature) external {
        require(msg.sender == owner, "Only owner can approve signatures");
        validSignatures[keccak256(abi.encodePacked(hash, signature))] = true;
    }

    /**
     * @notice Revoke a pre-approved signature
     * @param hash The hash of the data
     * @param signature The signature to revoke
     */
    function revokeSignature(bytes32 hash, bytes memory signature) external {
        require(msg.sender == owner, "Only owner can revoke signatures");
        validSignatures[keccak256(abi.encodePacked(hash, signature))] = false;
    }

    /**
     * @notice Change the owner of the wallet
     * @dev Useful for testing owner changes
     * @param newOwner The new owner address
     */
    function changeOwner(address newOwner) external {
        require(msg.sender == owner, "Only owner can change owner");
        owner = newOwner;
    }

    /**
     * @notice Receive function to accept native ETH transfers
     */
    receive() external payable {}
}
