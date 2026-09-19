// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title VestingVault
/// @notice Shared, immutable step-schedule (milestone) vesting for launch-token insider allocations. At genesis
///         the factory mints an insider's locked tokens to this vault (not to the insider) and registers a
///         per-insider schedule of unlock points; the insider pulls the vested portion over time via `claim`.
///         Each point is `(timestamp, cumulativeAmount)`: at/after `timestamp`, that cumulative total is
///         unlocked. Between points nothing new unlocks (a staircase), so any release shape is expressible.
///         The vault holds the tokens, so the launch token itself stays fully immutable and policy-free.
/// @dev    Deliberately admin-less: once `register` records a schedule it can never be changed, and the ONLY way
///         tokens leave the vault is the beneficiary's own scheduled `claim`. There is no owner, no withdraw, no
///         reschedule, and no beneficiary reassignment, so the launchpad invariant "no one can touch a live
///         launch's funds" holds for vested allocations too. Pull-based and balance-safe like the FeeEscrow:
///         per (token, beneficiary) `claimed <= vested <= total`, and the sum of a token's registered totals
///         equals what the factory minted here, so the vault is always solvent.
contract VestingVault is ReentrancyGuard {
    using SafeERC20 for IERC20;

    /// @notice A schedule's first unlock must be at least this far out, so nothing unlocks in the first day; must match LaunchpadFactoryCore.MIN_VESTING_DURATION.
    uint64 public constant MIN_VESTING_DURATION = 1 days;
    /// @notice Cap on unlock points per (token, beneficiary), bounding genesis gas + calldata; must match LaunchpadFactoryCore.MAX_VEST_STEPS.
    uint256 public constant MAX_UNLOCK_POINTS = 24;

    /// @notice The launchpad factory: the only address allowed to register schedules. Not `immutable` so the
    ///         runtime bytecode stays constant and the factory can pin this vault by codehash; still write-once.
    address public factory;

    /// @notice One unlock step: at/after `timestamp`, `cumulativeAmount` total is unlocked (cumulative, not a delta).
    struct UnlockPoint {
        uint64 timestamp;
        uint128 cumulativeAmount;
    }

    /// @notice A beneficiary's vesting for one token. `total` is the final cumulative amount (the last point);
    ///         `claimed` is what has been withdrawn; `points` is strictly time-ascending with strictly increasing
    ///         cumulative amounts, ending exactly at `total`.
    struct Schedule {
        uint128 total;
        uint128 claimed;
        UnlockPoint[] points;
    }

    mapping(address => mapping(address => Schedule)) internal schedules; // token => beneficiary => schedule

    error NotFactory();
    error AlreadyRegistered();
    error InvalidSchedule();
    error NothingToClaim();
    error ZeroAddress();

    event Registered(address indexed token, address indexed beneficiary, uint256 total, uint256 points);
    event Claimed(address indexed token, address indexed beneficiary, uint256 amount);

    constructor(address _factory) {
        if (_factory == address(0)) revert ZeroAddress();
        factory = _factory;
    }

    /// @notice Record a beneficiary's step schedule for `token`. Factory-only and set-once per (token, beneficiary);
    ///         the matching tokens must already have been minted here in the same transaction, so the vault's
    ///         balance always covers the sum of registered totals.
    /// @dev    `points` must be non-empty and at most MAX_UNLOCK_POINTS, with strictly increasing timestamps and
    ///         strictly increasing cumulative amounts; the first point at least MIN_VESTING_DURATION in the
    ///         future; and the last cumulative amount equal to `total`.
    function register(address token, address beneficiary, uint256 total, UnlockPoint[] calldata points) external {
        if (msg.sender != factory) revert NotFactory();
        if (token == address(0) || beneficiary == address(0)) revert ZeroAddress();
        if (schedules[token][beneficiary].total != 0) revert AlreadyRegistered();

        uint256 n = points.length;
        // forge-lint: disable-next-line(block-timestamp) genesis-time sanity check; a multi-day vest is not validator-gameable
        uint256 nowTs = block.timestamp;
        if (
            n == 0 || n > MAX_UNLOCK_POINTS || total == 0 || total > type(uint128).max
                || points[0].timestamp < nowTs + MIN_VESTING_DURATION || points[n - 1].cumulativeAmount != total
        ) revert InvalidSchedule();

        Schedule storage s = schedules[token][beneficiary];
        // forge-lint: disable-next-line(unsafe-typecast) total <= type(uint128).max checked above
        s.total = uint128(total);
        uint64 prevTs;
        uint128 prevCum;
        for (uint256 i = 0; i < n; i++) {
            UnlockPoint calldata pt = points[i];
            // strictly increasing time (after the first) and strictly increasing cumulative, never above total
            if ((i != 0 && pt.timestamp <= prevTs) || pt.cumulativeAmount <= prevCum || pt.cumulativeAmount > total) {
                revert InvalidSchedule();
            }
            s.points.push(pt);
            prevTs = pt.timestamp;
            prevCum = pt.cumulativeAmount;
        }
        emit Registered(token, beneficiary, total, n);
    }

    /// @notice Release the portion vested so far for (token, beneficiary). Permissionless to trigger, but funds
    ///         always go to the beneficiary. CEI: `claimed` is advanced before the transfer.
    function claim(address token, address beneficiary) external nonReentrant returns (uint256 amount) {
        Schedule storage s = schedules[token][beneficiary];
        amount = _vested(s) - s.claimed;
        if (amount == 0) revert NothingToClaim();
        // forge-lint: disable-next-line(unsafe-typecast) amount <= total - claimed <= total <= type(uint128).max
        s.claimed += uint128(amount);
        IERC20(token).safeTransfer(beneficiary, amount);
        emit Claimed(token, beneficiary, amount);
    }

    /// @notice Amount currently claimable by (token, beneficiary).
    function claimable(address token, address beneficiary) external view returns (uint256) {
        Schedule storage s = schedules[token][beneficiary];
        return _vested(s) - s.claimed;
    }

    function getSchedule(address token, address beneficiary) external view returns (Schedule memory) {
        return schedules[token][beneficiary];
    }

    /// @dev Staircase: the cumulative amount of the latest point whose timestamp has passed (zero before the
    ///      first point). Unregistered schedules have no points and vest nothing.
    function _vested(Schedule storage s) internal view returns (uint256 vested) {
        uint256 n = s.points.length;
        if (n == 0) return 0;
        // forge-lint: disable-next-line(block-timestamp) a validator cannot meaningfully game a multi-day vest
        uint256 t = block.timestamp;
        for (uint256 i = 0; i < n; i++) {
            if (t >= s.points[i].timestamp) {
                vested = s.points[i].cumulativeAmount;
            } else {
                break;
            }
        }
    }
}
