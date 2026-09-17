# Doppler link inventory

Every link discovered on any Doppler page captured on 2026-09-02, with where it was found and what it was captured as.

Sources scanned: all 49 docs pages (markdown link extraction, `_raw/links-extracted.tsv`), the `agent-browser` accessibility snapshots of `app.doppler.lol` with hrefs, the two docs sitemaps, `~gitbook/site-index`, `llms.txt`, the HAR of a full app session (`_raw/network/app-session.har`), and the Jina Reader captures of every external Doppler property.

Types: `internal` is a doppler.lol or app.doppler.lol URL, `external` is anything else.

## From launchpad-research.md

| found on | link text | href | type | captured as |
| --- | --- | --- | --- | --- |
| launchpad-research.md 2.1 | doppler app | <https://app.doppler.lol/> | internal | pages/50-app-home.md |
| launchpad-research.md 2.2 | doppler docs | <https://docs.doppler.lol/> | internal | pages/01-docs-home.md |

## Docs pages (every URL in the sitemap, all 49 visited)

Discovered from `_raw/tavily-map-docs.json` (21 URLs), `_raw/jina/docs-sitemap-pages.xml` (49 URLs), `_raw/jina/docs-llms.txt` and `_raw/jina/docs-gitbook-site-index.json`.
The tavily map missed 28 leaf pages that the sitemap has; the sitemap is the complete set and every one of its 49 URLs has a `pages/` file.

| found on | link text | href | type | captured as |
| --- | --- | --- | --- | --- |
| docs sitemap and nav | Home | <https://docs.doppler.lol/> | internal | pages/01-docs-home.md |
| docs sitemap and nav | Explainer | <https://docs.doppler.lol/explainer> | internal | pages/02-docs-explainer.md |
| docs sitemap and nav | Creation & initialization | <https://docs.doppler.lol/core-concepts/creation-and-initialization> | internal | pages/03-docs-core-concepts-creation-and-initialization.md |
| docs sitemap and nav | Price discovery auctions | <https://docs.doppler.lol/core-concepts/price-discovery-auctions> | internal | pages/04-docs-core-concepts-price-discovery-auctions.md |
| docs sitemap and nav | Supply curves | <https://docs.doppler.lol/core-concepts/supply-curves> | internal | pages/05-docs-core-concepts-supply-curves.md |
| docs sitemap and nav | Liquidity migration | <https://docs.doppler.lol/core-concepts/liquidity-migration-options> | internal | pages/06-docs-core-concepts-liquidity-migration-options.md |
| docs sitemap and nav | Fees & economics | <https://docs.doppler.lol/core-concepts/fees-and-economics> | internal | pages/07-docs-core-concepts-fees-and-economics.md |
| docs sitemap and nav | Doppler Hooks | <https://docs.doppler.lol/advanced-features/doppler-hooks> | internal | pages/08-docs-advanced-features-doppler-hooks.md |
| docs sitemap and nav | Fee Rehypothecation | <https://docs.doppler.lol/advanced-features/rehype-pools> | internal | pages/09-docs-advanced-features-rehype-pools.md |
| docs sitemap and nav | Doppler404 | <https://docs.doppler.lol/advanced-features/doppler404> | internal | pages/10-docs-advanced-features-doppler404.md |
| docs sitemap and nav | SDK API | <https://docs.doppler.lol/reference/api-reference> | internal | pages/11-docs-reference-api-reference.md |
| docs sitemap and nav | EVM SDK Examples | <https://docs.doppler.lol/reference/examples> | internal | pages/12-docs-reference-examples.md |
| docs sitemap and nav | Multicurve | <https://docs.doppler.lol/reference/examples/multicurve> | internal | pages/13-docs-reference-examples-multicurve.md |
| docs sitemap and nav | Static auctions | <https://docs.doppler.lol/reference/examples/static-auctions> | internal | pages/14-docs-reference-examples-static-auctions.md |
| docs sitemap and nav | Dynamic auctions | <https://docs.doppler.lol/reference/examples/dynamic-auctions> | internal | pages/15-docs-reference-examples-dynamic-auctions.md |
| docs sitemap and nav | Quoting, monitoring, and metrics | <https://docs.doppler.lol/reference/examples/quoting-monitoring-and-metrics> | internal | pages/16-docs-reference-examples-quoting-monitoring-and-metrics.md |
| docs sitemap and nav | SVM SDK Examples | <https://docs.doppler.lol/reference/svm-sdk-examples> | internal | pages/17-docs-reference-svm-sdk-examples.md |
| docs sitemap and nav | Launch | <https://docs.doppler.lol/reference/svm-sdk-examples/launch> | internal | pages/18-docs-reference-svm-sdk-examples-launch.md |
| docs sitemap and nav | Dynamic fee launch | <https://docs.doppler.lol/reference/svm-sdk-examples/dynamic-fee-launch> | internal | pages/19-docs-reference-svm-sdk-examples-dynamic-fee-launch.md |
| docs sitemap and nav | Swap | <https://docs.doppler.lol/reference/svm-sdk-examples/swap> | internal | pages/20-docs-reference-svm-sdk-examples-swap.md |
| docs sitemap and nav | Launch, monitor, and e2e | <https://docs.doppler.lol/reference/svm-sdk-examples/launch-monitor-and-e2e> | internal | pages/21-docs-reference-svm-sdk-examples-launch-monitor-and-e2e.md |
| docs sitemap and nav | Data Indexing | <https://docs.doppler.lol/reference/overview> | internal | pages/22-docs-reference-overview.md |
| docs sitemap and nav | Indexer API | <https://docs.doppler.lol/reference/api-usage> | internal | pages/23-docs-reference-api-usage.md |
| docs sitemap and nav | Quotes & swaps | <https://docs.doppler.lol/reference/quotes-and-swaps> | internal | pages/24-docs-reference-quotes-and-swaps.md |
| docs sitemap and nav | Contract addresses | <https://docs.doppler.lol/reference/contract-addresses> | internal | pages/25-docs-reference-contract-addresses.md |
| docs sitemap and nav | Metadata standards | <https://docs.doppler.lol/reference/metadata-standards> | internal | pages/26-docs-reference-metadata-standards.md |
| docs sitemap and nav | Legacy SDK migration guide | <https://docs.doppler.lol/reference/legacy-sdks-and-migration-guides> | internal | pages/27-docs-reference-legacy-sdks-and-migration-guides.md |
| docs sitemap and nav | v3 | <https://docs.doppler.lol/reference/legacy-sdks-and-migration-guides/v3> | internal | pages/28-docs-reference-legacy-sdks-and-migration-guides-v3.md |
| docs sitemap and nav | Overview | <https://docs.doppler.lol/reference/legacy-sdks-and-migration-guides/v3/overview> | internal | pages/29-docs-reference-legacy-sdks-and-migration-guides-v3-overview.md |
| docs sitemap and nav | Get Started | <https://docs.doppler.lol/reference/legacy-sdks-and-migration-guides/v3/getting-started> | internal | pages/30-docs-reference-legacy-sdks-and-migration-guides-v3-getting-started.md |
| docs sitemap and nav | Factory | <https://docs.doppler.lol/reference/legacy-sdks-and-migration-guides/v3/factory> | internal | pages/31-docs-reference-legacy-sdks-and-migration-guides-v3-factory.md |
| docs sitemap and nav | Token | <https://docs.doppler.lol/reference/legacy-sdks-and-migration-guides/v3/token> | internal | pages/32-docs-reference-legacy-sdks-and-migration-guides-v3-token.md |
| docs sitemap and nav | Quoter | <https://docs.doppler.lol/reference/legacy-sdks-and-migration-guides/v3/quoter> | internal | pages/33-docs-reference-legacy-sdks-and-migration-guides-v3-quoter.md |
| docs sitemap and nav | Custom Fees | <https://docs.doppler.lol/reference/legacy-sdks-and-migration-guides/v3/custom-fees> | internal | pages/34-docs-reference-legacy-sdks-and-migration-guides-v3-custom-fees.md |
| docs sitemap and nav | Governance Options | <https://docs.doppler.lol/reference/legacy-sdks-and-migration-guides/v3/governance-options> | internal | pages/35-docs-reference-legacy-sdks-and-migration-guides-v3-governance-options.md |
| docs sitemap and nav | Streamable V3 | <https://docs.doppler.lol/reference/legacy-sdks-and-migration-guides/v3/streamable-v3> | internal | pages/36-docs-reference-legacy-sdks-and-migration-guides-v3-streamable-v3.md |
| docs sitemap and nav | v4 | <https://docs.doppler.lol/reference/legacy-sdks-and-migration-guides/v4> | internal | pages/37-docs-reference-legacy-sdks-and-migration-guides-v4.md |
| docs sitemap and nav | Overview | <https://docs.doppler.lol/reference/legacy-sdks-and-migration-guides/v4/overview> | internal | pages/38-docs-reference-legacy-sdks-and-migration-guides-v4-overview.md |
| docs sitemap and nav | Get Started | <https://docs.doppler.lol/reference/legacy-sdks-and-migration-guides/v4/getting-started> | internal | pages/39-docs-reference-legacy-sdks-and-migration-guides-v4-getting-started.md |
| docs sitemap and nav | Examples | <https://docs.doppler.lol/reference/legacy-sdks-and-migration-guides/v4/examples> | internal | pages/40-docs-reference-legacy-sdks-and-migration-guides-v4-examples.md |
| docs sitemap and nav | Factory | <https://docs.doppler.lol/reference/legacy-sdks-and-migration-guides/v4/factory> | internal | pages/41-docs-reference-legacy-sdks-and-migration-guides-v4-factory.md |
| docs sitemap and nav | Quoter | <https://docs.doppler.lol/reference/legacy-sdks-and-migration-guides/v4/quoter> | internal | pages/42-docs-reference-legacy-sdks-and-migration-guides-v4-quoter.md |
| docs sitemap and nav | Lens | <https://docs.doppler.lol/reference/legacy-sdks-and-migration-guides/v4/lens> | internal | pages/43-docs-reference-legacy-sdks-and-migration-guides-v4-lens.md |
| docs sitemap and nav | Custom Fees | <https://docs.doppler.lol/reference/legacy-sdks-and-migration-guides/v4/custom-fees> | internal | pages/44-docs-reference-legacy-sdks-and-migration-guides-v4-custom-fees.md |
| docs sitemap and nav | Governance Options | <https://docs.doppler.lol/reference/legacy-sdks-and-migration-guides/v4/governance-options> | internal | pages/45-docs-reference-legacy-sdks-and-migration-guides-v4-governance-options.md |
| docs sitemap and nav | Historical context | <https://docs.doppler.lol/reference/legacy-sdks-and-migration-guides/overview> | internal | pages/46-docs-reference-legacy-sdks-and-migration-guides-overview.md |
| docs sitemap and nav | Legacy SDK migration guide | <https://docs.doppler.lol/reference/legacy-sdks-and-migration-guides/sdk-migration-guide> | internal | pages/47-docs-reference-legacy-sdks-and-migration-guides-sdk-migration-guide.md |
| docs sitemap and nav | Security & bug bounties | <https://docs.doppler.lol/reference/security-and-bug-bounties> | internal | pages/48-docs-reference-security-and-bug-bounties.md |
| docs sitemap and nav | Roadmap | <https://docs.doppler.lol/reference/roadmap> | internal | pages/49-docs-reference-roadmap.md |

Three docs machine-readable endpoints, also all captured:

| found on | link text | href | type | captured as |
| --- | --- | --- | --- | --- |
| docs nav banner | llms.txt | <https://docs.doppler.lol/llms.txt> | internal | `_raw/jina/docs-llms.txt` |
| docs nav banner | llms-full.txt | <https://docs.doppler.lol/llms-full.txt> | internal | `_raw/jina/docs-llms-full.txt` |
| tavily map | readme.md (the Home page as markdown) | <https://docs.doppler.lol/readme.md> | internal | pages/01-docs-home.md |
| GitBook | site index JSON | <https://docs.doppler.lol/~gitbook/site-index> | internal | `_raw/jina/docs-gitbook-site-index.json` |
| GitBook | sitemap | <https://docs.doppler.lol/sitemap.xml> | internal | `_raw/jina/docs-sitemap.xml` |
| GitBook | page sitemap | <https://docs.doppler.lol/sitemap-pages.xml> | internal | `_raw/jina/docs-sitemap-pages.xml` |

## App routes and views

`app.doppler.lol` is a single-page app.
Create token, Portfolio, Filters, How it works, Privacy and Terms are all modals or slide-overs that do not change the URL, so they are listed by the control that opens them.

| found on | link text | href | type | captured as |
| --- | --- | --- | --- | --- |
| launchpad-research.md 2.1 | Doppler (logo) | <https://app.doppler.lol/> | internal | pages/50-app-home.md, screenshots/01-app-home.png |
| app header | Filters | (client state, no URL) | internal | pages/51-app-filters.md, screenshots/02-app-filters.png |
| app header, Filters -> Robinhood | (chain filter) | (client state, no URL) | internal | pages/52-app-home-robinhood.md, screenshots/03-app-home-robinhood.png |
| app header | Create token | (slide-over) | internal | pages/53-app-create-launch-mode.md, screenshots/04, 05 |
| Create token -> Robinhood -> Multicurve | Quick launch | (slide-over) | internal | pages/54-app-create-quick-multicurve-robinhood.md, screenshots/06, 07 |
| Create token -> Robinhood -> Multicurve | Standard launch | (5-step wizard) | internal | pages/55-app-create-standard-launch-robinhood.md, screenshots/08 to 14 |
| app header | Portfolio | <https://app.doppler.lol/portfolio> | internal | pages/57-app-portfolio.md, screenshots/20-app-portfolio.png |
| app feeds | token page | <https://app.doppler.lol/tokens/robinhood/0x64bcf4aa85559526cff0528bcdc0cb9d3ea41e18> | internal | pages/56-app-token-johndog-robinhood.md, screenshots/23 |
| app footer | How it works | (carousel) | internal | pages/58-app-how-it-works.md, screenshots/16-1 to 16-3 |
| app footer | More, which reveals Doppler, Privacy and Terms | (expands the footer) | internal | screenshots/17-app-footer-more.png |
| app footer -> More | Privacy | (modal) | internal | pages/59-app-privacy.md, screenshots/18-app-privacy.png |
| app footer -> More | Terms | (modal) | internal | pages/60-app-terms.md, screenshots/19-app-terms.png |
| app footer -> More | Doppler | <https://doppler.lol/> | internal | pages/63-doppler-lol-home.md |
| app footer | Docs | <https://docs.doppler.lol/> | internal | pages/01-docs-home.md |
| app footer | X.com | <https://x.com/dopplerprotocol> | external | socials/01-x-dopplerprotocol.md |
| app footer | Telegram | <https://t.me/pure_markets> | external | socials/03-telegram.md |
| app header | Connect, which opens the Privy login | (modal) | internal | pages/62-app-connect-wallet-gate.md, screenshots/24-app-connect-privy-login.png |
| Connect -> Continue with a wallet | Select your wallet | (modal) | internal | pages/62-app-connect-wallet-gate.md, screenshots/25-app-connect-wallet-list.png |
| Connect -> wallet -> signature | SIWE challenge | (wallet prompt) | internal | pages/62-app-connect-wallet-gate.md, `_raw/wallet/siwe-message.txt`, screenshots/26 |
| authenticated header | logged-in app | (client state) | internal | pages/62-app-connect-wallet-gate.md, screenshots/27-app-logged-in.png |
| authenticated Portfolio | balances, Claimable fees | <https://app.doppler.lol/portfolio> | internal | pages/62-app-connect-wallet-gate.md, screenshots/28, 29 |
| authenticated Menu | Instant buy, enabled | (popover) | internal | pages/62-app-connect-wallet-gate.md, screenshots/30-app-menu-connected.png |
| authenticated account menu | Privy embedded EVM and Solana wallets | (popover) | internal | pages/62-app-connect-wallet-gate.md, screenshots/31-app-account-menu.png |
| authenticated Create | submit becomes Create token, balance precheck | (slide-over) | internal | pages/62-app-connect-wallet-gate.md, screenshots/32, 33 |
| Privy login modal | Terms | <https://app.doppler.lol/terms-of-service> | internal | pages/60-app-terms.md (same document, captured as the footer modal) |
| Privy login modal | Privacy Policy | <https://app.doppler.lol/privacy-policy> | internal | pages/59-app-privacy.md (same document, captured as the footer modal) |
| Privy login modal | Privy, the identity provider | <https://privy.io/> | external | recorded only |
| app header | Menu (Instant buy, Theme) | (popover) | internal | pages/61-app-command-palette-and-menu.md, screenshots/21-app-menu.png |
| app header | search, the command palette | (modal) | internal | pages/61-app-command-palette-and-menu.md, screenshots/22-app-search.png |

Token detail pages: 105 distinct `/tokens/<chain>/<address>` URLs were seen across the feeds and the HAR, 91 of them on `robinhood` and 14 on `base`.
One is written up in full (`pages/56`); the rest are listed in `_raw/links-extracted.tsv` and their on-chain data is in `_raw/blockscout/tokens-*.json` and `_raw/api/dexscreener-token-pairs-*.json`.
They are token listings rather than pages about the platform, so they are recorded but not each written up.

## Doppler-owned external properties

| found on | link text | href | type | captured as |
| --- | --- | --- | --- | --- |
| app footer, docs home | Doppler marketing site | <https://doppler.lol/> | internal | pages/63-doppler-lol-home.md |
| doppler.lol | Telegram redirect | <https://doppler.lol/telegram> | internal | socials/03-telegram.md, pages/73-telegram-pure-markets.md |
| docs home, doppler.lol | Whetstone Research | <https://whetstone.cc/> | external | pages/64-whetstone-cc.md |
| docs security page | security contact | <mailto:security@whetstone.cc> | external | recorded only, pages/48 |
| docs api-usage | test indexer, Base Sepolia | <https://test.indexer.doppler.lol/> | external | pages/74-test-indexer-playground.md, `_raw/api/probe-test.indexer.doppler.lol_graphql.txt` |
| app HAR | production indexer, all chains | <https://indexer-prod.doppler.lol/> | external | not linked anywhere; found in `_raw/network/app-session.har`. Probed in `_raw/api/probe-indexer-prod-*.json` |
| doppler.lol | Multicurve paper | <https://doppler.lol/multicurve.pdf> | internal | pages/72-paper-multicurve.md, `_raw/api/multicurve.pdf` |
| docs home | Price Discovery Auctions paper | <https://aada.ms/pdfs/pda.pdf> | external | pages/71-paper-price-discovery-auctions.md, `_raw/api/aada-pda.pdf` |

## Source, audits and security

| found on | link text | href | type | captured as |
| --- | --- | --- | --- | --- |
| docs, GitHub | core contracts | <https://github.com/whetstoneresearch/doppler> | external | pages/67-github-doppler-contracts.md, clone `_raw/github/doppler` @ 5754c7ee |
| docs, GitHub | TypeScript SDK | <https://github.com/whetstoneresearch/doppler-sdk> | external | pages/68-github-doppler-sdk.md, clone `_raw/github/doppler-sdk` @ 6bc20400 |
| docs | legacy SDK | <https://github.com/whetstoneresearch/doppler-sdk-legacy> | external | pages/70-github-doppler-sdk-legacy.md, clone `_raw/github/doppler-sdk-legacy` @ c8a9666f |
| docs | demo app | <https://github.com/whetstoneresearch/doppler-demo-app> | external | pages/69-github-doppler-demo-app.md, clone `_raw/github/doppler-demo-app` @ 3ff6b27a |
| docs contract table | Airlock.sol at main | <https://github.com/whetstoneresearch/doppler/blob/main/src/Airlock.sol> | external | `_raw/jina/ext-gh-doppler-airlock-sol.md` |
| docs contract table | 36 commit permalinks, one per deployed contract | `https://github.com/whetstoneresearch/doppler/commit/<sha>` | external | listed in `_raw/links-extracted.tsv`; the repo itself is cloned |
| docs security page | OpenZeppelin Audit, Nov 2024 | <https://drive.google.com/drive/folders/1cgY4UDtQ9j2v1t4XvFBraJqNCUfrdFxq> | external | not captured, Google Drive folder needs a session. See Gaps |
| docs security page | Certora Audit, Nov 2024 | (same Drive folder) | external | not captured, same reason |
| docs security page | Cantina audit contest | <https://cantina.xyz/competitions/57b00aab-8f8b-4d62-9378-41b6460ce6aa> | external | pages/66-cantina-competition.md |
| docs security page | Cantina bug bounty | <https://cantina.xyz/bounties/2c7af549-c36c-4432-bae6-3f4b1fa6b217> | external | pages/65-cantina-bug-bounty.md |

## Other external links in the docs

| found on | link text | href | type | captured as |
| --- | --- | --- | --- | --- |
| docs home | Zora, a Doppler integrator | <https://zora.co/> | external | `_raw/jina/ext-zora.md` |
| docs home | Paragraph, a Doppler integrator | <https://paragraph.com/> | external | `_raw/jina/ext-paragraph.md` |
| docs home | Noice, a Doppler integrator | <https://noice.so/> | external | `_raw/jina/ext-noice.md` |
| docs home | Bankr, a Doppler integrator | <https://bankr.bot/> | external | `_raw/jina/ext-bankr.md` |
| docs Data Indexing | Ponder, the indexer framework | <https://ponder.sh/> | external | `_raw/jina/ext-ponder.md` |
| docs Doppler404 | DN404 reference implementation | <https://github.com/Vectorized/dn404> | external | `_raw/jina/ext-gh-dn404.md` |
| docs Doppler404 | ERC-7631 discussion | <https://ethereum-magicians.org/t/erc-7631-dual-nature-token-pair/18796> | external | `_raw/jina/ext-erc-7631.md` |
| docs governance options | OpenZeppelin Governor | <https://docs.openzeppelin.com/contracts/4.x/api/governance> | external | `_raw/jina/ext-oz-governor.md` |
| docs quotes and swaps | Uniswap universal-router-sdk | <https://github.com/Uniswap/sdks/tree/main/sdks/universal-router-sdk> | external | `_raw/jina/ext-gh-universal-router-sdk.md` |
| docs legacy v3/v4 | drift, the web3 client abstraction | <https://github.com/delvtech/drift> | external | `_raw/jina/ext-gh-drift.md` |
| docs legacy v3/v4 | drift docs | <https://delvtech.github.io/drift/> | external | `_raw/jina/ext-drift-docs.md`, dead: GitHub Pages 404 |
| docs getting started | Base network faucets | <https://docs.base.org/tools/network-faucets> | external | `_raw/jina/ext-base-faucets.md` |
| docs metadata standards | IPFS metadata example | <https://ipfs.io/ipfs/QmTM59ZqHcJgv1EQVWs6e96Hchd3diHW9F9evLWmX2PQCU> | external | `_raw/jina/ext-ipfs-metadata-example.md`, blocked by a Cloudflare interstitial |

## Broken links found in the docs

| found on | link text | href | why it is broken |
| --- | --- | --- | --- |
| pages/49, Roadmap | Doppler Airlock | <https://docs.doppler.lol/how-it-works/airlock-and-modules> | 404. The page does not exist and is not in the sitemap |
| pages/30 and pages/39, v3 and v4 Get Started | Implementation Guide | `broken://pages/2xkvOvHSEt9zfaWDOv5z` | unresolved GitBook page reference, published as-is |
| pages/22, Data Indexing | Development Guide | `broken://pages/VZBnc78XqauN19pCmwWr` | unresolved GitBook page reference, published as-is |
| pages/69 and others | doppler-docs source files | `https://github.com/whetstoneresearch/doppler-docs/blob/main/...` (3 URLs) | GitHub 404, the paths moved when the docs repo was restructured |

## Block explorer links in the contract-addresses page

`pages/25-docs-reference-contract-addresses.md` links every deployed contract to its explorer, twice per row (address and creation transaction), across six networks:

| network | explorer host | rows |
| --- | --- | --- |
| Ethereum Mainnet (1) | etherscan.io | 22 |
| Monad Mainnet (143) | monadscan.com | 22 |
| **Robinhood Mainnet (4663)** | robinhoodchain.blockscout.com | **25** |
| Base (8453) | basescan.org | 24 |
| Arbitrum One (42161) | arbiscan.io | 25 |
| Base Sepolia (84532) | sepolia.basescan.org | 25 |

Only the Robinhood Mainnet rows matter here, and every one of those 25 addresses has a directory under `contracts/`.
The other networks' links are recorded in `_raw/links-extracted.tsv` and not followed; they point at chains this archive is not about.

## Backend endpoints (not links, but discovered the same way)

Found in the HAR, not linked from any page.
Documented in section 6 of `README.md`, samples in `_raw/har-api/`.

| endpoint | captured as |
| --- | --- |
| `GET https://app.doppler.lol/api/explore` | `_raw/har-api/app-api-explore.json` |
| `GET https://app.doppler.lol/api/trendingPools` | `_raw/har-api/app-api-trendingPools.json` |
| `GET https://app.doppler.lol/api/metadata/<chain>/<token>` | `_raw/har-api/app-api-metadata.json` |
| `GET https://app.doppler.lol/api/social/recent-buyers/<chain>/<token>` | `_raw/har-api/app-api-social-recent-buyers.json` |
| `GET https://app.doppler.lol/api/upcoming-auctions?tokenAddress=` | `_raw/har-api/app-api-upcoming-auctions.json` |
| `GET https://app.doppler.lol/api/native-price?assets=eth` | `_raw/har-api/app-api-native-price.json` |
| `GET https://app.doppler.lol/api/image/<chain>/<token>` | HAR only |
| `POST https://app.doppler.lol/api/rpc/4663` | `_raw/har-api/app-api-rpc-4663.json` |
| `POST https://indexer-prod.doppler.lol/` | `_raw/har-api/indexer-prod-graphql.json`, `_raw/api/probe-indexer-prod-*.json` |
| `GET https://rc-api-rc.up.railway.app/api/{tokens,launches,markets}/eip155:4663/...` | `_raw/har-api/rc-api-*.json` |
| `GET https://app.geckoterminal.com/api/p1/candlesticks/...` | HAR only |
