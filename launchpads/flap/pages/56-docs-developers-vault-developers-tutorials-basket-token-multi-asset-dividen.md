# Flap - Using a Basket Token to Distribute Multiple Dividend Assets

> Source: https://docs.flap.sh/flap/developers/vault-developers/tutorials/basket-token-multi-asset-dividends
> Retrieved: 2026-09-02 (GitBook markdown export, https://docs.flap.sh/flap/developers/vault-developers/tutorials/basket-token-multi-asset-dividends.md)

---

> For the complete documentation index, see [llms.txt](https://docs.flap.sh/flap/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://docs.flap.sh/flap/developers/vault-developers/tutorials/basket-token-multi-asset-dividends.md).

# Using a Basket Token to Distribute Multiple Dividend Assets

{% hint style="warning" %}
**Preview.** This document has not been reviewed yet. Content may be incomplete or inaccurate.
{% endhint %}

This tutorial explains a pattern for distributing **multiple underlying assets** as dividends, even though Flap's dividend contract can only track **one** dividend token per tax token. It uses the design from the Stocks Vault (multi-asset index vault) as a worked example - the mechanism generalizes to any vault that needs to pay out a basket of assets through a single-token dividend pipe.

***

## 1. The Constraint: One Dividend Token Per Tax Token

Every Flap tax token has exactly one `dividendToken` configured at launch (see [Vault & VaultFactory Specification](/flap/developers/vault-developers/vault-and-vaultfactory-specification.md)). The dividend contract's accounting - balances, `withdrawableDividends`, `withdrawDividendsFor` - is all built around tracking a **single ERC-20 balance** per holder.

```solidity
interface IIndexVaultDividend {
    function deposit(uint256 amount) external returns (bool success);
    function withdrawDividendsFor(address user) external returns (bool success);
    function withdrawableDividends(address user) external view returns (uint256);
    function dividendToken() external view returns (address);
}
```

This is a deliberate simplification: the dividend contract does one thing well (pro-rata distribution of a single balance) and does not need to know anything about a basket of underlying assets. But it means a vault that wants to pay out **NVDA + AAPL + TSLA** (for example) to its holders cannot deposit three different tokens into the dividend contract - there's only one `dividendToken` slot.

***

## 2. The Solution: A Basket Token as the Dividend Medium

The fix is to introduce an intermediate ERC-20 - a **basket token** - that represents a claim on a pool of underlying assets, and use *that* as the `dividendToken`. Instead of depositing NVDA, AAPL, and TSLA directly, the vault:

1. Buys/receives the underlying assets.
2. Mints basket shares against them.
3. Deposits the basket shares into the dividend contract.

```solidity
interface IIndexBasketToken {
    function mint(address asset, uint256 amount, address to) external returns (uint256 shares);
    function isSupportedAsset(address asset) external view returns (bool);
    function getSubset() external view returns (address[] memory);
    function previewMint(address asset, uint256 amount) external view returns (uint256);
}
```

Now the dividend contract only ever sees **one token** (the basket) - it doesn't need to change at all.

### NAV: why minted shares must equal value spent

The basket token tracks a Net Asset Value (NAV) in USD across its pooled assets:

```solidity
function totalNavUsd() public view returns (uint256 nav) {
    uint256 len = _subset.length;
    for (uint256 i; i < len; ++i) {
        nav += assetValueUsd(_subset[i], pooledAmount[_subset[i]]);
    }
}
```

{% hint style="warning" %}
**Minting must use a live oracle-priced NAV, not a fixed rate.** Every component asset needs a live USD price feed so `totalNavUsd()` reflects the basket's *current* value at mint time. Minting shares 1:1 against a fixed/assumed price (e.g. "1 unit of asset = X USD, always") would let the share ⇄ NAV ratio drift the moment any component's real price moves, silently diluting or over-crediting whoever mints next. The oracle read in `assetValueUsd()` below is not optional.
{% endhint %}

When a vault mints new shares, it must mint an amount that keeps the **share ⇄ NAV ratio constant** - otherwise existing holders get diluted or unfairly enriched. That means every mint must re-read each component asset's **current** oracle price to compute both the deposit's USD value and the basket's total NAV - never a cached or assumed price. The formula used is the standard proportional-mint formula:

```solidity
uint256 supplyBefore = totalSupply();
uint256 navBefore = totalNavUsd();       // sum of oracle USD price × pooled amount, across all components
uint256 depositValue = assetValueUsd(asset, amount); // oracle USD price × amount

if (supplyBefore == 0) {
    // First mint seeds the ratio 1:1 with USD value (minus a small locked-liquidity buffer)
    shares = depositValue - MINIMUM_LIQUIDITY;
} else {
    // shares = depositValue * supplyBefore / navBefore
    shares = Math.mulDiv(depositValue, supplyBefore, navBefore);
}
```

`assetValueUsd()` and `totalNavUsd()` both depend on a live price feed per component asset - this is why the basket token needs its own oracle wiring (or a factory-level price registry it can read from). There is no shortcut that lets you skip pricing components individually: NAV is, by definition, the sum of each component's *current* value.

{% hint style="info" %}
**Why USD, not the quote asset (e.g. BNB)?** Component assets (stocks, RWAs, etc.) are natively priced in USD by most oracle providers. Denominating NAV in USD means you consume each component's price feed directly, with no extra conversion step. If you instead tried to denominate NAV in BNB, you'd still need a USD price for every component (that's how they're quoted) *plus* a BNB/USD feed to convert - an extra moving part and an extra point of oracle staleness/failure, for no benefit. USD is the natural, minimal-dependency unit here.
{% endhint %}

This is the same reason **the amount of basket token minted (and then deposited into the dividend contract) must equal the USD value of BNB that was actually spent** buying the underlying asset. If a vault only sold `X` BNB worth of NVDA, it can only mint (and pay out) shares worth that same USD amount - never more. This keeps the basket's NAV per share honest: every share always redeems for the same proportional value it was minted at, regardless of how many times mint/unwrap happens afterward.

{% hint style="info" %}
Single-asset baskets (a vault backed by just one underlying token) skip the NAV math entirely and mint 1 share per 1 unit of the underlying token - no oracle read needed, and no rounding drift.
{% endhint %}

***

## 3. The Trick: Users Never Need to Hold the Basket Token

A basket token is an implementation detail - end users should never need to understand it, hold it, or manually redeem it. This is solved with an **auto-unwrap-on-transfer** hook on the basket token itself:

```solidity
function _transfer(address from, address to, uint256 value) internal override {
    if (!_unwrapping && value != 0 && from != address(0) && to != address(0)) {
        address dividendContract = IFlapTaxTokenV3(taxToken).dividendContract();
        if (dividendContract != address(0) && from == dividendContract) {
            // Transfer FROM the dividend contract triggers a pro-rata unwrap
            // instead of a normal ERC-20 transfer.
            _unwrapFrom(from, to, value);
            return;
        }
    }
    super._transfer(from, to, value);
}
```

The key insight: the dividend contract's `withdrawDividendsFor(user)` internally does an ERC-20 `transfer` of the basket token from itself to the claiming user. The basket token's overridden `_transfer` detects that the sender is the dividend contract and, instead of moving basket-token balance, it **burns the shares and releases the underlying assets pro-rata directly to the user**:

```solidity
function _unwrapFrom(address from, address to, uint256 shares) internal returns (uint256[] memory amounts) {
    uint256 supplyBefore = totalSupply();
    // amounts[i] = pooledAmount[asset_i] * shares / supplyBefore
    // ... burns `shares`, transfers each underlying asset slice to `to`
}
```

So from the user's perspective: they call `withdrawDividendsFor(self)` (or someone calls it for them) and **NVDA, AAPL, TSLA (or whatever assets are in the basket) land directly in their wallet** - they never see or hold the basket token itself. The basket token only ever "exists" transiently between the vault's `mint()` call and the dividend contract's payout.

***

## 4. Bonus: Other Launches Can Reuse This Basket as Their Dividend Token Too

The auto-unwrap trick isn't locked to a single tax token. If you're launching your **own** token and want the same "holders receive real underlying assets automatically" experience, you don't need to build your own vault + basket + dividend plumbing from scratch:

> **We can whitelist your token to use an existing basket as its `dividendToken`.**

When your `dividendToken` points at a whitelisted basket, our automation handles the distribution side for you - deposits into the dividend contract and the resulting payouts to your holders are managed the same way as the vault's own flow, so your holders still get the auto-unwrap experience (real underlying assets landing in their wallet, never the basket token itself) without you having to run any of that infrastructure yourself.

If your use case is instead "distribute a single fixed known asset" (like WBNB or an LP pair) rather than a multi-asset basket, see [Using an LP Token or Child Token as the Dividend Token](/flap/developers/vault-developers/tutorials/lp-token-as-dividend.md) for that simpler pattern.

***

## Summary

| Step                                | What happens                                                                                                                                          | Why                                                                                                                                                                                                    |
| ----------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 1. Dividend contract limitation     | Tracks exactly one `dividendToken` balance per holder                                                                                                 | Keeps dividend accounting simple and general                                                                                                                                                           |
| 2. Basket token as medium           | Vault mints basket shares against the **current oracle-priced USD NAV** of assets bought, deposits shares (not raw assets) into the dividend contract | Lets a single-token dividend pipe represent a multi-asset basket; shares minted must equal the live USD value of BNB spent, preserving NAV per share - a fixed/assumed price would let the ratio drift |
| 3. Auto-unwrap on claim             | Basket token's `_transfer` override detects transfers from the dividend contract and unwraps to underlying assets instead                             | Users never need to acquire, hold, or manually redeem the basket token                                                                                                                                 |
| 4. Whitelistable for other launches | A new token can point its `dividendToken` at an existing whitelisted basket                                                                           | Other launches get the same auto-unwrap payout experience without building their own vault/basket/dividend stack                                                                                       |
