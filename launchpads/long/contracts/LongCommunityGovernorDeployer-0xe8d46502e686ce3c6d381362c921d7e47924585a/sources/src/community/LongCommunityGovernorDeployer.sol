// SPDX-License-Identifier: BUSL-1.1
// Copyright (c) 2026 long.xyz. All rights reserved.
pragma solidity ^0.8.26;

import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";
import {IVotes} from "@openzeppelin/contracts/governance/utils/IVotes.sol";

import {LongCommunityGovernor} from "./LongCommunityGovernor.sol";

/// @title LongCommunityGovernorDeployer
/// @author @natan_benish
/// @notice Stateless helper that carries the governor's ~20.5KB creation code so the
/// factory doesn't have to: embedding all three suite initcodes pushed the factory's
/// runtime to ~39KB, past the EIP-170 limit of 24,576 bytes (foundry tests don't
/// enforce it; real chains and `forge script --broadcast` do). Permissionless — a
/// direct call just yields an orphan governor wired to whatever args were passed.
contract LongCommunityGovernorDeployer {
    function deploy(IVotes token, TimelockController timelock) external returns (LongCommunityGovernor governor) {
        governor = new LongCommunityGovernor(token, timelock);
    }
}
