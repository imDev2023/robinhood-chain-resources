# hood.fun - Whitepaper

> Source: https://hood.fun/whitepaper
> Retrieved: 2026-09-02 (Jina Reader)
> Note: Re-fetched 2026-09-03 and byte-identical apart from Jina's own trailing link list, which this capture keeps.

---

Title: hood.fun — Launch & Trade Coins on Robinhood Chain

URL Source: https://hood.fun/whitepaper

Markdown Content:
## 1. Overview

hood.fun lets anyone launch a token in one transaction. Every token starts trading immediately on a bonding curve — a smart contract that quotes a price from its own reserves — with no presale, no team allocation, and no way for the deployer to pull liquidity. When a token's curve sells out, its liquidity migrates to official Uniswap v3 and the position is locked forever in a locker with no withdraw function — the pool can never be rugged, and its trading fees keep paying the creator for life.

The protocol is a compact set of non-upgradeable contracts — the launchpad curve, the Uniswap v3 migrator, and an ownerless liquidity locker — deployed on Robinhood Chain, an Arbitrum-stack Ethereum L2. Gas is paid in ETH. Nothing about a launch depends on hood.fun staying online — the contracts run on their own.

## 2. The bonding curve

Each token uses a constant-product curve with virtual reserves — the same x·y=k math that powers Uniswap, seeded so price starts low and rises smoothly as tokens are bought. Buyers pay ETH into the curve and receive tokens; sellers return tokens for ETH. Price is always a deterministic function of how much of the curve supply has been sold — early buyers pay less, later buyers pay more.

Because pricing is virtual-reserve based, there is deep, continuous liquidity from the very first trade — no empty order books, no waiting for a market maker.

## 3. Parameters

Total supply is chosen at launch — anywhere from 1 to 1,000,000,000,000,000 (one quadrillion) tokens. The curve seeds scale with the supply you pick, so the ETH economics are identical no matter what: same seed price, same raise to graduate, same graduation market cap — only the token count and price-per-token change. The figures below use the 1,000,000,000 default.

Total supply 1 – 1,000,000,000,000,000 (default 1B)

Sold on the curve 80% of supply

Paired on Uniswap at graduation 20% of supply

Virtual ETH seed 2.81 ETH

Approx. raise to graduate~6.5 ETH

Graduation market cap~26.9 ETH (~$44k)

Quote asset ETH

## 4. Fees & revenue

Every trade pays a flat 1% fee on the curve, charged on every buy and sell. Creators keep 80% of that fee; the protocol takes the other 20%. Creator earnings accrue on-chain per token and are claimable at any time from the creator's profile.

Launching a coin is free — you pay only gas. There is no creation fee and no mandatory first buy; a creator's optional launch buy is capped like any other wallet.

Trade fee 1% flat

Creator share of fees 80%

Protocol share of fees 20%

Migration fee 0.05 ETH + 3% of raise + 0.5 ETH protocol

Creation fee 0 ETH (gas only)

Post-graduation pool fee 1% per swap — ETH side 80% creator / 20% protocol; token side burned

Fees are fixed per coin at launch. Each token snapshots its fee terms — including the protocol migration fee — when it is created, so they can never be changed after the fact, by anyone.

Fees don't stop at graduation.The Uniswap v3 pool every coin migrates into charges a 1% fee on each swap. Because the pool's liquidity position stays locked in the hood.fun Locker (rather than being burned), it keeps earning that fee — the ETH side split 80% creator / 20% protocol forever, and the token side burned. Anyone can trigger a collection; nobody can redirect it. If other people later add their own liquidity to the pool, they earn the fee share of their own positions — the locked position's earnings continue unchanged.

## 5. Graduation & liquidity

When the last curve token is sold, the token graduates. Anyone can then call the permissionless migrate function — it pairs the raised ETH (minus the migration fee) with the 200M reserved tokens in a 1% fee pool on the official Uniswap v3 deployment on Robinhood Chain, then locks the entire liquidity position in the hood.fun Liquidity Locker.

The locker has no withdraw function, no owner, and no admin— the code that could move the liquidity simply does not exist, so no team, no deployer, and no key compromise can ever pull it. Unlike burning LP, locking keeps the position alive: it earns the pool's 1% swap fee forever — the ETH side paid out 80% creator / 20% protocol, the token side burned. This is the same locked-position model that secures the largest v3 launchpads. Migration is idempotent and safe against a pre-existing pool, so it cannot be manipulated by front-running — a class of exploit that has hit other EVM launchpads.

## 6. Creator & holder features

hood.fun ships the tools creators and communities actually use — every one enforced on-chain, none requiring trust in the platform.

*   Custom supply. Choose any total supply from 1 to one quadrillion tokens at launch; the curve scales so the ETH economics stay identical.
*   Free, fair launches. No creation fee, no presale, no team allocation, no mandatory buy — deploy for the cost of gas, and the curve is open to everyone from the first block.
*   Creator fees for life. Creators earn 80% of every trade fee on the curve and 80% of the ETH-side Uniswap fee after graduation — accruing on-chain and claimable at any time.
*   Community mode. Launch a coin whose creator fees stream back to its holders pro-rata instead of to one wallet — sent automatically, with no claiming and no gas for holders.
*   Community takeover (CTO). If a creator abandons a coin, its future fee stream can be handed to a new team that revives it — behind a 7-day public timelock, with already-earned fees preserved for the original creator, and the recipient can never be the protocol itself.
*   Creator handoff.A creator can transfer their own coin's future fees to another wallet at any time — for sales, team changes, or a DAO treasury.
*   Anti-snipe & anti-drain. An opt-in launch guard caps each wallet in the first minutes, and a 5%-of-curve per-wallet cap — on by default — stops any single buyer from hoarding enough to drain the pool at graduation.
*   Rich coin pages. Verified socials (X, Telegram, website), custom banners, live charts, and holder-gated community boards on every coin.

## 7. Security & custody

hood.fun is fully non-custodial. Users sign their own transactions with their own wallets; the platform never signs, holds, or routes user funds. The only privileged role is the protocol owner — a 2-of-3 multisig (Gnosis Safe), so no single key controls it. Its powers are deliberately narrow and further constrained in code: it can adjust fee configuration for future launches only (every coin's fees are snapshotted and frozen at its own launch), propose a new migrator only behind a 7-day public timelock, hand off abandoned coins under the CTO rules above, and withdraw the protocol's accrued fee share. It can never touch curve reserves, user balances, or locked liquidity.

Additional protections built into the contract:

*   Per-token fee snapshot. Each coin freezes its fee terms at launch — the owner cannot change fees on an already-launched coin, ever.
*   Anti-drain wallet cap. A 5%-of-curve per-wallet cap is on by default (creators may disable it), so no single wallet can hoard enough to drain a pool right after graduation.
*   Timelocked migrator. The migration contract can only be changed behind a 7-day public timelock — a graduated coin can never be silently rerouted through a malicious migrator.
*   Verified migration. Migration checks it is depositing into the canonical Uniswap pool at the correct price (reverting on a squatted pool) and locks the LP position atomically in the same transaction.
*   Tokens are non-transferable outside the curve until graduation, closing pre-seeded-pair exploits.
*   Slippage bounds (minimum-out) enforced on every trade; reentrancy guards throughout.
*   A launch snipe-guard caps any single wallet during the first blocks after creation.
*   Fee caps enforced on-chain — no fee can exceed the coded maximum, and the total migration take is clamped so it can never brick a graduation.

ETH conservation and solvency are verified by an invariant-fuzzing test suite: across any sequence of trades, graduations, and claims, the contract always holds exactly what it owes — to the wei.

## 8. Disclaimer

hood.fun is experimental software for launching and trading memecoins. Memecoins are highly volatile and most go to zero. Nothing on this site is financial advice. Do your own research, and never risk more than you can afford to lose.

Links/Buttons:
- [HOODfun](https://hood.fun/)
- [Create](https://hood.fun/create)
- [Swap](https://hood.fun/swap)
- [Bridge](https://hood.fun/bridge)
- [Profile](https://hood.fun/portfolio)
- [1. Overview](https://hood.fun/whitepaper#overview)
- [2. The bonding curve](https://hood.fun/whitepaper#curve)
- [3. Parameters](https://hood.fun/whitepaper#params)
- [4. Fees & revenue](https://hood.fun/whitepaper#fees)
- [5. Graduation & liquidity](https://hood.fun/whitepaper#graduation)
- [6. Creator & holder features](https://hood.fun/whitepaper#features)
- [7. Security & custody](https://hood.fun/whitepaper#security)
- [8. Disclaimer](https://hood.fun/whitepaper#disclaimer)
- [@hooddotfun on X](https://x.com/hooddotfun)
- [t.me/hooddotfun](https://t.me/hooddotfun)
- [Whitepaper](https://hood.fun/whitepaper)
- [Terms](https://hood.fun/terms)
- [contact@hood.fun](mailto:contact@hood.fun)
