// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {IUnlockCallback} from "@uniswap/v4-core/src/interfaces/callback/IUnlockCallback.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {BalanceDelta} from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {LiquidityAmounts} from "@uniswap/v4-periphery/src/libraries/LiquidityAmounts.sol";

import {UnihoodHook} from "./UnihoodHook.sol";
import {UnihoodToken} from "./UnihoodToken.sol";

/// @title UnihoodFactory
/// @notice One-transaction launches on Robinhood Chain: deploy a fixed-supply token, register it
///         with the global UnihoodHook, initialize its native-ETH Uniswap v4 pool at the start
///         tick, place the entire supply as a single-sided range down to the minimum usable tick,
///         and optionally execute the creator's fee-free first buy. The factory keeps the launch
///         position forever: it has no function that can remove liquidity, so the position is
///         locked by construction. Nothing ever migrates.
contract UnihoodFactory is IUnlockCallback {
    using PoolIdLibrary for PoolKey;

    uint256 public constant TOKEN_SUPPLY = 1_000_000_000 ether;
    int24 public constant TICK_SPACING = 200;
    uint24 public constant LP_FEE_PIPS = 0;

    uint256 public constant MAX_NAME_BYTES = 48;
    uint256 public constant MAX_SYMBOL_BYTES = 12;
    uint256 public constant MAX_METAURI_BYTES = 4096;

    IPoolManager public immutable poolManager;
    UnihoodHook public immutable hook;
    /// @notice Every pool starts here (~$2.5k mcap at deploy calibration). Buys move the tick down.
    int24 public immutable startTick;

    address[] public allTokens;

    struct CallbackData {
        PoolKey key;
        address token;
        uint256 devBuyNative;
        address creator;
    }

    error InvalidMetadata();
    error LaunchFailedShape();
    error NotPoolManager();
    error Reentrancy();

    event Launched(
        address indexed token,
        bytes32 indexed poolId,
        address indexed creator,
        string name,
        string symbol,
        string metaURI,
        int24 startTick,
        uint256 tokenLiquidity,
        uint256 devBuyNative,
        uint256 devBuyTokens
    );

    modifier nonReentrant() {
        assembly {
            if tload(0) {
                mstore(0x00, 0xab143c06) // Reentrancy()
                revert(0x1c, 0x04)
            }
            tstore(0, 1)
        }
        _;
        assembly {
            tstore(0, 0)
        }
    }

    constructor(IPoolManager poolManager_, UnihoodHook hook_, int24 startTick_) {
        poolManager = poolManager_;
        hook = hook_;
        // Start tick must sit on the spacing grid and above the graduation tick (buys move down).
        if (startTick_ % TICK_SPACING != 0 || startTick_ <= hook_.gradTick()) revert LaunchFailedShape();
        startTick = startTick_;
    }

    /// @notice Launches a token. `msg.value` (optional) is the creator's fee-free first buy.
    function launch(string calldata name, string calldata symbol, string calldata metaURI)
        external
        payable
        nonReentrant
        returns (address token, bytes32 poolId)
    {
        if (
            bytes(name).length == 0 || bytes(name).length > MAX_NAME_BYTES || bytes(symbol).length == 0
                || bytes(symbol).length > MAX_SYMBOL_BYTES || bytes(metaURI).length > MAX_METAURI_BYTES
        ) revert InvalidMetadata();

        token = address(new UnihoodToken(name, symbol, metaURI, msg.sender, TOKEN_SUPPLY));

        PoolKey memory key = PoolKey({
            currency0: Currency.wrap(address(0)),
            currency1: Currency.wrap(token),
            fee: LP_FEE_PIPS,
            tickSpacing: TICK_SPACING,
            hooks: IHooks(address(hook))
        });
        poolId = hook.registerPool(key, token, msg.sender);
        poolManager.initialize(key, TickMath.getSqrtPriceAtTick(startTick));

        bytes memory result = poolManager.unlock(
            abi.encode(CallbackData({key: key, token: token, devBuyNative: msg.value, creator: msg.sender}))
        );
        (uint256 tokenLiquidity, uint256 devBuyTokens) = abi.decode(result, (uint256, uint256));

        allTokens.push(token);
        emit Launched(
            token, poolId, msg.sender, name, symbol, metaURI, startTick, tokenLiquidity, msg.value, devBuyTokens
        );
    }

    function unlockCallback(bytes calldata data) external returns (bytes memory) {
        if (msg.sender != address(poolManager)) revert NotPoolManager();
        CallbackData memory cb = abi.decode(data, (CallbackData));

        // Entire supply as one single-sided range [minUsableTick, startTick]; the pool sits exactly
        // at startTick so the position is 100% token. Rounding dust stays in the factory forever.
        int24 tickLower = TickMath.minUsableTick(TICK_SPACING);
        uint128 liquidity = LiquidityAmounts.getLiquidityForAmount1(
            TickMath.getSqrtPriceAtTick(tickLower), TickMath.getSqrtPriceAtTick(startTick), TOKEN_SUPPLY
        );
        (BalanceDelta delta,) = poolManager.modifyLiquidity(
            cb.key,
            IPoolManager.ModifyLiquidityParams({
                tickLower: tickLower,
                tickUpper: startTick,
                liquidityDelta: int256(uint256(liquidity)),
                salt: bytes32(0)
            }),
            ""
        );
        uint256 owedToken = uint256(uint128(-delta.amount1()));
        poolManager.sync(cb.key.currency1);
        UnihoodToken(cb.token).transfer(address(poolManager), owedToken);
        poolManager.settle();

        uint256 devBuyTokens = 0;
        if (cb.devBuyNative != 0) {
            BalanceDelta swapDelta = poolManager.swap(
                cb.key,
                IPoolManager.SwapParams({
                    zeroForOne: true,
                    amountSpecified: -int256(cb.devBuyNative),
                    sqrtPriceLimitX96: TickMath.MIN_SQRT_PRICE + 1
                }),
                ""
            );
            poolManager.settle{value: cb.devBuyNative}();
            devBuyTokens = uint256(uint128(swapDelta.amount1()));
            poolManager.take(cb.key.currency1, cb.creator, devBuyTokens);
        }

        return abi.encode(uint256(owedToken), devBuyTokens);
    }

    // ---------------------------------------------------------------- board reads

    function tokenCount() external view returns (uint256) {
        return allTokens.length;
    }

    function tokensSlice(uint256 start, uint256 count) external view returns (address[] memory slice) {
        uint256 length = allTokens.length;
        if (start >= length) return new address[](0);
        uint256 end = start + count;
        if (end > length) end = length;
        slice = new address[](end - start);
        for (uint256 i = start; i < end; i++) {
            slice[i - start] = allTokens[i];
        }
    }

    function poolKeyFor(address token) public view returns (PoolKey memory key) {
        key = PoolKey({
            currency0: Currency.wrap(address(0)),
            currency1: Currency.wrap(token),
            fee: LP_FEE_PIPS,
            tickSpacing: TICK_SPACING,
            hooks: IHooks(address(hook))
        });
    }

    function poolIdFor(address token) external view returns (bytes32) {
        return PoolId.unwrap(poolKeyFor(token).toId());
    }
}
