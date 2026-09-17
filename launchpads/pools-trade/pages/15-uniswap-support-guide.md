# Pools.trade - Uniswap support article: Launching and trading tokens on pools.trade

> Source: https://support.uniswap.org/hc/en-us/articles/47943121516685-Launching-and-trading-tokens-on-pools-trade
> Retrieved: 2026-09-03 (Jina Reader; raw at `_raw/jina/support-uniswap-pools-trade.md`)

---

Found by snapshotting a token page: the trade panel's explainer modal links here.
This is the official user guide, published on Uniswap Labs' own help centre on 2026-08-06, and its first sentence is the operator statement this section needed.

Site chrome has been trimmed; the article body is verbatim.

# Launching and trading tokens on pools.trade

[**Pools.trade**](https://pools.trade/) is a token launchpad built by Uniswap Labs for Robinhood Chain. It gives you a single interface to launch a token, discover new ones, and trade them end to end.

Every token launched on Pools starts with a fixed supply of 1 billion tokens and ends in a Uniswap v4 pool with permanently locked liquidity. LP fees autocompound back into the locked position.

#### **How to launch a token**

1.   Go to [pools.trade](https://pools.trade/) and connect your wallet.
2.   Choose your launch type:
    *   **Instant Launch:** Your token is live and tradable the moment you create it. Price climbs along a classic bonding curve as people buy — no minimum raise or graduation requirement.
    *   **Crowd Launch:** Your token launches over a four-hour bidding window using time-weighted (TWAP) mechanics. The token becomes tradable only if the launch reaches a $10k FDV; otherwise all bids are refunded.

3.   Add an image, ticker symbol, and description.

**Note:** These details can't be changed after creation.
4.   Optionally, enable a **creator fee** to receive 0.05% of the 0.25% LP fee on trades. The rest autocompounds into locked liquidity. By default, these funds go to your wallet, but you can change the wallet address if you wish.
5.   Select **Launch** and confirm the transaction in your wallet, which has a [network cost](https://support.uniswap.org/hc/en-us/articles/8370337377805).

There are no added launchpad fees. Each pool is a standard Uniswap pool with a 0.25% LP fee.

#### **How to participate in a Crowd Launch**

1.   Browse live Crowd Launches on [pools.trade](https://pools.trade/) or in [Uniswap Launches](https://app.uniswap.org/launches).
2.   Open the launch and place a bid for the budget you want to spend.
3.   Your bid fills gradually over the remainder of the four-hour window. Price moves with demand, so earlier bids get better prices, and every budget fills in full by the end of the window.
4.   When the window closes:
    *   **If the launch reaches $10k FDV,** the token graduates into a Uniswap v4 pool and you can claim your tokens.
    *   **If it falls short,** the launch fails and all bids are refunded. You will need to claim your refund.

#### **How to claim tokens**

Tokens from a Crowd Launch are claimed after the launch ends:

1.   Wait for the full four-hour launch window to close and the launch to graduate.
2.   Find the token on your Portfolio page or return to the launch page on [pools.trade](https://pools.trade/) with the same wallet you bid from.
3.   Select **Claim** and confirm the transaction in your wallet.

**Note:** Instant Launch tokens don't require claiming. They're immediately visible in your wallet when you buy, and you can swap in and out anytime.

#### **I didn't receive my tokens or my refund**

If an auction ended and you don't see your tokens or your refunded bid, work through these steps:

1.   **Confirm the launch outcome.** Check the launch page to see whether it graduated ($10k FDV reached) or failed.

A graduated launch pays out **tokens you must claim**; a failed launch **refunds your bid** instead. You won't receive both.
2.   **Claim manually.** Neither tokens nor refunds are automatic. Go to the Portfolio page of the wallet you bid from, find the token, and select **Claim**.
3.   **Check the right wallet and network.** Make sure you're connected with the same wallet address you bid from, and that your wallet is set to **Robinhood Chain**.
4.   **Import the token.** Some wallets don't display new tokens automatically. Add the token manually using its contract address from the launch page.
5.   **Allow time for settlement.** Claims and refunds are onchain transactions and can take a short time to confirm during periods of high network activity.

If none of these resolve it, [contact support](https://support.uniswap.org/hc/en-us/requests/new) with your **wallet address**, the **token/launch link**, and the **transaction hash** of your bid so the team can investigate.

#### **Disclaimer**

Pools features memecoins, which are assets created purely for entertainment, social, and cultural purposes. Their value is driven by market demand and speculation — not by anyone's efforts or by any enterprise. Prices are extremely volatile and may go to zero, and these assets may not carry securities-law or other regulatory protections. Any use of Pools for an asset other than a memecoin is prohibited; [CCA](https://support.uniswap.org/hc/en-us/articles/43107626487437) is available for other types of assets, subject to other applicable terms and conditions.

Uniswap Labs has not independently reviewed or verified any token or project displayed. The appearance of a token does not constitute a recommendation, endorsement, or solicitation. Some tokens have creator fees enabled, meaning the creator earns a portion of trading fees on that token and has a financial interest in its trading activity.

#### **Learn more**

*   [Pools.trade: A New Way to Launch on Robinhood Chain](https://blog.uniswap.org/pools-trade-a-new-way-to-launch-on-robinhood-chain)
*   [What are Continuous Clearing Auctions?](https://support.uniswap.org/hc/en-us/articles/43107626487437)
*   [Technical documentation on the Uniswap Liquidity Launchpad](https://docs.uniswap.org/contracts/liquidity-launchpad/Overview)
