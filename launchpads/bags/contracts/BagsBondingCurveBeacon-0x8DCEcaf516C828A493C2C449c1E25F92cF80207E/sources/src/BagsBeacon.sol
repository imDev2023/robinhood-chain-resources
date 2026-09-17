// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.26;

// OpenZeppelin
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {UpgradeableBeacon} from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";

/// @title BagsBeacon
/// @notice Two-step-ownable `UpgradeableBeacon` for the BondingCurve and FeeShare beacons.
/// @dev OZ's stock `UpgradeableBeacon` is single-step `Ownable`, but the beacon owner holds the
///      upgrade rights for EVERY live launch's curve/fee share at once — the same blast radius as
///      the UUPS singletons. This wrapper adds `Ownable2Step` so beacon upgrade rights get the same
///      fat-finger protection as the factory and vault (`transferOwnership` + `acceptOwnership`).
///
///      Both bases share the same OZ `Ownable`, so `transferOwnership`/`_transferOwnership` are
///      overridden to dispatch to the two-step (`Ownable2Step`) behavior via `super`.
/// @author Bags
contract BagsBeacon is UpgradeableBeacon, Ownable2Step {
    /// @notice Creates the beacon pointing at an initial implementation
    /// @param implementation_ Initial implementation the beacon resolves to
    /// @param initialOwner Owner allowed to upgrade the beacon (two-step transferable)
    constructor(
        address implementation_,
        address initialOwner
    ) UpgradeableBeacon(implementation_, initialOwner) {}

    /// @inheritdoc Ownable2Step
    function transferOwnership(
        address newOwner
    ) public virtual override(Ownable, Ownable2Step) onlyOwner {
        super.transferOwnership(newOwner);
    }

    /// @inheritdoc Ownable2Step
    function _transferOwnership(
        address newOwner
    ) internal virtual override(Ownable, Ownable2Step) {
        super._transferOwnership(newOwner);
    }
}
