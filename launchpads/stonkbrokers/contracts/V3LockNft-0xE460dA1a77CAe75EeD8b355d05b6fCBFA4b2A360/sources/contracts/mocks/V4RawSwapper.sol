// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "../locker/v4/IV4PoolManager.sol";

struct V4SwapParams {
    bool zeroForOne;
    int256 amountSpecified; // negative = exact input
    uint160 sqrtPriceLimitX96;
}

interface IV4PoolManagerSwap {
    function swap(PoolKey memory key, V4SwapParams memory params, bytes calldata hookData)
        external
        returns (int256 swapDelta);
}

/// @notice Drill-only exact-input swapper for Uniswap v4 pools (EOAs cannot
/// drive PoolManager.unlock directly). Owner-gated and fully sweepable.
contract V4RawSwapper is IV4UnlockCallback {
    IV4PoolManager public immutable pm;
    address public immutable owner;

    uint160 private constant MIN_SQRT_PRICE_PLUS_1 = 4295128740;
    uint160 private constant MAX_SQRT_PRICE_MINUS_1 = 1461446703485210103287273052203988822378723970341;

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    constructor(address poolManager) {
        pm = IV4PoolManager(poolManager);
        owner = msg.sender;
    }

    /// @dev Fund with ETH (send first or attach) / tokens (transfer first).
    function swapExactIn(PoolKey calldata key, bool zeroForOne, uint256 amountIn) external payable onlyOwner {
        pm.unlock(abi.encode(key, zeroForOne, amountIn));
    }

    function unlockCallback(bytes calldata data) external returns (bytes memory) {
        require(msg.sender == address(pm), "not pm");
        (PoolKey memory key, bool zeroForOne, uint256 amountIn) = abi.decode(data, (PoolKey, bool, uint256));
        int256 delta = IV4PoolManagerSwap(address(pm)).swap(
            key,
            V4SwapParams({
                zeroForOne: zeroForOne,
                amountSpecified: -int256(amountIn),
                sqrtPriceLimitX96: zeroForOne ? MIN_SQRT_PRICE_PLUS_1 : MAX_SQRT_PRICE_MINUS_1
            }),
            ""
        );
        int128 d0 = int128(delta >> 128);
        int128 d1 = int128(delta);
        if (d0 < 0) _pay(key.currency0, uint256(uint128(-d0)));
        if (d1 < 0) _pay(key.currency1, uint256(uint128(-d1)));
        if (d0 > 0) pm.take(key.currency0, address(this), uint256(uint128(d0)));
        if (d1 > 0) pm.take(key.currency1, address(this), uint256(uint128(d1)));
        return "";
    }

    function _pay(address currency, uint256 amount) internal {
        if (currency == address(0)) {
            pm.settle{value: amount}();
        } else {
            pm.sync(currency);
            require(IERC20(currency).transfer(address(pm), amount), "pay failed");
            pm.settle();
        }
    }

    function sweep(address token) external onlyOwner {
        if (token == address(0)) {
            (bool ok,) = owner.call{value: address(this).balance}("");
            require(ok, "sweep eth");
        } else {
            require(IERC20(token).transfer(owner, IERC20(token).balanceOf(address(this))), "sweep tok");
        }
    }

    receive() external payable {}
}
