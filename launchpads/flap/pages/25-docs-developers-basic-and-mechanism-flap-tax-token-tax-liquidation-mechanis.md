# Flap - Tax Liquidation Mechanism

> Source: https://docs.flap.sh/flap/developers/basic-and-mechanism/flap-tax-token/tax-liquidation-mechanism
> Retrieved: 2026-09-02 (GitBook markdown export, https://docs.flap.sh/flap/developers/basic-and-mechanism/flap-tax-token/tax-liquidation-mechanism.md)

---

> For the complete documentation index, see [llms.txt](https://docs.flap.sh/flap/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://docs.flap.sh/flap/developers/basic-and-mechanism/flap-tax-token/tax-liquidation-mechanism.md).

# Tax Liquidation Mechanism

{% hint style="info" %}
This page explains **how tax gets collected and converted into rewards** for holders, in plain terms. Some technical detail is included for developers, but you don't need to read Solidity to follow along.
{% endhint %}

## Overview

Every time someone buys or sells a Flap tax token, a small percentage is taken as **tax**. What happens to that tax next depends on one thing: **has the token's bonding curve finished (migrated to a DEX) or not?**

```mermaid
flowchart LR
    A[User buys/sells] --> B{Where does the trade happen?}
    B -->|Still on the Bonding Curve| C[Quote token tax paid directly]
    B -->|Migrated to DEX| D[Tax token itself accumulates]
    C --> E[Tax Processor]
    D -->|Threshold reached + trade through main pool| F[Liquidation: swap tax token → quote]
    F --> E
    E --> G[Fee / Market / LP / Burn buckets]
    E --> H[Dividend Contract]
    H --> I[Holders claim rewards]
```

The rest of this page walks through each stage of that diagram.

***

## 1. How tax is charged

### While still on the Bonding Curve

Before a token graduates to a DEX, all trading happens directly against Flap's bonding curve - there is no pool yet, so there is nothing to "liquidate." The tax is taken **in the quote token itself**, at the moment of the trade, and forwarded straight to the Tax Processor.

* If the quote is **BNB** (or another chain's native gas token), the trade contract wraps it into WBNB (or the equivalent wrapped native token) and forwards it.
* If the quote is an **ERC-20** (e.g. a token like `SPCXB`), it's forwarded as-is - no wrapping needed.

```mermaid
sequenceDiagram
    participant U as User
    participant BC as Bonding Curve (Portal)
    participant TP as Tax Processor

    U->>BC: Buy or sell (pays in BNB or ERC-20 quote)
    BC->>BC: Calculate tax amount (in quote token)
    alt Quote is BNB (native)
        BC->>BC: Wrap BNB → WBNB
        BC->>TP: processBondingCurveTax(WBNB amount)
    else Quote is ERC-20 (e.g. SPCXB)
        BC->>TP: processBondingCurveTax(SPCXB amount)
    end
    TP->>TP: Split into fee / market / LP / burn / dividend buckets
```

There's no waiting, no threshold, no separate "liquidation" step here - the quote token tax is already in the currency everyone wants (BNB, SPCXB, USDT, etc.), so it can be split and forwarded immediately.

### After the token migrates (is listed on a DEX)

Once a token graduates and starts trading on a DEX pool (PancakeSwap / Uniswap / a Uniswap-v2-style fork), the mechanism changes. The tax token contract now taxes trades **in the tax token itself** - every taxed buy or sell leaves a small amount of the *tax token* sitting inside the token's own contract balance.

That balance just sits there, growing with every trade, until it's large enough to be worth converting - that conversion step is called **liquidation** (covered in the next section).

```mermaid
flowchart TD
    subgraph BondingCurve["While on Bonding Curve"]
        BC1[Trade tax] --> BC2["Paid directly in quote token<br/>(BNB / SPCXB / etc.)"]
        BC2 --> BC3[Forwarded immediately to Tax Processor]
    end

    subgraph Migrated["After migration to DEX"]
        M1[Trade through pool] --> M2["Tax paid in the TAX TOKEN itself"]
        M2 --> M3["Accumulates inside the token contract's own balance"]
        M3 -->|Threshold reached| M4[Liquidation triggered]
        M4 --> M5[Swapped to quote token via the pool]
        M5 --> BC3
    end
```

***

## 2. When does liquidation trigger?

Liquidation only applies to **migrated** (DEX-listed) tokens - bonding curve tokens never need it, since their tax is already in quote-token form.

Two conditions must **both** be true for a liquidation to fire:

1. **The accumulated tax-token balance has reached the current liquidation threshold.**
2. **Someone is trading through the token's&#x20;*****main pool*** - the primary PancakeSwap/Uniswap-v2(-fork) pool paired with the token's quote token. Liquidation is checked (and can only trigger) on transfers that touch this pool; trades on unrelated/secondary pools don't count.

```mermaid
flowchart TD
    T[Someone trades through the main pool] --> C1{"Accumulated tax-token<br/>balance ≥ threshold?"}
    C1 -->|No| Skip[No liquidation - balance keeps growing]
    C1 -->|Yes| L[Liquidation runs]
    L --> S["Swap accumulated tax token → quote token<br/>(through the same main pool)"]
    S --> Adj{Was the swap price better or worse than expected?}
    Adj -->|Worse - big price impact| Down["Lower the threshold<br/>(liquidate smaller amounts, more often)"]
    Adj -->|Better - small price impact| Up["Raise the threshold<br/>(wait longer, liquidate bigger batches)"]
    Down --> Next[Threshold adjusts for next round]
    Up --> Next
```

### The threshold is dynamic, not fixed

The liquidation threshold **self-adjusts after every liquidation** - it isn't a fixed number. It moves within a range that's typically **50,000 to 400,000 tokens**, depending on the specific token's configuration:

* If a liquidation caused **more price impact than expected** (the swap was "expensive" - the price moved a lot), the threshold is **lowered** so future liquidations sell smaller amounts more frequently. Smaller, more frequent sells put less pressure on the price each time.
* If a liquidation caused **less price impact than expected** (there was plenty of liquidity to absorb it), the threshold is **raised** toward its starting ceiling, so the contract waits for more tokens to build up before selling again.

This means the mechanism is self-correcting: in a thin/volatile market it automatically liquidates in smaller, gentler batches; in a healthy/liquid market it can afford to wait and batch more together.

{% hint style="info" %}
**Why gate liquidation on "the main pool" specifically?** The main pool is where price discovery actually happens for the token. Restricting the liquidation check to main-pool trades (rather than any transfer) keeps the tax mechanism predictable and prevents it from firing based on unrelated token movement (e.g. wallet-to-wallet transfers, or activity on some other unrelated pool).
{% endhint %}

***

## 3. How the dividend mechanism works

Flap tax tokens can automatically reward holders with a share of the tax revenue. This works through two connected pieces: **share tracking** (who owns how much, updated on every transfer) and **dividend deposits** (rewards flowing in, distributed proportionally).

### Step A - every transfer updates your "share"

Every time tokens move - a buy, a sell, or a plain wallet-to-wallet transfer - the tax token contract calls into a separate **Dividend contract** to record the sender's and receiver's *new* balance as their "share." Your share is simply your current token balance (some addresses, like pools and the contracts themselves, are excluded).

```mermaid
sequenceDiagram
    participant From as Sender
    participant To as Receiver
    participant Token as Tax Token Contract
    participant Div as Dividend Contract

    From->>Token: transfer(to, amount)
    Token->>Token: Move balances (minus tax, if any)
    Token->>Div: setShare(from, newBalanceOfFrom)
    Token->>Div: setShare(to, newBalanceOfTo)
    Div->>Div: Settle any pending rewards for the old share, then record the new share
```

### Eligibility - when do you actually count as a holder?

* You must hold **at least the minimum share balance** the token was configured with (some tokens set this to a small non-zero amount to filter out dust holders; others accept any balance above zero).
* Certain addresses are **always excluded**, no matter their balance: the token contract itself, the burn address, the Dividend contract, the Tax Processor, and any registered trading pool. This prevents tax revenue from effectively being paid to itself or to liquidity pools instead of real holders.
* Being excluded or below the minimum sets your recorded share to **zero** - you stop accruing new rewards from that point on, though anything already earned remains claimable.

### Step B - where liquidated funds go before reaching holders

When a liquidation happens (or when quote-token tax arrives directly from the bonding curve), the proceeds don't go straight to holders. They pass through the **Tax Processor** first, which splits the incoming amount into buckets according to the token's configuration - for example: protocol fee, marketing/vault share, liquidity, burn (deflation), and **dividend**.

Only the portion allocated to the **dividend bucket** continues on to the Dividend contract. The Tax Processor accumulates this dividend portion, and periodically (via `dispatch()`) pushes it - as an actual token deposit - into the Dividend contract.

```mermaid
flowchart TD
    A["Tax revenue arrives<br/>(from bonding curve OR liquidation)"] --> TP[Tax Processor]
    TP --> Split{Split into buckets}
    Split --> Fee[Protocol fee]
    Split --> Market[Marketing / Vault]
    Split --> LP[Liquidity]
    Split --> Burn[Burn / Deflation]
    Split --> DivBucket[Dividend bucket]
    DivBucket -->|dispatch| Deposit["Dividend.deposit(amount)"]
    Deposit --> AccUpdate["Update accumulator:<br/>accPerShare += amount / totalShares"]
    AccUpdate --> Holders["All current eligible holders'<br/>claimable rewards increase proportionally"]
```

### Step C - how a deposit turns into "your" claimable rewards

The Dividend contract uses a well-known, gas-efficient pattern often called **"accumulated rewards per share"** (the same idea used by many staking/farming contracts). Here's the intuition, without the math notation:

1. The contract keeps one running number: **rewards accumulated per unit of share, ever** (`accPerShare`). Every time a deposit lands, this number increases by `deposit amount ÷ total shares outstanding at that moment`.
2. Each holder's claimable balance is effectively `(their share × the current accPerShare) − (their share × the accPerShare value from the last time their share changed or they claimed)`.
3. Because the accumulator only moves forward and each holder's personal "starting point" is recorded whenever their share changes (or they claim), this correctly gives everyone their **proportional slice of every deposit that happened while they held their current share** - without the contract needing to loop over every holder on every deposit.

```mermaid
flowchart LR
    subgraph Global["Global state (one accumulator)"]
        Acc["accPerShare<br/>(increases on every deposit)"]
        Total["totalShares<br/>(sum of all eligible holders' shares)"]
    end

    subgraph PerUser["Per-holder state"]
        Share["share<br/>(= token balance, if eligible)"]
        Debt["rewardDebt<br/>(accPerShare snapshot at last share change/claim)"]
        Pending["pendingBalance<br/>(rewards settled but not yet claimed)"]
    end

    Deposit[New deposit arrives] --> Acc
    Acc --> Claimable["Claimable = share × accPerShare − rewardDebt + pendingBalance"]
    Share --> Claimable
    Debt --> Claimable
    Pending --> Claimable
```

A practical consequence of this design: **you only earn rewards for the time you actually hold an eligible balance.** If you buy in after a big deposit already happened, your `rewardDebt` snapshot is set to the *current* accumulator value, so you don't retroactively get a share of rewards that were deposited before you held any tokens. Conversely, once you're holding, every future deposit is automatically counted for you - no need to "stake" or opt in separately; simply holding the token is enough.

### Claiming

Holders (or anyone calling on their behalf) can withdraw their claimable balance at any time. The reward token you receive depends on the tax token's configuration - it might be the quote token (e.g. BNB/WBNB), the tax token itself, or a different ERC-20 entirely; whichever was chosen as the token's "dividend token" at launch.

### Anyone can pay the gas to send *your* dividend to *you*

This is a subtle but genuinely useful feature of the Dividend contract: claiming is **permissionless on behalf of others**. There is no requirement that a holder pays their own gas to receive their rewards - any address, call it **A**, can trigger a withdrawal **for** another holder, call it **B**, and the reward tokens still land in **B's** wallet. A only pays the gas; A never receives B's funds.

```mermaid
sequenceDiagram
    participant A as Address A (pays gas)
    participant Div as Dividend Contract
    participant B as Address B (holder)

    A->>Div: withdrawDividendsFor(B)
    Div->>Div: Calculate B's claimable balance
    Div->>B: Send reward tokens directly to B
    Note over A,B: A never receives B's funds - A only paid the gas
```

Why would anyone bother paying gas to claim for someone else? Because it opens the door to **automated reward delivery** - you don't need every holder to remember to claim manually.

**Flap runs exactly this kind of automation as an off-chain bot:**

1. The bot continuously watches each holder's pending (claimable) dividend balance - the same `withdrawableDividendOf(user)` value described in [Step C](#step-c-how-a-deposit-turns-into-your-claimable-rewards) above.
2. Once a holder's pending rewards cross a **$4 USD-equivalent threshold**, the bot calls the withdraw-for-user function on their behalf.
3. The bot pays the gas for that transaction; the reward tokens are still sent directly to the holder's own wallet.

```mermaid
flowchart TD
    Bot["Off-chain bot"] -->|"1. Continuously polls"| Check["Holder's pending dividend balance"]
    Check --> Threshold{"Pending rewards ≥ $4?"}
    Threshold -->|No| Wait["Keep monitoring, do nothing"]
    Threshold -->|Yes| Pay["Bot pays gas: withdrawDividendsFor(holder)"]
    Pay --> Send["Reward tokens sent directly to the holder's wallet"]
```

The practical effect: small holders who might never bother claiming a few dollars' worth of rewards (because the gas cost isn't worth their own time or money) still get paid out automatically, without ever having to sign a transaction or spend their own gas.

***

## Summary

| Stage                   | Bonding Curve phase                                                       | After migration (DEX)                                                |
| ----------------------- | ------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| Tax is collected in     | Quote token (BNB/WBNB, or the ERC-20 quote, e.g. SPCXB)                   | The tax token itself                                                 |
| Where it accumulates    | Forwarded to Tax Processor immediately                                    | Inside the tax token contract's own balance                          |
| Trigger to move forward | None needed - already in quote form                                       | Liquidation: threshold reached **and** a trade through the main pool |
| Threshold behavior      | N/A                                                                       | Dynamic, self-adjusting (typically \~50k-400k tokens)                |
| Final destination       | Tax Processor → fee/market/LP/burn/dividend buckets                       | Same - once liquidated into quote token                              |
| Holder rewards          | Dividend bucket deposited into Dividend contract → accPerShare accounting | Same                                                                 |

Whether a token is still bonding or already trading on a DEX, tax revenue always ends up flowing through the same **Tax Processor → Dividend contract** pipeline - the only thing that changes is *what form* the tax is in before it gets there, and *what has to happen* to convert it into that form.
