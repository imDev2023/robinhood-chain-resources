# Virtuals Protocol - Commonly Asked Questions

> Source: https://whitepaper.virtuals.io/builders-hub/commonly-asked-questions
> Retrieved: 2026-09-02 (GitBook .md endpoint via curl)

---

# Commonly Asked Questions

This documentation is intended for agent creators to get access to answers to frequently asked questions from the community. It is updated regularly by the Virtuals team..&#x20;

## FAQs for Ecosystem Token Holders

<details>

<summary>Why do I get taxed?</summary>

There is a 1% trading fee being charged. 1% trading fee will be flowed to agent wallets to sustain the cost incurred for agent to performed. Fee collected from the prototypes agents will be flowed as platform revenue.&#x20;

For more info on trading fee distribution: <https://x.com/virtuals_io/status/1879474995333939356>&#x20;

</details>

<details>

<summary>What is prototypes and sentient agent?</summary>

Prototypes agents are the agents that have not graduated from bonding curve. Sentient Agents are the ones hit market cap and graduated

</details>

<details>

<summary>Where can I know more about Virtuals?</summary>

Head over to [whitepaper.virtuals.io](http://whitepaper.virtuals.io) for more details.

</details>

<details>

<summary>How do I unstake my xVirtuals from legacy mechanism?</summary>

To unstake your **xVirtuals** from the legacy staking mechanism, follow these steps using BaseScan:

**Step 1: Find Your Staked xVirtuals**

1. Go to [BaseScan](https://basescan.org/).
2. Enter your **wallet address** in the search bar.
3. Under the **"Tokens"** tab, find the token name **"xVirtuals"**.
4. Click on the **xVirtuals token**, and you will land on the token contract page.

**Step 2: Check Your Staked Deposits**

1. Navigate to the **"Contract"** tab.
2. Click on **"Read Contract"**.
3. Look for the function **`getDepositsOf(address)`**.
4. Enter your **wallet address** and click **"Query"**.
5. You will see an array of deposits displayed like this:<br>

   <pre data-title="[ getDepositsOf(address) method Response ]"><code>[
     [7186826061000000000000, 114989216976000000000000, 1712546271, 1838690271],
     [150000000000000000000000, 287594178082191780750000, 1715000000, 1840000000]
   ]
   </code></pre>
6. The **deposit ID** is based on the **array index** (starting from `0`).
   * Example:
     * **First deposit** → `_depositId = 0`
     * **Second deposit** → `_depositId = 1`
7. Decide which deposit you want to withdraw and **note down the `depositId`**.

**Step 3: Unstake Your xVirtuals**

1. Stay on the **"Contract"** tab and switch to **"Write Contract"**.
2. Click **"Connect to Web3"** and connect your MetaMask (or other compatible wallet).
3. Find the function **`withdraw(uint256, address)`**.
4. Input the following:
   * **First field (`_depositId`)** → Enter the `depositId` from Step 2.
   * **Second field (`_receiver`)** → Enter your **wallet address** (or the recipient’s address).
5. Click **"Write"** and confirm the transaction in your wallet.

#### **Step 4: What Happens After Withdrawal?**

* Your **original deposit amount** will be **returned to your wallet**.
* The **share amount (`shareAmount`) is not transferred**—it only acts as a **multiplier** for rewards on [**legacy.virtuals.io**](https://legacy.virtuals.io/).
* Once withdrawn, the **share amount is burned**, meaning you can no longer use it to claim staking rewards.

</details>

<details>

<summary>What is veVIRTUAL? </summary>

veVIRTUAL is your VIRTUAL voting power. It mirrors the transactions made on $VIRTUAL. It does not hold any monetary value, only voting power. We suggest that you avoid interacting with it.

</details>


---

# Agent Instructions
This documentation is published with GitBook. GitBook is the documentation platform designed so that both humans and AI agents can read, navigate, and reason over technical content effectively. Learn more at gitbook.com.

## Querying This Documentation
If you need additional information that is not directly available in this page, you can query the documentation dynamically by asking a question.

Perform an HTTP GET request on the current page URL with the `ask` query parameter, and the optional `goal` query parameter:

```
GET https://whitepaper.virtuals.io/builders-hub/commonly-asked-questions.md?ask=<question>&goal=<endgoal>
```

`ask` is the immediate question: it should be specific, self-contained, and written in natural language.
`goal` is optional and describes the broader end goal you are ultimately trying to accomplish on behalf of the user. GitBook uses it to tailor the answer towards what is most useful for that goal.

The response will contain a direct answer to the question and relevant excerpts and sources from the documentation.

Use this mechanism when the answer is not explicitly present in the current page, you need clarification or additional context, or you want to retrieve related documentation sections.
