# Sentry - Guide, The SENTRY Token

> Source: https://www.sentry.trading/desktop/guide#sentry-token
> Retrieved: 2026-09-02 (Jina Reader)
> Raw capture: `_raw/jina/sentry-desktop-guide.md`

---

## The SENTRY Token[](https://www.sentry.trading/desktop/guide#sentry-token "Copy link to this section")

SENTRY is the platform's own token, trading against WETH in a Uniswap v4 pool on Robinhood Chain — and it's built as a flywheel: **every launch and every trade on the platform feeds SENTRY, and SENTRY pays its holders in WETH**.

## The token

*   **Contract:**`0x1EcA20cfa4AF2e2fA2F4CE2bF8d97bFa184FD4D7` — fixed 1 billion supply, renounced, verified on Blockscout.
*   **Distribution:** 10% treasury, 3% founder (publicly disclosed), 87% launched into the public WETH pool. Holders of the original SENTRY were migrated via airdrop at the relaunch (July 28, 2026).
*   **Liquidity:** permanently locked, same custody model as every Sentry launch — no withdrawal path, ever.

## Hold SENTRY, earn WETH

SENTRY runs on the same per-swap fee-hook architecture as the launchpad, tuned for holders. The pool fee decays from 40% at relaunch to a permanent **2% floor**, and every trade splits it three ways, settled inside the swap itself:

| Leg | Share of the fee | At the 2% floor | Goes to |
| --- | --- | --- | --- |
| **Holder reflections** | 37.5% | 0.75% of the trade | **WETH, to all SENTRY holders pro-rata** — claimable any time, no snapshots, no deadlines |
| **Liquidity compound** | 37.5% | 0.75% of the trade | Permanently locked SENTRY/WETH liquidity — the pool deepens with every trade |
| **Treasury** | 25% | 0.5% of the trade | The Sentry treasury |

Reflections use the same dividend-accounting standard as stock-paired launches: **zero transfer tax**, fully DEX-compatible, accrual proportional to your holdings at the moment of each trade. Your claimable WETH shows on the SENTRY token page in the app.

## The flywheel: the whole platform feeds the token

The protocol's share of _every launch's_ trading fees — every WETH launch, every stock launch, every sniped block-zero buy on any token — routes to the on-chain **Treasury Splitter**, which cuts it 60/40:

*   **60%** funds platform operations.
*   **40% market-buys SENTRY and mints permanently locked SENTRY liquidity.** WETH proceeds compound into locked SENTRY/WETH liquidity; stock-launch proceeds route through USDG and WETH into locked SENTRY/stock liquidity. Locked means locked — the splitter has no removal function.

The loop closes cleanly: platform volume creates protocol fees → 40% of those become permanent SENTRY buy pressure and ever-deeper locked liquidity → SENTRY's own trading volume pays holders WETH on every swap. More launches, more trading, more snipers taxed — all of it accrues to the token and its holders, structurally, on-chain, with nothing to claim on faith.
