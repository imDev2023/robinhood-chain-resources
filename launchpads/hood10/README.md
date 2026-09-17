# HOOD10

## 1. Identity

HOOD10 is two products sharing one brand, one team and one X account, and they are built on completely different code.

**HOOD10, the index token.**
A 5% tax token on Robinhood Chain that buys the chain's ten largest tokens by pool liquidity and pushes them to holders in kind, once per epoch.
It lives at `https://www.hood10.xyz/` with its documentation at `https://www.hood10.xyz/docs`.

**HOOD10 Launchpad.**
A Uniswap v4 launch venue at `https://launch.hood10.xyz/`, opened on 2026-08-29, where creating a coin opens a real pool in the same transaction.
This is the part that matters for launching a project, and it is what most of this file is about.

| field | value | source |
| --- | --- | --- |
| Chain | Robinhood Chain, id 4663 | `_raw/api-launch-health.json`, `_raw/launch-sitemap.xml` |
| Index site | <https://www.hood10.xyz/> | `pages/01-home.md` |
| Docs | <https://www.hood10.xyz/docs> | `pages/02-docs.md` |
| Launchpad | <https://launch.hood10.xyz/> | `pages/03-launch-home.md` |
| Index token | `0x0D257cA40d40090BE60C2d2Ed5bB3535392838cc`, symbol HOOD10, name "Robinhood10 Index" | `_raw/rpc/hood10-token-state.txt` |
| Index pool | Uniswap v4 pool id `0x2e152bc12f30bd46eb39f0ead2367df62b9572ba3a2d54ea3e3aca43c00ae9f6` | `_raw/dexscreener-token-pairs-hood10.json` |
| X | [@hood10xyz](https://x.com/hood10xyz), 2,710 followers, 56 posts, joined August 2026 | `socials/01-x-hood10xyz.md` |
| Telegram, Discord, GitHub, Dune | none found | `socials/01-x-hood10xyz.md`, section 9 below |
| Owner of every launchpad contract | `0xfe2cF227e21C5FC54dcE8Bb65F7C1E1E90236862` | `_raw/rpc/live-state.txt` |
| Index keeper | `0xEE5cC579a0A6D90bFF4c481387b39BA655caC728` | `_raw/rpc/distributor-state.txt` |
| Capture date | 2026-09-02 | this file |

The index site is a Next.js app served from Vercel; its sitemap lists exactly two URLs and gives the canonical host as `hood10.vercel.app` (`_raw/hood10-sitemap.xml`).
The launchpad is a Vite single-page app with hash routes (`#/launch`, `#/vault`, `#/profile`, `#/t/<poolId>`) and its own JSON API on the same origin.
No team member is named anywhere on either site, in the docs, in the contracts, or on X.

## 2. What it is

**The launchpad, in plain words.**
You fill in a ticker, a name, some links and a picture, choose what your coin is priced in, choose a supply, choose what a trader pays, optionally buy some of your own supply, and send one transaction.
That transaction deploys a fixed-supply ERC-20, opens a Uniswap v4 pool for it, puts the entire supply into that pool as a single one-sided concentrated position, locks the position forever, and optionally executes your first buy before anyone else can trade.
There is no bonding curve contract, no graduation threshold, and no migration, because a one-sided v4 position in a range above the opening price already behaves as a curve.
The `LaunchFactory` natspec states the motive directly: skipping the migration "also removes the window that snipers farm on pads that move funds from a curve into a pool".

**Who it is for.**
Someone with no capital to seed a pool, because you seed nothing: the supply is the liquidity.
Launching costs gas and, optionally, your own first buy.
It is also for anyone who wants a coin priced in something other than ETH, because the quote asset is a free choice and includes tokenized equities.

**The index, in plain words.**
Buy and hold at least 100,000 HOOD10 and, at each epoch close, the contract that collects the token's 5% trade tax buys ten tokens and sends you your pro-rata share of all ten.
The two products are wired together by intent rather than by code: the launchpad's 1% venue fee is supposed to feed the index.
Section 4 shows why that wiring is not currently enforced on chain.

## 3. How a launch works, step by step

### 3.1 The form

Captured with no wallet connected in `pages/07-launch-create.md`, `screenshots/07-launch-create.png`, `screenshots/29-launch-create-stocks-tab.png`, `screenshots/30-launch-create-trending-tab.png` and `screenshots/34-launch-create-10b-10pct-options.png`.

| field | options as shown | notes |
| --- | --- | --- |
| art | drag and drop or click, 1:1 | stored off chain, served through `/api/icon` |
| ticker | free text, prefixed `$` | |
| name | free text | |
| links | website, x, telegram | "https only. Stored on chain and editable later." |
| description | free text | on chain, editable by whoever holds the fee lane |
| Priced in | three tabs: Classics, Stocks, Trending. Classics offers WETH ("the default"), USDG ("stable") and HOOD10 ("the index") | the full list `/api/vault` returns is 21 assets, section 4 |
| supply | 100M, 1B, 10B, 100B | four fixed choices in the UI; the contract takes any `uint256` |
| what a trader pays | No fee ("just the protocol's 1%"), 2% ("1% to you"), 5% ("4% to you"), 10% ("9% to you") | |
| pay my share to holders instead | checkbox. "Your 1% goes to everyone holding the token, in WETH, in proportion to what they hold. Two more transactions right after launching." | the reflection path, section 3.5 |
| keep some for yourself | None, 1%, 5%, 10%, or a free percentage | priced live in ETH, for example 10% shown as 0.151 ETH |

The form's own summary panel reads "The whole supply goes into the pool and the liquidity is locked forever.
The price climbs as people buy.
The position spans the whole tick range, so there is no ceiling at all."

**There is no launch fee.**
The docs say so ("Creating a coin costs gas and your own first buy") and no fee is taken anywhere in `LaunchFactory.launch` (`contracts/LaunchFactory-0x718633252AA8329495Df8BBa8fF7c9e8378CFC63/sources/src/LaunchFactory.sol`).
For comparison, letscash.fun, the pad the HOOD10 token itself launched on, charges `launchFee()` = 0.0005 ETH (`_raw/rpc/cashcat-state.txt`).

### 3.2 The transaction

Three entry points on `LaunchFactory` `0x718633252AA8329495Df8BBa8fF7c9e8378CFC63`:

- `launch(LaunchParams)` opens the pool and buys nothing.
- `launchAndBuy(LaunchParams, buyAmount, minTokensOut)` also spends `buyAmount` of the quote asset, which you must already hold and have approved.
- `launchAndBuyWithEth(LaunchParams, Hop[] route, minTokensOut)` funds the first buy with ether and routes it to the quote asset inside the same `unlock`, up to `MAX_ROUTE_HOPS` = 4 hops, refusing any hop whose pool has a hook.

`LaunchParams` is `name, symbol, metadataURI, supply, quote, openFdv, rangeTicks, tickSpacing, creatorFeeBps, snipeSurgePips, snipeWindow`.
`openFdv` is what the whole supply is worth at the opening price, in the quote's own base units, and `rangeTicks` is how far the price travels before the supply is exhausted, computed as `ln(multiple)/ln(1.0001)`.
Everything else about the geometry is derived by the linked library `LaunchGeometry` at `0xEb0C797DaDd23A7AD0d00187A976143C8AF8972A`, because the token address does not exist until the transaction runs and the currency ordering depends on it.

Inside one `PoolManager.unlock` the factory deploys the token, initializes the pool with `LP_FEE = 0` and `LaunchHook` as the hook, registers the pool's terms on the hook, seeds the whole supply as one position, and optionally swaps the first buy.
The `LP_FEE = 0` is deliberate: "Liquidity is protocol-owned and can never be removed, so an LP fee would accrue into a position nobody can ever collect from.
Everything is charged as a hook fee instead."

### 3.3 The lock

`LaunchHook` `0xe6234a98fF84220CcDA12985548ddAb36327Aacc` is what makes the liquidity permanent, and it does it with three checks.

- `_beforeInitialize` reverts unless the caller is the factory, so no one can open a rogue pool wearing this hook.
- `_beforeAddLiquidity` allows exactly one add per pool, tracked in `seeded[poolId]`, and reverts on every later add including the factory's.
- `_beforeRemoveLiquidity` always reverts with `LiquidityLocked()`.

There is no owner path around any of the three.
The hook's `owner` can change only the `feeRouter` address; it cannot pause a pool, change a fee, or move liquidity.

### 3.4 The fees a launched coin pays

| lane | rate | who sets it | who receives it |
| --- | --- | --- | --- |
| protocol | fixed 1%, `PROTOCOL_FEE_PIPS = 10000` | nobody, it is a constant | swept by whatever address is `LaunchHook.feeRouter` |
| creator | 0% to 9%, `MAX_CREATOR_FEE_BPS = 900` | the creator, once, at launch | the launching wallet, transferable |
| anti-snipe surge | `snipeSurgePips`, decaying linearly to zero over `snipeWindow` blocks | the creator, at launch | accrues to the protocol lane, never the creator lane |
| hard ceiling | 10%, `MAX_FEE_RATE = 100000`, surge included | nobody | |

The fee is taken on the quote side of the swap and held as ERC-6909 claims against the `PoolManager` until someone calls `settle(poolId)`, which anyone may do.
`settle` splits the accrual into `creatorTab[poolId]` and `platformTab[currency]`.
The creator withdraws with `claim(poolId, to)`.

The surge is credited entirely to the protocol lane on purpose, and the natspec explains why: crediting it proportionally "would hand the creator a proportional cut of their own surge, at a 200bp add-on, two thirds of it, which turns a snipe deterrent into a way to farm the first buyers it exists to protect".

**Handover.** `transferCreator(poolId, newCreator)` then `acceptCreator(poolId)` is a two-step move of the fee lane, and it takes the token's metadata control with it, because `LaunchToken` reads its admin from `LaunchHook.creatorOf(poolId)`.

### 3.5 Reflection launches

Ticking "Pay my share to holders instead" produces two extra transactions.

1. `DividendDeployer.deployFor(poolId, minDistribution, maxCutBps)` deploys a `LaunchDividendTreasury` and a `CreatorFeeSplitter` for the pool, deriving token and quote from `LaunchFactory.launches(poolId)` so the pair cannot be pointed at somebody else's launch.
2. The creator calls `LaunchHook.transferCreator(poolId, splitter)` and the splitter accepts, which wires the creator lane into the treasury.

Holders are then paid in the pool's quote asset.
Bond to NVDA and holders are paid in NVDA.

Seven pairs had been deployed at capture (`_raw/blockscout/dividenddeployer-logs.json`).
GOONER's pair is `LaunchDividendTreasury` `0x0E57Ef4Cb77362b3d69EB348735b38534104d237` and `CreatorFeeSplitter` `0x669D54EC9D475AdD053B50CdaC31fa13558553DB`, both in `contracts/`, both identified by selector matching because `DividendDeployer` creates them with `new` and Blockscout does not match them to its verified sources.

**The docs are wrong about this path in two ways, and the contract's own natspec is the correction.**
The docs say "Conversion happens on-chain as people trade.
No keeper, no claim, no protocol cut on the way through."
In fact `LaunchDividendTreasury` runs keeper-committed Merkle periods (`commitRoot`, `openClaims`, `claim(period, account, amount, proof)`), the site serves the proofs at `/api/dividendProof?treasury=&account=`, and `CreatorFeeSplitter` takes the pad a cut on the way through, bounded by `MAX_CUT_BPS = 3000`.
The treasury's own natspec states the trust model plainly: "the keeper commits the Merkle root, and nothing on chain checks that the root reflects real balances ... it is not trustless and should not be described as such".

### 3.6 There is no graduation

No threshold, no migration, no destination DEX, because the pool is the destination from block zero.
The docs put it as "What you see on a HOOD10 Launchpad chart is a pool price from the first candle, not a curve that later migrates somewhere else."
Nothing in `LaunchFactory` or `LaunchHook` implements a migration.

### 3.7 What nobody can do

Read off the contracts rather than off the docs page:

- No mint. `LaunchToken` has a fixed supply, no owner and no mint function.
- No fee change after launch. `LaunchHook.register` is factory-only and reverts with `AlreadyRegistered` on a second call, and `PoolConfig` is never rewritten.
- No liquidity withdrawal by anyone. `_beforeRemoveLiquidity` always reverts.
- No pause of a live pool. `LaunchFactory.paused` gates new launches only, and reads `false` (`_raw/rpc/live-state.txt`).
- No custody. The pad never holds a trader's funds.

The one power the owner does have is `LaunchHook.setFeeRouter`, and section 4 shows what has been done with it.

## 4. Economics

### 4.1 The launchpad

| item | value | source |
| --- | --- | --- |
| Launch fee | none | `pages/02-docs.md`, `contracts/LaunchFactory-0x718633252AA8329495Df8BBa8fF7c9e8378CFC63/sources/src/LaunchFactory.sol` |
| Liquidity you must supply | none, the supply is the liquidity | `LaunchFactory._seedLiquidity` |
| LP fee on a pad pool | 0, `LP_FEE = 0` | `LaunchFactory.sol` |
| Protocol fee per trade | 1.00%, `PROTOCOL_FEE_PIPS = 10000` | `_raw/rpc/live-state.txt` |
| Creator fee per trade | 0.00% to 9.00%, `MAX_CREATOR_FEE_BPS = 900` | `_raw/rpc/live-state.txt` |
| Total a trader can ever pay | 10.00%, `MAX_FEE_RATE = 100000` | `_raw/rpc/live-state.txt` |
| Fee tiers the form offers | 1%, 2%, 5%, 10% total | `pages/07-launch-create.md` |
| Supply choices the form offers | 100M, 1B, 10B, 100B | `pages/07-launch-create.md` |
| First-buy choices | 0%, 1%, 5%, 10% of supply, or a free percentage | `pages/07-launch-create.md` |
| Anti-snipe | creator-set surge in pips, decaying linearly over `snipeWindow` blocks | `LaunchHook._currentRate` |
| Route hop limit on an ether-funded launch | 4, `MAX_ROUTE_HOPS` | `_raw/rpc/live-state.txt` |
| Pad cut on a reflection launch | up to 30% of the creator lane, `MAX_CUT_BPS = 3000` | `contracts/DividendDeployer-0x3087cFD761D679Ded5d0a2baf4d3577aE447d5E3/sources/src/CreatorFeeSplitter.sol` |
| Vesting, creator allocation, team allocation | none of any kind | absence in `LaunchFactory.sol` |

**The 1% is documented as 0.7% buyback and 0.3% protocol.**
The docs' table reads "Buyback and burn 0.70%, buys $HOOD10 on the open market and burns it" plus "Protocol 0.30%".
The `FeeRouter` contract at `0xe1c046571e69Ae2408C21605f2ff657A23977C4c` implements exactly that shape, as `DIVIDEND_SHARE_BPS = 7000` to `dividendSink` and the rest to `protocolTreasury`, and its live config still reads `dividendSink` = the index distributor and `protocolTreasury` = the owner EOA (`_raw/rpc/live-state.txt`).

**That router is not in the path.**
`LaunchHook.feeRouter` today is `0xbd40E13889Cd75D8019CfbaA4f3C5562ba242279`, which has no code.
`RouterUpdated` fired twice: to the `FeeRouter` contract at block 49311480 on 2026-08-29 16:52 UTC, and away from it to this EOA at block 49485132 on 2026-08-29 21:45 UTC (`_raw/rpc/router-updates.txt`).
All 117 `PlatformCollected` events since name that EOA as the collector (`_raw/rpc/hook-fee-events.txt`), and its own transaction list shows it calling `collectPlatform` and `settleMany` directly and forwarding every collected asset, unconverted, to a second EOA `0x7e8ADA37D066a124Cd0A044c1209c48338c962fe` (`_raw/blockscout/eoa-bd40-transactions.json`, `_raw/blockscout/eoa-bd40-token-transfers.json`).
That second EOA trades the proceeds through a router at `0x8876789976dEcBfCbBbe364623C63652db8C0904` and is also `DividendDeployer.feeRecipient` (`_raw/blockscout/eoa-7e8a-transactions.json`).

So the 70/30 split is a policy the team runs off chain today, not a rule the contracts enforce.

**The site's own numbers say the same thing.**
`/api/vault` returns `withdrawnUsd` 55859.07, `buybackUsd` 39101.35, `buybackShare` 0.7 and `paidLifetime` 0 (`_raw/api-launch-vault-2026-09-02b.json`).
39101.35 is exactly 55859.07 times 0.7, so `buybackUsd` is a projection of what the collected fee would buy, not an observed purchase.
The vault page labels `paidLifetime` "paid in, lifetime, from launchpad fees" (`_raw/bundles/launch/_assets_index-xC7QnYIa.js`), and it is zero.
`pages/05-launch-vault.md` renders it as `0.0000 Ξ`.

### 4.2 Quote assets

Launching is permissionless in denomination.
`LaunchFactory._assertQuoteLaunchable` refuses only an address with no code, an asset the `QuoteRegistry` classifies `UNSUPPORTED`, and anything whose `decimals()` reverts.
The `QuoteRegistry` natspec says this in as many words: "This is deliberately NOT an allowlist.
The incumbent pad on this chain restricts launches to an approved ERC-20; letting a creator denominate a pool in literally anything is the product."

The 21 assets the form offers are a convenience list from `/api/vault`, not a gate.

WETH, USDG, HOOD10, PONS, CASHCAT, Index, microduck, YOLO, FRONG, AI, TENDIES, HMM, PENGU, and the tokenized equities SPY, COIN, RBLX, NVDA, AAPL, META, PLTR, TSLA (`_raw/api-launch-vault-2026-09-02b.json`).

The tier only sizes what the fee router is later willing to sell, and the defaults are:

| tier | `maxPoolFractionBps` | `minSweep` | `maxSweepNotional` |
| --- | --- | --- | --- |
| NATIVE, ether or WETH | 0, no sale needed | 10 | unbounded |
| STOCK, an ERC-8056 stock token | 50, 0.5% | 100 | 25,000,000 |
| ECOSYSTEM, HOOD10 and its basket | 100, 1% | 1,000 | 250,000,000 |
| EXOTIC, any other ERC-20 | 25, 0.25% | 1,000 | 50,000,000 |
| UNSUPPORTED | not sweepable, fees park | 0 | 0 |

Source: `contracts/QuoteRegistry-0x5D8b610E39156d2cFeF3c1ceCC3c22f4990A1298/sources/src/QuoteRegistry.sol`, ceiling `MAX_POOL_FRACTION_BPS = 1000` confirmed live in `_raw/rpc/live-state.txt`.

### 4.3 The index token

| item | value | source |
| --- | --- | --- |
| Supply | 1,000,000,000, fully circulating | `_raw/rpc/hood10-token-state.txt` |
| Trade tax | 5.00% buy and sell, `buyTaxRate()` and `sellTaxRate()` both 500 bps, `taxRatePips()` 50000 | `_raw/rpc/hood10-token-state.txt` |
| Documented split of that 5% | 4.00% dividends, 0.70% protocol, 0.30% letscash.fun platform fee | `pages/02-docs.md` |
| Fee currency | WETH, `feeToken()` on the distributor | `_raw/rpc/distributor-state.txt` |
| Constituents | 10, equal weight, 1000 bps each, read live from `getBasket()` | `_raw/rpc/distributor-state.txt` |
| Selection rule | ten largest eligible tokens on the chain by summed pool liquidity, measured at epoch close, HOOD10 excluded | `pages/02-docs.md` |
| Minimum holding to be paid | 100,000 HOOD10, 0.01% of supply | `pages/02-docs.md` |
| Maximum eligible wallets | 10,000 | `pages/02-docs.md` |
| Epoch cadence | the crank checks every three hours and settles only when the accrued tax covers settlement | `pages/01-home.md` |
| Claim window | 15,552,000 seconds, 180 days, `CLAIM_WINDOW()` | `_raw/rpc/distributor-state.txt` |
| Periods settled | `currentPeriodId()` 34; the ledger on the site lists 31 settled epochs and $374,268 distributed | `_raw/rpc/distributor-state.txt`, `pages/01-home.md` |
| Team allocation | none claimed | `pages/02-docs.md` |

**The 5% is charged by letscash.fun's hook, not by anything HOOD10 wrote.**
`HOOD10.hook()` is `CashCatHookV2` `0x75A54357D9C78a2Db19004a5FDc76c50F9242AEC`, and `CashCatHookV2.currentFeeRate(HOOD10 poolId, 0x0)` returns 50000 pips.
`CashCatHookV2.poolConfigs(poolId)` names the recipient of that pool's fee lane as an EOA, `0x639D6Faa4DAf85d4ccc4291D1134C83867df5d82`, not the distributor (`_raw/rpc/hood10-token-state.txt`).
So the tax reaches the index through a wallet, the same shape as the launchpad's fee lane.

**The distributor is a Merkle claim contract, not a push.**
It is unverified, and its surface was recovered by extracting selectors from the deployed bytecode and resolving them against openchain.xyz (`_raw/blockscout/selectors-distributor-resolved.json`).
The resolved names are `commitRoot`, `openClaims`, `claim(uint256,address,uint256,bytes32[])`, `previewClaim`, `closePeriod`, `settleExpired`, `getBasket`, `getPeriod`, `getPeriodRewards`, `currentPeriodId`, `reserved`, `sweep(address,address,uint256)` and Ownable2Step.
The identification is corroborated from an unusual direction: `LaunchDividendTreasury.sol`, which is verified, says it was "adapted from `SimpleRewardTreasury` in the hood10-lite repo, which is the same contract family already running the HOOD10 index in production, the deployment at 0x9f3edbfAE8014d55E328b6Dd966C6C95E75f6210".
Every recent transaction to it is a `claim`, sent by the keeper on a holder's behalf, and one such transaction emits ten `Claimed(epoch, asset, ...)` events plus ten transfers (`_raw/blockscout/tx-distributor-settle-sample-logs.json`).
That is how the docs' "nothing to claim" is delivered: the operator pays the gas to claim for you.

## 5. Smart contracts

The full table, with verification status, proxy relationships, creators and creation transactions, is `contracts/ADDRESSES.md`.
Every contract has a directory with `metadata.json`, `abi.json`, `sources/` or `bytecode.hex`, and a generated `README.md`.

The launch path, in call order:

| address | role | verified |
| --- | --- | --- |
| `0x718633252AA8329495Df8BBa8fF7c9e8378CFC63` | `LaunchFactory`, the only entry point | yes |
| `0xEb0C797DaDd23A7AD0d00187A976143C8AF8972A` | `LaunchGeometry`, linked library, price and tick maths | no, linked libraries are not verified separately |
| `0x5D8b610E39156d2cFeF3c1ceCC3c22f4990A1298` | `QuoteRegistry`, tiering and lot sizing | yes |
| `0x8366a39CC670B4001A1121B8F6A443A643e40951` | Uniswap v4 `PoolManager`, shared by the whole chain | yes |
| `0xe6234a98fF84220CcDA12985548ddAb36327Aacc` | `LaunchHook`, fee engine and liquidity lock | yes |
| `0xe1c046571e69Ae2408C21605f2ff657A23977C4c` | `FeeRouter`, the documented 70/30 split, **no longer wired in** | yes |
| `0x3087cFD761D679Ded5d0a2baf4d3577aE447d5E3` | `DividendDeployer`, the reflection path | yes |
| `0x0E57Ef4Cb77362b3d69EB348735b38534104d237` | `LaunchDividendTreasury`, GOONER's, one per reflection launch | no, deployed with `new` |
| `0x669D54EC9D475AdD053B50CdaC31fa13558553DB` | `CreatorFeeSplitter`, GOONER's | no, deployed with `new` |
| `0x4E17C658b0ccFB5ba0168cf6FF43DA5Ced9afc07` | `LaunchToken`, FLYWHEEL, one example of the output | yes |

The index path:

| address | role | verified |
| --- | --- | --- |
| `0x0D257cA40d40090BE60C2d2Ed5bB3535392838cc` | the HOOD10 token, an EIP-1167 clone | no, a 45-byte clone stub |
| `0xd6Da7f07eE822C8538C901217b37D1e7d86c76E5` | `CashCatTokenV2`, its implementation | yes |
| `0x75A54357D9C78a2Db19004a5FDc76c50F9242AEC` | `CashCatHookV2`, charges the 5% | yes |
| `0x9f3edbfAE8014d55E328b6Dd966C6C95E75f6210` | the index distributor | no, identified by selector matching |

### 5.1 The relationship with CASHCAT and letscash.fun

`SCRAPING-PLAN.md` section 5.8 records a suspicion that "the CashCat contracts suggest launch.hood10.xyz shares infrastructure with the CASHCAT community launchpad".
That is not what the evidence shows, and the correction matters for anyone deciding where to launch.

**The HOOD10 token was launched on letscash.fun.
The HOOD10 Launchpad is separate, later and independent code.**

- HOOD10 at `0x0D257cA4...` is an EIP-1167 clone whose 45-byte stub embeds `CashCatTokenV2`, and its creator is the CashCat factory proxy `0x5bd1Fbe78a78fe8236fa00CF48fbEBA74ae34661` (`_raw/blockscout/address-hood10.json`).
- Its 5% tax is charged by `CashCatHookV2`, and the HOOD10 docs list a 0.30% "letscash.fun platform fee" inside that 5% (`pages/02-docs.md`).
- No launchpad contract references any CashCat address, and no CashCat contract references any HOOD10 launchpad address. The only thing shared is the chain's single Uniswap v4 `PoolManager`.
- The HOOD10 `QuoteRegistry` refers to letscash.fun as "the incumbent pad on this chain" and defines its own product against it.

Full write-up with the live CashCat state and the letscash.fun timeline is in `socials/03-x-letscashfun-and-cashcat.md`.

### 5.2 Unverified contracts, and how each was identified

| address | identified as | method |
| --- | --- | --- |
| `0x9f3edbfAE8014d55E328b6Dd966C6C95E75f6210` | the index distributor, `SimpleRewardTreasury` family | 61 selectors extracted from bytecode, resolved against openchain.xyz, and corroborated by the `LaunchDividendTreasury` natspec naming this exact address |
| `0x0E57Ef4Cb77362b3d69EB348735b38534104d237` | `LaunchDividendTreasury` | selectors match the verified source exactly, and `DividendDeployer.PairDeployed` names it |
| `0x669D54EC9D475AdD053B50CdaC31fa13558553DB` | `CreatorFeeSplitter` | same |
| `0xEb0C797DaDd23A7AD0d00187A976143C8AF8972A` | `LaunchGeometry` | named under `external_libraries` in the verified `LaunchFactory` response, and reached by `delegatecall` in a real launch |
| `0x40250b4C73FC30f8F6ad077744B0124B3f111C28` | the current CashCat factory logic, a UUPS launch factory | 97 of 162 selectors resolved; `launchFee`, `approvedQuote`, `publishConfig`, `upgradeToAndCall` |
| `0x0D257cA40d40090BE60C2d2Ed5bB3535392838cc` | HOOD10, an EIP-1167 clone | the clone stub embeds the implementation address literally |

Raw selector dumps and resolutions are in `_raw/blockscout/selectors-*.txt` and `selectors-*-resolved.json`.

## 6. Backend APIs

Everything the launchpad SPA needs comes from JSON endpoints on its own origin.
No key, no authentication, no CORS restriction observed.
Endpoints were discovered from the network captures in `_raw/network-launch-*.json` and from the app bundle in `_raw/bundles/launch/`.

| endpoint | parameters | returns |
| --- | --- | --- |
| `GET /api/health` | none | chain and deployment state: `block`, `ethUsd`, `indexerLagSeconds`, `indexerTier`, `launches`, `rpcReachable`, and an `addresses` object naming every contract |
| `GET /api/board` | none | a JSON array, one object per launch, with token, creator, quote, poolId, supply, `inPool`, `quoteUsd`, `feeRatePips`, `pending`, `creatorTab`, `creatorPending`, `trades`, `buys`, `volumeQuote`, `price`, `openPrice` |
| `GET /api/token` | `poolId` | one board row for that pool |
| `GET /api/trades` | `poolId`, `limit` | `[{ts, tx, trader, side, token_amt, quote_amt, price}]` |
| `GET /api/candles` | `poolId`, `tf` (for example `5m`) | `[{time, open, high, low, close, volume}]` |
| `GET /api/holders` | `token`, `limit` | `{count, top: [{addr, balance}], float, inPool}` |
| `GET /api/profile` | `address` | `{address, launches: [...], positions: [...], trades: [...]}` |
| `GET /api/vault` | none | the 21 quote assets with their booked and sellable tabs, plus `distributorWeth`, `paidLifetime`, `withdrawnUsd`, `buybackUsd`, `buybackShare` |
| `GET /api/dividendProof` | `treasury`, `account` | Merkle proofs per period for a reflection launch's treasury |
| `GET /api/icon` | `address` | the token image |
| `POST /api/rpc` | JSON-RPC body | proxies chain 4663, **but only for the app**: a direct call returns `{"error":"this endpoint serves the app, not direct calls"}` |

Example, `GET /api/health` (`_raw/api-launch-health.json`):

```json
{"block":52270383,"ethUsd":2413.42,"indexerLagSeconds":0,"indexerBlocksBehind":0,
 "indexerTier":"live","launches":81,"rpcReachable":true,
 "addresses":{"chainId":4663,"launchFactory":"0x718633252AA8329495Df8BBa8fF7c9e8378CFC63",
  "launchHook":"0xe6234a98fF84220CcDA12985548ddAb36327Aacc",
  "quoteRegistry":"0x5D8b610E39156d2cFeF3c1ceCC3c22f4990A1298",
  "feeRouter":"0xe1c046571e69Ae2408C21605f2ff657A23977C4c",
  "dividendSink":"0x9f3edbfAE8014d55E328b6Dd966C6C95E75f6210", ... }}
```

Note that `addresses.feeRouter` here is stale: the payload records itself as `recordedAt` 2026-08-29T16:52:45Z, four hours before the hook's router was pointed at the EOA.
The endpoint still serves the same `addresses` block today, so anyone integrating against `/api/health` will wire up the wrong fee router.

Endpoints that do **not** exist, despite plausible names: `/api/config`, `/api/quotes`, `/api/launch`, `/api/pairs`, `/api/me`, `/api/leaderboard`, `/api/glossary`, `/api/human`.
Each returns `{"error":"no such endpoint: <name>"}` or a 404 (`_raw/api-launch-config.json` and siblings).

The index site at `www.hood10.xyz` has no API of its own.
It reads chain state directly and pulls charts from `api.geckoterminal.com/api/v2/networks/robinhood/pools/<id>/ohlcv/hour` (`_raw/network-home.json`, `_raw/geckoterminal/`).

## 7. Ecosystem

### 7.1 The launchpad, at capture

81 launches, from 2026-08-29 17:20 UTC to 2026-09-01 13:31 UTC, counted from `Launched` events on chain and confirmed by `/api/health` (`_raw/rpc/launch-counts.txt`).
**No launch has happened in the roughly thirty hours before capture**, so the venue's first three days are its whole history so far.

Quote asset chosen, from `/api/board`:

| quote | launches |
| --- | --- |
| WETH | 17 |
| PENGU | 14 |
| HOOD10 | 12 |
| PONS | 7 |
| NVDA | 5 |
| CASHCAT | 4 |
| SPY | 3 |
| Index | 3 |
| RBLX, AAPL, microduck | 2 each |
| COIN, TENDIES, USDG, YOLO, FRONG, AI, META, PLTR, TSLA, HMM | 1 each |

Two thirds of launches are priced in something other than ETH or a stablecoin, which is the product working as intended.

Fee tier chosen:

| total trader fee | launches |
| --- | --- |
| 1%, creator takes nothing | 18 |
| 2% | 42 |
| 5% | 18 |
| 10% | 3 |

Supply chosen: 1B in 61 launches, 100M in 15, 100B in 4, 10B in 1.

### 7.2 Volume is one coin

1,531 trades across all 81 launches, 797 of them buys.
Cumulative volume, converting each pool's `volumeQuote` at the board's own `quoteUsd`, is about **$391,000**.

| coin | quote | volume | trades | market cap |
| --- | --- | --- | --- | --- |
| GOONER | PENGU | $378,820 | 1,331 | $799,147 |
| FLYWHEEL | HOOD10 | $9,466 | 145 | $24,426 |
| WIRED | WETH | $2,491 | 39 | $22,123 |
| OOF | RBLX | $200 | 9 | $4,880 |
| PONSFRIENDS | PONS | $34 | 3 | $7,363 |
| CRI | SPY | $29 | 2 | $3,600 |

Everything else is below $2.
**75 of the 81 launches have one trade or none.**
GOONER alone is 97% of the venue's volume and 87% of its trades.

The pinned X thread claims "The HOOD10 Launchpad has surpassed $5M in total trading volume in just two days" (`socials/02-x-hood10xyz-posts.md`).
The site's own board data does not support that figure by any reading of `volumeQuote` I could construct; the gap is more than an order of magnitude.
Recorded as a discrepancy rather than resolved, because the API does not document what `volumeQuote` counts.

### 7.3 The index, at capture

| metric | value | source |
| --- | --- | --- |
| Holders | 6,086 | `_raw/blockscout/counters-hood10.json` |
| Transfers | 294,043 | same |
| Market cap | about $2.34M | `_raw/dexscreener-token-pairs-hood10.json` |
| Main pool liquidity | $172,765 | same |
| 24h volume, main pool | $461,239 | same |
| Pools | 20 | `pages/01-home.md` |
| Dividends distributed | $374,268 across 31 settled epochs | `pages/01-home.md` |
| Largest epoch | $50,958, epoch 2, 2026-08-24 | `pages/01-home.md` |
| Eligible supply at the last snapshot | 866.9M, 86.69% | `pages/01-home.md` |
| Basket at capture | ten addresses at 1000 bps each, read from `getBasket()` | `_raw/rpc/distributor-state.txt` |
| WETH sitting in the distributor | 2.0898 | `_raw/api-launch-vault-2026-09-02b.json` |

The index is by far the larger of the two products, and it predates the launchpad by five days.

## 8. Link inventory summary

`LINKS.md` has 436 individual rows plus four collapsed rows, generated from `pages/` and the Jina reads and cross-checked against `_raw/links-all.json`, which holds all 746 discovered links with nothing collapsed.

| class | rows | note |
| --- | --- | --- |
| internal, launchpad | 217 | board, token, vault, profile and create routes, plus per-token deep links |
| external, market data | 99 | Dexscreener, from the index pool page |
| internal, index site | 50 | home, docs and the seventeen docs anchors |
| social | 34 | X, all of it |
| external, letscash.fun | 25 | the venue the index token launched on |
| explorer | 6 | Blockscout, contract and token pages |
| external, other | 5 | GeckoTerminal, TradingView, IPFS |
| collapsed: explorer tx | 111 distinct | per-trade links from live feeds |
| collapsed: trader addresses | 13 distinct | per-trader links from live feeds |
| collapsed: letscash profiles | 62 distinct | per-trader links on the letscash listing |
| collapsed: images | 124 distinct | icon CDN URLs |

Both sitemaps are tiny and were fully covered: `www.hood10.xyz` lists two URLs, and `launch.hood10.xyz/sitemap.xml` returns the SPA shell rather than a sitemap, so its routes were enumerated from the bundle and from the board instead.

## 9. Gaps

**The wallet gate was not opened, and did not need to be.**
The create form renders fully with no wallet, including every field, every option and the live launch preview (`pages/07-launch-create.md`).
The only thing behind the connect button is the transaction itself.
Every number in section 3 and 4 was read from the verified sources or from a live `eth_call`, which is stronger evidence than a form capture.

**No launch was simulated.**
Read-only rules apply and no transaction was built or sent.
A creator following section 3.2 should simulate `launchAndBuy` against a fork before spending anything.

**The fee EOAs were not traced to a conclusion.**
`0xbd40E138...` and `0x7e8ADA37...` are documented as far as one page of Blockscout transactions and token transfers each.
Whether HOOD10 is in fact bought and burned with 70% of the collected fee, off chain, was not established either way.
What is established is that no contract enforces it and that `/api/vault` reports `paidLifetime` 0.

**The `$5M volume` claim is unresolved**, as described in section 7.2.

**No team identity was found.**
No name, no GitHub organisation, no audit, no bug bounty, no legal entity, no terms of service and no privacy policy exist on either site.
The `hood10-lite` repository that `LaunchDividendTreasury.sol` refers to is not public: no such repository was found by search (`_raw/bdata-search-hood10.json`).

**No Telegram or Discord.**
The launchpad asks creators for a Telegram link but publishes none of its own.
Support and announcements are X only.

**The index distributor's source is not available.**
Its behaviour is reconstructed from selectors, from live reads, from its transaction history, and from the natspec of the contract that was adapted from it.
The exact meaning of `TOTAL_FEE_BPS() = 4700` was not established.

**Docs corrections that a reader should carry forward.**
Each of these is the documentation being wrong about the project's own contracts, not a capture failure:

1. "Tax range 0% to 10%" on top of a 1% venue fee, "so a 10% coin costs a trader 11%". The contract caps the creator add-on at 9% and the total at 10%, and the form agrees with the contract.
2. "Reflection ... no keeper, no claim, no protocol cut on the way through". All three are wrong: keeper-committed Merkle periods, a `claim` with proofs, and a pad cut bounded at 30% of the creator lane.
3. "Nothing to claim ... rewards are pushed" for the index. The distributor is a Merkle claim contract; the keeper claims on holders' behalf.
4. "Read from chain, never from a database". Eligibility comes from a keeper-committed root that nothing on chain checks, which the sibling contract's natspec states outright.
5. "There is no admin withdrawal." The distributor exposes `sweep(address,address,uint256)` and its owner is the keeper EOA.
6. Epoch length is given as "every eight hours" in the epoch section and "3 hours, variable" in the parameters table of the same page, and the home page says three hours.
7. The 0.7% / 0.3% venue split is not contract-enforced today, as set out in section 4.1.
