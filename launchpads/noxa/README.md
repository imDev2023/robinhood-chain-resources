# Noxa

## 1. Identity

Noxa is a multi-chain "degen DEX and launchpad" that deploys onto new chains at or before their public launch.
On Robinhood Chain (4663) its launchpad product is called NOXA Fun.

| field | value | source |
| --- | --- | --- |
| Live launch app | <https://fun.noxa.fi/> (also served at <https://noxa.fi/>) | `pages/12-fun-home-jina.md` |
| Live launch app, second interface | <https://noxa.io/robinhood> | `pages/50-noxa-io-robinhood-today.md` |
| Read-only ENS/IPFS interface | <https://fun.noxa.eth.limo/>, <https://fun.noxa.eth.link/> | `pages/43-ens-fun-noxa-eth-limo-today.md` |
| Docs | <https://docs.noxa.fi/> | `pages/51-docs-root.md` |
| Backend API | <https://api.noxa.fi/> | `_raw/bundle-fun-urls.txt`, `_raw/api/live-2026-09-03-*.json` |
| DEX product | <https://dex.noxa.fi/> (no longer resolves as of 2026-09-03) | `pages/64-dex-noxa-fi.md` |
| X, project | [@Noxa_Fi](https://x.com/Noxa_Fi), joined May 2024, 26.7K followers | `socials/01-x-noxa-fi-profile.md` |
| X, Robinhood account the live app links to | [@NoxaLaunchpad](https://x.com/NoxaLaunchpad), joined July 2026, 5.5K followers | `socials/05-x-noxalaunchpad-posts.md` |
| X, the separate noxa.io effort | [@NOXA_CTO](https://x.com/NOXA_CTO) "NOXA Reloaded", joined August 2025, 221 followers | `socials/06-x-noxa-cto-profile.md` |
| Telegram | <https://t.me/Noxa_Fi>, and <https://t.me/NoxaCTO> for noxa.io | `socials/07-telegram-noxa-fi.md`, `socials/08-telegram-noxacto.md` |
| Builder named in the bio | [@AmunPhantom](https://x.com/AmunPhantom) | `socials/01-x-noxa-fi-profile.md` |
| DefiLlama | slug `noxa-fun`, parent `noxa`, category Launchpad, audits 0 | `_raw/defillama-api-protocol-noxa-fun.json` |
| Chains for the launchpad | MegaETH 4326, Monad 143, Intuition 1155, Stable 988, Merlin 4200, Arc 5042, Robinhood 4663 | `pages/59-docs-contracts-noxa-fun.md` |
| Capture date | 2026-09-03 | this file |

## 2. What it is

Noxa Fun is a one-click token launcher with no bonding curve.

A launch deploys a plain ERC-20, creates a Uniswap V3 1% pool against WETH, mints one single-sided position holding the entire supply, and hands that position NFT to a locker contract that has no unlock function.
The token is tradeable on a real DEX in the same transaction that creates it, and nothing ever migrates.
Trading fees accrue to that locked position and are claimed by the creator through the locker.
"Graduation" is a display milestone in the app, not a contract event, because there is nothing to graduate to.

It is aimed at memecoin creators who want zero capital outlay.
The creator supplies no liquidity at all: the token side of the pool is the token's own supply, and the WETH side starts empty.

**The important structural fact for this archive is that Noxa is not one launchpad on this chain, it is three.**
See section 5.

## 3. How a launch works today, step by step

This describes the live path at <https://fun.noxa.fi/launch> against factory `0xDd84fDdEA1206115B37dbBC0ba5721530E1bA9C5`, which is the one the app actually calls (`_raw/bundles-fun/1cxv3667t4e_2.js`, constant block `NOXA`).

1. **Connect a wallet.** The form is gated behind "Connect your wallet to launch" (`pages/20-fun-launch.md`).
2. **Fill the form.** Image upload, name, symbol, description, website, Twitter/X, Telegram, Discord, and an optional dev buy in ETH (`pages/22-fun-launch-filled.md`).
3. **Submit one transaction** to the factory: `launchToken((string name,string symbol,string logo,string description,(string telegram,string twitter,string discord,string website,string farcaster) socials), uint256 launchConfigId, uint256 dexId, bytes32 salt)`, selector `0xd9a4add3`.
   The signature was recovered by matching the PUSH4 scan of the unverified factory (`_raw/selectors/push4-newfactory.txt`) against a decoded production call, and the keccak of that exact signature is `0xd9a4add3`.
   A fully decoded real launch is in `_raw/blockscout-tx-newfactory-latest-launch.json`, and its 20 receipt logs are in `_raw/blockscout-tx-newfactory-latest-launch-logs.json`.
4. `msg.value` is **entirely the dev buy**. There is no launch fee today: `launchConfigs(0).launchFeeWei` is 0 and the frontend constant is literally `launchFeeWei: 0n`.
   A launch with `msg.value` 0 succeeds; the newest launch at capture time (`0x272618b6766f9e51953d4b6f15dd978239d1fa83d2366a35c4adc19edba8cf76`, 2026-09-03T01:18:38Z) sent 0 wei.
5. **The factory mints 1,000,000,000 tokens to itself**, creates the WETH pool at fee tier 10000 and tick spacing 200 if it does not exist, initialises it at tick -204200, and raises the pool's observation cardinality to 300 so the locker's TWAP has history.
6. **It mints one full-range-to-initial-tick position** through the NonfungiblePositionManager holding the entire supply, then transfers that NFT to the locker and calls `lockPosition`, which emits `PositionLocked(token, deployer, positionId, pairedToken, dexId, positionManager)`.
7. **If a dev buy was sent**, the factory wraps it to WETH and swaps it through SwapRouter02 in the same transaction, so the creator gets the first fill before anyone can see the token exists.
8. **Vanity address.** The `salt` argument is mined so the token address ends in `4663`, the chain id. Every V2 launch token in this archive ends in `4663`.

### Numbers a creator gets today

| item | value | source |
| --- | --- | --- |
| Launch fee | 0 ETH | `launchConfigs(0)` field 6, frontend `launchFeeWei: 0n`, and a successful 0-wei launch |
| Fee ceiling the owner can set | 1 ETH (`MAX_LAUNCH_FEE()`) | `_raw/rpc/derived-economics-2026-09-03.txt` |
| Supply | 1,000,000,000, 18 decimals, minted once, no mint function | `launchConfigs(0)`, `contracts/LaunchTokenV2-PCC-.../sources/src/LaunchToken.sol` |
| Creator's share of supply | 0% unless bought with the dev buy | decoded launch logs |
| Quote asset | WETH only | `dexConfigs(0)` |
| DEX and fee tier | Uniswap V3 on this chain, 1% (`fee = 10000`), tick spacing 200 | `dexConfigs(0)`, `PoolCreated` log |
| Opening price | tick -204200, about 1.3557 WETH fully diluted, roughly $3,253 | `launchConfigs(0)`, `_raw/rpc/derived-economics-2026-09-03.txt` |
| Graduation threshold | 20 WETH fully diluted market cap, about $48,000 | derived exactly over 12 tokens, `_raw/rpc/derived-economics-2026-09-03.txt` |
| What graduation does | nothing on chain, the position never moves | `pages/53-docs-launchpad-overview.md`, and no migrate path exists in `LaunchLocker.sol` |
| Liquidity lock | permanent, the locker has no unlock, withdraw or transfer-out function | `contracts/LaunchLockerV2-.../abi.json` |
| Trading fee split today | 100% creator, 0% protocol (`protocolFeeShare()` returns 0) | `_raw/rpc/derived-economics-2026-09-03.txt` |
| Trading fee split the UI claims | "1% swap fees split 50/50 platform/creator" | `pages/23-fun-launch-jina.md` |
| Anti-snipe today | none in practice: `maxWalletBps` 10000, `maxTxBps` 10000, `restrictionSeconds` 1 | `launchConfigs(0)`, and `restrictionSeconds()` on a live token |
| Anti-snipe the UI claims | "blocks everyone else on the launch block, then limits buy size for 1h after launch" | `pages/23-fun-launch-jina.md` |
| Vesting | none | no vesting contract exists in the set |
| KYC | none | no gate beyond a wallet |

### Claiming fees

The creator calls `collectFees(address token)` on the locker, or `collectFees(token, minWethOut)`, or `collectFeesWethOnly(token)`.
Only the token's `deployer`, the locker's `owner`, or an address the owner has whitelisted in `feeCollectors` may call it.
The locker collects both sides of the V3 position, swaps the token side to WETH through SwapRouter02 with a minimum-out derived from a 1800-second pool TWAP (never spot), unwraps everything to ETH, takes `protocolFeeShare` percent for the treasury and sends the rest to the creator.
If the token side cannot clear the TWAP floor the swap is skipped and retained for a later claim rather than reverting, so the WETH side is never frozen.
A creator can permanently redirect their own payouts with `setFeeRedirect(token, recipient)`.

## 4. Economics table

| item | value | where it is set | source file |
| --- | --- | --- | --- |
| Launch fee, live V2 | 0 ETH | `launchConfigs(0).launchFeeWei`, owner-settable up to 1 ETH | `_raw/rpc/derived-economics-2026-09-03.txt` |
| Launch fee, V2 before 2026-08-29 18:58 UTC | 0.0005 ETH | same field | `_raw/blockscout-tx-newfactory-admin-0x89e00a3a-b.json` |
| Launch fee, V1 | 0.0005 ETH, now unreachable | `launchFee()` | `_raw/rpc-eth-calls.txt` |
| Launch fee, noxa.io | 0.0005 ETH | `launchFee()` | `_raw/rpc/derived-economics-2026-09-03.txt` |
| Pool fee, all three | 1% (`10000`) | `dexConfigs` / `getDexConfig` | `_raw/rpc-eth-calls.txt` |
| Protocol share of trading fees, V2 today | 0% | `LaunchLockerV2.protocolFeeShare()` | `_raw/rpc/derived-economics-2026-09-03.txt` |
| Protocol share of trading fees, V2 at deploy | 50% | constructor argument | `contracts/LaunchLockerV2-.../README.md` |
| Protocol share of trading fees, V2 for 88 minutes on 2026-08-29 | 70% | `setProtocolFeeShare(70)` then `setProtocolFeeShare(0)` | `_raw/blockscout-newowner-txs.json` |
| Creator's share of V1 trading fees today | 100% of the WETH side, and the token side is burned to `0x...dEaD` | `LaunchLockerV1.protocolFeeShare()` is 100, which routes everything to the FeeCollector, whose `protocolShare()` and `tokenTreasuryShare()` both read 0 | `_raw/rpc/v1-fee-flow-2026-09-03.txt` |
| Protocol share, V1 second deployment | 65% at construction; that deployment holds a single position | constructor argument | `contracts/LaunchLockerV1Test-.../README.md` |
| Fee split, noxa.io | protocol 33.33%, creator/CTO 33.34%, burner 33.33% | `FeeRouter.setFeeConfig` | `_raw/rpc/derived-economics-2026-09-03.txt` |
| noxa.io protocol split | 70/30 between two addresses, epoch-based release | `FeeSplitter` constructor | `contracts/NoxaIO-FeeSplitter-.../README.md` |
| Supply | 1e27 base units, 1B tokens | `launchConfigs(0).supply` | same |
| Opening FDV | about 1.3557 WETH | initial tick -204200 | `_raw/rpc/derived-economics-2026-09-03.txt` |
| Graduation | 20 WETH FDV | api.noxa.fi, exact over 12 samples | `_raw/rpc/derived-economics-2026-09-03.txt` |
| Fee-conversion TWAP window | 1800 s, hard floor 60 s | `LaunchLockerV2.twapWindow` | source natspec |
| Fee-conversion slippage tolerance | 2000 bps, bounded to 100 to 2000 | `LaunchLockerV2.maxSlippageBps` | source natspec |
| CTO reassignment timelock | 86400 s | `REASSIGN_DELAY` | source |
| Protocol fees, 24h / 7d / 30d / all time | $153,498 / $1,087,140 / $4,222,958 / $21,053,955 | DefiLlama `noxa-fun` | `_raw/defillama-api-fees-noxa-fun.json` |
| TVL, Robinhood Chain | $5,626,229 (WETH side of locked LPs) | DefiLlama | `_raw/defillama-api-protocol-noxa-fun.json` |

Note on the DefiLlama fee series: its chart begins 2025-11-24, before Robinhood Chain existed, so the totals cover the `noxa-fun` adapter across every chain Noxa deploys on and must not be read as Robinhood-only.

## 5. Smart contracts

Full table with creators and creation transactions: `contracts/ADDRESSES.md`.
Twenty-three contract directories with sources, ABIs and generated READMEs are under `contracts/`.

### Three deployments, not one

This is the finding that matters most.

**V1, `0xD9eC2db5f3D1b236843925949fe5bd8a3836FCcB`, disabled.**
Deployed 2026-06-16 by `dev.noxa.eth`, two weeks before Robinhood Chain's public launch, and it produced 60,142 tokens including CASHCAT.
On 2026-07-11 at 10:44:42 UTC `dev.noxa.eth` called `setLaunchEnabled(false)` (`0xdf03d9cd279a3fceb940ef1665c4367d0cf6e64a2bfc9738e44e20de3ddc90c8`).
`launchEnabled()` still returns false, and every one of the 50 most recent `launchToken` calls to it, spanning 2026-07-13 to 2026-08-28, reverted (`_raw/blockscout-factory-txs.json`).
This factory is genuinely dead and the disable is enforced, not merely announced.

**V2, `0xDd84fDdEA1206115B37dbBC0ba5721530E1bA9C5`, live.**
Deployed 2026-07-22 at 11:37 UTC, eight days after the "launches stay permanently disabled" announcement, by a different key `0x63CD726Ccc6560F571861BbAb925f9AF4a6095B2` with no ENS.
`launchingEnabled()` returns true, `allTokensLength()` returns 1090, and the newest launch was 2026-09-03T01:18:38Z, the report date.
It is unverified, but the whole admin and launch surface was recovered from bytecode: `launchToken` `0xd9a4add3`, `setLaunchConfig(uint256,(uint256,uint16,uint16,uint32,int24,uint256,uint16,bool))` `0x89e00a3a`, `setLaunchingEnabled(bool)` `0x799fe343`, `launchingEnabled()` `0x1584ccf3`, `allTokensLength()` `0xdbb80e42`, `MAX_LAUNCH_FEE()` `0x28ff1d4c`.
Both `0x89e00a3a` and `0xd9a4add3` were confirmed by hashing the reconstructed signature, not guessed.
Its locker `0x9A6931E371b62048C7543C7002C99D83685BD44d` is verified and is the single best document in the archive: its natspec explains the TWAP anti-sandwich floor, the retained-token path, and the CTO timelock.

**noxa.io, `0xA24D48D50Fd7985c6dE816EaF77C1A17D3593BBE`, also live.**
A fourth-party stack of four fully verified contracts deployed by `0x407Fe47FA03617062E9cD27DCACe8DAB006322d8` and used by <https://noxa.io/robinhood>, which brands itself NOXA Fun and whose Telegram and X are the "NOXA Reloaded" CTO accounts.
It treats the V1 locker and V1 fee splitter as `legacyLockerAddress` and `legacyFeeRouterAddress` in its own frontend config (`_raw/bundles-noxaio/index-DT5rkcAb.js`).
`launchEnabled()` is true, `launchFee()` is 0.0005 ETH, and it has produced 171 tokens, the most recent on 2026-08-31.
Its FeeRouter pays the creator only 33.34% of collected fees and sends the rest to a protocol splitter and a burner address.
This is a materially worse deal for a creator than the fun.noxa.fi path, under the same brand.

The two live stacks share nothing but the Uniswap contracts and the Noxa name.
A creator who searches for "Noxa" and lands on the wrong domain gets a different fee split and a different owner.

### Key contract behaviour

`LaunchToken` (verified, `contracts/LaunchTokenV2-PCC-.../sources/src/LaunchToken.sol`) is an OpenZeppelin ERC-20 with immutable anti-snipe parameters, a `_update` override that only meters buys out of the pool, and no owner, no mint, no blacklist and no tax.
Its natspec contains a chain-specific fact worth carrying forward: on Robinhood Chain `block.number` returns the L1 block number at roughly 12-second cadence, so the contract deliberately uses `block.timestamp` for every time check, and the comment states that the earlier `== launchBlock` version blocked all buys for a full L1 block and was flagged by honeypot scanners.

`LaunchLocker` V2 (verified) holds the position and pays fees.
There is no function that can move, burn, unwind or transfer the position NFT, so the liquidity lock is real and unconditional.
The owner can, however, do three things that touch creator money:
`setProtocolFeeShare` changes the split globally and retroactively for every token, and the source says so explicitly ("intentional, NOT snapshotted per launch");
`setProtocolFeeRecipient` moves where the protocol cut goes;
and `proposeCreatorReassign` plus `executeCreatorReassign` can, after a 24-hour timelock, redirect any creator's fee stream to an address of the owner's choosing.
`setMaxSlippageBps` and `setTwapWindow` are bounded so no owner setting can price fee conversion off manipulable spot.

`FeeCollector` `0x9eFdC1A8e6E94f16A228e44f3025E1f346EE0417` is the V1 fee sink, unverified, with `protocolShare()` and `tokenTreasuryShare()` both reading 0 and `treasury()` pointing at `treasury.noxa.eth`.
Its PUSH4 scan names `collect(address)`, `collectFees(address)`, `feeRouting(address)`, `setOverride`, `sweep` and a `DEAD()` constant (`_raw/selectors/push4-feecollector.txt`).
Tracing a real collection settles what V1 fee claiming actually pays out today.
In `0x91479f6f1b0bed82e68ccbbc426d2beac6f7877323d96863731a1ec261a4a295` the token's own deployer called `collect(VIBECAT)`; the locker sent 100% of both sides to the FeeCollector because `protocolFeeShare()` is 100; the FeeCollector then burned the entire launched-token side to `0x000...dEaD` and paid the entire WETH side, 0.0629 ETH, to the deployer.
So V1's `protocolFeeShare() = 100` does not mean the protocol takes everything, it means everything is routed through the collector, which keeps nothing.
The 2026-07-14 promise of 100% of trading fees to creators is real and is still being honoured, and V1 claiming is busy: 49 successful `collect` calls in the nine hours to 2026-09-02T03:22Z (`_raw/rpc/v1-fee-flow-2026-09-03.txt`).

Everything downstream is stock Uniswap V3: factory `0x1f7d7550B1b028f7571E69A784071F0205FD2EfA`, NonfungiblePositionManager `0x73991a25C818Bf1f1128dEAaB1492D45638DE0D3`, SwapRouter02 `0xCaf681a66D020601342297493863E78C959E5cb2`, WETH `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`.

### Not Doppler

Noxa is not a Doppler integrator.
The Doppler indexer at `https://indexer-prod.doppler.lol/` returns `totalCount` 110392 for chain 4663 overall and 0 for every Noxa factory, locker, deployer and fee address as both `integrator` and `poolInitializer`, and 0 for CASHCAT and PCC as `address` (`_raw/indexer/doppler-check-2026-09-03.txt`).
It is a self-contained Uniswap V3 stack with no Airlock, no hook and no v4 pool.

### Docs versus chain

`docs.noxa.fi/contracts/noxa-fun/` still lists the disabled V1 factory `0xD9eC2db...` as the Robinhood Launch Factory, confirmed still wrong on 2026-09-03 (`pages/63-docs-contracts-noxa-fun-today.md`).
The same page lists `0x7F03effbd7ceB22A3f80Dd468f67eF27826acD85`, which is Robinhood's V1 **locker**, as Monad's Launch **Factory**, so the table has at least one copy-paste error on top of being stale.
The app itself is right and the docs are wrong; read the frontend chunk constants or the chain, never the docs, for a Noxa address.

## 6. Backend APIs

Host `https://api.noxa.fi`, a Fastify service, no key, no CORS obstacle, no Cloudflare interstitial.
All captures are under `_raw/api/`.

| endpoint | shape |
| --- | --- |
| `GET /api/health` | `{"ok":true}` |
| `GET /api/stats` | `{"ethUsd":2399.2156,"ts":1788402691}` |
| `GET /api/tokens?sort=<trending\|live\|new\|gainers\|marketcap\|volume\|holders\|trades\|oldest>&q=&page=1&limit=200` | `{"items":[{token,name,symbol,logo,deployer,priceWeth,marketCapWeth,volume24hWeth,priceUsd,marketCapUsd,volume24hUsd,trades24h,holderCount,createdTs,source,changePct5m,graduated,graduatedAt,graduationPct}]}` |
| `GET /api/tokens/<addr>` | the same object plus `description`, `socials{telegram,twitter,discord,website,farcaster}`, `pool`, `supply`, `positionId`, `poolFee`, `ethUsd` |
| `GET /api/tokens/<addr>/trades?limit=60` | `{"trades":[{ts,txHash,trader,side,tokenAmount,wethAmount,priceWeth,priceUsd}]}` |
| `GET /api/tokens/<addr>/holders?limit=50` | `{"holders":[{holder,balance,pct}],"total":11169}` |
| `GET /api/tokens/<addr>/candles?interval=5m` | `{"candles":[{t,o,h,l,c,v}]}` |
| `GET /api/tokens/<addr>/comments?page=1` | `{"items":[]}` |

`source` is `"noxa"` for a V2 launch and `"legacy"` for an imported V1 one.
`/api/config`, `/api/chains`, `/api/docs` and `/openapi.json` all 404 (`_raw/api/probe-*.txt`).
The full index returned 1121 tokens, 1083 `noxa` and 38 `legacy`, of which 52 are `graduated` (`_raw/api/api-tokens-ALL-merged.json`), so the app deliberately shows only a curated slice of the 60,142 V1 launches.

The frontend also names a chain config: RPC `https://rpc.mainnet.chain.robinhood.com`, explorer `https://rh-scan.com`, QuoterV2 `0x33e885eD0Ec9bF04EcfB19341582aADCb4c8A9E7`.

## 7. Ecosystem

Exact launch counts, from the number of Uniswap V3 position NFTs each locker holds, which is exact because every launch mints exactly one and no locker can release one:

| deployment | launches |
| --- | --- |
| V1 locker `0x7F03ef...` | 60,142 |
| V1 second locker `0xeC4a56...` | 1 |
| V2 locker `0x9A6931...` (live) | 1,090 |
| noxa.io locker `0x90331A...` (live) | 171 |
| **total on Robinhood Chain** | **61,404** |

The noxa.io front page's own "Tokens 60313 Total launched" counter equals 60,142 plus 171 exactly, so it counts V1 and its own launches and ignores the 1,090 on the live fun.noxa.fi factory.
`LaunchFactoryV2.allTokensLength()` independently returns 1090.

Notable launches, all V1 unless marked:
CASHCAT `0x020bfC650A365f8BB26819deAAbF3E21291018b4`, the chain's flagship memecoin, about $276M market cap and $10M 24h volume at capture;
TENDIES `0x45242320dbb855eea8fd36804c6487e10e97fcf9`, about $30.7M;
JUGGERNAUT `0xd7321801caae694090694ff55a9323139f043b88`, about $6.6M;
Robinhood Wallet `0x0339f5459fc690ac85f1782e15782a151b4a9e1b`, about $8.2M;
PCC `0xBF3e53713a53E9C3d5d1dDc25dd2C65669244663` (V2), about $6.2M, launched 2026-08-24 and graduated 784 seconds later.

There is a token called NOXA on the chain, `0x39E0D9057BD9039Cd14590f54dE20B9D3457c56E`, launched through the V1 factory on 2026-06-17.
The team publicly disowns it: "there is no official Noxa token on Robinhood ... anything trading under the noxa name right now was not launched by us" (`socials/05-x-noxalaunchpad-posts.md`).

Current activity on the live V2 app, from its own Stats page: $11.25M volume over 7 days, 54.73K trades, 4.52K active traders, 10 coins launched in the last 7 days, average trade $205.56 (`pages/29-fun-stats.md`).
That is a very different platform from the one that did $2.33M of fees in a single day on 2026-07-11 (`../_market/pages/17-odaily-noxa.md`).

## 8. Link inventory summary

`LINKS.md` holds 1,664 rows over 1,071 distinct URLs, extracted from all 72 `pages/` files and 9 `socials/` files.
368 rows point at a target that has its own file in this archive.
Breakdown: 425 external, 344 internal Noxa domains, 251 docs.noxa.fi, 235 IPFS asset URLs for token logos, 220 social, 130 data providers, 54 explorer, 3 repo, 2 chain.
The `external` bucket is dominated by DefiLlama site chrome on `pages/72-defillama-noxa-fun.md`.

## 9. Gaps

- **The V2 factory is unverified.** Its ABI was reconstructed from a PUSH4 scan plus one decoded production call plus keccak confirmation of two signatures. That is enough to state the launch parameters, the fee, the config setter and the enable flag with confidence, but the internal accounting, the whitelist behaviour and any pause path other than `setLaunchingEnabled` are inferred, not read.
- **The V1 factory and the V1 fee collector are also unverified.** Their bytecode is archived; only the selector-level surface is known.
- **Whether the V2 stack is the original team.** The V2 owner `0x63CD726Ccc...` has no ENS under `noxa.eth`, was funded 14 minutes before deployment by an unidentified high-throughput wallet, and never received anything from `dev.noxa.eth` or `treasury.noxa.eth`. The circumstantial case that it is the same operator is strong (it controls `noxa.fi`, the docs, and the `@NoxaLaunchpad` account the app links to; `dev.noxa.eth` was still collecting V1 fees on 2026-08-28), but there is no on-chain link. Treat "same team" as unproven.
- **The identity behind noxa.io.** Deployer `0x407Fe47FA03617062E9cD27DCACe8DAB006322d8`, 221 X followers, 249 Telegram members. Whether it is a genuine community takeover, a licensed deployment, or a lookalike is not established here.
- **The graduation formula is derived, not documented.** 20 WETH FDV fits twelve samples exactly, but it is a backend number and could be changed server-side without any chain event.
- **No wallet-gated capture of the create flow.** The launch form was read but never submitted; the shared test wallet was not used and no transaction was signed. Everything about the launch call comes from decoding real production transactions instead, which per the playbook is the better evidence anyway.
- **X timeline coverage is thin.** The syndication endpoint for `@Noxa_Fi` returns nothing newer than late 2025, and returns zero entries for `@NoxaLaunchpad` and `@NOXA_CTO`. The Bright Data profile scrape filled the gap for `@NoxaLaunchpad` (16 posts) but the full Robinhood-era `@Noxa_Fi` timeline is not archived.
- **noxacto.xyz returned HTTP 503** on 2026-09-03. The six pages captured on 2026-09-02 are preserved but the site could not be re-verified, and its relationship to noxa.io is not established.
- **dex.noxa.fi no longer resolves**, so the DEX half of the product could not be re-checked.
- **Two inherited screenshots were byte-identical duplicates and have been re-captured.** `09-fun-launch-filled.png` was the same file as `08-fun-launch.png`, and `12-fun-bridge-from.png` was the same as `11-fun-bridge-anywallet.png`, both from the earlier session. Both were re-shot against the live site during the wave 2 merge on 2026-09-03: `09` now shows the launch form filled with placeholder values and a 0.05 ETH dev buy, including the live preview panel reporting `Launch fee Free`, and `12` now shows the source-chain picker open over its 24 supported chains. The launch page was also re-shot fresh as `14-fun-launch-2026-09-03.png` and the noxa.io launch page as `15-noxaio-launch-2026-09-03.png`. No two screenshots in this directory are byte-identical.
- **`0x08241c8F618a932dAd58d9ef3098300A7CAFAF2f`** was deployed by the V2 owner and is unverified, unreferenced by any Noxa contract or frontend, and unidentified.

---

## Is a new launch possible on Noxa today? Yes.

The section 5.11 brief expected this README to state that new launches are not possible.
That was true of the platform described in the July reporting, and it is not true of the platform on chain on 2026-09-03.

The evidence, in order of strength:

1. `LaunchFactoryV2.launchingEnabled()` returns `true` at the head of the chain.
2. A stranger's launch transaction succeeded at 2026-09-03T01:18:38Z, hours before this capture, creating token `0x9852d8ACd4Ace9ef27Aed43b57b741ACFd894663` with `msg.value` 0 and `status: ok`.
3. That factory's locker holds 1,090 position NFTs, and its `allTokensLength()` agrees.
4. `https://fun.noxa.fi/launch` serves a working create form today, and `https://noxa.io/robinhood/launch` serves a second one over a second live factory.
5. The launch fee is 0 and the fee split is 100% to the creator, both readable on chain, both confirmed by a 2026-08-29 post that describes them as a temporary promotion.

### What remains usable on the V1 platform

Everything except launching.

- **Trading** every one of the 60,142 V1 tokens continues on Uniswap V3 with no involvement from Noxa; the pools are ordinary 1% pools.
- **Fee claiming works and is used.** A V1 creator calls `collect(token)` on the FeeCollector `0x9eFdC1A8e6E94f16A228e44f3025E1f346EE0417` and receives 100% of the WETH side, with the token side burned. 49 such calls succeeded in the nine hours to 2026-09-02T03:22Z.
- **The ENS/IPFS interface** at `fun.noxa.eth.limo` is still served and still does exactly what it promised: browse launched tokens, see what you launched or receive fees for, and claim. Its bundle references the V1 locker and the V1 FeeCollector and knows nothing about V2.
- **The liquidity is not recoverable by anyone**, including Noxa. The V1 locker has no unlock path, so every V1 launch's LP is permanently locked whatever happens to the team.

What is genuinely disabled is the **V1 factory**, and only that.
The 2026-07-14 announcement was accurate about V1 and about the ENS interface, which really is read-only and really does only browse and claim.
Eight days later the operator shipped a new factory and resumed launching under the same brand, and the announcement was never retracted.
Anyone relying on the "permanently disabled" statement is reading a claim that the chain contradicts.

The fee terms carry an obvious caveat: `protocolFeeShare` is a single owner-settable global that is applied at collection time, not snapshotted at launch.
It has already been 50, then 70, then 0 within one day.
A creator launching today on a "100% of fees" promise is trusting a value the owner can change to 100% in one transaction, retroactively, for every token ever launched.
