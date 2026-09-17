// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @dev The only position-manager surface the locker touches: fee collection
///      and reading a position's pool tokens. Deliberately NO transfer,
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

/// @title hood.fun Liquidity Locker
/// @notice Permanently holds the Uniswap v3 liquidity position of every
///         graduated hood.fun coin and streams the pool's trading fees to the
///         coin's creator and the protocol in a fixed split.
///
///         Unruggable BY CONSTRUCTION, not by configuration:
///           - There is no withdraw function. No transfer function. No
///             decreaseLiquidity. No burn. No migrate. The bytecode that could
///             move a locked position does not exist in this contract.
///           - There is no owner and no admin role. Nothing is upgradeable,
///             nothing is configurable after deployment.
///           - Each lock's creator / protocol / split are recorded once, when
///             the position NFT arrives, and can never be changed.
///           - `collectRewards` is permissionless: anyone may trigger it, and
///             the proceeds can only ever go to the recorded creator and
///             protocol addresses. Calling it moves fees only — never
///             principal liquidity.
///
///         This is the same trust model as Clanker's LP locker on Base
///         (locked-forever position, perpetual fee stream), which has held the
///         liquidity of 200k+ tokens without incident: the strongest available
///         precedent for "locked and earning".
contract HoodLiquidityLocker is IERC721Receiver, ReentrancyGuard {
    struct Reward {
        address creator; // receives creatorShareBps of every collection
        address protocol; // receives the remainder
        uint16 creatorShareBps; // fixed at lock time (5000 = 50%)
    }

    uint16 internal constant BPS = 10_000;

    /// @dev The one and only position manager this locker accepts NFTs from.
    ILockerPositionManager public immutable nfpm;

    mapping(uint256 tokenId => Reward) public rewards;

    event Locked(uint256 indexed tokenId, address indexed creator, address indexed protocol, uint16 creatorShareBps);
    event Collected(
        uint256 indexed tokenId,
        address indexed caller,
        uint256 creatorAmount0,
        uint256 creatorAmount1,
        uint256 protocolAmount0,
        uint256 protocolAmount1
    );

    error OnlyPositionManager();
    error UnknownPosition();
    error AlreadyLocked();
    error BadRewardConfig();

    constructor(address nfpm_) {
        require(nfpm_ != address(0), "ZERO_ADDR");
        nfpm = ILockerPositionManager(nfpm_);
    }

    /// @notice The only way in: a `safeTransferFrom` of a position NFT from the
    ///         position manager, carrying abi.encode(creator, protocol,
    ///         creatorShareBps). Once received the position can never leave.
    function onERC721Received(address, address, uint256 tokenId, bytes calldata data)
        external
        override
        returns (bytes4)
    {
        if (msg.sender != address(nfpm)) revert OnlyPositionManager();
        if (rewards[tokenId].creator != address(0)) revert AlreadyLocked();
        (address creator, address protocol, uint16 creatorShareBps) = abi.decode(data, (address, address, uint16));
        if (creator == address(0) || protocol == address(0) || creatorShareBps > BPS) revert BadRewardConfig();
        rewards[tokenId] = Reward({creator: creator, protocol: protocol, creatorShareBps: creatorShareBps});
        emit Locked(tokenId, creator, protocol, creatorShareBps);
        return this.onERC721Received.selector;
    }

    /// @notice Collect the position's accrued pool fees and pay them straight
    ///         out: creatorShareBps to the creator, the rest to the protocol.
    ///         Permissionless — anyone may call, nobody can redirect.
    function collectRewards(uint256 tokenId)
        external
        nonReentrant
        returns (uint256 amount0, uint256 amount1)
    {
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

        // Split the exact collected amounts (not balances), so unrelated
        // donations or other locks' dust can never cross-contaminate.
        (uint256 c0, uint256 p0) = _split(token0, amount0, r);
        (uint256 c1, uint256 p1) = _split(token1, amount1, r);
        emit Collected(tokenId, msg.sender, c0, c1, p0, p1);
    }

    function _split(address token, uint256 amount, Reward memory r)
        private
        returns (uint256 toCreator, uint256 toProtocol)
    {
        if (amount == 0) return (0, 0);
        toCreator = (amount * r.creatorShareBps) / BPS;
        toProtocol = amount - toCreator;
        if (toCreator > 0) require(IERC20(token).transfer(r.creator, toCreator), "XFER_CREATOR");
        if (toProtocol > 0) require(IERC20(token).transfer(r.protocol, toProtocol), "XFER_PROTOCOL");
    }
}
