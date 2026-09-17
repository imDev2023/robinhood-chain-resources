<!-- source: https://developers.uniswap.org/docs/protocols/v4-hooks/dualpool/guides/provide-liquidity | captured: 2026-08-22 | via: https://developers.uniswap.org/docs/protocols/v4-hooks/dualpool/guides/provide-liquidity.md (native markdown) -->
# Provide Liquidity (/docs/protocols/v4-hooks/dualpool/guides/provide-liquidity)

Deposit into and withdraw from DualPool pools using the hook's share-based liquidity functions.

## Context
Liquidity provision in DualPool goes through the hook, not the v4 [`PositionManager`](https://github.com/Uniswap/v4-periphery/blob/main/src/PositionManager.sol); direct v4 liquidity operations on a DualPool are blocked by the hook's permissions. Deposits mint internal, non-transferable [pool shares](/docs/protocols/v4-hooks/dualpool/concepts/lp-shares) that represent a proportional claim on the pool's total assets, and can earn both swap fees and vault yield with no further action.

This guide covers checking deposit eligibility, depositing, reading a position, withdrawing, and claiming rewards on incentivized pools.

## 1. Check the Pool Accepts Deposits
[`addLiquidity`](https://github.com/Uniswap/v4-hooks-public/blob/main/src/alf/DualPoolHook.sol#L409) is owner-only unless the pool's operator has enabled external deposits:

```solidity
bool open = hook.externalDepositsEnabled(poolId);
bool live = hook.livePools(poolId);
```

A pool must also be bootstrapped (live) before third-party deposits are possible.

## 2. Preview the Deposit
DualPool's LP interface is share-denominated: you request a number of shares to mint, and the hook pulls token amounts proportional to current total assets. Preview the token cost first:

```solidity
(uint256 amount0, uint256 amount1) = hook.previewDeposit(key, sharesToMint);
```

Deposits round up, so the executed amounts can differ slightly from a stale preview if total assets move (a swap, or vault yield accruing) between preview and execution.

## 3. Approve the Tokens
The hook pulls tokens with `transferFrom`, so approve the hook on both currencies:

```solidity
IERC20(token0).approve(address(hook), amount0Max);
IERC20(token1).approve(address(hook), amount1Max);
```

> [!NOTE]
> Some tokens (e.g. USDT) require resetting a non-zero allowance to zero before setting a new one. Use a max-style approval or a force-approve helper.

## 4. Add Liquidity
```solidity
(uint256 amount0, uint256 amount1) = hook.addLiquidity(
    key,
    sharesToMint,
    maxAmount0,      // slippage bound on token0
    maxAmount1,      // slippage bound on token1
    deadline         // unix timestamp
);
```

`maxAmount0`/`maxAmount1` bound how many tokens the deposit may pull; if the pool ratio moves against you past those bounds, the call reverts with `SlippageExceeded`. Expired deadlines revert with `DeadlineExpired`.

> [!NOTE]
> Fee-on-transfer and rebasing tokens are unsupported. If the hook receives fewer tokens than requested, the deposit reverts with `TransferReceiptShortfall`.

## 5. Read Your Position
```solidity
uint256 shares = hook.sharesOf(key, account);
uint256 supply = hook.totalShares(poolId);
(uint256 total0, uint256 total1) = hook.totalAssets(key);
(uint256 out0, uint256 out1) = hook.previewWithdraw(key, shares);
```

[`previewWithdraw`](https://github.com/Uniswap/v4-hooks-public/blob/main/src/alf/base/PoolVault.sol#L298) applies the exact [virtual-shares conversion](/docs/protocols/v4-hooks/dualpool/concepts/lp-shares) the contract uses, including rounding, so prefer it over recomputing pro-rata amounts offchain.

## 6. Remove Liquidity
```solidity
(uint256 amount0, uint256 amount1) = hook.removeLiquidity(
    key,
    sharesToBurn,
    minAmount0,      // slippage bound on token0
    minAmount1,      // slippage bound on token1
    deadline
);
```

Withdrawals round down and enforce `minAmount0`/`minAmount1` after transfer. Internally, the hook first redeems any pending ERC-6909 claims through a [`PoolManager`](https://github.com/Uniswap/v4-core/blob/main/src/PoolManager.sol) unlock, so you can exit even when post-swap balances sit in claims rather than in the vault.

Two timing rules to be aware of:

* **Deposit lock**: if the pool was configured with `minDepositBlocks > 0`, withdrawals revert with `DepositLocked` until that many blocks have passed since your last deposit
* **JIT cycles**: LP entry points revert with `JITInProgress` if called while any swap's JIT cycle is in flight on the hook (only possible from a contract executing within a swap transaction)

## Claim Rewards (Incentivized Pools)
Pools deployed on [`DualPoolIncentivizedHook`](https://github.com/Uniswap/v4-hooks-public/blob/main/src/alf/DualPoolIncentivizedHook.sol) additionally stream a per-pool reward token to shareholders, Synthetix-style, on a per-block schedule:

```solidity
uint256 pending = hook.earned(key, account);
uint256 claimed = hook.claimRewards(key);
```

Reward accrual checkpoints on share changes (deposits and withdrawals), never on swaps, so claiming does not interact with the swap path.

## Where to Go Next
* [Understand what backs your shares, and why reserves and immediately-withdrawable assets can differ](/docs/protocols/v4-hooks/dualpool/concepts/inventory-and-yield)
* [Learn how LP share accounting works](/docs/protocols/v4-hooks/dualpool/concepts/lp-shares)
