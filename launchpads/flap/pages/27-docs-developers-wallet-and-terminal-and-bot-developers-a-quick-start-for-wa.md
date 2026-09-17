# Flap - A Quick Start For Wallet & Terminal & Bot Developers

> Source: https://docs.flap.sh/flap/developers/wallet-and-terminal-and-bot-developers/a-quick-start-for-wallet-terminal-bot-developers
> Retrieved: 2026-09-02 (GitBook markdown export, https://docs.flap.sh/flap/developers/wallet-and-terminal-and-bot-developers/a-quick-start-for-wallet-terminal-bot-developers.md)

---

> For the complete documentation index, see [llms.txt](https://docs.flap.sh/flap/llms.txt). Markdown versions of documentation pages are available by appending `.md` to page URLs; this page is available as [Markdown](https://docs.flap.sh/flap/developers/wallet-and-terminal-and-bot-developers/a-quick-start-for-wallet-terminal-bot-developers.md).

# A Quick Start For Wallet & Terminal & Bot Developers

This page outlines the minimal steps to integrate with Flap for wallets, terminals and bots. Each step links to the detailed documentation.

1. **Find the `Portal` entrypoint.** Our main protocol has a single entrypoint contract called `Portal`. Use the deployed addresses listed in [Deployed Contract Addresses](/flap/developers/wallet-and-terminal-and-bot-developers/deployed-contract-addresses.md).
2. **Index tokens (recommended).** To index tokens launched on Flap, listen to `TokenCreated` and related events emitted by `Portal`. See [Index Token Created Events](/flap/developers/wallet-and-terminal-and-bot-developers/index-token-created-events.md) for the full event list and indexing strategy. The `TokenCreated` event only contains the IPFS CID of the metadata. To parse token metadata, follow [Parse Token Meta](/flap/developers/wallet-and-terminal-and-bot-developers/parse-token-meta.md).
3. **Skip indexing and query on demand (alternative).** If you do not want to index, you can query token info directly from `Portal` with the `getTokenV*` methods. See [Inspect A Token](/flap/developers/wallet-and-terminal-and-bot-developers/inspect-a-token.md) for details.
4. **Tax tokens: query dynamic info on-chain.** Tax tokens have dynamic fields (e.g., accumulated stats) that are best retrieved on-chain. Use the Tax Token Helper as described in [Inspect A Tax Token](/flap/developers/wallet-and-terminal-and-bot-developers/inspect-a-tax-token.md). For vault-specific data, see [how to inspect a tax token's vault](/flap/developers/wallet-and-terminal-and-bot-developers/inspect-a-tax-token.md#how-to-inspect-a-tax-tokens-vault).
5. **Trade tokens.** You can quote on-chain using `quoteExactInput`, or compute quotes off-chain and submit swaps using `swapExactInput`. See [Trade Tokens](/flap/developers/wallet-and-terminal-and-bot-developers/trade-tokens.md) for details.
