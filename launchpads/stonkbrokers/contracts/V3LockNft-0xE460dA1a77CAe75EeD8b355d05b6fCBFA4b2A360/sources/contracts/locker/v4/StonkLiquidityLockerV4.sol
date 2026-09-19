// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "../StonkLockerOwnershipNFT.sol";
import "./IV4PoolManager.sol";
import "./IStonkLiquidityLockerV4Adapter.sol";

/// @title StonkLiquidityLockerV4
/// @notice Time-locks Uniswap **v4** liquidity. Because Robinhood Chain exposes
/// the canonical v4 singleton `PoolManager` but no periphery `PositionManager`
/// (there are no v4 position NFTs to escrow), this locker *mints and custodies*
/// the v4 position directly against the PoolManager, keyed by
/// `salt = bytes32(lockTokenId)`. The depositor receives a transferable
/// `StonkLockerOwnershipNFT` (SLP) receipt that authorizes fee-collect, unlocked
/// decreases, and final release.
///
/// Fee modes mirror the v3 locker:
///  - `UpfrontHalfPercent`  : 0.5% of principal taken to protocol at lock time.
///  - `WithdrawOnePercent`  : 1% of each decreased principal taken on withdraw.
///  - `CollectTwentyPercent`: 20% of collected swap fees taken to protocol.
///
/// v4's `modifyLiquidity` returns `feesAccrued` separately from `callerDelta`,
/// so principal and swap fees are split *exactly* on-chain — the class of
/// orphaned-fee bugs (v3 H1/H2) is structurally impossible here.
contract StonkLiquidityLockerV4 is
    Ownable,
    ReentrancyGuard,
    IV4UnlockCallback,
    IStonkLiquidityLockerV4Adapter
{
    using SafeERC20 for IERC20;

    enum FeeMode {
        UpfrontHalfPercent,
        WithdrawOnePercent,
        CollectTwentyPercent
    }

    struct V4Lock {
        address currency0;
        address currency1;
        uint24 fee;
        int24 tickSpacing;
        address hooks;
        int24 tickLower;
        int24 tickUpper;
        uint128 initialLiquidity;
        uint128 withdrawnLiquidity;
        uint64 startUnlock;
        uint64 finishUnlock;
        FeeMode feeMode;
        bool closed;
    }

    uint256 private constant BPS = 10_000;
    uint256 private constant UPFRONT_BPS = 50; // 0.5%
    uint256 private constant WITHDRAW_BPS = 100; // 1%
    uint256 private constant COLLECT_BPS = 2_000; // 20%
    address private constant NATIVE = address(0);

    // Callback actions.
    uint8 private constant ACT_MINT = 1;
    uint8 private constant ACT_COLLECT = 2;
    uint8 private constant ACT_DECREASE = 3;

    IV4PoolManager public immutable poolManager;
    StonkLockerOwnershipNFT public immutable lockNft;
    address public protocolFeeRecipient;
    /// @notice Owner-managed set of wallets/contracts that bypass ALL protocol
    /// fees (upfront, withdraw, collect) — the protocol treasury plus, later,
    /// protocol contracts such as the launchpad that lock LP on users' behalf.
    /// Exemption is evaluated at charge time against the acting wallet, so a
    /// receipt sold on never carries the exemption with it.
    mapping(address => bool) public feeExempt;

    /// @dev Native protocol fees that could not be pushed (recipient rejected
    /// ETH). Held here so a bad recipient can never block user withdrawals;
    /// claimable any time via {claimPendingProtocolEth}.
    uint256 public pendingProtocolEth;

    mapping(uint256 => V4Lock) public lockPositions;

    /// @dev Reentrancy-independent guard proving the current unlock was opened by
    /// one of this contract's own entry points (never a third party).
    bool private _unlockActive;

    error InvalidLockWindow();
    error InvalidMode();
    error NotLockOwner();
    error UnknownLock();
    error ZeroLiquidity();
    error LiquidityExceedsUnlocked();
    error NotClosed();
    error ProtocolRecipientZero();
    error NotPoolManager();
    error UnlockNotActive();
    error EthValueMismatch();
    error PoolManagerZero();
    error CurrencyOrder();
    error RefundFailed();

    event ProtocolFeeRecipientUpdated(address indexed oldRecipient, address indexed newRecipient);
    event FeeExemptUpdated(address indexed wallet, bool exempt);
    event PositionLocked(
        uint256 indexed lockTokenId,
        address indexed owner,
        address currency0,
        address currency1,
        int24 tickLower,
        int24 tickUpper,
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
    event PositionReleased(uint256 indexed lockTokenId, address indexed owner);
    event ProtocolEthPending(uint256 amount);

    constructor(address initialOwner, address _poolManager, address _lockNft, address _protocolFeeRecipient)
        Ownable(initialOwner)
    {
        if (_poolManager == address(0)) revert PoolManagerZero();
        if (_protocolFeeRecipient == address(0)) revert ProtocolRecipientZero();
        require(_lockNft != address(0), "nft=0");
        poolManager = IV4PoolManager(_poolManager);
        lockNft = StonkLockerOwnershipNFT(_lockNft);
        protocolFeeRecipient = _protocolFeeRecipient;
    }

    // ───────────────────────────── adapter gate ─────────────────────────────

    function isV4Ready() external pure returns (bool) {
        return true;
    }

    function setProtocolFeeRecipient(address newRecipient) external onlyOwner {
        if (newRecipient == address(0)) revert ProtocolRecipientZero();
        emit ProtocolFeeRecipientUpdated(protocolFeeRecipient, newRecipient);
        protocolFeeRecipient = newRecipient;
    }

    /// @notice Add or remove a fee-exempt wallet/contract.
    function setFeeExempt(address wallet, bool exempt) external onlyOwner {
        require(wallet != address(0), "wallet=0");
        feeExempt[wallet] = exempt;
        emit FeeExemptUpdated(wallet, exempt);
    }

    function _isFeeExempt(address wallet) internal view returns (bool) {
        return feeExempt[wallet];
    }

    // ───────────────────────────── lock ─────────────────────────────

    struct LockParams {
        address currency0; // address(0) = native ETH; MUST be < currency1
        address currency1;
        uint24 fee;
        int24 tickSpacing;
        address hooks;
        int24 tickLower;
        int24 tickUpper;
        uint128 liquidity;
        uint256 amount0Max;
        uint256 amount1Max;
        uint64 startUnlock;
        uint64 finishUnlock;
        FeeMode feeMode;
    }

    /// @notice Mint a v4 position from the caller's funds and lock it. The caller
    /// must (a) pre-approve this contract for any ERC-20 currency up to its max,
    /// and (b) attach exactly the native-ETH max as `msg.value` when a currency
    /// is native. Unused funds are refunded.
    function lock(LockParams calldata p) external payable nonReentrant returns (uint256 lockTokenId) {
        if (p.liquidity == 0) revert ZeroLiquidity();
        if (p.finishUnlock <= p.startUnlock || p.startUnlock < block.timestamp) revert InvalidLockWindow();
        if (uint8(p.feeMode) > uint8(FeeMode.CollectTwentyPercent)) revert InvalidMode();
        if (uint160(p.currency0) >= uint160(p.currency1)) revert CurrencyOrder();

        // Native ETH must be currency0 (address(0) sorts first). Require the
        // attached value to exactly equal the native max so we never trap ETH.
        uint256 nativeMax;
        if (p.currency0 == NATIVE) nativeMax = p.amount0Max;
        if (msg.value != nativeMax) revert EthValueMismatch();

        lockTokenId = lockNft.mint(msg.sender);
        lockPositions[lockTokenId] = V4Lock({
            currency0: p.currency0,
            currency1: p.currency1,
            fee: p.fee,
            tickSpacing: p.tickSpacing,
            hooks: p.hooks,
            tickLower: p.tickLower,
            tickUpper: p.tickUpper,
            initialLiquidity: p.liquidity,
            withdrawnLiquidity: 0,
            startUnlock: p.startUnlock,
            finishUnlock: p.finishUnlock,
            feeMode: p.feeMode,
            closed: false
        });

        // Pull ERC-20 sides into the locker up to their maxima (paid to the pool
        // during settle; leftovers refunded below).
        if (p.currency0 != NATIVE && p.amount0Max > 0) {
            IERC20(p.currency0).safeTransferFrom(msg.sender, address(this), p.amount0Max);
        }
        if (p.amount1Max > 0) {
            IERC20(p.currency1).safeTransferFrom(msg.sender, address(this), p.amount1Max);
        }

        _unlockActive = true;
        bytes memory res = poolManager.unlock(abi.encode(ACT_MINT, lockTokenId, p.liquidity));
        _unlockActive = false;
        (uint256 paid0, uint256 paid1,,) = abi.decode(res, (uint256, uint256, uint256, uint256));

        // Upfront fee: pull 0.5% of principal liquidity and forward to protocol.
        if (p.feeMode == FeeMode.UpfrontHalfPercent && !_isFeeExempt(msg.sender)) {
            uint128 feeLiquidity = uint128((uint256(p.liquidity) * UPFRONT_BPS) / BPS);
            if (feeLiquidity > 0) {
                lockPositions[lockTokenId].initialLiquidity = p.liquidity - feeLiquidity;
                _unlockActive = true;
                bytes memory fres =
                    poolManager.unlock(abi.encode(ACT_DECREASE, lockTokenId, uint256(feeLiquidity)));
                _unlockActive = false;
                (uint256 up0, uint256 up1, uint256 uf0, uint256 uf1) =
                    abi.decode(fres, (uint256, uint256, uint256, uint256));
                // Whole swept amount (fresh position: fees ~0) goes to protocol.
                _payoutProtocol(p.currency0, up0 + uf0);
                _payoutProtocol(p.currency1, up1 + uf1);
            }
        }

        _refund(p.currency0, msg.sender, p.amount0Max - paid0, p.currency0 == NATIVE);
        _refund(p.currency1, msg.sender, p.amount1Max - paid1, false);

        V4Lock storage l = lockPositions[lockTokenId];
        emit PositionLocked(
            lockTokenId,
            msg.sender,
            l.currency0,
            l.currency1,
            l.tickLower,
            l.tickUpper,
            l.startUnlock,
            l.finishUnlock,
            l.feeMode,
            l.initialLiquidity
        );
    }

    // ───────────────────────────── collect fees ─────────────────────────────

    function collectFees(uint256 lockTokenId)
        external
        nonReentrant
        returns (uint256 userAmount0, uint256 userAmount1, uint256 protocolAmount0, uint256 protocolAmount1)
    {
        V4Lock storage l = lockPositions[lockTokenId];
        if (l.initialLiquidity == 0 && l.withdrawnLiquidity == 0) revert UnknownLock();
        if (lockNft.ownerOf(lockTokenId) != msg.sender) revert NotLockOwner();

        // Fully drained: the final decrease already swept all outstanding fees
        // (v4 pays fees out with every modifyLiquidity). A 0-delta modify on an
        // empty position reverts CannotUpdateEmptyPosition, so no-op instead.
        if (l.withdrawnLiquidity >= l.initialLiquidity) {
            emit LockFeesCollected(lockTokenId, 0, 0, 0, 0);
            return (0, 0, 0, 0);
        }

        _unlockActive = true;
        bytes memory res = poolManager.unlock(abi.encode(ACT_COLLECT, lockTokenId, uint256(0)));
        _unlockActive = false;
        (,, uint256 fee0, uint256 fee1) = abi.decode(res, (uint256, uint256, uint256, uint256));

        if (l.feeMode == FeeMode.CollectTwentyPercent && !_isFeeExempt(msg.sender)) {
            protocolAmount0 = (fee0 * COLLECT_BPS) / BPS;
            protocolAmount1 = (fee1 * COLLECT_BPS) / BPS;
        }
        userAmount0 = fee0 - protocolAmount0;
        userAmount1 = fee1 - protocolAmount1;

        _payoutProtocol(l.currency0, protocolAmount0);
        _payoutProtocol(l.currency1, protocolAmount1);
        _payout(l.currency0, msg.sender, userAmount0);
        _payout(l.currency1, msg.sender, userAmount1);

        emit LockFeesCollected(lockTokenId, userAmount0, userAmount1, protocolAmount0, protocolAmount1);
    }

    // ───────────────────────────── decrease (post-unlock) ─────────────────────────────

    function decreaseLockedLiquidity(uint256 lockTokenId, uint128 liquidity)
        external
        nonReentrant
        returns (uint256 userAmount0, uint256 userAmount1, uint256 protocolAmount0, uint256 protocolAmount1)
    {
        if (liquidity == 0) revert ZeroLiquidity();
        V4Lock storage l = lockPositions[lockTokenId];
        if (l.initialLiquidity == 0 && l.withdrawnLiquidity == 0) revert UnknownLock();
        if (lockNft.ownerOf(lockTokenId) != msg.sender) revert NotLockOwner();

        uint128 maxLiquidity = withdrawableLiquidity(lockTokenId);
        if (liquidity > maxLiquidity) revert LiquidityExceedsUnlocked();

        l.withdrawnLiquidity += liquidity;

        _unlockActive = true;
        bytes memory res = poolManager.unlock(abi.encode(ACT_DECREASE, lockTokenId, uint256(liquidity)));
        _unlockActive = false;
        (uint256 principal0, uint256 principal1, uint256 fee0, uint256 fee1) =
            abi.decode(res, (uint256, uint256, uint256, uint256));

        bool exempt = _isFeeExempt(msg.sender);
        // Principal: 1% cut only in WithdrawOnePercent mode.
        if (l.feeMode == FeeMode.WithdrawOnePercent && !exempt) {
            protocolAmount0 = (principal0 * WITHDRAW_BPS) / BPS;
            protocolAmount1 = (principal1 * WITHDRAW_BPS) / BPS;
        }
        // Swap fees dragged out by the decrease follow the collect rule (20% only
        // in CollectTwentyPercent mode) — never orphaned.
        uint256 feeProto0;
        uint256 feeProto1;
        if (l.feeMode == FeeMode.CollectTwentyPercent && !exempt) {
            feeProto0 = (fee0 * COLLECT_BPS) / BPS;
            feeProto1 = (fee1 * COLLECT_BPS) / BPS;
        }
        protocolAmount0 += feeProto0;
        protocolAmount1 += feeProto1;

        userAmount0 = (principal0 + fee0) - protocolAmount0;
        userAmount1 = (principal1 + fee1) - protocolAmount1;

        _payoutProtocol(l.currency0, protocolAmount0);
        _payoutProtocol(l.currency1, protocolAmount1);
        _payout(l.currency0, msg.sender, userAmount0);
        _payout(l.currency1, msg.sender, userAmount1);

        emit LockLiquidityDecreased(lockTokenId, liquidity, userAmount0, userAmount1, protocolAmount0, protocolAmount1);
    }

    // ───────────────────────────── release ─────────────────────────────

    /// @notice Close a fully-unlocked, fully-drained lock and burn the receipt.
    /// In v4 there is no position NFT to return; the underlying tokens were paid
    /// out through `decreaseLockedLiquidity`. Requires the same drainage +
    /// timelock condition as the v3 locker.
    function releasePosition(uint256 lockTokenId) external nonReentrant {
        V4Lock storage l = lockPositions[lockTokenId];
        if (l.initialLiquidity == 0 && l.withdrawnLiquidity == 0) revert UnknownLock();
        if (lockNft.ownerOf(lockTokenId) != msg.sender) revert NotLockOwner();
        if (!canRelease(lockTokenId)) revert NotClosed();

        l.closed = true;
        lockNft.burn(lockTokenId);
        emit PositionReleased(lockTokenId, msg.sender);
    }

    // ───────────────────────────── views ─────────────────────────────

    function withdrawableLiquidity(uint256 lockTokenId) public view returns (uint128) {
        V4Lock memory l = lockPositions[lockTokenId];
        if (l.initialLiquidity == 0 && l.withdrawnLiquidity == 0) return 0;
        uint128 unlocked = _unlockedLiquidity(l);
        if (unlocked <= l.withdrawnLiquidity) return 0;
        return unlocked - l.withdrawnLiquidity;
    }

    function canRelease(uint256 lockTokenId) public view returns (bool) {
        V4Lock memory l = lockPositions[lockTokenId];
        if (l.initialLiquidity == 0 && l.withdrawnLiquidity == 0) return false;
        return block.timestamp >= l.finishUnlock && l.withdrawnLiquidity >= l.initialLiquidity;
    }

    function _unlockedLiquidity(V4Lock memory l) internal view returns (uint128) {
        if (block.timestamp <= l.startUnlock) return 0;
        if (block.timestamp >= l.finishUnlock) return l.initialLiquidity;
        uint256 duration = uint256(l.finishUnlock) - uint256(l.startUnlock);
        uint256 elapsed = block.timestamp - uint256(l.startUnlock);
        return uint128((uint256(l.initialLiquidity) * elapsed) / duration);
    }

    // ───────────────────────────── unlock callback ─────────────────────────────

    function unlockCallback(bytes calldata data) external override returns (bytes memory) {
        if (msg.sender != address(poolManager)) revert NotPoolManager();
        if (!_unlockActive) revert UnlockNotActive();

        (uint8 act, uint256 lockTokenId, uint256 liquidity) = abi.decode(data, (uint8, uint256, uint256));
        V4Lock storage l = lockPositions[lockTokenId];

        PoolKey memory key = PoolKey({
            currency0: l.currency0,
            currency1: l.currency1,
            fee: l.fee,
            tickSpacing: l.tickSpacing,
            hooks: l.hooks
        });
        bytes32 salt = bytes32(lockTokenId);

        if (act == ACT_MINT) {
            (int256 callerDelta,) = poolManager.modifyLiquidity(
                key,
                ModifyLiquidityParams({
                    tickLower: l.tickLower,
                    tickUpper: l.tickUpper,
                    liquidityDelta: int256(liquidity),
                    salt: salt
                }),
                ""
            );
            (uint256 paid0, uint256 paid1) = _settleOwed(key, callerDelta);
            return abi.encode(paid0, paid1, uint256(0), uint256(0));
        }

        if (act == ACT_COLLECT) {
            (int256 callerDelta, int256 feesAccrued) = poolManager.modifyLiquidity(
                key,
                ModifyLiquidityParams({tickLower: l.tickLower, tickUpper: l.tickUpper, liquidityDelta: 0, salt: salt}),
                ""
            );
            // With liquidityDelta 0, callerDelta == feesAccrued (fees only).
            feesAccrued; // silence unused
            (uint256 fee0, uint256 fee1) = _takeOwed(key, callerDelta, address(this));
            return abi.encode(uint256(0), uint256(0), fee0, fee1);
        }

        // ACT_DECREASE
        {
            (int256 callerDelta, int256 feesAccrued) = poolManager.modifyLiquidity(
                key,
                ModifyLiquidityParams({
                    tickLower: l.tickLower,
                    tickUpper: l.tickUpper,
                    liquidityDelta: -int256(liquidity),
                    salt: salt
                }),
                ""
            );
            (int128 total0, int128 total1) = _split(callerDelta);
            (int128 f0, int128 f1) = _split(feesAccrued);
            // Take the full owed amount into the locker.
            if (total0 > 0) poolManager.take(key.currency0, address(this), uint256(uint128(total0)));
            if (total1 > 0) poolManager.take(key.currency1, address(this), uint256(uint128(total1)));
            uint256 got0 = total0 > 0 ? uint256(uint128(total0)) : 0;
            uint256 got1 = total1 > 0 ? uint256(uint128(total1)) : 0;
            // Clamp fees to the amount actually received: a hooked pool can
            // report feesAccrued > callerDelta (hook skimmed the output), and an
            // unchecked subtraction would underflow and permanently brick the
            // lock's withdrawal path. Worst case under a hostile hook the
            // fee/principal split shifts — funds still flow. (Audit pass #2, H-1)
            uint256 fee0 = f0 > 0 ? uint256(uint128(f0)) : 0;
            uint256 fee1 = f1 > 0 ? uint256(uint128(f1)) : 0;
            if (fee0 > got0) fee0 = got0;
            if (fee1 > got1) fee1 = got1;
            uint256 principal0 = got0 - fee0;
            uint256 principal1 = got1 - fee1;

            // Upfront-mode fee sweep re-enters here with the position's *own*
            // funds; when triggered from `lock`, route principal to protocol.
            return abi.encode(principal0, principal1, fee0, fee1);
        }
    }

    // ───────────────────────────── settle/take helpers ─────────────────────────────

    /// @dev Pay everything the pool is owed (negative deltas) from this contract's
    /// balances. Returns the amounts paid per currency. Also takes back any
    /// positive dust so the unlock nets to zero.
    function _settleOwed(PoolKey memory key, int256 delta) internal returns (uint256 paid0, uint256 paid1) {
        (int128 d0, int128 d1) = _split(delta);
        if (d0 < 0) {
            paid0 = uint256(uint128(-d0));
            _settleCurrency(key.currency0, paid0);
        }
        if (d1 < 0) {
            paid1 = uint256(uint128(-d1));
            _settleCurrency(key.currency1, paid1);
        }
        if (d0 > 0) poolManager.take(key.currency0, address(this), uint256(uint128(d0)));
        if (d1 > 0) poolManager.take(key.currency1, address(this), uint256(uint128(d1)));
    }

    function _takeOwed(PoolKey memory key, int256 delta, address to) internal returns (uint256 got0, uint256 got1) {
        (int128 d0, int128 d1) = _split(delta);
        if (d0 > 0) {
            got0 = uint256(uint128(d0));
            poolManager.take(key.currency0, to, got0);
        }
        if (d1 > 0) {
            got1 = uint256(uint128(d1));
            poolManager.take(key.currency1, to, got1);
        }
        // Defensive: if a fee-only modify ever owed the pool, pay it.
        if (d0 < 0) _settleCurrency(key.currency0, uint256(uint128(-d0)));
        if (d1 < 0) _settleCurrency(key.currency1, uint256(uint128(-d1)));
    }

    function _settleCurrency(address currency, uint256 amount) internal {
        if (amount == 0) return;
        if (currency == NATIVE) {
            poolManager.settle{value: amount}();
        } else {
            poolManager.sync(currency);
            IERC20(currency).safeTransfer(address(poolManager), amount);
            poolManager.settle();
        }
    }

    function _split(int256 delta) internal pure returns (int128 amount0, int128 amount1) {
        amount0 = int128(delta >> 128);
        amount1 = int128(delta);
    }

    /// @dev Protocol fee payout must NEVER be able to block a user withdrawal:
    /// a native transfer the recipient rejects is parked in
    /// `pendingProtocolEth` instead of reverting the user's call.
    function _payoutProtocol(address currency, uint256 amount) internal {
        if (amount == 0) return;
        if (currency == NATIVE) {
            (bool ok,) = protocolFeeRecipient.call{value: amount}("");
            if (!ok) {
                pendingProtocolEth += amount;
                emit ProtocolEthPending(amount);
            }
        } else {
            IERC20(currency).safeTransfer(protocolFeeRecipient, amount);
        }
    }

    /// @notice Push any parked native protocol fees to the current recipient.
    function claimPendingProtocolEth() external nonReentrant {
        uint256 amount = pendingProtocolEth;
        pendingProtocolEth = 0;
        if (amount == 0) return;
        (bool ok,) = protocolFeeRecipient.call{value: amount}("");
        if (!ok) revert RefundFailed();
    }

    function _payout(address currency, address to, uint256 amount) internal {
        if (amount == 0) return;
        if (currency == NATIVE) {
            (bool ok,) = to.call{value: amount}("");
            if (!ok) revert RefundFailed();
        } else {
            IERC20(currency).safeTransfer(to, amount);
        }
    }

    function _refund(address currency, address to, uint256 amount, bool isNative) internal {
        if (amount == 0) return;
        if (isNative || currency == NATIVE) {
            (bool ok,) = to.call{value: amount}("");
            if (!ok) revert RefundFailed();
        } else {
            IERC20(currency).safeTransfer(to, amount);
        }
    }

    receive() external payable {}
}
