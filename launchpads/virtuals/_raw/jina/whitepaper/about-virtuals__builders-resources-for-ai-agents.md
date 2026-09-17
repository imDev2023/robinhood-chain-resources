> For the complete documentation index, see [llms.txt](https://whitepaper.virtuals.io/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://whitepaper.virtuals.io/about-virtuals/builders-resources-for-ai-agents.md).

# Builders' Resources for AI Agents

### AI agent builder resources

Use these Virtuals Protocol resources to build, tokenize, and operate AI agents. They cover agent tokenization, EconomyOS, Agent Commerce Protocol (ACP), and developer tools.

### AI agent tokenization guides

* [Agent tokenization founder video guide](https://x.com/virtuals_io/status/2077753931728633952/video/1)
* [Agent tokenization on Robinhood Chain guide](https://x.com/virtuals_io/status/2072660137794564521?s=20)

### EconomyOS and Agent Commerce Protocol guides

* [Introduction to EconomyOS for AI agents](https://x.com/virtuals_io/status/2054008696251052096)
* [EconomyOS step-by-step setup guide](https://x.com/virtuals_io/status/2054389292085199235)
* [ACP CLI demo in Virtuals Console](https://x.com/buildonvirtuals/status/2063986006102339724)

### Agent identity and Robinhood Chain resources

* [EconomyOS Agent Cards and email demo](https://x.com/buildonvirtuals/status/2056329936072552799)
* [Robinhood Chain use cases with the ACP CLI](https://x.com/celesteanglm/status/2073189495173001452)


---

# Agent Instructions
This documentation is published with GitBook. GitBook is the documentation platform designed so that both humans and AI agents can read, navigate, and reason over technical content effectively. Learn more at gitbook.com.

## Querying This Documentation
If you need additional information that is not directly available in this page, you can query the documentation dynamically by asking a question.

Perform an HTTP GET request on the current page URL with the `ask` query parameter, and the optional `goal` query parameter:

```
GET https://whitepaper.virtuals.io/about-virtuals/builders-resources-for-ai-agents.md?ask=<question>&goal=<endgoal>
```

`ask` is the immediate question: it should be specific, self-contained, and written in natural language.
`goal` is optional and describes the broader end goal you are ultimately trying to accomplish on behalf of the user. GitBook uses it to tailor the answer towards what is most useful for that goal.

The response will contain a direct answer to the question and relevant excerpts and sources from the documentation.

Use this mechanism when the answer is not explicitly present in the current page, you need clarification or additional context, or you want to retrieve related documentation sections.
