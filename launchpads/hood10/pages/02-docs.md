# HOOD10 - Docs

> Source: https://www.hood10.xyz/docs
> Retrieved: 2026-09-02 (Jina Reader, cross-checked with agent-browser read)
> Screenshot: `screenshots/02-docs.png`

---

## Hold _1._

Own _10._

HOOD10 is a tax token on Robinhood Chain. Every trade pays **5%**. Four fifths of it buys the ten largest tokens on the chain, and those tokens are distributed to holders - on-chain, in kind, every epoch.

## Overview

the loop

Robinhood Chain has ten tokens worth naming and no index that holds them. HOOD10 is that index, and it funds itself out of its own trading volume rather than out of a treasury or a team allocation.

The loop is short. Trades pay tax in **WETH**. The contract accumulates WETH for the length of an epoch. At epoch close it ranks the chain, buys the top ten with the accumulated WETH, and pushes each holder their proportional share of all ten tokens in the same settlement.

**Nothing to claim.** Rewards are airdropped to eligible wallets after each epoch closes - no claim button, no proof to submit, no page you have to come back to. The tokens arrive in your wallet. The distributor is at `0x9f3edbfA…6210`.

## The tax

5% · collected in WETH

Every buy and every sell pays **5%**, collected in WETH. It is never collected in HOOD10, so the contract never has to sell the token to fund a purchase.

4% - dividends

0.7%

0.3%

dividend payout protocol

| wedge | rate | goes to |
| --- | --- | --- |
| Dividend payout | 4.00% | Buys the top ten, distributed to holders in kind |
| Protocol | 0.70% | HOOD10 operations, execution gas, the crank |
| Launchpad | 0.30% | letscash.fun platform fee |
| **Total** | **5.00%** | - |

**80% of every tax dollar is holder money.** The 1% protocol fee is the floor set by launching on letscash plus the cost of running the epoch - ranking, execution and settlement are not free, and the contract pays for them out of its own fee rather than out of the dividend.

## The epoch

every eight hours

An epoch is one full cycle: accumulate, close, rank, buy, distribute. Everything happens on-chain in a single settlement transaction at close.

01**Accumulate**WETH from the 4% dividend wedge collects in the contract for the length of the epoch. Nothing is held off-chain and nothing routes through a personal wallet.

02**Close**The epoch closes. Holder balances are checkpointed in a single block - the snapshot. Balances at any other moment do not count.

03**Rank**The ten largest tokens on Robinhood Chain are read at close. HOOD10 excludes itself.

04**Buy**The accumulated WETH is split ten ways and spent buying each constituent through its canonical pool.

05**Distribute**Every eligible holder receives their proportional share of all ten purchases, pushed to their wallet in the same settlement.

### Epoch length is variable

The crank checks **every eight hours** - 00:00, 08:00 and 16:00 Europe/Rome. It settles only when the accrued tax covers the cost of settlement: ten swaps plus a payout to every eligible wallet. When the tax has not cleared that bar the check passes without closing an epoch, so the interval is a floor on epoch length rather than the length itself.

Short epochs when volume is high, longer epochs when it is quiet. A fixed short interval regardless would spend a rising share of the dividend on gas as volume fell, which is the opposite of what a holder wants.

Epoch length is the one parameter that changes. Every change is written on-chain and visible before the epoch it applies to.

## Selection

by pool liquidity

Constituents are the**ten largest eligible tokens on Robinhood Chain by pool liquidity**, measured at epoch close.

*   **Liquidity, not market cap.** Market cap is trivially faked on a young chain with a thin float. Liquidity is money someone actually left in a pool.
*   **One token, one seat.** A token trading in more than one pool has its pools summed and is counted once. This is an index of ten tokens, not ten pools.
*   **HOOD10 excludes itself.** Buying your own token with your own tax is a buyback, not an index.
*   **Equal split.** The epoch’s WETH is divided ten ways. No weighting, no discretion.

The set is re-read every epoch, so constituents can change between one settlement and the next. What you were paid last epoch does not tell you what you will be paid in the next one.

## Eligibility

0.01% of supply

To receive a dividend, a wallet must hold at least**0.01% of supply** at the snapshot block.

| parameter | value |
| --- | --- |
| Total supply | 1,000,000,000 HOOD10 |
| Minimum holding | 100,000 HOOD10 |
| As a share of supply | 0.01% |
| Maximum eligible wallets | 10,000 |

**The minimum is what makes on-chain distribution possible.** Pushing ten different tokens to an unbounded holder set does not fit in a block at any price. A 0.01% floor caps the eligible set at 10,000 wallets by arithmetic, which bounds the cost of settlement and keeps the whole cycle on-chain.

Below the threshold you still hold HOOD10 and still trade it normally. You are simply not in the distribution set for that epoch.

Pools, the distributor contract and burn addresses are excluded - they would otherwise take slices belonging to holders.

## Distribution

pushed, in kind

Each eligible wallet receives a share of every constituent, proportional to its share of **eligible supply** - the sum of all qualifying balances at the snapshot, not total supply. Balances below the threshold are not counted in the denominator, so nothing is stranded.

epoch_weth        = tax collected this epoch (4% wedge)
per_constituent   = epoch_weth / 10
eligible_supply   = Σ balances ≥ 100,000 at snapshot

your_share        = your_balance / eligible_supply

**you receive = your_share × (amount bought of each of the ten)**
Paid **in kind** - you receive the ten tokens themselves, not a cash equivalent and not more HOOD10. What the contract bought is what lands in your wallet.

### How the airdrop works

At each epoch close the distributor records every eligible balance and buys the ten constituents, and the rewards go out to those wallets. Holding is the only action required of you - nothing to sign, nothing to submit, no deadline to miss.

*   **Holding is the whole job.** Clear the minimum at the snapshot block and your share is sent to you.
*   **Nothing expires.** Rewards are pushed rather than claimed, so there is no window to miss and nothing is forfeited by inaction.
*   **Settled per epoch.** Each epoch is worked out separately against its own snapshot.

## Parameters

fixed at deploy

| parameter | value |
| --- | --- |
| Chain | Robinhood Chain · id 4663 |
| Total supply | 1,000,000,000 |
| Trade tax | 5.00% buy and sell |
| Dividend wedge | 4.00% |
| Protocol fee | 1.00% (0.70% + 0.30%) |
| Fee currency | WETH |
| Constituents | 10, equal split |
| Epoch length | 3 hours, variable |
| Minimum holding | 0.01% - 100,000 HOOD10 |
| Payout | in kind, airdropped on-chain |
| Distributor | 0x9f3edbfA…6210 |
| Constituent weight | 1,000 bps each - 10%, on-chain |
| Liquidity | locked at launch |
| Team allocation | none |

## What it can’t do

no admin key

*   **There is no admin withdrawal.** No function exists to move accumulated WETH or purchased constituents to any address other than holders.
*   **The tax rate cannot be changed.** 5% is fixed at deploy.
*   **The split cannot be changed.** 4% / 1% is fixed at deploy.
*   **The minimum cannot be raised.** 0.01% is fixed at deploy.
*   **Constituents are not chosen by anyone.** The ranking is read from chain state at close.

Epoch length is the only mutable parameter, and every change is on-chain and visible before it takes effect.

## Risks

read this one

*   **No volume, no dividend.** The wedge only fills if HOOD10 trades. A quiet epoch distributes little or nothing.
*   **This is not diversification.** The ten largest tokens on one chain run on one attention cycle. In a drawdown they fall together.
*   **Constituents can go to zero,** and so can HOOD10. You may be paid in a token that is worthless by the time you receive it.
*   **The contract is a buyer in thin pools.** Its own purchases move constituent prices against it, and that effect grows with epoch size.
*   **A 5% tax is a real cost.** Round-tripping a position costs roughly 10% before any price movement.
*   **Falling below the minimum forfeits that epoch,** whatever your balance was an hour earlier.

## What HOOD10 Launchpad is

a venue on Robinhood Chain

[HOOD10 Launchpad](https://launch.hood10.xyz/)deploys coins on Robinhood Chain. There is no bonding curve and no graduation: creating a coin opens a real Uniswap v4 pool in the same transaction, and trading starts immediately.

What you see on a HOOD10 Launchpad chart is a pool price from the first candle - not a curve that later migrates somewhere else.

**You do not seed the liquidity.** The full supply enters the pool at the opening price you set, in the same transaction that creates the coin. Launching costs gas and your own first buy. Nothing else.

**Liquidity cannot be pulled.** The pool position is created by the launcher contract, which is required to end every launch holding nothing - the transaction reverts otherwise. No admin key exists over a live pool. Not the creator’s, and not ours.

## Bonding

pick what your coin is priced in

Every launch chooses its quote asset, and that choice is permanent. It is what your chart is quoted in forever, and it is what your fees pay out in. A coin can be bonded to:

*   **Stablecoins and majors** - USDG, WETH
*   **Tokenized equities** - shares of Robinhood, NVIDIA, Tesla, Coinbase, SpaceX, Strategy and others, priced by Chainlink’s equity feeds at execution
*   **Ecosystem coins** - any admitted Robinhood Chain token, including anything launched here
*   **$HOOD10** - the index itself

A stock-bonded coin’s chart moves with the stock, because the pool holds the equity token as its quote side. Bond to NVIDIA and you earn NVIDIA.

Chainlink’s equity feeds are **24/5**. When the underlying market is shut the feed holds its last close, while the pool keeps trading. The quote does not move on a weekend; the coin still does.

## The fee

1% · none of it to a team wallet

Every trade on the venue pays **1%**.

0.7% - buyback & burn

0.3%

buys and burns $hood10 protocol

| wedge | rate | goes to |
| --- | --- | --- |
| Buyback & burn | 0.70% | Buys $HOOD10 on the open market and burns it |
| Protocol | 0.30% | Gas, the epoch crank, infrastructure |
| **Total** | **1.00%** | - |

The buyback share is collected in whatever asset the launch is bonded to, converted, and executed automatically inside the swap.**A coin with no connection to $HOOD10 still burns $HOOD10 simply by trading.**

There is no launch fee. Creating a coin costs gas and your own first buy.

## The buyback loop

why venue volume raises the dividend

The 0.7% does not only burn supply. It buys $HOOD10 **through the pool**, which means it pays $HOOD10’s own 5% tax like any other buyer - and 4% of that tax is the dividend wedge that buys the top ten and distributes them in kind.

So a trade on a coin you have never heard of does two things at once: it burns $HOOD10, and it pays $HOOD10 holders in ten tokens they never bought.

venue_volume      × 0.70%  = buyback spend
buyback spend     × 4.00%  = dividend wedge
dividend wedge    ÷ 10     = **bought of each constituent**
At **$1M of daily venue volume**, that is roughly**$2.55M a year** of standing bid on $HOOD10, of which about**$102,000 a year** reaches holders as top-ten tokens and the remainder is burnt.

The bid grows with the venue. The supply moves one way.

## Two ways to launch

normal · reflection

### Normal launch

The coin trades clean. The creator decides whether it carries a tax at all - set a rate paid to a wallet you nominate, or set none and let it trade at zero. Either way the 1% venue fee applies, the liquidity is locked, and the supply is fixed.

### Reflection launch

The coin’s tax pays its own holders, **in whatever it is bonded to**. Bond to wtNVDA and holders are paid in NVIDIA. Bond to USDG and they are paid in dollars. Bond to $HOOD10 and they are paid in the index.

Conversion happens on-chain as people trade. No keeper, no claim, no protocol cut on the way through.

The dividend is a percentage of **trading volume**, not a slice of an LP fee. A coin routing 3% to holders on $200,000 of daily volume delivers roughly**$2.2M a year** to the people holding it.

|  | normal launch | reflection launch |
| --- | --- | --- |
| Tax range | 0% - 10% | 0% - 10% |
| Paid to | a wallet you nominate | every holder, pro-rata |
| Paid in | the pair asset | the pair asset |
| Set at | launch, permanently | launch, permanently |

## Setting the tax

up to 10%, once

A creator can set a tax of up to **10%**, once, at launch. It cannot be raised, lowered or removed afterwards - not by the creator, and not by us.

That figure sits on top of the 1% venue fee, so a 10% coin costs a trader 11% in total.

The ceiling is not a policy. Above roughly 10%, round-tripping a position costs more than 20% before any price movement, and the coin stops trading.**A tax nobody pays generates nothing for anybody.**

## Your first buy

optional · capped

Optional, and the only part of a launch that spends anything. It executes atomically inside the launch transaction, before the pool is public, so nobody can front-run the coin you just made.

| setting | share of supply |
| --- | --- |
| None | 0% |
| Small | 1% |
| Standard | 5% |
| Maximum | 10% |

Ask for more and the launch reverts rather than quietly trimming. You pay the opening price you set, the same as any other buyer would in that block.

## What we cannot do

powers that do not exist

The claims above are worth only what the contracts enforce, so here is the list of powers that do not exist:

*   **We cannot touch a live pool.** No pause, no fee change, no liquidity withdrawal. Delisting a pair only stops _new_ launches against it.
*   **We cannot mint.** Launched coins have no mint function and no owner.
*   **We cannot change a coin’s tax.** Neither can its creator. It is fixed at deploy.
*   **We cannot hold your funds.** Trading is wallet-to-pool through a router that custodies nothing.
*   **The index cannot sell.** What it buys leaves only by being distributed to holders. There is no function to write.

Every contract is source-verified on Blockscout.

Links/Buttons:
- [H10HOOD10](https://www.hood10.xyz/)
- [DOCS](https://www.hood10.xyz/docs)
- [LAUNCHPAD](https://launch.hood10.xyz/)
- [01Overview](https://www.hood10.xyz/docs#overview)
- [02The tax](https://www.hood10.xyz/docs#tax)
- [03The epoch](https://www.hood10.xyz/docs#epoch)
- [04Selection](https://www.hood10.xyz/docs#selection)
- [05Eligibility](https://www.hood10.xyz/docs#eligibility)
- [06Distribution](https://www.hood10.xyz/docs#distribution)
- [07Parameters](https://www.hood10.xyz/docs#params)
- [08What it can’t do](https://www.hood10.xyz/docs#limits)
- [09Risks](https://www.hood10.xyz/docs#risks)
- [10What it is](https://www.hood10.xyz/docs#lp)
- [11Bonding](https://www.hood10.xyz/docs#bond)
- [12The fee](https://www.hood10.xyz/docs#lpfee)
- [13The buyback loop](https://www.hood10.xyz/docs#loop)
- [14Two ways to launch](https://www.hood10.xyz/docs#types)
- [15Setting the tax](https://www.hood10.xyz/docs#lptax)
- [16Your first buy](https://www.hood10.xyz/docs#firstbuy)
- [17What we cannot do](https://www.hood10.xyz/docs#cannot)
