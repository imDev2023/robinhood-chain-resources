# Flap session notes, section 5.7

Session E, "Flap".
Ran 2026-09-02 into 2026-09-03.
Written for the coordinating session to merge into `SCRAPING-PLAN.md` and `PLAYBOOK.md`, which this session did not touch.

## 1. Row for `SCRAPING-PLAN.md` part 4.4

Replace the existing `flap` row with:

| Slug | Raw captures | pages/ | screenshots/ | contracts/ | socials/ | LINKS.md | README.md | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `flap` | 1,974 raw files: all 59 docs pages as GitBook markdown, 3 GitHub clones, Blockscout address and contract dumps, 10 board API pulls plus a fresh 200-row paginated pull, 7 agent-browser reads, 11 RPC state dumps, 5 decoded launch calls, 2 traced fee transactions, X syndication timeline, DefiLlama chain fees | 74 | 18 | 39 dirs (24 verified, 15 bytecode) | 5 | yes, 314 rows | yes | **Done 2026-09-03** |

## 2. Findings block for section 5.7

Add under the `### 5.7 Flap` entry:

**Done 2026-09-03.** Findings a later session should not have to rediscover.

- **Flap is not Doppler-derived.** The indexer check in playbook section 1 returns `totalCount: 0` for the FeeSafe, the Portal and the Sinjoh adapter as integrators. It is its own stack: a constant-product bonding curve plus a Uniswap V2 fork migration, no Airlock, no v4 hooks.
- **The archive's contract directory names were wrong in two places.** `FlapCore-0x26605f32...` is the **Portal**, the single entry point. `Portal-0xd35e36Df...` is **not** a Flap contract at all, it is a `SinjohFlapAdapter` clone, a third-party launcher for one token. Both directories were kept under their old names so earlier captures still resolve, and both now say so in their `README.md` and in `ADDRESSES.md`.
- **No launch fee, no minimum, no LP to seed.** Two of five decoded launches sent `msg.value = 0`. The app quotes "Deploy cost: around 0.001 ETH", which is gas.
- **The curve is calibrated to exactly 5 ETH and exactly 13x.** `(x+h)(y+r)=K` with r 1.9189797, h 107,036,752, K 2,124,381,054.2419344 puts graduation at 800M sold and **exactly 5.000000 ETH** of reserve. Opening FDV 1.733438 ETH, graduation FDV 22.534695 ETH, a **13.0000x** multiple. The HOODon curve is also exactly 13.0000x (89.285714 HOODon). Every quote asset is tuned to the same multiple.
- **Fees: 1% each way on the curve, all of it to Flap.** `Portal.getFeeRate()` returns `(100, 100)`. Traced on a real buy: a 37053982898397 wei buy sent exactly 1% to the FeeSafe in the same transaction. The creator gets none of it.
- **The creator of a non-tax token earns nothing on this chain.** Migration is V2-only and the LP is burned: 99.93% of the `$moon` pair's LP sits at the dead address, and `getLocks` returns zeros. `Portal.claim()` exists and is documented as LP-fee revenue share, but there is nothing to claim.
- **A tax token keeps 96.4% of its tax.** Flap takes 3% of the tax (`feeConfigV2().feeRate = 300`) and a launcher commission takes up to 0.6% (`commissionBps = 60`). The docs' "up to 0.3% of trade volume" is the same number: 3% of a maximum 10% tax.
- **Unallocated tax silently becomes Flap's.** `TaxProcessorBase._processFeeQuote` ends with `if (distributed < remaining) fee += remaining - distributed;`. The app validates that the four creator buckets total 100%, but the contract does not.
- **The docs are wrong about quote assets.** The Robinhood integration guide says native ETH is the only enabled quote token. On chain, `getQuoteTokenConfiguration` returns `enabled = 1` for **26** assets: ETH, HOODon and 24 tokenized stocks. 24 of the 200 tokens on the board are quoted in something other than ETH. Flap announced the change on X on 2026-08-27.
- **The docs' version label is stale.** They say Portal `v5.14.16`; `Portal.version()` returns **`v5.21.2`**. The `CurveType` enum in the verified `IPortal.sol` stops at index 24 while ETH's live curve is index 25 and stock curves run to 82, so the published interface is behind the deployment. Read `getTokenV8Safe`, never hardcode.
- **Governance is two Safes with no timelock.** ProxyAdmin `0x21f7f9b3...` upgrades the Portal, VaultPortal, SwapRegistry and TaxTokenHelper; it is owned by Safe `0xc68f29bf...`, **2 of 5**. The FeeSafe `0xa4A727E0...` is **2 of 3**, receives every fee, and holds the Portal's `DEFAULT_ADMIN_ROLE`. Two owners are common to both Safes. The Portal custodies every live curve's reserve.
- **Graduation is vanishingly rare.** `FlapCurvePairFactory.allPairsLength()` is **173,798**, one curve pair per token ever launched. Two independent 3,000-item samples put graduated tokens at roughly **116 to 364**, that is 0.07% to 0.21%.
- **The Portal implementation and its three dispatch modules are unverified.** Everything about the Portal here came from a PUSH4 selector scan resolved through openchain, plus `IPortal.sol` which ships verified inside `VaultPortalImpl`, plus decoded production calldata and traced transactions.
- **Launching on top of Flap is permissionless.** `SinjohFlapAdapterFactory` deploys wrappers around `Portal.newTokenV6` that take the commission slot, and `IOO.fun` branding appears on live bonding tokens. Vault factories are permissionless too, and the app builds the vault config form from an on-chain schema.
- **The backend is `batman.taxed.fun/v3/`, Cloudflare-fronted, and capped.** `limit` is silently clamped to 20 and `nextCursor` dies after 10 pages, so the board yields at most 200 rows. Ecosystem totals must come from the chain.
- **DefiLlama `flap-sh` on this chain**: $1,148,449 all-time fees on 2026-09-03, which is **8th among launchpads on Robinhood Chain**, behind Pons V2, Pons V1, NOXA Fun, StonkBrokers, LetsCash, Pools and o1, and ahead of Bags.

## 3. Additions for `PLAYBOOK.md`

For section 2, docs capture:

- GitBook sitemaps can live under the space path, not the domain root. `docs.flap.sh/sitemap-pages.xml` is a redirect stub; the real list is at **`docs.flap.sh/flap/sitemap-pages.xml`**, reached via `docs.flap.sh/flap/sitemap.xml`. Try `<domain>/<space>/sitemap.xml` before concluding a GitBook site has no sitemap.

For section 3, ecosystem numbers, a non-Doppler equivalent:

- On a launchpad with its own curve-pair factory, `allPairsLength()` on that factory is an exact launch count, and a `graduated()` view on the pair is a one-call graduation test. Sampling that view over evenly spaced indices through **Multicall3 `aggregate3` at `0xcA11bde05977b3631167028862bE2a173976CA11`** gives a graduation rate in two round trips instead of a log scan. Cross-check it from the destination side by sampling the DEX factory's pairs for the launchpad's vanity suffix. Both worked on Flap and agreed within a factor of three.

For section 4, contracts:

- **An unverified implementation is not a dead end.** A PUSH4 scan of the runtime bytecode plus `https://api.openchain.xyz/signature-database/v1/lookup?function=0x...` named 96 of the Portal's selectors, which is what made the whole Flap economics section possible. Reusable at `launchpads/flap/_raw/tools/mkcontract.py`, which builds a full contract directory (address, metadata, sources or bytecode, selectors, decoded selectors) from two Blockscout calls and one `eth_getCode`.
- **When the entry point is unverified, look for its interface inside a verified sibling.** Flap's `VaultPortalImpl` and `TaxProcessorUniV2Impl` both ship `src/interfaces/IPortal.sol`, which carries every struct and enum the unverified Portal takes. That, not the docs, is the authoritative ABI.
- **Read the EIP-1967 admin slot, not just the implementation slot.** `keccak256("eip1967.proxy.admin") - 1` then `owner()` on the ProxyAdmin then `getOwners()` and `getThreshold()` on the Safe answers "who can replace the contract holding user funds" in three calls. It found a 2-of-5 with no timelock over Flap's Portal, which no document mentions.
- Beware the near-miss constant: the EIP-1967 admin slot is **`0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103`**. A commonly copy-pasted variant ending `...0000000000c103` is wrong and silently returns the zero address.

For section 6, environment gotchas:

- `agent-browser screenshot` needs an **absolute** output path. A relative one fails with `No such file or directory (os error 2)` even when the directory exists.
- `agent-browser wait --time <ms>` is unreliable on this app: it reported `Wait timed out after 25000ms` on every call while the page had in fact updated. Ignore that specific failure and re-snapshot; `wait --load networkidle` is fine.
- `flap.sh` keys the active chain off a URL prefix (`/robinhood/board`) and remembers it, but prefixed routes exist only for some pages: `/robinhood/create` is a 404 while `/create` renders in whatever chain is remembered. Visit a prefixed route first to set the chain, then the unprefixed one. The `/prelaunch` page's own network selector does not follow the switcher at all.
- Launchpad backends behind Cloudflare need the same browser User-Agent trick as Blockscout. `batman.taxed.fun` returns an interstitial without one and clean JSON with one.

For section 9, Bright Data:

- Confirms the existing note: 6 status URLs submitted to `bdata pipelines x_posts`, 1 record returned. The syndication endpoint returned all 20 posts in one request and is strictly better for a timeline.

## 4. Definition of done, part 8 check

| requirement | state |
| --- | --- |
| Every URL from `launchpad-research.md` for the platform is in `LINKS.md` with a capture path | yes, `https://flap.sh/` and `https://docs.flap.sh/flap` and every docs page |
| Every internal link visited and has a real `pages/` file | yes, 59 of 59 docs pages from `docs.flap.sh/flap/sitemap-pages.xml`, plus 15 app views |
| Every contract in the launch path has a directory and is in `ADDRESSES.md` | yes, 39 dirs, 24 with verified sources, 15 with bytecode plus decoded selectors, each with a `README.md` |
| `README.md` has all nine sections, numbers cite a file, Gaps is honest | yes, 10 gaps recorded |
| agent-browser session closed | yes, `lp-flap` closed by name. `default` and `glumbo` belong to other sessions and were not touched |
| Part 4.4 updated | **not done by this session**, deliberately: two sibling sessions were running. The row is in section 1 above for the coordinator to merge |

Playbook section 8 extras:

- Every `pages/NN-slug.md` reference in `README.md` and `LINKS.md` resolves to a real file. Checked with the playbook one-liner, no misses.
- All 18 screenshots are referenced by at least one page.
- `onesentence.py` was run on `README.md`, `LINKS.md`, `contracts/ADDRESSES.md`, all 5 `socials/` files and all 39 contract `README.md` files. A copy lives at `_raw/tools/onesentence.py`.
- **Dash check:** no em dash or en dash in any authored prose. Two remain in `LINKS.md` and six in `socials/02-x-flapdotsh-posts.md`, all inside verbatim third-party text (a GitBook page title and quoted X posts). They were left alone rather than falsifying a capture.

## 5. What changed on disk, and one thing to be aware of

- **`pages/` was renumbered.** The directory had two files numbered `10`. The 59 docs pages were shifted from `10..68` to `11..69`, `_raw/docs/pages-index.tsv` was rewritten to match, and app pages now occupy `01..10` and `70..74`. Nothing outside this directory referenced the old numbers.
- **`screenshots/10-create-tax-token.png` was renamed** to `10-board-robinhood-hero.png`. The original capture was of the board, not the tax form; the real tax form is `12-create-tax-token-robinhood.png`.
- **`pages/09` and `pages/10` were rewritten.** Both were previously incomplete: 09 stopped before the payment-token list, 10 had captured the board instead of the form.
- **`contracts/DividendClaimHelperImpl-.../metadata.json` was a zero-byte file** and was rebuilt.

New this session: `pages/70` to `74`, `screenshots/11` to `18`, all of `socials/`, `contracts/ADDRESSES.md`, 39 contract `README.md` files, 8 new contract directories, `LINKS.md`, `README.md`, `_raw/rpc/` (11 files), `_raw/decoded/`, `_raw/ab/`, `_raw/llama/`, `_raw/tools/` (rpc.py, mkcontract.py, mkcontract_readme.py, mklinks.py, mkaddresses.py, onesentence.py), `_raw/docs/sitemap-pages.xml`, `_raw/api/board-all-createdAt-desc.jsonl`, `_raw/socials/x-syndication-*`.

## 6. Session log

1. Read `PLAYBOOK.md` in full including section 9, then `SCRAPING-PLAN.md` sections 0 to 5.7 and part 8.
2. Ran the part 4.3 inventory. Found the archive already had 69 pages, 10 screenshots, 30 contract dirs and 1,931 raw files, with socials, links and README outstanding, matching the status table.
3. Ran the playbook section 1 Doppler check against three candidate integrator addresses. All zero, so `doppler/` and `long/` were not read and not touched.
4. Read the docs that carry the economics, then went to the chain for everything the docs did not state or stated wrongly: Portal config, quote-token config for 27 assets, a live TaxProcessor, LP ownership on a graduated pair, proxy admin slots, both Safes, the Sinjoh adapter, and two Multicall3 graduation samples.
5. Decoded 5 real launch calls from `_raw/blockscout/portal-txs.json` and traced 2 transactions for the fee routing.
6. Opened `agent-browser` session `lp-flap` at viewport 1440x2200 and captured the two create forms, the vault picker, the IndexVault config, the prelaunch page, the CA store, a bonding-phase token and its tax-info page. 8 new screenshots, 7 new page files.
7. Wrote `socials/`, then the contract tooling, then 39 contract READMEs, `ADDRESSES.md`, `LINKS.md` and `README.md`.
8. Hit the account session limit partway through and was relaunched after the reset. Nothing captured was lost and nothing was recaptured.
9. Closed `lp-flap` by name. Confirmed only `default` and `glumbo`, which belong to other sessions, remain.

## 7. What is left

Nothing blocking.
Section 5.7's definition of done is met.

Open items, all recorded in `README.md` section 9 and none of which change a number:

- No wallet was connected, so the launch confirmation modal and the post-launch creator dashboard were not seen. The shared test wallet was not needed.
- No graduation was watched live, so the roughly 11% step from the last curve price to the opening pool price is arithmetic rather than a measurement.
- The graduation count is a sample (116 to 364), not a census. An exact figure needs a log scan of the migration event.
- Discord and Farcaster did not render for Jina or Bright Data, so no member counts.
- The site footer's `Terms and Conditions` and `Contact Us` are in `LINKS.md` but were not fetched.
- The `/prelaunch` page shows `BNB` as the network after the header is switched to Robinhood. Testing whether that is cosmetic costs the 0.003 ETH salt lock fee, so it was left alone.
