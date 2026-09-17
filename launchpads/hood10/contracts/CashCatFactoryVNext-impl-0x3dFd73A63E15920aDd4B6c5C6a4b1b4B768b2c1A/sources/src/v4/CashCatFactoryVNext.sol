// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Ownable2StepUpgradeable} from "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {IHooks} from "v4-core/src/interfaces/IHooks.sol";
import {Hooks} from "v4-core/src/libraries/Hooks.sol";
import {IUnlockCallback} from "v4-core/src/interfaces/callback/IUnlockCallback.sol";
import {TickMath} from "v4-core/src/libraries/TickMath.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {PoolId} from "v4-core/src/types/PoolId.sol";
import {Currency, CurrencyLibrary} from "v4-core/src/types/Currency.sol";
import {BalanceDelta} from "v4-core/src/types/BalanceDelta.sol";
import {SwapParams, ModifyLiquidityParams} from "v4-core/src/types/PoolOperation.sol";
import {CurrencySettler} from "./lib/CurrencySettler.sol";
import {LiquidityAmounts} from "./lib/LiquidityAmounts.sol";
import {Pool} from "v4-core/src/libraries/Pool.sol";
import {CashCatTokenV2} from "./CashCatTokenV2.sol";
import {CashCatHookV2} from "./CashCatHookV2.sol";
import {CashCatSelfBurnerV2} from "./CashCatSelfBurnerV2.sol";
import {CashCatLaunchSplitter} from "./CashCatLaunchSplitter.sol";

/// @title CashCatFactoryVNext
/// @notice One-transaction memecoin launches on Uniswap v4: deploys the token,
///         creates a pool carrying the CashCat hook — quoted in ether or in an
///         approved stablecoin — seeds the entire supply as single-sided
///         liquidity owned by this contract, with no code path that can ever
///         remove it, forwards the launch fee to the treasury, and optionally
///         executes the creator's first buy.
///
///         Upgradeability — sits behind a UUPS proxy so new launch modes can
///         ship over time. It holds no user funds at rest; fee custody lives
///         in the non-upgradeable hook, which upgrades can never reach.
contract CashCatFactoryVNext is Initializable, UUPSUpgradeable, Ownable2StepUpgradeable, IUnlockCallback {
    using CurrencySettler for Currency;
    using SafeERC20 for IERC20;
    using CurrencyLibrary for Currency;

    struct TokenParams {
        string name;
        string symbol;
        string logo; // ipfs://<CID> (or https URL) of the token image
        string description;
        string metadataURI; // ipfs://<CID> of the metadata JSON terminals read
        CashCatTokenV2.Socials socials;
        address creator; // receives the fee stream and the first buy
    }

    /// @notice The contracts a launch is built from, published together and
    ///         frozen. A config names one by id.
    /// @dev    Grouped rather than held as global pointers because a global
    ///         pointer means an owner call silently changes what every enabled
    ///         config produces. Here, what a config builds is fixed the moment
    ///         it is published.
    struct ModuleSet {
        address hook;
        address tokenMaster;
        address selfBurner;
        address splitterMaster;
        bool exists;
    }

    struct LaunchConfig {
        /// @dev Which module set this config builds from. Immutable.
        uint256 moduleSetId;
        // What the pool trades against. Native ETH is the zero address. Fixed
        // when the config is published and never edited, so every token born
        // under a config is denominated the same way.
        Currency quote;
        uint256 supply; // total token supply (18 decimals)
        int24 tickSpacing;
        int24 startTick; // initial price tick; sets starting FDV
        uint16 creatorFeeBps; // creator's share of hook fees
        /// @dev One flat rate for the life of the pool. There is no opening
        ///      premium and no decay.
        uint24 feeRate;
        bool enabled;
        // Self-burn mode: the creator share of fees is routed to the burner,
        // which buys the launched token and burns it — no creator earnings.
        bool selfBurn;
        bool exists;
    }

    struct LaunchCallbackData {
        PoolKey key;
        int24 startTick;
        uint256 supply;
        uint256 firstBuyIn;
        uint256 firstBuyMinOut;
        address creator;
    }

    /// @dev The scalar launch inputs, packed into memory so the shared launch
    ///      path keeps few stack slots (both modes reach it through _launch).
    struct LaunchArgs {
        uint256 configId;
        uint256 firstBuyIn;
        uint256 firstBuyMinOut;
        bytes32 salt;
    }

    /// @dev An EIP-2612 signed allowance, so a stablecoin launch is one
    ///      transaction rather than approve-then-launch.
    struct Permit {
        uint256 value;
        uint256 deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    /// @dev Where a launch's creator fee stream goes, named before the token
    ///      exists. One recipient is wired straight into the hook; two or more
    ///      get a splitter clone. Empty means the creator's own wallet, which
    ///      is what `launch` has always done.
    struct FeeRoute {
        address[] recipients;
        uint16[] shares;
    }

    error Reentrancy();
    error LaunchesPaused();
    error IncorrectValue();
    error InvalidConfigId();
    error ConfigDisabled();
    error InvalidConfig();
    error ZeroAddress();
    error EmptyString();
    error FeeTransferFailed();
    error NotPoolManager();
    error FirstBuySlippage();
    error VanityAddressRequired();
    error SaltNotFound();
    error CreatorMustBeSender();
    error BurnerNotSet();
    error BurnerMismatch();
    error NotAContract();
    /// @dev The quote's base unit is too large for the fee maths to round on.
    error QuoteDecimalsTooLow(uint256 decimals);
    /// @dev The quote does not answer `decimals()`, so its base unit cannot be
    ///      sized and the fee floor above cannot be reasoned about.
    error QuoteDecimalsUnreadable();
    error SupplyOutOfRange();
    /// A shape v4 would refuse: more liquidity at one tick than tick spacing allows.
    error SeedLiquidityAboveTickCap(uint256 seedLiquidity, uint256 cap);
    /// A payout aimed at a contract that is part of this system.
    error SelfPayment();
    /// @dev `initializeVNext` has not run, so config ids would start at zero
    ///      and reissue numbers the retired menu already used.
    error NotInitialized();
    error UnknownModuleSet();
    /// @dev A module in a set does not agree about who it works for, or
    ///      does not identify itself as one of ours.
    error ModuleMismatch();
    /// @dev A token rescue was aimed at the treasury, which is the ETH-only
    ///      revenue splitter and cannot give an ERC-20 back.
    error TreasuryCannotHoldTokens();
    error InvalidFeeRoute();
    error FeeRouteForbidden();
    error SplitterNotSet();
    error QuoteMustSortFirst();
    /// @dev An ether-quoted config has nothing to approve.
    error PermitNotApplicable();
    /// @dev The permit did not leave an allowance, however it failed.
    error PermitFailed();
    /// @dev A permit for more than the launch will spend would leave a standing
    ///      allowance to this proxy.
    error PermitValueMismatch();
    /// @dev A quote asset the owner has not listed. Code length is not a
    ///      capability check, and there is no on-chain test for the rest.
    error QuoteNotApproved();

    /// @notice A launch, in the shape the deployed factory emits it.
    ///
    /// @dev    Byte-identical to V1's, topic
    ///         0x17091df68f499cf4e20dcfc5d42f064dd22359e785b77691c4c4ed0322608897,
    ///         and that is the point of it.
    ///
    ///         Adding fields here looked free because the factory keeps its
    ///         address, and it is not: extra fields change the signature, which
    ///         changes topic0, which makes every existing filter stop matching.
    ///         `run-sweep-and-collect.sh` scans this exact string and would have
    ///         found no vNext pool ever, silently, while reporting success —
    ///         and every terminal and indexer watching the launchpad would have
    ///         done the same.
    ///
    ///         So the old event keeps its shape and the new data goes next door.
    ///         A consumer that has not been updated carries on working; one that
    ///         has reads both.
    event TokenLaunched(
        address indexed token,
        address indexed creator,
        PoolId indexed poolId,
        uint256 configId,
        uint256 firstBuyIn,
        uint256 firstBuyOut,
        address hook,
        address feeRecipient
    );

    /// @notice Everything about a launch that the legacy event cannot carry.
    ///
    /// @dev    Emitted alongside `TokenLaunched`, always, so the two are one
    ///         record split in half rather than two kinds of launch. `quote` is
    ///         the field that matters: without it a consumer cannot tell a
    ///         stablecoin launch from an ether one except by resolving
    ///         `configId` against the factory's current state, which is a
    ///         different question from what this pool launched as and answers
    ///         nothing for a config published later.
    event TokenLaunchedVNext(
        address indexed token,
        PoolId indexed poolId,
        Currency quote,
        uint256 moduleSetId,
        address splitter
    );
    event LaunchConfigAdded(uint256 indexed configId, LaunchConfig config);
    event ModuleSetPublished(uint256 indexed id, ModuleSet modules);
    event MigratedToVNext(uint256 retiredConfigCount, uint256 firstConfigId);
    event LaunchConfigEnabled(uint256 indexed configId, bool enabled);
    event QuoteApprovalUpdated(address indexed quote, bool approved);
    event LaunchFeeUpdated(uint256 oldFee, uint256 newFee);
    event LaunchEnabledUpdated(bool enabled);
    event TreasuryUpdated(address indexed oldTreasury, address indexed newTreasury);
    event FeeSplitterDeployed(PoolId indexed poolId, address indexed splitter, address[] recipients, uint16[] shares);

    // ————————————————————————————————————————————————————————————————
    //  LEGACY PREFIX, slots 0 to 8. Occupied on the deployed proxy and read
    //  after the upgrade. Reordering, retyping or removing anything here
    //  silently reinterprets live state. Proven intact by VNextLayoutFork.
    // ————————————————————————————————————————————————————————————————

    IPoolManager public poolManager; // slot 0
    /// @notice Flat fee in native ETH paid on every launch, forwarded to treasury.
    uint256 public launchFee; // slot 1
    /// @notice Receives launch fees.
    address public treasury; // slot 2

    /// @dev Retired. Was the single global hook pointer; module sets carry it.
    address private _retiredHook; // slot 3
    /// @dev Retired. vNext has its own gate, appended below.
    bool private _retiredLaunchEnabled; // slot 3 + 20

    /// @dev Retired and never read again. The live proxy holds 18 entries.
    ///      Not migrated: decoding them would need a struct shape vNext does
    ///      not have. A dynamic array of structs cannot gain a field without
    ///      changing the element stride, which is why the menu is closed rather
    ///      than extended, and why the replacement below is a mapping.
    LegacyLaunchConfig[] private _retiredConfigs; // slot 4

    uint256 private _reentrancyStatus; // slot 5

    /// @dev Retired. Module sets carry these.
    address private _retiredSelfBurner; // slot 6
    address private _retiredTokenImplementation; // slot 7
    address private _retiredDividendDistributor; // slot 8
    bool private _retiredDividendLaunchEnabled; // slot 8 + 20
    bool private _retiredLaunchWindowsEnabled; // slot 8 + 21

    /// @dev Shape of the retired array, present only so slot 4 is typed as a
    ///      dynamic array. Never decoded.
    struct LegacyLaunchConfig {
        uint256 supply;
        int24 tickSpacing;
        int24 startTick;
        uint16 creatorFeeBps;
        uint24 baseFeeRate;
        uint24 launchFeeRate;
        uint32 launchFeeDecay;
        bool enabled;
        bool selfBurn;
    }

    // ————————————————————————————————————————————————————————————————
    //  RESERVED, slots 9 and 10. Empty on the deployed proxy, and kept empty.
    //
    //  An in-place upgrade to V1, written before vNext existed, declared
    //  `launchSplitterImplementation` at slot 9 and `launchSplitterOf` at slot
    //  10. It was never deployed — the live implementation 0xcac3 carries none
    //  of those selectors and both slots read zero — and the code has since
    //  been removed from this tree, so nothing here declares them any more.
    //  vNext ships instead of that upgrade, not after it.
    //
    //  Declaring them anyway costs two slots out of thirty-seven and removes
    //  the dependency on that sentence staying true. Appending over slot 9
    //  would be safe only by coincidence — a mapping base nobody reads directly,
    //  and a count that happens to read zero — and the next person adding state
    //  would have no record that the coincidence was ever load-bearing.
    // ————————————————————————————————————————————————————————————————

    /// @dev Reserved. Never written by this implementation.
    address private _reservedSplitterImplementation; // slot 9
    /// @dev Reserved. Never written by this implementation.
    mapping(PoolId => address) private _reservedSplitterOf; // slot 10

    // ————————————————————————————————————————————————————————————————
    //  vNEXT, appended from slot 11.
    // ————————————————————————————————————————————————————————————————

    mapping(uint256 => ModuleSet) private _moduleSets; // slot 11
    uint256 public moduleSetCount; // slot 12
    /// @dev A mapping, so adding a field later cannot change how existing
    ///      entries decode. The retired array at slot 4 is what happens
    ///      otherwise.
    mapping(uint256 => LaunchConfig) private _configs; // slot 13
    uint256 public configCount; // slot 14
    bool public launchEnabled; // slot 15
    /// @notice The splitter clone serving a pool, or zero if it pays a single
    ///         address directly. Written once at launch, for discovery.
    mapping(PoolId => address) public launchSplitterOf; // slot 16
    /// @notice Quote assets a config may be published against.
    ///
    /// @dev    An explicit list, because there is no on-chain test for whether a
    ///         token is a sane thing to price a launchpad against. Code length
    ///         is not a capability check: a fee-on-transfer token, a rebasing
    ///         one, or one that simply cannot settle an ordinary swap all have
    ///         code, and a config published against one is a mode that takes a
    ///         creator's gas and produces a pool nobody can trade.
    mapping(address => bool) public approvedQuote; // slot 17

    /// @notice The same two bounds the hook applies when a pool registers.
    uint256 public constant BPS_DENOMINATOR = 10_000;
    /// @notice The advertised product ceiling, enforced. The factory this
    ///         replaces permitted nine times it.
    uint24 public constant MAX_FEE_RATE = 100_000; // 10%

    /// @notice The fewest decimals a quote asset may have.
    ///
    /// @dev    The hook charges `amount * rate / 1e6` and truncates, so a leg
    ///         below `1e6 / rate` base units pays nothing. At the menu's lowest
    ///         rate of 1% that is 100 base units, and whether 100 base units is
    ///         dust or money depends entirely on the decimals: at six it is a
    ///         hundredth of a cent, at two it is a dollar, at zero it is a
    ///         hundred whole tokens. A low-decimal quote would let a router
    ///         split a trade into legs under the threshold and pay no fee at
    ///         all, bleeding both the creator and the platform.
    ///
    ///         Six is a floor chosen here, not a limit of what exists — GUSD
    ///         is two, which is the case this refuses. At six, a dollar-priced
    ///         quote puts the free window at a hundredth of a cent, four orders
    ///         under a dollar, which is dust against any gas price worth
    ///         paying. Native ether never reaches this check: it is
    ///         `address(0)` and every approval test skips it.
    ///
    ///         Decimals is a proxy for the thing that actually matters, which
    ///         is what one base unit is worth. The two only track each other
    ///         while a quote is priced near a dollar, which every quote worth
    ///         listing is.
    uint8 public constant MIN_QUOTE_DECIMALS = 6;
    uint8 private constant VANITY_PREFIX = 0xCC;
    uint24 public constant PIPS_PER_BP = 100;

    /// @notice vNext config ids start here, above anything the retired menu
    ///         used.
    ///
    /// @dev    The factory keeps its address, so config ids restarting at zero
    ///         would have vNext reusing 0 to 17 on the same contract that
    ///         already issued them. Two different launch modes would answer to
    ///         one id depending on when you asked, which breaks the indexer's
    ///         existing rows and lets a client holding a stale id launch under
    ///         something unrelated — the legacy 0 was the flat 1% standard, and
    ///         a vNext 0 could be anything at all.
    ///
    ///         A gap rather than 18, so the two ranges are obviously distinct
    ///         when read by a human and an off-by-one cannot close it.
    uint256 public constant FIRST_CONFIG_ID = 1_000;

    /// @notice What a module must answer to be publishable. See
    ///         `CashCatTokenV2.GENERATION`.
    uint256 public constant MODULE_GENERATION = 2;

    /// @dev The callback permissions the launch path depends on, encoded in the
    ///      low bits of a hook's address. A hook mined without them registers
    ///      fine and then never gets called.
    uint160 internal constant REQUIRED_HOOK_FLAGS = uint160(
        Hooks.BEFORE_INITIALIZE_FLAG | Hooks.BEFORE_ADD_LIQUIDITY_FLAG | Hooks.BEFORE_REMOVE_LIQUIDITY_FLAG
            | Hooks.BEFORE_SWAP_FLAG | Hooks.AFTER_SWAP_FLAG | Hooks.BEFORE_DONATE_FLAG
            | Hooks.BEFORE_SWAP_RETURNS_DELTA_FLAG | Hooks.AFTER_SWAP_RETURNS_DELTA_FLAG
    );
    uint256 private constant _UNLOCKED = 1;
    uint256 private constant _LOCKED = 2;

    modifier nonReentrant() {
        if (_reentrancyStatus == _LOCKED) revert Reentrancy();
        _reentrancyStatus = _LOCKED;
        _;
        _reentrancyStatus = _UNLOCKED;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Run once, through `upgradeToAndCall`, when the live proxy moves
    ///         to this implementation. A reinitializer rather than an
    ///         initializer: owner, treasury, launch fee and pool manager are
    ///         already correct on the proxy. This closes the old menu and opens
    ///         the new id range.
    ///
    /// @dev    `onlyOwner` as well as `reinitializer`. The reinitializer alone
    ///         is single-shot but not owner-only, so an upgrade performed
    ///         without this call would leave it open for anyone to spend, and a
    ///         reinitializer that has been spent cannot be spent again.
    function initializeVNext() external onlyOwner reinitializer(2) {
        _retiredLaunchEnabled = false;
        configCount = FIRST_CONFIG_ID;
        emit MigratedToVNext(_retiredConfigs.length, FIRST_CONFIG_ID);
    }

    // —————————————————————————— launching ——————————————————————————

    /// @notice Launch a token.
    ///
    ///         The launch fee is always ether. How the first buy is paid depends
    ///         on the config's quote: for an ether pool `msg.value` must equal
    ///         `launchFee + firstBuyIn` exactly, and for a token-quoted pool it
    ///         must equal `launchFee` alone, with `firstBuyIn` pulled from the
    ///         caller by `transferFrom` — so approve first, or use
    ///         `launchWithPermit` and sign instead.
    ///
    ///         `firstBuyIn` is swapped into the new token for the creator in the
    ///         same transaction, at the pool's one flat rate.
    /// @dev Simulate via `eth_call` first: the return values give the token
    ///      address and pool id.
    function launch(
        TokenParams calldata params,
        uint256 configId,
        uint256 firstBuyIn,
        uint256 firstBuyMinOut,
        bytes32 salt
    ) external payable nonReentrant returns (address token, PoolId poolId) {
        FeeRoute memory noRoute;
        return _launch(params, LaunchArgs(configId, firstBuyIn, firstBuyMinOut, salt), noRoute);
    }

    /// @notice Launch a token whose fee stream belongs to someone other than
    ///         the launcher, or is divided between up to four addresses, with
    ///         the destination fixed before the token exists.
    ///
    /// @dev    Naming the destination up front is the whole point. The old way
    ///         round — launch, then hand the stream on — leaves a window during
    ///         which fees accrue to the launcher, and on a hyped launch that
    ///         window is exactly when the volume is. A charity token that has
    ///         to be reassigned afterwards is a promise; this is a fact.
    ///
    ///         `shares` are basis points and must sum to BPS_DENOMINATOR. One
    ///         recipient is written straight into the hook and can later be
    ///         moved with `updateCreator`; two or more get a splitter clone
    ///         whose shares can never be edited by anyone, including us.
    ///
    ///         Self-burn configs are refused: that mode already spends the
    ///         creator stream on buying and burning, so there is nothing left
    ///         for a split to divide.
    /// @notice A stablecoin launch in one transaction.
    ///
    /// @dev    A token-quoted first buy is pulled with `transferFrom`, so it
    ///         needs an allowance — which means approve, then launch. Two
    ///         transactions, from a product whose whole pitch is one. Nobody had
    ///         noticed because ether launches, which is all anything had ever
    ///         been tested against, arrive as `msg.value` and need no approval.
    ///
    ///         An EIP-2612 quote asset can sign the allowance instead, and this
    ///         spends it in the same call. Pass an empty `recipients` array for
    ///         an ordinary launch; the split path and the plain path are one
    ///         function here rather than two, because the factory is close
    ///         enough to the size limit that a duplicate is not free.
    ///
    ///         The permit is allowed to fail. A signature sitting in the mempool
    ///         can be lifted and submitted by anyone, which consumes the nonce
    ///         and makes ours revert — a well-known way to grief a permit-based
    ///         call into failing. Whoever submitted it, the allowance is what
    ///         matters, so that is what is checked.
    function launchWithPermit(
        TokenParams calldata params,
        uint256 configId,
        uint256 firstBuyIn,
        uint256 firstBuyMinOut,
        bytes32 salt,
        address[] calldata recipients,
        uint16[] calldata shares,
        Permit calldata p
    ) external payable nonReentrant returns (address token, PoolId poolId) {
        _applyPermit(configId, firstBuyIn, p);
        // Empty recipients with non-empty shares read as an ordinary launch and
        // silently discard the shares. The split entrypoint rejects a mismatch;
        // this one has to as well.
        if (recipients.length != shares.length) revert InvalidFeeRoute();
        FeeRoute memory route;
        if (recipients.length > 0) route = FeeRoute(recipients, shares);
        return _launch(params, LaunchArgs(configId, firstBuyIn, firstBuyMinOut, salt), route);
    }

    /// @dev Split out to keep the caller's stack short enough to compile.
    ///
    ///      The signature has to be for exactly the amount being spent. An
    ///      oversized permit leaves the difference approved to this contract
    ///      afterwards — a standing allowance to an upgradeable proxy, granted
    ///      by someone who thought they were authorising one launch. There is no
    ///      reason to want it, so it is refused rather than documented.
    ///
    ///      And a zero first buy has nothing to approve, so reaching this
    ///      entrypoint with one means the caller believes something that is not
    ///      true. `launch` is the function they wanted.
    function _applyPermit(uint256 configId, uint256 firstBuyIn, Permit calldata p) private {
        _requireConfigExists(configId);
        Currency quote = _configs[configId].quote;
        if (quote.isAddressZero()) revert PermitNotApplicable();
        if (firstBuyIn == 0) revert PermitNotApplicable();
        if (p.value != firstBuyIn) revert PermitValueMismatch();

        address asset = Currency.unwrap(quote);
        // The permit is allowed to fail. A signature sitting in the mempool can
        // be lifted and submitted by anyone, which consumes the nonce and makes
        // this revert — a well-known way to grief a permit-based call. What
        // matters is the allowance, whoever created it, so that is what is
        // checked, and it is checked either way rather than only on the failure
        // path: a permit that returns successfully without granting anything is
        // a token misbehaving, not a reason to carry on.
        try IERC20Permit(asset).permit(msg.sender, address(this), p.value, p.deadline, p.v, p.r, p.s) {}
        catch {}
        if (IERC20(asset).allowance(msg.sender, address(this)) < firstBuyIn) revert PermitFailed();
    }

    function launchWithFeeSplit(
        TokenParams calldata params,
        uint256 configId,
        uint256 firstBuyIn,
        uint256 firstBuyMinOut,
        bytes32 salt,
        address[] calldata recipients,
        uint16[] calldata shares
    ) external payable nonReentrant returns (address token, PoolId poolId) {
        if (recipients.length == 0) revert InvalidFeeRoute();
        return _launch(
            params,
            LaunchArgs(configId, firstBuyIn, firstBuyMinOut, salt),
            FeeRoute(recipients, shares)
        );
    }

    /// @dev Simulate via `eth_call` first: the return values give the token
    ///      address and pool id. For an ether pool `msg.value` must equal
    ///      `launchFee + firstBuyIn`
    ///      exactly. `firstBuyIn` is swapped into the new token for the creator
    ///      in the same transaction; it pays the base fee rate.
    function _launch(
        TokenParams calldata params,
        LaunchArgs memory a,
        FeeRoute memory route
    ) private returns (address token, PoolId poolId) {
        if (!launchEnabled) revert LaunchesPaused();
        _requireConfigExists(a.configId);
        LaunchConfig memory config = _configs[a.configId];
        if (!config.enabled) revert ConfigDisabled();
        // Checked here and not only at publication. An enabled config carries
        // an approval that was true when it was enabled; withdrawing the asset
        // has to stop new launches by itself, without the owner having to find
        // and disable every config that names it.
        if (!config.quote.isAddressZero() && !approvedQuote[Currency.unwrap(config.quote)]) {
            revert QuoteNotApproved();
        }
        ModuleSet memory mods = _moduleSets[config.moduleSetId];
        // The launch fee is always ETH, whatever the pool is quoted in, so the
        // treasury only ever holds one asset. A token-quoted first buy is
        // pulled from the creator instead of arriving as value.
        if (config.quote.isAddressZero()) {
            if (msg.value != launchFee + a.firstBuyIn) revert IncorrectValue();
        } else {
            if (msg.value != launchFee) revert IncorrectValue();
            if (a.firstBuyIn > 0) {
                IERC20(Currency.unwrap(config.quote)).safeTransferFrom(msg.sender, address(this), a.firstBuyIn);
            }
        }
        if (bytes(params.name).length == 0 || bytes(params.symbol).length == 0) revert EmptyString();
        // creator identity must be earned by signing the launch — otherwise
        // anyone could pin a token (and its on-chain paper trail) on a wallet
        // that never consented. So a contract or bot launching on someone
        // else's behalf is itself the creator, and the first buy lands on it.
        // The fee stream is the part that can belong to someone else, and
        // `launchWithFeeSplit` names them at launch rather than afterwards.
        if (params.creator != msg.sender) revert CreatorMustBeSender();

        // Bind the salt to the caller so nobody can snipe a pending token
        // address. The token is an EIP-1167 clone of the master, created and
        // initialized in this same transaction — it can never be observed
        // uninitialized, and its pointer to the master is fixed in bytecode.
        token = Clones.cloneDeterministic(mods.tokenMaster, keccak256(abi.encode(msg.sender, a.salt)));
        // The quality stamp: every CashCat token address ends in a clean,
        // lowercase "cc" — through any interface, ours or not. Callers find a
        // matching salt with the free `mineSalt` view first.
        if (!_hasVanitySuffix(token)) revert VanityAddressRequired();
        CashCatTokenV2(token).initialize(_tokenConfig(params, config));

        // v4 orders a key's currencies by address, and the launched token must
        // come second. Native ETH is address zero so this was free; an ERC-20
        // quote is not, and a token that mined an address below it would invert
        // the pool. Everything downstream — which side the fee is taken on,
        // which direction a buy is, whether the single-sided seed sits above or
        // below the price — is written for token-as-currency1.
        //
        // Handling both orderings was the alternative. It was rejected: the
        // tick semantics invert with the sides, so the same code would take two
        // meanings depending on an address nobody chose deliberately, and the
        // wrong one would only show up for some launches. An enforced invariant
        // fails loudly instead, and the salt search below already satisfies it.
        if (Currency.unwrap(config.quote) >= token) revert QuoteMustSortFirst();
        PoolKey memory key = PoolKey({
            currency0: config.quote,
            currency1: Currency.wrap(token),
            fee: 0, // all fees flow through the hook, in the quote asset
            tickSpacing: config.tickSpacing,
            hooks: IHooks(mods.hook)
        });
        poolId = key.toId();

        // Resolved before `_wirePool` rather than inside it, so the wiring
        // path keeps its arity and its stack depth.
        address defaultRecipient = params.creator;
        if (route.recipients.length != 0) {
            if (config.selfBurn) revert FeeRouteForbidden();
            defaultRecipient = _wireFeeRoute(poolId, config.quote, route, mods, token);
        }

        address feeRecipient = _wirePool(key, poolId, token, defaultRecipient, config, mods);
        _seedAndSettle(
            key,
            config,
            a.firstBuyIn,
            a.firstBuyMinOut,
            params.creator,
            a.configId,
            token,
            feeRecipient
        );
    }

    /// @dev Turns a fee route into the single address the hook will pay.
    ///
    ///      One recipient needs no splitter: the hook already holds exactly one
    ///      address per pool, so pointing it at somebody else costs nothing and
    ///      leaves `updateCreator` working as it always has.
    ///
    ///      Two or more get a clone. The share rules live in the splitter and
    ///      are not restated here: a second opinion about what a valid split is
    ///      is how a config gets accepted in one place and refused in another.
    ///      The one-recipient case is the exception, since no splitter is
    ///      deployed to hold an opinion, so its share is checked here and the
    ///      suite pins this contract's denominator against the splitter's.
    function _wireFeeRoute(PoolId poolId, Currency quote, FeeRoute memory route, ModuleSet memory mods, address token)
        private
        returns (address recipient)
    {
        address splitterMaster = mods.splitterMaster;
        address feeSource = mods.hook;
        uint256 n = route.recipients.length;
        if (n != route.shares.length) revert InvalidFeeRoute();

        // None of the addresses this system is made of can hold a fee stream:
        // each would either strand the share or double-count it, and none has a
        // path to claim. They are refused here because the factory is the only
        // party that knows all four.
        //
        // This does not make a recipient reachable, and nothing can. A stream
        // may be aimed at any contract that cannot claim, exactly as a transfer
        // may be aimed at one that cannot spend — the launcher is choosing where
        // their own fees go, and refusing contracts would refuse the multisigs
        // and cold wallets the feature exists for. Same reasoning as
        // `updateCreator`, which says so at its own definition.
        for (uint256 i; i < n; ++i) {
            _requireNotOurs(route.recipients[i], quote, mods, token);
        }

        if (n == 1) {
            if (route.recipients[0] == address(0)) revert InvalidFeeRoute();
            if (route.shares[0] != BPS_DENOMINATOR) revert InvalidFeeRoute();
            return route.recipients[0];
        }

        if (splitterMaster == address(0)) revert SplitterNotSet();
        // Salted on the pool so the splitter address is derivable off-chain
        // before the launch lands, the same way the token address is.
        recipient = Clones.cloneDeterministic(splitterMaster, PoolId.unwrap(poolId));
        CashCatLaunchSplitter(payable(recipient)).initialize(
            feeSource, PoolId.unwrap(poolId), Currency.unwrap(quote), route.recipients, route.shares
        );
        launchSplitterOf[poolId] = recipient;
        emit FeeSplitterDeployed(poolId, recipient, route.recipients, route.shares);
    }

    /// @dev Refuses the four addresses that make up this system. A share aimed
    ///      at any of them is stranded or double-counted rather than paid: the
    ///      factory and the pool manager have no claim path, the hook would be
    ///      paying itself out of the balance backing every other pool, and the
    ///      quote token holds the asset rather than receives it.
    function _requireNotOurs(address who, Currency quote, ModuleSet memory mods, address token) private view {
        if (
            who == address(this) || who == address(poolManager) || who == Currency.unwrap(quote) || who == token
                || who == mods.hook || who == mods.tokenMaster || who == mods.selfBurner
                || who == mods.splitterMaster
        ) revert InvalidFeeRoute();
    }

    /// @dev The launch tail: seed liquidity + optional first buy inside the
    ///      unlock, forward the launch fee, announce. Split out to keep
    ///      `_launch`'s stack shallow.
    function _seedAndSettle(
        PoolKey memory key,
        LaunchConfig memory config,
        uint256 firstBuyIn,
        uint256 firstBuyMinOut,
        address creator,
        uint256 configId,
        address token,
        address feeRecipient
    ) private {
        bytes memory result = poolManager.unlock(
            abi.encode(
                LaunchCallbackData({
                    key: key,
                    startTick: config.startTick,
                    supply: config.supply,
                    firstBuyIn: firstBuyIn,
                    firstBuyMinOut: firstBuyMinOut,
                    creator: creator
                })
            )
        );
        uint256 firstBuyOut = abi.decode(result, (uint256));

        (bool feePaid,) = treasury.call{value: launchFee}("");
        if (!feePaid) revert FeeTransferFailed();

        // Emitted from its own frame: reading the hook off the key here put
        // `_seedAndSettle` over the stack limit.
        _announce(key, token, creator, configId, firstBuyIn, firstBuyOut, feeRecipient);
    }

    /// @dev A frame of its own. Reading the pool id and the hook off the key
    ///      inside `_seedAndSettle` put it over the stack limit.
    function _announce(
        PoolKey memory key,
        address token,
        address creator,
        uint256 configId,
        uint256 firstBuyIn,
        uint256 firstBuyOut,
        address feeRecipient
    ) private {
        emit TokenLaunched(
            token, creator, key.toId(), configId, firstBuyIn, firstBuyOut, address(key.hooks), feeRecipient
        );
        emit TokenLaunchedVNext(
            token,
            key.toId(),
            key.currency0,
            _configs[configId].moduleSetId,
            launchSplitterOf[key.toId()]
        );
    }

    /// @dev Chooses the fee recipient, registers the pool with the hook and
    ///      (for self-burn mode) its burner, then initializes
    ///      the pool. Split out of `_launch` to keep that frame's stack small.
    ///        self-burn -> the burner buys and destroys the token
    ///        otherwise -> the creator's own wallet
    ///      The human creator always keeps the first buy and the deployer credit.
    function _wirePool(
        PoolKey memory key,
        PoolId poolId,
        address token,
        address defaultRecipient,
        LaunchConfig memory config,
        ModuleSet memory mods
    ) private returns (address feeRecipient) {
        feeRecipient = defaultRecipient;
        CashCatHookV2 hook = CashCatHookV2(payable(mods.hook));
        CashCatSelfBurnerV2 selfBurner = CashCatSelfBurnerV2(payable(mods.selfBurner));
        if (config.selfBurn) {
            if (mods.selfBurner == address(0)) revert BurnerNotSet();
            // a burner bound to a stale hook could never claim this pool's
            // stream — refuse to launch into a stranded configuration (guards
            // the window between setHook and setSelfBurner too)
            if (address(selfBurner.hook()) != mods.hook) revert BurnerMismatch();
            feeRecipient = mods.selfBurner;
        }

        hook.register(poolId, feeRecipient, config.quote, config.creatorFeeBps, config.feeRate);
        if (config.selfBurn) selfBurner.register(poolId, key);
        poolManager.initialize(key, TickMath.getSqrtPriceAtTick(config.startTick));
        CashCatTokenV2(token).initializePool(PoolId.unwrap(poolId), mods.hook);
    }

    /// @dev Seeds the full supply as a token-only range below the starting
    ///      tick, owned by this contract forever, then executes the optional
    ///      first buy. Runs inside the PoolManager unlock.
    function unlockCallback(bytes calldata rawData) external returns (bytes memory) {
        if (msg.sender != address(poolManager)) revert NotPoolManager();
        LaunchCallbackData memory data = abi.decode(rawData, (LaunchCallbackData));

        int24 minTick = TickMath.minUsableTick(data.key.tickSpacing);
        uint128 liquidity = LiquidityAmounts.getLiquidityForAmount1(
            TickMath.getSqrtPriceAtTick(minTick), TickMath.getSqrtPriceAtTick(data.startTick), data.supply
        );
        (BalanceDelta delta,) = poolManager.modifyLiquidity(
            data.key,
            ModifyLiquidityParams({
                tickLower: minTick, tickUpper: data.startTick, liquidityDelta: int256(uint256(liquidity)), salt: 0
            }),
            ""
        );
        data.key.currency1.settle(poolManager, address(this), uint256(uint128(-delta.amount1())), false);

        uint256 firstBuyOut = 0;
        if (data.firstBuyIn > 0) {
            BalanceDelta swapDelta = poolManager.swap(
                data.key,
                SwapParams({
                    zeroForOne: true,
                    amountSpecified: -int256(data.firstBuyIn),
                    sqrtPriceLimitX96: TickMath.MIN_SQRT_PRICE + 1
                }),
                ""
            );
            firstBuyOut = uint256(uint128(swapDelta.amount1()));
            if (firstBuyOut < data.firstBuyMinOut) revert FirstBuySlippage();
            data.key.currency0.settle(poolManager, address(this), uint256(uint128(-swapDelta.amount0())), false);
            data.key.currency1.take(poolManager, data.creator, firstBuyOut, false);
        }
        return abi.encode(firstBuyOut);
    }

    /// @notice Predicts the token address `launch` would deploy for this
    ///         sender/salt (CREATE2). The params/configId arguments are kept
    ///         for ABI stability but no longer affect the address: a clone's
    ///         init code is constant, so only sender and salt matter.
    function predictTokenAddress(TokenParams calldata, uint256 configId, address sender, bytes32 salt)
        external
        view
        returns (address)
    {
        _requireConfigExists(configId);
        return _predict(_moduleSets[_configs[configId].moduleSetId].tokenMaster, sender, salt);
    }

    /// @notice Finds a salt whose token address carries the "cc" stamp, for
    ///         `sender` launching `params` under `configId`. Read-only and
    ///         free via eth_call; a hit needs ~1k tries on average, so a few
    ///         thousand `rounds` nearly always suffice — on a miss, call again
    ///         with the next `start` window. Launching through any interface
    ///         starts here: `launch` rejects addresses without the stamp.
    function mineSalt(TokenParams calldata, uint256 configId, address sender, uint256 start, uint256 rounds)
        external
        view
        returns (bytes32 salt, address token)
    {
        _requireConfigExists(configId);
        // The launch enforces both of these, so the search has to satisfy both.
        // Against native ETH the ordering is free; against an ERC-20 quote it
        // discards the addresses that sort below it, which costs roughly a
        // factor of two on a mid-range quote and nothing at all on a low one.
        address quote = Currency.unwrap(_configs[configId].quote);
        address master = _moduleSets[_configs[configId].moduleSetId].tokenMaster;
        for (uint256 i = 0; i < rounds; i++) {
            salt = bytes32(start + i);
            token = _predict(master, sender, salt);
            if (_hasVanitySuffix(token) && quote < token) return (salt, token);
        }
        revert SaltNotFound();
    }

    /// @dev Where `launch` would place the clone for this sender/salt —
    ///      mirrors Clones.cloneDeterministic exactly.
    function _predict(address master, address sender, bytes32 salt) private view returns (address) {
        return Clones.predictDeterministicAddress(master, keccak256(abi.encode(sender, salt)), address(this));
    }

    /// @dev True when the address ends in byte 0xcc AND its EIP-55 checksum
    ///      renders both trailing characters lowercase — explorers and wallets
    ///      then always display a clean "…cc", never "…cC" or "…CC".
    function _hasVanitySuffix(address token) internal pure returns (bool) {
        if (uint8(uint160(token)) != VANITY_PREFIX) return false;
        bytes memory hexChars = "0123456789abcdef";
        bytes memory str = new bytes(40);
        uint160 value = uint160(token);
        for (uint256 i = 40; i > 0; i--) {
            str[i - 1] = hexChars[value & 0xf];
            value >>= 4;
        }
        bytes32 checksum = keccak256(str);
        // the trailing "cc" is hex chars 38 and 39 — the two nibbles of
        // checksum byte 19; EIP-55 keeps a character lowercase when its
        // checksum nibble is below 8
        return uint8(checksum[19]) >> 4 < 8 && uint8(checksum[19]) & 0xf < 8;
    }

    function _tokenConfig(TokenParams calldata params, LaunchConfig memory config)
        private
        pure
        returns (CashCatTokenV2.TokenConfig memory)
    {
        return CashCatTokenV2.TokenConfig({
            name: params.name,
            symbol: params.symbol,
            logo: params.logo,
            description: params.description,
            metadataURI: params.metadataURI,
            socials: params.socials,
            creator: params.creator,
            supply: config.supply,
            // pips -> basis points, rounded up so this never reads below the
            // rate actually charged. There is one rate for the life of the
            // pool — no opening premium and no decay — so unlike the previous
            // generation this figure is what a trade pays rather than a floor
            // beneath it. `buyTaxRate` still reads the hook live, because the
            // hook is what enforces it.
            taxBps: uint24((config.feeRate + (PIPS_PER_BP - 1)) / PIPS_PER_BP)
        });
    }

    // —————————————————————————— admin ——————————————————————————

    /// @dev Every entry point taking a `configId` goes through this. It was
    ///      three copies of the same comparison, and two functions that should
    ///      have had it did not — an owner or a frontend passing an id that does
    ///      not exist got a bare array panic instead of a named error. One
    ///      definition means the next entry point cannot quietly omit it.
    function _requireConfigExists(uint256 configId) private view {
        if (!_configs[configId].exists) revert InvalidConfigId();
    }


    /// @notice Publishes a set of modules that configs can then name. Frozen
    ///         once published.
    ///
    /// @dev    Checked properly rather than for code length, because a module
    ///         set is permanent and its mistakes are permanent with it. A
    ///         self-burner wired to the right hook and the wrong PoolManager
    ///         passes a code-length check, launches, becomes the pool's fee
    ///         recipient forever, and then fails every burn — with the fees
    ///         still arriving. Nothing can be repointed afterwards, by design.
    ///
    ///         So each module is asked to identify itself and to agree about
    ///         who it works for. A wrong answer costs a rejected transaction
    ///         here instead of a stranded pool later.
    function publishModuleSet(address hook_, address tokenMaster, address selfBurner_, address splitterMaster)
        external
        onlyOwner
        returns (uint256 id)
    {
        if (hook_ == address(0) || tokenMaster == address(0)) revert ZeroAddress();
        if (hook_.code.length == 0 || tokenMaster.code.length == 0) revert NotAContract();

        _requireHook(hook_);
        _requireTokenMaster(tokenMaster);
        if (selfBurner_ != address(0)) _requireSelfBurner(selfBurner_, hook_);
        if (splitterMaster != address(0)) _requireSplitterMaster(splitterMaster);

        id = moduleSetCount++;
        _moduleSets[id] = ModuleSet(hook_, tokenMaster, selfBurner_, splitterMaster, true);
        emit ModuleSetPublished(id, _moduleSets[id]);
    }

    /// @dev The hook must serve this factory and this PoolManager, carry the
    ///      callback permissions the launch path needs, and promise a ceiling no
    ///      looser than the one advertised here. That last one matters because
    ///      the hook is immutable and this contract is not: whatever it enforces
    ///      is the real limit, so a hook permitting more than the product claims
    ///      cannot be adopted however tight this factory happens to be today.
    function _requireHook(address hook_) private view {
        CashCatHookV2 h = CashCatHookV2(payable(hook_));
        if (h.factory() != address(this)) revert ModuleMismatch();
        if (address(h.poolManager()) != address(poolManager)) revert ModuleMismatch();
        if (uint160(hook_) & REQUIRED_HOOK_FLAGS != REQUIRED_HOOK_FLAGS) revert ModuleMismatch();
        if (h.MAX_FEE_RATE() > MAX_FEE_RATE) revert ModuleMismatch();
    }

    /// @dev A positive identification, not a version comparison: the V1 master
    ///      does not answer `GENERATION` at all, so a call to it reverts and the
    ///      set is refused. A V1 master would otherwise launch and then fail on
    ///      `initializePool`, since it reads a `hook()` this factory no longer
    ///      exposes.
    ///
    ///      `GENERATION` alone does not identify a token, because the splitter
    ///      master declares the same generation — so a splitter passed in this
    ///      slot answered the only question asked and published, with the
    ///      mistake surfacing as a revert on the first launch instead of on the
    ///      transaction that made it. `PIPS_PER_BP` is on the token and nothing
    ///      else, so the pair distinguishes them.
    function _requireTokenMaster(address tokenMaster) private view {
        CashCatTokenV2 t = CashCatTokenV2(tokenMaster);
        if (t.GENERATION() != MODULE_GENERATION) revert ModuleMismatch();
        if (t.PIPS_PER_BP() != 100) revert ModuleMismatch();
    }

    /// @dev The burner must agree with the hook it is being published alongside,
    ///      not merely with some hook. It is checked at launch too, but by then
    ///      the config is enabled and the failure is a creator's.
    function _requireSelfBurner(address selfBurner_, address hook_) private view {
        if (selfBurner_.code.length == 0) revert NotAContract();
        CashCatSelfBurnerV2 b = CashCatSelfBurnerV2(payable(selfBurner_));
        if (b.factory() != address(this)) revert ModuleMismatch();
        if (address(b.hook()) != hook_) revert ModuleMismatch();
        if (address(b.poolManager()) != address(poolManager)) revert ModuleMismatch();
    }

    /// @dev A master, not a live clone: an initialized splitter already serves
    ///      somebody's pool, and cloning from it would still work while making
    ///      the registry read as though it did not.
    ///
    ///      Identified positively, by `isMaster`, rather than by having an empty
    ///      `feeSource`. The negative test was the whole of a griefing vector:
    ///      the master had no constructor lock, so a stranger could call
    ///      `initialize` on it for the price of a transaction and this check
    ///      would then reject it forever, with redeployment the only recovery.
    ///      A master now says what it is, and the constructor makes that
    ///      unspendable.
    function _requireSplitterMaster(address splitterMaster) private view {
        if (splitterMaster.code.length == 0) revert NotAContract();
        CashCatLaunchSplitter s = CashCatLaunchSplitter(payable(splitterMaster));
        if (s.GENERATION() != MODULE_GENERATION) revert ModuleMismatch();
        if (s.BPS_DENOMINATOR() != BPS_DENOMINATOR) revert ModuleMismatch();
        if (!s.isMaster()) revert ModuleMismatch();
    }

    /// @notice Publishes a launch mode.
    ///
    /// @dev    An enabled config must be launchable. Everything here is a shape
    ///         that would otherwise be published, offered to creators, and then
    ///         revert on whoever tried it first — after they had paid for a
    ///         clone, a token and a hook registration.
    ///
    ///         Most of this is V1's validation, which was dropped in the port.
    ///         `SupplyOutOfRange` was still declared and never thrown, which is
    ///         how the gap showed. It is not purely cosmetic: an oversized
    ///         supply reaches `SafeCast` inside the vendored liquidity library
    ///         and reverts there instead, so the owner gets an anonymous
    ///         overflow from a dependency rather than a named error, and only
    ///         once a creator has paid gas to find it.
    function publishConfig(LaunchConfig calldata config) external onlyOwner returns (uint256 configId) {
        // Ids never overlap the retired menu.
        //
        // `configCount` is moved to `FIRST_CONFIG_ID` by `initializeVNext`, so
        // an upgrade carrying empty calldata instead of the initializer would
        // leave it at zero and this function would then reissue ids 0 upward —
        // numbers that already mean something to every consumer holding a
        // reference to the old menu. Not a storage collision: the retired menu
        // is an array at its own slot and new configs are a mapping at another.
        // An id-namespace collision, which is worse in the places that cannot
        // see storage at all.
        //
        // The deploy script sends the upgrade and the initializer atomically
        // and the release check asserts the floor, so this is a third guard
        // behind two procedural ones. It is here because it is the only one
        // that cannot be skipped by sending a transaction by hand.
        if (configCount < FIRST_CONFIG_ID) revert NotInitialized();

        ModuleSet memory mods = _moduleSets[config.moduleSetId];
        if (!mods.exists) revert UnknownModuleSet();

        if (config.feeRate == 0 || config.feeRate > MAX_FEE_RATE) revert InvalidConfig();
        // and no looser than the hook that will actually enforce it
        if (config.feeRate > CashCatHookV2(payable(mods.hook)).MAX_FEE_RATE()) revert InvalidConfig();
        if (config.creatorFeeBps > BPS_DENOMINATOR) revert InvalidConfig();
        // a self-burn mode with no creator share would have nothing to burn
        if (config.selfBurn && config.creatorFeeBps == 0) revert InvalidConfig();
        // and a self-burn mode needs a burner in its module set to do it
        if (config.selfBurn && mods.selfBurner == address(0)) revert InvalidConfig();
        // the quote has to sort before the launched token, and a launched token
        // is mined for its suffix rather than placed
        if (uint160(Currency.unwrap(config.quote)) > type(uint160).max / 2) revert InvalidConfig();
        // Native is the zero address; anything else has to be on the list.
        if (!config.quote.isAddressZero() && !approvedQuote[Currency.unwrap(config.quote)]) {
            revert QuoteNotApproved();
        }

        if (config.supply == 0) revert InvalidConfig();
        // The seeded position is measured in uint128 and the pool takes it as an
        // int128. Checked by name because a supply that fails this is otherwise
        // indistinguishable from a dozen unrelated arms, and an owner cannot
        // edit a config to find out which one they tripped.
        //
        // Bounded by int128, not uint128. The seed settles roughly the whole
        // supply as `amount1`, which v4-core casts to int128, so a supply above
        // that maximum is unlaunchable — and a supply between the two bounds
        // passed here and then reverted at every launch with an anonymous
        // overflow from a dependency, which is the failure this named error
        // exists to replace. The seed-liquidity arm below does not catch it
        // either, because over a wide range the liquidity figure is far
        // smaller than the supply it represents.
        if (config.supply > uint256(uint128(type(int128).max))) revert SupplyOutOfRange();

        _requireLaunchableRange(config);

        configId = configCount++;
        LaunchConfig memory c = config;
        c.exists = true;
        _configs[configId] = c;
        emit LaunchConfigAdded(configId, c);
    }

    /// @dev Tick bounds, and whether the shape can actually seed liquidity.
    ///
    ///      `startTick >= MAX_TICK` is its own arm rather than a consequence of
    ///      `maxUsableTick`: for a spacing that divides MAX_TICK the two are
    ///      equal, and the sqrt price at MAX_TICK is the exclusive bound pool
    ///      initialization rejects — so the usable-tick check alone lets through
    ///      a config that can never open a pool.
    function _requireLaunchableRange(LaunchConfig calldata config) private pure {
        if (config.tickSpacing < TickMath.MIN_TICK_SPACING || config.tickSpacing > TickMath.MAX_TICK_SPACING) {
            revert InvalidConfig();
        }
        int24 minTick = TickMath.minUsableTick(config.tickSpacing);
        int24 maxTick = TickMath.maxUsableTick(config.tickSpacing);
        if (
            config.startTick <= minTick || config.startTick > maxTick
                || config.startTick % config.tickSpacing != 0 || config.startTick >= TickMath.MAX_TICK
        ) revert InvalidConfig();

        uint128 seedLiquidity = LiquidityAmounts.getLiquidityForAmount1(
            TickMath.getSqrtPriceAtTick(minTick), TickMath.getSqrtPriceAtTick(config.startTick), config.supply
        );
        if (seedLiquidity == 0 || seedLiquidity > uint128(type(int128).max)) revert InvalidConfig();

        // v4 caps gross liquidity at each initialised tick, at a figure derived
        // from tick spacing alone, and it is far below the int128 bound above —
        // at a spacing of 200 it is roughly four thousand times smaller. The
        // seed opens one position, so both of its ticks take this whole figure
        // and one comparison covers them.
        //
        // Without it a config publishes on a shape whose every launch reverts
        // inside v4 with `TickLiquidityOverflow`, an error raised by a
        // dependency about a tick the creator never chose.
        uint128 perTickCap = Pool.tickSpacingToMaxLiquidityPerTick(config.tickSpacing);
        if (seedLiquidity > perTickCap) revert SeedLiquidityAboveTickCap(seedLiquidity, perTickCap);
    }

    /// @notice Adds or removes a quote asset from the list configs may name.
    ///
    /// @dev    Removing one does not disturb pools already launched against it,
    ///         whose denomination is fixed in the hook. It only stops new
    ///         configs being published and enabled.
    ///
    ///         WHAT AN APPROVED QUOTE HAS TO BE.
    ///
    ///         A transfer must debit the payer by exactly the amount sent.
    ///         `ExactTransfer` enforces this at every payout and reverts
    ///         otherwise, so an asset that breaks it stops paying out rather
    ///         than paying one claimant out of another's balance.
    ///
    ///         Delivering the payee less is absorbed on the paying lanes, and
    ///         not on all of them. The hook divides what its sweep actually
    ///         received, and a splitter divides the balance it actually holds,
    ///         so both keep paying at the reduced amount. A self-burn pool does
    ///         not: its buy settles through the pool manager, which credits what
    ///         it received, so a quote that withholds from every transfer leaves
    ///         the swap unsettled and every burn on that pool reverts. Ordinary
    ///         trades paying in that asset stop for the same reason, so such a
    ///         pool has no working path at all — but fuel already claimed into a
    ///         burner's tank stays there, and no burner has a withdrawal path.
    ///
    ///         A quote that delivers nothing whatsoever is a separate case: the
    ///         hook's sweep has nothing to divide and refuses, which also holds
    ///         up the balance it banked before the fault. See `InexactTransfer`.
    ///
    ///         Debiting the payer more than the amount sent is refused wherever
    ///         this system pays, and cannot be refused where the pool manager
    ///         does. Fees leave the manager as a `take` during a sweep, so the
    ///         excess is drawn from the manager's own balance, which also backs
    ///         the quote reserves of every pool priced in that asset. Nothing in
    ///         v4 checks it, and nothing here can: the shortfall would surface
    ///         later, as unrelated swaps and takes beginning to fail. An asset
    ///         that could start doing this puts every pool sharing the manager
    ///         at risk, not only this launchpad's.
    ///
    ///         A cap on the size of one transfer is a listing rule rather than
    ///         something the code can absorb. A lane that pays a whole balance
    ///         in one move dies above the cap: the transfer is refused, the
    ///         revert rolls back the write that would have reduced the balance,
    ///         and the figure that caused it survives to be attempted again.
    ///         Both paying lanes now take an amount — `claim(poolId,to,amount)`
    ///         and `collect(to,amount)` — so a balance already booked against a
    ///         slot or a tab can be drained in pieces instead of dying whole.
    ///
    ///         That is not the same as surviving such an asset. A sweep still
    ///         redeems a pool's whole `pending` in one `take` and there is no
    ///         partial sweep, so a pool whose pending is ever allowed past the
    ///         cap cannot be swept at all — and sweeping is the only thing that
    ///         drains it, so it stays there. Trades are capped too, and
    ///         sweeping is permissionless, so pending only crosses if roughly
    ///         twenty trades pass unswept; but nothing prevents it.
    ///
    ///         So the amount-bounded claim is a way out of the common half, not
    ///         a licence to list a capped asset. The rule is that an approved
    ///         quote does not cap a transfer at all.
    ///
    ///         An asset that can freeze an address ends the fee stream of every
    ///         pool that pays through the frozen contract, and there is no
    ///         recovery. Three contracts can be frozen, and what each one costs
    ///         is different:
    ///
    ///           the hook, which is part of every pool's identity and can never
    ///           be replaced — every pool quoted in that asset, at once;
    ///           a self-burner, which is the stamped recipient for every
    ///           self-burn pool in its module set — all of them at once;
    ///           a splitter, which serves one launch — that launch.
    ///
    ///         None of them can be re-pointed. A creator paid at their own
    ///         wallet is the exception: they can claim elsewhere or hand the
    ///         stream on, so a freeze on them traps nobody else.
    ///
    ///         The platform's own converter is not on that list, and the
    ///         asymmetry is deliberate rather than an oversight: it never holds
    ///         the asset, because `deliverPlatform` sends it from the hook
    ///         straight to the venue, and its sink is repointable. A contract
    ///         that holds balances for other people cannot be made
    ///         freeze-proof the same way — the balances are the problem — so
    ///         the platform's peripheral contract survives a freeze and a
    ///         creator's does not.
    ///
    ///         Listing an asset is accepting all of that on behalf of everyone
    ///         who launches against it.
    function setApprovedQuote(address quote, bool approved) external onlyOwner {
        if (quote == address(0)) revert InvalidConfig();
        if (approved) {
            if (quote.code.length == 0) revert NotAContract();
            // A staticcall rather than a typed call, because `decimals()` is
            // optional in ERC-20 and a token that omits it must be refused
            // rather than reverting on a failed decode. Read as a full word so
            // a token answering with a `uint256` decodes the same as one
            // answering with a `uint8`.
            //
            // Exactly one word, not at least one. Anything longer is not a
            // number: a `decimals()` returning a string answers with an offset,
            // a length and the bytes, and the offset alone decodes as 32 — over
            // the floor, from a token that never said what its decimals are.
            (bool ok, bytes memory answer) = quote.staticcall(abi.encodeWithSignature("decimals()"));
            if (!ok || answer.length != 32) revert QuoteDecimalsUnreadable();
            uint256 quoteDecimals = abi.decode(answer, (uint256));
            if (quoteDecimals < MIN_QUOTE_DECIMALS) revert QuoteDecimalsTooLow(quoteDecimals);
        }
        approvedQuote[quote] = approved;
        emit QuoteApprovalUpdated(quote, approved);
    }

    function setLaunchConfigEnabled(uint256 configId, bool enabled) external onlyOwner {
        _requireConfigExists(configId);
        // Re-checked on the way in, so an asset removed from the list cannot be
        // brought back into service by re-enabling an old config.
        Currency q = _configs[configId].quote;
        if (enabled && !q.isAddressZero() && !approvedQuote[Currency.unwrap(q)]) {
            revert QuoteNotApproved();
        }
        _configs[configId].enabled = enabled;
        emit LaunchConfigEnabled(configId, enabled);
    }

    function setLaunchFee(uint256 newFee) external onlyOwner {
        emit LaunchFeeUpdated(launchFee, newFee);
        launchFee = newFee;
    }

    function setLaunchEnabled(bool enabled) external onlyOwner {
        launchEnabled = enabled;
        emit LaunchEnabledUpdated(enabled);
    }


    function setTreasury(address newTreasury) external onlyOwner {
        if (newTreasury == address(0)) revert ZeroAddress();
        // This contract has a payable `receive`, so a launch fee paid to itself
        // succeeds and the ether never leaves. `sweep` does not recover it
        // either — it sends the balance to the treasury, which would be here.
        // The hook refuses the same address for the same reason; this did not.
        if (newTreasury == address(this)) revert SelfPayment();
        emit TreasuryUpdated(treasury, newTreasury);
        treasury = newTreasury;
    }








    /// @notice Sweeps stray ether — liquidity rounding dust, mostly — to the
    ///         treasury. The factory never holds user funds by design.
    function sweep() external onlyOwner {
        (bool ok,) = treasury.call{value: address(this).balance}("");
        if (!ok) revert FeeTransferFailed();
    }

    /// @notice Recovers a stray ERC-20 to a named destination.
    ///
    /// @dev    Separate from the ether path, with the destination named rather
    ///         than defaulted. Sending a token to the treasury would destroy it:
    ///         the treasury accounts in ether and has no path that returns an
    ///         ERC-20, so the transfer succeeds and the balance is unreachable.
    ///         It is refused by name for that reason; if the treasury is ever
    ///         replaced by something that can forward a token, drop that arm.
    ///
    ///         `safeTransfer` rather than `transfer`, so a token that returns
    ///         false rather than reverting cannot make a rescue report success
    ///         while moving nothing.
    function rescueToken(address token, address to) external onlyOwner {
        if (token == address(0) || to == address(0)) revert ZeroAddress();
        if (to == treasury) revert TreasuryCannotHoldTokens();
        IERC20(token).safeTransfer(to, IERC20(token).balanceOf(address(this)));
    }

    // —————————————————————————— views ——————————————————————————

    function getLaunchConfig(uint256 configId) external view returns (LaunchConfig memory) {
        _requireConfigExists(configId);
        return _configs[configId];
    }

    /// @notice How many vNext configs have actually been published.
    ///
    /// @dev    Not `configCount`, which is the next id to hand out and starts at
    ///         `FIRST_CONFIG_ID`. Returning that here meant a factory with an
    ///         empty menu reported a thousand configs, and anything that
    ///         iterated the answer got a thousand reverts.
    ///
    ///         Derived rather than stored, because ids are only ever handed out
    ///         one at a time and never skipped, so the count is the distance
    ///         from the floor. Guarded for the window before `initializeVNext`
    ///         runs, where the counter is still zero.
    function launchConfigCount() external view returns (uint256) {
        return publishedConfigCount();
    }

    function publishedConfigCount() public view returns (uint256) {
        return configCount < FIRST_CONFIG_ID ? 0 : configCount - FIRST_CONFIG_ID;
    }

    /// @notice The id range in use. Iterate `firstConfigId()` to `nextConfigId()`.
    ///
    /// @dev    Both, explicitly, because neither is guessable from the other and
    ///         code that iterates from zero cannot work here at all — the
    ///         retired range is unreachable by design, so a loop starting at
    ///         zero reverts eighteen times before reaching anything real.
    function firstConfigId() external pure returns (uint256) {
        return FIRST_CONFIG_ID;
    }

    function nextConfigId() external view returns (uint256) {
        return configCount;
    }

    /// @notice The module set a config builds from.
    function getModuleSet(uint256 id) external view returns (ModuleSet memory) {
        return _moduleSets[id];
    }

    /// @notice The splitter a launch's fees go to, or zero if it pays a single
    ///         address directly.
    ///
    /// @dev    Written once at launch and never moves. A splitter cannot hand
    ///         its stream on, so this is the answer for the life of the pool
    ///         and there is no chain to follow.
    function currentSplitterOf(PoolId poolId) external view returns (address) {
        return launchSplitterOf[poolId];
    }

    /// @notice How many entries the retired menu held. Read from the legacy
    ///         slot so a fork test can prove the prefix is intact.
    function retiredConfigCount() external view returns (uint256) {
        return _retiredConfigs.length;
    }

    /// @notice The retired global pointers, for the same reason.
    function retiredPointers()
        external
        view
        returns (address hook, address burner, address master, address distributor)
    {
        return (_retiredHook, _retiredSelfBurner, _retiredTokenImplementation, _retiredDividendDistributor);
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    receive() external payable {}

    /// @dev Reserved storage gap for future upgrades.
    ///
    ///      This contract IS layout-compatible with `CashCatFactory` and is
    ///      meant to go behind that proxy — see the legacy prefix above and
    ///      `VNextLayoutFork`, which performs the upgrade against live state on
    ///      a fork and reads every preserved value back.
    ///
    ///      V1 occupies slots 0 to 8 and gaps 9 to 45, which is 37. This one takes
    ///      0 to 17 and so gaps 18 to 45, which is 28. Both layouts therefore
    ///      end at the same slot.
    uint256[28] private __gap;
}
