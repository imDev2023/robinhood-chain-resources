// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {OwnableUpgradeable} from "@openzeppelin-contracts-upgradeable/access/OwnableUpgradeable.sol";
import {
    IERC20MetadataUpgradeable as IToken
} from "@openzeppelin-contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

interface IWETH {
    function withdraw(uint256) external;
}

/// @notice a very simple tax splitter contract
contract TaxSplitter is OwnableUpgradeable {
    using SafeERC20 for IERC20;
    address public immutable WETH_ADDRESS;

    address public beneficiary;
    address public feeReceiver;
    uint256 public splitRatio; // in basis points (1/100 of a percent)
    address public token;
    address public quoteToken; // new state variable for quote token
    uint256 public totalQuoteSentToMarketing; // total quote tokens sent to beneficiary (marketing wallet)

    event TaxSentToBeneficiary(address beneficiary, uint256 amount);
    event TaxSentToFeeReceiver(address feeReceiver, uint256 amount);

    constructor(address _wethAddress) {
        require(_wethAddress != address(0), "WETH address cannot be zero");
        WETH_ADDRESS = _wethAddress;
    }

    function initialize(address _beneficiary, address _feeReceiver, address _token, address _quoteToken)
        external
        initializer
    {
        __Ownable_init();
        require(_beneficiary != address(0), "Beneficiary cannot be zero");
        require(_feeReceiver != address(0), "FeeReceiver cannot be zero");
        beneficiary = _beneficiary;
        feeReceiver = _feeReceiver;
        splitRatio = 9000; // default 90% to beneficiary, 10% to feeReceiver
        token = _token;
        quoteToken = _quoteToken; // set quote token
    }

    /// @notice Split the tax based on the current balance of the quote token
    /// @dev Anyone can call this function. If quoteToken is zero address, use WETH and unwrap to ETH
    function split() external {
        _split();
    }

    /// @notice Dispatch method (alias for split)
    /// @dev Compatible with ITaxProcessor interface
    function dispatch() external {
        _split();
    }

    /// @notice Internal function to split the tax
    /// @dev Extracted from split() to be reused by dispatch()
    function _split() private {
        if (quoteToken == address(0)) {
            // Handle native token case: unwrap WETH to ETH and send ETH
            uint256 bal = IToken(WETH_ADDRESS).balanceOf(address(this));
            if (bal == 0) {
                return;
            }

            // Unwrap WETH to ETH
            IWETH(WETH_ADDRESS).withdraw(bal);

            uint256 beneficiaryAmount = (bal * splitRatio) / 10000;
            uint256 feeAmount = bal - beneficiaryAmount;
            uint256 remainingAmount = 0;

            // Try to send ETH to beneficiary first
            if (beneficiaryAmount > 0) {
                (bool successB,) = beneficiary.call{value: beneficiaryAmount}("");
                if (successB) {
                    emit TaxSentToBeneficiary(beneficiary, beneficiaryAmount);
                    // Track successful marketing payment
                    totalQuoteSentToMarketing += beneficiaryAmount;
                } else {
                    // If beneficiary refuses, add to amount for feeReceiver
                    remainingAmount += beneficiaryAmount;
                }
            }

            // Send fee amount + any refused amount to feeReceiver
            uint256 totalFeeAmount = feeAmount + remainingAmount;
            if (totalFeeAmount > 0) {
                (bool successF,) = feeReceiver.call{value: totalFeeAmount}("");
                require(successF, "FeeReceiver must accept payment to drain contract");
                emit TaxSentToFeeReceiver(feeReceiver, totalFeeAmount);
            }
        } else {
            // Handle ERC20 token case
            uint256 bal = IToken(quoteToken).balanceOf(address(this));
            if (bal == 0) {
                return;
            }

            uint256 beneficiaryAmount = (bal * splitRatio) / 10000;
            uint256 feeAmount = bal - beneficiaryAmount;
            uint256 remainingAmount = 0;

            // Try to send to beneficiary first
            if (beneficiaryAmount > 0) {
                // Use low-level call to handle both standard ERC20 (returns bool) and
                // non-standard tokens like USDT (no return value), while also catching
                // reverts — so a failed beneficiary transfer falls back to feeReceiver.
                (bool callOk, bytes memory retData) =
                    quoteToken.call(abi.encodeWithSelector(IERC20.transfer.selector, beneficiary, beneficiaryAmount));
                bool successB = callOk && (retData.length == 0 || abi.decode(retData, (bool)));
                if (successB) {
                    emit TaxSentToBeneficiary(beneficiary, beneficiaryAmount);
                    // Track successful marketing payment
                    totalQuoteSentToMarketing += beneficiaryAmount;
                } else {
                    // If beneficiary transfer fails, add to amount for feeReceiver
                    remainingAmount += beneficiaryAmount;
                }
            }

            // Send fee amount + any refused amount to feeReceiver
            uint256 totalFeeAmount = feeAmount + remainingAmount;
            if (totalFeeAmount > 0) {
                IERC20(quoteToken).safeTransfer(feeReceiver, totalFeeAmount);
                emit TaxSentToFeeReceiver(feeReceiver, totalFeeAmount);
            }
        }
    }

    /// @notice Fallback function - no longer handles splitting logic
    /// @dev Reserved for future use or accidental ETH sends
    receive() external payable {
        // ETH sent here will not be automatically split
        // Use the split() function instead after wrapping ETH to WETH
    }

    function setBeneficiary(address _beneficiary) external onlyOwner {
        require(_beneficiary != address(0), "Beneficiary cannot be zero");
        beneficiary = _beneficiary;
    }

    function setFeeReceiver(address _feeReceiver) external onlyOwner {
        require(_feeReceiver != address(0), "FeeReceiver cannot be zero");
        feeReceiver = _feeReceiver;
    }

    function setSplitRatio(uint256 _splitRatio) external onlyOwner {
        require(_splitRatio <= 10000, "Split ratio too high");
        splitRatio = _splitRatio;
    }

    // Renamed and updated: allow passing token address
    function sweep(address _token) external onlyOwner {
        if (_token == address(0)) {
            uint256 balance = address(this).balance;
            require(balance > 0, "No ETH balance");
            (bool sent,) = owner().call{value: balance}("");
            require(sent, "ETH transfer failed");
        } else {
            uint256 balance = IToken(_token).balanceOf(address(this));
            require(balance > 0, "No token balance");
            IERC20(_token).safeTransfer(owner(), balance);
        }
    }

    // version function
    function version() external pure returns (string memory) {
        // revison

        // v0.0.2: add all view methods from TaxProcessor, so can be used in read-only context without telling if it's a TaxProcessor or TaxSplitter
        // v0.0.1: initial version

        return "0.0.2";
    }

    //
    // Implement ITaxProcessor view methods for compatibility
    //

    /// @notice Get the quote token address
    /// @return The quote token address (WETH if quoteToken is zero, otherwise stored quoteToken)
    function getQuoteToken() external view returns (address) {
        return quoteToken == address(0) ? WETH_ADDRESS : quoteToken;
    }

    /// @notice Get WETH address (for compatibility with TaxProcessor)
    function weth() external view returns (address) {
        return WETH_ADDRESS;
    }

    /// @notice Get flapBlackHole address (returns zero for TaxSplitter)
    function flapBlackHole() external pure returns (address) {
        return address(0);
    }

    /// @notice Get tax token address (maps to token in TaxSplitter)
    function taxToken() external view returns (address) {
        return token;
    }

    /// @notice Get router address (returns zero for TaxSplitter)
    function router() external pure returns (address) {
        return address(0);
    }

    /// @notice Get market address (maps to beneficiary in TaxSplitter)
    function marketAddress() external view returns (address) {
        return beneficiary;
    }

    /// @notice Get dividend address (returns zero for TaxSplitter)
    function dividendAddress() external pure returns (address) {
        return address(0);
    }

    /// @notice Get fee quote balance (always 0 for TaxSplitter - no accumulation)
    function feeQuoteBalance() external pure returns (uint256) {
        return 0;
    }

    /// @notice Get LP quote balance (always 0 for TaxSplitter - no LP)
    function lpQuoteBalance() external pure returns (uint256) {
        return 0;
    }

    /// @notice Get market quote balance (always 0 for TaxSplitter - no accumulation)
    function marketQuoteBalance() external pure returns (uint256) {
        return 0;
    }

    /// @notice Get dividend quote balance (always 0 for TaxSplitter - no dividend)
    function dividendQuoteBalance() external pure returns (uint256) {
        return 0;
    }

    /// @notice Get packed fee configuration (constructed from splitRatio)
    /// @dev marketBps = splitRatio, feeRate = 10000 - splitRatio, others are 0
    function feeConfig()
        external
        view
        returns (uint16 marketBps, uint16 deflationBps, uint16 lpBps, uint16 dividendBps, uint16 feeRate, bool isWeth)
    {
        return (
            uint16(splitRatio), // marketBps = splitRatio
            0, // deflationBps = 0 (no deflation)
            0, // lpBps = 0 (no LP)
            0, // dividendBps = 0 (no dividend)
            uint16(10000 - splitRatio), // feeRate = 10000 - splitRatio
            quoteToken == address(0) // isWeth = true if quoteToken is zero
        );
    }

    /// @notice Get total quote sent to dividend (always 0 for TaxSplitter)
    function totalQuoteSentToDividend() external pure returns (uint256) {
        return 0;
    }

    /// @notice Get total quote added to liquidity (always 0 for TaxSplitter)
    function totalQuoteAddedToLiquidity() external pure returns (uint256) {
        return 0;
    }

    /// @notice Get total token added to liquidity (always 0 for TaxSplitter)
    function totalTokenAddedToLiquidity() external pure returns (uint256) {
        return 0;
    }
}

