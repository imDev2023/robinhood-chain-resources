# Sentry - Guide, Anti-Snipe Protection

> Source: https://www.sentry.trading/desktop/guide#anti-snipe
> Retrieved: 2026-09-02 (Jina Reader)
> Raw capture: `_raw/jina/sentry-desktop-guide.md`

---

## Anti-Snipe Protection[](https://www.sentry.trading/desktop/guide#anti-snipe "Copy link to this section")

Robinhood Chain has some of the most aggressive sniper bots anywhere. Most launchpads treat sniping as a bug to patch after the fact. Sentry treats it as an economics problem, solved in the pool itself: for the first minutes of every launch, sniping is **unprofitable by construction** — and every fee a sniper does pay goes to the creator, the holders' pool depth, and the protocol, not to the sniper's exit.

## The decay fee curve

Every v4 launch pool opens with a **40% trade fee** that holds for 3 minutes, then halves every 3 minutes (smoothly, not in steps) until it reaches the permanent **1.7% floor** about 17 minutes in:

| Time since launch | Trade fee |
| --- | --- |
| 0 – 3 min | **40%** |
| 6 min | 20% |
| 9 min | 10% |
| 12 min | 5% |
| 15 min | 2.5% |
| ~17 min onward | **1.7% — permanent floor** |

A block-zero bot buying 1 ETH pays 0.4 ETH in fees on the way in — and the curve is still elevated when it tries to flip, so the round trip only profits if the token does a large multiple in minutes. The math that makes sniping free money everywhere else simply doesn't clear here.

## Snipers pay the creator

The fee isn't burned and it doesn't accrue to some claimable pot — the hook settles it **within the sniper's own transaction**. On a reflection or stock-paired launch, a 40% opening-window fee splits into **20% of the trade to the creator's wallet**, 10% into permanently locked liquidity, and 10% to the protocol treasury (itself split 60% operations / 40% into permanently locked [SENTRY](https://www.sentry.trading/desktop/guide#sentry-token) liquidity). On a plain WETH launch the creator's cut is even larger — about 23.5% of every sniped trade. Launch frenzy volume is exactly when the curve is highest, so the more aggressively a launch gets sniped, **the more its creator earns and the deeper its locked liquidity gets**. Sniping a Sentry launch is donating to it.

## Why a time curve, and why 17 minutes

*   **Time-based, not swap-count-based:** a fee that decays per swap can be gamed down with dust swaps. The clock can't be.
*   **Time-based, not price-based:** a fee tied to price trusts a number snipers can push around. The clock can't be manipulated.
*   **Minutes, not seconds:** some launchpads open with a huge fee that collapses within seconds. That stops exactly one block of bots — snipers just wait it out and hit a still-empty chart. Seventeen minutes outlasts the entire frenzy window, which is precisely the stretch where a new token needs protecting.

## The launch whitelist

The anti-snipe fee has one deliberate exception. At launch, the creator can whitelist wallets (the launching wallet is always included automatically). During the decay window, whitelisted wallets pay the **1.7% floor instead of the curve rate — on buys only**. That lets a team actually acquire its supply at launch without feeding 40% of its capital to the fee curve: of a 1 ETH whitelisted buy, roughly 0.98 ETH ends up as real pool depth, versus 0.6 ETH unwhitelisted.

*   **It is not early access.** Whitelisted wallets buy from the same public pool, at the same market price, in the same blocks as everyone else. They just skip the anti-snipe premium.
*   **It is never free.** The floor fee — including its reflection and liquidity components — still applies to every whitelisted buy.
*   **Sells are never exempt.** The exemption checks trade direction; it cannot be used to dodge a sell fee during the window.
*   **It is frozen at launch.** The list is written to the hook before the pool initializes and rejects all changes afterward. Nobody — not the creator, not Sentry — can add a wallet after the fact, and anyone can verify the list on-chain.
*   **It survives routers.** Matching is on the transaction origin, so a whitelisted wallet gets the floor whether it buys through the app, the public swap page, or any router.
