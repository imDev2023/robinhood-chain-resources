// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

struct CreateParams {
    uint256 initialSupply;
    uint256 numTokensToSell;
    address numeraire;
    address tokenFactory;
    bytes tokenFactoryData;
    address governanceFactory;
    bytes governanceFactoryData;
    address poolInitializer;
    bytes poolInitializerData;
    address liquidityMigrator;
    bytes liquidityMigratorData;
    address integrator;
    bytes32 salt;
}

interface ILongLauncher {
    function create(CreateParams calldata data) external returns (address, address, address, address, address);
}

struct PoolKey {
    address currency0;
    address currency1;
    uint24 fee;
    int24 tickSpacing;
    address hooks;
}

struct SwapParams {
    bool zeroForOne;
    int256 amountSpecified;
    uint160 sqrtPriceLimitX96;
}

interface IPoolManager {
    function unlock(bytes calldata data) external returns (bytes memory);
    function swap(PoolKey memory key, SwapParams memory params, bytes calldata hookData)
        external
        returns (int256 delta);
    function sync(address currency) external;
    function settle() external payable returns (uint256);
    function take(address currency, address to, uint256 amount) external;
}

interface IERC20Balance {
    function balanceOf(address account) external view returns (uint256);
}

/// @title LongLaunchHelper
/// @notice Creates through LongLauncher and buys one exact token amount for the caller in the same
/// transaction. The caller supplies a maximum native/ERC20 cost and receives every unused unit back.
/// @dev Port of the fork-proven LongLaunchBundlerV4 version-one paths. The contract is stateless and
/// has no owner, pause, fee, or mutable storage. Cost and output guards run before PoolManager.settle.
contract LongLaunchHelper {
    ILongLauncher public immutable launcher;
    IPoolManager public immutable poolManager;
    address public immutable hook;
    int24 public immutable tickSpacing;

    uint24 private constant DYNAMIC_FEE_FLAG = 0x800000;
    uint160 private constant MIN_SQRT_PRICE_PLUS_ONE = 4295128740;
    uint160 private constant MAX_SQRT_PRICE_MINUS_ONE =
        1461446703485210103287273052203988822378723970341;

    error NotPoolManager();
    error NativeNumeraireOnly();
    error TokenNumeraireOnly();
    error NumeraireMismatch(address given, address inParams);
    error ZeroAmount();
    error TooExpensive(uint256 cost, uint256 maxCost);
    error ShortOutput(uint256 got, uint256 wanted);
    error RefundFailed();
    error TransferFailed();

    event LaunchedAndBought(
        address indexed asset,
        address indexed buyer,
        uint256 totalCost,
        uint256 recipients
    );
    event BoughtFor(address indexed asset, address indexed recipient, uint256 cost, uint256 assetOut);

    constructor(address launcher_, address poolManager_, address hook_, int24 tickSpacing_) {
        launcher = ILongLauncher(launcher_);
        poolManager = IPoolManager(poolManager_);
        hook = hook_;
        tickSpacing = tickSpacing_;
    }

    /// @notice Create and buy exactly `amountOut` tokens. `msg.value` is the native-cost ceiling.
    function launchAndBuyExactOut(CreateParams calldata params, uint256 amountOut)
        external
        payable
        returns (address asset, uint256 cost)
    {
        if (params.numeraire != address(0)) revert NativeNumeraireOnly();
        if (amountOut == 0 || msg.value == 0) revert ZeroAmount();

        (asset,,,,) = launcher.create(params);
        cost = _run(address(0), asset, msg.sender, amountOut, msg.value);
        _refundEth(msg.sender);

        emit LaunchedAndBought(asset, msg.sender, cost, 1);
    }

    /// @notice Create and buy exactly `amountOut` tokens with an ERC20 numeraire. The caller must
    /// approve exactly `maxCost`; every unit not settled into the pool is swept back in this call.
    function launchAndBuyExactOutWithToken(
        CreateParams calldata params,
        address numeraire,
        uint256 amountOut,
        uint256 maxCost
    ) external returns (address asset, uint256 cost) {
        if (numeraire == address(0)) revert TokenNumeraireOnly();
        if (params.numeraire != numeraire) revert NumeraireMismatch(numeraire, params.numeraire);
        if (amountOut == 0 || maxCost == 0) revert ZeroAmount();

        _safeTransferFrom(numeraire, msg.sender, address(this), maxCost);
        (asset,,,,) = launcher.create(params);
        cost = _run(numeraire, asset, msg.sender, amountOut, maxCost);
        _sweep(numeraire, msg.sender);

        emit LaunchedAndBought(asset, msg.sender, cost, 1);
    }

    function _run(address numeraire, address asset, address recipient, uint256 amountOut, uint256 maxCost)
        private
        returns (uint256 cost)
    {
        bytes memory result = poolManager.unlock(
            abi.encode(numeraire, asset, recipient, amountOut, maxCost)
        );
        return abi.decode(result, (uint256));
    }

    function unlockCallback(bytes calldata data) external returns (bytes memory) {
        if (msg.sender != address(poolManager)) revert NotPoolManager();
        (address numeraire, address asset, address recipient, uint256 amountOut, uint256 maxCost) =
            abi.decode(data, (address, address, address, uint256, uint256));

        bool zeroForOne = numeraire < asset;
        PoolKey memory key = PoolKey({
            currency0: zeroForOne ? numeraire : asset,
            currency1: zeroForOne ? asset : numeraire,
            fee: DYNAMIC_FEE_FLAG,
            tickSpacing: tickSpacing,
            hooks: hook
        });
        uint256 cost = _leg(key, zeroForOne, numeraire, asset, recipient, amountOut, maxCost);
        emit BoughtFor(asset, recipient, cost, amountOut);
        return abi.encode(cost);
    }

    function _leg(
        PoolKey memory key,
        bool zeroForOne,
        address numeraire,
        address asset,
        address recipient,
        uint256 amountOut,
        uint256 maxCost
    ) private returns (uint256 owed) {
        int256 delta = poolManager.swap(
            key,
            SwapParams({
                zeroForOne: zeroForOne,
                amountSpecified: int256(amountOut),
                sqrtPriceLimitX96: zeroForOne
                    ? MIN_SQRT_PRICE_PLUS_ONE
                    : MAX_SQRT_PRICE_MINUS_ONE
            }),
            ""
        );
        int128 amount0 = int128(delta >> 128);
        int128 amount1 = int128(delta);
        owed = uint256(uint128(-(zeroForOne ? amount0 : amount1)));
        uint256 got = uint256(uint128(zeroForOne ? amount1 : amount0));

        // Both checks intentionally precede settlement. Any failure rolls the launch and funding back.
        if (owed > maxCost) revert TooExpensive(owed, maxCost);
        if (got < amountOut) revert ShortOutput(got, amountOut);

        if (numeraire == address(0)) {
            poolManager.settle{value: owed}();
        } else {
            poolManager.sync(numeraire);
            _safeTransfer(numeraire, address(poolManager), owed);
            poolManager.settle();
        }
        poolManager.take(asset, recipient, got);
    }

    function _refundEth(address to) private {
        uint256 leftover = address(this).balance;
        if (leftover == 0) return;
        (bool ok,) = to.call{value: leftover}("");
        if (!ok) revert RefundFailed();
    }

    function _sweep(address token, address to) private {
        uint256 leftover = IERC20Balance(token).balanceOf(address(this));
        if (leftover > 0) _safeTransfer(token, to, leftover);
    }

    function _safeTransfer(address token, address to, uint256 amount) private {
        (bool ok, bytes memory result) = token.call(
            abi.encodeWithSelector(bytes4(0xa9059cbb), to, amount)
        );
        if (!ok || (result.length != 0 && !abi.decode(result, (bool)))) revert TransferFailed();
    }

    function _safeTransferFrom(address token, address from, address to, uint256 amount) private {
        (bool ok, bytes memory result) = token.call(
            abi.encodeWithSelector(bytes4(0x23b872dd), from, to, amount)
        );
        if (!ok || (result.length != 0 && !abi.decode(result, (bool)))) revert TransferFailed();
    }
}
