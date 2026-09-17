// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.26;

// OpenZeppelin
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// Uniswap v4 Core
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {LPFeeLibrary} from "@uniswap/v4-core/src/libraries/LPFeeLibrary.sol";
import {PoolId} from "@uniswap/v4-core/src/types/PoolId.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";

// Local contracts (used for type-casting clones, NOT for `new` deployment)
import {BagsBondingCurve} from "./BagsBondingCurve.sol";
import {BagsFeeShare} from "./BagsFeeShare.sol";
import {BagsToken} from "./BagsToken.sol";
import {BagsV4Hook} from "./BagsV4Hook.sol";
import {BagsVault} from "./BagsVault.sol";

// Local interfaces
import {IBagsFactory} from "src/interfaces/IBagsFactory.sol";

/// @title BagsFactory
/// @notice Deploys `BagsToken` + `BagsBondingCurve` pairs using EIP-1167 minimal proxy clones.
///         Implementation contracts are deployed once; the factory clones them cheaply per token launch.
///         All launches share one `BagsV4Hook` instance; the factory registers each pool with it.
/// @author Bags
contract BagsFactory is Ownable, IBagsFactory {
    using SafeERC20 for IERC20;
    /// @notice Basis points denominator (10_000 = 100%)
    uint256 private constant BPS_DENOM = 10_000;
    /// @notice Maximum number of claimers supported per token
    uint256 private constant MAX_CLAIMERS = 100;
    /// @notice Default creation fee for launching a token
    uint256 private constant DEFAULT_CREATION_FEE = 0.02 ether;
    /// @notice Default minimum tokens out used for the initial buy in createAndBuy
    /// @dev Atomic deployment+buy makes front-run slippage unlikely; keep minimal protection.
    uint256 private constant INITIAL_BUY_MIN_TOKENS_OUT = 1;
    /// @notice Minimum allowed graduation threshold
    uint256 private constant MIN_GRADUATION_THRESHOLD = 0.01 ether;
    /// @notice Maximum allowed graduation threshold
    uint256 private constant MAX_GRADUATION_THRESHOLD = 1000 ether;
    /// @notice Tick spacing of every Bags pool (must byte-match the curve's `_migrate` key)
    int24 private constant TICK_SPACING = 60;

    /// @notice Uniswap v4 PoolManager (set at deployment)
    address public immutable POOL_MANAGER;
    /// @notice Uniswap v4 PositionManager (set at deployment)
    address public immutable POSITION_MANAGER;
    /// @notice WETH address for the target chain
    address public immutable WETH;
    /// @notice Permit2 contract address
    address public immutable PERMIT2;
    /// @notice Global vault used by all bonding curves for fee collection
    BagsVault public immutable VAULT;
    /// @notice Shared Bags v4 hook instance attached to every pool
    BagsV4Hook public immutable HOOK;

    // --- Implementation addresses for EIP-1167 cloning ---
    /// @notice BagsToken implementation (clone template)
    address public immutable TOKEN_IMPL;
    /// @notice BagsFeeShare implementation (clone template)
    address public immutable FEE_SHARE_IMPL;
    /// @notice BagsBondingCurve implementation (clone template)
    address public immutable BONDING_CURVE_IMPL;

    /// @notice Creation fee required to create a new pair
    uint256 public creationFee = DEFAULT_CREATION_FEE;

    /// @notice Graduation threshold snapshotted into each new launch (owner-settable)
    /// @dev Changing it never affects live curves: each clone stores the value at initialize().
    ///      Any value within the bounds satisfies the curve's economics asserts (verified for the
    ///      full [0.01 ether, 1000 ether] range).
    uint256 public graduationThreshold;

    // --- On-chain registry (integrator/indexer surface) ---
    /// @notice Bonding curve for a launched token
    mapping(address => address) public curveForToken;
    /// @notice FeeShare contract for a launched token
    mapping(address => address) public feeShareForToken;
    /// @notice Reverse lookup from v4 pool id to the launched token
    mapping(PoolId => address) public tokenForPoolId;
    /// @notice All tokens ever launched by this factory
    address[] public allTokens;

    /// @notice Creates the factory with chain-specific infrastructure addresses and implementation contracts
    /// @param poolManager Uniswap v4 PoolManager address
    /// @param positionManager Uniswap v4 PositionManager address
    /// @param weth WETH address for the target chain
    /// @param vault Global Bags vault address
    /// @param permit2 Permit2 contract address
    /// @param hook Shared BagsV4Hook instance address
    /// @param tokenImpl BagsToken implementation address
    /// @param feeShareImpl BagsFeeShare implementation address
    /// @param bondingCurveImpl BagsBondingCurve implementation address
    /// @param graduationThreshold_ Initial graduation threshold (net quote raise per launch)
    constructor(
        address poolManager,
        address positionManager,
        address weth,
        address vault,
        address permit2,
        address hook,
        address tokenImpl,
        address feeShareImpl,
        address bondingCurveImpl,
        uint256 graduationThreshold_
    ) Ownable(msg.sender) {
        if (poolManager == address(0)) revert BagsFactory_ZeroAddressPoolManager();
        if (positionManager == address(0)) revert BagsFactory_ZeroAddressPositionManager();
        if (weth == address(0)) revert BagsFactory_ZeroAddressWETH();
        if (vault == address(0)) revert BagsFactory_ZeroAddressVault();
        if (permit2 == address(0)) revert BagsFactory_ZeroAddressPermit2();
        if (hook == address(0)) revert BagsFactory_ZeroAddressHook();
        if (tokenImpl == address(0)) revert BagsFactory_ZeroAddressImpl();
        if (feeShareImpl == address(0)) revert BagsFactory_ZeroAddressImpl();
        if (bondingCurveImpl == address(0)) revert BagsFactory_ZeroAddressImpl();

        POOL_MANAGER = poolManager;
        POSITION_MANAGER = positionManager;
        WETH = weth;
        PERMIT2 = permit2;

        VAULT = BagsVault(payable(vault));
        HOOK = BagsV4Hook(payable(hook));

        TOKEN_IMPL = tokenImpl;
        FEE_SHARE_IMPL = feeShareImpl;
        BONDING_CURVE_IMPL = bondingCurveImpl;

        _setGraduationThreshold(graduationThreshold_);
    }

    /// @notice Accept native transfers (needed to receive curve refunds during createAndBuy)
    receive() external payable {}

    // ====================================================================
    // EXTERNAL FUNCTIONS
    // ====================================================================

    /// @notice Update the creation fee required to create a new pair
    /// @param newFee New creation fee in native quote
    function setCreationFee(
        uint256 newFee
    ) external override onlyOwner {
        creationFee = newFee;
        emit CreationFeeUpdated(newFee);
    }

    /// @notice Update the graduation threshold snapshotted into future launches
    /// @dev Bounds-checked; live curves keep the value they snapshotted at creation.
    /// @param newThreshold New graduation threshold in quote wei
    function setGraduationThreshold(
        uint256 newThreshold
    ) external override onlyOwner {
        _setGraduationThreshold(newThreshold);
    }

    /// @notice Number of tokens ever launched by this factory
    /// @return length Length of the allTokens array
    function allTokensLength() external view override returns (uint256 length) {
        return allTokens.length;
    }

    /// @notice Paged getter over all launched tokens
    /// @param offset Index of the first token to return
    /// @param limit Maximum number of tokens to return
    /// @return tokens Token addresses in launch order
    function getTokens(
        uint256 offset,
        uint256 limit
    ) external view override returns (address[] memory tokens) {
        uint256 total = allTokens.length;
        if (offset >= total) return new address[](0);
        uint256 end = offset + limit;
        if (end > total) end = total;
        tokens = new address[](end - offset);
        for (uint256 i = offset; i < end; ++i) {
            tokens[i - offset] = allTokens[i];
        }
    }

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
    /// @dev The creator is set to msg.sender. With the FeeShare admin share removed, the claimers
    ///      array is the only creator-side fee routing: include the creator address for them to earn.
    function create(
        string calldata name,
        string calldata symbol,
        string calldata metadataURI,
        address partner,
        uint16 partnerBps,
        address[] calldata claimers,
        uint16[] calldata bps
    ) external payable override returns (address token, address curve) {
        if (msg.value < creationFee) {
            revert BagsFactory_InsufficientCreationFee(creationFee, msg.value);
        }
        (BagsToken deployedToken, BagsBondingCurve deployedCurve) =
            _deployPair(name, symbol, metadataURI, msg.sender, partner, partnerBps, claimers, bps);

        // Send only the creation fee to the vault, refund any surplus to sender
        (bool okFee,) = payable(address(VAULT)).call{value: creationFee}("");
        if (!okFee) revert BagsFactory_FeeTransferFailed(address(VAULT), creationFee);

        uint256 refund = msg.value - creationFee;
        if (refund > 0) {
            (bool okRefund,) = msg.sender.call{value: refund}("");
            if (!okRefund) revert BagsFactory_RefundFailed(msg.sender, refund);
        }

        return (address(deployedToken), address(deployedCurve));
    }

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
    /// @dev Sends exactly `creationFee` to vault, uses remaining value for the buy, forwards tokens/refund to sender
    function createAndBuy(
        string calldata name,
        string calldata symbol,
        string calldata metadataURI,
        address partner,
        uint16 partnerBps,
        address[] calldata claimers,
        uint16[] calldata bps
    ) external payable override returns (address token, address curve) {
        if (msg.value < creationFee) {
            revert BagsFactory_InsufficientCreationFee(creationFee, msg.value);
        }
        uint256 buyValue = msg.value - creationFee;
        if (buyValue == 0) revert BagsFactory_NoBuyValue();

        // Record baseline balance to compute exact refund after buy
        uint256 baseline = address(this).balance - msg.value;

        (BagsToken deployedToken, BagsBondingCurve deployedCurve) =
            _deployPair(name, symbol, metadataURI, msg.sender, partner, partnerBps, claimers, bps);

        // Pay creation fee to the vault
        (bool okFee,) = payable(address(VAULT)).call{value: creationFee}("");
        if (!okFee) revert BagsFactory_FeeTransferFailed(address(VAULT), creationFee);

        // Perform initial buy on behalf of the creator.
        (bool okBuy,) = address(deployedCurve).call{value: buyValue}(
            abi.encodeWithSignature("buyFor(address,uint256)", msg.sender, INITIAL_BUY_MIN_TOKENS_OUT)
        );
        if (!okBuy) revert BagsFactory_BuyFailed(address(deployedCurve), buyValue);

        // Any refund from the curve buy has already been returned to the factory.
        // Forward any refund to the creator (if curve limited the gross)
        uint256 refund = address(this).balance - baseline;
        if (refund > 0) {
            (bool okRefund,) = msg.sender.call{value: refund}("");
            if (!okRefund) revert BagsFactory_RefundFailed(msg.sender, refund);
        }

        return (address(deployedToken), address(deployedCurve));
    }

    /// @notice Withdraw mistakenly sent funds
    /// @param token Token address to rescue (zero for native)
    /// @param amount Amount to rescue
    function rescue(
        address token,
        uint256 amount
    ) external override onlyOwner {
        if (token == address(0)) {
            (bool ok,) = owner().call{value: amount}("");
            if (!ok) revert BagsFactory_FeeTransferFailed(owner(), amount);
            emit Rescued(address(0), owner(), amount);
            return;
        }
        IERC20(token).safeTransfer(owner(), amount);
        emit Rescued(token, owner(), amount);
    }

    // ====================================================================
    // INTERNAL FUNCTIONS
    // ====================================================================

    /// @dev Bounds-checks and stores the graduation threshold, emitting {GraduationThresholdUpdated}
    function _setGraduationThreshold(
        uint256 newThreshold
    ) internal {
        if (newThreshold < MIN_GRADUATION_THRESHOLD || newThreshold > MAX_GRADUATION_THRESHOLD) {
            revert BagsFactory_InvalidGraduationThreshold(newThreshold);
        }
        uint256 oldThreshold = graduationThreshold;
        graduationThreshold = newThreshold;
        emit GraduationThresholdUpdated(oldThreshold, newThreshold);
    }

    /// @dev Builds the canonical PoolKey for a launched token. Must byte-match the key the curve
    ///      builds in `_migrate` (sorted token/WETH, dynamic fee flag, tick spacing 60, shared hook).
    /// @param token Launched token address
    /// @return key Canonical pool key for the token's migration pool
    function _poolKeyFor(
        address token
    ) internal view returns (PoolKey memory key) {
        bool tokenIs0 = token < WETH;
        key = PoolKey({
            currency0: Currency.wrap(tokenIs0 ? token : WETH),
            currency1: Currency.wrap(tokenIs0 ? WETH : token),
            fee: LPFeeLibrary.DYNAMIC_FEE_FLAG,
            tickSpacing: TICK_SPACING,
            hooks: IHooks(address(HOOK))
        });
    }

    /// @dev Internal helper to deploy token and curve via EIP-1167 clones, mint, initialize,
    ///      register the pool with the shared hook, and populate the registry
    function _deployPair(
        string calldata name,
        string calldata symbol,
        string calldata metadataURI,
        address creator,
        address partner,
        uint16 partnerBps,
        address[] memory claimers,
        uint16[] memory bps
    ) internal returns (BagsToken token, BagsBondingCurve curve) {
        // Validate partnerBps
        if (partnerBps > BPS_DENOM) revert BagsFactory_InvalidPartnerBps(partnerBps);
        // Validate claimers config
        uint256 claimersLength = claimers.length;
        if (claimersLength == 0) revert BagsFactory_NoClaimers();
        if (claimersLength != bps.length || claimersLength > MAX_CLAIMERS) revert BagsFactory_InvalidClaimers();
        uint256 sum;
        for (uint256 i; i < claimersLength; ++i) {
            if (claimers[i] == address(0) || claimers[i] == partner) revert BagsFactory_InvalidClaimers();
            for (uint256 j = i + 1; j < claimersLength; ++j) {
                if (claimers[i] == claimers[j]) revert BagsFactory_InvalidClaimers();
            }
            sum += bps[i];
        }
        if (sum != BPS_DENOM) revert BagsFactory_InvalidClaimers();

        // Clone and initialize BagsToken
        token = BagsToken(Clones.clone(TOKEN_IMPL));
        token.initialize(name, symbol, metadataURI, address(this));

        // The pool id is deterministic as soon as the token address is known
        PoolId poolId = _poolKeyFor(address(token)).toId();

        // Clone and initialize BagsFeeShare, wired to the shared hook. The factory is the
        // temporary admin so it can call setBondingCurve; ownership moves to the platform below.
        BagsFeeShare feeShare = BagsFeeShare(payable(Clones.clone(FEE_SHARE_IMPL)));
        feeShare.initialize(WETH, address(this), partner, partnerBps, claimers, bps, address(HOOK), poolId);

        // Clone and initialize BagsBondingCurve. The factory stays owner only for
        // initializeAfterMint; pause authority and the LP NFT go to the factory owner.
        curve = BagsBondingCurve(payable(Clones.clone(BONDING_CURVE_IMPL)));
        curve.initialize(
            address(token), address(HOOK), address(this), creator, address(feeShare), owner(), graduationThreshold
        );

        // Wire bonding curve into feeshare for pre-migration fee notifications,
        // then hand the fee share admin over to the platform (factory owner)
        feeShare.setBondingCurve(address(curve));
        feeShare.transferOwnership(owner());

        // Register the pool with the shared hook: authorizes the curve to initialize the pool
        // and routes the creator half of swept fees to the fee share
        HOOK.register(poolId, address(curve), address(feeShare));

        // Mint full supply to curve
        token.mintInitialSupply(address(curve));

        // Sync curve real token reserves
        curve.initializeAfterMint();

        // Transfer token ownership to curve so it can renounce later; or dead directly
        token.transferOwnership(address(curve));

        // Populate the on-chain registry
        curveForToken[address(token)] = address(curve);
        feeShareForToken[address(token)] = address(feeShare);
        tokenForPoolId[poolId] = address(token);
        allTokens.push(address(token));

        emit TokenCreated(
            address(token), address(curve), creator, address(feeShare), poolId, name, symbol, metadataURI
        );
    }
}
