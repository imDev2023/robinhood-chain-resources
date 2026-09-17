// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {INonfungiblePositionManager} from "./interfaces/IUniswapV3.sol";
import {FeeRouter} from "./FeeRouter.sol";

interface IFeeRecipientSync {
    function syncFeeRecipientExemptions(address token) external;
}

/// @notice Permanently holds LP NFTs for launched tokens. There is no withdraw
/// path: liquidity is locked forever. Anyone may trigger a fee claim for a token;
/// proceeds are split by the FeeRouter among the protocol, buy-burner, and the
/// token's CTO fee vault.
contract LauncherLocker is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    error NotFactory();
    error NotFeeWallet();
    error UnknownToken();
    error ZeroAddress();
    error AlreadyRegistered();
    error AlreadyInitialized();
    error PositionNotHeld();
    error InvalidPosition();

    event PositionRegistered(
        address indexed token, uint256 indexed positionId, address indexed feeWallet, address positionManager
    );
    event FeesClaimed(address indexed token, uint256 indexed positionId, uint256 tokenAmount, uint256 pairAmount);
    event FeeRedirectUpdated(address indexed token, address indexed newFeeWallet);
    event FactoryUpdated(address factory);

    struct Position {
        uint256 positionId;
        address positionManager;
        address pairToken;
        address feeWallet;
        bool isToken0; // launched token is token0 of the pool
    }

    FeeRouter public immutable feeRouter;
    address public factory;

    mapping(address token => Position) internal positions;

    constructor(address payable feeRouter_) Ownable(msg.sender) {
        if (feeRouter_ == address(0)) revert ZeroAddress();
        feeRouter = FeeRouter(feeRouter_);
    }

    /// @notice One-time wiring of the factory (set at deployment).
    function setFactory(address factory_) external onlyOwner {
        if (factory_ == address(0)) revert ZeroAddress();
        if (factory != address(0)) revert AlreadyInitialized();
        factory = factory_;
        emit FactoryUpdated(factory_);
    }

    /// @notice Called by the factory right after minting the LP NFT to this contract.
    function registerPosition(
        address token,
        uint256 positionId,
        address positionManager,
        address pairToken,
        address feeWallet,
        bool isToken0
    ) external {
        if (msg.sender != factory) revert NotFactory();
        if (token == address(0) || positionManager == address(0) || pairToken == address(0) || feeWallet == address(0))
        {
            revert ZeroAddress();
        }
        if (positions[token].positionManager != address(0)) revert AlreadyRegistered();
        INonfungiblePositionManager manager = INonfungiblePositionManager(positionManager);
        if (manager.ownerOf(positionId) != address(this)) revert PositionNotHeld();
        (,, address token0, address token1,,,,,,,,) = manager.positions(positionId);
        if (isToken0 ? (token0 != token || token1 != pairToken) : (token1 != token || token0 != pairToken)) {
            revert InvalidPosition();
        }
        positions[token] = Position({
            positionId: positionId,
            positionManager: positionManager,
            pairToken: pairToken,
            feeWallet: feeWallet,
            isToken0: isToken0
        });
        emit PositionRegistered(token, positionId, feeWallet, positionManager);
    }

    /// @notice Current fee recipient can redirect future fee payouts.
    function setFeeRedirect(address token, address newFeeWallet) external {
        Position storage pos = positions[token];
        if (pos.positionManager == address(0)) revert UnknownToken();
        if (msg.sender != pos.feeWallet) revert NotFeeWallet();
        if (newFeeWallet == address(0)) revert ZeroAddress();
        pos.feeWallet = newFeeWallet;
        emit FeeRedirectUpdated(token, newFeeWallet);
    }

    /// @notice Collect accrued LP fees for `token` and distribute via the FeeRouter.
    /// Callable by anyone; destinations are fixed by the router plus this token's CTO vault.
    function claimFees(address token) external nonReentrant returns (uint256 tokenAmount, uint256 pairAmount) {
        Position memory pos = positions[token];
        if (pos.positionManager == address(0)) revert UnknownToken();

        // Recipient addresses are admin-configurable. Synchronize their
        // restriction exemptions before transferring fees so a rotation cannot
        // make max-wallet rules block collection during the launch window.
        IFeeRecipientSync(factory).syncFeeRecipientExemptions(token);

        (uint256 amount0, uint256 amount1) = INonfungiblePositionManager(pos.positionManager)
            .collect(
                INonfungiblePositionManager.CollectParams({
                    tokenId: pos.positionId,
                    recipient: address(feeRouter),
                    amount0Max: type(uint128).max,
                    amount1Max: type(uint128).max
                })
            );

        (tokenAmount, pairAmount) = pos.isToken0 ? (amount0, amount1) : (amount1, amount0);
        feeRouter.distribute(token, pos.pairToken, tokenAmount, pairAmount, pos.feeWallet);
        emit FeesClaimed(token, pos.positionId, tokenAmount, pairAmount);
    }

    /// @notice Pending (uncollected) fees are read off-chain via positionManager.positions().
    function getPosition(address token) external view returns (Position memory) {
        Position memory pos = positions[token];
        if (pos.positionManager == address(0)) revert UnknownToken();
        return pos;
    }

    function feeWalletOf(address token) external view returns (address) {
        Position memory pos = positions[token];
        if (pos.positionManager == address(0)) revert UnknownToken();
        return pos.feeWallet;
    }

    /// @notice Accept LP NFTs minted directly to this contract.
    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
