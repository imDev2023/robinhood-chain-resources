// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.26;

import {ILighterBridge, StoredBatchInfo} from "./ILighterBridge.sol";
import {LighterProofV2} from "./LighterProofV2.sol";

/// @title LighterStateVerifierV2 — committed-batch verifier for the v5.2
///        foreign-position-aware witness.
/// @notice Identical trust model and checks to `LighterStateVerifier`; the only
///         difference is the witness/facts type (`LighterProofV2`), which
///         carries all 16 position-bucket digests and therefore reports
///         `foreignBucketMask` instead of making a multi-market account
///         unprovable.
///
///         V1 is left deployed and untouched: the existing v2-v5.1 vaults, the
///         recorded fixtures and the tier-1 live-root reconstruction test all
///         continue to run against it.
///
/// @dev The verifier deliberately does NOT act on `foreignBucketMask` — that is
///      a policy decision per call site (see LongXVault: proveState /
///      acquireLease / releaseLease refuse, rebalance / challengeRelease
///      proceed). Encoding the policy here would remove the caller's ability to
///      keep de-risking and accountability alive while refusing to price.
contract LighterStateVerifierV2 {
    ILighterBridge public immutable bridge;
    /// @notice Max age (in batches behind the committed head) of an
    ///         acceptable proof anchor. At ~60s cadence, 15 ≈ 15 min.
    uint64 public immutable freshnessBatches;

    error UnknownBatch(uint64 batchNumber, bytes32 computedHash);
    error StaleBatch(uint64 batchNumber, uint64 committedHead);
    error RootMismatch(bytes32 computed, bytes32 committed);
    error QuoteMultiplierUnsupported(uint256 qm);

    constructor(ILighterBridge bridge_, uint64 freshnessBatches_) {
        bridge = bridge_;
        freshnessBatches = freshnessBatches_;
    }

    function verifyAccount(
        LighterProofV2.AccountWitness calldata w,
        StoredBatchInfo calldata batch,
        uint48 accountIndex,
        address expectedL1Owner,
        uint16 targetMarket
    ) external view returns (LighterProofV2.AccountFacts memory facts) {
        // 1. The claimed batch is genuinely committed on the bridge.
        bytes32 h = keccak256(abi.encode(batch));
        if (bridge.storedBatchHashes(batch.batchNumber) != h) {
            revert UnknownBatch(batch.batchNumber, h);
        }
        // 2. ...and recent enough to base a decision on.
        uint64 head = bridge.committedBatchesCount();
        if (batch.batchNumber + freshnessBatches < head) {
            revert StaleBatch(batch.batchNumber, head);
        }
        // 3. The witness re-derives exactly that batch's root.
        facts = LighterProofV2.computeFacts(w, accountIndex, expectedL1Owner, targetMarket);
        if (facts.stateRoot != batch.stateRoot) {
            revert RootMismatch(facts.stateRoot, batch.stateRoot);
        }
        if (facts.quoteMultiplier != 1) revert QuoteMultiplierUnsupported(facts.quoteMultiplier);
    }
}
