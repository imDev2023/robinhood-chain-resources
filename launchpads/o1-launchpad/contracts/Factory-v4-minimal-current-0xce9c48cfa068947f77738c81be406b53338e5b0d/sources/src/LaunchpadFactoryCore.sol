// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {IHooks} from "v4-core/src/interfaces/IHooks.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {PoolId} from "v4-core/src/types/PoolId.sol";
import {Currency} from "v4-core/src/types/Currency.sol";
import {TickMath} from "v4-core/src/libraries/TickMath.sol";
import {LiquidityAmounts} from "v4-core/test/utils/LiquidityAmounts.sol";

import {LaunchHook} from "./LaunchHook.sol";
import {AnnouncementRegistry} from "./AnnouncementRegistry.sol";
import {ICreatorRightsReceiver} from "./interfaces/ICreatorRightsReceiver.sol";
import {ILaunchTokenMetadata} from "./interfaces/ILaunchTokenMetadata.sol";
import {ILaunchBuyAdapter} from "./interfaces/ILaunchBuyAdapter.sol";

/// @title LaunchpadFactoryCore
/// @notice Shared genesis + governance for single-sided Uniswap v4 launchpads. Concrete factories provide the
///         token creation primitive while this core keeps quote registry, creator rights, pool creation, seed math,
///         locked-liquidity invariants, fee configuration, and event emission consistent across chains.
abstract contract LaunchpadFactoryCore is Ownable2Step, ReentrancyGuard {
    uint256 internal constant BPS = 10_000;
    uint8 internal constant TOKEN_DECIMALS = 18;
    /// @notice Sentinel `upperOffset` meaning "extend to the furthest usable tick on the token side".
    int24 internal constant TAIL = type(int24).max;

    uint256 public constant MIN_SUPPLY = 1_000_000e18;
    uint256 public constant MAX_SUPPLY = 1_000_000_000_000e18;
    uint256 public constant MAX_FEE_COMPONENTS = 20;
    uint256 internal constant MAX_BANDS = 10;
    uint256 internal constant MAX_LAUNCH_BUY_ROUTE_DATA_LENGTH = 4_096;
    bytes32 internal constant CREATOR_COMPONENT_ID = bytes32("CREATOR");
    bytes32 internal constant PLATFORM_COMPONENT_ID = bytes32("PLATFORM");
    bytes32 internal constant REFERRER_COMPONENT_ID = bytes32("REFERRER");

    IPoolManager public immutable poolManager;
    LaunchHook public immutable hook;

    /// @notice A registered quote. `startTickToken0Frame` is the opening tick assuming the launch token sorts
    ///         as currency0; it is negated at launch when the token is currency1. This single per-quote dial
    ///         folds in the quote's decimals + USD price, so each quote can open at a consistent market cap.
    struct QuoteConfig {
        bool registered;
        uint8 quoteDecimals;
        int24 startTickToken0Frame;
    }

    mapping(address quoteToken => QuoteConfig config) internal _quoteConfig;

    /// @notice A band of the single-sided seed, as tick offsets from the start tick on the token side
    ///         (`lowerOffset` nearer spot, `upperOffset` farther; `TAIL` = to the usable edge) plus a share
    ///         of supply in bps. Reused across every quote; each launch freezes the template it used.
    struct Band {
        int24 lowerOffset;
        int24 upperOffset;
        uint16 supplyShareBps;
    }

    Band[] internal _bandTemplate;

    enum FeeRecipientKind {
        CREATOR,
        PLATFORM,
        REFERRER,
        FIXED
    }

    struct FeeComponent {
        bytes32 componentId;
        FeeRecipientKind recipientKind;
        address configuredRecipient;
        uint16 feeBps;
    }

    struct FeeConfiguration {
        uint16 baseFeeBps;
        uint16 antiSnipeStartTotalBps;
        uint32 antiSnipeWindowSeconds;
        FeeComponent[] feeComponents;
    }

    uint16 public baseFeeBps;
    uint16 public antiSnipeStartTotalBps;
    uint32 public antiSnipeWindowSeconds;
    address internal _platformFeeRecipient;
    FeeComponent[] internal _feeComponents;

    struct CreatorRights {
        address originalCreator;
        address currentCreator;
        address pendingCreator;
        address creatorFeeRecipient;
        PoolId poolId;
        bool metadataEditable;
    }

    mapping(address token => CreatorRights rights) internal _creatorRights;
    address public creatorAdmin;
    address public pendingCreatorAdmin;

    uint256 public launchSupply;
    int24 public tickSpacing;
    uint256 public nativeLaunchFee;
    address public announcementRegistry;
    uint64 public configVersion = 1;
    mapping(bytes32 scopedSalt => bool used) public isLaunchSaltUsed;

    struct LaunchParams {
        string tokenName;
        string tokenSymbol;
        string tokenContractURI;
        bytes32 creatorSalt;
        address quoteToken;
        uint64 expectedConfigVersion;
        uint64 deadline;
        bool metadataEditable;
        string[] metadataKeys;
        string[] metadataValues;
    }

    struct LaunchBuyParams {
        address fundingToken;
        uint256 amountIn;
        uint256 minAmountOut;
        bytes routeData;
    }

    struct LaunchPreparation {
        uint256 supply;
        bytes32 scopedSalt;
        address predictedToken;
        bool tokenIsCurrency0;
        int24 spacing;
        int24 startTick;
        LaunchHook.SeedPosition[] seedPositions;
    }

    event QuoteRegistered(address indexed quoteToken, uint8 quoteDecimals, int24 startTickToken0Frame, uint64 revision);
    event QuoteStartTickUpdated(
        address indexed quoteToken, int24 previousStartTickToken0Frame, int24 newStartTickToken0Frame, uint64 revision
    );
    event QuoteUnregistered(address indexed quoteToken, uint64 revision);
    event BandTemplateUpdated(uint256 bandCount);
    event FeeConfigurationUpdated(
        uint64 indexed configVersion, uint16 baseFeeBps, uint16 antiSnipeStartTotalBps, uint32 antiSnipeWindowSeconds
    );
    event FeeComponentConfigured(
        uint64 indexed configVersion,
        uint8 indexed componentIndex,
        bytes32 indexed componentId,
        FeeRecipientKind recipientKind,
        address configuredRecipient,
        uint16 feeBps
    );
    event LaunchSupplyUpdated(uint256 previousLaunchSupply, uint256 newLaunchSupply);
    event TickSpacingUpdated(int24 previousTickSpacing, int24 newTickSpacing);
    event AnnouncementRegistrySet(address indexed announcementRegistry);
    event LaunchBuyAdapterUpdated(address indexed previousLaunchBuyAdapter, address indexed newLaunchBuyAdapter);
    event ConfigVersionUpdated(uint64 newConfigVersion);
    event Launched(
        address indexed token,
        PoolId indexed poolId,
        address indexed originalCreator,
        address quoteToken,
        uint256 launchSupply,
        int24 tickSpacing
    );
    event NativeLaunchFeePaid(address indexed payer, address indexed recipient, uint256 amount);
    event NativeLaunchFeeUpdated(uint256 previousNativeLaunchFee, uint256 newNativeLaunchFee);
    event LaunchBuyExecuted(
        address indexed token,
        PoolId indexed poolId,
        address indexed originalCreator,
        address fundingToken,
        uint256 amountIn,
        uint256 amountOut,
        address launchBuyAdapter
    );
    event CreatorRightsTransferProposed(
        address indexed token, address indexed currentCreator, address indexed pendingCreator
    );
    event CreatorRightsTransferCancelled(
        address indexed token, address indexed currentCreator, address indexed cancelledPendingCreator
    );
    event CreatorRightsTransferred(
        address indexed token,
        address indexed previousCreator,
        address indexed newCreator,
        address previousCreatorFeeRecipient,
        address newCreatorFeeRecipient
    );
    event CreatorFeeRecipientUpdated(
        address indexed token, address indexed previousCreatorFeeRecipient, address indexed newCreatorFeeRecipient
    );
    event CreatorAdminTransferStarted(address indexed currentCreatorAdmin, address indexed pendingCreatorAdmin);
    event CreatorAdminTransferCancelled(
        address indexed currentCreatorAdmin, address indexed cancelledPendingCreatorAdmin
    );
    event CreatorAdminTransferred(address indexed previousCreatorAdmin, address indexed newCreatorAdmin);
    event CreatorAdminRevoked(address indexed previousCreatorAdmin);
    event CreatorRightsReassigned(
        address indexed token,
        address indexed previousCreator,
        address indexed newCreator,
        address previousCreatorFeeRecipient,
        address newCreatorFeeRecipient,
        address creatorAdmin
    );

    error InvalidConfig();
    error EmptyTokenNameOrSymbol();
    error QuoteNotRegistered();
    error QuoteAlreadyRegistered();
    error OutOfBounds();
    error TokenMismatch();
    error MisalignedOffset();
    error NotImmutable();
    error LaunchSaltUsed(bytes32 scopedSalt);
    error StaleConfig(uint64 expectedConfigVersion, uint64 actualConfigVersion);
    error LaunchExpired(uint64 deadline);
    error InvalidNativeLaunchFeePayment();
    error NativeLaunchFeeTransferFailed();
    error UnknownLaunchToken();
    error NotCurrentCreator();
    error NotPendingCreator();
    error NotCreatorAdmin();
    error NotPendingCreatorAdmin();
    error UnsafeOwnershipRenunciation();
    error InvalidCreatorRightsReceiver();
    error MetadataNotEditable();
    error LaunchBuyAdapterNotConfigured();
    error InvalidLaunchBuyParams();
    error InvalidLaunchBuyPayment(uint256 expectedValue, uint256 actualValue);

    /// @notice Genesis economics supplied explicitly at deploy. Each field is validated with the same logic as
    ///         its governance setter and stays tunable for future launches.
    struct FactoryInitialization {
        uint256 launchSupply;
        int24 tickSpacing;
        FeeConfiguration feeConfiguration;
        Band[] bandTemplate;
    }

    constructor(
        IPoolManager poolManagerAddress,
        LaunchHook launchHook,
        FactoryInitialization memory initialFactoryConfiguration
    ) Ownable(msg.sender) {
        if (
            address(poolManagerAddress) == address(0) || address(poolManagerAddress).code.length == 0
                || address(launchHook) == address(0) || address(launchHook).code.length == 0
                || address(launchHook.poolManager()) != address(poolManagerAddress)
        ) revert InvalidConfig();
        poolManager = poolManagerAddress;
        hook = launchHook;
        _setLaunchSupply(initialFactoryConfiguration.launchSupply);
        _applyTickSpacing(initialFactoryConfiguration.tickSpacing);
        _applyFeeConfiguration(initialFactoryConfiguration.feeConfiguration);
        _applyBandTemplate(initialFactoryConfiguration.bandTemplate);
        _emitFeeConfiguration();
    }

    // ============================================================
    //                          CREATE
    // ============================================================

    function createLaunch(LaunchParams calldata launchParams)
        external
        payable
        nonReentrant
        returns (address token, PoolId poolId)
    {
        if (msg.value != nativeLaunchFee) revert InvalidNativeLaunchFeePayment();
        LaunchPreparation memory preparation = _prepareLaunch(launchParams, msg.sender);
        _payNativeLaunchFee(msg.sender);
        (token, poolId,) = _createLaunch(launchParams, msg.sender, preparation);
    }

    function createLaunchAndBuy(LaunchParams calldata launchParams, LaunchBuyParams calldata launchBuyParams)
        external
        payable
        nonReentrant
        returns (address token, PoolId poolId, uint256 amountOut)
    {
        address adapter = hook.launchBuyAdapter();
        if (adapter == address(0)) revert LaunchBuyAdapterNotConfigured();
        if (
            launchBuyParams.amountIn == 0 || launchBuyParams.minAmountOut == 0 || launchBuyParams.routeData.length == 0
                || launchBuyParams.routeData.length > MAX_LAUNCH_BUY_ROUTE_DATA_LENGTH
        ) revert InvalidLaunchBuyParams();

        address fundingToken = launchBuyParams.fundingToken;
        uint256 expectedValue = nativeLaunchFee;
        if (fundingToken == address(0)) {
            expectedValue += launchBuyParams.amountIn;
        } else if (fundingToken.code.length == 0) {
            revert InvalidLaunchBuyParams();
        }
        if (msg.value != expectedValue) revert InvalidLaunchBuyPayment(expectedValue, msg.value);

        LaunchPreparation memory preparation = _prepareLaunch(launchParams, msg.sender);
        PoolKey memory poolKey;
        (token, poolId, poolKey) = _createLaunch(launchParams, msg.sender, preparation);
        if (fundingToken == token) revert InvalidLaunchBuyParams();

        ILaunchBuyAdapter.LaunchBuyRequest memory request = ILaunchBuyAdapter.LaunchBuyRequest({
            originalCreator: msg.sender,
            launchToken: token,
            quoteToken: launchParams.quoteToken,
            poolKey: poolKey,
            fundingToken: fundingToken,
            amountIn: launchBuyParams.amountIn,
            minAmountOut: launchBuyParams.minAmountOut,
            deadline: launchParams.deadline,
            routeData: launchBuyParams.routeData
        });
        uint256 valueForAdapter = fundingToken == address(0) ? launchBuyParams.amountIn : 0;
        amountOut = hook.executeLaunchBuy{value: valueForAdapter}(poolId, request);
        _payNativeLaunchFee(msg.sender);

        emit LaunchBuyExecuted(token, poolId, msg.sender, fundingToken, launchBuyParams.amountIn, amountOut, adapter);
    }

    function _createLaunch(
        LaunchParams calldata launchParams,
        address originalCreator,
        LaunchPreparation memory preparation
    ) internal returns (address token, PoolId poolId, PoolKey memory poolKey) {
        token = _createToken(launchParams, preparation.scopedSalt, preparation.supply);
        if (token != preparation.predictedToken) revert TokenMismatch();
        _assertLaunchToken(token, originalCreator, launchParams.metadataEditable);

        poolKey = _buildPoolKey(launchParams.quoteToken, token, preparation.tokenIsCurrency0, preparation.spacing);
        poolId = _openAndSeed(
            poolKey, preparation.tokenIsCurrency0, preparation.startTick, preparation.seedPositions, originalCreator
        );

        _creatorRights[token] = CreatorRights({
            originalCreator: originalCreator,
            currentCreator: originalCreator,
            pendingCreator: address(0),
            creatorFeeRecipient: originalCreator,
            poolId: poolId,
            metadataEditable: launchParams.metadataEditable
        });

        AnnouncementRegistry(announcementRegistry).registerToken(token);
        emit Launched(token, poolId, originalCreator, launchParams.quoteToken, preparation.supply, preparation.spacing);
    }

    function _prepareLaunch(LaunchParams calldata launchParams, address originalCreator)
        internal
        returns (LaunchPreparation memory preparation)
    {
        if (launchParams.expectedConfigVersion != configVersion) {
            revert StaleConfig(launchParams.expectedConfigVersion, configVersion);
        }
        // forge-lint: disable-next-line(block-timestamp) user-supplied transaction expiry, not economic timing
        if (block.timestamp > launchParams.deadline) revert LaunchExpired(launchParams.deadline);
        if (bytes(launchParams.tokenName).length == 0 || bytes(launchParams.tokenSymbol).length == 0) {
            revert EmptyTokenNameOrSymbol();
        }
        if (!_quoteConfig[launchParams.quoteToken].registered) revert QuoteNotRegistered();
        if (launchParams.metadataKeys.length != launchParams.metadataValues.length) revert InvalidConfig();
        for (uint256 i = 0; i < launchParams.metadataKeys.length; i++) {
            if (bytes(launchParams.metadataKeys[i]).length == 0) revert InvalidConfig();
        }

        _beforeCreateLaunch(launchParams);

        preparation.supply = launchSupply;
        preparation.scopedSalt = keccak256(abi.encode(originalCreator, launchParams.creatorSalt));
        if (isLaunchSaltUsed[preparation.scopedSalt]) revert LaunchSaltUsed(preparation.scopedSalt);
        isLaunchSaltUsed[preparation.scopedSalt] = true;
        preparation.predictedToken = _predictTokenAddress(launchParams, preparation.scopedSalt, preparation.supply);
        _validatePredictedToken(preparation.predictedToken);
        preparation.tokenIsCurrency0 = uint160(preparation.predictedToken) < uint160(launchParams.quoteToken);
        preparation.spacing = tickSpacing;
        preparation.startTick =
            _resolveAlignedStartTick(launchParams.quoteToken, preparation.tokenIsCurrency0, preparation.spacing);
        preparation.seedPositions = _resolveSeedPositions(
            preparation.startTick, preparation.spacing, preparation.tokenIsCurrency0, preparation.supply
        );
    }

    function _payNativeLaunchFee(address payer) internal {
        uint256 amount = nativeLaunchFee;
        if (amount == 0) return;
        (bool success,) = payable(_platformFeeRecipient).call{value: amount}("");
        if (!success) revert NativeLaunchFeeTransferFailed();
        emit NativeLaunchFeePaid(payer, _platformFeeRecipient, amount);
    }

    function _beforeCreateLaunch(LaunchParams calldata launchParams) internal view virtual;

    function _predictTokenAddress(LaunchParams calldata launchParams, bytes32 scopedSalt, uint256 currentLaunchSupply)
        internal
        view
        virtual
        returns (address predictedToken);

    function _createToken(LaunchParams calldata launchParams, bytes32 scopedSalt, uint256 currentLaunchSupply)
        internal
        virtual
        returns (address token);

    function _assertLaunchToken(address token, address creatorAccount, bool metadataEditable) internal view virtual;

    function _validatePredictedToken(address) internal view virtual {}

    function _buildPoolKey(address quoteToken, address token, bool tokenIsCurrency0, int24 spacing)
        internal
        view
        returns (PoolKey memory key)
    {
        (Currency c0, Currency c1) = tokenIsCurrency0
            ? (Currency.wrap(token), Currency.wrap(quoteToken))
            : (Currency.wrap(quoteToken), Currency.wrap(token));
        key = PoolKey({currency0: c0, currency1: c1, fee: 0, tickSpacing: spacing, hooks: IHooks(address(hook))});
    }

    function _openAndSeed(
        PoolKey memory key,
        bool tokenIsCurrency0,
        int24 startTick,
        LaunchHook.SeedPosition[] memory positions,
        address originalCreator
    ) internal returns (PoolId poolId) {
        int24 initTick = tokenIsCurrency0 ? startTick - key.tickSpacing : startTick;
        if (initTick < TickMath.MIN_TICK || initTick > TickMath.MAX_TICK) revert OutOfBounds();
        poolManager.initialize(key, TickMath.getSqrtPriceAtTick(initTick));

        hook.registerPool(key, _buildPoolConfig(tokenIsCurrency0, originalCreator), _buildHookFeeComponents());
        hook.seedLiquidity(key, positions, tokenIsCurrency0);

        poolId = key.toId();
    }

    function _buildPoolConfig(bool tokenIsCurrency0, address originalCreator)
        internal
        view
        returns (LaunchHook.PoolConfig memory)
    {
        return LaunchHook.PoolConfig({
            initialized: false,
            tokenIsCurrency0: tokenIsCurrency0,
            currentCreator: originalCreator,
            creatorFeeRecipient: originalCreator,
            baseFeeBps: baseFeeBps,
            antiSnipeStartTotalBps: antiSnipeStartTotalBps,
            antiSnipeWindowSeconds: antiSnipeWindowSeconds,
            launchTime: uint48(block.timestamp)
        });
    }

    function _buildHookFeeComponents() internal view returns (LaunchHook.FeeComponent[] memory components) {
        uint256 n = _feeComponents.length;
        components = new LaunchHook.FeeComponent[](n);
        for (uint256 i = 0; i < n; i++) {
            FeeComponent storage component = _feeComponents[i];
            components[i] = LaunchHook.FeeComponent({
                componentId: component.componentId,
                recipientKind: LaunchHook.FeeRecipientKind(uint8(component.recipientKind)),
                configuredRecipient: component.configuredRecipient,
                feeBps: component.feeBps
            });
        }
    }

    function _resolveAlignedStartTick(address quoteToken, bool tokenIsCurrency0, int24 spacing)
        internal
        view
        returns (int24)
    {
        int24 frame = _quoteConfig[quoteToken].startTickToken0Frame;
        int24 startTick = tokenIsCurrency0 ? frame : -frame;
        // forge-lint: disable-next-line(divide-before-multiply) the truncation IS the alignment
        return (startTick / spacing) * spacing;
    }

    /// @notice Resolve the band template into absolute positions for this launch's ordering and supply.
    function _resolveSeedPositions(int24 startTick, int24 spacing, bool tokenIsCurrency0, uint256 supply)
        internal
        view
        returns (LaunchHook.SeedPosition[] memory positions)
    {
        Band[] memory tmpl = _bandTemplate;
        positions = new LaunchHook.SeedPosition[](tmpl.length);
        // forge-lint: disable-next-line(divide-before-multiply) the truncation IS the alignment
        int24 maxUsable = (TickMath.MAX_TICK / spacing) * spacing;
        // forge-lint: disable-next-line(divide-before-multiply) the truncation IS the alignment
        int24 minUsable = (TickMath.MIN_TICK / spacing) * spacing;

        for (uint256 i = 0; i < tmpl.length; i++) {
            if (tmpl[i].lowerOffset % spacing != 0) revert MisalignedOffset();
            if (tmpl[i].upperOffset != TAIL && tmpl[i].upperOffset % spacing != 0) revert MisalignedOffset();

            int24 tickLower;
            int24 tickUpper;
            if (tokenIsCurrency0) {
                tickLower = startTick + tmpl[i].lowerOffset;
                tickUpper = tmpl[i].upperOffset == TAIL ? maxUsable : startTick + tmpl[i].upperOffset;
            } else {
                tickUpper = startTick - tmpl[i].lowerOffset;
                tickLower = tmpl[i].upperOffset == TAIL ? minUsable : startTick - tmpl[i].upperOffset;
            }
            if (tickLower >= tickUpper) revert OutOfBounds();

            uint256 amount = supply * tmpl[i].supplyShareBps / BPS;
            uint160 sqrtA = TickMath.getSqrtPriceAtTick(tickLower);
            uint160 sqrtB = TickMath.getSqrtPriceAtTick(tickUpper);
            uint128 liquidity = tokenIsCurrency0
                ? LiquidityAmounts.getLiquidityForAmount0(sqrtA, sqrtB, amount)
                : LiquidityAmounts.getLiquidityForAmount1(sqrtA, sqrtB, amount);
            if (liquidity == 0 || liquidity >= uint128(type(int128).max)) revert OutOfBounds();

            positions[i] = LaunchHook.SeedPosition({tickLower: tickLower, tickUpper: tickUpper, liquidity: liquidity});
        }
    }

    // ============================================================
    //                       GOVERNANCE (future launches only)
    // ============================================================

    function setBandTemplate(Band[] calldata newBandTemplate) external onlyOwner nonReentrant {
        _applyBandTemplate(newBandTemplate);
        _bumpConfigVersion();
    }

    /// @dev Validate + store the seed band template. Shared by the constructor and the governance setter.
    function _applyBandTemplate(Band[] memory newBands) internal {
        if (newBands.length == 0 || newBands.length > MAX_BANDS) revert OutOfBounds();
        if (newBands[0].lowerOffset != 0) revert InvalidConfig();
        uint256 totalBps;
        int24 spacing = tickSpacing;
        for (uint256 i = 0; i < newBands.length; i++) {
            bool isTail = newBands[i].upperOffset == TAIL;
            if (
                newBands[i].lowerOffset < 0 || newBands[i].supplyShareBps == 0 || (isTail && i != newBands.length - 1)
                    || (!isTail && newBands[i].upperOffset <= newBands[i].lowerOffset)
            ) {
                revert InvalidConfig();
            }
            if (newBands[i].lowerOffset % spacing != 0 || (!isTail && newBands[i].upperOffset % spacing != 0)) {
                revert MisalignedOffset();
            }
            totalBps += newBands[i].supplyShareBps;
        }
        if (totalBps != BPS) revert InvalidConfig();
        delete _bandTemplate;
        for (uint256 i = 0; i < newBands.length; i++) {
            _bandTemplate.push(newBands[i]);
        }
        emit BandTemplateUpdated(newBands.length);
    }

    // ============================================================
    //                       CREATOR RIGHTS
    // ============================================================

    function creatorRights(address token) external view returns (CreatorRights memory rights) {
        rights = _creatorRights[token];
        if (rights.originalCreator == address(0)) revert UnknownLaunchToken();
    }

    function currentCreatorOf(address token) external view returns (address currentCreator) {
        currentCreator = _creatorRights[token].currentCreator;
        if (currentCreator == address(0)) revert UnknownLaunchToken();
    }

    function transferCreatorAdmin(address newCreatorAdmin) external onlyOwner nonReentrant {
        _validateCreatorAdminAddress(newCreatorAdmin);
        if (newCreatorAdmin == pendingCreatorAdmin) return;
        pendingCreatorAdmin = newCreatorAdmin;
        emit CreatorAdminTransferStarted(creatorAdmin, newCreatorAdmin);
    }

    function acceptCreatorAdmin() external nonReentrant {
        address pending = pendingCreatorAdmin;
        if (msg.sender != pending || pending == address(0)) revert NotPendingCreatorAdmin();
        address previous = creatorAdmin;
        creatorAdmin = pending;
        pendingCreatorAdmin = address(0);
        emit CreatorAdminTransferred(previous, pending);
    }

    function cancelCreatorAdminTransfer() external onlyOwner nonReentrant {
        address pending = pendingCreatorAdmin;
        if (pending == address(0)) return;
        pendingCreatorAdmin = address(0);
        emit CreatorAdminTransferCancelled(creatorAdmin, pending);
    }

    function revokeCreatorAdmin() external onlyOwner nonReentrant {
        address previousCreatorAdmin = creatorAdmin;
        address cancelledPendingCreatorAdmin = pendingCreatorAdmin;
        if (previousCreatorAdmin == address(0) && cancelledPendingCreatorAdmin == address(0)) return;
        creatorAdmin = address(0);
        pendingCreatorAdmin = address(0);
        if (cancelledPendingCreatorAdmin != address(0)) {
            emit CreatorAdminTransferCancelled(previousCreatorAdmin, cancelledPendingCreatorAdmin);
        }
        if (previousCreatorAdmin != address(0)) emit CreatorAdminRevoked(previousCreatorAdmin);
    }

    function adminReassignCreatorRights(address token, address newCreator, address newCreatorFeeRecipient)
        external
        nonReentrant
    {
        if (msg.sender != creatorAdmin || msg.sender == address(0)) revert NotCreatorAdmin();
        CreatorRights storage rights = _requireCreatorRights(token);
        _validateCreatorRightsAddress(token, newCreator);
        _validateCreatorRightsAddress(token, newCreatorFeeRecipient);
        address previousCreator = rights.currentCreator;
        if (newCreator == previousCreator) revert InvalidConfig();
        address previousCreatorFeeRecipient = rights.creatorFeeRecipient;
        _applyCreatorRightsTransition(rights, newCreator, newCreatorFeeRecipient);
        emit CreatorRightsReassigned(
            token, previousCreator, newCreator, previousCreatorFeeRecipient, newCreatorFeeRecipient, msg.sender
        );
    }

    function proposeCreatorRightsTransfer(address token, address newCreator) external nonReentrant {
        CreatorRights storage rights = _requireCurrentCreator(token);
        _validateCreatorRightsAddress(token, newCreator);
        if (newCreator == rights.currentCreator) revert InvalidConfig();
        if (newCreator == rights.pendingCreator) return;
        rights.pendingCreator = newCreator;
        emit CreatorRightsTransferProposed(token, rights.currentCreator, newCreator);
    }

    function cancelCreatorRightsTransfer(address token) external nonReentrant {
        CreatorRights storage rights = _requireCurrentCreator(token);
        address pending = rights.pendingCreator;
        if (pending == address(0)) return;
        rights.pendingCreator = address(0);
        emit CreatorRightsTransferCancelled(token, rights.currentCreator, pending);
    }

    function acceptCreatorRightsTransfer(address token) external nonReentrant {
        CreatorRights storage rights = _requireCreatorRights(token);
        if (msg.sender != rights.pendingCreator || msg.sender == address(0)) revert NotPendingCreator();
        _transitionCreatorRights(token, rights, msg.sender, msg.sender);
    }

    function setCreatorFeeRecipient(address token, address newCreatorFeeRecipient) external nonReentrant {
        CreatorRights storage rights = _requireCurrentCreator(token);
        _validateCreatorRightsAddress(token, newCreatorFeeRecipient);
        address previousCreatorFeeRecipient = rights.creatorFeeRecipient;
        if (previousCreatorFeeRecipient == newCreatorFeeRecipient) return;
        rights.creatorFeeRecipient = newCreatorFeeRecipient;
        hook.updateCreatorRights(rights.poolId, rights.currentCreator, newCreatorFeeRecipient);
        emit CreatorFeeRecipientUpdated(token, previousCreatorFeeRecipient, newCreatorFeeRecipient);
    }

    function safeTransferCreatorRights(address token, address rightsReceiver, bytes calldata callbackData)
        external
        payable
        nonReentrant
    {
        CreatorRights storage rights = _requireCurrentCreator(token);
        _validateCreatorRightsAddress(token, rightsReceiver);
        if (rightsReceiver == rights.currentCreator || rightsReceiver.code.length == 0) {
            revert InvalidCreatorRightsReceiver();
        }
        address previousCreator = rights.currentCreator;
        _transitionCreatorRights(token, rights, rightsReceiver, rightsReceiver);
        bytes4 selector = ICreatorRightsReceiver(rightsReceiver).onCreatorRightsReceived{value: msg.value}(
            previousCreator, token, callbackData
        );
        if (selector != ICreatorRightsReceiver.onCreatorRightsReceived.selector) {
            revert InvalidCreatorRightsReceiver();
        }
    }

    function updateTokenName(address token, string calldata newName) external nonReentrant {
        _requireMetadataEditor(token);
        ILaunchTokenMetadata(token).updateName(newName);
    }

    function updateTokenSymbol(address token, string calldata newSymbol) external nonReentrant {
        _requireMetadataEditor(token);
        ILaunchTokenMetadata(token).updateSymbol(newSymbol);
    }

    function updateTokenContractURI(address token, string calldata newContractURI) external nonReentrant {
        _requireMetadataEditor(token);
        ILaunchTokenMetadata(token).updateContractURI(newContractURI);
    }

    function updateTokenExtraMetadata(address token, string calldata metadataKey, string calldata metadataValue)
        external
        nonReentrant
    {
        _requireMetadataEditor(token);
        ILaunchTokenMetadata(token).updateExtraMetadata(metadataKey, metadataValue);
    }

    function _transitionCreatorRights(
        address token,
        CreatorRights storage rights,
        address newCreator,
        address newCreatorFeeRecipient
    ) internal {
        address previousCreator = rights.currentCreator;
        address previousCreatorFeeRecipient = rights.creatorFeeRecipient;
        _applyCreatorRightsTransition(rights, newCreator, newCreatorFeeRecipient);
        emit CreatorRightsTransferred(
            token, previousCreator, newCreator, previousCreatorFeeRecipient, newCreatorFeeRecipient
        );
    }

    function _applyCreatorRightsTransition(
        CreatorRights storage rights,
        address newCreator,
        address newCreatorFeeRecipient
    ) internal {
        rights.currentCreator = newCreator;
        rights.creatorFeeRecipient = newCreatorFeeRecipient;
        rights.pendingCreator = address(0);
        hook.updateCreatorRights(rights.poolId, newCreator, newCreatorFeeRecipient);
    }

    function _requireCreatorRights(address token) internal view returns (CreatorRights storage rights) {
        rights = _creatorRights[token];
        if (rights.originalCreator == address(0)) revert UnknownLaunchToken();
    }

    function _requireCurrentCreator(address token) internal view returns (CreatorRights storage rights) {
        rights = _requireCreatorRights(token);
        if (msg.sender != rights.currentCreator) revert NotCurrentCreator();
    }

    function _requireMetadataEditor(address token) internal view {
        CreatorRights storage rights = _requireCurrentCreator(token);
        if (!rights.metadataEditable) revert MetadataNotEditable();
    }

    function _validateCreatorRightsAddress(address token, address account) internal view {
        if (
            account == address(0) || account == token || account == address(this) || account == address(hook)
                || account == address(poolManager) || account == hook.feeEscrow() || account == announcementRegistry
        ) revert InvalidConfig();
    }

    function _validateCreatorAdminAddress(address newCreatorAdmin) internal view {
        if (newCreatorAdmin == creatorAdmin || _creatorRights[newCreatorAdmin].originalCreator != address(0)) {
            revert InvalidConfig();
        }
        _validateCreatorRightsAddress(address(0), newCreatorAdmin);
    }

    function setFeeConfiguration(FeeConfiguration calldata newConfiguration) external onlyOwner nonReentrant {
        _applyFeeConfiguration(newConfiguration);
        _bumpConfigVersion();
        _emitFeeConfiguration();
    }

    /// @dev Validate + store the fee configuration. Shared by the constructor and governance setter.
    function _applyFeeConfiguration(FeeConfiguration memory newConfiguration) internal {
        if (newConfiguration.baseFeeBps > hook.MAX_BASE_FEE_BPS()) revert OutOfBounds();
        uint256 componentCount = newConfiguration.feeComponents.length;
        if (newConfiguration.baseFeeBps == 0 || componentCount < 3 || componentCount > MAX_FEE_COMPONENTS) {
            revert InvalidConfig();
        }
        if (
            newConfiguration.antiSnipeStartTotalBps < newConfiguration.baseFeeBps
                || newConfiguration.antiSnipeStartTotalBps > hook.MAX_TOTAL_FEE_BPS()
        ) {
            revert OutOfBounds();
        }
        if (newConfiguration.antiSnipeWindowSeconds == 0) revert InvalidConfig();

        uint256 totalBps;
        bool creatorFound;
        bool platformFound;
        bool referrerFound;
        bytes32 previousId;
        delete _feeComponents;
        for (uint256 i = 0; i < componentCount; i++) {
            FeeComponent memory component = newConfiguration.feeComponents[i];
            if (component.componentId == bytes32(0) || component.componentId <= previousId || component.feeBps == 0) {
                revert InvalidConfig();
            }

            if (component.recipientKind == FeeRecipientKind.CREATOR) {
                if (
                    creatorFound || component.componentId != CREATOR_COMPONENT_ID
                        || component.configuredRecipient != address(0)
                ) {
                    revert InvalidConfig();
                }
                creatorFound = true;
            } else if (component.recipientKind == FeeRecipientKind.PLATFORM) {
                if (platformFound || component.componentId != PLATFORM_COMPONENT_ID) revert InvalidConfig();
                _validateConfiguredFeeRecipient(component.configuredRecipient);
                _platformFeeRecipient = component.configuredRecipient;
                platformFound = true;
            } else if (component.recipientKind == FeeRecipientKind.REFERRER) {
                if (
                    referrerFound || component.componentId != REFERRER_COMPONENT_ID
                        || component.configuredRecipient != address(0)
                ) {
                    revert InvalidConfig();
                }
                referrerFound = true;
            } else {
                if (
                    component.componentId == CREATOR_COMPONENT_ID || component.componentId == PLATFORM_COMPONENT_ID
                        || component.componentId == REFERRER_COMPONENT_ID
                ) revert InvalidConfig();
                _validateConfiguredFeeRecipient(component.configuredRecipient);
            }

            totalBps += component.feeBps;
            previousId = component.componentId;
            _feeComponents.push(component);
        }

        if (totalBps != newConfiguration.baseFeeBps || !creatorFound || !platformFound || !referrerFound) {
            revert InvalidConfig();
        }

        baseFeeBps = newConfiguration.baseFeeBps;
        antiSnipeStartTotalBps = newConfiguration.antiSnipeStartTotalBps;
        antiSnipeWindowSeconds = newConfiguration.antiSnipeWindowSeconds;
    }

    function feeComponentCount() external view returns (uint256 componentCount) {
        return _feeComponents.length;
    }

    function feeComponents(uint256 componentIndex)
        external
        view
        returns (bytes32 componentId, FeeRecipientKind recipientKind, address configuredRecipient, uint16 feeBps)
    {
        FeeComponent storage component = _feeComponents[componentIndex];
        return (component.componentId, component.recipientKind, component.configuredRecipient, component.feeBps);
    }

    function platformFeeRecipient() external view returns (address recipient) {
        return _platformFeeRecipient;
    }

    function quoteConfig(address quoteToken)
        external
        view
        returns (bool registered, uint8 quoteDecimals, int24 startTickToken0Frame)
    {
        QuoteConfig storage configuration = _quoteConfig[quoteToken];
        return (configuration.registered, configuration.quoteDecimals, configuration.startTickToken0Frame);
    }

    function _emitFeeConfiguration() internal {
        emit FeeConfigurationUpdated(configVersion, baseFeeBps, antiSnipeStartTotalBps, antiSnipeWindowSeconds);
        for (uint256 i = 0; i < _feeComponents.length; i++) {
            FeeComponent storage component = _feeComponents[i];
            // forge-lint: disable-next-line(unsafe-typecast) component count is capped at 20
            uint8 componentIndex = uint8(i);
            emit FeeComponentConfigured(
                configVersion,
                componentIndex,
                component.componentId,
                component.recipientKind,
                component.configuredRecipient,
                component.feeBps
            );
        }
    }

    function _validateConfiguredFeeRecipient(address configuredRecipient) internal view {
        if (
            configuredRecipient == address(0) || configuredRecipient == address(this)
                || configuredRecipient == address(hook) || configuredRecipient == address(poolManager)
                || configuredRecipient == hook.feeEscrow()
        ) revert InvalidConfig();
    }

    function setLaunchSupply(uint256 newLaunchSupply) external onlyOwner nonReentrant {
        if (newLaunchSupply == launchSupply) return;
        _setLaunchSupply(newLaunchSupply);
        _bumpConfigVersion();
    }

    function setTickSpacing(int24 newTickSpacing) external onlyOwner nonReentrant {
        if (newTickSpacing == tickSpacing) return;
        _applyTickSpacing(newTickSpacing);
        _bumpConfigVersion();
    }

    /// @dev Validate + store the tick spacing. Shared by the constructor and the governance setter.
    function _applyTickSpacing(int24 spacing) internal {
        if (spacing <= 0 || spacing > 16_384) revert OutOfBounds();
        for (uint256 i = 0; i < _bandTemplate.length; i++) {
            if (
                _bandTemplate[i].lowerOffset % spacing != 0
                    || (_bandTemplate[i].upperOffset != TAIL && _bandTemplate[i].upperOffset % spacing != 0)
            ) revert MisalignedOffset();
        }
        emit TickSpacingUpdated(tickSpacing, spacing);
        tickSpacing = spacing;
    }

    function setAnnouncementRegistry(address newAnnouncementRegistry) external onlyOwner nonReentrant {
        if (announcementRegistry != address(0)) revert InvalidConfig();
        if (
            newAnnouncementRegistry == address(0) || newAnnouncementRegistry.code.length == 0
                || AnnouncementRegistry(newAnnouncementRegistry).factory() != address(this)
        ) {
            revert InvalidConfig();
        }
        announcementRegistry = newAnnouncementRegistry;
        _bumpConfigVersion();
        emit AnnouncementRegistrySet(newAnnouncementRegistry);
    }

    function launchBuyAdapter() external view returns (address adapter) {
        return hook.launchBuyAdapter();
    }

    function setLaunchBuyAdapter(address newLaunchBuyAdapter) external onlyOwner nonReentrant {
        address previousAdapter = hook.launchBuyAdapter();
        if (newLaunchBuyAdapter == previousAdapter) return;
        hook.setLaunchBuyAdapter(newLaunchBuyAdapter);
        _bumpConfigVersion();
        emit LaunchBuyAdapterUpdated(previousAdapter, newLaunchBuyAdapter);
    }

    function setNativeLaunchFee(uint256 newNativeLaunchFee) external onlyOwner nonReentrant {
        uint256 previousNativeLaunchFee = nativeLaunchFee;
        if (newNativeLaunchFee == previousNativeLaunchFee) return;
        nativeLaunchFee = newNativeLaunchFee;
        _bumpConfigVersion();
        emit NativeLaunchFeeUpdated(previousNativeLaunchFee, newNativeLaunchFee);
    }

    function bandTemplate() external view returns (Band[] memory bands) {
        return _bandTemplate;
    }

    function _setLaunchSupply(uint256 supply) internal {
        if (supply < MIN_SUPPLY || supply > MAX_SUPPLY) revert OutOfBounds();
        emit LaunchSupplyUpdated(launchSupply, supply);
        launchSupply = supply;
    }

    /// @dev Reserve one `tickSpacing` of headroom from both tick extremes.
    function _validateStartTickFrame(int24 frame) internal view {
        int24 spacing = tickSpacing;
        if (frame < TickMath.MIN_TICK + spacing || frame > TickMath.MAX_TICK - spacing) revert OutOfBounds();
    }

    function _bumpConfigVersion() internal {
        configVersion++;
        emit ConfigVersionUpdated(configVersion);
    }

    function _requireLaunchCreationWiring() internal view virtual {
        address registry = announcementRegistry;
        address escrow = hook.feeEscrow();
        if (
            registry == address(0) || registry.code.length == 0
                || AnnouncementRegistry(registry).factory() != address(this) || !hook.wired()
                || hook.factory() != address(this) || escrow == address(0) || escrow.code.length == 0
        ) revert InvalidConfig();

        for (uint256 i = 0; i < _feeComponents.length; i++) {
            FeeComponent storage component = _feeComponents[i];
            if (
                component.recipientKind == FeeRecipientKind.PLATFORM
                    || component.recipientKind == FeeRecipientKind.FIXED
            ) _validateConfiguredFeeRecipient(component.configuredRecipient);
        }
    }

    function renounceOwnership() public virtual override onlyOwner {
        if (creatorAdmin != address(0) || pendingCreatorAdmin != address(0) || hook.launchBuyAdapter() != address(0)) {
            revert UnsafeOwnershipRenunciation();
        }
        super.renounceOwnership();
    }
}
