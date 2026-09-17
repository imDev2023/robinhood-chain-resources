# Sentry session notes, for the coordinating session to merge

Session D, Sentry.
Started 2026-09-02, finished 2026-09-03.
Ran in parallel with Flap and HOOD10, so `SCRAPING-PLAN.md` and `PLAYBOOK.md` were not touched.
Everything below is written here for the merge, exactly as playbook section 7 requires.

## 1. Row for `SCRAPING-PLAN.md` part 4.4

Replace the existing `sentry` row with this one.

| Slug | Raw captures | pages/ | screenshots/ | contracts/ | socials/ | LINKS.md | README.md | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `sentry` | 619 raw files: Jina, Bright Data, Tavily, 139 Blockscout smart-contract records and 4 decoded production launches, live `eth_call` state dumps, Goldsky subgraph pulls, the app's own backend API captures, an authenticated agent-browser session, X syndication | 81 | 45 | 54 dirs (49 with verified sources, 5 bytecode only) | 10 | yes, 1,027 rows | yes | **Done** 2026-09-03 |

Total files in `resources/launchpads/sentry/`: 1,646.

## 2. Findings block for the `sentry` entry under part 5

- **Not Doppler-derived.** `indexer-prod.doppler.lol` returns `totalCount: 0` for the Sentry deployer, the treasury splitter, the WETH launch factory and the SENTRY token, against 109,757 Doppler assets on chain 4663 in the same query. Sentry runs its own factories and its own Uniswap v4 hooks and never touches an Airlock.
- **No bonding curve and no graduation.** 100 percent of a fixed 1,000,000,000 supply goes straight into a Uniswap v4 pool, the position is locked in an immutable vault with no withdrawal function, and trading opens in the same transaction. The pool created at launch is the final pool. This is the structural difference from every other launchpad in the archive.
- **Launching is free; the fee curve is the business model.** Every pool opens at 40 percent (`startFee` 400000 pips) and decays with a 180-second hold and a 180-second half life to a permanent 1.7 percent floor (`endFee` 17000), about seventeen minutes in. Read from the hooks, not the docs.
- **Creator share, at the floor, read on chain**: a plain WETH launch pays the creator 1.00 percent of every trade (5882 bps of the fee), 0.20 percent into locked liquidity, 0.50 percent to the protocol. A reflections or stock-paired launch pays 0.50 percent creator, 0.80 percent holder reflections, 0.20 percent liquidity, 0.20 percent protocol. Settled inside each swap, so there is nothing to collect.
- **The legacy split is 70/30, not 65/35.** `creatorFeeBps()` returns 7000 on both v4 factories, on the retired V3 factory and on the LP vault. DefiLlama still describes Sentry as a Uniswap V3 launchpad splitting 65/35, which is two revisions out of date on both counts.
- **The whitelist is a fee exemption, not early access.** From the hook source: matched on `tx.origin` so it survives any router, applied on buys only, frozen before pool initialisation.
- **Registry trap.** `hook()` on the stock factory returns `SentryDynamicFeeHook 0x3b778ccf...`, which serves nothing that is registered; every live stock pool uses `baseTokenToHook(baseToken)` which returns `0x5DaA88b6...`. Reading the factory-level default alone gives the wrong hook.
- **The stock picker is a curated subset.** The Create form offers 19 tokenised stocks and ETFs; `getSupportedBaseTokens()` on the stock factory returns 88.
- **Upgrade risk sits in one EOA.** `0xbF551eED83c7eaEE63854a2013Eb94f18600B7C5` is `owner()` of both v4 factories, of the legacy factory and of the treasury splitter, and `admin()` of the LP vault, and both v4 factories are transparent proxies behind it. The hooks and the vault are not upgradeable and the vault has no withdrawal path, so locked liquidity is locked even against that key.
- **SENTRY's own pool carries an undocumented 80 percent early-exit fee** (`earlyExitFee` 800000 pips) charged to sellers still inside the migration lock, buys never. The migration unlock was extended from 2026-08-03 to 2026-10-03 by an on-chain holder vote (291.9M yes against 70.4M no, `extensionPassing() = true`). Neither the vote nor the exit fee appears in the guide.
- **Ecosystem is one token deep.** 185 launches, 56,780 swaps, 12,962 WETH of lifetime volume, 30.63 WETH paid to creators. CHILL alone is 10,698 WETH, 83 percent of everything. The median launch has done under 0.06 WETH of volume in its life. 73 of the 185 launches happened in the 30 days to 2026-09-02.
- **Sentry and Quotrons are the same company, different products.** Both footers read `a product of Mavrk, Inc.`; the SENTRY token's `founder()` is `0x7171E64E...`, the same EOA that deployed every Quotron contract. Quotrons is not a launchpad and does not launch other people's tokens.
- **Gaps**: no audit and no public source repo; the Ink half is documented but never read on chain; creator bundle tools are allowlisted per account and stayed closed; the guide's own live-stats panel renders empty; X syndication returns nothing for @sentrylauncher or @cruelhandeth.

## 3. Additions for `PLAYBOOK.md`

These are new since the section 9 that exists today.
Merge them wherever they fit best.

### The `headless-wallet` skill replaces the hand-rolled harness

Playbook section 5 recommends `@ensdomains/headless-web3-provider` with a real Playwright `Page`.
There is now a skill, `~/.claude/skills/headless-wallet`, whose tier 0 observer needs **no npm install and no Playwright**, and works directly with the `agent-browser` CLI:

```bash
S=~/.claude/skills/headless-wallet/scripts
node $S/make-observer.mjs --chain 4663 --address <test wallet> --out ./hw-observer.js
agent-browser open <url> --init-script "$(pwd)/hw-observer.js"
```

It announces over EIP-6963 four times so late-mounting React pickers still see it, forwards reads to the chain, parks signature challenges on `window.__HW.pending`, and records then rejects every `eth_sendTransaction` into `window.__HW.capture`.
This opened Sentry's wallet login on the first attempt and reached the gated Create form.
`node $S/chains.mjs resolve 4663 --verify` resolves and probes Robinhood Chain RPCs without any config.

### SIWE challenges can be signed outside the page with `eth_account`

The classifier concern recorded in playbook section 6 did not materialise here.
`eth_account` 0.13.7 is already installed and signs a parked `personal_sign` challenge in six lines, reading the key inside the script and printing only the signature:

```python
from eth_account import Account
from eth_account.messages import encode_defunct
sig = Account.sign_message(encode_defunct(bytes.fromhex(msg_hex[2:])), private_key=key)
```

Reusable copy: `sentry/_raw/tools/sign-siwe.py`.
The whole loop, from opening the picker to being signed in, is: click Connect wallet, click the announced wallet, read `window.__HW.pending.params[0]`, sign it, call `window.__HW.provide(id, sig)`.
Sentry's challenge expires five minutes after issue, so re-trigger it immediately before signing rather than reusing an old one.

### agent-browser gotchas that cost time on this platform

- **`agent-browser screenshot` needs an absolute path.** A relative path fails with `No such file or directory (os error 2)` even though the CLI reports the command started. Same class of trap as `bdata scrape -f screenshot` in section 9.
- **`open` then `read` in two separate Bash calls can read the wrong page.** The SPA finishes routing after the first call returns, and the second call read a stale tab. Chaining `agent-browser open <url> >/dev/null && agent-browser read > out.txt` inside one Bash call fixed it. `wait --load networkidle` did not.
- **Sticky headers make refs unclickable.** Half the header buttons returned `Element '@eN' is covered by <div...>`, and `--force` did not help. `agent-browser eval` with a `querySelectorAll` text or aria-label match clicked every one of them.
- **`agent-browser eval` shares one page context across calls**, so `const x = ...` in a second call throws `Identifier 'x' has already been declared`. Wrap every eval in `(() => { ... })()`.

### The X syndication endpoint is per-account, not universal

Playbook section 9 records the syndication endpoint as a general fallback.
On this platform it returned a full 20-post timeline for `@quotrons404` and `{"entries": []}` with `hasResults: true` for `@sentrylauncher` and `@cruelhandeth`.
Check the entries array rather than the byte count: the empty response is still a valid 2.2 KB page.

### Products that publish their own machine-readable docs

Sentry serves its entire user guide as one markdown file at `https://sentry.trading/sentry-guide.md`, written explicitly to be handed to an AI assistant, and Quotrons serves `llms.txt`, `llms-full.txt`, an `integration.md` and four ABI JSON files under `/integration/`.
Before crawling a launchpad's app, try `<host>/llms.txt`, `<host>/llms-full.txt` and `<host>/<product>-guide.md`.
It is worth checking even when the site is a SPA with no docs subdomain.
Treat these as the vendor's claims, not as facts: every number in this archive was re-read from the chain, and the guide's own address list, the DefiLlama record and the app's stock picker each disagreed with the chain in at least one place.

### Blockscout addendum

`smart-contracts/<addr>` can return a name and an ABI for an address that `addresses/<addr>` reports as `is_verified: false`, because it matches a verified twin by bytecode.
Take the verification flag from the `addresses` response and the sources from `smart-contracts`, not both from one.

## 4. Session log

1. Read `PLAYBOOK.md` in full including section 9, then `SCRAPING-PLAN.md` sections 0 to 4 and 5.6 and 8.
2. Ran the section 4.3 inventory: 536 raw files, 32 screenshots, no pages, contracts, socials, LINKS or README.
3. Ran the playbook section 1 Doppler check against four Sentry addresses. All zero, so `doppler/` and `long/` were never opened and never touched.
4. Read the existing raw captures, found the official `sentry-guide.md`, the Blockscout dumps and four decoded production launches already on disk.
5. Fetched the twelve Blockscout records that were missing (both factory implementations, the current stock hook, the position manager, the treasury Safe, the relaunch launcher, the V3 router, three example launch tokens, two stock base tokens).
6. Read live state off 12 contracts with `eth_call`, into `_raw/rpc/derived-*.txt`. This is where the fee legs, the 70/30 split, the 88 base tokens, the pool keys and the SENTRY vote came from.
7. Pulled the public Goldsky subgraph for the ecosystem numbers.
8. Opened `lp-sentry` in agent-browser, confirmed the logged-out redirects, captured the network switcher and the three-way login picker.
9. Injected the tier 0 headless wallet, signed the SIWE challenge outside the page with the shared test wallet, and captured the gated Create form, the stock picker, Profile, Tools and Settings. No transaction was produced and nothing was broadcast.
10. Closed `lp-sentry` by name. `agent-browser session list` then showed `lp-flap`, which belongs to the sibling session and was left alone.
11.
Hit the account session limit here.
Resumed after the reset with everything still on disk.
12.
Generated `contracts/` (54 dirs), `pages/` (81), `socials/` (10), `contracts/ADDRESSES.md`, `LINKS.md` (1,027 rows) and `README.md`, then ran `onesentence.py` on the README.

Tools written this session, all reusable and all inside `sentry/_raw/tools/`: `fetch-blockscout.sh`, `mkcontract.py` (adapted from `long/`), `rpc.py` (copied from `long/`), `readstate.py`, `sign-siwe.py`, `hw-observer.js`, `mkpages.py`, `mksocials.py`, `mkaddresses.py`, `mklinks.py`, `onesentence.py`.

## 5. Definition-of-done check, and what is left

Against `SCRAPING-PLAN.md` part 8 and playbook section 8:

- [x] Every URL from section 5.6 appears in `LINKS.md` with a capture path.
- [x] Every internal link discovered was visited. `pages/15-app-route-map.md` records which paths are real routes and which redirect, in both the logged-out and logged-in states, so no capture is a loading stub whose nature is unexplained.
- [x] Every contract in the launch path has a directory under `contracts/` and a row in `ADDRESSES.md`. 49 of 54 have verified sources, 5 have bytecode.
- [x] `README.md` has all nine sections, every number cites a file, and Gaps is honest.
- [x] Every `pages/` and `socials/` reference in the authored files resolves to a real file. Verified, not assumed.
- [x] All 45 screenshots are referenced by at least one page.
- [x] No em dashes or en dashes in anything this session authored. The verbatim page bodies keep the upstream text unchanged, which is the point of a verbatim capture.
- [x] `onesentence.py` run on `README.md`.
- [x] The `lp-sentry` agent-browser session is closed, by name. `close --all` was never run.
- [ ] `SCRAPING-PLAN.md` part 4.4 and the section 5.6 findings block. **Left for the coordinating session**, because Flap and HOOD10 were running in parallel. Section 1 and section 2 of this file are the text to paste.
- [ ] `PLAYBOOK.md` additions. **Left for the coordinating session.** Section 3 of this file is the text to paste.

Nothing else in section 5.6 is outstanding.
The two known omissions, both deliberate and both recorded in the README's Gaps section, are that no Ink contract was read (out of scope for a Robinhood Chain launch decision) and that no launch was executed.
