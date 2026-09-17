// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.26;

import {PoolId} from "@uniswap/v4-core/src/types/PoolId.sol";

import {IBagsFactory} from "src/interfaces/IBagsFactory.sol";

/// @title IBagsLens
/// @notice Interface for the stateless read-only lens over the Bags launchpad (integrator/indexer surface)
/// @author Bags
interface IBagsLens {
    /// @notice Aggregated on-chain state of a launched token
    /// @param exists True when the token was launched by the Bags factory
    /// @param migrated True once the bonding curve migrated into the Uniswap v4 pool
    /// @param curve Bonding curve clone address
    /// @param feeShare FeeShare clone address
    /// @param poolId Deterministic Uniswap v4 pool id of the (future) migration pool
    /// @param thresholdQuote Net quote raise (wei) snapshotted at launch that triggers migration
    /// @param realQuoteReserves Tracked real quote reserves in the curve (== thresholdQuote after migration)
    /// @param realTokenReserves Tracked real token reserves held by the curve
    /// @param virtualTokenReserves Current virtual token reserve used for curve pricing
    /// @param virtualQuoteReserves Current virtual quote reserve used for curve pricing
    /// @param priceQuotePerToken Curve spot price in quote wei per 1e18 token units
    ///        (frozen at the LP seed price after migration; read live pool price via StateView/V4Quoter)
    /// @param bondingProgressPct Bonding progress in percent (0-100, 100 at migration)
    /// @param totalRaised Net quote raised: realQuoteReserves pre-migration, thresholdQuote after
    struct TokenState {
        bool exists;
        bool migrated;
        address curve;
        address feeShare;
        PoolId poolId;
        uint256 thresholdQuote;
        uint256 realQuoteReserves;
        uint256 realTokenReserves;
        uint256 virtualTokenReserves;
        uint256 virtualQuoteReserves;
        uint256 priceQuotePerToken;
        uint256 bondingProgressPct;
        uint256 totalRaised;
    }

    /// @notice Zero address provided for the factory
    error BagsLens_ZeroAddressFactory();

    /// @notice Bags factory this lens reads from
    /// @return factory Factory instance
    function FACTORY() external view returns (IBagsFactory factory);

    /// @notice Aggregated state of a single launched token
    /// @param token Token address
    /// @return state Token state (zeroed with exists=false when the token is unknown)
    function getTokenState(
        address token
    ) external view returns (TokenState memory state);

    /// @notice Batch variant of {getTokenState}
    /// @param tokens Token addresses
    /// @return states Token states in input order
    function getTokenStates(
        address[] calldata tokens
    ) external view returns (TokenState[] memory states);

    /// @notice WETH amount currently claimable by a user from a token's FeeShare
    /// @param token Token address
    /// @param user Claimer address
    /// @return amount Claimable WETH in wei (0 when the token is unknown)
    function claimableOf(
        address token,
        address user
    ) external view returns (uint256 amount);
}
