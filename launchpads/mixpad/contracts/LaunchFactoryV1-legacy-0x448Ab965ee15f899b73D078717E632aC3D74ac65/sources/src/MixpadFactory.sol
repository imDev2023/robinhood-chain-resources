// SPDX-License-Identifier: MIT
pragma solidity ^0.8.36;

import {Ownable2Step, Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {
    Currency,
    PoolKey,
    PoolId,
    SwapParams,
    BalanceDelta,
    BalanceDeltaLib,
    IPoolManager,
    IUnlockCallback,
    IHooks,
    IPositionManager,
    IPermit2,
    IStateView,
    PoolIdLibrary
} from "./interfaces/IV4.sol";
import {TickMath} from "./libraries/TickMath.sol";
import {LiquidityMath} from "./libraries/LiquidityMath.sol";
import {MixpadToken} from "./MixpadToken.sol";
import {MixpadTokenDeployer} from "./MixpadTokenDeployer.sol";

/// @notice Surface MixpadFactory needs from MixpadHook at launch time.
/// buybackBurnBps and dividendBps split the hook's platform fee share
/// between auto buyback-and-burn and holder dividends; the remainder stays
/// with the treasury. Both are locked at registration and immutable after.
interface IMixpadHook {
    function registerToken(
        address token,
        uint16 buybackBurnBps,
        uint16 buyTaxBps,
        uint16 sellTaxBps
    ) external;
}

/// @notice Deploys MixpadToken instances into Uniswap V4, mints a one-sided
/// liquidity position for the full supply, burns that position to the dead
/// address, and hands fee/tax/anti-snipe control to MixpadHook. No transfer
/// restriction is ever placed on the token itself; every defensive and
/// tokenomics mechanism lives in the hook.
contract MixpadFactory is Ownable2Step, ReentrancyGuard, IUnlockCallback {
    using SafeERC20 for IERC20;
    using BalanceDeltaLib for BalanceDelta;
    using PoolIdLibrary for PoolKey;

    address public immutable poolManager;
    address public immutable positionManager;
    address private immutable tokenDeployer;
    address public constant PERMIT2 = 0x000000000022D473030F116dDEE9F6B43aC78BA3;
    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    uint8 private constant ACT_MINT_POSITION = 0x02;
    uint8 private constant ACT_SETTLE_PAIR = 0x0d;
    uint8 private constant ACT_SWEEP = 0x13;

    uint160 private constant MIN_SQRT_PRICE_LIMIT = 4295128740;

    uint24 public constant POOL_FEE = 0;
    int24 public constant TICK_SPACING = 200;

    int24 private constant MIN_USABLE_TICK = -887200;
    int24 private constant MAX_USABLE_TICK = 887200;

    uint256 public constant SUPPLY = 1_000_000_000 ether;
    uint256 public constant BPS_DENOM = 10_000;

    uint256 public constant MAX_LAUNCH_FEE = 0.001 ether;
    uint256 public constant MIN_GRADUATION_THRESHOLD = 0.5 ether;
    uint256 public constant MAX_GRADUATION_THRESHOLD = 1000 ether;
    int24 public constant MIN_INITIAL_TICK = -887200;
    int24 public constant MAX_INITIAL_TICK = -200;

    address public treasury;
    address public hook;
    address public stateView;

    uint256 public launchFee;
    int24 public initialTick = -204000;
    uint256 public defaultGraduationThreshold;
    bool public launchEnabled = true;

    struct LaunchedToken {
        address deployer;
        uint256 positionId;
        int24 tickLower;
        int24 tickUpper;
        uint256 graduationThreshold;
        bool exists;
        bool graduated;
        address quoteToken;
        bool tokenIsZero;
    }

    mapping(address => LaunchedToken) public launchedTokens;
    mapping(address => address) public tokenCreator;
    mapping(address => int256) public netPoolQuote;
    mapping(address => uint256) public pendingRefunds;

    event TokenLaunched(
        address indexed token,
        address indexed deployer,
        bytes32 indexed poolId,
        uint256 positionId,
        uint256 initialBuyAmount,
        uint16 buybackBurnBps
    );
    event Graduated(address indexed token, uint256 pairedQuote, uint256 threshold);
    event LaunchFeeUpdated(uint256 fee);
    event TreasuryUpdated(address indexed treasury);
    event HookUpdated(address indexed hook);
    event StateViewUpdated(address indexed stateView);
    event InitialTickUpdated(int24 tick);
    event GraduationThresholdUpdated(uint256 threshold);
    event RefundPending(address indexed recipient, uint256 amount);
    event RefundClaimed(address indexed recipient, uint256 amount);
    event LaunchEnabledUpdated(bool enabled);

    error InsufficientLaunchFee();
    error FeeTransferFailed();
    error TokenDeployFailed();
    error ZeroAddress();
    error TokenNotFound();
    error NotHook();
    error NotPoolManager();
    error LaunchFeeTooHigh();
    error GraduationThresholdTooLow();
    error GraduationThresholdTooHigh();
    error InitialTickOutOfRange();
    error HookAlreadySet();
    error HookNotSet();
    error NothingToRefund();
    error SlippageTooHigh();
    error InitialBuyNotSupportedForErc20Quote();
    error LaunchDisabled();
    error TaxAllocationTooHigh();

    constructor(
        address poolManager_,
        address positionManager_,
        address treasury_,
        uint256 launchFee_,
        uint256 graduationThreshold_
    ) Ownable(msg.sender) {
        if (poolManager_ == address(0) || positionManager_ == address(0) || treasury_ == address(0)) {
            revert ZeroAddress();
        }
        poolManager = poolManager_;
        positionManager = positionManager_;
        treasury = treasury_;
        launchFee = launchFee_;
        defaultGraduationThreshold = graduationThreshold_;
        tokenDeployer = address(new MixpadTokenDeployer());
    }

    /// @notice Launch against native ETH/BNB with default graduation threshold.
    function launchToken(
        string calldata name,
        string calldata symbol,
        string calldata metadataURI,
        string calldata image,
        string calldata description,
        MixpadToken.Socials calldata socials,
        bytes32 salt,
        uint256 deadline,
        uint128 minLiquidity,
        uint16 buybackBurnBps,
        uint16 buyTaxBps,
        uint16 sellTaxBps
    ) external payable nonReentrant returns (address token) {
        if (!launchEnabled) revert LaunchDisabled();
        if (msg.value < launchFee) revert InsufficientLaunchFee();
        return _launchToken(
            address(0),
            defaultGraduationThreshold,
            msg.value - launchFee,
            name,
            symbol,
            metadataURI,
            image,
            description,
            socials,
            salt,
            deadline,
            minLiquidity,
            buybackBurnBps,
            buyTaxBps,
            sellTaxBps
        );
    }

    /// @notice Launch against an arbitrary ERC-20 quote token (e.g. a
    /// tokenized RWA/xStock pair). No initial buy is supported on this path;
    /// msg.value must equal launchFee exactly, and graduationThreshold is
    /// required with no fallback to the native default.
    function launchTokenWithQuote(
        string calldata name,
        string calldata symbol,
        string calldata metadataURI,
        string calldata image,
        string calldata description,
        MixpadToken.Socials calldata socials,
        bytes32 salt,
        address quoteToken_,
        uint256 graduationThreshold,
        uint256 deadline,
        uint128 minLiquidity,
        uint16 buybackBurnBps,
        uint16 buyTaxBps,
        uint16 sellTaxBps
    ) external payable nonReentrant returns (address token) {
        if (!launchEnabled) revert LaunchDisabled();
        if (quoteToken_ == address(0)) revert ZeroAddress();
        if (msg.value != launchFee) revert InitialBuyNotSupportedForErc20Quote();
        if (graduationThreshold < MIN_GRADUATION_THRESHOLD) revert GraduationThresholdTooLow();
        if (graduationThreshold > MAX_GRADUATION_THRESHOLD) revert GraduationThresholdTooHigh();
        return _launchToken(
            quoteToken_,
            graduationThreshold,
            0,
            name,
            symbol,
            metadataURI,
            image,
            description,
            socials,
            salt,
            deadline,
            minLiquidity,
            buybackBurnBps,
            buyTaxBps,
            sellTaxBps
        );
    }

    function _launchToken(
        address quoteToken_,
        uint256 graduationThreshold_,
        uint256 initialBuyQuote,
        string calldata name,
        string calldata symbol,
        string calldata metadataURI,
        string calldata image,
        string calldata description,
        MixpadToken.Socials calldata socials,
        bytes32 salt,
        uint256 deadline,
        uint128 minLiquidity,
        uint16 buybackBurnBps,
        uint16 buyTaxBps,
        uint16 sellTaxBps
    ) private returns (address token) {
        if (hook == address(0)) revert HookNotSet();
        if (uint256(buybackBurnBps) > BPS_DENOM) revert TaxAllocationTooHigh();

        token = _deployToken(name, symbol, metadataURI, image, description, socials, msg.sender, salt);

        bool tokenIsZero_ = token < quoteToken_;
        address rawC0 = tokenIsZero_ ? token : quoteToken_;
        address rawC1 = tokenIsZero_ ? quoteToken_ : token;

        PoolKey memory poolKey = PoolKey({
            currency0: Currency.wrap(rawC0),
            currency1: Currency.wrap(rawC1),
            fee: POOL_FEE,
            tickSpacing: TICK_SPACING,
            hooks: IHooks(hook)
        });
        bytes32 poolId = PoolId.unwrap(poolKey.toId());

        int24 poolStartTick = tokenIsZero_ ? initialTick : -initialTick;
        uint160 sqrtPriceX96 = TickMath.getSqrtRatioAtTick(poolStartTick);
        IPoolManager(poolManager).initialize(poolKey, sqrtPriceX96);

        (int24 tickLower, int24 tickUpper, uint128 liquidity) =
            _computeRangeAndLiquidity(tokenIsZero_, poolStartTick);
        if (liquidity < minLiquidity) revert SlippageTooHigh();

        uint256 lpTokenId = IPositionManager(positionManager).nextTokenId();

        launchedTokens[token] = LaunchedToken({
            deployer: msg.sender,
            positionId: lpTokenId,
            tickLower: tickLower,
            tickUpper: tickUpper,
            graduationThreshold: graduationThreshold_,
            exists: true,
            graduated: false,
            quoteToken: quoteToken_,
            tokenIsZero: tokenIsZero_
        });
        tokenCreator[token] = msg.sender;

        _mintAndBurnLiquidity(poolKey, tickLower, tickUpper, liquidity, tokenIsZero_, token, deadline);

        IMixpadHook(hook).registerToken(token, buybackBurnBps, buyTaxBps, sellTaxBps);

        emit TokenLaunched(token, msg.sender, poolId, lpTokenId, initialBuyQuote, buybackBurnBps);

        if (initialBuyQuote > 0) {
            _executeBuy(poolKey, initialBuyQuote, msg.sender);
        }

        _forwardLaunchFee();
    }

    function _computeRangeAndLiquidity(bool tokenIsZero_, int24 poolStartTick)
        private
        pure
        returns (int24 tickLower, int24 tickUpper, uint128 liquidity)
    {
        if (tokenIsZero_) {
            tickLower = poolStartTick;
            tickUpper = MAX_USABLE_TICK;
            uint160 sqrtA = TickMath.getSqrtRatioAtTick(tickLower);
            uint160 sqrtB = TickMath.getSqrtRatioAtTick(tickUpper);
            liquidity = LiquidityMath.getLiquidityForAmount0(sqrtA, sqrtB, SUPPLY);
        } else {
            tickLower = MIN_USABLE_TICK;
            tickUpper = poolStartTick;
            uint160 sqrtA = TickMath.getSqrtRatioAtTick(tickLower);
            uint160 sqrtB = TickMath.getSqrtRatioAtTick(tickUpper);
            liquidity = LiquidityMath.getLiquidityForAmount1(sqrtA, sqrtB, SUPPLY);
        }
    }

    function _mintAndBurnLiquidity(
        PoolKey memory poolKey,
        int24 tickLower,
        int24 tickUpper,
        uint128 liquidity,
        bool tokenIsZero_,
        address token,
        uint256 deadline
    ) private {
        IERC20(token).forceApprove(PERMIT2, SUPPLY);
        IPermit2(PERMIT2).approve(token, positionManager, uint160(SUPPLY), type(uint48).max);

        bytes memory actions = abi.encodePacked(ACT_MINT_POSITION, ACT_SETTLE_PAIR, ACT_SWEEP);
        bytes[] memory mintParams = new bytes[](3);
        mintParams[0] = abi.encode(
            poolKey,
            tickLower,
            tickUpper,
            uint256(liquidity),
            tokenIsZero_ ? uint128(SUPPLY) : uint128(0),
            tokenIsZero_ ? uint128(0) : uint128(SUPPLY),
            BURN_ADDRESS,
            bytes("")
        );
        mintParams[1] = abi.encode(poolKey.currency0, poolKey.currency1);
        mintParams[2] = abi.encode(poolKey.currency0, address(this));

        IPositionManager(positionManager).modifyLiquidities(abi.encode(actions, mintParams), deadline);

        IERC20(token).forceApprove(PERMIT2, 0);
        uint256 dust = IERC20(token).balanceOf(address(this));
        if (dust > 0) IERC20(token).safeTransfer(BURN_ADDRESS, dust);
    }

    struct BuyCallbackData {
        PoolKey poolKey;
        uint256 quoteIn;
        address recipient;
    }

    function _executeBuy(PoolKey memory poolKey, uint256 quoteIn, address recipient) internal {
        IPoolManager(poolManager).unlock(
            abi.encode(BuyCallbackData({poolKey: poolKey, quoteIn: quoteIn, recipient: recipient}))
        );
    }

    function unlockCallback(bytes calldata data) external override returns (bytes memory) {
        if (msg.sender != poolManager) revert NotPoolManager();

        BuyCallbackData memory d = abi.decode(data, (BuyCallbackData));

        BalanceDelta delta = IPoolManager(poolManager).swap(
            d.poolKey,
            SwapParams({
                zeroForOne: true,
                amountSpecified: -int256(d.quoteIn),
                sqrtPriceLimitX96: MIN_SQRT_PRICE_LIMIT
            }),
            ""
        );

        uint256 quoteOwed = uint256(uint128(-delta.amount0()));
        IPoolManager(poolManager).settle{value: quoteOwed}();

        uint256 tokensOut = uint256(uint128(delta.amount1()));
        if (tokensOut > 0) {
            IPoolManager(poolManager).take(d.poolKey.currency1, d.recipient, tokensOut);
        }

        uint256 refund = d.quoteIn - quoteOwed;
        if (refund > 0) {
            pendingRefunds[d.recipient] += refund;
            emit RefundPending(d.recipient, refund);
        }

        return "";
    }

    function claimRefund() external nonReentrant {
        uint256 amount = pendingRefunds[msg.sender];
        if (amount == 0) revert NothingToRefund();
        pendingRefunds[msg.sender] = 0;
        (bool ok,) = msg.sender.call{value: amount}("");
        if (!ok) revert FeeTransferFailed();
        emit RefundClaimed(msg.sender, amount);
    }

    function expectedLiquidity() external view returns (uint128) {
        int24 tickUpper = -initialTick;
        uint160 sqrtA = TickMath.getSqrtRatioAtTick(MIN_USABLE_TICK);
        uint160 sqrtB = TickMath.getSqrtRatioAtTick(tickUpper);
        return LiquidityMath.getLiquidityForAmount1(sqrtA, sqrtB, SUPPLY);
    }

    /// @notice Called by MixpadHook after every swap to keep quote-side
    /// volume in sync and flip the graduation flag when the threshold is
    /// first crossed. graduated is monotonic: later sells cannot reverse it.
    function recordSwap(address token, bool isBuy, uint256 quoteAmount) external {
        if (msg.sender != hook) revert NotHook();
        if (!launchedTokens[token].exists) return;

        int256 prev = netPoolQuote[token];
        int256 delta = isBuy ? int256(quoteAmount) : -int256(quoteAmount);
        int256 next = prev + delta;
        netPoolQuote[token] = next;

        uint256 threshold = launchedTokens[token].graduationThreshold;
        if (threshold > 0 && prev < int256(threshold) && next >= int256(threshold)) {
            launchedTokens[token].graduated = true;
            emit Graduated(token, uint256(next), threshold);
        }
    }

    function graduationStatus(address token)
        external
        view
        returns (uint256 pairedQuote, uint256 threshold, bool graduated)
    {
        LaunchedToken storage lt = launchedTokens[token];
        if (!lt.exists) revert TokenNotFound();
        threshold = lt.graduationThreshold;

        if (stateView != address(0)) {
            pairedQuote = _poolQuoteFromStateView(token, lt);
        } else {
            int256 net = netPoolQuote[token];
            pairedQuote = net > 0 ? uint256(net) : 0;
        }

        graduated = lt.graduated || (threshold > 0 && pairedQuote >= threshold);
    }

    function _poolQuoteFromStateView(address token, LaunchedToken storage lt) private view returns (uint256) {
        address rawC0 = lt.tokenIsZero ? token : lt.quoteToken;
        address rawC1 = lt.tokenIsZero ? lt.quoteToken : token;
        PoolKey memory poolKey = PoolKey({
            currency0: Currency.wrap(rawC0),
            currency1: Currency.wrap(rawC1),
            fee: POOL_FEE,
            tickSpacing: TICK_SPACING,
            hooks: IHooks(hook)
        });
        PoolId poolId = poolKey.toId();

        (uint160 sqrtPriceX96,,,) = IStateView(stateView).getSlot0(poolId);
        uint128 liq = IStateView(stateView).getLiquidity(poolId);
        if (sqrtPriceX96 == 0 || liq == 0) return 0;

        uint160 sqrtA = TickMath.getSqrtRatioAtTick(lt.tickLower);
        uint160 sqrtB = TickMath.getSqrtRatioAtTick(lt.tickUpper);

        if (lt.tokenIsZero) {
            (, uint256 amount1) = LiquidityMath.getAmountsForLiquidity(sqrtPriceX96, sqrtA, sqrtB, liq);
            return amount1;
        } else {
            (uint256 amount0,) = LiquidityMath.getAmountsForLiquidity(sqrtPriceX96, sqrtA, sqrtB, liq);
            return amount0;
        }
    }

    function _forwardLaunchFee() internal {
        if (launchFee == 0) return;
        (bool ok,) = treasury.call{value: launchFee}("");
        if (!ok) revert FeeTransferFailed();
    }

    function predictTokenAddress(
        string calldata name,
        string calldata symbol,
        string calldata metadataURI,
        string calldata image,
        string calldata description,
        MixpadToken.Socials calldata socials,
        address deployer_,
        bytes32 salt
    ) external view returns (address) {
        bytes32 initHash = _fetchCodeHash(
            _encodeHashCall(name, symbol, metadataURI, image, description, socials, deployer_)
        );
        bytes32 h = keccak256(abi.encodePacked(bytes1(0xff), address(this), salt, initHash));
        return address(uint160(uint256(h)));
    }

    // Separated from predictTokenAddress: keeps each function under the via_ir stack limit.
    function _fetchCodeHash(bytes memory callData) private view returns (bytes32 initHash) {
        (bool ok, bytes memory ret) = tokenDeployer.staticcall(callData);
        if (!ok) revert TokenDeployFailed();
        initHash = abi.decode(ret, (bytes32));
    }

    function _encodeHashCall(
        string calldata name,
        string calldata symbol,
        string calldata metadataURI,
        string calldata image,
        string calldata description,
        MixpadToken.Socials calldata socials,
        address deployer_
    ) private pure returns (bytes memory) {
        return abi.encodeCall(
            MixpadTokenDeployer.codeHash,
            (name, symbol, metadataURI, image, description, socials, deployer_)
        );
    }

    function _deployToken(
        string calldata name,
        string calldata symbol,
        string calldata metadataURI,
        string calldata image,
        string calldata description,
        MixpadToken.Socials calldata socials,
        address deployer_,
        bytes32 salt
    ) private returns (address t) {
        bytes memory code = _fetchCreationCode(
            _encodeCreationCodeCall(name, symbol, metadataURI, image, description, socials, deployer_)
        );
        assembly ("memory-safe") {
            t := create2(0, add(code, 0x20), mload(code), salt)
        }
        if (t == address(0)) revert TokenDeployFailed();
    }

    // Fetches initcode from tokenDeployer via staticcall; separated to keep _deployToken below the via_ir stack limit.
    function _fetchCreationCode(bytes memory callData) private view returns (bytes memory code) {
        (bool ok, bytes memory ret) = tokenDeployer.staticcall(callData);
        if (!ok) revert TokenDeployFailed();
        code = abi.decode(ret, (bytes));
    }

    function _encodeCreationCodeCall(
        string calldata name,
        string calldata symbol,
        string calldata metadataURI,
        string calldata image,
        string calldata description,
        MixpadToken.Socials calldata socials,
        address deployer_
    ) private pure returns (bytes memory) {
        return abi.encodeCall(
            MixpadTokenDeployer.creationCode,
            (name, symbol, metadataURI, image, description, socials, deployer_)
        );
    }

    function setLaunchEnabled(bool v) external onlyOwner {
        launchEnabled = v;
        emit LaunchEnabledUpdated(v);
    }

    function setLaunchFee(uint256 v) external onlyOwner {
        if (v > MAX_LAUNCH_FEE) revert LaunchFeeTooHigh();
        launchFee = v;
        emit LaunchFeeUpdated(v);
    }

    function setTreasury(address v) external onlyOwner {
        if (v == address(0)) revert ZeroAddress();
        treasury = v;
        emit TreasuryUpdated(v);
    }

    function setHook(address v) external onlyOwner {
        if (hook != address(0)) revert HookAlreadySet();
        if (v == address(0)) revert ZeroAddress();
        hook = v;
        emit HookUpdated(v);
    }

    function setStateView(address v) external onlyOwner {
        stateView = v;
        emit StateViewUpdated(v);
    }

    function setInitialTick(int24 v) external onlyOwner {
        if (v < MIN_INITIAL_TICK || v > MAX_INITIAL_TICK) revert InitialTickOutOfRange();
        if ((-v) % int24(TICK_SPACING) != 0) revert InitialTickOutOfRange();
        initialTick = v;
        emit InitialTickUpdated(v);
    }

    function setGraduationThreshold(uint256 v) external onlyOwner {
        if (v < MIN_GRADUATION_THRESHOLD) revert GraduationThresholdTooLow();
        if (v > MAX_GRADUATION_THRESHOLD) revert GraduationThresholdTooHigh();
        defaultGraduationThreshold = v;
        emit GraduationThresholdUpdated(v);
    }

    receive() external payable {}
}
