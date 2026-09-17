// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.26;

import {UpgradeableBeacon} from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

/// @title LongXBeacon — UpgradeableBeacon with two-step ownership transfer.
/// @notice The beacon owner is the single most consequential key in the stack
///         (it swaps the logic of EVERY vault), and OZ's UpgradeableBeacon
///         hardcodes single-step Ownable — one mistyped transferOwnership
///         would permanently strand upgrade power. This subclass routes
///         ownership transfers through Ownable2Step: `transferOwnership` only
///         nominates a pending owner, who must prove control by calling
///         `acceptOwnership` from the nominated address. The offer is
///         revocable until accepted (re-nominate, or nominate address(0) to
///         cancel).
contract LongXBeacon is UpgradeableBeacon, Ownable2Step {
    constructor(address implementation_, address initialOwner) UpgradeableBeacon(implementation_, initialOwner) {}

    function transferOwnership(address newOwner) public virtual override(Ownable, Ownable2Step) onlyOwner {
        super.transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual override(Ownable, Ownable2Step) {
        super._transferOwnership(newOwner);
    }
}
