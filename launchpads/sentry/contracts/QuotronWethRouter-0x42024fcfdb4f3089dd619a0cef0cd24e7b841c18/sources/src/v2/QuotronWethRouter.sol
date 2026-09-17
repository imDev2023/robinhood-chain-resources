// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {IUnlockCallback} from "v4-core/interfaces/callback/IUnlockCallback.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {SwapParams} from "v4-core/types/PoolOperation.sol";
import {BalanceDelta, BalanceDeltaLibrary} from "v4-core/types/BalanceDelta.sol";
import {Currency} from "v4-core/types/Currency.sol";
import {TickMath} from "v4-core/libraries/TickMath.sol";

interface IWethRouterToken {
    function deposit() external payable;
    function withdraw(uint256 amount) external;
    function transfer(address to, uint256 amount) external returns (bool);
}

interface IERC20RouterToken {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IQuotronRouterToken {
    function transfer(address to, uint256 amount) external returns (bool);
    function assertPoolTransferAuthorizationConsumed() external view;
}

interface IQuotronFeeView {
    function currentFeeBps(address account) external view returns (uint256);
}

/// @title QuotronWethRouter
/// @notice Minimal exact-input router for the one canonical V2 QUOTRON/WETH
/// pool. ETH buys include the hook fee inside msg.value and refund rounding;
/// sells settle QUOTRON directly from the caller and return native ETH.
contract QuotronWethRouter is IUnlockCallback {
    using BalanceDeltaLibrary for BalanceDelta;

    uint256 private constant BPS = 10_000;

    struct SwapRequest {
        bool buy;
        bool exactOutput;
        address payer;
        address recipient;
        uint256 amountSpecified;
        uint256 limit;
        uint256 maxSettlement;
    }

    IPoolManager public immutable poolManager;
    address public immutable quotron;
    address public immutable weth;
    IQuotronFeeView public immutable hook;
    PoolKey public poolKey;
    bool public immutable wethIsCurrency0;
    uint256 private _lock = 1;

    event Bought(address indexed payer, address indexed recipient, uint256 wethSpent, uint256 quotronOut);
    event Sold(address indexed payer, address indexed recipient, uint256 quotronIn, uint256 ethOut);

    error Reentrancy();
    error NotPoolManager();
    error InvalidPool();
    error InvalidAmount();
    error DeadlineExpired();
    error SlippageExceeded();
    error SettlementExceeded();
    error TokenTransferFailed();
    error EthTransferFailed();
    error DirectEthRejected();
    error ExactOutputUnavailable();
    error PartialFill();

    modifier nonReentrant() {
        if (_lock != 1) revert Reentrancy();
        _lock = 2;
        _;
        _lock = 1;
    }

    constructor(address poolManager_, address quotron_, address weth_, PoolKey memory poolKey_) {
        if (poolManager_ == address(0) || quotron_ == address(0) || weth_ == address(0)) {
            revert InvalidPool();
        }
        address currency0 = Currency.unwrap(poolKey_.currency0);
        address currency1 = Currency.unwrap(poolKey_.currency1);
        if (
            !((currency0 == quotron_ && currency1 == weth_) || (currency0 == weth_ && currency1 == quotron_))
                || address(poolKey_.hooks) == address(0)
        ) {
            revert InvalidPool();
        }

        poolManager = IPoolManager(poolManager_);
        quotron = quotron_;
        weth = weth_;
        hook = IQuotronFeeView(address(poolKey_.hooks));
        poolKey = poolKey_;
        wethIsCurrency0 = currency0 == weth_;
    }

    function buyExactEth(uint256 minQuotronOut, address recipient, uint256 deadline)
        external
        payable
        nonReentrant
        returns (uint256 quotronOut)
    {
        if (block.timestamp > deadline) revert DeadlineExpired();
        if (msg.value == 0 || minQuotronOut == 0 || recipient == address(0)) {
            revert InvalidAmount();
        }

        IWethRouterToken(weth).deposit{value: msg.value}();

        bytes memory result = poolManager.unlock(
            abi.encode(SwapRequest(true, false, msg.sender, recipient, msg.value, minQuotronOut, msg.value))
        );
        uint256 wethSpent;
        (wethSpent, quotronOut) = abi.decode(result, (uint256, uint256));
        if (wethSpent > msg.value) revert SettlementExceeded();

        uint256 refund = msg.value - wethSpent;
        if (refund != 0) {
            IWethRouterToken(weth).withdraw(refund);
            _sendEth(msg.sender, refund);
        }
        emit Bought(msg.sender, recipient, wethSpent, quotronOut);
    }

    function buyExactQuotron(uint256 quotronOut, address recipient, uint256 deadline)
        external
        payable
        nonReentrant
        returns (uint256 wethSpent)
    {
        if (block.timestamp > deadline) revert DeadlineExpired();
        if (msg.value == 0 || quotronOut == 0 || recipient == address(0) || quotronOut > uint256(type(int256).max)) {
            revert InvalidAmount();
        }
        if (hook.currentFeeBps(msg.sender) >= BPS / 2) revert ExactOutputUnavailable();
        IWethRouterToken(weth).deposit{value: msg.value}();

        bytes memory result = poolManager.unlock(
            abi.encode(SwapRequest(true, true, msg.sender, recipient, quotronOut, msg.value, msg.value))
        );
        uint256 received;
        (wethSpent, received) = abi.decode(result, (uint256, uint256));
        if (received != quotronOut || wethSpent > msg.value) revert SettlementExceeded();

        uint256 refund = msg.value - wethSpent;
        if (refund != 0) {
            IWethRouterToken(weth).withdraw(refund);
            _sendEth(msg.sender, refund);
        }
        emit Bought(msg.sender, recipient, wethSpent, received);
    }

    function sellExactQuotronForEth(uint256 quotronIn, uint256 minEthOut, address recipient, uint256 deadline)
        external
        nonReentrant
        returns (uint256 ethOut)
    {
        if (block.timestamp > deadline) revert DeadlineExpired();
        if (quotronIn == 0 || minEthOut == 0 || recipient == address(0) || quotronIn > uint256(type(int256).max)) {
            revert InvalidAmount();
        }

        bytes memory result = poolManager.unlock(
            abi.encode(SwapRequest(false, false, msg.sender, recipient, quotronIn, minEthOut, quotronIn))
        );
        ethOut = abi.decode(result, (uint256));
        IWethRouterToken(weth).withdraw(ethOut);
        _sendEth(recipient, ethOut);
        emit Sold(msg.sender, recipient, quotronIn, ethOut);
    }

    function unlockCallback(bytes calldata data) external returns (bytes memory) {
        if (msg.sender != address(poolManager)) revert NotPoolManager();
        SwapRequest memory request = abi.decode(data, (SwapRequest));
        if (request.amountSpecified > uint256(type(int256).max)) {
            revert InvalidAmount();
        }

        bool zeroForOne = request.buy ? wethIsCurrency0 : !wethIsCurrency0;
        int256 amountSpecified =
            request.exactOutput ? int256(request.amountSpecified) : -int256(request.amountSpecified);
        if (request.buy) {
            // The launch pool is intentionally QUOTRON-only. Pre-settling the
            // buyer's WETH makes the physical token available before the hook
            // takes its fee during beforeSwap/afterSwap.
            _settle(weth, request.maxSettlement);
        }
        BalanceDelta delta = poolManager.swap(
            poolKey,
            SwapParams({
                zeroForOne: zeroForOne,
                amountSpecified: amountSpecified,
                sqrtPriceLimitX96: zeroForOne ? TickMath.MIN_SQRT_PRICE + 1 : TickMath.MAX_SQRT_PRICE - 1
            }),
            abi.encode(request.payer, request.recipient)
        );

        int128 wethDelta = wethIsCurrency0 ? delta.amount0() : delta.amount1();
        int128 quotronDelta = wethIsCurrency0 ? delta.amount1() : delta.amount0();

        if (request.buy) {
            if (wethDelta >= 0 || quotronDelta <= 0) revert InvalidAmount();
            uint256 wethSpent = uint256(uint128(-wethDelta));
            uint256 amountOut = uint256(uint128(quotronDelta));
            if (wethSpent > request.maxSettlement) revert SettlementExceeded();
            if (request.exactOutput) {
                if (amountOut != request.amountSpecified) revert SlippageExceeded();
            } else {
                if (wethSpent != request.maxSettlement) revert PartialFill();
                if (amountOut < request.limit) revert SlippageExceeded();
            }

            uint256 refund = request.maxSettlement - wethSpent;
            if (refund != 0) {
                poolManager.take(_currency(weth), address(this), refund);
            }
            poolManager.take(_currency(quotron), address(this), amountOut);
            IQuotronRouterToken(quotron).assertPoolTransferAuthorizationConsumed();
            _safeTransfer(quotron, request.recipient, amountOut);
            return abi.encode(wethSpent, amountOut);
        }

        if (quotronDelta >= 0 || wethDelta <= 0) revert InvalidAmount();
        uint256 quotronSpent = uint256(uint128(-quotronDelta));
        uint256 wethOut = uint256(uint128(wethDelta));
        if (request.exactOutput) revert SettlementExceeded();
        if (quotronSpent != request.amountSpecified) revert PartialFill();
        if (wethOut < request.limit) revert SlippageExceeded();

        _settleFrom(quotron, request.payer, quotronSpent);
        poolManager.take(_currency(weth), address(this), wethOut);
        IQuotronRouterToken(quotron).assertPoolTransferAuthorizationConsumed();
        return abi.encode(wethOut);
    }

    function _settle(address token, uint256 amount) internal {
        Currency currency = _currency(token);
        poolManager.sync(currency);
        _safeTransfer(token, address(poolManager), amount);
        poolManager.settle();
    }

    function _settleFrom(address token, address payer, uint256 amount) internal {
        Currency currency = _currency(token);
        poolManager.sync(currency);
        _safeTransferFrom(token, payer, address(poolManager), amount);
        poolManager.settle();
    }

    function _currency(address token) internal pure returns (Currency) {
        return Currency.wrap(token);
    }

    function _safeTransfer(address token, address to, uint256 amount) internal {
        (bool ok, bytes memory result) = token.call(abi.encodeCall(IWethRouterToken.transfer, (to, amount)));
        if (!ok || (result.length != 0 && !abi.decode(result, (bool)))) {
            revert TokenTransferFailed();
        }
    }

    function _safeTransferFrom(address token, address from, address to, uint256 amount) internal {
        (bool ok, bytes memory result) = token.call(abi.encodeCall(IERC20RouterToken.transferFrom, (from, to, amount)));
        if (!ok || (result.length != 0 && !abi.decode(result, (bool)))) {
            revert TokenTransferFailed();
        }
    }

    function _sendEth(address to, uint256 amount) internal {
        (bool ok,) = to.call{value: amount}("");
        if (!ok) revert EthTransferFailed();
    }

    receive() external payable {
        if (msg.sender != weth) revert DirectEthRejected();
    }
}
