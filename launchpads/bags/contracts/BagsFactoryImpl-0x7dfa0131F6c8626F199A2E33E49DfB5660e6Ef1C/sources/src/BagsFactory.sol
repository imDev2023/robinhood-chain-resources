// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.26;

// OpenZeppelin
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {BeaconProxy} from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// OpenZeppelin Upgradeable
import {Ownable2StepUpgradeable} from "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

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
/// @notice Deploys `BagsToken` + `BagsBondingCurve` + `BagsFeeShare` triples per launch: the token
///         as an immutable EIP-1167 clone, the curve and fee share as `BeaconProxy` instances so
///         all live launches can be upgraded in one beacon flip.
///         All launches share one `BagsV4Hook` instance; the factory registers each pool with it.
/// @dev UUPS upgradeable behind an `ERC1967Proxy`; all former constructor immutables are storage
///      set in {initialize}. Ownership is two-step (`Ownable2Step`) because the owner controls
///      upgrades.
///
///      DELIBERATELY MISSING SETTERS:
///      - No `setVault`: the curve implementation bakes `VAULT` in as an immutable, so a
///        factory-side vault change would silently split fee routing (creation fees to the new
///        vault, trading fees to the old one). Changing the vault must be a coordinated beacon
///        upgrade of the curve implementation, so the factory setter must not exist.
///      - No beacon setters (`feeShareBeacon`/`bondingCurveBeacon`): beacons are retargeted by
///        upgrading the beacon itself (`BagsBeacon.upgradeTo`), which atomically moves every live
///        launch. Repointing the factory at a different beacon would fork the fleet: existing
///        proxies would stay on the old beacon forever while new launches follow the new one.
/// @author Bags
contract BagsFactory is Initializable, Ownable2StepUpgradeable, UUPSUpgradeable, IBagsFactory {
    using SafeERC20 for IERC20;
    /// @notice Basis points denominator (10_000 = 100%)
    uint256 private constant BPS_DENOM = 10_000;
    /// @notice Maximum number of claimers supported per token
    uint256 private constant MAX_CLAIMERS = 100;
    /// @notice Default creation fee for launching a token
    uint256 private constant DEFAULT_CREATION_FEE = 0.02 ether;
    /// @notice Default partner fee in bps of the protocol half (25%)
    uint16 private constant DEFAULT_PARTNER_FEE_BPS = 2500;
    /// @notice Maximum partner fee in bps (100% of the protocol half)
    uint16 private constant MAX_PARTNER_FEE_BPS = 10_000;
    /// @notice Default minimum tokens out used for the initial buy in createAndBuy
    /// @dev Atomic deployment+buy makes front-run slippage unlikely; keep minimal protection.
    uint256 private constant INITIAL_BUY_MIN_TOKENS_OUT = 1;
    /// @notice Minimum allowed graduation threshold
    uint256 private constant MIN_GRADUATION_THRESHOLD = 0.01 ether;
    /// @notice Maximum allowed graduation threshold
    uint256 private constant MAX_GRADUATION_THRESHOLD = 1000 ether;
    /// @notice Tick spacing of every Bags pool (must byte-match the curve's `_migrate` key)
    int24 private constant TICK_SPACING = 60;

    /// @notice Uniswap v4 PoolManager (set at initialize)
    address public poolManager;
    /// @notice Uniswap v4 PositionManager (set at initialize)
    address public positionManager;
    /// @notice WETH address for the target chain
    address public weth;
    /// @notice Permit2 contract address
    address public permit2;
    /// @notice Global vault (proxy) used by all bonding curves for fee collection
    BagsVault public vault;
    /// @notice Shared Bags v4 hook instance attached to every pool (owner-settable)
    BagsV4Hook public hook;

    // --- Per-launch deployment templates ---
    /// @notice BagsToken implementation (EIP-1167 clone template; owner-settable for future launches)
    address public tokenImpl;
    /// @notice Beacon that every launched BagsFeeShare proxy resolves its implementation from
    address public feeShareBeacon;
    /// @notice Beacon that every launched BagsBondingCurve proxy resolves its implementation from
    address public bondingCurveBeacon;

    /// @notice Creation fee required to create a new pair
    /// @dev Set to DEFAULT_CREATION_FEE in initialize (field initializers don't run behind a proxy)
    uint256 public creationFee;

    /// @notice Graduation threshold snapshotted into each new launch (owner-settable)
    /// @dev Changing it never affects live curves: each proxy stores the value at initialize().
    ///      Any value within the bounds satisfies the curve's economics asserts (verified for the
    ///      full [0.01 ether, 1000 ether] range).
    uint256 public graduationThreshold;

    /// @notice Partner fee in bps of the PROTOCOL half, snapshotted into each new launch
    ///         (owner-settable; defaults to 25%)
    /// @dev Changing it never affects live launches: the curve and the hook pool config store the
    ///      value at launch time, exactly like {graduationThreshold}. The partner is paid from
    ///      Bags's half of the trade fee, never from the creator half.
    uint16 public partnerFeeBps;

    // --- On-chain registry (integrator/indexer surface) ---
    /// @notice Bonding curve for a launched token
    mapping(address => address) public curveForToken;
    /// @notice FeeShare contract for a launched token
    mapping(address => address) public feeShareForToken;
    /// @notice Reverse lookup from v4 pool id to the launched token
    mapping(PoolId => address) public tokenForPoolId;
    /// @notice All tokens ever launched by this factory
    address[] public allTokens;

    /// @dev Reserved storage to allow appending variables in future upgrades
    uint256[50] private __gap;

    /// @notice Locks the implementation; all state is set via initialize() on the proxy
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initialize the factory proxy with chain infrastructure, templates, and beacons
    /// @param poolManager_ Uniswap v4 PoolManager address
    /// @param positionManager_ Uniswap v4 PositionManager address
    /// @param weth_ WETH address for the target chain
    /// @param vault_ Global Bags vault (proxy) address
    /// @param permit2_ Permit2 contract address
    /// @param hook_ Shared BagsV4Hook instance address
    /// @param tokenImpl_ BagsToken implementation address (clone template)
    /// @param feeShareBeacon_ Beacon for BagsFeeShare proxies
    /// @param bondingCurveBeacon_ Beacon for BagsBondingCurve proxies
    /// @param graduationThreshold_ Initial graduation threshold (net quote raise per launch)
    /// @param initialOwner Owner of the factory (upgrade + config authority, two-step transferable)
    function initialize(
        address poolManager_,
        address positionManager_,
        address weth_,
        address vault_,
        address permit2_,
        address hook_,
        address tokenImpl_,
        address feeShareBeacon_,
        address bondingCurveBeacon_,
        uint256 graduationThreshold_,
        address initialOwner
    ) external initializer {
        if (poolManager_ == address(0)) revert BagsFactory_ZeroAddressPoolManager();
        if (positionManager_ == address(0)) revert BagsFactory_ZeroAddressPositionManager();
        if (weth_ == address(0)) revert BagsFactory_ZeroAddressWETH();
        if (vault_ == address(0)) revert BagsFactory_ZeroAddressVault();
        if (permit2_ == address(0)) revert BagsFactory_ZeroAddressPermit2();
        if (hook_ == address(0)) revert BagsFactory_ZeroAddressHook();
        if (tokenImpl_ == address(0)) revert BagsFactory_ZeroAddressImpl();
        if (feeShareBeacon_ == address(0)) revert BagsFactory_ZeroAddressBeacon();
        if (bondingCurveBeacon_ == address(0)) revert BagsFactory_ZeroAddressBeacon();

        __Ownable_init(initialOwner);
        __Ownable2Step_init();
        __UUPSUpgradeable_init();

        poolManager = poolManager_;
        positionManager = positionManager_;
        weth = weth_;
        permit2 = permit2_;

        vault = BagsVault(payable(vault_));
        hook = BagsV4Hook(payable(hook_));

        tokenImpl = tokenImpl_;
        feeShareBeacon = feeShareBeacon_;
        bondingCurveBeacon = bondingCurveBeacon_;

        creationFee = DEFAULT_CREATION_FEE;
        _setGraduationThreshold(graduationThreshold_);
        _setPartnerFeeBps(DEFAULT_PARTNER_FEE_BPS);
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

    /// @notice Update the partner fee (bps of the protocol half) snapshotted into future launches
    /// @dev Bounds-checked; live launches keep the value they snapshotted at creation.
    /// @param newPartnerFeeBps New partner fee in bps (base 10_000, max 10_000)
    function setPartnerFeeBps(
        uint16 newPartnerFeeBps
    ) external override onlyOwner {
        _setPartnerFeeBps(newPartnerFeeBps);
    }

    /// @notice Update the shared hook wired into future launches
    /// @dev Only affects future launches: already-registered pools keep the hook they were
    ///      registered with. The new hook must authorize this factory via `setFactory`.
    /// @param newHook New shared BagsV4Hook address
    function setHook(
        address newHook
    ) external override onlyOwner {
        if (newHook == address(0)) revert BagsFactory_ZeroAddressHook();
        hook = BagsV4Hook(payable(newHook));
        emit HookUpdated(newHook);
    }

    /// @notice Update the BagsToken implementation cloned into future launches
    /// @dev Only affects future launches: existing tokens are immutable EIP-1167 clones and keep
    ///      the implementation they were deployed with.
    /// @param newTokenImpl New BagsToken implementation address
    function setTokenImpl(
        address newTokenImpl
    ) external override onlyOwner {
        if (newTokenImpl == address(0)) revert BagsFactory_ZeroAddressImpl();
        tokenImpl = newTokenImpl;
        emit TokenImplUpdated(newTokenImpl);
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
    /// @param partner Optional partner address; paid the current factory rate out of the
    ///        PROTOCOL half of every trade fee (never from the creator side)
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
        address[] calldata claimers,
        uint16[] calldata bps
    ) external payable override returns (address token, address curve) {
        if (msg.value < creationFee) {
            revert BagsFactory_InsufficientCreationFee(creationFee, msg.value);
        }
        (BagsToken deployedToken, BagsBondingCurve deployedCurve) =
            _deployPair(name, symbol, metadataURI, msg.sender, partner, claimers, bps);

        // Send only the creation fee to the vault, refund any surplus to sender
        (bool okFee,) = payable(address(vault)).call{value: creationFee}("");
        if (!okFee) revert BagsFactory_FeeTransferFailed(address(vault), creationFee);

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
    /// @param partner Optional partner address; paid the current factory rate out of the
    ///        PROTOCOL half of every trade fee (never from the creator side)
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
            _deployPair(name, symbol, metadataURI, msg.sender, partner, claimers, bps);

        // Pay creation fee to the vault
        (bool okFee,) = payable(address(vault)).call{value: creationFee}("");
        if (!okFee) revert BagsFactory_FeeTransferFailed(address(vault), creationFee);

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

    /// @dev Bounds-checks and stores the partner fee bps, emitting {PartnerFeeBpsUpdated}
    function _setPartnerFeeBps(
        uint16 newPartnerFeeBps
    ) internal {
        if (newPartnerFeeBps > MAX_PARTNER_FEE_BPS) {
            revert BagsFactory_InvalidPartnerFeeBps(newPartnerFeeBps);
        }
        uint16 oldPartnerFeeBps = partnerFeeBps;
        partnerFeeBps = newPartnerFeeBps;
        emit PartnerFeeBpsUpdated(oldPartnerFeeBps, newPartnerFeeBps);
    }

    /// @dev Builds the canonical PoolKey for a launched token. Must byte-match the key the curve
    ///      builds in `_migrate` (sorted token/WETH, dynamic fee flag, tick spacing 60, shared hook).
    /// @param token Launched token address
    /// @return key Canonical pool key for the token's migration pool
    function _poolKeyFor(
        address token
    ) internal view returns (PoolKey memory key) {
        address weth_ = weth;
        bool tokenIs0 = token < weth_;
        key = PoolKey({
            currency0: Currency.wrap(tokenIs0 ? token : weth_),
            currency1: Currency.wrap(tokenIs0 ? weth_ : token),
            fee: LPFeeLibrary.DYNAMIC_FEE_FLAG,
            tickSpacing: TICK_SPACING,
            hooks: IHooks(address(hook))
        });
    }

    /// @dev Internal helper to deploy the token (EIP-1167 clone) and the curve/fee share
    ///      (BeaconProxy each), mint, initialize, register the pool with the shared hook, and
    ///      populate the registry. Snapshots the current `partnerFeeBps` into the curve and the
    ///      hook pool config so the launch's partner economics are frozen at creation.
    function _deployPair(
        string calldata name,
        string calldata symbol,
        string calldata metadataURI,
        address creator,
        address partner,
        address[] memory claimers,
        uint16[] memory bps
    ) internal returns (BagsToken token, BagsBondingCurve curve) {
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

        // Clone and initialize BagsToken (tokens stay immutable EIP-1167 clones by design)
        token = BagsToken(Clones.clone(tokenImpl));
        token.initialize(name, symbol, metadataURI, address(this));

        // The pool id is deterministic as soon as the token address is known
        PoolId poolId = _poolKeyFor(address(token)).toId();

        // Snapshot the current partner rate: this launch's economics are frozen at creation and
        // never change when the factory default moves (same pattern as graduationThreshold).
        uint16 partnerFeeBps_ = partnerFeeBps;

        // Deploy and initialize the BagsFeeShare BeaconProxy, wired to the shared hook. Empty
        // constructor data keeps the two-step init flow: initialize() runs in this same tx, so
        // there is no front-run window. The factory is the temporary admin so it can call
        // setBondingCurve; ownership moves to the platform below (single-step by design).
        BagsFeeShare feeShare = BagsFeeShare(payable(address(new BeaconProxy(feeShareBeacon, ""))));
        feeShare.initialize(weth, address(this), partner, claimers, bps, address(hook), poolId);

        // Deploy and initialize the BagsBondingCurve BeaconProxy. The factory stays owner only
        // for initializeAfterMint; pause authority and the LP NFT go to the factory owner.
        curve = BagsBondingCurve(payable(address(new BeaconProxy(bondingCurveBeacon, ""))));
        curve.initialize(
            address(token),
            address(hook),
            address(this),
            creator,
            address(feeShare),
            owner(),
            partner,
            partnerFeeBps_,
            graduationThreshold
        );

        // Wire bonding curve into feeshare for pre-migration fee notifications,
        // then hand the fee share admin over to the platform (factory owner)
        feeShare.setBondingCurve(address(curve));
        feeShare.transferOwnership(owner());

        // Register the pool with the shared hook: authorizes the curve to initialize the pool,
        // routes the creator half of swept fees to the fee share, and snapshots the partner config
        // so pre- and post-graduation partner rates for this launch are identical by construction
        hook.register(poolId, address(curve), address(feeShare), partner, partnerFeeBps_);

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
            address(token), address(curve), creator, address(feeShare), partner, poolId, name, symbol, metadataURI
        );
    }

    /// @dev UUPS upgrade authorization: only the (two-step) owner may upgrade
    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}
}
