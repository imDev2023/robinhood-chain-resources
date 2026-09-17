# Sentry - Guide, Tokenized Stocks as Base Pairs

> Source: https://www.sentry.trading/desktop/guide#stock-pairs
> Retrieved: 2026-09-02 (Jina Reader)
> Raw capture: `_raw/jina/sentry-desktop-guide.md`

---

## Tokenized Stocks as Base Pairs[](https://www.sentry.trading/desktop/guide#stock-pairs "Copy link to this section")

On Robinhood Chain and Ink you can launch a token paired against a tokenized stock instead of ETH. On Robinhood that is a Robinhood-issued stock; on Ink it is a Backed wrapped xStock (wNVDAx, wAAPLx, …). Your coin trades directly against that stock, and holders earn it as a reflection on every trade. Buyers can still pay with ETH — the router hops through USDG into the wrapper.

## What a stock-paired launch is

A normal Sentry launch pairs your token against ETH. A stock-paired launch instead pairs it against one of the tokenized stocks that live on Robinhood Chain (Apple, Netflix, Nvidia, and roughly a hundred others). The stock becomes the **base asset** of your pool: the thing your token is priced in and traded against. Everything else about a Sentry launch is unchanged: fixed 1 billion supply, contract renounced, 100% of supply locked as single-sided liquidity that the factory holds forever.

## How to launch one

1.   On Robinhood Chain, open **Create** and choose the**Stock Base Pair** launch type.
2.   Pick the base stock from the list. Each entry shows the company logo, name, ticker, and contract address. Every entry is verified on-chain as a genuine Robinhood issuance, and the list is limited to stocks with a real, liquid on-chain market (about twenty megacaps and ETFs — AAPL, NVDA, TSLA, META, SPY, QQQ and friends) so that every launch is actually tradeable with ETH. Stocks whose pools can't fill trades at a fair price are excluded automatically until Robinhood deepens them.
3.   Name your token and launch. Your token deploys, its pool against the chosen stock is created, and the full supply is locked as liquidity in the same transaction.

## The fees, and who earns what

Every trade in a stock-paired pool pays the launch fee curve (40% decaying to the permanent 1.7% floor — see [Anti-Snipe Protection](https://www.sentry.trading/desktop/guide#anti-snipe)), and all of it is denominated **in the base stock**. So creators are paid in the stock, and holders earn the stock. Once the pool is at the floor, every trade splits like this:

| Leg | Share of the fee | At the 1.7% floor | Goes to |
| --- | --- | --- | --- |
| **Holder reflections** | ~47% | 0.8% of the trade | All holders, pro-rata, in the base stock — claimable from the token contract any time |
| **Creator** | ~29% | 0.5% of the trade | The creator's fee wallet, paid within the swap itself — nothing to claim |
| **Liquidity reinvest** | ~12% | 0.2% of the trade | Compounded into permanently locked full-range liquidity — the pool gets deeper with every trade |
| **Treasury** | ~12% | 0.2% of the trade | The Sentry treasury splitter (60% operations, 40% into locked SENTRY liquidity) |

## Stock reflections for holders

Holding a stock-paired token earns you the base stock. On every buy and sell, just under half of the pool fee (0.8% of the trade at the permanent floor) is set aside in the stock and attributed to holders in proportion to how much of the token they hold at that moment. It accrues continuously and survives transfers. You claim your accrued stock directly from the token's contract whenever you want. This is real, on-chain, and automatic: there is no snapshot to catch and no team distributing manually.

## Buying and selling with ETH

You do not need to hold the base stock to trade a stock-paired token. When you buy with ETH, Sentry routes it for you in a single transaction:

`ETH → USDG → base stock → your token`

You send ETH and receive the token; the stock leg happens inside the transaction and you never have to manage it. Selling works the same way in reverse: by default you receive **ETH** back (token → stock → USDG → ETH in one transaction), with a toggle to receive the base stock instead if you prefer to hold it. Both directions work in the in-app swap and on the public swap page at [sentry.trading/swap](https://www.sentry.trading/swap), and you can also pay with the base stock directly if you already hold it.

## Viewing and claiming your stock reflections

Your accrued stock is visible and claimable in two places, depending on how you hold the token:

1.   **In the app:** open the token's page. A **Reflections** card shows your claimable balance in the base stock (for example `0.0450 NFLX`) with a `Claim` button. One tap sends the stock straight to your wallet.
2.   **With a connected wallet on [sentry.trading/swap](https://www.sentry.trading/swap):** connect the wallet that holds the token and a reflections card appears under the swap form whenever you have something to claim. The claim is signed by your own wallet, directly against the token contract — Sentry never touches the funds.
3.   **After claiming:** the stock appears in your in-app wallet automatically, with its real logo and live USD value, like any other asset. You can hold it, LP it, or swap it.

## Ink: wrapped xStocks

On Ink the base asset is a **Backed wrapped xStock** (wNVDAx, wAAPLx, and six others) — an ERC-4626 wrapper over the raw rebasing xStock. Always pair and trade the wrapper, never the raw token. The launch factory is the same v4 proxy as WETH launches; ETH still works as the pay asset, but the hop is different:

`ETH → WETH → USDT0 → USDG → wrapped xStock → your token`

*   The Ink stock-pair floor is **2.00%**, not the 1.7% WETH / Robinhood-stock floor.
*   Creators on Ink are paid in **WETH** (the router peels 75% of the live curve before the v4 swap). Holders still earn the wrapper as reflections (the remaining 25%).
*   Direct `PoolManager.swap` on these pools reverts — the hook is router-gated. Integrators must use `SentryStockRouterInk`.

Addresses, ABIs, pool keys, and a quote/swap walkthrough live in [Ink xStocks (Developers)](https://www.sentry.trading/desktop/guide#ink-xstocks).

## Good to know

*   **Tokenized stocks are geo-restricted by Robinhood.** Access to the underlying stock tokens follows Robinhood's own regional rules. Sentry does not promote any way around those restrictions.
*   **The base stock is on Robinhood's rails.** Robinhood can pause a stock token or upgrade its logic; a paused stock would freeze its pools, and corporate actions like stock splits are handled by Robinhood, not by Sentry.
*   **Ink wrappers are Backed xStocks.** Backed can halt a wrapper or the underlying xStock; a halt would freeze the Foundation USDG book and any Sentry pool paired against that wrapper.
*   **Prices move fast.** A stock-paired token starts at a small market cap, so early trades move the price sharply in both directions.
