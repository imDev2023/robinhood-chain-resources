<!-- source: https://developers.uniswap.org/docs/protocols/v4-hooks/dualpool/concepts/jit-liquidity | captured: 2026-08-22 | via: https://developers.uniswap.org/docs/protocols/v4-hooks/dualpool/concepts/jit-liquidity.md (native markdown) -->
# Just-in-Time Liquidity (/docs/protocols/v4-hooks/dualpool/concepts/jit-liquidity)

Understand how DualPool deploys concentrated liquidity per swap and holds none between swaps.

A DualPool holds approximately zero resident liquidity in the Uniswap v4 [`PoolManager`](https://github.com/Uniswap/v4-core/blob/main/src/PoolManager.sol) between swaps. Instead, the pool's capital rests in [ERC-4626](https://eips.ethereum.org/EIPS/eip-4626) vaults, and the hook deploys concentrated liquidity just-in-time (JIT), inside `beforeSwap` and for exactly one swap, then removes it again in `afterSwap`.

The lifecycle of every swap is:

1. **Rest state**: the hook holds vault shares (plus any tracked ERC-20 and ERC-6909 claims). Capital earns lending yield continuously. The v4 pool itself holds no liquidity.
2. **`beforeSwap`**: the hook computes how much of each token its configured tick ranges need at the current price, redeems any pending ERC-6909 claims, withdraws only the remaining shortfall from the vaults, and adds one v4 position per [distribution bucket](/docs/protocols/v4-hooks/dualpool/concepts/liquidity-distributions).
3. **Swap execution**: the `PoolManager` executes ordinary v4 swap math against the temporary positions and charges the pool's static `key.fee` natively.
4. **`afterSwap`**: the hook removes every position it added, settles its net deltas with the `PoolManager`, and deposits remaining balances back into the vaults.

All four steps happen atomically within the swap transaction. The swapper sees a normal swap and a normal `BalanceDelta`.

> [!NOTE]
> Because standing liquidity is \~0, onchain pool depth is not a routing signal for DualPool. Capacity is discovered through the hook's view functions; see [Integrate as a Router or Aggregator](/docs/protocols/v4-hooks/dualpool/guides/router-integration).

## Hook Permissions
DualPool declares five hook permissions:

| Permission              | Purpose                                                                                                                                                                             |
| ----------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `beforeInitialize`      | Blocks direct `PoolManager` initialization, so pools must be created through [`initializePool`](https://github.com/Uniswap/v4-hooks-public/blob/main/src/alf/DualPoolHook.sol#L292) |
| `beforeAddLiquidity`    | Blocks external LP positions; only the hook adds positions, during JIT deployment                                                                                                   |
| `beforeRemoveLiquidity` | Blocks external LP removals; only the hook removes its JIT positions                                                                                                                |
| `beforeSwap`            | Deploys JIT liquidity                                                                                                                                                               |
| `afterSwap`             | Removes JIT liquidity, settles deltas, and re-deposits into vaults                                                                                                                  |

All return-delta flags are false. DualPool does not use `BeforeSwapDelta` or custom accounting to synthesize execution: it lets normal v4 swap math run against temporarily deployed liquidity while v4 applies `key.fee` natively.

## Static Fee
DualPool pools use a static LP fee, fixed at pool creation via `PoolKey.fee` and never updated by the hook:

* Dynamic-fee pools are rejected at initialization with `DynamicFeeNotSupported`
* `hookData` is ignored by `beforeSwap` and by the quote views, so it cannot change pricing or fees
* To change the fee, the operator deploys a new pool with a different `PoolKey.fee`

Any v4 protocol fee is composed with the LP fee automatically, so quotes already reflect both.

## Liveness
A newly initialized pool is not live. Swaps revert with `PoolNotLive` until the owner calls [`bootstrap`](https://github.com/Uniswap/v4-hooks-public/blob/main/src/alf/DualPoolHook.sol#L377), which seeds the first deposit and flips the pool live. This closes the window between initialization and funding where a swap could move the pool price against zero liquidity.

The owner can pause and resume a live pool with [`setPoolLive`](https://github.com/Uniswap/v4-hooks-public/blob/main/src/alf/DualPoolHook.sol#L578). While paused, swaps revert `PoolNotLive` and the quote views return `0`.

## Transient State
The hook records each deployed position's liquidity in [transient storage](https://eips.ethereum.org/EIPS/eip-1153) during `beforeSwap` so that `afterSwap` removes exactly what was added. A per-pool JIT lock and a global in-flight counter, both also transient, reject reentrant swaps and block LP or admin calls while any JIT cycle is active. Nothing survives past the transaction.

## Where to Go Next
* [See where capital sits between swaps and how it is accounted](/docs/protocols/v4-hooks/dualpool/concepts/inventory-and-yield)
* [Execute a swap against a DualPool](/docs/protocols/v4-hooks/dualpool/guides/swap)
