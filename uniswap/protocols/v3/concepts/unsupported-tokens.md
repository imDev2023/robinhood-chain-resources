<!-- source: https://developers.uniswap.org/docs/protocols/v3/concepts/unsupported-tokens | captured: 2026-08-22 | via: https://developers.uniswap.org/docs/protocols/v3/concepts/unsupported-tokens.md (native markdown) -->
# Token Integration Issues (/docs/protocols/v3/concepts/unsupported-tokens)

Understand Uniswap v3 token integration issues and how non-standard token behavior affects pool interactions.

Fee-on-transfer and rebasing tokens will not function correctly on v3.

## Fee-on-Transfer Tokens
Fee-on-transfer tokens will not function with our router contracts. As a workaround, the token creators may create a token wrapper or a customized router. We will not be making a router that supports fee-on-transfer tokens in the future.

## Rebasing Tokens
Rebasing tokens will succeed in pool creation and swapping, but liquidity providers will bear the loss of a negative rebase when their position becomes active, with no way to recover the loss.
