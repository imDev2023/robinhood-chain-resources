# Robinhood Chain docs archive - changelog

Hand-written log of material changes to the pages archived in `resources/robinhood-chain/`.
"Material" means a changed fact, address, number, contact, version or policy.
Reformatting, nav changes, list-marker changes, code-fence language tags and boilerplate are excluded and are listed under "Checked and stable" instead.

## How the live doc set is discovered

`docs.robinhood.com/chain` is a Vocs single-page app.
It serves no sitemap and no `llms.txt`: `/chain/sitemap.xml`, `/chain/sitemap-pages.xml`, `/chain/llms.txt` and `/chain/llms-full.txt` all return the 535-byte SPA shell, and the root `/sitemap.xml` lists only `/`, `/crypto/`, `/crypto/connect/`, `/crypto/trading/` and `/healthcheck/`.
`tvly map` is therefore not sufficient on this site and has missed real pages on every run.

The authoritative page list is the route table inside the app bundle:

```
https://cdn.robinhood.com/assets/generated_assets/hoodchain_docsite/assets/index-<hash>.js
```

The hash changes on every rebuild, so **read it out of the `<script src=...>` on the page rather than reusing a previous one**.
Observed so far: `index-DCWCEAE1.js` on 2026-09-03 morning, `index-BHBqPiOr.js` on 2026-09-03 evening.
A changed hash is a signal worth checking and not, on its own, evidence of a content change: those two bundles carry byte-identical page sources.

That bundle also embeds the complete, URL-encoded MDX source of every page under a `content:` key, which makes an exact source-level diff possible without rendering anything.
The extracted sources for 2026-09-03 are in `_raw/docs-drift-2026-09-03/mdx/` and the bundle itself is kept alongside them.

---

## 2026-09-03 full audit

Every archived page, `01-` through `33-`, was content-diffed against its live source on this pass.
Not a sample and not a status check: 23 pages were diffed against the docsite bundle's own MDX, 6 against a freshly fetched external source, 2 against the live APIs behind them, 1 against the live explorer API, and 2 are original writing with no upstream document to diff.
This section exists so a reader can see that each page was actually checked, so the "checked and stable" list below matters as much as the changes.

### The bundle hash changed but the pages did not

Yesterday's pass read `index-DCWCEAE1.js`.
Today's shell serves `index-BHBqPiOr.js`, so the site was rebuilt between the two passes.
That is a new build, not new content.

- Both bundles are exactly 1,382,820 bytes.
- Comparing them byte for byte gives seven differing runs.
  Three are lazy-chunk filenames in the `__vite__mapDeps` table, one is the `PageViewTracker-*.js` chunk name, one is the `search-index-*.json` filename, and the two large runs are the route array reordered so that `/rhj` now sorts before `/chain`.
- All 25 `/chain` MDX sources extracted from the new bundle are **byte-identical** to the 25 extracted yesterday.

So a changed bundle hash is worth checking every time, and this time it meant nothing.
Raw: `_raw/docs-audit-2026-09-03b/index-BHBqPiOr.js`, extracted sources in `_raw/docs-audit-2026-09-03b/mdx/`, extractor in `_raw/docs-audit-2026-09-03b/extract.py`.

### Route table: no new routes

The route table holds 33 unique routes, 25 under `/chain` and 8 under `/rhj`, identical to yesterday.
No route was added or removed.
`34-lighter-domains.md` and `35-privacy-statements.md` remain the two most recent additions and both are still present in the table.
Route list: `_raw/docs-audit-2026-09-03b/routes-from-bundle.txt`, with byte sizes in `route-table.json`.

---

## Material changes found on 2026-09-03

### Chainlink is no longer expanding L2 Sequencer Uptime Feeds, and Robinhood Chain never got one

This is the most consequential finding of the pass and it was sitting in a page the last run had only status-checked.

- Page: `https://docs.chain.link/data-feeds/l2-sequencer-feeds`
- Archived as: `24-chainlink-l2-sequencer-feeds.md`
- Old value (2026-08-12): no availability notice of any kind.
- New value: a CAUTION block at the top of the page, quoted verbatim:
  > Chainlink is no longer expanding L2 Sequencer Uptime Feeds to additional networks. Existing feeds on the supported networks listed below will continue to operate and be supported.
- The supported-network list is unchanged at eleven entries: Arbitrum, BASE, Celo, Mantle, MegaETH, Metis, OP, Scroll, Soneium, X Layer and ZKsync.
  **Robinhood Chain is not on it**, and was not on 2026-08-12 either.
- Why it matters here: `21-oracles-and-price-feeds.md` tells developers to check an L2 sequencer uptime feed before trusting a price, and gives a code snippet for it, but no address.
  There is no such feed to point at.
  The Chainlink reference directory for this chain lists 57 feeds and none of them is a sequencer-uptime feed.
  With Chainlink now saying it will not add networks, one is unlikely to appear.
- `21-oracles-and-price-feeds.md` has an archive note recording this.
  Its own source text is unchanged; the note is clearly marked as not source text.

### Alchemy quickstart gained two explanatory sections

- Page: `https://www.alchemy.com/docs/reference/robinhood-chain-api-quickstart`
- Archived as: `25-alchemy-robinhood-quickstart.md`
- Old value: the page went from its title straight into the npm/yarn choice.
- New value: two new sections, `## What is Robinhood Chain?` and `## What is the Robinhood Chain API?`, plus explicit numbered step headings (`### 1. Choose a package manager (npm or yarn)` through `### 4. Run your script`).
- Unchanged: the example RPC URL is still the **testnet** endpoint `https://robinhood-testnet.g.alchemy.com/v2/your-api-key`, and the `eth_blockNumber` example is the same.

### Chainlink Data Streams added a Discovery endpoint reference

- Page: `https://docs.chain.link/data-streams`
- Archived as: `23-chainlink-data-streams.md`
- Old value: "Explore Available Data: Browse available reports and associated schemas to see what data is available."
- New value: the same sentence, extended with ", or discover streams programmatically with the Discovery endpoint", linking `https://docs.chain.link/data-streams/reference/data-streams-api/discovery-endpoint`.
- Small, but it is a new documented API surface, so it is a content change rather than formatting.

### Token registry: one multiplier moved, roster flat at 194

- Page: `https://docs.robinhood.com/chain/contracts`, live table
- Archived as: `16-token-contracts.md`
- The roster is **unchanged at 194 active Stock Tokens**: none added, none removed, every contract address identical to the 2026-09-02 pull.
  This resolves the previous entry that said the live table had not been re-pulled.
- One multiplier changed.
  `F` (Ford Motor, `0x25C288E6D899b9BC30160965aD9644c67e73bE0C`) read exactly `1.000000000000000000` on 2026-09-02 and reads `1.000145502866134027` on 2026-09-03.
  It follows the cash dividend with process date 2026-09-01 on `https://api.robinhood.com/rhj/corporate-actions`, applied the next business day.
  This makes F the tenth token with a non-unity multiplier.
- No other multiplier changed and no `pendingMultiplier` is populated anywhere.
- Total supply figures in that file were deliberately **not** refreshed: they drift continuously and the file's header already declares them point-in-time.
- Raw: `_raw/docs-audit-2026-09-03b/ext/rhj-assets.json`.

---

## Archive defects fixed on 2026-09-03, not source drift

### Token contracts: a canonical-token warning had never been captured

- Page: `https://docs.robinhood.com/chain/contracts`
- Archived as: `16-token-contracts.md`
- The source page carries this sentence, and has since at least 2026-08-12:
  > Use the addresses on this page to identify the **canonical** Robinhood Stock Token for each underlying — a token with a matching name/ticker but a different contract address is not a Robinhood Stock Token.
- It is present in the 2026-08-12 Tavily capture (`_raw/rh-batch1.json`), in the 2026-09-02 capture and in today's MDX, but it was never written into the archived file.
- Restored.
  It is the page's only warning about impostor tokens, which makes it exactly the sentence someone launching on this chain needs.

### Two external pages were captured with unusable code blocks

Both were re-captured from the native-markdown route `<url>.md`, which yesterday's pass had not tried on these hosts.
Source wording is preserved exactly; what changed is capture fidelity.

- `24-chainlink-l2-sequencer-feeds.md`: the 2026-08-12 Tavily extract had stripped identifiers out of the example consumer contract, leaving `import{} from`, `AggregatorV2V3Interface internal;` and `uint256 private constant = 3600;`.
  The whole point of that page is the example contract, and it could not be compiled or even read.
- `25-alchemy-robinhood-quickstart.md`: every code block was duplicated and interleaved with itself (`const  axios =  require(' axios ')`), and all headings and step numbers were flattened away.

### Blockscout explorer snapshot is a dashboard, not a document

- Page: `https://robinhoodchain.blockscout.com/`
- Archived as: `05-blockscout-explorer.md`
- This was on the previous "not verified" list.
  It has now been checked, and the honest verdict is that it cannot be kept current by re-capturing, because its content is live counters.
- Every number in it is stale by construction.
  Against `GET /api/v2/stats` on 2026-09-03: total transactions 355,696,574 to 593,172,267, total addresses 10,567,326 to 18,758,726, ETH price $1,888.94 to $2,508.82.
- The durable parts are all still correct: the host, the nav structure and the `/batches`, `/txs` and `/address/...` URL shapes.
- Deliberately **not** re-snapshotted, since a fresh capture would be equally wrong tomorrow.
  A header note now says this and redirects readers to `32-explorer-and-data-apis.md` and to reading counters live.

---

## Resolving the previous "Known stale or not verified" list

Every item on that list is now closed.

- `05-blockscout-explorer.md` - **resolved as far as it can be.** Content-diffed; it is a live dashboard, see above. Annotated rather than re-captured, with reasoning recorded.
- `10-chainlink-tokenized-equity-feeds.md` - **resolved, unchanged.** The previous pass could not diff it because the feed table renders client-side and Jina returned zero addresses. The native-markdown route `<url>.md` does return the page source, and it carries no feed addresses either: the "Available Robinhood tokenized equity feeds" section is a heading plus one sentence, with the table injected at render time. So the client-side table was never the obstacle to verifying the prose. Every heading, the Total Return Value formula, the multiplier mechanics, the corporate-action and oracle-pause behaviour and the SVR section match the archive word for word.
- `25-alchemy-robinhood-quickstart.md` - **resolved, changed.** See the material-change entry above.
- `09-eip-8056.md` - **resolved, unchanged.** Diffed against the canonical source. Headings, abstract, motivation, specification, rationale, security considerations and copyright all match, modulo straight-versus-curly quotes and the rendered page's own nav and citation block.
- `15-arbitrum-compliance-filtering.md` - **resolved, unchanged.** Re-diffed sentence for sentence and fact for fact against a fresh pull of the moved URL. ArbOS 61 and the 30-day adoption recommendation both stand.
- `24-chainlink-l2-sequencer-feeds.md` - **resolved, changed.** See the material-change entry above.
- The live `contracts` table - **resolved.** Re-pulled, see above.
- `docs.robinhood.com/rhj` not archived - **no longer this file's gap.** It was archived on 2026-09-03 as `36-` through `43-` by a separate pass. Four findings from it were folded into `07-` and `31-`, logged below.

### The EIP-8056 author-change entry can now be completed

The previous entry said the old author list was unrecoverable because the pre-2026-09-02 file had been overwritten.
Today's source does let it be filled in, because the EIP's canonical home is a git repository with full history.

- The EIP now lives at `https://raw.githubusercontent.com/ethereum/ERCs/master/ERCS/erc-8056.md`.
  `ethereum/EIPs/EIPS/eip-8056.md` returns **404**; that is why a raw fetch against the old path fails.
- Commit `554d3467b2` (2026-09-01) is the change the 2026-09-02 agent reacted to.
  - Old value (commit `f141fd92c8`, 2026-06-16 onward): Chris Ridmann (@cridmann) <chris@superstate.co>, Daniel Gretzke (@gretzke), Gilbert Shih <chung.shih@robinhood.com>, Tino Martinez Molina (@tinom9).
  - New value: the same four **plus Markus Osterlund (@robriks) <markus.osterlund@coinbase.com>**.
- The same commit added the optional `UIMultiplierUpdateCancelled` event.
  That is the more substantive half of the change and the 2026-09-02 entry did not mention it.
  The event is present in the archived file, so the capture was correct even though the log was incomplete.
- For completeness, the author list grew steadily: two names at creation (2025-12-04), three from 2026-01-23, four from 2026-02-05, five from 2026-09-01.

---

## Folded in from the `/rhj` pass, verified independently before writing

Four findings were handed over from the sibling `/rhj` archiving pass.
Each was re-verified against the primary source here before being written into a file, and each is recorded as an archive note rather than as source text.

### `07-building-with-stock-tokens.md`: the scheduled-multiplier path is never used in practice

- The page's "Multiplier Updates" section implies corporate actions are scheduled ahead of time and observable on-chain via `newUIMultiplier()` and `effectiveAt()`.
- Verified on 2026-09-03: `https://api.robinhood.com/rhj/corporate-actions` carried 44 cash-dividend actions, 32 of them `IN_PROGRESS`, including actions dated the same day.
  For **all 32**, the matching asset reported `pendingMultiplier: ""`.
  `31-onchain-verification.md` records the same thing on-chain.
- So the pending fields exist in the interface but are effectively never populated, and `/rhj/corporate-actions` is the only forward-looking notice of a corporate action.

### `07-building-with-stock-tokens.md`: the dividend rate does not predict the multiplier delta

- Solving `P = D / delta` against the published rates and the deltas recorded in `31-` gives implied reinvestment prices of 17,933.55 (ASML), 2,401.80 (COST), 1,030.91 (F), 476.96 (AAPL), 144.71 (SGOV) and 6.98 (CCL).
- None are plausible share prices, they are not a constant multiple of one another, and they err in **both** directions, so it is not a flat withholding rate either.
- Recomputed here rather than accepted.
  The CCL row is this pass's addition and is the one that goes the other way, which strengthens the conclusion.
- Recorded with its caveat: this is arithmetic on two published numbers only, and the actual share prices on the relevant dates were not checked.

### `07-building-with-stock-tokens.md`: redemption is not Authorized-Participant-only

- The page says "Direct mint/burn is available only to Authorized Participants / market makers and requires KYB onboarding."
- The issuer's own FAQ contradicts the redemption half, quoted verbatim from the page source in the docsite bundle:
  > Yes. You can sell your Stock Tokens from time to time in the secondary market. You can also redeem them directly with the Issuer, where there is no authorized participant (a firm that processes redemptions on investors' behalf), subject to completing the Issuer's KYC/AML (identity verification) processes.
- Minting is AP-only; redemption is not, and it is gated on KYC/AML rather than KYB.
- The captured sentence was **not** rewritten, since these files preserve source wording; an archive note records the contradiction and names the better authority.

### `31-onchain-verification.md`: the 15:10 UTC accrual cluster has a cause, and `Completed` does not mean adjusted

- For ASML, COST, AAPL, CCL and F, the corporate-action `processDate` maps to the recorded `effectiveAt()` on the **next business day**, verified including the two Friday-to-Monday cases.
- CRWD, ORCL, MU and DELL have `effectiveAt()` timestamps earlier than 2026-08-05, where that feed's rolling window starts, so four of the ten non-unity multipliers have no explanation in it.
  SGOV is a fifth exception for a different reason: it distributes monthly and its 2026-09-01 change does not map to a single action in the window.
- **Seven of the twelve dividends marked `Completed` produced no multiplier change at all.**
  HWM, CTSH, FIX, SIMO, UMC, SHY and BND all return `currentMultiplier` of exactly 1.0.
  The five that moved are AAPL, ASML, CCL, COST and SGOV.
  So `Completed` on that feed is not evidence the token was adjusted, which breaks the obvious reconciliation rule.

---

## Checked on 2026-09-03 and found unchanged

Method: for the 23 bundle-backed pages, the archived body was normalised (MDX frontmatter, JSX tags, code fences and link markup removed, markdown punctuation stripped, whitespace collapsed) and compared sentence by sentence with the page's own MDX source, then a separate pass compared every 40-hex address, URL, email address, version string and number-with-unit as sets.
The same harness was run for the external pages against freshly fetched sources.
Harness: `_raw/docs-audit-2026-09-03b/pagediff.py` and `extdiff.py`; full output in `pagediff.json` and `extdiff.json`.

Diffed against bundle MDX, no content difference:

- `01-overview.md`, including the full ecosystem partner table.
- `02-connecting.md`, all RPC, sequencer and feed endpoints and both chain IDs (4663, 46630). Ratio 1.000.
- `03-add-network-to-wallet.md`.
- `04-bridging.md`. Ratio 1.000.
- `06-stock-tokens.md`, including the RHJ prospectus and US-persons disclaimer.
- `07-building-with-stock-tokens.md` source text, all ERC-8056 interfaces and the multiplier arithmetic. Ratio 1.000. The archive notes added today are additions, not edits to captured prose.
- `08-stock-token-apis.md`, all endpoints, field tables and corporate-action types.
- `12-differences-from-ethereum.md`. Ratio 1.000.
- `13-gas-and-fees.md`. Ratio 1.000.
- `14-transaction-finality.md`. Ratio 1.000.
- `17-protocol-contracts.md`, all L1, L2, gateway and precompile addresses on mainnet and testnet. Ratio 1.000, zero address deltas.
- `18-deploy-smart-contracts.md`, both the Foundry and Hardhat flows and the Blockscout verifier URL. Ratio 1.000.
- `19-account-abstraction.md`, the Alchemy and ZeroDev snippets and the ZeroDev chain-4663 RPC template. Ratio 1.000.
- `20-cross-chain-messaging.md`. Ratio 1.000.
- `21-oracles-and-price-feeds.md` source text, including the `oraclePaused()` guidance. Ratio 1.000.
- `22-data-streams.md`, including the verifier proxy `0xcE73c8ad08CBDEaCa6078BF0627C8fe0a9a536E7`.
- `26-run-a-full-node.md`, including the Database Snapshots section, the two `snapshot-explorer.arbitrum.io` URLs, all six providers, ArbOS 61 and `offchainlabs/nitro-node:v3.11.2-3599aca`.
- `27-governance.md`, including the seat table. Ratio 1.000. It still names Offchain Labs and Alchemy as validator operators, so the tension with the Terms of Service sequencer clause noted on 2026-09-02 still stands and is still not a contradiction.
- `28-notices-and-upgrades.md`. Ratio 1.000. The Notices table is still present and still **empty**, on 2026-08-12, 2026-09-02 and 2026-09-03 alike.
- `29-terms-of-service.md`, whole body. Ratio 1.000, zero sentence deltas after unescaping. `Last Updated` is still August 24, 2026, and the restored line from yesterday is correct.
- `30-report-issue.md`, all three contacts still `chain-developers-group@robinhood.com`. Ratio 1.000.
- `33-brand-guidelines.md`, including `robinhoodchain@robinhood.com`, the Robin Neon value `#ccff00` and the 20px minimum logo height.

Diffed against freshly fetched external sources, no content difference:

- `09-eip-8056.md`, against `ethereum/ERCs`.
- `10-chainlink-tokenized-equity-feeds.md`, against the native-markdown route.
- `15-arbitrum-compliance-filtering.md`, against the native-markdown route.

Diffed against live APIs:

- `11-chainlink-feed-addresses.md`: the directory still lists **57** feeds and all 57 proxy addresses match the archive exactly. None added, none removed since 2026-09-02, so the `CBBTC / USD` addition logged then is still the most recent.
- `16-token-contracts.md`: 194 active tokens, addresses all unchanged. One multiplier moved, logged above.

Not diffable against an upstream document, by design:

- `31-onchain-verification.md` and `32-explorer-and-data-apis.md` are original writing, not captures.
  They were not diffed against a source because there is none; `31-` gained two cross-reference sections today.

### Noise explicitly ruled out, so nobody re-investigates it

Every one of these produced a diff signal and every one is a rendering artefact, not a change.

- JSX import lines and component wrappers that exist in the MDX but never render: `<CardGrid>` and `<Card>` on `01-`, `<AppStoreButtons>` and `<ConnectButton>` on `03-`, `<AssetsTable>` on `16-`, `AssetPrefix` imports on `26-` and `33-`.
- Ordered lists that restart after a code block, so the source's `2.` renders as `1.`. Seen on `03-` and, as noted on 2026-09-02, on `19-`.
- `<ConnectButton>` rendering as the literal text "Loading wallet connection..." in the capture.
- Autolinking by the capture tool: bare `www.adr.org` in the Terms source became `[www.adr.org](http://www.adr.org/)` in the archive, and `https://GlobalStake.io` picked up a lowercase href.
- Relative links resolved to absolute: the `#running-the-node` anchor on `26-`, `/chain/terms-of-service` on `33-`.
- MDX escaping: `\|` inside table cells on `08-`, and `\[`, `\]` and `12\.` in the Terms trademark sections.
- Placeholder tokens inside URLs being read as URLs: `<CONTRACT_ADDRESS>` on `18-`, `<address>` on `08-`.
- Link markup differences that flatten a URL away in one form and not the other, on `22-`.

None of these changed a fact, an address, a number, a contact or a policy, and no file was rewritten for any of them.

---

## 2026-09-03

Discovery: `tvly map` returned 20 URLs, the bundle route table returned 25.
Two of the 25 were not archived, and both are genuinely new since 2026-09-02.

### New page: Lighter Domains

- Page: `https://docs.robinhood.com/chain/lighter-domains`
- Archived as: `34-lighter-domains.md`
- Old value: page did not exist.
  It is absent from `_raw/map-robinhood-2026-09-02.json`, absent from every file in `_raw/jina-2026-09-02/`, and absent from the sidebar captured in `_raw/jina-2026-09-02/terms-of-service.md`.
- New value: a full integration page for the dedicated Lighter perps instance on Robinhood Chain.
  It names the Lighter contract `0x94bAB9693Ba2f6358507eFfcbd372b0660AFfF9d`, the public UI `https://robinhoodchain.lighter.xyz`, the API base `https://api.rh.lighter.xyz/` and the API docs at `https://apidocs.rh.lighter.xyz/docs/get-started`.
  It documents the `deposit(address,uint16,TxTypes.RouteType,uint256)` signature, gives USDG as `_assetIndex = 3` with 6 decimals, and describes a `createIntentAddress` CREATE2 flow for cross-chain deposits plus Fast Withdraw and Secure Withdraw.
- It now appears in the sidebar under **Build**, after Data Streams.
- Raw: `_raw/docs-drift-2026-09-03/mdx/chain_lighter-domains.mdx` and `_raw/docs-drift-2026-09-03/jina-lighter-domains.md`.
- Why it matters here: Lighter was previously only a one-line row in the ecosystem table on the overview page.
  There is now a first-party contract address and a documented deposit path for it.

### New page: Privacy Statements

- Page: `https://docs.robinhood.com/chain/privacy-statements`
- Archived as: `35-privacy-statements.md`
- Old value: page did not exist.
  The string `privacy-statements` appears nowhere in `_raw/jina-2026-09-02/`.
- New value: a link page listing the US, UK and EU privacy and cookie policies.
  It adds two links that Terms of Service section 14 does not carry: the UK cookie policy `https://robinhood.com/gb/en/support/articles/cookie-policy/` and the EU cookie policy `https://robinhood.com/eu/en/support/articles/cookie-policy/`.
- This page is **not in the sidebar** and `tvly map` does not find it.
  It was found only in the bundle route table.
- Raw: `_raw/docs-drift-2026-09-03/mdx/chain_privacy-statements.mdx` and `_raw/docs-drift-2026-09-03/jina-privacy-statements.md`.

### Capture-fidelity fix, not a source change: Terms of Service `Last Updated` line

- Page: `https://docs.robinhood.com/chain/terms-of-service`
- Archived as: `29-terms-of-service.md`
- The source carries `Last Updated: August 24, 2026` as the first line above the title.
  The 2026-09-02 Jina capture recorded it (`_raw/jina-2026-09-02/terms-of-service.md` line 94) but the archived file dropped it.
- The line has been restored to `29-terms-of-service.md` and the capture note there records why.
- The Terms body itself is byte-for-byte unchanged between 2026-09-02 and 2026-09-03, and the `Last Updated` value is still August 24, 2026.
  This is an archive defect that was fixed, not drift in the source.

---

## 2026-09-02

These entries were reconstructed on 2026-09-03 by diffing the surviving 2026-08-12 Tavily captures (`_raw/rh-batch1.json`, `_raw/rh-batch2.json`, `_raw/ext-batch1.json`, `_raw/ext-batch2.json`) against the 2026-09-02 Jina captures and against today's page source.
The 2026-09-02 agent overwrote the pre-existing archived files without writing this log, so these are recovered rather than recorded at the time.

### New page: Brand Guidelines

- Page: `https://docs.robinhood.com/chain/brand-guidelines`
- Archived as: `33-brand-guidelines.md`
- Old value: page did not exist.
  It is absent from `_raw/map-robinhood.json` (2026-08-12), which listed 21 URLs.
- New value: a full brand and co-marketing policy page, including a new dedicated contact address `robinhoodchain@robinhood.com` for brand misuse reports, the Robin Neon colour value `#ccff00`, a 20px minimum logo height, and prohibitions on "Hood Chain", on "tokenized stocks" and "tokenized equities" as terms for Stock Tokens, on referencing `$HOOD`, and on tagging `@RobinhoodApp`.
- It landed at the same time as the new trademark sections in the Terms of Service, which cross-reference it.

### Terms of Service: the sequencer operator changed from Offchain Labs to Robinhood

This is the most consequential change in the whole archive and it is a change of fact, not of wording.

- Page: `https://docs.robinhood.com/chain/terms-of-service`, the "The Sequencer" bullet under section 2.1 "The Services"
- Archived as: `29-terms-of-service.md`
- Old value (2026-08-12, `_raw/rh-batch2.json`):
  > OCL operates the sequencer on behalf of Robinhood. The sequencer node receives, records, and reports transactions on Robinhood Chain (the "Robinhood Chain Sequencer"). The Robinhood Chain Sequencer is non-custodial ...
- New value (2026-09-02, still current 2026-09-03):
  > Robinhood operates a sequencer node that receives, records, and reports transactions on Robinhood Chain (the "Robinhood Chain Sequencer"). The Robinhood Sequencer is non-custodial ...
- The named third-party operator (OCL, Offchain Labs) was removed and the operator is now Robinhood itself.
- Note the tension with `27-governance.md`, which still says the chain has two validators operated by Offchain Labs and Alchemy.
  Validator operation and sequencer operation are separate roles, so the two statements are not strictly contradictory, but anyone citing "who runs Robinhood Chain" should quote both.
- Raw: `_raw/rh-batch2.json` for the old text, `_raw/jina-2026-09-02/terms-of-service.md` and `_raw/docs-drift-2026-09-03/mdx/chain_terms-of-service.mdx` for the new.

### Terms of Service: a full trademark licence and an arbitration carve-out were added

- Page: `https://docs.robinhood.com/chain/terms-of-service`
- Old value (2026-08-12): the document contained no sections 5.5 through 5.13, no section 12.14, and no `robinhoodchain@robinhood.com` address.
  The document grew by roughly 60 percent: the 2026-08-12 Tavily extract is 49,992 characters and today's MDX source is 80,107.
  Those are two different capture formats, so treat the ratio as indicative rather than exact.
- New value: sections 5.5 through 5.13 grant a limited licence to the Robinhood Chain Marks with pre-approved uses ("Our dApp is deployed on Robinhood Chain", "[Your Brand] - Powered by Robinhood Chain") and a defined "Misleading Use", and section 12.14 carves trademark, trade dress, copyright, trade secret and injunctive-relief claims out of the mandatory arbitration agreement so Robinhood can pursue them in court.
  Section 17 adds `robinhoodchain@robinhood.com`, Attn: Robinhood Chain Brand Team, as the contact for mark authorisation requests and misuse reports.
- Practical effect for anyone launching on this chain: the previously informal use of the Robinhood Chain name in a token, project or marketing copy is now governed by a written licence, NFT and token metadata use of the marks is expressly prohibited, and enforcement is expressly not arbitrable.
- The `Last Updated` value on the current page is August 24, 2026.
  The 2026-08-12 Tavily extract stripped that header line, so the previous value is not recoverable from the archive.

### Run a full node: Database Snapshots section added, GlobalStake added to providers

- Page: `https://docs.robinhood.com/chain/run-a-full-node`
- Archived as: `26-run-a-full-node.md`
- Old value (2026-08-12): no "Database Snapshots" section at all.
  The only snapshot mention was one inline sentence under faster sync, and the third-party provider table listed Quicknode, Blockdaemon, dRPC, Validation Cloud and Chainstack.
- New value: a "Database Snapshots" section pointing at `https://snapshot-explorer.arbitrum.io/?chain=Robinhood+Chain` for mainnet and `https://snapshot-explorer.arbitrum.io/?chain=Robinhood+Chain+Sepolia` for testnet, stating that published snapshots are pruned full-node snapshots and that **archive nodes must sync from scratch**.
  GlobalStake (`https://GlobalStake.io`) was added as a sixth provider.
- ArbOS 61 and `offchainlabs/nitro-node:v3.11.2-3599aca` are unchanged from 2026-08-12 through 2026-09-03.
- Raw: `_raw/rh-batch2.json` for the old text, `_raw/docs-drift-2026-09-03/mdx/chain_run-a-full-node.mdx` for the new.

### Token contracts: the Stock Token roster grew from 96 to 194

- Page: `https://docs.robinhood.com/chain/contracts` (the table renders live from the on-chain asset registry, so this is a registry change rather than a docs edit)
- Archived as: `16-token-contracts.md`
- Old value: 96 active Stock Tokens at the 2026-08-12 capture.
- New value: 194 active Stock Tokens at block 52,437,900 on 2026-09-02.
- The two base tokens on the page are unchanged: WETH `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73` and USDG `0x5fc5360D0400a0Fd4f2af552ADD042D716F1d168`.
- Raw: `_raw/rhj-assets-2026-09-02.json`, `_raw/onchain-tokens-2026-09-02.json`.

### Chainlink feeds: 56 to 57, one addition

- Page: `https://docs.chain.link/data-feeds/price-feeds/addresses?network=robinhood`, backed by `https://reference-data-directory.vercel.app/feeds-robinhood-mainnet.json`
- Archived as: `11-chainlink-feed-addresses.md`
- Old value: 56 feeds on 2026-08-12.
- New value: 57 feeds on 2026-09-02.
  The one addition is `CBBTC / USD`; no feed was removed and the 35 equity feeds are unchanged.
- Because the roster grew to 194 Stock Tokens while equity feeds stayed at 35, 159 Stock Tokens now have no Chainlink feed.
- Raw: `_raw/chainlink-feeds-robinhood-mainnet-2026-09-02.json`.

### EIP-8056: author list changed

- Page: `https://eips.ethereum.org/EIPS/eip-8056`
- Archived as: `09-eip-8056.md`
- The 2026-09-02 agent refreshed this page because the author list changed.
  It did not record the old author list and the 2026-08-12 file was overwritten, so the specific names added or removed are not recoverable from this archive.
  Flagging this as an incomplete entry rather than inventing values.

### Arbitrum compliance filtering: the page moved and the old URL now 404s

- Old URL (archived 2026-08-12): `https://docs.arbitrum.io/launch-arbitrum-chain/configure-your-chain/advanced/compliance-filtering`, now 404.
- New URL: `https://docs.arbitrum.io/launch-arbitrum-chain/chain-config/sequencer/compliance-filtering`, confirmed 200 on 2026-09-03.
- Archived as: `15-arbitrum-compliance-filtering.md`, which records both URLs.

---

## Checked on 2026-09-03 (first pass) and found materially unchanged

**Superseded by the `2026-09-03 full audit` section at the top of this file**, which re-diffed every page including the ones this pass skipped.
Kept for the record; nothing in it was contradicted.

Method: the archived body of each file was normalised (links flattened, markdown punctuation stripped, whitespace collapsed) and diffed sentence by sentence against the live page source extracted from the bundle, then a separate pass diffed every 40-hex address, URL, email address and number-with-unit on each page.
Everything below produced only formatting differences: bullet markers rendered as `*` versus `-`, table alignment colons, code-fence language tags that the renderer drops, and JSX wrappers such as `<CardGrid>` and inline `<div style=...>` that do not exist in the rendered text.

- `01-overview.md`, including the full 16-row ecosystem partner table, which is identical row for row.
- `02-connecting.md`, all RPC, sequencer and feed endpoints and both chain IDs (4663, 46630).
- `03-add-network-to-wallet.md`.
- `04-bridging.md`, which diffed at ratio 1.000.
- `06-stock-tokens.md`, including the RHJ prospectus and US-persons disclaimer, unchanged since 2026-08-12.
- `07-building-with-stock-tokens.md`, all ERC-8056 interfaces and the multiplier arithmetic.
- `08-stock-token-apis.md`, all endpoints, field tables and corporate-action types.
- `12-differences-from-ethereum.md`.
- `13-gas-and-fees.md`.
- `14-transaction-finality.md`.
- `17-protocol-contracts.md`, all 30-plus L1, L2, gateway and precompile addresses on mainnet and testnet, byte for byte.
- `18-deploy-smart-contracts.md`, both the Foundry and Hardhat flows and the Blockscout verifier URL.
- `19-account-abstraction.md`, the Alchemy and ZeroDev snippets and the ZeroDev chain-4663 RPC template.
- `20-cross-chain-messaging.md`.
- `21-oracles-and-price-feeds.md`, including the sequencer-uptime and `oraclePaused()` guidance.
- `22-data-streams.md`, including the verifier proxy `0xcE73c8ad08CBDEaCa6078BF0627C8fe0a9a536E7`.
- `27-governance.md`, including the seat table.
- `28-notices-and-upgrades.md`.
  The Notices table is still present and still **empty**, on 2026-08-12, 2026-09-02 and 2026-09-03 alike.
- `29-terms-of-service.md` body, unchanged since 2026-09-02.
- `30-report-issue.md`, all three contacts still `chain-developers-group@robinhood.com`.
- `33-brand-guidelines.md`, unchanged since it was captured on 2026-09-02.

No archived page 404s.
All 30 `> Source:` URLs were requested on 2026-09-03: the 24 `docs.robinhood.com/chain` URLs return 301 to their trailing-slash form, which is this site's normal behaviour, and the six external URLs return 200.
Status log: `_raw/docs-drift-2026-09-03/source-url-status.txt`.

One cosmetic non-change worth naming so nobody re-investigates it: on `account-abstraction`, the fourth Alchemy step is numbered `4.` in the current MDX source and rendered as `1.` in the 2026-09-02 capture, because the ordered list restarts after a code block.
The archived file preserves the rendered `1.`.
No content differs.

---

## Known stale or not verified (as of the 2026-09-03 first pass)

**Every item below is now closed.**
See "Resolving the previous \"Known stale or not verified\" list" in the `2026-09-03 full audit` section at the top of this file.
Kept here so the two passes can be read against each other.

- `05-blockscout-explorer.md`, `10-chainlink-tokenized-equity-feeds.md` and `25-alchemy-robinhood-quickstart.md` are still the 2026-08-12 Tavily captures.
  They were confirmed reachable (HTTP 200) on 2026-09-03 but their **content was not diffed**, so they may be stale.
  They were not edited.
- The Chainlink tokenized-equity page renders its feed table client-side and a Jina fetch on 2026-09-03 returned zero addresses, so no content diff was possible from that route.
  Use `https://reference-data-directory.vercel.app/feeds-robinhood-mainnet.json` for that comparison instead, as `11-chainlink-feed-addresses.md` already does.
- `09-eip-8056.md`, `15-arbitrum-compliance-filtering.md` and `24-chainlink-l2-sequencer-feeds.md` were not re-diffed against their sources on 2026-09-03; only their HTTP status was checked.
- The live table on `https://docs.robinhood.com/chain/contracts` was not re-pulled on 2026-09-03.
  The roster count in `16-token-contracts.md` is a 2026-09-02 snapshot at block 52,437,900 and will drift; treat the addresses as canonical and the counts and supplies as point-in-time.
- The sibling documentation space `docs.robinhood.com/rhj` is **not archived at all**.
  The bundle route table lists eight pages there: `/rhj`, `/rhj/corporate-actions`, `/rhj/price-deviations`, `/rhj/faq`, `/rhj/product`, `/rhj/service-providers`, `/rhj/restricted-jurisdictions` and `/rhj/use-of-website`.
  The Stock Tokens disclaimer and the Terms of Service both point at it, and `corporate-actions` and `price-deviations` bear directly on the ERC-8056 multiplier behaviour documented in `07-building-with-stock-tokens.md`.
  This is the largest known gap in the archive.
