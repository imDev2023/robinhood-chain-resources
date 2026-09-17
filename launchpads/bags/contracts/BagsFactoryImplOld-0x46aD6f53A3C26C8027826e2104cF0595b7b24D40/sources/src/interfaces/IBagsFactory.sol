// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.26;

import {PoolId} from "@uniswap/v4-core/src/types/PoolId.sol";

import {BagsV4Hook} from "src/BagsV4Hook.sol";
import {BagsVault} from "src/BagsVault.sol";

/// @title IBagsFactory
/// @notice Interface for deploying Bags token + bonding curve pairs via EIP-1167 clones
/// @author Bags
interface IBagsFactory {
    /// @notice Emitted when a new token and bonding curve are created
    /// @param token Token address
    /// @param curve Bonding curve address
    /// @param creator Creator address
    /// @param feeShare FeeShare address
    /// @param poolId Deterministic v4 pool id of the future migration pool
    /// @param name Token name
    /// @param symbol Token symbol
    /// @param metadataURI Metadata URI
    event TokenCreated(
        address indexed token,
        address indexed curve,
        address indexed creator,
        address feeShare,
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
    /// @notice Invalid partner BPS
    error BagsFactory_InvalidPartnerBps(uint16 partnerBps);
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
    /// @return poolManager PoolManager address
    function POOL_MANAGER() external view returns (address poolManager);
    /// @notice Uniswap v4 PositionManager
    /// @return positionManager PositionManager address
    function POSITION_MANAGER() external view returns (address positionManager);
    /// @notice WETH address for the target chain
    /// @return weth WETH address
    function WETH() external view returns (address weth);
    /// @notice Permit2 contract address
    /// @return permit2 Permit2 address
    function PERMIT2() external view returns (address permit2);
    /// @notice Creation fee required to create a new pair
    /// @return fee Creation fee in native quote
    function creationFee() external view returns (uint256 fee);
    /// @notice Graduation threshold snapshotted into each new launch
    /// @return threshold Graduation threshold in quote wei
    function graduationThreshold() external view returns (uint256 threshold);
    /// @notice Global vault used by all bonding curves
    /// @return vault Global Bags vault
    function VAULT() external view returns (BagsVault vault);
    /// @notice Shared Bags v4 hook instance attached to every pool
    /// @return hook Shared hook instance
    function HOOK() external view returns (BagsV4Hook hook);

    /// @notice BagsToken implementation (clone template)
    /// @return impl Implementation address
    function TOKEN_IMPL() external view returns (address impl);
    /// @notice BagsFeeShare implementation (clone template)
    /// @return impl Implementation address
    function FEE_SHARE_IMPL() external view returns (address impl);
    /// @notice BagsBondingCurve implementation (clone template)
    /// @return impl Implementation address
    function BONDING_CURVE_IMPL() external view returns (address impl);

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
    /// @notice Create a new token + bonding curve pair
    /// @param name Token name
    /// @param symbol Token symbol
    /// @param metadataURI Off-chain metadata URI for token
    /// @param partner Optional partner address for fee sharing
    /// @param partnerBps Partner share in bps (base 10_000) applied to creator fees
    /// @param claimers List of claimer addresses for creator fee distribution
    /// @param bps BPS shares for each claimer (must sum to 10_000)
    /// @return token Newly deployed token address
    /// @return curve Newly deployed bonding curve address
    function create(
        string calldata name,
        string calldata symbol,
        string calldata metadataURI,
        address partner,
        uint16 partnerBps,
        address[] calldata claimers,
        uint16[] calldata bps
    ) external payable returns (address token, address curve);
    /// @notice Create a new token+curve pair and perform an initial buy on behalf of the creator
    /// @param name Token name
    /// @param symbol Token symbol
    /// @param metadataURI Off-chain metadata URI for token
    /// @param partner Optional partner address for fee sharing
    /// @param partnerBps Partner share in bps (base 10_000) applied to creator fees
    /// @param claimers List of claimer addresses for creator fee distribution
    /// @param bps BPS shares for each claimer (must sum to 10_000)
    /// @return token Newly deployed token address
    /// @return curve Newly deployed bonding curve address
    function createAndBuy(
        string calldata name,
        string calldata symbol,
        string calldata metadataURI,
        address partner,
        uint16 partnerBps,
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
