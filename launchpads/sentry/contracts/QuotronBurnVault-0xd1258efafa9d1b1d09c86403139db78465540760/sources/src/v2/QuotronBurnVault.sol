// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IQuotronBurnPot {
    function pullBurn(uint256 amount) external;
}

interface IQuotronBurnAdapter {
    /// @notice Swap an exact input and deliver tokenOut to `recipient`.
    function swapExactInput(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 minAmountOut,
        address recipient,
        uint256 deadline
    ) external returns (uint256 amountOut);
}

interface IERC20BurnVault {
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
}

/// @title QuotronBurnVault
/// @notice Destination-locked WETH pot. A one-time sealed adapter may convert
/// WETH to the canonical STONKBROKER token; all measured output is immediately
/// sent to the immutable burn address. There is no rescue or arbitrary sweep.
contract QuotronBurnVault {
    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    address public owner;
    address public executor;
    IQuotronBurnPot public immutable hook;
    address public immutable weth;
    address public immutable burnToken;
    IQuotronBurnAdapter public adapter;
    bool public adapterSealed;
    bool public paused;
    uint256 private _lock = 1;

    event AdapterSealed(address indexed adapter);
    event ExecutorSet(address indexed executor);
    event BurnExecuted(uint256 wethIn, uint256 tokenBurned);
    event Paused(bool paused);

    error NotOwner();
    error NotExecutor();
    error ZeroAddress();
    error AlreadySealed();
    error NotSealed();
    error Paused_();
    error Reentrancy();
    error SlippageExceeded();
    error TokenTransferFailed();
    error DeadlineExpired();
    error InvalidAmount();

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

    constructor(address hook_, address weth_, address burnToken_, address owner_) {
        if (hook_ == address(0) || weth_ == address(0) || burnToken_ == address(0) || owner_ == address(0)) {
            revert ZeroAddress();
        }
        hook = IQuotronBurnPot(hook_);
        weth = weth_;
        burnToken = burnToken_;
        owner = owner_;
        executor = owner_;
    }

    function setAndSealAdapter(address adapter_) external onlyOwner {
        if (adapterSealed) revert AlreadySealed();
        if (adapter_ == address(0)) revert ZeroAddress();
        adapter = IQuotronBurnAdapter(adapter_);
        adapterSealed = true;
        emit AdapterSealed(adapter_);
    }

    function executeBurn(uint256 wethAmount, uint256 minBurnTokenOut, uint256 deadline)
        external
        onlyExecutor
        nonReentrant
        returns (uint256 burned)
    {
        if (!adapterSealed) revert NotSealed();
        if (paused) revert Paused_();
        if (block.timestamp > deadline) revert DeadlineExpired();
        if (wethAmount == 0 || minBurnTokenOut == 0) revert InvalidAmount();

        hook.pullBurn(wethAmount);
        uint256 beforeBalance = IERC20BurnVault(burnToken).balanceOf(address(this));
        _forceApprove(weth, address(adapter), wethAmount);
        uint256 reported = adapter.swapExactInput(weth, burnToken, wethAmount, minBurnTokenOut, address(this), deadline);
        _forceApprove(weth, address(adapter), 0);

        burned = IERC20BurnVault(burnToken).balanceOf(address(this)) - beforeBalance;
        if (burned < minBurnTokenOut || reported < minBurnTokenOut) {
            revert SlippageExceeded();
        }
        _safeTransfer(burnToken, BURN_ADDRESS, burned);
        emit BurnExecuted(wethAmount, burned);
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

    function _forceApprove(address token, address spender, uint256 amount) internal {
        _safeApprove(token, spender, 0);
        if (amount != 0) _safeApprove(token, spender, amount);
    }

    function _safeApprove(address token, address spender, uint256 amount) internal {
        (bool ok, bytes memory data) = token.call(abi.encodeCall(IERC20BurnVault.approve, (spender, amount)));
        if (!ok || (data.length != 0 && !abi.decode(data, (bool)))) {
            revert TokenTransferFailed();
        }
    }

    function _safeTransfer(address token, address to, uint256 amount) internal {
        (bool ok, bytes memory data) = token.call(abi.encodeCall(IERC20BurnVault.transfer, (to, amount)));
        if (!ok || (data.length != 0 && !abi.decode(data, (bool)))) {
            revert TokenTransferFailed();
        }
    }
}
