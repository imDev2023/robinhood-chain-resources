// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.26;

// Local interfaces
import {IBagsBondingCurve} from "src/interfaces/IBagsBondingCurve.sol";
import {IBagsFactory} from "src/interfaces/IBagsFactory.sol";
import {IBagsFeeShare} from "src/interfaces/IBagsFeeShare.sol";
import {IBagsLens} from "src/interfaces/IBagsLens.sol";

/// @title BagsLens
/// @notice Stateless read-only lens over the Bags launchpad for integrators and indexers.
///         Aggregates the factory registry and per-token curve/fee-share state into one call.
/// @dev Zero protocol risk: no state, no auth, view-only; deployable/replaceable freely.
///
///      Quoting guidance (two-phase trading, PORT_PLAN §9.1):
///      - Pre-migration (`migrated == false`): quote and trade on the bonding curve itself via
///        `IBagsBondingCurve.quoteBuy` / `quoteSell` and `buy`/`buyFor`/`sell`/`sellFor`.
///      - Post-migration (`migrated == true`): the pool is a standard Uniswap v4 dynamic-fee pool;
///        quote with the official `V4Quoter` and read pool state via `StateView` (addresses in
///        deployments/<network>.json and PORT_PLAN §14), trade through the UniversalRouter
///        (`V4_SWAP`). This lens deliberately does not wrap the quoter.
///      - Caveats: a 2% hook fee is charged on the WETH leg of every pool swap, and exact-output
///        swaps where WETH is the specified currency revert by design.
/// @author Bags
contract BagsLens is IBagsLens {
    /// @notice Bags factory this lens reads from
    IBagsFactory public immutable FACTORY;

    /// @notice Creates the lens bound to one factory
    /// @param factory Bags factory address
    constructor(
        address factory
    ) {
        if (factory == address(0)) revert BagsLens_ZeroAddressFactory();
        FACTORY = IBagsFactory(factory);
    }

    // ====================================================================
    // EXTERNAL FUNCTIONS
    // ====================================================================

    /// @notice Batch variant of {getTokenState}
    /// @param tokens Token addresses
    /// @return states Token states in input order
    function getTokenStates(
        address[] calldata tokens
    ) external view override returns (TokenState[] memory states) {
        uint256 length = tokens.length;
        states = new TokenState[](length);
        for (uint256 i; i < length; ++i) {
            states[i] = getTokenState(tokens[i]);
        }
    }

    /// @notice WETH amount currently claimable by a user from a token's FeeShare
    /// @dev Includes only already-notified fees; pending hook accrual surfaces after
    ///      `BagsV4Hook.sweep(poolId)` (also poked best-effort by `claim`).
    /// @param token Token address
    /// @param user Claimer address
    /// @return amount Claimable WETH in wei (0 when the token is unknown)
    function claimableOf(
        address token,
        address user
    ) external view override returns (uint256 amount) {
        address feeShare = FACTORY.feeShareForToken(token);
        if (feeShare == address(0)) return 0;
        return IBagsFeeShare(feeShare).claimable(user);
    }

    // ====================================================================
    // PUBLIC FUNCTIONS
    // ====================================================================

    /// @notice Aggregated state of a single launched token
    /// @dev Unknown tokens return a zeroed struct with `exists == false` instead of reverting,
    ///      so batch calls never fail on a single bad address.
    /// @param token Token address
    /// @return state Token state snapshot
    function getTokenState(
        address token
    ) public view override returns (TokenState memory state) {
        address curve = FACTORY.curveForToken(token);
        if (curve == address(0)) return state;

        IBagsBondingCurve bondingCurve = IBagsBondingCurve(curve);
        address feeShare = FACTORY.feeShareForToken(token);

        state.exists = true;
        state.migrated = bondingCurve.migrated();
        state.curve = curve;
        state.feeShare = feeShare;
        // The FeeShare stores the poolId the factory computed at launch (byte-identical to the
        // key the curve initializes at migration)
        state.poolId = IBagsFeeShare(feeShare).poolId();
        state.thresholdQuote = bondingCurve.thresholdQuote();
        state.realQuoteReserves = bondingCurve.realQuoteReserves();
        state.realTokenReserves = bondingCurve.realTokenReserves();
        (state.virtualTokenReserves, state.virtualQuoteReserves) = bondingCurve.getVirtualReserves();
        state.priceQuotePerToken = bondingCurve.currentPrice();
        state.bondingProgressPct = bondingCurve.bondingProgress();
        // Net raise: capped by the snapshotted threshold once graduated
        state.totalRaised = state.migrated ? state.thresholdQuote : state.realQuoteReserves;
    }
}
