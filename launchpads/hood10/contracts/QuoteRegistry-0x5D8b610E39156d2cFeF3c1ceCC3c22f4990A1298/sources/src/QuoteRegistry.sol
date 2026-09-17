// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";

import {IQuoteRegistry, QuoteTier, QuotePolicy} from "./interfaces/IQuoteRegistry.sol";
import {IStockToken} from "./interfaces/IStockToken.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/// @title QuoteRegistry
/// @notice Classifies quote assets and sizes the lots the fee router sells them in.
///
/// @dev    This is deliberately NOT an allowlist. The incumbent pad on this
///         chain restricts launches to "an approved ERC-20"; letting a creator
///         denominate a pool in literally anything is the product, so the gate
///         moved downstream: launching is open, and the tier only decides how
///         the router sells what accrues. An asset marked unsweepable parks in
///         the tab and the pool trades on regardless.
contract QuoteRegistry is IQuoteRegistry, Ownable2Step {
    error ZeroAddress();
    error FractionTooLarge(uint16 bps);

    event PolicySet(Currency indexed quote, QuotePolicy policy);
    event PolicyCleared(Currency indexed quote);
    event DefaultSet(QuoteTier indexed tier, QuotePolicy policy);
    event EcosystemSet(Currency indexed quote, bool member);

    /// @notice Ceiling on how much of a pool one sale may take. The size cap IS
    ///         the sandwich defence, so leaving it unbounded would let a
    ///         mis-set policy delete the protection entirely.
    uint16 public constant MAX_POOL_FRACTION_BPS = 1_000; // 10%

    address public immutable weth;

    mapping(Currency => QuotePolicy) private _explicit;
    mapping(Currency => bool) public hasExplicitPolicy;
    mapping(QuoteTier => QuotePolicy) private _defaults;
    /// @notice HOOD10 and its basket constituents, which get larger lot sizes
    ///         because their depth is known and they are the assets the index
    ///         buys anyway.
    mapping(Currency => bool) public isEcosystem;

    constructor(address weth_, address owner_) Ownable(owner_) {
        if (weth_ == address(0)) revert ZeroAddress();
        weth = weth_;

        // Native and WETH pass straight through: no sale, so nothing to size.
        _defaults[QuoteTier.NATIVE] = QuotePolicy({
            tier: QuoteTier.NATIVE,
            sweepable: true,
            maxPoolFractionBps: 0,
            minSweep: 10, // 0.01 tokens; scaled by decimals in policyFor
            maxSweepNotional: type(uint128).max
        });

        // The fractions below are the whole sandwich defence, and they are
        // tighter where depth is thinner or less trustworthy. An asset with no
        // route at all ignores them entirely and goes to auction instead.
        _defaults[QuoteTier.STOCK] = QuotePolicy({
            tier: QuoteTier.STOCK,
            sweepable: true,
            maxPoolFractionBps: 50, // 0.5%
            minSweep: 100, // 0.1
            maxSweepNotional: 25_000_000 // 25k tokens
        });

        _defaults[QuoteTier.ECOSYSTEM] = QuotePolicy({
            tier: QuoteTier.ECOSYSTEM,
            sweepable: true,
            maxPoolFractionBps: 100, // 1%
            minSweep: 1_000, // 1
            maxSweepNotional: 250_000_000 // 250k tokens
        });

        _defaults[QuoteTier.EXOTIC] = QuotePolicy({
            tier: QuoteTier.EXOTIC,
            sweepable: true,
            maxPoolFractionBps: 25, // 0.25%
            minSweep: 1_000, // 1
            maxSweepNotional: 50_000_000 // 50k tokens
        });

        _defaults[QuoteTier.UNSUPPORTED] = QuotePolicy({
            tier: QuoteTier.UNSUPPORTED, sweepable: false, maxPoolFractionBps: 0, minSweep: 0, maxSweepNotional: 0
        });
    }

    // ────────────────────────────── reads ──────────────────────────────

    /// @notice True if `quote` answers `uiMultiplier()` with a non-zero value.
    ///
    /// @dev    Informational since the oracle path was removed: nothing in the
    ///         fee pipeline reads a price any more. It still picks the tier, and
    ///         the tier still picks the lot size.
    ///
    /// @dev    Probed rather than listed. Robinhood mints new Stock Tokens
    ///         continuously and a hardcoded list would be stale within a week;
    ///         the selector is the thing that actually distinguishes them.
    ///         A zero multiplier is rejected because it would make every price
    ///         read as zero, which is worse than not recognising the token.
    function isStockToken(Currency quote) public view returns (bool) {
        address a = Currency.unwrap(quote);
        if (a == address(0) || a.code.length == 0) return false;
        (bool ok, bytes memory ret) = a.staticcall(abi.encodeWithSelector(IStockToken.uiMultiplier.selector));
        if (!ok || ret.length != 32) return false;
        return abi.decode(ret, (uint256)) != 0;
    }

    function classify(Currency quote) public view returns (QuoteTier) {
        address a = Currency.unwrap(quote);
        if (a == address(0) || a == weth) return QuoteTier.NATIVE;
        if (isEcosystem[quote]) return QuoteTier.ECOSYSTEM;
        if (isStockToken(quote)) return QuoteTier.STOCK;
        if (a.code.length == 0) return QuoteTier.UNSUPPORTED;
        return QuoteTier.EXOTIC;
    }

    /// @notice The policy actually applied to a quote asset.
    ///
    /// @dev    Tier defaults are written in MILLI-TOKENS (thousandths of one
    ///         whole token) and scaled to the asset's own decimals here.
    ///         Hardcoding 1e18 is a trap on this chain: USDG -- the deepest
    ///         pool and the unit every Stock Token is quoted in -- has 6
    ///         decimals, so a literal 1e18 minimum would demand a trillion USDG
    ///         before a sweep was ever permitted and USDG fees would park
    ///         forever. Thousandths rather than whole tokens because the
    ///         sensible ether minimum is 0.01, not 1.
    function policyFor(Currency quote) external view returns (QuotePolicy memory p) {
        if (hasExplicitPolicy[quote]) return _explicit[quote];
        p = _defaults[classify(quote)];
        uint256 unit = 10 ** _decimalsOf(quote);
        p.minSweep = _scale(p.minSweep, unit);
        p.maxSweepNotional = _scale(p.maxSweepNotional, unit);
    }

    /// @dev Defaults hold milli-tokens; multiply BEFORE dividing so a
    ///      low-decimal asset does not round its whole policy to zero.
    function _scale(uint128 milli, uint256 unit) private pure returns (uint128) {
        if (milli == 0 || milli == type(uint128).max) return milli;
        uint256 v = (uint256(milli) * unit) / 1000;
        return v > type(uint128).max ? type(uint128).max : uint128(v);
    }

    /// @notice Decimals of a quote asset. Native ether and anything that does
    ///         not answer are treated as 18.
    function _decimalsOf(Currency quote) private view returns (uint8) {
        address a = Currency.unwrap(quote);
        if (a == address(0)) return 18;
        try IERC20Metadata(a).decimals() returns (uint8 d) {
            // Zero is a real answer, not a failure. Treating it as 18 scaled
            // every minimum by 1e18, so a 0-decimal quote needed a billion
            // billion tokens of fees before a sweep was allowed -- its platform
            // lane, and the 70% dividend inside it, stalled silently forever.
            // Only the genuinely unusable answer falls back.
            return d > 36 ? 18 : d;
        } catch {
            return 18;
        }
    }

    function defaultFor(QuoteTier tier) external view returns (QuotePolicy memory) {
        return _defaults[tier];
    }

    // ────────────────────────────── admin ──────────────────────────────

    function setPolicy(Currency quote, QuotePolicy calldata policy) external onlyOwner {
        if (policy.maxPoolFractionBps > MAX_POOL_FRACTION_BPS) revert FractionTooLarge(policy.maxPoolFractionBps);
        _explicit[quote] = policy;
        hasExplicitPolicy[quote] = true;
        emit PolicySet(quote, policy);
    }

    function clearPolicy(Currency quote) external onlyOwner {
        delete _explicit[quote];
        hasExplicitPolicy[quote] = false;
        emit PolicyCleared(quote);
    }

    function setDefault(QuoteTier tier, QuotePolicy calldata policy) external onlyOwner {
        if (policy.maxPoolFractionBps > MAX_POOL_FRACTION_BPS) revert FractionTooLarge(policy.maxPoolFractionBps);
        _defaults[tier] = policy;
        emit DefaultSet(tier, policy);
    }

    function setEcosystem(Currency quote, bool member) external onlyOwner {
        isEcosystem[quote] = member;
        emit EcosystemSet(quote, member);
    }
}
