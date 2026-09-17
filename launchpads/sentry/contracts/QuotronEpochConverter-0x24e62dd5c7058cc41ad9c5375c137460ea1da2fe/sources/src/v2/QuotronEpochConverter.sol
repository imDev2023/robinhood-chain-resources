// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {IUnlockCallback} from "v4-core/interfaces/callback/IUnlockCallback.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {SwapParams} from "v4-core/types/PoolOperation.sol";
import {BalanceDelta, BalanceDeltaLibrary} from "v4-core/types/BalanceDelta.sol";
import {Currency} from "v4-core/types/Currency.sol";
import {TickMath} from "v4-core/libraries/TickMath.sol";
import {IHooks} from "v4-core/interfaces/IHooks.sol";

interface IQuotronReflectionPot {
    function pullReflections(uint256 amount) external;
    function reflectionPot() external view returns (uint256);
}

interface IQuotronReflectionsInflow {
    function notifyFees(uint8 floorIdx, uint256 amount) external;
    function floorStocks(uint256 floorIdx) external view returns (address);
}

interface IERC20Converter {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

interface IV3ExactInputRouter {
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

/// @title QuotronEpochConverter
/// @notice Pulls the hook's WETH reflections carve in rate-limited epochs,
/// splits it equally across the ten floors, and executes the immutable
/// WETH -> USDG -> stock routes. No caller can choose a recipient.
contract QuotronEpochConverter is IUnlockCallback {
    using BalanceDeltaLibrary for BalanceDelta;

    struct FloorRoute {
        address stock;
        uint24 fee;
        int24 tickSpacing;
        address hooks;
    }

    struct UnlockData {
        uint8 floorIdx;
        uint256 usdgIn;
    }

    address public owner;
    address public executor;
    IPoolManager public immutable poolManager;
    IV3ExactInputRouter public immutable v3Router;
    IQuotronReflectionPot public immutable hook;
    IQuotronReflectionsInflow public immutable reflections;
    address public immutable weth;
    address public immutable usdg;
    uint24 public immutable wethUsdgFee;
    uint256 public immutable minEpochWeth;
    uint256 public immutable maxEpochWeth;
    uint256 public immutable minEpochInterval;

    FloorRoute[10] public routes;
    uint256[10] public floorBudget;
    uint256 public budgetTotal;
    uint256 public lastEpochAt;
    uint256 public epochNumber;
    bool public routesSealed;
    bool public paused;
    uint256 private _lock = 1;

    event RoutesSealed();
    event EpochOpened(uint256 indexed epoch, uint256 amount);
    event FloorConverted(
        uint256 indexed epoch, uint8 indexed floorIdx, uint256 wethIn, uint256 usdgOut, uint256 stockOut
    );
    event ExecutorSet(address indexed executor);
    event Paused(bool paused);

    error NotOwner();
    error NotExecutor();
    error NotPoolManager();
    error Reentrancy();
    error ZeroAddress();
    error AlreadySealed();
    error NotSealed();
    error Paused_();
    error EpochTooSoon();
    error EpochSize();
    error InvalidFloor();
    error InvalidRoute();
    error InsufficientBudget();
    error DeadlineExpired();
    error SlippageExceeded();
    error TokenTransferFailed();

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    modifier onlyExecutor() {
        if (msg.sender != executor) revert NotExecutor();
        _;
    }

    modifier nonReentrant() {
        if (_lock != 1) revert Reentrancy();
        _lock = 2;
        _;
        _lock = 1;
    }

    constructor(
        address poolManager_,
        address v3Router_,
        address hook_,
        address reflections_,
        address weth_,
        address usdg_,
        uint24 wethUsdgFee_,
        uint256 minEpochWeth_,
        uint256 maxEpochWeth_,
        uint256 minEpochInterval_,
        address owner_
    ) {
        if (
            poolManager_ == address(0) || v3Router_ == address(0) || hook_ == address(0) || reflections_ == address(0)
                || weth_ == address(0) || usdg_ == address(0) || owner_ == address(0)
        ) {
            revert ZeroAddress();
        }
        if (
            minEpochWeth_ == 0 || maxEpochWeth_ < minEpochWeth_ || maxEpochWeth_ % minEpochWeth_ != 0
                || wethUsdgFee_ == 0
        ) {
            revert EpochSize();
        }

        owner = owner_;
        executor = owner_;
        poolManager = IPoolManager(poolManager_);
        v3Router = IV3ExactInputRouter(v3Router_);
        hook = IQuotronReflectionPot(hook_);
        reflections = IQuotronReflectionsInflow(reflections_);
        weth = weth_;
        usdg = usdg_;
        wethUsdgFee = wethUsdgFee_;
        minEpochWeth = minEpochWeth_;
        maxEpochWeth = maxEpochWeth_;
        minEpochInterval = minEpochInterval_;
    }

    // ── one-time route wiring ───────────────────────────────────────

    function setRoute(uint8 floorIdx, address stock, uint24 fee, int24 tickSpacing, address hooks) external onlyOwner {
        if (routesSealed) revert AlreadySealed();
        if (
            floorIdx >= 10 || stock == address(0) || fee == 0 || tickSpacing == 0
                || reflections.floorStocks(floorIdx) != stock
        ) {
            revert InvalidRoute();
        }
        routes[floorIdx] = FloorRoute(stock, fee, tickSpacing, hooks);
    }

    function sealRoutes() external onlyOwner {
        if (routesSealed) revert AlreadySealed();
        for (uint256 i; i < 10; ++i) {
            if (routes[i].stock == address(0)) revert InvalidRoute();
        }
        routesSealed = true;
        emit RoutesSealed();
    }

    function setExecutor(address executor_) external onlyOwner {
        if (executor_ == address(0)) revert ZeroAddress();
        executor = executor_;
        emit ExecutorSet(executor_);
    }

    function setPaused(bool paused_) external onlyOwner {
        paused = paused_;
        emit Paused(paused_);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner == address(0)) revert ZeroAddress();
        owner = newOwner;
    }

    // ── epoch allocation / conversion ───────────────────────────────

    /// @notice Pulls every complete minimum-size batch currently available,
    /// capped by maxEpochWeth. The executor cannot choose a smaller amount and
    /// delay holder rewards.
    function openEpoch() external onlyExecutor nonReentrant returns (uint256 amount) {
        if (!routesSealed) revert NotSealed();
        if (paused) revert Paused_();
        if (block.timestamp < lastEpochAt + minEpochInterval) revert EpochTooSoon();
        uint256 available = hook.reflectionPot();
        if (available < minEpochWeth) revert InsufficientBudget();
        amount = (available / minEpochWeth) * minEpochWeth;
        if (amount > maxEpochWeth) amount = maxEpochWeth;

        hook.pullReflections(amount);
        uint256 each = amount / 10;
        uint256 remainder = amount - each * 10;
        for (uint256 i; i < 10; ++i) {
            floorBudget[i] += each;
        }
        floorBudget[0] += remainder;
        budgetTotal += amount;
        lastEpochAt = block.timestamp;
        ++epochNumber;
        emit EpochOpened(epochNumber, amount);
        return amount;
    }

    function convertFloor(uint8 floorIdx, uint256 wethAmount, uint256 minUsdgOut, uint256 minStockOut, uint256 deadline)
        external
        onlyExecutor
        nonReentrant
        returns (uint256 stockOut)
    {
        if (!routesSealed) revert NotSealed();
        if (paused) revert Paused_();
        if (floorIdx >= 10) revert InvalidFloor();
        if (block.timestamp > deadline) revert DeadlineExpired();
        if (wethAmount == 0 || floorBudget[floorIdx] < wethAmount) {
            revert InsufficientBudget();
        }

        floorBudget[floorIdx] -= wethAmount;
        budgetTotal -= wethAmount;

        _forceApprove(weth, address(v3Router), wethAmount);
        uint256 beforeUsdg = IERC20Converter(usdg).balanceOf(address(this));
        uint256 reportedUsdg = v3Router.exactInputSingle(
            IV3ExactInputRouter.ExactInputSingleParams({
                tokenIn: weth,
                tokenOut: usdg,
                fee: wethUsdgFee,
                recipient: address(this),
                amountIn: wethAmount,
                amountOutMinimum: minUsdgOut,
                sqrtPriceLimitX96: 0
            })
        );
        _forceApprove(weth, address(v3Router), 0);
        uint256 usdgOut = IERC20Converter(usdg).balanceOf(address(this)) - beforeUsdg;
        if (usdgOut < minUsdgOut || reportedUsdg < minUsdgOut) {
            revert SlippageExceeded();
        }

        bytes memory result = poolManager.unlock(abi.encode(UnlockData(floorIdx, usdgOut)));
        stockOut = abi.decode(result, (uint256));
        if (stockOut < minStockOut) revert SlippageExceeded();

        FloorRoute memory route = routes[floorIdx];
        _forceApprove(route.stock, address(reflections), stockOut);
        reflections.notifyFees(floorIdx, stockOut);
        _forceApprove(route.stock, address(reflections), 0);

        emit FloorConverted(epochNumber, floorIdx, wethAmount, usdgOut, stockOut);
    }

    // ── v4 USDG -> stock leg ────────────────────────────────────────

    function unlockCallback(bytes calldata data) external returns (bytes memory) {
        if (msg.sender != address(poolManager)) revert NotPoolManager();
        UnlockData memory request = abi.decode(data, (UnlockData));
        if (request.floorIdx >= 10 || request.usdgIn == 0) revert InvalidRoute();

        FloorRoute memory route = routes[request.floorIdx];
        PoolKey memory key = _key(usdg, route.stock, route.fee, route.tickSpacing, route.hooks);
        bool zeroForOne = Currency.unwrap(key.currency0) == usdg;
        if (request.usdgIn > uint256(type(int256).max)) revert EpochSize();

        BalanceDelta delta = poolManager.swap(
            key,
            SwapParams({
                zeroForOne: zeroForOne,
                amountSpecified: -int256(request.usdgIn),
                sqrtPriceLimitX96: zeroForOne ? TickMath.MIN_SQRT_PRICE + 1 : TickMath.MAX_SQRT_PRICE - 1
            }),
            ""
        );

        int128 amount0 = delta.amount0();
        int128 amount1 = delta.amount1();
        uint256 stockOut;
        if (amount0 < 0) _settle(key.currency0, uint256(uint128(-amount0)));
        if (amount1 < 0) _settle(key.currency1, uint256(uint128(-amount1)));
        if (amount0 > 0) {
            uint256 amount = uint256(uint128(amount0));
            poolManager.take(key.currency0, address(this), amount);
            if (Currency.unwrap(key.currency0) == route.stock) stockOut = amount;
        }
        if (amount1 > 0) {
            uint256 amount = uint256(uint128(amount1));
            poolManager.take(key.currency1, address(this), amount);
            if (Currency.unwrap(key.currency1) == route.stock) stockOut = amount;
        }
        return abi.encode(stockOut);
    }

    function _settle(Currency currency, uint256 amount) internal {
        poolManager.sync(currency);
        _safeTransfer(Currency.unwrap(currency), address(poolManager), amount);
        poolManager.settle();
    }

    function _key(address tokenA, address tokenB, uint24 fee, int24 tickSpacing, address hooks)
        internal
        pure
        returns (PoolKey memory)
    {
        (address currency0, address currency1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        return PoolKey({
            currency0: Currency.wrap(currency0),
            currency1: Currency.wrap(currency1),
            fee: fee,
            tickSpacing: tickSpacing,
            hooks: IHooks(hooks)
        });
    }

    // ── token helpers ───────────────────────────────────────────────

    function _forceApprove(address token, address spender, uint256 amount) internal {
        _safeApprove(token, spender, 0);
        if (amount != 0) _safeApprove(token, spender, amount);
    }

    function _safeApprove(address token, address spender, uint256 amount) internal {
        (bool ok, bytes memory data) = token.call(abi.encodeCall(IERC20Converter.approve, (spender, amount)));
        if (!ok || (data.length != 0 && !abi.decode(data, (bool)))) {
            revert TokenTransferFailed();
        }
    }

    function _safeTransfer(address token, address to, uint256 amount) internal {
        (bool ok, bytes memory data) = token.call(abi.encodeCall(IERC20Converter.transfer, (to, amount)));
        if (!ok || (data.length != 0 && !abi.decode(data, (bool)))) {
            revert TokenTransferFailed();
        }
    }
}
