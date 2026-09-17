# Sentry - Guide, Chains & Contracts

> Source: https://www.sentry.trading/desktop/guide#chains-contracts
> Retrieved: 2026-09-02 (Jina Reader)
> Raw capture: `_raw/jina/sentry-desktop-guide.md`

---

## Chains & Contracts[](https://www.sentry.trading/desktop/guide#chains-contracts "Copy link to this section")

Every contract Sentry deploys or routes through, per chain. Verify anything on the linked explorers — none of these addresses are secrets.

## Robinhood Chain (chain id 4663)

*   **Launch Factory (WETH pairs):**`0x472286b7d5c1B2A3cE1132eF73d3BcCF446C5cc1` — Uniswap v4, current.
*   **Launch Factory (stock pairs):**`0xd0A93885a387e3a8a14dd82776CF9104a3676b3A` — tokenized-stock base assets.
*   **Sentry LP Vault:**`0x0F0E601041Ec765B8bAB8c166840E291253F2Df0` — immutable LP custodian. Not a proxy; no withdrawal path exists.
*   **SENTRY token:**`0x1EcA20cfa4AF2e2fA2F4CE2bF8d97bFa184FD4D7` — the platform token; WETH-paired v4 pool, pays WETH reflections to holders.
*   **SENTRY fee hook:**`0xA695f84C86367d5aEA445e8289DBC7C4C4E530cc` — 40% → 2% floor decay; 37.5% WETH reflections / 37.5% LP compound / 25% treasury.
*   **Treasury Splitter:**`0x75450496fe333A93e1327368aa3c4130BF008697` — splits the platform fee leg 60% treasury / 40% into permanently locked SENTRY liquidity.
*   **Fee hook — WETH `launch()`:**`0x35c0098836FA0d10A015A95bf02C16387814f0CC`
*   **Fee hook — WETH `launchWithReflections()`:**`0x730AbADbB4f328520e5350F59126fbE1D67F70cc`
*   **Fee hook — stock pairs:**`0x5DaA88b65Bd47199eC92d3cDe01B56348e1270CC`
*   **Fee hook — stock pairs, legacy V2:**`0x7e6E258851575bD3F69e7A01981066A26329b0cC` — superseded; still serves the pools launched on it.
*   **Sentry Token Locker:**`0xbd0E7a242A323E5e4799Abe09b7516D9dA5ea81D` — trustless timelock, no owner, no fees, no admin withdrawal path.
*   **Sentry Swap Router (V2 + V3):**`0x8bfDC6Cc38DB45BDaf2F254415251b109058a97C`
*   **Sentry Swap Router (Uniswap v4):**`0x5811a5c7c4f73290cc9aa2235245bc9f48523662`
*   **Sentry Swap Router (stock multihop):**`0x641F05602B3dee5B35bAc08A1269827f2E84445D`
*   **Sentry Swap Router (PancakeSwap V3):**`0x4415F2360bfD9B1bF55500Cb28fA41dF95CB2d2b`
*   **Uniswap v4 PoolManager:**`0x8366a39CC670B4001A1121B8F6A443A643e40951`
*   **Uniswap V3 Factory (canonical):**`0x1f7d7550B1b028f7571E69A784071F0205FD2EfA`
*   **WETH9:**`0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`
*   **ZNS (.hood) registry:**`0x8f95ed212F37cDc19f5C0716c24966D9019939Ee`
*   **Legacy Launch Factory (Uniswap V3, retired):**`0x9e8f6f8214b01Fd4Cf1d73FB1fb7cf9f811036Cb` — its 93 LP positions were swept into the LP Vault; no new launches.
*   **Pool fee:** v4 launches use a dynamic fee that decays from 40% at launch to a permanent `1.7%` floor. Legacy V3 pools are the fixed `1%` tier.
*   **Fee split at the floor:** on a WETH `launch()`, the 1.7% is 1.0% creator / 0.2% back into the token's own liquidity / 0.5% platform. Reflection and stock launches also pay 0.8% to holders, leaving 0.5% creator and 0.2% platform. Legacy V3 pools split collected fees 70/30 creator/treasury (`creatorFeeBps` = 7000).
*   **Explorer:**[robinhoodchain.blockscout.com](https://robinhoodchain.blockscout.com/)
*   **Sentry subgraph (Goldsky):**[sentry-robinhood](https://api.goldsky.com/api/public/project_cmm7vh5xwsa8m01qmdr7w7u62/subgraphs/sentry-robinhood/1.2.0/gn) — public GraphQL API indexing every launch, pool, swap, and router trade.

## Ink (chain id 57073)

Ink runs the **same v4 launch stack as Robinhood Chain** — same factory implementation, same fee hooks, same 40% → 1.7% decay curve, same per-swap fee splits, same immutable LP vault custody. The only difference: Ink also supports stock-paired launches against Backed wrapped xStocks (Foundation v3 USDG books → Sentry v4 CAMPAIGN / wXSTOCK pool). WETH launches are unchanged.

*   **Launch Factory (v4, WETH and wrapped-xStock pairs):**`0xcF44b151aee1Ef69677f24cadED4d2d61b0D45BD`
*   **Fee hook — WETH `launch()`:**`0x976697AdCF27D0962d3B0b6304D5975bA647B0Cc`
*   **Fee hook — WETH `launchWithReflections()`:**`0x68ad7d7e2905656B7d89e56a43a6872F8487B0cC`
*   **Fee hook — CAMPAIGN / wXSTOCK:**`0x18195c33D8150B2e7f5166FC79e29a6C2B1fB0CC`
*   **SentryStockRouterInk:**`0x1b4D919149912c9781b086C8242729EE317631C8` — ETH hop (WETH→USDT0→USDG via Velodrome) + 75% WETH peel to the initialized Quotron proxies. Required for every stock-pair swap.
*   **SentryInkRouterV4 (WETH pairs only):**`0x5275de614E06DbA10546171c1e6d2a30A87844b7` — do not use this for wrapped-xStock launches.
*   **Sentry LP Vault:**`0x86585D4474C78c1C0fA1f8771682E9aD020787eC` — immutable LP custodian, no withdrawal path.
*   **Uniswap v4 PoolManager (canonical):**`0x360E68faCcca8cA495c1B759Fd9EEe466db9FB32`
*   **Uniswap v4 StateView:**`0x76fd297e2d437cd7f76d50f01afe6160f86e9990`
*   **Uniswap v4 Quoter:**`0x3972C00f7ed4885e145823eb7C655375d275A1C5` — allowlisted on the xStock hook so quotes simulate the 25% reflection skim.
*   **WETH9:**`0x4200000000000000000000000000000000000006`
*   **USDT0:**`0x0200C29006150606B650577BBE7B6248F58470c1` — 6 decimals; Velodrome hop.
*   **USDG (Ink):**`0xe343167631d89B6Ffc58B88d6b7fB0228795491D` — hop asset for ETH → wrapped xStock.
*   **Official Uniswap V3 Factory:**`0x640887A9ba3A9C53Ed27D0F7e8246A4F933f3424`
*   **Uniswap V3 SwapRouter02:**`0x177778F19E89dD1012BdBe603F144088A95C4B53`
*   **Uniswap V3 QuoterV2:**`0x96b572D2d880cf2Fa2563651BD23ADE6f5516652`
*   **Uniswap V3 Position Manager:**`0xC0836E5B058BBE22ae2266e1AC488A1A0fD8DCE8`
*   **Velodrome Slipstream SwapRouter:**`0x63951637d667f23D5251DEdc0f9123D22d8595be`
*   **Velodrome Slipstream Quoter:**`0x3FA596fAC2D6f7d16E01984897Ac04200Cb9cA05`
*   **Stock-paired launches:** same factory proxy; pair against Backed wrappers (wNVDAx, wAAPLx, …), never the raw rebasing xStock. ETH trades go through SentryStockRouterInk. Full integrator reference: [Ink xStocks (Developers)](https://www.sentry.trading/desktop/guide#ink-xstocks).
*   **ZNS (.ink) registry:**`0xFb2Cd41a8aeC89EFBb19575C6c48d872cE97A0A5`
*   **Legacy Launch Factory (V3):**`0xDc37e11B68052d1539fa23386eE58Ac444bf5BE1` — pre-v4 launches; positions self-custodied permanently, fees split 65/35 creator/treasury (`creatorFeeBps` = 6500).
*   **Explorer:**[explorer.inkonchain.com](https://explorer.inkonchain.com/)
*   **Sentry subgraph (Goldsky):**[sentry-ink](https://api.goldsky.com/api/public/project_cmm7vh5xwsa8m01qmdr7w7u62/subgraphs/sentry-ink/1.6.0/gn) — public GraphQL API indexing every Ink launch, pool, and swap.
