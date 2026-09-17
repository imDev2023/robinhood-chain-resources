# Building with Stock Tokens

> Source: <https://docs.robinhood.com/chain/building-with-stock-tokens>
> Retrieved: 2026-08-12 (Tavily extract, advanced depth)

---

# Building with Stock Tokens

Stock tokens are standard ERC-20 tokens, so building with them uses the same patterns you already know — plus onchain price feeds for real-world asset data. This guide covers what you can build, how to integrate, and how to get started.

## Use cases

| Use case | What it looks like | Example |
| --- | --- | --- |
| Portfolio & display | Show balances and live USD value | A wallet view listing a user's NVDA, AAPL, SPY tokens with real-time value and daily P&L |
| Trading | RFQ swap interfaces | An embedded widget that quotes NVDA ↔ USDG via 0x RFQ and settles onchain |
| Lending & borrowing | Stock tokens as collateral | Deposit NVDA as collateral on a lending market and borrow USDG — liquidity without selling |
| Indices & baskets | Bundle tokens into one product | An "AI basket" (NVDA, MSFT, GOOGL) that auto-values from each token's Chainlink feed |
| Yield strategies | Earn on equity exposure | A vault that supplies stock tokens to a lending market so holders earn yield on top of dividends |
| Price-aware contracts | Logic that reacts to equity prices | A contract that executes when a stock token crosses a threshold — onchain conditional logic |
| Perps & derivatives | Equity-backed leverage | Use stock tokens as margin or underlying on a perps venue |
| Global access (in eligible regions) | Equity exposure where direct access is limited | An app offering US-equity exposure to users in eligible regions |

*Tokenized stocks trade via RFQ at launch. They remain standard ERC-20s and can be transferred and held in any wallet.*

## Trading Venues & Liquidity

### Overview

Stock Tokens are standard ERC-20 assets and can be held or transferred in any compatible wallet. For trading, several venues are available.

### Liquidity Sources

#### RFQ

RFQ uses signed market-maker quotes sourced through aggregators such as 0x RFQ, 1inch Fusion, and LiFi. Wallets and exchanges can leverage RFQ as a source of liquidity by integrating these aggregators.

#### AMM

Stock Tokens can also be traded through standard automated market maker (AMM) pools such as Uniswap. AMM pools provide composable, on-chain liquidity that DeFi applications can integrate directly into smart-contract flows.

#### Proprietary AMM (propAMM)

Where on-chain AMM liquidity is limited, Stock Tokens can also be traded through proprietary AMM (propAMM) like Rialto, which provides market-maker-backed liquidity. Because it's onchain, a propAMM offers composable liquidity that DeFi applications can integrate directly into smart-contract flows — unlike RFQ, which relies on off-chain signed quotes.

#### Direct mint & burn

Stock Tokens are minted and burned directly with the issuer, Robinhood Assets (Jersey) Limited in the primary market. This is the ultimate source of Stock Token supply and underpins secondary-market liquidity. Direct mint/burn is available only to Authorized Participants / market makers and requires KYB onboarding; regular holders acquire and exit positions on the secondary market through the venues above.

> **Archive note, not source text (2026-09-03): the sentence above is contradicted by the issuer's own FAQ, and the FAQ is the better authority on redemption.**
> `https://docs.robinhood.com/rhj/faq`, under "Can I redeem my Stock Tokens?", says verbatim:
> "Yes. You can sell your Stock Tokens from time to time in the secondary market. You can also redeem them directly with the Issuer, where there is no authorized participant (a firm that processes redemptions on investors' behalf), subject to completing the Issuer's KYC/AML (identity verification) processes."
> So **minting** is Authorized-Participant-only, but **redemption** is not: an ordinary holder can redeem directly with RHJ where no authorized participant exists, subject to KYC/AML rather than KYB.
> Verified against the page source in the docsite bundle on 2026-09-03 and archived at `39-rhj-faq.md`.

#### Orderbook

Stock Tokens also trade on Lighter (spot & perps). Refer to the Lighter Domain for specific integration details.

## Integrations, contracts & APIs

### Contracts

Stock tokens are ERC-20 (18 decimals). All standard token operations work without modification:

```
IERC20 nvda = IERC20(NVDA_TOKEN_ADDRESS);
uint256 balance = nvda.balanceOf(user);
nvda.transfer(recipient, amount);
nvda.approve(spender, amount);
```

Stock tokens also implement ERC-8056 (Scaled UI Amount Extension), which defines the corporate-action multiplier (`uiMultiplier()`). The multiplier scales the effective amount without changing raw balances or total supply — `balanceOf()` and `totalSupply()` stay fixed. Stock tokens are not rebasing tokens. See the ERC-8056 spec.

Find all stock tokens and ETF addresses on the [Token Contracts](/chain/contracts) page.

### Prices

Every stock token has a per-asset Chainlink price feed implementing the standard `AggregatorV3Interface` (`latestRoundData()`, read via the feed proxy — same interface as crypto feeds):

```
AggregatorV3Interface feed = AggregatorV3Interface(NVDA_PRICE_FEED);
(, int256 price, , uint256 updatedAt, ) = feed.latestRoundData();
require(price > 0 && updatedAt > 0, "Invalid price");
```

The Chainlink price already includes the corporate-action multiplier (dividends, splits), so the value you read is the token's full price — don't apply the multiplier yourself. If you need the raw ratio, read it onchain via the token's `uiMultiplier()`.

See [Oracles & Price Feeds](/chain/oracles-and-price-feeds) for feed addresses, decimals, and best practices (staleness checks, sequencer uptime).

> **Archive note, not source text (2026-09-03): the published dividend rate does not predict the multiplier delta, so do not try to derive one from the other.**
> `https://api.robinhood.com/rhj/corporate-actions` publishes a cash-dividend `rate` per action, and the token's `uiMultiplier()` moves when the action is applied.
> If the multiplier delta were simply the dividend reinvested at the share price, then `delta = D / P` and the implied price `P = D / delta` should land near the real share price for every token.
> It does not.
> Using the rates in that feed against the multiplier deltas recorded in `31-onchain-verification.md`:
>
> | Symbol | Published rate | Multiplier delta | Implied reinvestment price |
> | --- | --- | --- | --- |
> | ASML | 1.817086 | 0.000101323251417769 | 17,933.55 |
> | COST | 1.47 | 0.000612040296259656 | 2,401.80 |
> | F | 0.15 | 0.000145502866134027 | 1,030.91 |
> | AAPL | 0.27 | 0.000566080061092436 | 476.96 |
> | SGOV | 0.306812 | 0.002120251003214918 | 144.71 |
> | CCL | 0.15 | 0.021486444855206408 | 6.98 |
>
> None of these are plausible share prices, they are not a constant multiple of one, and they err in both directions, so this is not a flat withholding or reinvestment rate either.
> The conversion from a published dividend rate to a multiplier delta is undocumented and, on this evidence, not derivable from the two published numbers.
> Read the multiplier from the token; do not compute it from the rate.
> Caveat: this is arithmetic on two published numbers only, and the actual share prices on the relevant dates were not checked.
> The SGOV row is the weakest of the six, because SGOV distributes monthly and its 2026-09-01 multiplier change does not map cleanly to a single action in the feed's window.

### Multiplier Conversion

Each token represents a number of underlying shares equal to its raw token amount scaled by the multiplier:

```
underlying shares = raw token amount × uiMultiplier ÷ 1e18
```

* `uiMultiplier()` is fixed-point with 18 decimals — 1e18 = 1.0.
* At launch the multiplier is 1e18 (one token = one underlying share).
* When a corporate action is applied (e.g. a reinvested dividend or a stock split), the multiplier is updated and `UIMultiplierUpdated` is emitted with the effective timestamp.

### Multiplier Updates

When a corporate action schedules a multiplier change ahead of time, the pending value and its effective time are readable on-chain:

```
interface IScaledUIAmountNewUIMultiplier {
// The pending UI multiplier scheduled to take effect at effectiveAt.
function newUIMultiplier() external view returns (uint256);
// The timestamp at which the pending multiplier becomes effective.
function effectiveAt() external view returns (uint256);
}
```

* **`newUIMultiplier()`** — the multiplier that will take effect at `effectiveAt()`. Before any update is scheduled this tracks the current multiplier.
* **`effectiveAt()`** — the timestamp at which `newUIMultiplier()` becomes the active `uiMultiplier()`.

> **Archive note, not source text (2026-09-03): the scheduled-change path exists in the interface but is effectively never populated, so do not build a dividend notification on it.**
> The section above implies that a corporate action is normally scheduled ahead of time and observable on-chain before it lands.
> Live evidence says otherwise.
> On 2026-09-03 the issuer's feed `https://api.robinhood.com/rhj/corporate-actions` carried 44 cash-dividend actions, 32 of them `CORPORATE_ACTION_STATUS_IN_PROGRESS`, including actions with a process date of the same day.
> For **all 32**, the corresponding asset on `https://api.robinhood.com/rhj/assets` reported `pendingMultiplier: ""`.
> `31-onchain-verification.md` records the same result on-chain: `newUIMultiplier()` equals `uiMultiplier()` on every token, and `effectiveAt()` holds the timestamp of the **last applied** change rather than a future one.
> In practice the multiplier simply changes when the action is applied.
> That makes `/rhj/corporate-actions` the only forward-looking notice of a pending corporate action; the chain is not one.
> A non-zero `effectiveAt()` is not evidence that an update is pending.

### UI-Adjust Views

Rather than mutating raw balances, the token exposes UI-adjusted (underlying-share) views of balance and supply:

```
interface IScaledUIAmountBalances {
// UI-adjusted balance of an account (raw balance scaled by uiMultiplier).
function balanceOfUI(address account) external view returns (uint256);
// UI-adjusted total supply.
function totalSupplyUI() external view returns (uint256);
}
```

* **`balanceOfUI(account)`** — the account's balance expressed in underlying shares. Use this to display how many underlying shares a holder's tokens represent. To convert any raw amount yourself, apply the formula in Multiplier Conversion above.
* **`totalSupplyUI()`** — total supply expressed in underlying shares.

### ERC-8056 events

The multiplier and its movements are exposed by the core ERC-8056 interface:

```
interface IScaledUIAmount {
// Current UI multiplier, expressed with 18 decimals (1e18 = 1.0).
function uiMultiplier() external view returns (uint256);
// Emitted when the multiplier changes (e.g. a dividend or split).
event UIMultiplierUpdated(
uint256 oldMultiplier,
uint256 newMultiplier,
uint256 effectiveAtTimestamp
);
// Emitted on a transfer, carrying both the raw value and the UI-adjusted
// (underlying-share) value.
event TransferWithScaledUI(
address indexed from,
address indexed to,
uint256 value,
uint256 uiValue
);
}
```

* Subscribe to `UIMultiplierUpdated` to track corporate-action adjustments and the timestamp each became effective.
* Use `TransferWithScaledUI` to record the underlying-share value (`uiValue`) of each transfer alongside the raw value.

## Getting started

1. Pick a stock token — grab its address from [Token Contracts](/chain/contracts).
2. Read a balance — call `balanceOf` like any ERC-20.
3. Read its price — call `latestRoundData()` on the token's Chainlink feed.
4. Build — display it, swap it, use it as collateral, or compose it into your product.

### Example: value a user's holdings in USD

```
// Returns the USD value of a user's stock token balance.
function holdingValueUsd(
IERC20 stockToken,
AggregatorV3Interface priceFeed,
address user
) external view returns (uint256) {
uint256 balance = stockToken.balanceOf(user); // 18 decimals
(, int256 price, , uint256 updatedAt, ) = priceFeed.latestRoundData();
require(price > 0 && updatedAt > 0, "Invalid price"); // price: 8 decimals
// (balance * price) scaled by token + feed decimals
return (balance * uint256(price)) / 1e8;
}
```

## Next steps

* [Token Contracts](/chain/contracts) — all stock token & ETF addresses
* [Oracles & Price Feeds](/chain/oracles-and-price-feeds) — price feed integration
* [Deploy a Contract](/chain/deploy-smart-contracts) — ship your contracts to Robinhood Chain

## Disclaimer

This page features third-party developers and protocols building on Robinhood Chain. Inclusion on this page does not constitute an endorsement, partnership, or warranty by Robinhood. Robinhood makes no representations regarding the safety, legitimacy, or suitability of any featured protocol or application and is not responsible for the content of any third-party websites, apps, or protocols, or any financial risks arising from interacting with them.
