# Resources

Standing reference material for Robinhood Chain work.
Intended to be reused across projects, not specific to any one build.

## Start here

**[`ROBINHOOD-CHAIN.md`](ROBINHOOD-CHAIN.md)** is the master reference.
It synthesizes every official doc page plus live on-chain verification into one document: network config, ERC-8056 mechanics, contract addresses, price feeds, trust assumptions, and an integration checklist.

For launchpads specifically, start at **[`LAUNCHPADS.md`](LAUNCHPADS.md)**, the cross-platform comparison, then **[`LAUNCHPADS-II.md`](LAUNCHPADS-II.md)** for the second wave.
Go to a platform's own `launchpads/<slug>/README.md` for the detail behind any cell, to `launchpads/PLAYBOOK.md` for how the archives were built, and to `scripts/README.md` for the tooling that builds them.

**Twenty-two platforms are archived.**
`LAUNCHPADS.md` covers the first eleven and ranks them for a creator choosing where to launch.
`LAUNCHPADS-II.md` covers the second eleven, ranks all twenty-two on custody and upgradeability rather than on creator payout, and corrects three entries in the first document.

## Layout

| Path | What it is |
| --- | --- |
| `ROBINHOOD-CHAIN.md` | Master synthesized reference. Read this first. |
| `robinhood-chain/` | Verbatim archive, one markdown file per source URL. Source of truth when the master doc summarizes something. |
| `robinhood-chain/31-onchain-verification.md` | What was read directly from mainnet, and where the docs and reality diverge. Re-verified 2026-09-03 at block 53,117,114. |
| `robinhood-chain/32-explorer-and-data-apis.md` | Original writing. Which explorer and data APIs actually answer questions about chain 4663: Blockscout v2 and the browser User-Agent requirement, the Blockscout PRO API at `api.blockscout.com/4663`, contract verification routes, Dexscreener chain id `robinhood`, Goldsky subgraph and Mirror support, Alchemy Data API coverage and refusals, and the Uniswap Developer API. Verified 2026-09-03. |
| `robinhood-chain/44-uniswap-v4-hooks.md` | Original writing. What changes when you put a Uniswap v4 **hook** on this chain: v4 addresses verified live, the CREATE2 deployer, EIP-1153 availability, and the `block.number` divergence (about 120 L2 blocks per tick) that silently changes two of OpenZeppelin's ready-made hooks. Verified 2026-09-19. |
| `robinhood-chain/45-v4-pools-and-liquidity.md` | Generated. Live pool census: 123 v4 pools against 49 v3, total liquidity and 24h volume, top pools by liquidity, quote-asset mix, and the 18 stock-token multipliers that moved since 2026-09-03. Captured 2026-09-19. |
| `robinhood-chain/46-uimultiplier-is-display-only.md` | Original writing. ERC-8056 `uiMultiplier()` is display-only: it never moves `balanceOf`. Corrects file 45. Also documents what stock tokens *do* carry - a central transfer blocklist, `adminBurn` from any holder, and one shared upgrade beacon behind all 194 tokens. Measured 2026-09-19. |
| `robinhood-chain/47-backrunning-measured.md` | Original writing. How much reactive MEV actually happens here: a backrun-shaped reaction on about 0.41% of large trades, one block after the victim, concentrated in 7.6% of testable pools. Sandwiching is unreachable; backrunning is not, but it is small and no v4 hook can reach it. Measured 2026-09-19 over 2.96M swaps. |
| `robinhood-chain/48-hook-census.md` | Original writing from two outside sources. How much of the chain trades through a hook and where the data lives: Uniswap's public `hooklist` registers 1,161 verified hooks here, more than any other chain, 66% of them able to replace the swap; Bitquery's census found 74.5% of v4 trades run through a hook and the largest hook takes 1% on pools that display a 0% fee. Also the nine fake-USDG tickers trap. Read 2026-09-19. |
| `robinhood-chain/16-token-contracts.md` | All Stock Token addresses, ISINs, UIDs, multipliers, matched feeds. 194 tokens as of 2026-09-03. |
| `robinhood-chain/11-chainlink-feed-addresses.md` | All Chainlink feeds on the chain, verified live. 57 as of 2026-09-03. |
| `robinhood-chain/CHANGELOG-2026-09-02.md` | Hand-written log of what changed in the official docs between captures, with old and new values. |
| `robinhood-chain/_raw/` | Untouched captures: Tavily and Jina extractions, REST responses, on-chain dumps, API probe results. One dated subdirectory per pass. |
| `robinhood-chain-links.md` | The original link list this archive was built from. |
| `uniswap/` | Complete Uniswap developer docs (311 pages, native markdown), all-chain `DEPLOYMENTS.md`, and the Trading API OpenAPI spec rendered per endpoint. Start at `uniswap/INDEX.md`. |
| `blockscout/` | Complete Blockscout docs (402 pages, native markdown, captured 2026-09-10) with a Robinhood-specific start-here list. Begin at `blockscout/README.md`, then `blockscout/INDEX.md`. |
| `launchpads/` | One directory per token launchpad on this chain, each with a `README.md`, `LINKS.md`, `contracts/ADDRESSES.md` and raw captures. `launchpads/PLAYBOOK.md` is the method; `launchpads/_market/` holds chain-wide market context and a catalog of about 45 launchpads found. |
| `LAUNCHPADS.md` | **Read this to choose a launchpad.** The first eleven archived platforms compared on launch cost, fee split, creator income, liquidity lock, quote assets, verification and privileged keys, every cell cited to a platform README section. Includes a ranked shortlist, the assumptions behind it, and the platforms found but not archived. |
| `LAUNCHPADS-II.md` | **Read this to choose a design to build on.** The second eleven, archived 2026-09-19, plus a custody and upgradeability ranking across all twenty-two. Shallower than wave one by design: verified contracts and mechanism only, no docs captures or screenshots, with an explicit gap list per archive. |
| `scripts/` | Tooling that builds the archives: `bsfetch.py` (Blockscout through a browser, since Cloudflare now challenges the API), `mkarchive.py` (contract directories), `push4scan.py` (function surface of unverified contracts). See `scripts/README.md`. |

## Provenance

Documentation captured 2026-08-12 via the Tavily CLI (`tvly extract`, advanced depth) across 26 official pages and 3 linked sub-pages, refreshed 2026-09-02 and 2026-09-03.
On-chain state was first captured 2026-08-12 at block 34,251,364, re-verified 2026-09-03 at block 53,117,114, and re-verified again 2026-09-19 at block 66,716,100, through an Alchemy archive RPC plus Multicall3, read-only.
No transaction was ever sent and no private key was ever used.

The archived pages preserve source wording exactly.
`ROBINHOOD-CHAIN.md`, `robinhood-chain/32-explorer-and-data-apis.md`, `robinhood-chain/CHANGELOG-2026-09-02.md` and the three generated files listed above are original writing and generated tables.

## What is not in this repository

The working copy this repository is published from holds more than is committed here.
Three kinds of material are left out, and some pages still refer to them by path.

- **Third-party repository clones**, under `launchpads/<slug>/_raw/github/`.
  About half of them ship no licence, so they cannot be redistributed.
  Every one is listed in [`upstream-repos.tsv`](upstream-repos.tsv) with its upstream URL and the exact commit that was read.
  Run `scripts/restore-upstream-repos.sh` to clone them all back into place, or pass a path prefix such as `launchpads/doppler` to restore one platform.
- **Browser session captures** (`*.har`), which are large and embed the visited sites' own API keys.
- **Minified site bundles**, under `launchpads/<slug>/_raw/js/`, `launchpads/<slug>/_raw/bundles*/` and the `index-*.js` files in `robinhood-chain/_raw/`.
  Findings drawn from them are written up in the platform READMEs, and the bundle URLs are recorded in each platform's `LINKS.md`.
  The scripts under `_raw/tools/` are this project's own tooling and are included.

The test wallet address used for read-only and login-gate captures is replaced with `0xTEST_WALLET_ADDRESS_REDACTED` throughout.
Keys belonging to the archived sites are replaced with `<REDACTED_THIRD_PARTY_KEY>`.

## Uniswap archive

`uniswap/` was captured 2026-08-22 and re-checked 2026-09-03.
Pages come from the docs site's own Markdown endpoint (`<url>.md`), which is the cleanest possible source; each file's first line records its source URL and capture method.
`uniswap/DEPLOYMENTS.md` is generated from Uniswap's official `deployments.json` feed (`uniswap/_raw/deployments.json`) and covers v2, v3, v4, UniswapX, Permit2, Universal Router, Smart Wallet, and Liquidity Launchpad on every chain, Robinhood Chain (4663) included.

Resolved 2026-09-03: two UniversalRouter contracts are live on Robinhood Chain and both are genuine.
Use `0x8876789976dEcBfCbBbe364623C63652db8C0904` for swapping, which is what Uniswap's SDK constants, the docs tables and the live Trading API all name and what carries 99.7 percent of the chain's router traffic.
`0x06AfBA43Fd06227fA663b0DAecF536f6EaA6bf99` is a second deployment of the byte-identical build whose only difference is a real Across SpokePool wired in place of a revert stub, and it is the one `deployments.json` records.
Neither is a fork of the other; the evidence is in `uniswap/DEPLOYMENTS.md`, section "Universal Router on Robinhood Chain: resolved 2026-09-03".
The Bags docs call `0x8876...0904` a "Robinhood-modified fork"; that claim is false and is corrected in `launchpads/bags/README.md`.

## Refreshing

Addresses, interfaces, and architecture are stable.
Prices, supply, multipliers, gas, and the token roster move.
Re-run the capture before trusting a moving value in a production decision; `31-onchain-verification.md` documents the method and lists the raw files.

To refresh the Robinhood Chain docs archive: **do not use `tvly map` or a sitemap for page discovery.**
`docs.robinhood.com/chain` is a Vocs single-page app that serves no sitemap and no `llms.txt`, and the Tavily map missed 5 of the 25 real pages and churns between runs.
The complete route table, plus the URL-encoded MDX source of every page, is embedded in the app bundle at `https://cdn.robinhood.com/assets/generated_assets/hoodchain_docsite/assets/index-*.js`, which gives an exact source-level diff with no rendering.

To refresh the Uniswap archive: re-fetch `https://developers.uniswap.org/llms.txt` for the page list, then `curl <page-url>.md` per page and `curl https://developers.uniswap.org/deployments.json`.
Checked 2026-09-03: both files came back byte-identical to the `uniswap/_raw/` copies, all 311 `llms.txt` URLs still resolve to an archived page, and `deployments.json` is still the 2026-07-15 generation, so nothing needed re-capturing.
