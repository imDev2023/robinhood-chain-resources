# Virtuals Protocol - Automated Capital Formation

> Source: https://whitepaper.virtuals.io/about-virtuals/capital-formation-layer/automated-capital-formation
> Retrieved: 2026-09-02 (GitBook .md endpoint via curl)

---

# Automated Capital Formation

### Automated Capital Formation (ACF) for token launches

Activating the Automated Capital Formation module requires a 10 $VIRTUAL fee.

When activated, 50% of token supply is reserved for the founding team. This allocation is split between Automated Capital Formation and Team Allocation.

<figure><img src="/files/tjZtMdlFYGmFkl8bAo9U" alt="Automated Capital Formation token allocation for Virtuals Protocol AI agent token launches"><figcaption></figcaption></figure>

***

### ACF token distribution and founder funding (25%)

Once a project reaches $2 million FDV, ACF begins automated team distribution. Distribution uses successive liquidity pool creations at every additional $100,000 FDV. It continues until $160 million FDV.

* ACF proceeds are disbursed directly to founders in $USDC.
* Distribution is automatic and transparent. It is tied strictly to market valuation.
* Founders receive liquidity only when their token demonstrates market growth.
* Orders fill through natural price discovery.

### Estimated capital formation by FDV range

| Range of Valuation ($, USD) | Sold (%) | Average Valuation Sold ($, USD) | Raise ($, USD) | Cumulative Raise ($, USD) |
| --------------------------- | -------- | ------------------------------- | -------------- | ------------------------- |
| 2,000,000 - 10,000,000      | 5%       | 6,000,000                       | 300,000        | 300,000                   |
| 10,000,000 - 20,000,000     | 5%       | 15,000,000                      | 750,000        | 1,050,000                 |
| 20,000,000 - 40,000,000     | 5%       | 30,000,000                      | 1,500,000      | 2,550,000                 |
| 40,000,000 - 80,000,000     | 5%       | 60,000,000                      | 3,000,000      | 5,550,000                 |
| 80,000,000 - 160,000,000    | 5%       | 120,000,000                     | 6,000,000      | 11,550,000                |

***

### Team token allocation and vesting (25%)

The remaining 25% of the team token allocation is locked for one year after TGE. It then follows a six-month linear vesting period.

If the project reaches $160 million FDV before one year, vesting begins immediately. It still follows the six-month linear schedule.

This supports founder accountability and long-term AI agent development.

***

### Team initial buy with the Pre-buy module

When the [Pre-buy](/about-virtuals/capital-formation-layer/pre-buy-tokens-for-ai-agent-launches.md) module is activated, teams may purchase up to 50% of total supply during creation. This can stabilize early token markets, prevent sniping, and signal founder conviction.

All pre-purchased tokens are disclosed in tokenomics. They follow a default minimum one-month cliff and 12-month vesting schedule. Teams can adjust these parameters before launch.

If founders self-purchase above $2 million FDV at TGE, the corresponding ACF token amounts are reclassified as Team Allocation. They are not distributed immediately.

This prevents early founder participation from accelerating capital release. It maintains long-term growth alignment and accountability.

### Pre-buy restrictions and token launch relaunches

Once the Agent Card is live, teams cannot execute a Pre-buy without relaunching the AI agent.

To add a Pre-buy after the Agent Card is deployed, teams must cancel the existing token launch and create a new one. This cancellation and relaunch is available until one day before the scheduled launch. Module fees are not refunded.

This keeps early team token access intentional, transparent, and fair. It protects participants and preserves market integrity.


---

# Agent Instructions
This documentation is published with GitBook. GitBook is the documentation platform designed so that both humans and AI agents can read, navigate, and reason over technical content effectively. Learn more at gitbook.com.

## Querying This Documentation
If you need additional information that is not directly available in this page, you can query the documentation dynamically by asking a question.

Perform an HTTP GET request on the current page URL with the `ask` query parameter, and the optional `goal` query parameter:

```
GET https://whitepaper.virtuals.io/about-virtuals/capital-formation-layer/automated-capital-formation.md?ask=<question>&goal=<endgoal>
```

`ask` is the immediate question: it should be specific, self-contained, and written in natural language.
`goal` is optional and describes the broader end goal you are ultimately trying to accomplish on behalf of the user. GitBook uses it to tailor the answer towards what is most useful for that goal.

The response will contain a direct answer to the question and relevant excerpts and sources from the documentation.

Use this mechanism when the answer is not explicitly present in the current page, you need clarification or additional context, or you want to retrieve related documentation sections.
