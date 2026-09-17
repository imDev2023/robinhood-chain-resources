# Sentry

## 1. Identity

Sentry is a non-custodial trading app with a token launchpad built into it, operated by Mavrk, Inc., a Delaware corporation incorporated 2026-06-12 (`pages/60-quotrons-about.md`).

| field | value | source |
| --- | --- | --- |
| App | <https://www.sentry.trading/> | `pages/01-app-discover-tokens.md` |
| Guest swap and lock surface | <https://www.sentry.trading/swap>, <https://www.sentry.trading/lock> | `pages/12-app-swap-public.md`, `pages/13-app-lock-public.md` |
| Guide | <https://www.sentry.trading/desktop/guide>, and the whole thing as one file at <https://www.sentry.trading/sentry-guide.md> | `pages/16-guide-welcome.md` to `pages/57-guide-privacy-policy.md`, `pages/58-guide-machine-readable-source.md` |
| X | [@sentrylauncher](https://x.com/sentrylauncher), 193 posts, 2,804 followers, joined January 2026 | `socials/01-x-sentrylauncher.md` |
| Telegram | [t.me/sentrylauncher](https://t.me/sentrylauncher), plus the bots [@SentryTG_Bot](https://t.me/SentryTG_Bot) and [@SentryBuyBot](https://t.me/SentryBuyBot) | `socials/05-telegram-sentrylauncher.md` to `socials/07-telegram-sentrytgbot.md` |
| Email | team@sentry.trading | `pages/52-guide-team.md` |
| Founder | Sergio Luna, Founder and CEO of Sentry and of Mavrk, Inc., [@cruelhandeth](https://x.com/cruelhandeth), [linktr.ee/cruelhand](https://linktr.ee/cruelhand) | `pages/52-guide-team.md`, `socials/02-x-cruelhandeth.md`, `pages/70-linktree-cruelhand.md` |
| Sibling product | Quotrons, <https://www.quotrons.cash/>, also a Mavrk product | `pages/59-quotrons-root.md` |
| Chains | Robinhood Chain, id 4663, and Ink, id 57073 | `pages/10-app-network-switcher.md`, `pages/45-guide-chains-contracts.md` |
| DefiLlama | slug `sentry`, category Launchpad, no audits, no public GitHub | `socials/10-defillama-sentry.md` |
| Capture date | 2026-09-02, with a few files added 2026-09-03 | this file |

Sentry is **not** Doppler-derived.
The Doppler indexer at `indexer-prod.doppler.lol` returns `totalCount: 0` for the Sentry deployer `0xbF551eED83c7eaEE63854a2013Eb94f18600B7C5`, for the treasury splitter, for the WETH launch factory and for the SENTRY token address, against 109,757 Doppler assets on chain 4663 in the same query.
Sentry runs its own factories and its own Uniswap v4 hooks, and never touches an Airlock.

## 2. What it is

Sentry is a wallet, a DEX aggregator and a launchpad in one app, and the launchpad is the part that pays for the rest.

Launching is free apart from gas.
A launch deploys a fixed-supply ERC-20, renounces it in the same transaction, puts **100 percent of supply** into a Uniswap v4 pool as a single-sided position, hands that position to an immutable vault with no withdrawal function, and opens trading in the same transaction.
There is no bonding curve, no presale, no team allocation and no graduation threshold: the token is on a public DEX from block zero.

Sentry's revenue is a share of the trading fee on the pools it creates, settled inside each swap by the pool's own hook.
The creator's share is the larger one.

Who it is for: someone who wants a token live on Robinhood Chain immediately, with liquidity they cannot rug and do not have to fund, and who is willing to trade a permanent 1.7 percent trade fee on their token for that.
It fits this project's constraint exactly, which is having no budget to seed a pool.

The second surface is a stock-paired launch: the same mechanics, but priced against one of Robinhood Chain's tokenised equities instead of ETH, with holders earning reflections in that stock.

## 3. How a launch works, step by step

### 3.1 What the creator fills in

The Create form is behind a login.
It was captured by signing in with a wallet, and is reproduced field by field in `pages/07-app-create-form.md` with screenshots `screenshots/38-create-form.png` to `screenshots/41-create-stock-selector.png`.

| field | required | detail |
| --- | --- | --- |
| Coin Name | yes | up to 32 characters (`pages/33-guide-creating-tokens.md`) |
| Coin Symbol | yes | up to 10 characters |
| Coin Logo | yes | enforced client-side: `Token logo is required.` |
| Launch Type | yes | `STANDARD` or `STOCK BASE PAIR` |
| Base Stock Pair | stock launches only | 19 stocks and ETFs offered in the picker |
| Telegram Coin Emoji | no | 20 USD, an animated emoji for the bots |
| Dev Buy | no | in USD or ETH |
| Social links | no | website, X, Telegram |
| Creator fee recipient | no | defaults to the launching wallet |

There is no supply field, no fee field, no curve field and no liquidity field.
Supply is fixed at 1,000,000,000 with 18 decimals, and the fee schedule is a property of the hook, not of the launch.

### 3.2 What actually goes on chain

Four real production launches were decoded from Blockscout rather than reconstructed from the form (`_raw/blockscout/tx-*.json`):

| tx | date | factory | method | arguments |
| --- | --- | --- | --- | --- |
| `0xee98627a...` | 2026-08-31 | WETH `0x472286b7...` | `launchWithWhitelist` | Hood Of Meme / HOME, baseToken WETH, feeRecipient `0x0`, whitelist `[deployer]` |
| `0x95d32514...` | 2026-08-28 | WETH `0x472286b7...` | `launchWithReflections` | Baby Sentry / BSENTRY, baseToken WETH, feeRecipient `0x0`, whitelist `[deployer]` |
| `0x561a23fa...` | 2026-08-29 | stock `0xd0A93885...` | `launchWithWhitelist` | Silver Inu / SILVER INU, baseToken SLV, feeRecipient `0x0`, whitelist `[deployer]` |
| `0x863c18ba...` | 2026-07-19 | stock `0xd0A93885...` | `launchStockWithSalt` | Netflix and Chill / CHILL, baseToken NFLX, salt, whitelist of 13 wallets |

The current implementation's ABI has no `launchStockWithSalt`, so that entry point was removed in an upgrade between July and September; the pools it created still trade.
`feeRecipient` of `0x0` means "pay the launching wallet": `feeRecipientOf(token)` returns the deployer for all three recent launches (`_raw/rpc/derived-poolkeys-2026-09-02.txt`).
The whitelist always contains at least the launching wallet, which the form adds automatically.

The sequence inside one transaction, from `contracts/LaunchFactoryV4Impl-0x818fdd15.../sources/src/SentryLaunchFactoryV4.sol` and confirmed against the pool state:

1. Deploy the token from a fixed template, `SentryTokenStandard` for a plain launch or `SentryTokenizedStocks` for a stock or reflections launch, 1,000,000,000 supply, 18 decimals, no mint, no pause, no blacklist, no proxy.
2. Renounce ownership.
3. Initialise a Uniswap v4 pool on the canonical PoolManager `0x8366a39C...` with `fee = 0x800000` (the dynamic-fee flag) and `tickSpacing = 200`.
4. Write the launch whitelist into the hook before initialisation, after which it is immutable.
5. Mint the whole supply as a single-sided position and lock it in `SentryLPVault` `0x0F0E6010...`.
6. Trading is open.

The three pool keys read back live are in `contracts/ADDRESSES.md`.
Which hook a pool gets is decided by base token, not by the factory's default: `baseTokenToHook(SLV)`, `baseTokenToHook(NFLX)` and `baseTokenToHook(AAPL)` all return `0x5DaA88b6...`, while `hook()` on the same stock factory returns a different contract, `SentryDynamicFeeHook 0x3b778ccf...`, which serves nothing that is registered.
Reading the factory's `hook()` alone would give the wrong answer.

The dev buy, or an automatic 0.00001 ETH seed buy when the creator skips it, is a **separate swap** immediately after the deploy, at the same price any other buyer pays (`pages/34-guide-launch-mechanics.md`).

### 3.3 The fee curve, which is the whole anti-snipe design

Every pool opens at 40 percent and decays to a permanent floor.
These are on-chain values, read from the hooks on 2026-09-02 (`_raw/rpc/derived-state-2026-09-02.txt`), not from the docs:

| parameter | WETH launch hook | WETH reflections hook | stock hook | SENTRY's own hook |
| --- | --- | --- | --- | --- |
| `startFee` | 400000 pips, 40% | 400000 | 400000 | 400000 |
| `endFee` | 17000 pips, 1.7% | 17000 | 17000 | 20000, 2% |
| `holdDuration` | 180 s | 180 s | 180 s | 180 s |
| `halfLife` | 180 s | 180 s | 180 s | 180 s |
| `reflectionStartDelay` | 0 | 600 s | 600 s | n/a |

40 percent holds for the first three minutes, then halves every three minutes on a smooth interpolation, reaching the floor around seventeen minutes.
The clock is the only input, so it cannot be gamed with dust swaps or a pushed price.

The launch whitelist is a fee exemption, not early access.
From `contracts/SentryFeeHook-0xa695f84c.../sources/src/SentrySentryFeeHook.sol`, matching is on `tx.origin`, so it survives any router, and it is checked only when the trade direction is a buy: "Launch whitelist is BUY-only: campaign wallets get the floor rate going in, and never a discount on the way out."

### 3.4 Where each fee leg goes

The hook settles every leg inside the swap, so nothing accrues to the position and there is nothing for a creator to collect.
Shares are in basis points of the curve fee; the remainder after the named legs goes to the treasury for reflections-style hooks and to locked liquidity for the plain WETH hook.

**Plain WETH launch**, hook `0x35c00988...`:

| window | creator | locked liquidity | treasury | reflections |
| --- | --- | --- | --- | --- |
| bps of the fee | 5882 | 4118 (the remainder) | 0 | 0 |
| during the 40% window | 23.5% of the trade | 16.5% of the trade | none | none |
| at the 1.7% floor | 5882 creator, 1176 LP, 2942 treasury | | | |
| at the floor, as a share of the trade | 1.00% | 0.20% | 0.50% | none |

**WETH with reflections** (`launchWithReflections`), hook `0x730AbADb...`, **and every stock pair**, hook `0x5DaA88b6...`, are numerically identical:

| window | creator | locked liquidity | treasury | reflections |
| --- | --- | --- | --- | --- |
| early, bps | 5000 | 2500 (remainder) | 2500 | 0, reflections start at 600 s |
| early, share of a 40% trade | 20% | 10% | 10% | none |
| late, bps | 2941 | 1176 | 1177 (remainder) | 4706 |
| late, share of a 1.7% trade | 0.50% | 0.20% | 0.20% | 0.80% |

The protocol leg goes to `SentryTreasurySplitter 0x75450496...`, whose `forwardBps` is 6000: 60 percent to the treasury wallet `0xcaafcf8e...`, and the other 40 percent buys SENTRY and mints permanently locked SENTRY liquidity.
The splitter has no removal function and its `keeper()` is the zero address.

Reflections use dividend accounting on balance changes, not a transfer tax, so the token stays compatible with every router.

### 3.5 The retired generation, and why the docs disagree with themselves

93 of the 185 launches predate the v4 stack.
Those sit in Uniswap V3 at the 1 percent fee tier (`FEE_TIER() = 10000`), their LP NFTs are held by the vault through the position manager `0x73991a25...`, and the accrued fees are split on collection.
`creatorFeeBps()` returns **7000** on the legacy factory, on both v4 factories and on the LP vault, so the Robinhood creator share is 70 percent and the treasury takes 30.

DefiLlama still describes Sentry as a Uniswap V3 launchpad splitting 65/35 (`socials/10-defillama-sentry.md`).
That is two revisions out of date on both counts.

### 3.6 There is no graduation

Nothing in the launch path has a migration threshold, a bonding curve or a graduation event.
The pool created at launch is the final pool.
This is the main structural difference from every other launchpad in this archive.

## 4. Economics table

Every row is either read from a contract or quoted from a captured page, and names its source.

| item | value | source |
| --- | --- | --- |
| Launch cost | free, gas only | `pages/33-guide-creating-tokens.md` |
| Token supply | 1,000,000,000, 18 decimals, fixed | `pages/34-guide-launch-mechanics.md`, `contracts/ExampleLaunchWeth-0x9b443427.../` |
| Supply into the pool | 100% | `pages/34-guide-launch-mechanics.md` |
| Creator or team allocation | none | `pages/34-guide-launch-mechanics.md` |
| Opening trade fee | 40.0000% (`startFee` 400000 pips) | `_raw/rpc/derived-state-2026-09-02.txt` |
| Fee floor, WETH and Robinhood stock pairs | 1.7000% (`endFee` 17000 pips) | same |
| Fee floor, SENTRY's own pool | 2.0000% (`endFee` 20000 pips) | same |
| Fee floor, Ink wrapped-xStock pairs | 2.00% | `pages/46-guide-ink-xstocks-developers.md`, not verified on chain |
| Hold before decay starts | 180 s | `holdDuration()` |
| Decay half life | 180 s | `halfLife()` |
| Time to the floor | about 17 minutes | derived from the two above |
| Reflections start delay | 600 s | `reflectionStartDelay()` |
| Creator share at the floor, plain WETH launch | 1.00% of every trade (5882 bps of the fee) | `lateCreatorBps()` |
| Locked-liquidity share, plain WETH launch | 0.20% (1176 bps) | `lateLpBps()` |
| Protocol share, plain WETH launch | 0.50% (2942 bps, the remainder) | derived from the three above |
| Creator share at the floor, reflections and stock launches | 0.50% (2941 bps) | `lateCreatorBps()` |
| Holder reflections at the floor | 0.80% (4706 bps) | `lateReflectionBps()` |
| Locked liquidity, reflections and stock launches | 0.20% (1176 bps) | `lateLpBps()` |
| Protocol share, reflections and stock launches | 0.20% (1177 bps, the remainder) | derived |
| Creator share during the 40% window, plain WETH | 23.5% of the trade (5882 bps) | `earlyCreatorBps()` |
| Creator share during the 40% window, reflections and stock | 20% of the trade (5000 bps) | `earlyCreatorBps()` |
| Legacy V3 creator share, Robinhood | 70% (`creatorFeeBps` and `CREATOR_FEE_BPS` = 7000) | `_raw/rpc/derived-state-2026-09-02.txt` |
| Legacy V3 creator share, Ink | 65% | `pages/36-guide-creator-rewards.md`, not verified on chain |
| Legacy V3 pool fee tier | 1% (`FEE_TIER` 10000) | `_raw/rpc/derived-state-2026-09-02.txt` |
| Treasury splitter forward | 60% to the treasury wallet, 40% into locked SENTRY liquidity (`forwardBps` 6000) | same |
| Whitelisted buy fee during decay | the floor rate, buys only, matched on `tx.origin` | `contracts/SentryFeeHook-0xa695f84c.../sources/` |
| Whitelist size | up to 50 wallets for bundle-buy accounts | `pages/34-guide-launch-mechanics.md` |
| Pool tick spacing | 200 | `TICK_SPACING()` |
| Pool fee field | `0x800000`, the Uniswap v4 dynamic-fee flag | `_raw/rpc/derived-poolkeys-2026-09-02.txt` |
| Swap fee, in-app and guest | 1% of input, redirected in full to a referrer when a code is attached | `pages/44-guide-platform-fees.md` |
| Bridging fee | none beyond Relay's quoted rate | same |
| Spend, off-ramp | 0.25% (25 bps) | same |
| Token locker | no fee, no owner, no early withdrawal | `pages/38-guide-token-locker.md`, `contracts/TokenLocker-0xbd0e7a24.../` |
| Boosts | 25 / 50 / 125 USD for 50x / 100x / 500x, 12 h, stackable | `pages/31-guide-boosts-featured-slots.md` |
| Featured slots | 25 / 50 / 125 USD for 6 h / 12 h / 24 h, 3 slots, paid to `0x8852BC7C...` | `_raw/api/pwa-evm-featured-slots-robinhood.json` |
| Telegram coin emoji | 20 USD | `pages/30-guide-telegram-bots.md` |
| Username change | 10 USD | `pages/44-guide-platform-fees.md` |
| Referral share | 1% of the referred user's swaps, the whole platform fee | `pages/09-app-settings.md` |
| SENTRY supply split | 10% treasury (`TREASURY_CUT` 100M), 3% founder (`FOUNDER_CUT` 30M), 87% into the public pool | `_raw/rpc/derived-sentry-token-2026-09-02.txt` |
| SENTRY fee split at its 2% floor | 3750 reflections, 3750 locked liquidity, 2500 treasury bps | same |
| SENTRY early-exit fee | 80% (`earlyExitFee` 800000 pips), sells only, migration-locked wallets only | same |
| SENTRY migration unlock | 1790985600, 2026-10-03, extended from 2026-08-03 by holder vote | same |

## 5. Smart contracts

The full table, with creator, creation transaction, proxy target and source directory for each of 54 contracts, is `contracts/ADDRESSES.md`.
Everything below is Robinhood Chain, id 4663.

The launch path, in the order a launch touches it:

| role | address | verified |
| --- | --- | --- |
| Launch factory, WETH pairs (proxy) | `0x472286b7d5c1B2A3cE1132eF73d3BcCF446C5cc1` | yes |
| Launch factory, stock pairs (proxy) | `0xd0A93885a387e3a8a14dd82776CF9104a3676b3A` | yes |
| Shared implementation, `SentryLaunchFactoryV4` | `0x818FdD15Dbe95851a0bd8c5389c49ed6d4FE2bBf` | yes |
| Fee hook, plain WETH launches | `0x35c0098836FA0d10A015A95bf02C16387814f0cC` | yes |
| Fee hook, WETH with reflections | `0x730AbADbB4f328520e5350F59126fbE1D67F70cc` | yes |
| Fee hook, every registered stock pair | `0x5DaA88b65Bd47199eC92d3cDe01B56348e1270CC` | yes |
| Fee hook, factory default, serves nothing registered | `0x3b778ccFF74C2f21e771E1e951b1343108Fc7080` | yes |
| Fee hook, stock legacy V2, still serving its pools | `0x7e6E258851575bD3F69e7A01981066A26329b0cC` | no, bytecode only |
| LP vault, immutable custodian | `0x0F0E601041Ec765B8bAB8c166840E291253F2Df0` | yes |
| Treasury splitter | `0x75450496fe333A93e1327368aa3c4130BF008697` | yes |
| Uniswap v4 PoolManager | `0x8366a39CC670B4001A1121B8F6A443A643e40951` | yes |
| WETH9, the only WETH base token | `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73` | yes |

Supporting contracts: the retired V3 factory `0x9e8f6f8214b01Fd4Cf1d73FB1fb7cf9f811036Cb` with implementation `0x12a9c649...`, the V3 position manager `0x73991a25...` holding the 93 legacy positions, the token locker `0xbd0E7a24...`, four swap routers (`0x8bfDC6Cc...` V2 and V3, `0x5811a5c7...` v4, `0x641F0560...` stock multihop, `0x4415F236...` PancakeSwap V3), the SENTRY token `0x1EcA20cf...` with its bespoke hook `0xA695f84C...` and its relaunch launcher `0x0ba59E25...`, USDG `0x5fc5360d...` as the ETH-to-stock hop asset, and the ZNS `.hood` registry `0x8f95ed21...`.

Ownership and upgrade risk, all read live:

- One EOA, `0xbF551eED83c7eaEE63854a2013Eb94f18600B7C5`, is `owner()` of both v4 factories, `owner()` of the legacy factory, `owner()` of the treasury splitter and `admin()` of the LP vault, and it deployed all of them.
- Both v4 factories are `TransparentUpgradeableProxy` behind that owner, so the launch logic is upgradeable by one key. The hooks and the vault are not upgradeable.
- The vault has no withdrawal function at all: the only outward paths are `collectV3Fees` and `collectV4Fees`. Locked liquidity is genuinely locked, even against that owner.
- `setCreatorFeeBps` exists on the factories and on the vault, so the 70/30 legacy split and the recorded creator share are owner-settable going forward.
- The hooks' fee parameters are `immutable`, so an existing pool's curve cannot be changed. Changing them means deploying a new hook and pointing the factory at it, which affects future launches only.
- The SENTRY token's `treasury()` is a Safe multisig, `0xffc93474d99F07e8D0f1C7C8C5b93bAA2fEdDD07`, while the launch fee treasury is the splitter. Different contracts, different control.

Verification: 49 of the 54 archived contracts carry full verified sources from Blockscout.
The five that do not are the superseded stock hook `0x7e6E2588...`, the v4 swap router `0x5811a5c7...`, the stock multihop router `0x641F0560...`, the ZNS name registry `0x8f95ed21...` and one example launch token, Baby Sentry `0xEf3a80C8...`.
Each of those five has `bytecode.hex` in its contract directory instead, and the first four also have a runtime-code dump under `_raw/rpc/`.
Every contract in the live launch path is verified.

## 6. Backend APIs the frontend uses

Captured from a live page load in `_raw/network/network-root.json` and replayed into `_raw/api/`.
Nothing here needs a key except the Supabase anon JWT, which the app ships publicly (`_raw/api/_supabase-anon-key.txt`).

| host | endpoint | shape |
| --- | --- | --- |
| `sentry-pwa-backend-production.up.railway.app` | `GET /api/pwa/evm/live-token-stats?chain=robinhood` | `{success, data:{tokens:[{address, lastPriceWETH, swapCount, buyCount, sellCount, volumeWETH, lastTradeTimestamp}]}}` |
| same | `GET /api/pwa/evm/featured-slots?chain=robinhood` | `{success, data:{maxSlots:3, pricesUsd:{6:25,12:50,24:125}, pricesEth, ethPriceUsd, paymentAddress, active, queued, house, boosts}}` |
| same | `GET /api/pwa/evm/gold-checks?chain=robinhood` | `{success, data:{addresses:[...]}}`, the verified-badge list |
| same | `GET /api/pwa/social/prices?addresses=0x...` | `{success, data:{prices:{"0x...":0.004083}}}` |
| same | `GET /api/pwa/evm/token-lp-fees?...` | rejects non-Sentry tokens with `Invalid token: not launched through the Sentry factory` |
| same | `GET /api/pwa/account/me`, `/api/pwa/wallets` | 401 without a session |
| same | `POST /api/pwa/analytics/collect` | telemetry |
| `web-production-7d3e.up.railway.app` | `GET /api/token-deployments?limit=5` | the Telegram deployer bot's Solana launches |
| same | `GET /api/sentry-total-bought`, `/api/copy-trader-alerts`, `/api/pwa/featured-slots`, `/api/pwa/featured-carousel` | small JSON, all captured |
| `esjrycmiokijtxnbfyox.supabase.co` | `GET /rest/v1/sentry_tokens_robinhood?select=*&order=created_at.desc` | the 183-row token database, `_raw/api/supabase-sentry_tokens_robinhood.json` |
| same | `/rest/v1/sentry_tokens_ink`, `/rest/v1/token_prices`, `/rest/v1/tokens_sol`, `/rest/v1/tokens_sol_agents` | the Ink, price and Solana tables |
| `api.goldsky.com` | `POST .../subgraphs/sentry-robinhood/1.2.0/gn` | the public subgraph: `protocol`, `token`, `pool`, `swap`, `holder`, `reflection`, `routerStats`, `referrer`, day-data entities |
| same | `.../subgraphs/sentry-ink/1.5.0/gn`, `.../subgraphs/eth-usd/1.0.0/gn` | the Ink twin and a price feed |
| `api.dexscreener.com` | `GET /latest/dex/tokens/<comma-separated addresses>` | batched market data, up to a few dozen addresses per call |
| `api.relay.link` | `GET /currencies/token/price?...&referrer=sentry.trading` | the bridge quote source |
| `rpc.mainnet.chain.robinhood.com` | `POST /` | the chain read path |

The subgraph is the useful one for anyone building against Sentry: it is public, unauthenticated, and answers every ecosystem question in one query.
Example, and the source of the numbers in section 7:

```graphql
{ protocols { id tokenCount poolCount swapCount totalVolumeWETH totalFeesWETH collectedFeesWETH creatorFeesPaidWETH }
  routerStats_collection { id swapCount volumeWETH feesWETH referralPaidWETH } }
```

## 7. Ecosystem

From the Sentry Robinhood subgraph at block 52844801, 2026-09-02 (`_raw/api/goldsky-sentry-robinhood-protocol.json`, `_raw/api/goldsky-sentry-robinhood-all-tokens.json`):

| metric | value |
| --- | --- |
| Tokens launched | 185 |
| Pools created | 185, of which 92 are v4 and 93 are the legacy V3 generation |
| Stock-paired launches | 16 |
| WETH-paired launches | 169 |
| Swaps | 56,780 |
| Total volume | 12,962.40 WETH |
| LP fees generated | 54.20 WETH |
| Fees collected | 44.06 WETH |
| Paid to creators | 30.63 WETH |
| Swaps through Sentry's own routers | 7,835, of which 5,164 v4, 2,651 Uniswap, 20 PancakeSwap |
| Router volume | 298.21 WETH, earning 2.98 WETH of the 1% app fee |
| Referral payments, all time | 0.00213 WETH |
| First launch | 2026-07-02 |
| Launches in the 30 days to 2026-09-02 | 73 |
| Tokens with at least one swap | 173 of 185 |
| Tokens with more than 100 swaps | 24 |
| Median lifetime volume per token | 0.059 WETH |
| DefiLlama TVL | 100,229 USD on Robinhood Chain, 99,269 USD on Ink |

The distribution is extremely top-heavy.
The top five tokens by lifetime volume:

| token | pair | volume WETH | fees WETH | paid to creator WETH | swaps |
| --- | --- | --- | --- | --- | --- |
| CHILL, Netflix and Chill | NFLX stock | 10,697.55 | 28.81 | 20.17 | 7,896 |
| WIF, RobinWifHat | WETH | 1,279.15 | 12.79 | 4.26 | 23,234 |
| BOINK | WETH | 331.55 | 3.32 | 1.15 | 8,704 |
| ROBIN | WETH | 161.47 | 1.62 | 0.50 | 5,106 |
| LIL, Little John | WETH | 61.90 | 0.62 | 0.21 | 1,565 |

One stock-paired token, CHILL, is 83 percent of all volume on the platform, and one creator has been paid two thirds of everything creators have earned.
The median launch has done under 0.06 WETH of volume in its life, which at a 1.7 percent fee and a 1.0 percent creator leg is under 0.0006 WETH earned.

QUOTRON, the largest market shown on Sentry's own Discover list at about 12.9M USD FDV, is not a Sentry launch: it is the sibling Quotrons product's own token, listed because Sentry indexes it (`pages/03-app-token-detail-views.md`).

Relationship between Sentry, Quotrons and the cruelhand team, with evidence:

- Both sites carry the same footer, `a product of Mavrk, Inc.` (`pages/01-app-discover-tokens.md`, `pages/59-quotrons-root.md`), and Quotrons' About page names Mavrk as a Delaware corporation.
- Sergio Luna is Founder and CEO of both Sentry and Mavrk (`pages/52-guide-team.md`), posts as [@cruelhandeth](https://x.com/cruelhandeth), and his linktree lists Sentry and Mavrk side by side (`pages/70-linktree-cruelhand.md`).
- The SENTRY token's `founder()` returns `0x7171E64E979265aeD6588577D1c6b60A701d7866`, and that same EOA is the `creator_address_hash` on every Quotron contract in this archive (`contracts/ADDRESSES.md`).
- The two products are technically separate: Quotrons has its own hook, vault, router and quoter, and publishes its own ABIs (`pages/81-quotrons-integration-bundle.md`). Sentry does not launch Quotron terminals and Quotrons is not a launchpad.

The Telegram bots, from `pages/30-guide-telegram-bots.md`:

- **@SentryTG_Bot** trades, launches and broadcasts from a chat, private chats only, on the same engine, routes and fees as the app. It sells the 20 USD animated Coin Emoji that then appears on token cards.
- **@SentryBuyBot** is added to a project's group and posts an alert on every buy with amount, price, market cap, buyer and one-tap chart and Buy links, and sells paid featured slots. It runs with Telegram group privacy on, so it sees only commands, replies and mentions.
- A third, older deployer bot is visible in the backend: `GET /api/token-deployments` returns Solana launches with `deployerChatId` and `deployerUserId` fields, which is the Telegram-bot lineage the product grew out of (`_raw/api/web-token-deployments.json`).

## 8. Link inventory summary

`LINKS.md` has 1,027 rows across every captured Sentry, Quotrons and linked page, with the capture path for each.

| bucket | note |
| --- | --- |
| Sentry app routes | all captured; `pages/15-app-route-map.md` records which paths are real routes and which redirect |
| Guide anchors | all 42 top-level sections are `pages/16-` through `pages/57-`, plus the single-file version at `pages/58-` |
| Quotrons pages | 11 pages plus the machine-readable bundle at `pages/81-` |
| Linktree targets | all nine of the founder's own links captured as pages or socials |
| Socials | 4 X accounts, 5 Telegram destinations, the DefiLlama record |
| Explorer and API endpoints | mapped to `_raw/blockscout/`, `_raw/api/`, `_raw/rpc/` |
| Recorded but not fetched | two brand-kit ZIPs, one Quotrons historical-rewards JSON, two `t.co` shorteners that resolve to pages already captured |

## 9. Gaps

- **No audit and no public source repository.** DefiLlama records zero audits, and `github.com/mavrkofficial` publishes only a brand kit. The Blockscout verified sources are complete, so the code is readable, but nobody outside Mavrk has reviewed it.
- **The Ink half is documented but not verified.** Every Ink number in this archive, including the 2.00 percent wrapped-xStock floor and the 65/35 legacy split, comes from Sentry's own guide. No Ink contract was read, because this archive exists to choose a Robinhood Chain venue.
- **Account-only surfaces were not entered.** The username-and-password and X sign-up paths were not used; the wallet path was, which is what the plan's amended rule permits. Creator tools stayed closed because bundle wallets are allowlisted per account (`Creator tools are not available for this account.`), so the bundle-buy flow is documented from the guide only.
- **No launch was executed.** The deploy attempt stopped at the client-side logo requirement, so no `eth_sendTransaction` was ever produced, let alone broadcast. The four decoded production launches in section 3.2 stand in for it, and they are better evidence than a form.
- **Live ecosystem stats in the guide render empty.** The guide's own Ecosystem Stats panel shows `-` for every counter in both a headless fetch and a real browser (`pages/47-guide-ecosystem-stats.md`). The subgraph numbers in section 7 were pulled directly instead.
- **X timelines for @sentrylauncher and @cruelhandeth are not capturable.** The syndication endpoint returns `entries: []` for both, and `bdata pipelines x_posts` rejects profile URLs. Only the profile pages and one individual post were retrieved. @quotrons404 did return a full timeline.
- **The Create form's chain label is wrong.** With the network selector on Robinhood, the form's badge reads `INK` and its subtitle reads `Deploy your coin on Ink chain`, while the submit button and the target factory are correctly Robinhood. Recorded in `pages/07-app-create-form.md`.
- **Two earlier screenshots are mislabelled.** `screenshots/16-network-switcher.png` is a second copy of the Filters modal and `screenshots/13-login-modal.png` and `37-login-modal.png` are the Discover list. The real captures are `33-network-switcher.png` and `34-` through `36-`. The originals are kept rather than deleted so the numbering in the earlier session's notes still resolves.
