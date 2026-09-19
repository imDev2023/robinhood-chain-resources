// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IStonkLiquidityLocker {
    enum FeeMode {
        UpfrontHalfPercent,
        WithdrawOnePercent,
        CollectTwentyPercent
    }

    struct LockPosition {
        uint256 positionTokenId;
        uint256 lockTokenId;
        address token0;
        address token1;
        uint128 initialLiquidity;
        uint128 withdrawnLiquidity;
        uint64 startUnlock;
        uint64 finishUnlock;
        FeeMode feeMode;
        bool closed;
    }

    function lockByTransfer(uint256 positionTokenId, uint64 startUnlock, uint64 finishUnlock, FeeMode feeMode)
        external
        returns (uint256 lockTokenId);

    function collectFees(uint256 lockTokenId, uint128 amount0Max, uint128 amount1Max)
        external
        returns (uint256 userAmount0, uint256 userAmount1, uint256 protocolAmount0, uint256 protocolAmount1);

    function decreaseLockedLiquidity(
        uint256 lockTokenId,
        uint128 liquidity,
        uint256 amount0Min,
        uint256 amount1Min
    ) external returns (uint256 userAmount0, uint256 userAmount1, uint256 protocolAmount0, uint256 protocolAmount1);

    function releasePosition(uint256 lockTokenId) external;
}

