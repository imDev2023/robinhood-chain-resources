> For the complete documentation index, see [llms.txt](https://whitepaper.virtuals.io/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://whitepaper.virtuals.io/about-virtuals-1/the-protocol/ai-agent-co-contribution-and-provenance/modular-consensus-framework-for-ai-agent-governance/decentralized-ai-agent-contributions-and-nfts/cognitive-core-for-ai-agents.md).

# Cognitive Core for AI Agents

The Cognitive Core is the central intelligence layer for a VIRTUAL agent. It uses large language models (LLMs), retrieval, and persistent memory to execute tasks and deliver a distinct AI agent personality.

### Large language models for AI agents

VIRTUAL agents use open-source LLMs. The Cognitive Core combines retrieval-augmented generation and model fine-tuning to build each agent’s personality and domain intelligence.

* **AI agent personality development**\
  Retrieval-augmented generation (RAG) develops an agent’s backstory, lore, traits, and characteristics. RAG combines language generation with knowledge-base retrieval, creating more relevant and lifelike AI agent interactions.
* **AI agent central intelligence**

  VIRTUAL agents with substantial datasets use direct fine-tuning of open-source models. Fine-tuning improves accurate, domain-specific responses. Instruction fine-tuning further aligns an AI agent’s responses and actions with defined rules or objectives.\
  \
  Smaller datasets are stored in a vector database and retrieved through RAG. This gives the AI agent efficient access to specialized information.

### AI training data preprocessing

AI agent training data can include text, video, and audio from textbooks, forums, and wikis. The Cognitive Core primarily uses text-based LLMs. Video and audio training data require transcription before model training.

* **Data cleaning:** Removes noise and null values to maintain data integrity and quality.
* **Data transformation:** Standardizes datasets for reliable model training.

### Persistent AI agent memory and conversation context

VIRTUAL agents use a persistent memory system for personalized, context-aware interactions. The system retains conversation context while supporting efficient long-term memory processing.

1. **User and conversation identification:** The system identifies users and their conversations for accurate recall.
2. **Long conversation storage:** The system stores and processes extended conversations efficiently.

#### Unique user identifier

Each VIRTUAL agent user receives a unique identifier. This maintains user-specific context and conversation continuity.

<details>

<summary>A Sample Database Table</summary>

A sample database table is formed as below.

```sql
CREATE TABLE Messages (
    message_id VARCHAR(32) NOT NULL PRIMARY KEY,
    conversation_id VARCHAR(32) NOT NULL,
    user_id VARCHAR(32) NOT NULL,
    prompt TEXT NOT NULL,
    timestamp DATETIME NOT NULL,
    response TEXT, 
    FOREIGN KEY (conversation_id) REFERENCES Conversations(conversation_id)
);

```

</details>

#### Vector database and memory retrieval

Embedding techniques vectorize messages into numerical formats for efficient storage and retrieval.

When the `getPrompt('identifier', 'context', 'params')` function runs, the system retrieves the user’s messages from the vector database. The LLM uses this retrieved conversation history to generate personalized, contextually relevant responses without requiring added context from the dApp.

[<mark style="color:red;">Learn more about contributing to Cognitive Core.</mark>](/builders-hub/build-with-virtuals/agent-contribution/contribute-to-cognitive-core.md)


---

# Agent Instructions
This documentation is published with GitBook. GitBook is the documentation platform designed so that both humans and AI agents can read, navigate, and reason over technical content effectively. Learn more at gitbook.com.

## Querying This Documentation
If you need additional information that is not directly available in this page, you can query the documentation dynamically by asking a question.

Perform an HTTP GET request on the current page URL with the `ask` query parameter, and the optional `goal` query parameter:

```
GET https://whitepaper.virtuals.io/about-virtuals-1/the-protocol/ai-agent-co-contribution-and-provenance/modular-consensus-framework-for-ai-agent-governance/decentralized-ai-agent-contributions-and-nfts/cognitive-core-for-ai-agents.md?ask=<question>&goal=<endgoal>
```

`ask` is the immediate question: it should be specific, self-contained, and written in natural language.
`goal` is optional and describes the broader end goal you are ultimately trying to accomplish on behalf of the user. GitBook uses it to tailor the answer towards what is most useful for that goal.

The response will contain a direct answer to the question and relevant excerpts and sources from the documentation.

Use this mechanism when the answer is not explicitly present in the current page, you need clarification or additional context, or you want to retrieve related documentation sections.
