# Long session notes, 2026-09-02

Written by the Long session (Session A) for the session that merges the three parallel runs.
This file exists because `SCRAPING-PLAN.md` and `PLAYBOOK.md` were off limits while the runs were in flight.
Nothing in `resources/launchpads/doppler/` was edited.

## 1. Status row for SCRAPING-PLAN.md part 4.4

| Slug | Raw captures | pages/ | screenshots/ | contracts/ | socials/ | LINKS.md | README.md | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `long` | 297 files: Jina, Bright Data, Blockscout, indexer samples, 50 decoded launches, live hook state via RPC, X syndication timelines | 58 | 8 | 24 dirs (23 verified plus the AI clone) | 5 | yes | yes | **Done** 2026-09-02 |

## 2. Findings block for SCRAPING-PLAN.md section 5.3

**Done 2026-09-02.** Findings a later session should not have to rediscover.

- Long is exactly Doppler plus one router. `LongLauncher.create` forwards an unchanged `Airlock.create` after enforcing a 24 hour, letters-only, 15 character ticker reservation. It takes no fee and is not an Airlock module.
- Every Long pool attaches the non-canonical Rehype hook `0x6f02324d...` through `InitData.dopplerHook`. It is enabled (`isDopplerHookEnabled` = 3) even though it is not an Airlock module; the Doppler archive's `not whitelisted` refers to the module registry only.
- Two fee streams per pool. LP fee 0.1% (95% creator, 5% Doppler Safe, claim with `collectFees(poolId)` on DopplerHookInitializer). Hook fee 80% at launch decaying to 1.12% over ten seconds, 5% of it reserved for the Doppler Safe, the rest converted to the stock token and sent to Long's EOA `0x92d435c9...` inside the swap. Long earns about nine times the creator's income and in the stock token. The EOA holds about $4.48M.
- AI-paired launches use 0.5% LP and 0.4% hook fee with everything routed to a no-code EOA `0x35d217b1...`, effectively a lock. July launches used 0.7% LP and 0.8% hook.
- No launch fee, no threshold, no vesting, no creator allocation, 1B fixed supply, 100% on the curve, opening market cap about $20K, 99.1% of supply in one 62,500x-wide position plus a 0.9% tail to the max tick. The token address is mined client-side to end in `1e18`.
- Anti-snipe is the 80% opening hook fee; Doppler's `maxBalanceLimit` is zero.
- `getBeneficiaries(asset)` is stale after `updateBeneficiary`; `getShares(poolId, address)` is the live view. AI's 95% slot belongs to a community splitter, not to the address `getBeneficiaries` returns.
- Community mode v2 (`LongFeeVaultFactory`, 26 vaults) burns the asset share, pays the creator 20% or 50%, and hands the rest to a hardcoded Long ops EOA. Its natspec says it carries no creator guarantees.
- Long is the second integrator on 4663 by count (13,802 of 109,404 assets; Bankr has 88,764) and the first by current rate (about 77 launches an hour on the capture day).
- The app is Cloudflare-hardened: every headless browser and every curl to `api.long.xyz` gets a 403. Jina Reader and Bright Data's unlocker get through for reads. The create form is behind Privy and was never rendered; the bundle constants and fifty decoded launches reconstruct it exactly.
- No docs site exists. The only document is the LongX litepaper at `app.long.xyz/litepaper`, about the leveraged-token side product on Lighter, not the launchpad.
- Third parties launch through Long's launcher with their own integrator address: `0x9adf17b7...` (the Doppler archive's unlabelled 921-asset integrator) does so from `0x4ef489fd...`.

## 3. Corrections for the Doppler archive

Listed in `README.md` section 9 item 10.
**Applied to `resources/launchpads/doppler/README.md` on 2026-09-02** at the user's request, once no parallel session was touching that directory; the Doppler README ends with a `Corrections merged from the Long session` list so the merge session does not need to redo them.
In short: the `four in five` share is recent-only and Bankr leads cumulatively; the non-canonical Rehype deployment is the production one and is enabled as a hook; `getShares` beats `getBeneficiaries`; `0x9adf17b7...` is a Long-launcher user; and Long shows the fee-schedule anti-snipe path in production.

## 4. Additions for PLAYBOOK.md

- **Cloudflare-hardened apps.** When `agent-browser` gets `Sorry, you have been blocked` on the first page load, stop trying browsers and go straight to Jina Reader for pages, `bdata scrape -f screenshot` with an absolute `-o` path for screenshots, and the chain for state. The wallet-gate method in section 5 needs a page to load first and cannot help here. Note that Bright Data's residential unlocker refuses x.com on compliance grounds; the X syndication endpoint `https://syndication.twitter.com/srv/timeline-profile/screen-name/<handle>` returns the most recent timeline page as JSON inside `__NEXT_DATA__` and needs no key.
- **Read the bundle for the create form.** A Next.js app's launch parameters live in a constants block (`e.s([...])` export lists in the chunk that mentions the API host). Grep the chunks for the integrator address to find the chain config and for `START_FEE` or `INITIAL_SUPPLY` to find the defaults. That plus decoded calldata reconstructs a wallet-gated form completely.
- **Decode fifty, not two.** `addresses/<launcher>/transactions` returns fifty decoded calls in one request; decoding all of them with the script in `long/_raw/api/decoded-launcher-recent-50.txt` surfaces every template and every non-app caller at once. Group by `fee`, `endFee`, `feeDistributionInfo`, `buybackDst`, `integrator`.
- **`getShares`, not `getBeneficiaries`,** for any Doppler-derived platform that lets creators move their fee slot.
- **Uniswap v4 dynamic-fee pools hide the LP fee.** `getState` returns `fee = 0x800000`; read the real fee with `StateView.getSlot0(poolId).lpFee`.
- **`echo ====` breaks in zsh.** `=word` is an equals expansion; quote separators.
- **Jina PDF extraction works on app routes that serve PDFs**, but a direct `curl` of the same route behind Cloudflare returns the challenge page; keep the extracted text and record the failure.
- **Subagents still die on the session limit.** This session launched Bags and Virtuals as two background agents at the user's request; both were terminated by the account session limit within the hour, exactly as part 0 of the plan warned. Run the remaining platform sections as separate top-level sessions after the limit resets.

## 5. Tools left behind

- `_raw/tools/mkcontract.py`: the Doppler builder adapted to this archive's raw file naming (`smart-contracts-<Role>-<addr>.json` or `smart-contracts-<addr>.json`). Feed it `Role|address|note` lines on stdin.
- `_raw/tools/mkpages.py`: regenerates `pages/` from `_raw/`; safe to rerun.
- `_raw/tools/rpc.py`: a twelve-line `eth_call` helper over `eth_abi` for reading contract state without an ABI file.
- `_raw/api/decode_launch.py` (from the earlier run) and the inline decoder at the top of `_raw/api/decoded-launcher-recent-50.txt`.
