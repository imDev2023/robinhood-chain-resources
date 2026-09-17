// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.26;

// OpenZeppelin
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// Local interfaces
import {IBagsVault} from "src/interfaces/IBagsVault.sol";

/// @title BagsVault
/// @notice Platform treasury: collects native (ETH) fees from bonding curves, the factory, and the
///         shared hook. Owner can withdraw native and tokens.
/// @author Bags
contract BagsVault is Ownable, IBagsVault {
    using SafeERC20 for IERC20;

    /// @notice Creates the vault with a designated owner
    /// @param initialOwner Owner of the vault (bags authority)
    constructor(
        address initialOwner
    ) Ownable(initialOwner) {}

    /// @notice Receive hook for native transfers
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    /// @notice Withdraw native (ETH) from the vault
    /// @param to Recipient of the native amount
    /// @param amount Amount of native to withdraw
    function withdraw(
        address payable to,
        uint256 amount
    ) external override onlyOwner {
        if (to == address(0)) revert BagsVault_ZeroAddressTo();
        (bool ok,) = to.call{value: amount}("");
        if (!ok) revert BagsVault_NativeTransferFailed(to, amount);
        emit Withdrawn(to, amount);
    }

    /// @notice Withdraw ERC20 tokens from the vault
    /// @param token ERC20 token address
    /// @param to Recipient of the tokens
    /// @param amount Amount of tokens to withdraw
    function withdrawToken(
        address token,
        address to,
        uint256 amount
    ) external override onlyOwner {
        if (to == address(0)) revert BagsVault_ZeroAddressTo();
        IERC20(token).safeTransfer(to, amount);
        emit TokenWithdrawn(token, to, amount);
    }

    /// @notice Current native (ETH) balance of the vault
    /// @return nativeBalance Current native balance
    function balance() external view override returns (uint256 nativeBalance) {
        return address(this).balance;
    }
}
