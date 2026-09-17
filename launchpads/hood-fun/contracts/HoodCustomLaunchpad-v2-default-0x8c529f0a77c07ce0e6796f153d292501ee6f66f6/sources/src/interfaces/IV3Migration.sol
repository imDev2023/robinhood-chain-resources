// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/// @notice Pluggable migrator the launchpad hands graduated liquidity to.
///         Keeping this behind an interface + owner-settable address means the
///         migration target (Uniswap v3 today, v4 later) can change without
///         redeploying the launchpad — the last forced launchpad redeploy.
interface IHoodMigrator {
    /// @dev The launchpad transfers `LP_SUPPLY` of `token` to this contract and
    ///      forwards the raised ETH as msg.value, then calls this. Returns the
    ///      created pool/pair address for the launchpad's Migrated event.
    function migrate(address token, address creator) external payable returns (address pool);
}

/// @notice Minimal Uniswap v3 factory surface the migrator needs.
interface IV3Factory {
    function getPool(address tokenA, address tokenB, uint24 fee) external view returns (address pool);
    function feeAmountTickSpacing(uint24 fee) external view returns (int24);
}

/// @notice Subset of Uniswap v3 NonfungiblePositionManager used to create the
///         pool and mint a full-range position.
interface INonfungiblePositionManager {
    struct MintParams {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        address recipient;
        uint256 deadline;
    }

    function createAndInitializePoolIfNecessary(address token0, address token1, uint24 fee, uint160 sqrtPriceX96)
        external
        payable
        returns (address pool);

    function mint(MintParams calldata params)
        external
        payable
        returns (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);

    function approve(address to, uint256 tokenId) external;

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    function factory() external view returns (address);
}
