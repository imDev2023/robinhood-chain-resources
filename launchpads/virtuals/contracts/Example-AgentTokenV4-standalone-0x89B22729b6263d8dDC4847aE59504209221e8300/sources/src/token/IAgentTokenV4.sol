// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IAgentTokenV2.sol";

/**
 * @title IAgentTokenV4
 * @dev Étend la V2 avec le "tax accounting adapter" : le contrat qui reçoit les
 * tokens de taxe accumulés, les swap en pairToken via Uniswap V2, puis les
 * comptabilise/dépose. Peut être address(0) → l'autoswap est simplement ignoré.
 */
interface IAgentTokenV4 is IAgentTokenV2 {
    event TaxAccountingAdapterUpdated(address newAdapter);

    /**
     * @notice Initialise le token (appelable UNE seule fois, sur un clone/proxy).
     *
     * @param integrationAddresses_ [0] = owner du contrat (ton wallet),
     *                              [1] = routeur Uniswap V2,
     *                              [2] = pairToken (le token contre lequel on trade)
     * @param baseParams_   abi.encode(string name, string symbol)
     * @param supplyParams_ abi.encode(ERC20SupplyParameters)
     * @param taxParams_    abi.encode(ERC20TaxParameters)
     * @param taxAccountingAdapter_ Adapter d'autoswap (address(0) = désactivé)
     */
    function initialize(
        address[3] memory integrationAddresses_,
        bytes memory baseParams_,
        bytes memory supplyParams_,
        bytes memory taxParams_,
        address taxAccountingAdapter_
    ) external;
}
