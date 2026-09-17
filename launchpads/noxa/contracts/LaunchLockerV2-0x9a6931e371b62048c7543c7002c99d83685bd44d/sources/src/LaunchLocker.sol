// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

library LauncherTypes {
    struct LaunchedToken {
        address token;
        address deployer;
        address pairedToken;
        address positionManager;
        uint256 positionId;
        uint256 dexId;
        uint256 launchConfigId;
        uint256 restrictionsEndTime;
        uint256 supply;
        bool isToken0;
        uint24 poolFee;
        bool exists;
        uint256 initialBuyAmount;
    }
}

interface ILaunchFactory {
    function getLaunchedToken(address token) external view returns (LauncherTypes.LaunchedToken memory);
}

interface INonfungiblePositionManager {
    struct CollectParams {
        uint256 tokenId;
        address recipient;
        uint128 amount0Max;
        uint128 amount1Max;
    }

    function ownerOf(uint256 tokenId) external view returns (address);

    function positions(uint256 tokenId)
        external
        view
        returns (
            uint96 nonce,
            address operator,
            address token0,
            address token1,
            uint24 fee,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );

    function collect(CollectParams calldata params) external returns (uint256 amount0, uint256 amount1);
}

interface ISwapRouter02 {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);
}

interface IWETH9 is IERC20 {
    function deposit() external payable;
    function withdraw(uint256) external;
}

interface IUniswapV3PoolState {
    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );
}

interface ILaunchTokenView {
    function liquidityPool() external view returns (address);
}

/// @dev Uniswap V3 oracle surface for manipulation-resistant TWAP pricing (FIX H3).
interface IUniswapV3PoolOracle {
    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);
    function observations(uint256 index)
        external
        view
        returns (uint32 blockTimestamp, int56 tickCumulative, uint160 secondsPerLiquidityCumulativeX128, bool initialized);
}

/// @dev Uniswap V3 TickMath.getSqrtRatioAtTick (0.8 port; identical to the factory's/vault's) —
///      converts a TWAP average tick back into a sqrtPriceX96 for the min-out quote.
library TickMath {
    int24 internal constant MAX_TICK = 887272;

    function getSqrtRatioAtTick(int24 tick) internal pure returns (uint160 sqrtPriceX96) {
        unchecked {
            uint256 absTick = tick < 0 ? uint256(-int256(tick)) : uint256(int256(tick));
            require(absTick <= uint256(int256(MAX_TICK)), "T");
            uint256 ratio = absTick & 0x1 != 0 ? 0xfffcb933bd6fad37aa2d162d1a594001 : 0x100000000000000000000000000000000;
            if (absTick & 0x2 != 0) ratio = (ratio * 0xfff97272373d413259a46990580e213a) >> 128;
            if (absTick & 0x4 != 0) ratio = (ratio * 0xfff2e50f5f656932ef12357cf3c7fdcc) >> 128;
            if (absTick & 0x8 != 0) ratio = (ratio * 0xffe5caca7e10e4e61c3624eaa0941cd0) >> 128;
            if (absTick & 0x10 != 0) ratio = (ratio * 0xffcb9843d60f6159c9db58835c926644) >> 128;
            if (absTick & 0x20 != 0) ratio = (ratio * 0xff973b41fa98c081472e6896dfb254c0) >> 128;
            if (absTick & 0x40 != 0) ratio = (ratio * 0xff2ea16466c96a3843ec78b326b52861) >> 128;
            if (absTick & 0x80 != 0) ratio = (ratio * 0xfe5dee046a99a2a811c461f1969c3053) >> 128;
            if (absTick & 0x100 != 0) ratio = (ratio * 0xfcbe86c7900a88aedcffc83b479aa3a4) >> 128;
            if (absTick & 0x200 != 0) ratio = (ratio * 0xf987a7253ac413176f2b074cf7815e54) >> 128;
            if (absTick & 0x400 != 0) ratio = (ratio * 0xf3392b0822b70005940c7a398e4b70f3) >> 128;
            if (absTick & 0x800 != 0) ratio = (ratio * 0xe7159475a2c29b7443b29c7fa6e889d9) >> 128;
            if (absTick & 0x1000 != 0) ratio = (ratio * 0xd097f3bdfd2022b8845ad8f792aa5825) >> 128;
            if (absTick & 0x2000 != 0) ratio = (ratio * 0xa9f746462d870fdf8a65dc1f90e061e5) >> 128;
            if (absTick & 0x4000 != 0) ratio = (ratio * 0x70d869a156d2a1b890bb3df62baf32f7) >> 128;
            if (absTick & 0x8000 != 0) ratio = (ratio * 0x31be135f97d08fd981231505542fcfa6) >> 128;
            if (absTick & 0x10000 != 0) ratio = (ratio * 0x9aa508b5b7a84e1c677de54f3e99bc9) >> 128;
            if (absTick & 0x20000 != 0) ratio = (ratio * 0x5d6af8dedb81196699c329225ee604) >> 128;
            if (absTick & 0x40000 != 0) ratio = (ratio * 0x2216e584f5fa1ea926041bedfe98) >> 128;
            if (absTick & 0x80000 != 0) ratio = (ratio * 0x48a170391f7dc42444e8fa2) >> 128;
            if (tick > 0) ratio = type(uint256).max / ratio;
            sqrtPriceX96 = uint160((ratio >> 32) + (ratio % (1 << 32) == 0 ? 0 : 1));
        }
    }
}

contract LaunchLocker is Ownable, ReentrancyGuard, IERC721Receiver {
    error AlreadyInitialized();
    error InvalidProtocolFee();
    error NoFeesToCollect();
    error NotAuthorized();
    error NotDeployer();
    error NotFactory();
    error PositionNotHeld();
    error TokenNotFound();
    error ZeroAddress();
    error InvalidSlippage();
    error PoolNotFound();
    error TooLowMinOut(); // explicit-minOut overload below the TWAP floor (self-sandwich guard)
    error InsufficientHistory(); // pool too young / not enough observations for a safe TWAP
    error InvalidTwapWindow();
    error NoPendingReassign();
    error TimelockNotElapsed();

    event FactoryUpdated(address indexed newFactory);
    event FeeCollectorUpdated(address indexed collector, bool status);
    event FeeRedirectUpdated(address indexed token, address indexed recipient);
    // Fees are now realised and paid out fully in native ETH.
    // recipientAmount / protocolAmount are ETH (wei); tokenSwapped/wethCollected are the
    // pre-conversion components for accounting.
    event FeesClaimed(
        address indexed token,
        address indexed caller,
        uint256 tokenSwapped,
        uint256 wethCollected,
        uint256 wethFromSwap,
        uint256 totalEth,
        uint256 recipientAmount,
        uint256 protocolAmount
    );
    event PositionLocked(
        address indexed token,
        address indexed deployer,
        uint256 positionId,
        address pairedToken,
        uint256 indexed dexId,
        address positionManager
    );
    event ProtocolFeeRecipientUpdated(address newRecipient);
    event ProtocolFeeUpdated(uint256 newFee);
    event MaxSlippageUpdated(uint256 newMaxSlippageBps);
    event TwapWindowUpdated(uint32 newTwapWindow);
    // Timelocked CTO / community-takeover reassignment of a creator's fee-share recipient.
    event ProposeCreatorReassign(address indexed token, address indexed newRecipient, uint256 eta);
    event ExecuteCreatorReassign(address indexed token, address indexed newRecipient);
    event CancelCreatorReassign(address indexed token); // FIX F-16 — distinct from a proposal
    event PayoutFailed(address indexed to, uint256 amount); // FIX vuln-0004(2) — never brick collection
    event TokenSwapSkipped(address indexed token, uint256 tokenAmount); // FIX F-2 — retained for later

    uint256 internal constant Q96 = 0x1000000000000000000000000; // 2**96
    uint256 public constant BPS_DENOMINATOR = 10_000;

    /// @notice Two-step timelock delay for reassignCreatorPayout (wall-clock seconds).
    uint256 public constant REASSIGN_DELAY = 86_400; // 24h
    /// @notice Hard floor on the TWAP window: no owner knob can price below this (anti self-sandwich).
    uint32 internal constant MIN_TWAP_WINDOW = 60;
    /// @notice FIX F-4 — maxSlippageBps is bounded to a sane band. Below the floor a normal downtrend
    ///         bricks every collection; above the ceiling the anti-sandwich floor collapses toward 0,
    ///         letting ANY mempool searcher take ~100% of the token-side fee — outside the owner-trust
    ///         boundary. The floor comfortably exceeds the 1% pool fee.
    uint256 public constant MIN_SLIPPAGE_BPS = 100; // 1%
    uint256 public constant MAX_SLIPPAGE_BPS = 2_000; // 20%

    /// @notice GLOBAL, owner-adjustable platform fee share (percent, 0..100). collectFees reads the
    ///         CURRENT value for every token, so the owner can change the split platform-wide
    ///         (intentional — NOT snapshotted per launch). Default 50 (50% platform / 50% creator).
    uint256 public protocolFeeShare;
    address public protocolFeeRecipient;
    address public factory;

    /// @notice Fee-conversion infra, set ONCE at deploy and IMMUTABLE (removes the malicious-router
    ///         drain vector — the owner can never repoint the swap at a hostile router/WETH).
    address public immutable weth;
    address public immutable swapRouter;

    uint256 public maxSlippageBps;

    /// @notice TWAP window (seconds) for the token->WETH fee-conversion min-out. Effective window is
    ///         clamped to available pool history; must be >= MIN_TWAP_WINDOW.
    uint32 public twapWindow;

    /// @notice The ONLY allowed post-launch redirect of a creator's fee share, set by the owner via
    ///         the 24h timelock (community takeover / CTO). Takes precedence over feeRedirects +
    ///         deployer.
    mapping(address => address) public creatorPayoutOverride;

    struct PendingReassign {
        address newRecipient;
        uint256 eta; // block.timestamp after which execute is allowed
    }

    mapping(address => PendingReassign) public pendingReassign;

    mapping(address => address[]) public deployerTokens;
    mapping(address => bool) public feeCollectors;
    mapping(address => address) public feeRedirects;

    constructor(address _protocolFeeRecipient, uint256 _protocolFeeShare, address _weth, address _swapRouter)
        Ownable(msg.sender)
    {
        if (_protocolFeeRecipient == address(0)) revert ZeroAddress();
        if (_protocolFeeShare > 100) revert InvalidProtocolFee();
        if (_weth == address(0) || _swapRouter == address(0)) revert ZeroAddress();

        protocolFeeRecipient = _protocolFeeRecipient;
        protocolFeeShare = _protocolFeeShare;
        weth = _weth;
        swapRouter = _swapRouter;
        maxSlippageBps = 500; // 5% default
        twapWindow = 1800; // 30 min default TWAP window
    }

    /// @dev Required so WETH.withdraw() can send native ETH back to this contract.
    receive() external payable {}

    function initialize(address _factory) external onlyOwner {
        if (_factory == address(0)) revert ZeroAddress();
        if (factory != address(0)) revert AlreadyInitialized();

        factory = _factory;
        emit FactoryUpdated(_factory);
    }

    function getLaunchedToken(address token) public view returns (LauncherTypes.LaunchedToken memory) {
        return ILaunchFactory(factory).getLaunchedToken(token);
    }

    function onERC721Received(address, address from, uint256, bytes calldata)
        external
        view
        override
        returns (bytes4)
    {
        if (from != factory) revert NotFactory();
        return IERC721Receiver.onERC721Received.selector;
    }

    function lockPosition(address token) external {
        if (msg.sender != factory) revert NotFactory();

        LauncherTypes.LaunchedToken memory launched = ILaunchFactory(factory).getLaunchedToken(token);
        if (!launched.exists || launched.token == address(0)) revert TokenNotFound();
        if (
            launched.deployer == address(0) || launched.pairedToken == address(0)
                || launched.positionManager == address(0) || launched.token != token
        ) revert TokenNotFound();

        if (INonfungiblePositionManager(launched.positionManager).ownerOf(launched.positionId) != address(this)) {
            revert PositionNotHeld();
        }

        deployerTokens[launched.deployer].push(token);
        emit PositionLocked(
            token,
            launched.deployer,
            launched.positionId,
            launched.pairedToken,
            launched.dexId,
            launched.positionManager
        );
    }

    /// @notice Collect accrued V3 fees, convert the token side to WETH, unwrap all to native ETH and
    ///         split by the token's launch-locked protocolFeeShare. minOut for the token->WETH swap
    ///         is derived from the pool's manipulation-resistant TWAP (FIX H3) — never raw slot0.
    function collectFees(address token) external nonReentrant {
        _collectFees(token, 0, true, false);
    }

    /// @notice Same as above but the caller supplies an explicit minimum WETH out. The value must be
    ///         >= the TWAP-derived floor — an authorized caller can only ask for MORE protection,
    ///         never less. This kills the old minOut=0 self-sandwich path (FIX H3).
    function collectFees(address token, uint256 minWethOutFromTokenSwap) external nonReentrant {
        _collectFees(token, minWethOutFromTokenSwap, false, false);
    }

    /// @notice FIX F-2 — collect and pay out ONLY the already-liquid WETH side, skipping the
    ///         token->WETH swap entirely. Lets fees be claimed even when the token side can't be
    ///         priced/swapped safely (downtrend, thin liquidity, young pool). The token side is
    ///         collected into the locker and swept by a later collection once conditions allow.
    function collectFeesWethOnly(address token) external nonReentrant {
        _collectFees(token, 0, true, true);
    }

    function _collectFees(address token, uint256 minWethOutFromTokenSwap, bool deriveMinOut, bool wethOnly)
        internal
    {
        LauncherTypes.LaunchedToken memory launched = ILaunchFactory(factory).getLaunchedToken(token);
        if (!launched.exists) revert TokenNotFound();
        if (msg.sender != owner() && msg.sender != launched.deployer && !feeCollectors[msg.sender]) {
            revert NotAuthorized();
        }

        INonfungiblePositionManager manager = INonfungiblePositionManager(launched.positionManager);
        (uint256 amount0, uint256 amount1) = manager.collect(
            INonfungiblePositionManager.CollectParams({
                tokenId: launched.positionId,
                recipient: address(this),
                amount0Max: type(uint128).max,
                amount1Max: type(uint128).max
            })
        );

        // Split into WETH-side (already ETH-equivalent) and launched-token-side (needs swap).
        uint256 tokenAmount;
        uint256 wethCollected;
        if (launched.isToken0) {
            // token0 == launched token, token1 == WETH
            tokenAmount = amount0;
            wethCollected = amount1;
        } else {
            // token0 == WETH, token1 == launched token
            tokenAmount = amount1;
            wethCollected = amount0;
        }

        // The token balance to swap is this collection's token fees PLUS anything RETAINED from a prior
        // skipped/WETH-only collection (FIX F-2). Only revert NoFeesToCollect when there is genuinely
        // nothing to do: no fresh fees AND (this is a WETH-only call OR there is no retained token to
        // re-sweep). This lets a pumped-then-dead token recover its stranded token-side fees once its
        // price is back above the floor, even with no new trading.
        uint256 heldToken = IERC20(token).balanceOf(address(this));
        if (amount0 == 0 && amount1 == 0 && (wethOnly || heldToken == 0)) revert NoFeesToCollect();

        uint256 wethFromSwap = 0;
        uint256 tokenSwapped = 0;
        if (!wethOnly && heldToken > 0) {
            // FIX F-2/F-3/F-13 — derive the TWAP floor (pool-fee-adjusted). If there is no safe TWAP
            // (young pool / insufficient history) or the amount is dust, SKIP the swap and RETAIN the
            // token for a later collection rather than reverting the whole call — the liquid WETH side
            // must never be frozen. We never fall back to spot, preserving the H3 anti-sandwich floor.
            (bool floorOk, uint256 floor) = _deriveMinOut(token, launched.isToken0, heldToken, launched.poolFee);
            if (floorOk) {
                uint256 minOut;
                if (deriveMinOut) {
                    minOut = floor;
                } else {
                    if (minWethOutFromTokenSwap < floor) revert TooLowMinOut();
                    minOut = minWethOutFromTokenSwap;
                }
                // FIX F-2 — best-effort swap: if it can't clear minOut (downtrend / price impact /
                // thin liquidity), skip + retain rather than brick the WETH-side payout.
                wethFromSwap = _trySwapTokenToWeth(token, launched.poolFee, heldToken, minOut);
                if (wethFromSwap > 0) {
                    tokenSwapped = heldToken;
                } else {
                    emit TokenSwapSkipped(token, heldToken);
                }
            } else {
                emit TokenSwapSkipped(token, heldToken);
            }
        }

        uint256 totalWeth = wethCollected + wethFromSwap;
        if (totalWeth == 0) revert NoFeesToCollect();

        // Unwrap everything to native ETH.
        IWETH9(weth).withdraw(totalWeth);

        // GLOBAL, current protocolFeeShare (owner-adjustable platform-wide; NOT snapshotted).
        uint256 protocolAmount = (totalWeth * protocolFeeShare) / 100;
        uint256 recipientAmount = totalWeth - protocolAmount;

        // Recipient precedence: owner's timelocked CTO override > creator's own feeRedirect >
        // deployer.
        address recipient;
        if (creatorPayoutOverride[token] != address(0)) {
            recipient = creatorPayoutOverride[token];
        } else if (feeRedirects[token] != address(0)) {
            recipient = feeRedirects[token];
        } else {
            recipient = launched.deployer;
        }

        if (protocolAmount > 0) _payout(weth, protocolFeeRecipient, protocolAmount);
        if (recipientAmount > 0) _payout(weth, recipient, recipientAmount);

        emit FeesClaimed(
            token, msg.sender, tokenSwapped, wethCollected, wethFromSwap, totalWeth, recipientAmount, protocolAmount
        );
    }

    /// @dev Send native ETH; if the recipient rejects ETH, re-wrap and send WETH so the
    ///      overall payout can never be bricked. FIX vuln-0004(2) — if even the WETH transfer fails
    ///      (a recipient that rejects both native ETH and ERC20 WETH — impossible for canonical WETH),
    ///      emit and leave the WETH in the contract instead of reverting the entire fee collection.
    function _payout(address weth_, address to, uint256 amount) internal {
        (bool ok,) = to.call{value: amount}("");
        if (!ok) {
            IWETH9(weth_).deposit{value: amount}();
            if (!IWETH9(weth_).transfer(to, amount)) emit PayoutFailed(to, amount);
        }
    }

    /// @dev FIX F-2 — best-effort token->WETH swap. Reverts inside the router (minOut not met) are
    ///      caught: the swap is skipped, the approval reset, and the token retained for a later
    ///      collection, so a stuck token side can never brick the liquid WETH-side payout.
    function _trySwapTokenToWeth(address token, uint24 poolFee, uint256 amountIn, uint256 minOut)
        internal
        returns (uint256 amountOut)
    {
        IERC20(token).approve(swapRouter, amountIn);
        try ISwapRouter02(swapRouter).exactInputSingle(
            ISwapRouter02.ExactInputSingleParams({
                tokenIn: token,
                tokenOut: weth,
                fee: poolFee,
                recipient: address(this),
                amountIn: amountIn,
                amountOutMinimum: minOut,
                sqrtPriceLimitX96: 0
            })
        ) returns (uint256 out) {
            amountOut = out;
        } catch {
            IERC20(token).approve(swapRouter, 0);
            amountOut = 0;
        }
    }

    /// @dev Manipulation-resistant token->WETH minOut from the pool's TWAP over `twapWindow`
    ///      (clamped to available history), with `maxSlippageBps` tolerance (FIX H3). Returns
    ///      ok=false (rather than reverting) when the pool is too young for a safe TWAP or the amount
    ///      is dust — the caller then SKIPS the swap and retains the token (FIX F-2/F-13). Never falls
    ///      back to spot, so no one can self-sandwich a fresh pool.
    function _deriveMinOut(address token, bool isToken0, uint256 tokenAmount, uint24 poolFee)
        internal
        view
        returns (bool ok, uint256 minOut)
    {
        address pool = ILaunchTokenView(token).liquidityPool();
        if (pool == address(0)) return (false, 0);
        uint256 sp = uint256(_twapSqrtPrice(pool));
        if (sp == 0) return (false, 0); // insufficient history — skip, never price off manipulable spot

        uint256 expectedOut;
        if (isToken0) {
            // amountOut(token1=WETH) = tokenAmount * price ; price = (sp/Q96)^2
            expectedOut = Math.mulDiv(Math.mulDiv(tokenAmount, sp, Q96), sp, Q96);
        } else {
            // launched token is token1, WETH is token0.
            // amountOut(token0=WETH) = tokenAmount / price = tokenAmount * (Q96/sp)^2
            expectedOut = Math.mulDiv(Math.mulDiv(tokenAmount, Q96, sp), Q96, sp);
        }

        // FIX F-2 — deduct the pool's own swap fee (poolFee is in 1e-6 units) before applying the
        // slippage tolerance, so the floor is actually reachable by the real swap (the linear TWAP
        // quote ignores the fee the swap must pay).
        expectedOut = (expectedOut * (1_000_000 - poolFee)) / 1_000_000;
        // FIX F-13 — never run a swap with a 0 floor (dust on a very cheap token); skip instead.
        if (expectedOut == 0) return (false, 0);

        minOut = (expectedOut * (BPS_DENOMINATOR - maxSlippageBps)) / BPS_DENOMINATOR;
        // FIX F-13 (hardening) — also skip if the slippage haircut truncates the floor to 0 (sub-~1-wei
        // value), so a swap can NEVER run at amountOutMinimum == 0 even in the dust corner.
        if (minOut == 0) return (false, 0);
        ok = true;
    }

    /// @dev Pool TWAP sqrtPriceX96 over `twapWindow` clamped to available observation history.
    ///      Returns 0 when history is shorter than MIN_TWAP_WINDOW or the observe reverts (OLD) —
    ///      the caller then reverts InsufficientHistory. Relies on the cardinality grown at launch.
    function _twapSqrtPrice(address pool) internal view returns (uint160) {
        (, , uint16 obsIndex, uint16 obsCard,,,) = IUniswapV3PoolState(pool).slot0();
        if (obsCard == 0) return 0;
        (uint32 oldestTs,,, bool init) =
            IUniswapV3PoolOracle(pool).observations((uint256(obsIndex) + 1) % obsCard);
        if (!init) {
            (oldestTs,,,) = IUniswapV3PoolOracle(pool).observations(0);
        }
        uint32 age = uint32(block.timestamp) - oldestTs;
        uint32 w = twapWindow;
        if (age < w) w = age;
        if (w < MIN_TWAP_WINDOW) return 0;

        uint32[] memory secondsAgos = new uint32[](2);
        secondsAgos[0] = w;
        secondsAgos[1] = 0;
        (bool ok, bytes memory ret) = pool.staticcall(abi.encodeCall(IUniswapV3PoolOracle.observe, (secondsAgos)));
        if (!ok) return 0;
        (int56[] memory tc,) = abi.decode(ret, (int56[], uint160[]));
        int56 delta = tc[1] - tc[0];
        int24 avgTick = int24(delta / int56(uint56(w)));
        if (delta < 0 && (delta % int56(uint56(w)) != 0)) avgTick--;
        return TickMath.getSqrtRatioAtTick(avgTick);
    }

    function setFeeRedirect(address token, address recipient) external {
        LauncherTypes.LaunchedToken memory launched = ILaunchFactory(factory).getLaunchedToken(token);
        if (!launched.exists) revert TokenNotFound();
        if (msg.sender != launched.deployer) revert NotDeployer();

        feeRedirects[token] = recipient;
        emit FeeRedirectUpdated(token, recipient);
    }

    /*//////////////////////// CTO / COMMUNITY TAKEOVER (TIMELOCKED) ////////////////////////*/

    /// @notice Step 1 of the ONLY allowed owner-initiated redirect of a creator's fee share
    ///         (community takeover / CTO). Proposes a new recipient; takes effect only after the 24h
    ///         timelock via executeCreatorReassign.
    function proposeCreatorReassign(address token, address newRecipient) external onlyOwner {
        if (newRecipient == address(0)) revert ZeroAddress();
        LauncherTypes.LaunchedToken memory launched = ILaunchFactory(factory).getLaunchedToken(token);
        if (!launched.exists) revert TokenNotFound();
        uint256 eta = block.timestamp + REASSIGN_DELAY;
        pendingReassign[token] = PendingReassign({newRecipient: newRecipient, eta: eta});
        emit ProposeCreatorReassign(token, newRecipient, eta);
    }

    /// @notice Step 2: execute a proposed reassignment once the 24h timelock has elapsed.
    ///         Redirects where the creator's fee share is sent (precedence: above feeRedirect/deployer).
    function executeCreatorReassign(address token) external onlyOwner {
        PendingReassign memory p = pendingReassign[token];
        if (p.newRecipient == address(0)) revert NoPendingReassign();
        if (block.timestamp < p.eta) revert TimelockNotElapsed();
        creatorPayoutOverride[token] = p.newRecipient;
        delete pendingReassign[token];
        emit ExecuteCreatorReassign(token, p.newRecipient);
    }

    /// @notice Cancel a pending (not-yet-executed) reassignment proposal.
    function cancelCreatorReassign(address token) external onlyOwner {
        if (pendingReassign[token].newRecipient == address(0)) revert NoPendingReassign();
        delete pendingReassign[token];
        emit CancelCreatorReassign(token); // FIX F-16 — distinct event so indexers don't desync
    }

    function setFeeCollector(address collector, bool status) external onlyOwner {
        if (collector == address(0)) revert ZeroAddress();
        feeCollectors[collector] = status;
        emit FeeCollectorUpdated(collector, status);
    }

    function setProtocolFeeShare(uint256 _protocolFeeShare) external onlyOwner {
        if (_protocolFeeShare > 100) revert InvalidProtocolFee();
        protocolFeeShare = _protocolFeeShare;
        emit ProtocolFeeUpdated(_protocolFeeShare);
    }

    function setProtocolFeeRecipient(address _protocolFeeRecipient) external onlyOwner {
        if (_protocolFeeRecipient == address(0)) revert ZeroAddress();
        protocolFeeRecipient = _protocolFeeRecipient;
        emit ProtocolFeeRecipientUpdated(_protocolFeeRecipient);
    }

    /// @notice FIX F-4 — bounded to [MIN_SLIPPAGE_BPS, MAX_SLIPPAGE_BPS]. Below the floor a normal
    ///         downtrend bricks all collection; above the ceiling the anti-sandwich floor collapses
    ///         and any searcher can take ~100% of the token-side fee.
    function setMaxSlippageBps(uint256 _maxSlippageBps) external onlyOwner {
        if (_maxSlippageBps < MIN_SLIPPAGE_BPS || _maxSlippageBps > MAX_SLIPPAGE_BPS) revert InvalidSlippage();
        maxSlippageBps = _maxSlippageBps;
        emit MaxSlippageUpdated(_maxSlippageBps);
    }

    /// @notice Set the TWAP window for the fee-conversion min-out. Hard-floored at MIN_TWAP_WINDOW
    ///         so no owner setting can weaken it toward manipulable spot.
    function setTwapWindow(uint32 _twapWindow) external onlyOwner {
        if (_twapWindow < MIN_TWAP_WINDOW) revert InvalidTwapWindow();
        twapWindow = _twapWindow;
        emit TwapWindowUpdated(_twapWindow);
    }
}
