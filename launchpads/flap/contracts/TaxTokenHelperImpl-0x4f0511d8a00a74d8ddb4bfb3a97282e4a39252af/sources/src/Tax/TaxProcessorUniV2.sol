// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {TaxProcessorCore, TaxProcessorV2DispatchImpl, TaxProcessorAdminImpl} from "./TaxProcessorBase.sol";

interface IUniswapRouter02 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);
    function getAmountsIn(uint256 amountOut, address[] memory path) external view returns (uint256[] memory amounts);

    function factory() external pure returns (address);
}

interface ITaxTokenWithThreshold {
    function liquidationThreshold() external view returns (uint256);
}

/// @title TaxProcessorUniV2
/// @notice TaxProcessor for tokens that graduate to Uniswap V2 / V3 DEX pools.
///         Implements `_swapTokensForQuote` and `_addLiquidity` using the Uniswap V2 router.
///
/// @dev Replaces the former monolithic TaxProcessorV2. All shared logic now lives in
///      TaxProcessorCore; this contract only provides the V2-specific DEX interactions.
///      Deployed as a Minimal Proxy (clone) — constructor sets immutables shared by all clones.
contract TaxProcessorUniV2 is TaxProcessorCore {
    using SafeERC20 for IERC20;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(address weth_, address flapBlackHole_, address portal_, address swapRegistry_, address adminImpl_)
        TaxProcessorCore(
            weth_,
            flapBlackHole_,
            portal_,
            swapRegistry_,
            address(new TaxProcessorV2DispatchImpl(weth_, flapBlackHole_, portal_, swapRegistry_)),
            adminImpl_
        )
    {
        _requireAddr(adminImpl_, "adminImpl cannot be zero address");
    }

    // ─────────────────────────────────────────────────────────────────────────
    // V2 DEX-specific implementations
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Swap tax tokens for quote tokens via Uniswap V2 router.
    function _swapTokensForQuote(uint256 amount) internal override returns (uint256 quoteReceived) {
        IERC20(taxToken).safeApprove(router, 0);
        IERC20(taxToken).safeApprove(router, amount);

        address[] memory path = new address[](2);
        path[0] = taxToken;
        path[1] = quoteToken;

        uint256 quoteBefore = IERC20(quoteToken).balanceOf(address(this));

        // Mark the processor as mid-swap so any nested token-hook liquidation is parked on the
        // processor instead of being processed reentrantly inside this router call.
        // Note: if the router call below reverts, this entire frame reverts too, so `_swapping = true`
        // is automatically rolled back and cannot get stuck.
        _swapping = true;

        IUniswapRouter02(router)
            .swapExactTokensForTokensSupportingFeeOnTransferTokens(amount, 0, path, address(this), block.timestamp);
        _swapping = false;
        quoteReceived = IERC20(quoteToken).balanceOf(address(this)) - quoteBefore;
    }

    /// @notice Add liquidity to Uniswap V2 pool. LP tokens sent to DEAD_ADDRESS.
    function _addLiquidity(uint256 tokenAmount, uint256 quoteAmount)
        internal
        override
        returns (uint256 actualTokenUsed, uint256 actualQuoteUsed)
    {
        IERC20(taxToken).safeApprove(router, 0);
        IERC20(taxToken).safeApprove(router, tokenAmount);
        IERC20(quoteToken).safeApprove(router, 0);
        IERC20(quoteToken).safeApprove(router, quoteAmount);

        (uint256 amountA, uint256 amountB,) = IUniswapRouter02(router)
            .addLiquidity(taxToken, quoteToken, tokenAmount, quoteAmount, 0, 0, address(DEAD_ADDRESS), block.timestamp);

        actualTokenUsed = amountA;
        actualQuoteUsed = amountB;

        totalTokenAddedToLiquidity += actualTokenUsed;
        totalQuoteAddedToLiquidity += actualQuoteUsed;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Partial-liquidation smoothing (gap + 50% backlog drain)
    // ─────────────────────────────────────────────────────────────────────────

    function _quoteToTaxTokens(uint256 quoteAmount) internal view returns (uint256 tokenAmount) {
        if (quoteAmount == 0) return 0;

        address[] memory path = new address[](2);
        path[0] = taxToken;
        path[1] = quoteToken;

        // We are swapping tax token for quote, so we should the getAmountsIn
        try IUniswapRouter02(router).getAmountsIn(quoteAmount, path) returns (uint256[] memory amounts) {
            if (amounts.length >= 2) tokenAmount = amounts[0];
        } catch {}
    }

    function _processTaxTokensBody(uint256 taxAmount) internal override returns (int8 liqThresholdDirection) {
        uint256 gapQuote = liqSmoothingGapQuote;
        if (gapQuote == 0) return super._processTaxTokensBody(taxAmount);

        uint256 gapInTokens = _quoteToTaxTokens(gapQuote);
        if (gapInTokens == 0) return super._processTaxTokensBody(taxAmount);

        // Adjust gapInTokens to account for the fraction of input tokens that will actually be
        // swapped to quote.  Deflation is burned and self-dividends are parked without swapping,
        // so we need more total input tokens to generate gapQuote worth of swap output.
        // Worst-case assumption: all LP tokens are swapped (i.e. no existing LP-quote balance).
        // Note: deflationBps + dividendBps <= 10000 is enforced by setTaxConfig; if that invariant
        // were violated the subtraction below would revert (Solidity 0.8+ checked arithmetic).
        {
            uint256 swapBps = 10000 - uint256(_feeConfig.deflationBps);
            if (dividendToken == taxToken) {
                swapBps -= uint256(_feeConfig.dividendBps);
            }
            // If nothing would be swapped fall back to legacy full processing.
            if (swapBps == 0) return super._processTaxTokensBody(taxAmount);
            if (swapBps < 10000) {
                gapInTokens = gapInTokens * 10000 / swapBps;
            }
        }

        // Rearm the tax token so it keeps roughly (threshold - one base gap) on the token side.
        // This preserves the normal trigger cadence while leaving one gap to be processed now.
        uint256 threshold;
        try ITaxTokenWithThreshold(taxToken).liquidationThreshold() returns (uint256 t) {
            threshold = t;
        } catch {
            return super._processTaxTokensBody(taxAmount);
        }
        // Important: the amount returned to the token contract can only come from this round's
        // freshly pulled taxAmount. Previously deferred backlog must stay on the processor.
        uint256 returnedToToken = threshold > gapInTokens ? threshold - gapInTokens : 0;
        if (returnedToToken > taxAmount) returnedToToken = taxAmount;

        if (returnedToToken > 0) {
            IERC20(taxToken).safeTransfer(taxToken, returnedToToken);
        }

        // Whatever fresh tax is not sent back to the token becomes newly deferred backlog.
        // Only the fresh tax left after rearming is added into the processor-side backlog.
        uint256 backlogAdded = taxAmount - returnedToToken;
        // Merge the new backlog with any historical deferred balance accumulated earlier.
        // Combine newly deferred tokens with any backlog carried over from previous rounds.
        uint256 totalDeferred = deferredTaxTokenBalance + backlogAdded;

        // Base processing always consumes one gap. On top of that, we may drain up to 50%
        // of one extra gap from true historical backlog, but never more than the backlog left
        // after reserving the base gap.
        // Each round always processes one full base gap, and may drain up to an extra 50%
        // of that gap from historical backlog. The extra drain is capped by real backlog so
        // the final rounds naturally taper down instead of overselling.
        uint256 extraBacklogQuota = gapInTokens / 2;
        uint256 backlogAvailable = totalDeferred > gapInTokens ? totalDeferred - gapInTokens : 0;
        uint256 extraBacklogDrain = extraBacklogQuota < backlogAvailable ? extraBacklogQuota : backlogAvailable;
        // Total processed this round = one base gap + a bounded backlog drain.
        uint256 amountToProcess = gapInTokens + extraBacklogDrain;
        if (amountToProcess > totalDeferred) amountToProcess = totalDeferred;

        deferredTaxTokenBalance = totalDeferred - amountToProcess;

        if (amountToProcess > 0) {
            _processFeeToken(amountToProcess);
            emit FlapTaxProcessorProcessTaxTokens(taxToken, amountToProcess);
        }

        // Simplified direction strategy:
        //   • deferredTaxTokenBalance == 0 → all tokens consumed → increase threshold (+1)
        //   • deferredTaxTokenBalance  > 0 → backlog remains    → decrease threshold (−1)
        liqThresholdDirection = deferredTaxTokenBalance == 0 ? int8(1) : int8(-1);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // V4-specific overrides — no-op on V2 processors
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Unsupported on V2 processors.
    function registerV4LPFeeSource(uint8, address, address, uint256, uint256) external pure {
        revert("TaxProcessor: V4 fee source unsupported");
    }

    /// @notice No-op for V2 processors.
    ///         V4 LP fee dispatch only applies to Uniswap V4 pools; V2 tokens have no V4 LP position.
    function checkAndNotifyDispatch() external override {}
}


