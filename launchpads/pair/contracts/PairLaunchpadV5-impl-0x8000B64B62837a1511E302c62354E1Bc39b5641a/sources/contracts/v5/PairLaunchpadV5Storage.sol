// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {IStateView} from "@uniswap/v4-periphery/src/interfaces/IStateView.sol";
import {
    IStockTokenRegistryV5,
    IPermit2Allowance,
    IPairV4Hook,
    IPairV4Locker,
    IPairV4ConvertedFeeLocker,
    IPairV4DeveloperBuyAdapter,
    IPositionManagerV4
} from "./interfaces/IPairV4.sol";

/// @notice Authoritative storage and ABI types shared by the V5 implementation
/// and its proxy-bound legacy launch delegate.
/// @dev The first 25 slots are the deployed V5 layout. V2 consumes seven slots
/// from the original 39-slot reserve; no historical field is moved or repacked.
abstract contract PairLaunchpadV5Storage is Initializable {
    uint256 public constant TOTAL_SUPPLY = 1_000_000_000 ether;
    uint16 public constant BPS_DENOMINATOR = 10_000;
    uint8 public constant MAX_PAIRS = 5;
    uint24 public constant POOL_FEE = 10_000;
    int24 public constant TICK_SPACING = 200;
    int24 public constant MIN_USABLE_TICK = -887_200;
    int24 public constant MAX_USABLE_TICK = 887_200;
    uint16 public constant MAX_DEV_BUY_BPS = 550;
    uint256 public constant ETH_GRAD_TARGET_WEI = 4.2 ether;
    uint256 public constant SQRT_10_X18 = 3_162_277_660_168_379_331;

    IPoolManager public poolManager;
    IPositionManagerV4 public positionManager;
    IStateView public stateView;
    IStockTokenRegistryV5 public stockRegistry;
    IPairV4Hook public pairHook;
    IPairV4Locker public locker;
    IPermit2Allowance public permit2;
    address public protocolTreasury;
    address public ethPriceFeed;
    address public universalRouter;
    uint256 public protectionBlocks;
    address public owner;
    uint256 public launchFeeWei;
    uint256 public maxOracleAge;
    IPairV4DeveloperBuyAdapter public developerBuyAdapter;

    struct PairAllocation { address quoteToken; uint16 weightBps; }
    struct LaunchParams {
        string name;
        string symbol;
        string metadataURI;
        bytes32 metadataHash;
        PairAllocation[] allocations;
        address creatorFeeRecipient;
        address developerBuyRecipient;
        address developerBuyFundingToken;
        uint8 developerBuyMode;
        uint256 developerBuyAmount;
        uint256 developerBuyLimit;
        uint256[5] developerBuyQuoteCaps;
        uint256 deadline;
    }
    struct LegacyLaunchParams {
        string name;
        string symbol;
        string metadataURI;
        bytes32 metadataHash;
        PairAllocation[] allocations;
        address creatorFeeRecipient;
        address developerBuyRecipient;
        uint8 developerBuyPairIndex;
        uint256 developerTokenAmountOut;
        uint256 maxQuoteAmountIn;
        uint256 deadline;
    }
    struct DeveloperBuyParams {
        address fundingToken;
        uint8 mode;
        uint256 amount;
        uint256 limit;
        uint256[5] quoteCaps;
    }
    struct LegacyDeveloperBuyParams {
        uint8 pairIndex;
        uint256 amountOut;
        uint256 maxAmountIn;
        bool selector;
    }
    struct LaunchPool {
        address quoteToken;
        uint16 weightBps;
        bytes32 poolId;
        uint256 positionId;
        uint256 initialProjectTokenAmount;
        int24 tickLower;
        int24 tickUpper;
        uint256 quoteUsdAtLaunchE8;
        address quotePriceFeed;
        uint8 quoteDecimals;
    }
    struct Launch {
        address creator;
        address creatorFeeRecipient;
        uint64 launchedAt;
        bool graduated;
        uint256 targetUsdE8;
        uint256 ethUsdAtLaunchE8;
        uint256 projectUsdFloorE8;
        uint256 projectUsdCeilingE8;
    }
    struct LaunchV2Params {
        string name;
        string symbol;
        string metadataURI;
        bytes32 metadataHash;
        PairAllocation[] allocations;
        address creatorFeeRecipient;
        address developerBuyRecipient;
        address developerBuyFundingToken;
        uint8 developerBuyMode;
        uint256 developerBuyAmount;
        uint256 developerBuyLimit;
        uint256[5] developerBuyQuoteCaps;
        uint256 deadline;
        bytes32 userSalt;
    }
    /// @notice Parameters for the canonical launch-token graph.
    /// @dev This is intentionally a new ABI type.  In particular it does not
    /// reuse the historical V2 developer-buy fields, whose funding-token and
    /// mode semantics are not part of the canonical ETH-only path.
    struct LaunchV2TokenBuyAllocation {
        address quoteToken;
        uint256 ethAmountIn;
        uint256 projectAmountOutMinimum;
    }
    struct LaunchV2TokenDeveloperBuy {
        uint256 ethAmountIn;
        uint256 projectAmountOutMinimum;
        LaunchV2TokenBuyAllocation[] allocations;
    }
    struct LaunchV2TokenParams {
        string name;
        string symbol;
        string metadataURI;
        bytes32 metadataHash;
        PairAllocation[] allocations;
        uint32 modeId;
        bytes modeConfiguration;
        address[] feeRecipients;
        uint16[] feeSharesBps;
        address developerBuyRecipient;
        LaunchV2TokenDeveloperBuy developerBuy;
        uint256 deadline;
        bytes32 userSalt;
    }
    /// @notice Additive custom-quote ABI. This is intentionally separate from
    /// LaunchV2TokenParams: canonical registry validation must never be relaxed.
    struct LaunchV2CustomQuoteAllocation {
        address quoteToken;
        uint16 weightBps;
        uint8 priceMode; // 0 = authenticated routed USD, 1 = explicit quote price, 2 = canonical registry oracles
        uint256 quoteUsdE8;
        uint256 projectUsdE8;
        uint256 validUntil;
        bytes routedPriceSignature;
        uint256 projectPriceInQuoteX18;
        bool requestDirectFunding;
        bool requestRoutedDeveloperBuy;
        bool requestFeeConversion;
        bool requestBuyback;
        address directFundingAdapter;
        address routedDeveloperBuyAdapter;
        address feeConversionAdapter;
        address buybackAdapter;
    }
    /// @notice A signed, fixed-shape funding and project-pool buy leg.
    /// @dev routeKind: 1 V3 WETH direct, 2 V3 WETH via USDG, 3 V4 WETH
    /// direct, 4 V4 WETH via USDG.
    struct LaunchV2CustomQuoteDeveloperBuyLeg {
        address quoteToken;
        uint256 ethAmountIn;
        uint256 quoteAmountOutMinimum;
        uint256 projectAmountOutMinimum;
        uint8 routeKind;
        uint24 routeFee;
        uint256 validUntil;
        bytes routeSignature;
    }
    struct LaunchV2CustomQuoteDeveloperBuy {
        uint256 ethAmountIn;
        uint256 projectAmountOutMinimum;
        LaunchV2CustomQuoteDeveloperBuyLeg[] legs;
    }
    struct LaunchV2CustomQuoteParams {
        string name;
        string symbol;
        string metadataURI;
        bytes32 metadataHash;
        LaunchV2CustomQuoteAllocation[] allocations;
        address creatorFeeRecipient;
        /// @notice Recipient of the one-shot, native funded custom quote buy.
        /// @dev Zero means that no developer buy is requested.
        address developerBuyRecipient;
        LaunchV2CustomQuoteDeveloperBuy developerBuy;
        uint256 deadline;
        bytes32 userSalt;
    }

    mapping(address => Launch) public launches;
    mapping(address => LaunchPool[]) internal _launchPools;
    mapping(bytes32 => address) public projectTokenByPoolId;
    mapping(bytes32 => address) public quoteTokenByPoolId;
    mapping(bytes32 => uint256) public positionIdByPoolId;
    address[] public launchedTokens;
    uint256 internal _reentrancyStatus;
    IPairV4ConvertedFeeLocker public feeConversionLocker;

    address public launchV2Coordinator;
    address public launchV2TokenFactory;
    address public launchV2Hook;
    address public launchV2BuybackExecutor;
    address public launchV2Aggregator;
    bool public launchV2Enabled;
    mapping(address => address) public launchV2VaultOf;
    // Dedicated additive graph. The published V2 graph above must remain
    // untouched until its API/indexer consumers have been republished.
    address public launchV2FeeSharingCoordinator;
    address public launchV2FeeSharingTokenFactory;
    address public launchV2FeeSharingHook;
    address public launchV2FeeSharingAggregator;
    // Consume the remainder of slot 32 so the capability flag has its own
    // audited raw pre-upgrade word at slot 33.
    uint96 private __feeSharingAddressPadding;
    bool public launchV2FeeSharingEnabled;
    // Preserve the audited slot-33 boundary. Without this filler Solidity
    // packs launchV2Activator beside the existing bool while still shrinking
    // the reserve, which would discard an untouched storage word.
    uint248 private __launchV2EnabledPadding;
    // Shared one-shot pool activation capability. This consumes only the first
    // untouched reserve word and is common to both immutable V2 graphs.
    address public launchV2Activator;
    // This release boundary is intentionally set only during vault registration.
    // Consequently, V1, legacy, and V2 vaults registered before this upgrade
    // remain false and cannot be retrospectively made CTO-eligible.
    mapping(address => bool) public launchV2CommunityTakeoverEligible;
    // The entire canonical graph is governed outside this size-constrained
    // proxy. This consumes one word from the pre-canonical reserve.
    address public launchV2ModeRegistry;
    // Historical registry remains immutable. Future canonical launches may be
    // atomically moved to a fully configured and already-enabled registry.
    address public activeLaunchV2ModeRegistry;
    // Isolated custom-quote release. These dependencies are intentionally not
    // shared with the canonical registry graph or its project-vault records.
    address public customQuoteLaunchV2Coordinator;
    // Keep the capability bit in an independently auditable storage word.
    uint96 private __customQuoteCoordinatorPadding;
    bool public customQuoteLaunchV2Enabled;
    uint248 private __customQuoteEnabledPadding;
    mapping(address => address) public customQuoteLaunchV2VaultOf;
    // Three reserved words above are consumed: coordinator/padding,
    // enabled/padding, and the vault mapping seed.
    uint256[21] private __gap;

    event MultiPairLaunchCreated(address indexed projectToken,address indexed creator,uint256 pairCount,
        uint256 totalSupply,uint256 graduationTargetUsdE8,string metadataURI);
    event PairPoolCreated(address indexed projectToken,address indexed quoteToken,bytes32 indexed poolId,
        uint256 positionId,uint16 weightBps,uint256 projectTokenAmount,int24 tickLower,int24 tickUpper,
        uint160 initialSqrtPriceX96,uint256 quoteUsdAtLaunchE8);
    event InitialDeveloperBuy(address indexed projectToken,address indexed quoteToken,address indexed recipient,
        uint256 projectAmountOut,uint256 quoteAmountIn);
    event RoundingDustPermanentlyLocked(address indexed projectToken,uint256 amount);
    event LaunchGraduated(address indexed projectToken,uint256 principalUsdE8,uint256 targetUsdE8);
    event OwnershipTransferred(address indexed previousOwner,address indexed newOwner);
    event LaunchV2Configured(address indexed coordinator,address indexed tokenFactory,address indexed hook,
        address buybackExecutor,address aggregator);
    event LaunchV2CapabilitySet(bool enabled);
    event LaunchV2Created(address indexed projectToken,address indexed creator,address indexed vault,
        bytes32 userSalt,uint256 pairCount);
    event LaunchV2CreatedWithMode(address indexed projectToken,address indexed creator,address indexed vault,
        bytes32 userSalt,uint256 pairCount,uint8 epoch1Mode);
    event LaunchV2ModeTransitioned(address indexed projectToken,address indexed vault,uint64 epoch,uint8 mode);
    event LaunchV2FeeSharingCreated(address indexed projectToken,address indexed creator,address indexed vault,
        bytes32 userSalt,uint256 pairCount);
    event LaunchV2FeeSharingConfigured(address indexed coordinator,address indexed tokenFactory,address indexed hook,
        address aggregator);
    event LaunchV2FeeSharingCapabilitySet(bool enabled);
    event LaunchV2ActivatorConfigured(address indexed activator);
    event LaunchV2FeeSharingDependenciesRotated(address indexed coordinator,address indexed tokenFactory,
        address indexed hook,address aggregator);
    event LaunchV2DependenciesRotated(address indexed coordinator,address indexed tokenFactory,address indexed hook,
        address buybackExecutor,address aggregator);
    event ActiveLaunchV2ModeRegistryInstalled(address indexed previousRegistry,address indexed newRegistry);
    event CustomQuoteLaunchV2Configured(address indexed coordinator,address indexed tokenFactory,
        address indexed initializer,address priceSigner);
    event CustomQuoteLaunchV2DependenciesRotated(address indexed previousCoordinator,address indexed coordinator,
        address indexed tokenFactory,address initializer,address priceSigner);
    event CustomQuoteLaunchV2CapabilitySet(bool enabled);
    event LaunchV2CommunityTakeover(
        address indexed projectToken,address indexed vault,address indexed previousCreator,
        address newCreator,uint64 previousEpoch,uint64 newEpoch,uint8 previousMode,uint8 newMode
    );

    error OnlyOwner();
    error InvalidAddress();
    error InvalidPairCount();
    error DuplicatePair();
    error InvalidWeight();
    error WeightsNotOneHundredPercent();
    error StockTokenDisabled();
    error InvalidOracle();
    error StaleOracle();
    error InvalidDecimals();
    error IncorrectLaunchFee();
    error DeadlineExpired();
    error InvalidDeveloperBuy();
    error NotLaunched();
    error AlreadyGraduated();
    error BelowGraduationTarget();
    error ReentrancyGuardReentrantCall();
    error PriceRangeTooNarrow();
    error EconomicsOutOfRange();
    error PriceOutOfRange();
    error ZeroAge();
    error FeeTransferFailed();
    error LaunchV2Disabled();
    error LaunchV2AlreadyConfigured();
    error InvalidLaunchV2();
    error InvalidLaunchV2Mode();
    error ImmutableFeeSharingLaunch();
    error InvalidLaunchV2Vault();
    error LaunchV2CommunityTakeoverIneligible();
    error LegacyHelperOnlyProxy();
    error LegacyHelperCallFailed();
    // Retained because SafeERC20 was linked into the deployed-old ABI.
    error SafeERC20FailedOperation(address token);
}