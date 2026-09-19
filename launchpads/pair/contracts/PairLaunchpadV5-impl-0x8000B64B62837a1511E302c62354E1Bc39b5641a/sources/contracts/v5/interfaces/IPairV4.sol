// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";

interface IStockTokenRegistryV5 {
    struct StockConfig {
        bool enabled;
        uint8 decimals;
        bytes32 symbol;
        address priceFeed;
        uint256 graduationTargetUsdE8;
        bool ethRouteEnabled;
    }
    function getConfig(address token) external view returns (StockConfig memory);
    function isEnabled(address token) external view returns (bool);
}

interface IAggregatorV3V5 {
    function decimals() external view returns (uint8);
    function latestRoundData()
        external
        view
        returns (uint80, int256, uint256, uint256, uint80);
}

interface IPermit2Allowance {
    function approve(address token, address spender, uint160 amount, uint48 expiration) external;
}

interface IUniversalRouterV4 {
    function execute(bytes calldata commands, bytes[] calldata inputs, uint256 deadline) external payable;
}

interface IPositionManagerV4 {
    function modifyLiquidities(bytes calldata unlockData, uint256 deadline) external payable;
    function nextTokenId() external view returns (uint256);
    function getPositionLiquidity(uint256 tokenId) external view returns (uint128);
    function getPoolAndPositionInfo(uint256 tokenId) external view returns (PoolKey memory, uint256);
    function ownerOf(uint256 tokenId) external view returns (address);
}

interface IPairV4Hook {
    function authorizePool(PoolKey calldata key, address projectToken, address quoteToken) external;
}

interface IPairV4Locker {
    function registerPosition(
        uint256 tokenId,
        address projectToken,
        address quoteToken,
        bytes32 poolId,
        address creator
    ) external;
}

/// @notice Locker used only by launches created after the fee-conversion upgrade.
/// @dev Kept separate from IPairV4Locker so existing permanent lockers retain
/// their immutable registration ABI and behaviour.
interface IPairV4ConvertedFeeLocker is IPairV4Locker {
    function launchpad() external view returns (address);
    function positionManager() external view returns (address);
    function permit2() external view returns (address);
    function universalRouter() external view returns (address);
    function protocolTreasury() external view returns (address);
    function registerPositionWithAllocation(
        uint256 tokenId,
        address projectToken,
        address quoteToken,
        bytes32 poolId,
        address creator,
        uint16 allocationBps
    ) external;
    function finalizeProjectRegistration(address projectToken) external;
}

/// @notice Closed-policy V3 funding conversion and V4 project-swap coordinator.
interface IPairV4DeveloperBuyAdapter {
    function launchpad() external view returns (address);
    function poolManager() external view returns (address);
    function universalRouter() external view returns (address);
    function permit2() external view returns (address);
    function swapRouter02() external view returns (address);
    function isConfigured(address,address,address,address) external view returns (bool);
    function executeWeighted(
        address projectToken,
        address payer,
        address recipient,
        address fundingToken,
        uint8 mode,
        uint256 amount,
        uint256 limit,
        uint256 maxProjectOut,
        uint256 deadline,
        uint256[5] calldata quoteCaps
    ) external payable returns (uint256 amountIn, uint256 amountOut);
}

/// @notice Read-only subset used by the permissionless V5 secondary-market aggregator.
interface IPairV5LaunchPoolSource {
    struct LaunchPool {
        address quoteToken; uint16 weightBps; bytes32 poolId; uint256 positionId;
        uint256 initialProjectTokenAmount; int24 tickLower; int24 tickUpper;
        uint256 quoteUsdAtLaunchE8; address quotePriceFeed; uint8 quoteDecimals;
    }
    function poolManager() external view returns (address);
    function universalRouter() external view returns (address);
    function permit2() external view returns (address);
    function pairHook() external view returns (address);
    function getLaunchPoolCount(address projectToken) external view returns (uint256);
    function getLaunchPool(address projectToken, uint256 index) external view returns (LaunchPool memory);
}