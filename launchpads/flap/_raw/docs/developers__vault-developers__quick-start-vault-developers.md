> For the complete documentation index, see [llms.txt](https://docs.flap.sh/flap/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://docs.flap.sh/flap/developers/vault-developers/quick-start-vault-developers.md).

# Quick start for Vault Developers

Welcome to Flap Vault. Please follow the steps below to build your Vault.

{% hint style="info" %}
**Permissionless vault creation** — You can create and deploy your own vaults and vault factories **without any permission or registration**. Vault factories no longer need to be registered in the VaultPortal before they can be used to launch tokens, and users can use any vault they want when launching a token.
{% endhint %}

## 1. Start with the example repo

Work through the [FlapVaultExample repository](https://github.com/flap-sh/FlapVaultExample) for a complete, working example of a vault and vault factory implementation. It is the fastest way to understand the patterns you need to follow.

Quick-start Vault example: [`src/FreeCoinBeacon.sol`](https://github.com/flap-sh/FlapVaultExample/blob/main/src/FreeCoinBeacon.sol)

## 2. Confirm your design if needed

You can implement any vault logic you want — there is no gatekeeping if you don't need the low-risk badge. If you are unsure whether your Vault design, decentralization model, or implementation meets Flap's standard for the low-risk badge specifically, feel free to reach out before building too much and we can help review and improve your plan. Even if you do want the badge, you don't need to lock in your design up front — you can launch on the [beacon proxy pattern](/flap/developers/vault-developers/case-study-beacon-upgradeable-vault.md) and upgrade later if something needs to change.

## 3. Check if Flap infrastructure already solves part of your problem

Before you build a custom backend for your vault, check whether one of Flap's existing pieces of infrastructure already covers it. These are shared, audited services any vault can call into — you don't need to run your own signing service, scheduler, or oracle backend.

| If you need to...                                                                                                          | Use...                                                                                                                                                                                                                                                                                                     |
| -------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Schedule a delayed or MEV-protected callback (e.g. a keeper that fires a buyback, unlock, or distribution at a later time) | [Flap Trigger Service](/flap/developers/preview/flap-trigger-service.md) — request a `trigger()` callback for or after a given timestamp, executed by a trusted backend.                                                                                                                                   |
| Verify that a specific X (Twitter) account posted a specific piece of text before letting a vault action proceed           | [X General Verifier](/flap/developers/preview/x-general-verifier.md) — a generalized, stateless on-chain verifier + off-chain oracle. Not limited to the fixed "gift the fee" sentence used by [Gift Vault](/flap/developers/vault-developers/gift-vault.md); you choose the substring your vault expects. |
| Get a verifiable LLM/AI decision on-chain (e.g. an AI-moderated vault or agent-driven logic)                               | [Flap AI Oracle](/flap/developers/preview/flap-ai-oracle.md) — commit-and-reveal AI reasoning with an on-chain auditable IPFS proof of every decision.                                                                                                                                                     |

{% hint style="info" %}
These pages live under **Preview** in the docs — they're still evolving, but the deployed contracts are live and usable today. If your vault design doesn't fit any of the patterns documented on those pages, [reach out to us](https://flap.sh) — we're happy to help you integrate, or to hear what new infrastructure you might need.
{% endhint %}

## 4. Run a basic self-check

After building your Vault, use the [Vault spec checker](https://github.com/flap-sh/FlapVaultExample/blob/main/.agents/skills/flap-vault-spec-checker/SKILL.md) for a basic review before you move on to writing tests.

## 5. Write integration tests

We highly recommend writing integration tests before submitting for audit.

Reference test: [`test/FreeCoinBeacon.mainnet.t.sol`](https://github.com/flap-sh/FlapVaultExample/blob/main/test/FreeCoinBeacon.mainnet.t.sol)

## 6. Test on BNB / Robinhood Testnet

You can also test your Vault on BNB Testnet or Robinhood Testnet: <https://testnet.flap.sh>

## 7. Audit and low-risk badge

Audit is **optional** — you can launch without one. However, if you want a low-risk badge, your Vault must pass an audit from our partner audit company.

Current cost: 0.5 BNB / 0.16 ETH per factory.

{% hint style="success" %}
If you launch your token using the recommended [beacon proxy pattern](/flap/developers/vault-developers/case-study-beacon-upgradeable-vault.md), you don't have to complete the audit before launch — you can launch first and do the audit afterwards. If the audit finds an issue, the vault can be upgraded through the beacon to fix it. See [Building Upgradeable Vaults — Beacon Proxy Pattern](/flap/developers/vault-developers/case-study-beacon-upgradeable-vault.md) for details.
{% endhint %}

## 8. Bespoke UI

If you want a custom UI, use the [flap-vault-component-template](https://github.com/flap-sh/flap-vault-component-template). See [Building a Vault UI](/flap/developers/vault-developers/building-a-vault-ui.md) for a full walkthrough: the four-file package boundary, manifest binding, SDK usage, the mandatory risk-status display, and the check/package/handoff pipeline.

After your Vault audit passes, you can submit the UI for review.

## 9. Optional: align on your launch plan with us

If you would like our support, you can align with the Flap team on your launch setup, such as whether to lock the CA, make the factory exclusive to a specific developer address, when to bind the UI, and when to display the low-risk badge.

Feel free to reach out to the Flap team anytime during the process. @I0ene @JingYixiaozhang @cedricflap

## Further reading

* Review the [Vault & VaultFactory specification](/flap/developers/vault-developers/vault-and-vaultfactory-specification.md) for the full interface definitions and how to build your own vaults and vault factories.
* Read the [Flap Tax Vault](/flap/developers/vault-developers/flap-tax-vault.md) documentation for an overview of the vault concept and VaultPortal integration.
* Explore registered (i.e. verified by Flap) vaults in the [Registered Vaults](/flap/developers/token-launcher-developers/registered-vaults.md) page to see available vault factories and their configuration schemas.
* Learn about the [Gift Vault](/flap/developers/vault-developers/gift-vault.md) family and how to integrate X proof-based revenue routing.
* Building a custom UI? See [Building a Vault UI](/flap/developers/vault-developers/building-a-vault-ui.md) for the full walkthrough based on the [flap-vault-component-template](https://github.com/flap-sh/flap-vault-component-template).
* Need a keeper, a social-proof check, or an on-chain AI decision? See [Flap Trigger Service](/flap/developers/preview/flap-trigger-service.md), [X General Verifier](/flap/developers/preview/x-general-verifier.md), and [Flap AI Oracle](/flap/developers/preview/flap-ai-oracle.md) — shared infrastructure you can plug into your vault instead of building your own.

## Available vault types

Flap currently supports the following official vault types:

1. **Split Vault** - Distributes BNB revenue across multiple recipients based on configurable basis points (percentage shares)
2. **Gift Vault** - Routes revenue based on X (Twitter) proof verification, with a fallback that varies by version (buyback & burn for V1, holder dividends for V2)

## Common workflows

1. **Launch a token with a custom vault** — You can launch a token and set the fund recipient wallet to your smart contract. If it follows the spec defined in the [Vault & VaultFactory specification](/flap/developers/vault-developers/vault-and-vaultfactory-specification.md), its info will be automatically available on our website and partner websites. No registration is required.
2. **Build a vault factory for others** — If you have an idea to build a vault to be used by others, you can build a `VaultFactoryBaseV2` and take a portion of the tax as a commission in each vault you create. Implement `vaultDataSchema()` so the UI can automatically render a launch form for your vault type. See the [Vault & VaultFactory specification](/flap/developers/vault-developers/vault-and-vaultfactory-specification.md) for full details.
