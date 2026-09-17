# Pools (pools.trade)

Archive captured 2026-09-02 and 2026-09-03 for the Robinhood Chain launchpad survey.
Every number below cites the file it came from.
Where the platform's own statements and the chain disagree, both are given and the chain is treated as authoritative.

---

## 1. Identity

| field | value | source |
| --- | --- | --- |
| product name | Pools | `_raw/site/manifest.webmanifest`, `pages/12` |
| domain | <https://pools.trade> | `pages/01` |
| other domains | none. No `app.`, `www.` or `docs.` subdomain exists; documentation lives on Uniswap's own properties | route manifest in `_raw/js/manifest-f37f3136.js`, `pages/13` |
| operator | **Uniswap Labs** | `pages/16`, `pages/15`, `socials/02`, `pages/12` |
| chains | Robinhood Chain only, chain id 4663 | `contracts/ADDRESSES.md`, `_raw/leads/uniswap-deployments.json` |
| public launch | 2026-08-05 | `pages/16` (blog, 18:33Z), `socials/02` (@Uniswap, 22:49Z) |
| contracts live earlier | first Crowd Launch auction started 2026-07-13T17:04Z, and over $150M traded through the contracts before the interface existed | `_raw/api/live-cca.listAllAuctions.json`, `socials/02` |
| status | live, self-labelled **Beta** in the header | `pages/01` |
| X | [@TradePools](https://x.com/TradePools), 26,259 followers, X affiliate badge pointing at @Uniswap | `socials/01` |
| Discord / Telegram | none of its own; the blog footer points at Uniswap's Discord | `pages/16` |
| GitHub | no pools.trade repo. The contracts are `Uniswap/liquidity-launcher`, `Uniswap/uerc20-factory` and the CCA repo | `pages/15`, `resources/uniswap/liquidity/liquidity-launchpad/overview.md` |
| DefiLlama | slug `pools`, category Launchpad, $1.54M fees in 30 days, $0 revenue | `socials/03` |
| legal entity in the footer | "© 2026 Uniswap Labs", linking to uniswap.org terms and privacy | `pages/10`, `pages/02` |
| search indexing | deliberately `noindex, nofollow` while in beta | `pages/12` |
| audits | none published. DefiLlama records `audits: "0"` | `socials/03` |

---

## 2. What it is, and who actually operates it

Pools is a consumer front end for the **Uniswap Liquidity Launchpad**, restricted to Robinhood Chain, that lets anyone mint a fixed-supply memecoin and put its entire supply into a Uniswap v4 pool whose LP position is permanently locked.
It is a launchpad in the sense that it bootstraps the pool for you; it is not a bonding-curve-then-migrate pad in the usual sense, because for one of its two models nothing ever migrates and for the other the migration destination is a plain v4 pool with no hook.

### The operator question, settled

`SCRAPING-PLAN.md` section 5.10 records a TrustSwap page claiming Pools.trade was built by Uniswap Labs and asks for that to be verified or refuted.
It is **confirmed**, by six independent lines of evidence, three of them on-chain.

1. **Uniswap Labs' own blog.** <https://blog.uniswap.org/pools-trade-a-new-way-to-launch-on-robinhood-chain>, published 2026-08-05T18:33:17Z, under the heading "Built by the most trusted team in DeFi": "Pools is built by Uniswap Labs." (`pages/16`)
2. **Uniswap Labs' own help centre.** <https://support.uniswap.org/hc/en-us/articles/47943121516685>, published 2026-08-06: "Pools.trade is a token launchpad built by Uniswap Labs for Robinhood Chain." (`pages/15`)
3. **The @Uniswap and @haydenzadams accounts announced it as theirs**, and @TradePools carries an X affiliate badge issued by @Uniswap. Hayden Adams: "Uniswap Labs team has been cooking hard on this one but its still in beta." (`socials/01`, `socials/02`)
4. **Uniswap's machine-readable deployment feed lists every contract.** <https://developers.uniswap.org/deployments.json>, generated from `github.com/Uniswap/contracts` commit `3793618`, carries 42 records for chain 4663, including `LiquidityLauncher 0x0000FffFBE8efE702c8703aE3477FF5dE3d319C0`, `InstantLaunchStrategy#creator-fees 0x23f8209572b4a1C2AD88A42749E830791Fb027f1`, `FeeSplitter#creator-fees 0xeFF166AAf189323c58dc27eD1206EB2C37FaACDf` and `ContinuousClearingAuctionFactory 0x000000001F26a0044BaA66024e7b6599c61963F8`. Those are exactly the addresses the pools.trade frontend pins in `_raw/js/useCreatorFeeExecutor-44W_DATt.js`. (`_raw/leads/uniswap-deployments.json`)
5. **The verified on-chain sources are Uniswap's.** `LBPStrategy.sol` on chain carries `/// @custom:security-contact security@uniswap.org`, and the import paths are `@uniswap/v4-core`, `@uniswap/v4-periphery`, `@uniswap/blocknumberish` and `lib/liquidity-launcher`. (`contracts/LBPStrategy-0x05d552391067389EE44fec3924157ed33F976000/sources/`)
6. **The deployer key is Uniswap's.** Every core contract was deployed through the canonical CREATE2 proxy `0x4e59b448...` by the EOA `0x32f4B2e69EbD7746596AF8699DAC1908F43107aD`. That same EOA deployed `ContinuousClearingAuctionFactory` at the identical address `0x000000001F26a0044BaA66024e7b6599c61963F8` on Ethereum mainnet, per Etherscan's `getcontractcreation`. (`_raw/blockscout/tx-0xbf68c51ed936a2a33fa3450ccf245bad1df199a15392bfd754935ba4d6728ccc.json`, `_raw/leads/etherscan-mainnet-creators.json`)

Supporting, non-decisive: the app is built from the Uniswap design system (Basel Grotesk, `bg-surface1 text-neutral1`, `#131313`), it compiles the `uniswap.liquidity.v1.ChainId` protobuf enum, it proxies `uniswap.platformservice.v1.SessionService` and `data.v1.DataApiService` same-origin under `/entry-gateway/`, and its Datadog service tag is `rh-cca` (`pages/13`).

### It is not "pools fun"

`SCRAPING-PLAN.md` section 5.10 also asks whether the Reddit "pools fun" post, which names a `PartyFactory` at `0x626C3d09B65bF5d1D40E0D5F25e19fa49783B3D4`, describes the same project.
It does not.
That contract is verified on chain, is named `PartyFactory`, and its own natspec says it "Deploys **pools.fun** tokens ... seeds a single-sided full-range **SushiSwap V3** position".
It was deployed by an unrelated EOA, uses a 1% fee tier and tick spacing 200, and appears nowhere in Uniswap's deployment feed.
Full side-by-side in `pages/14-pools-fun-is-a-different-platform.md`.

### The two launch models

| | Crowd Launch | Instant Launch |
| --- | --- | --- |
| internal name | CCA, run through `LBPStrategy` | `InstantLaunchStrategy` |
| `launchpadId` in the API | `uniswap-cca` | `uniswap-bonding-curve` |
| tradable | only after the window closes and the launch graduates | in the same block it is created |
| price | discovered by a continuous clearing auction | fixed at strategy deployment |
| supply split | 50% auctioned, 50% seeds the pool | 100% into the pool as one single-sided position |
| failure mode | below $10K FDV every bid is refunded and the token never trades | none, it always launches |
| share of recent launches | 4 of the 50 most recent launcher calls | 46 of 50 |
| all-time count | 126 auctions ever, 64 graduated | tens of thousands, see section 7 |

Both end in the same place: a hookless Uniswap v4 ETH pool at a 0.25% LP fee, tick spacing 25, whose LP position is owned by a `FeeSplitter` that can collect fees and increase liquidity but can never transfer the position out.

Who it is for: someone launching a memecoin who wants Uniswap-grade routing and distribution from block one and has no ETH to seed a pool with.
The interface, the blog and the terms all say memecoins explicitly, and "Any use of Pools for an asset other than a meme coin is prohibited" (`pages/15`).

---

## 3. How a launch works, as the creator experiences it

Captured by driving the real create flow with a headless observer wallet (`pages/03`, `pages/04` to `pages/07`), then decoding 50 real production launches to confirm every parameter (`_raw/blockscout/decoded-launcher-recent-50.txt`).

### Step 0, connect

Everything except creating, buying and the portfolio is readable anonymously.
Pressing `Launch a token` opens a modal; the only gate is `Connect a wallet`.
There is no Sign-In-With-Ethereum step, no server nonce and no signature: announcing an EIP-6963 provider and returning an account is enough (`pages/03`).
The named connectors are Robinhood Crypto, Uniswap Mobile and WalletConnect.

### Step 1, pick a model

Two radio cards.
Verbatim (`pages/02`):

> Fixed supply of 1B tokens. Fees auto-compound for added liquidity.
>
> **Crowd Launch** - Bundle resistant, fairer distribution
> - 4-hour launch window, $10K FDV graduation target
> - TWAP bids prevent bundling
> - Token tradable if launch graduates; bids refunded if not
> - Deeper liquidity, locked forever
>
> **Instant Launch** - Standard bonding curve launch
> - No sniper protection
> - Tokens immediately onchain
> - Token tradable any time
> - Liquidity locked forever

"Standard bonding curve launch" is the interface's own wording and is loose.
There is no bonding curve contract; an Instant Launch is a single v4 position spanning `MIN_LAUNCH_TICK` to `initialTick` holding the whole supply, which behaves like a curve as it is bought through (`_raw/rpc/derived-economics.txt`).

### Step 2, token info

Four required fields and two optional switches:

| field | required | notes |
| --- | --- | --- |
| Token image | yes | "256px or larger recommended". `Review` stays disabled without one. Uploaded to IPFS; every decoded production launch carries an `ipfs://` URI |
| Token name | yes | free text |
| Ticker symbol | yes | free text |
| Description | yes | 280 character limit, counter shown |
| X Profile | no | an OAuth connect button; verified handles get a badge and a "Linked X" discovery tab |
| Creator fee | no | off by default. Label: "Earn 0.1% of every buy. Paid in ETH." Turning it on reveals a `Fee recipient` field pre-filled with the connected wallet, annotated "Fee recipient can be updated any time" |
| Buy at launch | Instant Launch only | off by default. Sizes 0.5%, 1%, 2%, 5% of supply, default 1% |

Nothing else is configurable.
Supply, price, fee tier, tick spacing, duration, graduation target and lock are all fixed by the platform.
The review screen says so: "Pools uses standardized configurations for every launch ...
The fully configurable CCA is available if you want to set your own supply, duration, allocations, or compliance features."

At the 1% default, a `Buy at launch` was quoted as 10,000,000 APROBE for 0.0253656178726954 ETH, `$60.94` (`pages/06`).
That implies an opening FDV near $6.0K, which matches `initialSqrtPriceX96` read from the contract.

### Step 3, review and sign

**Crowd Launch review** (`pages/05`):

| row | value |
| --- | --- |
| Launch window | 4 hours, with the end time shown |
| Supply | 1 billion. "50% sold in the launch window, remainder seeds locked liquidity - leftover tokens are burned" |
| Graduation target | "$10K FDV. All orders refunded if it falls short" |
| Creator fee | "0.1% of every buy", with the recipient address |
| Network cost | `$7.14` |

**Instant Launch review** (`pages/07`):

| row | value |
| --- | --- |
| Tradable | Immediately |
| Supply | 1 billion. "Entire supply mapped to bonding curve" |
| Creator fee | "0.1% of every buy" |
| Network cost | `$2.83` |

There is no launch fee line on either screen, because there is no launch fee.
The only cost of launching is gas.

### What the transaction actually is

One `LiquidityLauncher.multicall` from the creator's wallet.
Of the 50 most recent launcher transactions, 36 carried three inner calls and 14 carried two:

```text
createToken(UERC20Factory, name, symbol, 18, 1e27, LiquidityLauncher, metadata)
distributeToken(token, (strategy, 1e27, configData), graffiti)
distributeWithNative(UniversalRouterStrategy, route, graffiti, msg.value)   # only when "Buy at launch" is on
```

- `createToken` always mints exactly `1e27` (1 billion, 18 decimals) through `UERC20Factory 0x000000e200088D55C39a11F609E5F667729ad49b`, with the recipient set to the launcher itself. Its `metadata` is `(description, xUrl, tokenURI)`, for example `("Ponzi Scheme", "https://x.com/doesntmattersol", "ipfs://bafybeie...")`.
- For an Instant Launch, `configData` is exactly 32 bytes: the creator fee beneficiary. In every sampled launch it equalled the launching wallet.
- For a Crowd Launch, `configData` is `abi.encode(MigratorParameters, auctionParameters)` and is fully decoded in `_raw/rpc/derived-economics.txt`.
- `distributeWithNative` is the anti-snipe mechanism the blog describes: the creator's first buy lands in the same transaction as the launch, so no sniper can be first (`pages/16`).

Nothing was ever broadcast from this archive.
The shared test wallet holds 0.00100 ETH, below both quoted network costs, so both review screens ended at `Add funds` (`pages/03`).

### After the launch

**Instant Launch.** The pool exists and trades immediately. There is no graduation event and nothing migrates. The API reports `graduationTargetUsd: 50000` on every Instant Launch record, which drives the "Near graduation" discovery tab; it is a display milestone, not an on-chain state change (`pages/13`).

**Crowd Launch.** Bids fill continuously over 144,000 blocks. The issuance schedule is 13 steps: twelve of about 5.82% of the auction supply each, spread over 143,999 blocks, then a final step releasing the remaining 30.011% in the single last block. Everything sums to exactly 1e7 mps, 100% of the auction supply (`_raw/rpc/derived-economics.txt`). `claimBlock` equals `endBlock`, so claiming opens the moment the window closes. If the raise clears `requiredCurrencyRaised`, `LBPStrategy.migrate()` mints the pool position; if not, every bid is refundable and the tokens go to `0x...dEaD`. Claims and refunds are both manual (`pages/15`).

**Creator fees.** Turning the switch on routes the position through `FeeSplitter 0xeFF166AAf189323c58dc27eD1206EB2C37FaACDf`, which pays 40% of the ETH side into `UERC20BeneficiaryVault 0xd35E9CA72F64C7F93BE30fad67524323396B36D7`. Registration there mints a transferable ERC-721; only its holder can claim, and it can be sold or moved, which is what "Fee recipient can be updated any time" means. Collection is permissionless: anyone can trigger it, and the money still lands with the NFT holder.

---

## 4. Economics

Everything in this table is either read live from the chain or decoded from a real production launch.
`source` names the file.

| item | value | source |
| --- | --- | --- |
| cost to launch | **zero fee, gas only**. Quoted `$2.83` for an Instant Launch and `$7.14` for a Crowd Launch at capture | `pages/07`, `pages/05` |
| platform cut of the raise | **zero**. `ContinuousClearingAuctionFactory.protocolFeeController()` is the zero address | `_raw/rpc/derived-economics.txt` |
| platform cut of trading fees | **zero**. DefiLlama records $1.596M lifetime fees and $0 lifetime revenue | `socials/03` |
| graduation fee | none, no such step exists | `pages/15` |
| token supply | exactly 1,000,000,000, 18 decimals, in all 50 sampled launches and all 126 auctions | `_raw/blockscout/decoded-launcher-recent-50.txt`, `_raw/api/live-cca.listAllAuctions.json` |
| supply available to the creator | none by default. 100% goes into the pool. The only way to hold supply at launch is the optional `Buy at launch`, capped at 5% and paid for at the pool price | `pages/06` |
| quote asset | native ETH. Every launch pool is ETH paired, and `MigratorParameters.currency` is `0x0` | `_raw/rpc/derived-economics.txt` |
| destination DEX | Uniswap v4 on chain 4663, `PoolManager 0x8366a39CC670B4001A1121B8F6A443A643e40951` | `contracts/ADDRESSES.md` |
| pool LP fee | **0.25%** (`LP_FEE() = 2500`), static, hookless pool | `_raw/rpc/derived-economics.txt` |
| pool tick spacing | 25 | `_raw/rpc/derived-economics.txt` |
| Uniswap v4 protocol fee | **0.04% on top**, in both directions. `StateView.getSlot0` on the POOLS pool returns `protocolFee = 1638800`, which unpacks to 400 and 400 hundredths of a bip. It accrues to Uniswap's `V4FeeAdapter 0x6d0009504d129cf5002dba61d9ae8575aa79314c`, not to pools.trade and not to the creator | `_raw/rpc/derived-economics.txt`, `socials/02` |
| total trader cost | about 0.29% per swap, that is 0.25% LP plus 0.04% protocol, combined per v4's `protocolFee + lpFee - protocolFee*lpFee/1e6` | derived |
| creator fee, contract truth | 40% of the **native side** and 0% of the token side of the LP fee. `FeeSplitter.getSplits()` returns `[(vault, 4000, 0, true), (compounder, 6000, 10000, true)]` | `_raw/rpc/derived-economics.txt` |
| creator fee, as the app states it | "Earn 0.1% of every buy. Paid in ETH." That is 40% of 0.25%, and it is correct for buys | `pages/04` |
| creator fee, as the docs state it | "receive 0.05% of the 0.25% LP fee", and Hayden Adams says "20% to the creator and 80% to the liquidity compounding mechanism". Both are the blended figure across buys and sells, since sells pay in token and the token side goes 100% to compounding | `pages/15`, `pages/16`, `socials/02` |
| rest of the fee | auto-compounded back into the same locked position by `CompoundingClaimRecipient 0xf9526Dd3361fe0ba6b7a99533ed471D3E808E99a`. With creator fees off, `FeeSplitter 0x222D6d4f...` sends 100% of both sides there | `_raw/rpc/derived-economics.txt` |
| liquidity lock | permanent. The LP position is minted to a `FeeSplitter`, which exposes only fee collection and liquidity increase. No withdrawal path exists for anyone | `contracts/FeeSplitter-creator-fees-.../sources/`, `pages/16` |
| vesting | none. There is no creator allocation to vest | `_raw/blockscout/decoded-launcher-recent-50.txt` |
| Instant Launch opening price | `initialTick() = 198050`, `initialSqrtPriceX96 = 1582215647010010450556252328775749`, so about 398,800,000 tokens per ETH, that is 1B tokens for about 2.507 ETH, about **$6.0K FDV** at ETH $2,395 | `_raw/rpc/derived-economics.txt` |
| Instant Launch position range | `MIN_LAUNCH_TICK -160100` to `initialTick 198050`, one position, `positionLiquidity 50074188046840591947412` | `_raw/rpc/derived-economics.txt` |
| Crowd Launch floor | `floorPrice` Q96 `33125577670982257900` = 4.181e-10 ETH per token = 0.4181 ETH for the full supply, about **$1,004 FDV**. Chosen per launch so the floor lands near $1,000 | `_raw/rpc/derived-economics.txt`, `_raw/api/live-cca.listAuctions.json` |
| Crowd Launch bid granularity | `tickSize` is exactly 1% of `floorPrice`, in all 100 sampled auctions | `_raw/api/live-cca.listAuctions.json` |
| Crowd Launch graduation | `requiredCurrencyRaised = 2.0905178565 ETH`, exactly 5x the floor FDV. 50% of supply sold for that implies a **$10K FDV** clearing price, which is what the interface shows | `_raw/rpc/derived-economics.txt` |
| Crowd Launch window | `endBlock - startBlock = 144,000` blocks = 14,400 s = **4.00 hours** at Robinhood Chain's 0.1 s blocks. 4.00 h in all 100 sampled auctions | `_raw/rpc/derived-economics.txt` |
| Crowd Launch claim delay | none. `claimBlock == endBlock` | `_raw/rpc/derived-economics.txt` |
| Crowd Launch supply split | `reservedTokenAmountForLP = 500,000,000`, exactly 50% | `_raw/rpc/derived-economics.txt` |
| Crowd Launch unsold supply | burned. `tokensRecipient` and `MigratorParameters.recipient` are both `0x...dEaD` | `_raw/rpc/derived-economics.txt` |
| Crowd Launch raise allocation | 100% into the LP. `lpAllocationSchedule` is a single bracket `(lowerThreshold 0, rate 1e7)` | `_raw/rpc/derived-economics.txt` |
| Crowd Launch LP range | one position, offsets `-98438` to `+98538` around the clearing tick, weight 1e7 | `_raw/rpc/derived-economics.txt` |
| anti-snipe, Crowd Launch | the 13-step issuance schedule. 70% of the auction supply drips over 4 hours and 30% clears in the final block, so a single-block bundle cannot take the supply | `_raw/rpc/derived-economics.txt` |
| anti-snipe, Instant Launch | only the optional `Buy at launch`, which bundles the creator's buy into the launch transaction. The interface itself says "No sniper protection" | `pages/02`, `pages/16` |
| KYC | none | `pages/15` |
| minimum raise | none for Instant Launch; the $10K FDV target for Crowd Launch | `pages/05`, `pages/07` |
| max supply purchasable at launch by the creator | 5% | `pages/06` |
| buyback and burn | `BuybackAndBurnClaimRecipient 0xa1ba4CC12654D2b188e3ba77dc86c75cA47f1A4e` exists with `minCurrency1BurnAmount() = 500,000` tokens, but no live pools.trade `FeeSplitter` routes to it | `_raw/rpc/derived-economics.txt` |

### What a creator with no LP budget actually pays and receives

Cost: one transaction's gas, `$2.83` at capture for an Instant Launch.
No fee to the platform, ever, at any stage.
No supply given up.

Received: 40% of the ETH side of a 0.25% LP fee on their token, forever, claimable at will, transferable as an ERC-721.
On a token doing $100K of buy volume a day, that is about $100 a day.

Given up: the liquidity itself.
The entire supply goes into a pool the creator can never withdraw from, and the other 60% of the ETH fee plus 100% of the token fee is compounded back into that same locked pool rather than paid out.
There is no path by which a creator recovers the token supply.

---

## 5. Smart contracts

Full table with creators, creation transactions and per-contract directories: `contracts/ADDRESSES.md`.
40 contracts have a directory; 28 have verified sources and 12 hold runtime bytecode plus an explanatory note.

### The launch path

```text
creator EOA
  |
  |-- LiquidityLauncher 0x0000FffFBE8efE702c8703aE3477FF5dE3d319C0   (v3.2.0, verified)
        |
        |-- createToken -> UERC20Factory 0x000000e200088D55C39a11F609E5F667729ad49b -> a new UERC20
        |
        |-- distributeToken -> one of:
        |     InstantLaunchStrategy 0x23f8209572b4a1C2AD88A42749E830791Fb027f1  (creator fees)
        |     InstantLaunchStrategy 0xAD44D55E7f8337C3cE113fBb591486E85be104b2  (no creator fees)
        |       -> PoolManager 0x8366a39C..., PositionManager 0x58daec31...
        |       -> LP NFT to FeeSplitter 0xeFF166AA... or 0x222D6d4f...
        |            -> UERC20BeneficiaryVault 0xd35E9CA7...        40% native
        |            -> CompoundingClaimRecipient 0xf9526Dd3...     60% native + 100% token
        |   or
        |     LBPStrategy 0x05d552391067389EE44fec3924157ed33F976000  (v3.1.1, Crowd Launch)
        |       -> ContinuousClearingAuctionFactory 0x000000001F26a0044BaA66024e7b6599c61963F8
        |            -> a fresh ContinuousClearingAuction per launch (CREATE2, unverified instance)
        |       -> migrate() -> PoolManager -> LP NFT to FeeSplitter 0xeFF166AA...
        |
        |-- distributeWithNative -> UniversalRouterStrategy 0x1242c9439d589cAE85E121B1f79f2aF51e91DCEE
              -> UniversalRouter 0x8876789976dEcBfCbBbe364623C63652db8C0904   (the launch buy)
```

### Notes worth carrying forward

- **Every core address matches Uniswap's published deployment feed for chain 4663.** The one exception is the Universal Router: the app pins `0x8876789976dEcBfCbBbe364623C63652db8C0904` while `deployments.json` lists `0x06AfBA43Fd06227fA663b0DAecF536f6EaA6bf99` for the same chain. The Bags docs call `0x8876...0904` the Robinhood-modified fork. Resolving that pair is already an open item in `SCRAPING-PLAN.md` section 5.12.
- **All strategy parameters are immutable and set at deployment.** There is no owner, no setter and no upgrade path on the strategies, the fee splitters, the vault or the compounding recipient. None of them is a proxy. The `FeeSplitter` split table is fixed in the constructor.
- **Two addresses in the app bundle are not deployed on this chain.** `eth_getCode` returns `0x` for `0x088ca22b...` (described as the early-test CCA factory) and `0x5fAE4679...` (the v1 tick lens). They are other-chain deployments carried in the shared Uniswap bundle.
- **The frontend's own strategy registry disagrees with the chain by 10 ticks.** `_raw/js/useCreatorFeeExecutor-44W_DATt.js` records `initialTick: 198060` for every Robinhood strategy; every deployed strategy returns `198050`.
- **`0xcccccccae7503cac057829bf2811de42e16e0bd5` is mislabelled in the bundle.** The app calls it the "v1 TWA auction factory"; on chain it verifies as `ContinuousClearingAuctionFactory`.
- **A per-launch auction contract shows unverified but its source is the factory's.** `ContinuousClearingAuction` instances are deployed with CREATE2 by the verified factory, so `src/ContinuousClearingAuction.sol` inside `contracts/ContinuousClearingAuctionFactory-.../sources/` is the authoritative source for every one of them.
- **Eight superseded Instant Launch strategies and three superseded fee splitters are unverified.** Runtime bytecode comparison places all the post-2026-07-30 strategies in one 10,822-byte family with the current verified pair, so only their immutables differ; the 2026-07-29 pair is a different 10,774-byte generation. The three old splitters are byte-identical to each other.

---

## 6. Backend APIs

Full detail, with request shapes, field lists and observed value ranges: `pages/13-backend-api.md`.

Three back ends.

### 1. `pools.trade/api/trpc/*`, the launchpad's own tRPC v11 router

Open, no key, no cookie, batched GET.
Namespaces `cca` (Crowd Launch), `curve` (Instant Launch), `prices` and `session`.

```bash
curl -s 'https://pools.trade/api/trpc/cca.listAuctions?batch=1&input=%7B%220%22%3A%7B%7D%7D'
curl -s 'https://pools.trade/api/trpc/curve.listLaunches?batch=1&input=%7B%220%22%3A%7B%22sortBy%22%3A%22trending%22%7D%7D'
```

`curve.listLaunches` returns 100 records with `fdvUsd`, `poolStats`, `recentTrades`, `holderCount`, `safety` and `launchpadId`.
`cca.listAuctions` returns 100 auctions with `clearingPriceQ96`, `floorPriceQ96`, `tickSizeQ96`, `raisedEth`, `startsAt` and `endsAt`.
`cca.listAllAuctions` returns the complete history, 126 records.
The `prepareBid`, `prepareClaim`, `prepareRefund` and `prepareExitAndClaim` procedures build calldata server-side, which is why the frontend needs no auction ABI.

### 2. `pools.trade/entry-gateway/*`, a same-origin Connect-RPC proxy onto Uniswap Labs services

`uniswap.platformservice.v1.SessionService/{InitSession,Challenge,Verify}`, `uniswap.notificationservice.v1.EventSubscriptionService/Subscribe` and `data.v1.DataApiService/GetTokenPrices`.

### 3. Telemetry

Datadog RUM with the service tag `rh-cca`, and an Amplitude proxy at `/amplitude-proxy`.

There is no public REST API, no OpenAPI document and no subgraph.

---

## 7. Ecosystem

All figures as of 2026-09-03 unless dated otherwise.

### Activity

| metric | value | source |
| --- | --- | --- |
| transactions to `LiquidityLauncher` v3.2.0 since 2026-08-05 | 43,904 | `_raw/blockscout/counters-0x0000FffFBE8efE702c8703aE3477FF5dE3d319C0.json` |
| transactions to `LiquidityLauncher` v3.0.0, the pre-interface period | 7,887 | `_raw/blockscout/counters-0x00004c4ccc709Ef590F7C81102C0689F0263D4e9.json` |
| Crowd Launch auctions, all time | 126 | `_raw/api/live-cca.listAllAuctions.json` |
| of those graduated | 64 | same |
| failed | 57 | same |
| live at capture | 5 | same |
| Crowd Launch graduation rate among concluded auctions | 52.9% | derived, 64 of 121 |
| first Crowd Launch auction | 2026-07-13T17:04Z | same |
| transactions to `UERC20BeneficiaryVault` | 30,894 | `_raw/blockscout/counters-0xd35E9CA72F64C7F93BE30fad67524323396B36D7.json` |
| fees, 24h / 7d / 30d / all time | $49,911 / $274,131 / $1,542,145 / $1,596,520 | `socials/03` |
| protocol revenue | $0, all time | `socials/03` |

The graduation rate deserves emphasis because it is unusually high for this chain.
Flap's measured graduation rate was 0.07% to 0.21%; Pools Crowd Launch is 52.9%.
That is a consequence of the $10K FDV bar, which is very low, not of better outcomes.

Instant Launch is by far the more used model: 46 of the 50 most recent launcher calls, against 4 Crowd Launches.
Taking the launcher transaction count as a proxy, on the order of 44,000 tokens have launched since the interface went live, of which roughly 120 were Crowd Launches.

### Notable tokens, from the live discovery feed

| token | symbol | address | model | FDV | 24h volume | holders |
| --- | --- | --- | --- | --- | --- | --- |
| Hookr.fun | HOOKR | `0x18E674231A58c239Dc7DaeDcffE15Ec3A24cff5c` | Instant | $12.9M | $3.6M | 5,360 |
| Prologue | PROLOGUE | `0xb9972CA7188e511174947E3936a5315ac7073277` | Instant | $9.4M | $6.4M | 7,330 |
| frong | FRONG | `0x6245e67affA44a23077f0Ea7f981a8DC743a0c47` | Instant | $9.1M | $8.3M | 15,028 |
| pools.trade | POOLS | `0x385b36Ff682Ab4C76E7c37A66b96aABC466471d5` | Instant | $2.4M | $1.1M | 6,238 |
| LogosLayer | LOGOS | `0x8C63B6adFb469Bbd0cD5d6EE64F73407f15f4c6c` | Instant | $1.6M | $224K | 572 |
| NOLOCK | WLAI | `0x68E3bE6252d97C71b109F1FDb5E4a5b284b7d96d` | Crowd, graduated 2026-08-27 | $1.4M | $64K | 191 |

The `POOLS` ticker is not protocol-owned.
It was launched on 2026-07-30 by `0xbE4EbA417999C7269c6d631eaEF82ad3F2bCdd9e` through the platform's own Instant Launch, like any other token.
DefiLlama's methodology note that "There is no pools.trade token" is correct in the sense that matters, that nothing accrues to it, but the ticker exists (`socials/03`).

### Distribution

Dexscreener indexes the launch pools under `chainId: robinhood`, `dexId: uniswap`, `labels: ["v4"]`, keyed by the v4 pool id rather than an address (`_raw/dexscreener/`).
Third parties open secondary pools against launched tokens: POOLS also has a Uniswap v3 WETH pair with $3.7K of liquidity and a v4 USDG pair with $11.0K, neither created by the platform.

Uniswap's own claimed day-one integrations are the Uniswap web app, the Uniswap wallet, the Uniswap trading API and its integrators including MetaMask and Ledger, plus Bitget, Fomo, GMGN and OKX Wallet (`pages/16`).
Hayden Adams reported Binance wallet support on 2026-08-13 (`socials/02`).
Tokens link out to `app.uniswap.org/explore/tokens/robinhood/<address>` from every token page.

---

## 8. Link inventory summary

`LINKS.md` has 100 rows.

The site itself is small: five real routes (`/`, `/create`, `/t/:address`, `/portfolio`, `/teaser`) plus an X OAuth callback, and a handful of API paths.
There is no documentation on the domain at all.
Every explanatory link points off-site to Uniswap Labs properties: `uniswap.org` for terms and privacy, `support.uniswap.org` for the user guide and the CCA explainer, `blog.uniswap.org` for the announcement, `app.uniswap.org` for the web app, the Launches aggregator and the fully configurable CCA form, and `docs.uniswap.org` / `developers.uniswap.org` for the contracts.

The remaining rows are token pages, all rendered from one template, captured twice: `pages/08` for an Instant Launch and `pages/09` for a live Crowd Launch.

Off-platform pages captured into this archive: the Uniswap support guide (`pages/15`), the Uniswap blog announcement (`pages/16`), the CCA support explainer (`_raw/jina/`), the DefiLlama records (`socials/03`), seven X posts (`socials/01`, `socials/02`) and Uniswap's `deployments.json` (`_raw/leads/`).
The technical documentation for the Liquidity Launchpad was already archived by an earlier session at `resources/uniswap/liquidity/liquidity-launchpad/` and is not duplicated here.

---

## 9. Gaps

1. **No launch transaction was captured from the interface.** The shared test wallet holds 0.00100 ETH, about $2.40, and both review screens quote a higher network cost, so the flow ends at `Add funds` and the wallet is never asked to sign. Closed from the other side: 50 real production launches are decoded in `_raw/blockscout/decoded-launcher-recent-50.txt`, and every parameter in section 3 and section 4 comes from those or from `eth_call`. Topping the wallet up to about 0.01 ETH would let a future session capture the actual `eth_sendTransaction` payload.

2. **No exact launch count.** There is no Doppler-style indexer for this stack and no subgraph. Section 7 uses `LiquidityLauncher` transaction counts as a proxy, which slightly overcounts because `depositToken` and standalone `distributeToken` calls land on the same address. An exact figure needs an `eth_getLogs` scan for the token-creation event across roughly 48 million blocks, which was out of budget for this session.

3. **The Universal Router discrepancy is recorded, not resolved.** The app pins `0x8876789976dEcBfCbBbe364623C63652db8C0904`; Uniswap's own feed lists `0x06AfBA43Fd06227fA663b0DAecF536f6EaA6bf99` for chain 4663. Both are archived. `SCRAPING-PLAN.md` section 5.12 item 3 already owns this.

4. **`PoolManager` ownership is not traced.** `PoolManager.owner()` is the EOA `0x2bad8182c09f50c8318d769245bea52c32be46cd`, with no ProxyAdmin or Safe behind it because the contract is not a proxy. Who controls that key, and therefore who can change the v4 protocol fee on every Pools pool, is unresolved. It is Uniswap v4 chain infrastructure rather than a pools.trade contract, so it sits outside this section's scope, but it is the single largest unaudited trust assumption in the stack.

5. **Twelve contracts are unverified.** Eight superseded Instant Launch strategies, three superseded fee splitters, and the sampled per-launch auction instance. All have runtime bytecode on disk, and each directory README says which verified contract to read instead. No unverified contract sits in the current launch path.

6. **No audit exists to archive.** DefiLlama records `audits: "0"` and Uniswap has published none for the Liquidity Launchpad on this chain. The header still says Beta.

7. **`@TradePools` has no retrievable timeline.** The X syndication endpoint returns `entries: []` for this account, and Bright Data's `x_posts` pipeline needs status URLs. Three posts were captured by id; the other 115 were not.

8. **The X Profile connect step was not exercised.** It requires an X OAuth session, and the callback route `/liquidity/launch-auction/x/callback` was therefore never reached. What a linked X handle changes, beyond the badge and the "Linked X" discovery tab, is not documented here.

9. **Uniswap's protocol fee is stated for one pool, not all.** `protocolFee = 0.04%` was read from the POOLS pool's `getSlot0`. It is set per pool by the `V4FeeAdapter`, so another Pools pool could in principle carry a different value. It was not sampled across pools.
