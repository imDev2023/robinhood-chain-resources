// SPDX-License-Identifier: MIT
pragma solidity ^0.8.36;

// Thin re-export facade over the canonical Uniswap V4 packages so every
// Mixpad contract imports one local path instead of reaching into
// @uniswap/v4-core and @uniswap/v4-periphery directly. Packed types
// (BalanceDelta, BeforeSwapDelta, Currency) and their arithmetic libraries
// are used as published, not reimplemented.

import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {IUnlockCallback} from "@uniswap/v4-core/src/interfaces/callback/IUnlockCallback.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {
    BalanceDelta,
    BalanceDeltaLibrary as BalanceDeltaLib
} from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {
    BeforeSwapDelta,
    toBeforeSwapDelta,
    BeforeSwapDeltaLibrary
} from "@uniswap/v4-core/src/types/BeforeSwapDelta.sol";
import {StateLibrary} from "@uniswap/v4-core/src/libraries/StateLibrary.sol";
// SwapParams and ModifyLiquidityParams are imported from v4-core so they are
// the exact same types IPoolManager.swap / IPoolManager.modifyLiquidity
// expect. Defining them locally would create a structurally-identical but
// incompatible shadow type.
import {SwapParams, ModifyLiquidityParams} from "@uniswap/v4-core/src/types/PoolOperation.sol";

/// @notice Minimal Permit2 surface used for approving the position manager
/// to pull the freshly minted supply during launch.
interface IPermit2 {
    function approve(address token, address spender, uint160 amount, uint48 expiration) external;
}

/// @notice Minimal V4 position manager surface used at launch time.
interface IPositionManager {
    function nextTokenId() external view returns (uint256);

    function modifyLiquidities(bytes calldata unlockData, uint256 deadline) external payable;

    function initializePool(PoolKey calldata key, uint160 sqrtPriceX96) external payable returns (int24);
}

/// @notice Minimal V4 StateView surface used for reading live pool state
/// (price, liquidity) outside of an unlock context, e.g. for graduation
/// checks and the on-chain trust score.
interface IStateView {
    function getSlot0(PoolId poolId)
        external
        view
        returns (uint160 sqrtPriceX96, int24 tick, uint24 protocolFee, uint24 lpFee);

    function getLiquidity(PoolId poolId) external view returns (uint128 liquidity);
}
