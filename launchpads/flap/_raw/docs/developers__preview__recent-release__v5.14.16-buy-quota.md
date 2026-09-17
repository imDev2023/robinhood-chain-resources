> For the complete documentation index, see [llms.txt](https://docs.flap.sh/flap/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://docs.flap.sh/flap/developers/preview/recent-release/v5.14.16-buy-quota.md).

# Buy Quota (v5.14.16)

{% hint style="warning" %}
**Preview.** This document has not been reviewed yet. Content may be incomplete or inaccurate.
{% endhint %}

{% hint style="success" %}
**This page is for terminal / bot / wallet developers** who quote or execute trades against the bonding curve. Read [Trade Tokens](https://github.com/flap-sh/gitbook/tree/main/developers/preview/wallet-and-terminal-and-bot-developers/trade-tokens.md) first if you haven't yet — this page assumes you're already familiar with `quoteExactInput` / `swapExactInput`.
{% endhint %}

**Current Protocol Version:** `v5.14.16`

***

## What Is a Buy Quota?

A **buy quota** is an optional, per-token limit on how much of a token a single address can buy cumulatively from the **bonding curve** (not the DEX, after graduation).

Unlike a hard cap that reverts, exceeding your quota does **not** fail your transaction. Instead, the protocol automatically refunds the portion of your input that would push you over the limit — you simply receive less output than you asked for (down to zero if your quota is already exhausted), and the excess quote-asset input comes back to you in the same transaction.

{% hint style="info" %}
Not every token has a quota. If a token has no cap configured, this entire mechanism has zero effect on it — you can buy as much as the bonding curve otherwise allows.
{% endhint %}

## Why It Exists

The bonding curve is where a token's price is most volatile relative to supply — a single address accumulating a large share early can distort later pricing for everyone else. A buy quota lets a token limit how much cumulative exposure any single address can build up while the token is still in its bonding-curve phase, without needing to block or blacklist anyone outright.

## Key Design Points

* **Quota is keyed by `tx.origin`, not `msg.sender`.** This means the limit tracks the *ultimate transaction originator* — the externally-owned account (EOA) that signed and sent the transaction — regardless of how many intermediate contracts (routers, aggregators, smart-contract wallets acting on behalf of a single owner) the call passes through before reaching the bonding curve.
* **Quota only applies to bonding-curve buys.** Once a token has migrated to a DEX, trading there is unaffected — a buy quota is a bonding-curve-phase mechanism only.
* **Cumulative, not per-transaction.** Your quota usage accumulates across every buy you make on that token while a quota is active; it does not reset per transaction.
* **Selling never reduces your quota usage.** Once you've bought against your quota, selling the tokens back does not free up allowance — the cumulative-bought figure only ever increases while a quota is active for that token.
* **Never causes a revert on its own.** If you're already at your quota (or your input would exceed it), your buy simply executes for less than requested — with a full or partial refund — rather than failing outright. You should still set a normal slippage/minimum-output check on your own call if you require a guaranteed minimum output; the quota mechanism does not bypass that.

***

## Checking a Token's Quota Configuration

To find out whether a token has a quota configured at all, and what it is:

```solidity
/// @notice Get the per-tx.origin cumulative buy cap for a token on the internal market.
/// @param token The address of the token
/// @return bps The cap in bps of maxSupply; 0 means no limit
/// @return maxBuyAmount The absolute cap in token units; 0 means no limit
function maxBuyPerOrigin(address token) external view returns (uint16 bps, uint256 maxBuyAmount);
```

* `bps` is expressed in basis points of the token's max supply (e.g. `200` = 2%).
* `maxBuyAmount` is the same limit expressed directly in token units, for convenience.
* If both values come back `0`, the token has **no quota** — this entire feature is a no-op for that token.

## Checking Your Own Quota Usage

To find out how much of your own quota you've already used, and how much remains, for a specific token:

```solidity
/// @notice Get an origin's per-token buy quota usage on the internal market.
/// @param token The address of the token
/// @param origin The tx.origin address to query
/// @return bought The cumulative bought amount in token units
/// @return remaining The remaining buy allowance in token units
///         (0 if exhausted; the maximum uint256 value if the token has no quota at all)
function buyQuotaOf(address token, address origin) external view returns (uint256 bought, uint256 remaining);
```

{% hint style="warning" %}
**Important for quoting — you must set the `from` field.**

`buyQuotaOf` (and, indirectly, `quoteExactInput` — see below) depends on the address you're querying *as* — the `origin` parameter. When you're building a raw `eth_call` (or the equivalent simulation call in your library of choice, e.g. viem/ethers), you must explicitly set the caller address in the call's `from` field to the address you actually intend to trade from.

If you omit `from` (or leave it as a zero/arbitrary address), the call will still succeed, but it will report the quota state for the **wrong address** — you'll get back the quota status of whatever default caller your RPC client happens to use, not your own.

This matters even more when you're getting a **quote** for a prospective buy (via `quoteExactInput`), not just checking your quota directly: the quoted output amount for a bonding-curve buy is quota-aware — if your quota is partially or fully consumed, the quoted `outputAmount` will already reflect a smaller (or zero) fill. If you quote with the wrong `from`, you'll get a quote for the wrong address's remaining allowance, which will not match what you actually receive when you execute the real trade from your real address.

**Rule of thumb:** whenever you simulate a call that a specific address will eventually execute for real (quoting a buy, or checking `buyQuotaOf`), always set `from` to that exact address in your `eth_call` (or your library's equivalent parameter — e.g. `account` in viem, `from` in ethers/web3.js).
{% endhint %}

## What Happens When You Exceed Your Quota

If your requested buy amount would push your cumulative total past your remaining allowance:

* The protocol fills your buy **up to your remaining allowance only**.
* The unused portion of your input (the amount that would have gone toward the excess) is **automatically refunded** to you in the same transaction — no separate claim step needed.
* If your quota is already fully exhausted (`remaining == 0`), your buy is filled for **zero output**, and effectively your entire input is refunded.

This means a buy quota never blocks a transaction from succeeding — it only changes how much you actually receive. If your integration requires a guaranteed exact fill, check `buyQuotaOf` before submitting the trade, or set an appropriate minimum-output parameter on your swap call and treat a shortfall as an expected, valid outcome rather than an error.

## Watching Quota Changes (Events)

Two events let you track quota state without polling:

```solidity
/// @notice emitted when a token's per-tx.origin cumulative buy cap is set on the internal market.
/// @dev Absence of this event for a token means "no limit".
///      The cap only applies to internal (bonding-curve) buys, not DEX trades.
/// @param token The address of the token
/// @param bps The cap in bps of maxSupply (e.g. 200 = 2%). 0 means no limit.
/// @param maxBuyAmount The absolute per-origin cumulative buy cap in token units. 0 means no limit.
event FlapTokenMaxBuyPerOriginSet(address indexed token, uint16 bps, uint256 maxBuyAmount);
```

```solidity
/// @notice emitted after a bonding-curve buy updates an origin's per-tx.origin buy quota usage.
/// @dev Only emitted when a cap is active for the token; a token with no cap set never emits this event.
/// @param token The address of the token
/// @param origin The tx.origin address whose quota usage changed
/// @param bought The cumulative bought amount for this origin after the buy, in token units
/// @param remaining The remaining buy allowance for this origin, in token units (0 if exhausted)
event FlapBuyQuotaUpdated(address indexed token, address indexed origin, uint256 bought, uint256 remaining);
```

* Index `FlapTokenMaxBuyPerOriginSet` to build a live map of which tokens currently have a quota configured, and what it is.
* Index `FlapBuyQuotaUpdated` (filterable by `token` and `origin`, both indexed) to track a specific address's quota usage on a specific token over time, without repeatedly calling `buyQuotaOf`.

{% hint style="info" %}
Neither event fires for a token with no quota configured — absence of `FlapTokenMaxBuyPerOriginSet` for a given token is itself the signal that the token has no limit.
{% endhint %}

## Summary Checklist

* [ ] Before quoting or trading a token you don't fully trust, call `maxBuyPerOrigin(token)` to check whether a quota exists.
* [ ] If a quota exists, call `buyQuotaOf(token, yourAddress)` to see your remaining allowance before submitting a large buy.
* [ ] Always set the `from` field on any `eth_call` / simulated quote to the exact address that will execute the real transaction — quota state is resolved by `tx.origin`, so an incorrect `from` gives you someone else's quota state, not yours.
* [ ] Design your integration to treat a partial fill (with automatic refund) as a normal, expected outcome when a quota is active — not as a failure.
* [ ] Index `FlapTokenMaxBuyPerOriginSet` and `FlapBuyQuotaUpdated` if you want to track quota state off-chain instead of polling the view functions.
