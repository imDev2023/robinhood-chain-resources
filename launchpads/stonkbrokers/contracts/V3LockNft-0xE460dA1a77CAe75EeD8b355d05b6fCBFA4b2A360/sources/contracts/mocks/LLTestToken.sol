// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @notice Throwaway ERC-20 for locker battle tests (mintable by deployer).
contract LLTestToken is ERC20 {
    constructor() ERC20("Locker Lock Test", "LLTEST") {
        _mint(msg.sender, 1_000_000_000 ether);
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}
