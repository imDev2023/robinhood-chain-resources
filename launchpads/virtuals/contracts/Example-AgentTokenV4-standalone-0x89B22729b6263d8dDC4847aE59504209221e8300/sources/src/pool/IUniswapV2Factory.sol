// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @dev Interface standard de la factory Uniswap V2 (crée et référence les paires).
interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    /// @notice Renvoie la paire tokenA/tokenB, ou address(0) si elle n'existe pas encore.
    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    /// @notice Déploie la paire tokenA/tokenB (déterministe via CREATE2).
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}
