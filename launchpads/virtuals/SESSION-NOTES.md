# Virtuals session notes (Session C, 2026-09-02)

This file carries the three things this session was not allowed to write into the shared files: the part 4.4 status row for `SCRAPING-PLAN.md`, the findings block for section 5.5, and the additions for `PLAYBOOK.md`.
Whoever merges the three parallel sessions should copy these into the shared files and delete nothing here.

## 1. Status row for SCRAPING-PLAN.md part 4.4

| Slug | Raw captures | pages/ | screenshots/ | contracts/ | socials/ | LINKS.md | README.md | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `virtuals` | 2353 raw files, 11 GitHub clones, 43 app views read through agent-browser, decoded preLaunch and launch transactions, 14 contract read dumps in `_raw/rpc/`, 91 Blockscout address records and 55 source records | 282 | 51 | 63 dirs (50 verified with sources, 8 unverified with bytecode, 5 clone or TBA records) | 7 | yes (4,571 rows) | yes | **Done** 2026-09-02 |

## 2. Findings block for SCRAPING-PLAN.md section 5.5

- Not Doppler-derived.
`indexer-prod.doppler.lol` returns `totalCount 0` on chain 4663 for the tax vault `0x6D80B81d...`, the treasury `0xb51C52d9...`, the launch-fee wallet `0x86CbAC9d...`, the owner `0xc31Cf116...` and the anti-sniper vault `0x32487287...`, and the contract set is Virtuals' own `BondingV5` / `FFactoryV3` / `FRouterV3` / `AgentFactoryV7` / `AgentTaxV2` stack with a Uniswap V2 exit.
The doppler archive was not needed and was not edited.
- VIRTUAL reached the chain through Chainlink CCIP: `0xc6911796...` is a `CrossChainToken` with a `BurnMintTokenPool`, deployed by the Virtuals deployer `0xe4a0015B...` on 2026-06-23; the launch stack followed on 2026-06-25 and the first token was pre-launched 2026-06-26.
- Economics verified on chain: 1,000,000,000 supply, 8,500 VIRTUAL fake initial liquidity (18,000 with ACF), graduation at 42,000 real VIRTUAL, 1 percent buy and sell tax on the curve and in the token after graduation, 30 percent to the treasury and 70 percent to the creator paid in USDG, 10-year LP lock through `AgentVeTokenV2` (VEX `matureAt` is exactly `fundedDate + 10 years`), anti-sniper tax 99 percent decaying over 60 s, 10 min or 98 min, 0 VIRTUAL to launch, 10 VIRTUAL for ACF.
- Graduation FDV works out to 300,000 VIRTUAL (plain) or 400,000 VIRTUAL (ACF); at graduation 140.0 M (plain) or 105.0 M (ACF) tokens go into the pool with the 42,000 VIRTUAL, and the excess goes to a burn wallet that feeds Hyperboost.
- Genesis and points do not exist on Robinhood Chain: every one of the 363 geneses in the backend is on Base, the Robinhood filter is empty, and the whitepaper calls Genesis and Unicorn superseded by modules.
- Activity: 25,342 tokens pre-launched, 85 graduated, 438K USD protocol fees on this chain in 30 days versus 218K USD on Base (DefiLlama), 6.2M USD of graduated-pool liquidity.
- Ownership risk: a single EOA `0xc31Cf116...` owns and can upgrade BondingV5, BondingConfig and TaxAccountingAdapter, and has upgraded BondingV5 three times already.
- Gaps: the create wizard is behind Privy login (launch parameters decoded from production transactions instead), `FFactoryV3` implementation and every `FPairV2` pair are unverified, Launch Radar fee and Hyperboost are backend-side, X timeline not capturable.

## 3. Additions for PLAYBOOK.md

### Whitepaper pages that are not in the sitemap

`whitepaper.virtuals.io` has 38 real pages that appear in neither `sitemap-pages.xml` nor `llms.txt` (the whole ACP developer onboarding guide, ACP v2 pages, builders-hub pages).
GitBook returns HTTP 200 for any path, so status codes do not detect missing pages; the `.md` body starts with `# Page Not Found` instead.
The crawler that found them is `_raw/tools/mkpages.py`'s companion loop in this session (six rounds of "collect internal links from every captured page, fetch the missing ones as `.md`, stop when nothing new"), results in `_raw/tools/wp-hidden-fetched.txt` and `wp-hidden-notfound.txt`.
Run that closure step on every GitBook site after the sitemap pass.

### Mintlify sites do not serve `.md`

`os.virtuals.io` (Mintlify) returns the SPA shell for `<path>.md`; `llms.txt` lists the pages with relative links and `llms-full.txt` has the whole site in one file but with no page delimiters.
Use `llms.txt` for the page list and Jina for each page (30 pages took about 2.5 minutes, longer than the default 2-minute Bash timeout, so pass `timeout` or split the loop).

### Jina cannot read Snapshot-style governance SPAs

`gov.virtuals.io` proposals come back empty through Jina; agent-browser `read` after `wait --load networkidle` works on the first try, and `legacy.virtuals.io` is the same.

### Bright Data `x_posts` pipeline

It accepts only `https://x.com/<user>/status/<id>` URLs, not profile URLs, and it silently returns fewer records than submitted (1 of 6 here).
Find status URLs first with `bdata search "<handle> <topic> site:x.com" --json` and with the links inside the project's own docs.
X Articles come back with metrics only, no body.

### Blockscout name search returns forks

Searching class names such as `BondingV1`, `FRouter`, `AgentFactory`, `virtualToken` on Robinhood Chain returns verified contracts deployed by unrelated addresses that copied the Virtuals code base.
Always confirm the creator address against the platform's deployer before treating a search hit as part of the platform.

### The auto-mode permission classifier blocks `rm -rf <dir>/*`

Even inside the session's own output directory, a command containing `rm -rf contracts/*` was denied as a whole, taking the useful parts of the command with it.
Keep destructive cleanup out of compound commands; the `mkcontract.py` and `mkpages.py` scripts recreate their outputs idempotently instead.

### Contract directory builder

`_raw/tools/mkcontract.py` (copied from `long/_raw/tools/`, `BASE` changed) reads a `role|address|note` list from stdin; the list used is `_raw/tools/contract-roles.txt`.
`_raw/tools/mkaddresses.py` builds `contracts/ADDRESSES.md` from the resulting directories plus hand-written EOA and fork sections.
`_raw/tools/mkpages.py`, `mklinks.py` and `mksocials.py` regenerate `pages/`, `LINKS.md` and `socials/` from `_raw/` and can be re-run at any time.

## 4. Session log

1. Inventory: 2,232 files on disk from the earlier attempts, including 45 screenshots, `_raw/rpc/` reads and 224 Blockscout files that the killed attempt had already produced; none were redone.
2. Doppler check: five integrator addresses queried, all zero.
3. Whitepaper: sitemap 72 URLs all present on disk; llms.txt order used for numbering; 38 hidden pages crawled; 66 zh and ko translations paged.
4. New captures this session: EconomyOS docs (31 pages), degen.virtuals.io docs, build and terms, four governance proposals and the forum home, legacy app, support portal, Dune Base dashboard, ACP developer agreement PDF, `app.virtuals.io/acp/new`, hidden whitepaper pages, one X post record, missing Blockscout sources for BondingV5 v2 and v3 implementations, the VEX Uniswap pair, the VIRTUAL/WETH V3 pool, the standalone AgentTokenV4, the RHOS creation transaction, and address records for 14 third-party forks.
5. Outputs: `pages/` 282, `screenshots/` 51 (45 to 50 added for governance and legacy), `contracts/` 63 directories plus `ADDRESSES.md`, `socials/` 7, `LINKS.md`, `README.md`, this file.
6. Browser session `lp-virtuals` closed by name at the end of the governance capture.

## 5. Open questions for the merge session

- Whether to add `virtuals` to the playbook's "independent stacks" grouping permanently: it shares nothing with Doppler, Pons or Long.
- The three helper contracts `0x22aC...`, `0xC8D5...`, `0x32FE...` (selector `0xe9dc6375`) deserve a look if anyone has time; they were deployed by the Virtuals deployer four days after the launch stack.
