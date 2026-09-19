// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/interfaces/IERC20.sol";

interface IV3PoolMinimal {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);
}

interface IWeth9 {
    function deposit() external payable;
    function transfer(address to, uint256 amount) external returns (bool);
}

/// @notice Drill-only exact-input single-pool swapper for Uniswap v3 pools on
/// chains with no public SwapRouter. Callers either attach ETH (wrapped to
/// WETH) or pre-approve `tokenIn`. Holds nothing between swaps; owner can
/// sweep dust.
contract V3RawSwapper {
    address public immutable owner;
    IWeth9 public immutable weth;

    uint160 private constant MIN_SQRT_RATIO_PLUS_1 = 4295128740;
    uint160 private constant MAX_SQRT_RATIO_MINUS_1 = 1461446703485210103287273052203988822378723970341;

    address private _expectedPool;
    address private _payToken;

    constructor(address weth_) {
        owner = msg.sender;
        weth = IWeth9(weth_);
    }

    /// @param pool     v3 pool to swap against
    /// @param tokenIn  input token; if WETH and msg.value == amountIn the ETH is wrapped
    /// @param amountIn exact input amount
    /// @param minOut   slippage floor on the output token
    /// @param to       output recipient
    function swapExactIn(address pool, address tokenIn, uint256 amountIn, uint256 minOut, address to)
        external
        payable
        returns (uint256 amountOut)
    {
        if (msg.value > 0) {
            require(tokenIn == address(weth) && msg.value == amountIn, "bad eth funding");
            weth.deposit{value: msg.value}();
        } else {
            require(IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn), "pull failed");
        }

        address t0 = IV3PoolMinimal(pool).token0();
        address t1 = IV3PoolMinimal(pool).token1();
        require(tokenIn == t0 || tokenIn == t1, "tokenIn not in pool");
        bool zeroForOne = tokenIn == t0;
        address tokenOut = zeroForOne ? t1 : t0;

        _expectedPool = pool;
        _payToken = tokenIn;
        (int256 a0, int256 a1) = IV3PoolMinimal(pool).swap(
            to,
            zeroForOne,
            int256(amountIn),
            zeroForOne ? MIN_SQRT_RATIO_PLUS_1 : MAX_SQRT_RATIO_MINUS_1,
            ""
        );
        _expectedPool = address(0);
        _payToken = address(0);

        int256 outDelta = zeroForOne ? a1 : a0;
        amountOut = outDelta < 0 ? uint256(-outDelta) : 0;
        require(amountOut >= minOut, "insufficient output");
        // Output was paid directly to `to` by the pool; nothing held here.
        tokenOut; // silence unused warning
    }

    function uniswapV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata) external {
        require(msg.sender == _expectedPool && msg.sender != address(0), "bad callback");
        uint256 owed = amount0Delta > 0 ? uint256(amount0Delta) : uint256(amount1Delta);
        require(IERC20(_payToken).transfer(msg.sender, owed), "pay failed");
    }

    function sweep(address token) external {
        require(msg.sender == owner, "not owner");
        if (token == address(0)) {
            (bool ok,) = owner.call{value: address(this).balance}("");
            require(ok, "sweep eth");
        } else {
            require(IERC20(token).transfer(owner, IERC20(token).balanceOf(address(this))), "sweep tok");
        }
    }

    receive() external payable {}
}
