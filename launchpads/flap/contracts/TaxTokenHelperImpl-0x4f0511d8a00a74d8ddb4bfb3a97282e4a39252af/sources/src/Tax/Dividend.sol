// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "@openzeppelin-contracts-upgradeable/access/OwnableUpgradeable.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {Math} from "@openzeppelin/utils/math/Math.sol";
import {IDividend} from "../interfaces/Tax/IDividend.sol";

interface IWETH {
    function withdraw(uint256) external;
}

/// @title Dividend Distribution Contract
/// @notice MasterChef-style dividend distribution based on share proportions
/// @dev Implements precise dividend calculation using magnified dividend per share
contract Dividend is IDividend, OwnableUpgradeable {
    using SafeERC20 for IERC20;

    // --- Constants ---
    uint256 internal constant MAGNITUDE = 2 ** 128;

    // --- Immutable Storage ---
    /// @notice WETH address (if dividendToken == weth, we send native ETH)
    address public immutable weth;

    /// @notice FlapBlackHole address (excluded from dividends)
    address public immutable flapBlackHole;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(address weth_, address flapBlackHole_) {
        require(weth_ != address(0), "Dividend: zero WETH address");
        weth = weth_;
        flapBlackHole = flapBlackHole_;
        _disableInitializers();
    }

    // --- Storage ---
    /// @notice The token used for dividend distribution.
    /// @dev This can be any ERC-20: the quote token, the tax token itself, or an unrelated token.
    ///      The front-end MUST read this field to determine which token is being distributed
    ///      rather than assuming a fixed token type.
    ///      This is never the zero address; when the dividend is the native gas token,
    ///      WETH is used instead and unwrapped to ETH upon withdrawal.
    address public dividendToken;

    /// @notice The FlapTaxToken contract that can call setShare
    address public taxToken;

    /// @notice User info structure combining share, debt, and pending balance
    struct UserInfo {
        uint256 share; // User's share amount
        uint256 rewardDebt; // Reward debt (already claimed debt)
        uint256 pendingBalance; // Pending balance (settled rewards before share changes)
    }

    /// @notice Magnified dividend per share for precise calculation
    uint256 internal magnifiedDividendPerShare;

    /// @notice Total shares across all users
    uint256 public totalShares;

    /// @notice Mapping of user address to their info
    mapping(address => UserInfo) public userInfo;

    /// @notice Total dividends withdrawn by each user
    mapping(address => uint256) public withdrawnDividends;

    /// @notice Total dividends distributed
    uint256 public totalDividendsDistributed;

    /// @notice Minimum share balance required for dividend distribution
    uint256 public minimumShareBalance;

    /// @notice Addresses excluded from receiving dividends
    mapping(address => bool) public excludedFromDividends;

    // --- Modifiers ---
    modifier onlyTaxToken() {
        require(msg.sender == taxToken, "Dividend: caller is not the tax token");
        _;
    }

    function _isExcluded(address user) internal view returns (bool) {
        return user == address(0) || user == address(0xdead) || user == address(this) || user == taxToken
            || user == flapBlackHole || excludedFromDividends[user];
    }

    // --- Initialization ---
    function initialize(address dividendToken_, address taxToken_, uint256 minimumShareBalance_) external initializer {
        require(dividendToken_ != address(0) && taxToken_ != address(0), "Dividend: zero init arg");

        __Ownable_init();

        dividendToken = dividendToken_;
        taxToken = taxToken_;
        minimumShareBalance = minimumShareBalance_;

        // No need to exclude addresses during initialization
        // Exclusion logic will be handled in setShare method or by the calling contract
    }

    // --- External Functions ---

    /// @notice Set user's share (only callable by FlapTaxToken)
    /// @param user The user address
    /// @param share The new share amount for the user
    function setShare(address user, uint256 share) external onlyTaxToken {
        // Skip excluded addresses to save gas (hardcoded exclusions + mapping-based exclusions)
        if (_isExcluded(user)) return;
        // If share is below minimum threshold, set to 0
        if (share < minimumShareBalance) {
            share = 0;
        }

        _setShare(user, share);
    }

    /// @notice Deposit dividends to be distributed
    /// @param amount The amount of dividend tokens to deposit
    /// @return success Whether the deposit was successful
    /// @dev Only accepts ERC20 tokens, returns false if no shares exist
    function deposit(uint256 amount) external returns (bool success) {
        if (amount == 0) {
            return false;
        }

        if (totalShares == 0) {
            return false; // No shareholders to distribute to
        }

        // Transfer dividend tokens (only ERC20).
        // Use balance-diff pattern to correctly account for tokens with transfer taxes.
        uint256 balanceBefore = IERC20(dividendToken).balanceOf(address(this));
        IERC20(dividendToken).safeTransferFrom(msg.sender, address(this), amount);
        uint256 actualReceived = IERC20(dividendToken).balanceOf(address(this)) - balanceBefore;

        if (actualReceived == 0) {
            return false;
        }

        // Update magnified dividend per share based on what was actually received
        magnifiedDividendPerShare = magnifiedDividendPerShare + (actualReceived * MAGNITUDE / totalShares);

        totalDividendsDistributed = totalDividendsDistributed + actualReceived;

        emit FlapDividendDeposited(taxToken, actualReceived, magnifiedDividendPerShare);
        return true;
    }

    /// @notice Batch distribute dividends to specified users
    /// @param users Array of user addresses to distribute dividends to
    function distributeDividend(address[] calldata users) external returns (uint256 successCount) {
        successCount = 0;
        for (uint256 i = 0; i < users.length; i++) {
            if (_withdrawDividendOfUser(users[i], false)) {
                // false = distributeDividend mode (send WETH directly)
                successCount++;
            }
        }

        return successCount;
    }

    /// @notice User can call this to withdraw their own dividends (unwraps WETH to ETH if applicable)
    /// @return success Whether the withdrawal was successful
    function withdrawDividends() external returns (bool success) {
        return _withdrawDividendOfUser(msg.sender, true); // true = withdrawDividends mode (unwrap WETH if needed)
    }

    /// @notice Withdraw dividends for a specific user
    /// @param user The user address to withdraw for
    /// @return success Whether the withdrawal was successful
    function withdrawDividendsFor(address user) external returns (bool success) {
        return _withdrawDividendOfUser(user, true);
    }

    /// @notice Withdraw dividends for a specific user with option to unwrap WETH
    /// @param user The user address to withdraw for
    /// @param unwrapWETH Whether to unwrap WETH to ETH
    /// @return success Whether the withdrawal was successful
    function withdrawDividendsFor(address user, bool unwrapWETH) external returns (bool success) {
        return _withdrawDividendOfUser(user, unwrapWETH);
    }

    /// @notice Get the withdrawable dividend amount for a user
    /// @param user The user address
    /// @return The amount of dividends the user can claim
    function withdrawableDividends(address user) external view returns (uint256) {
        return withdrawableDividendOf(user);
    }

    /// @notice Exclude an address from receiving dividends
    /// @param addr The address to exclude
    function excludeAddress(address addr) external onlyOwner {
        require(!excludedFromDividends[addr], "Dividend: already excluded");
        excludedFromDividends[addr] = true;

        // Reset their share to 0
        if (userInfo[addr].share > 0) {
            _setShare(addr, 0);
        }

        emit FlapDividendAddressExcluded(taxToken, addr);
    }

    /// @notice Remove an address from the exclusion list so it can accumulate
    ///         shares again on future token transfers.
    function unexcludeAddress(address addr) external onlyOwner {
        require(excludedFromDividends[addr], "Dividend: address not excluded");
        delete excludedFromDividends[addr];
        emit FlapDividendAddressUnexcluded(taxToken, addr);
    }

    /// @notice Update the dividend token address
    /// @dev Only callable by the owner (Portal). Any undistributed dividends accrued
    ///      under the previous token should be distributed (or recovered via emergencyWithdraw)
    ///      before calling this function, as the accounting will switch to the new token immediately.
    /// @param newToken The new token to distribute as dividends (must be non-zero)
    function setDividendToken(address newToken) external onlyOwner {
        require(newToken != address(0), "Dividend: zero token address");
        require(magnifiedDividendPerShare == 0, "magnifiedDividendPerShare must be 0");
        address oldToken = dividendToken;
        dividendToken = newToken;
        emit FlapDividendTokenUpdated(taxToken, oldToken, newToken);
    }

    /// @notice Update the minimum share balance threshold
    /// @param newMinimumShareBalance The new minimum share balance
    function setMinimumShareBalance(uint256 newMinimumShareBalance) external onlyOwner {
        minimumShareBalance = newMinimumShareBalance;
    }

    // --- Public View Functions ---

    /// @notice Get the current magnified dividend per share accumulator
    /// @return The current magnifiedDividendPerShare value
    function getMagnifiedDividendPerShare() public view returns (uint256) {
        return magnifiedDividendPerShare;
    }

    /// @notice Get the withdrawable dividend for a user
    /// @param user The user address
    /// @return The withdrawable dividend amount (currently claimable)
    function withdrawableDividendOf(address user) public view returns (uint256) {
        UserInfo storage info = userInfo[user];

        // Part 1: (share * magnifiedDividendPerShare - rewardDebt) / MAGNITUDE
        uint256 accumulatedDividend = info.share * magnifiedDividendPerShare / MAGNITUDE;
        uint256 part1;
        if (accumulatedDividend > info.rewardDebt) {
            part1 = accumulatedDividend - info.rewardDebt;
        } else {
            part1 = 0;
        }

        // Part 2: pendingBalance (settled rewards from previous share changes)
        uint256 part2 = info.pendingBalance;

        // Total currently claimable = part1 + part2
        return part1 + part2;
    }

    /// @notice Get the cumulative dividend for a user (total ever earned)
    /// @param user The user address
    /// @return The cumulative dividend amount (includes withdrawn + withdrawable)
    function accumulativeDividendOf(address user) public view returns (uint256) {
        // Total earned = currently withdrawable + already withdrawn
        return withdrawableDividendOf(user) + withdrawnDividends[user];
    }

    // --- Internal Functions ---

    /// @notice Internal function to set a user's share
    /// @param user The user address
    /// @param newShare The new share amount
    /// @dev When share changes, settle current claimable amount into pendingBalance
    function _setShare(address user, uint256 newShare) internal {
        UserInfo storage info = userInfo[user];
        uint256 currentShare = info.share;

        if (newShare == currentShare) {
            return;
        }

        // Settlement: calculate and store current claimable amount before changing share
        // This simulates claiming and adds to pendingBalance
        if (currentShare > 0) {
            uint256 accumulatedDividend = currentShare * magnifiedDividendPerShare / MAGNITUDE;
            if (accumulatedDividend > info.rewardDebt) {
                uint256 claimable = accumulatedDividend - info.rewardDebt;
                info.pendingBalance = info.pendingBalance + claimable;
                emit FlapDividendPendingBalanceChanged(taxToken, user, info.pendingBalance);
            }
        }

        // Update total shares
        if (newShare > currentShare) {
            totalShares = totalShares + (newShare - currentShare);
        } else {
            totalShares = totalShares - (currentShare - newShare);
        }

        // Update user's share
        info.share = newShare;

        // Update rewardDebt to current accumulated amount for new share
        // This represents the "already claimed" debt for the new share amount
        info.rewardDebt = Math.ceilDiv(newShare * magnifiedDividendPerShare, MAGNITUDE);
        emit FlapDividendRewardDebtChanged(taxToken, user, info.rewardDebt);

        emit FlapDividendShareChanged(taxToken, user, newShare, totalShares);
    }

    /// @notice Internal function to withdraw dividends for a user
    /// @param user The user address
    /// @param shouldUnwrapWETH Whether to unwrap WETH to ETH (true for withdrawDividends, false for distributeDividend)
    /// @return success Whether the withdrawal was successful
    function _withdrawDividendOfUser(address user, bool shouldUnwrapWETH) internal returns (bool success) {
        if (_isExcluded(user)) return false; // excluded addresses cannot claim
        uint256 withdrawableAmount = withdrawableDividendOf(user);

        if (withdrawableAmount == 0) {
            return false;
        }

        UserInfo storage info = userInfo[user];

        // Update state: clear pendingBalance and update rewardDebt
        // Round up to prevent users from accumulating claimable dust after each withdrawal
        info.rewardDebt = Math.ceilDiv(info.share * magnifiedDividendPerShare, MAGNITUDE);
        emit FlapDividendRewardDebtChanged(taxToken, user, info.rewardDebt);
        info.pendingBalance = 0;
        emit FlapDividendPendingBalanceChanged(taxToken, user, 0);

        withdrawnDividends[user] = withdrawnDividends[user] + withdrawableAmount;

        return _sendToken(user, withdrawableAmount, shouldUnwrapWETH);
    }

    /// @dev Transfer `amount` of dividendToken to `user`.
    ///      - If dividendToken == weth and unwrapWETH == true: unwrap WETH and send native ETH (reverts on failure)
    ///      - Otherwise: SafeERC20.safeTransfer (reverts atomically on failure, rolling back state changes)
    function _sendToken(address user, uint256 amount, bool unwrapWETH) internal returns (bool) {
        if (dividendToken == weth && weth != address(0) && unwrapWETH) {
            IWETH(weth).withdraw(amount);
            (bool sent,) = payable(user).call{value: amount}("");
            require(sent, "Dividend: ETH transfer failed");
        } else {
            // SafeERC20.safeTransfer handles all non-standard ERC20 variants:
            //   • No return value (USDT / TetherToken) : returndata.length == 0 → ok
            //   • Returns true   (standard ERC20)      : decoded true → ok
            //   • Returns false  (non-standard)        : require fails → reverts
            //   • Reverts                              : functionCall bubbles revert
            // Reverting on failure is intentional: _withdrawDividendOfUser updates state
            // before calling _sendToken, so a revert here rolls back everything atomically,
            // leaving the user's pending balance intact to retry later.
            IERC20(dividendToken).safeTransfer(user, amount);
        }

        emit FlapDividendDistributed(taxToken, user, amount);
        return true;
    }

    /// @notice Emergency withdraw function to recover tokens in case of emergency
    /// @param token The token address to withdraw (use address(0) for native ETH)
    /// @param amount The amount to withdraw (0 means withdraw all)
    /// @param to The address to send the tokens to
    /// @dev Only callable by owner in emergency situations
    function emergencyWithdraw(address token, uint256 amount, address to) external onlyOwner {
        require(to != address(0), "Dividend: invalid recipient");

        if (token == address(0)) {
            // Withdraw native ETH
            uint256 balance = address(this).balance;
            uint256 withdrawAmount = amount == 0 ? balance : amount;
            require(withdrawAmount <= balance, "Dividend: insufficient ETH balance");

            (bool success,) = payable(to).call{value: withdrawAmount}("");
            require(success, "Dividend: ETH transfer failed");
        } else {
            // Withdraw ERC20 token
            IERC20 tokenContract = IERC20(token);
            uint256 balance = tokenContract.balanceOf(address(this));
            uint256 withdrawAmount = amount == 0 ? balance : amount;
            require(withdrawAmount <= balance, "Dividend: insufficient token balance");

            tokenContract.safeTransfer(to, withdrawAmount);
        }
    }

    // --- Fallback ---
    /// @notice Allow contract to receive native ETH when unwrapping WETH
    receive() external payable {}
}

