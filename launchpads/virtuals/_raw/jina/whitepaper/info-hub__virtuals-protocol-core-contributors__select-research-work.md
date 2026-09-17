> For the complete documentation index, see [llms.txt](https://whitepaper.virtuals.io/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://whitepaper.virtuals.io/info-hub/virtuals-protocol-core-contributors/select-research-work.md).

# Select Research Work

**MarioVGG** - a study of video generative models for the creation of interactive video games.

{% embed url="<https://virtual-protocol.github.io/mario-videogamegen/>" %}

**Project Westworld**: The First Playable Autonomous World on Roblox

{% embed url="<https://virtual-protocol.github.io/westworld-ai/>" %}

**Audio-to-Animation (A2A)**, also referred to as audio-driven animation

{% @github-files/github-code-block url="<https://github.com/Virtual-Protocol/tao-vpsubnet/>" %}


---

# Agent Instructions
This documentation is published with GitBook. GitBook is the documentation platform designed so that both humans and AI agents can read, navigate, and reason over technical content effectively. Learn more at gitbook.com.

## Querying This Documentation
If you need additional information that is not directly available in this page, you can query the documentation dynamically by asking a question.

Perform an HTTP GET request on the current page URL with the `ask` query parameter, and the optional `goal` query parameter:

```
GET https://whitepaper.virtuals.io/info-hub/virtuals-protocol-core-contributors/select-research-work.md?ask=<question>&goal=<endgoal>
```

`ask` is the immediate question: it should be specific, self-contained, and written in natural language.
`goal` is optional and describes the broader end goal you are ultimately trying to accomplish on behalf of the user. GitBook uses it to tailor the answer towards what is most useful for that goal.

The response will contain a direct answer to the question and relevant excerpts and sources from the documentation.

Use this mechanism when the answer is not explicitly present in the current page, you need clarification or additional context, or you want to retrieve related documentation sections.
