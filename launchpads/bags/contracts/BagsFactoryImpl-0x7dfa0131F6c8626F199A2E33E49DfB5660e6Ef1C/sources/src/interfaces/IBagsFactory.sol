// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.26;

import {PoolId} from "@uniswap/v4-core/src/types/PoolId.sol";

import {BagsV4Hook} from "src/BagsV4Hook.sol";
import {BagsVault} from "src/BagsVault.sol";

/// @title IBagsFactory
/// @notice Interface for deploying Bags token (EIP-1167 clone) + bonding curve / fee share
///         (BeaconProxy) triples per launch
/// @author Bags
interface IBagsFactory {
    /// @notice Emitted when a new token and bonding curve are created
    /// @param token Token address
    /// @param curve Bonding curve address
    /// @param creator Creator address
    /// @param feeShare FeeShare address
    /// @param partner Optional partner address (zero for none); paid from the protocol half
    /// @param poolId Deterministic v4 pool id of the future migration pool
    /// @param name Token name
    /// @param symbol Token symbol
    /// @param metadataURI Metadata URI
    event TokenCreated(
        address indexed token,
        address indexed curve,
        address indexed creator,
        address feeShare,
        address partner,
        PoolId poolId,
        string name,
        string symbol,
        string metadataURI
    );
    /// @notice Emitted when the creation fee is updated
    /// @param newFee New creation fee in native quote
    event CreationFeeUpdated(uint256 newFee);
    /// @notice Emitted when the graduation threshold is updated
    /// @param oldThreshold Previous graduation threshold
    /// @param newThreshold New graduation threshold
    event GraduationThresholdUpdated(uint256 oldThreshold, uint256 newThreshold);
    /// @notice Emitted when the partner fee bps snapshotted into future launches is updated
    /// @param oldPartnerFeeBps Previous partner fee bps
    /// @param newPartnerFeeBps New partner fee bps
    event PartnerFeeBpsUpdated(uint16 oldPartnerFeeBps, uint16 newPartnerFeeBps);
    /// @notice Emitted when the shared hook wired into future launches is updated
    /// @param newHook New shared hook address
    event HookUpdated(address indexed newHook);
    /// @notice Emitted when the BagsToken implementation for future launches is updated
    /// @param newTokenImpl New BagsToken implementation address
    event TokenImplUpdated(address indexed newTokenImpl);
    /// @notice Emitted when funds are rescued
    /// @param token Token address (zero for native)
    /// @param to Recipient address
    /// @param amount Amount rescued
    event Rescued(address indexed token, address indexed to, uint256 amount);

    /// @notice Zero address provided for Pool Manager
    error BagsFactory_ZeroAddressPoolManager();
    /// @notice Zero address provided for Position Manager
    error BagsFactory_ZeroAddressPositionManager();
    /// @notice Zero address provided for the shared hook
    error BagsFactory_ZeroAddressHook();
    /// @notice Partner fee bps exceeds the 10_000 denominator
    error BagsFactory_InvalidPartnerFeeBps(uint16 partnerFeeBps);
    /// @notice Claimers array empty
    error BagsFactory_NoClaimers();
    /// @notice Invalid claimers config
    error BagsFactory_InvalidClaimers();
    /// @notice Zero address provided for WETH
    error BagsFactory_ZeroAddressWETH();
    /// @notice Zero address provided for Vault
    error BagsFactory_ZeroAddressVault();
    /// @notice Zero address provided for Permit2
    error BagsFactory_ZeroAddressPermit2();
    /// @notice Zero address provided for an implementation contract
    error BagsFactory_ZeroAddressImpl();
    /// @notice Zero address provided for a beacon contract
    error BagsFactory_ZeroAddressBeacon();
    /// @notice Graduation threshold outside the allowed bounds
    error BagsFactory_InvalidGraduationThreshold(uint256 threshold);
    /// @notice Sent value is less than the required creation fee
    error BagsFactory_InsufficientCreationFee(uint256 required, uint256 sent);
    /// @notice Native value transfer to `to` failed
    error BagsFactory_FeeTransferFailed(address to, uint256 amount);
    /// @notice Refund transfer to `to` failed
    error BagsFactory_RefundFailed(address to, uint256 amount);
    /// @notice Initial buy low-level call to curve failed
    error BagsFactory_BuyFailed(address curve, uint256 value);
    /// @notice createAndBuy called with no value left for buy after paying fee
    error BagsFactory_NoBuyValue();

    /// @notice Uniswap v4 PoolManager
    /// @return poolManagerAddress PoolManager address
    function poolManager() external view returns (address poolManagerAddress);
    /// @notice Uniswap v4 PositionManager
    /// @return positionManagerAddress PositionManager address
    function positionManager() external view returns (address positionManagerAddress);
    /// @notice WETH address for the target chain
    /// @return wethAddress WETH address
    function weth() external view returns (address wethAddress);
    /// @notice Permit2 contract address
    /// @return permit2Address Permit2 address
    function permit2() external view returns (address permit2Address);
    /// @notice Creation fee required to create a new pair
    /// @return fee Creation fee in native quote
    function creationFee() external view returns (uint256 fee);
    /// @notice Graduation threshold snapshotted into each new launch
    /// @return threshold Graduation threshold in quote wei
    function graduationThreshold() external view returns (uint256 threshold);
    /// @notice Partner fee in bps of the protocol half, snapshotted into each new launch
    /// @return bps Partner fee bps
    function partnerFeeBps() external view returns (uint16 bps);
    /// @notice Global vault (proxy) used by all bonding curves
    /// @return vaultContract Global Bags vault
    function vault() external view returns (BagsVault vaultContract);
    /// @notice Shared Bags v4 hook instance attached to every pool
    /// @return hookContract Shared hook instance
    function hook() external view returns (BagsV4Hook hookContract);

    /// @notice BagsToken implementation (EIP-1167 clone template for future launches)
    /// @return impl Implementation address
    function tokenImpl() external view returns (address impl);
    /// @notice Beacon that every launched BagsFeeShare proxy resolves its implementation from
    /// @return beacon Beacon address
    function feeShareBeacon() external view returns (address beacon);
    /// @notice Beacon that every launched BagsBondingCurve proxy resolves its implementation from
    /// @return beacon Beacon address
    function bondingCurveBeacon() external view returns (address beacon);

    /// @notice Bonding curve for a launched token
    /// @param token Token address
    /// @return curve Bonding curve address (zero if unknown)
    function curveForToken(
        address token
    ) external view returns (address curve);
    /// @notice FeeShare contract for a launched token
    /// @param token Token address
    /// @return feeShare FeeShare address (zero if unknown)
    function feeShareForToken(
        address token
    ) external view returns (address feeShare);
    /// @notice Reverse lookup from v4 pool id to the launched token
    /// @param poolId Pool identifier
    /// @return token Token address (zero if unknown)
    function tokenForPoolId(
        PoolId poolId
    ) external view returns (address token);
    /// @notice Launched token by index
    /// @param index Token index in launch order
    /// @return token Token address
    function allTokens(
        uint256 index
    ) external view returns (address token);
    /// @notice Number of tokens ever launched by this factory
    /// @return length Length of the allTokens array
    function allTokensLength() external view returns (uint256 length);
    /// @notice Paged getter over all launched tokens
    /// @param offset Index of the first token to return
    /// @param limit Maximum number of tokens to return
    /// @return tokens Token addresses in launch order
    function getTokens(
        uint256 offset,
        uint256 limit
    ) external view returns (address[] memory tokens);

    /// @notice Update the creation fee required to create a new pair
    /// @param newFee New creation fee in native quote
    function setCreationFee(
        uint256 newFee
    ) external;
    /// @notice Update the graduation threshold snapshotted into future launches
    /// @param newThreshold New graduation threshold in quote wei
    function setGraduationThreshold(
        uint256 newThreshold
    ) external;
    /// @notice Update the partner fee (bps of the protocol half) snapshotted into future launches
    /// @param newPartnerFeeBps New partner fee in bps (base 10_000, max 10_000)
    function setPartnerFeeBps(
        uint16 newPartnerFeeBps
    ) external;
    /// @notice Update the shared hook wired into future launches
    /// @param newHook New shared BagsV4Hook address
    function setHook(
        address newHook
    ) external;
    /// @notice Update the BagsToken implementation cloned into future launches
    /// @param newTokenImpl New BagsToken implementation address
    function setTokenImpl(
        address newTokenImpl
    ) external;
    /// @notice Create a new token + bonding curve pair
    /// @param name Token name
    /// @param symbol Token symbol
    /// @param metadataURI Off-chain metadata URI for token
    /// @param partner Optional partner address; paid the current factory rate out of the
    ///        protocol half of every trade fee (never from the creator side)
    /// @param claimers List of claimer addresses for creator fee distribution
    /// @param bps BPS shares for each claimer (must sum to 10_000)
    /// @return token Newly deployed token address
    /// @return curve Newly deployed bonding curve address
    function create(
        string calldata name,
        string calldata symbol,
        string calldata metadataURI,
        address partner,
        address[] calldata claimers,
        uint16[] calldata bps
    ) external payable returns (address token, address curve);
    /// @notice Create a new token+curve pair and perform an initial buy on behalf of the creator
    /// @param name Token name
    /// @param symbol Token symbol
    /// @param metadataURI Off-chain metadata URI for token
    /// @param partner Optional partner address; paid the current factory rate out of the
    ///        protocol half of every trade fee (never from the creator side)
    /// @param claimers List of claimer addresses for creator fee distribution
    /// @param bps BPS shares for each claimer (must sum to 10_000)
    /// @return token Newly deployed token address
    /// @return curve Newly deployed bonding curve address
    function createAndBuy(
        string calldata name,
        string calldata symbol,
        string calldata metadataURI,
        address partner,
        address[] calldata claimers,
        uint16[] calldata bps
    ) external payable returns (address token, address curve);
    /// @notice Withdraw mistakenly sent funds
    /// @param token Token address to rescue (zero for native)
    /// @param amount Amount to rescue
    function rescue(
        address token,
        uint256 amount
    ) external;
}
