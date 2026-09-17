# Flap - Registered vaults

> Source: https://docs.flap.sh/flap/developers/token-launcher-developers/registered-vaults
> Retrieved: 2026-09-02 (GitBook markdown export, https://docs.flap.sh/flap/developers/token-launcher-developers/registered-vaults.md)

---

> For the complete documentation index, see [llms.txt](https://docs.flap.sh/flap/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://docs.flap.sh/flap/developers/token-launcher-developers/registered-vaults.md).

# Registered vaults

## Registered vaults

This page lists registered vault factories and the expected `vaultData` schema for each factory.

### BNB mainnet

| name                    | description                                                                                                  | is official (yes/no) | vaultFactory address                       | vaultData schema description                                                                                                                                                                                                                                                                              | interface                                                                                                                                                        |
| ----------------------- | ------------------------------------------------------------------------------------------------------------ | -------------------- | ------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Split Vault             | Splits received BNB across up to 10 recipients based on basis points and allows dispatch/claim.              | yes                  | 0xfab75Dc774cB9B38b91749B8833360B46a52345F | ABI-encode `SplitVault.Recipient[]` where each item is `{address recipient, uint16 bps}`. `recipient` is the payout address (must be non-zero and unique across the array). `bps` is the share in basis points (1% = 100, 100% = 10,000). The array length must be 1-10 and total bps must sum to 10,000. | [misc/interfaces/vaults/SplitVault.sol](https://github.com/flap-sh/gitbook/tree/main/developers/token-launcher-developers/misc/interfaces/vaults/SplitVault.sol) |
| Gift Vault (FlapXVault) | A gift vault that routes tax token revenue based on X (Twitter) proof and can fall back to snowball buyback. | yes                  | 0x025549F52B03cF36f9e1a337c02d3AA7Af66ab32 | ABI-encode `VaultData` with `{string xHandle}` (the fee manager’s X handle). The `xHandle` must be all lowercase.                                                                                                                                                                                         | [Gift Vault Guide](/flap/developers/vault-developers/gift-vault.md)                                                                                              |

### BNB testnet

| name                    | description                                                                                                  | is official (yes/no) | vaultFactory address                       | vaultData schema description                                                                                                                                                                                                                                                                              | interface                                                                                                                                                        |
| ----------------------- | ------------------------------------------------------------------------------------------------------------ | -------------------- | ------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Split Vault             | Splits received BNB across up to 10 recipients based on basis points and allows dispatch/claim.              | yes                  | 0x1ae091F75D593eb7dC6539600a185C8A6076A424 | ABI-encode `SplitVault.Recipient[]` where each item is `{address recipient, uint16 bps}`. `recipient` is the payout address (must be non-zero and unique across the array). `bps` is the share in basis points (1% = 100, 100% = 10,000). The array length must be 1-10 and total bps must sum to 10,000. | [misc/interfaces/vaults/SplitVault.sol](https://github.com/flap-sh/gitbook/tree/main/developers/token-launcher-developers/misc/interfaces/vaults/SplitVault.sol) |
| Gift Vault (FlapXVault) | A gift vault that routes tax token revenue based on X (Twitter) proof and can fall back to snowball buyback. | yes                  | 0xa02DA44D67DB6D692efa7f751b5952bd670d5326 | ABI-encode `VaultData` with `{string xHandle}` (the fee manager’s X handle). The `xHandle` must be all lowercase.                                                                                                                                                                                         | [Gift Vault Guide](/flap/developers/vault-developers/gift-vault.md)                                                                                              |

## Interfaces

### Split Vault interface

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/// @title ISplitVault
/// @notice Interface for the Split Vault implementation.
/// @dev Derived from the on-chain SplitVault contract.
interface ISplitVault {
	/// @notice A payout recipient with a basis-point share.
	/// @param recipient The payout address (non-zero and unique).
	/// @param bps Share in basis points (1% = 100, 100% = 10,000).
	struct Recipient {
		address recipient;
		uint16 bps;
	}

	/// @notice Balance tracking for a recipient.
	/// @param accumulated Total BNB credited to the user.
	/// @param claimed Total BNB claimed by the user.
	struct UserBalance {
		uint128 accumulated;
		uint128 claimed;
	}

	/// @notice View structure returned by `getRecipientsInfo()`.
	/// @param recipient The payout address.
	/// @param bps Share in basis points.
	/// @param accumulated Total BNB credited to the user.
	/// @param claimed Total BNB claimed by the user.
	struct RecipientInfo {
		address recipient;
		uint16 bps;
		uint128 accumulated;
		uint128 claimed;
	}

	/// @notice Emitted when BNB is received and split across recipients.
	/// @param amount The total amount distributed.
	event FlapSplitVaultDistributed(uint256 amount);

	/// @notice Emitted when a recipient is dispatched funds.
	/// @param recipient The recipient address.
	/// @param amount The amount dispatched.
	event FlapSplitVaultDispatched(address recipient, uint256 amount);

	/// @notice Emitted when a recipient claims funds manually.
	/// @param user The recipient address.
	/// @param amount The amount claimed.
	event FlapSplitVaultClaimed(address user, uint256 amount);

	/// @notice Error when number of recipients exceeds the limit.
	error TooManyRecipients();

	/// @notice Error when the total basis points is not 10,000.
	error InvalidBpsSum();

	/// @notice Error when a recipient address is zero.
	error ZeroRecipient();

	/// @notice Error when no recipients are provided.
	error NoRecipients();

	/// @notice Error when recipients are duplicated.
	error DuplicateRecipient();

	/// @notice Initialize the vault after cloning.
	/// @param _taxToken The associated tax token address.
	/// @param _recipients Array of recipients and their shares.
	function initialize(address _taxToken, Recipient[] calldata _recipients) external;

	/// @notice Dispatch claimable balances to all recipients.
	function dispatch() external;

	/// @notice Claim the caller’s accumulated balance.
	/// @param user The recipient address to claim for.
	function claim(address user) external;

	/// @notice Return detailed information for all recipients.
	/// @return info Array of recipient info entries.
	function getRecipientsInfo() external view returns (RecipientInfo[] memory info);

	/// @notice Retrieve a recipient by index.
	/// @param index The recipient index.
	/// @return recipient The recipient address.
	/// @return bps The recipient share in basis points.
	function recipients(uint256 index) external view returns (address recipient, uint16 bps);

	/// @notice Retrieve user balance totals for a recipient.
	/// @param user The recipient address.
	/// @return accumulated Total BNB credited to the user.
	/// @return claimed Total BNB claimed by the user.
	function userBalances(address user) external view returns (uint128 accumulated, uint128 claimed);

	/// @notice The associated tax token address.
	function taxToken() external view returns (address);

	/// @notice The factory address that created this vault.
	function factory() external view returns (address);

	/// @notice The total basis points constant (10,000).
	function TOTAL_BPS() external view returns (uint256);
}
```

### Gift Vault (FlapXVault) interface

For detailed API integration guide and the complete interface, see the [Gift Vault Guide](/flap/developers/vault-developers/gift-vault.md).
