// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "../uniswap/INonfungiblePositionManagerMinimal.sol";
import "./MockUniswapV3Pool.sol";

/// @notice Minimal NonfungiblePositionManager mock for launcher tests.
/// It:
/// - creates a dummy pool (token0/token1)
/// - pulls tokens on mint via transferFrom
/// - tracks ERC721 ownership for safeTransferFrom/ownerOf
/// - allows collect() to send any balances it holds to recipient
contract MockNonfungiblePositionManager is INonfungiblePositionManagerMinimal {
    using Address for address;

    uint256 private _nextTokenId = 1;

    mapping(uint256 => address) private _ownerOf;
    struct PositionData {
        address token0;
        address token1;
        uint128 liquidity;
        uint128 tokensOwed0;
        uint128 tokensOwed1;
    }
    mapping(uint256 => PositionData) private _positions;

    address public lastPool;

    function createAndInitializePoolIfNecessary(
        address token0,
        address token1,
        uint24, /* fee */
        uint160 /* sqrtPriceX96 */
    ) external payable returns (address pool) {
        MockUniswapV3Pool p = new MockUniswapV3Pool(token0, token1);
        pool = address(p);
        lastPool = pool;
    }

    function mint(MintParams calldata params)
        external
        payable
        returns (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1)
    {
        // Pull tokens like the real PM.
        if (params.amount0Desired > 0) {
            require(IERC20(params.token0).transferFrom(msg.sender, address(this), params.amount0Desired), "t0 xfer");
        }
        if (params.amount1Desired > 0) {
            require(IERC20(params.token1).transferFrom(msg.sender, address(this), params.amount1Desired), "t1 xfer");
        }

        tokenId = _nextTokenId++;
        _ownerOf[tokenId] = params.recipient;
        _positions[tokenId] = PositionData({
            token0: params.token0,
            token1: params.token1,
            liquidity: 100_000,
            tokensOwed0: 0,
            tokensOwed1: 0
        });
        amount0 = params.amount0Desired;
        amount1 = params.amount1Desired;
        liquidity = 1;
    }

    function collect(CollectParams calldata params) external payable returns (uint256 amount0, uint256 amount1) {
        require(_ownerOf[params.tokenId] != address(0), "no token");

        PositionData storage p = _positions[params.tokenId];
        uint256 owed0 = p.tokensOwed0;
        uint256 owed1 = p.tokensOwed1;

        amount0 = owed0 > params.amount0Max ? params.amount0Max : owed0;
        amount1 = owed1 > params.amount1Max ? params.amount1Max : owed1;

        if (amount0 > 0) p.tokensOwed0 = uint128(owed0 - amount0);
        if (amount1 > 0) p.tokensOwed1 = uint128(owed1 - amount1);

        if (amount0 > 0) require(IERC20(p.token0).transfer(params.recipient, amount0), "c0 xfer");
        if (amount1 > 0) require(IERC20(p.token1).transfer(params.recipient, amount1), "c1 xfer");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) external {
        require(_ownerOf[tokenId] == from, "not owner");
        require(msg.sender == from, "not auth");
        _ownerOf[tokenId] = to;

        if (to.code.length > 0) {
            bytes4 ret = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, "");
            require(ret == IERC721Receiver.onERC721Received.selector, "bad receiver");
        }
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external {
        require(_ownerOf[tokenId] == from, "not owner");
        require(msg.sender == from, "not auth");
        _ownerOf[tokenId] = to;

        if (to.code.length > 0) {
            bytes4 ret = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data);
            require(ret == IERC721Receiver.onERC721Received.selector, "bad receiver");
        }
    }

    function decreaseLiquidity(DecreaseLiquidityParams calldata params)
        external
        payable
        returns (uint256 amount0, uint256 amount1)
    {
        require(_ownerOf[params.tokenId] == msg.sender, "not owner");
        PositionData storage p = _positions[params.tokenId];
        require(params.liquidity > 0 && params.liquidity <= p.liquidity, "bad liq");

        p.liquidity -= params.liquidity;
        amount0 = uint256(params.liquidity) * 1e12;
        amount1 = uint256(params.liquidity) * 1e12;
        p.tokensOwed0 += uint128(amount0);
        p.tokensOwed1 += uint128(amount1);
    }

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
        )
    {
        PositionData memory p = _positions[tokenId];
        require(_ownerOf[tokenId] != address(0), "no token");
        nonce = 0;
        operator = address(0);
        token0 = p.token0;
        token1 = p.token1;
        fee = 3000;
        tickLower = -887220;
        tickUpper = 887220;
        liquidity = p.liquidity;
        feeGrowthInside0LastX128 = 0;
        feeGrowthInside1LastX128 = 0;
        tokensOwed0 = p.tokensOwed0;
        tokensOwed1 = p.tokensOwed1;
    }

    function seedFees(uint256 tokenId, uint128 amount0, uint128 amount1) external {
        PositionData storage p = _positions[tokenId];
        require(_ownerOf[tokenId] != address(0), "no token");
        if (amount0 > 0) {
            require(IERC20(p.token0).transferFrom(msg.sender, address(this), amount0), "seed0");
            p.tokensOwed0 += amount0;
        }
        if (amount1 > 0) {
            require(IERC20(p.token1).transferFrom(msg.sender, address(this), amount1), "seed1");
            p.tokensOwed1 += amount1;
        }
    }

    function ownerOf(uint256 tokenId) external view returns (address) {
        address o = _ownerOf[tokenId];
        require(o != address(0), "no token");
        return o;
    }
}

