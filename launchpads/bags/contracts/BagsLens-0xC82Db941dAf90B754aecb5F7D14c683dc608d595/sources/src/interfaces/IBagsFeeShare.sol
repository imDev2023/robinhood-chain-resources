// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.26;

import {PoolId} from "@uniswap/v4-core/src/types/PoolId.sol";

/// @title IBagsFeeShare
/// @notice Interface for per-token fee sharing of WETH fees: creator-side fees go to claimers,
///         and the partner's cut of the protocol half is credited via {notifyPartnerFee}
/// @author Bags
interface IBagsFeeShare {
    /// @notice Emitted when creator-side fees are recorded for distribution to claimers
    /// @param amount Total fee amount distributed to claimers
    event FeeNotified(uint256 amount);
    /// @notice Emitted when the partner's cut of the protocol half is credited
    /// @param amount Partner fee amount credited
    event PartnerFeeNotified(uint256 amount);
    /// @notice Emitted when claimers are updated
    /// @param claimers List of claimer addresses
    /// @param bps BPS shares for each claimer
    event ClaimersUpdated(address[] claimers, uint16[] bps);
    /// @notice Emitted when a user claims fees
    /// @param user Claimer address
    /// @param amount Amount claimed
    /// @param unwrap True if claimed as native quote
    event Claimed(address indexed user, uint256 amount, bool unwrap);
    /// @notice Emitted when the bonding curve is set
    /// @param bondingCurve Bonding curve address
    event BondingCurveSet(address bondingCurve);
    /// @notice Emitted when a sweep attempt fails
    /// @param hook Hook address
    event SweepFailed(address indexed hook);

    /// @notice Caller is not the authorized hook or bonding curve
    error BagsFeeShare_NotAuthorized(address caller);
    /// @notice Native quote transfer to recipient failed
    error BagsFeeShare_SendFailed(address to, uint256 amount);
    /// @notice Zero address provided for WETH
    error BagsFeeShare_ZeroWETH();
    /// @notice Zero address provided for hook
    error BagsFeeShare_ZeroHook();
    /// @notice Partner fee notified but no partner is configured
    error BagsFeeShare_NoPartner();
    /// @notice Bonding curve address has already been set
    error BagsFeeShare_BondingCurveAlreadySet();
    /// @notice Zero address provided for bonding curve
    error BagsFeeShare_ZeroBondingCurve();
    /// @notice Caller has no claimable fees
    error BagsFeeShare_NothingToClaim();
    /// @notice Cannot remove a claimer with unpaid fees
    error BagsFeeShare_ClaimerHasUnpaid(address claimer);
    /// @notice Claimers and BPS arrays have different lengths
    error BagsFeeShare_LenMismatch(uint256 claimersLength, uint256 bpsLength);
    /// @notice Claimers array is empty
    error BagsFeeShare_NoClaimers();
    /// @notice Claimers array exceeds maximum allowed length
    error BagsFeeShare_TooManyClaimers(uint256 length, uint256 max);
    /// @notice Zero address provided for a claimer
    error BagsFeeShare_ZeroClaimer();
    /// @notice Partner address cannot also be a claimer
    error BagsFeeShare_PartnerIsClaimer();
    /// @notice Duplicate claimer address found
    error BagsFeeShare_DuplicateClaimer(address claimer);
    /// @notice Claimer BPS do not sum to 10_000
    error BagsFeeShare_BpsSumInvalid(uint256 sum);
    /// @notice Clone has already been initialized
    error BagsFeeShare_AlreadyInitialized();

    /// @notice Initialize a freshly-deployed BeaconProxy
    /// @param _weth WETH token address
    /// @param admin Owner/admin of this fee share contract
    /// @param _partner Optional partner address (zero for none); paid from the protocol half
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
    ) external;

    /// @notice WETH token address
    /// @return weth WETH address
    function WETH() external view returns (address weth);
    /// @notice Partner address (may be zero); receives protocol-side partner fees
    /// @return partner Partner address
    function PARTNER() external view returns (address partner);
    /// @notice Authorized shared hook address
    /// @return hookAddress Hook address
    function hook() external view returns (address hookAddress);
    /// @notice Pool identifier used when poking the shared hook's sweep
    /// @return id Pool identifier
    function poolId() external view returns (PoolId id);
    /// @notice Authorized bonding curve address
    /// @return bondingCurveAddress Bonding curve address
    function bondingCurve() external view returns (address bondingCurveAddress);
    /// @notice Claimable amount per address
    /// @param user Address to query
    /// @return amount Claimable amount
    function claimable(
        address user
    ) external view returns (uint256 amount);
    /// @notice BPS for a given claimer address
    /// @param claimer Claimer address to query
    /// @return bps Claimer bps
    function claimerBps(
        address claimer
    ) external view returns (uint16 bps);
    /// @notice Single claimer by index
    /// @param index Claimer index
    /// @return claimerAddress Claimer address
    function claimers(
        uint256 index
    ) external view returns (address claimerAddress);

    /// @notice One-time bonding curve setter; required to authorize notifyFee for pre-migration fees
    /// @param _bondingCurve Bonding curve address to authorize
    function setBondingCurve(
        address _bondingCurve
    ) external;
    /// @notice Called by hook or bonding curve to record creator-side fee accounting (claimers only)
    /// @param amount Amount of WETH fees being recorded
    function notifyFee(
        uint256 amount
    ) external;
    /// @notice Called by hook or bonding curve to credit the partner's cut of the protocol half
    /// @param amount Amount of WETH partner fees being recorded
    function notifyPartnerFee(
        uint256 amount
    ) external;
    /// @notice Claim accrued WETH; optionally unwrap to native
    /// @param unwrap True to receive native quote, false to receive WETH
    function claim(
        bool unwrap
    ) external;
    /// @notice Update claimers and their BPS; forward-only; cannot remove unpaid claimers
    /// @param _claimers List of claimer addresses
    /// @param _bps BPS shares for each claimer (must sum to 10_000)
    function setClaimers(
        address[] calldata _claimers,
        uint16[] calldata _bps
    ) external;
    /// @notice Get claimers and their BPS
    /// @return addrs List of claimer addresses
    /// @return bps BPS shares for each claimer
    function getClaimers() external view returns (address[] memory addrs, uint16[] memory bps);
}
