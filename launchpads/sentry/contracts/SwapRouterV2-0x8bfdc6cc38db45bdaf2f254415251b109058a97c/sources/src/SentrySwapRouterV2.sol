// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface IV3SwapRouter02 {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params)
        external
        payable
        returns (uint256 amountOut);
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address);
}

interface IUniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;
}

interface IWETH9 {
    function deposit() external payable;
    function withdraw(uint256 wad) external;
}

/**
 * @title SentrySwapRouterV2
 * @notice Second-generation fee-taking swap wrapper: routes through the
 * canonical Uniswap V3 SwapRouter02 (like its predecessor) AND directly
 * against Uniswap V2 pairs, so any WETH-paired token on either venue is
 * swappable through one contract.
 *
 * V2 execution needs no external periphery: the pair address resolves
 * from the immutable V2 factory (never caller-supplied, so a malicious
 * pair can't be injected), WETH transfers to the pair, and `swap()` is
 * called with constant-product math (0.3% pair fee). Sells use the
 * canonical fee-on-transfer-safe pattern (pair balance delta) and buys
 * enforce the minimum on the recipient's actual balance delta, so taxed
 * tokens degrade honestly instead of reverting in the pair.
 *
 * Fee model unchanged from v1: `feeBps` of the ETH side of every swap
 * goes to the treasury. Buys skim the ETH input before the swap; sells
 * skim the ETH output after unwrapping. The token side is never touched.
 *
 * Referrals: the referral variants take a `referrer` that receives
 * `referralBps` of the ETH side, carved out of the app fee (the
 * swapper's all-in cost never changes). referralBps can never exceed
 * feeBps, self-referrals pay the treasury in full, and a referrer that
 * cannot receive ETH forfeits its cut to the treasury rather than
 * blocking the swap.
 *
 * The custodial backend routes its V2 swaps through this contract too:
 * a raw transfer-then-swap from an EOA would be atomically frontrunnable
 * (anyone can call `pair.swap` after the transfer lands), while this
 * contract does both in one transaction.
 *
 * Holds no funds between transactions; `rescue*` covers forced dust.
 */
contract SentrySwapRouterV2 is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    IV3SwapRouter02 public immutable swapRouter;
    IUniswapV2Factory public immutable v2Factory;
    address public immutable weth9;

    address public treasury;
    uint16 public feeBps;
    /// @notice Referrer's slice of the ETH side, in bps of volume.
    /// Always a subset of feeBps; 0 disables referral payouts.
    uint16 public referralBps;

    /// @notice Hard ceiling on the app fee: 3%.
    uint16 public constant MAX_FEE_BPS = 300;

    event SwapExecuted(
        address indexed sender,
        address indexed token,
        bool indexed isBuy,
        uint256 amountIn,
        uint256 amountOut,
        uint256 feeAmount
    );
    event FeeBpsUpdated(uint16 previousBps, uint16 newBps);
    event ReferralBpsUpdated(uint16 previousBps, uint16 newBps);
    event TreasuryUpdated(address previousTreasury, address newTreasury);
    event ReferralPaid(
        address indexed referrer,
        address indexed swapper,
        address indexed token,
        bool isBuy,
        uint256 amount
    );

    error ZeroAddress();
    error ZeroAmount();
    error FeeTooHigh();
    error ReferralExceedsFee();
    error NoV2Pair();
    error SlippageExceeded(uint256 received, uint256 minimum);
    error EthTransferFailed();
    error DirectEthNotAccepted();

    constructor(
        address swapRouter_,
        address v2Factory_,
        address weth9_,
        address treasury_,
        uint16 feeBps_
    ) {
        if (swapRouter_ == address(0) || weth9_ == address(0) || treasury_ == address(0)) {
            revert ZeroAddress();
        }
        // v2Factory_ may be zero on chains without a V2 deployment; the
        // V2 entrypoints then revert NoV2Pair.
        if (feeBps_ > MAX_FEE_BPS) revert FeeTooHigh();
        swapRouter = IV3SwapRouter02(swapRouter_);
        v2Factory = IUniswapV2Factory(v2Factory_);
        weth9 = weth9_;
        treasury = treasury_;
        feeBps = feeBps_;
    }

    /* ────────────────────────── V3 venue ────────────────────────── */

    /**
     * @notice Buy `tokenOut` with native ETH through the V3 pool at
     * `poolFee`. Identical semantics to the v1 router.
     */
    function buyExactEthForTokens(address tokenOut, uint24 poolFee, uint256 amountOutMinimum)
        external
        payable
        nonReentrant
        returns (uint256 amountOut)
    {
        return _buyV3(tokenOut, poolFee, amountOutMinimum, address(0));
    }

    /// @notice Referral variant: `referrer` receives referralBps of the
    /// ETH input, carved out of the app fee. address(0) = no referral.
    function buyExactEthForTokens(
        address tokenOut,
        uint24 poolFee,
        uint256 amountOutMinimum,
        address referrer
    ) external payable nonReentrant returns (uint256 amountOut) {
        return _buyV3(tokenOut, poolFee, amountOutMinimum, referrer);
    }

    function _buyV3(address tokenOut, uint24 poolFee, uint256 amountOutMinimum, address referrer)
        private
        returns (uint256 amountOut)
    {
        if (msg.value == 0) revert ZeroAmount();
        uint256 fee = (msg.value * feeBps) / 10_000;
        uint256 swapIn = msg.value - fee;

        amountOut = swapRouter.exactInputSingle{value: swapIn}(
            IV3SwapRouter02.ExactInputSingleParams({
                tokenIn: weth9,
                tokenOut: tokenOut,
                fee: poolFee,
                recipient: msg.sender,
                amountIn: swapIn,
                amountOutMinimum: amountOutMinimum,
                sqrtPriceLimitX96: 0
            })
        );

        _payFee(referrer, tokenOut, true, fee);
        emit SwapExecuted(msg.sender, tokenOut, true, msg.value, amountOut, fee);
    }

    /**
     * @notice Sell `amountIn` of `tokenIn` for native ETH through the V3
     * pool at `poolFee`. `minEthOut` is POST-fee, identical to v1.
     */
    function sellExactTokensForEth(address tokenIn, uint24 poolFee, uint256 amountIn, uint256 minEthOut)
        external
        nonReentrant
        returns (uint256 ethOut)
    {
        return _sellV3(tokenIn, poolFee, amountIn, minEthOut, address(0));
    }

    /// @notice Referral variant: `referrer` receives referralBps of the
    /// ETH output, carved out of the app fee. address(0) = no referral.
    function sellExactTokensForEth(
        address tokenIn,
        uint24 poolFee,
        uint256 amountIn,
        uint256 minEthOut,
        address referrer
    ) external nonReentrant returns (uint256 ethOut) {
        return _sellV3(tokenIn, poolFee, amountIn, minEthOut, referrer);
    }

    function _sellV3(address tokenIn, uint24 poolFee, uint256 amountIn, uint256 minEthOut, address referrer)
        private
        returns (uint256 ethOut)
    {
        if (amountIn == 0) revert ZeroAmount();

        uint256 balanceBefore = IERC20(tokenIn).balanceOf(address(this));
        IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), amountIn);
        uint256 received = IERC20(tokenIn).balanceOf(address(this)) - balanceBefore;
        if (received == 0) revert ZeroAmount();

        IERC20(tokenIn).forceApprove(address(swapRouter), received);
        uint256 wethOut = swapRouter.exactInputSingle(
            IV3SwapRouter02.ExactInputSingleParams({
                tokenIn: tokenIn,
                tokenOut: weth9,
                fee: poolFee,
                recipient: address(this),
                amountIn: received,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            })
        );

        ethOut = _settleEthSale(tokenIn, received, wethOut, minEthOut, referrer);
    }

    /* ────────────────────────── V2 venue ────────────────────────── */

    /**
     * @notice Buy `tokenOut` with native ETH against its WETH V2 pair.
     * @param amountOutMinimum Minimum tokens the BUYER must actually
     * receive (checked on their balance delta, so fee-on-transfer taxes
     * count against the minimum instead of being silently eaten).
     */
    function buyExactEthForTokensV2(address tokenOut, uint256 amountOutMinimum)
        external
        payable
        nonReentrant
        returns (uint256 amountOut)
    {
        return _buyV2(tokenOut, amountOutMinimum, address(0));
    }

    /// @notice Referral variant: `referrer` receives referralBps of the
    /// ETH input, carved out of the app fee. address(0) = no referral.
    function buyExactEthForTokensV2(address tokenOut, uint256 amountOutMinimum, address referrer)
        external
        payable
        nonReentrant
        returns (uint256 amountOut)
    {
        return _buyV2(tokenOut, amountOutMinimum, referrer);
    }

    function _buyV2(address tokenOut, uint256 amountOutMinimum, address referrer)
        private
        returns (uint256 amountOut)
    {
        if (msg.value == 0) revert ZeroAmount();
        address pair = _v2Pair(tokenOut);
        uint256 fee = (msg.value * feeBps) / 10_000;
        uint256 swapIn = msg.value - fee;

        IWETH9(weth9).deposit{value: swapIn}();
        (uint256 reserveIn, uint256 reserveOut) = _orderedReserves(pair, weth9, tokenOut);
        uint256 expectedOut = _getAmountOut(swapIn, reserveIn, reserveOut);

        IERC20(weth9).safeTransfer(pair, swapIn);
        uint256 balanceBefore = IERC20(tokenOut).balanceOf(msg.sender);
        (uint256 out0, uint256 out1) = weth9 < tokenOut
            ? (uint256(0), expectedOut)
            : (expectedOut, uint256(0));
        IUniswapV2Pair(pair).swap(out0, out1, msg.sender, "");

        amountOut = IERC20(tokenOut).balanceOf(msg.sender) - balanceBefore;
        if (amountOut < amountOutMinimum) revert SlippageExceeded(amountOut, amountOutMinimum);

        _payFee(referrer, tokenOut, true, fee);
        emit SwapExecuted(msg.sender, tokenOut, true, msg.value, amountOut, fee);
    }

    /**
     * @notice Sell `amountIn` of `tokenIn` for native ETH against its
     * WETH V2 pair. Canonical fee-on-transfer-safe pattern: the swap
     * uses what actually ARRIVED at the pair. `minEthOut` is POST-fee.
     */
    function sellExactTokensForEthV2(address tokenIn, uint256 amountIn, uint256 minEthOut)
        external
        nonReentrant
        returns (uint256 ethOut)
    {
        return _sellV2(tokenIn, amountIn, minEthOut, address(0));
    }

    /// @notice Referral variant: `referrer` receives referralBps of the
    /// ETH output, carved out of the app fee. address(0) = no referral.
    function sellExactTokensForEthV2(address tokenIn, uint256 amountIn, uint256 minEthOut, address referrer)
        external
        nonReentrant
        returns (uint256 ethOut)
    {
        return _sellV2(tokenIn, amountIn, minEthOut, referrer);
    }

    function _sellV2(address tokenIn, uint256 amountIn, uint256 minEthOut, address referrer)
        private
        returns (uint256 ethOut)
    {
        if (amountIn == 0) revert ZeroAmount();
        address pair = _v2Pair(tokenIn);

        (uint256 reserveIn, uint256 reserveOut) = _orderedReserves(pair, tokenIn, weth9);
        IERC20(tokenIn).safeTransferFrom(msg.sender, pair, amountIn);
        uint256 arrived = IERC20(tokenIn).balanceOf(pair) - reserveIn;
        if (arrived == 0) revert ZeroAmount();

        uint256 wethOut = _getAmountOut(arrived, reserveIn, reserveOut);
        (uint256 out0, uint256 out1) = tokenIn < weth9
            ? (uint256(0), wethOut)
            : (wethOut, uint256(0));
        IUniswapV2Pair(pair).swap(out0, out1, address(this), "");

        ethOut = _settleEthSale(tokenIn, arrived, wethOut, minEthOut, referrer);
    }

    /* ────────────────────────── Admin ───────────────────────────── */

    function setFeeBps(uint16 newFeeBps) external onlyOwner {
        if (newFeeBps > MAX_FEE_BPS) revert FeeTooHigh();
        if (newFeeBps < referralBps) revert ReferralExceedsFee();
        emit FeeBpsUpdated(feeBps, newFeeBps);
        feeBps = newFeeBps;
    }

    /// @notice Set the referrer's slice of the ETH side (bps of volume,
    /// at most feeBps). The season dial: 25 -> 20 -> 15 -> 10.
    function setReferralBps(uint16 newReferralBps) external onlyOwner {
        if (newReferralBps > feeBps) revert ReferralExceedsFee();
        emit ReferralBpsUpdated(referralBps, newReferralBps);
        referralBps = newReferralBps;
    }

    function setTreasury(address newTreasury) external onlyOwner {
        if (newTreasury == address(0)) revert ZeroAddress();
        emit TreasuryUpdated(treasury, newTreasury);
        treasury = newTreasury;
    }

    /// @notice Recover tokens that were sent here outside the swap flow.
    function rescueToken(address token, uint256 amount) external onlyOwner {
        IERC20(token).safeTransfer(owner(), amount);
    }

    /// @notice Recover ETH that was forced here outside the swap flow.
    function rescueEth(uint256 amount) external onlyOwner {
        _sendEth(owner(), amount);
    }

    /* ────────────────────────── Internals ───────────────────────── */

    /// @dev Unwrap the WETH proceeds of a sale, skim the fee, enforce the
    ///      post-fee minimum, pay the seller. Shared by both venues.
    function _settleEthSale(address tokenIn, uint256 amountIn, uint256 wethOut, uint256 minEthOut, address referrer)
        private
        returns (uint256 ethOut)
    {
        IWETH9(weth9).withdraw(wethOut);
        uint256 fee = (wethOut * feeBps) / 10_000;
        ethOut = wethOut - fee;
        if (ethOut < minEthOut) revert SlippageExceeded(ethOut, minEthOut);

        _payFee(referrer, tokenIn, false, fee);
        _sendEth(msg.sender, ethOut);
        emit SwapExecuted(msg.sender, tokenIn, false, amountIn, ethOut, fee);
    }

    /// @dev Split `fee` between the referrer and the treasury. The
    /// referrer's cut is referralBps/feeBps of the fee, which equals
    /// referralBps of the swap's ETH side. Self-referrals earn nothing,
    /// and a referrer whose ETH transfer fails forfeits the cut to the
    /// treasury so a hostile receiver can never block a swap.
    function _payFee(address referrer, address token, bool isBuy, uint256 fee) private {
        uint256 referralCut = 0;
        if (fee != 0 && referralBps != 0 && referrer != address(0) && referrer != msg.sender) {
            referralCut = (fee * referralBps) / feeBps;
            if (referralCut != 0) {
                (bool ok,) = referrer.call{value: referralCut}("");
                if (ok) {
                    emit ReferralPaid(referrer, msg.sender, token, isBuy, referralCut);
                } else {
                    referralCut = 0;
                }
            }
        }
        _sendEth(treasury, fee - referralCut);
    }

    /// @dev Pair lookup from the immutable factory only — callers never
    ///      supply pair addresses.
    function _v2Pair(address token) private view returns (address pair) {
        if (address(v2Factory) == address(0)) revert NoV2Pair();
        pair = v2Factory.getPair(weth9, token);
        if (pair == address(0)) revert NoV2Pair();
    }

    function _orderedReserves(address pair, address tokenIn, address tokenOut)
        private
        view
        returns (uint256 reserveIn, uint256 reserveOut)
    {
        (uint112 r0, uint112 r1,) = IUniswapV2Pair(pair).getReserves();
        (reserveIn, reserveOut) = tokenIn < tokenOut ? (uint256(r0), uint256(r1)) : (uint256(r1), uint256(r0));
    }

    /// @dev Standard x*y=k output with the 0.3% pair fee.
    function _getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut)
        private
        pure
        returns (uint256)
    {
        uint256 amountInWithFee = amountIn * 997;
        return (amountInWithFee * reserveOut) / (reserveIn * 1000 + amountInWithFee);
    }

    function _sendEth(address to, uint256 amount) private {
        if (amount == 0) return;
        (bool ok,) = to.call{value: amount}("");
        if (!ok) revert EthTransferFailed();
    }

    /// @dev Only WETH9.withdraw may push ETH here.
    receive() external payable {
        if (msg.sender != weth9) revert DirectEthNotAccepted();
    }
}
