// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @notice Stake a meme coin (stakeToken) to earn LP-fee yield in token0+token1.
/// Uses a simple accumulator model; each deposit resets the user's lock to >= 2 weeks.
contract StonkYieldStakingVault is ReentrancyGuard {
    using SafeERC20 for IERC20;
    uint256 public constant MIN_LOCK = 14 days;

    IERC20 public immutable stakeToken;
    IERC20 public immutable rewardToken0;
    IERC20 public immutable rewardToken1;

    address public feeSplitter;
    address public immutable deployer;

    uint256 public totalStaked;
    uint256 public acc0PerShare; // 1e18
    uint256 public acc1PerShare; // 1e18
    uint256 public undistributed0;
    uint256 public undistributed1;

    struct User {
        uint256 staked;
        uint256 unlockTime;
        uint256 debt0;
        uint256 debt1;
    }
    mapping(address => User) public users;

    event Staked(address indexed user, uint256 amount, uint256 unlockTime);
    event Unstaked(address indexed user, uint256 amount);
    event Claimed(address indexed user, uint256 amount0, uint256 amount1);
    event RewardsNotified(uint256 amount0, uint256 amount1);
    event FeeSplitterSet(address indexed feeSplitter);

    error NotFeeSplitter();
    error NotDeployer();
    error FeeSplitterAlreadySet();
    error Locked();
    error AmountZero();

    constructor(address _stakeToken, address _token0, address _token1) {
        require(_stakeToken != address(0), "stake=0");
        require(_token0 != address(0) && _token1 != address(0), "reward=0");
        stakeToken = IERC20(_stakeToken);
        rewardToken0 = IERC20(_token0);
        rewardToken1 = IERC20(_token1);
        deployer = msg.sender;
    }

    function setFeeSplitter(address splitter) external {
        if (msg.sender != deployer) revert NotDeployer();
        if (feeSplitter != address(0)) revert FeeSplitterAlreadySet();
        require(splitter != address(0), "splitter=0");
        feeSplitter = splitter;
        emit FeeSplitterSet(splitter);
    }

    function pendingRewards(address user) public view returns (uint256 pending0, uint256 pending1) {
        User memory u = users[user];
        if (u.staked == 0) return (0, 0);
        pending0 = ((u.staked * acc0PerShare) / 1e18) - u.debt0;
        pending1 = ((u.staked * acc1PerShare) / 1e18) - u.debt1;
    }

    function stake(uint256 amount) external nonReentrant {
        if (amount == 0) revert AmountZero();
        _syncUndistributed();
        _claim(msg.sender);

        User storage u = users[msg.sender];
        stakeToken.safeTransferFrom(msg.sender, address(this), amount);
        u.staked += amount;
        totalStaked += amount;

        uint256 newUnlock = block.timestamp + MIN_LOCK;
        if (newUnlock > u.unlockTime) u.unlockTime = newUnlock;

        // IMPORTANT: Set debt *before* syncing undistributed. If rewards arrived before any stakers existed,
        // we want the first staker to be able to claim them (i.e. pending > 0 after this stake).
        u.debt0 = (u.staked * acc0PerShare) / 1e18;
        u.debt1 = (u.staked * acc1PerShare) / 1e18;

        // If rewards arrived before the first staker, distribute them now.
        _syncUndistributed();
        emit Staked(msg.sender, amount, u.unlockTime);
    }

    function unstake(uint256 amount) external nonReentrant {
        if (amount == 0) revert AmountZero();
        User storage u = users[msg.sender];
        if (block.timestamp < u.unlockTime) revert Locked();
        require(u.staked >= amount, "insufficient staked");

        _syncUndistributed();
        _claim(msg.sender);
        u.staked -= amount;
        totalStaked -= amount;
        u.debt0 = (u.staked * acc0PerShare) / 1e18;
        u.debt1 = (u.staked * acc1PerShare) / 1e18;

        stakeToken.safeTransfer(msg.sender, amount);
        emit Unstaked(msg.sender, amount);
    }

    function claim() external nonReentrant {
        _syncUndistributed();
        _claim(msg.sender);
        User storage u = users[msg.sender];
        u.debt0 = (u.staked * acc0PerShare) / 1e18;
        u.debt1 = (u.staked * acc1PerShare) / 1e18;
    }

    /// @notice Called by fee splitter after transferring reward tokens in.
    function notifyRewards(uint256 amount0, uint256 amount1) external nonReentrant {
        if (msg.sender != feeSplitter) revert NotFeeSplitter();
        if (totalStaked == 0) {
            // No stakers yet; track and distribute once someone stakes.
            undistributed0 += amount0;
            undistributed1 += amount1;
            emit RewardsNotified(amount0, amount1);
            return;
        }
        _syncUndistributed();
        if (amount0 > 0) acc0PerShare += (amount0 * 1e18) / totalStaked;
        if (amount1 > 0) acc1PerShare += (amount1 * 1e18) / totalStaked;
        emit RewardsNotified(amount0, amount1);
    }

    function _syncUndistributed() internal {
        if (totalStaked == 0) return;
        uint256 u0 = undistributed0;
        uint256 u1 = undistributed1;
        if (u0 > 0) {
            undistributed0 = 0;
            acc0PerShare += (u0 * 1e18) / totalStaked;
        }
        if (u1 > 0) {
            undistributed1 = 0;
            acc1PerShare += (u1 * 1e18) / totalStaked;
        }
    }

    function _claim(address user) internal {
        (uint256 p0, uint256 p1) = pendingRewards(user);
        if (p0 == 0 && p1 == 0) return;

        if (p0 > 0) rewardToken0.safeTransfer(user, p0);
        if (p1 > 0) rewardToken1.safeTransfer(user, p1);
        emit Claimed(user, p0, p1);
    }
}

