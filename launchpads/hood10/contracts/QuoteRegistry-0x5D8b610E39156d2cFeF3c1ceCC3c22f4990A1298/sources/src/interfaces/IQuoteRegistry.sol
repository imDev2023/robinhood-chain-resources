// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";

/// @notice How much trust the fee pipeline extends to a given quote asset.
///
/// @dev    A tier never gates *launching* -- anyone may quote a pool in anything.
///         It gates only what the router is willing to do with the fees that
///         accrue in it. An asset nobody can safely sell parks forever rather
///         than being dumped into a thin book or handed to a honeypot.
enum QuoteTier {
    UNSUPPORTED, // never auto-swept; park only
    NATIVE, // native ETH or WETH -- no swap needed
    STOCK, // ERC-8056 stock token with a Chainlink feed
    ECOSYSTEM, // HOOD10 and its basket constituents
    EXOTIC // any other ERC-20, including memecoins
}

struct QuotePolicy {
    QuoteTier tier;
    /// @dev False parks fees in the tab instead of selling them. The launch still works.
    bool sweepable;
    /// @dev Ceiling on one sale, as a share of the target pool's own depth.
    ///
    ///      This is what makes a permissionless sale safe without an oracle.
    ///      Sandwiching only pays when the trade being front-run is large
    ///      relative to the pool: the attacker has to move the price, eat their
    ///      own slippage in both directions, and pay gas. Keep the sale small
    ///      enough and the arithmetic never works out for them, whatever the
    ///      price happens to be.
    uint16 maxPoolFractionBps;
    /// @dev Below this it is not worth its own gas; fees keep accruing.
    uint128 minSweep;
    /// @dev Absolute backstop on one sale or auction lot, independent of depth.
    uint128 maxSweepNotional;
}

interface IQuoteRegistry {
    function policyFor(Currency quote) external view returns (QuotePolicy memory);
    function classify(Currency quote) external view returns (QuoteTier);
    function isStockToken(Currency quote) external view returns (bool);

    /// @notice The chain's WETH. Already a public immutable on the deployed
    ///         registry, so naming it here reaches an existing getter rather
    ///         than requiring a new registry.
    function weth() external view returns (address);
}
