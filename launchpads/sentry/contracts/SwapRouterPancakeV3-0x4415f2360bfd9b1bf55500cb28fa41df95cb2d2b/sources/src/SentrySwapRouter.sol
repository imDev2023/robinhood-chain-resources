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

interface IWETH9 {
    function withdraw(uint256 wad) external;
}

/**
 * @title SentrySwapRouter
 * @notice Fee-taking wrapper around the canonical Uniswap V3 SwapRouter02.
 *
 * Purpose: self-custody swaps (the PWA's guest swap path) route through
 * here instead of calling SwapRouter02 directly, so they pay the same
 * app fee that Sentry's custodial swaps pay via the server-side skim.
 * The pool hop itself is unchanged: this contract forwards to the same
 * SwapRouter02 and the same V3 pools, so price, liquidity, and pool
 * fee tiers are identical to a direct swap.
 *
 * Fee model (mirrors the custodial skim): `feeBps` of the ETH side of
 * every swap goes to the treasury. Buys skim the ETH input before the
 * swap; sells skim the ETH output after unwrapping. The token side is
 * never touched, so fee-on-transfer launch tokens can't break the math.
 *
 * Referrals: the referral variants take a `referrer` that receives
 * `referralBps` of the ETH side, carved out of the app fee (the
 * swapper's all-in cost never changes). referralBps can never exceed
 * feeBps, self-referrals pay the treasury in full, and a referrer that
 * cannot receive ETH forfeits its cut to the treasury rather than
 * blocking the swap.
 *
 * Only ETH <-> token swaps are supported, matching the guest swap UI
 * (every Sentry pool on Robinhood is WETH-paired).
 *
 * The contract holds no funds between transactions. `rescue*` exists
 * only for tokens or ETH forced in from outside the swap flow.
 */
contract SentrySwapRouter is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    IV3SwapRouter02 public immutable swapRouter;
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
    error SlippageExceeded(uint256 received, uint256 minimum);
    error EthTransferFailed();
    error DirectEthNotAccepted();

    constructor(address swapRouter_, address weth9_, address treasury_, uint16 feeBps_) {
        if (swapRouter_ == address(0) || weth9_ == address(0) || treasury_ == address(0)) {
            revert ZeroAddress();
        }
        if (feeBps_ > MAX_FEE_BPS) revert FeeTooHigh();
        swapRouter = IV3SwapRouter02(swapRouter_);
        weth9 = weth9_;
        treasury = treasury_;
        feeBps = feeBps_;
    }

    /**
     * @notice Buy `tokenOut` with native ETH. The app fee is skimmed off
     * msg.value, the remainder swaps through the V3 pool at `poolFee`,
     * and the output tokens go straight to the caller.
     * @param amountOutMinimum Minimum token output for the swap leg
     * (computed by the client from a post-fee quote); the router reverts
     * the whole transaction when the pool can't meet it.
     */
    function buyExactEthForTokens(address tokenOut, uint24 poolFee, uint256 amountOutMinimum)
        external
        payable
        nonReentrant
        returns (uint256 amountOut)
    {
        return _buy(tokenOut, poolFee, amountOutMinimum, address(0));
    }

    /// @notice Referral variant: `referrer` receives referralBps of the
    /// ETH input, carved out of the app fee. address(0) = no referral.
    function buyExactEthForTokens(
        address tokenOut,
        uint24 poolFee,
        uint256 amountOutMinimum,
        address referrer
    ) external payable nonReentrant returns (uint256 amountOut) {
        return _buy(tokenOut, poolFee, amountOutMinimum, referrer);
    }

    function _buy(address tokenOut, uint24 poolFee, uint256 amountOutMinimum, address referrer)
        private
        returns (uint256 amountOut)
    {
        if (msg.value == 0) revert ZeroAmount();
        uint256 fee = (msg.value * feeBps) / 10_000;
        uint256 swapIn = msg.value - fee;

        // SwapRouter02 wraps msg.value into WETH9 itself.
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

        // Fee moves only after the swap succeeded; a reverted swap
        // reverts the skim with it.
        _payFee(referrer, tokenOut, true, fee);
        emit SwapExecuted(msg.sender, tokenOut, true, msg.value, amountOut, fee);
    }

    /**
     * @notice Sell `amountIn` of `tokenIn` for native ETH. The swap's
     * WETH output lands here, gets unwrapped, the app fee is skimmed,
     * and the remainder is sent to the caller as ETH.
     * @param minEthOut Minimum POST-FEE ETH the seller accepts. Enforced
     * after the skim so the number the user saw is the number
     * guaranteed; the whole transaction reverts otherwise.
     */
    function sellExactTokensForEth(address tokenIn, uint24 poolFee, uint256 amountIn, uint256 minEthOut)
        external
        nonReentrant
        returns (uint256 ethOut)
    {
        return _sell(tokenIn, poolFee, amountIn, minEthOut, address(0));
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
        return _sell(tokenIn, poolFee, amountIn, minEthOut, referrer);
    }

    function _sell(address tokenIn, uint24 poolFee, uint256 amountIn, uint256 minEthOut, address referrer)
        private
        returns (uint256 ethOut)
    {
        if (amountIn == 0) revert ZeroAmount();

        // Balance-delta accounting so fee-on-transfer tokens swap what
        // actually arrived instead of reverting inside the router.
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
                // The post-fee check below is the real guard; a pool-leg
                // minimum here would double-count the fee.
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            })
        );

        IWETH9(weth9).withdraw(wethOut);
        uint256 fee = (wethOut * feeBps) / 10_000;
        ethOut = wethOut - fee;
        if (ethOut < minEthOut) revert SlippageExceeded(ethOut, minEthOut);

        _payFee(referrer, tokenIn, false, fee);
        _sendEth(msg.sender, ethOut);
        emit SwapExecuted(msg.sender, tokenIn, false, received, ethOut, fee);
    }

    // ── Admin ────────────────────────────────────────────────────────

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

    // ── Internals ────────────────────────────────────────────────────

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

    function _sendEth(address to, uint256 amount) private {
        if (amount == 0) return;
        (bool ok,) = to.call{value: amount}("");
        if (!ok) revert EthTransferFailed();
    }

    /// @dev Only WETH9.withdraw may push ETH here; anything else is a
    /// mistake we'd rather bounce than strand.
    receive() external payable {
        if (msg.sender != weth9) revert DirectEthNotAccepted();
    }
}
