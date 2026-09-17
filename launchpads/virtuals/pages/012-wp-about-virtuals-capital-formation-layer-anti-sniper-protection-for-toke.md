# Virtuals Protocol - Anti-Sniper Protection for Token Launches

> Source: https://whitepaper.virtuals.io/about-virtuals/capital-formation-layer/anti-sniper-protection-for-token-launches
> Retrieved: 2026-09-02 (GitBook .md endpoint via curl)

---

# Anti-Sniper Protection for Token Launches

### Token launch anti-sniper protection

Anti-Sniper Protection is a free Virtuals Protocol launch module for AI agent token launches. It applies a dynamic buy-side tax at TGE. This reduces bot activity and opportunistic token sniping during early trading.

The module is activated by default and is free.

<figure><img src="/files/xS0Uz5CTckVbtBZL405p" alt=""><figcaption><p>Dynamic buy-tax decay during the TGE protection window.</p></figcaption></figure>

### How the dynamic sniper tax works

The sniper tax starts at 99% at TGE.

* It decays to the 1% baseline trading tax over the founder's chosen protection window.
* Founders choose which side of trading the tax applies to:
  * **Buy:** protects against bots sniping the token on the way in. This is the default.
  * **Sell:** discourages early holders from dumping into thin liquidity.
  * **Buy & sell:** applies the decaying tax to both sides simultaneously.
* Sniper taxes collected during the window fund automatic on-chain agent token buybacks.
* Repurchased tokens go to the team wallet. They follow a three-month cliff and nine-month linear vesting schedule.

This token launch protection helps defend early liquidity from bots and snipers. It converts early trading tax into long-term alignment for project founders.

### Configure the TGE protection window

Founders set the protection window and side (buy, sell, or buy & sell) during the creation phase, choosing from four preset windows. The tax decay rate adjusts automatically to reach the 1% baseline by the end of the chosen window.

Available windows:

* **0 seconds:** no anti-sniper protection applies. Trading tax remains 1% from launch.
* **60 seconds:** tax decays from 99% to 1% over one minute.
* **10 minutes:** tax decays from 99% to 1% over ten minutes.
* **98 minutes:** tax decays from 99% to 1% over 98 minutes, roughly 1% per minute.

The 60-second and 10-minute presets currently apply to buy-side trading only. The 98-minute preset can be applied to buy-side, sell-side, or both, giving founders the most granular control over their launch's protection profile.

### Anti-Sniper Protection FAQ

<details>

<summary>When do sniper-tax buybacks begin?</summary>

Buybacks start automatically as soon as the configured protection window ends and the tax on the protected side (buy or sell) reaches the baseline 1%.

</details>

<details>

<summary>Are collected sniper taxes used in one buyback?</summary>

No. Onchain buybacks are executed gradually over 24 hours.

</details>

<details>

<summary>Can I change the anti-sniper protection window after launch?</summary>

No. The protection window is set during creation and cannot be modified after the Agent Launch Page is published.

</details>


---

# Agent Instructions
This documentation is published with GitBook. GitBook is the documentation platform designed so that both humans and AI agents can read, navigate, and reason over technical content effectively. Learn more at gitbook.com.

## Querying This Documentation
If you need additional information that is not directly available in this page, you can query the documentation dynamically by asking a question.

Perform an HTTP GET request on the current page URL with the `ask` query parameter, and the optional `goal` query parameter:

```
GET https://whitepaper.virtuals.io/about-virtuals/capital-formation-layer/anti-sniper-protection-for-token-launches.md?ask=<question>&goal=<endgoal>
```

`ask` is the immediate question: it should be specific, self-contained, and written in natural language.
`goal` is optional and describes the broader end goal you are ultimately trying to accomplish on behalf of the user. GitBook uses it to tailor the answer towards what is most useful for that goal.

The response will contain a direct answer to the question and relevant excerpts and sources from the documentation.

Use this mechanism when the answer is not explicitly present in the current page, you need clarification or additional context, or you want to retrieve related documentation sections.
