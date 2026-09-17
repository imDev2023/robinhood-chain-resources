// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.26;

/// @title Poseidon2 — Poseidon2 permutation and sponge over Goldilocks.
/// @notice Solidity port of the exact hash Lighter's circuits commit state
///         with: elliottech/plonky2 @ e1c2d354 (MIT/Apache-2.0),
///         plonky2/src/hash/poseidon2/{config.rs,hash.rs}. Parameters:
///         WIDTH=12, S-box x^7, RATE=8, OUT=4, 8 full + 22 partial rounds.
///         Reference vectors: test/vectors/poseidon2.txt (regenerate with
///         tools/poseidon2-vectors — pinned to the same rev).
///
/// @dev A digest is uint256[4] holding canonical Goldilocks elements
///      (p = 2^64 - 2^32 + 1). All functions expect and produce canonical
///      lanes; `hashNoPad` inputs must be canonical field elements.
///
///      The sponge is OVERWRITE-MODE WITH NO PADDING (plonky2
///      `hash_n_to_m_no_pad`): each chunk of up to 8 elements overwrites the
///      first `len(chunk)` rate lanes and the state is permuted — a final
///      short chunk leaves lanes `len(chunk)..8` holding the PREVIOUS
///      permutation's output, not zeros. Consequence (asserted in tests):
///      hashNoPad([0]) == twoToOne(ZERO, ZERO).
library Poseidon2 {
    /// @dev Goldilocks prime p = 2^64 - 2^32 + 1.
    uint256 internal constant P = 0xFFFFFFFF00000001;

    /// @dev Round constants + internal-matrix diagonal, generated from the
    ///      pinned config.rs by a script that parses the Rust source (no
    ///      hand transcription). Layout: 96 external RCs (round-major:
    ///      round r lane i at index r*12+i) || 22 internal RCs || 12 diag
    ///      entries; each an 8-byte big-endian u64.
    bytes private constant RC =
        hex"d70193d17ab3b7d6a2c3662a78a9162b7a9fda827556ad44e8d5501818c996434c7a8fced4d5fd3855ab38985c0c513d28a17bd016210b0b8f8277679ec32fa8768b3c3d68a460e9872a022eb559d941d1316dd4b3b97973a7b608e5783210003fa02c87b0bee0267a38f0022e13c31e00c054f3c5e8d20d439f50f4bca7242f4d0938aa57cd517fb2e03ac5fb6b9a7de29d1f4237bedca805b7c844bc99b84891cc0b73f34e17ed876e4427694bd75567002ae0725c612d05351f20e0b6315f2e3b9ef5457eb60bd9ac17618c3783dd0807528ad8874bcfc78d546a455d2a0ef8b930c81e2481f0712707d8dff3b041dcb8c0aa0b9d34c39baddbdf2ee3a4682dd16d50c5176c7889eac5cfbc075cd32a741dea181587f31a4d6aa85a113d844d736286a2387e348bad5dfc4fcb3ee384fbd03adb77c56a8d5cdd1a23ec53a2036f08f08fff28ecb717a3f4dbdfb44358a074b5509d645cf92bf834e4b877181541c3a0baa5ac4b22149e6783e676929be8b5d9e112476f41e0969f62babb76bc585ad3b9443dbbf28dd3206975cbb1dd8815e53ca045e0de82c416b9e701bac5cb875233afa0257212697cd897ffa967844790aa63cfd7dc0b9cfa97fe65c3e8fe091869a8207062902bb2e413c6d129f9f5001fb84f57be1014796ef5f8be71feb53e9bdba19c251054f592ebb71ce1a57643a4bb284ba4ba6f87a45b739b2c1fcade0b958c49bbb424cda9a3e3602ca647354c5f3f54c9277b64d152e084dbc9ac97445eff176f6cdf3198969f701de29d14fa76d8f173337458a8cc1d19b87e775e2fb3ab23f166a1c7a565c80bb24be06f426c747fc281e8c49482ce0051974c3b3b726c2d87444cf8caf7d6197c362f827a580ced9567af14667647a0cbf0473cbec54e37e3209dedeff4f620d43ad94e45a4c4ee976981ee73f41768ef707a224e2072582fc779e10e6362ee29b5ee60ad8c891f96b37b39d8bfd667877df68a8b22e7335c41746f562c8d9f0c9d76751052b71afb3465341bf1c087a0d14dc614d15eb1dc27d17136906fa6482e163b05ec397f0273a462992366efa571418d95897b608f32676574fcf6d3731102d4e3fb1bbe0330f08328a82d2b7f0449b6557f785d62f06210658dcbcbd5a98af9f89c458b77ec69083a346385ef7ca48bbc27f89053e9652f61eac532a71c634abff4f0ccb16f5f0d7e28ea29c9dde31d0a003ab22ddadf9775902533e4fa73fb16408b4790242ebc00d2ee59bb02dffd9f381982dea328364c50907c1395d3b924857cf87d3ead0d5aec04e6c2f12be3fed746680ba3c338f8c3d285c3b6c08e23ba9300d84b5de94a324fb60d0c371c5b35b84f7964f570e71880375daf18bbd996604b6743bc47b95952575528b9362c59bb70ac45e25b7127b68ba2077d7dfbb606b5f3faac6faee378ae0c6388b51545e883d27dbb6944917b60";

    /// @notice Unpacks RC into 130 memory words. Call once per verification
    ///         and thread the pointer through every hash call.
    /// @return rcPtr memory pointer to word 0 of [ext(96) || int(22) || diag(12)]
    function loadConstants() internal pure returns (uint256 rcPtr) {
        bytes memory blob = RC;
        assembly ("memory-safe") {
            rcPtr := mload(0x40)
            mstore(0x40, add(rcPtr, 4160)) // 130 * 32
            let src := add(blob, 32)
            for { let i := 0 } lt(i, 130) { i := add(i, 1) } {
                mstore(add(rcPtr, shl(5, i)), shr(192, mload(add(src, shl(3, i)))))
            }
        }
    }

    /// @notice The Poseidon2 permutation. Mutates `st` in place.
    /// @dev Canonical lanes in, canonical lanes out. Lanes live in Yul locals
    ///      (via-IR spills as needed); the Yul optimizer inlines the helpers.
    function permute(uint256[12] memory st, uint256 rcPtr) internal pure {
        assembly ("memory-safe") {
            let p := P
            let s0 := mload(st)
            let s1 := mload(add(st, 0x20))
            let s2 := mload(add(st, 0x40))
            let s3 := mload(add(st, 0x60))
            let s4 := mload(add(st, 0x80))
            let s5 := mload(add(st, 0xa0))
            let s6 := mload(add(st, 0xc0))
            let s7 := mload(add(st, 0xe0))
            let s8 := mload(add(st, 0x100))
            let s9 := mload(add(st, 0x120))
            let s10 := mload(add(st, 0x140))
            let s11 := mload(add(st, 0x160))

            // x^7 mod p; tolerates unreduced input (mulmod reduces).
            function sb(x, q) -> y {
                let x2 := mulmod(x, x, q)
                let x4 := mulmod(x2, x2, q)
                y := mulmod(mulmod(x4, x2, q), x, q)
            }

            // M4 = [[2,3,1,1],[1,2,3,1],[1,1,2,3],[3,1,1,2]] on one 4-lane
            // group. Plain adds; intermediates fit ~70 bits.
            function m4(x0, x1, x2, x3) -> y0, y1, y2, y3 {
                let t01 := add(x0, x1)
                let t23 := add(x2, x3)
                let t := add(t01, t23)
                y0 := add(t, add(t01, x1))
                y1 := add(t, add(x1, add(x2, x2)))
                y2 := add(t, add(t23, x3))
                y3 := add(t, add(x3, add(x0, x0)))
            }

            // External linear layer: M4 per group, then add per-column sums
            // across the 3 groups; reduced canonical at the end.
            function ext(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, q) ->
                b0,
                b1,
                b2,
                b3,
                b4,
                b5,
                b6,
                b7,
                b8,
                b9,
                b10,
                b11
            {
                b0, b1, b2, b3 := m4(a0, a1, a2, a3)
                b4, b5, b6, b7 := m4(a4, a5, a6, a7)
                b8, b9, b10, b11 := m4(a8, a9, a10, a11)
                let c0 := add(b0, add(b4, b8))
                let c1 := add(b1, add(b5, b9))
                let c2 := add(b2, add(b6, b10))
                let c3 := add(b3, add(b7, b11))
                b0 := mod(add(b0, c0), q)
                b1 := mod(add(b1, c1), q)
                b2 := mod(add(b2, c2), q)
                b3 := mod(add(b3, c3), q)
                b4 := mod(add(b4, c0), q)
                b5 := mod(add(b5, c1), q)
                b6 := mod(add(b6, c2), q)
                b7 := mod(add(b7, c3), q)
                b8 := mod(add(b8, c0), q)
                b9 := mod(add(b9, c1), q)
                b10 := mod(add(b10, c2), q)
                b11 := mod(add(b11, c3), q)
            }

            // Initial external layer on the input state.
            s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11 := ext(s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, p)

            // First 4 full rounds (external rounds 0..3): add the 12 round
            // constants, S-box every lane, external layer.
            for { let r := 0 } lt(r, 4) { r := add(r, 1) } {
                let rcp := add(rcPtr, mul(r, 0x180)) // 12 words per round
                s0 := sb(add(s0, mload(rcp)), p)
                s1 := sb(add(s1, mload(add(rcp, 0x20))), p)
                s2 := sb(add(s2, mload(add(rcp, 0x40))), p)
                s3 := sb(add(s3, mload(add(rcp, 0x60))), p)
                s4 := sb(add(s4, mload(add(rcp, 0x80))), p)
                s5 := sb(add(s5, mload(add(rcp, 0xa0))), p)
                s6 := sb(add(s6, mload(add(rcp, 0xc0))), p)
                s7 := sb(add(s7, mload(add(rcp, 0xe0))), p)
                s8 := sb(add(s8, mload(add(rcp, 0x100))), p)
                s9 := sb(add(s9, mload(add(rcp, 0x120))), p)
                s10 := sb(add(s10, mload(add(rcp, 0x140))), p)
                s11 := sb(add(s11, mload(add(rcp, 0x160))), p)
                s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11 :=
                    ext(s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, p)
            }

            // 22 partial rounds: RC + S-box on lane 0 only, then the internal
            // layer s[i] = sum + s[i]*diag[i]. `sum` is reduced canonical each
            // round, so lanes stay < 2^65 and never overflow.
            {
                let intRc := add(rcPtr, 0xc00) // 96 * 32
                let dg := add(rcPtr, 0xec0) // 118 * 32
                for { let r := 0 } lt(r, 22) { r := add(r, 1) } {
                    s0 := sb(add(s0, mload(add(intRc, shl(5, r)))), p)
                    let sum :=
                        mod(
                            add(
                                add(add(add(s0, s1), add(s2, s3)), add(add(s4, s5), add(s6, s7))),
                                add(add(s8, s9), add(s10, s11))
                            ),
                            p
                        )
                    s0 := add(sum, mulmod(s0, mload(dg), p))
                    s1 := add(sum, mulmod(s1, mload(add(dg, 0x20)), p))
                    s2 := add(sum, mulmod(s2, mload(add(dg, 0x40)), p))
                    s3 := add(sum, mulmod(s3, mload(add(dg, 0x60)), p))
                    s4 := add(sum, mulmod(s4, mload(add(dg, 0x80)), p))
                    s5 := add(sum, mulmod(s5, mload(add(dg, 0xa0)), p))
                    s6 := add(sum, mulmod(s6, mload(add(dg, 0xc0)), p))
                    s7 := add(sum, mulmod(s7, mload(add(dg, 0xe0)), p))
                    s8 := add(sum, mulmod(s8, mload(add(dg, 0x100)), p))
                    s9 := add(sum, mulmod(s9, mload(add(dg, 0x120)), p))
                    s10 := add(sum, mulmod(s10, mload(add(dg, 0x140)), p))
                    s11 := add(sum, mulmod(s11, mload(add(dg, 0x160)), p))
                }
            }

            // Last 4 full rounds (external rounds 4..7).
            for { let r := 4 } lt(r, 8) { r := add(r, 1) } {
                let rcp := add(rcPtr, mul(r, 0x180))
                s0 := sb(add(s0, mload(rcp)), p)
                s1 := sb(add(s1, mload(add(rcp, 0x20))), p)
                s2 := sb(add(s2, mload(add(rcp, 0x40))), p)
                s3 := sb(add(s3, mload(add(rcp, 0x60))), p)
                s4 := sb(add(s4, mload(add(rcp, 0x80))), p)
                s5 := sb(add(s5, mload(add(rcp, 0xa0))), p)
                s6 := sb(add(s6, mload(add(rcp, 0xc0))), p)
                s7 := sb(add(s7, mload(add(rcp, 0xe0))), p)
                s8 := sb(add(s8, mload(add(rcp, 0x100))), p)
                s9 := sb(add(s9, mload(add(rcp, 0x120))), p)
                s10 := sb(add(s10, mload(add(rcp, 0x140))), p)
                s11 := sb(add(s11, mload(add(rcp, 0x160))), p)
                s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11 :=
                    ext(s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, p)
            }

            mstore(st, s0)
            mstore(add(st, 0x20), s1)
            mstore(add(st, 0x40), s2)
            mstore(add(st, 0x60), s3)
            mstore(add(st, 0x80), s4)
            mstore(add(st, 0xa0), s5)
            mstore(add(st, 0xc0), s6)
            mstore(add(st, 0xe0), s7)
            mstore(add(st, 0x100), s8)
            mstore(add(st, 0x120), s9)
            mstore(add(st, 0x140), s10)
            mstore(add(st, 0x160), s11)
        }
    }

    /// @notice plonky2 `hash_no_pad`: overwrite-mode sponge, no padding.
    /// @dev `elts` must be non-empty canonical field elements.
    function hashNoPad(uint256[] memory elts, uint256 rcPtr) internal pure returns (uint256[4] memory out) {
        uint256[12] memory st;
        uint256 n = elts.length;
        uint256 i;
        while (i < n) {
            uint256 k = n - i < 8 ? n - i : 8;
            // Overwrite lanes 0..k-1 only; lanes k..7 retain prior output.
            for (uint256 j = 0; j < k; ++j) {
                st[j] = elts[i + j];
            }
            permute(st, rcPtr);
            i += k;
        }
        out[0] = st[0];
        out[1] = st[1];
        out[2] = st[2];
        out[3] = st[3];
    }

    /// @notice plonky2 `two_to_one` (compress): one permutation over
    ///         [l0..l3, r0..r3, 0, 0, 0, 0], squeeze lanes 0..3.
    function twoToOne(uint256[4] memory l, uint256[4] memory r, uint256 rcPtr)
        internal
        pure
        returns (uint256[4] memory out)
    {
        uint256[12] memory st;
        st[0] = l[0];
        st[1] = l[1];
        st[2] = l[2];
        st[3] = l[3];
        st[4] = r[0];
        st[5] = r[1];
        st[6] = r[2];
        st[7] = r[3];
        permute(st, rcPtr);
        out[0] = st[0];
        out[1] = st[1];
        out[2] = st[2];
        out[3] = st[3];
    }

    /// @notice Merkle fold with path-bit swap (mirror hash.rs `fold`):
    ///         bit set → H(sibling, cur), else H(cur, sibling).
    function fold(uint256[4] memory cur, uint256[4] memory sib, bool bit, uint256 rcPtr)
        internal
        pure
        returns (uint256[4] memory)
    {
        return bit ? twoToOne(sib, cur, rcPtr) : twoToOne(cur, sib, rcPtr);
    }

    /// @notice Packs a digest into the bridge's bytes32 encoding:
    ///         LE64(e0) ‖ LE64(e1) ‖ LE64(e2) ‖ LE64(e3)
    ///         (element 0 first, each limb's bytes little-endian). Matches
    ///         mirror server.rs `le_digest` / prover wrapper_circuit.rs.
    function pack(uint256[4] memory d) internal pure returns (bytes32 out) {
        out = bytes32((rev8(d[0]) << 192) | (rev8(d[1]) << 128) | (rev8(d[2]) << 64) | rev8(d[3]));
    }

    /// @notice Inverse of `pack`. Limbs are NOT range-checked against p —
    ///         callers compare packed bytes, never trust unpacked limbs.
    function unpack(bytes32 b) internal pure returns (uint256[4] memory d) {
        uint256 w = uint256(b);
        d[0] = rev8(w >> 192);
        d[1] = rev8((w >> 128) & 0xFFFFFFFFFFFFFFFF);
        d[2] = rev8((w >> 64) & 0xFFFFFFFFFFFFFFFF);
        d[3] = rev8(w & 0xFFFFFFFFFFFFFFFF);
    }

    /// @dev Byte-reverses a u64.
    function rev8(uint256 x) internal pure returns (uint256) {
        x = ((x & 0x00FF00FF00FF00FF) << 8) | ((x >> 8) & 0x00FF00FF00FF00FF);
        x = ((x & 0x0000FFFF0000FFFF) << 16) | ((x >> 16) & 0x0000FFFF0000FFFF);
        x = ((x & 0x00000000FFFFFFFF) << 32) | (x >> 32);
        return x & 0xFFFFFFFFFFFFFFFF;
    }
}
