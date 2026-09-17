Title: Data APIs Overview

URL Source: https://www.alchemy.com/docs/reference/data-overview

Markdown Content:
The Data APIs give you fast, reliable access to blockchain data without running your own indexing infrastructure. Whether you're building wallets, NFT platforms, analytics dashboards, or DeFi apps, the Data APIs save you time and engineering costs by offering pre-transformed, production-ready data.

* * *

Use the Data APIs if:

*   You need pre-indexed blockchain data without running your own nodes or infrastructure.
*   You want to read user portfolios, token balances, transfer history, or NFT data.
*   You're sending transactions and **not** using Alchemy's Smart Wallets.
    *   If you are using our wallets, check out the Wallet APIs, which supports:
        *   `sendUserOp`
        *   `estimateUserOpGas`
        *   and more account abstraction features

*   You want to simulate or estimate transaction outcomes before sending them.
*   You need to track wallet or contract activity with push notifications via webhooks.

* * *

Perfect for advanced dev environments, simulation dashboards, and infra teams.

*   Use endpoints like:
    *   `debug_traceTransaction`
    *   `debug_getRawTrace`

Ideal for apps that generate transactions on behalf of your users.

**Common use cases:**

*   ERC-20 swaps
*   NFT purchases and listings
*   Wallets that send tokens or interact with contracts
*   Portfolio apps that need to simulate or batch transactions

**Common use cases:**

*   Wallets and portfolio trackers

*   Token/NFT ownership queries

*   Historical transfers and analytics dashboards

*   Price feeds and onchain trends

*   Pre-indexed data to power all your frontend and backend logic

*   Use endpoints like:

    *   `getNftsForOwner` - Retrieves all NFTs currently owned by a specified address.
    *   `alchemy_getTokenBalances` - Returns ERC-20 token balances for a given address.
    *   `alchemy_getAssetTransfers` - Fetches historical transactions for any address across Ethereum and supported L2s including Polygon, Arbitrum, and Optimism.

* * *

The Data APIs do the heavy lifting so you can focus on your product.

We're not just a data provider -- we're the infra layer behind the biggest names in web3. Alchemy is set apart by:

*   **Battle-tested scale**: powering millions of wallets, swaps, and NFT marketplaces — from Fortune 500s to weekend and hackathon builders.
*   **Multi-chain support**: Ethereum, Base, Polygon, Arbitrum, Optimism, and dozens of other chains supported out of the box.

* * *
