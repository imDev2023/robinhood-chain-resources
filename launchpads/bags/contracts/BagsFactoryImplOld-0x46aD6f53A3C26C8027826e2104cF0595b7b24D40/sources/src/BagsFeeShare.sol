// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

// OpenZeppelin
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

// Uniswap v4 Core
import {PoolId} from "@uniswap/v4-core/src/types/PoolId.sol";

// Local interfaces
import {IBagsFeeShare} from "src/interfaces/IBagsFeeShare.sol";
import {IWETH} from "src/interfaces/IWETH.sol";

/// @title IHookSweep
/// @notice Minimal interface for the shared hook's per-pool sweep
/// @author Bags
interface IHookSweep {
    /// @notice Sweep a pool's accrued fees from the hook into the fee share contract
    /// @param poolId Pool identifier
    function sweep(PoolId poolId) external;
}

/// @title BagsFeeShare
/// @notice Per-token pull-payment ledger for the creator-side 50% of fees, denominated in WETH.
///         Supports both direct deployment (`new`) and EIP-1167 minimal proxy clones.
/// @author Bags
/// - Optional partner receives partnerBps (base 10_000) of every notified amount
/// - The remainder goes to claimers pro-rata by BPS (last claimer absorbs rounding dust)
/// - Partner immutable; claimers updatable by admin (forward-only), max 100, unique, non-overlapping with partner
contract BagsFeeShare is Ownable, ReentrancyGuard, IBagsFeeShare {
    using SafeERC20 for IERC20;
    using Math for uint256;

    /// @notice Basis points denominator (10_000 = 100%)
    uint256 private constant BPS_DENOM = 10_000;
    /// @notice Maximum number of claimers supported
    uint256 private constant MAX_CLAIMERS = 100;

    /// @notice WETH token address
    address public WETH;
    /// @notice Partner address (may be zero)
    address public PARTNER;
    /// @notice Partner share in bps (base 10_000)
    uint16 public PARTNER_BPS;

    /// @notice Authorized shared hook address (set at initialize)
    address public hook;
    /// @notice Pool identifier used when poking the shared hook's sweep
    PoolId public poolId;

    /// @notice Authorized bonding curve address
    address public bondingCurve;
    bool private bondingCurveSet;

    /// @notice List of claimer addresses
    address[] public claimers;
    /// @notice BPS for each claimer (base 10_000)
    mapping(address => uint16) public claimerBps;
    /// @notice Claimable WETH amounts per address
    mapping(address => uint256) public claimable;

    /// @dev Prevents initialize() from being called more than once (or on a directly deployed instance)
    bool private _cloneInitialized;

    /// @notice Modifier to restrict function access to authorized callers (hook or bonding curve)
    modifier onlyAuthorized() {
        _onlyAuthorized();
        _;
    }

    /// @notice Deploys the implementation template and locks it against initialize()
    /// @dev Only used once to create the clone template. All real state is set via initialize().
    constructor() Ownable(msg.sender) {
        _cloneInitialized = true;
    }

    /// @notice Accept native transfers (required for the WETH unwrap round-trip in claim(true))
    receive() external payable {}

    // ====================================================================
    // EXTERNAL FUNCTIONS
    // ====================================================================

    /// @notice Initialize a clone created via Clones.clone()
    /// @dev Reverts if already initialized (constructor or previous initialize call)
    /// @param _weth WETH token address
    /// @param admin Owner/admin of this fee share contract
    /// @param _partner Optional partner address (zero for none)
    /// @param _partnerBps Partner share in bps (base 10_000, range-checked) applied to creator fees
    /// @param _claimers List of claimer addresses for creator fee distribution
    /// @param _bps BPS shares for each claimer (must sum to 10_000)
    /// @param hook_ Shared Bags v4 hook authorized to notify fees
    /// @param poolId_ Pool identifier for the hook sweep poke
    function initialize(
        address _weth,
        address admin,
        address _partner,
        uint16 _partnerBps,
        address[] memory _claimers,
        uint16[] memory _bps,
        address hook_,
        PoolId poolId_
    ) external override {
        if (_cloneInitialized) revert BagsFeeShare_AlreadyInitialized();
        _cloneInitialized = true;
        if (_weth == address(0)) revert BagsFeeShare_ZeroWETH();
        if (hook_ == address(0)) revert BagsFeeShare_ZeroHook();
        if (_partnerBps > BPS_DENOM) revert BagsFeeShare_PartnerBpsTooHigh(_partnerBps);
        WETH = _weth;
        PARTNER = _partner;
        PARTNER_BPS = _partnerBps;
        hook = hook_;
        poolId = poolId_;
        _validateClaimers(_partner, _claimers, _bps);
        uint256 length = _claimers.length;
        for (uint256 i; i < length; ++i) {
            claimers.push(_claimers[i]);
            claimerBps[_claimers[i]] = _bps[i];
        }
        _transferOwnership(admin);
    }

    /// @notice One-time bonding curve setter; required to authorize notifyFee for pre-migration fees
    /// @param _bondingCurve Bonding curve address to authorize
    function setBondingCurve(
        address _bondingCurve
    ) external override onlyOwner {
        if (bondingCurveSet) revert BagsFeeShare_BondingCurveAlreadySet();
        if (_bondingCurve == address(0)) revert BagsFeeShare_ZeroBondingCurve();
        bondingCurve = _bondingCurve;
        bondingCurveSet = true;
        emit BondingCurveSet(_bondingCurve);
    }

    /// @notice Called by hook or bonding curve to record accounting
    /// @param amount Amount of WETH fees being recorded
    /// @dev True 50/50 protocol split: the platform's half never reaches this contract, so the full
    ///      notified amount belongs to the creator side (partner + claimers). There is no admin share.
    /// @dev nonReentrant deliberately omitted: notifyFee performs only accounting
    /// (increments claimable mappings, no external calls), and onlyAuthorized
    /// restricts callers to trusted hook/bondingCurve. Removing the guard allows
    /// claim() → hook.sweep() → notifyFee() to succeed within a single tx.
    function notifyFee(
        uint256 amount
    ) external override onlyAuthorized {
        if (amount == 0) return;

        // Optional partner share on the full amount
        uint256 partnerShare = 0;
        if (PARTNER != address(0) && PARTNER_BPS != 0) {
            partnerShare = Math.mulDiv(amount, PARTNER_BPS, BPS_DENOM);
        }
        uint256 claimerPot = amount - partnerShare;

        if (partnerShare > 0) claimable[PARTNER] += partnerShare;

        // Distribute to claimers by BPS with remainder to last claimer
        uint256 distributed;
        uint256 n = claimers.length;
        for (uint256 i; i < n; ++i) {
            address c = claimers[i];
            uint256 share =
                (i == n - 1) ? (claimerPot - distributed) : Math.mulDiv(claimerPot, claimerBps[c], BPS_DENOM);
            distributed += share;
            claimable[c] += share;
        }

        emit FeeNotified(amount, partnerShare, claimerPot);
    }

    /// @notice Claim accrued WETH; optionally unwrap to native
    /// @param unwrap True to receive native quote, false to receive WETH
    function claim(
        bool unwrap
    ) external override nonReentrant {
        // Optionally pre-sweep this pool's accrual (anyone can also call hook.sweep(poolId) directly)
        if (hook != address(0) && hook.code.length > 0) {
            // solhint-disable-next-line avoid-low-level-calls
            (bool ok,) = hook.call(abi.encodeWithSelector(IHookSweep.sweep.selector, poolId));
            if (!ok) emit SweepFailed(hook);
        }

        uint256 amt = claimable[msg.sender];
        if (amt == 0) revert BagsFeeShare_NothingToClaim();
        claimable[msg.sender] = 0;

        if (unwrap) {
            IWETH(WETH).withdraw(amt);
            (bool sent,) = msg.sender.call{value: amt}("");
            if (!sent) revert BagsFeeShare_SendFailed(msg.sender, amt);
        } else {
            IERC20(WETH).safeTransfer(msg.sender, amt);
        }
        emit Claimed(msg.sender, amt, unwrap);
    }

    /// @notice Update claimers and their BPS; forward-only; cannot remove unpaid claimers
    /// @param _claimers List of claimer addresses
    /// @param _bps BPS shares for each claimer (must sum to 10_000)
    function setClaimers(
        address[] calldata _claimers,
        uint16[] calldata _bps
    ) external override onlyOwner {
        _validateClaimers(PARTNER, _claimers, _bps);

        // Forbid removing unpaid claimers
        uint256 oldLength = claimers.length;
        for (uint256 i; i < oldLength; ++i) {
            address c = claimers[i];
            if (_indexOf(_claimers, c) == type(uint256).max) {
                if (claimable[c] != 0) revert BagsFeeShare_ClaimerHasUnpaid(c);
            }
        }

        // Reset current mapping and set new
        for (uint256 i; i < oldLength; ++i) {
            delete claimerBps[claimers[i]];
        }
        delete claimers;

        uint256 newLength = _claimers.length;
        for (uint256 i; i < newLength; ++i) {
            claimers.push(_claimers[i]);
            claimerBps[_claimers[i]] = _bps[i];
        }
        emit ClaimersUpdated(_claimers, _bps);
    }

    /// @notice Get claimers and their BPS
    /// @return addrs List of claimer addresses
    /// @return bps BPS shares for each claimer
    function getClaimers() external view override returns (address[] memory addrs, uint16[] memory bps) {
        addrs = claimers;
        uint256 length = claimers.length;
        bps = new uint16[](length);
        for (uint256 i; i < length; ++i) {
            bps[i] = claimerBps[claimers[i]];
        }
    }

    // ====================================================================
    // INTERNAL FUNCTIONS
    // ====================================================================

    /// @dev Internal helper to enforce authorized-only access
    function _onlyAuthorized() internal view {
        if (msg.sender != hook && msg.sender != bondingCurve) revert BagsFeeShare_NotAuthorized(msg.sender);
    }

    /// @dev Validates claimer configuration: checks lengths, uniqueness, and BPS sum
    /// @param _partner Partner address to exclude from claimers
    /// @param addrs Array of claimer addresses
    /// @param bps Array of BPS shares (must sum to 10_000)
    function _validateClaimers(
        address _partner,
        address[] memory addrs,
        uint16[] memory bps
    ) internal pure {
        uint256 length = addrs.length;
        if (length != bps.length) revert BagsFeeShare_LenMismatch(length, bps.length);
        if (length == 0) revert BagsFeeShare_NoClaimers();
        if (length > MAX_CLAIMERS) revert BagsFeeShare_TooManyClaimers(length, MAX_CLAIMERS);
        uint256 sum;
        for (uint256 i; i < length; ++i) {
            if (addrs[i] == address(0)) revert BagsFeeShare_ZeroClaimer();
            if (addrs[i] == _partner) revert BagsFeeShare_PartnerIsClaimer();
            for (uint256 j = i + 1; j < length; ++j) {
                if (addrs[i] == addrs[j]) revert BagsFeeShare_DuplicateClaimer(addrs[i]);
            }
            sum += bps[i];
        }
        if (sum != BPS_DENOM) revert BagsFeeShare_BpsSumInvalid(sum);
    }

    /// @dev Finds the index of an address in an array
    /// @param arr Array of addresses to search
    /// @param x Address to find
    /// @return idx Index of the address, or type(uint256).max if not found
    function _indexOf(
        address[] memory arr,
        address x
    ) internal pure returns (uint256 idx) {
        uint256 length = arr.length;
        for (uint256 i; i < length; ++i) {
            if (arr[i] == x) return i;
        }
        return type(uint256).max;
    }
}
