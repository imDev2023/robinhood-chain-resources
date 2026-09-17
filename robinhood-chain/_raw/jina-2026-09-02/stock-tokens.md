Title: Stock Tokens

URL Source: https://docs.robinhood.com/chain/stock-tokens

Markdown Content:
[Skip to content](https://docs.robinhood.com/chain/stock-tokens#vocs-content)

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

Overview

On this page

[Ask in ChatGPT](https://chatgpt.com/?hints=search&q=Please%20research%20and%20analyze%20this%20page%3A%20https%3A%2F%2Fdocs.robinhood.com%2Fchain%2Fstock-tokens%20so%20I%20can%20ask%20you%20questions%20about%20it.%20Once%20you%20have%20read%20it%2C%20prompt%20me%20with%20any%20questions%20I%20have.%20Do%20not%20post%20content%20from%20the%20page%20in%20your%20response.%20Any%20of%20my%20follow%20up%20questions%20must%20reference%20the%20site%20I%20gave%20you.)

## On this page

*   [Why build with stock tokens](https://docs.robinhood.com/chain/stock-tokens#why-build-with-stock-tokens)
*   [What you can build](https://docs.robinhood.com/chain/stock-tokens#what-you-can-build)
*   [How Stock Tokens work](https://docs.robinhood.com/chain/stock-tokens#how-stock-tokens-work)
*   [Corporate actions & the multiplier](https://docs.robinhood.com/chain/stock-tokens#corporate-actions--the-multiplier)
*   [Get started](https://docs.robinhood.com/chain/stock-tokens#get-started)
*   [Disclaimer](https://docs.robinhood.com/chain/stock-tokens#disclaimer)

# Stock Tokens[](https://docs.robinhood.com/chain/stock-tokens#stock-tokens)

Robinhood Chain is built for tokenized real-world assets — and Robinhood Stock Tokens are our flagship real-world asset. Stock Tokens are tokenised debt securities issued by Robinhood Assets (Jersey) Limited ("RHJ"). The Product provides economic exposure to underlying securities like US shares and ETFs, but does not grant investors any legal or beneficial rights in, or against the issuer of, those underlying securities. Stock Tokens are issued as standard ERC-20 tokens that can be held, transferred, and composed into applications onchain.

For developers, this means programmable access to real-world assets using the same tools you already use for any ERC-20 — no special SDK required to get started.

## Why build with stock tokens[](https://docs.robinhood.com/chain/stock-tokens#why-build-with-stock-tokens)

*   **Programmable real-world assets**
*   **Standard ERC-20 interface** — works out of the box with existing wallets, libraries, and tooling.
*   **Onchain prices** — every Stock Token has a live Chainlink price feed, so your contracts can read prices directly onchain.
*   **Composable** — build trading, lending, structured products, and more on top of real-world asset exposure.
*   **Self-custodied and 24/7** — assets live in users' wallets and are accessible around the clock.

## What you can build[](https://docs.robinhood.com/chain/stock-tokens#what-you-can-build)

A few examples of what developers can build with Stock Tokens:

*   List and display Robinhood Stock Tokens in a wallet, portfolio tracker, or trading interface.
*   Enable trading.
*   Build lending markets that use stock tokens as collateral.

See [Building with Stock Tokens](https://docs.robinhood.com/chain/building-with-stock-tokens) for use cases, integration patterns, and code.

## How Stock Tokens work[](https://docs.robinhood.com/chain/stock-tokens#how-stock-tokens-work)

*   Each Stock Token is a standard ERC-20 contract with 18 decimals.
*   Each token corresponds to a specific underlying equity or ETF, identified by its ticker symbol.
*   Prices are published onchain via per-asset Chainlink data feeds.

## Corporate actions & the multiplier[](https://docs.robinhood.com/chain/stock-tokens#corporate-actions--the-multiplier)

The platform manages dividends and stock splits through an onchain multiplier, which adjusts the shares-per-token ratio while keeping your raw balance static until redemption. You can access this value via the token's `uiMultiplier()` function, defined by [ERC-8056](https://eips.ethereum.org/EIPS/eip-8056) (Scaled UI Amount Extension). Onchain swaps remain unaffected, and the oracle automatically incorporates the multiplier into the price (see [Oracles & Price Feeds](https://docs.robinhood.com/chain/oracles-and-price-feeds)).

## Get started[](https://docs.robinhood.com/chain/stock-tokens#get-started)

| Goal | Where to go |
| --- | --- |
| Build with Stock Tokens | [Building with Stock Tokens](https://docs.robinhood.com/chain/building-with-stock-tokens) |
| Find contract addresses | [Token Contracts](https://docs.robinhood.com/chain/contracts) |
| Read onchain prices | [Oracles & Price Feeds](https://docs.robinhood.com/chain/oracles-and-price-feeds) |

## Disclaimer[](https://docs.robinhood.com/chain/stock-tokens#disclaimer)

Stock Tokens are ERC-20s issued by RHJ. RHJ also acts as the tokenizer. Only Authorised Participants (at issuance, the only Authorised Participant is BBVI) may subscribe for Stock Tokens directly from RHJ after KYB onboarding (the primary market), so developers build by composing with existing tokens rather than minting. For how holders acquire and redeem tokens.

Stock Tokens are tokenised debt securities issued by Robinhood Assets (Jersey) Limited. They provide economic exposure to underlying securities but do not grant investors any legal or beneficial rights in, or against the issuer of, those underlying securities. Stock Tokens carry a high level of risk and are not appropriate for all investors. Investors should be prepared for the possibility of losing some or all of their investment. Eligible investors should carefully review the Base Prospectus (together with any supplements) and the applicable Final Terms, available here: [http://docs.robinhood.com/rhj](http://docs.robinhood.com/rhj)

Stock Tokens are not registered under U.S. securities laws and may not be offered, sold, or delivered, directly or indirectly, in the United States or to, or for the account or benefit of, U.S. persons. Offers and sales of Stock Tokens are subject to restrictions in other jurisdictions, including, without limitation, Canada, the United Kingdom, and Switzerland. A full list of the jurisdictions in which offers or sales are restricted or prohibited is available here: [http://docs.robinhood.com/rhj](http://docs.robinhood.com/rhj)

Robinhood Assets (Jersey) Limited is a private limited company incorporated in Jersey, with its registered address at First Floor, La Chasse Chambers, Ten La Chasse, St. Helier, JE2 4UE, Jersey. The Issuer is registered under the registration number 162428.

Stock Tokens have not been and will not be registered under the U.S. Securities Act of 1933, as amended from time to time (the "Securities Act") or with any securities regulatory authority of any state or other jurisdiction of the United States. Stock Tokens may not be offered, sold or delivered within the United States to, or for the account or benefit of U.S. Persons (as defined in Regulation S under the Securities Act ("Regulation S")), and (ii) may be offered, sold or otherwise delivered at any time only outside of the United States and to transferees that are not U.S. Persons (as defined in Regulation S).

This website is directed only at persons who are resident or incorporated outside of the United Kingdom, and is therefore exempt from the general restriction in Section 21 of the Financial Services and Markets Act 2000 on the communication of invitations or inducements to engage in investment activity on the grounds that it is being issued to and/or directed at non-UK persons, and that the products and services described are not available to UK persons. It should not therefore be acted upon by any person who is resident in, or incorporated in, the United Kingdom.

Nothing on this website constitutes, and may not be used in connection with, an offer or solicitation in any place where offers or solicitations are not permitted by law. Nothing on this website constitutes investment, legal, tax or financial advice. Prospective investors should make their own assessment as to the suitability of investing in the Products.

Robinhood Markets, Inc., 85 Willow Road, Menlo Park, CA 94025. ©2026 Robinhood Markets, Inc. All rights reserved.

[Bridging Previous shift←](https://docs.robinhood.com/chain/bridging)[Building with Stock Tokens Next shift→](https://docs.robinhood.com/chain/building-with-stock-tokens)

Your Privacy Choices![Image 7](https://cdn.robinhood.com/assets/generated_assets/hoodchain_docsite/privacy-options.svg)
