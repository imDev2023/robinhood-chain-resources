// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IStockFactory {
    function deploy(bytes32 uid, string calldata name, string calldata symbol) external returns (address);
    function tokenAddress(bytes32 uid) external view returns (address);
}
