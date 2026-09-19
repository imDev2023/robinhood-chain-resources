// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {LaunchToken} from "./LaunchToken.sol";

/// @title LaunchTokenDeployer
/// @notice One-purpose CREATE2 deployer for ERC20 launch tokens. It keeps token creation bytecode out of the
///         ERC20 launchpad factory while preserving deterministic token addresses and genesis metadata.
contract LaunchTokenDeployer {
    address public immutable owner;
    address public factory;

    error AlreadyInitialized();
    error InvalidConfig();
    error TokenAlreadyExists(address token);
    error Unauthorized();

    constructor(address owner_) {
        if (owner_ == address(0)) revert InvalidConfig();
        owner = owner_;
    }

    function initializeFactory(address factory_) external {
        if (msg.sender != owner) revert Unauthorized();
        if (factory != address(0)) revert AlreadyInitialized();
        if (factory_ == address(0)) revert InvalidConfig();
        factory = factory_;
    }

    function predictTokenAddress(bytes32 salt, LaunchToken.GenesisParams calldata p) external view returns (address) {
        return _predictTokenAddress(salt, p);
    }

    function deploy(bytes32 salt, LaunchToken.GenesisParams calldata p) external returns (address token) {
        address factory_ = factory;
        if (msg.sender != factory_) revert Unauthorized();
        if (p.factory != factory_) revert InvalidConfig();
        token = _predictTokenAddress(salt, p);
        if (token.code.length != 0) revert TokenAlreadyExists(token);
        return address(new LaunchToken{salt: salt}(p));
    }

    function _predictTokenAddress(bytes32 salt, LaunchToken.GenesisParams calldata p) internal view returns (address) {
        bytes32 bytecodeHash = _tokenBytecodeHash(p);
        return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), address(this), salt, bytecodeHash)))));
    }

    function _tokenBytecodeHash(LaunchToken.GenesisParams calldata p) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(type(LaunchToken).creationCode, abi.encode(p)));
    }
}
