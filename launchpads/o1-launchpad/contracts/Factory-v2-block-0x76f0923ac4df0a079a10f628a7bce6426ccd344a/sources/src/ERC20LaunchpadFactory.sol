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
contract ERC20LaunchpadFactory is LaunchpadFactoryCore {
    LaunchTokenDeployer public immutable tokenDeployer;

    constructor(IPoolManager _poolManager, LaunchHook _hook, LaunchTokenDeployer _tokenDeployer, InitConfig memory cfg)
        LaunchpadFactoryCore(_poolManager, _hook, cfg)
    {
        if (address(_tokenDeployer) == address(0) || _tokenDeployer.factory() != address(0)) revert InvalidConfig();
        tokenDeployer = _tokenDeployer;
    }

    function _beforeCreateLaunch(LaunchParams calldata) internal view override {}

    function _predictTokenAddress(
        LaunchParams calldata p,
        bytes32 salt,
        uint256,
        uint256 poolSupply,
        address creator,
        uint256 vestedTotal
    ) internal view override returns (address) {
        (address[] memory recips, uint256[] memory amts) = _genesisMints(p, poolSupply, vestedTotal);
        return tokenDeployer.predictTokenAddress(salt, _tokenParams(p, creator, recips, amts));
    }

    function _createToken(
        LaunchParams calldata p,
        bytes32 salt,
        uint256,
        uint256 poolSupply,
        address creator,
        uint256 vestedTotal
    ) internal override returns (address) {
        (address[] memory recips, uint256[] memory amts) = _genesisMints(p, poolSupply, vestedTotal);
        return tokenDeployer.deploy(salt, _tokenParams(p, creator, recips, amts));
    }

    function _assertLaunchToken(address token, address creator, uint8 roleMode) internal view override {
        LaunchToken t = LaunchToken(token);
        if (
            t.factory() != address(this) || t.totalSupply() != launchSupply || t.supplyCap() != launchSupply
                || t.decimals() != 18
        ) {
            revert NotImmutable();
        }
        if (t.hasRole(t.DEFAULT_ADMIN_ROLE(), creator)) revert NotImmutable();
        bool hasMetadata = t.hasRole(t.METADATA_ROLE(), creator);
        address expectedMetadataAuthority = roleMode == 1 ? creator : address(0);
        if (
            t.metadataAuthority() != expectedMetadataAuthority || (roleMode == 1 && !hasMetadata)
                || (roleMode == 0 && hasMetadata)
        ) {
            revert NotImmutable();
        }
    }

    function _tokenParams(
        LaunchParams calldata p,
        address creator,
        address[] memory recipients,
        uint256[] memory amounts
    ) internal view returns (LaunchToken.GenesisParams memory) {
        return LaunchToken.GenesisParams({
            factory: address(this),
            name: p.name,
            symbol: p.symbol,
            contractURI: p.contractURI,
            metadataAuthority: p.roleMode == 1 ? creator : address(0),
            recipients: recipients,
            amounts: amounts,
            metadataKeys: p.metadataKeys,
            metadataValues: p.metadataValues
        });
    }

    function _genesisMints(LaunchParams calldata p, uint256 poolSupply, uint256 vestedTotal)
        internal
        view
        returns (address[] memory recips, uint256[] memory amts)
    {
        uint256 nImm = p.allocationRecipients.length;
        uint256 extra = vestedTotal > 0 ? 1 : 0;
        uint256 n = nImm + extra + 1;
        recips = new address[](n);
        amts = new uint256[](n);

        for (uint256 i = 0; i < nImm; i++) {
            recips[i] = p.allocationRecipients[i];
            amts[i] = p.allocationAmounts[i];
        }
        uint256 cursor = nImm;
        if (extra == 1) {
            recips[cursor] = vestingVault;
            amts[cursor] = vestedTotal;
            cursor++;
        }
        recips[cursor] = address(hook);
        amts[cursor] = poolSupply;
    }
}
