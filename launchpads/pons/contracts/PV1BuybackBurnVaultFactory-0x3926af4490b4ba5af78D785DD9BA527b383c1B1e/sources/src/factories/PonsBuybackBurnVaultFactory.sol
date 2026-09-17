// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {BeaconProxy} from "@openzeppelin/proxy/beacon/BeaconProxy.sol";
import {UpgradeableBeacon} from "@openzeppelin/proxy/beacon/UpgradeableBeacon.sol";
import {Ownable2Step} from "@openzeppelin/access/Ownable2Step.sol";

import {IPonsVaultFactory} from "../interfaces/IPonsVaultFactory.sol";
import {PonsBuybackBurnVault} from "../vaults/PonsBuybackBurnVault.sol";

/// @title PonsBuybackBurnVaultFactory
/// @notice Deploys one {PonsBuybackBurnVault} per pons token, behind a shared upgradeable beacon.
///
/// @dev The beacon pattern is deliberate: it lets vaults ship before an audit completes and be
///      patched afterwards without asking any token creator to migrate. {lockUpgrades} exists so
///      the ability to patch can be renounced permanently once the design has settled, which is
///      the credible-immutability endgame.
contract PonsBuybackBurnVaultFactory is Ownable2Step, IPonsVaultFactory {
    error VaultAlreadyExists(address token, address vault);
    error NotTokenDeployer(address caller, address deployer);

    event VaultCreated(address indexed token, address indexed vault, address indexed creator);
    event UpgradesLocked();

    /// @notice Beacon all deployed vaults delegate to.
    address public immutable beacon;

    /// @notice Vault deployed for a given pons token, if any.
    mapping(address token => address vault) public vaultOf;

    /// @notice Every vault this factory has deployed, in creation order.
    address[] public vaults;

    constructor() Ownable2Step() {
        PonsBuybackBurnVault impl = new PonsBuybackBurnVault();
        beacon = address(new UpgradeableBeacon(address(impl)));
    }

    /// @inheritdoc IPonsVaultFactory
    /// @dev `config` is an ABI-encoded {PonsBuybackBurnVault.Config}. Decoding here rather than
    ///      taking it typed is what lets the launcher stay ignorant of this template; a wrong
    ///      shape reverts in `abi.decode`, and wrong values revert in the vault's own validation.
    function createVault(address token, address locker, bytes calldata config)
        external
        returns (address vault)
    {
        address existing = vaultOf[token];
        if (existing != address(0)) revert VaultAlreadyExists(token, existing);

        address deployer = _tokenDeployer(token);
        if (msg.sender != deployer) revert NotTokenDeployer(msg.sender, deployer);

        PonsBuybackBurnVault.Config memory decoded = abi.decode(config, (PonsBuybackBurnVault.Config));

        vault = address(
            new BeaconProxy(
                beacon, abi.encodeCall(PonsBuybackBurnVault.initialize, (token, locker, msg.sender, decoded))
            )
        );

        vaultOf[token] = vault;
        vaults.push(vault);

        emit VaultCreated(token, vault, msg.sender);
    }

    /// @inheritdoc IPonsVaultFactory
    function template() external pure returns (string memory) {
        return "buyback-burn";
    }

    /// @notice Number of vaults deployed by this factory.
    function vaultCount() external view returns (uint256) {
        return vaults.length;
    }

    /// @notice Point every deployed vault at a new implementation.
    function upgradeVaultImplementation(address newImplementation) external onlyOwner {
        UpgradeableBeacon(beacon).upgradeTo(newImplementation);
    }

    /// @notice Permanently give up the ability to upgrade deployed vaults. Irreversible.
    function lockUpgrades() external onlyOwner {
        UpgradeableBeacon(beacon).renounceOwnership();
        emit UpgradesLocked();
    }

    /// @notice Whether {lockUpgrades} has been called.
    function isUpgradesLocked() external view returns (bool) {
        return UpgradeableBeacon(beacon).owner() == address(0);
    }

    /// @notice Current vault implementation behind the beacon.
    function implementation() external view returns (address) {
        return UpgradeableBeacon(beacon).implementation();
    }

    function _tokenDeployer(address token) private view returns (address deployer) {
        (bool ok, bytes memory data) = token.staticcall(abi.encodeWithSignature("deployer()"));
        if (!ok || data.length < 32) return address(0);
        deployer = abi.decode(data, (address));
    }
}
