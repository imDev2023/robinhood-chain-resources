# Sentry - Guide, Trading & The Aggregator

> Source: https://www.sentry.trading/desktop/guide#trading-ink
> Retrieved: 2026-09-02 (Jina Reader)
> Raw capture: `_raw/jina/sentry-desktop-guide.md`

---

## Trading & The Aggregator[](https://www.sentry.trading/desktop/guide#trading-ink "Copy link to this section")

Sentry's swap engine is an aggregator. Every quote fans out across all live DEX venues on the active chain in parallel and executes on the single venue that returns the most output. Price impact is already reflected in the quote, because each quote is a real simulation against live pool state.

## Venues quoted per chain

*   **Robinhood Chain (4663), four venues:** canonical **Uniswap V3** (all four fee tiers: 0.01% / 0.05% / 0.3% / 1%), **Uniswap V2** (live pair reserves), **Uniswap v4** (Sentry launch pools — WETH-paired and stock-paired — plus the Doppler hook pools where Bankr-launched tokens trade), and **PancakeSwap V3** (0.01% / 0.05% / 0.25% / 1%). Stock-paired tokens quote through the multihop route automatically (ETH → USDG → stock → token and back), so they buy and sell with ETH like any other coin.
*   **Ink (57073):****Uniswap V3** (the governance-recognized deployment on Ink), fanning across every live fee tier (0.01% up to 5%). Every Sentry-launched Ink pool was migrated here in August 2026; the liquidity stayed locked throughout and moved at the same price. Trading on Ink is also routable through Relay, so you can buy these tokens with ETH from any supported chain.

The winning venue is shown alongside the quote. Because the fan-out compares every pool a token trades in, you automatically get the deepest pool's pricing and the lowest realistic price impact without picking a venue yourself.

## Anatomy of the swap form

*   **You Pay** — the input. Defaults to ETH. Tap `MAX` to pull your full balance minus a small gas reserve (0.0005 ETH), or use a quick-buy preset.
*   **You Receive** — pick any token from the picker, or paste any contract address to resolve a token on-chain, even one never launched through Sentry.
*   **Quote details** — appears once you've typed an amount. Shows minimum received (after slippage), your slippage tolerance, and the venue/fee tier the aggregator picked.
*   **Slippage** — defaults to 1%. Tap the value to switch between 0.5% / 1% / 3%. “Minimum received” is the quoted output minus your tolerance; if the pool can't deliver at least that at execution, the transaction reverts and nothing is traded.
*   **USD or token input** — flip the input denomination in `Settings`>`Swap input`.

## Quick-buy presets

On the BUY direction, four chips appear under the You-Pay field: `0.05 ETH`, `0.1 ETH`, `0.5 ETH`, `1 ETH`. Tap one to drop that amount into the input.

## Sells

Flip the direction with the arrow button. The first sell of any token requires a one-time on-chain approval (the router needs permission to pull tokens from your wallet); the app handles this transparently. You'll see “Approving token…” before the swap kicks off. Sells to ETH always unwrap WETH, so you receive native ETH with no leftover WETH balance.

## Bankr and other launchpads' tokens

Sentry lists and trades tokens from other launchpads too. On Robinhood Chain, **Bankr** tokens (which trade in Uniswap v4 Doppler pools) appear in the tokens grid with a launchpad badge and route through Sentry's v4 router with the same 1% fee. They are tradeable through Sentry, not launched by it, so their launch mechanics are Bankr's own.

## Guest swaps: no account needed

[sentry.trading/swap](https://www.sentry.trading/swap) is a standalone swap page that works without a Sentry account, using your own browser wallet (MetaMask, Rabby, any injected wallet). Connect, pick a chain and token, and swap; gas comes from your connected wallet and the same 1% platform fee applies. The URL updates live as you pick tokens (`/swap?chain=robinhood&token=0x…`), so you can share a link that drops someone straight into a preloaded swap. Token pages have a Share button that produces the same kind of deep link.
