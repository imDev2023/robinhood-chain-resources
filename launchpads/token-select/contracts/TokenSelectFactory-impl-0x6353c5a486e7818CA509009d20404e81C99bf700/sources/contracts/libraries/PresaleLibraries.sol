// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title AllocationValidator
 * @dev Lightweight library for validating token allocations only
 */
library AllocationValidator {
    
    // Constants for allocation limits
    uint256 public constant TOTAL_SUPPLY = 1_000_000_000 ether; // 1 billion tokens
    uint256 public constant MAX_MARKETING_FOUNDATION = 300_000_000 ether;    // 300m
    uint256 public constant MAX_TEAM_CONTRIBUTORS = 300_000_000 ether;  // 300m
    uint256 public constant MAX_COMMUNITY_REWARDS = 300_000_000 ether;  // 300m
    uint256 public constant MAX_COMBINED_ALLOCATIONS = 800_000_000 ether; // 800m combined

    // Constant for vesting schedule limits
    uint256 public constant MIN_VESTING_DURATION = 24 hours;
    uint256 public constant MIN_VESTING_DELAY = 24 hours;
    uint256 public constant MAX_VESTING_DURATION = 36500 days;
    uint256 public constant MAX_VESTING_DELAY = 36500 days;

    // Errors
    error CombinedAllocationsExceedLimit();
    error AllocationExceedsLimit();
    error VestingScheduleOverflow();
    error InvalidVestingSchedule();

    /**
     * @dev Validate allocation amounts meet all requirements
     */
    function validateAllocations(
        uint256 teamAllocation,
        uint256 marketingAllocation,
        uint256 communityRewardsAllocation
    ) external pure {
        // Check maximum limits
        if (marketingAllocation > MAX_MARKETING_FOUNDATION) revert AllocationExceedsLimit();
        if (teamAllocation > MAX_TEAM_CONTRIBUTORS) revert AllocationExceedsLimit();
        if (communityRewardsAllocation > MAX_COMMUNITY_REWARDS) revert AllocationExceedsLimit();
        
        // Check that sum doesn't exceed total supply
        uint256 totalSpecified = teamAllocation + marketingAllocation + communityRewardsAllocation;

        if (totalSpecified > MAX_COMBINED_ALLOCATIONS) revert CombinedAllocationsExceedLimit();
    }

    /**
     * @dev Validate vesting schedules for allocations
     * @param teamAllocation Team token allocation
     * @param teamStartDelay Team vesting start timestamp
     * @param teamDuration Team vesting end timestamp
     * @param marketingAllocation Marketing token allocation
     * @param marketingStartDelay Marketing vesting start timestamp
     * @param marketingDuration Marketing vesting end timestamp
     * @param communityAllocation Community token allocation
     * @param communityStartDelay Community vesting start timestamp
     * @param communityDuration Community vesting end timestamp
     */
    function validateVestingSchedules(
        uint256 teamAllocation,
        uint40 teamStartDelay,
        uint40 teamDuration,
        uint256 marketingAllocation,
        uint40 marketingStartDelay,
        uint40 marketingDuration,
        uint256 communityAllocation,
        uint40 communityStartDelay,
        uint40 communityDuration
    ) external pure {
        // Validate team timestamps
        if (teamAllocation > 0) {
            _validateSchedule(teamStartDelay, teamDuration);
        }

        // Validate marketing timestamps
        if (marketingAllocation > 0) {
            _validateSchedule(marketingStartDelay, marketingDuration);
        }

        // Validate community timestamps
        if (communityAllocation > 0) {
            _validateSchedule(communityStartDelay, communityDuration);
        }
    }

    /**
     * @dev Internal function to validate vesting schedule for a pair
     * @param delay Vesting start delay
     * @param duration Vesting duration
     */
    function _validateSchedule(uint40 delay, uint40 duration) internal pure {
        // Duration must be atleast MIN_VESTING_DURATION
        // Duration must be below MAX_VESTING_DURATION to prevent overflow
        if (duration < MIN_VESTING_DURATION || duration > MAX_VESTING_DURATION) revert InvalidVestingSchedule();

        // Delay must be atleast MIN_VESTING_DELAY 
        // Delay must be below MAX_VESTING_DELAY to prevent overflow
        if (delay < MIN_VESTING_DELAY || delay > MAX_VESTING_DELAY) revert InvalidVestingSchedule();
    }
    

    /**
     * @dev Check if allocations are valid (returns boolean instead of reverting)
     */
    function areAllocationsValid(
        uint256 teamAllocation,
        uint256 marketingAllocation,
        uint256 communityRewardsAllocation
    ) external pure returns (bool) {
        if (marketingAllocation > MAX_MARKETING_FOUNDATION) return false;
        if (teamAllocation > MAX_TEAM_CONTRIBUTORS) return false;
        if (communityRewardsAllocation > MAX_COMMUNITY_REWARDS) return false;
        
        uint256 totalSpecified = teamAllocation + marketingAllocation + communityRewardsAllocation;
        if (totalSpecified > MAX_COMBINED_ALLOCATIONS) return false;
        
        return true;
    }

    /**
     * @dev Check if vesting schedules are valid for given allocations (returns boolean)
     * @return bool True if all schedules are valid for their respective allocations
     */
    function areVestingSchedulesValid(
        uint256 teamAllocation,
        uint40 teamStartDelay,
        uint40 teamDuration,
        uint256 marketingAllocation,
        uint40 marketingStartDelay,
        uint40 marketingDuration,
        uint256 communityAllocation,
        uint40 communityStartDelay,
        uint40 communityDuration
    ) external pure returns (bool) {
        // Team validation
        if (teamAllocation > 0) {
            if (!_isScheduleValid(teamStartDelay, teamDuration)) return false;
        }

        // Marketing validation
        if (marketingAllocation > 0) {
            if (!_isScheduleValid(marketingStartDelay, marketingDuration)) return false;
        }

        // Community validation
        if (communityAllocation > 0) {
            if (!_isScheduleValid(communityStartDelay, communityDuration)) return false;
        }

        return true;
    }

    /**
    * @dev Check if schedule is valid (returns boolean)
    */
    function _isScheduleValid(uint40 delay, uint40 duration) internal pure returns (bool) {
        // Duration must be atleast MIN_VESTING_DURATION
        // Duration must be below MAX_VESTING_DURATION to prevent overflow
        if (duration < MIN_VESTING_DURATION || duration > MAX_VESTING_DURATION) return false;

        // Delay must be atleast MIN_VESTING_DELAY 
        // Delay must be below MAX_VESTING_DELAY to prevent overflow
        if (delay < MIN_VESTING_DELAY || delay > MAX_VESTING_DELAY) return false;
    
        return true;
    }

    /**
     * @dev Get allocation limits
     */
    function getAllocationLimits() external pure returns (
        uint256 maxMarketing,
        uint256 maxTeam,
        uint256 maxCommunity,
        uint256 maxCombined
    ) {
        return (
            MAX_MARKETING_FOUNDATION,
            MAX_TEAM_CONTRIBUTORS,
            MAX_COMMUNITY_REWARDS,
            MAX_COMBINED_ALLOCATIONS
        );
    }
}