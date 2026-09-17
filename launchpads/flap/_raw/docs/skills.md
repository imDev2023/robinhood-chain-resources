> For the complete documentation index, see [llms.txt](https://docs.flap.sh/flap/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://docs.flap.sh/flap/skills.md).

# Flap Skills for AI Agents

Flap publishes AI-agent skills that any compatible coding/agent assistant can use — Claude Code, Codex, OpenClaw, Hermes, or another agent that supports this skill format. You can invoke them directly from a chat with your agent.

***

## Launch a BNB Token on Flap

**Registry page:** [clawhub.ai/flapguy/launch-bnb-token-on-flap](https://clawhub.ai/flapguy/launch-bnb-token-on-flap) (v1.3.0)

This skill walks an AI assistant through every step required to launch a **Flap Tax Token V3** on Flap (BNB Chain): uploading metadata to IPFS, mining a vanity salt, encoding calldata, and broadcasting the transaction.

{% hint style="info" %}
As of v1.3.0, this skill only launches tax tokens (Flap Tax Token V3). Standard (non-tax) token launches are no longer supported. It also supports launching against any quote token Flap offers on BNB Chain — not just native BNB — resolved live from Flap's quote-tokens API.
{% endhint %}

### How to use

Give your agent a prompt like one of the examples below. The skill handles the rest.

***

### Example 1 — Tax token gifted to an X account (Gift Vault)

Launch a tax token whose trading fees are gifted to the X account `@elonmusk` using the **Gift Vault**. No vault factory address is needed — just refer to it by name.

```
Launch a tax token on Flap BNB called "Elon's Rocket" with symbol ROKYT.
Use the Gift Vault and set the gift owner to the X account @elonmusk.
Set buy tax and sell tax both to 5%.
Spend 0.00001 BNB on the initial buy.
```

***

### Example 2 — Tax token with a custom vault factory

Launch a tax token and route its fees through a specific vault factory you have already deployed.

```
Launch a tax token on Flap BNB called "Alpha Fund" with symbol ALFX.
Use the vault factory at address 0xAbCd1234AbCd1234AbCd1234AbCd1234AbCd1234 to set up the vault.
Set buy tax to 3% and sell tax to 3%.
Skip the initial buy.
```

***

### Example 3 — Tax token without a vault

Launch a straightforward tax token with no vault. Fees go directly to a beneficiary address.

```
Launch a tax token on Flap BNB called "Simple Tax" with symbol SMTX.
No vault. Set buy tax to 0% and sell tax to 3%.
Set the beneficiary to 0xYourBeneficiaryAddressHere.
Spend 0.05 BNB on the initial buy.
```

***

### Example 4 — Tax token quoted against a non-BNB token

Launch a tax token that quotes and launches against a different Flap-supported quote token (e.g. `USDT`) instead of native BNB. The skill fetches the current BNB-chain quote token list from Flap and resolves the token's address/decimals automatically.

```
Launch a tax token on Flap BNB called "Dollar Tax" with symbol DTAX.
Quote it against USDT instead of BNB.
No vault. Set buy tax to 2% and sell tax to 5%.
Spend 50 USDT on the initial buy.
```

***

### Using this skill with the Binance Agentic Wallet

Want your agent to sign in to a wallet and broadcast the launch transaction itself, end to end, from chat? See [Using Flap Skills with the Binance Agentic Wallet](/flap/skills/using-with-binance-agentic-wallet.md) for a full walkthrough — installing both skills, signing in, the required wallet security settings, and a worked example launching a token quoted against a BStock.
