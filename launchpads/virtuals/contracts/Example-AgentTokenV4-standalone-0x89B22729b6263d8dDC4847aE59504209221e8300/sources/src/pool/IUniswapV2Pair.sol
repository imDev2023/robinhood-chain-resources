// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @dev Interface (partielle) d'une paire Uniswap V2 : le pool de liquidité lui-même.
interface IUniswapV2Pair {
    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    /**
     * @notice Frappe les LP tokens après qu'on a transféré les deux tokens à la
     * paire. C'est le chemin "bas niveau" que _addInitialLiquidity utilise
     * (transfert direct + mint) au lieu de passer par le routeur.
     */
    function mint(address to) external returns (uint256 liquidity);

    function burn(
        address to
    ) external returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function sync() external;
}
