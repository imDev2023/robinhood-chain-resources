// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {PoolKey} from "v4-core/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "v4-core/types/PoolId.sol";
import {SwapParams, ModifyLiquidityParams} from "v4-core/types/PoolOperation.sol";
import {Currency} from "v4-core/types/Currency.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {IHooks} from "v4-core/interfaces/IHooks.sol";
import {StateLibrary} from "v4-core/libraries/StateLibrary.sol";
import {TransientStateLibrary} from "v4-core/libraries/TransientStateLibrary.sol";
import {TickMath} from "v4-core/libraries/TickMath.sol";
import {LiquidityAmounts} from "./libraries/LiquidityAmounts.sol";

interface IERC20Minimal_ {
    function transfer(address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

/// @dev Uniswap V3 SwapRouter02-style single-hop exact input (the
/// USDG<->WETH leg lives on Uniswap V3, not v4).
interface IV3SwapRouter_ {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);
}

/**
 * @title SentryTreasurySplitter
 * @notice Drop-in treasury for BOTH SentryLaunchFactoryV4 proxies. Every
 * live hook reads `factory.treasury()` per swap and pays the treasury leg
 * there as a plain ERC-20 transfer (WETH for WETH-paired pools, the
 * paired stock for stock pools), so pointing setTreasury() at this
 * contract reroutes every pool — past and future launches alike — with
 * zero hook or factory changes.
 *
 * What it does with the money:
 *
 *   split(asset)      permissionless bookkeeping: forwards forwardBps
 *                     (e.g. 6000 = 60%) of newly received `asset` to the
 *                     treasury wallet and books the remainder as the
 *                     SENTRY-LP share.
 *
 *   compoundWeth()    swaps HALF the accrued WETH for SENTRY through the
 *                     SENTRY/WETH v4 pool and mints the pair into a
 *                     full-range position in that same pool.
 *
 *   compoundStock(s)  sells HALF the accrued stock for SENTRY via
 *                     stock -> USDG (v4) -> WETH (Uniswap V3) -> SENTRY
 *                     (v4), then pairs the bought SENTRY with the
 *                     retained stock half into a full-range position in
 *                     the (hookless) SENTRY/stock v4 pool. The first
 *                     compound requires the pool to have been initialized
 *                     via initializePairPool() at an owner-supplied price.
 *
 * Both positions are owned by this contract and there is NO liquidity
 * removal function: compounded liquidity is locked forever. Position fees
 * auto-roll: minting on the same range credits accrued fees, which offset
 * settlement.
 *
 * Compounds are keeper-gated (owner or keeper) with caller-supplied
 * minimum outputs, so a manipulated pool price at compound time can only
 * make the call revert, not extract value.
 *
 * SENTRY itself is never treated as fee income: swap leftovers stay in
 * the contract as pairing inventory for the next compound (and anyone MAY
 * top the contract up with SENTRY to stretch the stock legs).
 *
 * NOTE: return-delta accounting that moves real funds. Fork-tested
 * against the live PoolManager; independently audit before it carries
 * meaningful volume.
 */
contract SentryTreasurySplitter {
    using PoolIdLibrary for PoolKey;

    /* ─────────────────────────── Config ─────────────────────────── */

    address public immutable poolManager;
    address public immutable weth;
    address public immutable usdg;
    address public immutable v3Router;
    /// @notice Share of every received asset forwarded to the treasury
    /// wallet, in bps. The remainder accrues for SENTRY LP.
    uint16 public immutable forwardBps;

    address public owner;
    address public keeper;
    /// @notice Destination of the platform share (the old treasury wallet).
    address public treasuryWallet;

    /// @notice The SENTRY token. Set once, together with the pool key.
    address public sentry;
    /// @notice The SENTRY/WETH pool this contract buys through and
    /// compounds WETH into. Set once when the relaunch pool is live.
    PoolKey internal sentryWethKey;
    bool public sentryConfigured;

    /// @notice Per-stock route + pair-pool parameters.
    struct StockConfig {
        uint24 usdgPoolFee;         // stock/USDG v4 pool (vanilla static fee)
        int24 usdgPoolTickSpacing;
        address usdgPoolHooks;      // usually address(0)
        uint24 v3FeeUsdgToWeth;     // Uniswap V3 tier for USDG->WETH
        uint24 pairFee;             // SENTRY/stock v4 pool static fee
        int24 pairTickSpacing;
    }

    mapping(address => StockConfig) public stockConfig;

    /// @notice Accrued SENTRY-LP share per asset, awaiting compound.
    mapping(address => uint256) public pending;

    uint256 private constant BPS = 10_000;

    /* ─────────────────────────── Events ─────────────────────────── */

    event Split(address indexed asset, uint256 forwarded, uint256 accrued);
    event WethCompounded(uint256 wethSpent, uint256 sentryBought, uint128 liquidityAdded);
    event StockCompounded(
        address indexed stock, uint256 stockSpent, uint256 sentryPaired, uint128 liquidityAdded
    );
    event PairPoolInitialized(address indexed stock, uint160 sqrtPriceX96);
    event SentryConfigured(address indexed sentry);
    event StockConfigSet(address indexed stock);
    event PendingSwept(address indexed asset, uint256 amount);
    event KeeperUpdated(address indexed oldKeeper, address indexed newKeeper);
    event TreasuryWalletUpdated(address indexed oldWallet, address indexed newWallet);
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    /* ─────────────────────────── Errors ─────────────────────────── */

    error NotOwner();
    error NotKeeper();
    error NotPoolManager();
    error InvalidConfig();
    error SentryNotConfigured();
    error SentryAlreadyConfigured();
    error SentryIsNotIncome();
    error StockNotConfigured();
    error NothingToDo();
    error PairPoolNotInitialized();
    error SlippageExceeded();
    error Reentrancy();

    /* ────────────────────────── Modifiers ───────────────────────── */

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    modifier onlyKeeper() {
        if (msg.sender != owner && msg.sender != keeper) revert NotKeeper();
        _;
    }

    bool private locked;

    modifier nonReentrant() {
        if (locked) revert Reentrancy();
        locked = true;
        _;
        locked = false;
    }

    constructor(
        address _poolManager,
        address _weth,
        address _usdg,
        address _v3Router,
        address _treasuryWallet,
        uint16 _forwardBps
    ) {
        if (
            _poolManager == address(0) || _weth == address(0) || _usdg == address(0) || _v3Router == address(0)
                || _treasuryWallet == address(0)
        ) revert InvalidConfig();
        if (_forwardBps == 0 || _forwardBps >= BPS) revert InvalidConfig();
        poolManager = _poolManager;
        weth = _weth;
        usdg = _usdg;
        v3Router = _v3Router;
        treasuryWallet = _treasuryWallet;
        forwardBps = _forwardBps;
        owner = msg.sender;
    }

    /* ─────────────────────────── Split ──────────────────────────── */

    /**
     * @notice Book newly received `asset`: forward the platform share to
     * the treasury wallet, accrue the rest for SENTRY LP. Permissionless —
     * it can only move funds to the fixed treasury wallet.
     */
    function split(address asset) public nonReentrant returns (uint256 forwarded, uint256 accrued) {
        if (asset == sentry && sentry != address(0)) revert SentryIsNotIncome();
        uint256 balance = IERC20Minimal_(asset).balanceOf(address(this));
        uint256 delta = balance - pending[asset];
        if (delta == 0) return (0, 0);
        forwarded = (delta * forwardBps) / BPS;
        accrued = delta - forwarded;
        pending[asset] += accrued;
        if (forwarded > 0) IERC20Minimal_(asset).transfer(treasuryWallet, forwarded);
        emit Split(asset, forwarded, accrued);
    }

    /* ──────────────────────── Compounding ───────────────────────── */

    /// @dev Unlock-callback dispatch.
    uint8 private constant OP_WETH = 1;
    uint8 private constant OP_STOCK = 2;

    struct StockOp {
        address stock;
        uint256 minWethOut;
        uint256 minSentryOut;
    }

    /**
     * @notice Compound the accrued WETH: split() any unbooked balance
     * first, then swap half the total through the SENTRY/WETH pool and
     * mint full-range liquidity there. Leftovers roll into pending.
     */
    function compoundWeth(uint256 minSentryOut) external onlyKeeper nonReentrant returns (uint128 liquidityAdded) {
        if (!sentryConfigured) revert SentryNotConfigured();
        _splitUnlocked(weth);
        if (pending[weth] == 0) revert NothingToDo();
        bytes memory result = IPoolManager(poolManager).unlock(abi.encode(OP_WETH, abi.encode(minSentryOut)));
        liquidityAdded = abi.decode(result, (uint128));
    }

    /**
     * @notice Compound an accrued stock: split() any unbooked balance
     * first, then sell half the total for SENTRY (stock -> USDG on v4,
     * USDG -> WETH on Uniswap V3, WETH -> SENTRY on v4) and pair the
     * bought SENTRY with the retained half into the full-range
     * SENTRY/stock position. Any SENTRY already sitting in the contract
     * (leftovers, top-ups) is used for pairing too.
     */
    function compoundStock(address stock, uint256 minWethOut, uint256 minSentryOut)
        external
        onlyKeeper
        nonReentrant
        returns (uint128 liquidityAdded)
    {
        if (!sentryConfigured) revert SentryNotConfigured();
        if (stockConfig[stock].pairFee == 0) revert StockNotConfigured();
        _splitUnlocked(stock);
        if (pending[stock] == 0) revert NothingToDo();
        (uint160 sqrtP,,,) = StateLibrary.getSlot0(IPoolManager(poolManager), _pairKey(stock).toId());
        if (sqrtP == 0) revert PairPoolNotInitialized();
        bytes memory result = IPoolManager(poolManager).unlock(
            abi.encode(OP_STOCK, abi.encode(StockOp({stock: stock, minWethOut: minWethOut, minSentryOut: minSentryOut})))
        );
        liquidityAdded = abi.decode(result, (uint128));
    }

    function unlockCallback(bytes calldata data) external returns (bytes memory) {
        if (msg.sender != poolManager) revert NotPoolManager();
        (uint8 op, bytes memory payload) = abi.decode(data, (uint8, bytes));
        if (op == OP_WETH) {
            return abi.encode(_compoundWeth(abi.decode(payload, (uint256))));
        }
        return abi.encode(_compoundStock(abi.decode(payload, (StockOp))));
    }

    /// @dev Swap half the WETH budget for SENTRY through the SENTRY/WETH
    /// pool, then mint full-range liquidity there from both sides.
    function _compoundWeth(uint256 minSentryOut) internal returns (uint128 liquidity) {
        PoolKey memory key = sentryWethKey;
        bool wethIs0 = Currency.unwrap(key.currency0) == weth;
        Currency wethCur = wethIs0 ? key.currency0 : key.currency1;
        Currency sentryCur = wethIs0 ? key.currency1 : key.currency0;

        uint256 budget = pending[weth];
        pending[weth] = 0;

        uint256 half = budget / 2;
        _v4Swap(key, wethIs0, half);
        uint256 sentryOut = _positiveDelta(sentryCur);
        if (sentryOut < minSentryOut) revert SlippageExceeded();

        // Pair the unswapped half with the bought SENTRY plus any
        // inventory already in the contract.
        uint256 sentryAvail = sentryOut + IERC20Minimal_(sentry).balanceOf(address(this));
        liquidity = _mintFullRange(key, wethIs0 ? budget - half : sentryAvail, wethIs0 ? sentryAvail : budget - half);

        uint256 wethSpent = _settle(wethCur);
        _settle(sentryCur);
        if (wethSpent < budget) pending[weth] += budget - wethSpent;
        emit WethCompounded(wethSpent, sentryOut, liquidity);
    }

    /// @dev Sell half the stock budget for SENTRY via
    /// stock -> USDG (v4) -> WETH (V3) -> SENTRY (v4), then mint
    /// full-range SENTRY/stock liquidity from the retained half plus the
    /// bought SENTRY (plus inventory).
    function _compoundStock(StockOp memory op) internal returns (uint128 liquidity) {
        StockConfig memory cfg = stockConfig[op.stock];
        uint256 budget = pending[op.stock];
        pending[op.stock] = 0;
        uint256 half = budget / 2;

        // Leg 1: stock -> USDG on the vanilla v4 pool, USDG out to us.
        PoolKey memory usdgKey = _sortedKey(op.stock, usdg, cfg.usdgPoolFee, cfg.usdgPoolTickSpacing, cfg.usdgPoolHooks);
        bool stockIs0 = op.stock < usdg;
        _v4Swap(usdgKey, stockIs0, half);
        Currency usdgCur = Currency.wrap(usdg);
        uint256 usdgOut = _positiveDelta(usdgCur);
        IPoolManager(poolManager).take(usdgCur, address(this), usdgOut);
        _settle(stockIs0 ? usdgKey.currency0 : usdgKey.currency1); // pay the stock in

        // Leg 2: USDG -> WETH on Uniswap V3 (external call; v4 lock is
        // ours and the V3 pool doesn't touch it).
        IERC20Minimal_(usdg).approve(v3Router, usdgOut);
        uint256 wethOut = IV3SwapRouter_(v3Router).exactInputSingle(
            IV3SwapRouter_.ExactInputSingleParams({
                tokenIn: usdg,
                tokenOut: weth,
                fee: cfg.v3FeeUsdgToWeth,
                recipient: address(this),
                amountIn: usdgOut,
                amountOutMinimum: op.minWethOut,
                sqrtPriceLimitX96: 0
            })
        );

        // Leg 3: WETH -> SENTRY through the SENTRY/WETH pool. The WETH
        // arrived as ERC-20 balance, so _settle pays it from the wallet.
        PoolKey memory sKey = sentryWethKey;
        bool wethIs0 = Currency.unwrap(sKey.currency0) == weth;
        Currency sentryCur = wethIs0 ? sKey.currency1 : sKey.currency0;
        _v4Swap(sKey, wethIs0, wethOut);
        uint256 sentryOut = _positiveDelta(sentryCur);
        if (sentryOut < op.minSentryOut) revert SlippageExceeded();
        _settle(wethIs0 ? sKey.currency0 : sKey.currency1); // pay the WETH in

        // Leg 4: pair retained stock + SENTRY into the full-range
        // SENTRY/stock position.
        PoolKey memory pairKey = _pairKey(op.stock);
        bool sentryIs0 = sentry < op.stock;
        uint256 stockAvail = budget - half;
        uint256 sentryAvail = sentryOut + IERC20Minimal_(sentry).balanceOf(address(this));
        liquidity =
            _mintFullRange(pairKey, sentryIs0 ? sentryAvail : stockAvail, sentryIs0 ? stockAvail : sentryAvail);

        uint256 stockSpent = _settle(sentryIs0 ? pairKey.currency1 : pairKey.currency0);
        uint256 sentrySpent = _settle(sentryIs0 ? pairKey.currency0 : pairKey.currency1);
        // The sold half is gone regardless; only the unpaired remainder of
        // the retained half rolls back into pending.
        uint256 consumed = half + stockSpent;
        if (consumed < budget) pending[op.stock] += budget - consumed;
        emit StockCompounded(op.stock, consumed, sentrySpent, liquidity);
    }

    /* ─────────────────── v4 plumbing (internal) ─────────────────── */

    /// @dev Exact-input swap inside our unlock. Deltas are settled by the
    /// callers, who know which side is wallet-funded vs credit-funded.
    function _v4Swap(PoolKey memory key, bool zeroForOne, uint256 amountIn) internal {
        IPoolManager(poolManager).swap(
            key,
            SwapParams({
                zeroForOne: zeroForOne,
                amountSpecified: -int256(amountIn),
                sqrtPriceLimitX96: zeroForOne ? TickMath.MIN_SQRT_PRICE + 1 : TickMath.MAX_SQRT_PRICE - 1
            }),
            ""
        );
    }

    function _mintFullRange(PoolKey memory key, uint256 amt0, uint256 amt1) internal returns (uint128 liquidity) {
        (uint160 sqrtP,,,) = StateLibrary.getSlot0(IPoolManager(poolManager), key.toId());
        int24 tickLo = (TickMath.MIN_TICK / key.tickSpacing) * key.tickSpacing;
        int24 tickHi = (TickMath.MAX_TICK / key.tickSpacing) * key.tickSpacing;
        // 1 wei of slack per side: modifyLiquidity rounds owed amounts up.
        if (amt0 > 0) amt0 -= 1;
        if (amt1 > 0) amt1 -= 1;
        liquidity = LiquidityAmounts.getLiquidityForAmounts(
            sqrtP, TickMath.getSqrtPriceAtTick(tickLo), TickMath.getSqrtPriceAtTick(tickHi), amt0, amt1
        );
        if (liquidity > 0) {
            IPoolManager(poolManager).modifyLiquidity(
                key,
                ModifyLiquidityParams({
                    tickLower: tickLo,
                    tickUpper: tickHi,
                    liquidityDelta: int256(uint256(liquidity)),
                    salt: bytes32(0)
                }),
                ""
            );
        }
    }

    function _positiveDelta(Currency cur) internal view returns (uint256) {
        int256 delta = TransientStateLibrary.currencyDelta(IPoolManager(poolManager), address(this), cur);
        return delta > 0 ? uint256(delta) : 0;
    }

    /// @dev Settle a currency: pay negative deltas from our ERC-20
    /// balance, take positive deltas back as balance. Returns what we paid.
    function _settle(Currency cur) internal returns (uint256 paid) {
        int256 delta = TransientStateLibrary.currencyDelta(IPoolManager(poolManager), address(this), cur);
        if (delta < 0) {
            paid = uint256(-delta);
            IPoolManager(poolManager).sync(cur);
            IERC20Minimal_(Currency.unwrap(cur)).transfer(poolManager, paid);
            IPoolManager(poolManager).settle();
        } else if (delta > 0) {
            IPoolManager(poolManager).take(cur, address(this), uint256(delta));
        }
    }

    /// @dev split() without taking the reentrancy lock (compounds hold it).
    function _splitUnlocked(address asset) internal {
        uint256 balance = IERC20Minimal_(asset).balanceOf(address(this));
        uint256 delta = balance - pending[asset];
        if (delta == 0) return;
        uint256 forwarded = (delta * forwardBps) / BPS;
        pending[asset] += delta - forwarded;
        if (forwarded > 0) IERC20Minimal_(asset).transfer(treasuryWallet, forwarded);
        emit Split(asset, forwarded, delta - forwarded);
    }

    /* ──────────────────────── Pool helpers ──────────────────────── */

    function _sortedKey(address a, address b, uint24 fee, int24 tickSpacing, address hooks)
        internal
        pure
        returns (PoolKey memory)
    {
        (address c0, address c1) = a < b ? (a, b) : (b, a);
        return PoolKey({
            currency0: Currency.wrap(c0),
            currency1: Currency.wrap(c1),
            fee: fee,
            tickSpacing: tickSpacing,
            hooks: IHooks(hooks)
        });
    }

    function _pairKey(address stock) internal view returns (PoolKey memory) {
        StockConfig memory cfg = stockConfig[stock];
        return _sortedKey(sentry, stock, cfg.pairFee, cfg.pairTickSpacing, address(0));
    }

    function pairKeyOf(address stock) external view returns (PoolKey memory) {
        return _pairKey(stock);
    }

    function sentryWethKeyView() external view returns (PoolKey memory) {
        return sentryWethKey;
    }

    /* ───────────────────────── Admin ────────────────────────────── */

    /// @notice One-time wiring of the SENTRY token + SENTRY/WETH pool.
    function configureSentry(address _sentry, PoolKey calldata _sentryWethKey) external onlyOwner {
        if (sentryConfigured) revert SentryAlreadyConfigured();
        if (_sentry == address(0)) revert InvalidConfig();
        bool sentryIs0 = Currency.unwrap(_sentryWethKey.currency0) == _sentry;
        bool sentryIs1 = Currency.unwrap(_sentryWethKey.currency1) == _sentry;
        bool wethIs0 = Currency.unwrap(_sentryWethKey.currency0) == weth;
        bool wethIs1 = Currency.unwrap(_sentryWethKey.currency1) == weth;
        if (!((sentryIs0 && wethIs1) || (sentryIs1 && wethIs0))) revert InvalidConfig();
        sentry = _sentry;
        sentryWethKey = _sentryWethKey;
        sentryConfigured = true;
        emit SentryConfigured(_sentry);
    }

    function setStockConfig(address stock, StockConfig calldata cfg) external onlyOwner {
        if (stock == address(0) || cfg.pairFee == 0 || cfg.pairTickSpacing <= 0) revert InvalidConfig();
        stockConfig[stock] = cfg;
        emit StockConfigSet(stock);
    }

    /// @notice Initialize the (hookless) SENTRY/stock pair pool at an
    /// explicit price. Owner-supplied on purpose: deriving it on-chain
    /// from other pools would be a manipulation surface.
    function initializePairPool(address stock, uint160 sqrtPriceX96) external onlyOwner {
        if (!sentryConfigured) revert SentryNotConfigured();
        if (stockConfig[stock].pairFee == 0) revert StockNotConfigured();
        IPoolManager(poolManager).initialize(_pairKey(stock), sqrtPriceX96);
        emit PairPoolInitialized(stock, sqrtPriceX96);
    }

    /// @notice Escape hatch for assets that will never be compounded
    /// (e.g. a delisted stock): send their pending share to the treasury
    /// wallet. Cannot touch SENTRY (inventory) or minted liquidity.
    function sweepPending(address asset) external onlyOwner {
        if (asset == sentry) revert SentryIsNotIncome();
        uint256 amount = pending[asset];
        if (amount == 0) revert NothingToDo();
        pending[asset] = 0;
        IERC20Minimal_(asset).transfer(treasuryWallet, amount);
        emit PendingSwept(asset, amount);
    }

    function setKeeper(address newKeeper) external onlyOwner {
        emit KeeperUpdated(keeper, newKeeper);
        keeper = newKeeper;
    }

    function setTreasuryWallet(address newWallet) external onlyOwner {
        if (newWallet == address(0)) revert InvalidConfig();
        emit TreasuryWalletUpdated(treasuryWallet, newWallet);
        treasuryWallet = newWallet;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner == address(0)) revert InvalidConfig();
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}
