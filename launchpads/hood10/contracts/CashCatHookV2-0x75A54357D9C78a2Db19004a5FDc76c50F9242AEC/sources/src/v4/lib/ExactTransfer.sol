// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title ExactTransfer
/// @notice An ERC-20 payout that reverts unless the payer's balance fell by
///         exactly the amount being settled.
///
/// @dev    Each contract using this holds one balance of an asset against
///         several separate liabilities: a splitter's balance is owed to up to
///         four recipients, the hook's is owed to every pool's creator and to
///         the platform, a burner's backs each pool's unspent fuel. Those
///         liabilities are settled one at a time out of the shared balance,
///         which is sound only while moving `amount` reduces the balance by
///         `amount`.
///
///         `SafeERC20.safeTransfer` does not establish that. It establishes
///         that the call did not revert and did not return false. A token
///         debiting the payer more than the amount satisfies it, and the
///         difference is then taken from whoever is paid next out of the same
///         balance — so payout order would decide who goes unpaid.
///
///         The two ways a transfer can be inexact have different consequences,
///         and only one of them is refused here.
///
///         An excess debit removes more from the payer than the liability it
///         clears. The remaining balance no longer covers the remaining
///         liabilities. That is refused.
///
///         A short credit delivers less to the payee while the payer's balance
///         falls by exactly the liability cleared. Every other claim stays
///         fully backed, so the shortfall is confined to the payee. That is
///         allowed, and `delivered` reports it. Refusing it would strand every
///         unpaid claim on an asset that began taxing, since a payout that
///         reverts can never be retried into success. `CashCatHookV2._sweep`
///         resolves the inbound half the same way.
library ExactTransfer {
    using SafeERC20 for IERC20;

    /// @param debited what left the payer
    /// @param wanted  the liability being settled
    error InexactDebit(uint256 debited, uint256 wanted);
    /// @dev A payment to the payer nets to zero and cannot be verified.
    error SelfPayment();

    /// @notice Transfers `amount` to `to`, reverting unless the payer's
    ///         balance falls by exactly `amount`.
    /// @dev    Zero is a no-op: some tokens reject a zero-value transfer, and
    ///         there is nothing to verify about moving nothing.
    /// @return delivered what reached the payee, which is below `amount` for an
    ///         asset that taxes the recipient.
    function payExact(IERC20 token, address to, uint256 amount)
        internal
        returns (uint256 delivered)
    {
        if (amount == 0) return 0;
        if (to == address(this)) revert SelfPayment();

        uint256 fromBefore = token.balanceOf(address(this));
        uint256 toBefore = token.balanceOf(to);

        token.safeTransfer(to, amount);

        // A transfer cannot raise the sender's balance, so this cannot
        // underflow; a token that minted to itself mid-call fails the equality.
        uint256 debited = fromBefore - token.balanceOf(address(this));
        if (debited != amount) revert InexactDebit(debited, amount);

        uint256 held = token.balanceOf(to);
        delivered = held > toBefore ? held - toBefore : 0;
    }
}
