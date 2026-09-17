# HOOD10 session notes, 2026-09-02 into 2026-09-03

Session F, `SCRAPING-PLAN.md` section 5.8.
Written for the coordinating session to merge, because two sibling sessions (Sentry, Flap) ran concurrently and `SCRAPING-PLAN.md` and `PLAYBOOK.md` must not be edited in parallel (playbook section 7).

Nothing outside `resources/launchpads/hood10/` was written or modified.

---

## 1. Row for `SCRAPING-PLAN.md` part 4.4

Replace the existing `hood10` row with this one.

| Slug | Raw captures | pages/ | screenshots/ | contracts/ | socials/ | LINKS.md | README.md | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `hood10` | 380 files: browser reads, app bundles, 148 Blockscout JSON, 24 launchpad API captures, GeckoTerminal and Dexscreener, X pipeline posts and syndication, 6 live RPC state dumps, 4 selector-resolution sets | 28 | 35 | 18 dirs (12 verified, 6 bytecode or clone) | 3 | yes, 442 rows | yes | **Done** 2026-09-03 |

## 2. Findings block for `SCRAPING-PLAN.md` section 5.8

Paste under the section 5.8 entry, in the same form as the Long, Bags and Virtuals blocks.

**Done 2026-09-03.** Findings a later session should not have to rediscover.

- **HOOD10 is not Doppler-derived.** The indexer check in playbook section 1 returns `totalCount` 0 for `LaunchFactory`, `LaunchHook` and `FeeRouter` as `integrator` and as `poolInitializer`, and 0 for the sample launch token as an `address`. It is an independently written Uniswap v4 hook pad. The only thing it shares with the Doppler stack is the chain's single `PoolManager` `0x8366a39CC670B4001A1121B8F6A443A643e40951`.
- **It is two products under one brand.** The HOOD10 index token (hood10.xyz, live since 2026-08-24) and the HOOD10 Launchpad (launch.hood10.xyz, live since 2026-08-29). Different code, different contracts, different trust models. Do not conflate them.
- **The launchpad is the most attractive mechanism on this chain for a creator with no LP budget.** No launch fee, no minimum, no LP to seed, no bonding curve, no graduation, no migration. `LaunchFactory.launch` deploys the token, opens the v4 pool, seeds the entire supply as one one-sided concentrated position and locks it, in one transaction. letscash.fun by comparison charges `launchFee()` = 0.0005 ETH.
- **The lock is real and has no owner path around it.** `LaunchHook._beforeRemoveLiquidity` always reverts, `_beforeAddLiquidity` permits exactly one seed add per pool, and `_beforeInitialize` refuses any pool not opened by the factory. The owner's only power over a live pool is `setFeeRouter`.
- **Fees: fixed 1% protocol, plus a creator add-on of 0% to 9%, hard-capped at 10% total.** `PROTOCOL_FEE_PIPS = 10000`, `MAX_CREATOR_FEE_BPS = 900`, `MAX_FEE_RATE = 100000`. The docs' claim that a 10% coin costs a trader 11% is wrong; the form agrees with the contract, not the docs.
- **Quote assets are permissionless.** `LaunchFactory._assertQuoteLaunchable` refuses only a non-contract, an asset the `QuoteRegistry` classifies `UNSUPPORTED`, and anything whose `decimals()` reverts. The 21 assets in `/api/vault` are a UI convenience list. The registry's natspec says this outright and names letscash.fun as "the incumbent pad" that does gate quotes.
- **`LP_FEE` is 0 on every pad pool.** All fee is charged by the hook and held as ERC-6909 claims until a permissionless `settle(poolId)`. Creators withdraw with `claim(poolId, to)`; the fee lane moves with a two-step `transferCreator` / `acceptCreator`, and carries token metadata control with it.
- **Anti-snipe is a creator-set surge decaying linearly to zero over `snipeWindow` blocks, and 100% of it goes to the protocol lane, never the creator.** The natspec explains that crediting it proportionally would turn a snipe deterrent into a way to farm the first buyers.
- **The 0.7 / 0.3 fee split is not contract-enforced today.** `FeeRouter` `0xe1c046571e69Ae2408C21605f2ff657A23977C4c` implements it (`DIVIDEND_SHARE_BPS = 7000`), but `LaunchHook.feeRouter` was pointed away from it at block 49485132 on 2026-08-29 21:45 UTC and now reads `0xbd40E13889Cd75D8019CfbaA4f3C5562ba242279`, **an address with no code**. All 117 `PlatformCollected` events since name that EOA, which calls `collectPlatform` and `settleMany` directly and forwards every asset unconverted to a second EOA `0x7e8ADA37D066a124Cd0A044c1209c48338c962fe`. `/api/health` still advertises the superseded router, so anyone integrating against it wires up the wrong address.
- **The site's own vault API confirms the gap.** `withdrawnUsd` 55859.07, `buybackUsd` 39101.35, `buybackShare` 0.7, `paidLifetime` **0**. 39101.35 is exactly 55859.07 x 0.7, so `buybackUsd` is a projection, not an observed purchase, and the amount actually paid into the index from launchpad fees is zero.
- **Both dividend systems are keeper-committed Merkle claims, not pushes.** The index distributor `0x9f3edbfA...` and every reflection-launch `LaunchDividendTreasury` use `commitRoot` / `openClaims` / `claim(period, account, amount, proof)`. The "nothing to claim" experience is the operator paying gas to call `claim` for each holder. The site serves proofs at `/api/dividendProof?treasury=&account=`. The verified `LaunchDividendTreasury` natspec states the trust model: "the keeper commits the Merkle root, and nothing on chain checks that the root reflects real balances ... it is not trustless and should not be described as such."
- **Six documentation claims are contradicted by the project's own contracts.** Tax ceiling (11% vs 10%), reflection "no keeper, no claim, no protocol cut" (all three false, and the pad cut is bounded at `MAX_CUT_BPS = 3000`), "nothing to claim", "read from chain, never from a database", "there is no admin withdrawal" (the distributor has `sweep(address,address,uint256)` and its owner is the keeper EOA), and epoch length given as both eight hours and three hours on the same page. Full list in `README.md` section 9.
- **The venue is one coin.** 81 launches between 2026-08-29 17:20 and 2026-09-01 13:31 UTC, then nothing for the next thirty hours. 1,531 trades, about $391K cumulative volume, of which GOONER is $378,820. **75 of the 81 launches have one trade or none.** The pinned X post claims "$5M in total trading volume in just two days"; the site's own board data is more than an order of magnitude below that.
- **Quote choice is genuinely used:** only 17 of 81 launches are priced in WETH and 1 in USDG. PENGU 14, HOOD10 12, PONS 7, NVDA 5, CASHCAT 4, plus eight more tokenized equities and memecoins.
- **The index is the larger product:** 6,086 holders, about $2.34M market cap, $374,268 distributed across 31 settled epochs, `currentPeriodId()` 34, ten constituents at 1000 bps each read live from `getBasket()`.
- **No team identity, no audit, no bug bounty, no repository, no terms, no Telegram and no Discord exist for either product.** X is the only channel. The `hood10-lite` repository that `LaunchDividendTreasury.sol` cites is not public.

### The CashCat relationship, with evidence

Section 5.8 records a suspicion that "the CashCat contracts suggest launch.hood10.xyz shares infrastructure with the CASHCAT community launchpad".
**That is not what the evidence shows, and the correction should go into the plan.**

The HOOD10 **token** was launched on letscash.fun.
The HOOD10 **Launchpad** is separate, later, and independently written code.

1. HOOD10 `0x0D257cA40d40090BE60C2d2Ed5bB3535392838cc` is an EIP-1167 clone. Its 45-byte stub embeds `0xd6Da7f07eE822C8538C901217b37D1e7d86c76E5`, the verified `CashCatTokenV2` master, and its creator is the CashCat factory proxy `0x5bd1Fbe78a78fe8236fa00CF48fbEBA74ae34661`, in tx `0xb508e76ec585225f317cd821dfa58acf0839c91c1937a65fe859bd9acb128538` (`_raw/blockscout/address-hood10.json`, `contracts/HOOD10Token-proxy-.../bytecode.hex`).
2. `HOOD10.hook()` returns `CashCatHookV2` `0x75A54357D9C78a2Db19004a5FDc76c50F9242AEC`, and that hook returns `currentFeeRate(poolId, 0x0)` = 50000 pips. The index's 5% tax is charged by CashCat's engine, not by anything HOOD10 wrote (`_raw/rpc/hood10-token-state.txt`).
3. The HOOD10 docs' own tax table lists a 0.30% wedge as a "letscash.fun platform fee" inside the 5% (`pages/02-docs.md`).
4. `letscash.fun/token/0x0D257cA4...` renders the HOOD10 token page with a live trade feed, so the index still trades as a letscash listing (`_raw/jina-letscash-token-hood10.md`).
5. Nothing runs the other way. No launchpad contract references any CashCat address and no CashCat contract references any HOOD10 launchpad address. The only shared component is the chain's single Uniswap v4 `PoolManager`.
6. The relationship is competitive, not cooperative. The HOOD10 `QuoteRegistry` natspec: "This is deliberately NOT an allowlist. The incumbent pad on this chain restricts launches to 'an approved ERC-20'; letting a creator denominate a pool in literally anything is the product." `approvedQuote(address)` is a real selector in the CashCat factory's current implementation, which identifies the incumbent as letscash.fun.
7. `CashCatHookV2.poolConfigs(HOOD10 poolId)` names the fee recipient as an EOA `0x639D6Faa4DAf85d4ccc4291D1134C83867df5d82`, not the distributor. So the index's own 5% also reaches its distributor through a wallet.

Full write-up: `socials/03-x-letscashfun-and-cashcat.md` and `README.md` section 5.1.

## 3. Additions for `PLAYBOOK.md` section 9

These cost time this session and would save the next one.

### Selector matching is the reliable way to name an unverified contract

Four of the six unverified contracts here were identified this way and none of them needed a guess.
The recipe:

1. `eth_getCode` (or Blockscout `deployed_bytecode`) into a `.hex` file.
2. Candidate selectors are every `PUSH4` in the dispatcher: `re.finditer(r"63([0-9a-f]{8})", bytecode)`. It over-collects, which is fine.
3. Resolve in batches of 50 against `https://api.openchain.xyz/signature-database/v1/lookup?function=0x...,0x...`. No key needed.
4. About 60% resolve, and the named 60% is always enough to identify the contract family.

Worked examples in `hood10/_raw/blockscout/selectors-*-resolved.json`.
Reusable script inline in the session; the pattern is four lines.

### Three cheaper identifications to try before selector matching

- **A linked Solidity library** shows unverified but is named in the verified parent's `external_libraries` field in the `smart-contracts/<addr>` response. `LaunchGeometry` was found that way in one request.
- **A contract deployed with `new` by a verified factory** shows unverified, but the factory's own `PairDeployed`-style event names it and the factory's verified sources are the readable source. Two contracts here.
- **An EIP-1167 clone** needs no lookup at all: the 45-byte stub contains the implementation address literally, at bytes 10 to 29.

### Read the natspec, not just the ABI

The most valuable facts in this archive were prose comments in verified sources, not state.
`LaunchDividendTreasury.sol` names the unverified index distributor by address and describes its trust model.
`QuoteRegistry.sol` identifies a competitor by behaviour.
`LaunchFactory.sol` explains why there is no migration.
Grep verified sources for `@dev` and `@notice` before reaching for the chain.

### An owner-settable address can silently take a documented contract out of the path

`LaunchHook.feeRouter` still resolves; the `FeeRouter` contract still exists, is verified, and returns sensible config when read directly.
Everything looks right until you compare `hook.feeRouter()` against the address you archived.
**Read the pointer from the consumer, not the config from the pointee**, and check `eth_getCode` on anything a contract calls a "router" or a "sink".
Then confirm with the emission history: `eth_getLogs` on the `RouterUpdated`-style event gave the exact block and both addresses in one call.

### A frontend's own API can disagree with the chain

`/api/health` here serves an `addresses` block stamped `recordedAt`, and it is four hours stale on the one address that changed.
Treat a launchpad's config endpoint as a hint and re-read every address from the contract that uses it.

### Derived numbers in a dashboard are not observations

`buybackUsd` was exactly `withdrawnUsd * buybackShare`.
Before citing a dashboard figure, check whether it is a product of two other figures on the same response.

### Cheap non-Doppler check

The playbook section 1 indexer query answers "is this Doppler-derived" for a fee address.
When the platform has no obvious integrator EOA, query the same endpoint with the launcher, the hook and the fee router as both `integrator` and `poolInitializer`, and with a sample launch token as `address`.
Five queries, about ten seconds, and a definitive no.

### `onesentence.py` rewrites in place and prints a status line

Run it as `python3 onesentence.py FILE...`.
Do **not** redirect its stdout over the file: `python3 onesentence.py x.md > x.md` destroys the file, because the tool has already rewritten it and the shell then overwrites it with the one-line status report.
This cost a restore-from-backup here.
Back the file up before running it, or just run it bare.

### `launch.hood10.xyz/api/rpc` is not a usable open proxy

Unlike `app.doppler.lol/api/rpc/4663`, it refuses direct calls with `{"error":"this endpoint serves the app, not direct calls"}`.
The Doppler proxy works for any chain-4663 read from anywhere and was used for every `eth_call` here.

## 4. Session log

| when | what |
| --- | --- |
| 2026-09-02 | Read `PLAYBOOK.md` in full including section 9, then `SCRAPING-PLAN.md` parts 0 to 5.8 and part 8. |
| | Ran the part 4.3 inventory: 824 files on disk, 28 pages, 35 screenshots, 15 contract dirs, 0 socials, no `LINKS.md`, `README.md` or `ADDRESSES.md`. |
| | Ran the playbook section 1 Doppler check. Negative on all five queries. Did not read or touch `doppler/` or `long/` beyond copying the shape of their `mkcontract.py` and `rpc.py` tools. |
| | Read the verified sources for `LaunchFactory`, `LaunchHook`, `QuoteRegistry`, `FeeRouter`, `DividendDeployer`, `LaunchDividendTreasury`, `CreatorFeeSplitter` and `CashCatTokenV2`. |
| | Wrote `_raw/tools/rpc.py` and read live state for all five launchpad contracts, the index distributor, the index token and the CashCat factory into `_raw/rpc/`. Found the `feeRouter` EOA. |
| | Traced the fee lane on Blockscout: `RouterUpdated` history, 117 `PlatformCollected` events, and both fee EOAs' transactions and token transfers. |
| | Selector-matched four unverified contracts; added three contract directories (`LaunchDividendTreasury`, `CreatorFeeSplitter`, `LaunchGeometry`). |
| | Wrote `_raw/tools/mkcontract.py`, generated a `README.md` for all 18 contract directories from a per-directory `NOTE.md` plus Blockscout metadata. |
| | Wrote `contracts/ADDRESSES.md`, `socials/01`, `02`, `03`, `LINKS.md` and `README.md`. |
| | Session killed by the account session limit. |
| 2026-09-03 | Resumed after the 01:10 reset. Re-ran the part 4.3 inventory rather than trusting memory. |
| | Ran the playbook section 8 finish checklist. Regenerated the one `_raw/rpc/live-state.txt` that a failed `tee` had never written, and re-confirmed every value on chain. Expanded two elided paths in `README.md`. |
| | Annotated all 28 `pages/` files with the screenshots they correspond to, so every one of the 35 screenshots is now referenced. |
| | Ran `onesentence.py`, destroyed four files by redirecting its stdout, restored `README.md` and `contracts/ADDRESSES.md` from scratchpad backups and regenerated both socials files from their sources, then re-ran it correctly. All four verified intact afterwards. |
| | Wrote this file. |

**Browser sessions.** None were opened this session; all work was `curl`, `eth_call` and Blockscout. `agent-browser session list` shows only `lp-flap`, which belongs to the concurrent Flap session and was left alone. Nothing to close, and `--all` was never run.

## 5. Definition of done, checked against part 8

| requirement | state |
| --- | --- |
| Every URL from `launchpad-research.md` for this platform appears in `LINKS.md` with a capture path | yes. All four section 5.8 sources (`www.hood10.xyz`, `/docs`, `launch.hood10.xyz`, the Dexscreener pool) are rows |
| Every internal link visited and has a `pages/` file with real content | yes. Both sitemap URLs and every launchpad route are in `pages/`, no loading stubs |
| Every contract in the launch path has a directory with sources or bytecode, and `ADDRESSES.md` lists it | yes. 18 directories, 12 verified with sources, 6 with bytecode or a clone stub, all in `ADDRESSES.md` along with the nine no-code addresses in the money path |
| `README.md` has all nine sections, every number cites a file, "Gaps" is honest | yes |
| The agent-browser session is closed | not applicable, none opened |
| Part 4.4 updated | **not done by me, by design.** Section 1 above is the row for the coordinator to merge |
| Findings block added under the section 5.8 entry | **not done by me, by design.** Section 2 above |
| Playbook additions | **not done by me, by design.** Section 3 above |

## 6. What is left

Nothing blocking, and nothing that needs another HOOD10 session.
Three items are deliberate stopping points rather than omissions, and all three are recorded in `README.md` section 9:

1. **The two fee EOAs were traced one Blockscout page deep, not to a conclusion.** Whether 70% of the collected fee does in fact buy and burn HOOD10 off chain was not established either way. What is established is that no contract enforces it and that `/api/vault` reports `paidLifetime` 0. Settling it needs a full transfer history for `0xbd40E138...` and `0x7e8ADA37...` and a reconstruction of the swaps through `0x8876789976dEcBfCbBbe364623C63652db8C0904`.
2. **The "$5M volume in two days" claim is unresolved.** The board's own data gives about $391K. The API does not document what `volumeQuote` counts, so this is recorded as a discrepancy rather than called an error.
3. **`TOTAL_FEE_BPS() = 4700` on the index distributor has no confirmed meaning.** The contract is unverified and the value is not obviously 47% of anything in the documented 4.00 / 0.70 / 0.30 split.

The three merges in sections 1 to 3 are the only actions outstanding, and they belong to the coordinating session once nothing else is running.
