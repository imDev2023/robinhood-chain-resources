// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @title SentryLaunchFactoryV4
 * @dev Token launch factory for the Sentry launchpad on Uniswap V4
 * (Robinhood Chain). The v4 sibling of SentryLaunchFactory (v3):
 *
 * - Deploys SentryTokenStandard tokens (1B fixed supply)
 * - Initializes a dynamic-fee v4 pool on the canonical PoolManager with
 *   the SentryDynamicFeeHook (fee decays 40% → 1.25% after launch)
 * - Adds the full supply as single-sided liquidity, with the position
 *   owned by this factory INSIDE the PoolManager singleton. There is no
 *   LP NFT and no transfer path: the liquidity is locked by construction
 *   and can only ever be touched via collectFees (delta-0 fee poke).
 * - Routes collected trading fees between creators and treasury
 *   (creatorFeeBps, default 70/30), with the same fee-recipient
 *   override/migration semantics as the v3 factory.
 * - Reuses the v3 per-base-token parameter contracts
 *   (getMintingParameters) as the price/range source.
 *
 * Upgradeable via TransparentUpgradeableProxy + ProxyAdmin; initialize()
 * replaces the constructor.
 */

import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {IHooks} from "v4-core/interfaces/IHooks.sol";
import {IUnlockCallback} from "v4-core/interfaces/callback/IUnlockCallback.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "v4-core/types/PoolId.sol";
import {Currency} from "v4-core/types/Currency.sol";
import {BalanceDelta} from "v4-core/types/BalanceDelta.sol";
import {ModifyLiquidityParams} from "v4-core/types/PoolOperation.sol";
import {LPFeeLibrary} from "v4-core/libraries/LPFeeLibrary.sol";
import {TickMath} from "v4-core/libraries/TickMath.sol";
import {StateLibrary} from "v4-core/libraries/StateLibrary.sol";
import {SentryTokenStandard} from "./SentryTokenStandard.sol";
import {SentryTokenizedStocks} from "./SentryTokenizedStocks.sol";

/// @dev Same interface as the deployed v3 parameter contracts
/// (TsunamiPoolManager on Robinhood: 0x21a6ffd6f364460d81035c48349a6e79abb37fe8).
interface ISentryMintParams {
    function getMintingParameters(address tokenAddress, address token0, address token1)
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tickLower,
            int24 tickUpper,
            uint256 amount0Desired,
            uint256 amount1Desired,
            uint256 amount0Min,
            uint256 amount1Min
        );
}

interface IERC20Minimal {
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

interface ISentryDynamicFeeHook {
    function setLaunchWhitelist(PoolId poolId, bool baseIsCurrency0, address[] calldata wallets) external;
}

/// @dev The immutable custody vault. New launches lock their liquidity
/// straight here; existing pools migrate here. The vault has no removal
/// path, so once a position is locked no upgrade to this factory can
/// touch it.
/// @dev Stock campaign tokens (SentryTokenizedStocks) expose their
/// dividend-exclusion set; migration checks it so the vault can never
/// silently accrue unclaimable reflections.
interface ISentryDividendToken {
    function dividendExcluded(address account) external view returns (bool);
}

interface ISentryLPVault {
    function lockLaunchLiquidity(
        address token,
        PoolKey calldata key,
        int24 tickLower,
        int24 tickUpper,
        uint256 amount0Max,
        uint256 amount1Max
    ) external returns (uint128 liquidity);
}

contract SentryLaunchFactoryV4 is IUnlockCallback {
    using PoolIdLibrary for PoolKey;
    using StateLibrary for IPoolManager;

    /* ─────────────────────────── Types ──────────────────────────── */

    struct LaunchInfo {
        address baseToken;
        address creator;
        address hook;      // hook at launch time; pinned so admin hook rotation never orphans a pool
        int24 tickLower;
        int24 tickUpper;
    }

    /// @dev The only unlock this factory performs is the migration
    /// liquidity removal; fee collection moved to the vault (v4 fees are
    /// paid per swap by the hooks, so launch positions never accrue).
    struct CallbackData {
        PoolKey key;
        int24 tickLower;
        int24 tickUpper;
        int256 liquidityDelta;
    }

    /* ─────────────────────── State Variables ────────────────────── */

    bool private _initialized;

    /// @dev Locks initialize() on the implementation; only the proxy can init.
    constructor() {
        _initialized = true;
    }

    // Core v4 addresses
    address public poolManager; // canonical Uniswap v4 PoolManager
    address public hook;        // SentryDynamicFeeHook used for NEW launches

    // Multi-base token support: base token → minting-parameter contract
    mapping(address => address) public baseTokenToPoolManager;
    address[] public baseTokens;

    // Constants
    int24 public constant TICK_SPACING = 200;
    uint256 private constant DEFAULT_CREATOR_FEE_BPS = 7000; // 70% of collected LP fees → creator
    uint256 private constant BPS_DENOMINATOR = 10_000;

    // Treasury — receives the non-creator share of collected fees
    address public treasury;

    // Launch tracking (keyed by token address; v4 has no LP NFT)
    mapping(address => LaunchInfo) public launches;
    mapping(address => address[]) public creatorTokens;
    uint256 public totalTokensDeployed;

    // Owner
    address public owner;

    // Reentrancy guard
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    // Creator's share of collected LP fees, in bps
    uint256 private _creatorFeeBps;

    // Fee recipient overrides, same semantics as v3: zero address means
    // fees route to the token's creator; self-service migration once per
    // token ever, owner path unlimited.
    mapping(address => address) public feeRecipients;
    mapping(address => bool) public feeRecipientMigrated;

    // Stock-paired launches. A base token with a dedicated hook uses it
    // instead of the global `hook`; a stock base additionally deploys
    // the dividend-tracking SentryTokenizedStocks standard (reflections
    // paid in the base stock) instead of SentryTokenStandard. WETH-based
    // launches are untouched: both mappings stay empty for WETH.
    // Appended for proxy storage-layout safety — never reorder above.
    mapping(address => address) public baseTokenToHook;
    mapping(address => bool) public isStockBase;

    // LP custody vault. When set, new launches lock their liquidity in
    // the immutable vault instead of self-custodying it here, and
    // migrateToVault can move already-launched positions there. Appended
    // for proxy storage-layout safety — never reorder above. Consumes two
    // slots from __gap (40 -> 38).
    address public vault;
    mapping(address => bool) public migratedToVault;
    /// @dev Vault candidate awaiting acceptVault(). Consumes a third gap slot.
    address public pendingVault;

    // Opt-in reflection route. A launch made through launchWithReflections
    // uses this hook and deploys the dividend-tracking standard with the
    // BASE ASSET as the reward token (WETH for a WETH pair), so holders
    // accrue the base rather than the campaign token. Consumes two more
    // gap slots (37 -> 35).
    address public reflectionHook;
    /// @notice Tokens that pay holder reflections, from EITHER route.
    /// Migration keys its dividend-exclusion gate off this rather than
    /// isStockBase, so a WETH-paired reflection token cannot slip past it.
    mapping(address => bool) public isReflectionToken;

    /* ──────────────────────────── Events ────────────────────────── */

    event Initialized(address indexed poolManager, address indexed hook, address indexed treasury);
    event TokenDeployed(
        address indexed token,
        string name,
        string symbol,
        address indexed creator,
        PoolId indexed poolId
    );
    event LiquidityLocked(PoolId indexed poolId, address indexed token, uint128 liquidity);
    event BaseTokenAdded(address indexed baseToken, address indexed paramSource);
    event StockBaseTokenAdded(address indexed baseToken, address indexed paramSource, address indexed stockHook);
    event BaseTokenRemoved(address indexed baseToken);
    event ParamSourceUpdated(address indexed baseToken, address oldSource, address newSource);
    event TreasuryUpdated(address oldTreasury, address newTreasury);
    event HookUpdated(address oldHook, address newHook);
    event CreatorFeeBpsUpdated(uint256 oldCreatorFeeBps, uint256 newCreatorFeeBps);
    event FeeRecipientUpdated(
        address indexed token,
        address indexed oldRecipient,
        address indexed newRecipient,
        address setBy
    );
    event VaultProposed(address indexed candidate);
    event ReflectionHookUpdated(address oldHook, address newHook);
    event VaultUpdated(address oldVault, address newVault);
    event MigratedToVault(address indexed token, PoolId indexed poolId, uint128 liquidity);


    /* ─── Custom errors (cheaper bytecode than revert strings) ─── */

    error BaseTokenExists();
    error BaseTokenMissing();
    error CreatorTransferFailed();
    error InvalidAddresses();
    error InvalidBaseToken();
    error InvalidCreatorFee();
    error InvalidHook();
    error InvalidOwner();
    error InvalidParamSource();
    error InvalidPoolManager();
    error InvalidRecipient();
    error InvalidTreasury();
    error InvalidVault();
    error MigrateTransferFailed();
    error NoPosition();
    error NotFeeAuthorized();
    error NotFeeRecipient();
    error NotPendingVault();
    error NotPoolManager();
    error NotStockBase();
    error Reentrant();
    error TickNotAligned();
    error TreasuryTransferFailed();
    error UnknownToken();
    error VaultFundingFailed();
    error VaultNotSet();

    /* ─────────────────────────── Modifiers ──────────────────────── */

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, Reentrant());
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    modifier initializer() {
        require(!_initialized, "Already initialized");
        _initialized = true;
        _;
    }

    /* ────────────────────────── Initializer ─────────────────────── */

    /**
     * @notice Replaces the constructor for proxy compatibility.
     * @param _poolManager        Canonical Uniswap v4 PoolManager
     * @param _hook               SentryDynamicFeeHook (CREATE2-mined address)
     * @param _initialBaseToken   First supported base token (e.g. WETH)
     * @param _initialParamSource Minting-parameter contract for that base token
     * @param _treasury           Address that receives treasury LP fees
     */
    function initialize(
        address _poolManager,
        address _hook,
        address _initialBaseToken,
        address _initialParamSource,
        address _treasury
    ) external initializer {
        require(_poolManager != address(0), InvalidPoolManager());
        require(_hook != address(0), InvalidHook());
        require(_initialBaseToken != address(0), InvalidBaseToken());
        require(_initialParamSource != address(0), InvalidParamSource());
        require(_treasury != address(0), InvalidTreasury());

        poolManager = _poolManager;
        hook = _hook;
        treasury = _treasury;
        owner = msg.sender; // proxy deployer becomes owner
        _status = _NOT_ENTERED;
        _creatorFeeBps = DEFAULT_CREATOR_FEE_BPS;

        baseTokenToPoolManager[_initialBaseToken] = _initialParamSource;
        baseTokens.push(_initialBaseToken);

        emit BaseTokenAdded(_initialBaseToken, _initialParamSource);
        emit Initialized(_poolManager, _hook, _treasury);
    }

    /* ─────────────────── Base Token Management ──────────────────── */

    function addBaseToken(address baseToken, address paramSource) external onlyOwner {
        require(baseToken != address(0) && paramSource != address(0), InvalidAddresses());
        require(baseTokenToPoolManager[baseToken] == address(0), BaseTokenExists());
        baseTokenToPoolManager[baseToken] = paramSource;
        baseTokens.push(baseToken);
        emit BaseTokenAdded(baseToken, paramSource);
    }

    /// @notice Register a tokenized STOCK as a base asset: its minting
    /// params, its dedicated fee hook (decay curve + holder reflections
    /// paid in the stock), and the SentryTokenizedStocks standard for
    /// tokens launched against it.
    function addStockBaseToken(address baseToken, address paramSource, address stockHook) external onlyOwner {
        require(baseToken != address(0) && paramSource != address(0) && stockHook != address(0), InvalidAddresses());
        require(baseTokenToPoolManager[baseToken] == address(0), BaseTokenExists());
        baseTokenToPoolManager[baseToken] = paramSource;
        baseTokens.push(baseToken);
        baseTokenToHook[baseToken] = stockHook;
        isStockBase[baseToken] = true;
        emit StockBaseTokenAdded(baseToken, paramSource, stockHook);
    }

    function updateParamSource(address baseToken, address newSource) external onlyOwner {
        require(baseTokenToPoolManager[baseToken] != address(0), BaseTokenMissing());
        require(newSource != address(0), InvalidParamSource());
        address oldSource = baseTokenToPoolManager[baseToken];
        baseTokenToPoolManager[baseToken] = newSource;
        emit ParamSourceUpdated(baseToken, oldSource, newSource);
    }

    function removeBaseToken(address baseToken) external onlyOwner {
        require(baseTokenToPoolManager[baseToken] != address(0), BaseTokenMissing());
        delete baseTokenToPoolManager[baseToken];
        delete baseTokenToHook[baseToken];
        delete isStockBase[baseToken];
        for (uint256 i = 0; i < baseTokens.length; i++) {
            if (baseTokens[i] == baseToken) {
                baseTokens[i] = baseTokens[baseTokens.length - 1];
                baseTokens.pop();
                break;
            }
        }
        emit BaseTokenRemoved(baseToken);
    }

    /* ───────────────────────── Token Launch ─────────────────────── */

    /**
     * @notice Launch a new token, create its dynamic-fee v4 pool, and lock
     * the full supply as single-sided liquidity owned by this factory.
     */
    function launch(
        string memory _name,
        string memory _symbol,
        address baseToken
    ) external nonReentrant returns (address tokenAddress) {
        return _launch(_name, _symbol, baseToken, new address[](0), false);
    }

    /// @notice Launch with LP fees directed to `feeRecipient` instead of
    /// the launcher. Zero address (or the launcher's own address) behaves
    /// exactly like launch().
    function launchWithFeeRecipient(
        string memory _name,
        string memory _symbol,
        address baseToken,
        address feeRecipient
    ) external nonReentrant returns (address tokenAddress) {
        tokenAddress = _launch(_name, _symbol, baseToken, new address[](0), false);
        _setFeeRecipient(tokenAddress, feeRecipient);
    }

    /// @notice Launch with a campaign whitelist: the listed wallets pay
    /// the endFee floor (1.25%) instead of the decayed launch fee when
    /// BUYING during the decay window. The whitelist is handed to the
    /// hook BEFORE the pool is initialized and is immutable afterwards.
    /// `feeRecipient` behaves as in launchWithFeeRecipient (zero = launcher).
    function launchWithWhitelist(
        string memory _name,
        string memory _symbol,
        address baseToken,
        address feeRecipient,
        address[] calldata whitelist
    ) external nonReentrant returns (address tokenAddress) {
        tokenAddress = _launch(_name, _symbol, baseToken, whitelist, false);
        _setFeeRecipient(tokenAddress, feeRecipient);
    }

    /// @notice Launch a token that pays HOLDER REFLECTIONS in the base
    /// asset (WETH for a WETH pair). Uses `reflectionHook` and deploys the
    /// dividend-tracking standard instead of the vanilla one, so holders
    /// accrue the base and claim it from the token contract. Everything
    /// else — creator fees, treasury, LP compound — behaves exactly as a
    /// regular launch. Stock bases already reflect by default and should
    /// use launch(); calling this for one changes nothing.
    /// `feeRecipient` behaves as in launchWithFeeRecipient (zero = launcher).
    function launchWithReflections(
        string memory _name,
        string memory _symbol,
        address baseToken,
        address feeRecipient,
        address[] calldata whitelist
    ) external nonReentrant returns (address tokenAddress) {
        tokenAddress = _launch(_name, _symbol, baseToken, whitelist, true);
        _setFeeRecipient(tokenAddress, feeRecipient);
    }

    function _setFeeRecipient(address tokenAddress, address feeRecipient) internal {
        if (feeRecipient != address(0) && feeRecipient != msg.sender) {
            feeRecipients[tokenAddress] = feeRecipient;
            emit FeeRecipientUpdated(tokenAddress, msg.sender, feeRecipient, msg.sender);
        }
    }

    /// @dev Addresses that must NEVER accrue stock reflections: they hold
    /// supply as infrastructure, not as holders. Excluding the vault is
    /// critical — under vault custody it holds the full supply
    /// pre-deposit and the dust after, and it is the ONLY tracked holder
    /// at launch, so if it accrued it would absorb the first swap's
    /// reflections permanently (the vault has no claim path).
    function _stockExclusions() internal view returns (address[] memory excluded) {
        address v = vault;
        excluded = new address[](v == address(0) ? 2 : 3);
        excluded[0] = poolManager;   // V4 singleton custodies pool reserves
        excluded[1] = address(this); // factory holds supply pre-deposit
        if (v != address(0)) excluded[2] = v; // vault custodies the locked LP
    }

    function _launch(
        string memory _name,
        string memory _symbol,
        address baseToken,
        address[] memory whitelist,
        bool wantReflections
    ) internal returns (address tokenAddress) {
        address paramSource = baseTokenToPoolManager[baseToken];
        require(paramSource != address(0), "Base token not supported");

        // A launch pays reflections if its base is a registered stock OR
        // the caller opted in via launchWithReflections. Either way the
        // dividend standard is deployed with the BASE as reward token and
        // the dedicated reflection hook is used.
        bool stockLaunch = isStockBase[baseToken];
        address launchHook = baseTokenToHook[baseToken];
        if (launchHook == address(0)) launchHook = hook;
        if (wantReflections && !stockLaunch) {
            require(reflectionHook != address(0), "Reflection hook unset");
            launchHook = reflectionHook;
            stockLaunch = true; // same token standard + whitelist registration
        }

        if (stockLaunch) {
            address[] memory excluded = _stockExclusions();
            tokenAddress = address(new SentryTokenizedStocks(_name, _symbol, address(this), baseToken, excluded));
        } else {
            tokenAddress = address(new SentryTokenStandard(_name, _symbol, address(this)));
        }
        totalTokensDeployed++;

        // v4 requires currency0 < currency1 (sorted by address)
        (address c0, address c1) = tokenAddress < baseToken ? (tokenAddress, baseToken) : (baseToken, tokenAddress);

        (
            uint160 sqrtPriceX96,
            int24 tickLower,
            int24 tickUpper,
            uint256 amount0Desired,
            uint256 amount1Desired,
            ,
        ) = ISentryMintParams(paramSource).getMintingParameters(tokenAddress, c0, c1);
        require(tickLower % TICK_SPACING == 0 && tickUpper % TICK_SPACING == 0, TickNotAligned());

        PoolKey memory key = PoolKey({
            currency0: Currency.wrap(c0),
            currency1: Currency.wrap(c1),
            fee: LPFeeLibrary.DYNAMIC_FEE_FLAG,
            tickSpacing: TICK_SPACING,
            hooks: IHooks(launchHook)
        });

        // Whitelist must land before initialize: the hook rejects writes
        // once the pool exists, which is what makes it launch-immutable.
        // Stock launches ALWAYS register (even with an empty whitelist):
        // that call is how SentryStockFeeHook learns which side of the
        // pair is the stock, and it refuses to initialize without it.
        // Always register: this call is how a decay hook learns which side
        // of the pair is the base, and the V3 hooks refuse to initialize
        // without it. Harmless for older hooks (they only record the flag
        // and any listed wallets).
        ISentryDynamicFeeHook(launchHook).setLaunchWhitelist(key.toId(), c0 == baseToken, whitelist);

        IPoolManager(poolManager).initialize(key, sqrtPriceX96);

        // Mint straight into the immutable vault. Hand it the full supply
        // and let it add + permanently lock the position under its OWN
        // ownership inside the PoolManager. The position is never owned by
        // this (upgradeable) factory, so no upgrade here can ever remove
        // it. This is not a separate transfer step: the vault's add IS the
        // liquidity provisioning, with the same all-or-nothing semantics
        // the self-custody path had.
        //
        // The legacy self-custody branch was REMOVED: it is dead once a
        // vault is configured, and its LiquidityAmounts/ADD_LIQUIDITY
        // machinery pushed this implementation past the EIP-170 24,576
        // byte limit. Launching therefore requires a vault.
        uint128 liquidity =
            _depositToVault(tokenAddress, key, tickLower, tickUpper, amount0Desired, amount1Desired);

        if (stockLaunch) isReflectionToken[tokenAddress] = true;

        launches[tokenAddress] = LaunchInfo({
            baseToken: baseToken,
            creator: msg.sender,
            hook: launchHook,
            tickLower: tickLower,
            tickUpper: tickUpper
        });
        creatorTokens[msg.sender].push(tokenAddress);

        PoolId poolId = key.toId();
        emit TokenDeployed(tokenAddress, _name, _symbol, msg.sender, poolId);
        emit LiquidityLocked(poolId, tokenAddress, liquidity);
    }

    /// @dev Hand the freshly minted supply to the vault and have it add +
    /// permanently lock the launch position under its own ownership.
    /// Split out of _launch to keep that frame within stack limits.
    function _depositToVault(
        address tokenAddress,
        PoolKey memory key,
        int24 tickLower,
        int24 tickUpper,
        uint256 amount0Desired,
        uint256 amount1Desired
    ) internal returns (uint128 liquidity) {
        address v = vault;
        require(v != address(0), VaultNotSet());
        uint256 bal = IERC20Minimal(tokenAddress).balanceOf(address(this));
        require(IERC20Minimal(tokenAddress).transfer(v, bal), VaultFundingFailed());
        liquidity = ISentryLPVault(v).lockLaunchLiquidity(
            tokenAddress, key, tickLower, tickUpper, amount0Desired, amount1Desired
        );
    }

    /* ─────────────────────── Fee Collection ─────────────────────── */

    /// @notice Collect accrued trading fees from a launch's locked
    /// position and route them. Callable by the factory owner, the
    /// token's creator, or the current fee recipient. Routing is
    /// identical regardless of caller.
        // NOTE: collectMultipleFees(address[]) was removed to fit EIP-170.
    // It was unused off-chain (the fee sweeper batches the v3 factory's
    // collectMultipleFees(uint256[])) and is vestigial on v4 anyway: the
    // hooks pay creator/treasury per swap, so launch positions accrue no
    // fees. Callers can loop collectFees(token) if ever needed.

            /* ─────────────────────── Unlock Callback ────────────────────── */

    /// @dev PoolManager calls back here inside unlock().
    /// ADD_LIQUIDITY: add the locked position, settle what the pool is
    /// owed from the factory's token balance.
    /// COLLECT_FEES: delta-0 poke credits accrued fees, take both sides.
    function unlockCallback(bytes calldata rawData) external returns (bytes memory) {
        require(msg.sender == poolManager, NotPoolManager());
        CallbackData memory data = abi.decode(rawData, (CallbackData));

        (BalanceDelta delta,) = IPoolManager(poolManager).modifyLiquidity(
            data.key,
            ModifyLiquidityParams({
                tickLower: data.tickLower,
                tickUpper: data.tickUpper,
                liquidityDelta: data.liquidityDelta,
                salt: bytes32(0)
            }),
            ""
        );

        int128 amount0 = delta.amount0();
        int128 amount1 = delta.amount1();

        // Removal surfaces as non-negative amounts owed TO the factory.
        // Take whatever the pool owes; the caller decodes the totals.
        uint256 amt0 = amount0 > 0 ? uint256(uint128(amount0)) : 0;
        uint256 amt1 = amount1 > 0 ? uint256(uint128(amount1)) : 0;
        if (amt0 > 0) IPoolManager(poolManager).take(data.key.currency0, address(this), amt0);
        if (amt1 > 0) IPoolManager(poolManager).take(data.key.currency1, address(this), amt1);
        return abi.encode(amt0, amt1);
    }

    /* ─────────────────────── Fee Routing ────────────────────────── */

    /// @dev Splits both sides the same way: creatorFeeBps (default 70%)
    /// to the current fee recipient, remainder to treasury. A zero
    /// recipient sends everything to treasury.
            /* ────────────────── Fee Recipient Management ────────────────── */

    function feeRecipientOf(address token) public view returns (address) {
        address override_ = feeRecipients[token];
        return override_ == address(0) ? launches[token].creator : override_;
    }

    /// @notice One-time self-service migration of a token's fee
    /// recipient. Callable only by the CURRENT recipient, once per
    /// token, ever. Further changes require the owner path.
    function migrateFeeRecipient(address token, address newRecipient) external {
        require(newRecipient != address(0), InvalidRecipient());
        address current = feeRecipientOf(token);
        require(current != address(0), UnknownToken());
        require(msg.sender == current, NotFeeRecipient());
        require(!feeRecipientMigrated[token], "Already migrated");

        feeRecipientMigrated[token] = true;
        feeRecipients[token] = newRecipient;
        emit FeeRecipientUpdated(token, current, newRecipient, msg.sender);
    }

    /// @notice Owner override, unrestricted and repeatable (CTO lever).
    function adminSetFeeRecipient(address token, address newRecipient) external onlyOwner {
        require(newRecipient != address(0), InvalidRecipient());
        require(launches[token].creator != address(0), UnknownToken());
        address old = feeRecipientOf(token);
        feeRecipients[token] = newRecipient;
        emit FeeRecipientUpdated(token, old, newRecipient, msg.sender);
    }

    /* ─────────────────────── Admin Functions ────────────────────── */

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), InvalidOwner());
        owner = newOwner;
    }

    /// @notice Step 1 of setting the LP custody vault. Two-step on
    /// purpose: `_launch` hands the vault the ENTIRE campaign supply
    /// before calling it, so a mistyped or hostile address here would
    /// forfeit a full launch in a single transaction. The candidate must
    /// prove it is the intended contract by accepting.
    function proposeVault(address newVault) external onlyOwner {
        require(newVault != address(0), InvalidVault());
        pendingVault = newVault;
        emit VaultProposed(newVault);
    }

    /// @notice Step 2: the proposed vault accepts custody itself. Being
    /// callable only by the candidate proves it is a live contract that
    /// knows this factory, which rules out EOAs and typo'd addresses.
    function acceptVault() external {
        address candidate = pendingVault;
        require(candidate != address(0) && msg.sender == candidate, NotPendingVault());
        pendingVault = address(0);
        emit VaultUpdated(vault, candidate);
        vault = candidate;
    }

    /// @notice Move an already-launched position out of this factory and
    /// into the immutable vault. Removes the factory's liquidity, hands
    /// the principal to the vault, and re-locks it under the vault's
    /// ownership at the current price. Fees are unaffected: the hook pays
    /// them per swap and reads config from this factory regardless of who
    /// owns the position. One-time per token; owner only.
    /// @dev NOTE: a supply-skimming variant was deliberately REMOVED after
    /// audit. Pulling only the token side out of a two-sided position makes
    /// the token the binding side of getLiquidityForAmounts, so the
    /// proportional BASE asset cannot be re-locked and would be stranded in
    /// the vault forever (the vault has no withdrawal path). Migration is
    /// therefore always clean: remove and re-lock the same position at the
    /// same price, which rebalances to the same liquidity. Any future
    /// treasury allocation must come from new launches, not from migration.
    function migrateToVault(address token) external onlyOwner nonReentrant {
        _migrate(token);
    }

    function _migrate(address token) internal {
        require(vault != address(0), VaultNotSet());
        LaunchInfo memory info = launches[token];
        require(info.creator != address(0), UnknownToken());
        require(!migratedToVault[token], "Already migrated");

        // A stock token's dividend-exclusion list is fixed at launch, so
        // tokens launched before vault custody do not exclude the vault.
        // If we migrated one of those, the vault would join trackedSupply
        // holding dust and accrue reflections it can never claim (no claim
        // path), permanently leaking them from real holders. The exclusion
        // must be set first by the factory owner via
        // SentryTokenizedStocks.setDividendExcluded — the factory itself
        // cannot call it (that function gates on factory.owner(), the EOA).
        // Enforce it on-chain rather than trusting a runbook step.
        if (isReflectionToken[token] || isStockBase[info.baseToken]) {
            require(ISentryDividendToken(token).dividendExcluded(vault), "Vault not dividend-excluded");
        }

        migratedToVault[token] = true;

        PoolKey memory key = poolKeyOf(token);
        PoolId poolId = key.toId();

        // Liquidity of THIS factory's locked position for the launch range.
        bytes32 positionKey = keccak256(abi.encodePacked(address(this), info.tickLower, info.tickUpper, bytes32(0)));
        uint128 liq = IPoolManager(poolManager).getPositionLiquidity(poolId, positionKey);
        require(liq > 0, NoPosition());

        // 1. Remove the factory's liquidity; both currencies land here.
        bytes memory res = IPoolManager(poolManager).unlock(
            abi.encode(
                CallbackData({
                    key: key,
                    tickLower: info.tickLower,
                    tickUpper: info.tickUpper,
                    liquidityDelta: -int256(uint256(liq))
                })
            )
        );
        (uint256 got0, uint256 got1) = abi.decode(res, (uint256, uint256));

        // 2. Hand the full removed principal to the vault. Both sides move
        //    intact — nothing is skimmed, so nothing can strand.
        if (got0 > 0) require(IERC20Minimal(Currency.unwrap(key.currency0)).transfer(vault, got0), MigrateTransferFailed());
        if (got1 > 0) require(IERC20Minimal(Currency.unwrap(key.currency1)).transfer(vault, got1), MigrateTransferFailed());

        // 3. Re-lock under the vault. It recomputes liquidity from the
        //    supplied amounts at the current price and settles from the
        //    funds we just sent; only rounding dust remains.
        uint128 locked = ISentryLPVault(vault).lockLaunchLiquidity(token, key, info.tickLower, info.tickUpper, got0, got1);
        emit MigratedToVault(token, poolId, locked);
    }

    function updateTreasury(address newTreasury) external onlyOwner {
        require(newTreasury != address(0), InvalidTreasury());
        address oldTreasury = treasury;
        treasury = newTreasury;
        emit TreasuryUpdated(oldTreasury, newTreasury);
    }

    /// @notice Swap the hook used for NEW launches (e.g. a retuned fee
    /// curve). Existing pools are immutable: their PoolKey pins the hook
    /// they launched with.
    /// @notice Set the hook used by launchWithReflections. Existing pools
    /// are immutable: their PoolKey pins the hook they launched with.
    function setReflectionHook(address newHook) external onlyOwner {
        require(newHook != address(0), InvalidHook());
        emit ReflectionHookUpdated(reflectionHook, newHook);
        reflectionHook = newHook;
    }

    function updateHook(address newHook) external onlyOwner {
        require(newHook != address(0), InvalidHook());
        address oldHook = hook;
        hook = newHook;
        emit HookUpdated(oldHook, newHook);
    }

    function creatorFeeBps() public view returns (uint256) {
        uint256 configured = _creatorFeeBps;
        return configured == 0 ? DEFAULT_CREATOR_FEE_BPS : configured;
    }

    function setCreatorFeeBps(uint256 newCreatorFeeBps) external onlyOwner {
        require(newCreatorFeeBps > 0 && newCreatorFeeBps <= BPS_DENOMINATOR, InvalidCreatorFee());
        uint256 old = creatorFeeBps();
        _creatorFeeBps = newCreatorFeeBps;
        emit CreatorFeeBpsUpdated(old, newCreatorFeeBps);
    }

    /* ─────────────────────── View Functions ─────────────────────── */

    /// @notice Reconstruct the PoolKey for a launched token.
    function poolKeyOf(address token) public view returns (PoolKey memory key) {
        LaunchInfo memory info = launches[token];
        require(info.creator != address(0), UnknownToken());
        (address c0, address c1) = token < info.baseToken ? (token, info.baseToken) : (info.baseToken, token);
        key = PoolKey({
            currency0: Currency.wrap(c0),
            currency1: Currency.wrap(c1),
            fee: LPFeeLibrary.DYNAMIC_FEE_FLAG,
            tickSpacing: TICK_SPACING,
            hooks: IHooks(info.hook)
        });
    }

    function poolIdOf(address token) external view returns (PoolId) {
        return poolKeyOf(token).toId();
    }

    function getParamSource(address baseToken) external view returns (address) {
        return baseTokenToPoolManager[baseToken];
    }

    function getSupportedBaseTokens() external view returns (address[] memory) {
        return baseTokens;
    }

    function getCreator(address token) external view returns (address) {
        return launches[token].creator;
    }

    function getCreatorTokens(address creator) external view returns (address[] memory) {
        return creatorTokens[creator];
    }

    function getCreatorTokenCount(address creator) external view returns (uint256) {
        return creatorTokens[creator].length;
    }

    function getTotalTokensDeployed() external view returns (uint256) {
        return totalTokensDeployed;
    }

    /* ─────────────── Upgrade Storage Gap ────────────────────────── */

    // Shrunk 40 -> 35: `vault`, `migratedToVault`, `pendingVault`,
    // `reflectionHook` and `isReflectionToken` consumed the gap's first
    // five slots, keeping the total storage footprint identical to the
    // deployed layout.
    uint256[35] private __gap;
}
