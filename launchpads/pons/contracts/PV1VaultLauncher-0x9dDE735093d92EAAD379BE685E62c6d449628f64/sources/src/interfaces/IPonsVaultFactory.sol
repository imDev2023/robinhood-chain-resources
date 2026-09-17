// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title IPonsVaultFactory
/// @notice The one thing every vault template's factory must look like.
///
/// @dev Config travels as opaque `bytes` so the launcher never has to know a template's
///      parameters. That is the whole point: a typed argument per template would mean a new
///      launcher function, a new launcher address, and a migration every time a template ships.
///      Each factory decodes and validates its own struct, so a malformed config still reverts —
///      it just reverts inside the factory that understands it rather than at the launcher.
interface IPonsVaultFactory {
    /// @notice Deploy a vault of this factory's template for `token`.
    /// @dev Must revert unless the caller is the token's on-chain `deployer`: only they can point
    ///      the locker's fee redirect at the resulting vault, so deploying for anyone else's token
    ///      would strand it. The caller also becomes the vault's fee collector.
    /// @param token The pons token to attach the vault to.
    /// @param locker The pons locker custodying that token's LP position.
    /// @param config ABI-encoded template parameters, fixed for the vault's lifetime.
    function createVault(address token, address locker, bytes calldata config)
        external
        returns (address vault);

    /// @notice Vault this factory deployed for `token`, or the zero address if none.
    function vaultOf(address token) external view returns (address);

    /// @notice Stable identifier for the template this factory produces.
    function template() external pure returns (string memory);
}
