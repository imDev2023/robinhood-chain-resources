# Flap - Tax Token V2

> Source: https://docs.flap.sh/flap/developers/basic-and-mechanism/flap-tax-token/tax-token-v2
> Retrieved: 2026-09-02 (GitBook markdown export, https://docs.flap.sh/flap/developers/basic-and-mechanism/flap-tax-token/tax-token-v2.md)

---

> For the complete documentation index, see [llms.txt](https://docs.flap.sh/flap/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://docs.flap.sh/flap/developers/basic-and-mechanism/flap-tax-token/tax-token-v2.md).

# Tax Token V2

## Overview

The V2 tax token let you split the tax for different usage:

<figure><img src="/files/BJsaPakkd2qAF6xyDjGr" alt="" width="375"><figcaption></figcaption></figure>

{% hint style="warning" %}
When the "Funds Recipient Wallet" section is 100%, a v1 tax token will be created instead
{% endhint %}

### Tax Processor & Dividend

<figure><img src="/files/mWZ4cgy43DPnhBJLUKRF" alt=""><figcaption></figcaption></figure>

For every Tax Token V2 launch, the following contracts are deployed:

1. **Tax Processor** - Always deployed
2. **Dividend Contract** - Optionally deployed if dividend distribution is enabled (when `dividendBps > 0`)

When the token is still trading on the bonding curve (before DEX migration):

```
User buys/sells on Portal bonding curve
    ↓
Portal collects extra trading fee as tax in quote tokens (WETH/BNB/USDT/etc.)
    ↓
Portal sends extra fee to TaxProcessor.processBondingCurveTax(quoteAmount)
    ↓
Tax Processor accumulates quote tokens for later distribution
```

While the token is migrated to DEX and when users trade the Flap Tax Token V2 on DEX:

```
User trades token on DEX
    ↓
Tax Token V2 applies tax (e.g., 5%) on transfer
    ↓
Tax tokens accumulate in Token contract
    ↓
When threshold reached → Triggers tax liquidation
    ↓
Token contract calls TaxProcessor.processTaxTokens(taxAmount)
```

**Anyone** can call `TaxProcessor.dispatch()` to distribute accumulated funds:

```
Anyone calls dispatch()
    ↓
1. Send feeQuoteBalance → Funds Recipient Wallet
2. Send marketQuoteBalance → Market Address
3. Send dividendQuoteBalance → Dividend Contract
4. Process preBondBurnFunds (the quote accumuated on bonding curve phase for the burn):
   - If token on bonding curve: Use Portal to buyback & burn
   - If token on DEX: Swap quote tokens for tax tokens & burn  
5. Process burn: 
   - Send token to flapBlackHole or Burn address 
```

* Flap Tax Trigger Bot monitors balances and calls `dispatch()` when economically viable
* Bot pays gas fees to ensure timely distribution
* Anyone can call dispatch() if they want to pay the gas

If dividend contract is deployed (`dividendBps > 0`):

```
Token holder balance changes (buy/sell/transfer)
    ↓
Token contract calls Dividend.setShare(user, newBalance)
    ↓
Dividend contract updates user's share
    ↓
Settles any pending rewards before share change
```

**Excluded from dividends:**

* DEX pool addresses
* Token contract itself
* Dividend contract
* Dead address (0x000...dEaD)
* FlapBlackHole
* Zero address
* Addresses with balance below `minimumShareBalance`

**Manual Claiming:**

```
Token holder calls withdrawDividends()
    ↓
Dividend contract calculates withdrawable amount
    ↓
If dividendToken == WETH: Unwraps to ETH and sends
If dividendToken == other: Sends ERC20 tokens
    ↓
Updates withdrawnDividends tracking
```

**Automated Claiming (by Bot):**

```
Flap Tax Trigger Bot monitors pending dividends
    ↓
When holder's pending > threshold:
    Bot calls distributeDividend([holder1, holder2, ...])
    ↓
Dividend contract sends rewards to holders
    ↓
Bot pays gas fees
```

**Anyone Can Trigger:**

```
Any external caller can call:
- withdrawDividendsFor(user) - claim for specific user
- distributeDividend([users]) - batch claim for multiple users
- Caller pays gas fees
```
