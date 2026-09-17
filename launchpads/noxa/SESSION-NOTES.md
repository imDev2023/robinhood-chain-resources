# Noxa session notes, 2026-09-03

Session I of wave 2, running in parallel with hood.fun and Pools.trade.
This session owned only `resources/launchpads/noxa/` and edited nothing outside it.
No subagents were spawned.

Everything below is meant for the coordinating session to merge into `SCRAPING-PLAN.md` and `PLAYBOOK.md`.

---

## 1. Proposed part 4.4 status row

Replace the existing `noxa` row with:

```
| `noxa` | 331 raw files: 12 GitBook docs pages, 3 app bundle sets (fun.noxa.fi, noxa.io, the ENS/IPFS artifact), 29 agent-browser reads, 118 Blockscout address, contract, transaction and log records, 40 backend API captures, 3 PUSH4 selector scans, the Doppler indexer check, a traced V1 fee collection and a derived-economics dump | 72 | 24 | 23 dirs (17 with verified sources, 6 bytecode only) | 9 | yes, 1,664 rows | yes | **Done 2026-09-03**, and the section 5.11 premise is wrong: launching is live |
```

Exact counts at the end of the session are in part 4 below; regenerate the raw-file count with the 4.3 inventory command before pasting if anything else has touched the directory.

## 2. Findings block for section 5.11

Suggested replacement for the "State of the platform" paragraph and the To-do list under `### 5.11 Noxa (noxa)`:

> **Done 2026-09-03. The brief's premise did not survive contact with the chain.**
>
> Section 5.11 asked for a README "stating definitively that new launches are not possible today".
> New launches **are** possible today, and were happening hours before the capture.
> What is disabled is the original V1 factory, and only that.
>
> There are **three** Noxa launchpad deployments on Robinhood Chain, not one:
>
> - **V1** `0xD9eC2db5f3D1b236843925949fe5bd8a3836FCcB`, deployed 2026-06-16 by `dev.noxa.eth`, 60,142 launches including CASHCAT, disabled on 2026-07-11 by `setLaunchEnabled(false)` in tx `0xdf03d9cd279a3fceb940ef1665c4367d0cf6e64a2bfc9738e44e20de3ddc90c8`. `launchEnabled()` still returns false and the 50 most recent `launchToken` calls to it, through 2026-08-28, all reverted. The disable is real and enforced.
> - **V2** `0xDd84fDdEA1206115B37dbBC0ba5721530E1bA9C5`, deployed 2026-07-22, **eight days after the "permanently disabled" announcement**, by a different key `0x63CD726Ccc6560F571861BbAb925f9AF4a6095B2`. `launchingEnabled()` is true, `allTokensLength()` is 1090, and the newest launch was 2026-09-03T01:18:38Z with `msg.value` 0 and `status: ok`. This is what `fun.noxa.fi` calls, and `fun.noxa.fi` is back up on the conventional domain.
> - **noxa.io** `0xA24D48D50Fd7985c6dE816EaF77C1A17D3593BBE`, a fully verified four-contract stack by `0x407Fe47FA03617062E9cD27DCACe8DAB006322d8`, also live, `launchFee()` 0.0005 ETH, 171 launches, most recent 2026-08-31. It brands itself NOXA Fun, its socials are the "NOXA Reloaded" CTO accounts, and it treats the V1 contracts as `legacy` in its own frontend config. Its FeeRouter pays the creator only 33.34% of fees against 100% on `fun.noxa.fi`.
>
> **Not Doppler.** Indexer control `totalCount` 110392 for chain 4663, and 0 for every Noxa factory, locker, deployer and fee address as `integrator` and `poolInitializer`, and 0 for CASHCAT and PCC as `address`.
>
> **Model.** No bonding curve. One transaction deploys an ERC-20, opens a Uniswap V3 1% WETH pool at tick -204200, mints one single-sided position holding the entire 1B supply, and hands the NFT to a locker with no unlock path. Optional dev buy is executed in the same transaction. "Graduation" is a display metric with no contract effect; it is exactly **20 WETH fully diluted market cap**, derived to four decimal places over twelve tokens, from a launch FDV of about 1.3557 WETH.
>
> **Economics today, all read from chain.** Launch fee 0 (ceiling 1 ETH). Trading fee 1%, split 100% creator, 0% protocol. Anti-snipe effectively off (`maxWalletBps` 10000, `maxTxBps` 10000, `restrictionSeconds` 1). The app's own launch page still advertises "50/50 platform/creator" and a one-hour anti-snipe window, both of which the chain contradicts.
>
> **The fee split is a live global knob, not a per-launch term.** `LaunchLockerV2.protocolFeeShare` is read at collection time and the verified source says the non-snapshotting is deliberate. It was 50 at deploy, set to **70** at 2026-08-29 15:14:49Z, and to **0** at 16:42:51Z the same day. The owner can also redirect any creator's fee stream after a 24-hour timelock via `proposeCreatorReassign` / `executeCreatorReassign`.
>
> **V1 fee claiming works and is busy.** Tracing `0x91479f6f1b0bed82e68ccbbc426d2beac6f7877323d96863731a1ec261a4a295`: the locker's `protocolFeeShare()` of 100 routes both sides to the unverified FeeCollector `0x9eFdC1A8...`, which burns the launched-token side to `0x...dEaD` and pays 100% of the WETH side to the deployer. 49 successful `collect` calls in the nine hours to 2026-09-02T03:22Z. The ENS/IPFS interface at `fun.noxa.eth.limo` still serves and still does exactly what it promised: browse, and claim V1 fees. It knows nothing about V2.
>
> **Docs are stale and wrong.** `docs.noxa.fi/contracts/noxa-fun/` still lists the disabled V1 factory as the Robinhood Launch Factory, re-confirmed on 2026-09-03, and lists the Robinhood V1 *locker* address as Monad's Launch *Factory*. Read the frontend chunk constants or the chain, never the docs.
>
> **Open question.** No on-chain link ties the V2 owner to `dev.noxa.eth` or `treasury.noxa.eth`. The circumstantial case is strong (it controls `noxa.fi`, the docs and `@NoxaLaunchpad`) but "same team" is unproven, and there is a competing live deployment under the same brand.

## 3. Proposed playbook additions

Each of these cost this session real time or would have.

### For section 0 or a new "before you trust the brief" note

**A platform's own shutdown announcement is a claim, not a state.**
The section 5.11 brief, three market articles and DefiLlama all describe Noxa as permanently launch-disabled since 2026-07-11.
All of that is true of one factory and false of the platform: the same operator shipped a new factory eight days later and has launched 1,090 tokens through it since.
Two calls settled it, `launchingEnabled()` on the new factory and the timestamp of its most recent successful launch, and both should be the first thing any session does on a platform described as paused, dead or migrated.
The general rule: before writing "X is not possible", find the contract that would refuse and read its flag, and find the most recent successful attempt and read its timestamp.

**Look for more than one deployment under one brand.**
Noxa has three launchpad contract sets on this chain and two of them are live right now with different owners and different fee splits.
The cheap way to find them: grep every frontend bundle for the launch factory address rather than assuming the docs or one app tell you the whole story.
`noxa.io`'s bundle names its own `launchFactoryAddress`, `launchLockerAddress`, `feeRouterAddress`, `feeSplitterAddress` **and** `legacyLockerAddress`, which is what exposed the split.

### For section 3, ecosystem numbers

**An ERC-721 `balanceOf` on the position manager is an exact launch count for any locker-based launchpad.**
Every Noxa launch mints exactly one Uniswap V3 position NFT and transfers it to a locker with no release path, so `NonfungiblePositionManager.balanceOf(locker)` is the exact number of launches, in one call, with no log scan and no sampling.
That gave 60,142, 1, 1,090 and 171 for the four Noxa lockers, and the sum of two of them reproduced the app's own headline counter to the unit, which validated both numbers at once.
This is strictly better than the `allPairsLength()` trick in the current section 3 wherever the launchpad locks LP, and it works even when the factory is unverified.

**A backend "progress" percentage can be inverted into the exact threshold.**
`marketCapWeth / (graduationPct/100)` returned 20.0000 for all twelve sampled Noxa tokens, giving the graduation threshold to four decimal places without any documentation.
Sample a dozen, not two, and check that the implied constant is identical, which is what distinguishes a real threshold from a coincidence.

### For section 4, contracts

**A PUSH4 scan plus one decoded production call plus a keccak check fully recovers an unverified factory's admin surface.**
The scan named `launchingEnabled()`, `setLaunchingEnabled(bool)`, `allTokensLength()` and `MAX_LAUNCH_FEE()` on Noxa's unverified V2 factory.
The two selectors it could not resolve, `0xd9a4add3` and `0x89e00a3a`, were recovered by word-dumping a real call's calldata, reconstructing the tuple from the field values, and confirming with `keccak(signature)[:4]`.
Both matched exactly, which turns an inference into a fact:
`launchToken((string,string,string,string,(string,string,string,string,string)),uint256,uint256,bytes32)` and
`setLaunchConfig(uint256,(uint256,uint16,uint16,uint32,int24,uint256,uint16,bool))`.
Always hash the candidate signature before writing it down; guessing a plausible name and never checking is how wrong ABIs get archived.

**A verified sibling of an unverified contract is often the whole documentation.**
Noxa's V2 factory is unverified but its locker is verified, and the locker declares `interface ILaunchFactory { getLaunchedToken(address) returns (LauncherTypes.LaunchedToken) }` with the full struct, which is the factory's own storage layout.
Same trick as Flap's `IPortal.sol` in the current section 4, but from a callee rather than a sibling implementation.

**Trace one real fee collection before believing a fee-share getter.**
`LaunchLockerV1.protocolFeeShare()` reads 100 on a 0-to-100 percent scale, which looks like the protocol taking everything.
The token-transfer list of an actual `collect` shows it routes 100% to a fee collector that keeps nothing, burns the token side and pays the whole WETH side to the creator.
Reading the getter alone would have put the exact opposite of the truth in the README.
`transactions/<hash>/token-transfers` on Blockscout is one request and gives the whole flow in order.

### For section 6, environment

**Jina Reader is blocked on x.com under a shared abuse penalty.**
`r.jina.ai/https://x.com/...` returned `AbuseAlleviationError ... blocked until <timestamp> due to previous abuse found on <someone else's profile>`, so the block is global to the domain and not caused by this session.
`bdata scrape https://x.com/<handle>` worked immediately for both a profile and a single status and returned the post text, so it is the fallback for X, not Jina.

**X syndication is per-account and can be stale rather than empty.**
The existing playbook note covers empty responses.
Add: `@Noxa_Fi` returned 99 entries but nothing newer than late 2025, so the size and entry count both look healthy while the timeline is a year out of date.
Check the newest `created_at` in the payload, not just `len(entries)`.

**A launchpad backend can be completely open.**
`api.noxa.fi` needs no key, no browser User-Agent and no Cloudflare workaround, and serves tokens, trades, holders, candles and comments.
Probe `<api-host>/api/health` before building any browser harness.

### For section 8, finish checklist

Add: **check for byte-identical screenshots** (`md5 screenshots/*.png | sort | uniq -d`).
Two inherited pairs in this archive were duplicates, so two documented "distinct views" were the same image.

## 4. What is on disk

Run from `resources/launchpads/noxa/`:

| directory | count |
| --- | --- |
| `pages/` | 72 |
| `screenshots/` | 24 (22 inherited, 2 taken this session) |
| `contracts/` | 23 directories (17 with verified sources, 6 bytecode only) plus `ADDRESSES.md` |
| `socials/` | 9 |
| `_raw/` | 331 files |
| `README.md` | yes, all nine sections plus a "what remains usable" block and an explicit answer to the launching question |
| `LINKS.md` | yes, 1,664 rows over 1,071 distinct URLs |

New this session under `_raw/`:
`indexer/doppler-check-2026-09-03.txt`,
`selectors/push4-{newfactory,factory,feecollector}.txt`,
`rpc/derived-economics-2026-09-03.txt`,
`rpc/v1-fee-flow-2026-09-03.txt`,
`tools/{rpc.py,mkcontract.py,mkpages.py,mklinks.py,linkshots.py}`,
`jina-2026-09-03/` (5 files),
`bundles-ens/index-DsXVcCyP.js`,
`browser/noxaio-launch-2026-09-03.txt`,
`api/live-2026-09-03-*.json` (9 files),
`socials/{syndication-*.json,syndication-*.html,syndication-Noxa_Fi-posts.txt,bdata-x-halt-announcement.md,bdata-x-NoxaLaunchpad-2026-09-03.md}`,
and 14 further Blockscout records including the whole noxa.io contract set.

`pages/`, `LINKS.md` and the screenshot links are all regenerable: `python3 _raw/tools/mkpages.py && python3 _raw/tools/linkshots.py && python3 _raw/tools/mklinks.py`.

## 5. Housekeeping

- The agent-browser session `noxa-archive` was opened and closed by name. `lp-pools-trade` and `glumbo` were left alone and `close --all` was never used.
- No transaction was signed and the shared test wallet was not touched.
- No file outside `resources/launchpads/noxa/` was created or modified.
