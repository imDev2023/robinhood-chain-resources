// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IQuotronV3Router {
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

interface IERC20V3Adapter {
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

/// @title QuotronV3ExactInputAdapter
/// @notice Immutable, caller-bound single-hop V3 adapter. It cannot change
/// tokens, fee tier, recipient, or retain a configurable approval.
contract QuotronV3ExactInputAdapter {
    address public immutable caller;
    IQuotronV3Router public immutable router;
    address public immutable tokenIn;
    address public immutable tokenOut;
    uint24 public immutable fee;
    uint256 private _lock = 1;

    error NotCaller();
    error InvalidRoute();
    error InvalidRecipient();
    error InvalidAmount();
    error DeadlineExpired();
    error TransferFailed();
    error SlippageExceeded();
    error Reentrancy();

    constructor(address caller_, address router_, address tokenIn_, address tokenOut_, uint24 fee_) {
        if (
            caller_ == address(0) || router_ == address(0) || tokenIn_ == address(0) || tokenOut_ == address(0)
                || tokenIn_ == tokenOut_ || fee_ == 0
        ) {
            revert InvalidRoute();
        }
        caller = caller_;
        router = IQuotronV3Router(router_);
        tokenIn = tokenIn_;
        tokenOut = tokenOut_;
        fee = fee_;
    }

    function swapExactInput(
        address tokenIn_,
        address tokenOut_,
        uint256 amountIn,
        uint256 minAmountOut,
        address recipient,
        uint256 deadline
    ) external returns (uint256 amountOut) {
        if (msg.sender != caller) revert NotCaller();
        if (_lock != 1) revert Reentrancy();
        if (tokenIn_ != tokenIn || tokenOut_ != tokenOut) revert InvalidRoute();
        if (recipient != caller) revert InvalidRecipient();
        if (amountIn == 0 || minAmountOut == 0) revert InvalidAmount();
        if (block.timestamp > deadline) revert DeadlineExpired();
        _lock = 2;

        uint256 beforeInput = IERC20V3Adapter(tokenIn).balanceOf(address(this));
        _safeTransferFrom(tokenIn, caller, address(this), amountIn);
        if (IERC20V3Adapter(tokenIn).balanceOf(address(this)) - beforeInput != amountIn) {
            revert TransferFailed();
        }

        _forceApprove(tokenIn, address(router), amountIn);
        uint256 beforeOutput = IERC20V3Adapter(tokenOut).balanceOf(recipient);
        uint256 reported = router.exactInputSingle(
            IQuotronV3Router.ExactInputSingleParams({
                tokenIn: tokenIn,
                tokenOut: tokenOut,
                fee: fee,
                recipient: recipient,
                amountIn: amountIn,
                amountOutMinimum: minAmountOut,
                sqrtPriceLimitX96: 0
            })
        );
        _forceApprove(tokenIn, address(router), 0);

        amountOut = IERC20V3Adapter(tokenOut).balanceOf(recipient) - beforeOutput;
        if (amountOut < minAmountOut || reported < minAmountOut) revert SlippageExceeded();
        _lock = 1;
    }

    function _forceApprove(address token, address spender, uint256 amount) internal {
        _safeApprove(token, spender, 0);
        if (amount != 0) _safeApprove(token, spender, amount);
    }

    function _safeApprove(address token, address spender, uint256 amount) internal {
        (bool ok, bytes memory data) = token.call(abi.encodeCall(IERC20V3Adapter.approve, (spender, amount)));
        if (!ok || (data.length != 0 && !abi.decode(data, (bool)))) revert TransferFailed();
    }

    function _safeTransferFrom(address token, address from, address to, uint256 amount) internal {
        (bool ok, bytes memory data) = token.call(abi.encodeCall(IERC20V3Adapter.transferFrom, (from, to, amount)));
        if (!ok || (data.length != 0 && !abi.decode(data, (bool)))) revert TransferFailed();
    }
}
