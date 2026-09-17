// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface IFeeSplitterRecipient {
    function feeRouter() external view returns (address);
    function currentEpoch() external view returns (uint256);
    function deposit(address token, uint256 amount) external;
}

/// @notice Splits both ERC20 assets collected by the LauncherLocker among the
/// protocol, the buy-burner, and the token's current CTO fee vault.
contract FeeRouter is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    error InvalidBasisPoints();
    error ZeroAddress();
    error InvalidRecipient();
    error NotConfigured();
    error NotLocker();
    error AlreadyInitialized();

    event FeesDistributed(
        address indexed token,
        address indexed ctoRecipient,
        uint256 ctoTokenAmount,
        uint256 ctoPairAmount,
        uint256 protocolTokenAmount,
        uint256 protocolPairAmount,
        uint256 burnerTokenAmount,
        uint256 burnerPairAmount
    );
    event RecipientsUpdated(address indexed protocolRecipient, address indexed burnerRecipient);
    event ProtocolSplitterModeUpdated(bool enabled);
    event SharesUpdated(uint16 protocolShareBps, uint16 burnerShareBps, uint16 ctoShareBps);
    event LockerUpdated(address locker);

    uint16 public constant MAX_BPS = 10_000;
    uint16 public constant DEFAULT_PROTOCOL_SHARE_BPS = 3_333;
    uint16 public constant DEFAULT_BURNER_SHARE_BPS = 3_333;
    uint16 public constant DEFAULT_CTO_SHARE_BPS = 3_334;

    address public protocolRecipient;
    address public burnerRecipient;
    address public locker;
    bool public protocolRecipientIsSplitter;

    /// @notice Share paid to the fixed protocol recipient for each fee asset.
    uint16 public protocolShareBps = DEFAULT_PROTOCOL_SHARE_BPS;
    /// @notice Share paid to the fixed buy-burner recipient for each fee asset.
    uint16 public burnerShareBps = DEFAULT_BURNER_SHARE_BPS;
    /// @notice Share paid to the per-token CTO vault for each fee asset.
    uint16 public ctoShareBps = DEFAULT_CTO_SHARE_BPS;

    constructor() Ownable(msg.sender) {}

    /// @notice Atomically updates the two fixed recipients and the split applied
    /// identically to both ERC20 fee assets. The per-token CTO recipient
    /// continues to be supplied by the LauncherLocker.
    function setFeeConfig(
        address protocolRecipient_,
        address burnerRecipient_,
        uint16 protocolShareBps_,
        uint16 burnerShareBps_,
        uint16 ctoShareBps_
    ) external onlyOwner {
        if (protocolRecipient_ == address(0) || burnerRecipient_ == address(0)) {
            revert ZeroAddress();
        }
        if (
            protocolRecipient_ == burnerRecipient_ || protocolRecipient_ == address(this)
                || burnerRecipient_ == address(this)
        ) revert InvalidRecipient();

        (bool protocolIsSplitter, address protocolSplitterSource) = _splitterBinding(protocolRecipient_);
        if (protocolIsSplitter && protocolSplitterSource != address(this)) revert InvalidRecipient();

        // The factory sends launch-fee WETH directly to this semantic slot.
        // A FeeSplitter intentionally ignores raw transfers, so accepting one
        // here would make every launch fee unallocated and unclaimable.
        (bool burnerIsSplitter,) = _splitterBinding(burnerRecipient_);
        if (burnerIsSplitter) revert InvalidRecipient();
        if (uint256(protocolShareBps_) + burnerShareBps_ + ctoShareBps_ != MAX_BPS) {
            revert InvalidBasisPoints();
        }

        protocolRecipient = protocolRecipient_;
        burnerRecipient = burnerRecipient_;
        protocolShareBps = protocolShareBps_;
        burnerShareBps = burnerShareBps_;
        ctoShareBps = ctoShareBps_;
        protocolRecipientIsSplitter = protocolIsSplitter;

        emit RecipientsUpdated(protocolRecipient_, burnerRecipient_);
        emit ProtocolSplitterModeUpdated(protocolRecipientIsSplitter);
        emit SharesUpdated(protocolShareBps_, burnerShareBps_, ctoShareBps_);
    }

    /// @notice One-time wiring of the locker (set at deployment).
    function setLocker(address locker_) external onlyOwner {
        if (locker_ == address(0)) revert ZeroAddress();
        if (locker != address(0)) revert AlreadyInitialized();
        locker = locker_;
        emit LockerUpdated(locker_);
    }

    /// @notice Distributes fees previously transferred to this contract by the locker.
    /// @dev Only callable by the locker, within the same tx as the collect.
    function distribute(address token, address pairToken, uint256 tokenAmount, uint256 pairAmount, address ctoRecipient)
        external
        nonReentrant
    {
        if (msg.sender != locker) revert NotLocker();
        if (protocolRecipient == address(0) || burnerRecipient == address(0)) revert NotConfigured();
        if (ctoRecipient == address(0)) revert ZeroAddress();

        uint16 fixedRecipientShareBps = uint16(uint256(protocolShareBps) + burnerShareBps);

        uint256 protocolTokenAmount = _mulBps(tokenAmount, protocolShareBps);
        uint256 fixedRecipientTokenAmount = _mulBps(tokenAmount, fixedRecipientShareBps);
        uint256 burnerTokenAmount = fixedRecipientTokenAmount - protocolTokenAmount;
        uint256 ctoTokenAmount = tokenAmount - fixedRecipientTokenAmount;

        uint256 protocolPairAmount = _mulBps(pairAmount, protocolShareBps);
        uint256 fixedRecipientPairAmount = _mulBps(pairAmount, fixedRecipientShareBps);
        uint256 burnerPairAmount = fixedRecipientPairAmount - protocolPairAmount;
        uint256 ctoPairAmount = pairAmount - fixedRecipientPairAmount;

        _payFixedRecipient(token, protocolRecipient, protocolTokenAmount, protocolRecipientIsSplitter);
        _payFixedRecipient(token, burnerRecipient, burnerTokenAmount, false);
        if (ctoTokenAmount != 0) IERC20(token).safeTransfer(ctoRecipient, ctoTokenAmount);

        _payFixedRecipient(pairToken, protocolRecipient, protocolPairAmount, protocolRecipientIsSplitter);
        _payFixedRecipient(pairToken, burnerRecipient, burnerPairAmount, false);
        if (ctoPairAmount != 0) IERC20(pairToken).safeTransfer(ctoRecipient, ctoPairAmount);

        emit FeesDistributed(
            token,
            ctoRecipient,
            ctoTokenAmount,
            ctoPairAmount,
            protocolTokenAmount,
            protocolPairAmount,
            burnerTokenAmount,
            burnerPairAmount
        );
    }

    function _payFixedRecipient(address token, address recipient, uint256 amount, bool isSplitter) private {
        if (amount == 0) return;

        IERC20 asset = IERC20(token);
        if (!isSplitter) {
            asset.safeTransfer(recipient, amount);
            return;
        }

        asset.forceApprove(recipient, amount);
        IFeeSplitterRecipient(recipient).deposit(token, amount);
        asset.forceApprove(recipient, 0);
    }

    function _splitterBinding(address recipient) private view returns (bool, address) {
        if (recipient.code.length == 0) return (false, address(0));
        try IFeeSplitterRecipient(recipient).feeRouter() returns (address source) {
            try IFeeSplitterRecipient(recipient).currentEpoch() returns (uint256 epoch) {
                return (epoch != 0, source);
            } catch {
                return (false, address(0));
            }
        } catch {
            return (false, address(0));
        }
    }

    /// @dev Equivalent to floor(amount * bps / MAX_BPS) without risking
    /// overflow for arbitrary uint256 amounts.
    function _mulBps(uint256 amount, uint16 bps) private pure returns (uint256) {
        return (amount / MAX_BPS) * bps + ((amount % MAX_BPS) * bps) / MAX_BPS;
    }
}
