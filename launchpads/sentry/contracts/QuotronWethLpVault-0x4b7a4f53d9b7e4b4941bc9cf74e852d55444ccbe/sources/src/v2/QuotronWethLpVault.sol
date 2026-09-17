// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {IUnlockCallback} from "v4-core/interfaces/callback/IUnlockCallback.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "v4-core/types/PoolId.sol";
import {ModifyLiquidityParams} from "v4-core/types/PoolOperation.sol";
import {BalanceDelta, BalanceDeltaLibrary} from "v4-core/types/BalanceDelta.sol";
import {Currency} from "v4-core/types/Currency.sol";

interface IQuotronLpPot {
    function pullLp(uint256 amount) external;
}

interface IERC20LpVault {
    function transfer(address to, uint256 amount) external returns (bool);
}

/// @title QuotronWethLpVault
/// @notice Pulls only the WETH LP carve and places WETH-only positions in the
/// single QUOTRON/WETH pool. Liquidity deltas must never require QUOTRON, and
/// there is deliberately no remove-liquidity or withdrawal function.
contract QuotronWethLpVault is IUnlockCallback {
    using PoolIdLibrary for PoolKey;
    using BalanceDeltaLibrary for BalanceDelta;

    struct AddLiquidity {
        int24 tickLower;
        int24 tickUpper;
        int256 liquidity;
        bytes32 salt;
        uint256 maxWeth;
    }

    address public owner;
    address public executor;
    IPoolManager public immutable poolManager;
    IQuotronLpPot public immutable hook;
    address public immutable quotron;
    address public immutable weth;
    PoolKey public poolKey;
    PoolId public immutable poolId;
    bool public immutable wethIsCurrency0;
    uint256 public managedWeth;
    uint256 public positionNonce;
    bool public paused;
    uint256 private _lock = 1;

    event ExecutorSet(address indexed executor);
    event WethPulled(uint256 amount);
    event LiquidityLocked(bytes32 indexed salt, int24 tickLower, int24 tickUpper, int256 liquidity, uint256 wethSpent);
    event Paused(bool paused);

    error NotOwner();
    error NotExecutor();
    error NotPoolManager();
    error ZeroAddress();
    error InvalidPool();
    error InvalidLiquidity();
    error QuotronRequired();
    error WethLimit();
    error Paused_();
    error Reentrancy();
    error TokenTransferFailed();
    error DeadlineExpired();

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
        address hook_,
        address quotron_,
        address weth_,
        PoolKey memory poolKey_,
        address owner_
    ) {
        if (
            poolManager_ == address(0) || hook_ == address(0) || quotron_ == address(0) || weth_ == address(0)
                || owner_ == address(0)
        ) {
            revert ZeroAddress();
        }
        address currency0 = Currency.unwrap(poolKey_.currency0);
        address currency1 = Currency.unwrap(poolKey_.currency1);
        if (!((currency0 == quotron_ && currency1 == weth_) || (currency0 == weth_ && currency1 == quotron_))) {
            revert InvalidPool();
        }

        owner = owner_;
        executor = owner_;
        poolManager = IPoolManager(poolManager_);
        hook = IQuotronLpPot(hook_);
        quotron = quotron_;
        weth = weth_;
        poolKey = poolKey_;
        poolId = poolKey_.toId();
        wethIsCurrency0 = currency0 == weth_;
    }

    function compound(
        uint256 pullAmount,
        int24 tickLower,
        int24 tickUpper,
        int256 liquidity,
        uint256 maxWeth,
        uint256 deadline
    ) external onlyExecutor nonReentrant returns (uint256 wethSpent) {
        if (paused) revert Paused_();
        if (block.timestamp > deadline) revert DeadlineExpired();
        if (liquidity <= 0 || tickLower >= tickUpper || maxWeth == 0) {
            revert InvalidLiquidity();
        }

        if (pullAmount != 0) {
            hook.pullLp(pullAmount);
            managedWeth += pullAmount;
            emit WethPulled(pullAmount);
        }
        if (maxWeth > managedWeth) revert WethLimit();

        bytes32 salt = keccak256(abi.encodePacked(address(this), ++positionNonce, tickLower, tickUpper));
        bytes memory result =
            poolManager.unlock(abi.encode(AddLiquidity(tickLower, tickUpper, liquidity, salt, maxWeth)));
        wethSpent = abi.decode(result, (uint256));
        if (wethSpent > managedWeth) revert WethLimit();
        managedWeth -= wethSpent;
        emit LiquidityLocked(salt, tickLower, tickUpper, liquidity, wethSpent);
    }

    function unlockCallback(bytes calldata data) external returns (bytes memory) {
        if (msg.sender != address(poolManager)) revert NotPoolManager();
        AddLiquidity memory request = abi.decode(data, (AddLiquidity));
        if (request.liquidity <= 0) revert InvalidLiquidity();

        (BalanceDelta delta,) = poolManager.modifyLiquidity(
            poolKey,
            ModifyLiquidityParams({
                tickLower: request.tickLower,
                tickUpper: request.tickUpper,
                liquidityDelta: request.liquidity,
                salt: request.salt
            }),
            ""
        );

        int128 wethDelta = wethIsCurrency0 ? delta.amount0() : delta.amount1();
        int128 quotronDelta = wethIsCurrency0 ? delta.amount1() : delta.amount0();
        if (quotronDelta != 0) revert QuotronRequired();
        if (wethDelta >= 0) revert InvalidLiquidity();

        uint256 wethSpent = uint256(uint128(-wethDelta));
        if (wethSpent > request.maxWeth) revert WethLimit();
        Currency wethCurrency = wethIsCurrency0 ? poolKey.currency0 : poolKey.currency1;
        poolManager.sync(wethCurrency);
        _safeTransfer(weth, address(poolManager), wethSpent);
        poolManager.settle();
        return abi.encode(wethSpent);
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

    function _safeTransfer(address token, address to, uint256 amount) internal {
        (bool ok, bytes memory data) = token.call(abi.encodeCall(IERC20LpVault.transfer, (to, amount)));
        if (!ok || (data.length != 0 && !abi.decode(data, (bool)))) {
            revert TokenTransferFailed();
        }
    }
}
