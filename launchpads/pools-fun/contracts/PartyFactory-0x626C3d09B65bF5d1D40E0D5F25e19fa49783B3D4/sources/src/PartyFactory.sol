// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

import {PartyToken} from "./PartyToken.sol";
import {TickMath} from "./libraries/TickMath.sol";
import {ISushiV3Factory} from "./interfaces/ISushiV3Factory.sol";
import {ISushiV3Pool} from "./interfaces/ISushiV3Pool.sol";
import {INonfungiblePositionManager} from "./interfaces/INonfungiblePositionManager.sol";
import {IWETH9} from "./interfaces/IWETH9.sol";
import {IUniswapV3SwapCallback} from "./interfaces/IUniswapV3SwapCallback.sol";
import {IPartyLocker} from "./interfaces/IPartyLocker.sol";
import {IChainlinkAggregatorV3} from "./interfaces/IChainlinkAggregatorV3.sol";

/// @title PartyFactory
/// @notice Deploys pools.fun tokens (CREATE2, always token0), seeds a single-sided
///         full-range SushiSwap V3 position, registers the LP with the permanent
///         locker, and optionally performs a dev buy. The launch curve is protocol
///         state, never caller input: per paired asset the owner registers a
///         Chainlink USD feed and a fallback tick; launches derive the start tick
///         live from the feed (targeting `initialFdvUsd`) and degrade gracefully
///         to the fallback tick when the feed or sequencer is unusable. The factory
///         never retains custody of pool assets — LP NFTs go straight to the locker.
contract PartyFactory is Ownable2Step, IUniswapV3SwapCallback {
    using SafeERC20 for IERC20;

    // ── constants ────────────────────────────────────────────────────────────
    uint256 public constant TOTAL_SUPPLY = 1_000_000_000e18;
    uint24 public constant FEE = 10000;
    int24 public constant TICK_SPACING = 200;
    address internal constant DEAD = 0x000000000000000000000000000000000000dEaD;
    /// @dev Feed heartbeat bounds. Each curve chooses its own maximum age so a
    ///      weekend stock feed can tolerate market closure without making WETH
    ///      trust a multi-day-old ETH price.
    uint32 public constant MIN_PRICE_AGE = 1 minutes;
    uint32 public constant MAX_PRICE_AGE = 3 days;
    /// @dev After the L2 sequencer recovers, feeds may still be catching up;
    ///      stay on the fallback tick until the uptime feed has aged past this.
    uint256 public constant SEQUENCER_GRACE_PERIOD = 1 hours;
    /// @dev Sanity bounds for the owner-tunable FDV target (whole USD).
    uint256 public constant MIN_FDV_USD = 100;
    uint256 public constant MAX_FDV_USD = 1_000_000_000;

    // ── immutables ───────────────────────────────────────────────────────────
    ISushiV3Factory public immutable sushiFactory;
    INonfungiblePositionManager public immutable npm;
    address public immutable weth;
    address public immutable usdg;

    // ── state ────────────────────────────────────────────────────────────────
    address public locker;
    bool public paused;
    /// @dev Per-paired-asset launch pricing. Registration doubles as the
    ///      paired-asset allowlist: an asset with no curve cannot launch.
    mapping(address => PairedAssetCurve) private _curves;
    /// @notice Chainlink L2 sequencer-uptime feed; zero disables the gate.
    address public sequencerUptimeFeed;
    /// @notice Feed-priced launches start at this fully-diluted valuation (whole USD).
    uint256 public initialFdvUsd = 10_000;

    /// @dev Pool authorised to invoke `uniswapV3SwapCallback` during a dev buy.
    address private transientCallbackPool;
    /// @dev Asset the callback pays out — WETH (wrapped msg.value) or the pulled
    ///      paired asset for ERC20-funded dev buys.
    address private transientCallbackPayToken;

    // ── types ────────────────────────────────────────────────────────────────
    struct PairedAssetCurve {
        /// @dev Chainlink USD feed for the paired asset; zero ⇒ fallback-only
        ///      pricing for an explicitly accepted emergency configuration.
        address feed;
        /// @dev Maximum trusted age for this feed. Zero iff `feed == address(0)`.
        uint32 maxPriceAge;
        /// @dev Spacing-aligned tick used whenever the feed path is unusable
        ///      (unset feed, stale round, bad answer, sequencer down/recovering).
        int24 fallbackTick;
        bool set;
    }

    // ── events / errors ──────────────────────────────────────────────────────
    event TokenLaunched(
        address indexed token,
        address indexed pool,
        address pairedAsset,
        address indexed creator,
        address deployer,
        address feeRecipient,
        int24 startTick,
        string metadataUri,
        uint256 devBuyAmountOut
    );
    event PairedAssetCurveSet(address indexed asset, address feed, uint32 maxPriceAge, int24 fallbackTick);
    event PairedAssetCurveRemoved(address indexed asset);
    event SequencerUptimeFeedSet(address feed);
    event InitialFdvSet(uint256 usd);
    /// @dev A launch priced off the stored fallback tick instead of the live feed
    ///      (accepted-drift mode) — the indexer's signal that FDV may be off-target.
    event FallbackTickUsed(address indexed pairedAsset, int24 tick);
    event LockerSet(address indexed locker);
    event PausedSet(bool paused);

    error LockerUnset();
    error LockerAlreadySet();
    error Paused();
    error PairedAssetNotAllowed();
    error CreatorNotCaller();
    error DeployFailed();
    error TokenNotToken0();
    error PoolAlreadyInitialized();
    error InvalidTick();
    error FeedProbeFailed();
    error SequencerFeedProbeFailed();
    error InvalidPriceAge();
    error InvalidFdv();
    error StartTickChanged();
    error Expired();
    error DevBuyWethOnly();
    error DevBuyTooLittle();
    error AmbiguousDevBuy();
    error DevBuyTooLarge();
    error UnexpectedCallback();
    error ZeroAddress();
    error OwnershipCannotBeRenounced();

    constructor(address sushiV3Factory_, address npm_, address weth_, address usdg_, address owner_) Ownable(owner_) {
        if (sushiV3Factory_ == address(0) || npm_ == address(0) || weth_ == address(0) || usdg_ == address(0)) {
            revert ZeroAddress();
        }
        sushiFactory = ISushiV3Factory(sushiV3Factory_);
        npm = INonfungiblePositionManager(npm_);
        weth = weth_;
        usdg = usdg_;
        // No assets are launchable until the owner registers their curves —
        // the deploy script wires WETH and USDG (live feeds + pinned fallbacks)
        // inside the deploy broadcast.
    }

    // ── admin ────────────────────────────────────────────────────────────────
    /// @notice One-time wiring of the locker; must be set before the first launch.
    function setLocker(address locker_) external onlyOwner {
        if (locker != address(0)) revert LockerAlreadySet();
        if (locker_ == address(0)) revert ZeroAddress();
        locker = locker_;
        emit LockerSet(locker_);
    }

    /// @notice Register (or retune) an asset's launch curve, which also allowlists
    ///         it. `feed` may be zero for an explicitly accepted fallback-only
    ///         configuration. A non-zero
    ///         feed is probed here so a typo'd address fails at set time, loudly,
    ///         instead of silently pricing every launch off the fallback.
    function setPairedAssetCurve(address asset, address feed, uint32 maxPriceAge, int24 fallbackTick)
        external
        onlyOwner
    {
        validatePairedAssetCurve(asset, feed, maxPriceAge, fallbackTick);
        _curves[asset] = PairedAssetCurve({feed: feed, maxPriceAge: maxPriceAge, fallbackTick: fallbackTick, set: true});
        emit PairedAssetCurveSet(asset, feed, maxPriceAge, fallbackTick);
    }

    function removePairedAssetCurve(address asset) external onlyOwner {
        delete _curves[asset];
        emit PairedAssetCurveRemoved(asset);
    }

    /// @notice Zero disables the sequencer gate (feed answers stand on their own).
    function setSequencerUptimeFeed(address feed) external onlyOwner {
        if (feed != address(0)) {
            if (feed.code.length == 0) revert SequencerFeedProbeFailed();
            try IChainlinkAggregatorV3(feed).latestRoundData() returns (
                uint80, int256 answer, uint256 startedAt, uint256, uint80
            ) {
                if ((answer != 0 && answer != 1) || startedAt == 0 || startedAt > block.timestamp) {
                    revert SequencerFeedProbeFailed();
                }
            } catch {
                revert SequencerFeedProbeFailed();
            }
        }
        sequencerUptimeFeed = feed;
        emit SequencerUptimeFeedSet(feed);
    }

    function setInitialFdvUsd(uint256 usd) external onlyOwner {
        if (usd < MIN_FDV_USD || usd > MAX_FDV_USD) revert InvalidFdv();
        initialFdvUsd = usd;
        emit InitialFdvSet(usd);
    }

    function setPaused(bool paused_) external onlyOwner {
        paused = paused_;
        emit PausedSet(paused_);
    }

    // ── views ────────────────────────────────────────────────────────────────
    /// @notice Predicts the CREATE2 address of a PartyToken with the given args.
    /// @dev The backend calls this (via eth_call) to verify its locally mined salt
    ///      produces an address that sorts below the paired asset. `deployer` must
    ///      be the eventual launch caller; the effective salt commits to it.
    function computeTokenAddress(
        address deployer,
        bytes32 salt,
        string calldata name,
        string calldata symbol,
        string calldata metadataUri
    ) external view returns (address) {
        bytes32 initcodeHash = keccak256(_tokenInitcode(name, symbol, metadataUri));
        return _computeTokenAddress(deployer, salt, initcodeHash);
    }

    /// @notice Largest spacing-aligned tick usable for a position.
    function maxUsableTick() public pure returns (int24) {
        return (TickMath.MAX_TICK / TICK_SPACING) * TICK_SPACING;
    }

    /// @notice ABI-compatible allowlist view: an asset is launchable iff its
    ///         curve is registered.
    function allowedPairedAsset(address asset) public view returns (bool) {
        return _curves[asset].set;
    }

    function getPairedAssetCurve(address asset) external view returns (PairedAssetCurve memory) {
        return _curves[asset];
    }

    /// @notice Fail-closed preflight used by governance scripts before a batch of
    ///         curve registrations. For feed-backed assets it proves the complete
    ///         live path: deployed contracts, heartbeat, sequencer, decimals,
    ///         answer validity and a usable derived tick.
    function validatePairedAssetCurve(address asset, address feed, uint32 maxPriceAge, int24 fallbackTick)
        public
        view
        returns (int24 liveTick)
    {
        if (asset == address(0)) revert ZeroAddress();
        _validateStartTick(fallbackTick);
        if (asset.code.length == 0) revert FeedProbeFailed();
        uint8 assetDecimals;
        try IERC20Metadata(asset).decimals() returns (uint8 d) {
            assetDecimals = d;
        } catch {
            revert FeedProbeFailed();
        }
        if (assetDecimals > 18) revert FeedProbeFailed();
        if (feed == address(0)) {
            if (maxPriceAge != 0) revert InvalidPriceAge();
            return fallbackTick;
        }
        if (maxPriceAge < MIN_PRICE_AGE || maxPriceAge > MAX_PRICE_AGE) revert InvalidPriceAge();
        if (feed.code.length == 0 || asset.code.length == 0 || !_sequencerUp()) revert FeedProbeFailed();
        (bool ok, int24 tick) = _feedTick(feed, asset, maxPriceAge);
        if (!ok) revert FeedProbeFailed();
        return tick;
    }

    /// @notice The tick a launch would use right now for `pairedAsset`, and
    ///         whether it came from the live feed (false ⇒ fallback tick).
    /// @dev Callers quoting a dev buy should eth_call-simulate `launch` itself
    ///      (which returns `devBuyOut`) rather than re-deriving from this tick.
    function startTickFor(address pairedAsset) public view returns (int24 tick, bool live) {
        PairedAssetCurve storage c = _curves[pairedAsset];
        if (!c.set) revert PairedAssetNotAllowed();
        if (c.feed != address(0) && _sequencerUp()) {
            (bool ok, int24 feedTick) = _feedTick(c.feed, pairedAsset, c.maxPriceAge);
            if (ok) return (feedTick, true);
        }
        return (c.fallbackTick, false);
    }

    // ── launch ───────────────────────────────────────────────────────────────
    /// @notice Launch a token. The curve (start tick + full-range band) is protocol
    ///         state — callers choose identity (name/symbol/metadata/salt), the
    ///         paired asset, the fee recipient, and their dev buy; never pricing.
    /// @dev `devBuyOut` is returned so a caller can eth_call-simulate this exact
    ///      call with `devBuyMinOut = 0`, read the deterministic fill, and submit
    ///      with `devBuyMinOut` pinned to it (simulate-then-send). Dev-buy funding
    ///      is EITHER native ETH via msg.value (WETH pairs only) OR
    ///      `devBuyAmountIn` of the paired asset pulled from the caller's prior
    ///      approval (any pair — the unit is the paired asset: USDG, the stock,
    ///      or WETH itself). Never both.
    function launch(
        string calldata name,
        string calldata symbol,
        string calldata metadataUri,
        bytes32 salt,
        address pairedAsset,
        int24 expectedStartTick,
        uint256 deadline,
        address creator,
        address feeRecipient,
        uint256 devBuyAmountIn,
        uint256 devBuyMinOut
    ) external payable returns (address token, address pool, uint256 devBuyOut) {
        if (paused) revert Paused();
        if (locker == address(0)) revert LockerUnset();
        if (block.timestamp > deadline) revert Expired();
        // The recorded creator and CREATE2 namespace are both bound to the caller:
        // copying launch calldata can deploy only inside the copyist's namespace.
        if (creator != msg.sender) revert CreatorNotCaller();
        // Fee payouts may target a separate recipient (e.g. a resolved X/ENS
        // identity). Payout address only — no caller binding. Zero ⇒ the creator.
        if (feeRecipient == address(0)) feeRecipient = creator;
        // Reverts PairedAssetNotAllowed for unregistered assets (the allowlist).
        (int24 startTick, bool live) = startTickFor(pairedAsset);
        if (startTick != expectedStartTick) revert StartTickChanged();
        if (!live) emit FallbackTickUsed(pairedAsset, startTick);

        token = _deployToken(name, symbol, metadataUri, salt, pairedAsset);
        pool = _createAndInitPool(token, pairedAsset, startTick);

        uint256[] memory tokenIds = _mintPositions(token, pairedAsset, startTick);
        _burnDust(token);

        IPartyLocker(locker).register(token, pairedAsset, pool, tokenIds, creator, feeRecipient);

        devBuyOut = _devBuy(token, pairedAsset, pool, devBuyAmountIn, devBuyMinOut);

        emit TokenLaunched(
            token, pool, pairedAsset, creator, msg.sender, feeRecipient, startTick, metadataUri, devBuyOut
        );
    }

    // ── launch internals ─────────────────────────────────────────────────────
    function _deployToken(
        string calldata name,
        string calldata symbol,
        string calldata metadataUri,
        bytes32 salt,
        address pairedAsset
    ) internal returns (address token) {
        bytes memory initcode = _tokenInitcode(name, symbol, metadataUri);
        bytes32 initcodeHash = keccak256(initcode);
        if (_computeTokenAddress(msg.sender, salt, initcodeHash).code.length != 0) revert DeployFailed();
        bytes32 effectiveSalt = _effectiveSalt(msg.sender, salt);
        // memory-safe: reads the initcode bytes and writes only the return variable,
        // letting solc use a memoryguard (the extra launch() arg needs the stack room).
        assembly ("memory-safe") {
            token := create2(0, add(initcode, 0x20), mload(initcode), effectiveSalt)
        }
        if (token == address(0)) revert DeployFailed();
        // The launched token MUST sort as token0 so single-sided liquidity is token0.
        if (token >= pairedAsset) revert TokenNotToken0();
    }

    function _createAndInitPool(address token, address pairedAsset, int24 startTick) internal returns (address pool) {
        pool = sushiFactory.getPool(token, pairedAsset, FEE);
        if (pool == address(0)) {
            pool = sushiFactory.createPool(token, pairedAsset, FEE);
        }
        uint160 target = TickMath.getSqrtRatioAtTick(startTick);
        (uint160 existing,,,,,,) = ISushiV3Pool(pool).slot0();
        // Never adopt an initialized pool, even at the requested spot: it may already
        // contain attacker liquidity or poisoned observation history. A pre-created
        // but uninitialized pool is safe to initialize here.
        if (existing != 0) revert PoolAlreadyInitialized();
        ISushiV3Pool(pool).initialize(target);
        // Deliberately NO oracle ring growth here (decision 2026-08-10): pools
        // launch with V3's default 1-slot observation ring, saving ~13M gas
        // (~70% of the launch tx). No deployed contract reads the TWAP, and any
        // project that later needs an on-chain oracle can permissionlessly call
        // pool.increaseObservationCardinalityNext themselves — history accrues
        // from that point on. See README "On-chain oracle (opt-in, post-launch)".
    }

    /// @dev The one sanctioned curve shape: the full supply in a single band from
    ///      the start tick to the top of the range (decision 2026-08-10 — no
    ///      caller- or protocol-configurable band layouts).
    function _mintPositions(address token, address pairedAsset, int24 startTick)
        internal
        returns (uint256[] memory tokenIds)
    {
        IERC20(token).forceApprove(address(npm), TOTAL_SUPPLY);
        tokenIds = new uint256[](1);
        tokenIds[0] = _mintBand(token, pairedAsset, startTick, maxUsableTick(), TOTAL_SUPPLY);
        IERC20(token).forceApprove(address(npm), 0);
    }

    function _mintBand(address token, address pairedAsset, int24 tickLower, int24 tickUpper, uint256 amount0)
        internal
        returns (uint256 tokenId)
    {
        // token is always token0; single-sided token0 above spot needs no paired asset.
        (tokenId,,,) = npm.mint(
            INonfungiblePositionManager.MintParams({
                token0: token,
                token1: pairedAsset,
                fee: FEE,
                tickLower: tickLower,
                tickUpper: tickUpper,
                amount0Desired: amount0,
                amount1Desired: 0,
                amount0Min: 0,
                amount1Min: 0,
                recipient: locker,
                deadline: block.timestamp
            })
        );
    }

    /// @dev Burn any token0 rounding dust left after minting for a clean supply story.
    function _burnDust(address token) internal {
        uint256 dust = IERC20(token).balanceOf(address(this));
        if (dust > 0) IERC20(token).safeTransfer(DEAD, dust);
    }

    /// @dev Two funding modes, never both: native ETH (WETH pairs only — wrapped
    ///      here) or `devBuyAmountIn` of the paired asset pulled from the caller.
    ///      Either way the swap is the pool's FIRST, inside the launch tx, so the
    ///      fill is deterministic and un-frontrunnable.
    function _devBuy(address token, address pairedAsset, address pool, uint256 devBuyAmountIn, uint256 devBuyMinOut)
        internal
        returns (uint256 amountOut)
    {
        if (msg.value > 0 && devBuyAmountIn > 0) revert AmbiguousDevBuy();
        uint256 amountIn;
        if (msg.value > 0) {
            if (pairedAsset != weth) revert DevBuyWethOnly();
            IWETH9(weth).deposit{value: msg.value}();
            amountIn = msg.value;
        } else if (devBuyAmountIn > 0) {
            // AUDIT CLASS (router regression): int256(amountIn) is a
            // reinterpretation, not a checked conversion — a value >= 2^255 would
            // flip to EXACT OUTPUT and pull unboundedly from the approval.
            if (devBuyAmountIn > uint256(type(int256).max)) revert DevBuyTooLarge();
            // Paired assets are owner-allowlisted standard tokens (WETH, USDG,
            // the pinned stocks) — stated-amount pull is safe here.
            IERC20(pairedAsset).safeTransferFrom(msg.sender, address(this), devBuyAmountIn);
            amountIn = devBuyAmountIn;
        } else {
            return 0;
        }

        transientCallbackPool = pool;
        transientCallbackPayToken = pairedAsset;
        // zeroForOne = false: pay token1 (the paired asset) for token0. No price limit.
        // forge-lint: disable-next-line(unsafe-typecast)
        (int256 amount0, int256 amount1) =
            ISushiV3Pool(pool).swap(msg.sender, false, int256(amountIn), TickMath.MAX_SQRT_RATIO - 1, abi.encode(token));
        transientCallbackPool = address(0);
        transientCallbackPayToken = address(0);

        amountOut = uint256(-amount0);
        if (amountOut < devBuyMinOut) revert DevBuyTooLittle();

        // Refund exactly what THIS swap did not consume — never a balance sweep, which
        // would hand the launcher anything stranded here by an earlier failed call.
        uint256 leftover = amountIn - uint256(amount1);
        if (leftover > 0) {
            if (msg.value > 0) {
                IWETH9(weth).withdraw(leftover);
                (bool ok,) = msg.sender.call{value: leftover}("");
                require(ok, "refund failed");
            } else {
                IERC20(pairedAsset).safeTransfer(msg.sender, leftover);
            }
        }
    }

    /// @inheritdoc IUniswapV3SwapCallback
    function uniswapV3SwapCallback(int256, int256 amount1Delta, bytes calldata) external override {
        if (msg.sender != transientCallbackPool) revert UnexpectedCallback();
        // Dev buy pays token1 (the paired asset) from the balance _devBuy just
        // funded — wrapped ETH or the pulled ERC20.
        if (amount1Delta > 0) IERC20(transientCallbackPayToken).safeTransfer(msg.sender, uint256(amount1Delta));
    }

    /// @notice Disabled. This contract is immutable and every safety lever (pausing,
    ///         paired-asset allowlist, oracle cardinality) is owner-gated, so
    ///         renouncing would freeze the system permanently with no recovery.
    function renounceOwnership() public view override onlyOwner {
        revert OwnershipCannotBeRenounced();
    }

    // ── helpers ──────────────────────────────────────────────────────────────
    function _tokenInitcode(string calldata name, string calldata symbol, string calldata metadataUri)
        internal
        view
        returns (bytes memory)
    {
        return abi.encodePacked(
            type(PartyToken).creationCode, abi.encode(name, symbol, TOTAL_SUPPLY, address(this), metadataUri)
        );
    }

    function _effectiveSalt(address deployer, bytes32 salt) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(deployer, salt));
    }

    function _computeTokenAddress(address deployer, bytes32 salt, bytes32 initcodeHash)
        internal
        view
        returns (address)
    {
        bytes32 effectiveSalt = _effectiveSalt(deployer, salt);
        return address(
            uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), address(this), effectiveSalt, initcodeHash))))
        );
    }

    function _validateStartTick(int24 startTick) internal pure {
        if (startTick % TICK_SPACING != 0) revert InvalidTick();
        // The range ends at maxUsableTick, so equality would create an
        // empty [tickLower, tickUpper) position and fail later inside the NPM.
        if (startTick < -maxUsableTick() || startTick >= maxUsableTick()) revert InvalidTick();
    }

    // ── feed pricing internals ───────────────────────────────────────────────
    /// @dev Chainlink L2 convention: answer 0 = sequencer up, startedAt = when the
    ///      current status began. Unset feed ⇒ gate disabled. Any anomaly reads as
    ///      "not up" so pricing degrades to the fallback tick, never a revert.
    function _sequencerUp() internal view returns (bool) {
        address feed = sequencerUptimeFeed;
        if (feed == address(0)) return true;
        // try/catch cannot catch a call to a code-less address; guard explicitly
        // so a destroyed feed degrades to "not up" instead of bricking launches.
        if (feed.code.length == 0) return false;
        try IChainlinkAggregatorV3(feed).latestRoundData() returns (
            uint80, int256 answer, uint256 startedAt, uint256, uint80
        ) {
            return answer == 0 && startedAt != 0 && startedAt <= block.timestamp
                && block.timestamp - startedAt > SEQUENCER_GRACE_PERIOD;
        } catch {
            return false;
        }
    }

    /// @dev Validated feed read: (ok, answer, feedDecimals). ok is false on any
    ///      revert, non-positive answer, incomplete round, or stale age.
    function _readFeed(address feed, uint32 maxPriceAge) internal view returns (bool ok, uint256 answer) {
        // Same code-less guard as _sequencerUp: fall back, never revert.
        if (feed.code.length == 0) return (false, 0);
        try IChainlinkAggregatorV3(feed).latestRoundData() returns (
            uint80 roundId, int256 rawAnswer, uint256, uint256 updatedAt, uint80 answeredInRound
        ) {
            if (rawAnswer <= 0) return (false, 0);
            if (updatedAt == 0 || updatedAt > block.timestamp || answeredInRound < roundId) return (false, 0);
            if (block.timestamp - updatedAt > maxPriceAge) return (false, 0);
            return (true, uint256(rawAnswer));
        } catch {
            return (false, 0);
        }
    }

    /// @dev Derive the spacing-aligned start tick that prices the full supply at
    ///      `initialFdvUsd` given the paired asset's live USD feed. Any failure —
    ///      feed revert, stale round, decimals probe, price outside the usable
    ///      tick range — returns ok=false and the caller uses the fallback tick.
    function _feedTick(address feed, address pairedAsset, uint32 maxPriceAge)
        internal
        view
        returns (bool ok, int24 tick)
    {
        (bool feedOk, uint256 answer) = _readFeed(feed, maxPriceAge);
        if (!feedOk) return (false, 0);

        uint8 feedDecimals;
        // feed has code (checked in _readFeed); the paired asset is checked below.
        try IChainlinkAggregatorV3(feed).decimals() returns (uint8 d) {
            feedDecimals = d;
        } catch {
            return (false, 0);
        }
        uint8 quoteDecimals;
        if (pairedAsset.code.length == 0) return (false, 0);
        try IERC20Metadata(pairedAsset).decimals() returns (uint8 d) {
            quoteDecimals = d;
        } catch {
            return (false, 0);
        }
        // 10**(feedDec+quoteDec) below must stay sane; every real feed/ERC20 is ≤ 18.
        if (feedDecimals > 18 || quoteDecimals > 18) return (false, 0);

        // price(token1 raw per token0 raw) = FDV_USD * 10^(feedDec+quoteDec)
        //                                    / (answer * TOTAL_SUPPLY)
        uint256 numerator = initialFdvUsd * (10 ** (uint256(feedDecimals) + uint256(quoteDecimals)));
        if (answer > type(uint256).max / TOTAL_SUPPLY) return (false, 0);
        uint256 denominator = answer * TOTAL_SUPPLY;
        uint256 ratioX192 = Math.mulDiv(numerator, 1 << 192, denominator);
        uint256 sqrtPrice = Math.sqrt(ratioX192);
        if (sqrtPrice < TickMath.MIN_SQRT_RATIO || sqrtPrice >= TickMath.MAX_SQRT_RATIO) return (false, 0);

        int24 rawTick = TickMath.getTickAtSqrtRatio(uint160(sqrtPrice));
        // Floor to spacing (Solidity division truncates toward zero, so negative
        // non-multiples need one more step down).
        tick = (rawTick / TICK_SPACING) * TICK_SPACING;
        if (rawTick < 0 && rawTick % TICK_SPACING != 0) tick -= TICK_SPACING;
        if (tick < -maxUsableTick() || tick >= maxUsableTick()) return (false, 0);
        return (true, tick);
    }

    /// @dev Receives ETH only from WETH.withdraw during a dev-buy refund; reject strays.
    receive() external payable {
        require(msg.sender == weth, "not weth");
    }
}
