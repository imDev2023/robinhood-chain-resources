// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IStock {
    event Paused();
    event Unpaused();

    function initialize(bytes32 uid_, string calldata name_, string calldata symbol_) external;
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;
    function adminBurn(address from, uint256 amount) external;
    function uid() external view returns (bytes32);
    function terms() external pure returns (string memory);
}
