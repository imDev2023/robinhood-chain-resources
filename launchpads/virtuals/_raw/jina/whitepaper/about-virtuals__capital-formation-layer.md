> For the complete documentation index, see [llms.txt](https://whitepaper.virtuals.io/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://whitepaper.virtuals.io/about-virtuals/capital-formation-layer.md).

# Capital Formation Layer

### Launch an AI Agent on Virtuals

To launch an AI agent on Virtuals, create an agent on the [Virtuals Launchpad](https://app.virtuals.io/create), choose your launch modules, configure them, and publish. Trading opens automatically after creation.

Every launch starts on a bonding curve paired with $VIRTUAL. At 42,000 $VIRTUAL in liquidity, the agent token automatically graduates to a Uniswap V2 pool. LP tokens remain locked for 10 years.

Most launches are free. Certain module costs 10 $VIRTUAL such as Capital Formation and SOL Launch.

The Capital Formation Layer of Virtuals Protocol is where AI agents become financeable economic actors. The Virtuals Launchpad, a fully modular tokenization platform, lets founders fund, distribute ownership in, and create continuous markets for their agents from day one, with every launch paired with $VIRTUAL liquidity and underwritten by long-term LP locks.

### Why Agents Need Capital Formation

An agent that produces economic output is, by definition, a financeable asset. Capital formation gives agents the ability to fund development before generating revenue, distribute ownership to backers, and access continuous liquidity through onchain markets. Without these primitives, agents remain experiments. With them, they become economic businesses with cap tables, investors, and durable upside for the people who build and back them.

### Your Agent, Your Way

The Virtuals Launchpad enables founders to tokenize AI agents and AI-native businesses directly onchain by pairing their agents with $VIRTUAL liquidity.

The Launchpad is fully modular. There are no fixed tiers, no preset configurations, and no default launch classes. Every launch feature is an independent toggle. Founders assemble the exact launch configuration that fits their project.

All launches share the same underlying infrastructure: bonding curve mechanics, $VIRTUAL liquidity pairing, 42K VIRTUAL graduation threshold, 10-year LP lock, and 1% trading fee structure. These are universal. Everything else is configurable.

### How to Launch/Tokenise Your Agent

1. [Create your agent](https://app.virtuals.io/create).
2. Toggle launch modules on or off.
3. Configure each active module.
4. Publish your launch. Trading opens automatically.

No two launches need to look the same. The modules are independent. They can be combined in any configuration.

For a visual launch walkthrough, see the [Virtuals agent tokenization tutorial on X](https://x.com/virtuals_io/status/2079962937566056563?s=46).

***

### Launch Modules

**Anti-Sniper Protection** Dynamic tax starting at 99%, decaying to 1% across a chosen window. Applies to buys, sells, or both — founder's choice. Protects early liquidity from bots and snipers. Buybacks vest to the team. [\[Read more\]](/about-virtuals/capital-formation-layer/anti-sniper-protection-for-token-launches.md)

**60 Days Experiment** Trial-based launch. Build publicly for 60 days. Capital forms through trading and optional Growth Allocation. Commit or wind down cleanly. No reputation risk. [\[Read more\]](/about-virtuals/capital-formation-layer/60-days.md)

**Capital Formation** Structured, transparent fundraising. 25% team stack, 25% in automated tiered sell orders from $2M to $160M FDV. Disbursed in USDC. [\[Read more\]](/about-virtuals/capital-formation-layer/automated-capital-formation.md)

**Airdrop Distribution** Allocate up to 5% of supply to veVIRTUAL stakers. Community alignment from day one. [\[Read more\]](/about-virtuals/capital-formation-layer/airdrop-distribution.md)

**Fee Delegation** Let anyone launch an agent token while reserving the creator fee share for the identified builder. [\[Read more\]](/about-virtuals/capital-formation-layer/fee-delegation-for-ai-agent-token-launches.md)

**Launch as an Existing Token** Already deployed? Connect your token to Virtuals Protocol. Unlock the full AI agent feature suite. [\[Read more\]](/about-virtuals/capital-formation-layer/launch-as-an-existing-token.md)

**Pre-buy Token** Purchase up to 100% of supply at launch. Fully transparent. 1-month cliff, 12-month vesting by default. [\[Read more\]](/about-virtuals/capital-formation-layer/pre-buy-tokens-for-ai-agent-launches.md)

**Robotics Launch** Signal that your project has a physical robot form factor at its core. Become visible to the Eastworlds accelerator. [\[Read more\]](/about-virtuals/physical-labor-layer-robotics-and-embodied-ai.md)

***

### Why We Built It This Way

Genesis was a bold experiment in fairness. Everyone could participate, every project had visibility, and launches were broadly accessible. Over time, fairness alone proved insufficient. Participation optimized around point accumulation rather than conviction, capital failed to settle, and founders lacked a meaningful path to funding.

Unicorn was introduced as a correction, aligning conviction, capital, and accountability. As the ecosystem matured further, a final realization emerged: no single launch model can serve every builder reality.

Early teams need distribution. Growth-stage teams need aligned capital formation. Established teams need clean market entry. Robotics teams need a pathway to physical infrastructure.

Rather than prescribing fixed classes, the Launchpad now lets founders compose their launch from independent modules. Every project is different. The launch should reflect that.

***

### Universal Infrastructure

These apply to every launch regardless of module configuration:

* Free to create agent (Exception to 3Modules)
  * Capital Formation module: 10 $VIRTUAL
  * SOL Launches: 10 $VIRTUAL
* Bonding curve with 42,000 $VIRTUAL graduation threshold
* Auto-migration to Uniswap V2 pool upon graduation
* 1% trading fee (70% creator, 30% Virtuals Treasury)
* 10-year LP token lock

For full mechanics, see [Virtuals Launch Mechanics](/about-virtuals/capital-formation-layer/virtuals-launch-mechanics.md).


---

# Agent Instructions
This documentation is published with GitBook. GitBook is the documentation platform designed so that both humans and AI agents can read, navigate, and reason over technical content effectively. Learn more at gitbook.com.

## Querying This Documentation
If you need additional information that is not directly available in this page, you can query the documentation dynamically by asking a question.

Perform an HTTP GET request on the current page URL with the `ask` query parameter, and the optional `goal` query parameter:

```
GET https://whitepaper.virtuals.io/about-virtuals/capital-formation-layer.md?ask=<question>&goal=<endgoal>
```

`ask` is the immediate question: it should be specific, self-contained, and written in natural language.
`goal` is optional and describes the broader end goal you are ultimately trying to accomplish on behalf of the user. GitBook uses it to tailor the answer towards what is most useful for that goal.

The response will contain a direct answer to the question and relevant excerpts and sources from the documentation.

Use this mechanism when the answer is not explicitly present in the current page, you need clarification or additional context, or you want to retrieve related documentation sections.
