// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @notice Minimal interfaces for the up33 (up.) Slipstream concentrated-liquidity
/// stack on Robinhood Chain 4663. up33 is a Velodrome V2 + Slipstream fork; the
/// periphery is solc 0.7.6 and predates custom errors, so reverts are short
/// string codes ("NA" not approved, "PM" pool mismatch, "GK" gauge killed, ...).
///
/// IMPORTANT — `positions(uint256)` keeps Uniswap V3's exact selector 0x99fbab88
/// but returns `tickSpacing` in the slot where V3 returns `fee`. A V3-typed
/// interface decodes it without reverting and silently reads a tick spacing as a
/// fee tier. Slipstream pools are keyed by tick spacing, and the real swap fee is
/// dynamic (read `ICLPool.fee()` at the time you need it, never cache it).
interface IUpNonfungiblePositionManager {
    struct CollectParams {
        uint256 tokenId;
        address recipient;
        uint128 amount0Max;
        uint128 amount1Max;
    }

    struct DecreaseLiquidityParams {
        uint256 tokenId;
        uint128 liquidity;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    /// @dev Slot 5 is `tickSpacing`, NOT `fee`. See note above.
    function positions(uint256 tokenId)
        external
        view
        returns (
            uint96 nonce,
            address operator,
            address token0,
            address token1,
            int24 tickSpacing,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );

    function collect(CollectParams calldata params) external payable returns (uint256 amount0, uint256 amount1);

    function decreaseLiquidity(DecreaseLiquidityParams calldata params)
        external
        payable
        returns (uint256 amount0, uint256 amount1);

    function burn(uint256 tokenId) external payable;

    function factory() external view returns (address);

    function ownerOf(uint256 tokenId) external view returns (address);

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId) external view returns (address);

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

interface IUpCLFactory {
    /// @dev Slipstream pools are keyed by tick spacing. Addresses are EIP-1167
    /// clones of `poolImplementation()`, so the Uniswap V3 init-code-hash
    /// derivation does NOT work here — always resolve through the factory.
    function getPool(address tokenA, address tokenB, int24 tickSpacing) external view returns (address pool);

    function isPool(address pool) external view returns (bool);

    function poolImplementation() external view returns (address);
}

interface IUpCLPool {
    function gauge() external view returns (address);

    /// @dev Dynamic, served by a governance-controlled fee module. Never cache.
    function fee() external view returns (uint24);

    /// @dev Levy applied to fees earned by UNSTAKED positions (pips out of 1e6).
    function unstakedFee() external view returns (uint24);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function tickSpacing() external view returns (int24);

    function liquidity() external view returns (uint128);

    function stakedLiquidity() external view returns (uint128);
}

/// @notice up33 Slipstream gauge. Custodial: the gauge becomes `ownerOf` the
/// position NFT, and ONLY the depositing address can withdraw it again.
interface IUpCLGauge {
    /// @dev Requires `nft.ownerOf(tokenId) == msg.sender` AND the gauge to be
    /// approved on the NFT (it calls `nft.collect` and `nft.safeTransferFrom`
    /// before taking ownership). Sweeps pending swap fees to msg.sender.
    function deposit(uint256 tokenId) external;

    /// @dev Requires `stakedContains(msg.sender, tokenId)`. Sweeps pending swap
    /// fees AND accrued emissions to msg.sender, then returns the NFT via
    /// `safeTransferFrom` (so the caller must implement `onERC721Received`).
    function withdraw(uint256 tokenId) external;

    /// @dev Requires `stakedContains(msg.sender, tokenId)`. Pays msg.sender.
    function getReward(uint256 tokenId) external;

    function earned(address account, uint256 tokenId) external view returns (uint256);

    function stakedContains(address depositor, uint256 tokenId) external view returns (bool);

    function rewardToken() external view returns (address);

    function pool() external view returns (address);

    function left() external view returns (uint256);
}

interface IUpVoter {
    function gauges(address pool) external view returns (address);

    function isGauge(address gauge) external view returns (bool);

    /// @dev A killed gauge blocks `deposit` ("GK") but NOT `withdraw`.
    function isAlive(address gauge) external view returns (bool);
}
