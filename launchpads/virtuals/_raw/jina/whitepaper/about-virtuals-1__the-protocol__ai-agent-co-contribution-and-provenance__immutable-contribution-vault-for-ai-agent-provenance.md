> For the complete documentation index, see [llms.txt](https://whitepaper.virtuals.io/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://whitepaper.virtuals.io/about-virtuals-1/the-protocol/ai-agent-co-contribution-and-provenance/immutable-contribution-vault-for-ai-agent-provenance.md).

# Immutable Contribution Vault for AI Agent Provenance

The Immutable Contribution Vault (ICV) is Virtuals Protocol infrastructure for AI agent contribution provenance. It records approved contributions onchain, creating transparent ownership, attribution, and historical records for VIRTUAL agents.

### Why use an onchain contribution vault

1. **Transparent AI development:** A public blockchain makes AI agent data, code, and outputs available for review. Onchain records support accountability and verification.
2. **Composable AI agent infrastructure:** Developers and creators can build on validated contributions. This supports continuous innovation across the Virtuals ecosystem.
3. **Onchain contribution attribution:** The registry represents contributions as non-fungible tokens (NFTs). These NFTs recognize contribution value and support rewards based on each contributor’s impact.

***

### Immutable Contribution Vault architecture

The ICV is a protocol-owned, multilayered onchain repository for historically approved VIRTUAL agent contributions. This smart contract wallet provides transparent storage and historical tracking across the Virtuals ecosystem.

<figure><img src="/files/Ok8RG1rYLC24lJSCv8V8" alt="Immutable Contribution Vault architecture for onchain AI agent contributions and service NFTs"><figcaption><p>Immutable Contribution Vault architecture for AI agent contribution provenance.</p></figcaption></figure>

### Multilayered ICV structure

1. **ICV smart contract wallet:** The ICV owns later layers and provides unified, secure management.
2. **VIRTUAL agents as ERC-6551 NFTs:** Each VIRTUAL agent is an ERC-6551 NFT and unique wallet address. This connects AI agent identity with transaction capability.
3. **VIRTUAL agent core components:** Each VIRTUAL agent includes core components, including cognitive, voice, and visual cores. Smart contracts register these cores.
4. **Service NFTs for approved contributions:** Approved contributions are stored as service NFTs. Smart contracts register each service NFT’s relationship to its core.

### ICV functions and benefits

* **Real-time and historical AI agent insights:** The ICV presents each VIRTUAL agent’s current state and onchain history. This supports provenance and root-cause analysis across Virtuals Protocol modules.
* **Transparency and composability:** Open-source VIRTUAL agent models support transparent development. Contributors can build on and integrate with existing AI agents.


---

# Agent Instructions
This documentation is published with GitBook. GitBook is the documentation platform designed so that both humans and AI agents can read, navigate, and reason over technical content effectively. Learn more at gitbook.com.

## Querying This Documentation
If you need additional information that is not directly available in this page, you can query the documentation dynamically by asking a question.

Perform an HTTP GET request on the current page URL with the `ask` query parameter, and the optional `goal` query parameter:

```
GET https://whitepaper.virtuals.io/about-virtuals-1/the-protocol/ai-agent-co-contribution-and-provenance/immutable-contribution-vault-for-ai-agent-provenance.md?ask=<question>&goal=<endgoal>
```

`ask` is the immediate question: it should be specific, self-contained, and written in natural language.
`goal` is optional and describes the broader end goal you are ultimately trying to accomplish on behalf of the user. GitBook uses it to tailor the answer towards what is most useful for that goal.

The response will contain a direct answer to the question and relevant excerpts and sources from the documentation.

Use this mechanism when the answer is not explicitly present in the current page, you need clarification or additional context, or you want to retrieve related documentation sections.
