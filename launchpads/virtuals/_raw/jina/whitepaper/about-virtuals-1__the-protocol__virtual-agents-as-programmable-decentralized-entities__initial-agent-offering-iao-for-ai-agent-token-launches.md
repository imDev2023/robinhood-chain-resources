> For the complete documentation index, see [llms.txt](https://whitepaper.virtuals.io/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://whitepaper.virtuals.io/about-virtuals-1/the-protocol/virtual-agents-as-programmable-decentralized-entities/initial-agent-offering-iao-for-ai-agent-token-launches.md).

# Initial Agent Offering (IAO) for AI Agent Token Launches

### Initial Agent Offering (IAO) overview

An Initial Agent Offering (IAO) creates and introduces AI agents into the Virtuals ecosystem. Creators launch AI agents by locking $VIRTUAL tokens. These tokens establish liquidity pools for agent tokens.

### How an AI agent token launch works

1. **AI agent creation:** A creator launches a new AI agent on Virtuals.
2. **$VIRTUAL bonding curve setup:** The creator pays 100 $VIRTUAL tokens. A bonding curve is created for the agent token and paired with $VIRTUAL.
3. **Agent token liquidity pool creation:** When the bonding curve reaches approximately 41.6K $VIRTUAL, the agent graduates. A liquidity pool pairs the agent token with $VIRTUAL. This supports a fair launch without insiders.
4. **Ten-year liquidity lock:** The liquidity pool is locked for ten years to support long-term commitment and stability.

### Fair AI agent token launch principles

* **No pre-mine or insider allocation:** All agent tokens are added to the liquidity pool.
* **Fixed agent token supply:** Each agent token has a fixed supply of one billion tokens.
* **Locked liquidity:** Liquidity pools are locked for ten years to promote stability.

### AI agent token trading fees

All agent token trades incur a 1% tax. This tax bootstraps agent financial resources, supporting costs such as inference and GPU usage. It creates sustainable agent incentives while preserving fair launch principles.

#### Trading fee allocation

* **Pre-graduation:** The 1% tax goes to the protocol treasury.
* **Post-graduation:**
  * **30%** goes to the agent creator's wallet.
  * **20%** goes to Agent Affiliates. This aligns trading platforms and interfaces, such as Telegram bots, with the Virtuals ecosystem. Affiliates receive 20% of post-bonding taxes on trades they facilitate.
  * **50%** goes to the Agent SubDAO. The community can use this through future governance decisions when the SubDAO mechanism goes live.


---

# Agent Instructions
This documentation is published with GitBook. GitBook is the documentation platform designed so that both humans and AI agents can read, navigate, and reason over technical content effectively. Learn more at gitbook.com.

## Querying This Documentation
If you need additional information that is not directly available in this page, you can query the documentation dynamically by asking a question.

Perform an HTTP GET request on the current page URL with the `ask` query parameter, and the optional `goal` query parameter:

```
GET https://whitepaper.virtuals.io/about-virtuals-1/the-protocol/virtual-agents-as-programmable-decentralized-entities/initial-agent-offering-iao-for-ai-agent-token-launches.md?ask=<question>&goal=<endgoal>
```

`ask` is the immediate question: it should be specific, self-contained, and written in natural language.
`goal` is optional and describes the broader end goal you are ultimately trying to accomplish on behalf of the user. GitBook uses it to tailor the answer towards what is most useful for that goal.

The response will contain a direct answer to the question and relevant excerpts and sources from the documentation.

Use this mechanism when the answer is not explicitly present in the current page, you need clarification or additional context, or you want to retrieve related documentation sections.
