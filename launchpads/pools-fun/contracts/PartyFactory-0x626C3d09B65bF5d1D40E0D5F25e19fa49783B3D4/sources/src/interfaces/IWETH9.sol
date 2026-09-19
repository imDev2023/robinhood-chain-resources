// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @notice Wrapped native token (WETH9) interface with deposit/withdraw.
interface IWETH9 is IERC20 {
    function deposit() external payable;

    function withdraw(uint256 amount) external;
}
