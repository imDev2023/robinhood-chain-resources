# Session notes: `pools-trade` (SCRAPING-PLAN.md section 5.10)

Session H, wave 2, 2026-09-03.
Ran in parallel with `hood-fun` and `noxa`, so per playbook section 7 this session edited nothing outside `resources/launchpads/pools-trade/`.
`SCRAPING-PLAN.md`, `PLAYBOOK.md` and `NEXT-SESSIONS.md` are untouched.
Everything below is for the coordinating session to merge.

---

## 1. Proposed part 4.4 status row

Replace the existing `pools-trade` row with this one.

```text
| `pools-trade` | 264 raw files: 58 app JS bundles plus the i18n table, 119 Blockscout address, smart-contract and counter records, 14 tRPC API captures, 17 browser reads and snapshots, 50 decoded production launches, a decoded CCA config and auction step schedule, live `eth_call` state dumps, Uniswap's `deployments.json`, 3 Jina docs pulls, 23 X captures, Dexscreener, the home network capture | 16 | 22 | 40 dirs (28 verified, 12 bytecode) | 3 | yes, 100 rows | yes | **Done 2026-09-03** |
```

For the record, the inventory command now reports:

```text
files: 1525
pages: 16
screenshots: 22
contracts: 1218
socials: 3
_raw: 264
```

The row's raw-file count is `_raw` only (264), matching how the `sentry`, `flap` and `hood10` rows were written.

## 2. Proposed edit to part 7, "Safe groupings"

The wave-2 line can be struck the way the earlier waves were:

```text
| ~~`hood-fun` + `pools-trade` + `noxa`~~ | pools-trade done 2026-09-03 |
```

Leave the strike-through to whichever session finishes last; this session only claims `pools-trade`.

---

## 3. Findings block to paste under section 5.10

> **Done 2026-09-03.** Not Doppler-derived: the Doppler indexer returns `totalCount: 0` for the launcher, the CCA factory and both Instant Launch strategies as `integrator` and as `poolInitializer`, and for three sample launch tokens as `address`, against a control of 110,393 for chain 4663.
>
> **Both leads resolved.**
> The DefiLlama fee-tracked launchpad "Pools" (slug `pools`) **is** this platform: `url: https://pools.trade/`, `description: "Uniswap Labs' token launchpad on Robinhood Chain"`, $1,542,145 fees in 30 days and $0 revenue all time.
> The Reddit "pools fun" post with `PartyFactory 0x626C3d09B65bF5d1D40E0D5F25e19fa49783B3D4` is **a different platform**: that contract is verified on chain, its own natspec says it "Deploys pools.fun tokens ... seeds a single-sided full-range SushiSwap V3 position", it was deployed by an unrelated EOA, it uses a 1% fee tier and tick spacing 200, and it appears nowhere in Uniswap's deployment feed. Side-by-side in `pools-trade/pages/14-pools-fun-is-a-different-platform.md`. pools.fun is not in `launchpad-research.md` and is a candidate for the part 6 "found but not archived" list.
>
> **The TrustSwap claim is confirmed, not refuted.** Pools.trade is operated by Uniswap Labs, on six independent lines of evidence, three of them on-chain: the Uniswap Labs blog post of 2026-08-05 ("Pools is built by Uniswap Labs"), the Uniswap help centre article of 2026-08-06, the @Uniswap and @haydenzadams announcements plus an X affiliate badge, Uniswap's own `deployments.json` listing all 42 chain-4663 addresses that the frontend pins, the verified on-chain sources carrying `@custom:security-contact security@uniswap.org`, and a deployer EOA `0x32f4B2e69EbD7746596AF8699DAC1908F43107aD` that also deployed the CCA factory at the identical address on Ethereum mainnet.
>
> **Launch model.** Two models, both ending in a hookless Uniswap v4 native-ETH pool at a 0.25% LP fee, tick spacing 25, whose LP position is minted to a `FeeSplitter` that can only collect fees and add liquidity, never withdraw. Supply is always exactly 1,000,000,000 with 18 decimals. **Instant Launch** puts the whole supply into one single-sided position from `MIN_LAUNCH_TICK -160100` to `initialTick 198050`, tradable in the same block, opening FDV about $6.0K, no graduation. **Crowd Launch** runs a 4-hour continuous clearing auction (exactly 144,000 blocks at 0.1 s), floor about $1.0K FDV, graduation at 5x the floor raise which is a $10K FDV clearing price, 50% of supply auctioned and 50% reserved to seed the pool, 100% of the raise into the LP, unsold supply and unused ETH burned to `0x...dEaD`, all bids refunded if it falls short. Anti-bundling is a 13-step issuance schedule: twelve steps of about 5.82% each over the window, then 30.011% released in the final block.
>
> **Economics for a creator with no LP budget.** Zero launch fee, zero platform cut of the raise, zero platform cut of trading fees, no supply given up, no KYC. Several platforms in this survey already charge no launch fee (Doppler, Long, Flap, HOOD10, Bags since 2026-07-13); what is distinctive here is the second one: DefiLlama records $1,596,520 of lifetime fees against $0 of lifetime protocol revenue, and no contract in the launch path has an owner, a setter or a treasury address at all. The only cost is gas, quoted at $2.83 for an Instant Launch and $7.14 for a Crowd Launch. Optional creator fee pays 40% of the native side and 0% of the token side of the 0.25% LP fee, read live from `FeeSplitter.getSplits()`, which the interface states as "0.1% of every buy" and the docs state as "0.05% of the 0.25% LP fee"; the second is the blended figure across buys and sells. The rest auto-compounds into the same permanently locked position. Traders pay Uniswap's own v4 protocol fee of 0.04% on top (`getSlot0` returns `protocolFee = 1638800`, that is 400 and 400 hundredths of a bip), which goes to Uniswap's `V4FeeAdapter`, not to pools.trade.
>
> **Activity.** 43,904 transactions to `LiquidityLauncher` v3.2.0 since 2026-08-05, plus 7,887 to the v3.0.0 launcher in the pre-interface period. 126 Crowd Launch auctions all time, 64 graduated, 57 failed, 5 live, so a 52.9% graduation rate among concluded auctions, which is three orders of magnitude above Flap's. Instant Launch is the dominant model, 46 of the 50 most recent launcher calls.
>
> **Wallet gate is trivial.** No SIWE, no nonce, no signature. An EIP-6963 announcement plus an account from `eth_requestAccounts` reaches the full create wizard, the portfolio and the trade panels. The `headless-wallet` tier 0 observer opened it on the first attempt.
>
> **Gaps:** no launch transaction captured from the interface (the shared test wallet's 0.001 ETH is below both quoted network costs, so the flow stops at `Add funds`; closed instead by decoding 50 production launches); no exact launch count, because there is no indexer or subgraph for this stack; `PoolManager.owner()` is an unexplained EOA; twelve superseded or per-launch contracts are unverified, none in the current launch path; no audit exists.

---

## 4. Proposed playbook additions

These are written as drop-in text. Suggested homes are given.

### For section 1, "Session start, in order"

After the Doppler check paragraph, add:

> **A non-Doppler platform can still be someone else's published stack.** Before reverse-engineering anything, check whether the vendor publishes a machine-readable deployment feed. Uniswap serves <https://developers.uniswap.org/deployments.json>, generated from `github.com/Uniswap/contracts`, and filtering it to `chainId == 4663` returned all 42 addresses for pools.trade, roles and versions included, in one request. That answered "which contracts, which versions, which are superseded" before a single Blockscout call, and it doubles as the operator proof. Try `<vendor docs host>/deployments.json` and the vendor's docs repo before crawling an explorer.

### For section 2, "Docs capture"

> **A platform with no docs site can still have complete first-party docs.** pools.trade serves no `/docs`, no `llms.txt` and no sitemap; its documentation lives on the operator's other properties. The user guide was found by snapshotting a token page, because the trade panel's explainer modal links to `support.uniswap.org/hc/en-us/articles/<id>`, and that article links onward to the blog announcement and the developer docs. When a launchpad looks undocumented, snapshot its modals for outbound help links before concluding there are no docs.

### For section 3, "Ecosystem numbers, the fast way"

> **A launchpad's own tRPC router is often the cheapest census.** `pools.trade/api/trpc/<procedure>?batch=1&input=<url-encoded JSON keyed by call index>` is open, unauthenticated and uncapped in practice. `cca.listAllAuctions` returned the complete 126-auction history with statuses in one request, which is a graduation rate for free. Look in the shipped bundles for the `list*`, `getAll*` and `*Deep` variants of whatever the UI calls: the UI usually calls the paginated one and the unpaginated one is usually also exposed. Zod validation errors name the missing field, so an input schema can be recovered by sending `{}`.

### For section 4, "Contracts, the fast way"

> **A frontend bundle can carry a fully annotated deployment history.** `pools-trade/_raw/js/useCreatorFeeExecutor-44W_DATt.js` holds an array of every strategy ever deployed on the chain, each with its fee splitter, its creator-fee basis points, its initial tick, and a prose `description` naming the date and the git commit ("2026-08-05, full 4663 stack redeploy, current"). Grep bundles for a known current address and read outward: that one array explained eight otherwise-unidentifiable unverified contracts. Then check it against the chain, because it can be stale: the same array records `initialTick: 198060` where every deployed strategy returns `198050`, and it labels `0xccccccca...` a "v1 TWA auction factory" where the chain verifies it as `ContinuousClearingAuctionFactory`.
>
> **Bytecode length is a fast generation test for a family of near-identical deployments.** Eight unverified Instant Launch strategies split cleanly into a 10,774-byte generation and a 10,822-byte one, and the 10,822 group matches the current verified contract exactly, which proves those differ only in immutables. `eth_getCode` plus `wc -c` and `shasum`, no selector scan needed. Two of them were byte-identical to each other, which identified a pure re-deploy under a different salt.
>
> **Decode the launch `configData`, not just the outer call.** The outer `distributeToken(token, (strategy, amount, configData), salt)` says almost nothing; `configData` is the whole product. For pools.trade's Crowd Launch it decodes as `abi.decode(configData, (MigratorParameters, bytes))` and yields the supply split, the burn address for unsold supply, the LP position range, the LP allocation schedule, the auction duration in blocks, the floor price, the graduation threshold and a packed 13-step issuance schedule. The struct definition is in the verified strategy's own `src/libraries/` and `src/interfaces/`. Worked example: `pools-trade/_raw/rpc/derived-economics.txt`.
>
> **Read `StateView.getSlot0(poolId)` for the protocol fee, not only the LP fee.** The third return value is a packed pair of `uint12`s in hundredths of a bip, `fee1For0 << 12 | fee0For1`. On a Pools pool it is `1638800`, that is 400 and 400, so 0.04% each way on top of the 0.25% LP fee. Platforms advertise the LP fee and omit this, and a trader's true cost is `protocolFee + lpFee - protocolFee*lpFee/1e6`.

### For section 5, "The wallet gate"

> **Not every gate is SIWE. Try connecting before building a signer.** pools.trade has no login, no nonce and no signature: announcing over EIP-6963 and returning an account from `eth_requestAccounts` reached the full create wizard, the portfolio and the trade panels. The tier 0 observer from `~/.claude/skills/headless-wallet` did it in two clicks and appeared in the picker as "Headless Wallet Detected".
>
> **Watch for a balance gate at the end rather than the start.** The whole create flow renders and validates on an empty wallet; only the final button flips to `Add funds` when the balance is below the quoted network cost. That is far enough to capture every parameter and every screenshot, so an unfunded wallet is not a blocker for documentation, only for capturing the `eth_sendTransaction` payload.
>
> **`agent-browser upload <ref> <file>` clears a required-image field.** pools.trade keeps `Review` disabled until a token image is uploaded. A 762-byte PNG generated in the scratchpad with `zlib` and `struct` was enough; no real asset needed.

### For section 6, "Environment gotchas that cost time"

> **`agent-browser open ... && agent-browser read` in one call still returns an empty document on a React Router SPA.** On pools.trade the chained form the playbook recommends returned a 1-byte read every time. What worked was three separate calls: `open`, then `wait --load networkidle`, then `read`. The failure is silent, so check `wc -c` on the output rather than trusting the exit code.
>
> **`onesentence.py` un-indents continuation lines inside a numbered list**, which turns the rest of the list item into a sibling paragraph and breaks the numbering. Prefer `###` subheadings over numbered lists with multi-paragraph bodies in any file you intend to run it on, and re-read any list-heavy section afterwards.
>
> **Verbatim `pages/` captures keep their em dashes.** The no-dash rule applies to authored files. `sentry` has em dashes in 52 of 81 page files and none in its README; match that, and do not rewrite a capture to satisfy a style rule.

### For section 9, a new subsection

> ### From hood.fun, Pools.trade and Noxa (2026-09-03)
>
> **Confirm the operator with the chain, not the marketing.** Three separate third parties said Pools.trade was built by Uniswap Labs, and all three were right, but none of them was evidence. What settled it was that Uniswap's own `deployments.json` lists the exact addresses the frontend pins, the verified sources carry `security@uniswap.org`, and the deployer EOA also deployed the same contract at the same address on Ethereum mainnet. Run those three checks on any platform that claims a famous parent.
>
> **Similar names on one chain are a real hazard.** `pools.trade` (Uniswap Labs, Uniswap v4, 0.25%) and `pools.fun` (an independent team, SushiSwap V3, 1%) were both live on Robinhood Chain in August 2026 and are unrelated. A contract's own natspec is the cheapest disambiguator: `PartyFactory`'s first comment line names its own domain.
>
> **The blended fee figure and the contract fee figure will differ, and both will be published.** Pools states the creator's cut three ways: "0.1% of every buy" in the app, "0.05% of the 0.25% LP fee" in the docs, and "20% to the creator" from the founder. The contract says 40% of the native side and 0% of the token side. All four are consistent once you notice that sells pay in token and the token side goes entirely to compounding. Always quote the split as `(nativeBps, tokenBps)` from `getSplits()`, then give the blended figure as a derived number.
