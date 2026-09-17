# Pools.trade - launch announcements from @Uniswap and @haydenzadams

> Source: x.com/Uniswap and x.com/haydenzadams
> Retrieved: 2026-09-02 (Bright Data `x_posts` pipeline; raw JSON under `_raw/x/`)

---

These posts are the primary public evidence for who operates pools.trade.

## @Uniswap, 2026-08-05 22:49:09Z

<https://x.com/Uniswap/status/2085136053661213180>, 2,151 likes, 413 reposts, 1,238,064 views.

> Say hello to @TradePools, a new launchpad on Robinhood Chain
>
> Launch and trade now on https://t.co/9fqa8AnC7U

Three seconds later, <https://x.com/Uniswap/status/2085136062997754217>:

> Follow @TradePools and discover new tokens

## @haydenzadams, 2026-08-05 23:09:51Z

<https://x.com/haydenzadams/status/2085141263310102935>, 1,067 likes, 372,601 views.
Hayden Adams is the founder of Uniswap.
Full text as captured:

> Incredibly excited for the launch of @TradePools!!
>
> This rollout has been absolutely insane. Degens discovered earlier versions of the smart contracts and traded over $150m in trading volume before the UI even went live
>
> This created a unique challenge where we had to update our site and indexing to support both the earlier test versions and the final versions of the contracts at the same time, which added some additional time to the launch
>
> People have used uniswap as both a launchpad and launchpad infra for over 8 years. We're excited to be building alongside all the other launchpads to move the space forward
>
> What most sets https://t.co/wEWmXIGbvx apart?
> - no added launchpad fee, just the normal protocol fee that comes with all v4 pools. This makes the launch pool way better for traders, with total spreads far lower than most launchpads
> - autocompounding liquidity (excited to bring this feature to normal Uniswap LPing as well)
> - permanently locked liquidity for all launches
> - two launch methods: instant launch works similar to other launchpads, and crowd launch simplifies what we built with CCA to create a fairer, more bundle resistant launch method
> - deep integrations and distribution: Pools has day one support across uniswap web app, wallet, trading api, all third party trading api integrations, bitget, fomo, gmgn, okx wallet, etc, with more coming online rapidly
>
> Have seen various takes claiming incorrect fee splits - to be clear the 0.25% LP fees autocompounds to the locked liquidity pool, it does not go to the uniswap team. This becomes 20% to the creator and 80% to the liquidity compounding mechanism
>
> Uniswap Labs team has been cooking hard on this one but its still in beta. We intend to ship a constant stream of upgrades and improvements from here. So please share any feedback!!

Three claims in that post are checked against the chain in `README.md`:

1. "no added launchpad fee" holds: there is no launch fee and no protocol cut anywhere in the launch path. `ContinuousClearingAuctionFactory.protocolFeeController()` is the zero address.
2. "the normal protocol fee that comes with all v4 pools" holds and is worth spelling out: `StateView.getSlot0` on a live Pools pool returns `protocolFee = 1638800`, which unpacks to 400 hundredths of a bip, that is 0.04%, in both swap directions. That fee accrues to Uniswap's `V4FeeAdapter` at `0x6d0009504d129cf5002dba61d9ae8575aa79314c`, not to the creator or the pool.
3. "20% to the creator and 80% to the liquidity compounding mechanism" is a blended figure, not what the contract encodes. `FeeSplitter.getSplits()` on `0xeFF166AAf189323c58dc27eD1206EB2C37FaACDf` returns 40% of the native side and 0% of the token side to the creator's vault, and 60% native plus 100% token to the compounding recipient. Averaged over both sides of a balanced pool that is about 20/80, which is where the figure comes from, but a creator is paid only in ETH and only from the ETH side.

## @haydenzadams, 2026-08-13

<https://x.com/haydenzadams/status/2087920502559887431>: "Tokens from @TradePools now show up in Binance wallet!"
304 likes, 68,569 views.

## @Uniswap, 2026-08-06

<https://x.com/Uniswap/status/2085401598377836865>: "Pools."
991 likes.

## @Uniswap, 2026-08-14

<https://x.com/Uniswap/status/2088304171984318937>: "@TradePools true".

## @Uniswap, 2026-08-27

<https://x.com/Uniswap/status/2092935558993485997>, 1,186 bytes captured:

> Every launch on Pools comes with:
>
> - Autocompounding liquidity
> - Permanently locked liquidity
> - Sniping mitigation
> - Zero launchpad fees
> - Optional creator fees
>
> Read the full guide

All five of those are confirmed on-chain in `README.md` sections 3 and 4.
