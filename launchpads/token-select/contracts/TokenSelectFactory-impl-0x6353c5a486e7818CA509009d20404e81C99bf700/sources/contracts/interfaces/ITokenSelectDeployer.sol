//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./ITokenSelectToken.sol";

interface ITokenSelectDeployer {

    error OnlyFactory();
    error InvalidFactory();

    function deployToken(
        ITokenSelectToken.ConstructorParams memory constructorParams
    ) external returns (address tokenAddress);

}