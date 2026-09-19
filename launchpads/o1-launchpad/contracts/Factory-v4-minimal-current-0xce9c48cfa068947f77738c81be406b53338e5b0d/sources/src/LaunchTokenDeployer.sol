// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {LaunchToken} from "./LaunchToken.sol";

interface ILaunchTokenFactory {
    function tokenDeployer() external view returns (address);
}

/// @title LaunchTokenDeployer
/// @notice One-purpose CREATE2 deployer for ERC20 launch tokens. It keeps token creation bytecode out of the
///         ERC20 launchpad factory while preserving deterministic token addresses and genesis metadata.
contract LaunchTokenDeployer {
    address public immutable factoryInitializer;
    address public factory;

    error AlreadyInitialized();
    error InvalidConfig();
    error TokenAlreadyExists(address token);
    error Unauthorized();

    constructor(address factoryInitializerAddress) {
        if (factoryInitializerAddress == address(0)) revert InvalidConfig();
        factoryInitializer = factoryInitializerAddress;
    }

    function initializeFactory(address factoryAddress) external {
        if (msg.sender != factoryInitializer) revert Unauthorized();
        if (factory != address(0)) revert AlreadyInitialized();
        if (factoryAddress == address(0) || factoryAddress.code.length == 0) revert InvalidConfig();
        if (ILaunchTokenFactory(factoryAddress).tokenDeployer() != address(this)) revert InvalidConfig();
        factory = factoryAddress;
    }

    function predictTokenAddress(bytes32 scopedSalt, LaunchToken.GenesisParams calldata genesisParams)
        external
        view
        returns (address predictedToken)
    {
        return _predictTokenAddress(scopedSalt, genesisParams);
    }

    function tokenBytecodeHash(LaunchToken.GenesisParams calldata genesisParams)
        external
        pure
        returns (bytes32 bytecodeHash)
    {
        return _tokenBytecodeHash(genesisParams);
    }

    function deploy(bytes32 scopedSalt, LaunchToken.GenesisParams calldata genesisParams)
        external
        returns (address token)
    {
        address factoryAddress = factory;
        if (msg.sender != factoryAddress) revert Unauthorized();
        if (genesisParams.factory != factoryAddress) revert InvalidConfig();
        token = _predictTokenAddress(scopedSalt, genesisParams);
        if (token.code.length != 0) revert TokenAlreadyExists(token);
        return address(new LaunchToken{salt: scopedSalt}(genesisParams));
    }

    function _predictTokenAddress(bytes32 scopedSalt, LaunchToken.GenesisParams calldata genesisParams)
        internal
        view
        returns (address predictedToken)
    {
        bytes32 bytecodeHash = _tokenBytecodeHash(genesisParams);
        return
            address(
                uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), address(this), scopedSalt, bytecodeHash))))
            );
    }

    function _tokenBytecodeHash(LaunchToken.GenesisParams calldata genesisParams)
        internal
        pure
        returns (bytes32 bytecodeHash)
    {
        return keccak256(abi.encodePacked(type(LaunchToken).creationCode, abi.encode(genesisParams)));
    }
}
