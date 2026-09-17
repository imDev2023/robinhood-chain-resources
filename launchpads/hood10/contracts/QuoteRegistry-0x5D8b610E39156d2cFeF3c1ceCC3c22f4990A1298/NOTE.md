## What it does

Classifies a quote asset into `NATIVE`, `STOCK`, `ECOSYSTEM`, `EXOTIC` or `UNSUPPORTED` and returns the lot-sizing policy the fee router sells it under.
Its own natspec says it is deliberately not an allowlist: the tier gates what the router will sell, not what a creator may quote a pool in.
Constructor defaults, per tier `maxPoolFractionBps`: NATIVE 0 (no sale), STOCK 50 (0.5%), ECOSYSTEM 100 (1%), EXOTIC 25 (0.25%), UNSUPPORTED not sweepable.
`MAX_POOL_FRACTION_BPS` is 1000.
`isStockToken` probes `uiMultiplier()`, the ERC-8056 Robinhood stock-token selector.
