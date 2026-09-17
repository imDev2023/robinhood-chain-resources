// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.26;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {BeaconProxy} from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ILighterBridge} from "../ILighterBridge.sol";
import {LongXVaultUpgradeable} from "./LongXVaultUpgradeable.sol";

/// @title LongXVaultFactory — deploys and registers beacon-proxy vaults.
/// @notice Every vault created here is a `BeaconProxy` pointing at the shared
///         beacon, so a single `UpgradeableBeacon.upgradeTo(newImpl)` (executed
///         by the beacon owner, not this factory) upgrades every vault
///         atomically. Initialization happens inside the proxy's constructor —
///         there is no uninitialized-proxy window to front-run.
///
/// @dev `createVault` is owner-gated because the registry is load-bearing for
///      operations: the verifier-upgrade script iterates `vaults` to assert the
///      freshness invariant before re-routing proofs, so strangers must not be
///      able to register junk vaults into that loop. The owner is the protocol
///      admin (multisig) — never the deployer key. The beacon is deliberately
///      NOT owned by the factory: vault-creation authority and vault-upgrade
///      authority stay separately revocable. Ownership transfers are two-step
///      (Ownable2Step): the nominee must accept before the role moves.
contract LongXVaultFactory is Ownable2Step {
    address public immutable beacon;
    address[] public vaults;

    event VaultCreated(address indexed vault, address indexed admin, string name, string symbol);

    error ZeroBeacon();

    constructor(address beacon_, address initialOwner) Ownable(initialOwner) {
        if (beacon_ == address(0)) revert ZeroBeacon();
        beacon = beacon_;
    }

    /// @notice Deploy a new vault proxy and atomically initialize it.
    /// @dev cfg.admin must be set explicitly — inside `initialize`, msg.sender
    ///      is this factory and the vault refuses a zero admin.
    function createVault(
        IERC20 usdg,
        ILighterBridge bridge,
        uint16 assetIndex,
        uint8 routeType,
        LongXVaultUpgradeable.VaultConfig memory cfg,
        string memory name,
        string memory symbol
    ) external onlyOwner returns (address vault) {
        vault = address(
            new BeaconProxy(
                beacon,
                abi.encodeCall(
                    LongXVaultUpgradeable.initialize, (usdg, bridge, assetIndex, routeType, cfg, name, symbol)
                )
            )
        );
        vaults.push(vault);
        emit VaultCreated(vault, cfg.admin, name, symbol);
    }

    function vaultCount() external view returns (uint256) {
        return vaults.length;
    }

    /// @notice The full registry in one call — operational scripts iterate this.
    function allVaults() external view returns (address[] memory) {
        return vaults;
    }
}
