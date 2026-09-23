# V4 pools and liquidity on Robinhood Chain

> Captured 2026-09-19 from the Dexscreener API (`tokens/v1/robinhood/<addresses>`), driven by the 194-token roster in `16-token-contracts.md`.
> Token roster re-pulled the same day from `GET https://api.robinhood.com/rhj/assets`.
> Raw: `_raw/pools-2026-09-19/pairs.json` and `roster.json`.
> Liquidity and volume are point-in-time and move constantly. Addresses and pool ids do not.
> **Caveat found 2026-09-23:** `tokens/v1` returns only each token's top pool, so the per-token figures below are top-pool figures and the pair count is a count of top pools. NVDA's top pool held $14.3M of the $24.1M its 30 pools traded that day. See `50-stock-token-market-data.md` section 6.

## Roster check against 2026-09-03

Still **194 active** tokens. No symbol added, none removed, and every contract address unchanged.

**18 multipliers moved**, all upward, consistent with dividend accrual under ERC-8056.

| Symbol | 2026-09-03 | 2026-09-19 |
| --- | --- | --- |
| AMAT | `1.000000000000` | `1.000044656302636618` |
| CRM | `1.000000000000` | `1.001148322800714293` |
| GOOGL | `1.000000000000` | `1.000193924414112587` |
| HPE | `1.000000000000` | `1.001716957939304938` |
| JNJ | `1.000000000000` | `1.000021490286701962` |
| KSS | `1.000000000000` | `1.004610068732316661` |
| LLY | `1.000000000000` | `1.000002288774375687` |
| MSFT | `1.000000000000` | `1.000412952576205964` |
| NVDA | `1.000000000000` | `1.000775159164630595` |
| PR | `1.000000000000` | `1.004477942292229526` |
| SOXX | `1.000000000000` | `1.000450838210425960` |
| SPY | `1.000000000000` | `1.001717991187472003` |
| TSM | `1.000000000000` | `1.001463024159690554` |
| UNH | `1.000000000000` | `1.004241501039702113` |
| UPS | `1.000000000000` | `1.002208724969205741` |
| VRT | `1.000000000000` | `1.000162788892052072` |
| WDC | `1.000000000000` | `1.000217565250523909` |
| XOM | `1.000000000000` | `1.001039563764661900` |

This is the practical reminder that `uiMultiplier()` moves often.

**It does not follow that the balances move, and an earlier version of this file said it did.**
The multiplier is display-only: it scales `balanceOfUI()` and `totalSupplyUI()` and never touches `balanceOf`.
Stock tokens are not elastic-supply tokens for a contract that holds them.
Measured either side of two real corporate actions with zero transfers, and swept across all 194 tokens, in `46-uimultiplier-is-display-only.md`.
What a contract holding these tokens does need to price in is the issuer's control surface: a central blocklist, `adminBurn` from any holder, and one shared upgrade beacon behind all 194 tokens. Same file.

## Market shape

| Metric | Value |
| --- | --- |
| Pairs with liquidity | 172 |
| Uniswap **v4** pools | **123** |
| Uniswap v3 pools | 49 |
| Other DEXes | 4 (ramses, up) |
| Total liquidity | $44,938,641 |
| Total 24h volume | $103,153,988 |
| v4 share of liquidity | 28.3% |
| v4 share of 24h volume | 17.5% |

**v4 is the dominant venue on this chain**, not a new arrival: it carries more pools than v3 and the majority of both liquidity and flow.

Quote assets, by pair count: `USDG` 92, `ETH` 67, `SPY` 6, `WETH` 4, `cbBTC` 1, `HOTDOG` 1, `BONER` 1.
USDG, the Paxos Global Dollar, is the default quote asset here rather than a wrapped native token.

## Top 25 pools by liquidity

| Base | Quote | Ver | Liquidity USD | 24h vol USD | Pool id / pair |
| --- | --- | --- | ---: | ---: | --- |
| NVDA | USDG | v3 | 6,274,093 | 25,542,248 | `0xd4EB21209C4D6093f80B5b84f5C45cc093EA14a3` |
| SGOV | USDG | v3 | 3,988,621 | 491,128 | `0xfAb520051f96F4D2a32c22B6a3dD7fFfdf231bFe` |
| META | USDG | v4 | 3,896,725 | 7,663,387 | `0x5875d407a42965b0e768c8925cea290e06fa50603ef34fc99eb92a1050e6ae36` |
| GLD | USDG | v3 | 3,698,657 | 1,538,847 | `0x7A6A053eCCf1446A2633E05aA6D40D09381997ec` |
| SPCX | USDG | v3 | 2,808,767 | 24,132,211 | `0xc61284332117c3FB23A2A56cceFFD07F7aF60029` |
| HIMS | BONER | v4 | 2,532,443 | 932,896 | `0x9c89b04303dfa76f3f6fb02c2b77be0e8a00ab8fa00d507119acd54ab3e8640d` |
| CRCL | USDG | v3 | 2,064,633 | 2,182,946 | `0x654E4143e82a5824445Ade0824351C2A9ACD95a8` |
| SPY | WETH | v3 | 1,945,484 | 9,571,059 | `0xDDCBBa3666f578E3F09516f21Ff85BFee859AB5e` |
| USO | USDG | v3 | 1,656,656 | 1,610,510 | `0x02175608F1b5E6b5ed221cCFdC7Be197D111D915` |
| QQQ | USDG | v3 | 1,499,904 | 3,592,008 | `0xD60A5d14dB690B7Afad71F76B108071D7175597d` |
| GOOGL | USDG | v3 | 1,478,820 | 6,403,896 | `0x34D0dC122CF9A8Eb296fC5e0D3A233625D7d19b7` |
| AMZN | USDG | v3 | 925,444 | 506,186 | `0x8AC92DA74AB5F3b1d024Dc1943Ad7e15Dc4179Ef` |
| MSFT | USDG | v3 | 785,314 | 261,517 | `0xeb60bCD1D920ad6E102690CCFC6fB488899E1510` |
| MU | SPY | v4 | 741,587 | 892,673 | `0xcc2a903a8744a65258bb07fbeea553a25410f731c9fef306321d0c176a09542c` |
| RDDT | WETH | v3 | 644,375 | 310,369 | `0xA541143F20D7b0643123064aBF25F423E375b531` |
| TSM | SPY | v4 | 613,871 | 694,456 | `0x4c862e5846659b086fe73896bbb9058513417e4e6938a1be93aeb7a768fa5754` |
| INTC | SPY | v4 | 603,631 | 1,909,060 | `0x7fb585f108d921de3b197cf7e26b5aebc96b035fec13f972b868e008ea062394` |
| AMD | SPY | v4 | 448,678 | 484,038 | `0xe6e17efdbdd916526293cf1b509171be4ffb04f47c4a5fe1a7367acdaa6ffd82` |
| SLV | USDG | v3 | 437,887 | 244,362 | `0x8cB787e6c315D464775289BaD00FDD67d53Ecb3D` |
| SNDK | USDG | v4 | 311,812 | 167,421 | `0x2707cb88a6a40fa0f948f58958051ba097d6f6a3cf7f87929bd68ccc5becea24` |
| PLTR | SPY | v4 | 311,329 | 1,115,454 | `0xb8d9b6b622bb03dd06d95790553f327710a73d85d845a59fa9e652638ca96ae6` |
| AMC | USDG | v4 | 282,902 | 1,502,060 | `0x7499938c352d5b5b8f0c648722aca5ee964ef9b85c3a3041f1ec379726291d9d` |
| RBLX | WETH | v3 | 257,502 | 196,442 | `0x6d25417718A8D6c529130a8ccC4BfBf0a18219D3` |
| DJT | USDG | v4 | 251,221 | 228,700 | `0x55f2df399bf61fd758b99848452eaf217ee9d2f98fb9c79deb23fe9a2652bc5a` |
| DELL | USDG | v3 | 241,567 | 45,385 | `0xc30c89cB7815A1488b7998D15eEC73961707Fc5a` |

## What this source cannot tell you

Dexscreener returns no hook address for a v4 pool.
Its record carries `pairAddress` (the 32-byte `PoolId`), tokens, price, liquidity and volume, and nothing about the `PoolKey`'s `hooks` field.

To learn which hook, if any, serves a pool you need the `Initialize` event from the PoolManager at `0x8366a39cc670b4001a1121b8f6a443a643e40951`, which carries the full `PoolKey`.
That means a log scan, and free-tier `eth_getLogs` on this chain is capped at a 10 block range.
Use `alchemy_getAssetTransfers`, the Blockscout PRO API, or a Goldsky subgraph for any real scan.

A `PoolId` is a hash, not an address, so there is no contract to call at it.
To resolve one back to its tokens, use `https://api.dexscreener.com/latest/dex/pairs/robinhood/<poolId>`.

## New-pool rate: v3 versus v4

> Measured 2026-09-23 on the public RPC, blocks 70,333,742 to 70,733,742 (400,000 blocks, 11.2 hours), with `eth_getLogs` in 100,000-block windows.

| Event | Emitter | Count | Per day, extrapolated |
| --- | --- | ---: | ---: |
| v3 `PoolCreated` | factory `0x1f7d7550B1b028f7571E69A784071F0205FD2EfA` | 227 | about 490 |
| v4 `Initialize` | PoolManager `0x8366a39cc670b4001a1121b8f6a443a643e40951` | 4,552 | about 9,750 |

About 95% of new pools on this chain are v4.
A launch watcher that only listens for v3 `PoolCreated` misses nearly all of them; it must also subscribe to `Initialize` (topic `0xdd466e674ea557f56295e2d0218a125ea4b4f0f6f3307b95f85e6110838d6438`) on the PoolManager.
Many v4 pools quote in native ETH (`currency0 == address(0)`), which a watcher keyed only on WETH and USDG also misses.
The v4 figure is lower than the roughly 15,000 per day in `48-hook-census.md`, which comes from an outside source over a different window.
The public RPC served these 100,000-block `eth_getLogs` windows with no range error, unlike the 10-block cap on free Alchemy.
