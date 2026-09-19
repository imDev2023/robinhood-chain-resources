// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";

import {LaunchHook} from "./LaunchHook.sol";
import {LaunchToken} from "./LaunchToken.sol";
import {LaunchTokenDeployer} from "./LaunchTokenDeployer.sol";
import {LaunchpadFactoryCore} from "./LaunchpadFactoryCore.sol";

/// @title ERC20LaunchpadFactory
/// @notice Non-Base launchpad factory that deploys immutable fixed-supply ERC20 launch tokens with CREATE2,
///         then reuses the shared Uniswap v4 single-sided locked-liquidity launch flow.
abstract contract ERC20LaunchpadFactory is LaunchpadFactoryCore {
    LaunchTokenDeployer public immutable tokenDeployer;

    constructor(
        IPoolManager poolManagerAddress,
        LaunchHook launchHook,
        LaunchTokenDeployer launchTokenDeployer,
        FactoryInitialization memory initialFactoryConfiguration
    ) LaunchpadFactoryCore(poolManagerAddress, launchHook, initialFactoryConfiguration) {
        if (
            address(launchTokenDeployer) == address(0) || address(launchTokenDeployer).code.length == 0
                || launchTokenDeployer.factory() != address(0)
        ) revert InvalidConfig();
        tokenDeployer = launchTokenDeployer;
    }

    function _beforeCreateLaunch(LaunchParams calldata) internal view virtual override {}

    function _predictTokenAddress(LaunchParams calldata launchParams, bytes32 scopedSalt, uint256 currentLaunchSupply)
        internal
        view
        override
        returns (address)
    {
        return tokenDeployer.predictTokenAddress(scopedSalt, _tokenParams(launchParams, currentLaunchSupply));
    }

    function _createToken(LaunchParams calldata launchParams, bytes32 scopedSalt, uint256 currentLaunchSupply)
        internal
        override
        returns (address)
    {
        return tokenDeployer.deploy(scopedSalt, _tokenParams(launchParams, currentLaunchSupply));
    }

    function _assertLaunchToken(address token, address creatorAccount, bool metadataEditable) internal view override {
        LaunchToken t = LaunchToken(token);
        if (
            t.factory() != address(this) || t.totalSupply() != launchSupply || t.supplyCap() != launchSupply
                || t.decimals() != 18
        ) {
            revert NotImmutable();
        }
        if (t.hasRole(t.DEFAULT_ADMIN_ROLE(), creatorAccount)) revert NotImmutable();
        bool hasMetadata = t.hasRole(t.METADATA_ROLE(), address(this));
        address expectedMetadataAuthority = metadataEditable ? address(this) : address(0);
        if (t.metadataAuthority() != expectedMetadataAuthority || metadataEditable != hasMetadata) {
            revert NotImmutable();
        }
    }

    function _tokenParams(LaunchParams calldata launchParams, uint256 currentLaunchSupply)
        internal
        view
        returns (LaunchToken.GenesisParams memory)
    {
        return LaunchToken.GenesisParams({
            factory: address(this),
            tokenName: launchParams.tokenName,
            tokenSymbol: launchParams.tokenSymbol,
            tokenContractURI: launchParams.tokenContractURI,
            metadataAuthority: launchParams.metadataEditable ? address(this) : address(0),
            initialRecipient: address(hook),
            initialSupply: currentLaunchSupply,
            metadataKeys: launchParams.metadataKeys,
            metadataValues: launchParams.metadataValues
        });
    }
}
