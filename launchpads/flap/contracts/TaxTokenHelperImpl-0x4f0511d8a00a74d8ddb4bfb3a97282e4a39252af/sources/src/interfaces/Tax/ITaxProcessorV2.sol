// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {PackedFeeConfig, PackedFeeConfigV2, TaxProcessorInitParams} from "./ITaxProcessor.sol";

/// @notice Fee configuration struct (V3 — includes all 4 market/vault slots and their addresses)
/// @dev Returned by feeConfigV3(). Exposes the full configuration including multi-wallet
///      distribution and pluggable module addresses.
struct PackedFeeConfigV3 {
    // --- Base fields ---
    uint16 mktOrVaultBps1; // was marketBps
    uint16 mktOrVaultBps2; // was wallet1Bps — independent bps for slot 2
    uint16 mktOrVaultBps3; // was wallet2Bps — independent bps for slot 3
    uint16 mktOrVaultBps4; // was wallet3Bps — independent bps for slot 4
    uint16 deflationBps;
    uint16 lpBps;
    uint16 dividendBps;
    uint16 feeRate;
    bool isWeth;
    uint16 commissionBps;
    address dividendToken;
    // --- Market/vault addresses ---
    address mktOrVaultAddr1; // was marketAddress
    address mktOrVaultAddr2; // was wallet1
    address mktOrVaultAddr3; // was wallet2
    address mktOrVaultAddr4; // was wallet3
}

// ─────────────────────────────────────────────────────────────────────────────
// TaxProcessorV2InitParams
// ─────────────────────────────────────────────────────────────────────────────

/// @notice Initialization parameters for TaxProcessorV2.
/// @dev All distribution bps MUST sum to 10000:
///      mktOrVaultBps1 + mktOrVaultBps2 + mktOrVaultBps3 + mktOrVaultBps4
///      + deflationBps + lpBps + dividendBps == 10000
///      Additional wallet slots (2/3/4) can be reconfigured post-init via setWalletConfig().
struct TaxProcessorV2InitParams {
    address quoteToken;
    address router;
    address feeReceiver;
    // --- Wallet / market distribution (all explicit, must sum with deflation+lp+dividend to 10000) ---
    address mktOrVaultAddr1;
    uint16 mktOrVaultBps1;
    address mktOrVaultAddr2;
    uint16 mktOrVaultBps2;
    address mktOrVaultAddr3;
    uint16 mktOrVaultBps3;
    address mktOrVaultAddr4;
    uint16 mktOrVaultBps4;
    // --- Other distribution ---
    address dividendAddress;
    address taxToken;
    uint16 feeRate;
    uint16 deflationBps;
    uint16 lpBps;
    uint16 dividendBps;
    // --- V3 fields ---
    address dividendToken;
    address commissionReceiver;
    uint16 commissionBps;
    address converter;
    uint256 liqExpectedOutputAmount;
}

// ─────────────────────────────────────────────────────────────────────────────
// ITaxProcessorV2 interface
// ─────────────────────────────────────────────────────────────────────────────

/// @title ITaxProcessorV2
/// @notice Standalone interface for the new TaxProcessorV2 (TaxProcessorUniV2 / TaxProcessorUniV4).
///         Contains all base methods from ITaxProcessor plus V2-specific extensions:
///           • initialize(TaxProcessorV2InitParams) — includes primary beneficiary address
///           • Multi-wallet distribution (setWalletConfig / getWalletConfig)
///           • V4 LP fee processing (processLPFeeQuote / processLPFeeToken)
///           • feeConfigV3 view
///
/// @dev Does NOT inherit ITaxProcessor — the two interfaces are kept separate for clarity.
///      All ITaxProcessor methods are duplicated here so callers only need one import.
interface ITaxProcessorV2 {
    // ═════════════════════════════════════════════════════════════════════════
    // Initialization
    // ═════════════════════════════════════════════════════════════════════════

    /// @notice Initialize TaxProcessorV2.
    /// @dev Called ONCE during clone deployment.  Primary beneficiary (mktOrVaultAddr1) is set
    ///      directly from params.  Additional wallet slots (2/3/4) default to zero and can be
    ///      configured post-init via setWalletConfig().
    function initialize(TaxProcessorV2InitParams memory params) external;

    // ═════════════════════════════════════════════════════════════════════════
    // Core Tax Processing (same as ITaxProcessor)
    // ═════════════════════════════════════════════════════════════════════════

    /// @notice Process tax tokens by computing fees, splitting remainder, and handling distribution.
    /// @param taxAmount The total amount of tax tokens to process
    /// @return liqThresholdDirection A directional indicator for the liquidation threshold:
    ///         > 0 => increase threshold (swap output exceeded expected)
    ///         < 0 => decrease threshold (swap output was worse than expected)
    ///         == 0 => no change (output matched expected, or liqExpectedOutputAmount is zero)
    function processTaxTokens(uint256 taxAmount) external returns (int8 liqThresholdDirection);

    /// @notice Process bonding curve tax by accepting quote tokens and distributing them
    function processBondingCurveTax(uint256 quoteAmount) external;

    /// @notice Dispatch accumulated balances to receivers and dividend contract.
    function dispatch() external;

    // ═════════════════════════════════════════════════════════════════════════
    // View: Addresses (same as ITaxProcessor)
    // ═════════════════════════════════════════════════════════════════════════

    function getQuoteToken() external view returns (address);
    function weth() external view returns (address);
    function flapBlackHole() external view returns (address);
    function taxToken() external view returns (address);
    function router() external view returns (address);
    function feeReceiver() external view returns (address);
    function marketAddress() external view returns (address);
    function dividendAddress() external view returns (address);
    function commissionReceiver() external view returns (address);
    function converter() external view returns (address);
    function dividendToken() external view returns (address);
    function swapRegistry() external view returns (address);
    function forwardAddress() external view returns (address);
    function autoForward() external view returns (bool);

    // ═════════════════════════════════════════════════════════════════════════
    // View: Balances (same as ITaxProcessor)
    // ═════════════════════════════════════════════════════════════════════════

    function feeQuoteBalance() external view returns (uint256);
    function lpQuoteBalance() external view returns (uint256);
    function marketQuoteBalance() external view returns (uint256);
    function pendingDividendQuoteTokenBalance() external view returns (uint256);
    function dividendQuoteBalance() external view returns (uint256);
    function dividendTokenBalance() external view returns (uint256);
    function commissionQuoteBalance() external view returns (uint256);

    // ═════════════════════════════════════════════════════════════════════════
    // View: Config (same as ITaxProcessor)
    // ═════════════════════════════════════════════════════════════════════════

    function feeConfig() external view returns (PackedFeeConfig memory);
    function feeConfigV2() external view returns (PackedFeeConfigV2 memory);
    function commissionBps() external view returns (uint16);
    function liqExpectedOutputAmount() external view returns (uint256);
    function liqSmoothingGapQuote() external view returns (uint256);
    function deferredTaxTokenBalance() external view returns (uint256);
    function requiresMEVProtection() external view returns (bool);

    // ═════════════════════════════════════════════════════════════════════════
    // View: Totals (same as ITaxProcessor)
    // ═════════════════════════════════════════════════════════════════════════

    function totalDividendTokenSent() external view returns (uint256);
    function totalQuoteSentToDividend() external view returns (uint256);
    function totalQuoteAddedToLiquidity() external view returns (uint256);
    function totalTokenAddedToLiquidity() external view returns (uint256);
    function totalQuoteSentToMarketing() external view returns (uint256);

    // ═════════════════════════════════════════════════════════════════════════
    // V2 Extensions — Multi-wallet config
    // ═════════════════════════════════════════════════════════════════════════

    /// @notice Reconfigure market/vault wallet receivers after initialization.
    ///         mktOrVaultAddr1 is the primary beneficiary — its bps is auto-computed:
    ///         mktOrVaultBps1 = totalMarketBps - (bps2 + bps3 + bps4).
    ///         Only callable by the owner.
    function setWalletConfig(
        address mktOrVaultAddr1,
        address mktOrVaultAddr2,
        uint16 mktOrVaultBps2,
        address mktOrVaultAddr3,
        uint16 mktOrVaultBps3,
        address mktOrVaultAddr4,
        uint16 mktOrVaultBps4
    ) external;

    /// @notice Returns all 4 configured wallet/vault receivers and their basis points.
    function getWalletConfig()
        external
        view
        returns (
            address mktOrVaultAddr1,
            uint16 mktOrVaultBps1,
            address mktOrVaultAddr2,
            uint16 mktOrVaultBps2,
            address mktOrVaultAddr3,
            uint16 mktOrVaultBps3,
            address mktOrVaultAddr4,
            uint16 mktOrVaultBps4
        );

    // ═════════════════════════════════════════════════════════════════════════
    // V2 Extensions — Config view
    // ═════════════════════════════════════════════════════════════════════════

    /// @notice Returns the full fee configuration including all 4 wallet slots and addresses.
    function feeConfigV3() external view returns (PackedFeeConfigV3 memory);

    /// @notice Update only the protocol fee rate without changing any distribution percentages.
    ///         Typical lifecycle:
    ///           • Bonding curve (internal market): feeRate = 6000 (60%)
    ///           • DEX (external market):           feeRate = 4100 (41%)
    ///         Call this after the token graduates from the bonding curve to the DEX.
    ///         Only callable by the owner.
    /// @param feeRate_ New fee rate in basis points (0 – 10000).
    function setFeeRate(uint16 feeRate_) external;

    /// @notice Configure the quote-denominated smoothing gap bucket used for gradual liquidation.
    function setLiqSmoothingGapQuote(uint256 gap) external;

    // ═════════════════════════════════════════════════════════════════════════
    // V2 Extensions — Dispatch threshold (keeper signaling)
    // ═════════════════════════════════════════════════════════════════════════

    /// @notice Minimum pending LP fee amount that triggers a DispatchReady event.
    ///         0 = disabled (no threshold check / keeper signaling).
    function dispatchThreshold() external view returns (uint256);

    /// @notice Set the dispatch threshold. Only callable by the owner.
    /// @param threshold New threshold value (0 to disable)
    function setDispatchThreshold(uint256 threshold) external;

    /// @notice Configure forwarding of unsolicited native ETH received by the processor.
    /// @param receiver Receiver for forwarded ETH when enabled.
    /// @param enabled Whether forwarding is enabled.
    function setAutoForwarding(address receiver, bool enabled) external;

    /// @notice Register the V4 / PCS Infinity LP fee source metadata for this processor.
    /// @dev Called by Portal during DEX migration after the LP position NFTs are minted.
    ///      Only meaningful for TaxProcessorUniV4-style processors.
    /// @param migratorType The token migrator type encoded as uint8.
    /// @param poolManager The V4 / PCS pool manager address.
    /// @param positionManager The V4 / PCS position manager address.
    /// @param tokenId0 The first LP position NFT id.
    /// @param tokenId1 The second LP position NFT id.
    function registerV4LPFeeSource(
        uint8 migratorType,
        address poolManager,
        address positionManager,
        uint256 tokenId0,
        uint256 tokenId1
    ) external;

    /// @notice Query the pending (uncollected) V4 LP fees from the locker via Portal.
    /// @return pendingQuote Total pending quote-token fees across both lock positions
    /// @return pendingToken Total pending meme-token fees across both lock positions
    /// @return estimatedQuoteValue Spot-price estimate of the combined pending fee value in quote-token units
    function getPendingLPFees()
        external
        view
        returns (uint256 pendingQuote, uint256 pendingToken, uint256 estimatedQuoteValue);

    /// @notice Check pending V4 LP fees against the dispatch threshold.
    ///         If either the pending quote-token or meme-token fees exceed the threshold,
    ///         emits a DispatchReady event to signal off-chain keepers to call dispatch().
    ///         No-op if dispatchThreshold is 0 or if fees are below threshold.
    function checkAndNotifyDispatch() external;

    // ═════════════════════════════════════════════════════════════════════════
    // Events
    // ═════════════════════════════════════════════════════════════════════════

    event FlapTaxProcessorQuoteReconciled(address indexed taxToken, uint256 quoteAmount);
    event FlapTaxProcessorTokensReconciled(address indexed taxToken, uint256 tokenAmount);
    event FlapTaxProcessorWalletDistributed(address indexed wallet, uint16 bps, uint256 amount);
    event FlapDispatchReady(address indexed taxToken, uint256 pendingQuoteFees, uint256 pendingTokenFees);
    event FlapDispatchThresholdUpdated(uint256 oldThreshold, uint256 newThreshold);
}

