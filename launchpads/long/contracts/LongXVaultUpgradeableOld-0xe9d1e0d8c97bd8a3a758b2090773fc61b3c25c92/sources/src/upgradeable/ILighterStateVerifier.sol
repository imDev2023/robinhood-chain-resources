// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.26;

import {StoredBatchInfo} from "../ILighterBridge.sol";
import {LighterProofV2} from "../LighterProofV2.sol";

/// @title ILighterStateVerifier — the verifier ABI the vault depends on.
/// @notice Matches `LighterStateVerifierV2` as deployed (its public immutable
///         `freshnessBatches` getter included), so existing verifier
///         deployments register in the router unchanged. Future verifier
///         versions (e.g. for a new Lighter proof format) implement this
///         interface and slot into the router without touching the vault.
interface ILighterStateVerifier {
    function verifyAccount(
        LighterProofV2.AccountWitness calldata w,
        StoredBatchInfo calldata batch,
        uint48 accountIndex,
        address expectedL1Owner,
        uint16 targetMarket
    ) external view returns (LighterProofV2.AccountFacts memory facts);

    function freshnessBatches() external view returns (uint64);
}

/// @title IVerifierRouter — batch-range verifier resolution.
/// @notice The vault resolves which verifier proves a given anchor batch and
///         then calls the verifier DIRECTLY — the ~30KB witness is never
///         re-encoded through the router. Lighter proof-format changes are
///         handled by registering a new verifier from a boundary batch; the
///         vault needs no upgrade.
interface IVerifierRouter {
    function verifierFor(uint64 batchNumber) external view returns (ILighterStateVerifier);
    function latestVerifier() external view returns (ILighterStateVerifier);
}
