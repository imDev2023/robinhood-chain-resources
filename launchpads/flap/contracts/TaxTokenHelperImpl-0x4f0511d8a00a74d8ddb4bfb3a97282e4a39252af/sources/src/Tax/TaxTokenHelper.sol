// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ITokenV3} from "src/interfaces/ITokenV3.sol";
import {Dividend} from "src/Tax/Dividend.sol";
import {FlapTaxToken} from "src/Tax/FlapTaxToken.sol";
import {IDividend} from "src/interfaces/Tax/IDividend.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {IFlapAIProvider} from "src/interfaces/Vault/IFlapAIProvider.sol";
import {IFlapTaxTokenV2} from "src/interfaces/Tax/IFlapTaxTokenV2.sol";
import {IFlapTaxTokenV3} from "src/interfaces/Tax/IFlapTaxTokenV3.sol";
import {IPortal, IPortalTypes} from "src/interfaces/IPortal.sol";
import {ITaxProcessorV2} from "src/interfaces/Tax/ITaxProcessorV2.sol";
import {IVaultPortal, IVaultPortalTypes} from "src/interfaces/Vault/IVaultPortal.sol";
import {PackedFeeConfig} from "src/interfaces/Tax/ITaxProcessor.sol";
import {TaxProcessorUniV2} from "src/Tax/TaxProcessorUniV2.sol";
import {TaxSplitter} from "src/TaxSplitter.sol";

contract TaxTokenHelper {
    IPortal public immutable portal;
    IVaultPortal public immutable vaultPortal;
    IFlapAIProvider public immutable flapAIProvider;

    constructor(address _portal, address _vaultPortal, address _flapAIProvider) {
        portal = IPortal(_portal);
        vaultPortal = IVaultPortal(_vaultPortal);
        flapAIProvider = IFlapAIProvider(_flapAIProvider);
    }

    function version() external pure returns (string memory) {
        return "0.0.3";
    }

    struct TaxTokenInfo {
        uint16 marketBps;
        uint16 deflationBps;
        uint16 lpBps;
        uint16 dividendBps;
        uint16 taxRate;
        uint256 burntTokenAmount;
        uint256 totalQuoteSentToDividend;
        uint256 totalQuoteAddedToLiquidity;
        uint256 totalTokenAddedToLiquidity;
        uint256 totalQuoteSentToMarketing;
        address marketingWallet;
        address quoteToken;
        uint256 minimumShareBalance;
    }

    /// @notice Information about the marketing wallet or vault associated with a tax token.
    ///         This struct is used to provide richer context about who receives the marketing
    ///         tax revenue, including whether it is a Flap Vault and whether it uses AI Oracle.
    struct MarketingWalletInfo {
        /// @notice The marketing wallet address, which could be:
        ///         - A plain EOA marketing wallet
        ///         - A Flap Vault contract (created via VaultPortal)
        ///         - Any smart contract (potentially using Flap AI Oracle)
        address addr;
        /// @notice The vault factory address that created this vault.
        ///         Zero if the marketing wallet is not a Flap Vault, or
        ///         the factory is unknown (e.g., legacy vault, adapter-based).
        ///         Only populated when the vault was created via Flap's VaultPortal.
        address factory;
        /// @notice The risk level of the vault as assessed by Flap auditors.
        ///         Defaults to UNVERIFIED (0) for non-vault marketing wallets.
        ///         See IVaultPortalTypes.RiskLevel for possible values:
        ///         UNVERIFIED(0), LOW_RISK(1), LOW_MEDIUM_RISK(2), MEDIUM_RISK(3), HIGH_RISK(4)
        uint8 riskLevel;
        /// @notice Whether the vault is an official Flap-endorsed vault.
        ///         Always false for non-vault marketing wallets.
        bool isOfficialVault;
        /// @notice Whether the marketing wallet is a Flap Vault (i.e., was
        ///         registered via VaultPortal and implements the Vault interface).
        ///         Determined by calling VaultPortal.tryGetVault(taxToken).
        bool isVault;
        /// @notice Whether the marketing wallet is an AI consumer. True when either:
        ///         (a) The vault's category is TYPE_AI_ORACLE_POWERED (from VaultPortal), OR
        ///         (b) The address is a smart contract (non-EOA, non-EIP-7702 delegate)
        ///             that has made at least one AI request via FlapAIProvider
        ///             (checked via getTotalRequestsByConsumer > 0).
        bool isAIConsumer;
    }

    /// @notice Extended tax token info with vault/AI metadata.
    ///         Replaces TaxTokenInfo with richer fields for AI consumer detection.
    struct TaxTokenInfoV2 {
        uint16 marketBps;
        uint16 deflationBps;
        uint16 lpBps;
        uint16 dividendBps;
        /// @notice The tax rate applied on buys, in basis points (e.g., 500 = 5%).
        uint16 buyTaxRate;
        /// @notice The tax rate applied on sells, in basis points (e.g., 500 = 5%).
        ///         Currently equal to buyTaxRate as the contract uses a single taxRate.
        uint16 sellTaxRate;
        uint256 burntTokenAmount;
        uint256 totalQuoteSentToDividend;
        uint256 totalQuoteAddedToLiquidity;
        uint256 totalTokenAddedToLiquidity;
        uint256 totalQuoteSentToMarketing;
        /// @notice The token distributed as dividends to shareholders.
        ///         address(0) means the native gas token (e.g., BNB or ETH);
        ///         any other address is the ERC20 reward token.
        address dividendToken;
        address quoteToken;
        uint256 minimumShareBalance;
        /// @notice Information about the marketing wallet / vault that receives tax revenue.
        MarketingWalletInfo vaultInfo;
    }

    function getTaxTokenInfo(address taxToken) external view returns (TaxTokenInfo memory info) {
        // Use V8Safe to avoid enum decode reverts when Portal adds new enum variants.
        IPortal.TokenStateV8Safe memory state = portal.getTokenV8Safe(taxToken);

        // Check token version
        if (state.tokenVersion == uint8(IPortalTypes.TokenVersion.TOKEN_V2_PERMIT)) {
            // TOKEN_V2_PERMIT has no tax
            return info;
        }

        if (state.tokenVersion == uint8(IPortalTypes.TokenVersion.TOKEN_TAXED)) {
            // Legacy tax token - get beneficiary from tax splitter
            address taxSplitterAddress = FlapTaxToken(taxToken).taxSplitter();
            TaxSplitter taxSplitter = TaxSplitter(payable(taxSplitterAddress));
            address beneficiaryAddress = taxSplitter.beneficiary();

            info.marketBps = 10000; // 100% to marketing
            info.deflationBps = 0;
            info.lpBps = 0;
            info.dividendBps = 0;
            uint256 maxTaxRate = state.buyTaxRate >= state.sellTaxRate ? state.buyTaxRate : state.sellTaxRate;
            info.taxRate = uint16(maxTaxRate);
            info.marketingWallet = beneficiaryAddress;
            info.quoteToken = state.quoteTokenAddress;

            // Try to get totalQuoteSentToMarketing - may not exist in older splitters
            try taxSplitter.totalQuoteSentToMarketing() returns (uint256 total) {
                info.totalQuoteSentToMarketing = total;
            } catch {
                // Old splitter without this method - leave as 0
            }

            return info;
        }

        // Handle TOKEN_TAXED_V2 and TOKEN_TAXED_V3 (share the same TaxProcessor interface)
        IFlapTaxTokenV2 token = IFlapTaxTokenV2(taxToken);
        address taxProcessorAddr = token.taxProcessor();

        if (taxProcessorAddr == address(0)) {
            return info;
        }

        TaxProcessorUniV2 processor = TaxProcessorUniV2(payable(taxProcessorAddr));

        // 1. Tax allocation pie chart
        PackedFeeConfig memory fc = processor.feeConfig();
        info.marketBps = fc.marketBps;
        info.deflationBps = fc.deflationBps;
        info.lpBps = fc.lpBps;
        info.dividendBps = fc.dividendBps;
        // For TOKEN_TAXED_V3, taxRate() returns max(buyTaxRate, sellTaxRate) for backward compat.
        // TOKEN_V3_PERMIT has taxProcessor but no taxRate() — default to 0.
        if (state.tokenVersion != uint8(IPortalTypes.TokenVersion.TOKEN_V3_PERMIT)) {
            info.taxRate = token.taxRate();
        }

        // 1.1 Addresses
        info.marketingWallet = processor.marketAddress();
        info.quoteToken = fc.isWeth ? address(0) : processor.quoteToken();

        // 2. Burnt token amount
        address flapBlackHole = processor.flapBlackHole();
        address deadAddress = processor.DEAD_ADDRESS();

        uint256 blackHoleBalance = 0;
        if (flapBlackHole != address(0)) {
            blackHoleBalance = IERC20(taxToken).balanceOf(flapBlackHole);
        }
        uint256 deadBalance = 0;
        // Only count deadAddress balance if it's different from flapBlackHole
        if (deadAddress != flapBlackHole) {
            deadBalance = IERC20(taxToken).balanceOf(deadAddress);
        }
        info.burntTokenAmount = blackHoleBalance + deadBalance;

        // 3, 4, 5. Cumulative amounts
        info.totalQuoteSentToDividend = processor.totalQuoteSentToDividend();
        info.totalQuoteAddedToLiquidity = processor.totalQuoteAddedToLiquidity();
        info.totalTokenAddedToLiquidity = processor.totalTokenAddedToLiquidity();
        info.totalQuoteSentToMarketing = processor.totalQuoteSentToMarketing();

        // 6. Dividend info
        address dividendAddr = token.dividendContract();
        if (dividendAddr != address(0)) {
            info.minimumShareBalance = IDividend(dividendAddr).minimumShareBalance();
        }
    }

    function getTaxTokenInfoV2(address taxToken) external view returns (TaxTokenInfoV2 memory info) {
        // Use V8Safe to avoid enum decode reverts when Portal adds new enum variants.
        IPortal.TokenStateV8Safe memory state = portal.getTokenV8Safe(taxToken);

        // Check token version
        if (state.tokenVersion == uint8(IPortalTypes.TokenVersion.TOKEN_V2_PERMIT)) {
            // TOKEN_V2_PERMIT has no tax
            return info;
        }

        if (state.tokenVersion == uint8(IPortalTypes.TokenVersion.TOKEN_TAXED)) {
            // Legacy tax token - get beneficiary from tax splitter
            address taxSplitterAddress = FlapTaxToken(taxToken).taxSplitter();
            TaxSplitter taxSplitter = TaxSplitter(payable(taxSplitterAddress));

            info.marketBps = 10000; // 100% to marketing
            info.buyTaxRate = uint16(state.buyTaxRate);
            info.sellTaxRate = uint16(state.sellTaxRate);
            info.vaultInfo.addr = taxSplitter.beneficiary();
            info.quoteToken = state.quoteTokenAddress;

            // Try to get totalQuoteSentToMarketing - may not exist in older splitters
            try taxSplitter.totalQuoteSentToMarketing() returns (uint256 total) {
                info.totalQuoteSentToMarketing = total;
            } catch {}

            info = _populateVaultInfo(taxToken, info);
            return info;
        }

        // Handle TOKEN_TAXED_V3 (asymmetric buy/sell rates, commission support)
        if (state.tokenVersion == uint8(IPortalTypes.TokenVersion.TOKEN_TAXED_V3)) {
            info = _fillFromTaxedV3(taxToken, info);
            return info;
        } else if (state.tokenVersion == uint8(IPortalTypes.TokenVersion.TOKEN_TAXED_V2)) {
            // Handle TOKEN_TAXED_V2
            info = _fillFromTaxedV2(taxToken, info);
        } else if (state.tokenVersion == uint8(IPortalTypes.TokenVersion.TOKEN_V3_PERMIT)) {
            info = _fillFromTokenV3(taxToken, info);
        }
        return info;
    }

    /// @dev Fills TaxTokenInfoV2 fields from a TOKEN_TAXED_V2 token.
    function _fillFromTaxedV2(address taxToken, TaxTokenInfoV2 memory info)
        internal
        view
        returns (TaxTokenInfoV2 memory)
    {
        IFlapTaxTokenV2 token = IFlapTaxTokenV2(taxToken);
        address taxProcessorAddr = token.taxProcessor();

        if (taxProcessorAddr == address(0)) {
            return info;
        }

        TaxProcessorUniV2 processor = TaxProcessorUniV2(payable(taxProcessorAddr));

        // 1. Tax allocation pie chart
        PackedFeeConfig memory fc = processor.feeConfig();
        info.marketBps = fc.marketBps;
        info.deflationBps = fc.deflationBps;
        info.lpBps = fc.lpBps;
        info.dividendBps = fc.dividendBps;
        info.buyTaxRate = token.taxRate();
        info.sellTaxRate = info.buyTaxRate;

        // 1.1 Addresses
        info.vaultInfo.addr = processor.marketAddress();
        info.quoteToken = fc.isWeth ? address(0) : processor.quoteToken();

        // 2. Burnt token amount
        {
            address flapBlackHole = processor.flapBlackHole();
            address deadAddress = processor.DEAD_ADDRESS();
            uint256 burnt = flapBlackHole != address(0) ? IERC20(taxToken).balanceOf(flapBlackHole) : 0;
            if (deadAddress != flapBlackHole) {
                burnt += IERC20(taxToken).balanceOf(deadAddress);
            }
            info.burntTokenAmount = burnt;
        }

        // 3, 4, 5. Cumulative amounts
        info.totalQuoteSentToDividend = processor.totalQuoteSentToDividend();
        info.totalQuoteAddedToLiquidity = processor.totalQuoteAddedToLiquidity();
        info.totalTokenAddedToLiquidity = processor.totalTokenAddedToLiquidity();
        info.totalQuoteSentToMarketing = processor.totalQuoteSentToMarketing();

        // 6. Dividend info
        address dividendAddr = token.dividendContract();
        if (dividendAddr != address(0)) {
            info.minimumShareBalance = IDividend(dividendAddr).minimumShareBalance();
            info.dividendToken = _getDividendToken(dividendAddr);
        }

        return _populateVaultInfo(taxToken, info);
    }

    /// @dev Fills TaxTokenInfoV2 fields from a TOKEN_TAXED_V3 token.
    ///      TOKEN_TAXED_V3 supports asymmetric buy/sell tax rates and an optional commission.
    ///      Unlike TOKEN_TAXED_V2, the dividend token is stored directly in the TaxProcessor
    ///      and buy/sell rates are read separately via buyTaxRate()/sellTaxRate().
    function _fillFromTaxedV3(address taxToken, TaxTokenInfoV2 memory info)
        internal
        view
        returns (TaxTokenInfoV2 memory)
    {
        IFlapTaxTokenV3 token = IFlapTaxTokenV3(taxToken);
        address taxProcessorAddr = token.taxProcessor();

        if (taxProcessorAddr == address(0)) {
            return info;
        }

        TaxProcessorUniV2 processor = TaxProcessorUniV2(payable(taxProcessorAddr));

        // 1. Tax allocation pie chart
        PackedFeeConfig memory fc = processor.feeConfig();
        info.marketBps = fc.marketBps;
        info.deflationBps = fc.deflationBps;
        info.lpBps = fc.lpBps;
        info.dividendBps = fc.dividendBps;
        // V3: read asymmetric buy/sell rates directly
        info.buyTaxRate = token.buyTaxRate();
        info.sellTaxRate = token.sellTaxRate();

        // 1.1 Addresses
        info.vaultInfo.addr = processor.marketAddress();
        info.quoteToken = fc.isWeth ? address(0) : processor.quoteToken();

        // 2. Burnt token amount
        {
            address flapBlackHole = processor.flapBlackHole();
            address deadAddress = processor.DEAD_ADDRESS();
            uint256 burnt = flapBlackHole != address(0) ? IERC20(taxToken).balanceOf(flapBlackHole) : 0;
            if (deadAddress != flapBlackHole) {
                burnt += IERC20(taxToken).balanceOf(deadAddress);
            }
            info.burntTokenAmount = burnt;
        }

        // 3, 4, 5. Cumulative amounts
        info.totalQuoteSentToDividend = processor.totalQuoteSentToDividend();
        info.totalQuoteAddedToLiquidity = processor.totalQuoteAddedToLiquidity();
        info.totalTokenAddedToLiquidity = processor.totalTokenAddedToLiquidity();
        info.totalQuoteSentToMarketing = processor.totalQuoteSentToMarketing();

        // 6. Dividend info
        address dividendAddr = token.dividendContract();
        if (dividendAddr != address(0)) {
            info.minimumShareBalance = IDividend(dividendAddr).minimumShareBalance();
        }
        // For V3, dividendToken is explicitly stored in the TaxProcessor (always non-zero after init)
        info.dividendToken = processor.dividendToken();

        return _populateVaultInfo(taxToken, info);
    }

    /// @dev Fills TokenV3 fields from a TOKEN_V3_PERMIT token.
    function _fillFromTokenV3(address taxToken, TaxTokenInfoV2 memory info)
        internal
        view
        returns (TaxTokenInfoV2 memory)
    {
        ITokenV3 token = ITokenV3(taxToken);
        address taxProcessorAddr = token.taxProcessor();

        if (taxProcessorAddr == address(0)) {
            return info;
        }

        TaxProcessorUniV2 processor = TaxProcessorUniV2(payable(taxProcessorAddr));

        // 1. Tax allocation pie chart
        PackedFeeConfig memory fc = processor.feeConfig();
        info.marketBps = fc.marketBps;
        info.deflationBps = fc.deflationBps;
        info.lpBps = fc.lpBps;
        info.dividendBps = fc.dividendBps;
        info.buyTaxRate = 0;
        info.sellTaxRate = 0;

        // 1.1 Addresses
        info.vaultInfo.addr = processor.marketAddress();
        info.quoteToken = fc.isWeth ? address(0) : processor.quoteToken();

        // 2. Burnt token amount
        {
            address flapBlackHole = processor.flapBlackHole();
            address deadAddress = processor.DEAD_ADDRESS();
            uint256 burnt = flapBlackHole != address(0) ? IERC20(taxToken).balanceOf(flapBlackHole) : 0;
            if (deadAddress != flapBlackHole) {
                burnt += IERC20(taxToken).balanceOf(deadAddress);
            }
            info.burntTokenAmount = burnt;
        }

        // 3, 4, 5. Cumulative amounts
        info.totalQuoteSentToDividend = processor.totalQuoteSentToDividend();
        info.totalQuoteAddedToLiquidity = processor.totalQuoteAddedToLiquidity();
        info.totalTokenAddedToLiquidity = processor.totalTokenAddedToLiquidity();
        info.totalQuoteSentToMarketing = processor.totalQuoteSentToMarketing();

        // 6. Dividend info
        address dividendAddr = token.dividendContract();
        if (dividendAddr != address(0)) {
            info.minimumShareBalance = IDividend(dividendAddr).minimumShareBalance();
            info.dividendToken = _getDividendToken(dividendAddr);
        }

        return _populateVaultInfo(taxToken, info);
    }

    /// @dev Returns the dividend reward token address for a Dividend contract.
    ///      Returns address(0) if the dividend token is the native gas token (WETH wrapper).
    function _getDividendToken(address dividendAddr) internal view returns (address) {
        try Dividend(payable(dividendAddr)).dividendToken() returns (address dt) {
            try Dividend(payable(dividendAddr)).weth() returns (address w) {
                if (dt == w && w != address(0)) {
                    return address(0); // native gas token
                }
            } catch {}
            return dt;
        } catch {}
        return address(0);
    }

    /// @dev Populates vaultInfo fields using VaultPortal and FlapAIProvider lookups.
    ///      Silently skips each step if the respective dependency address is zero or the call reverts.
    function _populateVaultInfo(address taxToken, TaxTokenInfoV2 memory info)
        internal
        view
        returns (TaxTokenInfoV2 memory)
    {
        // Step A: Query VaultPortal for vault registration info
        if (address(vaultPortal) != address(0)) {
            try vaultPortal.tryGetVault(taxToken) returns (bool found, IVaultPortalTypes.VaultInfo memory vi) {
                if (found) {
                    info.vaultInfo.isVault = true;
                    info.vaultInfo.factory = vi.vaultFactory;
                    info.vaultInfo.riskLevel = uint8(vi.riskLevel);
                    info.vaultInfo.isOfficialVault = vi.isOfficial;
                }
            } catch {}

            // Step B1: Vault category check for AI Consumer
            if (info.vaultInfo.isVault) {
                try vaultPortal.getVaultCategory(taxToken) returns (IVaultPortalTypes.VaultCategory cat) {
                    if (cat == IVaultPortalTypes.VaultCategory.TYPE_AI_ORACLE_POWERED) {
                        info.vaultInfo.isAIConsumer = true;
                    }
                } catch {}
            }
        }

        // Step B2: FlapAIProvider check (if not already flagged as AI consumer)
        if (!info.vaultInfo.isAIConsumer && address(flapAIProvider) != address(0)) {
            address wallet = info.vaultInfo.addr;
            if (wallet != address(0) && wallet.code.length > 0) {
                // Exclude EIP-7702 delegated EOAs (code starts with 0xef0100)
                bytes memory code = wallet.code;
                bool is7702 = code.length >= 3 && code[0] == 0xef && code[1] == 0x01 && code[2] == 0x00;
                if (!is7702) {
                    try flapAIProvider.getTotalRequestsByConsumer(wallet) returns (uint256 totalReqs) {
                        if (totalReqs > 0) {
                            info.vaultInfo.isAIConsumer = true;
                        }
                    } catch {}
                }
            }
        }

        return info;
    }

    function getDividendInfo(address taxToken, address user) external view returns (uint256 claimed, uint256 pending) {
        IFlapTaxTokenV2 token = IFlapTaxTokenV2(taxToken);
        address dividendAddr = token.dividendContract();

        if (dividendAddr == address(0)) {
            return (0, 0);
        }

        IDividend dividend = IDividend(dividendAddr);
        claimed = dividend.withdrawnDividends(user);
        pending = dividend.withdrawableDividends(user);
    }

    function claimDividend(address taxToken) external {
        IFlapTaxTokenV2 token = IFlapTaxTokenV2(taxToken);
        address dividendAddr = token.dividendContract();

        require(dividendAddr != address(0), "TaxTokenHelper: dividend contract not set");

        IDividend(dividendAddr).withdrawDividendsFor(msg.sender);
    }

    function claimDividend(address taxToken, bool unwrapWETH) external {
        IFlapTaxTokenV2 token = IFlapTaxTokenV2(taxToken);
        address dividendAddr = token.dividendContract();

        require(dividendAddr != address(0), "TaxTokenHelper: dividend contract not set");

        IDividend(dividendAddr).withdrawDividendsFor(msg.sender, unwrapWETH);
    }

    function claimDividendForUser(address taxToken, bool unwrapWETH, address user) external {
        IFlapTaxTokenV2 token = IFlapTaxTokenV2(taxToken);
        address dividendAddr = token.dividendContract();

        require(dividendAddr != address(0), "TaxTokenHelper: dividend contract not set");

        IDividend(dividendAddr).withdrawDividendsFor(user, unwrapWETH);
    }
}

