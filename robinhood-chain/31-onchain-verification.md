# On-Chain Verification Snapshot

Everything on this page was read directly from Robinhood Chain mainnet, not from documentation.
Method: Alchemy archive RPC (`ALCHEMY_ROBINHOOD_MAINNET_URL`) plus Multicall3 batching, read-only `eth_call` / `eth_getCode` only.
No transactions were sent and no private key was used.

**Captured:** 2026-08-12, block 34,251,364.
**Re-verified:** 2026-09-02 at block 52,266,372 (roster at 52,437,900), and 2026-09-03 at block 53,117,114.
The three re-verification sections are at the bottom of this file, newest last.
Read them before quoting any number above: gas price and the multiplier table have both moved, and two tables above carry corrections made on 2026-09-03.
The environment variable is `ALCHEMY_MAINNET_URL` in `.env`; the name `ALCHEMY_ROBINHOOD_MAINNET_URL` used just above is how the August pass referred to it and no longer matches the file.

---

## Chain parameters (verified)

| Property | Value | How verified |
| --- | --- | --- |
| Chain ID | 4663 (`0x1237`) | `eth_chainId` |
| Client | `nitro/v3.11.2-3599aca/linux-amd64/go1.25.11` | `web3_clientVersion` |
| Block height at capture | 34,251,364 | `eth_blockNumber` |
| Observed block time | ~0.1 s | timestamp delta over 100 blocks |
| Gas price | 42,584,000 wei (~0.0426 gwei) | `eth_gasPrice` |
| Base fee per gas | 42,584,000 wei | `eth_getBlockByNumber` |
| Block gas limit | 1,125,899,906,842,624 (2^50, Arbitrum sentinel) | `eth_getBlockByNumber` |

The 2^50 gas limit is the standard Arbitrum Nitro placeholder. Real capacity is bounded by the L2 gas
price mechanism and the L1 data fee, not by this number. Do not treat it as a per-block budget.

## Contract deployments (verified via `eth_getCode`)

| Contract | Address | Bytecode |
| --- | --- | --- |
| L2 Gateway Router | `0x1E324B9316138CA9a73F960213621AD1aaf01B89` | 2,202 B |
| L2 ERC20 Gateway | `0xfd9b17206278C16DdaacF6AC8f05dBf97EdCb31e` | 2,202 B |
| L2 Arb-Custom Gateway | `0x912285144fC0f6e89d3Ed16F5Ab72f87A1878959` | 2,202 B |
| L2 Weth Gateway | `0x1D187C3E2dA52D72BC9C41e3AbA0fdFa6a7bF055` | 2,202 B |
| WETH | `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73` | 2,202 B |
| USDG | `0x5fc5360D0400a0Fd4f2af552ADD042D716F1d168` | 170 B (proxy) |
| L2 Proxy Admin | `0xa3Acd31AFb851B4eB9DAD00F5204c01D924267dF` | 1,681 B |
| L2 Multicall (per docs) | `0x2cAC2D899eCC914d704FeaAE33ac1bF36277DaD1` | 3,339 B |
| **Multicall3 (canonical)** | `0xcA11bde05977b3631167028862bE2a173976CA11` | 3,808 B |
| Permit2 | `0x000000000022D473030F116dDEE9F6B43aC78BA3` | 9,152 B |
| Chainlink Data Streams VerifierProxy | `0xcE73c8ad08CBDEaCa6078BF0627C8fe0a9a536E7` | 7,009 B |
| ERC-4337 EntryPoint v0.6 | `0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789` | 23,689 B |
| ERC-4337 EntryPoint v0.7 | `0x0000000071727De22E5E9d8BAf0edAc6f37da032` | 16,035 B |
| ERC-4337 EntryPoint v0.8 | `0x4337084D9E255Ff0702461CF8895CE9E3b5Ff108` | 21,738 B |
| CREATE2 deployer (Arachnid) | `0x4e59b44847b379578588920cA78FbF26c0B4956C` | 69 B |
| ArbSys precompile | `0x0000000000000000000000000000000000000064` | 1 B (precompile stub) |
| ArbGasInfo precompile | `0x000000000000000000000000000000000000006C` | 1 B (precompile stub) |
| NodeInterface | `0x00000000000000000000000000000000000000C8` | **0 B** |

Two things worth knowing that the docs do not say:

- **Multicall3 is deployed at its canonical cross-chain address.** The docs only list the Arbitrum
  `L2 Multicall`. Multicall3 is present and works, which makes batched reads far cheaper - this whole
  verification pass used it to read 960 token fields in 4 RPC calls.
- **`NodeInterface` has no bytecode**, which is correct and expected. It is a virtual contract simulated by
  the node during `eth_call`; it is not a real deployment. Never `eth_getCode`-gate on it, and never
  try to call it from a contract - it only works from an off-chain `eth_call`.
- **CREATE2 deployer is present**, so deterministic cross-chain addresses work with Foundry's default
  `--create2-deployer`.

## Stock Token architecture (discovered on-chain, not documented)

Every one of the 96 Stock Tokens has **identical 284-byte bytecode**. They are not independent
deployments - they are **beacon proxies** pointing at one shared beacon:

| Role | Address |
| --- | --- |
| Shared beacon | `0xe10B6f6B275De231345c20d14aB812DB62151B00` |
| Shared implementation | `0xb35490d6f9163de4f80d88dc75c3516eb64c5ae2` (11,614 B) |

Verified by reading ERC-1967 beacon slot
`0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50` on a token, which returned the
beacon address, and by calling `implementation()` on the beacon.
The ERC-1967 implementation slot is zero on the tokens, confirming beacon rather than transparent/UUPS proxying.

**Why this matters for anything you build:** a single beacon upgrade changes the logic of all 96 Stock
Tokens simultaneously. Token behaviour is not immutable, and the upgrade is not per-token. If your
protocol takes Stock Tokens as collateral, this is a governance dependency you are inheriting, and it is
not mentioned anywhere in the Robinhood documentation. `owner()` on the beacon reverts, so the upgrade
authority is not exposed through the standard Ownable interface - identify the controlling address from
Blockscout before assuming who holds it.

## ERC-8056 interface (confirmed present on every token)

Probed on `0x1Cdad396DB64BDa184d5182A97Dd9B3C62100b7D`, then read across all 96 tokens.

| Function | Selector | Result |
| --- | --- | --- |
| `uiMultiplier()` | `0xa60bf13d` | works |
| `newUIMultiplier()` | `0xdc767007` | works |
| `effectiveAt()` | `0x97a4064f` | works |
| `totalSupplyUI()` | `0x9bea6429` | works |
| `balanceOfUI(address)` | `0x437a9958` | works |
| `oraclePaused()` | `0x7706ba52` | works |
| `uid()` | `0xf514ce36` | works |
| `owner()` / `version()` / `isin()` / `oracle()` | - | **revert - not exposed on-chain** |

ISIN is available from the REST registry (`/rhj/assets`) but **not** from the token contract.

## Registry cross-check: REST API vs on-chain

All 96 tokens were read on-chain and compared field by field against `GET https://api.robinhood.com/rhj/assets`.

**Zero mismatches** on symbol, name, decimals, `uiMultiplier`, and `uid`. The REST registry is a faithful
mirror of chain state, so it is safe to use for discovery. Still read prices and multipliers on-chain when
they drive money movement.

Also confirmed by arithmetic across all 96 tokens:

```
totalSupplyUI() == totalSupply() * uiMultiplier() / 1e18
```

This holds exactly (within 1 wei of integer truncation), which confirms the multiplier is applied as a
pure view-layer scale and that the tokens are genuinely non-rebasing.

## Live state at capture

- All 96 tokens: `decimals() == 18`, status `ASSET_STATUS_ACTIVE`, all deployed only on chain 4663.
- `oraclePaused() == true`: **none**. No corporate action was mid-flight.
- `uiMultiplier() != 1.0` on 7 tokens:

| Symbol | Multiplier | Reading |
| --- | --- | --- |
| CRWD | 4.000000000000000000 | a 4:1 forward split already applied |
| SGOV | 1.002981519346766532 | accrued dividend reinvestment |
| ORCL | 1.002210914971013375 | accrued dividend reinvestment |
| COST | 1.000612040296259656 | accrued dividend reinvestment |
| ASML | 1.000101323251417769 | accrued dividend reinvestment |
| MU | 1.000074823219171086 | accrued dividend reinvestment |
| DELL | 1.000063708620124549 | accrued dividend reinvestment |

The COST and ASML rows are corrected values.
The original write-up rounded them to `...259700` and `...417800`; an archive `eth_call` replayed at block 34,251,364 on 2026-09-03 returns `...259656` and `...417769` (`_raw/onchain-2026-09-03/august-block-34251364-multipliers-reread.json`).
Every other row in this table was confirmed byte-exact by the same replay.

- `effectiveAt() != 0` on those same 7 tokens, with timestamps in the **past**. `newUIMultiplier()` equals
  the current `uiMultiplier()` for all of them, and the REST API reports `pendingMultiplier: ""`.
  So these are completed updates, not scheduled ones. `effectiveAt` is not cleared after a multiplier
  update lands - it retains the timestamp of the last change. **Do not treat a non-zero `effectiveAt()` as
  "an update is pending."** Compare `newUIMultiplier()` against `uiMultiplier()`, or check
  `effectiveAt() > block.timestamp`, to detect a genuinely scheduled change.

## Chainlink feeds

All 56 feeds listed for Robinhood Chain were called via `latestRoundData()`. **All 56 returned live data**
and none were stale beyond twice their heartbeat. 35 are Robinhood tokenized-equity feeds; 21 are
crypto, stablecoin, and exchange-rate feeds. See `11-chainlink-feed-addresses.md` for the full table.

Two gaps found against the documentation:

1. **Only 35 of 96 Stock Tokens have a Chainlink feed.** The docs state that every Stock Token has a
   live price feed. 61 tokens had none at capture time. Handle the missing-feed case explicitly.
2. **No L2 Sequencer Uptime Feed is published for Robinhood Chain.** The docs recommend checking one
   before trusting a price, and give sample code, but the Chainlink directory lists no such feed for this
   network. That best practice is currently not actionable here; confirm with Chainlink before designing
   around it.

A third thing to note: on-chain `description()` is inconsistent across the equity feeds. Some return
`Robinhood NVDA / USD`, others return the short form `RHNVDA / USD`. Do not match feeds by parsing
`description()`.

## Reproducing this

The raw captures are in `_raw/`:

| File | Contents |
| --- | --- |
| `rhj-assets.json` | REST asset registry response (96 assets) |
| `onchain-tokens.json` | 10 fields read from each of the 96 token contracts |
| `chainlink-feeds-robinhood-mainnet.json` | Chainlink reference directory for this chain |
| `onchain-feeds.json` | `latestRoundData()` / `decimals()` / `description()` for all 56 feeds |
| `chain-info.json` | Chain parameters at capture |
| `rh-batch*.json`, `ext-batch*.json` | Tavily page extractions |
| `map-robinhood.json` | Tavily site map of `docs.robinhood.com/chain` |


---

## Re-verified 2026-09-02

Same method as above: Alchemy archive RPC (`ALCHEMY_MAINNET_URL`, host `robinhood-mainnet.g.alchemy.com`), Multicall3 `aggregate3`, read-only `eth_call`, `eth_getCode`, and `eth_getStorageAt`.
No transactions were sent and no private key was used.
Chain parameters were read at block **52,266,372**; the token roster was read at block **52,437,900** because the session was interrupted between the two passes.

### Chain parameters

| Property | 2026-08-12 | 2026-09-02 | Note |
| --- | --- | --- | --- |
| Chain ID | 4663 (`0x1237`) | 4663 (`0x1237`) | unchanged |
| Client | `nitro/v3.11.2-3599aca/linux-amd64/go1.25.11` | `nitro/v3.11.3-beb2108/linux-amd64/go1.25.12` | patch release |
| Block height | 34,251,364 | 52,266,372 | 18.0 M blocks in 21 days |
| Observed block time | ~0.1 s | 0.1 s (100 blocks in 10 s, blocks 52,266,272 to 52,266,372) | unchanged |
| Gas price (`eth_gasPrice`) | 42,584,000 wei (0.0426 gwei) | 360,574,000 wei (0.361 gwei) | about 8.5x higher |
| Base fee (`eth_getBlockByNumber`) | 42,584,000 wei | 474,862,000 wei at block 52,266,850 | moving value |
| Blockscout gas oracle | not captured | slow 0.38 / average 0.52 / fast 0.98 gwei | `GET /api/v2/stats` |
| Block gas limit | 2^50 | 2^50 | Arbitrum sentinel, unchanged |

### Contract deployments (`eth_getCode`)

Every address in the table above returned exactly the same byte count as on 2026-08-12, including `NodeInterface` at 0 B.
Two Uniswap Universal Router candidates were added to the check because the archive documented a discrepancy between them:

| Contract | Address | Bytecode | Verified on Blockscout |
| --- | --- | --- | --- |
| Universal Router (v4 docs page, SDK, Trading API) | `0x8876789976decbfcbbbe364623c63652db8c0904` | 24,546 B | yes, `UniversalRouter`, solc 0.8.26, verified 2026-05-26 |
| Universal Router (`deployments.json`) | `0x06AfBA43Fd06227fA663b0DAecF536f6EaA6bf99` | 24,546 B | yes, `UniversalRouter`, solc 0.8.26, verified 2026-07-06 |

**Both have bytecode**, so `eth_getCode` alone does not settle the discrepancy.
The two bytecodes differ (different sha256), and the only difference in their decoded constructor arguments is the last field, `spokePool` (Across): `0x7332D11BD10d18A04B119Cd4671a96f3148002c4` on `0x8876...0904` versus `0xD29C85F15DF544bA632C9E25829fd29d767d7978` on `0x06Af...bf99`.
All other constructor fields are identical (Permit2, WETH, v2 factory `0x8bcE...937f`, v3 factory `0x1f7d...2EfA`, v4 PoolManager `0x8366...0951`, v3 NFT position manager `0x7399...E0D3`, v4 position manager `0x58da...4fA7`).
Both were deployed through the Arachnid CREATE2 deployer.

What actually routes on this chain:

- The Uniswap Trading API `POST /v1/swap` for a chain 4663 quote returned `to: 0x8876789976dEcBfCbBbe364623C63652db8C0904` (live test, `_raw/apis-2026-09-02/uni-swap-code.txt`).
- `@uniswap/universal-router-sdk` `constants.ts` lists chain 4663 with only `V2_1_1: 0x8876789976decbfcbbbe364623c63652db8c0904`, creation block 18,127 (`_raw/apis-2026-09-02/uniswap-universal-router-sdk-constants.ts`).
- The Trading API supported-chains page lists `0x8876...0904` as the Universal Router 2.1.1 for Robinhood Chain, no 2.0 deployment, and says the API defaults to 2.1.1 on this chain.

**Conclusion:** use `0x8876789976decbfcbbbe364623c63652db8c0904` as the Universal Router on Robinhood Chain.
`0x06AfBA43Fd06227fA663b0DAecF536f6EaA6bf99` is a real, later deployment wired to a different Across SpokePool; nothing in Uniswap's SDK or API references it, and `deployments.json` was unchanged since 2026-08-22, so treat it as an alternate deployment until Uniswap documents its purpose.

### Stock Token roster

| Measure | 2026-08-12 | 2026-09-02 |
| --- | --- | --- |
| Active assets in `GET /rhj/assets` | 96 | 194 |
| Deployed on chain 4663 | 96 | 194 (no other chain listed) |
| Added since August | - | 98 |
| Removed since August | - | 0 |
| Address changes among the original 96 | - | 0 |
| Proxy bytecode | 284 B (as written in August) | 283 B, sha256 `399ec4bc5b43db03...`, identical on old and new tokens |
| Beacon slot on a new token | - | `0xe10B6f6B275De231345c20d14aB812DB62151B00` (same beacon) |
| Beacon `implementation()` | `0xb35490d6...5ae2` | `0xb35490d6f9163de4f80d88dc75c3516eb64c5ae2` (unchanged, 11,614 B) |
| Beacon bytecode | - | 2,332 B |
| `decimals() == 18` | 96 of 96 | 194 of 194 |
| `oraclePaused() == true` | none | none |
| `newUIMultiplier() != uiMultiplier()` | none | none (no scheduled change) |
| `totalSupplyUI == totalSupply * uiMultiplier / 1e18` | holds on 96 | holds on 194 |
| REST vs on-chain mismatches (multiplier, uid) | 0 | 0 |

The 283-byte figure is a correction of the August text, not an on-chain change: proxy bytecode cannot change after deployment, and old and new tokens hash identically.
The 98 additions are all beacon proxies on the same beacon, so the single-upgrade-point warning above now covers 194 tokens.

Added symbols: ABCL, ADBE, AEHR, AEIS, ALAB, AMBA, AMC, AMKR, ANET, APP, AUR, AVAV, AXON, AXTI, BB, BND, BULL, CEG, CIEN, CLOV, CLS, COHR, CRDO, CRM, CSCO, CTSH, CVNA, DJT, DOCN, EWT, FICO, FIG, FISV, FIX, FLY, FTNT, GE, GEV, GLD, GLXY, HII, HIMS, HPE, HWM, IBM, IBRX, INDA, INFQ, JBL, JNJ, JOBY, KLAC, KSS, KTOS, LHX, LMT, LRCX, MOD, MPWR, MRNA, MTSI, NAVN, NET, OKLO, ON, ONTO, OUST, PANW, PATH, PFE, PL, POWL, PWR, RCAT, RUN, SCHD, SHY, SIMO, SLS, SMH, SMR, SNAP, SNOW, SOUN, TE, TEAM, TEM, TER, TTD, UNH, VICR, VRT, VSAT, VST, VTI, WDC, WULF, WYFI.

### Multipliers at block 52,437,900

Nine tokens carry a `uiMultiplier()` other than 1.0 (seven in August).

| Symbol | `uiMultiplier()` | `effectiveAt()` | Since August |
| --- | --- | --- | --- |
| CRWD | 4.000000000000000000 | 2026-07-02 13:30 UTC | unchanged |
| CCL | 1.021486444855206408 | 2026-08-31 15:10 UTC | changed from 1.000000000 |
| SGOV | 1.005101770003214918 | 2026-09-01 00:00 UTC | changed from 1.002981519 |
| ORCL | 1.002210914971013375 | 2026-07-27 15:10 UTC | unchanged |
| COST | 1.000612040296259656 | 2026-08-10 15:10 UTC | unchanged |
| AAPL | 1.000566080061092436 | 2026-08-14 15:12 UTC | changed from 1.000000000 |
| ASML | 1.000101323251417769 | 2026-08-06 15:10 UTC | unchanged |
| MU | 1.000074823219171086 | 2026-07-24 15:10 UTC | unchanged |
| DELL | 1.000063708620124549 | 2026-08-03 15:10 UTC | unchanged |

Eight of the nine `uiMultiplier()` values in this table are corrections made on 2026-09-03.
The figures first written here disagreed with `_raw/onchain-tokens-2026-09-02.json`, the raw capture they were supposed to come from, in the last two or three digits.
The values above are the ones in that file, and a fresh read on 2026-09-03 returned exactly the same integers for all nine (`_raw/onchain-2026-09-03/onchain-tokens-2026-09-03.json`).
Only CRWD was right as first written.

`effectiveAt()` still holds the timestamp of the last applied change on every one of these tokens, and `newUIMultiplier()` equals `uiMultiplier()` everywhere, so the detection rule from August stands: a non-zero `effectiveAt()` does not mean a change is pending.

#### Cross-reference added 2026-09-03: the 15:10 UTC accrual cluster now has a cause

Five of the timestamps above line up with the issuer's corporate-action feed, `https://api.robinhood.com/rhj/corporate-actions`.
For each, the published `processDate` maps to the `effectiveAt()` recorded here on the **next business day**.

| Symbol | Corporate-action process date | `effectiveAt()` recorded above | Gap |
| --- | --- | --- | --- |
| ASML | 2026-08-05 (Wed) | 2026-08-06 15:10 UTC (Thu) | next day |
| COST | 2026-08-07 (Fri) | 2026-08-10 15:10 UTC (Mon) | next business day |
| AAPL | 2026-08-13 (Thu) | 2026-08-14 15:12 UTC (Fri) | next day |
| CCL | 2026-08-28 (Fri) | 2026-08-31 15:10 UTC (Mon) | next business day |
| F | 2026-09-01 (Tue) | applied 2026-09-02 (Wed), see below | next day |

F is the tenth non-unity multiplier and is new since this section was written.
Its `currentMultiplier` on `https://api.robinhood.com/rhj/assets` was exactly 1.0 in the 2026-09-02 capture and is 1.000145502866134027 when read on 2026-09-03, which places the change on 2026-09-02, the business day after its 2026-09-01 process date.

CRWD, ORCL, MU and DELL cannot be explained this way.
Their `effectiveAt()` timestamps are 2026-07-02, 2026-07-27, 2026-07-24 and 2026-08-03, all earlier than 2026-08-05, which is where the corporate-action feed's rolling window starts.
So four of the ten non-unity multipliers have no explanation in that feed, and the feed cannot be used to reconstruct multiplier history beyond its window.
SGOV is a fifth exception for a different reason: it distributes monthly and its 2026-09-01 change does not map to a single action inside the window.

#### New observable for the next pass: `Completed` does not mean the token was adjusted

Seven of the twelve dividends marked `CORPORATE_ACTION_STATUS_COMPLETED` in that feed produced **no multiplier change at all**.
HWM, CTSH, FIX, SIMO, UMC, SHY and BND all return `currentMultiplier` of exactly `1.000000000000000000` on `https://api.robinhood.com/rhj/assets`, read live on 2026-09-03.
The five that did move are AAPL, ASML, CCL, COST and SGOV.
This breaks the obvious reconciliation rule.
A completed cash dividend on the issuer's feed is not sufficient evidence that the corresponding token's `uiMultiplier()` was touched, so any reconciliation between the feed and chain state has to check the multiplier directly rather than trust the status field.
Raw: `_raw/rhj-docs-2026-09-03/api-corporate-actions.json` and `_raw/docs-audit-2026-09-03b/ext/rhj-assets.json`.

### Chainlink feeds

The reference directory now lists **57** feeds for Robinhood Chain (56 in August).
The one addition is `CBBTC / USD`, proxy `0x0009cD492adf8167f9eEBf1293556A673530a21a`, 8 decimals, 86400 s heartbeat, 0.5% deviation.
The `latestRoundData()` figure originally recorded here for 2026-09-02, 7,722,325,588,557 (77,223.26 USD) at 08:30 UTC, was never written to a raw file and cannot be reproduced, so treat it as unsourced.
The feed was read from chain on 2026-09-03 and the sourced reading is in the next section.
No feed was read on-chain on 2026-09-02 at all: `chainlink-feeds-robinhood-mainnet-2026-09-02.json` is the Chainlink reference directory, that is, a published claim, not a chain read.
Equity feeds are unchanged at 35, so **159 of the 194 Stock Tokens have no Chainlink feed**.
No sequencer uptime feed is listed.

### RPC provider limits observed

- Alchemy free tier restricts `eth_getLogs` to a 10-block range on this network (error text: "Under the Free tier plan, you can make eth_getLogs requests with up to a 10 block range").
- `trace_block` and `arbtrace_block` are "not available on the ROBINHOOD_MAINNET" regardless of tier.
- `debug_traceBlockByNumber` requires a paid tier.
- `alchemy_getTokenMetadata`, `alchemy_getTokenBalances`, `alchemy_getAssetTransfers`, and `alchemy_getTransactionReceipts` all work on the free tier.
- Blockscout's API v2 rate limit is 10 requests per window per IP (`x-ratelimit-limit: 10`) and returns 429 with "Too many requests" once exceeded.

### Raw files for this pass

| File | Contents |
| --- | --- |
| `_raw/rhj-assets-2026-09-02.json` | REST asset registry response (194 assets, now includes `isin` and `tokenDecimals`) |
| `_raw/onchain-tokens-2026-09-02.json` | 8 fields read from each of the 194 token contracts at block 52,437,900 |
| `_raw/chainlink-feeds-robinhood-mainnet-2026-09-02.json` | Chainlink reference directory (57 feeds) |
| `_raw/chain-info-2026-09-02.json` | Chain parameters and Blockscout stats at capture |
| `_raw/apis-2026-09-02/eth_getCode-2026-09-02.txt` | Byte counts for every address in the deployment table plus both routers and the beacon pair |
| `_raw/apis-2026-09-02/universal-router-bytecode-sha256.txt` | Bytecode hashes of the two Universal Router candidates |
| `_raw/apis-2026-09-02/bs_ur_*.json` | Blockscout verified-source records for both routers, including decoded constructor arguments |
| `_raw/rh-batch*-2026-09-02.json`, `_raw/jina-2026-09-02/` | Page extractions for the docs drift check |
| `_raw/map-robinhood-2026-09-02.json` | Tavily site map of `docs.robinhood.com/chain` |

---

## Re-verified 2026-09-03

Same method again: Alchemy archive RPC (`ALCHEMY_MAINNET_URL`, host `robinhood-mainnet.g.alchemy.com`), Multicall3 `aggregate3` at `0xcA11bde05977b3631167028862bE2a173976CA11`, read-only `eth_chainId`, `web3_clientVersion`, `eth_blockNumber`, `eth_gasPrice`, `eth_getBlockByNumber`, `eth_getCode`, `eth_getStorageAt` and `eth_call`.
No transaction was sent and no private key was used.
Captured at 2026-09-03T03:56:25Z.
Every state read on this pass is pinned to a single block, **53,117,114** (`0x32a80ba`), so unlike the 2026-09-02 pass there is no split between a parameters block and a roster block.

### Chain parameters

| Property | 2026-09-02 | 2026-09-03 | Note |
| --- | --- | --- | --- |
| Chain ID | 4663 (`0x1237`) | 4663 (`0x1237`) | unchanged |
| Client | `nitro/v3.11.3-beb2108/linux-amd64/go1.25.12` | `nitro/v3.11.3-beb2108/linux-amd64/go1.25.12` | unchanged, same build hash |
| Block height | 52,266,372 | 53,117,114 | 850,742 blocks in about 24 hours |
| Observed block time | 0.1 s | 0.1 s (100 blocks in 10 s, blocks 53,117,014 to 53,117,114) | unchanged |
| Gas price (`eth_gasPrice`) | 360,574,000 wei (0.361 gwei) | 472,640,000 wei (0.473 gwei) | about 31 percent higher in a day, 11.1x the August reading |
| Base fee (`eth_getBlockByNumber`) | 474,862,000 wei at block 52,266,850 | 471,712,000 wei at block 53,117,114 | moving value |
| Block gas limit | 2^50 | 2^50 | Arbitrum sentinel, unchanged |

Only two things moved between 2026-09-02 and 2026-09-03: the block height, and the gas price.
The client build, the chain id, the block time and the gas limit are byte-identical readings.
Gas price on this chain is the one parameter worth re-reading before quoting: it has now moved 0.043 to 0.361 to 0.473 gwei across the three captures, an order of magnitude in three weeks.

### Contract deployments (`eth_getCode`)

All 22 addresses from the tables above were re-read at block 53,117,114.
Every one returned the same byte count as on 2026-09-02, and this pass also recorded a sha256 of each runtime blob so a future pass can compare content rather than length (`_raw/onchain-2026-09-03/eth_getCode-2026-09-03.txt`).

Worth recording from those hashes:

- The four Arbitrum gateways and WETH are not merely the same size, they are the **same contract**: `0x1E32...1B89`, `0xfd9b...b31e`, `0x9122...8959`, `0x1D18...F055` and `0x0Bd7...AD73` all hash to `eb5a5f69ebb602e71cdf5fdeb7d49ca9e4b37d105432c0cbd31a754fc4d360a7`.
  They are five instances of one 2,202-byte transparent proxy, which is why the "2,202 B" column repeats.
  Do not read equal byte counts in the August table as five separate implementations.
- `ArbSys` and `ArbGasInfo` share one 1-byte stub hash, as expected for precompiles.
- `NodeInterface` still returns 0 bytes, unchanged and still correct.
- Both Universal Router candidates still return 24,546 B with the same two distinct sha256 values recorded on 2026-09-02, so the conclusion in that section stands untouched: `0x8876789976decbfcbbbe364623c63652db8c0904` is the router in use.

Ten further addresses that `ROBINHOOD-CHAIN.md` section 9 calls "all verified deployed" but that no raw capture had ever covered were checked on this pass (`_raw/onchain-2026-09-03/eth_getCode-supplement-2026-09-03.txt`).
All ten have code: SenderCreator v0.6.0 528 B, v0.7.0 451 B, v0.8.0 1,217 B, Safe Module Setup v0.3.0 547 B, Safe 4337 Module v0.3.0 8,373 B, and the `ArbRetryableTx`, `ArbStatistics`, `ArbOwner`, `ArbWasm` and `ArbWasmCache` precompiles at 1 B each.
The "all verified deployed" claim on that table is now backed for every row in it.

### Chainlink feeds, read from chain

This pass closes the gap left by 2026-09-02, which compared directory listings but never called a feed.
`latestRoundData()`, `decimals()` and `description()` were called on all **57** feeds through Multicall3 at block 53,117,114 (`_raw/onchain-2026-09-03/onchain-feeds-2026-09-03.json`).

| Measure | Result |
| --- | --- |
| Feeds in the Chainlink reference directory | 57 |
| Feeds that returned `latestRoundData()` | 57 of 57 |
| Feeds stale beyond twice their own heartbeat | 0 |
| Robinhood tokenized-equity feeds | 35 |
| Crypto, stablecoin and exchange-rate feeds | 22 |
| L2 Sequencer Uptime feeds | 0 |

The directory file was refetched on 2026-09-03 and is **byte-identical** to the 2026-09-02 copy, so no feed was added or removed in the intervening day.

`CBBTC / USD` at `0x0009cD492adf8167f9eEBf1293556A673530a21a` returned `answer` 7,764,764,129,913 with 8 decimals, that is 77,647.64 USD, `updatedAt` 2026-09-03T02:31:35Z.
This is the sourced replacement for the unsourced 2026-09-02 figure noted above.

The August warning about `description()` is stronger than it was written.
Across the 35 equity feeds there are **three** naming forms, not two: 23 return `Robinhood <SYM> / USD`, 9 return `RH<SYM> / USD` (SPY, TSLA, SNDK, INTC, MU, NVDA, USO, MSFT, AMD), and 3 return `Robinhood <SYM>-USD` with a hyphen and no spaces (SGOV, USAR, DELL).
Never match a feed by parsing `description()`.

### Stock Token roster

| Measure | 2026-09-02 | 2026-09-03 |
| --- | --- | --- |
| Active assets in `GET /rhj/assets` | 194 | 194 |
| Token contracts read on-chain | 194 | 194 |
| Added or removed | - | 0 |
| Proxy bytecode | 283 B | 283 B on all 194, one sha256 `399ec4bc5b43db03486ceae11f9a6fc5c126427f8f8e10c90fed0c773f4325c6` for every token |
| ERC-1967 beacon slot | `0xe10B6f6B275De231345c20d14aB812DB62151B00` | same on all three sampled tokens |
| ERC-1967 implementation slot on a token | zero | zero, confirming beacon rather than transparent or UUPS proxying |
| Beacon `implementation()` | `0xb35490d6f9163de4f80d88dc75c3516eb64c5ae2` | unchanged, 11,614 B |
| `decimals() == 18` | 194 of 194 | 194 of 194 |
| `oraclePaused() == true` | none | none |
| `newUIMultiplier() != uiMultiplier()` | none | none, no scheduled change anywhere |
| `totalSupplyUI == totalSupply * uiMultiplier / 1e18` | holds on 194 | holds on 194, zero failures |

The 283-byte and single-hash result is the first time the "identical bytecode" claim has been checked over the whole roster rather than sampled.
All 194 Stock Tokens are literally the same 283 bytes, so the single-beacon upgrade risk applies to every one of them without exception.

### Multipliers at block 53,117,114

Ten tokens now carry a `uiMultiplier()` other than 1.0, one more than on 2026-09-02.

| Symbol | `uiMultiplier()` | `effectiveAt()` | Since 2026-09-02 |
| --- | --- | --- | --- |
| CRWD | 4.000000000000000000 | 2026-07-02 13:30 UTC | unchanged |
| CCL | 1.021486444855206408 | 2026-08-31 15:10 UTC | unchanged |
| SGOV | 1.005101770003214918 | 2026-09-01 00:00 UTC | unchanged |
| ORCL | 1.002210914971013375 | 2026-07-27 15:10 UTC | unchanged |
| COST | 1.000612040296259656 | 2026-08-10 15:10 UTC | unchanged |
| AAPL | 1.000566080061092436 | 2026-08-14 15:12 UTC | unchanged |
| **F** | **1.000145502866134027** | **2026-09-02 15:10 UTC** | **new, was 1.0 with `effectiveAt() == 0`** |
| ASML | 1.000101323251417769 | 2026-08-06 15:10 UTC | unchanged |
| MU | 1.000074823219171086 | 2026-07-24 15:10 UTC | unchanged |
| DELL | 1.000063708620124549 | 2026-08-03 15:10 UTC | unchanged |

`F` is the only token whose state changed between the two passes, and it landed at 15:10 UTC, the same minute of day as CCL, ORCL, COST, ASML, MU and DELL.
That is a scheduled daily accrual job, not a one-off, so expect this table to grow by one or two rows most weekdays and do not cache a multiplier across a session.

### Lighter Robinhood Chain instance

`34-lighter-domains.md` is a docs page that first appeared after the 2026-09-02 capture and names one contract, `0x94bAB9693Ba2f6358507eFfcbd372b0660AFfF9d`.
Read at block 53,117,114 (`_raw/onchain-2026-09-03/lighter-contract-2026-09-03.json`):

| Item | Value |
| --- | --- |
| Lighter contract | `0x94bAB9693Ba2f6358507eFfcbd372b0660AFfF9d`, 1,367 B |
| ERC-1967 implementation slot | `0x82de5b1161c93afdfe21ba0d5343f01cd7401d90`, 23,168 B |
| ERC-1967 beacon slot | zero |
| ERC-1967 admin slot | `0x43cff77cd060a155dce5deb12b93b875f69f2716`, 4,116 B |

The address the docs give is a **transparent upgradeable proxy**, which the docs page does not say.
The admin slot holds a contract rather than an EOA, so a ProxyAdmin sits in front of it and the party that owns that ProxyAdmin can replace the deposit logic.
That owner could not be read from chain: every standard ownership accessor reverts, so see the closing section.
The `deposit(address,uint16,RouteType,uint256)` signature and the USDG `_assetIndex = 3` in that page were not exercised on chain, because doing so would require sending a transaction.

### ERC-8056 interface, re-probed

Re-run on `0x1Cdad396DB64BDa184d5182A97Dd9B3C62100b7D` at block 53,117,114 (`_raw/onchain-2026-09-03/erc8056-interface-2026-09-03.json`).

| Call | Result 2026-09-03 |
| --- | --- |
| `uiMultiplier()`, `newUIMultiplier()`, `effectiveAt()`, `totalSupplyUI()`, `oraclePaused()`, `uid()`, `balanceOfUI(address)` | all return |
| `owner()`, `version()`, `isin()`, `oracle()` | all revert with empty return data |
| Beacon `owner()` | reverts with empty return data |
| Beacon `implementation()` | `0xb35490d6f9163de4f80d88dc75c3516eb64c5ae2` |

Every August finding on this interface still holds, but the one that mattered most has now been answered, and the answer is not the one `Ownable` was hiding.

### Upgrade authority over all 194 Stock Tokens, resolved 2026-09-03

`owner()` on the beacon reverts because **the beacon is not `Ownable`**.
`0xe10B6f6B275De231345c20d14aB812DB62151B00` is a verified contract named **`AccessControlsRegistry`** (Solidity `v0.8.33+commit.64118f21`), and it uses OpenZeppelin `AccessControl` role gating, so every `Ownable` accessor reverts by construction.
Three roles gate it, from the verified source: `upgradeTo(address)` is `onlyRole(BEACON_UPGRADER_ROLE)`, `pause()` and `unpause()` are `onlyRole(PAUSER_ROLE)`, and `blockAccounts(address[])` and `unblockAccounts(address[])` are `onlyRole(BLOCKER_ROLE)`.

`hasRole` read at block 53,117,114 (`_raw/upgrade-authority-2026-09-03/`):

| Role | `0xd6f8378f8e440c65f8382f5f2728c78dfd55b66d` | Deployer `0x074377a78A9710A1D47244f89797718b4f491279` |
| --- | --- | --- |
| `DEFAULT_ADMIN_ROLE` | **yes** | no |
| `BEACON_UPGRADER_ROLE` | no | no |
| `PAUSER_ROLE` | no | no |
| `BLOCKER_ROLE` | no | no |

**`0xd6f8378f8e440c65f8382f5f2728c78dfd55b66d` holds `DEFAULT_ADMIN_ROLE` and is an externally owned account, not a contract and not a multisig.**
It holds none of the three operational roles today, but `DEFAULT_ADMIN_ROLE` is the admin of every role by default in OpenZeppelin `AccessControl`, so that one key can grant itself `BEACON_UPGRADER_ROLE` and then replace the implementation behind all 194 Stock Tokens in two transactions.
There is no timelock, no multisig and no notice period on that path.
This is the single largest governance dependency in this archive, and it is a single private key.

**The same registry also enforces an account blocklist and a global pause.**
`isBlocked(address)` and `paused()` are live reads, and the contract's log history shows `Blocked` fired for dozens of distinct real addresses, so the blocklist is in active use rather than dormant.
`paused()` returned false at block 53,117,114.
This is where the chain's compliance filtering is actually implemented for Stock Tokens, and it is worth reading alongside `15-arbitrum-compliance-filtering.md`, which describes the policy but not this mechanism.

Not read: the current holders of `BEACON_UPGRADER_ROLE`, `PAUSER_ROLE` and `BLOCKER_ROLE`.
The constructor granted `DEFAULT_ADMIN_ROLE` and `BEACON_UPGRADER_ROLE` to the deployer and both have since moved; identifying today's holders needs a topic-filtered `RoleGranted` scan, which the free-tier 10-block `eth_getLogs` cap makes impractical here.
It does not change the finding above, because the `DEFAULT_ADMIN_ROLE` holder can appoint itself to any of them.

### Upgrade authority over the Lighter deposit contract, resolved 2026-09-03

The address that reverted every `Ownable` and `AccessControl` accessor, `0x43cff77cd060a155dce5deb12b93b875f69f2716`, is a verified contract named **`UpgradeGatekeeper`** (Solidity `v0.8.25+commit.b61c2a91`), a zkSync-lineage upgrade controller rather than an OpenZeppelin `ProxyAdmin`.
That is why none of the standard accessors resolved: its interface is `getMaster`, `securityCouncilAddress`, `approvedUpgradeNoticePeriod`, `upgradeStatus`, `nextTargets`, `managedContracts` and `zkLighterProxy`.

Read at block 53,117,114:

| Call | Value | What it is |
| --- | --- | --- |
| `zkLighterProxy()` | `0x94bAB9693Ba2f6358507eFfcbd372b0660AFfF9d` | confirms this gatekeeper governs the Lighter deposit contract |
| `getMaster()` | `0x8caf9ff9392f39e87cbc65a130c026caacd321ef` | a verified **`SafeProxy`**, threshold **3 of 5** |
| `securityCouncilAddress()` | `0x4972e0cacb2ac45644ba054838e96ff4f6f7efdb` | an externally owned account |
| `approvedUpgradeNoticePeriod()` | 1,814,400 | **21 days** |
| `upgradeStatus()` | 0 | idle, no upgrade in progress |
| `upgradeStartTimestamp()`, `noticePeriodFinishTimestamp()` | 0, 0 | consistent with idle |
| `versionId()` | 6 | six upgrades have completed |

Safe owners: `0x07b06b78c1a1908dd8e59322fd45f78406d2241f`, `0xa88dc20dc32c72e90032c409703de04a942c9353`, `0x7f7db611e49edd1745cb9e92b74d7233f57682e0`, `0x9517f746f489a04679c0aff07c73bb50a6543377`, `0x42cdb51c23d03c69c05fa691c3b5517ace876213`.

So a Lighter upgrade needs 3 of 5 Safe signatures and then a 21-day public notice period, which `startUpgrade` opens and `finishUpgrade` closes.
The caveat is `cutUpgradeNoticePeriod`, which exists to shorten that window; the security council is a single externally owned account, so the 21 days is only as strong as that one key.
Compare this with the Stock Token beacon above: the asset most people would consider systemically important has the weaker control.

### Raw files for this pass

All under `_raw/onchain-2026-09-03/`, indexed in `README.txt` there.

| File | Contents |
| --- | --- |
| `chain-info-2026-09-03.json` | chain id, client version, block height, gas price, base fee, gas limit, block time over 100 blocks |
| `eth_getCode-2026-09-03.txt` | byte count and sha256 for all 22 deployment-table addresses, with a same or changed flag against 2026-09-02 |
| `stock-token-bytecode-2026-09-03.json` | `eth_getCode` over all 194 Stock Tokens, size and sha256 histograms, ERC-1967 slots on 3 sampled tokens |
| `onchain-tokens-2026-09-03.json` | 8 fields from all 194 token contracts, the `totalSupplyUI` identity check, and the diff against 2026-09-02 |
| `onchain-feeds-2026-09-03.json` | `latestRoundData()`, `decimals()`, `description()` for all 57 Chainlink feeds |
| `chainlink-feeds-robinhood-mainnet-2026-09-03.json` | Chainlink reference directory, refetched, byte-identical to the 2026-09-02 copy |
| `erc8056-interface-2026-09-03.json` | ERC-8056 selector probe on one token plus `owner()` and `implementation()` on the beacon |
| `beacon-implementation-2026-09-03.json` | raw `eth_call` result for `implementation()` on the beacon |
| `rhj-assets-2026-09-03.json` | REST asset registry response, for the roster count cross-check |
| `august-block-34251364-multipliers-reread.json` | archive replay at the August capture block, which corrected two digits in the August multiplier table |
| `eth_getCode-supplement-2026-09-03.txt` | `eth_getCode` on the 10 further section 9 addresses no earlier capture covered |
| `lighter-contract-2026-09-03.json` | Lighter instance: code, ERC-1967 slots, implementation and ProxyAdmin |

### What is still not verified from chain

- ~~The owner of the Lighter ProxyAdmin~~ and ~~the upgrade authority over the Stock Token beacon~~ were both closed on 2026-09-03; see the two sections above. The method that worked was reading the contract *name* from Blockscout first, which showed that neither contract implements the interface every accessor assumed.
- **The current holders of `BEACON_UPGRADER_ROLE`, `PAUSER_ROLE` and `BLOCKER_ROLE`** on the Stock Token registry, as noted above. The `DEFAULT_ADMIN_ROLE` holder can appoint itself to all three, so this does not change the trust conclusion, but it does mean the archive cannot name who can pause or blocklist today.
- **The 2026-09-02 CBBTC price reading**, as noted above. It is unreproducible and has been marked unsourced rather than deleted.
- **Sequencer behaviour.** First-come-first-served ordering and sanctions screening at the sequencer are documented claims and are not observable through `eth_call`. Nothing in this file confirms them.
- **`eth_getLogs` history.** The Alchemy free tier caps the range at 10 blocks on this network and blocks `trace_block`, `arbtrace_block` and `debug_traceBlockByNumber`, so no event-derived figure in this archive was produced by a full-range log scan.
