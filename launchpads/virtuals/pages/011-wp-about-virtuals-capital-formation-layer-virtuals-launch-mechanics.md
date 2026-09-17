# Virtuals Protocol - Virtuals Launch Mechanics

> Source: https://whitepaper.virtuals.io/about-virtuals/capital-formation-layer/virtuals-launch-mechanics
> Retrieved: 2026-09-02 (GitBook .md endpoint via curl)

---

# Virtuals Launch Mechanics

### How It Works

### 1. [Creation](https://app.virtuals.io/create) Phase

Founders initiate a launch by creating their agent on the Virtuals platform at no cost. Certain modules carry an activation fee: Launch Radar (100 $VIRTUAL), Capital Formation (10 $VIRTUAL), SOL Launch (10 $VIRTUAL). All other modules are free.

During creation, founders configure their launch by toggling modules on or off. Each module is independent. No module requires another module to function.

Once created, an Agent Launch Page is published instantly on the Virtuals Protocol platform, displaying:

* Token supply and distribution parameters
* Active modules and their configurations
* Founding team details
* Product details and agent information

***

### 2. Launch and Early Trading

Once the agent is created, trading opens automatically.

Anyone can trade directly through the Virtuals Protocol platform. There are no presales, whitelists, or gated allocations.

#### **Sniper Tax Mechanism**&#x20;

**If Anti-Sniper Protection is activated:**

The tax starts at 99% and decays to the 1% baseline trading tax across the founder's chosen protection window. Founders select a preset window at creation: 0 seconds, 60 seconds, 10 minutes, or 98 minutes.

* Founders also choose which side of trading the protection applies to: buy only, sell only, or both buy and sell. By default, protection applies to buy-side trading only; sell-side and combined buy-and-sell protection are opt-in.
* All sniper taxes collected during the protection window are automatically used to buy back agent tokens onchain.
* The repurchased tokens are distributed to the team wallet, following a 3-month cliff and 9-month linear vesting schedule.
* This structure protects early liquidity from bots and opportunistic snipers while converting initial volatility into long-term alignment for project founders.

If Anti-Sniper Protection is not activated, trading tax is fixed at 1% from launch.

{% hint style="info" %}

#### **Sniper Tax Mechanism General FAQ**

Can refer to [Anti-Sniper Protection FAQ](/about-virtuals/capital-formation-layer/anti-sniper-protection-for-token-launches.md#anti-sniper-protection-faq)
{% endhint %}

***

### 3. Launch Life Cycle

The creator deploys the agent and initializes its bonding curve. The token becomes immediately tradable on the Virtuals platform. A 1% trading fee applies from day one:

* 70% distributed to the agent creator
* 30% to Virtuals Treasury

For launches using the 60 Days module, the founder's 70% share is locked during the trial period and released only after commitment. If the founder does not commit, this allocation is redirected to the refund pool.

The creator's 70% share can be redirected before claim via the Fee Delegation module: see \[Fee Delegation for Token Launches].

***

### 4. Liquidity Model

As trading continues, the bonding curve automatically accumulates $VIRTUAL liquidity.

Once total liquidity reaches 42,000 $VIRTUAL, a liquidity pool is automatically created and paired with the agent token on Uniswap V2.

After the pool is established, users can trade the token directly on the Virtuals platform, or through any supported DEX, aggregator, or trading bot integrated with the protocol.

This ensures:

* Continuous, verifiable onchain liquidity growth
* Seamless transition from bonding curve to open market
* Full compatibility across all supported trading environments

{% hint style="success" %}
All liquidity pool (LP) tokens generated during agent graduation are automatically staked under a long-term lock of ten (10) years. The purpose of this mechanism is to guarantee liquidity permanence, remove ambiguity around post-launch liquidity control, and ensure that all agents launched through Virtuals operate with long-term, non-extractable liquidity guarantees.
{% endhint %}

***

### **5. Hyperboost**

Hyperboost is a post-graduation reward mechanism that applies automatically to every token that bonds on Virtuals. No module activation or founder configuration is required.

**Mechanism**

Historically, a fraction of token supply remained idle at graduation to maintain a consistent transition into open-market trading. Hyperboost deploys this supply as time-released rewards for post-graduation market participants.

Upon graduation, the reward allocation enters a 14-day distribution schedule:

* 1/14 of the total reward allocation is released each day for 14 days
* Daily rewards are distributed across two categories: trading, allocated to wallets in proportion to their share of the day's trading volume, and content published about the token.&#x20;
* Rewards are claimable at any time once distributed, with no vesting or lockup

Reward parameters, including the allocation size and content evaluation criteria, are set by the protocol and may be adjusted to preserve the integrity of the distribution.

**Purpose**

Over 75% of tokens record their highest-volume 24 hours at graduation. Hyperboost extends market participation beyond this peak by introducing a second incentive window: traders receive rewards for volume they provide, holders benefit from sustained post-graduation liquidity, and founders gain an extended visibility period following graduation.

**Eligibility**

Every token graduating after July 27th 4pm UTC enters Hyperboost automatically.


---

# Agent Instructions
This documentation is published with GitBook. GitBook is the documentation platform designed so that both humans and AI agents can read, navigate, and reason over technical content effectively. Learn more at gitbook.com.

## Querying This Documentation
If you need additional information that is not directly available in this page, you can query the documentation dynamically by asking a question.

Perform an HTTP GET request on the current page URL with the `ask` query parameter, and the optional `goal` query parameter:

```
GET https://whitepaper.virtuals.io/about-virtuals/capital-formation-layer/virtuals-launch-mechanics.md?ask=<question>&goal=<endgoal>
```

`ask` is the immediate question: it should be specific, self-contained, and written in natural language.
`goal` is optional and describes the broader end goal you are ultimately trying to accomplish on behalf of the user. GitBook uses it to tailor the answer towards what is most useful for that goal.

The response will contain a direct answer to the question and relevant excerpts and sources from the documentation.

Use this mechanism when the answer is not explicitly present in the current page, you need clarification or additional context, or you want to retrieve related documentation sections.
