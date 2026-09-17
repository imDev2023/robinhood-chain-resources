Title: Building with Stock Tokens

URL Source: https://docs.robinhood.com/chain/building-with-stock-tokens

Markdown Content:
[Skip to content](https://docs.robinhood.com/chain/building-with-stock-tokens#vocs-content)

[![Image 1: Logo](https://cdn.robinhood.com/assets/generated_assets/hoodchain_docsite/feather-light.svg)![Image 2: Logo](https://cdn.robinhood.com/assets/generated_assets/hoodchain_docsite/feather-dark.svg)](https://docs.robinhood.com/chain)

Get Started

[About Robinhood Chain](https://docs.robinhood.com/chain)[Connecting to Robinhood Chain](https://docs.robinhood.com/chain/connecting)[Add network to your wallet](https://docs.robinhood.com/chain/add-network-to-wallet)[Bridging](https://docs.robinhood.com/chain/bridging)

Stock Tokens

[Overview](https://docs.robinhood.com/chain/stock-tokens)[Building with Stock Tokens](https://docs.robinhood.com/chain/building-with-stock-tokens)[Stock Token APIs](https://docs.robinhood.com/chain/stock-token-apis)

Core Concepts

[Differences from Ethereum](https://docs.robinhood.com/chain/differences-from-ethereum)[Gas & Fees](https://docs.robinhood.com/chain/gas-and-fees)[Transaction Finality](https://docs.robinhood.com/chain/transaction-finality)

[Token Contracts](https://docs.robinhood.com/chain/contracts)[Protocol Contracts](https://docs.robinhood.com/chain/protocol-contracts)

Build

[Deploy a Contract](https://docs.robinhood.com/chain/deploy-smart-contracts)[Account Abstraction](https://docs.robinhood.com/chain/account-abstraction)[Cross-Chain Messaging](https://docs.robinhood.com/chain/cross-chain-messaging)[Oracles & Price Feeds](https://docs.robinhood.com/chain/oracles-and-price-feeds)[Data Streams](https://docs.robinhood.com/chain/data-streams)

[Run a full node](https://docs.robinhood.com/chain/run-a-full-node)[Governance](https://docs.robinhood.com/chain/governance)

Brand Guidelines

[Overview](https://docs.robinhood.com/chain/brand-guidelines)

Notices & Upgrades

[Overview](https://docs.robinhood.com/chain/notices-and-upgrades)

[Report an issue](https://docs.robinhood.com/chain/report-issue)[Terms of Service](https://docs.robinhood.com/chain/terms-of-service)

Search...

[![Image 3: Logo](https://cdn.robinhood.com/assets/generated_assets/hoodchain_docsite/feather-light.svg)![Image 4: Logo](https://cdn.robinhood.com/assets/generated_assets/hoodchain_docsite/feather-dark.svg)](https://docs.robinhood.com/chain)

[![Image 5: Logo](https://cdn.robinhood.com/assets/generated_assets/hoodchain_docsite/feather-light.svg)![Image 6: Logo](https://cdn.robinhood.com/assets/generated_assets/hoodchain_docsite/feather-dark.svg)](https://docs.robinhood.com/chain)

Menu

Building with Stock Tokens

On this page

[Ask in ChatGPT](https://chatgpt.com/?hints=search&q=Please%20research%20and%20analyze%20this%20page%3A%20https%3A%2F%2Fdocs.robinhood.com%2Fchain%2Fbuilding-with-stock-tokens%20so%20I%20can%20ask%20you%20questions%20about%20it.%20Once%20you%20have%20read%20it%2C%20prompt%20me%20with%20any%20questions%20I%20have.%20Do%20not%20post%20content%20from%20the%20page%20in%20your%20response.%20Any%20of%20my%20follow%20up%20questions%20must%20reference%20the%20site%20I%20gave%20you.)

## On this page

*   [Use cases](https://docs.robinhood.com/chain/building-with-stock-tokens#use-cases)
*   [Trading Venues & Liquidity](https://docs.robinhood.com/chain/building-with-stock-tokens#trading-venues--liquidity)

    *   [Overview](https://docs.robinhood.com/chain/building-with-stock-tokens#overview)
    *   [Liquidity Sources](https://docs.robinhood.com/chain/building-with-stock-tokens#liquidity-sources)

*   [Integrations, contracts & APIs](https://docs.robinhood.com/chain/building-with-stock-tokens#integrations-contracts--apis)

    *   [Contracts](https://docs.robinhood.com/chain/building-with-stock-tokens#contracts)
    *   [Prices](https://docs.robinhood.com/chain/building-with-stock-tokens#prices)
    *   [Multiplier Conversion](https://docs.robinhood.com/chain/building-with-stock-tokens#multiplier-conversion)
    *   [Multiplier Updates](https://docs.robinhood.com/chain/building-with-stock-tokens#multiplier-updates)
    *   [UI-Adjust Views](https://docs.robinhood.com/chain/building-with-stock-tokens#ui-adjust-views)
    *   [ERC-8056 events](https://docs.robinhood.com/chain/building-with-stock-tokens#erc-8056-events)

*   [Getting started](https://docs.robinhood.com/chain/building-with-stock-tokens#getting-started)

    *   [Example: value a user's holdings in USD](https://docs.robinhood.com/chain/building-with-stock-tokens#example-value-a-users-holdings-in-usd)

*   [Next steps](https://docs.robinhood.com/chain/building-with-stock-tokens#next-steps)
*   [Disclaimer](https://docs.robinhood.com/chain/building-with-stock-tokens#disclaimer)

# Building with Stock Tokens[](https://docs.robinhood.com/chain/building-with-stock-tokens#building-with-stock-tokens)

Stock tokens are standard ERC-20 tokens, so building with them uses the same patterns you already know — plus onchain price feeds for real-world asset data. This guide covers what you can build, how to integrate, and how to get started.

## Use cases[](https://docs.robinhood.com/chain/building-with-stock-tokens#use-cases)

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

_Tokenized stocks trade via RFQ at launch. They remain standard ERC-20s and can be transferred and held in any wallet._

## Trading Venues & Liquidity[](https://docs.robinhood.com/chain/building-with-stock-tokens#trading-venues--liquidity)

### Overview[](https://docs.robinhood.com/chain/building-with-stock-tokens#overview)

Stock Tokens are standard ERC-20 assets and can be held or transferred in any compatible wallet. For trading, several venues are available.

### Liquidity Sources[](https://docs.robinhood.com/chain/building-with-stock-tokens#liquidity-sources)

#### RFQ[](https://docs.robinhood.com/chain/building-with-stock-tokens#rfq)

RFQ uses signed market-maker quotes sourced through aggregators such as 0x RFQ, 1inch Fusion, and LiFi. Wallets and exchanges can leverage RFQ as a source of liquidity by integrating these aggregators.

#### AMM[](https://docs.robinhood.com/chain/building-with-stock-tokens#amm)

Stock Tokens can also be traded through standard automated market maker (AMM) pools such as Uniswap. AMM pools provide composable, on-chain liquidity that DeFi applications can integrate directly into smart-contract flows.

#### Proprietary AMM (propAMM)[](https://docs.robinhood.com/chain/building-with-stock-tokens#proprietary-amm-propamm)

Where on-chain AMM liquidity is limited, Stock Tokens can also be traded through proprietary AMM (propAMM) like Rialto, which provides market-maker-backed liquidity. Because it's onchain, a propAMM offers composable liquidity that DeFi applications can integrate directly into smart-contract flows — unlike RFQ, which relies on off-chain signed quotes.

#### Direct mint & burn[](https://docs.robinhood.com/chain/building-with-stock-tokens#direct-mint--burn)

Stock Tokens are minted and burned directly with the issuer, Robinhood Assets (Jersey) Limited in the primary market. This is the ultimate source of Stock Token supply and underpins secondary-market liquidity. Direct mint/burn is available only to Authorized Participants / market makers and requires KYB onboarding; regular holders acquire and exit positions on the secondary market through the venues above.

#### Orderbook[](https://docs.robinhood.com/chain/building-with-stock-tokens#orderbook)

Stock Tokens also trade on Lighter (spot & perps). Refer to the Lighter Domain for specific integration details.

## Integrations, contracts & APIs[](https://docs.robinhood.com/chain/building-with-stock-tokens#integrations-contracts--apis)

### Contracts[](https://docs.robinhood.com/chain/building-with-stock-tokens#contracts)

Stock tokens are ERC-20 (18 decimals). All standard token operations work without modification:

```
IERC20 nvda = IERC20(NVDA_TOKEN_ADDRESS);
uint256 balance = nvda.balanceOf(user);
nvda.transfer(recipient, amount);
nvda.approve(spender, amount);
```

Stock tokens also implement ERC-8056 (Scaled UI Amount Extension), which defines the corporate-action multiplier (`uiMultiplier()`). The multiplier scales the effective amount without changing raw balances or total supply — `balanceOf()` and `totalSupply()` stay fixed. Stock tokens are not rebasing tokens. See the ERC-8056 spec.

Find all stock tokens and ETF addresses on the [Token Contracts](https://docs.robinhood.com/chain/contracts) page.

### Prices[](https://docs.robinhood.com/chain/building-with-stock-tokens#prices)

Every stock token has a per-asset Chainlink price feed implementing the standard `AggregatorV3Interface` (`latestRoundData()`, read via the feed proxy — same interface as crypto feeds):

```
AggregatorV3Interface feed = AggregatorV3Interface(NVDA_PRICE_FEED);
(, int256 price, , uint256 updatedAt, ) = feed.latestRoundData();
require(price > 0 && updatedAt > 0, "Invalid price");
```

The Chainlink price already includes the corporate-action multiplier (dividends, splits), so the value you read is the token's full price — don't apply the multiplier yourself. If you need the raw ratio, read it onchain via the token's `uiMultiplier()`.

See [Oracles & Price Feeds](https://docs.robinhood.com/chain/oracles-and-price-feeds) for feed addresses, decimals, and best practices (staleness checks, sequencer uptime).

### Multiplier Conversion[](https://docs.robinhood.com/chain/building-with-stock-tokens#multiplier-conversion)

Each token represents a number of underlying shares equal to its raw token amount scaled by the multiplier:

`underlying shares = raw token amount × uiMultiplier ÷ 1e18`

*   `uiMultiplier()` is fixed-point with 18 decimals — 1e18 = 1.0.
*   At launch the multiplier is 1e18 (one token = one underlying share).
*   When a corporate action is applied (e.g. a reinvested dividend or a stock split), the multiplier is updated and `UIMultiplierUpdated` is emitted with the effective timestamp.

### Multiplier Updates[](https://docs.robinhood.com/chain/building-with-stock-tokens#multiplier-updates)

When a corporate action schedules a multiplier change ahead of time, the pending value and its effective time are readable on-chain:

```
interface IScaledUIAmountNewUIMultiplier {
  // The pending UI multiplier scheduled to take effect at effectiveAt.
  function newUIMultiplier() external view returns (uint256);
 
  // The timestamp at which the pending multiplier becomes effective.
  function effectiveAt() external view returns (uint256);
}
```

*   **`newUIMultiplier()`** — the multiplier that will take effect at `effectiveAt()`. Before any update is scheduled this tracks the current multiplier.
*   **`effectiveAt()`** — the timestamp at which `newUIMultiplier()` becomes the active `uiMultiplier()`.

### UI-Adjust Views[](https://docs.robinhood.com/chain/building-with-stock-tokens#ui-adjust-views)

Rather than mutating raw balances, the token exposes UI-adjusted (underlying-share) views of balance and supply:

```
interface IScaledUIAmountBalances {
  // UI-adjusted balance of an account (raw balance scaled by uiMultiplier).
  function balanceOfUI(address account) external view returns (uint256);
 
  // UI-adjusted total supply.
  function totalSupplyUI() external view returns (uint256);
}
```

*   **`balanceOfUI(account)`** — the account's balance expressed in underlying shares. Use this to display how many underlying shares a holder's tokens represent. To convert any raw amount yourself, apply the formula in Multiplier Conversion above.
*   **`totalSupplyUI()`** — total supply expressed in underlying shares.

### ERC-8056 events[](https://docs.robinhood.com/chain/building-with-stock-tokens#erc-8056-events)

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

*   Subscribe to `UIMultiplierUpdated` to track corporate-action adjustments and the timestamp each became effective.
*   Use `TransferWithScaledUI` to record the underlying-share value (`uiValue`) of each transfer alongside the raw value.

## Getting started[](https://docs.robinhood.com/chain/building-with-stock-tokens#getting-started)

1.   Pick a stock token — grab its address from [Token Contracts](https://docs.robinhood.com/chain/contracts).
2.   Read a balance — call `balanceOf` like any ERC-20.
3.   Read its price — call `latestRoundData()` on the token's Chainlink feed.
4.   Build — display it, swap it, use it as collateral, or compose it into your product.

### Example: value a user's holdings in USD[](https://docs.robinhood.com/chain/building-with-stock-tokens#example-value-a-users-holdings-in-usd)

```
// Returns the USD value of a user's stock token balance.
function holdingValueUsd(
   IERC20 stockToken,
   AggregatorV3Interface priceFeed,
   address user
) external view returns (uint256) {
   uint256 balance = stockToken.balanceOf(user);          // 18 decimals
   (, int256 price, , uint256 updatedAt, ) = priceFeed.latestRoundData();
   require(price > 0 && updatedAt > 0, "Invalid price");   // price: 8 decimals
   // (balance * price) scaled by token + feed decimals
   return (balance * uint256(price)) / 1e8;
}
```

## Next steps[](https://docs.robinhood.com/chain/building-with-stock-tokens#next-steps)

*   [Token Contracts](https://docs.robinhood.com/chain/contracts) — all stock token & ETF addresses
*   [Oracles & Price Feeds](https://docs.robinhood.com/chain/oracles-and-price-feeds) — price feed integration
*   [Deploy a Contract](https://docs.robinhood.com/chain/deploy-smart-contracts) — ship your contracts to Robinhood Chain

## Disclaimer[](https://docs.robinhood.com/chain/building-with-stock-tokens#disclaimer)

This page features third-party developers and protocols building on Robinhood Chain. Inclusion on this page does not constitute an endorsement, partnership, or warranty by Robinhood. Robinhood makes no representations regarding the safety, legitimacy, or suitability of any featured protocol or application and is not responsible for the content of any third-party websites, apps, or protocols, or any financial risks arising from interacting with them.

[Overview Previous shift←](https://docs.robinhood.com/chain/stock-tokens)[Stock Token APIs Next shift→](https://docs.robinhood.com/chain/stock-token-apis)

Your Privacy Choices![Image 7](https://cdn.robinhood.com/assets/generated_assets/hoodchain_docsite/privacy-options.svg)
