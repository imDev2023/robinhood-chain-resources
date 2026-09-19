// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "../uniswap/INonfungiblePositionManagerMinimal.sol";

interface IStonkYieldStakingVault {
    function notifyRewards(uint256 amount0, uint256 amount1) external;
}

/// @notice Owns a Uniswap v3 position NFT, collects fees and splits:
/// 50% to treasury, 50% to staking vault.
contract StonkLpFeeSplitter is IERC721Receiver, ReentrancyGuard {
    using SafeERC20 for IERC20;
    INonfungiblePositionManagerMinimal public immutable positionManager;
    address public immutable treasury;
    address public immutable stakingVault;

    address public token0;
    address public token1;
    uint256 public positionTokenId;
    bool public initialized;

    event PositionInitialized(uint256 indexed tokenId, address indexed token0, address indexed token1);
    event FeesCollected(uint256 indexed tokenId, uint256 amount0, uint256 amount1);
    event FeesSplit(uint256 treasury0, uint256 treasury1, uint256 stakers0, uint256 stakers1);

    error AlreadyInitialized();
    error NotOwnerOfPosition();

    constructor(address _positionManager, address _treasury, address _stakingVault) {
        require(_positionManager != address(0), "pm=0");
        require(_treasury != address(0), "treasury=0");
        require(_stakingVault != address(0), "staking=0");
        positionManager = INonfungiblePositionManagerMinimal(_positionManager);
        treasury = _treasury;
        stakingVault = _stakingVault;
    }

    function initializePosition(uint256 tokenId, address _token0, address _token1) external {
        if (initialized) revert AlreadyInitialized();
        require(_token0 != address(0) && _token1 != address(0), "token=0");
        require(positionManager.ownerOf(tokenId) == address(this), "not held");
        positionTokenId = tokenId;
        token0 = _token0;
        token1 = _token1;
        initialized = true;
        emit PositionInitialized(tokenId, _token0, _token1);
    }

    function collectAndSplit() external nonReentrant returns (uint256 amount0, uint256 amount1) {
        require(initialized, "not init");

        (amount0, amount1) = positionManager.collect(
            INonfungiblePositionManagerMinimal.CollectParams({
                tokenId: positionTokenId,
                recipient: address(this),
                amount0Max: type(uint128).max,
                amount1Max: type(uint128).max
            })
        );

        emit FeesCollected(positionTokenId, amount0, amount1);

        uint256 t0 = amount0 / 2;
        uint256 t1 = amount1 / 2;
        uint256 s0 = amount0 - t0;
        uint256 s1 = amount1 - t1;

        if (t0 > 0) IERC20(token0).safeTransfer(treasury, t0);
        if (t1 > 0) IERC20(token1).safeTransfer(treasury, t1);

        if (s0 > 0) IERC20(token0).safeTransfer(stakingVault, s0);
        if (s1 > 0) IERC20(token1).safeTransfer(stakingVault, s1);
        IStonkYieldStakingVault(stakingVault).notifyRewards(s0, s1);

        emit FeesSplit(t0, t1, s0, s1);
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}

