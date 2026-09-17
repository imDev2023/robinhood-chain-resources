// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.26;

import {Poseidon2} from "./Poseidon2.sol";

/// @title LighterProofV2 — Lighter state-root reconstruction + account facts.
/// @notice The single proof library. It reconstructs Lighter's state root from a
///         raw account witness and returns the account facts (USDG balance,
///         position size, mark price) extracted from the very preimages that
///         were hashed — so a fact is trustworthy iff the final root matches one
///         the bridge has verified:
///
///           stateRoot = H2( H2(pubDataTreeRoot, publicMarketHash), validiumRoot )
///
///         TWO witness layouts live here:
///           - The V2 (production) layout carries all 16 position-bucket
///             digests, so an account holding a position OUTSIDE the target
///             market stays PROVABLE (it reports `possiblyForeignMask` instead
///             of reverting `RootMismatch`). This is the DRILL-4 Q6 fix — under
///             the V1 layout a ~$10 order in any other market froze the vault
///             and disabled the accountability layer aimed at the lessee.
///           - The V1 (`*V1`) layout substitutes `EMPTY_BUCKET` for the 15
///             non-target buckets. It is retained SOLELY for the two live-root
///             conformance tests (account 1368 in the V1 ABI, account 8782 in
///             the V2 ABI) that pin our Poseidon2 chain to the real rollup root.
///             Production code uses only the V2 entrypoints.
///
///         v5.3: the former standalone `LighterProof.sol` (V1) was folded in
///         here so there is one proof file and no cross-file internal
///         dependency. The shared Poseidon stages (`_balancesRoot`,
///         `_bucketDigest`, `_leaf`, limb/field encoders) are defined once and
///         used by both layouts.
///
/// @dev Soundness stances (all fail closed):
///      - The TARGET bucket digest is COMPUTED from the raw slots and
///        cross-checked against the supplied array (`TargetDigestMismatch`), so
///        `positionSize` stays bound to the hashed preimage and the whole array
///        becomes trustworthy.
///      - The other 15 digests are authenticated implicitly: a wrong value
///        changes the leaf and the root check fails.
///      - `NonEmptySiblingSlot` is retained for the in-bucket case.
///      - l1_address is not witnessed: the leaf is built with `expectedL1Owner`,
///        binding the proof to the vault's registered address.
///      - Callers MUST decide explicitly what to do with `possiblyForeignMask`.
library LighterProofV2 {
    /// Goldilocks prime.
    uint256 internal constant P = 0xFFFFFFFF00000001;

    /// hash_no_pad([0; 160]) — an all-zero 16-slot position bucket. Generated
    /// by tools/poseidon2-vectors (see test/vectors/poseidon2.txt) and asserted
    /// against Poseidon2.hashNoPad in the test suite.
    uint256 internal constant EMPTY_BUCKET_0 = 3569409528440474668;
    uint256 internal constant EMPTY_BUCKET_1 = 14149179056480293916;
    uint256 internal constant EMPTY_BUCKET_2 = 12413614468028469174;
    uint256 internal constant EMPTY_BUCKET_3 = 3860821299311047842;

    // shared
    error LimbRangeExceeded();
    error NonEmptySiblingSlot(uint8 slot);
    error TargetMarketOutOfRange();
    // v5.2
    error TargetDigestMismatch();
    error NotAForeignBucket();
    error ForeignOpeningMismatch();
    error NoForeignPositionAtSlot();
    error SlotOutOfRange();
    // v5.2.1
    error UnclearedForeignBucket(uint16 remainingMask);
    error ForeignPositionInBucket(uint8 bucketIndex, uint8 slot);

    // ========================================================================
    // V2 (production) witness layout — all 16 bucket digests carried.
    // ========================================================================

    struct AccountWitness {
        int128[64] balances;
        int128[16] bucketFunding;
        int128[16] bucketSize;
        uint64[16] poolIndices;
        int128[16] poolShareAmounts;
        int128 poolTotalShares;
        int128 poolOperatorShares;
        uint8 accountType;
        /// @dev v5.2: all 16 position-bucket digests, packed-LE. The target
        ///      entry is cross-checked against the digest recomputed from the
        ///      raw slots; the rest are root-authenticated.
        bytes32[16] bucketDigests;
        bytes32[48] merklePath;
        uint32[255] markPrices;
        int128[255] marketFundings;
        uint16[255] quoteMultipliers;
        bytes32 validiumRoot;
    }

    struct AccountFacts {
        bytes32 stateRoot;
        int256 usdgBalance;
        int256 positionSize;
        uint256 markPrice;
        uint256 quoteMultiplier;
        /// @dev v5.2.1: bit b set iff bucket b != targetBucket and its digest
        ///      is NOT the empty-bucket constant. This means **"possibly
        ///      foreign — needs checking"**, NOT "holds a position".
        ///
        ///      DRILL-5: a bucket is non-empty if it holds a position **OR**
        ///      merely carries `funding_prefix_sum` residue — and funding
        ///      accumulators are protocol-level and never reset. So once any
        ///      position has existed in a bucket, its digest stays non-empty
        ///      FOREVER, even after the position is fully closed (observed:
        ///      market 16 size=0 funding=202923327, digest 762e3973... !=
        ///      EMPTY 3189170d...). Treating a set bit as "has a position"
        ///      turned a temporary freeze into a PERMANENT settlement block.
        ///
        ///      Clear a flagged bucket by opening it (`requireForeignClear`)
        ///      and showing every slot's size is zero.
        uint16 possiblyForeignMask;
    }

    function computeFacts(AccountWitness calldata w, uint48 accountIndex, address expectedL1Owner, uint16 targetMarket)
        internal
        pure
        returns (AccountFacts memory facts)
    {
        if (targetMarket >= 255) revert TargetMarketOutOfRange();
        uint256 rc = Poseidon2.loadConstants();
        uint256 targetSlot = targetMarket % 16;
        uint256 targetBucket = uint256(targetMarket) / 16;

        // 1-2. Balances root + target bucket digest (shared stages).
        uint256[4] memory balancesRoot = _balancesRoot(w.balances, rc);
        uint256[4] memory bucketDigest = _bucketDigest(w.bucketFunding, w.bucketSize, targetSlot, rc);

        // 2b. The supplied target digest must equal the computed one — this is
        //     what authenticates the rest of the array for the mask below.
        {
            uint256[4] memory supplied = Poseidon2.unpack(w.bucketDigests[targetBucket]);
            if (
                supplied[0] != bucketDigest[0] || supplied[1] != bucketDigest[1] || supplied[2] != bucketDigest[2]
                    || supplied[3] != bucketDigest[3]
            ) revert TargetDigestMismatch();
        }

        // 3. pd_hash — SUPPLIED digests for non-target buckets (the V2 change).
        uint256[4] memory pdHash = _pdHash(w, bucketDigest, targetBucket, rc);

        // 4-5. Shared leaf + 48-level fold.
        uint256[4] memory leafD = _leaf(pdHash, expectedL1Owner, w.accountType, balancesRoot, rc);
        for (uint256 lvl = 0; lvl < 48; ++lvl) {
            leafD =
                Poseidon2.fold(leafD, Poseidon2.unpack(w.merklePath[lvl]), (uint256(accountIndex) >> lvl) & 1 == 1, rc);
        }

        // 6-7. Market hash + state root.
        uint256[4] memory marketHash = _publicMarketHash(w, rc);
        facts.stateRoot = Poseidon2.pack(
            Poseidon2.twoToOne(Poseidon2.twoToOne(leafD, marketHash, rc), Poseidon2.unpack(w.validiumRoot), rc)
        );

        facts.usdgBalance = w.balances[3];
        facts.positionSize = w.bucketSize[targetSlot];
        facts.markPrice = w.markPrices[targetMarket];
        facts.quoteMultiplier = w.quoteMultipliers[targetMarket];
        facts.possiblyForeignMask = _possiblyForeignMask(w, targetBucket);
    }

    /// @notice Authenticate a raw foreign-bucket opening against the (already
    ///         root-bound) digest array; returns the market and size of one
    ///         non-zero slot.
    function openForeign(
        AccountWitness calldata w,
        uint16 targetMarket,
        uint8 bucketIndex,
        int128[16] calldata funding,
        int128[16] calldata size,
        uint8 slot
    ) internal pure returns (uint16 market, int256 positionSize) {
        if (bucketIndex >= 16 || slot >= 16) revert SlotOutOfRange();
        if (bucketIndex == targetMarket / 16) revert NotAForeignBucket();
        uint256[4] memory computed = _bucketDigestRaw(funding, size, Poseidon2.loadConstants());
        uint256[4] memory supplied = Poseidon2.unpack(w.bucketDigests[bucketIndex]);
        if (
            computed[0] != supplied[0] || computed[1] != supplied[1] || computed[2] != supplied[2]
                || computed[3] != supplied[3]
        ) revert ForeignOpeningMismatch();
        positionSize = size[slot];
        if (positionSize == 0) revert NoForeignPositionAtSlot();
        market = uint16(uint256(bucketIndex) * 16 + slot);
    }

    /// @notice v5.2.1: a raw opening used to prove a flagged bucket holds NO
    ///         position (as opposed to `openForeign`, which proves it DOES).
    struct ForeignClearing {
        uint8 bucketIndex;
        int128[16] funding;
        int128[16] size; // must be all-zero for the bucket to count as clear
    }

    /// @notice Require that EVERY bucket flagged in `mask` is proven
    ///         position-free. Each clearing is authenticated against the
    ///         root-bound digest, then every one of its 16 slots must have
    ///         size 0. A flagged bucket with no clearing fails closed.
    /// @dev This is the v5.2.1 fix: `possiblyForeignMask` cannot distinguish a
    ///      live foreign position from funding residue, so the caller must
    ///      supply the evidence. Costs one 160-element hash (~20 permutations)
    ///      per flagged bucket, and only when a bucket is flagged.
    function requireForeignClear(AccountWitness calldata w, uint16 mask, ForeignClearing[] calldata clearings)
        internal
        pure
    {
        if (mask == 0) return;
        uint256 rc = Poseidon2.loadConstants();
        uint16 remaining = mask;
        for (uint256 i = 0; i < clearings.length; ++i) {
            uint8 b = clearings[i].bucketIndex;
            if (b >= 16) revert SlotOutOfRange();
            uint16 bit = uint16(1 << b);
            if (remaining & bit == 0) continue; // not flagged, or already cleared
            uint256[4] memory computed = _bucketDigestRaw(clearings[i].funding, clearings[i].size, rc);
            uint256[4] memory supplied = Poseidon2.unpack(w.bucketDigests[b]);
            if (
                computed[0] != supplied[0] || computed[1] != supplied[1] || computed[2] != supplied[2]
                    || computed[3] != supplied[3]
            ) revert ForeignOpeningMismatch();
            for (uint256 sIdx = 0; sIdx < 16; ++sIdx) {
                if (clearings[i].size[sIdx] != 0) {
                    revert ForeignPositionInBucket(b, uint8(sIdx));
                }
            }
            remaining &= ~bit;
        }
        if (remaining != 0) revert UnclearedForeignBucket(remaining);
    }

    /// pd_hash preimage (98 elts). Identical shape to V1 — only the source of
    /// the non-target bucket digests differs (SUPPLIED, not EMPTY), so there is
    /// no extra hashing.
    function _pdHash(AccountWitness calldata w, uint256[4] memory bucketDigest, uint256 targetBucket, uint256 rc)
        internal
        pure
        returns (uint256[4] memory)
    {
        uint256[] memory e = new uint256[](98);
        for (uint256 b = 0; b < 16; ++b) {
            uint256 o = b * 4;
            if (b == targetBucket) {
                e[o] = bucketDigest[0];
                e[o + 1] = bucketDigest[1];
                e[o + 2] = bucketDigest[2];
                e[o + 3] = bucketDigest[3];
            } else {
                uint256[4] memory d = Poseidon2.unpack(w.bucketDigests[b]);
                e[o] = d[0];
                e[o + 1] = d[1];
                e[o + 2] = d[2];
                e[o + 3] = d[3];
            }
        }
        for (uint256 s = 0; s < 16; ++s) {
            e[64 + 2 * s] = w.poolIndices[s];
            e[64 + 2 * s + 1] = _fieldI128(w.poolShareAmounts[s]);
        }
        e[96] = _fieldI128(w.poolTotalShares);
        e[97] = _fieldI128(w.poolOperatorShares);
        return Poseidon2.hashNoPad(e, rc);
    }

    function _possiblyForeignMask(AccountWitness calldata w, uint256 targetBucket) internal pure returns (uint16 mask) {
        for (uint256 b = 0; b < 16; ++b) {
            if (b == targetBucket) continue;
            uint256[4] memory d = Poseidon2.unpack(w.bucketDigests[b]);
            if (d[0] != EMPTY_BUCKET_0 || d[1] != EMPTY_BUCKET_1 || d[2] != EMPTY_BUCKET_2 || d[3] != EMPTY_BUCKET_3) {
                mask |= uint16(1 << b);
            }
        }
    }

    /// Bucket digest with NO sibling-slot restriction — a FOREIGN bucket may
    /// legitimately hold positions in any of its 16 slots.
    function _bucketDigestRaw(int128[16] calldata funding, int128[16] calldata size, uint256 rc)
        internal
        pure
        returns (uint256[4] memory)
    {
        uint256[] memory e = new uint256[](160);
        for (uint256 s = 0; s < 16; ++s) {
            uint256 o = s * 10;
            _putI64Limbs16(e, o, funding[s]);
            _putI64Limbs16(e, o + 5, size[s]);
        }
        return Poseidon2.hashNoPad(e, rc);
    }

    /// publicMarketHash over all 255 markets: per market 4 LE u16 limbs of
    /// |funding_prefix_sum|, funding sign, mark_price, quote_multiplier.
    function _publicMarketHash(AccountWitness calldata w, uint256 rc) internal pure returns (uint256[4] memory) {
        uint256[] memory e = new uint256[](1785);
        for (uint256 m = 0; m < 255; ++m) {
            uint256 o = m * 7;
            _putI64Limbs16(e, o, w.marketFundings[m]);
            e[o + 5] = w.markPrices[m];
            e[o + 6] = w.quoteMultipliers[m];
        }
        return Poseidon2.hashNoPad(e, rc);
    }

    // ========================================================================
    // V1 (legacy) witness layout — non-target buckets substituted EMPTY.
    // Retained ONLY for the account-1368 live-root conformance test; no
    // production code path uses these.
    // ========================================================================

    /// The full preimage material for one account at one batch, V1 layout.
    struct AccountWitnessV1 {
        int128[64] balances;
        int128[16] bucketFunding;
        int128[16] bucketSize;
        uint64[16] poolIndices;
        int128[16] poolShareAmounts;
        int128 poolTotalShares;
        int128 poolOperatorShares;
        uint8 accountType;
        bytes32[48] merklePath;
        uint32[255] markPrices;
        int128[255] marketFundings;
        uint16[255] quoteMultipliers;
        bytes32 validiumRoot;
    }

    struct AccountFactsV1 {
        bytes32 stateRoot;
        int256 usdgBalance;
        int256 positionSize;
        uint256 markPrice;
        uint256 quoteMultiplier;
    }

    /// Recomputes the state root from the V1 witness and extracts facts.
    function computeFactsV1(
        AccountWitnessV1 calldata w,
        uint48 accountIndex,
        address expectedL1Owner,
        uint16 targetMarket
    ) internal pure returns (AccountFactsV1 memory facts) {
        if (targetMarket >= 255) revert TargetMarketOutOfRange();
        uint256 rc = Poseidon2.loadConstants();

        uint256[4] memory balancesRoot = _balancesRoot(w.balances, rc);
        uint256 targetSlot = targetMarket % 16;
        uint256[4] memory bucketDigest = _bucketDigest(w.bucketFunding, w.bucketSize, targetSlot, rc);
        uint256[4] memory pdHash = _pdHashV1(w, bucketDigest, uint256(targetMarket) / 16, rc);
        uint256[4] memory leafD = _leaf(pdHash, expectedL1Owner, w.accountType, balancesRoot, rc);

        for (uint256 lvl = 0; lvl < 48; ++lvl) {
            leafD =
                Poseidon2.fold(leafD, Poseidon2.unpack(w.merklePath[lvl]), (uint256(accountIndex) >> lvl) & 1 == 1, rc);
        }

        uint256[4] memory marketHash = _publicMarketHashV1(w, rc);
        facts.stateRoot = Poseidon2.pack(
            Poseidon2.twoToOne(Poseidon2.twoToOne(leafD, marketHash, rc), Poseidon2.unpack(w.validiumRoot), rc)
        );

        facts.usdgBalance = w.balances[3];
        facts.positionSize = w.bucketSize[targetSlot];
        facts.markPrice = w.markPrices[targetMarket];
        facts.quoteMultiplier = w.quoteMultipliers[targetMarket];
    }

    /// pd_hash (V1): EMPTY_BUCKET for every non-target bucket.
    function _pdHashV1(AccountWitnessV1 calldata w, uint256[4] memory bucketDigest, uint256 targetBucket, uint256 rc)
        internal
        pure
        returns (uint256[4] memory)
    {
        uint256[] memory e = new uint256[](98);
        for (uint256 b = 0; b < 16; ++b) {
            uint256 o = b * 4;
            if (b == targetBucket) {
                e[o] = bucketDigest[0];
                e[o + 1] = bucketDigest[1];
                e[o + 2] = bucketDigest[2];
                e[o + 3] = bucketDigest[3];
            } else {
                e[o] = EMPTY_BUCKET_0;
                e[o + 1] = EMPTY_BUCKET_1;
                e[o + 2] = EMPTY_BUCKET_2;
                e[o + 3] = EMPTY_BUCKET_3;
            }
        }
        for (uint256 s = 0; s < 16; ++s) {
            e[64 + 2 * s] = w.poolIndices[s];
            e[64 + 2 * s + 1] = _fieldI128(w.poolShareAmounts[s]);
        }
        e[96] = _fieldI128(w.poolTotalShares);
        e[97] = _fieldI128(w.poolOperatorShares);
        return Poseidon2.hashNoPad(e, rc);
    }

    /// publicMarketHash (V1) — byte-identical layout to the V2 variant.
    function _publicMarketHashV1(AccountWitnessV1 calldata w, uint256 rc) internal pure returns (uint256[4] memory) {
        uint256[] memory e = new uint256[](1785);
        for (uint256 m = 0; m < 255; ++m) {
            uint256 o = m * 7;
            _putI64Limbs16(e, o, w.marketFundings[m]);
            e[o + 5] = w.markPrices[m];
            e[o + 6] = w.quoteMultipliers[m];
        }
        return Poseidon2.hashNoPad(e, rc);
    }

    // ========================================================================
    // Shared Poseidon stages / encoders (used by both layouts).
    // ========================================================================

    /// Sign as the circuit hashes it: +1 / 0 / p-1 (leaf.rs sign_elt).
    function _signElt(int256 x) internal pure returns (uint256) {
        if (x > 0) return 1;
        if (x < 0) return P - 1;
        return 0;
    }

    /// asset leaf: ZERO if 0, else H([sign, 3 LE u32 limbs of |b|]).
    function _balancesRoot(int128[64] calldata balances, uint256 rc) internal pure returns (uint256[4] memory) {
        uint256[4][] memory level = new uint256[4][](64);
        uint256[] memory e = new uint256[](4);
        for (uint256 i = 0; i < 64; ++i) {
            int256 b = balances[i];
            if (b == 0) continue; // ZERO digest, already zeroed
            uint256 abs = _abs(b);
            if (abs >= 1 << 96) revert LimbRangeExceeded();
            e[0] = _signElt(b);
            e[1] = abs & 0xFFFFFFFF;
            e[2] = (abs >> 32) & 0xFFFFFFFF;
            e[3] = (abs >> 64) & 0xFFFFFFFF;
            level[i] = Poseidon2.hashNoPad(e, rc);
        }
        uint256 n = 64;
        while (n > 1) {
            n /= 2;
            for (uint256 i = 0; i < n; ++i) {
                level[i] = Poseidon2.twoToOne(level[2 * i], level[2 * i + 1], rc);
            }
        }
        return level[0];
    }

    /// One 16-slot bucket: per slot 10 elements — 4 LE u16 limbs of |funding|,
    /// funding sign, 4 LE u16 limbs of |size|, size sign. Enforces the
    /// sibling-slot rule (only the target slot may hold size).
    function _bucketDigest(int128[16] calldata funding, int128[16] calldata size, uint256 targetSlot, uint256 rc)
        internal
        pure
        returns (uint256[4] memory)
    {
        uint256[] memory e = new uint256[](160);
        for (uint256 s = 0; s < 16; ++s) {
            if (s != targetSlot && size[s] != 0) revert NonEmptySiblingSlot(uint8(s));
            uint256 o = s * 10;
            _putI64Limbs16(e, o, funding[s]);
            _putI64Limbs16(e, o + 5, size[s]);
        }
        return Poseidon2.hashNoPad(e, rc);
    }

    /// Writes [4 LE u16 limbs of |x|, sign] at e[o..o+5]. Requires |x| < 2^64.
    function _putI64Limbs16(uint256[] memory e, uint256 o, int256 x) private pure {
        uint256 abs = _abs(x);
        if (abs >= 1 << 64) revert LimbRangeExceeded();
        e[o] = abs & 0xFFFF;
        e[o + 1] = (abs >> 16) & 0xFFFF;
        e[o + 2] = (abs >> 32) & 0xFFFF;
        e[o + 3] = (abs >> 48) & 0xFFFF;
        e[o + 4] = _signElt(x);
    }

    /// leaf = H(pd_hash(4) ‖ l1 5×u32 LE limbs ‖ account_type ‖ balances_root(4)).
    function _leaf(
        uint256[4] memory pdHash,
        address l1Owner,
        uint8 accountType,
        uint256[4] memory balancesRoot,
        uint256 rc
    ) internal pure returns (uint256[4] memory) {
        uint256[] memory e = new uint256[](14);
        e[0] = pdHash[0];
        e[1] = pdHash[1];
        e[2] = pdHash[2];
        e[3] = pdHash[3];
        uint256 a = uint256(uint160(l1Owner));
        e[4] = a & 0xFFFFFFFF;
        e[5] = (a >> 32) & 0xFFFFFFFF;
        e[6] = (a >> 64) & 0xFFFFFFFF;
        e[7] = (a >> 96) & 0xFFFFFFFF;
        e[8] = (a >> 128) & 0xFFFFFFFF;
        e[9] = accountType;
        e[10] = balancesRoot[0];
        e[11] = balancesRoot[1];
        e[12] = balancesRoot[2];
        e[13] = balancesRoot[3];
        return Poseidon2.hashNoPad(e, rc);
    }

    /// field_i128: positive → value, negative → p − |value| (leaf.rs).
    /// The Rust casts the positive value to u64; anything wider on a real
    /// account would be a decode bug, so fail closed on it here.
    function _fieldI128(int256 x) internal pure returns (uint256) {
        uint256 abs = _abs(x);
        if (abs >= 1 << 64) revert LimbRangeExceeded();
        if (x < 0) return P - abs;
        return abs;
    }

    function _abs(int256 x) internal pure returns (uint256) {
        return x < 0 ? uint256(-x) : uint256(x);
    }
}
