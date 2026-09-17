# Sentry - DefiLlama protocol record, slug `sentry`

> Source: https://api.llama.fi/protocol/sentry
> Retrieved: 2026-09-02 (curl)
> Raw capture: `_raw/api/defillama-protocol-sentry.json`

---

DefiLlama's description is out of date in two ways that matter: it describes only the Uniswap V3 generation, and it quotes the creator split as 65/35.
On chain on 2026-09-02 the Robinhood split is 70/30 (`creatorFeeBps() = 7000` on both live factories, on the legacy factory and on the LP vault), and the live generation is Uniswap v4 with per-swap settlement rather than V3 fee accrual.
DefiLlama also records zero audits and no public GitHub, which matches what could be found independently.

| field | value |
| --- | --- |
| id | 8155 |
| name | Sentry |
| category | Launchpad |
| chains | Ink, Robinhood Chain |
| twitter | sentrylauncher |
| audits | 0 |
| github | None |
| listed at | 1783448895 (unix) |
| current TVL, Robinhood Chain | $100229.04 |
| current TVL, Ink | $99269.4 |

## Description, verbatim

> Sentry is a token launchpad on Robinhood Chain: one-click ERC-20 launches with a Uniswap V3 pool seeded at launch and the LP position permanently locked in the factory. LP fees split 65/35 between the token creator and the protocol treasury.

## Methodology, verbatim

> TVL is the base-asset liquidity held in the pools created by the Sentry Launch Factory, across both live generations, on Robinhood Chain and Ink. v3 launches hold liquidity in a Uniswap V3 pool contract whose LP NFT is permanently locked in the factory, so the WETH balance of each pool is counted directly. v4 launches have no per-pool contract: funds sit in the Uniswap V4 PoolManager singleton and the position is owned by the factory or by the immutable SentryLPVault, so each position's base-asset reserve is derived from its liquidity, tick range and the pool's current price. Both WETH-paired and tokenized-stock-paired launches are included. The launched token's own side of the pair is excluded, since its only market is the pool being measured.
