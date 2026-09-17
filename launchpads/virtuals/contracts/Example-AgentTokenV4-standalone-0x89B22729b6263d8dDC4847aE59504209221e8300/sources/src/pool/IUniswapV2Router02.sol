// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @dev Interface (partielle) du routeur Uniswap V2 (Router02).
interface IUniswapV2Router02 {
    /// @notice Adresse de la factory V2 associée au routeur.
    function factory() external pure returns (address);

    /// @notice Adresse du WETH canonique de la chaîne (utile comme pairToken).
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    /**
     * @dev Variante obligatoire pour les tokens à taxe (fee-on-transfer) :
     * elle ne présuppose pas le montant reçu par la paire.
     */
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);
}
