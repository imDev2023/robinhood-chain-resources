> For the complete documentation index, see [llms.txt](https://whitepaper.virtuals.io/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://whitepaper.virtuals.io/about-virtuals/capital-formation-layer/fee-delegation-for-ai-agent-token-launches.md).

# Fee Delegation for AI Agent Token Launches

### What is Fee Delegation?

Fee Delegation is a launch module for permissionless AI agent token launches. It separates the token creator from the designated creator-fee recipient.

It supports launches by community members, supporters, and collaborators. The designated builder receives the creator fee share.

### How does Fee Delegation work?

During token creation, the creator enables Fee Delegation. They select the builder's fee-recipient identity:

* **X handle** — the builder's `@username`.
* **Wallet address** — the builder's onchain address.

The token can then begin trading. A 1% trading fee applies to trades. Fee Delegation reserves the creator's 70% share for the specified identity. The remaining 30% supports the Virtuals Treasury.

The reserved balance accrues while the token trades. The designated builder can claim it after profile verification.

### Can a community member launch an AI agent token for my project?

Yes. Fee Delegation lets a community member launch an AI agent token while reserving its creator fee share for you.

This can happen without prior coordination. The creator identifies you using your X handle or wallet address. Fees reserved for your identity remain yours to claim.

### How do I claim delegated trading fees?

1. Sign in to Virtuals Protocol.
2. Verify the profile linked to the delegated X handle or wallet address.
3. Claim the accrued balance.

After verification, future creator fees flow directly to you.

### Common questions

<details>

<summary>Can the token creator claim fees delegated to me?</summary>

No. Only the builder identified during token creation can claim the reserved creator fee share.

</details>

<details>

<summary>Can I receive fees before I claim my profile?</summary>

Yes. Fees accrue to a reserved balance linked to your X handle or wallet address. Verify the linked profile to claim them.

</details>

<details>

<summary>What fee share does Fee Delegation reserve for the builder?</summary>

Fee Delegation reserves the creator's 70% share of the 1% trading fee. Virtuals Treasury receives the remaining 30%.

</details>

For launch lifecycle and trading-fee details, see [Virtuals Launch Mechanics](/about-virtuals/capital-formation-layer/virtuals-launch-mechanics.md).


---

# Agent Instructions
This documentation is published with GitBook. GitBook is the documentation platform designed so that both humans and AI agents can read, navigate, and reason over technical content effectively. Learn more at gitbook.com.

## Querying This Documentation
If you need additional information that is not directly available in this page, you can query the documentation dynamically by asking a question.

Perform an HTTP GET request on the current page URL with the `ask` query parameter, and the optional `goal` query parameter:

```
GET https://whitepaper.virtuals.io/about-virtuals/capital-formation-layer/fee-delegation-for-ai-agent-token-launches.md?ask=<question>&goal=<endgoal>
```

`ask` is the immediate question: it should be specific, self-contained, and written in natural language.
`goal` is optional and describes the broader end goal you are ultimately trying to accomplish on behalf of the user. GitBook uses it to tailor the answer towards what is most useful for that goal.

The response will contain a direct answer to the question and relevant excerpts and sources from the documentation.

Use this mechanism when the answer is not explicitly present in the current page, you need clarification or additional context, or you want to retrieve related documentation sections.
