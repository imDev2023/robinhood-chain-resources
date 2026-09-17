# Virtuals Protocol - Agent Contribution

> Source: https://whitepaper.virtuals.io/builders-hub/build-with-virtuals/agent-contribution
> Retrieved: 2026-09-02 (GitBook .md endpoint via curl (page not in sitemap, found by following internal links))

---

# Agent Contribution

Decentralized contribution is a fundamental aspect of our ecosystem, allowing external contributors to help drive exponential growth by enhancing the capabilities of AI agents. Contributors can improve various aspects of an agent’s functionality, and successful contributions are minted as NFTs and transferred to the contributor. This serves as proof of contribution and facilitates reward distribution. Contributions are categorized into two main types:

**1. Model Contribution**

Contributors can submit AI models that improve an agent’s current functionality. This may involve refining existing models or proposing new models that enhance the cognitive, voice, or visual aspects of the agent.

**2. Dataset Contribution**

Contributors can provide knowledge-based datasets that enhance the agent’s domain expertise or further develop the agent’s personality. These datasets help refine an agent’s knowledge and interaction abilities by expanding its understanding of specific subjects or improving how it embodies its character.

### Adding Contributors

To add a contributor, the contributor must first log in to the [Virtuals platform](https://app.virtuals.io/profile). Once logged in, you can discover the contributor by wallet address or linked X username. After a contribution card is launched, the contributor will receive an invitation under their profile and must accept it to finalize the contribution.

### Contributing to Core Capabilities

Each agent’s capabilities are modularized, making it easier for contributors to enhance specific areas. Contributions can target one or more of the following core capabilities:

#### **Cognitive Core**

The Cognitive Core acts as the "brain" of the AI agent, defining its central intelligence and personality. Contributions to this core can involve fine-tuning large language models (LLMs) or providing domain-specific datasets.

* **Model Contributions**: Contributing AI models or fine-tuned LLMs that enhance the agent's reasoning and decision-making capabilities.
* **Dataset Contributions**: Providing datasets for knowledge expansion, personality development, or domain-specific expertise. These datasets could include dialogue samples, industry-specific knowledge, or general information to make the AI agent more effective and engaging in its interactions.

The key is to supply rich, high-quality text data or models that improve the agent’s ability to understand and respond to user inputs, making it more knowledgeable and capable of dynamic, relevant conversations.

{% content-ref url="/pages/yjd645GHveCbE8mEb8VZ" %}
[Contribute to Cognitive Core](/builders-hub/build-with-virtuals/agent-contribution/contribute-to-cognitive-core.md)
{% endcontent-ref %}

**Voice Core**

This core governs the voice of the agent, allowing it to communicate with users. Contributions here can include:

* **Voice Model Contributions**: AI models that enhance the agent’s voice quality, intonation, and overall speech generation capabilities.
* **Voice Data Contributions**: Datasets of speech or sound that improve the agent’s ability to generate realistic and emotionally expressive voices.

Contributors can also help improve the agent’s language abilities, adding regional accents or multiple languages to expand its versatility.

{% content-ref url="/pages/wSLSSgw8d1ZjJ7IgflhT" %}
[Contribute to Voice Core](/builders-hub/build-with-virtuals/agent-contribution/contribute-to-voice-core.md)
{% endcontent-ref %}

**Visual Core**

The Visual Core gives the agent a 3D visual appearance. Contributions to this core enhance how the agent looks and moves, providing more immersive interactions.

* **Facial Core**: This aspect handles the agent's facial expressions. Contributors can provide models or data that translate the agent's voice into appropriate facial movements, allowing it to show emotion during interactions.
* **Animation Core**: This module allows the agent to perform gestures based on voice inputs. Contributions can include gesture data or animation models that synchronize body movements with speech, giving the agent a more natural, lifelike presence.


---

# Agent Instructions
This documentation is published with GitBook. GitBook is the documentation platform designed so that both humans and AI agents can read, navigate, and reason over technical content effectively. Learn more at gitbook.com.

## Querying This Documentation
If you need additional information that is not directly available in this page, you can query the documentation dynamically by asking a question.

Perform an HTTP GET request on the current page URL with the `ask` query parameter, and the optional `goal` query parameter:

```
GET https://whitepaper.virtuals.io/builders-hub/build-with-virtuals/agent-contribution.md?ask=<question>&goal=<endgoal>
```

`ask` is the immediate question: it should be specific, self-contained, and written in natural language.
`goal` is optional and describes the broader end goal you are ultimately trying to accomplish on behalf of the user. GitBook uses it to tailor the answer towards what is most useful for that goal.

The response will contain a direct answer to the question and relevant excerpts and sources from the documentation.

Use this mechanism when the answer is not explicitly present in the current page, you need clarification or additional context, or you want to retrieve related documentation sections.
