# Flap - Tax Token V1

> Source: https://docs.flap.sh/flap/developers/basic-and-mechanism/flap-tax-token/tax-token-v1
> Retrieved: 2026-09-02 (GitBook markdown export, https://docs.flap.sh/flap/developers/basic-and-mechanism/flap-tax-token/tax-token-v1.md)

---

> For the complete documentation index, see [llms.txt](https://docs.flap.sh/flap/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://docs.flap.sh/flap/developers/basic-and-mechanism/flap-tax-token/tax-token-v1.md).

# Tax Token V1

{% hint style="info" %}
Tax Token V1 is still used and maintained. A V1 Tax token is created when you are using the vault mode or when 100% tax to Funds Recipient Wallet.
{% endhint %}

## Overview

In V1 tax token, all the tax will be sent to a single beneficiary. However, you can build a smart contract as the beneficiary to receive the tax, where you can implement your own logics. We have a recommended interface for such contracts (check [https://github.com/flap-sh/gitbook/tree/main/developers/basic-and-mechanism/flap-tax-token/flap-tax-vault.md](https://github.com/flap-sh/gitbook/tree/main/developers/basic-and-mechanism/flap-tax-token/flap-tax-vault.md "mention") for more details)

## Tax Splitter

To avoid DOS, we do not liquidate and distribute the Tax in the tax token directly. For each v1 tax token, a "Tax Splitter" contract will be deployed on creation. Both the liquidated Tax (when token is on DEX) and the Tax on the bonding curve will be directly sent to the "Tax Splitter" first. Then anyone could trigger the tax distribution by calling the "Tax Splitter" contract's `split` method. However, for most of the time you don't need to manually call "Tax Splitter" yourself , Flap will run a bot to automatically trigger the distribution when needed.

<figure><img src="/files/rhRbQxMHjRVl34PDtq4w" alt=""><figcaption></figcaption></figure>
