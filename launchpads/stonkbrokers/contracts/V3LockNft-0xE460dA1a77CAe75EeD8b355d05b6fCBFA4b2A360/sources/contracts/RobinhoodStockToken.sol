// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RobinhoodStockToken is ERC20, Ownable {
    address public minter;

    event MinterUpdated(address indexed newMinter);

    constructor(address initialOwner) ERC20("Robinhood Stock Token", "RHOOD") Ownable(initialOwner) {}

    function setMinter(address newMinter) external onlyOwner {
        require(newMinter != address(0), "minter=0");
        minter = newMinter;
        emit MinterUpdated(newMinter);
    }

    function mint(address to, uint256 amount) external {
        require(msg.sender == minter, "not minter");
        _mint(to, amount);
    }
}
