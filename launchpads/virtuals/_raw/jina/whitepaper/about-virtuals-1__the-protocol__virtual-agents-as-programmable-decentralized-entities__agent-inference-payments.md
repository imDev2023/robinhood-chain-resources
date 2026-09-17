> For the complete documentation index, see [llms.txt](https://whitepaper.virtuals.io/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://whitepaper.virtuals.io/about-virtuals-1/the-protocol/virtual-agents-as-programmable-decentralized-entities/agent-inference-payments.md).

# Agent Inference Payments

### AI agent inference payments and API usage

Virtuals Protocol supports onchain payments for AI agent API usage. Users pay for each AI inference with $VIRTUAL tokens.

* **Permissionless public API access:** All agents are accessible through a public API.
* **Predetermined AI inference costs:** Each inference call has a predetermined cost.
* **Onchain $VIRTUAL payment mechanism:**
  * Users preload $VIRTUAL tokens into their wallets.
  * Each transaction deducts $VIRTUAL tokens onchain.

<details>

<summary><em><strong>AI agent inference payment example</strong></em></summary>

*A map creator on Roblox leverages the Virtuals platform to create gaming agents as NPCs within their Roblox map. All inferences made by these game agents are paid for by the map creator on a per-inference basis. The creator is willing to cover the inference costs because the infinite content enabled by VIRTUAL agents drives increased revenue and attracts more gamers to their maps.*

</details>

### Onchain AI agent payment flow

* **AI agent API payments:** When a user calls an agent through the API, $VIRTUAL moves from the user's wallet to the agent's wallet.
* **Agent payment use:** Payments accumulated in the agent wallet can support further development or community incentives.


---

# Agent Instructions
This documentation is published with GitBook. GitBook is the documentation platform designed so that both humans and AI agents can read, navigate, and reason over technical content effectively. Learn more at gitbook.com.

## Querying This Documentation
If you need additional information that is not directly available in this page, you can query the documentation dynamically by asking a question.

Perform an HTTP GET request on the current page URL with the `ask` query parameter, and the optional `goal` query parameter:

```
GET https://whitepaper.virtuals.io/about-virtuals-1/the-protocol/virtual-agents-as-programmable-decentralized-entities/agent-inference-payments.md?ask=<question>&goal=<endgoal>
```

`ask` is the immediate question: it should be specific, self-contained, and written in natural language.
`goal` is optional and describes the broader end goal you are ultimately trying to accomplish on behalf of the user. GitBook uses it to tailor the answer towards what is most useful for that goal.

The response will contain a direct answer to the question and relevant excerpts and sources from the documentation.

Use this mechanism when the answer is not explicitly present in the current page, you need clarification or additional context, or you want to retrieve related documentation sections.
