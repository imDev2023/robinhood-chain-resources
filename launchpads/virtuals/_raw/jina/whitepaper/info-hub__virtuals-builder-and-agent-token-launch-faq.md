> For the complete documentation index, see [llms.txt](https://whitepaper.virtuals.io/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://whitepaper.virtuals.io/info-hub/virtuals-builder-and-agent-token-launch-faq.md).

# Virtuals Builder & Agent Token Launch FAQ

{% hint style="info" %}
The FAQ reflects the current system as of Aug 14, 2026. Details may evolve over time as the protocol iterates.
{% endhint %}

{% hint style="info" %}

## Can't find what you need?

Raise a ticket with our [Discord Support](https://discord.com/invite/virtualsio).
{% endhint %}

### Virtuals Protocol builder and agent token launch FAQ

Find answers about launching and tokenizing an agent on Virtuals Protocol. This FAQ covers launch support, trading tax distribution, and vested token claims.

<details>

<summary>How to launch/tokenize an agent on Virtuals Protocol?</summary>

Start with [Virtuals Launch Mechanics](/about-virtuals/capital-formation-layer/virtuals-launch-mechanics.md). It covers creation, trading, liquidity, and graduation.

</details>

<details>

<summary>How to get support on my agent launch?</summary>

See [Agent Launch Support](/info-hub/builders-hub/agent-launch-support.md) for marketing and technical support resources.

</details>

<details>

<summary>How are trading taxes tracked and processed on Base?</summary>

To track trading tax flow on Base, there are three methods:<br>

**Option 1: Track from Virtuals Tax Checker Dashboard**\
\
You can track your agent's trading fee accumulation and distribution status through the official [Virtuals Tax Checker Dashboard](https://dune.com/virtual_protocol/tax-checker).\
\
Scroll down to the section labeled “Virtual not distributed breakdown by project” and sort the table to view pending distributions.

Notes:

* Fee distribution is triggered when an agent token's trading tax accumulates to 1 $VIRTUAL or more. *(Details Above)*

**Option 2: Trace Through Contracts**

1. Token Swap to Tax Swapper\
   \
   Agent token trades that incur a tax will route to the Tax Swapper:\
   \
   0x8e0253dA409Faf5918FE2A15979fd878F4495D0E<br>
2. Swapper Converts to $VIRTUAL → Sent to Tax Manager\
   \
   The Tax Swapper converts taxed tokens to $VIRTUAL, then sends the output to the Tax Manager:\
   \
   0x7e26173192d72fd6d75a759f888d61c2cdbb64b1<br>
3. Tax Manager Distributes Fees in $VIRTUAL\
   \
   The Tax Manager distributes fees directly in $VIRTUAL to the creator and the platform.

**Option 3: Read from Tax Manager Contract**

Use Function 5 on the Tax Manager proxy contract:

[BaseScan - Tax Manager Contract](https://basescan.org/address/0x7e26173192d72fd6d75a759f888d61c2cdbb64b1#readProxyContract)

This function returns current stats on distribution balances.

</details>

<details>

<summary>How are agent trading taxes tracked and processed on Solana?</summary>

On Solana, tax proceeds are sent directly from the agent wallet to the creator’s distribution wallet.

* If the destination wallet is unknown, creators should contact the Virtuals team for verification.
* Alternatively, distributions can be monitored via the LP fee distribution wallet:

  9WBoFXeAbskmi6aMK5jvyNgXVKeZrcVeFJtDBLikzdnm

</details>

<details>

<summary>How is trading tax processed and distributed?</summary>

Trading tax accumulates for each agent token. Once an agent token’s trading tax reaches 1 $VIRTUAL or more, the system swaps it into USDC and distributes it to token owners.

</details>

<details>

<summary>How are vested tokens claimed?</summary>

Vested tokens are not auto-distributed.

Recipient wallets must log in to [app.virtuals.io](https://app.virtuals.io) and manually claim any vested tokens.

</details>

### Agent token launch planning and configuration

<details>

<summary>How does my token move from launch to a liquidity pool?</summary>

Trading opens when the agent is created. The bonding curve graduates into a liquidity pool at 42,000 $VIRTUAL. See [Virtuals Launch Mechanics](/about-virtuals/capital-formation-layer/virtuals-launch-mechanics.md) for the full lifecycle.

</details>

<details>

<summary>How can I protect my launch from early sniping?</summary>

Enable Anti-Sniper Protection during creation. It applies a decaying tax across your selected protection window. Review [Anti-Sniper Protection for Token Launches](/about-virtuals/capital-formation-layer/anti-sniper-protection-for-token-launches.md) before configuring it.

</details>

<details>

<summary>What is the 60 Days module, and when should I use it?</summary>

60 Days is an optional founder trial. It lets you validate demand before committing long term. Read [60 Days](/about-virtuals/capital-formation-layer/60-days.md) for commitments, refunds, and funding rules.

</details>

<details>

<summary>How does Fee Delegation support launches for my project?</summary>

Fee Delegation lets anyone launch an AI agent token while reserving the creator fee share for you.

The launcher identifies you with your X handle or wallet address. The creator's 70% share of trading fees accrues to a balance linked to that identity. The launcher cannot claim this balance.

Verify the linked profile on Virtuals Protocol to claim accrued fees. Future fees then flow directly to you. See [Fee Delegation for Token Launches](/about-virtuals/capital-formation-layer/fee-delegation-for-ai-agent-token-launches.md).

</details>

<details>

<summary>Why do developer wallets receive staked tokens when a liquidity pool is created?</summary>

When a liquidity pool is launched through Virtuals Protocol, the pool creator is the owner of the LP. To ensure permanence and prevent liquidity extraction, all LP tokens are immediately staked and locked for the long term.

The protocol then transfers the staked LP position back to the creator’s wallet. This means:

* Ownership → the creator retains ownership of the LP
* Locked liquidity → LP tokens are staked for years and cannot be withdrawn
* Ecosystem alignment → liquidity remains permanently secured, while the project retains ownership rights

This mechanism is standardized across Virtuals Protocol. Every pool is designed to be creator-owned but protocol-secured to protect both builders and participants.

</details>


---

# Agent Instructions
This documentation is published with GitBook. GitBook is the documentation platform designed so that both humans and AI agents can read, navigate, and reason over technical content effectively. Learn more at gitbook.com.

## Querying This Documentation
If you need additional information that is not directly available in this page, you can query the documentation dynamically by asking a question.

Perform an HTTP GET request on the current page URL with the `ask` query parameter, and the optional `goal` query parameter:

```
GET https://whitepaper.virtuals.io/info-hub/virtuals-builder-and-agent-token-launch-faq.md?ask=<question>&goal=<endgoal>
```

`ask` is the immediate question: it should be specific, self-contained, and written in natural language.
`goal` is optional and describes the broader end goal you are ultimately trying to accomplish on behalf of the user. GitBook uses it to tailor the answer towards what is most useful for that goal.

The response will contain a direct answer to the question and relevant excerpts and sources from the documentation.

Use this mechanism when the answer is not explicitly present in the current page, you need clarification or additional context, or you want to retrieve related documentation sections.
