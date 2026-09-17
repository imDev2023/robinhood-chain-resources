// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "@openzeppelin-contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin-contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import {ITaxProcessor, PackedFeeConfig, PackedFeeConfigV2} from "src/interfaces/Tax/ITaxProcessor.sol";
import {BuyBackGuardUpgradeable} from "./BuyBackGuardUpgradeable.sol";
import {IDividend} from "src/interfaces/Tax/IDividend.sol";
import {IERC20Metadata} from "@openzeppelin/token/ERC20/extensions/IERC20Metadata.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {IMultiDexRouter} from "src/interfaces/IMultiDexRouter.sol";
import {IPortal, IPortalTradeV2, IPortalTypes} from "src/interfaces/IPortal.sol";
import {ISwapRegistry} from "src/interfaces/Tax/ISwapRegistry.sol";
import {SafeERC20} from "@openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {PackedFeeConfigV3, TaxProcessorV2InitParams} from "src/interfaces/Tax/ITaxProcessorV2.sol";

// ─────────────────────────────────────────────────────────────────────────────
// External protocol interfaces
// ─────────────────────────────────────────────────────────────────────────────

interface IWETH {
    function withdraw(uint256) external;
    function deposit() external payable;
}

interface ITaxProcessorMinimal {
    function reconcileToken(uint256 amount) external;
}

// ═════════════════════════════════════════════════════════════════════════════
// TaxProcessorBaseStorage — Shared state for all TaxProcessor variants
// ═════════════════════════════════════════════════════════════════════════════

/// @title TaxProcessorBaseStorage
/// @notice Abstract base contract containing shared state, events, modifiers and constructor
///         for all TaxProcessor variants and their dispatch implementations.
///
/// @dev Storage layout (27 slots from OZ base + our fields):
///      This is the canonical storage layout shared by TaxProcessorBaseStorage, TaxProcessorUniV2,
///      TaxProcessorUniV4, and all dispatch implementations. All contracts in the hierarchy
///      MUST inherit this and MUST NOT introduce storage between these fields.
abstract contract TaxProcessorBaseStorage is OwnableUpgradeable, ReentrancyGuardUpgradeable, BuyBackGuardUpgradeable {
    using SafeERC20 for IERC20;

    // --- Constants ---
    /// @notice Dead address for burning deflation tokens
    address public constant DEAD_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    /// @notice Default delay between successive keeper-facing V4 LP fee threshold checks.
    uint256 internal constant DEFAULT_DISPATCH_CHECK_COOLDOWN = 1 minutes;

    // --- Immutable Storage ---
    /// @notice WETH address for ETH conversion (immutable)
    address public immutable weth;

    /// @notice FlapBlackHole address (immutable)
    address public immutable flapBlackHole;

    /// @notice Portal address for swapping (immutable)
    address public immutable portal;

    /// @notice SwapRegistry address for dividend token swap path lookup (immutable).
    address public immutable swapRegistry;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(address weth_, address flapBlackHole_, address portal_, address swapRegistry_) {
        _requireAddr(weth_, "TaxProcessor: zero WETH address");
        _requireAddr(portal_, "TaxProcessor: zero portal address");
        weth = weth_;
        flapBlackHole = flapBlackHole_;
        portal = portal_;
        swapRegistry = swapRegistry_;
        _disableInitializers();
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Address validation helper
    // ─────────────────────────────────────────────────────────────────────────

    /// @dev Revert with `errMsg` when `addr` is the zero address.
    ///      Centralises all "zero address" checks so they read as assertions
    ///      rather than boiler-plate require + != address(0) noise.
    function _requireAddr(address addr, string memory errMsg) internal pure {
        require(addr != address(0), errMsg);
    }

    // --- Core Storage ---
    /// @notice Quote token (WETH or other ERC20)
    address public quoteToken;

    /// @notice Tax token (the token that calls processing)
    address public taxToken;

    /// @notice Uniswap V2 router address (also used as generic swap router)
    address public router;

    /// @notice Fee receiver address
    address public feeReceiver;

    /// @notice Market/vault receiver address 1 (beneficiary, only set if mktOrVaultBps1 > 0)
    address internal _mktOrVaultAddress1;

    /// @notice Dividend contract address (only set if dividendBps > 0)
    address public dividendAddress;

    /// @notice Accumulated quote token balance for fee
    uint256 public feeQuoteBalance;

    /// @notice Accumulated quote token balance for lp
    uint256 public lpQuoteBalance;

    /// @notice Accumulated quote token balance for market
    uint256 public marketQuoteBalance;

    /// @notice Accumulated quote token balance pending conversion to dividend token
    uint256 public pendingDividendQuoteTokenBalance;

    /// @notice Internal gas-optimized struct containing all fee configuration including commission
    /// @dev Packed into a single 256-bit storage slot:
    ///      mktOrVaultBps1/2/3/4 (4×16) + deflationBps/lpBps/dividendBps/feeRate/commissionBps (5×16) + isWeth (8)
    ///      = 9×16 + 8 = 152 bits (fits in one 32-byte slot).
    ///      mktOrVaultBps1 is the main beneficiary (was marketBps).
    ///      mktOrVaultBps2/3/4 are carved out of bps1 via setWalletConfig; their addresses live in _mktOrVaultAddress2/3/4.
    struct PackedFeeConfigInternal {
        uint16 mktOrVaultBps1; // was marketBps — main market/vault address
        uint16 mktOrVaultBps2; // independent bps for _mktOrVaultAddress2
        uint16 mktOrVaultBps3; // independent bps for _mktOrVaultAddress3
        uint16 mktOrVaultBps4; // independent bps for _mktOrVaultAddress4
        uint16 deflationBps;
        uint16 lpBps;
        uint16 dividendBps;
        uint16 feeRate;
        bool isWeth;
        uint16 commissionBps;
    }

    /// @notice All fee-related configuration packed into a single storage slot
    PackedFeeConfigInternal internal _feeConfig;

    /// @notice Total dividend tokens deposited to dividend contract
    uint256 public totalDividendTokenSent;

    /// @notice Total quote token added to liquidity
    uint256 public totalQuoteAddedToLiquidity;

    /// @notice Total tax token added to liquidity
    uint256 public totalTokenAddedToLiquidity;

    /// @notice Total quote token sent to marketing wallet
    uint256 public totalQuoteSentToMarketing;

    /// @notice Pre-bonding burn funds (deflation portion from bonding curve tax)
    uint256 public preBondBurnFunds;

    /// @notice Minimum buy back quote amount threshold
    uint256 public minBuyBackQuote;

    /// @notice Maximum gas limit for buy back operations
    uint256 public maxBuyBackGasLimit;

    // --- V3 Storage ---
    /// @notice The dividend token address.
    address public dividendToken;

    /// @notice Optional commission receiver. address(0) = disabled.
    address public commissionReceiver;

    /// @notice Accumulated quote-token commission waiting to be dispatched.
    uint256 public commissionQuoteBalance;

    /// @notice MEV-protected converter address for Case 3 dividend swaps.
    address public converter;

    /// @notice Reference output amount used to determine liquidation-threshold direction.
    uint256 public liqExpectedOutputAmount;

    /// @notice Accumulated dividend tokens waiting to be deposited to dividend contract.
    uint256 public dividendTokenBalance;

    // --- V2 Extension Storage (wallet/vault addresses for mktOrVaultBps2/3/4) ---
    address internal _mktOrVaultAddress2; // address for mktOrVaultBps2
    address internal _mktOrVaultAddress3; // address for mktOrVaultBps3
    address internal _mktOrVaultAddress4; // address for mktOrVaultBps4

    // --- V4 Dispatch Threshold Storage ---
    /// @notice Minimum pending LP fee (in estimated quote-token units) that triggers
    ///         a DispatchReady event. 0 = disabled (no keeper signaling).
    uint256 public dispatchThreshold;

    // --- Events ---
    event FlapTaxProcessorDispatchExecuted(
        address indexed taxToken, uint256 feeAmount, uint256 marketAmount, uint256 dividendAmount
    );
    event FlapTaxProcessorBurnExecuted(address indexed taxToken, uint256 quoteAmount, uint256 tokensBurned);
    event FlapTaxProcessorBuyBackSkipped(address indexed taxToken, uint256 quoteAmount, uint256 gasLeft, string reason);
    event FlapTaxProcessorPortalRefund(address indexed taxToken, uint256 refundAmount, bool isWeth);
    event FlapTaxProcessorDividendDepositSkipped(address indexed taxToken, uint256 amount, string reason);
    event FlapTaxProcessorTokensBurned(address indexed taxToken, uint256 amount);
    event FlapTaxProcessorBondingCurveTax(address indexed taxToken, uint256 quoteAmount);
    event FlapTaxProcessorProcessTaxTokens(address indexed taxToken, uint256 taxAmount);
    event FlapTaxProcessorTokensParked(address indexed taxToken, uint256 taxAmount);
    event FlapTaxProcessorMaxBuyBackGasLimitUpdated(uint256 oldLimit, uint256 newLimit);
    event FlapTaxProcessorMinBuyBackQuoteUpdated(uint256 oldAmount, uint256 newAmount);
    event FlapTaxProcessorFeeRateUpdated(uint16 oldFeeRate, uint16 newFeeRate);
    event FlapTaxProcessorCommissionPaid(address receiver, uint256 amount);
    event FlapTaxProcessorDividendConverted(address dividendToken, uint256 quoteIn, uint256 dividendOut);
    event FlapTaxProcessorConverterUpdated(address oldConverter, address newConverter);
    event FlapTaxProcessorCommissionConfigUpdated(address receiver, uint16 bps);
    /// @notice Emitted during initialize() when a processor is set up with a custom dividend token.
    /// @dev Used by backend discovery/indexing for MEV-protected converter flows.
    event FlapTaxProcessorMEVProtectionRequired(address taxProcessor, address taxToken);
    event FlapTaxProcessorQuoteReconciled(address indexed taxToken, uint256 quoteAmount);
    event FlapTaxProcessorTokensReconciled(address indexed taxToken, uint256 tokenAmount);
    event FlapTaxProcessorWalletDistributed(address indexed wallet, uint16 bps, uint256 amount);
    event FlapTaxProcessorWalletConfigSet(
        address mktOrVaultAddr1,
        uint16 mktOrVaultBps1,
        address mktOrVaultAddr2,
        uint16 mktOrVaultBps2,
        address mktOrVaultAddr3,
        uint16 mktOrVaultBps3,
        address mktOrVaultAddr4,
        uint16 mktOrVaultBps4
    );

    /// @notice Emitted when pending V4 LP fees exceed the dispatch threshold.
    ///         Off-chain keepers should listen for this and call dispatch().
    event FlapDispatchReady(
        address indexed taxToken,
        address indexed quoteToken,
        uint256 pendingQuoteFees,
        uint256 pendingTokenFees,
        uint256 estimatedQuoteValue
    );

    /// @notice Emitted when the dispatch threshold is updated.
    event FlapDispatchThresholdUpdated(uint256 oldThreshold, uint256 newThreshold);

    /// @notice Emitted when the dispatch-check cooldown is updated.
    event FlapDispatchCheckCooldownUpdated(uint256 oldCooldown, uint256 newCooldown);

    /// @notice Emitted when quoteExactInput is unavailable during checkAndNotifyDispatch.
    ///         Off-chain keepers can use this to detect when token price cannot be determined.
    event FlapDispatchQuoteUnavailable(
        address indexed taxToken, address indexed quoteToken, uint256 pendingQuote, uint256 pendingToken
    );
    event FlapV4FeeCollectFailed(address indexed taxToken, bytes reason);
    event FlapNativeReceiveForwardingUpdated(
        address indexed oldReceiver, address indexed newReceiver, bool oldEnabled, bool newEnabled
    );
    event FlapNativeReceiveForwarded(address indexed sender, address indexed receiver, uint256 amount);
    event FlapNativeReceiveForwardFailed(address indexed sender, address indexed receiver, uint256 amount);
    event FlapTaxProcessorLiqSmoothingGapQuoteUpdated(uint256 oldGap, uint256 newGap);

    /// @notice @deprecated — use FlapTaxProcessorTokensReconciled
    event TokensReconciled(address indexed token, uint256 amount);

    /// @notice Optional receiver for auto-forwarded native ETH sent to the processor.
    ///         Used only when `autoForward` is true.
    address public forwardAddress;

    /// @notice Enables automatic forwarding of native ETH received by the processor.
    ///         Disabled by default to preserve historical behavior.
    bool public autoForward;

    /// @notice Timestamp of the last keeper-facing V4 LP fee threshold check.
    ///         Used to throttle `checkAndNotifyDispatch()` and avoid repeated fee queries.
    /// @dev Appended at the end of storage to preserve upgrade / clone layout compatibility.
    uint256 public lastDispatchCheckAt;

    /// @notice Minimum delay between successive keeper-facing V4 LP fee threshold checks.
    ///         0 disables throttling entirely.
    /// @dev Appended after `lastDispatchCheckAt` to preserve storage layout compatibility.
    uint256 public dispatchCheckCooldown;

    /// @notice Registered V4 / PCS Infinity LP fee source metadata for this processor.
    /// @dev Filled by Portal during DEX migration once the position NFTs are minted.
    ///      Appended at the end of storage to preserve upgrade / clone layout compatibility.
    struct V4LPFeeSource {
        uint8 migratorType;
        address poolManager;
        address positionManager;
        uint256 tokenId0;
        uint256 tokenId1;
    }

    V4LPFeeSource public v4LPFeeSource;

    /// @notice Base smoothing bucket size denominated in quote token units.
    ///         0 disables gradual tax-token liquidation and restores legacy full processing.
    /// @dev Appended at the end of storage to preserve upgrade / clone layout compatibility.
    uint256 public liqSmoothingGapQuote;

    /// @notice Deferred tax-token backlog held on the processor for gradual processing.
    /// @dev Appended at the end of storage to preserve upgrade / clone layout compatibility.
    uint256 public deferredTaxTokenBalance;

    /// @notice True while the processor is inside `_swapTokensForQuote`.
    /// @dev Nested `processTaxTokens` calls triggered by tax-token transfer hooks are parked by
    ///      incrementing `deferredTaxTokenBalance` instead of being processed reentrantly inside
    ///      the current swap.
    bool internal _swapping;

    // --- Modifiers ---
    modifier onlyTaxToken() {
        require(msg.sender == taxToken, "TaxProcessor: caller is not the tax token");
        _;
    }

    modifier onlyPortal() {
        require(msg.sender == portal, "TaxProcessor: caller is not portal");
        _;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Bucket distribution helper — accessible by both TaxProcessorV2DispatchImpl
    // (_reconcileBalance) and TaxProcessorCore (processBondingCurveTax).
    // ─────────────────────────────────────────────────────────────────────────

    /// @dev Distribute a quote-token amount: apply fee/commission split, then allocate
    ///      remainder across market / deflation / LP / dividend buckets.
    ///      Pure storage writes — no external calls.  Symmetric counterpart to _processFeeToken.
    ///      Called by processBondingCurveTax and _reconcileBalance (for untracked LP-fee surplus).
    function _processFeeQuote(uint256 quoteAmount) internal {
        PackedFeeConfigInternal memory config = _feeConfig;

        uint256 fee = (quoteAmount * uint256(config.feeRate)) / 10000;
        uint256 commission = 0;
        if (config.commissionBps > 0 && commissionReceiver != address(0)) {
            commission = (quoteAmount * uint256(config.commissionBps)) / 10000;
        }

        uint256 remaining = quoteAmount - fee - commission;
        uint256 totalMktBps = uint256(config.mktOrVaultBps1) + uint256(config.mktOrVaultBps2)
            + uint256(config.mktOrVaultBps3) + uint256(config.mktOrVaultBps4);
        uint256 market = (remaining * totalMktBps) / 10000;
        uint256 deflation = (remaining * uint256(config.deflationBps)) / 10000;
        uint256 lp = (remaining * uint256(config.lpBps)) / 10000;
        uint256 dividend = (remaining * uint256(config.dividendBps)) / 10000;
        uint256 distributed = market + deflation + lp + dividend;

        if (distributed < remaining) {
            fee += remaining - distributed;
        }

        feeQuoteBalance += fee;
        if (commission > 0) commissionQuoteBalance += commission;
        marketQuoteBalance += market;
        pendingDividendQuoteTokenBalance += dividend;
        lpQuoteBalance += lp;
        preBondBurnFunds += deflation;
    }

    /// @dev Token-side processing for the V4/Infinity path is only valid after graduation.
    ///      Before DEX, TokenV3 fees are quote-side only; any stray tax-token balance should
    ///      remain parked on the processor until the token reaches DEX status.
    function _isTaxTokenOnDex() internal view returns (bool) {
        return IPortal(portal).getTokenV8(taxToken).status == IPortalTypes.TokenStatus.DEX;
    }
}

// ═════════════════════════════════════════════════════════════════════════════
// Dispatch Implementations — execute dispatch via delegatecall
// ═════════════════════════════════════════════════════════════════════════════

/// @title TaxProcessorV2DispatchImpl
/// @notice Dispatch implementation for TaxProcessorV2. Called via delegatecall from dispatch().
///         Handles fee, commission, 4-way independent wallet distribution, dividends, burn, and
///         balance reconciliation — all in one flat contract (no base/override split).
contract TaxProcessorV2DispatchImpl is TaxProcessorBaseStorage {
    using SafeERC20 for IERC20;

    constructor(address weth_, address flapBlackHole_, address portal_, address swapRegistry_)
        TaxProcessorBaseStorage(weth_, flapBlackHole_, portal_, swapRegistry_)
    {}

    /// @notice Executes the dispatch logic.
    function executeDispatch() external virtual {
        _executeDispatchInternal();
    }

    /// @notice Core dispatch logic — reads accumulated balances, clears them, then distributes
    ///         to fee/market/commission receivers, handles dividends, processes burn, and reconciles.
    /// @dev Extracted so V4 subclasses can override executeDispatch() to prepend LP fee collection
    ///      and then call this function for the actual dispatch.
    function _executeDispatchInternal() internal {
        // ── Gas safety: warm up receive() storage slots ───────────────────────
        // receive() now returns early when msg.sender == weth, so the main concern
        // is the autoForward path for any non-WETH ETH that may arrive mid-dispatch
        // on chains where WETH.withdraw uses transfer() (2300-gas limit).
        // Reading both slots here keeps them warm (100 gas each) for the rest of
        // this call so that any such callbacks do not OOG on the cold SLOAD.
        if (autoForward && forwardAddress != address(0)) {} // warm both slots

        uint256 feeAmount = feeQuoteBalance;
        uint256 commissionAmount = commissionQuoteBalance;
        uint256 marketAmount = marketQuoteBalance;
        uint256 burnAmount = preBondBurnFunds;
        uint256 pendingDividendQuote = pendingDividendQuoteTokenBalance;
        uint256 dividendTokenAmt = dividendTokenBalance;

        uint256 dividendAmountForEvent = pendingDividendQuote;

        // Clear balances first (checks-effects-interactions pattern)
        if (feeAmount > 0) feeQuoteBalance = 0;
        if (marketAmount > 0) marketQuoteBalance = 0;
        if (pendingDividendQuote > 0) pendingDividendQuoteTokenBalance = 0;
        if (burnAmount > 0) preBondBurnFunds = 0;
        if (commissionAmount > 0) commissionQuoteBalance = 0;
        if (dividendTokenAmt > 0) dividendTokenBalance = 0;

        PackedFeeConfigInternal memory config = _feeConfig;

        // 1. Dividend handling ---
        {
            address dvToken = dividendToken;

            if (dvToken == quoteToken) {
                dividendTokenAmt += pendingDividendQuote;
                pendingDividendQuote = 0;
            } else if (dvToken == taxToken) {
                if (pendingDividendQuote > 0 && dividendAddress != address(0)) {
                    uint256 quoteIn = pendingDividendQuote;
                    pendingDividendQuote = 0;
                    uint256 converted;
                    if (quoteIn >= minBuyBackQuote) {
                        // Token still on bonding curve — use Portal when threshold is met
                        converted = _swapQuoteForTokens(quoteIn);
                    } else {
                        pendingDividendQuoteTokenBalance += quoteIn;
                    }

                    if (converted > 0) {
                        dividendTokenAmt += converted;
                        emit FlapTaxProcessorDividendConverted(dvToken, quoteIn, converted);
                    }
                    // for security reason, We intentionally dropped the inputs for a failed swap.
                    // for most of the time, this could be the dust.
                    // However, they will first be collected as the burn funds
                    // If it cannot be used for burning, then it will be assimilated into the fee balance.
                }
            } else {
                if (msg.sender == converter && pendingDividendQuote >= minBuyBackQuote && dividendAddress != address(0))
                {
                    uint256 converted = _convertQuoteToDividendToken(pendingDividendQuote, dvToken);
                    if (converted > 0) {
                        dividendTokenAmt += converted;
                        emit FlapTaxProcessorDividendConverted(dvToken, pendingDividendQuote, converted);
                        pendingDividendQuote = 0;
                    }
                }
            }

            if (pendingDividendQuote > 0) {
                pendingDividendQuoteTokenBalance += pendingDividendQuote;
            }

            if (dividendTokenAmt > 0 && dividendAddress != address(0)) {
                if (!_sendToDividendContract(dividendTokenAmt, dvToken)) {
                    if (dvToken == quoteToken) {
                        pendingDividendQuoteTokenBalance += dividendTokenAmt;
                    } else {
                        dividendTokenBalance += dividendTokenAmt;
                    }
                }
            }
        }

        // 2. Process burn funds
        if (burnAmount > 0) {
            IPortalTradeV2.TokenStateV8 memory state = IPortal(portal).getTokenV8(taxToken);

            if (state.status == IPortalTypes.TokenStatus.DEX) {
                uint256 taxTokensReceived = _swapQuoteForTokens(burnAmount);
                if (taxTokensReceived > 0) {
                    IERC20(taxToken).safeTransfer(flapBlackHole, taxTokensReceived);
                    emit FlapTaxProcessorBurnExecuted(taxToken, burnAmount, taxTokensReceived);
                } else {
                    // Redirect failed/dust burn attempts to fee so we do not retry forever on each dispatch.
                    feeQuoteBalance += burnAmount;
                    emit FlapTaxProcessorBuyBackSkipped(taxToken, burnAmount, gasleft(), "Dust: redirected to fee");
                }
            } else {
                if (burnAmount >= minBuyBackQuote) {
                    // Measure balance change across the buyback to detect portal refunds.
                    // Any quote tokens returned by the portal (partial fill on bonding curve)
                    // must go back to preBondBurnFunds so the next dispatch can retry.
                    // Formula: netRefund = quoteAfter − quoteBefore + burnAmount − taxDuringSwap
                    //   • burnAmount : tokens we sent into the swap
                    //   • quoteAfter − quoteBefore : net change in our quote balance
                    //   • taxDuringSwap (= preBondBurnFunds after the call) : tracked via
                    //     processBondingCurveTax while _isBuyingBack() was true
                    // This correctly isolates the refund from any LP-fee surplus already
                    // sitting in the contract (which remains untracked and is handled by
                    // _reconcileBalance → _processFeeQuote below).
                    uint256 quoteBefore = IERC20(quoteToken).balanceOf(address(this));
                    _buyBackAndBurn(burnAmount);
                    uint256 quoteAfter = IERC20(quoteToken).balanceOf(address(this));
                    uint256 taxDuringSwap = preBondBurnFunds; // set by processBondingCurveTax callback
                    int256 netRefund =
                        int256(quoteAfter) - int256(quoteBefore) + int256(burnAmount) - int256(taxDuringSwap);
                    if (netRefund > 0) {
                        preBondBurnFunds += uint256(netRefund);
                        emit FlapTaxProcessorPortalRefund(taxToken, uint256(netRefund), _feeConfig.isWeth);
                    }
                } else {
                    preBondBurnFunds = burnAmount;
                }
            }
        }

        // 3. Distribute to fee/market/commission receivers
        if (config.isWeth) {
            _dispatchETH(feeAmount, marketAmount, commissionAmount);
        } else {
            _dispatchERC20(feeAmount, marketAmount, commissionAmount);
        }

        _reconcileBalance();

        emit FlapTaxProcessorDispatchExecuted(taxToken, feeAmount, marketAmount, dividendAmountForEvent);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Dispatch helpers (shared between ETH and ERC20 paths)
    // ─────────────────────────────────────────────────────────────────────────

    /// @dev Split `marketAmount` across 4 wallet slots proportionally to their bps.
    ///      Slot 4 receives the remainder to avoid dust from integer division.
    function _computeWalletAmounts(uint256 marketAmount, PackedFeeConfigInternal memory config)
        private
        pure
        returns (uint256 w1, uint256 w2, uint256 w3, uint256 w4)
    {
        uint256 totalMktBps = uint256(config.mktOrVaultBps1) + uint256(config.mktOrVaultBps2)
            + uint256(config.mktOrVaultBps3) + uint256(config.mktOrVaultBps4);
        w1 = marketAmount; // default: everything to slot 1 when only one wallet is set
        if (marketAmount > 0 && totalMktBps > 0) {
            w2 = (marketAmount * uint256(config.mktOrVaultBps2)) / totalMktBps;
            w3 = (marketAmount * uint256(config.mktOrVaultBps3)) / totalMktBps;
            w4 = (marketAmount * uint256(config.mktOrVaultBps4)) / totalMktBps;
            w1 = marketAmount - w2 - w3 - w4; // remainder → w1 (primary wallet, always has valid address)
        }
    }

    /// @dev Send `amount` ETH to a single market/vault wallet; returns how much was actually sent.
    function _dispatchOneWalletETH(address wallet, uint16 bps, uint256 amount) private returns (uint256 sent) {
        if (amount == 0 || wallet == address(0)) return 0;
        (bool s,) = payable(wallet).call{value: amount}("");
        if (s) {
            totalQuoteSentToMarketing += amount;
            emit FlapTaxProcessorWalletDistributed(wallet, bps, amount);
            return amount;
        }
    }

    /// @dev Send `amount` of `quoteToken` ERC20 to a single market/vault wallet.
    function _dispatchOneWalletERC20(address wallet, uint16 bps, uint256 amount) private {
        if (amount == 0 || wallet == address(0)) return;
        IERC20(quoteToken).safeTransfer(wallet, amount);
        totalQuoteSentToMarketing += amount;
        emit FlapTaxProcessorWalletDistributed(wallet, bps, amount);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Dispatch: ETH (when quote token is WETH)
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Dispatch ETH to fee receiver, 4 independent market/vault wallets, and commission.
    function _dispatchETH(uint256 feeAmount, uint256 marketAmount, uint256 commissionAmount) internal virtual {
        PackedFeeConfigInternal memory config = _feeConfig;
        (uint256 w1Amt, uint256 w2Amt, uint256 w3Amt, uint256 w4Amt) = _computeWalletAmounts(marketAmount, config);

        uint256 totalETHNeeded = feeAmount + w1Amt + w2Amt + w3Amt + w4Amt;
        if (commissionAmount > 0 && commissionReceiver != address(0)) totalETHNeeded += commissionAmount;
        if (totalETHNeeded > 0) IWETH(weth).withdraw(totalETHNeeded);

        uint256 ethUsed = 0;

        if (feeAmount > 0) {
            (bool s,) = payable(feeReceiver).call{value: feeAmount}("");
            if (s) ethUsed += feeAmount;
        }

        ethUsed += _dispatchOneWalletETH(_mktOrVaultAddress1, config.mktOrVaultBps1, w1Amt);
        ethUsed += _dispatchOneWalletETH(_mktOrVaultAddress2, config.mktOrVaultBps2, w2Amt);
        ethUsed += _dispatchOneWalletETH(_mktOrVaultAddress3, config.mktOrVaultBps3, w3Amt);
        ethUsed += _dispatchOneWalletETH(_mktOrVaultAddress4, config.mktOrVaultBps4, w4Amt);

        if (commissionAmount > 0 && commissionReceiver != address(0)) {
            (bool s,) = payable(commissionReceiver).call{value: commissionAmount, gas: 100_000}("");
            if (s) {
                ethUsed += commissionAmount;
                emit FlapTaxProcessorCommissionPaid(commissionReceiver, commissionAmount);
            }
        }

        // Wrap any failed ETH back to WETH
        uint256 remainingETH = totalETHNeeded - ethUsed;
        if (remainingETH > 0) {
            IWETH(weth).deposit{value: remainingETH}();
            feeQuoteBalance += remainingETH;
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Dispatch: ERC20 (when quote token is not WETH)
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Dispatch ERC20 to fee receiver, 4 independent market/vault wallets, and commission.
    function _dispatchERC20(uint256 feeAmount, uint256 marketAmount, uint256 commissionAmount) internal virtual {
        PackedFeeConfigInternal memory config = _feeConfig;
        (uint256 w1Amt, uint256 w2Amt, uint256 w3Amt, uint256 w4Amt) = _computeWalletAmounts(marketAmount, config);

        if (feeAmount > 0) IERC20(quoteToken).safeTransfer(feeReceiver, feeAmount);

        _dispatchOneWalletERC20(_mktOrVaultAddress1, config.mktOrVaultBps1, w1Amt);
        _dispatchOneWalletERC20(_mktOrVaultAddress2, config.mktOrVaultBps2, w2Amt);
        _dispatchOneWalletERC20(_mktOrVaultAddress3, config.mktOrVaultBps3, w3Amt);
        _dispatchOneWalletERC20(_mktOrVaultAddress4, config.mktOrVaultBps4, w4Amt);

        if (commissionAmount > 0 && commissionReceiver != address(0)) {
            IERC20(quoteToken).safeTransfer(commissionReceiver, commissionAmount);
            emit FlapTaxProcessorCommissionPaid(commissionReceiver, commissionAmount);
        }
    }

    /// @notice Swap quote tokens for tax tokens via Portal's swapExactInput.
    /// @dev Portal knows the token's pool type and routes through the correct DEX.
    ///      This replaces the V2-router-based swap for V4 tokens.
    function _swapQuoteForTokens(uint256 quoteAmount) internal returns (uint256 taxTokensReceived) {
        uint256 taxTokenBefore = IERC20(taxToken).balanceOf(address(this));

        if (_feeConfig.isWeth) {
            // Unwrap WETH → native ETH, then swap via Portal
            IWETH(weth).withdraw(quoteAmount);

            IPortalTradeV2.ExactInputParams memory params = IPortalTradeV2.ExactInputParams({
                inputToken: address(0), // native
                outputToken: taxToken,
                inputAmount: quoteAmount,
                minOutputAmount: 0,
                permitData: ""
            });

            try IPortal(portal).swapExactInput{value: quoteAmount, gas: maxBuyBackGasLimit}(params) returns (
                uint256 received
            ) {
                taxTokensReceived = IERC20(taxToken).balanceOf(address(this)) - taxTokenBefore;
                // Wrap any remaining ETH back
                uint256 ethBalance = address(this).balance;
                if (ethBalance > 0) {
                    IWETH(weth).deposit{value: ethBalance}();
                }
            } catch {
                // Swap failed — wrap ETH back and return 0
                IWETH(weth).deposit{value: quoteAmount}();
                return 0;
            }
        } else {
            // ERC20 quote → swap via Portal
            IERC20(quoteToken).safeApprove(portal, 0);
            IERC20(quoteToken).safeApprove(portal, quoteAmount);

            IPortalTradeV2.ExactInputParams memory params = IPortalTradeV2.ExactInputParams({
                inputToken: quoteToken,
                outputToken: taxToken,
                inputAmount: quoteAmount,
                minOutputAmount: 0,
                permitData: ""
            });

            try IPortal(portal).swapExactInput{gas: maxBuyBackGasLimit}(params) returns (uint256 received) {
                taxTokensReceived = IERC20(taxToken).balanceOf(address(this)) - taxTokenBefore;
                IERC20(quoteToken).safeApprove(portal, 0);
            } catch {
                IERC20(quoteToken).safeApprove(portal, 0);
                return 0;
            }
        }

        // Fallback: measure balance change if try/catch returned 0
        if (taxTokensReceived == 0) {
            taxTokensReceived = IERC20(taxToken).balanceOf(address(this)) - taxTokenBefore;
        }
    }

    /// @notice Deposit tokens to Dividend contract
    function _sendToDividendContract(uint256 amount, address token) internal returns (bool success) {
        IERC20(token).safeApprove(dividendAddress, 0);
        IERC20(token).safeApprove(dividendAddress, amount);

        success = IDividend(dividendAddress).deposit(amount);
        if (success) {
            totalDividendTokenSent += amount;
        } else {
            emit FlapTaxProcessorDividendDepositSkipped(taxToken, amount, "Deposit failed or no shareholders");
        }
    }

    /// @notice Swap quote tokens to dividendToken via SwapRegistry (Case 3)
    function _convertQuoteToDividendToken(uint256 quoteAmount, address dvToken) internal returns (uint256 dvReceived) {
        // Emergency brake: skip custom dividend conversion when the token is blacklisted in the registry.
        if (ISwapRegistry(swapRegistry).isBlacklisted(dvToken)) {
            return 0;
        }

        ISwapRegistry.SwapInfo memory info = ISwapRegistry(swapRegistry).getSwapInfo(quoteToken, dvToken);
        if (!info.supported) return 0;

        address routerAddr = ISwapRegistry(swapRegistry).multiDexRouter();
        require(routerAddr != address(0), "TaxProcessor: no router in registry"); // not a zero-address guard, kept as-is

        IERC20(quoteToken).safeApprove(routerAddr, 0);
        IERC20(quoteToken).safeApprove(routerAddr, quoteAmount);

        uint256 dvBefore = IERC20(dvToken).balanceOf(address(this));

        if (info.poolType == ISwapRegistry.PoolType.V3) {
            IMultiDexRouter.ExactInputSingleParams memory p = IMultiDexRouter.ExactInputSingleParams({
                tokenIn: quoteToken,
                tokenOut: dvToken,
                fee: info.feeTier,
                recipient: address(this),
                amountIn: quoteAmount,
                amountOutMinimum: 1,
                sqrtPriceLimitX96: 0
            });
            try IMultiDexRouter(routerAddr).exactInputSingle(info.dexId, p) {}
            catch {
                return 0;
            }
        } else {
            // V2 fallback
            address[] memory path = new address[](2);
            path[0] = quoteToken;
            path[1] = dvToken;
            try IMultiDexRouter(routerAddr).swapExactTokensForTokens(info.dexId, quoteAmount, 1, path, address(this)) {}
            catch {
                return 0;
            }
        }

        dvReceived = IERC20(dvToken).balanceOf(address(this)) - dvBefore;
    }

    /// @notice Buy back tax tokens using quote tokens and burn them
    function _buyBackAndBurn(uint256 quoteAmount) internal duringBuyBack {
        uint256 taxTokenBefore = IERC20(taxToken).balanceOf(address(this));
        uint256 tokensBought;

        if (_feeConfig.isWeth) {
            IWETH(weth).withdraw(quoteAmount);

            IPortalTradeV2.ExactInputParams memory params = IPortalTradeV2.ExactInputParams({
                inputToken: address(0),
                outputToken: taxToken,
                inputAmount: quoteAmount,
                minOutputAmount: 0,
                permitData: ""
            });

            try IPortal(portal).swapExactInput{value: quoteAmount, gas: maxBuyBackGasLimit}(params) returns (
                uint256 received
            ) {
                tokensBought = IERC20(taxToken).balanceOf(address(this)) - taxTokenBefore;
                uint256 ethBalance = address(this).balance;
                if (ethBalance > 0) {
                    IWETH(weth).deposit{value: ethBalance}();
                }
            } catch {
                IWETH(weth).deposit{value: quoteAmount}();
                preBondBurnFunds += quoteAmount;
                emit FlapTaxProcessorBuyBackSkipped(taxToken, quoteAmount, gasleft(), "Swap failed");
                return;
            }
        } else {
            IERC20(quoteToken).safeApprove(portal, 0);
            IERC20(quoteToken).safeApprove(portal, quoteAmount);

            IPortalTradeV2.ExactInputParams memory params = IPortalTradeV2.ExactInputParams({
                inputToken: quoteToken,
                outputToken: taxToken,
                inputAmount: quoteAmount,
                minOutputAmount: 0,
                permitData: ""
            });

            try IPortal(portal).swapExactInput{gas: maxBuyBackGasLimit}(params) returns (uint256 received) {
                tokensBought = IERC20(taxToken).balanceOf(address(this)) - taxTokenBefore;
            } catch {
                preBondBurnFunds += quoteAmount;
                emit FlapTaxProcessorBuyBackSkipped(taxToken, quoteAmount, gasleft(), "Swap failed");
                return;
            }
        }

        if (tokensBought > 0) {
            IERC20(taxToken).safeTransfer(flapBlackHole, tokensBought);
            emit FlapTaxProcessorBurnExecuted(taxToken, quoteAmount, tokensBought);
        }
    }

    /// @notice Reconcile actual token balance with tracked balances.
    ///         Untracked quote surplus (e.g. V4 LP fees transferred by the locker) is
    ///         distributed via _processFeeQuote.  Stranded tax-token surplus is handled
    ///         by _afterReconcile via a self-call to reconcileToken.
    function _reconcileBalance() internal {
        uint256 actualBalance = IERC20(quoteToken).balanceOf(address(this));
        uint256 trackedBalance = feeQuoteBalance + marketQuoteBalance + pendingDividendQuoteTokenBalance
            + lpQuoteBalance + preBondBurnFunds + commissionQuoteBalance;

        if (actualBalance > trackedBalance) {
            uint256 untracked = actualBalance - trackedBalance;
            _processFeeQuote(untracked);
            emit FlapTaxProcessorQuoteReconciled(taxToken, untracked);
        }

        _afterReconcile();
    }

    function _afterReconcile() internal virtual {
        // Expected tax-token balance = any deferred smoothing backlog that the processor is
        // intentionally holding, plus the tax-token dividend bucket when dividendToken == taxToken.
        // Anything above those tracked balances is stranded and should be reconciled.
        uint256 expected = deferredTaxTokenBalance;
        if (dividendToken == taxToken) expected += dividendTokenBalance;
        uint256 actualBalance = IERC20(taxToken).balanceOf(address(this));
        if (actualBalance <= expected) return;

        if (!_isTaxTokenOnDex()) return;

        uint256 stranded = actualBalance - expected;
        if (stranded > 0) {
            // Self-call routes through the proxy (TaxProcessorCore subclass) which has
            // access to _processFeeToken and the virtual DEX swap methods.
            try ITaxProcessorMinimal(address(this)).reconcileToken(stranded) {} catch {}
        }
    }
}

// ═════════════════════════════════════════════════════════════════════════════
// TaxProcessorAdminImpl — admin & init, called via delegatecall from TaxProcessorCore
// ═════════════════════════════════════════════════════════════════════════════

/// @title TaxProcessorAdminImpl
/// @notice Holds all cold-path admin, initialization, and V4 keeper functions.
///         Called via delegatecall from TaxProcessorCore, so all reads/writes target
///         the caller's storage context. onlyOwner / initializer modifiers work correctly.
///
/// @dev Shared by both TaxProcessorUniV2 and TaxProcessorUniV4 (same admin logic).
///      The generic `checkAndNotifyDispatch` fallback is intentionally a no-op; only
///      TaxProcessorUniV4 overrides it with live V4/PCS Infinity LP-fee inspection.
contract TaxProcessorAdminImpl is TaxProcessorBaseStorage {
    using SafeERC20 for IERC20;

    constructor(address weth_, address flapBlackHole_, address portal_, address swapRegistry_)
        TaxProcessorBaseStorage(weth_, flapBlackHole_, portal_, swapRegistry_)
    {}

    // ── BSC (56/97) stock/gold quote tokens ──────────────────────────────────────────────────────
    // These quote tokens track a real-world asset far above $1, so the value-blind `50 * 10^decimals`
    // fallback (which assumes a ~$1 peg) massively overshoots the intended ~$50 buyback / ~$20 dispatch
    // notional — e.g. XAUT (6-decimal, gold-priced) would need ~50 oz of gold to trigger a buyback.
    // We hardcode a static per-token USD price (the same rounded anchors documented in script 072 and
    // the CURVE_RH_*_ASSET buckets) and derive the token amount as targetUsd * 10^decimals / priceUsd,
    // so the default self-scales to each token's decimals. These are coarse deploy-time defaults; the
    // owner refines them to the LIVE route price via PortalTweak.retuneTaxThresholds after launch.
    address internal constant SPYB = 0x7138b48df7D98D7e3cc221BfE7192D0a178182D8; // ~$738, tracks S&P 500 (18 dec)
    address internal constant SPCXB = 0xbe9D156892E55e7154BcD3cB0FEA677F9D3103E1; // ~$116 (18 dec)
    address internal constant XAUT = 0x21cAef8A43163Eea865baeE23b9C2E327696A3bf; // ~$4073, tracks gold (6 dec)

    /// @dev Static USD price (whole dollars) for a BSC stock/gold quote token, or 0 if not special-cased.
    function _bscAssetQuotePriceUsd(address quoteTokenAddr) private pure returns (uint256) {
        if (quoteTokenAddr == SPYB) return 738;
        if (quoteTokenAddr == SPCXB) return 116;
        if (quoteTokenAddr == XAUT) return 4073;
        return 0;
    }

    /// @dev `targetUsd` worth of `quoteTokenAddr` in its own units, for a special-cased BSC asset token;
    ///      returns 0 when the token isn't one of the hardcoded stock/gold quote tokens (caller then
    ///      falls back to the value-blind default).
    function _bscAssetQuoteAmount(address quoteTokenAddr, uint256 decimals, uint256 targetUsd)
        private
        pure
        returns (uint256)
    {
        uint256 priceUsd = _bscAssetQuotePriceUsd(quoteTokenAddr);
        if (priceUsd == 0) return 0;
        return (targetUsd * (10 ** decimals)) / priceUsd;
    }

    /// @notice Compute the canonical per-chain/-token dispatch threshold (V4 keeper LP-fee signal).
    /// @dev    This is the single source of truth for both init thresholds: `initialize` derives the
    ///         on-chain dust floor `minBuyBackQuote` as 80% of the returned value.
    ///         ┌──────────────────┬─────────────────────────┬──────────────┐
    ///         │ Network          │ Quote token             │ dispatch     │
    ///         ├──────────────────┼─────────────────────────┼──────────────┤
    ///         │ BSC (56/97)      │ BNB (native)            │ 0.05 BNB     │
    ///         │                  │ USD1 (0x000Ae314…)      │ 50 USD1      │
    ///         │                  │ ASTER (0x924fa68a…)     │ 150 ASTER    │
    ///         │                  │ SPYB/SPCXB/XAUT         │ $20 worth    │
    ///         │                  │ other ERC-20            │ 20×10^dec    │
    ///         │ Robinhood(4663)  │ WETH (native)           │ 0.015        │
    ///         │                  │ USDG (0x5fc5360D…)      │ 50×10^6      │
    ///         │ XLayer (196)     │ OKB (native)            │ 1 OKB        │
    ///         │ all others       │ any (ETH / WETH / …)    │ 0.05 ETH     │
    ///         └──────────────────┴─────────────────────────┴──────────────┘
    function _calculateDispatchThreshold(bool isWeth_, address quoteTokenAddr) internal view returns (uint256) {
        uint256 chainId = block.chainid;

        if (chainId == 56 || chainId == 97) {
            if (isWeth_) {
                return 0.05 ether;
            } else if (quoteTokenAddr == 0x000Ae314E2A2172a039B26378814C252734f556A) {
                return 50 ether;
            } else if (quoteTokenAddr == 0x924fa68a0FC644485b8df8AbfA0A41C2e7744444) {
                return 150 ether;
            } else {
                uint256 decimals = IERC20Metadata(quoteTokenAddr).decimals();
                // Stock/gold quote tokens (SPYB/SPCXB/XAUT) price far above $1: derive ~$20 worth from a
                // static per-token price. Returns 0 when not one of those, then fall back to 20*10^dec.
                uint256 assetAmount = _bscAssetQuoteAmount(quoteTokenAddr, decimals, 20);
                return assetAmount > 0 ? assetAmount : 20 * (10 ** decimals);
            }
        } else if (chainId == 4663 || chainId == 46630) {
            if (isWeth_) {
                return 0.015 ether;
            } else if (quoteTokenAddr == 0x5fc5360D0400a0Fd4f2af552ADD042D716F1d168) {
                return 50 * (10 ** 6); // USDG
            } else {
                return 20 * (10 ** IERC20Metadata(quoteTokenAddr).decimals());
            }
        } else if (chainId == 196) {
            if (isWeth_) {
                return 1 ether;
            } else {
                return 20 * (10 ** IERC20Metadata(quoteTokenAddr).decimals());
            }
        } else {
            return 0.05 ether;
        }
    }

    function initialize(TaxProcessorV2InitParams memory params) public initializer {
        _requireAddr(params.router, "TaxProcessor: zero router");
        _requireAddr(params.feeReceiver, "TaxProcessor: zero fee receiver");
        _requireAddr(params.taxToken, "TaxProcessor: zero tax token");
        _requireAddr(params.quoteToken, "TaxProcessor: zero quote token");
        _requireAddr(params.dividendToken, "TaxProcessor: zero dividend token");
        require(params.feeRate <= 10000, "TaxProcessor: feeRate must be <= 10000");

        // Explicit 100% validation
        uint256 totalBps = uint256(params.mktOrVaultBps1) + uint256(params.mktOrVaultBps2)
            + uint256(params.mktOrVaultBps3) + uint256(params.mktOrVaultBps4) + uint256(params.deflationBps)
            + uint256(params.lpBps) + uint256(params.dividendBps);
        require(totalBps == 10000, "TaxProcessor: distribution bps must sum to 10000");

        // Address validation: non-zero bps requires non-zero address
        if (params.mktOrVaultBps1 > 0) _requireAddr(params.mktOrVaultAddr1, "TaxProcessor: zero wallet1 address");
        if (params.mktOrVaultBps2 > 0) _requireAddr(params.mktOrVaultAddr2, "TaxProcessor: zero wallet2 address");
        if (params.mktOrVaultBps3 > 0) _requireAddr(params.mktOrVaultAddr3, "TaxProcessor: zero wallet3 address");
        if (params.mktOrVaultBps4 > 0) _requireAddr(params.mktOrVaultAddr4, "TaxProcessor: zero wallet4 address");
        if (params.dividendBps > 0) _requireAddr(params.dividendAddress, "TaxProcessor: zero dividend address");

        __Ownable_init();
        __ReentrancyGuard_init();
        __BuyBackGuard_init();

        router = params.router;
        feeReceiver = params.feeReceiver;
        taxToken = params.taxToken;

        bool isWeth = params.quoteToken == weth;
        quoteToken = params.quoteToken;

        // Set all wallet addresses
        _mktOrVaultAddress1 = params.mktOrVaultAddr1;
        _mktOrVaultAddress2 = params.mktOrVaultAddr2;
        _mktOrVaultAddress3 = params.mktOrVaultAddr3;
        _mktOrVaultAddress4 = params.mktOrVaultAddr4;
        // Always preserve a provided dividend contract so tracker-only deployments can keep share accounting wired.
        if (params.dividendAddress != address(0)) dividendAddress = params.dividendAddress;

        _feeConfig = PackedFeeConfigInternal({
            mktOrVaultBps1: params.mktOrVaultBps1,
            mktOrVaultBps2: params.mktOrVaultBps2,
            mktOrVaultBps3: params.mktOrVaultBps3,
            mktOrVaultBps4: params.mktOrVaultBps4,
            deflationBps: params.deflationBps,
            lpBps: params.lpBps,
            dividendBps: params.dividendBps,
            feeRate: params.feeRate,
            isWeth: isWeth,
            commissionBps: params.commissionReceiver != address(0) ? params.commissionBps : 0
        });

        dispatchThreshold = _calculateDispatchThreshold(isWeth, params.quoteToken);
        // On-chain dust floor is 80% of the keeper dispatch signal (uniform across all chains/tokens).
        minBuyBackQuote = (dispatchThreshold * 80) / 100;
        liqSmoothingGapQuote = dispatchThreshold * 20;
        maxBuyBackGasLimit = 500_000;
        dispatchCheckCooldown = DEFAULT_DISPATCH_CHECK_COOLDOWN;

        if (params.commissionReceiver != address(0)) {
            commissionReceiver = params.commissionReceiver;
        }

        if (
            params.dividendBps > 0 && params.dividendToken != params.taxToken
                && params.dividendToken != params.quoteToken
        ) {
            require(swapRegistry != address(0), "TaxProcessor: swapRegistry required for custom dividend token");
            require(
                ISwapRegistry(swapRegistry).isSwapSupported(params.quoteToken, params.dividendToken),
                "TaxProcessor: swap path not supported for dividend token"
            );
            require(params.converter != address(0), "TaxProcessor: converter required for custom dividend token");
            converter = params.converter;
            emit FlapTaxProcessorMEVProtectionRequired(address(this), params.taxToken);
        }
        dividendToken = params.dividendToken;
        liqExpectedOutputAmount = params.liqExpectedOutputAmount;
    }

    function setWalletConfig(
        address mktOrVaultAddr1,
        address mktOrVaultAddr2,
        uint16 mktOrVaultBps2,
        address mktOrVaultAddr3,
        uint16 mktOrVaultBps3,
        address mktOrVaultAddr4,
        uint16 mktOrVaultBps4
    ) external onlyOwner {
        PackedFeeConfigInternal memory config = _feeConfig;

        uint256 totalMarketBps = uint256(config.mktOrVaultBps1) + uint256(config.mktOrVaultBps2)
            + uint256(config.mktOrVaultBps3) + uint256(config.mktOrVaultBps4);

        uint256 walletBps = uint256(mktOrVaultBps2) + uint256(mktOrVaultBps3) + uint256(mktOrVaultBps4);
        require(walletBps <= totalMarketBps, "TaxProcessor: wallet bps exceed total market allocation");

        uint16 mktOrVaultBps1 = uint16(totalMarketBps - walletBps);

        if (mktOrVaultBps1 > 0) _requireAddr(mktOrVaultAddr1, "TaxProcessor: zero wallet1 address");
        if (mktOrVaultBps2 > 0) _requireAddr(mktOrVaultAddr2, "TaxProcessor: zero wallet2 address");
        if (mktOrVaultBps3 > 0) _requireAddr(mktOrVaultAddr3, "TaxProcessor: zero wallet3 address");
        if (mktOrVaultBps4 > 0) _requireAddr(mktOrVaultAddr4, "TaxProcessor: zero wallet4 address");

        config.mktOrVaultBps1 = mktOrVaultBps1;
        config.mktOrVaultBps2 = mktOrVaultBps2;
        config.mktOrVaultBps3 = mktOrVaultBps3;
        config.mktOrVaultBps4 = mktOrVaultBps4;
        _feeConfig = config;

        _mktOrVaultAddress1 = mktOrVaultAddr1;
        _mktOrVaultAddress2 = mktOrVaultAddr2;
        _mktOrVaultAddress3 = mktOrVaultAddr3;
        _mktOrVaultAddress4 = mktOrVaultAddr4;

        emit FlapTaxProcessorWalletConfigSet(
            mktOrVaultAddr1,
            mktOrVaultBps1,
            mktOrVaultAddr2,
            mktOrVaultBps2,
            mktOrVaultAddr3,
            mktOrVaultBps3,
            mktOrVaultAddr4,
            mktOrVaultBps4
        );
    }

    function setReceivers(address feeReceiver_, address marketAddress_, address dividendAddress_) external onlyOwner {
        _requireAddr(feeReceiver_, "TaxProcessor: zero fee receiver");
        feeReceiver = feeReceiver_;

        PackedFeeConfigInternal memory config = _feeConfig;

        if (config.mktOrVaultBps1 > 0) {
            _requireAddr(marketAddress_, "TaxProcessor: zero market address");
            _mktOrVaultAddress1 = marketAddress_;
        }

        if (config.dividendBps > 0) {
            _requireAddr(dividendAddress_, "TaxProcessor: zero dividend address");
            dividendAddress = dividendAddress_;
        }
    }

    function setTaxConfig(uint16 feeRate_, uint16 marketBps_, uint16 deflationBps_, uint16 lpBps_, uint16 dividendBps_)
        external
        onlyOwner
    {
        require(feeRate_ <= 10000, "TaxProcessor: feeRate must be <= 10000");
        uint256 totalBps = uint256(marketBps_) + uint256(deflationBps_) + uint256(lpBps_) + uint256(dividendBps_);
        require(totalBps == 10000, "TaxProcessor: distribution bps must sum to 10000");

        if (marketBps_ > 0) {
            require(_mktOrVaultAddress1 != address(0), "TaxProcessor: market address not set");
        }
        if (dividendBps_ > 0) {
            require(dividendAddress != address(0), "TaxProcessor: dividend address not set");
        }

        PackedFeeConfigInternal memory config = _feeConfig;

        uint256 existingWalletBps =
            uint256(config.mktOrVaultBps2) + uint256(config.mktOrVaultBps3) + uint256(config.mktOrVaultBps4);
        require(uint256(marketBps_) >= existingWalletBps, "TaxProcessor: marketBps too small for existing wallets");

        config.feeRate = feeRate_;
        config.mktOrVaultBps1 = uint16(uint256(marketBps_) - existingWalletBps);
        config.deflationBps = deflationBps_;
        config.lpBps = lpBps_;
        config.dividendBps = dividendBps_;
        _feeConfig = config;
    }

    /// @notice Update only the protocol fee rate, without touching distribution percentages.
    ///         Bonding curve (internal market): feeRate = 6000 (60%).
    ///         DEX (external market):           feeRate = 4100 (41%).
    ///         Call this after the token graduates from the bonding curve to DEX.
    /// @param feeRate_ New fee rate in basis points (max 10000).
    function setFeeRate(uint16 feeRate_) external onlyOwner {
        require(feeRate_ <= 10000, "TaxProcessor: feeRate must be <= 10000");
        uint16 oldFeeRate = _feeConfig.feeRate;
        _feeConfig.feeRate = feeRate_;
        emit FlapTaxProcessorFeeRateUpdated(oldFeeRate, feeRate_);
    }

    function setMaxBuyBackGasLimit(uint256 newLimit) external onlyOwner {
        require(newLimit > 0, "TaxProcessor: zero maxBuyBackGasLimit");
        uint256 oldLimit = maxBuyBackGasLimit;
        maxBuyBackGasLimit = newLimit;
        emit FlapTaxProcessorMaxBuyBackGasLimitUpdated(oldLimit, newLimit);
    }

    function setMinBuyBackQuote(uint256 newAmount) external onlyOwner {
        require(newAmount > 0, "TaxProcessor: zero minBuyBackQuote");
        uint256 oldAmount = minBuyBackQuote;
        minBuyBackQuote = newAmount;
        emit FlapTaxProcessorMinBuyBackQuoteUpdated(oldAmount, newAmount);
    }

    function setCommissionConfig(address receiver, uint16 bps) external onlyOwner {
        commissionReceiver = receiver;
        _feeConfig.commissionBps = bps;
        emit FlapTaxProcessorCommissionConfigUpdated(receiver, bps);
    }

    function setDividendToken(address token) external onlyOwner {
        _requireAddr(token, "TaxProcessor: dividendToken cannot be zero");
        if (_feeConfig.dividendBps > 0 && token != quoteToken && token != taxToken) {
            require(swapRegistry != address(0), "TaxProcessor: swapRegistry required for custom dividend token");
            require(
                ISwapRegistry(swapRegistry).isSwapSupported(quoteToken, token),
                "TaxProcessor: swap path not supported for dividend token"
            );
            require(converter != address(0), "TaxProcessor: converter required for custom dividend token");
        }
        dividendToken = token;
    }

    function setConverter(address converter_) external onlyOwner {
        address old = converter;
        converter = converter_;
        emit FlapTaxProcessorConverterUpdated(old, converter_);
    }

    function setLiqExpectedOutputAmount(uint256 amount) external onlyOwner {
        liqExpectedOutputAmount = amount;
    }

    /// @notice Configure the smoothing gap bucket in quote-token units.
    /// @dev 0 disables smoothing and restores legacy full processing.
    function setLiqSmoothingGapQuote(uint256 gap) external onlyOwner {
        uint256 oldGap = liqSmoothingGapQuote;
        liqSmoothingGapQuote = gap;
        emit FlapTaxProcessorLiqSmoothingGapQuoteUpdated(oldGap, gap);
    }

    /// @notice Configure auto-forwarding for native ETH received by the processor.
    /// @dev When enabled and a receiver is configured, any ETH hitting `receive()` is forwarded.
    ///      Forward failures are tolerated and leave the ETH parked on the processor for manual recovery.
    function setAutoForwarding(address receiver, bool enabled) external onlyOwner {
        if (enabled) {
            _requireAddr(receiver, "TaxProcessor: zero forward address");
        }

        address oldReceiver = forwardAddress;
        bool oldEnabled = autoForward;

        forwardAddress = receiver;
        autoForward = enabled;

        emit FlapNativeReceiveForwardingUpdated(oldReceiver, receiver, oldEnabled, enabled);
    }

    /// @notice Register the V4 / PCS Infinity LP fee source metadata for this processor.
    /// @dev Called by Portal during migration after both LP position NFTs are minted.
    function registerV4LPFeeSource(
        uint8 migratorType,
        address poolManager,
        address positionManager,
        uint256 tokenId0,
        uint256 tokenId1
    ) external onlyPortal {
        require(
            migratorType == uint8(IPortalTypes.MigratorType.V4_UNI_MIGRATOR)
                || migratorType == uint8(IPortalTypes.MigratorType.PCS_INFINITY_CL_MIGRATOR),
            "TaxProcessor: invalid V4 migrator"
        );
        _requireAddr(poolManager, "TaxProcessor: zero pool manager");
        _requireAddr(positionManager, "TaxProcessor: zero position manager");
        require(tokenId0 != 0 || tokenId1 != 0, "TaxProcessor: zero token ids");

        v4LPFeeSource = V4LPFeeSource({
            migratorType: migratorType,
            poolManager: poolManager,
            positionManager: positionManager,
            tokenId0: tokenId0,
            tokenId1: tokenId1
        });
    }

    function withdrawAll(address token, address to) external onlyOwner {
        _requireAddr(to, "TaxProcessor: zero address");

        if (token == address(0)) {
            if (_feeConfig.isWeth) {
                uint256 balance = address(this).balance;
                if (balance > 0) {
                    (bool success,) = payable(to).call{value: balance}("");
                    require(success, "TaxProcessor: ETH transfer failed");
                }
            } else {
                uint256 balance = IERC20(quoteToken).balanceOf(address(this));
                if (balance > 0) {
                    IERC20(quoteToken).safeTransfer(to, balance);
                }
            }
        } else {
            uint256 balance = IERC20(token).balanceOf(address(this));
            if (balance > 0) {
                IERC20(token).safeTransfer(to, balance);
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // V4-specific admin — only meaningful on TaxProcessorUniV4.
    // TaxProcessorUniV2 overrides checkAndNotifyDispatch() as a no-op.
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Set the dispatch threshold. Only callable by the owner.
    function setDispatchThreshold(uint256 threshold) external onlyOwner {
        uint256 old = dispatchThreshold;
        dispatchThreshold = threshold;
        emit FlapDispatchThresholdUpdated(old, threshold);
    }

    /// @notice Set the cooldown between successive keeper-facing dispatch checks.
    /// @param cooldown New cooldown in seconds. Set to 0 to disable throttling.
    function setDispatchCheckCooldown(uint256 cooldown) external onlyOwner {
        uint256 old = dispatchCheckCooldown;
        dispatchCheckCooldown = cooldown;
        emit FlapDispatchCheckCooldownUpdated(old, cooldown);
    }

    /// @notice Generic dispatch-check fallback.
    /// @dev No-op for shared admin implementations; TaxProcessorUniV4 overrides this
    ///      on the concrete processor with local V4 LP-fee math.
    function checkAndNotifyDispatch() external {
        return;
    }
}

// ═════════════════════════════════════════════════════════════════════════════
// TaxProcessorCore — Abstract base with all shared logic
// ═════════════════════════════════════════════════════════════════════════════

/// @title TaxProcessorCore
/// @notice Abstract base contract containing all shared tax processing logic.
///         Subclasses (TaxProcessorUniV2, TaxProcessorUniV4) implement DEX-specific
///         `_swapTokensForQuote` and `_addLiquidity`.
///
/// @dev Deployed as a Minimal Proxy (clone). The DISPATCH_IMPL immutable is set by
///      each subclass's constructor, deploying the appropriate dispatch implementation.
///      Named TaxProcessorCore (not TaxProcessorBaseStorage) to avoid name collision with the
///      legacy TaxProcessorBaseStorage defined in TaxProcessor.sol.
abstract contract TaxProcessorCore is TaxProcessorBaseStorage {
    using SafeERC20 for IERC20;

    // ─────────────────────────────────────────────────────────────────────────
    // Immutables
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Address of the deployed dispatch implementation (delegatecall target for dispatch())
    address public immutable DISPATCH_IMPL;

    /// @notice Address of the deployed admin implementation (delegatecall target for admin calls)
    address public immutable ADMIN_IMPL;

    // ─────────────────────────────────────────────────────────────────────────
    // Constructor
    // ─────────────────────────────────────────────────────────────────────────

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(
        address weth_,
        address flapBlackHole_,
        address portal_,
        address swapRegistry_,
        address dispatchImpl_,
        address adminImpl_
    ) TaxProcessorBaseStorage(weth_, flapBlackHole_, portal_, swapRegistry_) {
        DISPATCH_IMPL = dispatchImpl_;
        ADMIN_IMPL = adminImpl_;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Delegatecall forwarders
    // ─────────────────────────────────────────────────────────────────────────

    /// @dev Forwards to ADMIN_IMPL — used by initialize(), setters, and withdrawAll().
    function _delegateToAdminImpl() internal {
        address impl = ADMIN_IMPL;
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Initialization — delegated to ADMIN_IMPL
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Initialize with all wallet and distribution config.
    /// @dev Implementation lives in TaxProcessorAdminImpl; the `initializer` guard runs
    ///      in the caller's storage context via delegatecall, preventing re-init.
    function initialize(TaxProcessorV2InitParams memory params) public virtual {
        _delegateToAdminImpl();
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Virtual hooks — MUST be overridden by subclasses
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Swap tax tokens for quote tokens via DEX.
    /// @dev Subclass implementations:
    ///   - TaxProcessorUniV2: uses IUniswapRouter02 (V2 router)
    ///   - TaxProcessorUniV4: uses MultiDexRouter / V4 UniversalRouter
    function _swapTokensForQuote(uint256 amount) internal virtual returns (uint256 quoteReceived);

    /// @notice Add liquidity to DEX pool.
    /// @dev Subclass implementations:
    ///   - TaxProcessorUniV2: uses IUniswapRouter02.addLiquidity (V2 LP)
    ///   - TaxProcessorUniV4: uses PositionManager.modifyLiquidities or LP module
    function _addLiquidity(uint256 tokenAmount, uint256 quoteAmount)
        internal
        virtual
        returns (uint256 actualTokenUsed, uint256 actualQuoteUsed);

    // ═════════════════════════════════════════════════════════════════════════
    // Core Tax Processing
    // ═════════════════════════════════════════════════════════════════════════

    function getQuoteToken() external view returns (address) {
        return quoteToken;
    }

    function processBondingCurveTax(uint256 quoteAmount) external {
        require(quoteAmount > 0, "TaxProcessor: zero amount");

        IERC20(quoteToken).safeTransferFrom(msg.sender, address(this), quoteAmount);

        if (_isBuyingBack()) {
            preBondBurnFunds += quoteAmount;
            emit FlapTaxProcessorBondingCurveTax(taxToken, quoteAmount);
            return;
        }

        _processFeeQuote(quoteAmount);

        emit FlapTaxProcessorBondingCurveTax(taxToken, quoteAmount);
    }

    /// @notice Process tax tokens: compute fees, split amounts, burn deflation, swap and distribute
    /// @param taxAmount The total amount of tax tokens to process
    /// @return liqThresholdDirection Direction to adjust liquidation threshold:
    ///         +1 = swap output below reference (price lower, raise threshold to liquidate less often),
    ///          0 = no reference set or exact match,
    ///         -1 = swap output exceeded reference (price higher, lower threshold to liquidate smaller amounts).
    function processTaxTokens(uint256 taxAmount) external onlyTaxToken returns (int8 liqThresholdDirection) {
        require(taxAmount > 0, "TaxProcessor: zero amount");

        IERC20(taxToken).safeTransferFrom(msg.sender, address(this), taxAmount);

        if (_swapping) {
            deferredTaxTokenBalance += taxAmount;
            emit FlapTaxProcessorTokensParked(taxToken, taxAmount);
            return 0;
        }

        return _processTaxTokensBody(taxAmount);
    }

    /// @dev Convert a swap result into the directional threshold signal.
    ///      Comparison is normalized by token size so deflation / LP / self-dividend routing does not
    ///      bias the signal merely by changing how many tokens actually reached the swap leg.
    ///      `referenceTokenAmount` defines the token size that `refAmount` is meant to represent:
    ///        - legacy/default path: the full processed tax-token amount
    ///        - smoothing path: one base gap (`gapInTokens`)
    function _computeLiqThresholdDirection(
        uint256 totalQuoteReceived,
        uint256 actualSwappedTokenAmount,
        uint256 refAmount,
        uint256 referenceTokenAmount
    ) internal pure returns (int8 liqThresholdDirection) {
        if (refAmount == 0 || totalQuoteReceived == 0 || actualSwappedTokenAmount == 0 || referenceTokenAmount == 0) {
            return 0;
        }

        // Compare quote-per-token rates without doing division first:
        //   totalQuoteReceived / actualSwappedTokenAmount  ?  refAmount / referenceTokenAmount
        // Cross-multiplying keeps full integer precision and answers whether the actual swap
        // execution, normalized to the reference token size, was above or below the target.
        uint256 normalizedActual = totalQuoteReceived * referenceTokenAmount;
        uint256 normalizedRef = refAmount * actualSwappedTokenAmount;

        if (normalizedActual > normalizedRef) {
            // Price is higher than expected: lower the threshold so liquidations sell smaller
            // amounts more frequently, avoiding a large single dump that nukes the price.
            return -1;
        }

        if (normalizedActual < normalizedRef) {
            // Price is lower than expected: raise the threshold so the contract waits for more
            // tokens to accumulate before selling, reducing sell pressure during weak markets.
            return 1;
        }

        return 0;
    }

    /// @dev Default tax-token processing path: process everything currently available.
    ///      If smoothing previously deferred tokens and is later disabled, the next
    ///      legacy call naturally flushes the backlog by including it here.
    function _processTaxTokensBody(uint256 taxAmount) internal virtual returns (int8 liqThresholdDirection) {
        uint256 totalAvailable = deferredTaxTokenBalance + taxAmount;
        deferredTaxTokenBalance = 0;

        (uint256 totalQuoteReceived, uint256 actualSwappedTokenAmount) = _processFeeToken(totalAvailable);

        emit FlapTaxProcessorProcessTaxTokens(taxToken, totalAvailable);

        liqThresholdDirection = _computeLiqThresholdDirection(
            totalQuoteReceived, actualSwappedTokenAmount, liqExpectedOutputAmount, totalAvailable
        );
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Shared distribution helpers
    // ─────────────────────────────────────────────────────────────────────────

    /// @dev Distribute a tax-token amount: apply fee/commission split, burn deflation,
    ///      handle self-dividend short-circuit, then swap remainder to quote via
    ///      _processTokenDistribution.  Symmetric counterpart to _processFeeQuote.
    ///      Called by processTaxTokens and reconcileToken (via _afterReconcile self-call).
    /// @return totalQuoteReceived The total quote received from swapping tokens.
    /// @return actualSwappedTokenAmount The actual number of tax tokens that left the processor via the swap leg.
    function _processFeeToken(uint256 tokenAmount)
        internal
        returns (uint256 totalQuoteReceived, uint256 actualSwappedTokenAmount)
    {
        PackedFeeConfigInternal memory config = _feeConfig;

        uint256 fee = (tokenAmount * uint256(config.feeRate)) / 10000;
        uint256 remaining = tokenAmount - fee;

        uint256 commission = 0;
        if (config.commissionBps > 0 && commissionReceiver != address(0)) {
            commission = (remaining * uint256(config.commissionBps)) / 10000;
            if (commission > 0) {
                remaining -= commission;
            }
        }

        uint256 totalMktBps = uint256(config.mktOrVaultBps1) + uint256(config.mktOrVaultBps2)
            + uint256(config.mktOrVaultBps3) + uint256(config.mktOrVaultBps4);
        uint256 market = (remaining * totalMktBps) / 10000;
        uint256 deflation = (remaining * uint256(config.deflationBps)) / 10000;
        uint256 lp = (remaining * uint256(config.lpBps)) / 10000;
        uint256 dividend = (remaining * uint256(config.dividendBps)) / 10000;
        uint256 distributed = market + deflation + lp + dividend;

        if (distributed < remaining) {
            fee += remaining - distributed;
        }

        // Deflation: burn
        if (deflation > 0) {
            IERC20(taxToken).safeTransfer(flapBlackHole, deflation);
            emit FlapTaxProcessorTokensBurned(taxToken, deflation);
        }

        uint256 dividendToSwap = dividend;
        {
            address dvToken = dividendToken;
            if (dvToken == taxToken && dividend > 0) {
                dividendTokenBalance += dividend;
                dividendToSwap = 0;
            }
        }

        (totalQuoteReceived, actualSwappedTokenAmount) =
            _processTokenDistribution(fee, market, lp, dividendToSwap, commission);
    }

    /// @notice Process token distribution: add liquidity first, then swap remaining tokens.
    /// @return totalQuoteReceived The quote token proceeds from the swap leg.
    /// @return actualSwappedTokenAmount The actual number of tax tokens removed from the processor by the swap leg.
    function _processTokenDistribution(uint256 fee, uint256 market, uint256 lp, uint256 dividend, uint256 commission)
        internal
        returns (uint256 totalQuoteReceived, uint256 actualSwappedTokenAmount)
    {
        uint256 lpTaxToSwap = lp;

        if (lp > 0 && lpQuoteBalance > 0) {
            (uint256 actualTokenUsed, uint256 actualQuoteUsed) = _addLiquidity(lp, lpQuoteBalance);
            lpTaxToSwap = lp >= actualTokenUsed ? lp - actualTokenUsed : 0;
            lpQuoteBalance = lpQuoteBalance >= actualQuoteUsed ? lpQuoteBalance - actualQuoteUsed : 0;
        }

        uint256 totalToSwap = lpTaxToSwap + fee + commission + market + dividend;

        if (totalToSwap > 0) {
            uint256 taxTokenBefore = IERC20(taxToken).balanceOf(address(this));
            uint256 quoteReceived = _swapTokensForQuote(totalToSwap);
            totalQuoteReceived = quoteReceived;
            uint256 taxTokenAfter = IERC20(taxToken).balanceOf(address(this));
            if (taxTokenBefore > taxTokenAfter) {
                actualSwappedTokenAmount = taxTokenBefore - taxTokenAfter;
            }

            if (quoteReceived > 0) {
                uint256 feeShare = fee > 0 ? (quoteReceived * fee) / totalToSwap : 0;
                uint256 commissionShare = commission > 0 ? (quoteReceived * commission) / totalToSwap : 0;
                uint256 marketShare = market > 0 ? (quoteReceived * market) / totalToSwap : 0;
                uint256 dividendShare = dividend > 0 ? (quoteReceived * dividend) / totalToSwap : 0;
                uint256 lpShare = lpTaxToSwap > 0 ? (quoteReceived * lpTaxToSwap) / totalToSwap : 0;

                feeQuoteBalance += feeShare;
                commissionQuoteBalance += commissionShare;
                marketQuoteBalance += marketShare;
                pendingDividendQuoteTokenBalance += dividendShare;
                lpQuoteBalance += lpShare;

                // Credit any wei remainder from integer-division rounding to feeQuoteBalance
                // so that no quote tokens are left untracked.
                uint256 distributed = feeShare + commissionShare + marketShare + dividendShare + lpShare;
                if (distributed < quoteReceived) {
                    feeQuoteBalance += quoteReceived - distributed;
                }
            }
        }
    }

    function dispatch() external nonReentrant {
        (bool success, bytes memory result) =
            DISPATCH_IMPL.delegatecall(abi.encodeWithSelector(TaxProcessorV2DispatchImpl.executeDispatch.selector));
        if (!success) {
            assembly ("memory-safe") {
                revert(add(result, 32), mload(result))
            }
        }
    }

    /// @notice Reconcile stranded tax tokens — called via self-call from _afterReconcile.
    ///         Routes through the proxy so _processFeeToken and the virtual DEX
    ///         swap methods resolve correctly (self-call exits the delegatecall context).
    function reconcileToken(uint256 tokenAmount) external {
        require(msg.sender == address(this), "TaxProcessor: only self can call");
        require(tokenAmount > 0, "TaxProcessor: zero amount");
        require(_isTaxTokenOnDex(), "TaxProcessor: tax token not on DEX");

        _processFeeToken(tokenAmount);

        emit FlapTaxProcessorTokensReconciled(taxToken, tokenAmount);
    }

    // ═════════════════════════════════════════════════════════════════════════
    // Multi-wallet configuration — delegated to ADMIN_IMPL
    // ═════════════════════════════════════════════════════════════════════════

    function setWalletConfig(
        address mktOrVaultAddr1,
        address mktOrVaultAddr2,
        uint16 mktOrVaultBps2,
        address mktOrVaultAddr3,
        uint16 mktOrVaultBps3,
        address mktOrVaultAddr4,
        uint16 mktOrVaultBps4
    ) external {
        _delegateToAdminImpl();
    }

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
        )
    {
        PackedFeeConfigInternal memory config = _feeConfig;
        return (
            _mktOrVaultAddress1,
            config.mktOrVaultBps1,
            _mktOrVaultAddress2,
            config.mktOrVaultBps2,
            _mktOrVaultAddress3,
            config.mktOrVaultBps3,
            _mktOrVaultAddress4,
            config.mktOrVaultBps4
        );
    }

    // ═════════════════════════════════════════════════════════════════════════
    // Setter Functions — delegated to ADMIN_IMPL
    // ═════════════════════════════════════════════════════════════════════════

    function setReceivers(address feeReceiver_, address marketAddress_, address dividendAddress_) external {
        _delegateToAdminImpl();
    }

    function setTaxConfig(uint16 feeRate_, uint16 marketBps_, uint16 deflationBps_, uint16 lpBps_, uint16 dividendBps_)
        external
    {
        _delegateToAdminImpl();
    }

    function setMaxBuyBackGasLimit(uint256 newLimit) external {
        _delegateToAdminImpl();
    }

    function setFeeRate(uint16 feeRate_) external {
        _delegateToAdminImpl();
    }

    function setMinBuyBackQuote(uint256 newAmount) external {
        _delegateToAdminImpl();
    }

    function setCommissionConfig(address receiver, uint16 bps) external {
        _delegateToAdminImpl();
    }

    function setDividendToken(address token) external {
        _delegateToAdminImpl();
    }

    function setConverter(address converter_) external {
        _delegateToAdminImpl();
    }

    function setLiqExpectedOutputAmount(uint256 amount) external {
        _delegateToAdminImpl();
    }

    function setLiqSmoothingGapQuote(uint256 gap) external {
        _delegateToAdminImpl();
    }

    function setAutoForwarding(address receiver, bool enabled) external {
        _delegateToAdminImpl();
    }

    // ═════════════════════════════════════════════════════════════════════════
    // View Functions
    // ═════════════════════════════════════════════════════════════════════════

    /// @notice Backward-compatible getter for market/vault address 1 (beneficiary).
    /// @dev Replaces the former `address public marketAddress` auto-getter.
    function marketAddress() external view returns (address) {
        return _mktOrVaultAddress1;
    }

    function requiresMEVProtection() external view returns (bool) {
        address dvToken = dividendToken;
        return dvToken != quoteToken && dvToken != taxToken;
    }

    function feeConfig() external view returns (PackedFeeConfig memory) {
        PackedFeeConfigInternal memory c = _feeConfig;
        return PackedFeeConfig({
            marketBps: c.mktOrVaultBps1 + c.mktOrVaultBps2 + c.mktOrVaultBps3 + c.mktOrVaultBps4,
            deflationBps: c.deflationBps,
            lpBps: c.lpBps,
            dividendBps: c.dividendBps,
            feeRate: c.feeRate,
            isWeth: c.isWeth
        });
    }

    function commissionBps() external view returns (uint16) {
        return _feeConfig.commissionBps;
    }

    function feeConfigV2() external view returns (PackedFeeConfigV2 memory result) {
        PackedFeeConfigInternal memory config = _feeConfig;
        result = PackedFeeConfigV2({
            marketBps: config.mktOrVaultBps1 + config.mktOrVaultBps2 + config.mktOrVaultBps3 + config.mktOrVaultBps4,
            deflationBps: config.deflationBps,
            lpBps: config.lpBps,
            dividendBps: config.dividendBps,
            feeRate: config.feeRate,
            isWeth: config.isWeth,
            commissionBps: config.commissionBps,
            dividendToken: dividendToken
        });
    }

    function feeConfigV3() external view returns (PackedFeeConfigV3 memory result) {
        PackedFeeConfigInternal memory config = _feeConfig;
        result = PackedFeeConfigV3({
            mktOrVaultBps1: config.mktOrVaultBps1,
            mktOrVaultBps2: config.mktOrVaultBps2,
            mktOrVaultBps3: config.mktOrVaultBps3,
            mktOrVaultBps4: config.mktOrVaultBps4,
            deflationBps: config.deflationBps,
            lpBps: config.lpBps,
            dividendBps: config.dividendBps,
            feeRate: config.feeRate,
            isWeth: config.isWeth,
            commissionBps: config.commissionBps,
            dividendToken: dividendToken,
            mktOrVaultAddr1: _mktOrVaultAddress1,
            mktOrVaultAddr2: _mktOrVaultAddress2,
            mktOrVaultAddr3: _mktOrVaultAddress3,
            mktOrVaultAddr4: _mktOrVaultAddress4
        });
    }

    function totalQuoteSentToDividend() external view returns (uint256) {
        return totalDividendTokenSent;
    }

    function dividendQuoteBalance() external view returns (uint256) {
        return pendingDividendQuoteTokenBalance;
    }

    // ═════════════════════════════════════════════════════════════════════════
    // Emergency Functions — delegated to ADMIN_IMPL
    // ═════════════════════════════════════════════════════════════════════════

    function withdrawAll(address token, address to) external {
        _delegateToAdminImpl();
    }

    // ═════════════════════════════════════════════════════════════════════════
    // V4-specific admin — delegated to ADMIN_IMPL
    // TaxProcessorUniV2 overrides checkAndNotifyDispatch() as a no-op since
    // V2 tokens have no Uniswap V4 LP positions.
    // ═════════════════════════════════════════════════════════════════════════

    function setDispatchThreshold(uint256 threshold) external virtual {
        _delegateToAdminImpl();
    }

    function setDispatchCheckCooldown(uint256 cooldown) external virtual {
        _delegateToAdminImpl();
    }

    function checkAndNotifyDispatch() external virtual {
        _delegateToAdminImpl();
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Fallback
    // ─────────────────────────────────────────────────────────────────────────

    receive() external payable {
        // ETH arriving from WETH.withdraw() or Portal swap/refund flows is for internal
        // dispatch / swap / buyback use and must never be auto-forwarded.
        if (msg.sender == weth || msg.sender == portal) return;

        if (!autoForward) return;

        address receiver = forwardAddress;
        if (receiver == address(0)) return;

        (bool ok,) = payable(receiver).call{value: msg.value}("");
        if (ok) {
            emit FlapNativeReceiveForwarded(msg.sender, receiver, msg.value);
        } else {
            emit FlapNativeReceiveForwardFailed(msg.sender, receiver, msg.value);
        }
    }
}

