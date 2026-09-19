// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";

import "../StonkLockerOwnershipNFT.sol";
import "./interfaces/IStonkUpLocker.sol";
import "./interfaces/IUpSlipstream.sol";

/// @title StonkUpLockerCL
/// @notice Safety Deposit Box locker for up33 (up.) Slipstream concentrated
/// liquidity position NFTs, with opt-in gauge staking while locked.
///
/// Lock windows and fee modes mirror `StonkLiquidityLocker` exactly, so the
/// three lock styles the box already sells are expressed the same way:
///   - permanent      startUnlock = 2^64-2, finishUnlock = 2^64-1
///   - hard lock      startUnlock = now + d, finishUnlock = start + 600
///   - linear vesting startUnlock = now,     finishUnlock = start + d
///
/// STAKING. up33 gauges are custodial: `deposit` demands the caller be
/// `ownerOf` the NFT and `withdraw` returns it to the depositor only. This
/// locker therefore becomes the staker of record, which is precisely the
/// property that keeps a locked position locked — the gauge will hand the NFT
/// back to nobody but this contract, and this contract only releases it when
/// the lock window says so.
///
/// The economics are a genuine either/or imposed by up33, not by us: a STAKED
/// position earns UP emissions and zero swap fees (they are routed to the
/// pool's voters), while an UNSTAKED position earns swap fees less the pool's
/// `unstakedFee` levy. Callers choose per lock, at any time, as often as they
/// like.
contract StonkUpLockerCL is Ownable, IERC721Receiver, ReentrancyGuard, IStonkUpLocker {
    using SafeERC20 for IERC20;
    using SafeCast for uint256;

    uint256 private constant BPS = 10_000;
    uint256 private constant UPFRONT_BPS = 50; // 0.5%
    uint256 private constant WITHDRAW_BPS = 100; // 1%
    uint256 private constant COLLECT_BPS = 2_000; // 20%

    IUpNonfungiblePositionManager public immutable positionManager;
    IUpCLFactory public immutable clFactory;
    IUpVoter public immutable voter;
    StonkLockerOwnershipNFT public immutable lockNft;

    address public protocolFeeRecipient;
    mapping(address => bool) public feeExempt;

    struct CLLock {
        uint256 positionTokenId;
        uint256 lockTokenId;
        address token0;
        address token1;
        int24 tickSpacing;
        uint128 initialLiquidity;
        uint128 withdrawnLiquidity;
        uint64 startUnlock;
        uint64 finishUnlock;
        FeeMode feeMode;
        bool closed;
        /// @dev Non-zero exactly while the position is escrowed in a gauge.
        address gauge;
    }

    mapping(uint256 => CLLock) public lockPositions;
    mapping(uint256 => uint256) public positionToLockTokenId;

    /// @dev Set only for the duration of `gauge.withdraw()`, which returns the
    /// position via `safeTransferFrom` and would otherwise look like a brand
    /// new lock deposit to `onERC721Received`.
    uint256 private _gaugeReturn;

    error InvalidLockWindow();
    error InvalidMode();
    error NotLockOwner();
    error UnknownLock();
    error PositionAlreadyLocked();
    error BadPositionSender();
    error ProtocolRecipientZero();
    error ZeroLiquidity();
    error LiquidityExceedsUnlocked();
    error NotClosed();
    error UnknownPool();
    error NoGauge();
    error GaugeNotAlive();
    error PositionStaked();
    error PositionNotStaked();
    error GaugeReturnFailed();
    error GaugeDepositFailed();

    event ProtocolFeeRecipientUpdated(address indexed oldRecipient, address indexed newRecipient);
    event FeeExemptUpdated(address indexed wallet, bool exempt);
    event PositionLocked(
        uint256 indexed positionTokenId,
        uint256 indexed lockTokenId,
        address indexed owner,
        uint64 startUnlock,
        uint64 finishUnlock,
        FeeMode feeMode,
        uint128 initialLiquidity
    );
    event LockFeesCollected(
        uint256 indexed lockTokenId,
        uint256 userAmount0,
        uint256 userAmount1,
        uint256 protocolAmount0,
        uint256 protocolAmount1
    );
    event LockLiquidityDecreased(
        uint256 indexed lockTokenId,
        uint128 liquidity,
        uint256 userAmount0,
        uint256 userAmount1,
        uint256 protocolAmount0,
        uint256 protocolAmount1
    );
    event PositionReleased(uint256 indexed lockTokenId, uint256 indexed positionTokenId, address indexed owner);
    event PositionStakedInGauge(uint256 indexed lockTokenId, address indexed gauge, uint256 indexed positionTokenId);
    event PositionUnstakedFromGauge(
        uint256 indexed lockTokenId, address indexed gauge, uint256 indexed positionTokenId
    );
    /// @dev Emitted once per distinct token moved by a staking-path payout.
    /// Staking paths can move token0, token1 and the gauge reward token at
    /// once, and the reward token may alias one of the pair, so amounts are
    /// reported per token rather than as a fixed pair.
    event LockTokensPaid(
        uint256 indexed lockTokenId, address indexed token, uint256 userAmount, uint256 protocolAmount
    );

    constructor(
        address initialOwner,
        address _positionManager,
        address _voter,
        address _lockNft,
        address _protocolFeeRecipient
    ) Ownable(initialOwner) {
        require(_positionManager != address(0), "pm=0");
        require(_voter != address(0), "voter=0");
        require(_lockNft != address(0), "nft=0");
        if (_protocolFeeRecipient == address(0)) revert ProtocolRecipientZero();
        positionManager = IUpNonfungiblePositionManager(_positionManager);
        clFactory = IUpCLFactory(IUpNonfungiblePositionManager(_positionManager).factory());
        voter = IUpVoter(_voter);
        lockNft = StonkLockerOwnershipNFT(_lockNft);
        protocolFeeRecipient = _protocolFeeRecipient;
    }

    // ---------------------------------------------------------------- admin

    function setProtocolFeeRecipient(address newRecipient) external onlyOwner {
        if (newRecipient == address(0)) revert ProtocolRecipientZero();
        emit ProtocolFeeRecipientUpdated(protocolFeeRecipient, newRecipient);
        protocolFeeRecipient = newRecipient;
    }

    function setFeeExempt(address wallet, bool exempt) external onlyOwner {
        require(wallet != address(0), "wallet=0");
        feeExempt[wallet] = exempt;
        emit FeeExemptUpdated(wallet, exempt);
    }

    // ----------------------------------------------------------------- lock

    /// @notice Optional convenience path for UIs that would rather approve than
    /// encode `safeTransferFrom` data. Registration runs inside the receive
    /// hook so a failed window/pool check rolls the NFT transfer back with it
    /// (same atomic pattern as `StonkLiquidityLocker`).
    function lockByTransfer(uint256 positionTokenId, uint64 startUnlock, uint64 finishUnlock, FeeMode feeMode)
        external
        returns (uint256 lockTokenId)
    {
        positionManager.safeTransferFrom(
            msg.sender, address(this), positionTokenId, abi.encode(startUnlock, finishUnlock, feeMode)
        );
        lockTokenId = positionToLockTokenId[positionTokenId];
        if (lockTokenId == 0) revert UnknownLock();
    }

    function onERC721Received(address, address from, uint256 tokenId, bytes calldata data)
        external
        override
        returns (bytes4)
    {
        if (msg.sender != address(positionManager)) revert BadPositionSender();

        // A gauge handing back a position we staked. Accept it without touching
        // lock state; `unstake` owns the bookkeeping for this leg.
        if (_gaugeReturn == tokenId) {
            if (from != lockPositions[positionToLockTokenId[tokenId]].gauge) revert BadPositionSender();
            return IERC721Receiver.onERC721Received.selector;
        }

        // Anything else must carry lock parameters, or the NFT would be
        // stranded in a contract with no lock to release it.
        if (data.length == 0) revert InvalidLockWindow();
        (uint64 startUnlock, uint64 finishUnlock, FeeMode feeMode) = abi.decode(data, (uint64, uint64, FeeMode));
        _registerLock(from, tokenId, startUnlock, finishUnlock, feeMode);

        return IERC721Receiver.onERC721Received.selector;
    }

    function _registerLock(address owner_, uint256 tokenId, uint64 startUnlock, uint64 finishUnlock, FeeMode feeMode)
        internal
        nonReentrant
        returns (uint256 lockTokenId)
    {
        if (positionToLockTokenId[tokenId] != 0) revert PositionAlreadyLocked();
        if (finishUnlock <= startUnlock || startUnlock < block.timestamp) revert InvalidLockWindow();
        if (uint8(feeMode) > uint8(FeeMode.CollectTwentyPercent)) revert InvalidMode();
        if (positionManager.ownerOf(tokenId) != address(this)) revert BadPositionSender();

        (,, address token0, address token1, int24 tickSpacing,,, uint128 liquidity,,,,) =
            positionManager.positions(tokenId);
        if (liquidity == 0) revert ZeroLiquidity();

        // Resolve through the factory: Slipstream pools are EIP-1167 clones, so
        // the Uniswap V3 init-code-hash derivation would compute garbage.
        address pool = clFactory.getPool(token0, token1, tickSpacing);
        if (pool == address(0) || !clFactory.isPool(pool)) revert UnknownPool();

        lockTokenId = lockNft.mint(owner_);
        positionToLockTokenId[tokenId] = lockTokenId;
        lockPositions[lockTokenId] = CLLock({
            positionTokenId: tokenId,
            lockTokenId: lockTokenId,
            token0: token0,
            token1: token1,
            tickSpacing: tickSpacing,
            initialLiquidity: liquidity,
            withdrawnLiquidity: 0,
            startUnlock: startUnlock,
            finishUnlock: finishUnlock,
            feeMode: feeMode,
            closed: false,
            gauge: address(0)
        });

        if (feeMode == FeeMode.UpfrontHalfPercent && !feeExempt[owner_]) {
            _chargeUpfront(lockTokenId, liquidity);
        }

        // Emit the post-fee principal so the event matches stored state (and V2).
        emit PositionLocked(
            tokenId, lockTokenId, owner_, startUnlock, finishUnlock, feeMode, lockPositions[lockTokenId].initialLiquidity
        );
    }

    // ------------------------------------------------------------- yield

    /// @notice Collect accrued swap fees. Only meaningful while unstaked — a
    /// staked position's swap fees belong to the pool's voters, and the NFPM
    /// would reject us anyway since the gauge is the owner.
    function collectFees(uint256 lockTokenId, uint128 amount0Max, uint128 amount1Max)
        external
        nonReentrant
        returns (uint256 userAmount0, uint256 userAmount1, uint256 protocolAmount0, uint256 protocolAmount1)
    {
        CLLock storage p = _ownedLock(lockTokenId);
        if (p.gauge != address(0)) revert PositionStaked();

        // Pay the realized balance delta, never the NFPM return values — a
        // fee-on-transfer / deflationary pair token would otherwise make the
        // subsequent transfers revert and brick the lock (see audit H-1).
        uint256 before0 = IERC20(p.token0).balanceOf(address(this));
        uint256 before1 = IERC20(p.token1).balanceOf(address(this));
        positionManager.collect(
            IUpNonfungiblePositionManager.CollectParams({
                tokenId: p.positionTokenId,
                recipient: address(this),
                amount0Max: amount0Max == 0 ? type(uint128).max : amount0Max,
                amount1Max: amount1Max == 0 ? type(uint128).max : amount1Max
            })
        );
        uint256 gross0 = IERC20(p.token0).balanceOf(address(this)) - before0;
        uint256 gross1 = IERC20(p.token1).balanceOf(address(this)) - before1;

        (userAmount0, userAmount1, protocolAmount0, protocolAmount1) =
            _payPair(p.token0, p.token1, gross0, gross1, _yieldCutBps(p.feeMode, msg.sender));

        emit LockFeesCollected(lockTokenId, userAmount0, userAmount1, protocolAmount0, protocolAmount1);
    }

    // ------------------------------------------------------------- staking

    /// @notice Stake the locked position into its pool's up33 gauge to earn UP
    /// emissions. Any swap fees the position had accrued are swept out by the
    /// gauge on deposit and paid to the caller here.
    function stake(uint256 lockTokenId) external nonReentrant returns (address gauge) {
        CLLock storage p = _ownedLock(lockTokenId);
        if (p.gauge != address(0)) revert PositionStaked();

        address pool = clFactory.getPool(p.token0, p.token1, p.tickSpacing);
        if (pool == address(0)) revert UnknownPool();
        gauge = voter.gauges(pool);
        if (gauge == address(0) || !voter.isGauge(gauge)) revert NoGauge();
        if (!voter.isAlive(gauge)) revert GaugeNotAlive();

        address[] memory toks = _yieldTokens(p.token0, p.token1, IUpCLGauge(gauge).rewardToken());
        uint256[] memory before = _balances(toks);

        // The gauge calls `nft.collect` and `nft.safeTransferFrom` on our behalf.
        positionManager.approve(gauge, p.positionTokenId);
        IUpCLGauge(gauge).deposit(p.positionTokenId);
        if (positionManager.ownerOf(p.positionTokenId) != gauge) revert GaugeDepositFailed();
        // OZ `_transfer` clears the approval; belt-and-braces in case a future
        // gauge generation takes custody another way.
        if (positionManager.getApproved(p.positionTokenId) != address(0)) {
            positionManager.approve(address(0), p.positionTokenId);
        }
        p.gauge = gauge;

        _payoutDeltas(lockTokenId, p.feeMode, toks, before);
        emit PositionStakedInGauge(lockTokenId, gauge, p.positionTokenId);
    }

    /// @notice Pull the position back out of its gauge. Sweeps both the accrued
    /// UP emissions and any swap fees the gauge settles on withdrawal.
    function unstake(uint256 lockTokenId) external nonReentrant {
        CLLock storage p = _ownedLock(lockTokenId);
        address gauge = p.gauge;
        if (gauge == address(0)) revert PositionNotStaked();

        address[] memory toks = _yieldTokens(p.token0, p.token1, IUpCLGauge(gauge).rewardToken());
        uint256[] memory before = _balances(toks);

        _gaugeReturn = p.positionTokenId;
        IUpCLGauge(gauge).withdraw(p.positionTokenId);
        _gaugeReturn = 0;
        if (positionManager.ownerOf(p.positionTokenId) != address(this)) revert GaugeReturnFailed();
        p.gauge = address(0);

        _payoutDeltas(lockTokenId, p.feeMode, toks, before);
        emit PositionUnstakedFromGauge(lockTokenId, gauge, p.positionTokenId);
    }

    /// @notice Claim UP emissions without unstaking.
    function claimEmissions(uint256 lockTokenId) external nonReentrant {
        CLLock storage p = _ownedLock(lockTokenId);
        address gauge = p.gauge;
        if (gauge == address(0)) revert PositionNotStaked();

        address[] memory toks = _yieldTokens(p.token0, p.token1, IUpCLGauge(gauge).rewardToken());
        uint256[] memory before = _balances(toks);

        IUpCLGauge(gauge).getReward(p.positionTokenId);

        _payoutDeltas(lockTokenId, p.feeMode, toks, before);
    }

    // ------------------------------------------------------------ withdraw

    function decreaseLockedLiquidity(uint256 lockTokenId, uint128 liquidity, uint256 amount0Min, uint256 amount1Min)
        external
        nonReentrant
        returns (uint256 userAmount0, uint256 userAmount1, uint256 protocolAmount0, uint256 protocolAmount1)
    {
        if (liquidity == 0) revert ZeroLiquidity();
        CLLock storage p = _ownedLock(lockTokenId);
        if (p.gauge != address(0)) revert PositionStaked();

        uint128 maxLiquidity = withdrawableLiquidity(lockTokenId);
        if (liquidity > maxLiquidity) revert LiquidityExceedsUnlocked();

        uint256 before0 = IERC20(p.token0).balanceOf(address(this));
        uint256 before1 = IERC20(p.token1).balanceOf(address(this));

        (uint256 reported0, uint256 reported1) = positionManager.decreaseLiquidity(
            IUpNonfungiblePositionManager.DecreaseLiquidityParams({
                tokenId: p.positionTokenId,
                liquidity: liquidity,
                amount0Min: amount0Min,
                amount1Min: amount1Min,
                deadline: block.timestamp + 30 minutes
            })
        );

        // Record the burn before collect so a dust tail that yields (0, 0)
        // amounts can still advance `withdrawnLiquidity` toward `canRelease`.
        // The NFPM reverts a collect with both maxes at zero, so skip it then.
        p.withdrawnLiquidity += liquidity;
        if (reported0 > 0 || reported1 > 0) {
            // Collect exactly the principal just released. Sweeping uint128.max
            // here would drag accrued swap fees into this contract outside the
            // fee-mode logic.
            positionManager.collect(
                IUpNonfungiblePositionManager.CollectParams({
                    tokenId: p.positionTokenId,
                    recipient: address(this),
                    amount0Max: reported0.toUint128(),
                    amount1Max: reported1.toUint128()
                })
            );
        }

        uint256 gross0 = IERC20(p.token0).balanceOf(address(this)) - before0;
        uint256 gross1 = IERC20(p.token1).balanceOf(address(this)) - before1;
        uint256 cutBps =
            (p.feeMode == FeeMode.WithdrawOnePercent && !feeExempt[msg.sender]) ? WITHDRAW_BPS : 0;
        (userAmount0, userAmount1, protocolAmount0, protocolAmount1) =
            _payPair(p.token0, p.token1, gross0, gross1, cutBps);

        emit LockLiquidityDecreased(lockTokenId, liquidity, userAmount0, userAmount1, protocolAmount0, protocolAmount1);
    }

    function releasePosition(uint256 lockTokenId) external nonReentrant {
        CLLock storage p = _ownedLock(lockTokenId);
        if (p.gauge != address(0)) revert PositionStaked();
        if (!canRelease(lockTokenId)) revert NotClosed();

        uint256 positionTokenId = p.positionTokenId;
        delete positionToLockTokenId[positionTokenId];
        p.closed = true;
        lockNft.burn(lockTokenId);
        positionManager.safeTransferFrom(address(this), msg.sender, positionTokenId);
        emit PositionReleased(lockTokenId, positionTokenId, msg.sender);
    }

    // -------------------------------------------------------------- views

    function withdrawableLiquidity(uint256 lockTokenId) public view returns (uint128) {
        CLLock memory p = lockPositions[lockTokenId];
        // The record is kept after release for history; it must not keep
        // reporting a live vesting schedule once the position has gone home.
        if (p.positionTokenId == 0 || p.closed) return 0;
        uint128 unlocked = _unlockedLiquidity(p);
        if (unlocked <= p.withdrawnLiquidity) return 0;
        return unlocked - p.withdrawnLiquidity;
    }

    function canRelease(uint256 lockTokenId) public view returns (bool) {
        CLLock memory p = lockPositions[lockTokenId];
        if (p.positionTokenId == 0 || p.closed) return false;
        return block.timestamp >= p.finishUnlock && p.withdrawnLiquidity >= p.initialLiquidity;
    }

    function isStaked(uint256 lockTokenId) external view returns (bool) {
        return lockPositions[lockTokenId].gauge != address(0);
    }

    /// @notice Gauge for a lock's pool, or zero when the pool has none.
    function gaugeFor(uint256 lockTokenId) external view returns (address) {
        CLLock memory p = lockPositions[lockTokenId];
        if (p.positionTokenId == 0) return address(0);
        address pool = clFactory.getPool(p.token0, p.token1, p.tickSpacing);
        if (pool == address(0)) return address(0);
        return voter.gauges(pool);
    }

    /// @notice Emissions accrued to a staked lock, gross of the protocol cut.
    function pendingEmissions(uint256 lockTokenId) external view returns (uint256) {
        CLLock memory p = lockPositions[lockTokenId];
        if (p.gauge == address(0)) return 0;
        return IUpCLGauge(p.gauge).earned(address(this), p.positionTokenId);
    }

    // ----------------------------------------------------------- internals

    function _ownedLock(uint256 lockTokenId) internal view returns (CLLock storage p) {
        p = lockPositions[lockTokenId];
        if (p.positionTokenId == 0 || p.closed) revert UnknownLock();
        if (lockNft.ownerOf(lockTokenId) != msg.sender) revert NotLockOwner();
    }

    /// @dev Cut applied to yield (swap fees and gauge emissions alike). Because
    /// the rate is identical for both, a reward token that aliases token0/token1
    /// can be paid out from a single combined balance delta with no error.
    function _yieldCutBps(FeeMode feeMode, address actor) internal view returns (uint256) {
        if (feeExempt[actor]) return 0;
        return feeMode == FeeMode.CollectTwentyPercent ? COLLECT_BPS : 0;
    }

    /// @dev token0/token1/rewardToken, deduplicated and zero-filtered.
    function _yieldTokens(address token0, address token1, address reward)
        internal
        pure
        returns (address[] memory toks)
    {
        bool addReward = reward != address(0) && reward != token0 && reward != token1;
        toks = new address[](addReward ? 3 : 2);
        toks[0] = token0;
        toks[1] = token1;
        if (addReward) toks[2] = reward;
    }

    function _balances(address[] memory toks) internal view returns (uint256[] memory out) {
        out = new uint256[](toks.length);
        for (uint256 i = 0; i < toks.length; i++) {
            out[i] = IERC20(toks[i]).balanceOf(address(this));
        }
    }

    /// @dev Pays every positive balance delta to the lock owner net of the
    /// mode's yield cut. Deltas are used rather than call return values because
    /// the gauge performs collects and reward transfers internally.
    function _payoutDeltas(uint256 lockTokenId, FeeMode feeMode, address[] memory toks, uint256[] memory before)
        internal
    {
        uint256 bps = _yieldCutBps(feeMode, msg.sender);
        address recipient = protocolFeeRecipient;
        for (uint256 i = 0; i < toks.length; i++) {
            uint256 gross = IERC20(toks[i]).balanceOf(address(this)) - before[i];
            if (gross == 0) continue;
            uint256 protocolAmount = bps == 0 ? 0 : (gross * bps) / BPS;
            uint256 userAmount = gross - protocolAmount;
            if (protocolAmount > 0) IERC20(toks[i]).safeTransfer(recipient, protocolAmount);
            if (userAmount > 0) IERC20(toks[i]).safeTransfer(msg.sender, userAmount);
            emit LockTokensPaid(lockTokenId, toks[i], userAmount, protocolAmount);
        }
    }

    function _unlockedLiquidity(CLLock memory p) internal view returns (uint128) {
        if (block.timestamp <= p.startUnlock) return 0;
        if (block.timestamp >= p.finishUnlock) return p.initialLiquidity;

        uint256 duration = uint256(p.finishUnlock) - uint256(p.startUnlock);
        uint256 elapsed = block.timestamp - uint256(p.startUnlock);
        return uint128((uint256(p.initialLiquidity) * elapsed) / duration);
    }

    function _chargeUpfront(uint256 lockTokenId, uint128 liquidity) internal {
        CLLock storage p = lockPositions[lockTokenId];

        uint128 feeLiquidity = uint128((uint256(liquidity) * UPFRONT_BPS) / BPS);
        if (feeLiquidity == 0) return;

        uint256 before0 = IERC20(p.token0).balanceOf(address(this));
        uint256 before1 = IERC20(p.token1).balanceOf(address(this));

        (uint256 reported0, uint256 reported1) = positionManager.decreaseLiquidity(
            IUpNonfungiblePositionManager.DecreaseLiquidityParams({
                tokenId: p.positionTokenId,
                liquidity: feeLiquidity,
                amount0Min: 0,
                amount1Min: 0,
                deadline: block.timestamp + 30 minutes
            })
        );

        // Always reduce principal by the liquidity burned. A zero-amount burn
        // (tiny position, both legs round to 0) is "no fee tokens", not failure.
        p.initialLiquidity -= feeLiquidity;
        if (reported0 > 0 || reported1 > 0) {
            positionManager.collect(
                IUpNonfungiblePositionManager.CollectParams({
                    tokenId: p.positionTokenId,
                    recipient: address(this),
                    amount0Max: reported0.toUint128(),
                    amount1Max: reported1.toUint128()
                })
            );
        }

        uint256 got0 = IERC20(p.token0).balanceOf(address(this)) - before0;
        uint256 got1 = IERC20(p.token1).balanceOf(address(this)) - before1;
        if (got0 > 0) IERC20(p.token0).safeTransfer(protocolFeeRecipient, got0);
        if (got1 > 0) IERC20(p.token1).safeTransfer(protocolFeeRecipient, got1);
    }

    /// @dev Split a realized (token0, token1) balance delta between the caller
    /// and the protocol fee recipient. Amounts are what the locker actually
    /// holds, so fee-on-transfer tokens cannot brick the payout.
    function _payPair(address token0, address token1, uint256 gross0, uint256 gross1, uint256 bps)
        internal
        returns (uint256 user0, uint256 user1, uint256 protocol0, uint256 protocol1)
    {
        protocol0 = bps == 0 ? 0 : (gross0 * bps) / BPS;
        protocol1 = bps == 0 ? 0 : (gross1 * bps) / BPS;
        user0 = gross0 - protocol0;
        user1 = gross1 - protocol1;
        if (protocol0 > 0) IERC20(token0).safeTransfer(protocolFeeRecipient, protocol0);
        if (protocol1 > 0) IERC20(token1).safeTransfer(protocolFeeRecipient, protocol1);
        if (user0 > 0) IERC20(token0).safeTransfer(msg.sender, user0);
        if (user1 > 0) IERC20(token1).safeTransfer(msg.sender, user1);
    }
}
