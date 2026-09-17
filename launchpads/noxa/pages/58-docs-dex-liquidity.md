# Noxa - docs dex liquidity

> Source: https://docs.noxa.fi/dex/liquidity/
> Retrieved: 2026-09-02 (Jina Reader)

---

Title: Providing Liquidity

URL Source: https://docs.noxa.fi/dex/liquidity/

Markdown Content:
NOXA DEX supports both V2 and V3 liquidity provision.

Classic AMM liquidity pools.

### Adding V2 Liquidity

[Section titled “Adding V2 Liquidity”](https://docs.noxa.fi/dex/liquidity/#adding-v2-liquidity)

1.   Go to [dex.noxa.fi](https://dex.noxa.fi/) and navigate to Pool
2.   Click “Add Liquidity”
3.   Select V2 pool type
4.   Choose your token pair
5.   Enter amounts (must be balanced by value)
6.   Approve tokens if needed
7.   Add liquidity

You’ll receive LP tokens representing your share of the pool.

### Removing V2 Liquidity

[Section titled “Removing V2 Liquidity”](https://docs.noxa.fi/dex/liquidity/#removing-v2-liquidity)

1.   Go to the Pool section
2.   Find your position
3.   Click “Remove”
4.   Choose the amount to remove (25%, 50%, 100%, or custom)
5.   Confirm the transaction

You’ll receive both tokens back proportional to your share.

Concentrated liquidity with range orders.

### Adding V3 Liquidity

[Section titled “Adding V3 Liquidity”](https://docs.noxa.fi/dex/liquidity/#adding-v3-liquidity)

1.   Navigate to Pool and select V3
2.   Choose your token pair
3.   Select fee tier (0.05%, 0.3%, or 1%)
4.   Set your price range
5.   Enter the amount of tokens
6.   Approve and add liquidity

You’ll receive an LP NFT representing your position.

### Choosing a Price Range

[Section titled “Choosing a Price Range”](https://docs.noxa.fi/dex/liquidity/#choosing-a-price-range)

*   **Wide range:** More like V2, earns fees across all prices, lower capital efficiency
*   **Narrow range:** Higher capital efficiency, but goes inactive if price moves outside
*   **Full range:** Equivalent to V2 behavior

For new/volatile tokens, wider ranges are safer.

| Fee Tier | Best For |
| --- | --- |
| 0.05% | Stable pairs, high volume |
| 0.3% | Standard pairs |
| 1% | Volatile/exotic pairs, new tokens |

NOXA Fun tokens use the **1% fee tier** by default.

### Managing V3 Positions

[Section titled “Managing V3 Positions”](https://docs.noxa.fi/dex/liquidity/#managing-v3-positions)

*   **Collect fees:** Earned fees can be collected at any time
*   **Adjust range:** Close position and open a new one with different range
*   **Increase liquidity:** Add more to an existing position
*   **Remove liquidity:** Partial or full removal

For tokens launched on NOXA Fun, the initial LP is:

*   Created automatically at launch
*   Locked forever in the locker contract
*   Cannot be removed by anyone (including the token creator)

This locked LP provides permanent baseline liquidity. Additional LP can still be added by anyone.

*   **Impermanent loss:** Your position value may decrease relative to holding
*   **Smart contract risk:** Using DeFi protocols always carries risk
*   **Token risk:** Providing liquidity to low-quality tokens can result in losses

Only provide liquidity you can afford to lose.

Links/Buttons:
- [Skip to content](https://docs.noxa.fi/dex/liquidity/#_top)
- [NOXA](https://docs.noxa.fi/)
- [Twitter](https://x.com/Noxa_Fi)
- [Telegram](https://t.me/Noxa_Fi)
- [Introduction](https://docs.noxa.fi/introduction/)
- [Overview](https://docs.noxa.fi/dex/overview/)
- [How to Launch](https://docs.noxa.fi/launchpad/how-to-launch/)
- [Supported Chains](https://docs.noxa.fi/launchpad/chains/)
- [Trading](https://docs.noxa.fi/dex/trading/)
- [Liquidity](https://docs.noxa.fi/dex/liquidity/)
- [NOXA Fun](https://docs.noxa.fi/contracts/noxa-fun/)
- [NOXA DEX](https://docs.noxa.fi/contracts/noxa-dex/)
- [Building on NOXA Fun](https://docs.noxa.fi/integrations/launchpad/)
- [DEX Integration](https://docs.noxa.fi/integrations/dex/)
- [V2 Liquidity](https://docs.noxa.fi/dex/liquidity/#v2-liquidity)
- [Adding V2 Liquidity](https://docs.noxa.fi/dex/liquidity/#adding-v2-liquidity)
- [Removing V2 Liquidity](https://docs.noxa.fi/dex/liquidity/#removing-v2-liquidity)
- [V3 Liquidity](https://docs.noxa.fi/dex/liquidity/#v3-liquidity)
- [Adding V3 Liquidity](https://docs.noxa.fi/dex/liquidity/#adding-v3-liquidity)
- [Choosing a Price Range](https://docs.noxa.fi/dex/liquidity/#choosing-a-price-range)
- [Fee Tiers](https://docs.noxa.fi/dex/liquidity/#fee-tiers)
- [Managing V3 Positions](https://docs.noxa.fi/dex/liquidity/#managing-v3-positions)
- [NOXA Fun LP](https://docs.noxa.fi/dex/liquidity/#noxa-fun-lp)
- [Risks](https://docs.noxa.fi/dex/liquidity/#risks)
- [dex.noxa.fi](https://dex.noxa.fi/)
