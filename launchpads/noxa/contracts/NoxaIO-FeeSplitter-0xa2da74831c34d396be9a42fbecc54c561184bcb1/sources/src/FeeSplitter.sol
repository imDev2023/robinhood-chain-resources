// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @notice Owner-configurable, epoch-based splitter for ERC20 fee receipts.
/// @dev The owner (intended to be a multisig) may replace recipients and
/// shares at any time. Each update opens a new epoch for future deposits;
/// prior deposits remain owed under their original immutable epoch.
///
/// The bound FeeRouter calls `deposit` atomically when routing a fee share.
/// Raw ERC20 transfers are intentionally not allocated. Accounting assumes
/// conventional, balance-conserving ERC20 assets such as WETH and LaunchToken.
contract FeeSplitter is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    error EmptyRecipients();
    error LengthMismatch();
    error TooManyRecipients();
    error ZeroAddress();
    error InvalidRecipient();
    error DuplicateRecipient(address recipient);
    error InvalidBasisPoints();
    error InvalidToken();
    error InvalidAmount();
    error UnsupportedToken();
    error NotFeeRouter();
    error NothingToRelease();

    event EpochClosed(uint256 indexed epoch);
    event EpochOpened(uint256 indexed epoch, address indexed roundingRecipient);
    event EpochRecipientConfigured(uint256 indexed epoch, address indexed recipient, uint16 shareBps);
    event DepositRecorded(uint256 indexed epoch, address indexed token, uint256 amount);
    event PaymentReleased(uint256 indexed epoch, address indexed token, address indexed recipient, uint256 amount);

    uint16 public constant MAX_BPS = 10_000;
    uint256 public constant MAX_RECIPIENTS = 32;

    address public immutable feeRouter;
    uint256 public currentEpoch;

    mapping(uint256 epoch => bool closed) public epochClosed;
    mapping(uint256 epoch => address[] recipients) private _epochRecipients;
    mapping(uint256 epoch => mapping(address recipient => uint16 bps)) public epochShareBps;
    mapping(uint256 epoch => address recipient) public epochRoundingRecipient;

    mapping(uint256 epoch => mapping(address token => uint256 amount)) public epochDeposited;
    mapping(uint256 epoch => mapping(address token => mapping(address recipient => uint256 amount))) public released;

    /// @notice Total router-recorded balance still held across every epoch.
    mapping(address token => uint256 amount) public accountedBalance;
    mapping(address token => uint256 amount) public totalRecorded;
    mapping(address token => uint256 amount) public totalReleased;

    constructor(address feeRouter_, address owner_, address[] memory recipients_, uint16[] memory shares_)
        Ownable(owner_)
    {
        if (feeRouter_ == address(0)) revert ZeroAddress();
        feeRouter = feeRouter_;
        _openEpoch(recipients_, shares_);
    }

    /// @notice Changes the recipients and shares for future FeeRouter deposits.
    /// @dev The current epoch is closed but remains independently claimable.
    function setConfig(address[] calldata recipients_, uint16[] calldata shares_)
        external
        onlyOwner
        returns (uint256 epoch)
    {
        epochClosed[currentEpoch] = true;
        emit EpochClosed(currentEpoch);
        epoch = _openEpoch(recipients_, shares_);
    }

    /// @notice Pulls and records an exact fee deposit into the current epoch.
    /// @dev Only the immutable FeeRouter may call this function.
    function deposit(address token, uint256 amount) external nonReentrant {
        if (msg.sender != feeRouter) revert NotFeeRouter();
        if (token == address(0)) revert InvalidToken();
        if (amount == 0) revert InvalidAmount();

        IERC20 asset = IERC20(token);
        uint256 balanceBefore = asset.balanceOf(address(this));
        asset.safeTransferFrom(msg.sender, address(this), amount);
        uint256 balanceAfter = asset.balanceOf(address(this));
        if (balanceAfter < balanceBefore || balanceAfter - balanceBefore != amount) revert UnsupportedToken();

        epochDeposited[currentEpoch][token] += amount;
        accountedBalance[token] += amount;
        totalRecorded[token] += amount;

        emit DepositRecorded(currentEpoch, token, amount);
    }

    /// @notice Releases the caller's accrued share for one epoch and token.
    function release(uint256 epoch, address token) external nonReentrant returns (uint256 amount) {
        return _release(epoch, token, msg.sender);
    }

    /// @notice Releases `recipient`'s accrued share for one epoch and token, paid
    /// to `recipient`. Permissionless: the caller cannot redirect the payment
    /// (it always lands at `recipient`), so a keeper or anyone else may settle a
    /// recipient on its behalf. Reverts NothingToRelease when `recipient` is owed
    /// nothing, so it cannot be used to grief with dust.
    function releaseFor(uint256 epoch, address token, address recipient)
        external
        nonReentrant
        returns (uint256 amount)
    {
        if (recipient == address(0)) revert ZeroAddress();
        return _release(epoch, token, recipient);
    }

    /// @dev Shared release logic; the payout always goes to `recipient`, never to
    /// msg.sender, so `releaseFor` carries no redirect risk.
    function _release(uint256 epoch, address token, address recipient) private returns (uint256 amount) {
        if (token == address(0)) revert InvalidToken();
        amount = releasable(epoch, token, recipient);
        if (amount == 0) revert NothingToRelease();

        released[epoch][token][recipient] += amount;
        accountedBalance[token] -= amount;
        totalReleased[token] += amount;

        IERC20 asset = IERC20(token);
        uint256 balanceBefore = asset.balanceOf(address(this));
        asset.safeTransfer(recipient, amount);
        uint256 balanceAfter = asset.balanceOf(address(this));
        if (balanceAfter > balanceBefore || balanceBefore - balanceAfter != amount) revert UnsupportedToken();

        emit PaymentReleased(epoch, token, recipient, amount);
    }

    /// @notice Amount currently claimable by `recipient` for one epoch/token.
    /// @dev Once an epoch closes, its final integer-division remainder is owed
    /// to the epoch's last recipient so every recorded unit remains claimable.
    function releasable(uint256 epoch, address token, address recipient) public view returns (uint256) {
        uint16 bps = epochShareBps[epoch][recipient];
        if (bps == 0) return 0;

        uint256 entitlement = _mulBps(epochDeposited[epoch][token], bps);
        if (epochClosed[epoch] && recipient == epochRoundingRecipient[epoch]) {
            entitlement += roundingRemainder(epoch, token);
        }

        uint256 alreadyReleased = released[epoch][token][recipient];
        return entitlement > alreadyReleased ? entitlement - alreadyReleased : 0;
    }

    /// @notice Final rounding remainder for a closed epoch and token.
    function roundingRemainder(uint256 epoch, address token) public view returns (uint256 remainder) {
        if (!epochClosed[epoch]) return 0;

        uint256 deposited = epochDeposited[epoch][token];
        address[] storage recipients = _epochRecipients[epoch];
        uint256 allocated;
        uint256 count = recipients.length;
        for (uint256 i; i < count; ++i) {
            allocated += _mulBps(deposited, epochShareBps[epoch][recipients[i]]);
        }
        remainder = deposited - allocated;
    }

    /// @notice Unrecorded tokens sent directly rather than through FeeRouter.
    /// @dev Such balances do not affect any recipient's entitlement.
    function unallocatedBalance(address token) external view returns (uint256) {
        if (token == address(0)) revert InvalidToken();
        uint256 balance = IERC20(token).balanceOf(address(this));
        uint256 accounted = accountedBalance[token];
        return balance > accounted ? balance - accounted : 0;
    }

    function currentShareBps(address recipient) external view returns (uint16) {
        return epochShareBps[currentEpoch][recipient];
    }

    function recipientCount(uint256 epoch) external view returns (uint256) {
        return _epochRecipients[epoch].length;
    }

    function recipientAt(uint256 epoch, uint256 index) external view returns (address recipient, uint16 bps) {
        recipient = _epochRecipients[epoch][index];
        bps = epochShareBps[epoch][recipient];
    }

    function getRecipients(uint256 epoch) external view returns (address[] memory recipients, uint16[] memory shares) {
        recipients = _epochRecipients[epoch];
        uint256 count = recipients.length;
        shares = new uint16[](count);
        for (uint256 i; i < count; ++i) {
            shares[i] = epochShareBps[epoch][recipients[i]];
        }
    }

    function _openEpoch(address[] memory recipients_, uint16[] memory shares_) private returns (uint256 epoch) {
        uint256 count = recipients_.length;
        if (count == 0) revert EmptyRecipients();
        if (count != shares_.length) revert LengthMismatch();
        if (count > MAX_RECIPIENTS) revert TooManyRecipients();

        epoch = ++currentEpoch;
        uint256 totalBps;
        for (uint256 i; i < count; ++i) {
            address recipient = recipients_[i];
            uint16 bps = shares_[i];
            if (recipient == address(0)) revert ZeroAddress();
            if (recipient == address(this) || recipient == feeRouter || bps == 0) revert InvalidRecipient();
            if (epochShareBps[epoch][recipient] != 0) revert DuplicateRecipient(recipient);

            totalBps += bps;
            if (totalBps > MAX_BPS) revert InvalidBasisPoints();

            _epochRecipients[epoch].push(recipient);
            epochShareBps[epoch][recipient] = bps;
            emit EpochRecipientConfigured(epoch, recipient, bps);
        }
        if (totalBps != MAX_BPS) revert InvalidBasisPoints();

        epochRoundingRecipient[epoch] = recipients_[count - 1];
        emit EpochOpened(epoch, recipients_[count - 1]);
    }

    /// @dev Equivalent to floor(amount * bps / MAX_BPS) without risking
    /// overflow for arbitrary uint256 amounts.
    function _mulBps(uint256 amount, uint16 bps) private pure returns (uint256) {
        return (amount / MAX_BPS) * bps + ((amount % MAX_BPS) * bps) / MAX_BPS;
    }
}
