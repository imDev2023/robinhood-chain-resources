<!-- source: https://developers.uniswap.org/docs/protocols/v4-hooks/dualpool/concepts/inventory-and-yield | captured: 2026-08-22 | via: https://developers.uniswap.org/docs/protocols/v4-hooks/dualpool/concepts/inventory-and-yield.md (native markdown) -->
# Inventory and Yield (/docs/protocols/v4-hooks/dualpool/concepts/inventory-and-yield)

Learn how DualPool tracks pool inventory across vault shares, ERC-6909 claims, and raw ERC-20 balances.

Between swaps, a DualPool's capital does not sit in the Uniswap v4 [`PoolManager`](https://github.com/Uniswap/v4-core/blob/main/src/PoolManager.sol). For every `(PoolId, Currency)` pair, the hook maintains a pool-local ledger with three legs:

* **[ERC-4626](https://eips.ethereum.org/EIPS/eip-4626) vault shares**: the rest state. Idle capital is deposited into the pool's configured vault and earns lending yield continuously.
* **ERC-6909 claims**: tokens owed to the hook by the `PoolManager`, held as [ERC-6909](/docs/protocols/v4/concepts/erc-6909) claim tokens. A short-lived settlement buffer (see below).
* **Raw ERC-20**: token balances held by the hook and attributed to the pool, typically only transiently during a JIT cycle.

The hook never treats its global token balance as pool ownership. Many pools can share the same currency on one hook, so all accounting flows through per-pool mappings. Claims minted for one pool cannot be redeemed into another pool's ledger.

## Why Claims Exist
After a swap, the hook may be owed tokens by the `PoolManager`, but it cannot always take ERC-20 immediately, because the swapper settles their side of the swap *after* `afterSwap` runs. Instead, the hook mints ERC-6909 claims to itself and records them in the pool's ledger.

At the start of the next JIT deployment, the hook burns those claims and takes the underlying ERC-20, crediting the pool's tracked balance. [`removeLiquidity`](https://github.com/Uniswap/v4-hooks-public/blob/main/src/alf/DualPoolHook.sol#L437) also redeems claims before withdrawal math runs, so LPs can exit even when post-swap balances sit in claims.

> [!NOTE]
> **Claims earn no yield**
>
> Incoming swap tokens lag one cycle as claims. Under sustained one-way flow, a meaningful fraction of pool inventory can sit in claims rather than in the vault until an opposing-direction swap or LP action sweeps it back. Interfaces displaying pool inventory should show the claims leg distinctly.

## Reserves vs. Effective Liquidity
DualPool exposes two views of pool inventory, and the distinction matters:

* [`getReserves(key)`](https://github.com/Uniswap/v4-hooks-public/blob/main/src/alf/DualPoolHook.sol#L584) returns **total economic assets**: `vault.convertToAssets(poolShares)` + claims + tracked ERC-20. This is what LPs own.
* [`getEffectiveLiquidity(key)`](https://github.com/Uniswap/v4-hooks-public/blob/main/src/alf/DualPoolHook.sol#L594) returns **immediately deployable assets**: `vault.previewRedeem(poolShares)` + claims + tracked ERC-20. This is what the hook can withdraw and put to work right now.

LP share math uses total assets, so LPs retain their full economic claim even when a vault is temporarily illiquid. JIT deployment and the quote views use effective assets, so routing only ever sees what the hook can realistically source this block.

When the configured vault is paused, capped, or utilization-constrained, `getEffectiveLiquidity` falls below `getReserves`. Swaps larger than effective liquidity fill less, or revert on the vault withdrawal.

> [!NOTE]
> `previewRedeem` is used instead of `maxWithdraw` because curated vaults (e.g. Morpho VaultV2) often return `0` from `maxWithdraw` by design while still reporting meaningful per-share exit value.

## Yield Accrual
Vault yield accrues to the pool automatically: as the vault's share price rises, the same vault-share balance converts to more underlying tokens. This has two visible effects:

* LP positions appreciate without any pool activity, since share conversion is based on total assets
* The JIT curve deepens as yield accrues, so quotes for identical inputs improve over time

There is no harvest step and no separate yield token. Yield is realized whenever the hook withdraws from the vault, during a JIT cycle or an LP exit.

## Vault Requirements
Configured vaults must satisfy strict requirements, enforced at pool initialization:

* `vault.asset()` must equal the pool currency
* The vault must be feeless: `previewDeposit == convertToShares` and `previewRedeem == convertToAssets`. Entry or exit fees would bleed LPs on every JIT round-trip and break share math
* The vault receives a standing max token allowance from the hook, so operators must choose vaults whose governance and upgrade risk they accept

## Where to Go Next
* [Understand how LP positions are denominated against this inventory](/docs/protocols/v4-hooks/dualpool/concepts/lp-shares)
* [Size router fills against effective liquidity](/docs/protocols/v4-hooks/dualpool/guides/router-integration)
