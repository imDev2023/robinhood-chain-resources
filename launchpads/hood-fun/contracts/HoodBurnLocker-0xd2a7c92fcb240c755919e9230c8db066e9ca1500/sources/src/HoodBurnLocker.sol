// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @dev The only position-manager surface the locker touches: fee collection and
///      reading a position's pool tokens. Deliberately NO transfer,
///      decreaseLiquidity or burn — the locker cannot call what it cannot see.
interface ILockerPositionManager {
    struct CollectParams {
        uint256 tokenId;
        address recipient;
        uint128 amount0Max;
        uint128 amount1Max;
    }

    function collect(CollectParams calldata params) external payable returns (uint256 amount0, uint256 amount1);

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
}

/// @title HoodBurnLocker
/// @notice Ownerless, unruggable Uniswap v3 LP locker for hood.fun's migrated
///         coins. Same permanent-lock guarantees as the classic hood.fun locker:
///           - NO owner, NO admin, nothing upgradeable.
///           - NO withdraw / transfer / decreaseLiquidity / burn of the position —
///             the locked LP NFT can never leave, so liquidity is unruggable by
///             construction.
///           - Each position's payout wallets + split are recorded once at lock
///             time and can never be changed.
///         The ONLY behavioural difference from the classic locker: the collected
///         1% pool fee is distributed as
///           - quote (WETH) side  → `creatorShareBps` to creator, remainder to protocol
///           - launch-token side  → BURN_BPS burned to 0x…dEaD, remainder to protocol
///         making every migrated coin deflationary. Permissionless to collect;
///         nobody can redirect the proceeds.
contract HoodBurnLocker is IERC721Receiver, ReentrancyGuard {
    address internal constant DEAD = 0x000000000000000000000000000000000000dEaD;
    uint256 internal constant BPS = 10_000;
    /// @notice Share of the launch-token fee side that is burned (80%).
    uint256 public constant BURN_BPS = 8_000;

    ILockerPositionManager public immutable nfpm;
    address public immutable WETH;

    struct Reward {
        address creator; // receives creatorShareBps of the WETH-side fees
        address protocol; // receives the remainder of both sides
        uint16 creatorShareBps; // fixed at lock time (8000 = 80%)
    }

    mapping(uint256 tokenId => Reward) public rewards;

    event Locked(uint256 indexed tokenId, address indexed creator, address indexed protocol, uint16 creatorShareBps);
    event Collected(
        uint256 indexed tokenId,
        address indexed caller,
        uint256 creatorWeth,
        uint256 protocolWeth,
        uint256 burnedTokens,
        uint256 protocolTokens
    );

    error AlreadyLocked();
    error BadRewardConfig();
    error UnknownPosition();
    error OnlyPositionManager();

    constructor(address nfpm_, address weth_) {
        nfpm = ILockerPositionManager(nfpm_);
        WETH = weth_;
    }

    /// @notice Receive + permanently lock a position. Delivered by the position
    ///         manager via safeTransferFrom, carrying abi.encode(creator, protocol,
    ///         creatorShareBps). Once received the position can never leave.
    function onERC721Received(address, address, uint256 tokenId, bytes calldata data) external returns (bytes4) {
        if (msg.sender != address(nfpm)) revert OnlyPositionManager();
        if (rewards[tokenId].creator != address(0)) revert AlreadyLocked();
        (address creator, address protocol, uint16 creatorShareBps) = abi.decode(data, (address, address, uint16));
        if (creator == address(0) || protocol == address(0) || creatorShareBps > BPS) revert BadRewardConfig();
        rewards[tokenId] = Reward({creator: creator, protocol: protocol, creatorShareBps: creatorShareBps});
        emit Locked(tokenId, creator, protocol, creatorShareBps);
        return IERC721Receiver.onERC721Received.selector;
    }

    /// @notice Collect the position's accrued fees and distribute them.
    ///         Permissionless — anyone may call, nobody can redirect.
    function collectRewards(uint256 tokenId) external nonReentrant returns (uint256 amount0, uint256 amount1) {
        Reward memory r = rewards[tokenId];
        if (r.creator == address(0)) revert UnknownPosition();

        (,, address token0, address token1,,,,,,,,) = nfpm.positions(tokenId);
        (amount0, amount1) = nfpm.collect(
            ILockerPositionManager.CollectParams({
                tokenId: tokenId,
                recipient: address(this),
                amount0Max: type(uint128).max,
                amount1Max: type(uint128).max
            })
        );

        // split the exact collected amounts (not balances) so unrelated donations
        // or other locks' dust can never cross-contaminate
        (uint256 cW0, uint256 pW0, uint256 b0, uint256 pT0) = _distribute(token0, amount0, r);
        (uint256 cW1, uint256 pW1, uint256 b1, uint256 pT1) = _distribute(token1, amount1, r);
        emit Collected(tokenId, msg.sender, cW0 + cW1, pW0 + pW1, b0 + b1, pT0 + pT1);
    }

    /// @dev WETH side → creator/protocol; launch-token side → burn/protocol.
    function _distribute(address token, uint256 amount, Reward memory r)
        private
        returns (uint256 creatorWeth, uint256 protocolWeth, uint256 burnedTokens, uint256 protocolTokens)
    {
        if (amount == 0) return (0, 0, 0, 0);
        if (token == WETH) {
            creatorWeth = (amount * r.creatorShareBps) / BPS;
            protocolWeth = amount - creatorWeth;
            if (creatorWeth > 0) require(IERC20(token).transfer(r.creator, creatorWeth), "XFER_CREATOR");
            if (protocolWeth > 0) require(IERC20(token).transfer(r.protocol, protocolWeth), "XFER_PROTOCOL");
        } else {
            burnedTokens = (amount * BURN_BPS) / BPS;
            protocolTokens = amount - burnedTokens;
            if (burnedTokens > 0) require(IERC20(token).transfer(DEAD, burnedTokens), "XFER_BURN");
            if (protocolTokens > 0) require(IERC20(token).transfer(r.protocol, protocolTokens), "XFER_PROTOCOL");
        }
    }
}
