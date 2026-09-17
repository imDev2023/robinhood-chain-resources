# Pools.trade - DefiLlama record (slug `pools`)

> Source: https://api.llama.fi/protocol/pools and https://api.llama.fi/summary/fees/pools
> Retrieved: 2026-09-03 (curl; raw at `_raw/leads/defillama-protocol-pools.json` and `_raw/leads/defillama-fees-pools.json`)

---

This resolves the `_market` lead that a fee-tracked launchpad called "Pools" (slug `pools`) exists on Robinhood Chain.
It is this platform.

```json
{
  "id": "8371",
  "name": "Pools",
  "url": "https://pools.trade/",
  "description": "Uniswap Labs' token launchpad on Robinhood Chain",
  "chain": "Robinhood Chain",
  "chains": ["Robinhood Chain"],
  "category": "Launchpad",
  "twitter": "TradePools",
  "audits": "0",
  "github": null,
  "parentProtocol": null,
  "forkedFrom": null
}
```

## Fees, 2026-09-03

| metric | value |
| --- | --- |
| fees 24h | $49,911 |
| fees 7d | $274,131 |
| fees 30d | $1,542,145 |
| fees all time | $1,596,520 |
| change 1d | +53.8% |
| revenue 24h / 7d / 30d / all time | $0 |

The 30-day figure matches the "about $1.5M fees in 30 days" note in `_market`.
Fees all time is only 3.5% above fees 30d, which is consistent with a 2026-08-05 launch: essentially the whole history is inside the 30-day window.

## DefiLlama's own methodology text

Worth quoting because it is the clearest short statement of the economics, and every clause of it is confirmed on-chain in `README.md` section 4:

> **Fees**: The 0.25% fee charged on every trade, taken in whichever token the trader pays with. pools.trade charges nothing to launch a token and takes no cut of the raise. Traders also pay Uniswap's own 0.04% protocol fee on pools where it is switched on; that is Uniswap's charge, not pools.trade's, and is left out here.
>
> **SupplySideRevenue**: The whole 0.25% trading fee: the creator's share plus the part that is compounded back into the locked liquidity.
>
> **Revenue**: Zero. pools.trade keeps none of the trading fee - it all goes to the token's creator and back into the pool's own permanently locked liquidity.
>
> **ProtocolRevenue**: Zero. pools.trade has no treasury cut, no launch fee and no graduation fee.
>
> **HoldersRevenue**: Zero. There is no pools.trade token.

The last clause needs one correction from the chain.
There is a token called `pools.trade`, ticker `POOLS`, at `0x385b36Ff682Ab4C76E7c37A66b96aABC466471d5`, launched 2026-07-30 through the platform's own Instant Launch by `0xbE4EbA417999C7269c6d631eaEF82ad3F2bCdd9e`, with 6,240 holders and a $2.3M FDV at capture.
Nothing about it is protocol-owned or fee-accruing, so DefiLlama's point stands, but the ticker exists.
