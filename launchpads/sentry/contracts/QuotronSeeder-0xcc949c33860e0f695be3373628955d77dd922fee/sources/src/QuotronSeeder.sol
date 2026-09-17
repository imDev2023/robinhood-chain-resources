// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {IUnlockCallback} from "v4-core/interfaces/callback/IUnlockCallback.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {ModifyLiquidityParams} from "v4-core/types/PoolOperation.sol";
import {BalanceDelta, BalanceDeltaLibrary} from "v4-core/types/BalanceDelta.sol";
import {Currency} from "v4-core/types/Currency.sol";

interface IERC20S {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

/// @title QuotronSeeder — add-only liquidity for the ten floor pools
/// @notice Seeds launch liquidity and receives the LP-compound deposits.
/// There is deliberately NO remove function and no way to withdraw a
/// position: liquidity added through this contract is locked forever.
/// That is the "permanently locked LP compound" promise, enforced by
/// the absence of the code that could break it.
contract QuotronSeeder is IUnlockCallback {
    using BalanceDeltaLibrary for BalanceDelta;

    IPoolManager public immutable pm;
    address public owner;

    error NotOwner();
    error NotPoolManager();
    error TransferFailed();

    constructor(address pm_) {
        pm = IPoolManager(pm_);
        owner = msg.sender;
    }

    function transferOwnership(address n) external {
        if (msg.sender != owner) revert NotOwner();
        owner = n;
    }

    struct Seed {
        PoolKey key;
        int24 tickLower;
        int24 tickUpper;
        int256 liquidity;
        address payer;
    }

    /// @notice Add liquidity to a pool. Tokens are pulled from the
    /// caller, who must have approved this contract. One-way.
    function addLiquidity(PoolKey calldata key, int24 tickLower, int24 tickUpper, int256 liquidity) external {
        if (msg.sender != owner) revert NotOwner();
        pm.unlock(abi.encode(Seed(key, tickLower, tickUpper, liquidity, msg.sender)));
    }

    function unlockCallback(bytes calldata data) external returns (bytes memory) {
        if (msg.sender != address(pm)) revert NotPoolManager();
        Seed memory s = abi.decode(data, (Seed));
        (BalanceDelta delta,) = pm.modifyLiquidity(
            s.key,
            ModifyLiquidityParams({
                tickLower: s.tickLower, tickUpper: s.tickUpper, liquidityDelta: s.liquidity, salt: 0
            }),
            ""
        );
        if (delta.amount0() < 0) {
            _settle(s.key.currency0, s.payer, uint256(uint128(-delta.amount0())));
        }
        if (delta.amount1() < 0) {
            _settle(s.key.currency1, s.payer, uint256(uint128(-delta.amount1())));
        }
        return "";
    }

    function _settle(Currency c, address payer, uint256 amount) internal {
        pm.sync(c);
        if (!IERC20S(Currency.unwrap(c)).transferFrom(payer, address(pm), amount)) {
            revert TransferFailed();
        }
        pm.settle();
    }
}
