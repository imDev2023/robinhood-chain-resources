# Long

Archive captured 2026-09-02.
Scope: Long (long.xyz, styled `LONG()`) as a place to launch a token on Robinhood Chain (chain id 4663).
Long is a Doppler integrator, not an independent protocol.
The contract set it executes through is the Doppler set documented in `resources/launchpads/doppler/`, plus a thin launcher and two side products of its own.
This README is written as a diff against that archive: whatever Doppler already says is referenced, not repeated, and section 9 lists the places where this archive contradicts it.

---

## 1. Identity

| field | value |
| --- | --- |
| Name | Long, written `LONG()` and `L❨∞❩NG` in its own material, domain long.xyz |
| App | <https://app.long.xyz/> (`pages/01-app-home.md`) |
| Apex domain | <https://long.xyz/> serves the same app (`pages/31-long-xyz-home.md`) |
| Docs | none. `docs.long.xyz` is a deleted Vercel deployment, `www.long.xyz` an unconfigured Framer site, `join.long.xyz` does not resolve, and every unknown app path renders the landing page (`pages/30`, `pages/32`) |
| Only published document | the LongX litepaper, a five-page PDF at <https://app.long.xyz/litepaper> (`pages/57-app-litepaper-longx.md`; the PDF itself could not be downloaded past Cloudflare); it covers the leveraged-token side product, not the launchpad |
| X, platform | <https://x.com/longdotxyz>, 20.5K followers, 412 posts (`socials/01-x-longdotxyz.md`) |
| X, co-founder | <https://x.com/Natan_benish>, `Co-founder @longdotxyz / @joinlong_`, 15.1K followers; the launcher and fee-vault sources carry `@author @natan_benish` (`socials/02-x-natan-benish.md`, `contracts/LongLauncher-.../sources/src/LongLauncher.sol`) |
| X, community | <https://x.com/joinlong_>, `Home of Stock Communities.` (`socials/03-x-joinlong.md`) |
| Second co-founder | `@0xrunexu_` describes themself as `Co-founder @longdotxyz /@joinlong_` in a search snippet (`socials/05-rootdata-and-press.md`); not captured directly |
| Analytics | Dune, <https://dune.com/natan_benish2001/long-on-robinhood-chain> (`pages/33`, `socials/04-dune-natan-benish2001.md`) and <https://dune.com/natan_benish2001/ai-pairing-mode-on-long> (`pages/58`) |
| RootData | <https://www.rootdata.com/projects/detail/Long?k=MTgwMDQ%3D>, blocked by a CAPTCHA for every tool tried (`pages/52`) |
| Telegram, Discord | none found on the app, the profiles, the posts, or in search (`socials/05`) |
| Legal entity | not stated anywhere captured. Source headers say `Copyright (c) 2026 long.xyz` (`contracts/LongLauncher-.../sources/src/LongLauncher.sol:2`) |
| Chains | Robinhood Chain 4663 is the default and the only one the landing page advertises. The same app serves Long's earlier Base (8453) product under the `/base` prefix (`pages/05`, `pages/06`, `_raw/js/1d2db5e62a5a89a1.js`) |
| History | Long launched on Base on 2025-05-29 as an `ICM` launchpad, and on Robinhood Chain on 2026-07-14 (`socials/02`, `pages/51`). The first Robinhood launches were made by the team on 2026-07-12 through the first-generation launcher (`_raw/blockscout/tickerfactory-transactions.json`) |
| Identity layer | Privy, app id `cmppfotax00ql0clcbz4vvt4b` (`_raw/network/requests-01-home.json`) |
| Capture date | 2026-09-02 |

The one-line pitch, from the pinned launch post: `Pick a stock ... Launch a new token on top of it ... Trade it normally while the underlying stock token driving the market floor` (`pages/51-x-longdotxyz-launch-thread.md`).

## 2. What it is

Long is a front end and a fee policy on top of Doppler.
A Long launch is a Doppler multicurve launch in which the numeraire is a tokenized Robinhood stock (NVDA, AAPL, SPCX and about 95 others), USDG, ETH, or since August the AI token, and in which Doppler's Rehype hook is attached with parameters chosen by Long.
The app calls its own `LongLauncher` contract, which forwards the unchanged `Airlock.create` request after checking that nobody launched the same ticker in the last 24 hours (`contracts/LongLauncher-0x22e99278308b393ea1260859b181ad7e78f5eeed/sources/src/LongLauncher.sol`).
That is the entire on-chain difference between Long and using Doppler directly.

What Long adds is economic, not mechanical.
Every Long pool carries a second fee on top of the Uniswap v4 LP fee: a Rehype hook fee that starts at 80% for the first ten seconds after launch and then settles at 1.12% (0.4% on AI-paired launches), and whose proceeds are converted into the stock token and sent to Long's own address at swap time (section 4).
The creator's income is the 95% share of the ordinary LP fee, which on a standard launch today is 0.1% of volume.
The 80% opening fee is the anti-snipe mechanism, and it works without any per-wallet cap.

There is no bonding curve to graduate from.
Like every Doppler launch on this chain, a Long pool is the permanent market: the tail curve reaches the maximum tick, the migrator is `NoOpMigrator`, and the indexer shows zero Long assets migrated (`_raw/indexer/long-assets-sample1000.json`).
No fee is charged to launch and no liquidity is seeded by the creator.

Two side products sit next to the launchpad and share its contracts.
`Community mode` lets a creator hand their 95% fee slot to a vault that buys and holds the stock token and burns the creator token, under a Long-operated admin key (section 3.5).
`LongX` mints ERC-20 leveraged tokens such as NVDAx3L, backed by a perpetual position on the Lighter exchange, and is documented in the litepaper (`pages/57`) and in section 5.4; it is not part of the launch path.

Who it is for: a creator who wants a token whose liquidity is denominated in a real-world asset rather than ETH, is content with 0.095% of volume as income, and wants a permanent market with no launch fee and no threshold to clear.
It is not for a creator who wants a bonding-curve raise, a graduation event, a vesting schedule set in the UI, or a swap fee they control: the app fixes every parameter except the name, ticker, image, description, links and the anchor asset.

## 3. How a launch works, step by step

The create form itself is behind a Privy wallet login that no headless browser could reach (section 9, gap 1).
Everything below is reconstructed from three sources that agree with each other exactly: the application bundle's launch constants (`_raw/js/760859da30817643.js`), fifty consecutive production `LongLauncher.create` calls decoded from calldata (`_raw/api/decoded-launcher-recent-50.json`, generated by the script at the top of `_raw/api/decoded-launcher-recent-50.txt`), and the live pool state of ten tokens read from the chain (`_raw/rpc/hook-state-top-tokens.json`, `_raw/rpc/lpfee-slot0-top-tokens.txt`).

### 3.1 What the creator does

**Step 0, connect.** `/create` renders `Connect Wallet. Please connect your wallet to launch on Robinhood Chain.` and nothing else (`pages/03-app-create-wallet-gate.md`, `screenshots/03-create.png`).
Login is Privy; the bundle also carries Farcaster mini-app and Base App login paths from the Base era.

**Step 1, fill the form.** The off-chain metadata the app writes to IPFS lists the fields: `name`, `symbol`, `ticker`, `description`, `image_hash`, `social_links` (label plus URL pairs), `categories`, `vesting_recipients` and `fee_receiver` (`_raw/api/ipfs-bafkreig37duwng3ch64ser2p4ogqiifw35owcnk34hexigarcpfi6zbosq.json`, the metadata of a user launch made the same day).
The token page shows the same set: name, ticker, contract, `Anchored to`, description, social links, supply (`pages/09-app-token-hiai.md`).

| field | rule | source |
| --- | --- | --- |
| Ticker | 1 to 15 characters, letters A to Z only, case-folded to upper case; any other byte reverts with `InvalidTickerCharacter` | `LongLauncher.sol:_normalizeTicker` |
| Ticker uniqueness | a ticker cannot be relaunched for 24 hours after any launch of it; `isTickerAvailable(string)` and `getTickerRecord(string)` are public | `LongLauncher.sol:RESERVATION_DURATION`, `_raw/rpc/hook-state-top-tokens.txt` (BONER, AI, JOHNDOG, PEPE and DOGE were all reserved at capture time) |
| Anchor | one asset, called the numeraire on chain and `Anchored to` in the app: a Robinhood stock token, USDG, ETH, or the AI token | `pages/02-app-tokens.md`, section 7.4 |
| Image | required; served afterwards from `storage.long.xyz/tokens/<address>.<ext>` | `pages/02` |
| Supply, sale share, fees, curves, vesting | not offered; fixed by the app (next table) | bundle constants |

**Step 2, sign one transaction.** The wallet signs `LongLauncher.create(CreateParams)`, `value = 0`, about 1.8M gas (`_raw/api/decoded-launcher-recent-50.json`, field `gas`).
The client first mines a salt so that the token address ends in `1e18`, up to one million iterations (`TOKEN_REHYPE_ADDRESS_SUFFIX`, `TOKEN_REHYPE_ADDRESS_MAX_MINE_ITERATIONS` in the bundle); 956 of the 1,000 most recent Long assets carry that suffix (`_raw/indexer/long-assets-sample1000.json`).

**Step 3, done.** The token page is live at `/tokens/<address>` with a Defined chart, a `Trade on Matcha Meta DEX` hand-off, and a `Fees` panel showing the fee receiver and the claimed and unclaimed amounts (`pages/07`, `pages/08`).
There is no post-launch dashboard beyond that panel.

### 3.2 What the transaction contains

All fifty decoded launches share these values; the four exceptions are described in 3.4.

| parameter | value | where it comes from |
| --- | --- | --- |
| `initialSupply` | 1,000,000,000 | `TOKEN_REHYPE_INITIAL_SUPPLY` |
| `numTokensToSell` | 1,000,000,000, that is 100% of supply on the curve, nothing to the creator | `TOKEN_REHYPE_NUM_TOKENS_TO_SELL` |
| `tokenFactory` | `DopplerERC20V1Factory` `0x1b37d3a7...`, the only one the launcher accepts (`UnsupportedTokenFactory` otherwise) | `LongLauncher.sol:TRUSTED_TOKEN_FACTORY` |
| vesting, grants, balance cap, controller | none: `vestingSchedules = []`, `maxBalanceLimit = 0`, `controller = 0x0`. Doppler's per-wallet anti-snipe cap is switched off | decoded `tokenFactoryData` |
| `tokenURI` | `ipfs://<cid>` of the metadata JSON above | decoded `tokenFactoryData` |
| `governanceFactory`, `liquidityMigrator` | `NoOpGovernanceFactory`, `NoOpMigrator`, empty data | decoded `createParams` |
| `poolInitializer` | `DopplerHookInitializer` `0x4e346895...` | decoded `createParams` |
| `InitData.fee` | 1000, that is a 0.1% LP fee, set on a dynamic-fee pool | `ROBINHOOD_REHYPE_END_FEE`, `_raw/rpc/lpfee-slot0-top-tokens.txt` |
| `InitData.tickSpacing` | 8 | `TOKEN_MULTICURVE_TICK_SPACING` |
| `InitData.farTick` | 887256 | `REHYPE_FAR_TICK` |
| `InitData.curves` | two positions: 99.1% of supply in one range 110,440 ticks wide (a 62,500x price span), 0.9% from the top of that range to the maximum tick | decoded `poolInitializerData` |
| `InitData.beneficiaries` | creator wallet 95%, Doppler Safe `0x21e2ce70...` 5% | decoded; 45 of 50 launches name `msg.sender` as the 95% beneficiary |
| `InitData.dopplerHook` | `RehypeDopplerHookInitializer` `0x6f02324d...` | decoded, and `getState` on every live pool |
| Rehype `numeraire`, `buybackDst` | the anchor; Long's address `0x92d435c9...` | decoded `onInitializationDopplerHookCalldata` |
| Rehype `startFee`, `endFee`, `durationSeconds`, `startingTime` | 800000 (80%), 11200 (1.12%), 10, 0 | `TOKEN_REHYPE_START_FEE`, `ROBINHOOD_REHYPE_BUYBACK_FEE`, `TOKEN_REHYPE_DECAY_DURATION` |
| Rehype `feeRoutingMode` | 0, `DirectBuyback` | decoded |
| Rehype `feeDistributionInfo`, asset side | 0% asset buyback, 71.43% sold into the numeraire, 0% beneficiary, 28.57% reinvested as LP | `ROBINHOOD_REHYPE_FEE_DISTRIBUTION_INFO` (`iN` in the bundle) |
| Rehype `feeDistributionInfo`, numeraire side | 14.29% used to buy the asset, 71.43% kept as numeraire, 0% beneficiary, 14.29% reinvested as LP | same |
| `integrator` | `0x92d435c9...`, Long | decoded; `integratorAddress` in the chain config |
| `salt` | mined client-side for the `1e18` suffix | decoded |

The curve start is placed by the client from the anchor's USD price so that the launch opens at roughly a $20,000 market cap: for HIAI, anchored to RDDT at $145.82, the lower tick of `-157944` gives `1.0001^-157944 x 145.82 = $0.0000202` per token, that is a $20.2K fully diluted value (`_raw/api/decoded-launch-user-0x26617c38.json`, `_raw/blockscout/tokens-0x05b37fb5...json`).
Fresh tokens on the Base list show $20.04K to $20.09K, the same number (`pages/06-app-base-tokens.md`).

### 3.3 What happens to each swap

Read from `contracts/RehypeDopplerHookInitializer-0x6f02324d20cc679d0e585290caa6b16bacbc0f77/sources/src/dopplerHooks/RehypeDopplerHookInitializer.sol`.

1. The Uniswap v4 pool charges its LP fee (0.1%) into the concentrated positions; that fee accrues to the pool's beneficiaries through `DopplerHookInitializer` exactly as in the Doppler archive, 95% to the creator and 5% to the Doppler Safe.
2. The hook's `_onSwap` then takes the hook fee out of the swap's unspecified side, at the rate given by the decaying schedule: 80% at launch, falling linearly to 1.12% over ten seconds, then constant.
A sniper who buys in the launch block therefore pays 80% of their output to the hook.
3. 5% of the hook fee is set aside for the Airlock owner (`AIRLOCK_OWNER_FEE_BPS`) and claimable only by the Doppler Safe via `claimAirlockOwnerFees`.
4. The remaining 95% is split by `feeDistributionInfo`: on the asset side 71.43% is swapped into the stock token and transferred to `buybackDst`, 28.57% is paired with numeraire and added as full-range liquidity owned by the hook; on the numeraire side 71.43% is transferred straight to `buybackDst`, 14.29% buys the asset and sends it to `buybackDst`, 14.29% goes to the hook's full-range position.
In `DirectBuyback` mode these transfers happen inside the same swap, so nothing accrues for the creator on the hook.

`buybackDst` is Long's own address on every standard launch, so the `buyback` is a payment to Long denominated in the stock token.
The address holds about $4.48M, of which $3.89M is USDG and the rest is a spread of stock tokens, after 1.75M incoming token transfers (`_raw/blockscout/tokens-held-0x92d435c96e63c43e12d6d0ab28f6b0b04072f765.json`, `_raw/blockscout/counters-0x92d4...json`).

### 3.4 The other templates seen in production

Of the fifty most recent launcher calls (`_raw/api/decoded-launcher-recent-50.txt`):

| template | count | LP fee | hook fee after decay | distribution | `buybackDst` | who |
| --- | --- | --- | --- | --- | --- | --- |
| Standard, above | 35 | 0.1% | 1.12% | 71/29 and 14/71/14 | Long | the app |
| AI pairing mode | 11 | 0.5% | 0.4% | 100% of both sides kept as AI and sent to the destination | `0x35d217b1...`, an EOA with no code and no outgoing transaction, so a lock address for AI | the app, when the anchor is AI (`ROBINHOOD_AI_PAIR_*` constants) |
| Third-party integrator | 5 | 0.1% | 1.12% | as standard | `0x9adf17b7...`, which is also passed as `integrator` | one sender, `0x4ef489fd...`, using Long's launcher with its own integrator address; this is the unlabelled 921-asset integrator in the Doppler archive |
| Non-app caller | 4 | 1% to 3% | 1% to 3% | 100% of both sides to beneficiary, `RouteToBeneficiaryFees`, 50% start fee decaying over 15 s, 900M sold and a 100M grant to the sender | the sender `0x6495687d...` | an SDK user or bot, not the app |

The July launches used an earlier standard: LP fee 0.7% and hook fee 0.8% with 100% of both sides sent to Long (`AI`, `SPACEHOOD`, `MOO`, `CLIPPY` in `_raw/rpc/hook-state-top-tokens.json`, `_raw/api/decoded-launch-spacehood.json`).
The bundle still carries those values as the Base defaults (`TOKEN_REHYPE_END_FEE = 7000`, `TOKEN_REHYPE_BUYBACK_FEE = 8000`).
The switch to 0.1% for the creator and 1.12% for Long happened between 2026-07-17 (CLIPPY, old) and 2026-08-20 (BONER, new); no announcement of it was found.

### 3.5 After the launch: claiming, and Community mode

The creator claims LP fees exactly as in the Doppler archive, `DopplerHookInitializer.collectFees(bytes32 poolId)`, and the app's `Claimed` figure is the creator's share of `getCumulatedFees0/1`: for AI, 72.7M AI accrued at $0.2528 is $18.4M, and the page shows `Claimed $18,210,401` (`_raw/rpc/hook-state-top-tokens.txt`, `screenshots/06-token-ai.png`).
Fees accrue in both the token and the stock token.

Community mode moves that 95% slot away from the creator.
Two generations exist:

- v1, `LongCommunityFactory` (2026-07-27), deploys a splitter, an OpenZeppelin Governor and a TimelockController with a two-day minimum delay per token; used once, for AI, whose slot now belongs to the splitter `0x4f6c50a8...` and whose vault holds 943 NVDA and other stock tokens worth about $231K (`_raw/rpc/community-mode-ai-deployment.txt`, `_raw/blockscout/tokens-held-0xd14D2eEb...json`, `screenshots/06-token-ai.png`).
- v2, `LongFeeVaultFactory` (2026-08-05), the `communityFactory` the app is configured with.
The creator, who must hold more than 50% of the beneficiary shares, calls `deployVault(asset, mode)` with mode `TwentyEighty` (creator 20%, vault 40%, burn 40% of the asset side; creator 20%, vault 80% of the stock side) or `FiftyFifty` (50 / 25 / 25 and 50 / 50), then calls `DopplerHookInitializer.updateBeneficiary(poolId, vault)` themself.
The vault burns the asset share, pays the creator share, and retains the rest for a hardcoded Long ops key `0x8aa7a1df...` to push into `modules` (index-buy contracts and the like) or migrate (`contracts/LongFeeVaultFactory-.../sources/src/community/LongFeeVault.sol:21-31,55`).
26 vaults have been deployed; MOO's is activated and holds MOO's 95% slot (`_raw/blockscout/logs-LongFeeVaultFactory.json`, `_raw/rpc/lpfee-slot0-top-tokens.txt`).

The vault source is explicit that the arrangement `carries NO creator guarantees and NO governance` and that the admin EOA can retune splits and migrate at will.
A creator who enters Community mode is delegating the fee stream to Long.

## 4. Economics

Everything per launch on chain 4663, cited to a file.
Percentages of a swap are of the swap's output side, which is how both the LP fee and the hook fee are computed.

| item | value | source |
| --- | --- | --- |
| Fee to create a token | none; `create` is not payable and `value = 0` on all 50 decoded calls | `LongLauncher.sol`, `_raw/api/decoded-launcher-recent-50.txt` |
| Gas to create | about 1.8M gas | same |
| Minimum raise, graduation threshold | none; the pool is permanent | section 2, `_raw/indexer/long-assets-sample1000.json` (0 migrated) |
| Liquidity the creator must seed | none | same |
| Total supply | 1,000,000,000, fixed | bundle `TOKEN_REHYPE_INITIAL_SUPPLY` |
| Share on the curve | 100%; no creator allocation, no vesting, no grants | decoded `tokenFactoryData` |
| Opening market cap | about $20K, placed by the client from the anchor's price | section 3.2 |
| Supply layout | 99.1% across a 62,500x price range in one position, 0.9% from there to the max tick | decoded curves |
| LP fee, standard launch | 0.1% (`lpFee = 1000` on a dynamic-fee pool) | `_raw/rpc/lpfee-slot0-top-tokens.txt` |
| LP fee, AI-paired launch | 0.5% | bundle `ROBINHOOD_AI_PAIR_END_FEE`, decoded |
| LP fee, July launches | 0.7% | `_raw/rpc/lpfee-slot0-top-tokens.txt` (AI, SPACEHOOD, MOO, CLIPPY) |
| Creator's share of the LP fee | 95%, claimable with `collectFees(poolId)`; 0.095% of volume on a standard launch | decoded beneficiaries, `_raw/rpc/getshares-check.txt` |
| Doppler's share of the LP fee | 5% to the Doppler Safe | same |
| Hook fee at launch | 80% of output, decaying linearly to the end fee over 10 seconds | `RehypeDopplerHookInitializer.sol:_getCurrentFee`, decoded schedule |
| Hook fee after decay, standard | 1.12% | bundle `ROBINHOOD_REHYPE_BUYBACK_FEE`, decoded |
| Hook fee after decay, AI-paired | 0.4% | bundle `ROBINHOOD_AI_PAIR_BUYBACK_FEE` |
| Hook fee after decay, July launches | 0.8% | `_raw/rpc/hook-state-top-tokens.json` |
| Doppler's share of the hook fee | 5%, claimable only by the Airlock owner. Unclaimed at capture: 5.65M AI, 3.43M BONER, 6.29M MOO and so on, so it has never been claimed | `RehypeTypes.sol:AIRLOCK_OWNER_FEE_BPS`, `_raw/rpc/hook-state-top-tokens.txt` |
| Long's share of the hook fee, standard | 95% of the fee less the LP reinvestment: about 68% of the asset-side fee arrives as stock token, about 81% of the stock-side fee arrives as stock token or asset, all at `0x92d435c9...`; roughly 0.9% of volume | section 3.3 |
| Reinvested as hook-owned full-range liquidity | 28.57% of asset-side and 14.29% of stock-side hook fees; the hook's position on BONER holds 80,176 units of liquidity | decoded distribution, `_raw/rpc/hook-state-top-tokens.txt` |
| Total cost to a trader after the first ten seconds | 1.22% standard, 0.9% AI-paired, 1.5% July-era | sum of the two fees |
| Anti-snipe | the 80% opening hook fee. Doppler's per-wallet balance cap is off (`maxBalanceLimit = 0`) | decoded |
| Ticker reservation | 24 hours per normalized ticker, letters only, 1 to 15 characters | `LongLauncher.sol` |
| Community mode split, v2 | `TwentyEighty`: creator 20 / vault 40 / burn 40 of the asset, 20 / 80 of the stock; `FiftyFifty`: 50 / 25 / 25 and 50 / 50. Admin can retune | `LongFeeVaultFactory.sol:_splitsFor` |
| Community mode v1 timelock | 2 days minimum delay | `_raw/rpc/community-mode-ai-deployment.txt` |
| Wallet requirement | any wallet through Privy; no KYC found | `pages/03` |
| LongX mint fee | `mintFeeBps`, 0 by default, per vault config; NVDAx3L cap $550,000 shown as 100% used | `contracts/LongXVaultUpgradeable-.../sources/src/upgradeable/LongXVaultUpgradeable.sol:169-184`, `pages/04-app-longx.md` |

Two consequences for a creator planning a launch.
First, on a standard launch Long earns roughly nine times what the creator earns from the same volume, and earns it in the stock token rather than in the creator's token.
Second, the numbers the app shows as `Claimed` are LP fees only; the hook fee is invisible in the UI and only readable from `getHookFees(poolId)` on the Rehype contract.

## 5. Smart contracts

Full table with creators, creation transactions and directories: **`contracts/ADDRESSES.md`**.
24 directories, 23 verified plus the AI token clone, each with `metadata.json`, `abi.json`, `sources/` and a generated `README.md`.

### 5.1 The launch path, in call order

| step | contract | address | in the Doppler archive? |
| --- | --- | --- | --- |
| entry | LongLauncher | `0x22e99278308b393ea1260859b181ad7e78f5eeed` | no |
| forwarded to | Airlock | `0xeb7c034704ef8dcd2d32324c1545f62fb4ad0862` | yes |
| mint | DopplerERC20V1Factory -> DopplerERC20V1 clone | `0x1b37d3a7...` -> `0x3be8b97f...` | yes |
| curve | DopplerHookInitializer | `0x4e3468951d49f2eea976ed0d6e75ffcb44a9a544` | yes |
| hook | RehypeDopplerHookInitializer, non-canonical deployment | `0x6f02324d20cc679d0e585290caa6b16bacbc0f77` | yes, as `RehypeDopplerHookInitializerAlt` |
| hook's quoter | Quoter | `0x3881e5246e81e1bf731a9fc1856268d381bb9bd7` | no |
| pool | Uniswap v4 PoolManager | `0x8366a39cc670b4001a1121b8f6a443a643e40951` | yes |
| governance, migration | NoOpGovernanceFactory, NoOpMigrator | `0x85f37f74...`, `0xba2f330e...` | yes |

`LongLauncher` (verified 2026-07-14, Solidity 0.8.26, `Ownable2Step`, `Pausable`, `ReentrancyGuard`) has exactly one job: parse the symbol out of `tokenFactoryData` at the ABI offset used by `DopplerERC20V1Factory`, normalize it, revert with `TickerReserved` if a record is younger than 24 hours, forward to the Airlock, check the deployed token's `symbol()` matches, and record the reservation.
It holds no funds and takes no fee; `sweepNative` and `sweepERC20` exist for accidents.
Owner is `0x9b7f0d4d...`, an EOA with zero transactions; `paused()` is false (`_raw/api/rpc-launcher-owner.json`, `_raw/rpc/hook-state-top-tokens.txt`).
The app's chain config names it `tickerFactory` with `tickerFactoryStartBlock 8636038` (`_raw/js/1d2db5e62a5a89a1.js`).

`TickerAirlockFactory` (`0x9c88f06b...`, verified 2026-07-12) is the same source under its first name with a different owner (`0x8aa7a1df...`, the ops key); it made Long's first ten launches and has been idle since 2026-07-13.

### 5.2 What is not a module

Neither launcher is whitelisted on the Airlock, and neither needs to be: `Airlock.getModuleState` returns 0 for both because they are callers, not modules (`_raw/rpc/hook-state-top-tokens.txt`).
The Doppler archive's finding that the non-canonical Rehype contract is `not whitelisted` is correct for the module registry and irrelevant for how Long uses it: `DopplerHookInitializer.isDopplerHookEnabled(0x6f02324d...)` returns 3, the same as the canonical `0x5f9eb5f6...`, and every one of the 13,802 Long assets attaches it as `dopplerHook`.

### 5.3 Community mode contracts

| contract | address | role |
| --- | --- | --- |
| LongCommunityFactory | `0x4a477bfb623a84a4a664f779cb0a202f6124b3e7` | v1, one call deploys splitter, Governor and TimelockController; `MIN_DEPLOY_SHARES = 0.5e18`; used once |
| LongCommunityGovernorDeployer | `0xe8d46502e686ce3c6d381362c921d7e47924585a` | Governor deployer for v1 |
| AI Community Vault | `0xd14d2eeb9648f53fa153a218eeed908789c28630` | AI's TimelockController, linked from the token page |
| LongFeeVaultFactory | `0xba85d8fad36c57f4890a0f3c414ed87a50b9319a` | v2, ownerless, deployed through the deterministic-deployment proxy at salt `long.fee-vault.v1`; 26 vaults deployed |
| LongetfFactory | `0xd2ba46aeffec4bfddde62c2dd3e8c76c5c9aeedc` | verified 2026-09-01; a registry that only deploys one pinned vault bytecode and registers it against the pool's beneficiary shares. Its natspec describes a `meme surplus` paid to holders of the anchor. No launch has used it yet |
| LongLaunchHelper | `0xa97faace9a0222af631d8b25fc8c6df46d6555f4` | 2026-08-29, stateless create-plus-exact-output-buy through the launcher, native or ERC-20 numeraire; eight transactions, all from its deployer, so a test of a dev-buy feature the app does not expose yet |

### 5.4 LongX contracts

Not part of a launch; documented because the app links to them and the token pages can anchor to them (`DEMOTHREE` is anchored to `NVDAx3L`, `pages/10`).

| contract | address | role |
| --- | --- | --- |
| LongXVaultFactory | `0x69fd4a2f26e08925d9e7101c00b5a021a9cca7ce` | deploys BeaconProxy vaults |
| LongXBeacon | `0x50e11faae3c85f1ff7e38933c707ae5e0116de5f` | beacon, current implementation `0xcfb0f21f...` |
| LongXVaultUpgradeable | `0x3b2542ed...`, `0xe9d1e0d8...` | implementations; 1,936-line proof-gated vault over a Lighter L2 account: NAV derived from zk-verified account state, no price oracle, bonded key leasing for rebalancing |
| NVDAx3L | `0xf51fb54de60f6e16252e852a5ed0e60b8307606a` | the live `NVDA 3x Long` token, USDG collateral, leverage 3, $551.53K TVL at a $550,000 cap (`pages/04`) |
| NVDA 3x Long, alpha | `0xfa973da4f294085105b61c44e517e98e06d85b5a` | the 2026-08-20 standalone version |

### 5.5 Ownership and keys

| key | address | controls |
| --- | --- | --- |
| Deployer | `0x1ae51740ce21caebb8c92c457ad7fc1bdaae5305` | deployed both launchers, launched SPACEHOOD and the first ten tokens |
| Launcher owner | `0x9b7f0d4dcf6a4baed39b2f4f5aeae6ca082bed47` | `pause`, `sweep*` on LongLauncher; never used |
| Ops admin | `0x8aa7a1dfa6635af2979da4d2bdd51780842e3f99` | every LongFeeVault (`setSplits`, `pushToModule`, `adminMigrate`), TickerAirlockFactory |
| Fee sink and integrator | `0x92d435c96e63c43e12d6d0ab28f6b0b04072f765` | receives the hook fee; also what the Doppler indexer keys Long on |
| AI-pair destination | `0x35d217b10f974a49f1bfd369fc5c85b597ae09a1` | receives AI from AI-paired pools; never spends |

All are EOAs; no multisig was found anywhere in Long's set.

### 5.6 Audits

None claimed, and no audit or bug-bounty page exists for Long.
The Doppler contracts underneath carry Doppler's audits (`resources/launchpads/doppler/README.md` section 5.7).

## 6. Backend APIs

The app is a Next.js bundle behind Cloudflare with a JavaScript challenge; every automated browser and every direct `curl` to its API hosts received a 403 (`_raw/network/requests-02-tokens.json`, `_raw/api/long-graphql-noauth.json`).
What follows is therefore what the bundle declares, plus the third-party endpoints that did answer.

| host or key | what it is | source |
| --- | --- | --- |
| `https://api.long.xyz/v1` and `/v1/graphql` | `LONG_API_URL`, `GRAPHQL_URL`: the app's own backend. An API key `lxyz_4953...2213` is embedded in the bundle as `LONG_API_KEY`. Cloudflare 403 to curl with or without the key | `_raw/js/760859da30817643.js`, `_raw/api/long-graphql-apikey.json` |
| `https://notifications.mainnet.base.long.xyz` | `API_NOTIFICATIONS_URL`, from the Base era; 403 | same |
| `https://storage.long.xyz/tokens/<address>.<png,jpg,webp>` | token images | `pages/02` |
| `https://robinhood-mainnet.g.alchemy.com/v2/alch_3wol...` | `ROBINHOOD_APP_RPC_URL`, the app's own Alchemy key for chain 4663 | `_raw/js/1d2db5e62a5a89a1.js` |
| `https://auth.privy.io/api/v1/apps/cmppfotax00ql0clcbz4vvt4b` | Privy identity | `_raw/network/requests-01-home.json` |
| Codex (Defined.fi) | `CODEX_API_KEY` in the bundle; the price chart and the `View chart` link | `pages/56` |
| Matcha Meta | the `Trade` button; the app has no swap of its own | `pages/55` |
| PostHog, Sentry | analytics and error reporting | `_raw/network/requests-*.json` |

The bundle also names `trading: "relay"` for Robinhood versus `trading: "v4"` for Base, meaning in-app trades on 4663 would go through Relay rather than a direct v4 router; no trade UI was reachable to confirm it.

Two third-party endpoints answer for Long tokens without any key and are the practical way to read the platform:

- Doppler's `GET https://app.doppler.lol/api/metadata/robinhood/<token>` returns Long's own IPFS metadata, including `fee_receiver` (`_raw/api/doppler-metadata-AI.json`, `_raw/api/doppler-metadata-BONER.json`).
- Doppler's indexer `POST https://indexer-prod.doppler.lol/` filtered on `integrator: "0x92d435c96e63c43e12d6d0ab28f6b0b04072f765"` lists every Long asset with its pool id, numeraire and market cap (`_raw/indexer/`).

The metadata JSON shape, from a user launch:

```json
{"name":"Human Intel","description":"HI + AI ...","image_hash":"ipfs://bafybe...","social_links":[{"label":"Website","url":"https://x.com/..."}],"vesting_recipients":[{"address":"0x0000000000000000000000000000000000000000","amount":0}],"fee_receiver":"0x79e660623A3fFf90f8233200160EeF40a1133B12","categories":[],"symbol":"HIAI","ticker":"HIAI"}
```

## 7. Ecosystem

### 7.1 Size, from the Doppler indexer on 2026-09-02

| integrator | assets on 4663 | share |
| --- | --- | --- |
| Bankr `0xf60633d0...` | 88,764 | 81.1% |
| **Long `0x92d435c9...`** | **13,802** | **12.6%** |
| Doppler Safe (direct app launches) | 2,265 | 2.1% |
| `0x9adf17b7...` (third party using Long's launcher) | 921 | 0.8% |
| Feel `0x3879b1ee...` | 821 | 0.8% |
| all assets | 109,404 | |

Source: `_raw/indexer/counts-long-vs-all.json`, `_raw/indexer/counts-other-integrators.txt`.
Long is the second integrator by count, not the first.
It is, however, the most active one now: its 1,000 most recent assets were all created between 04:41 and 17:34 UTC on the capture day, about 77 launches an hour, and 821 of the chain's 1,000 most recent assets were Long's (`_raw/indexer/long-assets-sample1000.json`, doppler archive section 7.3).
`LongLauncher` had 13,369 transactions and `TickerAirlockFactory` 10 at capture (`_raw/blockscout/counters-LongLauncher.json`), so about 420 assets carry Long's integrator address without having passed through a Long launcher.

### 7.2 Volume and value

Long's own Dune queries (`pages/42`, `pages/33`) give, in USD, gross volume across Long pools per stock: NVDA $128.0M, SPCX $33.1M, HIMS $28.9M, MU $27.5M, AAPL $25.0M, and per token: AI $105.5M, BONER $27.0M, MOO $25.4M, SPACEHOOD $21.7M, AU $15.8M, SAYLORMOON $15.6M.
The platform account claimed on 2026-09-02 that Long had passed $425M in cumulative tokenized-stock volume and was near $12M of stock TVL, about 20% of all stock TVL on chain (`socials/01`).
The Dexscreener pairs for AI show a $250M fully diluted value and $30M of 24-hour volume on the AI/NVDA v4 pool alone, with three further AI pools on WETH and ETH created by third parties (`_raw/dexscreener/token-pairs-AI.json`).

Long is absent from DefiLlama, as Doppler is; the `_market` fee table cannot see it (doppler archive section 7.5).

### 7.3 Notable launches

| token | anchor | launched | note |
| --- | --- | --- | --- |
| AI, Artificial Inu | NVDA | 2026-07-14 | Long's flagship; $229M to $258M market cap during capture, Community mode active, numeraire of 312 of the 1,000 most recent launches (`pages/07`, `screenshots/06`) |
| BONER | HIMS | 2026-08-20 | $52.5M; creator has claimed $213,689 in LP fees (`pages/08`, `screenshots/05`) |
| MOO | MU | 2026-07-20 | $18.8M; the one activated v2 fee vault |
| SPACEHOOD | SPCX | 2026-07-14 | $13.7M; launched by Long's deployer, so a team token (`_raw/api/decoded-launch-spacehood.json`) |
| AU, SIT, CACHE, SAYLORMOON, CLANKER, CLIPPY, JOHNDOG, AGI, DOGGIE, AAPLCAT, INCEL, ASTEROID, LUCIA, GOYBEAM, SCHIFFY, CHIPS | TSM, AI, SNDK, MSTR, AI, MSFT, SGOV, AI, TSLA, AAPL, INTC, SPCX, TTWO, PLTR, GLD, AI | | the rest of the leaderboard, $0.7M to $3.7M each, one page each in `pages/11` to `pages/28` |
| NVDAx3L | USDG collateral | 2026-08-24 | LongX vault token, not a launch; $551K TVL at cap (`pages/04`) |
| DEMOTHREE | NVDAx3L | 2026-09-01 | first token anchored to a leveraged token (`pages/10`) |

### 7.4 What tokens are anchored to

In the 1,000 most recent Long launches: AI 312, NVDA 78, AAPL 35, USDG 31, SNAP 30, SPCX 25, FAMI 22, then a long tail of stock tokens; ETH is rare (`_raw/indexer/long-assets-sample1000.json`).
Across all of Long's history the Dune leaderboard counts 821 tokens anchored to NVDA, 547 to SPCX, 345 to GME, 320 to AAPL and 675 to WETH (`pages/33`).

## 8. Link inventory summary

Full table: `LINKS.md`, 414 rows.

- **All 7 URLs** the plan lists for Long are captured or accounted for: the app home and tokens list (`pages/01`, `pages/02`), the three X profiles (`socials/01` to `socials/03`), the Dune dashboard (`pages/33`), and RootData (`pages/52`, blocked).
- **Every internal route** of app.long.xyz was visited: `/`, `/tokens`, `/create`, `/longx`, `/litepaper`, 23 token pages, the `/base` variants, and nine paths that fall through to the landing page (`pages/30`).
- **All 17 Dune queries** behind the dashboard are captured (`pages/34` to `pages/50`), plus the second dashboard (`pages/58`).
- **58 pages**, **8 screenshots**, **5 socials files**, **24 contract directories**.
- External properties captured: the launch thread on X, the LongX litepaper, MEXC's explainer, the BlockBeats note, Matcha Meta, and the Defined chart host.
- Not captured: RootData (CAPTCHA), Defined.fi (Vercel checkpoint), Long's own API (Cloudflare), and the token images.

## 9. Gaps

1. **The create form was never seen.** It sits behind a Privy login on a site whose Cloudflare configuration blocks every headless browser outright, including `agent-browser` on first load (`_raw/network/read-02-tokens.txt`), so the playbook's wallet-injection method could not even reach the login.
Bright Data's unlocker renders the page but cannot hold a wallet session.
The mitigation is complete rather than partial: the bundle's constants and fifty decoded production launches give every parameter the form would have submitted, and they agree byte for byte.
What is genuinely unknown is only the form's labels and whether it exposes any option beyond name, ticker, image, description, links and anchor; the constants suggest it does not.
2. **Long's own API.** `api.long.xyz/v1/graphql` returns a Cloudflare 403 to any non-browser client, with or without the bundled API key.
Its schema is unknown; the token pages' data (fees claimed, community vault contents) can be reproduced from the chain, as sections 3.5 and 7 do.
3. **RootData** is behind a CAPTCHA for Jina, Bright Data and Tavily alike.
4. **Dune counters** (total volume, traders, tokens launched, stock TVL) are client-rendered and did not come through; the underlying queries and one rendered table did.
The second dashboard, on AI pairing mode, rendered nothing but navigation.
5. **The fee change is undated.** Standard launches moved from 0.7% LP plus 0.8% hook (July) to 0.1% LP plus 1.12% hook (by 2026-08-20).
No post or document announces it; the exact block was not searched for.
6. **Two non-app callers of the launcher are unidentified.** `0x9adf17b7...` launches through `LongLauncher` with its own integrator address and its own fee sink (five of the last fifty launches, all sent by `0x4ef489fd...`), and `0x6495687d...` uses a template the app does not produce.
The IPFS gateway timed out on their metadata, which would have named them.
7. **Whether Doppler ever claims its hook share.** `airlockOwnerFees` on the Rehype contract have accumulated on every pool read and no `AirlockOwnerFeesClaimed` event was looked for; the Doppler Safe appears never to have collected them.
8. **The Base side** (`/base`) was captured as two pages only; it is out of scope for a Robinhood Chain launch.
9. **The two EIP-7702 fee receivers.** AI's original receiver and BONER's receiver are EOAs delegated to a `CaliburEntry` contract.
Calibur is Uniswap's minimal smart-account implementation, so these are wallet-side account abstractions, not Long contracts; not investigated further.
10. **Contradictions with the Doppler archive**, none of which affect the Doppler conclusions about the substrate itself.
    All five were applied to `resources/launchpads/doppler/README.md` on 2026-09-02 and are listed at its end; they stay here as the record of what this session found:
    - Doppler README section 2 and 7.3 say roughly four in five assets on 4663 were created by Long.
      That is true of the most recent 1,000 assets only.
      Cumulatively Bankr has 88,764 assets and Long 13,802 of 109,404 (`_raw/indexer/counts-other-integrators.txt`).
    - Doppler README section 5.3 says `Fee rehypothecation cannot be used on Robinhood Chain today` and section 5.4 says the non-canonical Rehype contract is `not whitelisted`.
      Both statements are about the Airlock module registry; the archive's own later correction (rehype attached as a hook) applies, and the specific fact worth adding is that **the non-canonical `0x6f02324d...` is the one enabled and in production use on every Long pool**, with `isDopplerHookEnabled` = 3 for both deployments.
    - Doppler README section 5.6 documents fee claiming through `getBeneficiaries(asset)`.
      That view is stale after `updateBeneficiary`: for AI it still lists the original receiver at 95% while `getShares(poolId, ...)` shows the community splitter holding the slot and the original receiver at 0 (`_raw/rpc/getshares-check.txt`).
      Use `getShares`.
    - Doppler README section 7.3 lists `0x9adf17b7...` as an unidentified EOA.
      It is a third party launching through Long's launcher with its own integrator and fee-sink address; who operates it is still unknown.
    - Doppler README section 4 gives the anti-snipe mechanism as `maxBalanceLimit`.
      Long's launches show the other mechanism in production: a Rehype fee schedule opening at 80% and decaying over ten seconds.
