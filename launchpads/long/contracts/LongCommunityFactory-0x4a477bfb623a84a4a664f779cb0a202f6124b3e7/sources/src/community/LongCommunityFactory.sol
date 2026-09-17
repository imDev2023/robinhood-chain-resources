// SPDX-License-Identifier: BUSL-1.1
// Copyright (c) 2026 long.xyz. All rights reserved.
pragma solidity ^0.8.26;

import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";
import {IVotes} from "@openzeppelin/contracts/governance/utils/IVotes.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "v4-core/src/types/PoolId.sol";

import {IDopplerHookInitializer} from "../interfaces/IDopplerHookInitializer.sol";
import {LongCommunityGovernor} from "./LongCommunityGovernor.sol";
import {LongCommunityGovernorDeployer} from "./LongCommunityGovernorDeployer.sol";
import {LongFeeSplitter} from "./LongFeeSplitter.sol";

/// @title LongCommunityFactory
/// @author @natan_benish
/// @notice One-call deployer of a token's community-mode suite: a TimelockController
/// treasury, a LongCommunityGovernor over the launched DERC20 (already ERC20Votes), and a
/// LongFeeSplitter wired between them. Permissionless and ownerless.
/// @dev Activation is a deliberate SECOND transaction by the creator:
/// `initializer.updateBeneficiary(poolId, splitter)` moves the CALLER's slot, so only the
/// current fee receiver can flip it — the factory cannot. That call has no access control
/// and made from the wrong wallet it is a silent no-op that still emits UpdateBeneficiary,
/// so integrators MUST verify {isActivated} afterwards instead of trusting the event.
/// Once activated the DAO governs the asset-side split and the treasury, but two creator
/// protections are baked into the splitter: the numeraire-side split (20% original
/// receiver / 80% treasury) is immutable, and migrating the beneficiary slot away
/// requires the original receiver's standing approval of the exact destination.
/// (Launched DERC20s can carry a maxBalanceLimit; production launches disable it, but a
/// future limited token could cap splitter/timelock balances.)
contract LongCommunityFactory {
    using PoolIdLibrary for PoolKey;

    struct CommunityDeployment {
        address splitter;
        address governor;
        address payable timelock;
        address originalReceiver;
        bytes32 poolId;
        uint48 deployedAt;
    }

    /// @dev Wall-clock seconds (TimelockController is timestamp-based, unlike the
    /// block-number-clocked governor).
    uint256 public constant TIMELOCK_MIN_DELAY = 2 days;
    /// @dev Caller must hold a strict MAJORITY of beneficiary shares (WAD) to deploy.
    /// The standard creator slot is 0.95e18; the 0.05e18 protocol slot can neither deploy
    /// a suite nor overwrite an inert one and bind itself as originalReceiver.
    uint256 public constant MIN_DEPLOY_SHARES = 0.5e18;

    IDopplerHookInitializer public immutable INITIALIZER;
    /// @dev Carries the governor creation code; without it this factory would exceed
    /// EIP-170 (see LongCommunityGovernorDeployer).
    LongCommunityGovernorDeployer public immutable GOVERNOR_DEPLOYER;

    mapping(address asset => CommunityDeployment) private _deployments;

    error ZeroAddress();
    error PoolNotInitialized(address asset);
    error NotBeneficiary(address caller);
    error AlreadyDeployed(address asset);

    event CommunityModeDeployed(
        address indexed asset,
        bytes32 indexed poolId,
        address splitter,
        address governor,
        address timelock,
        address originalReceiver
    );

    constructor(address initializer_, address governorDeployer_) {
        if (initializer_ == address(0) || governorDeployer_ == address(0)) revert ZeroAddress();
        INITIALIZER = IDopplerHookInitializer(initializer_);
        GOVERNOR_DEPLOYER = LongCommunityGovernorDeployer(governorDeployer_);
    }

    /// @notice Deploys the full governance suite for `asset` in one transaction and
    /// records it. Does NOT move the fee-beneficiary slot — see the activation note above.
    function deployCommunityMode(address asset)
        external
        returns (address splitter, address governor, address payable timelock)
    {
        (,,,, uint8 status, PoolKey memory key,) = INITIALIZER.getState(asset);
        if (status == 0) revert PoolNotInitialized(asset);
        bytes32 poolId = PoolId.unwrap(key.toId());

        if (INITIALIZER.getShares(poolId, msg.sender) <= MIN_DEPLOY_SHARES) revert NotBeneficiary(msg.sender);

        // A never-activated suite is inert (holds no slot, no funds) and may be replaced —
        // this lets a creator who rotated wallets re-deploy. Once the splitter holds
        // shares the suite is canonical. After a governance migration away, the asset
        // reads deactivated again and a fresh suite may be deployed; the old timelock
        // keeps its treasury under the old governor.
        CommunityDeployment storage prior = _deployments[asset];
        if (prior.splitter != address(0) && INITIALIZER.getShares(poolId, prior.splitter) != 0) {
            revert AlreadyDeployed(asset);
        }

        TimelockController timelockController = new TimelockController(
            TIMELOCK_MIN_DELAY, new address[](0), _openExecutors(), address(this)
        );
        LongCommunityGovernor governorContract =
            GOVERNOR_DEPLOYER.deploy(IVotes(asset), timelockController);
        LongFeeSplitter splitterContract =
            new LongFeeSplitter(address(INITIALIZER), asset, msg.sender, address(timelockController));

        // Governor proposes and cancels; execution is open (address(0) executor above);
        // the timelock administers itself from here on (self-grant in its constructor).
        timelockController.grantRole(timelockController.PROPOSER_ROLE(), address(governorContract));
        timelockController.grantRole(timelockController.CANCELLER_ROLE(), address(governorContract));
        timelockController.renounceRole(timelockController.DEFAULT_ADMIN_ROLE(), address(this));

        splitter = address(splitterContract);
        governor = address(governorContract);
        timelock = payable(address(timelockController));

        _deployments[asset] = CommunityDeployment({
            splitter: splitter,
            governor: governor,
            timelock: timelock,
            originalReceiver: msg.sender,
            poolId: poolId,
            deployedAt: uint48(block.timestamp)
        });

        emit CommunityModeDeployed(asset, poolId, splitter, governor, timelock, msg.sender);
    }

    function getDeployment(address asset) external view returns (CommunityDeployment memory) {
        return _deployments[asset];
    }

    /// @notice True once the recorded splitter actually holds the beneficiary slot.
    function isActivated(address asset) public view returns (bool) {
        CommunityDeployment storage deployment = _deployments[asset];
        if (deployment.splitter == address(0)) return false;
        return INITIALIZER.getShares(deployment.poolId, deployment.splitter) != 0;
    }

    function _openExecutors() private pure returns (address[] memory executors) {
        executors = new address[](1);
        executors[0] = address(0);
    }
}
