> For the complete documentation index, see [llms.txt](https://whitepaper.virtuals.io/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://whitepaper.virtuals.io/about-virtuals-1/the-protocol/virtual-agents-as-programmable-decentralized-entities/agent-subdao-governance/token-delegation-via-dpos.md).

# Token Delegation via DPos

**Liquidity Providers (LPs)** can delegate any amount of their LP stake to an Agent validator through a process called **delegation**. Delegation on Virtual Protocol works like this:

* An Agent staker, i.e., a delegator, also called a **nominator**, stakes with an Agent validator, making this Agent validator a **delegate** of the Agent. This provides support to the delegate as the delegate's effective stake becomes larger, which increases the delegate's impact on the Agent Validation.

{% hint style="info" %}
**A nominator is a delegating authority.**&#x20;

A nominator is the same as a delegating authority. Typically a nominator is an owner of Agent LP tokens, looking to stake in any Agent without doing any validating tasks.
{% endhint %}

* The delegate (the Agent validator) then pools all such delegated stake, along with their own stake, and uses this total stake to perform validation tasks in the Agent. Regular staking rewards, in proportion to the total stake of the delegate, are credited to the delegate as a result of such validation tasks.
* After deducting a percentage for the delegate, these staking rewards are given back to the delegate's nominators.

{% hint style="info" %}
**Delegate take %**

The default value of the delegate take rate is 10%.
{% endhint %}


---

# Agent Instructions
This documentation is published with GitBook. GitBook is the documentation platform designed so that both humans and AI agents can read, navigate, and reason over technical content effectively. Learn more at gitbook.com.

## Querying This Documentation
If you need additional information that is not directly available in this page, you can query the documentation dynamically by asking a question.

Perform an HTTP GET request on the current page URL with the `ask` query parameter, and the optional `goal` query parameter:

```
GET https://whitepaper.virtuals.io/about-virtuals-1/the-protocol/virtual-agents-as-programmable-decentralized-entities/agent-subdao-governance/token-delegation-via-dpos.md?ask=<question>&goal=<endgoal>
```

`ask` is the immediate question: it should be specific, self-contained, and written in natural language.
`goal` is optional and describes the broader end goal you are ultimately trying to accomplish on behalf of the user. GitBook uses it to tailor the answer towards what is most useful for that goal.

The response will contain a direct answer to the question and relevant excerpts and sources from the documentation.

Use this mechanism when the answer is not explicitly present in the current page, you need clarification or additional context, or you want to retrieve related documentation sections.
