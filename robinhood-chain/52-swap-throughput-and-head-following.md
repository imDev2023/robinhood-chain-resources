# Swap throughput and head-following on chain 4663, measured

> Original writing. Measured 2026-09-25 from a workstation over blocks 71,345,374 to 72,202,464, a contiguous 24.00 hours (2026-09-24T11:47:38Z to 2026-09-25T11:47:38Z), plus a 12-minute head-following window the same afternoon.
> Useful to anyone sizing an indexer, a trade feed or a rolling-stats service on this chain, or choosing between polling and subscribing.
> Complements `47-backrunning-measured.md`, which counted v4 swaps only and over a different day, and `32-explorer-and-data-apis.md`, whose per-provider `eth_getLogs` caps this page extends with the WebSocket behaviour those same plans allow.

## The chain does 3.3 million swaps a day, and 42% of them are not v4

One `eth_getLogs` per window, `topics[0]` an OR list of the v4 and v3 `Swap` signatures, no address constraint, so both are counted in one pass.
A swap the PoolManager (`0x8366a39cc670b4001a1121b8f6a443a643e40951`) emitted is v4 and names its pool in `topics[1]`; anything else at the v3 topic is a v3-style pool and names itself by the emitting address.

| | Swaps in 24 h | Share | Pools that traded |
| --- | ---: | ---: | ---: |
| Uniswap v4 | 1,934,585 | 58.4% | 16,563 |
| v3-style (Uniswap v3, Ramses, "up") | 1,375,074 | 41.6% | 4,856 |
| **Total** | **3,309,659** | | **21,419** |

A second run over the window one hour earlier counted 3,304,285, so the figure is the chain's and not the method's.
`47-backrunning-measured.md` counted 2,962,730 v4 swaps over 24 hours on 2026-09-19, against 1,934,585 six days later: v4 swap volume on this chain moves by tens of percent week to week, so do not treat any single day's count as a constant.

Per block, which is what a head-follower absorbs:

| mean | p50 | p90 | p99 | p99.9 | max | blocks with no swap |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 3.86 | 3 | 8 | 22 | 48 | 193 | 13.8% |

1,480,175 transactions carried at least one v4 swap, so such a transaction averages 1.31 v4 swaps.

**Anything that reads only the v4 PoolManager is missing two swaps in five.**
That is a bigger v3 share than the pool census in `45-v4-pools-and-liquidity.md` would suggest, because v3 pools here are fewer and far busier: 4,856 v3 pools took 41.6% of the flow.

## Trading is concentrated, and one pool is a ninth of the chain

| Top N pools by swaps | Share of all swaps |
| --- | ---: |
| 10 | 21.0% |
| 100 | 47.3% |
| 1,000 | 83.3% |
| 2,000 | 91.3% |

6,936 pools took at least ten swaps in the day, 2,789 at least a hundred, 537 at least a thousand.
The busiest single pool is the **v3 WETH/USDG pool at one basis point**, with 376,919 swaps in the day: 11.4% of every swap on the chain.
The rest of the top twenty is WETH/USDG at other fee tiers, USDG/META, and launchpad tokens (FOOMS, JOLLY, RBD, ROO, SCHIFFY, MONIT), several through hooks.

**The 195 tokenized equities are about 3% of this chain's swap traffic.**
Classified against a production catalogue of 196 chosen pools: stock-token pools took 100,449 swaps (3.0%) across 145 of 192, the three quote-currency anchor pools took 393,400 (11.9%), and everything else, which is the launchpad ecosystem, took 2,815,810 (85.1%) across 21,271 pools.
47 of the 192 stock-token pools took no swap at all in the day.
Anyone building "a DEX screener for Robinhood Chain" is building a site about launchpad tokens with an equities section, whatever the framing.

## `eth_subscribe` works on both keyed free plans, and it is the way to follow head

This is the part that changes designs.
The same free plans whose `eth_getLogs` is capped at 10 and 100 blocks (`32-explorer-and-data-apis.md`) will push logs over WebSocket with no range involved.
Measured once per endpoint, each subscription given 30 s to deliver and stopped after 20 notifications:

| endpoint | `newHeads` | `logs` |
| --- | --- | --- |
| `robinhood-mainnet.g.alchemy.com` (free) | works, first notification 62 ms | works, first notification 5 ms |
| `lb.drpc.live` (free) | works, first notification 119 ms | works, first notification 434 ms |
| `wss://rpc.mainnet.chain.robinhood.com` | socket error, no subscription | socket error, no subscription |

Use `wss://` against the same path as the HTTPS endpoint.
The public endpoint has no usable WebSocket, so a subscriber has to hold a key.
This was measured from a workstation; it has not been tried from Cloudflare Workers egress, which is where the public endpoint refuses about 99 log queries in 100.

## Polling numbers, for the fallback path

`eth_blockNumber` once a second for 12 minutes, 720 polls per endpoint, 2026-09-25 from about 12:35Z.

| | Alchemy | dRPC | public |
| --- | ---: | ---: | ---: |
| Errors | 0 | 0 | 11 (1.53%), all HTTP 429 |
| Latency p50 / p90 / p99 | 35 / 48 / 150 ms | 104 / 153 / 241 ms | 119 / 136 / 294 ms |
| Blocks advanced per 1 s poll, mean | 9.908 | 9.910 | 10.059 |
| Polls where head went backwards | 0 | 0 | 0 |

Head never went backwards on any endpoint, and the three agreed to within about eight blocks.
A mean of 9.91 blocks a second is a block time of 0.1009 s, matching 0.1011 s measured over 100,000 blocks the same morning.

`eth_getLogs` over the newest 100 blocks, 48 attempts each at one every fifteen seconds:

| | Alchemy | dRPC | public |
| --- | ---: | ---: | ---: |
| Served | 0 of 48 | 47 of 48 | 46 of 48 |
| Latency p50 / p90 | - | 145 / 213 ms | 234 / 297 ms |
| Mean logs returned | - | 298.6 | 297.3 |
| The refusal | free-tier 10-block cap | one "Unknown block" (asked past its own head) | HTTP 429 |

**Alchemy's free plan cannot follow head by polling at all.**
dRPC can, at 145 ms for the median.
A 101-block window is 10.2 s of chain, so a poller of that shape is between 0 and 10 seconds behind before its own latency, and costs 8,487 requests a day, 354 an hour.
dRPC's cap is on `toBlock - fromBlock`, so 101 blocks per request is the most it serves: 100 is accepted, 101 refused with "ranges over 10000 blocks are not supported on free plan".

Scanning a whole day this way cost 8,636 requests for 8,487 windows at concurrency 10, 199 s of wall time, 149 refusals (133 HTTP 408 "Request timeout" from dRPC, 16 socket failures) and no unread range.
dRPC's timeouts under sustained concurrency are the only thing that needs a retry; none of them needed a split.

## Decode cost and archive size

40 windows of 101 blocks, 4,040 blocks, 11,626 swaps, decoded into pool, both signed amounts, `sqrtPriceX96`, liquidity, tick, block and log index, timed on a workstation with Node 26:

- 268,828 bytes of JSON per 101-block window, 2,662 bytes per block.
- `JSON.parse` 0.467 ms and decode 0.548 ms per window, so **1.015 ms of CPU per window, 0.0100 ms per block, 0.0035 ms per swap**.
- That is **0.099 ms of CPU per second of chain**: following the whole chain's swap flow is about 0.01% of one core.

Keeping the raw log is cheap, measured over 30 windows, 3,030 blocks, 8,823 logs:

- 927 bytes per log as JSON, **130 bytes per log gzipped at level 6, a 7.11x ratio**.
- 2.31 GB a day raw, **0.324 GB a day gzipped**, about 9.9 GB a month.

For contrast, putting the same 100.7 million swaps a month into a row-billed SQL store (D1, or SQLite in a Durable Object, which share both the rates and the 10 GB ceiling) is 100.7 million rows written with no index and 302 million with two, against 50 million included, and roughly 25 GB a month of storage against a 10 GB per-database ceiling.
On this chain, the raw log belongs in object storage and the SQL store belongs to aggregates.

## Method and provenance

Read-only throughout; no transaction was sent and no key was used beyond the two read endpoints' own.
Window ends were found by binary search on block timestamps, not by interpolation, because the block rate here is not steady (`32-explorer-and-data-apis.md`).
Both topic hashes were confirmed against the chain before being counted on: `0x40e9cecb9f5f1f1c5b9c97dec2917b7ee92e57ba5563708daca94dd84ad7112f` returned logs from the PoolManager and nobody else, `0xc42079f94a6350d7e6235f29174924f928cc2ac818eb64fed8004e115fbcca67` from v3 pool addresses.
Scripts: `scripts/spike/` in the Dex-screener repository, for issue #43.
