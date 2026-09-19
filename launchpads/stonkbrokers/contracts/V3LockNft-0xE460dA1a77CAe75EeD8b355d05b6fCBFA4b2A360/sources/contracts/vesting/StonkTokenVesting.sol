// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

interface IStonkLauncherFactoryView {
    function launchedTokens(address token) external view returns (bool);
}

/// @notice Monthly vesting for STONK and launcher-issued tokens.
/// Protocol takes a 0.25% fee from every monthly claim.
contract StonkTokenVesting is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    uint256 public constant BPS = 10_000;
    uint256 public constant CLAIM_FEE_BPS = 25; // 0.25%

    /// @dev Real-world "monthly" vesting is 30 days per period. `periodDuration` is
    /// exposed per-schedule (rather than hardcoded) so deployments can verify the
    /// unlock math end-to-end on a live chain using a short period, without being
    /// able to fast-forward that chain's clock.
    uint32 public constant DEFAULT_PERIOD_DURATION = 30 days;
    uint32 public constant MIN_PERIOD_DURATION = 60 seconds;

    struct VestingSchedule {
        address token;
        address beneficiary;
        uint256 totalAmount;
        uint256 claimedAmount;
        uint64 startTimestamp;
        uint16 monthlyPeriods;
        uint32 periodDuration;
        bool cancelled;
    }

    address public protocolFeeRecipient;
    address public immutable stonkToken;
    IStonkLauncherFactoryView public launcherFactory;

    uint256 public nextScheduleId = 1;
    mapping(uint256 => VestingSchedule) public schedules;

    error RecipientZero();
    error BeneficiaryZero();
    error InvalidPeriods();
    error InvalidPeriodDuration();
    error InvalidStart();
    error InvalidAmount();
    error NotBeneficiary();
    error NotEligibleToken();
    error NothingClaimable();
    error ScheduleMissing();
    error ScheduleIsCancelled();

    event ProtocolFeeRecipientUpdated(address indexed oldRecipient, address indexed newRecipient);
    event LauncherFactoryUpdated(address indexed oldFactory, address indexed newFactory);
    event ScheduleCreated(
        uint256 indexed scheduleId,
        address indexed token,
        address indexed beneficiary,
        uint256 totalAmount,
        uint64 startTimestamp,
        uint16 monthlyPeriods,
        uint32 periodDuration
    );
    event TokensClaimed(
        uint256 indexed scheduleId,
        address indexed beneficiary,
        uint256 grossAmount,
        uint256 netAmount,
        uint256 protocolFeeAmount
    );
    event ScheduleCanceled(uint256 indexed scheduleId);

    constructor(address initialOwner, address _stonkToken, address _launcherFactory, address _protocolFeeRecipient)
        Ownable(initialOwner)
    {
        require(_stonkToken != address(0), "stonk=0");
        require(_launcherFactory != address(0), "factory=0");
        if (_protocolFeeRecipient == address(0)) revert RecipientZero();
        stonkToken = _stonkToken;
        launcherFactory = IStonkLauncherFactoryView(_launcherFactory);
        protocolFeeRecipient = _protocolFeeRecipient;
    }

    function setProtocolFeeRecipient(address newRecipient) external onlyOwner {
        if (newRecipient == address(0)) revert RecipientZero();
        emit ProtocolFeeRecipientUpdated(protocolFeeRecipient, newRecipient);
        protocolFeeRecipient = newRecipient;
    }

    function setLauncherFactory(address newFactory) external onlyOwner {
        require(newFactory != address(0), "factory=0");
        emit LauncherFactoryUpdated(address(launcherFactory), newFactory);
        launcherFactory = IStonkLauncherFactoryView(newFactory);
    }

    /// @param periodDuration Length of one vesting period in seconds. Pass 0 to use the
    /// standard 30-day month; a shorter value (min 60s) is only intended for verifying
    /// the unlock schedule quickly on a testnet.
    function createSchedule(
        address token,
        address beneficiary,
        uint256 totalAmount,
        uint64 startTimestamp,
        uint16 monthlyPeriods,
        uint32 periodDuration
    ) external nonReentrant returns (uint256 scheduleId) {
        if (beneficiary == address(0)) revert BeneficiaryZero();
        if (monthlyPeriods == 0) revert InvalidPeriods();
        if (startTimestamp < block.timestamp) revert InvalidStart();
        if (totalAmount == 0) revert InvalidAmount();
        if (!_isEligibleToken(token)) revert NotEligibleToken();

        uint32 resolvedPeriodDuration = periodDuration == 0 ? DEFAULT_PERIOD_DURATION : periodDuration;
        if (resolvedPeriodDuration < MIN_PERIOD_DURATION) revert InvalidPeriodDuration();

        scheduleId = nextScheduleId++;
        schedules[scheduleId] = VestingSchedule({
            token: token,
            beneficiary: beneficiary,
            totalAmount: totalAmount,
            claimedAmount: 0,
            startTimestamp: startTimestamp,
            monthlyPeriods: monthlyPeriods,
            periodDuration: resolvedPeriodDuration,
            cancelled: false
        });

        IERC20(token).safeTransferFrom(msg.sender, address(this), totalAmount);
        emit ScheduleCreated(scheduleId, token, beneficiary, totalAmount, startTimestamp, monthlyPeriods, resolvedPeriodDuration);
    }

    function claim(uint256 scheduleId) external nonReentrant returns (uint256 netAmount, uint256 protocolFeeAmount) {
        VestingSchedule storage s = schedules[scheduleId];
        if (s.token == address(0)) revert ScheduleMissing();
        if (s.cancelled) revert ScheduleIsCancelled();
        if (s.beneficiary != msg.sender) revert NotBeneficiary();

        uint256 grossClaimable = claimableAmount(scheduleId);
        if (grossClaimable == 0) revert NothingClaimable();

        s.claimedAmount += grossClaimable;
        protocolFeeAmount = (grossClaimable * CLAIM_FEE_BPS) / BPS;
        netAmount = grossClaimable - protocolFeeAmount;

        if (protocolFeeAmount > 0) IERC20(s.token).safeTransfer(protocolFeeRecipient, protocolFeeAmount);
        IERC20(s.token).safeTransfer(s.beneficiary, netAmount);
        emit TokensClaimed(scheduleId, s.beneficiary, grossClaimable, netAmount, protocolFeeAmount);
    }

    /// @notice Cancel a schedule. Any amount that has already vested (but not yet
    /// been claimed) is paid to the beneficiary net of the standard 0.25% fee before
    /// the truly-unvested remainder is returned to the contract owner. This prevents
    /// the owner from being able to reclaim tokens the beneficiary was already
    /// entitled to under the schedule.
    function cancelSchedule(uint256 scheduleId) external onlyOwner nonReentrant {
        VestingSchedule storage s = schedules[scheduleId];
        if (s.token == address(0)) revert ScheduleMissing();
        if (s.cancelled) revert ScheduleIsCancelled();

        uint256 vestedButUnclaimed = claimableAmount(scheduleId);
        s.cancelled = true;

        if (vestedButUnclaimed > 0) {
            s.claimedAmount += vestedButUnclaimed;
            uint256 protocolFee = (vestedButUnclaimed * CLAIM_FEE_BPS) / BPS;
            uint256 netToBeneficiary = vestedButUnclaimed - protocolFee;
            if (protocolFee > 0) IERC20(s.token).safeTransfer(protocolFeeRecipient, protocolFee);
            if (netToBeneficiary > 0) IERC20(s.token).safeTransfer(s.beneficiary, netToBeneficiary);
            emit TokensClaimed(scheduleId, s.beneficiary, vestedButUnclaimed, netToBeneficiary, protocolFee);
        }

        uint256 remaining = s.totalAmount - s.claimedAmount;
        if (remaining > 0) {
            IERC20(s.token).safeTransfer(owner(), remaining);
        }
        emit ScheduleCanceled(scheduleId);
    }

    function claimableAmount(uint256 scheduleId) public view returns (uint256) {
        VestingSchedule memory s = schedules[scheduleId];
        if (s.token == address(0) || s.cancelled || block.timestamp < s.startTimestamp) return 0;

        uint256 elapsedMonths = ((block.timestamp - s.startTimestamp) / s.periodDuration) + 1;
        if (elapsedMonths > s.monthlyPeriods) elapsedMonths = s.monthlyPeriods;

        uint256 vested = (s.totalAmount * elapsedMonths) / s.monthlyPeriods;
        if (vested <= s.claimedAmount) return 0;
        return vested - s.claimedAmount;
    }

    function _isEligibleToken(address token) internal view returns (bool) {
        if (token == stonkToken) return true;
        return launcherFactory.launchedTokens(token);
    }
}

