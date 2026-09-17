// SPDX-License-Identifier: BUSL-1.1
// Copyright (c) 2026 long.xyz. All rights reserved.
pragma solidity ^0.8.26;

import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "v4-core/src/types/PoolId.sol";

import {IDopplerHookInitializer} from "../interfaces/IDopplerHookInitializer.sol";
import {LongFeeVault} from "./LongFeeVault.sol";

/// @title LongFeeVaultFactory
/// @author @natan_benish
/// @notice One-call, ownerless, permissionless deployer of per-asset {LongFeeVault}s.
/// Deployed once via CREATE2 (salt keccak256("long.fee-vault.v1") through the canonical
/// deterministic-deployment proxy) by whichever creator goes first — the factory holds
/// no admin rights, takes no LONG involvement, and records nothing mutable.
/// @dev Activation is a deliberate SECOND transaction by the creator:
/// `initializer.updateBeneficiary(poolId, vault)` moves the CALLER's slot, so only the
/// current fee receiver can flip it — the factory cannot. That call has no access
/// control and made from the wrong wallet it is a silent no-op that still emits
/// UpdateBeneficiary, so integrators MUST verify {isActivated} afterwards instead of
/// trusting the event. Once activated, the vault is operated by the LONG ops ADMIN
/// hardcoded in {LongFeeVault} (see its trust-model natspec).
contract LongFeeVaultFactory {
    using PoolIdLibrary for PoolKey;

    /// @notice The two supported creator/vault economics a deployer may choose. The
    /// factory maps them to exact initial split tables; the vault ADMIN can retune
    /// later, but deploys are restricted to these presets.
    /// - TwentyEighty: creator 20% / vault 80% — asset side 20/40/40 (creator/vault/burn),
    ///   numeraire side 20/80.
    /// - FiftyFifty: creator 50% / vault 50% — the non-creator half keeps the same 1:1
    ///   vault:burn ratio, so asset side 50/25/25, numeraire side 50/50.
    enum SplitMode {
        TwentyEighty,
        FiftyFifty
    }

    struct VaultDeployment {
        address vault;
        address originalReceiver;
        bytes32 poolId;
        uint48 deployedAt;
    }

    /// @dev Caller must hold a strict MAJORITY of beneficiary shares (WAD) to deploy.
    /// The standard creator slot is 0.95e18; the 0.05e18 protocol slot can neither
    /// deploy a vault nor overwrite an inert one and bind itself as originalReceiver.
    uint256 public constant MIN_DEPLOY_SHARES = 0.5e18;

    IDopplerHookInitializer public immutable INITIALIZER;

    mapping(address asset => VaultDeployment) private _deployments;

    error ZeroAddress();
    error PoolNotInitialized(address asset);
    error NotBeneficiary(address caller);
    error AlreadyDeployed(address asset);

    event VaultDeployed(
        address indexed asset, bytes32 indexed poolId, address vault, address originalReceiver, SplitMode mode
    );

    constructor(address initializer_) {
        if (initializer_ == address(0)) revert ZeroAddress();
        INITIALIZER = IDopplerHookInitializer(initializer_);
    }

    /// @notice Deploys the asset's fee vault with one of the two supported split modes
    /// and records it. Does NOT move the fee-beneficiary slot — see the activation note
    /// above. (An out-of-range mode value fails ABI decoding and reverts.)
    function deployVault(address asset, SplitMode mode) external returns (address vault) {
        (,,,, uint8 status, PoolKey memory key,) = INITIALIZER.getState(asset);
        if (status == 0) revert PoolNotInitialized(asset);
        bytes32 poolId = PoolId.unwrap(key.toId());

        if (INITIALIZER.getShares(poolId, msg.sender) <= MIN_DEPLOY_SHARES) revert NotBeneficiary(msg.sender);

        // A never-activated vault is inert (holds no slot, no funds) and may be
        // replaced — this lets a creator who rotated wallets re-deploy (or switch
        // modes). Once the vault holds shares it is canonical. After an admin migration
        // away, the asset reads deactivated again and a fresh vault may be deployed.
        VaultDeployment storage prior = _deployments[asset];
        if (prior.vault != address(0) && INITIALIZER.getShares(poolId, prior.vault) != 0) {
            revert AlreadyDeployed(asset);
        }

        (LongFeeVault.Split memory assetSplit, LongFeeVault.Split memory numeraireSplit) = _splitsFor(mode);
        vault = address(new LongFeeVault(address(INITIALIZER), asset, msg.sender, assetSplit, numeraireSplit));

        _deployments[asset] = VaultDeployment({
            vault: vault,
            originalReceiver: msg.sender,
            poolId: poolId,
            deployedAt: uint48(block.timestamp)
        });

        emit VaultDeployed(asset, poolId, vault, msg.sender, mode);
    }

    /// @notice The exact initial split tables for a mode (also handy for UIs).
    function splitsFor(SplitMode mode)
        external
        pure
        returns (LongFeeVault.Split memory assetSplit, LongFeeVault.Split memory numeraireSplit)
    {
        return _splitsFor(mode);
    }

    function _splitsFor(SplitMode mode)
        internal
        pure
        returns (LongFeeVault.Split memory assetSplit, LongFeeVault.Split memory numeraireSplit)
    {
        if (mode == SplitMode.TwentyEighty) {
            return (
                LongFeeVault.Split({creatorBps: 2000, vaultBps: 4000, burnBps: 4000}),
                LongFeeVault.Split({creatorBps: 2000, vaultBps: 8000, burnBps: 0})
            );
        }
        return (
            LongFeeVault.Split({creatorBps: 5000, vaultBps: 2500, burnBps: 2500}),
            LongFeeVault.Split({creatorBps: 5000, vaultBps: 5000, burnBps: 0})
        );
    }

    function getDeployment(address asset) external view returns (VaultDeployment memory) {
        return _deployments[asset];
    }

    /// @notice True once the recorded vault actually holds the beneficiary slot (a LIVE
    /// getShares read — activation and migration flip it atomically).
    function isActivated(address asset) public view returns (bool) {
        VaultDeployment storage deployment = _deployments[asset];
        if (deployment.vault == address(0)) return false;
        return INITIALIZER.getShares(deployment.poolId, deployment.vault) != 0;
    }
}
