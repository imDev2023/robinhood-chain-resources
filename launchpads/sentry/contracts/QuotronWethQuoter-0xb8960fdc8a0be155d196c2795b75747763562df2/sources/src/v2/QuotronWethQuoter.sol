// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "v4-core/types/PoolId.sol";
import {Currency} from "v4-core/types/Currency.sol";
import {StateLibrary} from "v4-core/libraries/StateLibrary.sol";
import {SwapMath} from "v4-core/libraries/SwapMath.sol";
import {TickMath} from "v4-core/libraries/TickMath.sol";
import {TickBitmap} from "v4-core/libraries/TickBitmap.sol";
import {BitMath} from "v4-core/libraries/BitMath.sol";
import {LiquidityMath} from "v4-core/libraries/LiquidityMath.sol";
import {ProtocolFeeLibrary} from "v4-core/libraries/ProtocolFeeLibrary.sol";
import {SafeCast} from "v4-core/libraries/SafeCast.sol";

import {QuotronV2FeeLib} from "./QuotronV2FeeLib.sol";

interface IQuotronRouterView {
    function poolManager() external view returns (address);
    function quotron() external view returns (address);
    function weth() external view returns (address);
    function hook() external view returns (address);
    function poolKey() external view returns (PoolKey memory);
    function wethIsCurrency0() external view returns (bool);
}

interface IQuotronHookView {
    function currentFeeBps(address account) external view returns (uint256);
    function paused() external view returns (bool);
}

interface IQuotronLaunchView {
    function isLaunched() external view returns (bool);
}

/// @title QuotronWethQuoter
/// @notice View-only quotes for the sealed QUOTRON/WETH router. Aggregators
/// staticcall with `(amount, payer)` and receive output plus the payer's hook
/// fee without that wallet holding ETH, QUOTRON, or a router allowance.
///
/// This contract never calls PoolManager.swap. The live hook rejects every
/// non-router sender, and wrapping the router would price fees for the quoter
/// instead of `payer`. Quotes replay the hook fee lib, then the v4 pool math
/// with the same 0 LP-fee override the hook returns.
contract QuotronWethQuoter {
    using PoolIdLibrary for PoolKey;
    using ProtocolFeeLibrary for uint16;

    uint256 private constant MAX_STEPS = 1024;

    address public immutable router;
    IPoolManager public immutable poolManager;
    IQuotronHookView public immutable hook;
    address public immutable quotron;
    address public immutable weth;
    PoolId public immutable poolId;
    bool public immutable wethIsCurrency0;
    PoolKey public poolKey;

    error ZeroAddress();
    error InvalidPool();
    error InvalidAmount();
    error InvalidPayer();
    error Paused_();
    error TradingNotOpen();
    error ExactOutputFeeTooHigh();
    error PartialFill();
    error InvalidFeeForExactOut();
    error PriceLimitAlreadyExceeded();
    error PriceLimitOutOfBounds();
    error InsufficientLiquidity();

    struct SwapState {
        int256 amountSpecifiedRemaining;
        int256 amountCalculated;
        uint160 sqrtPriceX96;
        int24 tick;
        uint128 liquidity;
        uint24 swapFee;
        int24 tickSpacing;
        uint160 sqrtPriceLimitX96;
        bool zeroForOne;
        bool exactInput;
    }

    constructor(address router_) {
        if (router_ == address(0)) revert ZeroAddress();

        IQuotronRouterView routerView = IQuotronRouterView(router_);
        address poolManager_ = routerView.poolManager();
        address hook_ = routerView.hook();
        address quotron_ = routerView.quotron();
        address weth_ = routerView.weth();
        PoolKey memory key = routerView.poolKey();
        bool wethIsCurrency0_ = routerView.wethIsCurrency0();

        if (
            poolManager_ == address(0) || hook_ == address(0) || quotron_ == address(0) || weth_ == address(0)
                || address(key.hooks) != hook_
        ) {
            revert InvalidPool();
        }

        address currency0 = Currency.unwrap(key.currency0);
        address currency1 = Currency.unwrap(key.currency1);
        bool validPair = wethIsCurrency0_
            ? (currency0 == weth_ && currency1 == quotron_)
            : (currency0 == quotron_ && currency1 == weth_);
        if (!validPair) revert InvalidPool();

        router = router_;
        poolManager = IPoolManager(poolManager_);
        hook = IQuotronHookView(hook_);
        quotron = quotron_;
        weth = weth_;
        poolKey = key;
        poolId = key.toId();
        wethIsCurrency0 = wethIsCurrency0_;
    }

    function currentFeeBps(address payer) external view returns (uint256) {
        return hook.currentFeeBps(payer);
    }

    /// @notice Exact-ETH buy quote. Fee is taken from gross `ethIn` before the
    /// remaining WETH hits the pool, matching `buyExactEth`.
    function quoteBuyExactEth(uint256 ethIn, address payer)
        external
        view
        returns (uint256 quotronOut, uint256 feeBps, uint256 feeWeth, uint256 poolWethIn)
    {
        _requireLiveQuote(ethIn, payer);
        feeBps = hook.currentFeeBps(payer);
        feeWeth = QuotronV2FeeLib.feeFromGross(ethIn, feeBps);
        poolWethIn = ethIn - feeWeth;
        if (poolWethIn == 0) revert InvalidAmount();
        quotronOut = _swapExactIn(wethIsCurrency0, poolWethIn);
    }

    /// @notice Exact-QUOTRON sell quote. The pool produces WETH first; the hook
    /// then skims the payer's fee from that gross output, matching
    /// `sellExactQuotronForEth`.
    function quoteSellExactQuotron(uint256 quotronIn, address payer)
        external
        view
        returns (uint256 ethOut, uint256 feeBps, uint256 feeWeth, uint256 poolWethOut)
    {
        _requireLiveQuote(quotronIn, payer);
        poolWethOut = _swapExactIn(!wethIsCurrency0, quotronIn);
        feeBps = hook.currentFeeBps(payer);
        feeWeth = QuotronV2FeeLib.feeFromGross(poolWethOut, feeBps);
        ethOut = poolWethOut - feeWeth;
        if (ethOut == 0) revert InvalidAmount();
    }

    /// @notice Exact-QUOTRON buy quote. Fee is added on top of the net pool
    /// WETH input, matching `buyExactQuotron`. Reverts at a 50%+ fee tier.
    function quoteBuyExactQuotron(uint256 quotronOut, address payer)
        external
        view
        returns (uint256 ethIn, uint256 feeBps, uint256 feeWeth, uint256 poolWethIn)
    {
        _requireLiveQuote(quotronOut, payer);
        feeBps = hook.currentFeeBps(payer);
        if (feeBps >= 5_000) revert ExactOutputFeeTooHigh();
        poolWethIn = _swapExactOut(wethIsCurrency0, quotronOut);
        feeWeth = QuotronV2FeeLib.feeFromNet(poolWethIn, feeBps);
        ethIn = poolWethIn + feeWeth;
    }

    function _requireLiveQuote(uint256 amount, address payer) internal view {
        if (payer == address(0)) revert InvalidPayer();
        if (amount == 0 || amount > uint256(type(int256).max)) revert InvalidAmount();
        if (hook.paused()) revert Paused_();
        if (!IQuotronLaunchView(quotron).isLaunched()) revert TradingNotOpen();
    }

    function _swapExactIn(bool zeroForOne, uint256 amountIn) internal view returns (uint256 amountOut) {
        (int256 specifiedDelta, int256 unspecifiedDelta) = _simulate(zeroForOne, -int256(amountIn));
        if (specifiedDelta >= 0 || uint256(-specifiedDelta) != amountIn) revert PartialFill();
        if (unspecifiedDelta <= 0) revert InvalidAmount();
        amountOut = uint256(unspecifiedDelta);
    }

    function _swapExactOut(bool zeroForOne, uint256 amountOut) internal view returns (uint256 amountIn) {
        (int256 specifiedDelta, int256 unspecifiedDelta) = _simulate(zeroForOne, int256(amountOut));
        if (specifiedDelta <= 0 || uint256(specifiedDelta) != amountOut) revert PartialFill();
        if (unspecifiedDelta >= 0) revert InvalidAmount();
        amountIn = uint256(-unspecifiedDelta);
    }

    function _simulate(bool zeroForOne, int256 amountSpecified)
        internal
        view
        returns (int256 specifiedDelta, int256 unspecifiedDelta)
    {
        SwapState memory state = _initSwapState(zeroForOne, amountSpecified);
        uint256 steps;

        while (!(state.amountSpecifiedRemaining == 0 || state.sqrtPriceX96 == state.sqrtPriceLimitX96)) {
            if (++steps > MAX_STEPS) revert InsufficientLiquidity();
            _step(state);
        }

        specifiedDelta = amountSpecified - state.amountSpecifiedRemaining;
        unspecifiedDelta = state.amountCalculated;
    }

    function _initSwapState(bool zeroForOne, int256 amountSpecified) internal view returns (SwapState memory state) {
        uint24 protocolFee;
        (state.sqrtPriceX96, state.tick, protocolFee,) = StateLibrary.getSlot0(poolManager, poolId);
        state.liquidity = StateLibrary.getLiquidity(poolManager, poolId);
        state.tickSpacing = poolKey.tickSpacing;
        state.sqrtPriceLimitX96 = zeroForOne ? TickMath.MIN_SQRT_PRICE + 1 : TickMath.MAX_SQRT_PRICE - 1;
        state.zeroForOne = zeroForOne;
        state.exactInput = amountSpecified < 0;
        state.amountSpecifiedRemaining = amountSpecified;

        uint16 protocolFeeForDirection = zeroForOne
            ? ProtocolFeeLibrary.getZeroForOneFee(protocolFee)
            : ProtocolFeeLibrary.getOneForZeroFee(protocolFee);
        state.swapFee = protocolFeeForDirection == 0 ? 0 : protocolFeeForDirection.calculateSwapFee(0);

        if (state.swapFee >= SwapMath.MAX_SWAP_FEE && !state.exactInput) revert InvalidFeeForExactOut();
        if (amountSpecified == 0) revert InvalidAmount();

        if (zeroForOne) {
            if (state.sqrtPriceLimitX96 >= state.sqrtPriceX96) revert PriceLimitAlreadyExceeded();
            if (state.sqrtPriceLimitX96 <= TickMath.MIN_SQRT_PRICE) revert PriceLimitOutOfBounds();
        } else {
            if (state.sqrtPriceLimitX96 <= state.sqrtPriceX96) revert PriceLimitAlreadyExceeded();
            if (state.sqrtPriceLimitX96 >= TickMath.MAX_SQRT_PRICE) revert PriceLimitOutOfBounds();
        }
    }

    function _step(SwapState memory state) internal view {
        uint160 sqrtPriceStartX96 = state.sqrtPriceX96;
        (int24 tickNext, bool initialized) =
            _nextInitializedTickWithinOneWord(state.tick, state.tickSpacing, state.zeroForOne);
        if (tickNext <= TickMath.MIN_TICK) tickNext = TickMath.MIN_TICK;
        if (tickNext >= TickMath.MAX_TICK) tickNext = TickMath.MAX_TICK;

        uint160 sqrtPriceNextX96 = TickMath.getSqrtPriceAtTick(tickNext);
        uint256 amountIn;
        uint256 amountOut;
        uint256 feeAmount;
        (state.sqrtPriceX96, amountIn, amountOut, feeAmount) = SwapMath.computeSwapStep(
            state.sqrtPriceX96,
            SwapMath.getSqrtPriceTarget(state.zeroForOne, sqrtPriceNextX96, state.sqrtPriceLimitX96),
            state.liquidity,
            state.amountSpecifiedRemaining,
            state.swapFee
        );

        if (state.exactInput) {
            unchecked {
                state.amountSpecifiedRemaining += SafeCast.toInt256(amountIn + feeAmount);
            }
            state.amountCalculated += SafeCast.toInt256(amountOut);
        } else {
            unchecked {
                state.amountSpecifiedRemaining -= SafeCast.toInt256(amountOut);
            }
            state.amountCalculated -= SafeCast.toInt256(amountIn + feeAmount);
        }

        if (state.sqrtPriceX96 == sqrtPriceNextX96) {
            if (initialized) {
                (, int128 liquidityNet) = StateLibrary.getTickLiquidity(poolManager, poolId, tickNext);
                unchecked {
                    if (state.zeroForOne) liquidityNet = -liquidityNet;
                }
                state.liquidity = LiquidityMath.addDelta(state.liquidity, liquidityNet);
            }
            unchecked {
                state.tick = state.zeroForOne ? tickNext - 1 : tickNext;
            }
        } else if (state.sqrtPriceX96 != sqrtPriceStartX96) {
            state.tick = TickMath.getTickAtSqrtPrice(state.sqrtPriceX96);
        }
    }

    function _nextInitializedTickWithinOneWord(int24 tick, int24 tickSpacing, bool lte)
        internal
        view
        returns (int24 next, bool initialized)
    {
        unchecked {
            int24 compressed = TickBitmap.compress(tick, tickSpacing);

            if (lte) {
                (int16 wordPos, uint8 bitPos) = TickBitmap.position(compressed);
                uint256 mask = type(uint256).max >> (uint256(type(uint8).max) - bitPos);
                uint256 masked = StateLibrary.getTickBitmap(poolManager, poolId, wordPos) & mask;
                initialized = masked != 0;
                next = initialized
                    ? (compressed - int24(uint24(bitPos - BitMath.mostSignificantBit(masked)))) * tickSpacing
                    : (compressed - int24(uint24(bitPos))) * tickSpacing;
            } else {
                (int16 wordPos, uint8 bitPos) = TickBitmap.position(++compressed);
                uint256 mask = ~((1 << bitPos) - 1);
                uint256 masked = StateLibrary.getTickBitmap(poolManager, poolId, wordPos) & mask;
                initialized = masked != 0;
                next = initialized
                    ? (compressed + int24(uint24(BitMath.leastSignificantBit(masked) - bitPos))) * tickSpacing
                    : (compressed + int24(uint24(type(uint8).max - bitPos))) * tickSpacing;
            }
        }
    }
}
