# Oracles and Price Feeds

> Source: <https://docs.robinhood.com/chain/oracles-and-price-feeds>
> Retrieved: 2026-08-12 (Tavily extract, advanced depth)

---

# Oracles & Price Feeds

Robinhood Chain uses [Chainlink](https://chain.link/) for onchain price data. Both crypto assets and Stock Tokens have Chainlink price feeds, so your contracts can read reliable prices directly onchain — including live prices for tokenized equities and ETFs.

## Reading a price feed

Chainlink price feeds implement the standard `AggregatorV3Interface`. Read the latest price with `latestRoundData()`, accessed through the feed's proxy address:

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
interface AggregatorV3Interface {
function latestRoundData()
external
view
returns (
uint80 roundId,
int256 answer,
uint256 startedAt,
uint256 updatedAt,
uint80 answeredInRound
);
function decimals() external view returns (uint8);
}
contract PriceConsumer {
AggregatorV3Interface internal priceFeed;
constructor(address feedProxy) {
priceFeed = AggregatorV3Interface(feedProxy);
}
function getLatestPrice() public view returns (int256) {
(, int256 answer, , uint256 updatedAt, ) = priceFeed.latestRoundData();
require(answer > 0, "Invalid price");
require(updatedAt > 0, "Round not complete");
return answer;
}
}
```

Decimals: prices are returned as integers — call `decimals()` to scale. Most USD feeds use 8 decimals (e.g. 30000000000 at 8 decimals = $300.00).

## Stock Token price feeds

Each Stock Token on Robinhood Chain has its own Chainlink price feed. These feeds use the same `AggregatorV3Interface` and `latestRoundData()` as crypto feeds — reading a stock price is identical to reading any other Chainlink feed. Point the consumer above at the stock's feed proxy.

The feed returns the price of one token, which is the underlying share price times the multiplier. `latestRoundData()` returns this directly, so you don't apply the multiplier yourself. The multiplier accounts for corporate actions (dividends, splits) and is also readable onchain via the token's `uiMultiplier()`.

The token price diverges from the underlying share price over time. Because dividends are reinvested into the token via the multiplier, a stock token tracks the total return of the underlying — price changes plus reinvested dividends — not just the share price. As dividends accrue, the multiplier rises and one token comes to represent more than one share, so the feed price drifts above the headline share price. This is expected.

Example: a token tracking a $100 stock starts at a multiplier of 1.0 (1 token = 1 share, feed price $100). After a dividend is reinvested, the multiplier rises to ~1.05 — one token now represents 1.05 shares. If the share price is still $100, the feed price is $105 (1.05 × $100). `latestRoundData()` always returns this full, multiplier-adjusted value.

Stock feeds update 24/5, following market hours.

### Displaying balances and prices

The feed returns the price of a single token. `uiMultiplier()` is the shares-per-token ratio, returned as an integer scaled by 1e18. Always divide by 1e18 after applying it (as shown below), otherwise the result is off by a factor of 1e18. Depending on what you want to show users:

* Token value (default): use the feed price directly.
* Underlying share price: `feedPrice * 1e18 / uiMultiplier()`
* Share-equivalent units: `balance * uiMultiplier() / 1e18`

The economic value is identical in every case — only the presentation differs.

See [Building with Stock Tokens](/chain/building-with-stock-tokens) for end-to-end examples.

## Available feeds

Feed proxy addresses, decimals, and heartbeats are maintained by Chainlink. See the [Robinhood price feeds page](https://docs.chain.link/data-feeds/price-feeds/addresses?network=robinhood) for the current list — it's the source of truth, so always read addresses and parameters from there rather than hardcoding them.

## Checking sequencer uptime (recommended on L2)

Because Robinhood Chain is a Layer-2, verify the sequencer is up before trusting a price — during a sequencer outage, feeds can go stale. Chainlink provides an L2 Sequencer Uptime Feed for this; check it before reading any price:

```
(, int256 sequencerStatus, uint256 startedAt, , ) = sequencerUptimeFeed.latestRoundData();
require(sequencerStatus == 0, "Sequencer down"); // 0 = up
require(block.timestamp - startedAt > GRACE_PERIOD, "Grace period not over");
```

> **Archive note, not source text (2026-09-03): the source gives no sequencer uptime feed address for Robinhood Chain, and there does not appear to be one.**
> This section's advice is unchanged in the source and is sound in general, but it is not actionable on this chain as written.
> Robinhood Chain is **not** among the eleven networks Chainlink lists as having an L2 Sequencer Uptime Feed (Arbitrum, BASE, Celo, Mantle, MegaETH, Metis, OP, Scroll, Soneium, X Layer, ZKsync), on either the 2026-08-12 or the 2026-09-03 capture of `24-chainlink-l2-sequencer-feeds.md`.
> The Chainlink reference directory for this chain, `https://reference-data-directory.vercel.app/feeds-robinhood-mainnet.json`, lists 57 feeds and **none** of them is a sequencer-uptime feed.
> As of 2026-09-03 that page also carries a new CAUTION notice: Chainlink is **no longer expanding L2 Sequencer Uptime Feeds to additional networks**, so one is unlikely to appear.
> Treat the `sequencerUptimeFeed` snippet above as a pattern to copy on a chain that has such a feed, not as something you can wire up on Robinhood Chain today.
> Keep the staleness check (`updatedAt` versus heartbeat) as the working guard here, as the checklist below already recommends.

## Oracle Pauses During Corporate Actions

While a corporate action is being processed, the price oracle for the affected token is **paused** — feeds are expected to stop publishing fresh prices while the token's terms or multiplier are being updated — and **unpaused** once processing completes. You can read this state on-chain via `oraclePaused()` on the token.

Integrators reading prices on-chain should treat a paused oracle as "price temporarily unavailable" for that token, rather than as a zero or stale price. The flag is advisory and not enforced on-chain, so a paused oracle may still return a value — keep your staleness check (`updatedAt` vs. heartbeat) as the primary guard rather than relying on the flag alone. These pause windows align with the trading pauses around corporate actions.

## Best practices

* Check staleness — compare `updatedAt` against the feed's heartbeat; reject stale prices.
* Validate the answer — reject zero or negative values.
* Read `decimals()` — never hard-code.
* Check sequencer uptime — see above.
* Account for the multiplier on corp actions — the feed quotes per-token price; read `uiMultiplier()` (and pending `newUIMultiplier()` / `effectiveAt()`) consistently before converting to share terms.
* Check the oracle pause flag — read `oraclePaused()`; treat `true` as "do not trust the price," but keep your staleness check as the primary guard since the flag is advisory and not enforced on-chain.

## Further reading

* [Chainlink Data Feeds](https://docs.chain.link/data-feeds)
* [Chainlink L2 Sequencer Uptime Feeds](https://docs.chain.link/data-feeds/l2-sequencer-feeds)
* [Robinhood Price Feeds](https://docs.chain.link/data-feeds/tokenized-equity-feeds/robinhood)
* [Building with Stock Tokens](/chain/building-with-stock-tokens)
