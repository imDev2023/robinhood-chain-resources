// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IPonsLaunchpad {
    struct Socials {
        string twitter;
        string telegram;
        string discord;
        string website;
        string farcaster;
    }

    struct TokenMetadata {
        string name;
        string symbol;
        string logo;
        string description;
        Socials socials;
        address feeWallet;
    }

    function launchToken(TokenMetadata calldata metadata, uint256 launchConfigId, uint256 dexId, bytes32 salt)
        external
        payable
        returns (address token);

    function launchFee() external view returns (uint256);

    function launchEnabled() external view returns (bool);
}

/// @dev Only `deployer()` is safe to rely on across pons token generations. Tokens from the current
///      factory do not expose a `locker()` getter, so the locker must be supplied out of band.
interface IPonsToken {
    function deployer() external view returns (address);
}

/// @notice Permissionless sweep of a token's pending pons creator fees into its vault.
/// @dev Implemented by {PonsVaultLauncher}. Needed because the locker only accepts
///      `collectFees` from the token's `deployer` (or pons's own protocol fee recipient),
///      so the launcher that performed the launch is the party that can sweep.
interface IPonsFeeCollector {
    function collect(address token) external returns (uint256 amount0, uint256 amount1);
}
