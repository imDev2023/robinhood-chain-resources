# Sentry - Guide, Launch Mechanics

> Source: https://www.sentry.trading/desktop/guide#launch-mechanics
> Retrieved: 2026-09-02 (Jina Reader)
> Raw capture: `_raw/jina/sentry-desktop-guide.md`

---

## Launch Mechanics[](https://www.sentry.trading/desktop/guide#launch-mechanics "Copy link to this section")

Exactly what happens on-chain when a token is deployed through Sentry. This page is the source of truth — if anything in marketing copy disagrees with the mechanics here, the mechanics win.

## What happens at deploy

1.   **Token contract is deployed.** A standard ERC-20 with a fixed supply of **1,000,000,000 tokens** (18 decimals) minted in the deploy transaction. No proxy pattern, no upgrade mechanism, no mint function, no pause function, no blacklist function.
2.   **Contract is immediately renounced.** Ownership is transferred to the dead address in the same transaction. After this block, no one, not the deployer and not Sentry, can mint additional tokens, change parameters, or interact with the contract in any privileged way. It is, by EVM definition, immutable.
3.   **The LP is created and locked.** 100% of the supply is deposited as a single-sided position. New launches on both chains live in a **Uniswap v4** dynamic-fee pool: the trade fee starts at 40% at launch (an anti-snipe tax that makes block-zero bots pay dearly), holds there for 3 minutes, then halves every 3 minutes until it reaches a permanent **1.7% floor** about 17 minutes in. The position is held permanently by the **SentryLPVault**, an immutable contract with no withdrawal function of any kind. It is not a proxy and cannot be upgraded. No timer, no unlock, ever.
4.   **Trading opens to everyone in the same transaction.** Once the LP exists, the token is tradable by anyone. There is no presale and no privileged buying window — nobody, creator included, can buy before the pool is public. The creator's optional dev buy (or the automatic 0.00001 ETH seed buy from the creator's wallet if there isn't one) runs as a separate swap right after the deploy, at the same market price any other buyer would get. The optional **launch whitelist** changes the _fee_ a listed wallet pays during the anti-snipe window, never its access or its price — see [Anti-Snipe Protection](https://www.sentry.trading/desktop/guide#anti-snipe).

## What is NOT in a Sentry launch

*   **No pre-loaded tokens.** Every token that ends up in a wallet got there via a public on-chain swap against the LP. Nothing was airdropped, allocated, or pre-distributed.
*   **No team allocation.** Sentry doesn't reserve any portion of the supply for itself, the deployer, or any other party. 100% goes into the LP.
*   **No dev wallet holding tokens.** The deployer's EOA has zero tokens in it the moment the deploy completes — they can only acquire tokens by buying from the public LP at market price, same as everyone else.
*   **No admin keys.** The renounced contract has no owner, no governor, no upgrader. There is no role that can change anything.
*   **No timed LP unlock.** The vault's custody of the position is not on a timer that releases it back to the deployer later. It's permanent, and the vault has no code path that could return it.

## Locked LP still earns fees, and creators get the majority

Locking the LP takes withdrawal off the table, not the trading fees. On every current launch — both chains, same contracts, same numbers — the pool's own LP fee is set to zero and the hook settles every leg _per swap_, so nothing accrues to the position and there is nothing to claim later. At the 1.7% floor a WETH launch pays **1.0% to the creator**, 0.2% compounded back into the token's own liquidity, and 0.5% to the protocol. Launches with reflections enabled, and stock-paired launches, instead pay 0.8% to holders, 0.5% to the creator, 0.2% into liquidity, and 0.2% to the protocol. The protocol leg doesn't just sit in a wallet either: it routes through the on-chain Treasury Splitter — 60% operations, **40% compounded into permanently locked SENTRY liquidity** (see [The SENTRY Token](https://www.sentry.trading/desktop/guide#sentry-token)).

Legacy **V3-era** launches (from before the v4 stack) work the older way: fees accrue to the locked position on both sides of the pair, and collecting them splits **70% / 30%** between the creator and the Sentry treasury on Robinhood Chain (**65% / 35%** on Ink). Every split is enforced by the contract and readable on-chain. Full details in [Creator Rewards](https://www.sentry.trading/desktop/guide#creator-rewards).

## The optional dev buy

The Create form lets the deployer optionally swap ETH for tokens at deploy time. This is just a normal swap: same router and same slippage rules as any subsequent buy, executed against the freshly-created LP at the same market price the very next buyer would pay. It is not a privileged allocation; it's a public swap that happens right after the deploy. Because the launching wallet is whitelisted, the dev buy pays the 1.7% floor fee rather than the anti-snipe rate — the price is the market's, only the fee differs.

## Verifying it yourself on the explorer

Don't take any of this on faith — for any Sentry-deployed token, the entire sequence is verifiable on [explorer.inkonchain.com](https://explorer.inkonchain.com/) (Ink) or [robinhoodchain.blockscout.com](https://robinhoodchain.blockscout.com/) (Robinhood Chain):

*   **Token contract:** search the address. The owner read returns the dead address. There are no `Mint` events after the deploy block.
*   **The pool:** holds the entire supply at deploy. Subsequent swaps move balances around, but the pool itself is immutable V3 code.
*   **LP position NFT:** the position is held by the Sentry Launch Factory contract, not by the deployer's EOA, and the factory has no function that can transfer it out.
*   **Deploy transaction:** bundles the ERC-20 deploy, ownership renouncement, LP creation, and lock into one tx. The Sentry factory contract is the caller; the deployer EOA only signs the transaction that triggers the bundle.
