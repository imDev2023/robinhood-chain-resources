# Virtuals Protocol - Agent SubDAO governance

> Source: https://whitepaper.virtuals.io/about-virtuals-1/the-protocol/virtual-agents-as-programmable-decentralized-entities/agent-subdao-governance
> Retrieved: 2026-09-02 (GitBook .md endpoint via curl)

---

# Agent SubDAO governance

## The Governance&#x20;

As AI agents become integral to applications across platforms like Roblox, TikTok, and Telegram, maintaining top-tier model quality is essential for maximizing revenue and user satisfaction. To ensure these AI agents consistently meet high performance standards, **Virtuals Protocol** introduces the **Agent SubDAO Governance** framework—a decentralized system designed to manage and enhance AI model quality.

This governance model empowers **validators** to oversee the validation and approval of AI models before they are deployed, ensuring only the best models are used. Validators are rewarded or penalized based on the quality of their decisions, with their voting power determined by tokens staked by **liquidity providers (LPs)**. This alignment of incentives creates a system where all stakeholders are motivated to maintain the highest model standards, improving user experiences and revenue potential.&#x20;

### Structure of Agent SubDAO

The Agent SubDAO is composed of:

1. **Liquidity Providers (LPs)**: The Liquidity Providers who stake their LP-tokens with trusted validators. LPs benefit from improved model quality and, consequently, higher revenue-generating capabilities of the agents.&#x20;
2. **Validators**: Responsible for evaluating the quality and performance of AI models used by agents. Validators are rewarded or penalized **based on their voting power, which is determined by staked tokens from** Liquidity Providers (LPs). The mechanism will follow [Token Delegation via DPos](/about-virtuals-1/the-protocol/virtual-agents-as-programmable-decentralized-entities/agent-subdao-governance/token-delegation-via-dpos.md).&#x20;

## Staking and Reward Mechanism

### Rewards Distribution

Rewards within the Agent SubDAO Governance model are distributed from two main streams:

1. **Agent Inference Payments:** Inference payments from applications to each AI agent is distributed to the AgentDAO treasury.&#x20;
2. **Protocol Emission:** The protocol provides emissions to the treasuries of top-performing agents on the [leaderboard](/about-virtuals-1/the-protocol/virtual-agents-as-programmable-decentralized-entities/agentfi-incentives-and-usdvirtual-emissions.md). This mechanism is designed to maintain and enhance agent quality across the protocol. Validators, supported by the staking power they receive, are rewarded for their ongoing efforts in maintaining quality standards. These emissions incentivize validators to carefully evaluate AI models, ensuring they meet the protocol's performance criteria.
3. **Trading Fees.** All trades involving agent tokens will incur a 1% tax (subject to reduction based on future conditions). 50% of the 1% tax for post-graduation agents will be directed to the Agent SubDAO treasury.

### Rewards Utilization

The Agent SubDAO can decide how to best utilize the rewards accumulated in the treasury via a governance vote when the mechanism is live.

### Validator Rewards

Validators are rewarded based on their voting power. Validators with higher voting power (from more delegated LP tokens) receive higher rewards.

### Penalty System

Validators are also subject to penalties. If a model validated by a validator fails to meet the quality standards or negatively impacts an application, the validator may lose part of their staked tokens or be penalized by losing voting power. This system ensures that validators are held accountable for the models they approve, encouraging them to focus on quality and reliability.

## The Governance Mechanism

Validators within the subDAO will review and approve AI models for deployment and upgrades. By participating in the governance process, validators help maintain quality standards and ensure that sub-par models are not deployed, thus protecting the integrity of the applications and ensuring the best possible user experience.

Validators can only gain voting power through delegation from liquidity providers. This delegated voting power determines their influence over the subDAO’s governance decisions. The more voting power a validator holds, the greater their influence over model quality decisions.

### Voting Process

The voting process allows validators to cast votes on proposals for model upgrades, validations, and other critical governance matters. Votes are weighted based on the validator’s voting power, which is determined by the total amount staked on the validator. Proposals that receive majority votes are approved and implemented, allowing the subDAO to:

* **Upgrade models**: New models are proposed, reviewed, and voted on by validators. If approved, the model is implemented.
* **Enforce penalties**: Validators vote on penalties for other validators that allow poor-quality models to pass, holding them accountable and maintaining overall quality.

### **Model Upgrades**

When validating a model, validators are presented with two models anonymously for comparison. They go through 10 rounds of interaction with each model pair, selecting the better responses. After 10 rounds, a vote is submitted with the final outcomes.

Anonymity in model comparison prevents collusion and bias among validators and contributors, ensuring a fair model selection process.

Virtual Protocol has opted for the Elo Rating System for model comparison.

#### Refining the Elo Rating System

Building on the [foundation](https://colab.research.google.com/drive/1RAWb22-PFNI-X1gPVzc927SGUdfr6nsR?usp=sharing) laid by pioneers like [Fastchat](https://github.com/lm-sys/FastChat), we acknowledge the challenges in stability with traditional Elo ratings. Hence, we've implemented a refined, bootstrap version of the Elo Rating System, enhancing stability and reliability in our model validation outcomes.

A standard Elo Rating Mechanism works as below:&#x20;

```python
def compute_elo(battles, K=4, SCALE=400, BASE=10, INIT_RATING=1000):
    rating = defaultdict(lambda: INIT_RATING)

    for rd, model_a, model_b, winner in battles[['model_a', 'model_b', 'winner']].itertuples():
        ra = rating[model_a]
        rb = rating[model_b]
        ea = 1 / (1 + BASE ** ((rb - ra) / SCALE))
        eb = 1 / (1 + BASE ** ((ra - rb) / SCALE))
        if winner == "model_a":
            sa = 1
        elif winner == "model_b":
            sa = 0
        elif winner == "tie" or winner == "tie (bothbad)":
            sa = 0.5
        else:
            raise Exception(f"unexpected vote {winner}")
        rating[model_a] += K * (sa - ea)
        rating[model_b] += K * (1 - sa - eb)

    return rating

    def preety_print_elo_ratings(ratings):
    df = pd.DataFrame([
        [n, elo_ratings[n]] for n in elo_ratings.keys()
    ], columns=["Model", "Elo rating"]).sort_values("Elo rating", ascending=False).reset_index(drop=True)
    df["Elo rating"] = (df["Elo rating"] + 0.5).astype(int)
    df.index = df.index + 1
    return df

elo_ratings = compute_elo(battles)
preety_print_elo_ratings(elo_ratings)
```

### Dataset Contribution

When a model is fine-tuned using a dataset contributed by others, the Elo rating scored by the model indicates the quality of the dataset. The impact score, derived from the score differences between the proposed model and the existing one, determines whether the proposed model is superior after fine-tuning with the dataset. This enables Virtual Protocol to establish standards for contributed datasets and reject those of lower impact.


---

# Agent Instructions
This documentation is published with GitBook. GitBook is the documentation platform designed so that both humans and AI agents can read, navigate, and reason over technical content effectively. Learn more at gitbook.com.

## Querying This Documentation
If you need additional information that is not directly available in this page, you can query the documentation dynamically by asking a question.

Perform an HTTP GET request on the current page URL with the `ask` query parameter, and the optional `goal` query parameter:

```
GET https://whitepaper.virtuals.io/about-virtuals-1/the-protocol/virtual-agents-as-programmable-decentralized-entities/agent-subdao-governance.md?ask=<question>&goal=<endgoal>
```

`ask` is the immediate question: it should be specific, self-contained, and written in natural language.
`goal` is optional and describes the broader end goal you are ultimately trying to accomplish on behalf of the user. GitBook uses it to tailor the answer towards what is most useful for that goal.

The response will contain a direct answer to the question and relevant excerpts and sources from the documentation.

Use this mechanism when the answer is not explicitly present in the current page, you need clarification or additional context, or you want to retrieve related documentation sections.
