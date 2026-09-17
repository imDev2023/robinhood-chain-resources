// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @notice Immutable fee custody for one launched token.
/// @dev The LauncherLocker should register this contract as the position's feeWallet. The existing
///      FeeRouter sends the configured creator/community share of both ERC20 fee assets here.
///      There is deliberately no arbitrary-call or fee-redirect function: only the CTO election module
///      can release the known fee assets, so the original creator cannot bypass a later election.
contract CTOFeeVault is ReentrancyGuard {
    using SafeERC20 for IERC20;

    error NotCTOFund();
    error ZeroAddress();
    error DuplicateAsset();
    error NativeTransferFailed();
    error AlreadyInitialized();
    error NotFactory();

    event Initialized(address indexed token, address indexed pairToken, address indexed ctoFund);
    event FeesClaimed(address indexed recipient, uint256 tokenAmount, uint256 pairAmount, uint256 nativeAmount);

    address public immutable factory;
    address public token;
    address public pairToken;
    address public ctoFund;
    bool public initialized;

    /// @dev Locks the implementation contract. EIP-1167 clones start with empty storage and initialize once.
    constructor() {
        factory = msg.sender;
        initialized = true;
    }

    function initialize(address token_, address pairToken_, address ctoFund_) external {
        if (msg.sender != factory) revert NotFactory();
        if (initialized) revert AlreadyInitialized();
        if (token_ == address(0) || pairToken_ == address(0) || ctoFund_ == address(0)) revert ZeroAddress();
        if (token_ == pairToken_) revert DuplicateAsset();
        initialized = true;
        token = token_;
        pairToken = pairToken_;
        ctoFund = ctoFund_;
        emit Initialized(token_, pairToken_, ctoFund_);
    }

    /// @notice Retained for accidental native transfers and legacy recovery through the normal CTO claim path.
    /// Current FeeRouter distributions keep WETH wrapped.
    receive() external payable {}

    /// @notice Releases every accrued known fee asset to a recipient selected by the current CTO leader.
    /// @dev Authorization and the post-election delay are enforced by NoxaCTOFund before this call. A leader
    ///      can use the fund's `claimTo` entry point to choose a payable recipient when the leader itself is a
    ///      non-payable contract. Unsupported tokens sent here are intentionally not recoverable by an admin.
    function claimTo(address recipient)
        external
        nonReentrant
        returns (uint256 tokenAmount, uint256 pairAmount, uint256 nativeAmount)
    {
        if (msg.sender != ctoFund) revert NotCTOFund();
        if (recipient == address(0)) revert ZeroAddress();

        tokenAmount = IERC20(token).balanceOf(address(this));
        pairAmount = IERC20(pairToken).balanceOf(address(this));
        nativeAmount = address(this).balance;

        if (tokenAmount != 0) IERC20(token).safeTransfer(recipient, tokenAmount);
        if (pairAmount != 0) IERC20(pairToken).safeTransfer(recipient, pairAmount);
        if (nativeAmount != 0) {
            (bool ok,) = recipient.call{value: nativeAmount}("");
            if (!ok) revert NativeTransferFailed();
        }

        emit FeesClaimed(recipient, tokenAmount, pairAmount, nativeAmount);
    }
}
