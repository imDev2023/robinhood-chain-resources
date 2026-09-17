// SPDX-License-Identifier: BUSL-1.1
// Copyright (c) 2026 long.xyz. All rights reserved.
pragma solidity ^0.8.26;

import {Governor} from "@openzeppelin/contracts/governance/Governor.sol";
import {GovernorSettings} from "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
import {GovernorCountingSimple} from "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import {GovernorVotes} from "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import {GovernorVotesQuorumFraction} from
    "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import {GovernorPreventLateQuorum} from "@openzeppelin/contracts/governance/extensions/GovernorPreventLateQuorum.sol";
import {GovernorTimelockControl} from "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";
import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";
import {IVotes} from "@openzeppelin/contracts/governance/utils/IVotes.sol";

/// @dev The launched DERC20's votes implementation is SOLADY ERC20Votes, which does NOT
/// expose OZ's `getPastTotalSupply` — its equivalent is `getPastVotesTotalSupply`.
/// Calling the OZ name reverts (missing selector), which would brick every quorum check.
interface ISoladyVotesTotalSupply {
    function getPastVotesTotalSupply(uint256 timepoint) external view returns (uint256);
}

/// @title LongCommunityGovernor
/// @author @natan_benish
/// @notice Community-mode governor over a launched DERC20 (already ERC20Votes, solady
/// implementation). Stock OpenZeppelin v5 modules only — no custom counting logic.
/// @dev CLOCK: the DERC20 clock is `mode=blocknumber`, and on Robinhood Chain the in-EVM
/// `block.number` is the ETHEREUM L1 block number (~12s cadence, ~7_200/day) — NOT the
/// ~0.1s L2 block height that `eth_blockNumber` reports (verified live: AI clock() ≈
/// 25.6M = L1 height while the RPC head was ≈ 20.7M). Every governor timepoint below is
/// therefore an L1-paced block count, while the timelock's execution delay is wall-clock
/// seconds. Voting power snapshots at voting start: buying after a proposal is created
/// adds zero weight. All parameters are tunable later through governance via the
/// inherited onlyGovernance setters (setVotingDelay(uint48), setVotingPeriod(uint32),
/// setProposalThreshold(uint256), updateQuorumNumerator(uint256),
/// setLateQuorumVoteExtension(uint48)).
contract LongCommunityGovernor is
    Governor,
    GovernorSettings,
    GovernorCountingSimple,
    GovernorVotes,
    GovernorVotesQuorumFraction,
    GovernorPreventLateQuorum,
    GovernorTimelockControl
{
    /// @dev ~24 hours (of ~12s L1-anchored blocks) before voting starts; the snapshot is
    /// taken at the end of the delay.
    uint48 public constant INITIAL_VOTING_DELAY = 7_200;
    /// @dev ~3 days of voting.
    uint32 public constant INITIAL_VOTING_PERIOD = 21_600;
    /// @dev 1% of the fixed 1e27 launch supply, in delegated votes, to open a proposal.
    uint256 public constant INITIAL_PROPOSAL_THRESHOLD = 1e25;
    /// @dev Quorum: 40% of past total supply must vote For or Abstain. Deliberately a hard
    /// bar against low-participation governance capture; note lowering it later itself
    /// requires a proposal that clears it. As burns shrink total supply the absolute
    /// quorum shrinks with it, while the proposal threshold above stays absolute.
    uint256 public constant INITIAL_QUORUM_NUMERATOR = 40;
    /// @dev ~12 hours: a vote that first reaches quorum near the deadline extends voting.
    uint48 public constant INITIAL_VOTE_EXTENSION = 3_600;

    constructor(IVotes token_, TimelockController timelock_)
        Governor("LongCommunityGovernor")
        GovernorSettings(INITIAL_VOTING_DELAY, INITIAL_VOTING_PERIOD, INITIAL_PROPOSAL_THRESHOLD)
        GovernorVotes(token_)
        GovernorVotesQuorumFraction(INITIAL_QUORUM_NUMERATOR)
        GovernorPreventLateQuorum(INITIAL_VOTE_EXTENSION)
        GovernorTimelockControl(timelock_)
    {}

    // ------------------------------------------------------------ required overrides

    function votingDelay() public view override(Governor, GovernorSettings) returns (uint256) {
        return super.votingDelay();
    }

    function votingPeriod() public view override(Governor, GovernorSettings) returns (uint256) {
        return super.votingPeriod();
    }

    function proposalThreshold() public view override(Governor, GovernorSettings) returns (uint256) {
        return super.proposalThreshold();
    }

    /// @dev Recomputed against solady's `getPastVotesTotalSupply` instead of delegating
    /// to GovernorVotesQuorumFraction, whose OZ-named `getPastTotalSupply` call does not
    /// exist on the launched DERC20 (see {ISoladyVotesTotalSupply}) — that base-contract
    /// path is dead code here. Falls back to the OZ name so a future token generation
    /// with standard ERC20Votes (e.g. a CloneDERC20VotesV2 launch) also governs
    /// correctly. The checkpointed, governance-tunable numerator machinery is reused
    /// unchanged.
    function quorum(uint256 timepoint) public view override(Governor, GovernorVotesQuorumFraction) returns (uint256) {
        address tokenAddress = address(token());
        uint256 pastSupply;
        try ISoladyVotesTotalSupply(tokenAddress).getPastVotesTotalSupply(timepoint) returns (uint256 supply) {
            pastSupply = supply;
        } catch {
            pastSupply = IVotes(tokenAddress).getPastTotalSupply(timepoint);
        }
        return (pastSupply * quorumNumerator(timepoint)) / quorumDenominator();
    }

    function state(uint256 proposalId) public view override(Governor, GovernorTimelockControl) returns (ProposalState) {
        return super.state(proposalId);
    }

    function proposalNeedsQueuing(uint256 proposalId)
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (bool)
    {
        return super.proposalNeedsQueuing(proposalId);
    }

    function proposalDeadline(uint256 proposalId)
        public
        view
        override(Governor, GovernorPreventLateQuorum)
        returns (uint256)
    {
        return super.proposalDeadline(proposalId);
    }

    function _queueOperations(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(Governor, GovernorTimelockControl) returns (uint48) {
        return super._queueOperations(proposalId, targets, values, calldatas, descriptionHash);
    }

    function _executeOperations(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(Governor, GovernorTimelockControl) {
        super._executeOperations(proposalId, targets, values, calldatas, descriptionHash);
    }

    function _cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(Governor, GovernorTimelockControl) returns (uint256) {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    function _executor() internal view override(Governor, GovernorTimelockControl) returns (address) {
        return super._executor();
    }

    function _tallyUpdated(uint256 proposalId) internal override(Governor, GovernorPreventLateQuorum) {
        super._tallyUpdated(proposalId);
    }
}
