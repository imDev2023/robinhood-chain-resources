// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";

import "../uniswap/INonfungiblePositionManagerMinimal.sol";
import "./StonkLockerOwnershipNFT.sol";
import "./interfaces/IStonkLiquidityLocker.sol";

/// @notice Uniswap v3 LP locker with immutable per-position fee mode.
/// Users lock a position NFT and receive a transferable lock ownership NFT.
contract StonkLiquidityLocker is Ownable, IERC721Receiver, ReentrancyGuard, IStonkLiquidityLocker {
    using SafeERC20 for IERC20;
    using SafeCast for uint256;

    uint256 private constant BPS = 10_000;
    uint256 private constant UPFRONT_BPS = 50; // 0.5%
    uint256 private constant WITHDRAW_BPS = 100; // 1%
    uint256 private constant COLLECT_BPS = 2_000; // 20%

    INonfungiblePositionManagerMinimal public immutable positionManager;
    StonkLockerOwnershipNFT public immutable lockNft;
    address public protocolFeeRecipient;
    /// @notice Owner-managed set of wallets/contracts that bypass ALL protocol
    /// fees (upfront, withdraw, collect) — the protocol treasury plus, later,
    /// protocol contracts such as the launchpad that lock LP on users' behalf.
    /// Exemption is evaluated at charge time against the acting wallet, so a
    /// receipt sold on never carries the exemption with it.
    mapping(address => bool) public feeExempt;

    mapping(uint256 => LockPosition) public lockPositions;
    mapping(uint256 => uint256) public positionToLockTokenId;

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

    constructor(address initialOwner, address _positionManager, address _lockNft, address _protocolFeeRecipient)
        Ownable(initialOwner)
    {
        require(_positionManager != address(0), "pm=0");
        if (_protocolFeeRecipient == address(0)) revert ProtocolRecipientZero();
        require(_lockNft != address(0), "nft=0");
        positionManager = INonfungiblePositionManagerMinimal(_positionManager);
        lockNft = StonkLockerOwnershipNFT(_lockNft);
        protocolFeeRecipient = _protocolFeeRecipient;
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

    /// @dev Optional manual path (for UIs that transfer first then register).
    function lockByTransfer(uint256 positionTokenId, uint64 startUnlock, uint64 finishUnlock, FeeMode feeMode)
        external
        returns (uint256 lockTokenId)
    {
        positionManager.safeTransferFrom(msg.sender, address(this), positionTokenId, abi.encode(startUnlock, finishUnlock, feeMode));
        lockTokenId = positionToLockTokenId[positionTokenId];
    }

    function onERC721Received(address, address from, uint256 tokenId, bytes calldata data)
        external
        override
        nonReentrant
        returns (bytes4)
    {
        if (msg.sender != address(positionManager)) revert BadPositionSender();
        if (positionToLockTokenId[tokenId] != 0) revert PositionAlreadyLocked();
        if (data.length == 0) revert InvalidLockWindow();

        (uint64 startUnlock, uint64 finishUnlock, FeeMode feeMode) = abi.decode(data, (uint64, uint64, FeeMode));
        if (finishUnlock <= startUnlock || startUnlock < block.timestamp) revert InvalidLockWindow();
        if (uint8(feeMode) > uint8(FeeMode.CollectTwentyPercent)) revert InvalidMode();

        (, , address token0, address token1, , , , uint128 liquidity, , , , ) = positionManager.positions(tokenId);
        if (liquidity == 0) revert ZeroLiquidity();

        uint256 lockTokenId = lockNft.mint(from);
        positionToLockTokenId[tokenId] = lockTokenId;
        lockPositions[lockTokenId] = LockPosition({
            positionTokenId: tokenId,
            lockTokenId: lockTokenId,
            token0: token0,
            token1: token1,
            initialLiquidity: liquidity,
            withdrawnLiquidity: 0,
            startUnlock: startUnlock,
            finishUnlock: finishUnlock,
            feeMode: feeMode,
            closed: false
        });

        if (feeMode == FeeMode.UpfrontHalfPercent && !_isFeeExempt(from)) {
            _chargeUpfront(lockTokenId, liquidity);
        }

        emit PositionLocked(tokenId, lockTokenId, from, startUnlock, finishUnlock, feeMode, liquidity);
        return IERC721Receiver.onERC721Received.selector;
    }

    function collectFees(uint256 lockTokenId, uint128 amount0Max, uint128 amount1Max)
        external
        nonReentrant
        returns (uint256 userAmount0, uint256 userAmount1, uint256 protocolAmount0, uint256 protocolAmount1)
    {
        LockPosition storage p = lockPositions[lockTokenId];
        if (p.positionTokenId == 0) revert UnknownLock();
        if (lockNft.ownerOf(lockTokenId) != msg.sender) revert NotLockOwner();

        (uint256 gross0, uint256 gross1) = positionManager.collect(
            INonfungiblePositionManagerMinimal.CollectParams({
                tokenId: p.positionTokenId,
                recipient: address(this),
                amount0Max: amount0Max == 0 ? type(uint128).max : amount0Max,
                amount1Max: amount1Max == 0 ? type(uint128).max : amount1Max
            })
        );

        if (p.feeMode == FeeMode.CollectTwentyPercent && !_isFeeExempt(msg.sender)) {
            (protocolAmount0, protocolAmount1) = _transferProtocolCut(p.token0, p.token1, gross0, gross1, COLLECT_BPS);
        }

        userAmount0 = gross0 - protocolAmount0;
        userAmount1 = gross1 - protocolAmount1;
        if (userAmount0 > 0) IERC20(p.token0).safeTransfer(msg.sender, userAmount0);
        if (userAmount1 > 0) IERC20(p.token1).safeTransfer(msg.sender, userAmount1);

        emit LockFeesCollected(lockTokenId, userAmount0, userAmount1, protocolAmount0, protocolAmount1);
    }

    function decreaseLockedLiquidity(
        uint256 lockTokenId,
        uint128 liquidity,
        uint256 amount0Min,
        uint256 amount1Min
    ) external nonReentrant returns (uint256 userAmount0, uint256 userAmount1, uint256 protocolAmount0, uint256 protocolAmount1) {
        if (liquidity == 0) revert ZeroLiquidity();
        LockPosition storage p = lockPositions[lockTokenId];
        if (p.positionTokenId == 0) revert UnknownLock();
        if (lockNft.ownerOf(lockTokenId) != msg.sender) revert NotLockOwner();

        uint128 maxLiquidity = withdrawableLiquidity(lockTokenId);
        if (liquidity > maxLiquidity) revert LiquidityExceedsUnlocked();

        (uint256 gross0, uint256 gross1) = positionManager.decreaseLiquidity(
            INonfungiblePositionManagerMinimal.DecreaseLiquidityParams({
                tokenId: p.positionTokenId,
                liquidity: liquidity,
                amount0Min: amount0Min,
                amount1Min: amount1Min,
                deadline: block.timestamp + 30 minutes
            })
        );

        // Collect *exactly* the principal amounts just decreased. Anything else
        // owed to the position (accumulated swap fees, or pre-existing tokensOwed
        // that arrived with the NFT) is intentionally left in the Uniswap position
        // so it can be claimed by the user through `collectFees` under the correct
        // fee-mode logic. Using `uint128.max` here would silently sweep those into
        // this contract without paying them out and orphan them.
        positionManager.collect(
            INonfungiblePositionManagerMinimal.CollectParams({
                tokenId: p.positionTokenId,
                recipient: address(this),
                amount0Max: gross0.toUint128(),
                amount1Max: gross1.toUint128()
            })
        );

        p.withdrawnLiquidity += liquidity;
        if (p.feeMode == FeeMode.WithdrawOnePercent && !_isFeeExempt(msg.sender)) {
            (protocolAmount0, protocolAmount1) = _transferProtocolCut(p.token0, p.token1, gross0, gross1, WITHDRAW_BPS);
        }

        userAmount0 = gross0 - protocolAmount0;
        userAmount1 = gross1 - protocolAmount1;
        if (userAmount0 > 0) IERC20(p.token0).safeTransfer(msg.sender, userAmount0);
        if (userAmount1 > 0) IERC20(p.token1).safeTransfer(msg.sender, userAmount1);

        emit LockLiquidityDecreased(lockTokenId, liquidity, userAmount0, userAmount1, protocolAmount0, protocolAmount1);
    }

    function releasePosition(uint256 lockTokenId) external nonReentrant {
        LockPosition storage p = lockPositions[lockTokenId];
        if (p.positionTokenId == 0) revert UnknownLock();
        if (lockNft.ownerOf(lockTokenId) != msg.sender) revert NotLockOwner();
        if (!canRelease(lockTokenId)) revert NotClosed();

        uint256 positionTokenId = p.positionTokenId;
        delete positionToLockTokenId[positionTokenId];
        p.closed = true;
        lockNft.burn(lockTokenId);
        positionManager.safeTransferFrom(address(this), msg.sender, positionTokenId);
        emit PositionReleased(lockTokenId, positionTokenId, msg.sender);
    }

    function withdrawableLiquidity(uint256 lockTokenId) public view returns (uint128) {
        LockPosition memory p = lockPositions[lockTokenId];
        if (p.positionTokenId == 0) return 0;
        uint128 unlocked = _unlockedLiquidity(p);
        if (unlocked <= p.withdrawnLiquidity) return 0;
        return unlocked - p.withdrawnLiquidity;
    }

    function canRelease(uint256 lockTokenId) public view returns (bool) {
        LockPosition memory p = lockPositions[lockTokenId];
        if (p.positionTokenId == 0) return false;
        return block.timestamp >= p.finishUnlock && p.withdrawnLiquidity >= p.initialLiquidity;
    }

    function _unlockedLiquidity(LockPosition memory p) internal view returns (uint128) {
        if (block.timestamp <= p.startUnlock) return 0;
        if (block.timestamp >= p.finishUnlock) return p.initialLiquidity;

        uint256 duration = uint256(p.finishUnlock) - uint256(p.startUnlock);
        uint256 elapsed = block.timestamp - uint256(p.startUnlock);
        return uint128((uint256(p.initialLiquidity) * elapsed) / duration);
    }

    function _chargeUpfront(uint256 lockTokenId, uint128 liquidity) internal {
        LockPosition storage p = lockPositions[lockTokenId];

        uint128 feeLiquidity = uint128((uint256(liquidity) * UPFRONT_BPS) / BPS);
        if (feeLiquidity == 0) return;

        (uint256 gross0, uint256 gross1) = positionManager.decreaseLiquidity(
            INonfungiblePositionManagerMinimal.DecreaseLiquidityParams({
                tokenId: p.positionTokenId,
                liquidity: feeLiquidity,
                amount0Min: 0,
                amount1Min: 0,
                deadline: block.timestamp + 30 minutes
            })
        );

        // Collect *exactly* the principal amounts just decreased so pre-existing
        // tokensOwed / accrued swap fees on the position stay with the position
        // (belonging to the user) instead of being swept into this contract with
        // no payout path. See H1/H2 in docs/security/liquidity-locker-audit.md.
        positionManager.collect(
            INonfungiblePositionManagerMinimal.CollectParams({
                tokenId: p.positionTokenId,
                recipient: address(this),
                amount0Max: gross0.toUint128(),
                amount1Max: gross1.toUint128()
            })
        );

        p.initialLiquidity -= feeLiquidity;
        if (gross0 > 0) IERC20(p.token0).safeTransfer(protocolFeeRecipient, gross0);
        if (gross1 > 0) IERC20(p.token1).safeTransfer(protocolFeeRecipient, gross1);
    }

    function _transferProtocolCut(address token0, address token1, uint256 gross0, uint256 gross1, uint256 bps)
        internal
        returns (uint256 protocol0, uint256 protocol1)
    {
        protocol0 = (gross0 * bps) / BPS;
        protocol1 = (gross1 * bps) / BPS;
        if (protocol0 > 0) IERC20(token0).safeTransfer(protocolFeeRecipient, protocol0);
        if (protocol1 > 0) IERC20(token1).safeTransfer(protocolFeeRecipient, protocol1);
    }
}

