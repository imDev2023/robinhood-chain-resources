// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.26;

import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {PoolId} from "@uniswap/v4-core/src/types/PoolId.sol";
import {IPositionManager} from "@uniswap/v4-periphery/src/interfaces/IPositionManager.sol";
import {IAllowanceTransfer} from "permit2/src/interfaces/IAllowanceTransfer.sol";

/// @title IBagsBondingCurve
/// @notice Interface for the Bags bonding curve AMM and migration logic
/// @author Bags
interface IBagsBondingCurve {
    /// @notice Emitted on successful buys on the bonding curve (pre-migration)
    /// @param buyer The account that paid quote
    /// @param recipient The account that received tokens
    /// @param grossQuoteIn The total msg.value provided
    /// @param netQuoteIn The amount of quote added to the curve after fee
    /// @param tokensOut Tokens transferred to recipient
    /// @param feeQuote Total fee amount (in native quote)
    /// @param vaultFeeQuote Platform share (native quote)
    /// @param creatorFeeWETH Creator share (paid as WETH to FeeShare)
    /// @param refundQuote Any refunded quote because the threshold cap was reached
    /// @param price Spot price after the trade (quote wei per 1 token, scaled by 1e18)
    /// @param virtualTokenReserves Virtual token reserve after the trade
    /// @param virtualQuoteReserves Virtual quote reserve after the trade
    event TokensBought(
        address indexed buyer,
        address indexed recipient,
        uint256 grossQuoteIn,
        uint256 netQuoteIn,
        uint256 tokensOut,
        uint256 feeQuote,
        uint256 vaultFeeQuote,
        uint256 creatorFeeWETH,
        uint256 refundQuote,
        uint256 price,
        uint256 virtualTokenReserves,
        uint256 virtualQuoteReserves
    );
    /// @notice Emitted on successful sells on the bonding curve (pre-migration)
    /// @param seller The account that sold tokens
    /// @param recipient The account that received the quote proceeds
    /// @param tokensIn Tokens received from seller
    /// @param grossQuoteOut Gross quote removed from virtual reserves
    /// @param netQuoteToRecipient Net quote paid to the recipient after fee
    /// @param feeQuote Total fee amount (in native quote)
    /// @param vaultFeeQuote Platform share (native quote)
    /// @param creatorFeeWETH Creator share (paid as WETH to FeeShare)
    /// @param price Spot price after the trade (quote wei per 1 token, scaled by 1e18)
    /// @param virtualTokenReserves Virtual token reserve after the trade
    /// @param virtualQuoteReserves Virtual quote reserve after the trade
    event TokensSold(
        address indexed seller,
        address indexed recipient,
        uint256 tokensIn,
        uint256 grossQuoteOut,
        uint256 netQuoteToRecipient,
        uint256 feeQuote,
        uint256 vaultFeeQuote,
        uint256 creatorFeeWETH,
        uint256 price,
        uint256 virtualTokenReserves,
        uint256 virtualQuoteReserves
    );
    /// @notice Emitted when fees are split between the Bags vault, FeeShare, and partner
    /// @param payer Payer of the fee (buyer/seller)
    /// @param vault Bags vault address
    /// @param feeShare FeeShare contract address
    /// @param vaultFeeQuote Protocol share sent to the vault in native quote (after partner cut)
    /// @param creatorFeeWETH Creator share in WETH
    /// @param partnerFeeWETH Partner cut of the protocol half in WETH (zero when no partner)
    event FeesSplit(
        address indexed payer,
        address indexed vault,
        address indexed feeShare,
        uint256 vaultFeeQuote,
        uint256 creatorFeeWETH,
        uint256 partnerFeeWETH
    );
    /// @notice Emitted after successful migration to the Uniswap v4 pool
    /// @param creator Creator address
    /// @param platformAdmin Platform admin address (LP NFT recipient)
    /// @param token Token address
    /// @param lpQuote Quote amount seeded for LP
    /// @param lpTokens Token amount seeded for LP
    /// @param poolId Pool identifier
    /// @param sqrtPriceX96 Initial sqrt price for the pool
    event Migrated(
        address indexed creator,
        address indexed platformAdmin,
        address indexed token,
        uint256 lpQuote,
        uint256 lpTokens,
        PoolId poolId,
        uint160 sqrtPriceX96
    );
    /// @notice Emitted after the curve is initialized post-mint
    /// @param caller Initializer address
    /// @param realTokenReserves Token reserves recorded at initialization
    event Initialized(address indexed caller, uint256 realTokenReserves);

    /// @notice Caller lacks ADMIN_ROLE
    error BagsBondingCurve_NotAdmin(address caller);
    /// @notice Zero address provided for token
    error BagsBondingCurve_ZeroAddressToken();
    /// @notice Zero address provided for Pool Manager
    error BagsBondingCurve_ZeroAddressPoolManager();
    /// @notice Zero address provided for Position Manager
    error BagsBondingCurve_ZeroAddressPositionManager();
    /// @notice Zero address provided for Hook
    error BagsBondingCurve_ZeroAddressHook();
    /// @notice Zero address provided for WETH
    error BagsBondingCurve_ZeroAddressWETH();
    /// @notice Zero address provided for Vault
    error BagsBondingCurve_ZeroAddressVault();
    /// @notice Zero address provided for FeeShare
    error BagsBondingCurve_ZeroAddressFeeShare();
    /// @notice Zero address provided for platform admin
    error BagsBondingCurve_ZeroAddressPlatformAdmin();
    /// @notice Zero graduation threshold provided
    error BagsBondingCurve_ZeroThreshold();
    /// @notice Partner fee bps exceeds the 10_000 denominator
    error BagsBondingCurve_InvalidPartnerFeeBps(uint16 partnerFeeBps);
    /// @notice Snapshotted threshold does not sell the curve allocation within dust
    error BagsBondingCurve_EconomicsSoldMismatch(uint256 soldAtThreshold, uint256 expected);
    /// @notice Snapshotted threshold breaks curve-to-LP price continuity
    error BagsBondingCurve_EconomicsPriceDiscontinuity(uint256 lpSide, uint256 curveSide);
    /// @notice Contract already initialized
    error BagsBondingCurve_AlreadyInitialized();
    /// @notice Contract not initialized
    error BagsBondingCurve_NotInitialized();
    /// @notice Curve already migrated to the v4 pool
    error BagsBondingCurve_AlreadyMigrated();
    /// @notice No quote sent with the call
    error BagsBondingCurve_NoQuoteSent();
    /// @notice Slippage exceeded: actualOut is less than minExpected
    error BagsBondingCurve_SlippageExceeded(uint256 minExpected, uint256 actualOut);
    /// @notice Native transfer to the vault failed
    error BagsBondingCurve_VaultFeeTransferFailed(uint256 amount);
    /// @notice Native refund transfer failed
    error BagsBondingCurve_RefundTransferFailed(uint256 amount);
    /// @notice Invalid recipient address
    error BagsBondingCurve_InvalidRecipient();
    /// @notice Zero input amount provided
    error BagsBondingCurve_ZeroInputAmount();
    /// @notice Native transfer to recipient failed
    error BagsBondingCurve_NativeTransferFailed(address to, uint256 amount);
    /// @notice Migration threshold not reached
    error BagsBondingCurve_ThresholdNotReached(uint256 have, uint256 need);
    /// @notice Insufficient quote balance for LP provisioning
    error BagsBondingCurve_InsufficientQuoteForLP(uint256 have, uint256 need);
    /// @notice Insufficient token balance for LP provisioning
    error BagsBondingCurve_InsufficientTokenForLP(uint256 have, uint256 need);
    /// @notice Invalid amounts provided (must be > 0)
    error BagsBondingCurve_InvalidAmounts(uint256 amount0, uint256 amount1);
    /// @notice Virtual token reserve is zero
    error BagsBondingCurve_ZeroVirtualTokenReserve();

    /// @notice Initialize a freshly-deployed BeaconProxy with per-instance parameters
    /// @param token ERC20 token address traded on this bonding curve
    /// @param hook Shared Bags v4 hook address
    /// @param initialOwner Owner for Ownable (the factory; used for initializeAfterMint)
    /// @param creator_ Creator address
    /// @param feeShare_ FeeShare contract that receives creator's 50% of fees
    /// @param platformAdmin_ Platform admin: receives ADMIN_ROLE/DEFAULT_ADMIN_ROLE and the LP NFT
    /// @param partner_ Optional partner address (zero for none); paid from the protocol half
    /// @param partnerFeeBps_ Partner share in bps of the protocol half (snapshotted from the factory)
    /// @param thresholdQuote_ Net quote amount required to graduate (snapshotted from the factory)
    function initialize(
        address token,
        address hook,
        address initialOwner,
        address creator_,
        address feeShare_,
        address platformAdmin_,
        address partner_,
        uint16 partnerFeeBps_,
        uint256 thresholdQuote_
    ) external;

    /// @notice Access control role allowed to pause/unpause
    /// @return role Admin role identifier
    function ADMIN_ROLE() external view returns (bytes32 role);
    /// @notice Uniswap v4 PoolManager (singleton) used post-migration
    /// @return poolManager PoolManager instance
    function POOL_MANAGER() external view returns (IPoolManager poolManager);
    /// @notice Uniswap v4 PositionManager used to mint the full range position
    /// @return positionManager PositionManager instance
    function POSITION_MANAGER() external view returns (IPositionManager positionManager);
    /// @notice Shared Bags v4 hook attached to the migration pool
    /// @return hook Hook instance
    function HOOK() external view returns (IHooks hook);
    /// @notice ERC20 token that this curve sells and buys
    /// @return token ERC20 token address
    function TOKEN() external view returns (address token);
    /// @notice Vault that receives platform's 50% of quote fees
    /// @return vault Vault address
    function VAULT() external view returns (address vault);
    /// @notice FeeShare contract that receives creator's 50% of fees (as WETH)
    /// @return feeShare FeeShare address
    function FEE_SHARE() external view returns (address feeShare);
    /// @notice WETH address for the target chain
    /// @return weth WETH address
    function WETH() external view returns (address weth);
    /// @notice Permit2 contract
    /// @return permit2 Permit2 instance
    function PERMIT2() external view returns (IAllowanceTransfer permit2);

    /// @notice Net quote threshold required to trigger migration (snapshotted at initialize)
    /// @return threshold Graduation threshold in quote wei
    function thresholdQuote() external view returns (uint256 threshold);
    /// @notice Initial virtual quote reserve used for pricing (derived from the threshold)
    /// @return reserves Initial virtual quote reserve in quote wei
    function initialVirtualQuoteReserves() external view returns (uint256 reserves);
    /// @notice Quote amount seeded into the LP at migration (equals the snapshotted threshold)
    /// @return amount Quote amount wrapped into the migration LP
    function lpQuoteAmount() external view returns (uint256 amount);
    /// @notice Tracked real quote balance that contributes toward the migration threshold
    /// @return quoteReserves Current real quote reserves
    function realQuoteReserves() external view returns (uint256 quoteReserves);
    /// @notice Tracked real token balance held by the curve contract
    /// @return tokenReserves Current real token reserves
    function realTokenReserves() external view returns (uint256 tokenReserves);
    /// @notice One-time flag set after initial token mint is observed
    /// @return isInitialized True if initialized
    function initialized() external view returns (bool isInitialized);
    /// @notice True after migration completes
    /// @return isMigrated True if migrated
    function migrated() external view returns (bool isMigrated);
    /// @notice Creator address (kept for record, no reward paid)
    /// @return creatorAddress Creator address
    function creator() external view returns (address creatorAddress);
    /// @notice Platform admin: pause authority and migration LP NFT recipient
    /// @return adminAddress Platform admin address
    function platformAdmin() external view returns (address adminAddress);
    /// @notice Optional partner address (zero for none); paid from the protocol half
    /// @return partnerAddress Partner address
    function partner() external view returns (address partnerAddress);
    /// @notice Partner share in bps of the protocol half (snapshotted at initialize)
    /// @return bps Partner fee bps
    function partnerFeeBps() external view returns (uint16 bps);

    /// @notice Returns the current virtual reserves used for pricing
    /// @return vToken Virtual token reserve
    /// @return vQuote Virtual quote reserve
    function getVirtualReserves() external view returns (uint256 vToken, uint256 vQuote);
    /// @notice Returns current spot price as quote wei per token unit based on virtual reserves
    /// @return price Spot price in quote wei per token unit (scaled by 1e18)
    function currentPrice() external view returns (uint256 price);
    /// @notice Returns the bonding progress percentage based on virtual token depletion
    /// @dev Returns 100 if and only if the curve has migrated; pre-migration values are 0-99.
    /// @return percent Progress in percent (0-100; 100 == migrated)
    function bondingProgress() external view returns (uint256 percent);

    /// @notice Quote a buy (exact-in quote) against the current virtual reserves
    /// @param quoteIn Amount of quote the user intends to send
    /// @return tokensOut Estimated tokens to receive
    /// @return feeQuote Estimated quote fee split between vault and fee share
    /// @return netQuoteIn Estimated quote added to the curve (after fee)
    /// @return grossUsed Portion of quoteIn that would be used (subject to threshold cap)
    /// @return refundQuote Portion of quoteIn that would be refunded
    function quoteBuy(
        uint256 quoteIn
    )
        external
        view
        returns (uint256 tokensOut, uint256 feeQuote, uint256 netQuoteIn, uint256 grossUsed, uint256 refundQuote);
    /// @notice Quote a sell (exact-in tokens) against the current virtual reserves
    /// @param tokensIn Amount of tokens the user intends to sell
    /// @return quoteToSeller Estimated quote to the seller after fee
    /// @return feeQuote Estimated quote fee split between vault and fee share
    /// @return grossQuoteOut Estimated gross quote out before fee
    function quoteSell(
        uint256 tokensIn
    ) external view returns (uint256 quoteToSeller, uint256 feeQuote, uint256 grossQuoteOut);

    /// @notice Pause trading
    function pause() external;
    /// @notice Unpause trading
    function unpause() external;
    /// @notice One-time initializer to sync realTokenReserves after the token supply has been minted
    function initializeAfterMint() external;

    /// @notice Buy tokens with native quote for yourself
    /// @param minTokensOut Minimum tokens expected to receive to protect against slippage
    function buy(
        uint256 minTokensOut
    ) external payable;
    /// @notice Buy tokens on behalf of a recipient with native quote
    /// @param recipient Address to receive the purchased tokens
    /// @param minTokensOut Minimum tokens expected to receive to protect against slippage
    function buyFor(
        address recipient,
        uint256 minTokensOut
    ) external payable;
    /// @notice Sell tokens for native quote
    /// @param tokensIn Amount of tokens to sell
    /// @param minQuoteOut Minimum quote expected to receive to protect against slippage
    function sell(
        uint256 tokensIn,
        uint256 minQuoteOut
    ) external;
    /// @notice Sell tokens for native quote on behalf of a recipient
    /// @dev Tokens are pulled from msg.sender; proceeds are paid to `recipient`.
    /// @param recipient Address to receive the quote proceeds
    /// @param tokensIn Amount of tokens to sell
    /// @param minQuoteOut Minimum quote expected to receive to protect against slippage
    function sellFor(
        address recipient,
        uint256 tokensIn,
        uint256 minQuoteOut
    ) external;
    /// @notice External entry point to trigger migration once threshold is reached
    function migrate() external;
}
