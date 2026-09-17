# Blockscout documentation archive

Complete capture of `https://docs.blockscout.com`, 402 pages, taken 2026-09-10.
Every file is the page's own source markdown as GitBook serves it at `<page-url>.md`, so nothing was converted from HTML and nothing is paraphrased.
Component tags such as `<Card>`, `<Warning>` and `<Tabs>` are left as they were in the source.

Start at `INDEX.md`, which lists every page with its title and one-line description, grouped by section.

## Layout

| Path | What it is |
| --- | --- |
| `INDEX.md` | Every page, title and description, grouped by section. |
| `index.md` | The site's landing page. |
| `robinhood-api.md` | **The page written for our chain.** Chain id 4663, PRO API base, the three route styles, the Etherscan-compatible modules, the 1,000-record cap on `txlistinternal` and `eth_getLogs`, and pricing. |
| `rate-limits.md` | Tiers, per-endpoint credit costs, and the free tier's roughly 5,000 requests a day at 20 credits each. |
| `make-your-first-call.md`, `best-practices.md` | The two short pages to read before scripting anything. |
| `devs/` | The developer hub: `for-web3-developers.md`, `apis/`, `verification/`, `blockscout-sdk.md`, `mcp-server.md`, `api-for-ai-agents.md`, `pro-api.md`, `pro-api-responses-and-routes.md`, `error-responses.md`, `migrate-from-etherscan.md`, `x402-payments.md`, `metadata-service.md`, `multichain-service.md`. |
| `api-reference/` | 212 pages, one per endpoint, grouped by resource: `addresses/`, `transactions/`, `tokens/`, `token-transfers/`, `smart-contracts/`, `blocks/`, `internal-transactions/`, `search/`, `stats/`, `advanced-filters/`, `csv-export/`, `account-abstraction/`, `arbitrum/` for the L2-specific routes, and the `legacy/` Etherscan-style module reference. |
| `using-blockscout/` | Explorer UI features: verification flows, watchlists, tags, CSV export, the swap and bridge widgets. |
| `setup/` | Self-hosting: Docker, env variables, indexer configuration, microservices. Reference only; we use the hosted instance. |
| `guides/`, `resources/`, `faqs/`, `about/`, `get-started/` | Tutorials, changelog, FAQs, announcements, onboarding. |
| `_raw/` | `sitemap.xml`, `llms.txt`, `llms-full.txt` (all pages in one 1.7 MB file, useful for grep), `urls.txt`, `CAPTURED.txt`, and `fetch.sh` to refresh. |

## Start here for developing and testing on Robinhood Chain

1. `robinhood-api.md`, then `rate-limits.md`.
2. `devs/pro-api.md` and `devs/pro-api-responses-and-routes.md` for the PRO endpoint at `api.blockscout.com/4663`, which needs `BLOCKSCOUT_API_KEY` from `.env` and is credit-metered.
3. `devs/error-responses.md` before writing retry logic.
4. `api-reference/smart-contracts/` and `devs/verification/` for verifying our hook, token and locker after deployment. `devs/verification/foundry-verification.md` covers `forge verify-contract`, `devs/verification/blockscout-ui.md` the UI path, and `devs/verification/blockscout-smart-contract-verification-api.md` the raw API.
5. `api-reference/arbitrum/` for batch and L1-settlement routes specific to this L2.
6. `devs/mcp-server.md` and `devs/api-for-ai-agents.md` for the tooling this session already has wired in.
7. `api-reference/advanced-filters/` and `api-reference/csv-export/` for pulling volume and fee data in bulk.

Our own notes on which explorer routes actually answer questions about chain 4663, including the browser User-Agent requirement on the public instance and the 180-per-window limit, are in `../robinhood-chain/32-explorer-and-data-apis.md` and `../../SCRAPING-PLAN.md`.
Where those notes and these docs disagree, the notes were verified against the live instance and the docs describe the product in general.

## Refreshing

From the `long-launch` root:

```bash
bash resources/blockscout/_raw/fetch.sh
```

It re-reads the sitemap and `llms.txt`, fetches every page as markdown with six parallel connections, and prints any URL that did not return 200.
Expect four 307s for the Discord, discussion, GitHub and `apis-redirect` stubs, which are external redirects and not pages.
