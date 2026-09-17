// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

// OpenZeppelin
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

// OpenZeppelin Upgradeable
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

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
/// @notice Per-token pull-payment ledger, denominated in WETH, for the creator-side 50% of fees
///         (claimers) plus the partner's cut of the protocol half ({notifyPartnerFee}).
///         Deployed once as the shared implementation behind an `UpgradeableBeacon`; the factory
///         creates a `BeaconProxy` per launch and calls `initialize(...)`.
/// @dev BEACON UPGRADE DESIGN RULE: this implementation is shared by every live launch through the
///      fee-share beacon. Flipping the beacon runs NO migration call on any proxy (unlike UUPS's
///      `upgradeToAndCall`), so every future upgrade MUST be safe with new state variables reading
///      as zero in all live proxies (or lazily initialized in the new logic). No upgrade may ever
///      require per-proxy setup.
///
///      STORAGE DISCIPLINE (append-only): never reorder, remove, or retype existing variables;
///      append new ones only at the end, consuming the trailing `__gap`. The OZ upgradeable bases
///      use ERC-7201 namespaced slots and do not shift this contract's linear layout. A bad beacon
///      upgrade corrupts ALL launches at once — diff the storage layout before every upgrade.
///
///      OWNERSHIP IS DELIBERATELY SINGLE-STEP (`OwnableUpgradeable`, not Ownable2Step): the factory
///      initializes each fee share with itself as owner, then hands ownership to the platform
///      inside the same launch transaction (`transferOwnership` after `setBondingCurve`). Two-step
///      ownership would strand every launch's fee share as "pending" until the platform manually
///      accepted. This ownership is operational admin only (claimers config via {setClaimers});
///      upgrade rights live with the beacon owner, which IS two-step protected (see BagsBeacon).
/// @author Bags
/// - Creator-side fees ({notifyFee}) go entirely to claimers pro-rata by BPS (last claimer absorbs
///   rounding dust); the partner takes nothing from the creator side
/// - Partner fees ({notifyPartnerFee}) are carved out of the PROTOCOL half upstream (curve/hook)
///   and credited to the partner's ledger here; the partner claims through the same {claim} flow
/// - Partner immutable; claimers updatable by admin (forward-only), max 100, unique, non-overlapping with partner
contract BagsFeeShare is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable, IBagsFeeShare {
    using SafeERC20 for IERC20;
    using Math for uint256;

    /// @notice Basis points denominator (10_000 = 100%)
    uint256 private constant BPS_DENOM = 10_000;
    /// @notice Maximum number of claimers supported
    uint256 private constant MAX_CLAIMERS = 100;

    /// @notice WETH token address
    address public WETH;
    /// @notice Partner address (may be zero; receives protocol-side partner fees via {notifyPartnerFee})
    address public PARTNER;

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

    /// @dev Reserved storage to allow appending variables in future beacon upgrades (append-only:
    ///      new variables replace gap slots from the top; never shrink from the middle).
    uint256[50] private __gap;

    /// @notice Modifier to restrict function access to authorized callers (hook or bonding curve)
    modifier onlyAuthorized() {
        _onlyAuthorized();
        _;
    }

    /// @notice Deploys the shared implementation and locks it against initialize()
    /// @dev All real state is set via initialize() on each BeaconProxy.
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Accept native transfers (required for the WETH unwrap round-trip in claim(true))
    receive() external payable {}

    // ====================================================================
    // EXTERNAL FUNCTIONS
    // ====================================================================

    /// @notice Initialize a freshly-deployed BeaconProxy
    /// @dev Guarded by OZ's `initializer` (re-calls revert `InvalidInitialization()`)
    /// @param _weth WETH token address
    /// @param admin Owner/admin of this fee share contract
    /// @param _partner Optional partner address (zero for none); paid from the protocol half via
    ///        {notifyPartnerFee}, never from the creator half
    /// @param _claimers List of claimer addresses for creator fee distribution
    /// @param _bps BPS shares for each claimer (must sum to 10_000)
    /// @param hook_ Shared Bags v4 hook authorized to notify fees
    /// @param poolId_ Pool identifier for the hook sweep poke
    function initialize(
        address _weth,
        address admin,
        address _partner,
        address[] memory _claimers,
        uint16[] memory _bps,
        address hook_,
        PoolId poolId_
    ) external override initializer {
        if (_weth == address(0)) revert BagsFeeShare_ZeroWETH();
        if (hook_ == address(0)) revert BagsFeeShare_ZeroHook();

        // Single-step ownership on purpose: the factory owns the fee share transiently and hands
        // it to the platform within the launch tx (see the contract-level NatSpec).
        __Ownable_init(admin);
        __ReentrancyGuard_init();

        WETH = _weth;
        PARTNER = _partner;
        hook = hook_;
        poolId = poolId_;
        _validateClaimers(_partner, _claimers, _bps);
        uint256 length = _claimers.length;
        for (uint256 i; i < length; ++i) {
            claimers.push(_claimers[i]);
            claimerBps[_claimers[i]] = _bps[i];
        }
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

    /// @notice Called by hook or bonding curve to record creator-side fee accounting
    /// @param amount Amount of WETH fees being recorded
    /// @dev True 50/50 protocol split: the platform's half never reaches this function, so the full
    ///      notified amount belongs to the claimers. The partner is paid from the PROTOCOL half via
    ///      {notifyPartnerFee} and takes nothing here.
    /// @dev nonReentrant deliberately omitted: notifyFee performs only accounting
    /// (increments claimable mappings, no external calls), and onlyAuthorized
    /// restricts callers to trusted hook/bondingCurve. Removing the guard allows
    /// claim() → hook.sweep() → notifyFee() to succeed within a single tx.
    function notifyFee(
        uint256 amount
    ) external override onlyAuthorized {
        if (amount == 0) return;

        // Distribute the full amount to claimers by BPS with remainder to last claimer
        uint256 distributed;
        uint256 n = claimers.length;
        for (uint256 i; i < n; ++i) {
            address c = claimers[i];
            uint256 share = (i == n - 1) ? (amount - distributed) : Math.mulDiv(amount, claimerBps[c], BPS_DENOM);
            distributed += share;
            claimable[c] += share;
        }

        emit FeeNotified(amount);
    }

    /// @notice Called by hook or bonding curve to credit the partner's cut of the PROTOCOL half
    /// @param amount Amount of WETH partner fees being recorded
    /// @dev The upstream callers (curve `_splitFee`, hook `sweep`) only route a partner cut when a
    ///      partner is configured, so the zero-partner revert is a defense-in-depth invariant.
    ///      Accounting-only (no external calls); same reentrancy reasoning as {notifyFee}.
    function notifyPartnerFee(
        uint256 amount
    ) external override onlyAuthorized {
        if (amount == 0) return;
        address partner_ = PARTNER;
        if (partner_ == address(0)) revert BagsFeeShare_NoPartner();

        claimable[partner_] += amount;
        emit PartnerFeeNotified(amount);
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
