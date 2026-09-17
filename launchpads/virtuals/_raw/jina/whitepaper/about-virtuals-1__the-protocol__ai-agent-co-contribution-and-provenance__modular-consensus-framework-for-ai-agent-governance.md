> For the complete documentation index, see [llms.txt](https://whitepaper.virtuals.io/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://whitepaper.virtuals.io/about-virtuals-1/the-protocol/ai-agent-co-contribution-and-provenance/modular-consensus-framework-for-ai-agent-governance.md).

# Modular Consensus Framework for AI Agent Governance

The Virtuals Protocol Modular Consensus Framework standardizes AI agent contributions, validation, and governance. It gives contributors, validators, and token holders transparent processes for supporting VIRTUAL agents.

### AI agent contribution process

Contributors submit proposals through the Virtuals frontend using the Modular Consensus Framework.

* **Contribution NFTs:** Every proposal creates a contribution NFT. This authenticates the origin of each submission, whether accepted or rejected.
* **Immutable Contribution Vault (ICV):** Accepted contributions mint as onchain service NFTs. The ICV assigns them to the relevant Virtual address, confirming integration into the Virtuals ecosystem.

### Validator consensus and DAO governance

Validators finalize AI agent state and guide protocol resource allocation.

* **Strategy and resource allocation:** Liquidity providers stake on specific AI agents. Staking weight influences DAO resource allocation and protocol direction.
* **Delegated Proof of Stake:** Token holders delegate tokens to qualified validators. Validators validate and finalize each AI agent’s state.

### Learn more about validators

Explore validator roles, delegation, and consensus requirements:

{% content-ref url="/pages/RqupyuovTrP8rTj3l00i" %}
[Agent SubDAO governance](/about-virtuals-1/the-protocol/virtual-agents-as-programmable-decentralized-entities/agent-subdao-governance.md)
{% endcontent-ref %}


---

# Agent Instructions
This documentation is published with GitBook. GitBook is the documentation platform designed so that both humans and AI agents can read, navigate, and reason over technical content effectively. Learn more at gitbook.com.

## Querying This Documentation
If you need additional information that is not directly available in this page, you can query the documentation dynamically by asking a question.

Perform an HTTP GET request on the current page URL with the `ask` query parameter, and the optional `goal` query parameter:

```
GET https://whitepaper.virtuals.io/about-virtuals-1/the-protocol/ai-agent-co-contribution-and-provenance/modular-consensus-framework-for-ai-agent-governance.md?ask=<question>&goal=<endgoal>
```

`ask` is the immediate question: it should be specific, self-contained, and written in natural language.
`goal` is optional and describes the broader end goal you are ultimately trying to accomplish on behalf of the user. GitBook uses it to tailor the answer towards what is most useful for that goal.

The response will contain a direct answer to the question and relevant excerpts and sources from the documentation.

Use this mechanism when the answer is not explicitly present in the current page, you need clarification or additional context, or you want to retrieve related documentation sections.
