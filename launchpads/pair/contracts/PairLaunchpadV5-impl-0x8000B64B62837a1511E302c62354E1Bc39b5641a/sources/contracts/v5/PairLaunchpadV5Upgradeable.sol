// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {PoolId} from "@uniswap/v4-core/src/types/PoolId.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {FullMath} from "@uniswap/v4-core/src/libraries/FullMath.sol";
import {FixedPoint96} from "@uniswap/v4-core/src/libraries/FixedPoint96.sol";
import {PairLaunchpadV5Storage} from "./PairLaunchpadV5Storage.sol";
import {
    IStockTokenRegistryV5,
    IAggregatorV3V5,
    IPermit2Allowance,
    IPairV4Hook,
    IPairV4Locker,
    IPairV4ConvertedFeeLocker,
    IPairV4DeveloperBuyAdapter,
    IPositionManagerV4
} from "./interfaces/IPairV4.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {IStateView} from "@uniswap/v4-periphery/src/interfaces/IStateView.sol";

/// @dev Immutable math boundary keeps the proxy runtime below EIP-170 while
/// retaining the published launchpad selectors and exact arithmetic.
contract PairV5LaunchMathDelegate {
    uint256 private constant ETH_GRAD_TARGET_WEI=4.2 ether;
    uint256 private constant SQRT_10_X18=3_162_277_660_168_379_331;
    int24 private constant TICK_SPACING=200;
    int24 private constant MIN_USABLE_TICK=-887_200;
    int24 private constant MAX_USABLE_TICK=887_200;
    function calculate(address project,address quote,uint8 decimals,uint256 quoteUsd,uint256 floor,uint256 ceiling)
        external pure returns(int24 lower,int24 upper,uint160 sqrt) {
        uint160 root=_sqrt(project<quote,floor,quoteUsd,decimals);
        int24 tick=TickMath.getTickAtSqrtPrice(root);
        if(project<quote) { lower=_floor(tick);upper=MAX_USABLE_TICK;sqrt=TickMath.getSqrtPriceAtTick(lower); }
        else { lower=MIN_USABLE_TICK;upper=_ceil(tick);sqrt=TickMath.getSqrtPriceAtTick(upper); }
        if(lower>=upper) revert PairLaunchpadV5Storage.PriceRangeTooNarrow();
        ceiling;
    }
    function economics(uint256 ethUsd) external pure returns(uint256 target,uint256 floor,uint256 ceiling) {
        target=FullMath.mulDiv(ETH_GRAD_TARGET_WEI,ethUsd,1 ether);
        uint256 midpoint=target/1_000_000_000;
        floor=FullMath.mulDiv(midpoint,1e18,SQRT_10_X18);
        ceiling=FullMath.mulDiv(midpoint,SQRT_10_X18,1e18);
        if(floor==0||ceiling<=floor) revert PairLaunchpadV5Storage.EconomicsOutOfRange();
    }
    function _sqrt(bool projectIs0,uint256 projectPrice,uint256 quotePrice,uint8 decimals) private pure returns(uint160) {
        uint256 ratio=projectIs0?FullMath.mulDiv(projectPrice,10**decimals,quotePrice)
            :FullMath.mulDiv(quotePrice,1e36,projectPrice*(10**decimals));
        uint256 value=FullMath.mulDiv(Math.sqrt(ratio),FixedPoint96.Q96,1e9);
        if(value<TickMath.MIN_SQRT_PRICE||value>=TickMath.MAX_SQRT_PRICE) revert PairLaunchpadV5Storage.PriceOutOfRange();
        return uint160(value);
    }
    function _floor(int24 tick) private pure returns(int24) {
        int24 compressed=tick/TICK_SPACING;
        if(tick<0&&tick%TICK_SPACING!=0) --compressed;
        return compressed*TICK_SPACING;
    }
    function _ceil(int24 tick) private pure returns(int24) {
        int24 floor=_floor(tick); return floor==tick?tick:floor+TICK_SPACING;
    }
}

interface IPairV5LaunchV2Coordinator {
    function launch(address creator,PairLaunchpadV5Storage.LaunchV2Params calldata parameters)
        external payable returns (address);
    function launchWithEpoch1Mode(address creator,PairLaunchpadV5Storage.LaunchV2Params calldata parameters,
        uint8 epoch1Mode) external payable returns (address);
    function launchWithFeeSharing(address creator,PairLaunchpadV5Storage.LaunchV2Params calldata parameters,
        address[] calldata recipients,uint16[] calldata sharesBps) external payable returns (address);
    function dependencies() external view returns (address,address,address,address,address);
    function launchV2ModeSelectionVersion() external pure returns (uint256);
}
interface IPairV5LaunchV2FeeSharingCoordinator {
    function launchWithFeeSharing(address creator,PairLaunchpadV5Storage.LaunchV2Params calldata parameters,
        address[] calldata recipients,uint16[] calldata sharesBps) external payable returns (address);
    function dependencies() external view returns (address,address,address,address,address);
    function launchV2FeeSharingVersion() external pure returns (uint256);
}
interface IPairV5LaunchV2Vault {
    function transitionMode(address creator,uint8 mode) external;
    function transitionFeeSharing(address[] calldata recipients,uint16[] calldata sharesBps) external;
    function epoch() external view returns (uint64);
    function epochs(uint64) external view returns (address creator,uint8 mode);
    function projectToken() external view returns (address);
    function launchpad() external view returns (address);
    function hook() external view returns (address);
    function buybackExecutor() external view returns (address);
    function registrar() external view returns (address);
}
interface IPairV5LaunchV2Token {
    function launchpad() external view returns (address);
    function locker() external view returns (address);
    function buybackExecutor() external view returns (address);
}
/// @notice Boundary for the canonical graph.  It deliberately has no
/// activator/recovery callback: a successful coordinator launch is final.
interface IPairV5LaunchV2TokenCoordinator {
    function launchV2Token(
        address creator,
        PairLaunchpadV5Storage.LaunchV2TokenParams calldata parameters
    ) external payable returns (address projectToken);
}
/// @notice Deliberately separate release capability for non-registry quotes.
interface IPairV5LaunchV2CustomQuoteCoordinator {
    function customQuoteLaunchVersion() external pure returns(uint256);
    function dependencies() external view returns(address,address,address,address,address);
    function launchV2TokenWithCustomQuotes(
        address creator,PairLaunchpadV5Storage.LaunchV2CustomQuoteParams calldata parameters
    ) external payable returns(address projectToken);
}
interface IPairV5LaunchV2CustomQuoteFactoryBinding {
    function launchpad() external view returns(address);
    function coordinator() external view returns(address);
}
interface IPairV5LaunchV2CustomQuoteInitializerBinding {
    function launchCapability() external view returns(address);
}
/// @dev Immutable delegate target preserving proxy storage while keeping the
/// optional release out of the production launchpad runtime.
contract PairV5CustomQuoteReleaseDelegate is PairLaunchpadV5Storage {
    function launchV2TokenWithCustomQuotes(LaunchV2CustomQuoteParams calldata p)
        external payable returns(address projectToken) {
        address coordinator=customQuoteLaunchV2Coordinator;
        if(!customQuoteLaunchV2Enabled||coordinator.code.length==0) revert LaunchV2Disabled();
        (bool ok,bytes memory data)=coordinator.staticcall(
            abi.encodeWithSelector(IPairV5LaunchV2CustomQuoteCoordinator.customQuoteLaunchVersion.selector));
        // V1 remains an accepted historical graph; V2 adds the separately
        // attested native custom-quote developer-buy capability.
        if(!ok||data.length!=32) revert InvalidLaunchV2();
        uint256 version=abi.decode(data,(uint256));
        if(version!=1&&version!=2) revert InvalidLaunchV2();
        projectToken=IPairV5LaunchV2CustomQuoteCoordinator(coordinator)
            .launchV2TokenWithCustomQuotes{value:msg.value}(msg.sender,p);
    }
    function configureCustomQuoteLaunchV2(address coordinator_,address tokenFactory_,address initializer_,
        address priceSigner_) external {
        if(msg.sender!=owner) revert OnlyOwner();
        if(customQuoteLaunchV2Coordinator!=address(0)) revert LaunchV2AlreadyConfigured();
        _setCustomQuoteLaunchV2(coordinator_,tokenFactory_,initializer_,priceSigner_);
        emit CustomQuoteLaunchV2Configured(coordinator_,tokenFactory_,initializer_,priceSigner_);
    }
    /// @notice Rebinds only future custom-quote launches after the old graph is disabled.
    /// @dev Existing project tokens and vaults retain their immutable historical dependencies.
    function rotateCustomQuoteLaunchV2(address coordinator_,address tokenFactory_,address initializer_,
        address priceSigner_) external {
        if(msg.sender!=owner) revert OnlyOwner();
        address previous=customQuoteLaunchV2Coordinator;
        if(previous==address(0)||customQuoteLaunchV2Enabled) revert InvalidLaunchV2();
        _setCustomQuoteLaunchV2(coordinator_,tokenFactory_,initializer_,priceSigner_);
        emit CustomQuoteLaunchV2DependenciesRotated(previous,coordinator_,tokenFactory_,initializer_,priceSigner_);
    }
    function _setCustomQuoteLaunchV2(address coordinator_,address tokenFactory_,address initializer_,
        address priceSigner_) private {
        if(coordinator_.code.length==0||tokenFactory_.code.length==0||initializer_.code.length==0||priceSigner_==address(0)) {
            revert InvalidLaunchV2();
        }
        (address pad,address factory,address init,address signer,)=
            IPairV5LaunchV2CustomQuoteCoordinator(coordinator_).dependencies();
        if(pad!=address(this)||factory!=tokenFactory_||init!=initializer_||signer!=priceSigner_
            ||IPairV5LaunchV2CustomQuoteFactoryBinding(tokenFactory_).launchpad()!=address(this)
            ||IPairV5LaunchV2CustomQuoteFactoryBinding(tokenFactory_).coordinator()!=coordinator_
            ||IPairV5LaunchV2CustomQuoteInitializerBinding(initializer_).launchCapability()!=coordinator_) {
            revert InvalidLaunchV2();
        }
        customQuoteLaunchV2Coordinator=coordinator_;
    }
    function setCustomQuoteLaunchV2Enabled(bool enabled) external {
        if(msg.sender!=owner) revert OnlyOwner();
        if(customQuoteLaunchV2Coordinator==address(0)) revert InvalidLaunchV2();
        customQuoteLaunchV2Enabled=enabled;
        emit CustomQuoteLaunchV2CapabilitySet(enabled);
    }
    function registerCustomQuoteLaunchV2Vault(address projectToken,address vault) external {
        if(msg.sender!=customQuoteLaunchV2Coordinator||projectToken==address(0)||vault==address(0)
            ||customQuoteLaunchV2VaultOf[projectToken]!=address(0)) revert InvalidLaunchV2();
        customQuoteLaunchV2VaultOf[projectToken]=vault;
    }
}
interface IPairV5LaunchV2ModeRegistry {
    function launchpad() external view returns(address);
    function launchEnabled() external view returns(bool);
    function currentCoordinator() external view returns(address);
}
interface IPairV5LaunchV2Activator {
    function activationVersion() external pure returns(uint256);
    function launchpad() external view returns(address);
    function recover(address,address,uint256) external;
    function configureActivationQuotes(address[] calldata) external;
}
contract PairV5ActiveRegistryValidator is PairLaunchpadV5Storage {
    function installActiveLaunchV2ModeRegistry(address candidate) external {
        address historical=launchV2ModeRegistry;
        address previous=activeLaunchV2ModeRegistry==address(0)?historical:activeLaunchV2ModeRegistry;
        if(previous==address(0)||candidate==previous||candidate==historical||candidate.code.length==0
            ||IPairV5LaunchV2ModeRegistry(candidate).launchpad()!=address(this)
            ||IPairV5LaunchV2ModeRegistry(candidate).launchEnabled()) revert PairLaunchpadV5Storage.InvalidLaunchV2();
        activeLaunchV2ModeRegistry=candidate;
        emit ActiveLaunchV2ModeRegistryInstalled(previous,candidate);
    }
    function installEnabledActiveLaunchV2ModeRegistry(address candidate) external {
        address historical=launchV2ModeRegistry;
        address previous=activeLaunchV2ModeRegistry==address(0)?historical:activeLaunchV2ModeRegistry;
        if(candidate.code.length==0) revert PairLaunchpadV5Storage.InvalidLaunchV2();
        if(previous==address(0)||candidate==previous||candidate==historical
            ||IPairV5LaunchV2ModeRegistry(candidate).launchpad()!=address(this)
            ||!IPairV5LaunchV2ModeRegistry(candidate).launchEnabled()
            ||IPairV5LaunchV2ModeRegistry(candidate).currentCoordinator()==address(0)) {
            revert PairLaunchpadV5Storage.InvalidLaunchV2();
        }
        activeLaunchV2ModeRegistry=candidate;
        emit ActiveLaunchV2ModeRegistryInstalled(previous,candidate);
    }
}

/// @notice Canonical UUPS V5 implementation. Legacy launch execution is pinned
/// to an immutable, proxy-bound delegate while every V2 path is a normal call.
contract PairLaunchpadV5Upgradeable is PairLaunchpadV5Storage, UUPSUpgradeable {
    address public immutable legacyLaunchHelper;
    PairV5ActiveRegistryValidator private immutable _activeRegistryValidator;
    PairV5CustomQuoteReleaseDelegate private immutable _customQuoteReleaseDelegate;
    PairV5LaunchMathDelegate private immutable _launchMathDelegate;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(address legacyLaunchHelper_) {
        if (legacyLaunchHelper_ == address(0) || legacyLaunchHelper_.code.length == 0) revert InvalidAddress();
        legacyLaunchHelper = legacyLaunchHelper_;
        _activeRegistryValidator=new PairV5ActiveRegistryValidator();
        _customQuoteReleaseDelegate=new PairV5CustomQuoteReleaseDelegate();
        _launchMathDelegate=new PairV5LaunchMathDelegate();
        _disableInitializers();
    }

    function initialize(
        IPoolManager poolManager_,IPositionManagerV4 positionManager_,IStateView stateView_,
        IStockTokenRegistryV5 stockRegistry_,IPairV4Hook pairHook_,IPairV4Locker locker_,
        IPermit2Allowance permit2_,address universalRouter_,
        IPairV4DeveloperBuyAdapter developerBuyAdapter_,address ethPriceFeed_,
        address protocolTreasury_,address owner_,uint256 launchFeeWei_,uint256 protectionBlocks_
    ) external initializer {
        if (address(poolManager_) == address(0) || address(positionManager_) == address(0)
            || address(stateView_) == address(0) || address(stockRegistry_) == address(0)
            || address(pairHook_) == address(0) || address(locker_) == address(0)
            || address(permit2_) == address(0) || universalRouter_ == address(0)
            || address(developerBuyAdapter_) == address(0) || ethPriceFeed_ == address(0)
            || protocolTreasury_ == address(0) || owner_ == address(0)) revert InvalidAddress();
        poolManager = poolManager_;
        positionManager = positionManager_;
        stateView = stateView_;
        stockRegistry = stockRegistry_;
        pairHook = pairHook_;
        locker = locker_;
        permit2 = permit2_;
        universalRouter = universalRouter_;
        if (developerBuyAdapter_.launchpad() != address(this)
            || developerBuyAdapter_.poolManager() != address(poolManager_)
            || developerBuyAdapter_.permit2() != address(permit2_)
            || developerBuyAdapter_.universalRouter() != universalRouter_) revert InvalidAddress();
        developerBuyAdapter = developerBuyAdapter_;
        ethPriceFeed = ethPriceFeed_;
        protocolTreasury = protocolTreasury_;
        owner = owner_;
        launchFeeWei = launchFeeWei_;
        protectionBlocks = protectionBlocks_;
        maxOracleAge = 2 hours;
        _reentrancyStatus = 1;
        emit OwnershipTransferred(address(0),owner_);
    }

    modifier onlyOwner() { if (msg.sender != owner) revert OnlyOwner(); _; }
    modifier nonReentrant() {
        if (_reentrancyStatus != 1) revert ReentrancyGuardReentrantCall();
        _reentrancyStatus = 2; _; _reentrancyStatus = 1;
    }
    function _authorizeUpgrade(address) internal override onlyOwner {}

    function launchTokenMulti(LaunchParams calldata p)
        external payable nonReentrant returns (address projectToken) {
        p;
        return _legacyDelegate();
    }
    function launchTokenMulti(LegacyLaunchParams calldata p)
        external payable nonReentrant returns (address projectToken) {
        p;
        return _legacyDelegate();
    }
    /// @custom:oz-upgrades-unsafe-allow delegatecall
    function _legacyDelegate() private returns (address projectToken) {
        (bool ok,bytes memory result) = legacyLaunchHelper.delegatecall(msg.data);
        if (!ok) assembly ("memory-safe") { revert(add(result,32),mload(result)) }
        if (result.length != 32) revert LegacyHelperCallFailed();
        projectToken = abi.decode(result,(address));
    }

    function launchV2(LaunchV2Params calldata p)
        external payable nonReentrant returns (address projectToken) {
        return _launchV2(p,0,false);
    }
    /// @notice Launches V2 with an immutable epoch-one fee destination.
    /// @dev Retains launchV2(LaunchV2Params) as the Creator-mode compatibility selector.
    function launchV2WithEpoch1Mode(LaunchV2Params calldata p,uint8 epoch1Mode)
        external payable nonReentrant returns (address projectToken) {
        return _launchV2(p,epoch1Mode,true);
    }
    /// @notice Launches with an immutable recipient fee split on a V2-capable coordinator.
    function launchV2WithFeeSharing(
        LaunchV2Params calldata p,address[] calldata recipients,uint16[] calldata sharesBps
    ) external payable nonReentrant returns (address projectToken) {
        if (!launchV2FeeSharingEnabled) revert LaunchV2Disabled();
        if (p.allocations.length == 0 || p.allocations.length > MAX_PAIRS || p.userSalt == bytes32(0)) {
            revert InvalidLaunchV2();
        }
        if (launchV2FeeSharingVersion() != 1) revert InvalidLaunchV2();
        projectToken = IPairV5LaunchV2FeeSharingCoordinator(launchV2FeeSharingCoordinator)
            .launchWithFeeSharing{value:msg.value}(
            msg.sender,p,recipients,sharesBps);
        address vault = launchV2VaultOf[projectToken];
        if (vault == address(0)) revert InvalidLaunchV2();
        emit LaunchV2FeeSharingCreated(projectToken,msg.sender,vault,p.userSalt,p.allocations.length);
    }
    /// @notice Launch through the canonical graph.
    /// @dev Kept separate from `launchV2` so published V2 selector and
    /// callback semantics remain byte-for-byte untouched.
    function launchV2Token(LaunchV2TokenParams calldata p)
        external payable nonReentrant returns (address projectToken) {
        IPairV5LaunchV2ModeRegistry registry = IPairV5LaunchV2ModeRegistry(_selectedLaunchV2ModeRegistry());
        address coordinator = registry.currentCoordinator();
        if (!registry.launchEnabled() || coordinator == address(0)) revert LaunchV2Disabled();
        projectToken = IPairV5LaunchV2TokenCoordinator(coordinator)
            .launchV2Token{value: msg.value}(msg.sender,p);
    }
    /// @notice Launch through an opt-in custom-quote release selected by the
    /// active V2 registry. The published canonical selector remains untouched.
    /// @dev The exact capability marker prevents fallback contracts and older
    /// coordinators from accidentally accepting this ABI.
    function launchV2TokenWithCustomQuotes(LaunchV2CustomQuoteParams calldata p)
        external payable nonReentrant returns(address projectToken) {
        p;
        return _customQuoteDelegate();
    }
    /// @notice Proxy-originated initialization bridge for the isolated custom
    /// quote graph. PairV4Hook authorizes the launchpad, never an initializer.
    function initializeActiveCustomQuotePool(address project,address quote,uint160 sqrtPriceX96) external {
        address coordinator=customQuoteLaunchV2Coordinator;
        if(!customQuoteLaunchV2Enabled||project==address(0)||quote==address(0)||project==quote) revert InvalidLaunchV2();
        (address pad,,address initializer,,)=IPairV5LaunchV2CustomQuoteCoordinator(coordinator).dependencies();
        if(pad!=address(this)||msg.sender!=initializer) revert InvalidLaunchV2();
        bool projectIs0=project<quote;
        PoolKey memory key=PoolKey(Currency.wrap(projectIs0?project:quote),Currency.wrap(projectIs0?quote:project),
            POOL_FEE,TICK_SPACING,IHooks(address(pairHook)));
        pairHook.authorizePool(key,project,quote);
        poolManager.initialize(key,sqrtPriceX96);
    }
    function _customQuoteDelegate() private returns(address projectToken) {
        bytes memory result=_customQuoteDelegateCall();
        if(result.length!=32) revert InvalidLaunchV2();
        projectToken=abi.decode(result,(address));
    }
    /// @notice Capability probe for explicit epoch-one mode selection.
    /// @dev Fails closed for an unconfigured, legacy, reverting, or malformed coordinator.
    function launchV2ModeSelectionVersion() external view returns (uint256 version) {
        address coordinator = launchV2Coordinator;
        if (coordinator.code.length == 0) return 0;
        (bool ok,bytes memory result) = coordinator.staticcall(
            abi.encodeWithSelector(IPairV5LaunchV2Coordinator.launchV2ModeSelectionVersion.selector));
        if (!ok || result.length != 32) return 0;
        assembly ("memory-safe") { version := mload(add(result,32)) }
        return version == 1 ? 1 : 0;
    }
    /// @notice Capability probe for the isolated fee-sharing launch graph.
    function launchV2FeeSharingVersion() public view returns (uint256 version) {
        address coordinator = launchV2FeeSharingCoordinator;
        if (coordinator.code.length == 0) return 0;
        (bool ok,bytes memory result) = coordinator.staticcall(
            abi.encodeWithSelector(IPairV5LaunchV2FeeSharingCoordinator.launchV2FeeSharingVersion.selector));
        if (!ok || result.length != 32) return 0;
        assembly ("memory-safe") { version := mload(add(result,32)) }
        return version == 1 ? 1 : 0;
    }
    function _launchV2(LaunchV2Params calldata p,uint8 epoch1Mode,bool modeAware)
        private returns (address projectToken) {
        if (!launchV2Enabled) revert LaunchV2Disabled();
        if (p.allocations.length == 0 || p.allocations.length > MAX_PAIRS || p.userSalt == bytes32(0)) {
            revert InvalidLaunchV2();
        }
        if (epoch1Mode > 1) revert InvalidLaunchV2Mode();
        IPairV5LaunchV2Coordinator coordinator = IPairV5LaunchV2Coordinator(launchV2Coordinator);
        projectToken = modeAware
            ? coordinator.launchWithEpoch1Mode{value: msg.value}(msg.sender,p,epoch1Mode)
            : coordinator.launch{value: msg.value}(msg.sender,p);
        address vault = launchV2VaultOf[projectToken];
        if (vault == address(0)) revert InvalidLaunchV2();
        emit LaunchV2Created(projectToken,msg.sender,vault,p.userSalt,p.allocations.length);
        if (modeAware) emit LaunchV2CreatedWithMode(
            projectToken,msg.sender,vault,p.userSalt,p.allocations.length,epoch1Mode);
    }

    function calculateV4LaunchRange(address projectToken,address quoteToken,uint8 quoteDecimals,
        uint256 quoteUsdE8,uint256 projectFloorE8,uint256 projectCeilingE8)
        public view returns (int24 lower,int24 upper,uint160 initialSqrtPriceX96) {
        return _launchMathDelegate.calculate(
            projectToken,quoteToken,quoteDecimals,quoteUsdE8,projectFloorE8,projectCeilingE8);
    }
    function deriveLaunchEconomics(uint256 ethUsdE8)
        public view returns (uint256 targetUsdE8,uint256 floorUsdE8,uint256 ceilingUsdE8) {
        return _launchMathDelegate.economics(ethUsdE8);
    }
    function _freshPrice(address feed) private view returns (uint256 priceE8) {
        (uint80 roundId,int256 answer,,uint256 updatedAt,uint80 answered) =
            IAggregatorV3V5(feed).latestRoundData();
        if (answer <= 0 || updatedAt == 0 || answered < roundId) revert InvalidOracle();
        if (block.timestamp < updatedAt || block.timestamp - updatedAt > maxOracleAge) revert StaleOracle();
        uint8 decimals = IAggregatorV3V5(feed).decimals();
        if (decimals > 36) revert InvalidDecimals();
        priceE8 = decimals == 8 ? uint256(answer) : decimals < 8
            ? uint256(answer) * (10 ** (8 - decimals)) : uint256(answer) / (10 ** (decimals - 8));
        if (priceE8 == 0) revert InvalidOracle();
    }

    function graduationStatus(address projectToken)
        public view returns (uint256 principalUsdE8,uint256 targetUsdE8,bool graduated) {
        Launch storage l = launches[projectToken];
        if (l.launchedAt == 0) revert NotLaunched();
        LaunchPool[] storage pools = _launchPools[projectToken];
        for (uint256 i; i < pools.length;) {
            LaunchPool storage p = pools[i];
            (uint160 current,,,) = stateView.getSlot0(PoolId.wrap(p.poolId));
            uint128 liquidity = positionManager.getPositionLiquidity(p.positionId);
            uint160 lo = TickMath.getSqrtPriceAtTick(p.tickLower);
            uint160 hi = TickMath.getSqrtPriceAtTick(p.tickUpper);
            bool is0 = projectToken < p.quoteToken;
            uint160 bounded = current < lo ? lo : current > hi ? hi : current;
            uint256 quotePrincipal = is0
                ? (bounded <= lo ? 0 : FullMath.mulDiv(liquidity,bounded - lo,FixedPoint96.Q96))
                : (bounded >= hi ? 0 : FullMath.mulDiv(
                    FullMath.mulDiv(liquidity,hi - bounded,bounded),FixedPoint96.Q96,hi));
            principalUsdE8 += FullMath.mulDiv(
                quotePrincipal,_freshPrice(p.quotePriceFeed),10 ** p.quoteDecimals);
            unchecked { ++i; }
        }
        return (principalUsdE8,l.targetUsdE8,l.graduated);
    }
    function syncGraduation(address projectToken) external {
        Launch storage l = launches[projectToken];
        if (l.graduated) revert AlreadyGraduated();
        (uint256 principal,uint256 target,) = graduationStatus(projectToken);
        if (principal < target) revert BelowGraduationTarget();
        l.graduated = true;
        emit LaunchGraduated(projectToken,principal,target);
    }
    function getLaunchPoolCount(address projectToken) external view returns (uint256) {
        return _launchPools[projectToken].length;
    }
    function getLaunchPool(address projectToken,uint256 index) external view returns (LaunchPool memory) {
        return _launchPools[projectToken][index];
    }

    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner == address(0)) revert InvalidAddress();
        address old = owner; owner = newOwner; emit OwnershipTransferred(old,newOwner);
    }
    function setMaxOracleAge(uint256 age) external onlyOwner {
        if (age == 0) revert ZeroAge();
        maxOracleAge = age;
    }
    function setLaunchFee(uint256 fee) external onlyOwner { launchFeeWei = fee; }
    function setFeeConversionLocker(IPairV4ConvertedFeeLocker newLocker) external onlyOwner {
        if (address(newLocker) != address(0) && (newLocker.launchpad() != address(this)
            || newLocker.positionManager() != address(positionManager)
            || newLocker.permit2() != address(permit2)
            || newLocker.universalRouter() != universalRouter
            || newLocker.protocolTreasury() != protocolTreasury)) revert InvalidAddress();
        feeConversionLocker = newLocker;
    }
    function setDeveloperBuyAdapter(IPairV4DeveloperBuyAdapter newAdapter) external onlyOwner {
        if (!newAdapter.isConfigured(address(this),address(poolManager),address(permit2),universalRouter)) {
            revert InvalidAddress();
        }
        developerBuyAdapter = newAdapter;
    }

    function configureLaunchV2(address coordinator_,address tokenFactory_,address hook_,
        address buybackExecutor_,address aggregator_) external onlyOwner {
        if (launchV2Coordinator != address(0)) revert LaunchV2AlreadyConfigured();
        _setLaunchV2Dependencies(coordinator_,tokenFactory_,hook_,buybackExecutor_,aggregator_);
        emit LaunchV2Configured(coordinator_,tokenFactory_,hook_,buybackExecutor_,aggregator_);
    }
    /// @notice Installs the external canonical registry once.
    function configureLaunchV2TokenRegistry(address registry_) external onlyOwner {
        if (launchV2ModeRegistry != address(0) || registry_.code.length == 0
            || IPairV5LaunchV2ModeRegistry(registry_).launchpad() != address(this)) revert InvalidLaunchV2();
        launchV2ModeRegistry = registry_;
    }
    /// @notice Selects a new registry for future canonical launches without
    /// changing the historical registry used by already-deployed vaults.
    function installActiveLaunchV2ModeRegistry(address registry_) external onlyOwner {
        registry_;
        address validator=address(_activeRegistryValidator);
        assembly ("memory-safe") {
            calldatacopy(0,0,calldatasize())
            if iszero(delegatecall(gas(),validator,0,calldatasize(),0,0)) {
                mstore(0,shl(224,0x79c04aab))
                revert(0,4)
            }
        }
    }
    /// @notice Atomically selects a fully configured, already-enabled graph.
    /// @dev This preserves launch availability throughout a forward-only release.
    function installEnabledActiveLaunchV2ModeRegistry(address registry_) external onlyOwner {
        registry_;
        address validator=address(_activeRegistryValidator);
        assembly ("memory-safe") {
            calldatacopy(0,0,calldatasize())
            if iszero(delegatecall(gas(),validator,0,calldatasize(),0,0)) {
                mstore(0,shl(224,0x79c04aab))
                revert(0,4)
            }
        }
    }
    function _selectedLaunchV2ModeRegistry() private view returns(address) {
        address active=activeLaunchV2ModeRegistry;
        return active==address(0)?launchV2ModeRegistry:active;
    }
    /// @notice Installs the single write-once activation-marker authority shared
    /// by standard and Fee Sharing V2 releases.
    function configureLaunchV2Activator(address activator_) external onlyOwner {
        if(launchV2Activator!=address(0)||activator_.code.length==0) revert LaunchV2AlreadyConfigured();
        if(IPairV5LaunchV2Activator(activator_).activationVersion()!=1
            ||IPairV5LaunchV2Activator(activator_).launchpad()!=address(this)) revert InvalidLaunchV2();
        launchV2Activator=activator_;
        emit LaunchV2ActivatorConfigured(activator_);
    }
    function recoverLaunchV2ActivationInventory(address quote,address recipient,uint256 amount) external onlyOwner {
        IPairV5LaunchV2Activator(launchV2Activator).recover(quote,recipient,amount);
    }
    function configureLaunchV2ActivationQuotes(address[] calldata quotes) external onlyOwner {
        IPairV5LaunchV2Activator(launchV2Activator).configureActivationQuotes(quotes);
    }
    /// @notice Rebinds future V2 launches only; existing project vaults retain immutable dependencies.
    /// @dev Rotation is deliberately impossible while users can launch.
    function rotateLaunchV2Dependencies(address coordinator_,address tokenFactory_,address hook_,
        address buybackExecutor_,address aggregator_) external onlyOwner {
        if (launchV2Enabled || launchV2Coordinator == address(0)) revert InvalidLaunchV2();
        _setLaunchV2Dependencies(coordinator_,tokenFactory_,hook_,buybackExecutor_,aggregator_);
        emit LaunchV2DependenciesRotated(coordinator_,tokenFactory_,hook_,buybackExecutor_,aggregator_);
    }
    function _setLaunchV2Dependencies(address coordinator_,address tokenFactory_,address hook_,
        address buybackExecutor_,address aggregator_) private {
        if (coordinator_ == address(0) || tokenFactory_ == address(0) || hook_ == address(0)
            || buybackExecutor_ == address(0) || aggregator_ == address(0)
            || coordinator_.code.length == 0 || tokenFactory_.code.length == 0 || hook_.code.length == 0
            || buybackExecutor_.code.length == 0 || aggregator_.code.length == 0) revert InvalidLaunchV2();
        (address launchpad_,address factory_,address hookAttested,address executor_,address aggregatorAttested) =
            IPairV5LaunchV2Coordinator(coordinator_).dependencies();
        if (launchpad_ != address(this) || factory_ != tokenFactory_ || hookAttested != hook_
            || executor_ != buybackExecutor_ || aggregatorAttested != aggregator_) revert InvalidLaunchV2();
        launchV2Coordinator = coordinator_;
        launchV2TokenFactory = tokenFactory_;
        launchV2Hook = hook_;
        launchV2BuybackExecutor = buybackExecutor_;
        launchV2Aggregator = aggregator_;
    }
    function setLaunchV2Enabled(bool enabled) external onlyOwner {
        if (launchV2Coordinator == address(0)) revert InvalidLaunchV2();
        launchV2Enabled = enabled;
        emit LaunchV2CapabilitySet(enabled);
    }
    /// @notice One-time configuration for the isolated custom-quote release.
    /// @dev This does not affect canonical mode registry selection or state.
    function configureCustomQuoteLaunchV2(address coordinator_,address tokenFactory_,address initializer_,
        address priceSigner_) external {
        coordinator_; tokenFactory_; initializer_; priceSigner_;
        _customQuoteConfigDelegate();
    }
    function rotateCustomQuoteLaunchV2(address coordinator_,address tokenFactory_,address initializer_,
        address priceSigner_) external {
        coordinator_; tokenFactory_; initializer_; priceSigner_;
        _customQuoteConfigDelegate();
    }
    function setCustomQuoteLaunchV2Enabled(bool enabled) external {
        enabled;
        _customQuoteConfigDelegate();
    }
    function _customQuoteConfigDelegate() private {
        _customQuoteDelegateCall();
    }
    /// @dev Every custom-release selector keeps its proxy ABI but executes in
    /// the isolated immutable delegate, avoiding duplicated delegatecall code.
    function _customQuoteDelegateCall() private returns(bytes memory result) {
        address helper=address(_customQuoteReleaseDelegate);
        bool ok;
        (ok,result)=helper.delegatecall(msg.data);
        if(!ok) assembly ("memory-safe") { revert(add(result,32),mload(result)) }
    }
    function configureLaunchV2FeeSharing(address coordinator_,address tokenFactory_,address hook_,address aggregator_)
        external onlyOwner {
        if (launchV2FeeSharingCoordinator != address(0) || launchV2BuybackExecutor == address(0)) {
            revert LaunchV2AlreadyConfigured();
        }
        _setLaunchV2FeeSharingDependencies(coordinator_,tokenFactory_,hook_,aggregator_);
        emit LaunchV2FeeSharingConfigured(coordinator_,tokenFactory_,hook_,aggregator_);
    }
    /// @notice Rebinds only future fee-sharing launches; old project vaults
    /// retain their immutable graph. Rotation is unavailable while launchable.
    function rotateLaunchV2FeeSharingDependencies(address coordinator_,address tokenFactory_,address hook_,
        address aggregator_) external onlyOwner {
        if (launchV2FeeSharingEnabled || launchV2FeeSharingCoordinator == address(0)) revert InvalidLaunchV2();
        _setLaunchV2FeeSharingDependencies(coordinator_,tokenFactory_,hook_,aggregator_);
        emit LaunchV2FeeSharingDependenciesRotated(coordinator_,tokenFactory_,hook_,aggregator_);
    }
    function _setLaunchV2FeeSharingDependencies(address coordinator_,address tokenFactory_,address hook_,
        address aggregator_) private {
        if (coordinator_ == address(0) || tokenFactory_ == address(0) || hook_ == address(0)
            || aggregator_ == address(0) || coordinator_.code.length == 0 || tokenFactory_.code.length == 0
            || hook_.code.length == 0 || aggregator_.code.length == 0) revert InvalidLaunchV2();
        (address launchpad_,address factory_,address hookAttested,address executor_,address aggregatorAttested) =
            IPairV5LaunchV2FeeSharingCoordinator(coordinator_).dependencies();
        if (launchpad_ != address(this) || factory_ != tokenFactory_ || hookAttested != hook_
            || executor_ != launchV2BuybackExecutor || aggregatorAttested != aggregator_) revert InvalidLaunchV2();
        launchV2FeeSharingCoordinator = coordinator_;
        launchV2FeeSharingTokenFactory = tokenFactory_;
        launchV2FeeSharingHook = hook_;
        launchV2FeeSharingAggregator = aggregator_;
    }
    function setLaunchV2FeeSharingEnabled(bool enabled) external onlyOwner {
        if (launchV2FeeSharingCoordinator == address(0)) revert InvalidLaunchV2();
        launchV2FeeSharingEnabled = enabled;
        emit LaunchV2FeeSharingCapabilitySet(enabled);
    }
    function registerLaunchV2Vault(address projectToken,address vault) external {
        address canonicalCoordinator;
        address selectedRegistry=_selectedLaunchV2ModeRegistry();
        if (selectedRegistry != address(0)) {
            canonicalCoordinator = IPairV5LaunchV2ModeRegistry(selectedRegistry).currentCoordinator();
        }
        if ((msg.sender != launchV2Coordinator && msg.sender != launchV2FeeSharingCoordinator
                && msg.sender != canonicalCoordinator)
            || projectToken == address(0) || vault == address(0)
            || launchV2VaultOf[projectToken] != address(0)) revert InvalidLaunchV2();
        launchV2VaultOf[projectToken] = vault;
        // This mapping did not exist before the CTO release. Writing it only
        // here creates a one-way, prospective eligibility boundary.
        if (msg.sender != canonicalCoordinator) launchV2CommunityTakeoverEligible[projectToken] = true;
    }
    /// @notice Separate vault boundary for the isolated custom-quote release.
    function registerCustomQuoteLaunchV2Vault(address projectToken,address vault) external {
        projectToken; vault;
        _customQuoteConfigDelegate();
    }
    /// @notice Owner-controlled Community Takeover for eligible future V2 launches.
    /// @dev A fresh epoch makes the policy change prospective: claims and
    /// buyback buckets already allocated to an older epoch are never rewritten.
    /// Fee-sharing epoch one remains immutable; eligible future vaults may append
    /// a single-wallet Creator epoch without changing historical allocations.
    function communityTakeoverLaunchV2(address projectToken,address newCreator,uint8 newMode)
        external onlyOwner {
        // A community takeover is always a prospective single-wallet Creator
        // policy. The generic transition selector remains available for the
        // explicit BuybackBurn policy on standard V2 vaults.
        if (newMode != 0) revert InvalidLaunchV2Mode();
        _communityTakeoverLaunchV2(projectToken,newCreator,newMode);
    }
    /// @notice Redirects all future project-side V2 fees to the CTO wallet.
    function communityTakeoverLaunchV2(address projectToken,address newCreator) external onlyOwner {
        _communityTakeoverLaunchV2(projectToken,newCreator,0);
    }
    /// @notice Backwards-compatible policy transition selector.
    function transitionLaunchV2Mode(address projectToken,address creator,uint8 mode) external onlyOwner {
        // CTO-eligible releases intentionally retire owner-directed Buyback
        // transitions. Every prospective policy change routes to one wallet.
        if (mode != 0) revert InvalidLaunchV2Mode();
        _communityTakeoverLaunchV2(projectToken,creator,mode);
    }
    function _communityTakeoverLaunchV2(address projectToken,address creator,uint8 mode) private {
        address vault = launchV2VaultOf[projectToken];
        if (projectToken == address(0) || vault == address(0) || creator == address(0)) {
            revert InvalidLaunchV2();
        }
        if (mode > 1) revert InvalidLaunchV2Mode();
        if (!launchV2CommunityTakeoverEligible[projectToken]) {
            revert LaunchV2CommunityTakeoverIneligible();
        }

        IPairV5LaunchV2Vault policy = IPairV5LaunchV2Vault(vault);
        uint64 oldEpoch;
        address previousCreator;
        uint8 previousMode;
        // Attest both sides of the project/vault binding. This prevents a
        // corrupted registry entry or an incompatible vault from being called.
        try policy.epoch() returns (uint64 value) { oldEpoch = value; }
        catch { revert InvalidLaunchV2Vault(); }
        try policy.epochs(oldEpoch) returns (address value,uint8 valueMode) {
            previousCreator = value;
            previousMode = valueMode;
        } catch { revert InvalidLaunchV2Vault(); }
        (bool projectOk,address vaultProject) =
            _readAddress(vault,IPairV5LaunchV2Vault.projectToken.selector);
        (bool vaultLaunchpadOk,address vaultLaunchpad) =
            _readAddress(vault,IPairV5LaunchV2Vault.launchpad.selector);
        (bool hookOk,address vaultHook) = _readAddress(vault,IPairV5LaunchV2Vault.hook.selector);
        (bool executorOk,address vaultExecutor) =
            _readAddress(vault,IPairV5LaunchV2Vault.buybackExecutor.selector);
        (bool registrarOk,address vaultRegistrar) =
            _readAddress(vault,IPairV5LaunchV2Vault.registrar.selector);
        (bool tokenLaunchpadOk,address tokenLaunchpad) =
            _readAddress(projectToken,IPairV5LaunchV2Token.launchpad.selector);
        (bool lockerOk,address tokenLocker) =
            _readAddress(projectToken,IPairV5LaunchV2Token.locker.selector);
        (bool tokenExecutorOk,address tokenExecutor) =
            _readAddress(projectToken,IPairV5LaunchV2Token.buybackExecutor.selector);
        if (oldEpoch == 0 || previousCreator == address(0) || previousMode > 1
            || !projectOk || vaultProject != projectToken
            || !vaultLaunchpadOk || vaultLaunchpad != address(this)
            || !hookOk || vaultHook == address(0) || !executorOk || vaultExecutor == address(0)
            || !registrarOk || vaultRegistrar == address(0)
            || !tokenLaunchpadOk || tokenLaunchpad != address(this)
            || !lockerOk || tokenLocker != vault
            || !tokenExecutorOk || tokenExecutor != vaultExecutor) {
            revert InvalidLaunchV2Vault();
        }

        policy.transitionMode(creator,mode);
        uint64 newEpoch = policy.epoch();
        if (newEpoch != oldEpoch + 1) revert InvalidLaunchV2Vault();
        emit LaunchV2ModeTransitioned(projectToken,vault,newEpoch,mode);
        emit LaunchV2CommunityTakeover(
            projectToken,vault,previousCreator,creator,oldEpoch,newEpoch,previousMode,mode);
    }
    function _readAddress(address target,bytes4 selector) private view returns (bool ok,address value) {
        bytes memory result;
        (ok,result) = target.staticcall(abi.encodeWithSelector(selector));
        if (!ok || result.length != 32) return (false,address(0));
        value = abi.decode(result,(address));
    }
    function withdrawLaunchFees() external {
        (bool ok,) = payable(protocolTreasury).call{value: address(this).balance}("");
        if (!ok) revert FeeTransferFailed();
    }
}