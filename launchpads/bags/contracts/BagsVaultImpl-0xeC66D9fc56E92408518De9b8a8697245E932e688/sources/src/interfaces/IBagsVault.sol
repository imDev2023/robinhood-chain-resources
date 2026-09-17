// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.26;

/// @title IBagsVault
/// @notice Interface for the Bags platform vault
/// @author Bags
interface IBagsVault {
    /// @notice Emitted when the vault receives native (ETH)
    /// @param from Sender address
    /// @param amount Amount received
    event Received(address indexed from, uint256 amount);
    /// @notice Emitted when native (ETH) is withdrawn
    /// @param to Recipient address
    /// @param amount Amount withdrawn
    event Withdrawn(address indexed to, uint256 amount);
    /// @notice Emitted when ERC20 tokens are withdrawn
    /// @param token Token address
    /// @param to Recipient address
    /// @param amount Amount withdrawn
    event TokenWithdrawn(address indexed token, address indexed to, uint256 amount);

    /// @notice Zero address for recipient
    error BagsVault_ZeroAddressTo();
    /// @notice Native transfer failed
    error BagsVault_NativeTransferFailed(address to, uint256 amount);

    /// @notice Withdraw native (ETH) from the vault
    /// @param to Recipient of the native amount
    /// @param amount Amount of native to withdraw
    function withdraw(
        address payable to,
        uint256 amount
    ) external;
    /// @notice Withdraw ERC20 tokens from the vault
    /// @param token ERC20 token address
    /// @param to Recipient of the tokens
    /// @param amount Amount of tokens to withdraw
    function withdrawToken(
        address token,
        address to,
        uint256 amount
    ) external;
    /// @notice Current native (ETH) balance of the vault
    /// @return nativeBalance Current native balance
    function balance() external view returns (uint256 nativeBalance);
}
