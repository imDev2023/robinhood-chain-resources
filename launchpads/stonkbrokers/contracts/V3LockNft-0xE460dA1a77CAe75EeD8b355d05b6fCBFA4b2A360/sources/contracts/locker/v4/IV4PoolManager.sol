// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @notice Minimal surface of the canonical Uniswap v4 singleton `PoolManager`
/// needed by the liquidity locker. Native ETH is `currency == address(0)`.
///
/// BalanceDelta is packed int256: the high 128 bits are the currency0 delta and
/// the low 128 bits are the currency1 delta. A NEGATIVE delta means the caller
/// owes the pool (must `settle`); a POSITIVE delta means the pool owes the
/// caller (may `take`).
struct PoolKey {
    address currency0; // address(0) == native ETH; must sort before currency1
    address currency1;
    uint24 fee;
    int24 tickSpacing;
    address hooks;
}

struct ModifyLiquidityParams {
    int24 tickLower;
    int24 tickUpper;
    int256 liquidityDelta;
    bytes32 salt;
}

interface IV4PoolManager {
    function initialize(PoolKey memory key, uint160 sqrtPriceX96) external returns (int24 tick);

    function unlock(bytes calldata data) external returns (bytes memory);

    /// @return callerDelta total delta owed to/from the caller (principal + fees)
    /// @return feesAccrued the fee-only portion of `callerDelta`
    function modifyLiquidity(PoolKey memory key, ModifyLiquidityParams memory params, bytes calldata hookData)
        external
        returns (int256 callerDelta, int256 feesAccrued);

    function settle() external payable returns (uint256 paid);

    function sync(address currency) external;

    function take(address currency, address to, uint256 amount) external;

    function extsload(bytes32 slot) external view returns (bytes32);
}

/// @notice Callback the PoolManager invokes inside `unlock`.
interface IV4UnlockCallback {
    function unlockCallback(bytes calldata data) external returns (bytes memory);
}
