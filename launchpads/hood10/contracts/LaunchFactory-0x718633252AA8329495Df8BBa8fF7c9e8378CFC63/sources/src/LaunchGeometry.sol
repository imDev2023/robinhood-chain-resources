// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {FullMath} from "@uniswap/v4-core/src/libraries/FullMath.sol";
import {FixedPointMathLib} from "solmate/src/utils/FixedPointMathLib.sol";

/// @notice The pure geometry of a launch: where the range sits, where the price
///         opens, and how much quote the range can absorb.
///
/// @dev    Split out of `LaunchFactory` because that contract crossed EIP-170.
///         At 25,425 bytes of runtime it could not be deployed at all, and the
///         optimizer could not close the gap -- one run per call site still left
///         it 123 bytes over, so the code was genuinely too large rather than
///         merely inefficiently compiled.
///
///         These three functions were the right things to move. They are pure,
///         they touch no storage and no immutables, and between them they pull
///         in TickMath and FullMath, which are the heaviest dependencies in the
///         file. Declared `public` rather than `internal` on purpose: an
///         internal library function is inlined into its caller and saves
///         nothing, while a public one is deployed once and reached by
///         delegatecall.
///
///         The cost is a delegatecall per call and one more address to link at
///         deploy time. The benefit is that the factory has room again, which
///         it needs: it cannot be changed after deployment, so being 123 bytes
///         from the ceiling is not a place to ship from.
library LaunchGeometry {
    error BadTickRange();

    /// @notice The tick bounds of the one-sided position that IS the curve.
    ///
    /// @dev    The whole supply valued at `openFdv` gives the opening ratio
    ///         directly; the range then extends in whichever direction buying
    ///         pushes the price, which is up when the token is currency0 and
    ///         down when it is currency1.
    function range(bool quoteIsCurrency0, uint256 supply, uint256 openFdv, int24 rangeTicks, int24 spacing)
        public
        pure
        returns (int24 lower, int24 upper)
    {
        // ratio = amount(currency1) / amount(currency0), as a fixed point whose
        // square root lands in X96.
        //
        // The scale is chosen rather than fixed at 192, because 192 does not
        // always fit. A 100B supply against a 6-decimal quote opening at 3,400
        // -- both offered on the launch page, two clicks apart -- gives
        // 1e29 * 2^192 / 3.4e9 = 1.85e77, past the 1.16e77 that a uint256
        // holds. mulDiv reverts there, BEFORE the BadTickRange check below ever
        // runs, so the creator paid gas for a bare "execution reverted" with no
        // reason. Worse, it depended on which side the freshly created token
        // address sorted to, so the same form submitted twice failed once.
        //
        // Reducing the scale by an even number of bits and giving half of them
        // back after the square root is exact: sqrt(x * 2^(192-2k)) * 2^k is
        // sqrt(x * 2^192). Even, so the halving is not a truncation. Adaptive,
        // so precision is only given up where it must be -- a fixed smaller
        // scale would zero the low bits of every price, including the small
        // ones that cannot spare them.
        (uint256 num, uint256 den) = quoteIsCurrency0 ? (supply, openFdv) : (openFdv, supply);
        uint256 shift = 192;
        {
            uint256 head = _bits(num) + shift;
            uint256 room = _bits(den) + 255;
            if (head > room) {
                uint256 excess = head - room;
                if (excess & 1 == 1) excess += 1;
                shift = shift > excess ? shift - excess : 0;
            }
        }
        uint256 sq = FixedPointMathLib.sqrt(FullMath.mulDiv(num, 1 << shift, den)) << ((192 - shift) >> 1);
        if (sq < TickMath.MIN_SQRT_PRICE || sq > TickMath.MAX_SQRT_PRICE) revert BadTickRange();

        int24 center = TickMath.getTickAtSqrtPrice(uint160(sq));
        int24 span = (rangeTicks / spacing) * spacing;
        if (span == 0) span = spacing;

        // Align inward so both bounds stay on the spacing grid whichever way
        // the division truncated.
        int24 c = (center / spacing) * spacing;

        if (quoteIsCurrency0) {
            // token is currency1: price falls as the token is bought out.
            upper = c;
            lower = c - span;
        } else {
            // token is currency0: price rises as the token is bought out.
            lower = c;
            upper = c + span;
        }
        if (lower < TickMath.MIN_TICK || upper > TickMath.MAX_TICK) revert BadTickRange();
    }

    /// @dev How many bits a value occupies. Used to decide the fixed-point
    ///      scale without performing the multiplication that would overflow.
    function _bits(uint256 x) private pure returns (uint256 n) {
        while (x != 0) {
            x >>= 1;
            unchecked {
                ++n;
            }
        }
    }

    /// @notice Where the pool opens, given the range it will hold.
    ///
    /// @dev    A one-sided position holds only the currency the price has not
    ///         yet reached. If the token is currency1, price must open at or
    ///         above the range and falls as the token is bought; if it is
    ///         currency0, price opens at or below and rises. Opening exactly on
    ///         the boundary tick puts 100% of the supply on the token side.
    function openingSqrtPrice(bool quoteIsCurrency0, int24 tickLower, int24 tickUpper)
        public
        pure
        returns (uint160)
    {
        return quoteIsCurrency0
            ? TickMath.getSqrtPriceAtTick(tickUpper) // token == currency1
            : TickMath.getSqrtPriceAtTick(tickLower); // token == currency0
    }

    /// @notice The most quote a fully-traversed range can ever absorb.
    ///
    /// @dev    The same arithmetic v4's own LiquidityAmounts uses, written out
    ///         because the periphery copy this repo imports carries only the
    ///         liquidity-from-amount direction, and reaching into a test utility
    ///         for production maths is not a trade worth making.
    function quoteCapacity(uint160 lower, uint160 upper, uint128 liquidity, bool quoteIsCurrency0)
        public
        pure
        returns (uint256)
    {
        if (quoteIsCurrency0) {
            // amount0 = L << 96 * (upper - lower) / upper / lower
            return FullMath.mulDiv(uint256(liquidity) << 96, upper - lower, upper) / lower;
        }
        // amount1 = L * (upper - lower) / 2^96
        return FullMath.mulDiv(liquidity, upper - lower, 1 << 96);
    }
}
