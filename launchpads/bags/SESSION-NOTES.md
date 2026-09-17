# Bags session notes (Session B, 2026-09-02)

This file carries what would otherwise have been edited into `SCRAPING-PLAN.md` and `PLAYBOOK.md`, because two other sessions were running in parallel and this is not a git repo.
Merge the three blocks below into those files at the end of the parallel run.

## 1. Row for SCRAPING-PLAN.md part 4.4

| Slug | Raw captures | pages/ | screenshots/ | contracts/ | socials/ | LINKS.md | README.md | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `bags` | 594 files under `_raw/` (5 GitHub clones with 300 files, 94 Blockscout JSON, 130 Jina pages, 32 browser reads, 12 socials, 8 API captures, 7 Tavily, 6 RPC state dumps, 2 Dexscreener, 1 network log), Doppler indexer check, decoded launches; 1666 files in the directory overall | 137 | 20 | 28 dirs (26 verified, 2 bytecode) | 7 | yes, 965 rows | yes, 9 sections | **Done** 2026-09-02 |

Counts were taken with `find <dir> -type f | wc -l` on 2026-09-02 after the session finished; the `_raw/` count includes `.git` internals of the clones, and `contracts/` holds 905 files across its 28 directories.

## 2. Findings block for SCRAPING-PLAN.md section 5.4

- Not Doppler-derived: zero assets on `indexer-prod.doppler.lol` for the factory, vault, hook, deployer and v1 factory under all three of `integrator`, `poolInitializer` and `liquidityMigrator` (`bags/_raw/api/doppler-indexer-check-2026-09-02.json`).
- Stack: own `BagsBondingCurve` (virtual x*y=k in native ETH) plus own `BagsV4Hook` on the canonical Uniswap v4 PoolManager and PositionManager; per token an EIP-1167 `BagsToken` clone and two `BeaconProxy` instances (curve, fee share).
- Economics, all read from chain: 2% fee on the ETH leg in both phases, 50/50 creator and protocol, partner 25% of the protocol half (0.25% of volume) when set; creation fee is 0 since 2026-07-13 (docs still say 0.02 ETH); graduation at 5 ETH net; 830M on the curve, 170M plus 5 ETH into a full-range v4 pool with LP fee 0, hook fee 2%, liquidity locked by the hook; LP NFT to the platform key; no vesting, no creator allocation, no anti-snipe beyond an atomic `createAndBuy`.
- Curve maths: launch price 1.2339e-9 ETH per token (FDV 1.23 ETH), graduation price 2.9412e-8 (FDV 29.41 ETH, 23.8x), 5.102 ETH gross to fill, 0.102 ETH of fees on the way, pool worth 10 ETH at graduation (`bags/_raw/rpc/derived-economics-2026-09-02.txt`).
- Control: one EOA `0xDEf671F11C8a30818eb3D9Cc9476EEEc805f9058` owns the factory (UUPS), vault (UUPS), both beacons (can upgrade every live curve and fee share at once), is `platformAdmin` on every curve (pause) and owns every per-token fee share (`setClaimers`, forward-only). No upgrade has happened since deployment.
- Undocumented v1 stack: factory `0x46aD...4D40` deployed 2026-07-10 by a different key, 314 launches until 2026-07-30, hook `0x2083...6EcC`, vault `0x26e4...ab80`; v1 charged the partner cut to the creator half, v2 charges it to the protocol half.
- Ecosystem: 3934 v2 plus 314 v1 launches by block 52761706; 33.8 launches per day over the newest 100; 38 `Migrated` events on chain (23 on the live hook), so about 0.9% graduate; vault holds 28.17 ETH; DefiLlama attributes $585,729 all-time fees on Robinhood Chain to Bags.
- App: four-step wizard, wallet gated at the claimer editor and at "Login to launch" (Privy). Everything after the gate was reconstructed from three decoded production launches (BARRY, RHOBOT, POINTLESS) and the BARRY graduation transaction.
- Index tokens ("Stock dividends" mode) are ordinary launches with the Bags claimer wallet `0x6828...055a` as sole claimer at 10000 bps plus an API registration; RHOBOT is a live example.
- Gaps: no X posts (Bright Data pipeline shape), Discord shell only, no team names, partner `0x40FA...6a7` on 22 in-progress launches unidentified, vault withdrawals not enumerated, 38 versus 33 graduation count not reconciled, no audit found.

## 3. Additions for PLAYBOOK.md

### Session hygiene

- A killed session can leave an archive that is far more complete than the plan's status table says. Run the inventory command and `ls` every subdirectory before believing any status row. This session found about 1660 files, `LINKS.md`, `contracts/ADDRESSES.md`, 137 pages, 20 screenshots and 7 socials already on disk where the table said "103 pages, 1 screenshot, 0 contracts".
- Check for a derived-numbers scratch file (`_raw/rpc/derived-economics-*.txt` here) before recomputing anything; the previous attempt had already done the curve maths and stored it.

### Mintlify docs (docs.bags.fm is Mintlify, not GitBook)

- Appending `.md` to a page path works on Mintlify too and returns the MDX source with `<Note>`, `<Warning>`, `<Card>` tags intact. `sitemap-pages.xml` returns 404 on Mintlify. The previous attempt saved the sitemap as `_raw/tavily/sitemap-docs.xml` and `llms.txt` as `_raw/jina/llms.txt`, so both exist; re-checking `/sitemap.xml` and `/llms.txt` from this sandbox returned HTTP 000 and 000, so send a browser User-Agent and retry if they fail.
- The OpenAPI spec behind the API reference is one JSON document; the copy at `_raw/api/openapi.json` (61 paths) is cheaper and more complete than the per-endpoint pages and lists every server URL and schema.

### Bags-specific shortcuts for anyone building against it

- `GET https://api2.bags.fm/api/v1/evm/rh/pulse` needs no key and returns `new`, `soon` and `bonded` lists with curve, fee share, poolId, version, price, progress and 24h volume per token. It is the fastest way to see the whole Robinhood Chain population.
- `BagsLens.getTokenState(token)` on `0xC82D...d595` returns curve, feeShare, poolId, migrated flag, price and progress in one `eth_call`.
- Beacon proxies: `eth_getStorageAt(proxy, 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50)` is the EIP-1967 beacon slot; the beacon's `implementation()` gives the logic. Both beacons here resolve to the addresses in `contracts/ADDRESSES.md`.
- Blockscout has not matched the bytecode of `BeaconProxy` fee shares or the `BagsToken` clones, so per-token fee shares and tokens show as unverified even though their logic is verified at the implementation. Do not spend time re-verifying them; record the beacon slot and move on.

### Bright Data limits met

- `bdata pipelines x_posts` only accepts `https://x.com/<user>/status/<id>` URLs, and there is no `x_profiles` pipeline. For a profile without known post ids, use Jina on the profile URL for the header and record the post gap.

### Other

- `agent-browser session list` prints the session name right after a `close` even when the browser is gone; a second `session list` shows "No active sessions". Do not loop on it.
- A curl to Blockscout for a transaction hash you do not already have costs about a second; the two factory creation transactions were the only Blockscout requests this session needed to make, everything else was already in `_raw/`.
