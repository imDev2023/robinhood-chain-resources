// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./BaseACPHook.sol";
import "./SubscriptionState.sol";
import "../interfaces/IACPHookMetadata.sol";
import "../AgenticCommerceV3.sol";

/// @title SubscriptionHook
/// @notice Self-contained subscription hook for job-gated subscriptions.
///         Provider proposes subscription terms (duration, packageId) via
///         setBudget optParams. Client confirms terms match via fund optParams.
///         Subscription activates after job completion with expiry = now + duration.
///         If the client already has an active subscription for the same
///         provider + packageId, term proposal is skipped and budget must be 0
///         (reverts ActiveSubscriptionMustHaveZeroBudget otherwise).
///         Payment is handled by core's budget escrow, not by this hook.
/// @dev Four-hook flow:
///      1. _preSetBudget: checks active subscription, stores proposed terms if none active
///      2. _postFund: client validates proposed terms match their optParams
///      3. _postComplete: activates subscription with expiry = block.timestamp + duration
///      4. _postReject: cleans up proposed terms when a job is rejected
///
///      OptParams encoding (2 fields):
///        abi.encode(uint256 subDuration, uint256 packageId)
///        Empty optParams (length 0) means no subscription data.
contract SubscriptionHook is BaseACPHook, IACPHookMetadata {

    // ──────────────────── Types ────────────────────

    struct SubscriptionTerms {
        uint256 duration;
        uint256 packageId;
    }

    // ──────────────────── Storage ────────────────────

    SubscriptionState public immutable subscriptionState;

    mapping(uint256 jobId => SubscriptionTerms) public proposedTerms;

    // ──────────────────── Events ────────────────────

    event SubscriptionTermsProposed(
        uint256 indexed jobId,
        uint256 indexed packageId,
        uint256 duration
    );

    event SubscriptionActivated(
        uint256 indexed jobId,
        uint256 indexed packageId,
        address indexed client,
        address provider,
        uint256 duration
    );

    event SubscriptionTermsSkipped(
        uint256 indexed jobId,
        uint256 indexed packageId,
        uint256 currentExpiry
    );

    // ──────────────────── Errors ────────────────────

    error TermsMismatch();
    error TermsNotProposed();
    /// @notice Reverted when setBudget is called with a nonzero amount during an active subscription
    error ActiveSubscriptionMustHaveZeroBudget();

    // ──────────────────── Constructor ────────────────────

    /// @param coreAddress The ACP core contract or MultiHookRouter address
    /// @param subscriptionState_ The SubscriptionState contract address
    constructor(
        address coreAddress,
        address subscriptionState_
    ) BaseACPHook(coreAddress) {
        subscriptionState = SubscriptionState(subscriptionState_);
    }

    /// @dev Typed accessor -- works whether acpContract is core or router
    function _core() internal view returns (AgenticCommerceV3) {
        return AgenticCommerceV3(acpContract);
    }

    // ──────────────────── Before hooks ────────────────────

    /// @dev Provider proposes subscription terms. If the client already has an
    ///      active subscription with this provider for the same package, the
    ///      terms are skipped and a SubscriptionTermsSkipped event is emitted.
    ///      Otherwise stores the proposed terms for client confirmation.
    function _preSetBudget(
        uint256 jobId,
        address,
        uint256 budget,
        bytes memory optParams
    ) internal override {
        (uint256 subDuration, uint256 packageId) =
            _decodeSubParams(optParams);

        if (subDuration == 0) return;

        AgenticCommerceV3.Job memory job = _core().getJob(jobId);

        uint256 currentExpiry = subscriptionState.getSubscriptionExpiry(
            job.client, job.provider, packageId
        );
        if (currentExpiry > block.timestamp) {
            if (budget != 0) revert ActiveSubscriptionMustHaveZeroBudget();
            emit SubscriptionTermsSkipped(jobId, packageId, currentExpiry);
            return;
        }

        proposedTerms[jobId] = SubscriptionTerms({
            duration: subDuration,
            packageId: packageId
        });

        emit SubscriptionTermsProposed(jobId, packageId, subDuration);
    }

    // ──────────────────── After hooks ────────────────────

    /// @dev Client confirms proposed terms match their optParams. Reverts on mismatch.
    ///      Skipped if no terms were proposed (e.g. active subscription or duration=0).
    function _postFund(
        uint256 jobId,
        address,
        bytes memory optParams
    ) internal override {
        (uint256 subDuration, uint256 packageId) =
            _decodeSubParams(optParams);

        SubscriptionTerms storage terms = proposedTerms[jobId];

        if (terms.duration == 0) {
            if (subDuration != 0) revert TermsNotProposed();
            return;
        }

        // Client must provide matching params
        if (terms.duration != subDuration) revert TermsMismatch();
        if (terms.packageId != packageId) revert TermsMismatch();
    }

    /// @dev Cleans up proposed terms when a job is rejected.
    function _postReject(
        uint256 jobId,
        address,
        bytes32,
        bytes memory
    ) internal override {
        delete proposedTerms[jobId];
    }

    /// @dev Activates subscription after job completion. Expiry = now + duration.
    ///      No-op if no terms were proposed (e.g. active subscription or duration=0).
    ///      Cleans up proposed terms after activation.
    function _postComplete(
        uint256 jobId,
        address,
        bytes32,
        bytes memory
    ) internal override {
        SubscriptionTerms storage terms = proposedTerms[jobId];
        if (terms.duration == 0) return; // No subscription for this job

        AgenticCommerceV3.Job memory job = _core().getJob(jobId);

        uint256 expiry = block.timestamp + terms.duration;

        subscriptionState.activateSubscription(
            job.client,
            job.provider,
            terms.packageId,
            expiry
        );

        emit SubscriptionActivated(
            jobId,
            terms.packageId,
            job.client,
            job.provider,
            terms.duration
        );

        delete proposedTerms[jobId];
    }

    // ──────────────────── View Functions ────────────────────

    /// @notice Returns the subscription expiry for a client-provider-package tuple
    function getSubscriptionExpiry(
        address client,
        address provider,
        uint256 packageId
    ) external view returns (uint256) {
        return subscriptionState.getSubscriptionExpiry(client, provider, packageId);
    }

    /// @notice Returns proposed terms for a job (zero if none)
    function getProposedTerms(uint256 jobId) external view returns (SubscriptionTerms memory) {
        return proposedTerms[jobId];
    }

    // ──────────────────── ERC165 ────────────────────

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(BaseACPHook) returns (bool) {
        return
            interfaceId == type(IACPHookMetadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    // ──────────────────── IACPHookMetadata ────────────────────

    /// @notice Returns the selectors SubscriptionHook requires: setBudget, fund, complete, reject.
    /// @dev submit is NOT required -- SubscriptionHook does not override _preSubmit or _postSubmit.
    function requiredSelectors() external pure override returns (bytes4[] memory) {
        bytes4[] memory sels = new bytes4[](4);
        sels[0] = bytes4(keccak256("setBudget(uint256,uint256,bytes)"));
        sels[1] = bytes4(keccak256("fund(uint256,uint256,bytes)"));
        sels[2] = bytes4(keccak256("complete(uint256,bytes32,bytes)"));
        sels[3] = bytes4(keccak256("reject(uint256,bytes32,bytes)"));
        return sels;
    }

    // ──────────────────── Internal ────────────────────

    /// @dev Decodes subscription params from optParams.
    ///      Encoding: abi.encode(uint256 subDuration, uint256 packageId)
    ///      Empty optParams (length 0) returns zeros (no subscription data).
    function _decodeSubParams(bytes memory optParams) internal pure returns (
        uint256 subDuration,
        uint256 packageId
    ) {
        if (optParams.length == 0) return (0, 0);
        (subDuration, packageId) = abi.decode(optParams, (uint256, uint256));
    }
}
