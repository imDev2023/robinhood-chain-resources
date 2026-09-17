# hood.fun session notes, 2026-09-03

Session G of wave 2, section 5.9.
This file is the handoff into the merge session.
Nothing outside `resources/launchpads/hood-fun/` was edited.

---

## 1. Proposed part 4.4 status row

Replace the existing `hood-fun` row in `SCRAPING-PLAN.md` part 4.4 with:

```text
| `hood-fun` | 1,046 files: 227 raw (8.5 MB board API pull plus a fresh one, 100 Blockscout address and contract records, 21 Dexscreener pulls, 31 app chunks, X pipeline posts, Jina page captures), full-range `Graduated` and `Migrated` log pulls on all four launchpads, `Collected` log pulls on all four lockers, 20 live `eth_call` state reads | 18 | 9 | 38 dirs (34 verified, 4 bytecode) | 4 | yes, 489 rows | yes | **Done 2026-09-03** |
```

Column-by-column, so the merge session can reformat if the table shape has drifted:

| column | value |
| --- | --- |
| Raw captures | 1,046 files total, 227 in `_raw/` |
| `pages/` | 18 |
| `screenshots/` | 9 (pre-existing, all referenced) |
| `contracts/` | 38 dirs, 34 verified, 4 bytecode-only |
| `socials/` | 4 |
| `LINKS.md` | yes, 489 rows |
| `README.md` | yes |
| Status | **Done 2026-09-03** |

Also worth a one-line edit in part 7 of the playbook's safe-grouping table if anyone keeps it current: `hood-fun` is finished, `pools-trade` and `noxa` were still running when this session closed.

---

## 2. Findings block for section 5.9

Paste under `### 5.9 hood.fun (`hood-fun`) - Opus 5`:

```markdown
Findings (2026-09-03). Full write-up in `launchpads/hood-fun/README.md`.

**Not Doppler.** The Doppler indexer returns `totalCount: 0` for all four hood.fun launchpads as `integrator` and `poolInitializer`, and for a hood.fun token as `address`, against a control of 110,392 assets on chain 4663. Its own non-upgradeable stack: launchpad, migrator, ownerless locker, plus optional community and stock-rewards factories.

**Four launchpads, not one.** `HoodLaunchpad` classic `0x6a63d9...` (85 launches, 2 graduations, `creatorFeeShareBps` 5000), `HoodCustomLaunchpad` v1 `0x5Fcc1DF0...` (10,575 / 19), an undocumented third `HoodCustomLaunchpad` `0x3d1c455f...` (14 / 0) found by reading `launchpad()` off `HoodV3MigratorV2-b`, and the live one `0x8c529f0a...` (352 / 2). **11,026 launches, 23 graduations, a 0.21% graduation rate.**

**Free to launch, and that is the whole pitch.** `creationFee` is 0, there is no LP to provide and no mandatory dev buy. One observed `createTokenGuarded` cost 1,235,667 gas, 0.000557 ETH, about $1.34. The token address must end `0x600d` (`vanityEnforced` true); the app grinds the salt.

**Every graduation is identical.** All 23 `Graduated` events carry `raisedEth` 6.5159 ETH (2.81 ETH virtual seed, 1.145e9 token seed, 80% of supply on the curve). On the current launchpad the migration take is 0.05 ETH flat + 3% of the raise + a **0.5 ETH flat protocol fee**, so 5.77046 ETH seeds the pool against 6.27046 ETH on the older launchpads. **Creator take at graduation ~0.249 ETH ($599); protocol take ~0.562 ETH ($1,352), 2.26x the creator.**

**Post-graduation income is a lottery, not an annuity.** The locked v3 1% position pays the creator 80% of the WETH side forever. Summed from every `Collected` event across the 19 older graduations: total 3.20378 WETH, **median 0.0008 WETH ($1.92) for life**, mean 0.1686 WETH, max 1.5874 WETH, and six positions have paid exactly zero. The two current-launchpad graduations have paid 0.0416 and 2.1219 WETH.

**Three ways a creator's income silently goes to zero, none of them documented.**
1. Either rewards mode (community coin or stock rewards) makes a vault clone the coin's `creator`, so 100% of the fee stream goes to holders, not the launcher. 34% of all coins ever launched are community coins, and three of the four graduated coins on the live board are.
2. `selectQuote` lets a creator pair against USDG or a tokenized stock at graduation. `HoodBurnLocker._distribute` pays the creator only when the collected token *is* WETH, so a non-WETH pair burns 80% of the quote-side fee to `0x...dEaD`, sends 20% to protocol, and **pays the creator nothing, forever**. Five quotes have configured paths and the create form offers the toggle.
3. `tradeFeeBps` is a per-launch argument bounded 100 to 500 bps, but the create form hard-codes 100. A direct contract call can set 500 and keep 80% of a 5% fee. Only 5 of 10,629 coins ever did.

**The board was reset between 2026-09-02 and 2026-09-03.** `/api/board` served 10,629 coins from the older launchpads on 09-02 and 354 from the current one on 09-03; `/api/token/<addr>` now returns `unknown token` for the 10,568 that were dropped. The contracts are untouched, but a pre-switch creator has lost their coin page. Both boards are archived (`_raw/api-board.json`, `_raw/api-board-2026-09-03.json`) and both home captures are kept as `pages/01` and `pages/11`.

**Two owner Safes, both 2-of-3, with no signer in common.** `0x8E96a84A...` owns the current launchpad, migrator and both factories; `0xB3f3B54E...` owns the three older launchpads. The whitepaper describes one. Neither can touch curve reserves or locked liquidity.

**Platform activity is near zero.** 24h volume across the whole live board was 1.113 ETH (about $2,677) on 2026-09-03, and 4h volume was 0. One coin, Buttkiss, is 541 of the board's 960 cumulative ETH. DefiLlama does not track hood.fun.

**For a creator with no LP budget:** cheapest launch of any platform archived so far ($1.34 of gas, no LP, no creation fee), best headline creator share (80% of curve fees and 80% of the WETH-side pool fee), and an 0.21% chance of reaching the point where those numbers pay anything. Do not pick a rewards mode and do not pair against a stock.
```

---

## 3. Proposed playbook additions

None of these are in `PLAYBOOK.md` yet.
Suggested homes are given per item.

**Section 4, contracts.** *Read `tokenCount()` on every launchpad generation, not just the one the frontend names.* hood.fun's frontend config block names one launchpad; there are four live, and the one it names holds 3% of the platform's history. The two that matter were found by reading `launchpad()` back off each migrator and `locker()` off each of those. A launchpad family is a ring of mutual pointers, and walking it in both directions finds generations no config file mentions.

**Section 3, ecosystem numbers.** *For a non-Doppler bonding-curve launchpad, `eth_getLogs` on the `Graduated` topic over the full range is an exact graduation count in one call per launchpad, and the event's data field gives the raise.* On hood.fun all 23 events carried a byte-identical `raisedEth`, which validated the curve arithmetic without a single `eth_call`. Pair it with `tokenCount()` for an exact graduation rate. This is cheaper and more precise than the Multicall3 sampling the playbook recommends for Flap-style pair factories, and it works whenever graduation emits an event.

**Section 3 or 4.** *`eth_getLogs` on a locker's payout event answers "what does a creator actually earn after graduation", which no dashboard will.* Summing `Collected` on hood.fun's lockers gave a per-position distribution, and the median (0.0008 WETH) and the mean (0.1686 WETH) differ by 200x. Always report the median and the zero count, not the total. Watch for a second locker generation with a differently shaped event: decoding `HoodLiquidityLocker` logs with the `HoodBurnLocker` ABI produced plausible-looking nonsense.

**Section 4 or a new "reading the code for the user" note.** *Grep a locker or fee splitter for the branch that decides who gets paid, not just the split constants.* hood.fun's split is a clean 80/20, but `_distribute` only takes the creator branch when the collected token `== WETH`, so an opt-in feature the same team shipped later routes the creator's whole income into a burn address. The constant was right and the branch was wrong, and no amount of reading the fee table would have found it.

**Section 9, cross-cutting.** *A launchpad's indexer can be repointed, and the site's own history disappears with it.* hood.fun's board went from 10,629 coins to 354 overnight while the contracts were untouched. Capture `/api/board`-style bulk endpoints on the first day of a session, timestamp the file, and re-capture on the last day; the diff was one of the most useful findings on this platform. Never treat a board API as a stable snapshot of a chain.

**Section 9, X syndication.** Add `@hooddotfun` to the list of accounts for which `syndication.twitter.com/srv/timeline-profile/screen-name/<handle>` returns a valid 2.2 KB page with `entries: []`. That is now three of five accounts tried across sessions, so the endpoint should be treated as a lucky shortcut rather than a method.

**Section 2, docs capture.** *Some platforms have no docs site at all and a single `/whitepaper` route is the entire documentation.* hood.fun serves the SPA shell for `llms.txt`, `sitemap.xml` and `sitemap-pages.xml`. Probe those three, and when all three return the shell, stop looking for a docs subdomain and read the app's own routes instead.

**Section 5, the wallet gate.** *Check whether there is a gate before building a harness for one.* hood.fun's create form renders in full to Jina with no wallet, no cookie, and no terms acceptance. Its `/swap`, `/bridge` and `/portfolio` routes render only a terms-accept overlay, so the gate on this platform is a modal, not a wallet. Fetching `/create` through Jina first cost ninety seconds and removed the whole section-5 workload.

---

## 4. What is on disk

Final inventory, `resources/launchpads/hood-fun/`:

| | count |
| --- | --- |
| files total | 1,046 |
| `pages/` | 18 |
| `screenshots/` | 9 |
| `contracts/` | 38 dirs (34 verified, 4 bytecode-only) plus `ADDRESSES.md` |
| `socials/` | 4 |
| `_raw/` | 227 |
| `README.md` | 9 sections, every number citing a source |
| `LINKS.md` | 489 rows |

### Written this session

- `README.md`, `LINKS.md`, `contracts/ADDRESSES.md`, `SESSION-NOTES.md`.
- `pages/01` to `pages/18`: 10 hood.fun routes (including two dated pairs spanning the board reset) and 6 external articles.
- `socials/01` to `socials/04`: X profile, two Telegram views, and the five Bright Data post records joined into one file.
- 11 new contract directories: the third launchpad `0x3d1c455f...`, three more lockers, the Uniswap `NonfungiblePositionManager`, the current owner Safe, `HoodCommunityGuarded`, and four bytecode-only directories for `new`-deployed implementations and the legacy owner Safe.
- New raw files: `_raw/jina2/` (10 page captures), `_raw/api-board-2026-09-03.json`, `_raw/api-token_0xA8028daB...json`, `_raw/x-syndication-hooddotfun-2026-09-03.html`, `_raw/fetch_contracts_2.sh`, `_raw/write_unverified.py`, plus the Blockscout records the two scripts pulled.

### Found already on disk, not redone

- 9 screenshots, 27 contract directories with generated READMEs, `_raw/address-roundup-2.txt`, `_raw/frontend-config-block.txt`, `_raw/bs.sh`, `_raw/write_contract.py`, `_raw/fetch_contracts.sh`, the 8.5 MB `_raw/api-board.json`, the Dexscreener and Blockscout pulls, and the Jina and Bright Data captures.
- `_raw/api-board-stats.json` is a **derived** summary of the 2026-09-02 board written by the earlier session, not a raw API response. It is cited as derived in `README.md` section 7. Its `graduated: 20` for the two older launchpads is one short of the chain's 21, which is consistent with its snapshot ending 2026-07-31 rather than with an error, but every number in the README that could be taken from it was re-derived from the chain instead.

### Not done

- `/creator/<address>` routes: 193 distinct links in `LINKS.md`, none visited. One template, one instance per wallet.
- `/swap`, `/bridge`, `/portfolio`: only the terms-accept overlay was captured. Nothing behind them is part of a launch.
- `GET /api/trades/<address>` against a live token: timed out on a 25 second probe.
- `HoodLiquidityLocker` `Collected` logs: not decoded, different event shape, 2 positions.
- The full 161-post X history: syndication is empty for this account and Bright Data was used per status URL, so only the 5 posts visible logged-out are archived.

No agent-browser session was opened at any point, so there is none to close.
