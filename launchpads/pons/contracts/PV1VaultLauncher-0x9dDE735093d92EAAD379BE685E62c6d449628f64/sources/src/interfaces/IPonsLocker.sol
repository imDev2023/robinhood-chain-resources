// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title IPonsLocker
/// @notice Minimal interface for the pons launchpad locker, which custodies each launch's
///         Uniswap V3 LP position and routes collected fees.
/// @dev The locker is unverified on Blockscout; this interface was derived from the ABI the
///      pons frontend uses plus on-chain probing of the deployed contract.
///
///      Access control observed on `collectFees`: the caller must be either the token's
///      `deployer()` or the configured `feeRedirects(token)` address, otherwise it reverts
///      with `NotAuthorized()` (0xea8e4eb5). Payout goes to `feeRedirects(token)` when set,
///      and to `deployer()` when it is the zero address. The protocol share defined by
///      `tokenProtocolFeeShares(token)` is deducted first and sent to `protocolFeeRecipient()`.
///
///      `setFeeRedirect` is restricted to the token deployer, reverting with `NotDeployer()`
///      (0x8b906c97) for anyone else. It accepts a contract address, which is what allows a
///      vault to become the fee claimant.
interface IPonsLocker {
    /// @notice Collect accrued LP fees for `token` and forward the creator share to the claimant.
    /// @dev Fees arrive as ERC-20 transfers (WETH and/or the token itself), never as native ETH.
    /// @param token The pons token whose LP position should be swept.
    /// @return amount0 Amount of pool token0 collected.
    /// @return amount1 Amount of pool token1 collected.
    function collectFees(address token) external returns (uint256 amount0, uint256 amount1);

    /// @notice Redirect a token's creator fees to another address. Deployer only.
    function setFeeRedirect(address token, address newFeeWallet) external;

    /// @notice Current fee redirect target for `token`, or the zero address when unset.
    function feeRedirects(address token) external view returns (address);

    /// @notice Protocol fee share for `token`, expressed as a whole percentage.
    function tokenProtocolFeeShares(address token) external view returns (uint256);

    /// @notice Address receiving the protocol share of collected fees.
    function protocolFeeRecipient() external view returns (address);
}
