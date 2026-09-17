# Bags

Archive of the Bags launchpad as deployed on Robinhood Chain (chain id 4663), captured 2026-09-02.
Bags is a creator-fee launchpad that started on Solana and now runs a second, fully on-chain stack on Robinhood Chain: a virtual constant-product bonding curve per token, a fixed 2% fee on the ETH leg of every trade split half to the creator and half to the platform, and graduation into a permanently locked Uniswap v4 pool once 5 ETH has been raised.
Every number below cites the file it came from.
Raw tool output is under `_raw/`, verbatim page captures under `pages/`, contract sources under `contracts/`.

Bags is not Doppler-derived.
The Doppler indexer returns zero assets for the Bags factory, vault, hook, deployer and v1 factory as `integrator`, `poolInitializer` or `liquidityMigrator` (`_raw/api/doppler-indexer-check-2026-09-02.json`).
The stack is Bags' own contracts on top of the canonical Uniswap v4 PoolManager and periphery.

## 1. Identity

| item | value | source |
| --- | --- | --- |
| Name | Bags (BAGS), operated by Bags Holdings, Inc. | `pages/113-app-about.md`, `pages/115-app-terms.md` line 34 |
| App | <https://bags.fm/> with a Solana or Robinhood network selector | `pages/104-app-home.md`, `screenshots/119-app-home-network-selector.png` |
| Docs | <https://docs.bags.fm/> (Mintlify, 103 pages in the sitemap, all captured) | `_raw/tavily/docs-urls-from-sitemap.txt`, `_raw/tavily/pages-index-docs.tsv` |
| Robinhood Chain docs | <https://docs.bags.fm/robinhood/overview> and eight sibling pages | `pages/001-docs-robinhood-claim-fees.md` to `pages/009-docs-robinhood-trade-tokens.md` |
| Support | <https://support.bags.fm/> (Intercom help centre, 18 FAQ articles, Solana oriented) | `pages/118-support-home.md` to `pages/137-support-how-to-launch-a-token.md` |
| Developer portal | <https://dev.bags.fm> (API keys, login wall, not captured) | `pages/003-docs-robinhood-index-tokens.md` |
| Public API | `https://public-api-v2.bags.fm/api/v1/`, header `x-api-key` | `pages/069-docs-api-reference-introduction.md` lines 16 to 30 |
| X | [@BagsApp](https://x.com/BagsApp), 153.9K followers, 10.2K posts, joined October 2022 | `socials/01-x-bagsapp.md` |
| Discord | <https://discord.gg/bagsapp> (invite page needs JavaScript, no member count captured) | `socials/02-discord-bagsapp.md` |
| Telegram | [@bags_dev](https://t.me/bags_dev), developer contact linked from the docs | `socials/03-telegram-bags_dev.md` |
| LinkedIn | [company/bagsfm](https://www.linkedin.com/company/bagsfm), Financial Services, 2 to 10 employees, 596 followers | `socials/04-linkedin-bagsfm.md` |
| GitHub | [bagsfm](https://github.com/bagsfm), 8 public repos; `bags-sdk` (23 stars), `bags-cli`, `bags-idl`, `bags-skill`, `play` cloned | `socials/05-github-bagsfm.md`, `_raw/github/org-repos.json`, `_raw/github/` |
| Mobile apps | iOS "BAGS: Trade Coins" id6473196333, Android `com.bags.bagsfm` | `socials/06-appstore-bags.md`, `socials/07-googleplay-bags.md` |
| Chains | Solana (Meteora DBC then DAMM v2) and Robinhood Chain 4663 (own contracts on Uniswap v4); the docs mention BNB Chain only to say it is a separate chain | `pages/005-docs-robinhood-overview.md` line 17, `pages/132-support-liquidity.md` |
| Team handles | none captured; LinkedIn hides employees without login and no page names the team | Gaps |
| Deployer and owner key | `0xDEf671F11C8a30818eb3D9Cc9476EEEc805f9058` (EOA) owns the factory, vault and both beacons and is `platformAdmin` on every curve | `contracts/ADDRESSES.md`, `_raw/rpc/factory-state-2026-09-02.json` |
| Capture date | 2026-09-02, chain state read at block 52761706 | `_raw/rpc/factory-state-2026-09-02.json` |

## 2. What it is

Bags is a "launch a coin and earn royalties from every trade" product aimed at creators, streamers and small teams rather than at protocol engineers (`pages/104-app-home.md`, `pages/113-app-about.md`).
The Solana product is API driven and dominates the company's numbers: 183,031 coins launched, $4.66B lifetime volume and $46.57M in creator earnings are shown on the home page and returned by `data-api.bags.fm` (`pages/104-app-home.md`, `_raw/api/api-data-stats.json`).
The Robinhood Chain product is different in kind: a set of permissionless contracts that anyone can call with viem or ethers, with no API key needed to launch, trade or claim (`pages/005-docs-robinhood-overview.md`).

The mechanism on Robinhood Chain is a per-token virtual constant-product bonding curve quoted in native ETH.
Every token has a fixed supply of 1,000,000,000 with 18 decimals, minted once to its curve (`contracts/BagsTokenImpl-0x74E9A91f676fC314da8816E965Ee098AED275409/sources/src/BagsToken.sol` lines 26 to 28 and 78 to 85).
830,000,000 tokens are sold on the curve; when the curve holds 5 ETH of real reserves it migrates the remaining 170,000,000 tokens plus the 5 ETH into a full-range Uniswap v4 pool guarded by the Bags hook, at the exact final curve price, and the liquidity can never be removed (`contracts/BagsBondingCurveImpl-0x419890a21711c3D3Af46B58548376420B9723275/sources/src/BagsBondingCurve.sol` lines 111 to 113 and 146, `_migrate`; `contracts/BagsV4Hook-0x2380aBf72C17aABAb76480244759AC7E2932EEcC/sources/src/BagsV4Hook.sol` lines 244 to 272).
A flat 2% fee on the ETH side of every trade, before and after graduation, is split 50/50 between the creator's claimers and the platform, with an optional partner paid out of the platform half (`pages/005-docs-robinhood-overview.md` "Fee model", `BagsBondingCurve.sol` `_splitFee`, `BagsV4Hook.sol` lines 141 to 184).

Who it is for: creators who want ongoing fee income without seeding liquidity, apps that want to be the `partner` on launches they originate and earn 0.25% of volume for the token's lifetime (`pages/006-docs-robinhood-partner-program.md`), and "index token" creators whose fees are automatically turned into stock-token dividends for holders (`pages/003-docs-robinhood-index-tokens.md`).
It is not a raise: the 5 ETH graduation threshold is the pool's liquidity, not money the creator receives, and the creator gets no token allocation unless they buy in the launch transaction (`pages/004-docs-robinhood-launch-token.md` section 1).

## 3. How a launch works, step by step

### 3.1 Through the app

The wizard at <https://bags.fm/launch> has four steps: Coin details, Mode, Fee sharing, Launch (`pages/105-app-launch-step1-coin-details.md`, `screenshots/106-app-launch-step1-coin-details.png`).

1. Coin details: name, ticker, image upload, optional social links, and a chain selector "Solana" or "Robinhood" (`pages/105-app-launch-step1-coin-details.md`, `screenshots/107-app-launch-step1-robinhood-selected.png`).
2. Mode, with Robinhood selected: "Normal" ("Earn 1% of total trading volume") or "Stock dividends" ("Use fees to buy stocks and pay dividends to holders"), the latter opening a picker of up to 10 tokenized stocks (GME, TSLA, PLTR, NVDA, AAPL, AMZN, META, GOOGL and others) (`pages/106-app-launch-step2-mode-robinhood.md`, `pages/107-app-launch-step2-stock-dividends.md`, `screenshots/108-app-launch-step2-mode.png`, `screenshots/109-app-launch-step2-stock-dividends.png`).
3. Fee sharing: "Add claimers to share fees with social accounts or EVM wallets. Anything you don't share stays with you.", a "Total: 100.00%" meter, and a "Dev buy" field ("Buy your coin before anyone else."); the claimer editor itself is wallet gated ("Loading your wallet...") (`pages/108-app-launch-step3-fee-sharing.md`, `screenshots/110-app-launch-step3-fee-sharing.png`).
4. Launch: the button reads "Login to launch"; a preview shows the ticker, "Robinhood Chain" and "Fee distribution: You 100%" (`pages/109-app-launch-step4-login-to-launch.md`, `screenshots/111-app-launch-step4-launch.png`).

Login is Privy (app id `cm7m1jjj900ks13jd6kmrv20s` in `_raw/network/network-home.json`).
The archive did not log in and nothing was submitted, so the fee-claimer editor and the transaction confirmation were not captured (Gaps).
Everything past that point was reconstructed from the contracts and from real production transactions, which is more precise.

### 3.2 What the transaction does

The app and every SDK call end in one of two factory functions on the UUPS proxy `0xe8Cc4431adF8b5A847C113EF0c6af9043219Cb37` (`pages/004-docs-robinhood-launch-token.md` section 1, `contracts/BagsFactoryImpl-0x7dfa0131F6c8626F199A2E33E49DfB5660e6Ef1C/sources/src/BagsFactory.sol` lines 280 and 318):

```solidity
create(string name, string symbol, string metadataURI, address partner, address[] claimers, uint16[] bps) payable
createAndBuy(string name, string symbol, string metadataURI, address partner, address[] claimers, uint16[] bps) payable
```

Required fields and rules (`pages/004-docs-robinhood-launch-token.md` section 2, `BagsFactory.sol` lines 56 and 438):

- `metadataURI` is a JSON document, IPFS in every observed launch (`_raw/blockscout/tx-0x346f5da71b41f20b4be1926b0dd66c22441714d7a8d2a6addc243b277a5ca8e2.json`).
- 1 to 100 claimers, unique, non-zero, not equal to `partner`, with `bps` summing to exactly 10000.
- `partner` is `address(0)` for none; its rate is not a launch parameter but the factory global `partnerFeeBps`, snapshotted into the curve and the hook at launch.
- `msg.value` must be at least `creationFee`; with `createAndBuy` the whole surplus is spent on an atomic `buyFor(msg.sender, 1)` (`BagsFactory.sol` lines 288 to 298 and 326 to 340).

One transaction deploys three contracts and registers them: an EIP-1167 clone of `BagsToken`, a `BeaconProxy` for `BagsFeeShare` and a `BeaconProxy` for `BagsBondingCurve`, then mints the 1B supply to the curve, approves Permit2 and the PositionManager, registers the future pool with the hook, and emits `TokenCreated(token, curve, creator, feeShare, partner, poolId, name, symbol, metadataURI)` (`BagsFactory.sol` lines 450 to 467, `_raw/blockscout/tx-0x346f5da71b41f20b4be1926b0dd66c22441714d7a8d2a6addc243b277a5ca8e2-logs.json`).
Per-token addresses are not predictable and must be read from that event, from `factory.curveForToken` / `feeShareForToken`, or from `BagsLens.getTokenState` (`pages/005-docs-robinhood-overview.md` "Per-token contracts").
The fee share's ownership is handed to the platform key `0xDEf6...9058` inside the launch transaction, and the curve grants that key `ADMIN_ROLE` (`tx-0x346f...-logs.json` events `OwnershipTransferred` and `RoleGranted`).

### 3.3 Fees, minimums and supply split

- Creation fee: the factory default is 0.02 ETH (`BagsFactory.sol` line 58) but the owner set it to 0 in block 8375410 on 2026-07-13 04:20:53 UTC, 13.5 hours after deployment, and it has been 0 since (`_raw/rpc/admin-events-2026-09-02.json` `CreationFeeUpdated`, `_raw/rpc/factory-state-2026-09-02.json` `factory.creationFee`).
The docs still say 0.02 ETH (`pages/004-docs-robinhood-launch-token.md` "Prerequisites").
- Minimum spend: none beyond gas; the POINTLESS launch was a plain `create` with `value = 0` (`_raw/blockscout/tx-0xd76087d5ee1e740fc13ce56abcd7e6a65e82ec2e7cc2fd95ec0aa50f17465ccc.json`).
The BARRY launch cost 1,731,956 gas, 0.000638 ETH at the time (`_raw/blockscout/tx-0x346f5da71b41f20b4be1926b0dd66c22441714d7a8d2a6addc243b277a5ca8e2.json`).
- Supply split: 1,000,000,000 fixed; 830,000,000 sold on the curve; 170,000,000 reserved for the pool; nothing to the creator, the platform or a vesting contract (`BagsBondingCurve.sol` lines 111 to 113 and 146, `BagsToken.sol` line 28).
- Trading fee: `TX_FEE_BPS = 200` on the curve and `CUSTOM_LP_FEE = 200` in the hook, both on the ETH or WETH leg only (`BagsBondingCurve.sol` line 137, `BagsV4Hook.sol` line 42).
On buys the fee is taken from the input, on sells from the output (`pages/005-docs-robinhood-overview.md` "Fee model").
- Fee split: `protocolHalf = fee / 2`, `creatorFee = fee - protocolHalf`, `partnerCut = protocolHalf * partnerFeeBps / 10000`, `vaultFee = protocolHalf - partnerCut`; the vault receives native ETH, the creator and partner amounts are wrapped to WETH and pushed into the token's `BagsFeeShare` (`BagsBondingCurve.sol` `_splitFee`, `BagsV4Hook.sol` lines 150 to 184).
- Creator rewards: 1% of all ETH volume for the life of the token, in both phases, split among claimers by bps, pull-payment through `BagsFeeShare.claim(unwrap)` (`pages/001-docs-robinhood-claim-fees.md`).
Post-graduation fees sit in the hook until anyone calls `hook.sweep(poolId)`; `claim` triggers the sweep (`pages/001-docs-robinhood-claim-fees.md` section 1 note).
- Partner: 25% of the protocol half, so 0.25% of volume, on launches that name a partner; immutable per token; paid through the same fee share (`pages/006-docs-robinhood-partner-program.md`, `BagsFactory.sol` line 60).
- Vesting: none anywhere in the launch path.
- Anti-snipe: only the atomic `createAndBuy`, which the docs describe as "no front-run window" (`pages/004-docs-robinhood-launch-token.md` section 1); the app calls it "Dev buy" (`pages/108-app-launch-step3-fee-sharing.md`).
There is no whitelist, no per-wallet cap, no delay and no LP fee.

### 3.4 Curve shape and graduation

The curve is `x * y = k` on virtual reserves.
The virtual token reserve starts at 1,043,787,878.79 tokens, a chain-independent constant, and the virtual quote reserve starts at `threshold * 17 / 66`, which is 1.2879 ETH for the live 5 ETH threshold (`BagsBondingCurve.sol` lines 111 and 271, `_raw/rpc/derived-economics-2026-09-02.txt`).
Those two numbers are chosen so that exactly 830M tokens are sold when real reserves hit the threshold, which the contract asserts at initialisation (`BagsBondingCurve.sol` lines 220 to 222 and 276).

Derived from those constants (`_raw/rpc/derived-economics-2026-09-02.txt`):

| point | price (ETH per token) | FDV (ETH) |
| --- | --- | --- |
| launch | 1.2339e-9 | 1.234 |
| graduation | 2.9412e-8 | 29.41 |

The price rises 23.8x over the curve.
Filling the curve costs buyers 5.102 ETH gross, of which 0.102 ETH is fees (0.051 ETH to the creator's claimers, 0.051 ETH to the vault) and 5.0 ETH lands in the pool.

Graduation is triggered by the buy that reaches `thresholdQuote`, or by anyone calling `migrate()` afterwards (`BagsBondingCurve.sol` lines 354 to 360 and 560).
A buy that would overshoot is capped at the threshold and the excess is refunded in the same call (`BagsBondingCurve.sol` lines 426 and 537 to 540).
`_migrate` then initialises a Uniswap v4 pool with `fee = DYNAMIC_FEE_FLAG`, `tickSpacing = 60` and the Bags hook, at `sqrtPriceX96` computed from the final virtual reserves so the price is continuous, mints one full-range position (ticks -887220 to 887220) with 170M tokens and 5 ETH, sends the position NFT to `platformAdmin`, pauses the curve forever and transfers curve ownership to `0xdEaD` (`BagsBondingCurve.sol` `_migrate`, `_raw/blockscout/tx-0xe76bd4babbd04f30160e521e208bd639ad94c117646d27b266e214a82542104e-logs.json`).
The pool value at graduation is 10 ETH, 34% of the 29.41 ETH FDV.

Destination DEX and fee tier: Uniswap v4 on the canonical PoolManager `0x8366...0951`, one pool per token against WETH `0x0Bd7...AD73`, LP fee forced to 0 by the hook on every swap, hook fee 2% of the WETH leg (`BagsV4Hook.sol` lines 275 to 306).
The hook rejects any `tickSpacing` other than 60, any position that is not full range, any second mint, and every `removeLiquidity`, so the liquidity is locked by code rather than by a timelock (`BagsV4Hook.sol` lines 219 to 272).
Post-graduation swaps go through a Robinhood-modified UniversalRouter `0x8876...0904` whose v4 swap struct has an extra `uint256 minHopPriceX36` field, so stock Uniswap SDK calldata reverts; two other router look-alikes exist on the chain (`pages/009-docs-robinhood-trade-tokens.md` line 200, `pages/005-docs-robinhood-overview.md`).

### 3.5 Three decoded production launches

| token | tx | function | value sent | claimers and bps | what happened |
| --- | --- | --- | --- | --- | --- |
| BARRY, Barry Marquet | `0x346f5da7...5ca8e2`, block 52388070, 2026-09-02 07:14:11 UTC | `createAndBuy` | 0.041232 ETH | `0xC7E1...b48A` 1 bps (the creator), `0xD6C5...69e8` 9999 bps | fee 0.000825 ETH split 0.000412 to vault and 0.000412 to fee share; 31,752,486 BARRY (3.18% of supply) bought for 0.040407 ETH net |
| RHOBOT | `0xd3e50706...551a2`, block 52266832, 2026-09-02 03:50:32 UTC | `createAndBuy` | 0.001242 ETH | `0x6828...055a` 10000 bps (the Bags index bot wallet) | an index token in the sense of `pages/003-docs-robinhood-index-tokens.md`; 15% bonded at capture |
| POINTLESS | `0xd76087d5...5ccc`, block 52260288, 2026-09-02 03:39:33 UTC | `create` | 0 ETH | creator 10000 bps | zero-cost launch, 0% bonded at capture |

Sources: the `tx-<hash>.json` and `tx-<hash>-logs.json` files under `_raw/blockscout/` for each hash above, `_raw/rpc/factory-state-2026-09-02.json` "examples" and per-curve reads.
The BARRY split is the app's "fees directed to him to support his art" pattern: the creator keeps 0.01% and routes 99.99% to the artist, which the token page renders as "JulianBurford 100.0%" (`pages/111-app-token-barry.md`).

BARRY graduated 2.8 hours after launch, in block 52488616 at 2026-09-02 10:03:10 UTC (`_raw/rpc/derived-economics-2026-09-02.txt`, `_raw/api/api-evm-rh-pulse-2026-09-02b.json`).
The graduating buy is instructive (`_raw/blockscout/tx-0xe76bd4babbd04f30160e521e208bd639ad94c117646d27b266e214a82542104e-logs.json`): a trader sent 0.075 ETH through a third-party aggregator `0x6505...40Dc`, which kept 0.00075 ETH of its own fee and forwarded 0.07425 ETH to the curve; the curve used 0.04846 ETH net plus 0.000989 ETH of Bags fee, refunded the remaining 0.0248 ETH, then initialised pool `0x08cf5337...d8b4` at `sqrtPriceX96 = 461975604337661047389914602706935` (34,000,000 BARRY per ETH), minted position NFT 1496541 to `0xDEf6...9058` with 4.999999999999998351 WETH and 169,999,999.99 BARRY, paused itself and emitted `Migrated`.

Two v1 launches were also decoded for comparison: FEATHER (`_raw/blockscout/tx-0x0386307bcec42cd244357923332b38239536882a4f2a734f815c3df4de851ef5.json`, `createAndBuy` with 0.01 ETH) and HEADSTART (`_raw/blockscout/tx-0x5cd0b8f647061c8f74e7fb11b7a4c9eb9b5e4b0105c6529cea30c090ee7921ac.json`, `create` with 0 ETH), both on the v1 factory `0x46aD...4D40` on 2026-07-13.
The v1 signature carries an extra `uint16 partnerBps` argument and that partner share was "applied to creator fees", so in v1 the partner was paid by the creator, while in v2 the partner is carved out of the protocol half (`contracts/BagsFactoryImplOld-0x46aD6f53A3C26C8027826e2104cF0595b7b24D40/sources/src/BagsFactory.sol` lines 192 to 204, `BagsFactory.sol` v2 line 60 and `pages/006-docs-robinhood-partner-program.md`).

### 3.6 Index tokens (the "Stock dividends" mode)

An index token is a normal v2 launch whose only claimer is the Bags claimer wallet `0x6828E679Fb51b6d0416035370aF6Ec0fb2f2055a` at 10000 bps, then registered through `POST /evm/rh/index-token/init` with a basket of 1 to 10 tokenized stock addresses (`pages/003-docs-robinhood-index-tokens.md` sections 2 and 3).
A Bags bot scans about once a minute, claims once at least 0.001 ETH is claimable, splits the ETH evenly across the basket, buys each asset and multisends it to holders pro rata by a snapshot, excluding contracts; the docs state "no skim" (`pages/003-docs-robinhood-index-tokens.md` section 1).
The trade-off is that the creator gives up the entire creator half; the platform half is unchanged.
Registration returns 403 unless the API key's user owns the creator wallet and the claimer is configured (`pages/003-docs-robinhood-index-tokens.md` section 3).

## 4. Economics

| item | value | where it is set | source |
| --- | --- | --- | --- |
| Trading fee, curve phase | 2% of ETH in (buys) or ETH out (sells) | `TX_FEE_BPS = 200` | `BagsBondingCurve.sol` line 137, `_raw/rpc/factory-state-2026-09-02.json` `TX_FEE_BPS` = 0xc8 |
| Trading fee, pool phase | 2% of the WETH leg per swap, LP fee overridden to 0 | `CUSTOM_LP_FEE = 200`, `OVERRIDE_FEE_FLAG` | `BagsV4Hook.sol` lines 42 and 275 to 306 |
| Creator share | 50% of the fee = 1% of volume, split by claimer bps | `creatorFee = fee - fee/2` | `BagsBondingCurve.sol` `_splitFee`, `BagsV4Hook.sol` line 152 |
| Protocol share | 50% of the fee = 1% of volume, to BagsVault as native ETH | `vaultFee = protocolHalf - partnerCut` | same |
| Partner share | 25% of the protocol half = 0.25% of volume, only if a partner is set | `partnerFeeBps = 2500`, snapshotted per launch, max 10000 | `_raw/rpc/factory-state-2026-09-02.json` `factory.partnerFeeBps` = 0x9c4, `BagsFactory.sol` lines 60 to 62 |
| Creation fee, live | 0 ETH since block 8375410 (2026-07-13 04:20:53 UTC) | `factory.creationFee` | `_raw/rpc/admin-events-2026-09-02.json`, `_raw/rpc/factory-state-2026-09-02.json` |
| Creation fee, code default and docs | 0.02 ETH | `DEFAULT_CREATION_FEE` | `BagsFactory.sol` line 58, `pages/005-docs-robinhood-overview.md` |
| Graduation threshold | 5 ETH of net reserves, snapshotted per curve as `thresholdQuote` | `factory.graduationThreshold`, bounds 0.01 to 1000 ETH | `_raw/rpc/factory-state-2026-09-02.json` = 0x4563918244f40000, `BagsFactory.sol` lines 67 to 69 |
| Total supply | 1,000,000,000 tokens, 18 decimals | `INITIAL_SUPPLY` | `BagsToken.sol` line 28 |
| Curve allocation | 830,000,000 (83%) | `CURVE_TOKEN_ALLOCATION` | `BagsBondingCurve.sol` line 113 |
| Pool allocation | 170,000,000 (17%) plus the 5 ETH raise | `LP_TOKEN_AMOUNT` | `BagsBondingCurve.sol` line 146 |
| Creator or team allocation | 0 | | `BagsFactory.sol` `_deployPair` lines 426 to 467, `tx-0x346f...-logs.json` |
| Initial virtual reserves | 1,043,787,878.79 tokens and 1.2879 ETH | constant and `threshold * 17 / 66` | `BagsBondingCurve.sol` lines 111 and 271, `_raw/rpc/derived-economics-2026-09-02.txt` |
| Launch price and FDV | 1.2339e-9 ETH per token, 1.234 ETH FDV | derived | `_raw/rpc/derived-economics-2026-09-02.txt`, POINTLESS `currentPrice` = 0x498b12ba wei in `_raw/rpc/factory-state-2026-09-02.json` |
| Graduation price and FDV | 2.9412e-8 ETH per token, 29.41 ETH FDV, 34,000,000 tokens per ETH | derived, confirmed by BARRY `Migrated.sqrtPriceX96` | `_raw/rpc/derived-economics-2026-09-02.txt`, `tx-0xe76b...-logs.json` |
| Gross ETH to fill a curve | 5.102 ETH, of which 0.102 ETH fees | derived | `_raw/rpc/derived-economics-2026-09-02.txt` |
| Pool value at graduation | 10 ETH (5 ETH + 170M tokens at 2.9412e-8), 34% of FDV | derived | `_raw/rpc/derived-economics-2026-09-02.txt` |
| Pool parameters | dynamic fee flag 8388608, tickSpacing 60, full range -887220 to 887220, hook `0x2380...EEcC` | constants | `BagsBondingCurve.sol` lines 149 to 153, `tx-0xe76b...-logs.json` `Initialize` |
| LP lock | permanent; hook reverts every `removeLiquidity`; position NFT held by `0xDEf6...9058` | `_beforeRemoveLiquidity` | `BagsV4Hook.sol` lines 266 to 272, NFT id 1496541 in `tx-0xe76b...-logs.json` |
| Claimers | 1 to 100, bps sum 10000, updatable forward-only by the fee share owner (the platform key) | `MAX_CLAIMERS`, `setClaimers` | `BagsFactory.sol` line 56, `BagsFeeShare.sol` lines 58 and 236 to 266 |
| Index token bot threshold | claims once at least 0.001 ETH is claimable; basket 1 to 10 assets; no skim | off-chain | `pages/003-docs-robinhood-index-tokens.md` section 1 |
| Migration deadline | `block.timestamp + 1 hour` on the PositionManager call | `MIGRATION_DEADLINE_SECONDS` | `BagsBondingCurve.sol` line 83 |
| Vault balance at capture | 28.171 ETH at block 52761706 (27.701 ETH on Blockscout a few hours earlier) | | `_raw/rpc/factory-state-2026-09-02.json` `vault.balance`, `_raw/blockscout/address-0x4861446aa7fFd9e67a83cBbAcb1A4B70540B83Aa.json` |
| Bags fees on Robinhood Chain per DefiLlama | $22,155 (24h), $66,882 (7d), $203,850 (30d), $585,729 all time | | `_raw/api/defillama-fees-robinhood-chain-2026-09-02.json` protocol "Bags" |
| Solana side, for scale | 85 SOL DBC threshold, about 0.2 SOL to launch | | `pages/132-support-liquidity.md`, `pages/129-support-sol-needed-to-launch.md` |

Control points a launcher should know about, all held by the single EOA `0xDEf671F11C8a30818eb3D9Cc9476EEEc805f9058` (`_raw/rpc/factory-state-2026-09-02.json`):

- It owns the factory UUPS proxy and can change `creationFee`, `graduationThreshold`, `partnerFeeBps`, `hook` and `tokenImpl` for future launches, and upgrade the factory (`BagsFactory.sol` lines 195 to 241).
- It owns both beacons, so it can upgrade every live bonding curve and every live fee share in one transaction (`BagsFactory.sol` lines 34 to 49, `contracts/BagsBondingCurveBeacon-0x8DCEcaf516C828A493C2C449c1E25F92cF80207E/`).
- It is `platformAdmin` on every curve, which can pause and unpause trading and receives the LP NFT (`BagsBondingCurve.sol` lines 160 to 161 and 290 to 299).
- It owns every per-token `BagsFeeShare` and can call `setClaimers`, limited to not removing a claimer with an unpaid balance (`BagsFeeShare.sol` lines 236 to 266).
- It owns the vault and can withdraw ETH and tokens from it (`contracts/BagsVaultImpl-0xeC66D9fc56E92408518De9b8a8697245E932e688/sources/src/BagsVault.sol` lines 53 to 71).

No `Upgraded` event has been emitted on the factory proxy or either beacon since deployment, so the deployed implementations are the originals (`_raw/rpc/admin-events-2026-09-02.json`, `_raw/blockscout/address-0x8DCEcaf516C828A493C2C449c1E25F92cF80207E-logs.json`, `_raw/blockscout/address-0xdFf07d39C5332C602e06FA64f0A97C92fd8537e0-logs.json`).

## 5. Smart contracts

The full table with creator, creation tx, proxy and implementation for every address is `contracts/ADDRESSES.md`.
Every address has a directory `contracts/<Role>-<address>/` with `metadata.json`, `abi.json`, verified `sources/` (or `bytecode.hex` where Blockscout has no match) and a generated `README.md`.
28 directories, 26 with verified sources.

### 5.1 The live v2 stack

| contract | address | notes | dir |
| --- | --- | --- | --- |
| BagsFactory proxy | `0xe8Cc4431adF8b5A847C113EF0c6af9043219Cb37` | ERC1967 UUPS proxy, deployed block 7887315 on 2026-07-12 14:45:56 UTC; EIP-1967 implementation slot = `0x7dfa...Ef1C` | `contracts/BagsFactoryProxy-0xe8Cc4431adF8b5A847C113EF0c6af9043219Cb37/` |
| BagsFactory implementation | `0x7dfa0131F6c8626F199A2E33E49DfB5660e6Ef1C` | Solidity 0.8.26, cancun, optimizer 200 runs | `contracts/BagsFactoryImpl-0x7dfa0131F6c8626F199A2E33E49DfB5660e6Ef1C/` |
| BagsLens | `0xC82Db941dAf90B754aecb5F7D14c683dc608d595` | `getTokenState`, `getTokenStates`, `claimableOf` | `contracts/BagsLens-0xC82Db941dAf90B754aecb5F7D14c683dc608d595/` |
| BagsV4Hook | `0x2380aBf72C17aABAb76480244759AC7E2932EEcC` | CREATE2 singleton via `0x4e59...956C`, `factory.hook()` | `contracts/BagsV4Hook-0x2380aBf72C17aABAb76480244759AC7E2932EEcC/` |
| BagsVault proxy | `0x4861446aa7fFd9e67a83cBbAcb1A4B70540B83Aa` | UUPS proxy; implementation slot = `0xeC66...e688` | `contracts/BagsVaultProxy-0x4861446aa7fFd9e67a83cBbAcb1A4B70540B83Aa/` |
| BagsVault implementation | `0xeC66D9fc56E92408518De9b8a8697245E932e688` | `withdraw`, `withdrawToken`, owner only | `contracts/BagsVaultImpl-0xeC66D9fc56E92408518De9b8a8697245E932e688/` |
| BagsBondingCurve beacon | `0x8DCEcaf516C828A493C2C449c1E25F92cF80207E` | `implementation()` = `0x4198...3275` | `contracts/BagsBondingCurveBeacon-0x8DCEcaf516C828A493C2C449c1E25F92cF80207E/` |
| BagsBondingCurve implementation | `0x419890a21711c3D3Af46B58548376420B9723275` | the curve logic every per-token proxy runs | `contracts/BagsBondingCurveImpl-0x419890a21711c3D3Af46B58548376420B9723275/` |
| BagsFeeShare beacon | `0xdFf07d39C5332C602e06FA64f0A97C92fd8537e0` | `implementation()` = `0xD169...8a1A` | `contracts/BagsFeeShareBeacon-0xdFf07d39C5332C602e06FA64f0A97C92fd8537e0/` |
| BagsFeeShare implementation | `0xD169EBd0aa9E42F2410f92740D00cD2228d98a1A` | pull-payment ledger in WETH | `contracts/BagsFeeShareImpl-0xD169EBd0aa9E42F2410f92740D00cD2228d98a1A/` |
| BagsToken implementation | `0x74E9A91f676fC314da8816E965Ee098AED275409` | `factory.tokenImpl()`, cloned per launch; ERC20Permit | `contracts/BagsTokenImpl-0x74E9A91f676fC314da8816E965Ee098AED275409/` |
| UniversalRouter (stock Uniswap, not a fork) | `0x8876789976dEcBfCbBbe364623C63652db8C0904` | post-graduation swaps | `contracts/UniversalRouter-0x8876789976dEcBfCbBbe364623C63652db8C0904/` |
| V4Quoter | `0x8Dc178eFB8111BB0973Dd9d722ebeFF267c98F94` | quotes include the 2% hook fee | `contracts/V4Quoter-0x8Dc178eFB8111BB0973Dd9d722ebeFF267c98F94/` |
| StateView | `0xF3334192D15450CdD385c8B70e03f9A6bD9E673b` | `getSlot0`, `getLiquidity` | `contracts/StateView-0xF3334192D15450CdD385c8B70e03f9A6bD9E673b/` |
| PoolManager | `0x8366a39CC670B4001A1121B8F6A443A643e40951` | Uniswap v4 singleton | `contracts/PoolManager-0x8366a39CC670B4001A1121B8F6A443A643e40951/` |
| PositionManager | `0x58daec3116aae6D93017bAAea7749052E8a04fA7` | mints the migration LP NFT | `contracts/PositionManager-0x58daec3116aae6D93017bAAea7749052E8a04fA7/` |
| Permit2 | `0x000000000022D473030F116dDEE9F6B43aC78BA3` | router spending route | `contracts/Permit2-0x000000000022D473030F116dDEE9F6B43aC78BA3/` |
| WETH (aeWETH proxy) | `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73` | transparent proxy, impl `0xC6B8...947e` | `contracts/WETHProxy-0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73/` |
| Multicall3 | `0xcA11bde05977b3631167028862bE2a173976CA11` | | `contracts/Multicall3-0xcA11bde05977b3631167028862bE2a173976CA11/` |

All nine addresses in the docs address book match what the factory proxy returns for `hook`, `vault`, `weth`, `permit2`, `poolManager`, `positionManager`, `tokenImpl`, `bondingCurveBeacon` and `feeShareBeacon` (`_raw/api/rpc-factory-config.json`, `_raw/rpc/factory-state-2026-09-02.json`, `pages/002-docs-robinhood-contracts.md`).
The docs' "protocol deploy block 7887312" is three blocks before the proxy's own creation block 7887315 (`pages/005-docs-robinhood-overview.md`, `_raw/blockscout/tx-0x224d5dbccbab85a6be5a40ee696272f4db2527f651eb3ee814864254c28c6c9a.json`).

**Correction, 2026-09-03: the Bags docs are wrong about the router.**
Their address book calls `0x8876789976dEcBfCbBbe364623C63652db8C0904` a "Robinhood-modified fork" (`pages/002-docs-robinhood-contracts.md`, captured verbatim and left as-is).
It is a stock Uniswap UniversalRouter.
Two UniversalRouter deployments are live on chain 4663 and their verified sources hash identically (109 files, same compiler settings); the only difference in 24,546 bytes of runtime code is 111 bytes of immutables, none of them logic.
`0x8876...0904` is the one Uniswap's own SDK constants, docs tables and live Trading API all name for this chain, and it carries 99.7 percent of router traffic.
The other, `0x06AfBA43Fd06227fA663b0DAecF536f6EaA6bf99`, differs only in having a real Across SpokePool wired where `0x8876...0904` has a revert stub, which is reachable only from the cross-chain deposit path and cannot affect a swap.
Evidence: `resources/uniswap/DEPLOYMENTS.md`, section "Universal Router on Robinhood Chain: resolved 2026-09-03".

### 5.2 The undocumented v1 stack

A first, non-upgradeable factory `0x46aD6f53A3C26C8027826e2104cF0595b7b24D40` was deployed by a different key `0xC6c66AeEbe18e3d1027a4b0b38cE0071616D6464` in block 6191499 on 2026-07-10 15:34:50 UTC, with its own hook `0x208378dDc05eD5De1833624a30EB9C1d26f86EcC` and vault `0x26e421917aeA64B615A3127A2BA3AC3051C3ab80` (`_raw/blockscout/tx-0x5c291dcc915485e505aa0491a046f902f78fb9d6f3e6890b99f1965c2f3aa096.json`, `contracts/ADDRESSES.md`).
It launched 314 tokens, the last in block 23256514 on 2026-07-30, and its `creationFee` is also 0 (`_raw/rpc/factory-v1-state-2026-09-02.json`, `_raw/blockscout/address-0x46aD6f53A3C26C8027826e2104cF0595b7b24D40-logs.json`).
The docs never mention it, but its graduated tokens (MOONCAT, FINN and eight others) still appear as `version: v1` in the app's feed and the public API's claimable-positions endpoint covers "V1 and V2 tokens" (`_raw/api/api-evm-rh-pulse-2026-09-02b.json`, `pages/042-docs-api-reference-get-rh-claimable-positions.md` line 10).
A 2404-byte unverified contract `0xcF8DA63Dd1cb58daDd2c1B350ac756ffA43EF2d4` from the same deployer four minutes later is kept as bytecode (`contracts/Unknown-0xcF8D-0xcF8DA63Dd1cb58daDd2c1B350ac756ffA43EF2d4/`).

### 5.3 Per-token example (BARRY)

| contract | address | dir |
| --- | --- | --- |
| BagsToken clone | `0x1F24CE2dEC25B8bD5C88316A69B188221d3bf8aF`, EIP-1167 bytecode pointing at `0x74E9...5409` | `contracts/ExampleToken-BARRY-0x1F24CE2dEC25B8bD5C88316A69B188221d3bf8aF/` |
| BagsBondingCurve proxy | `0x0b40294883335c8E5724ea5C0D519510Cab8e2cf`, beacon slot = `0x8DCE...07E`, `migrated = 1` | `contracts/ExampleCurve-BARRY-0x0b40294883335c8E5724ea5C0D519510Cab8e2cf/` |
| BagsFeeShare proxy | `0x87aA06739c835B89953e5e99f0A4AcB9814C670D`, beacon slot = `0xdFf0...7e0` | `contracts/ExampleFeeShare-BARRY-0x87aA06739c835B89953e5e99f0A4AcB9814C670D/` |
| Uniswap v4 pool | poolId `0x08cf533730748e2a82c683292a3dbf20734732705e648c6fcaea8c74c095d8b4`, WETH/BARRY | `_raw/dexscreener/token-pairs-BARRY.json` |

The beacon slots and the clone bytecode were read directly with `eth_getStorageAt` and `eth_getCode` (`_raw/rpc/factory-state-2026-09-02.json`).

### 5.4 What it is built on

Custom bonding curve plus Uniswap v4 hook.
Evidence: the curve is Bags' own `BagsBondingCurve` with hard-coded constants, graduation calls the canonical v4 `PoolManager.initialize` and `PositionManager.modifyLiquidities`, and the pool key names the Bags hook (`BagsBondingCurve.sol` `_migrate`, `tx-0xe76b...-logs.json`).
No Doppler Airlock, no Uniswap v2 or v3, no Clanker (`_raw/api/doppler-indexer-check-2026-09-02.json`).

### 5.5 Audits

None of the 137 captured pages mentions a smart-contract audit of the Robinhood Chain contracts; the only "audit" hits are a Jupiter token-metadata field in two Solana API pages (`pages/059-docs-api-reference-get-token-claim-events.md`, `pages/087-docs-how-to-guides-get-token-claim-events.md`).

## 6. Backend APIs

### 6.1 Public API v2

Base `https://public-api-v2.bags.fm/api/v1`, OpenAPI 3.1.0 "Bags Public API v2" version 2.0.0, 61 paths, authentication by `x-api-key` from dev.bags.fm (`_raw/api/openapi.json`, `pages/069-docs-api-reference-introduction.md`).
Every response is `{ "success": true, "response": ... }` or `{ "success": false, "error": "..." }`.
The 21 Robinhood Chain endpoints (`_raw/api/openapi.json`, one docs page each under `pages/041-docs-api-reference-get-rh-balances.md` to `pages/068-docs-api-reference-init-rh-index-token.md`):

| method | path | purpose |
| --- | --- | --- |
| GET | `/evm/rh/creation-fee` | `{ "creationFeeWei": "0" }`, read from the v2 factory |
| GET | `/evm/rh/tokens`, `/evm/rh/token`, `/evm/rh/token-state`, `/evm/rh/token-creations` | discovery and per-token state |
| GET | `/evm/rh/quote`, `/evm/rh/pool-price`, `/evm/rh/trades`, `/evm/rh/trade-stats`, `/evm/rh/top-volume` | trading data |
| GET | `/evm/rh/balances`, `/evm/rh/portfolio` | holder views |
| GET | `/evm/rh/claimable-positions`, `/evm/rh/creator-fees`, `/evm/rh/creator-earnings`, `/evm/rh/creator-roster` | fee views across V1 and V2 tokens, with `pendingWei` estimates of un-swept hook fees |
| POST | `/evm/rh/create-claim-txs` | unsigned `BagsFeeShare.claim` transactions |
| POST | `/evm/rh/index-token/init`, `/evm/rh/index-token/status`; GET `/evm/rh/index-token/history` | index tokens |
| GET | `/evm/token-creator` | creator lookup |

Example (`pages/003-docs-robinhood-index-tokens.md` section 3):

```text
POST /evm/rh/index-token/init   x-api-key: ...
{ "tokenAddress": "0x...", "tokens": ["0xTSLA...", "0xNVDA...", "0xAAPL..."] }
-> { "success": true, "response": "Index token initialized successfully" }
403 wrong owner or claimer not configured, 404 not a Bags token, 409 already initialised
```

The official `bags-sdk` exposes `sdk.robinhood` with `getClaimablePositions`, `getTopVolume` and `createClaimTransactions`, and the `bags-cli` has `robinhood top-volume`, `robinhood claimable` and `robinhood create-claim-transactions` (unsigned) (`_raw/github/bags-sdk/src/services/robinhood.ts`, `_raw/github/bags-cli/src/commands/robinhood.ts`).
Launching on Robinhood Chain is not wrapped by either; the docs send you straight to the factory with viem (`pages/004-docs-robinhood-launch-token.md`).

### 6.2 Endpoints the web app itself calls

Observed while loading bags.fm with the Robinhood network selected (`_raw/network/network-home.json`, 97 requests):

| host and path | role | capture |
| --- | --- | --- |
| `GET api2.bags.fm/api/v1/evm/rh/pulse` | the home and trade feeds; `response: { new[100], soon[100], bonded[33] }`, each item with `address, name, symbol, metadataURI, curve, feeShare, poolId, creator, partner, partnerFeeBps, createdAtBlock, txHash, migrated, migratedAtBlock, version, priceEthPerToken, bondingProgressPct, priceChange24hPct, volume24hEthWei` | `_raw/api/api-evm-rh-pulse-2026-09-02b.json` |
| `POST api2.bags.fm/api/v1/token-launch/bulk` | token metadata for the cards | not stored |
| `GET api2.bags.fm/api/v1/token-launch/top-tokens/lifetime-fees` | the "Earned $393.20K from $ASTEROID" banner, 110 Solana tokens | `_raw/api/api-top-tokens-lifetime-fees.json` |
| `GET api2.bags.fm/api/v1/user/<handle>` | creator cards (TheGivingBlock, finnbags, Steve_Yegge and others) | not stored |
| `GET data-api.bags.fm/v2/bags/stats/` | site-wide stats | `_raw/api/api-data-stats.json` |
| `GET ipfs.bags.fm/ipfs/<cid>` | token images | not stored |
| `auth.privy.io` | login, app id `cm7m1jjj900ks13jd6kmrv20s` | headers only |
| `datapi.jup.ag`, `api.coingecko.com/api/v3/simple/price?ids=ethereum`, Amplitude | Solana prices, ETH price, analytics | headers only |

No RPC host appeared in the 97 requests, so the app's own RPC endpoint was not observed (Gaps).
The `pulse` response shape is what a launcher would poll to watch a token's progress without an API key.

## 7. Ecosystem

Launch counts (`_raw/rpc/factory-state-2026-09-02.json`, `_raw/rpc/factory-v1-state-2026-09-02.json`):

- v2 factory `allTokensLength` = 3934 at block 52761706, up from 3920 earlier the same day (`_raw/api/rpc-factory-config.json`).
- v1 factory `allTokensLength` = 314, all between 2026-07-10 and 2026-07-30.
- Total 4248 Bags tokens on Robinhood Chain in 54 days.

Pace and quality (`_raw/api/api-evm-rh-pulse-2026-09-02b.json`, `_raw/rpc/derived-economics-2026-09-02.txt`):

- The 100 newest launches span 2.95 days, 33.8 launches per day; 11 of them had any bonding progress and 28 any 24h volume.
- 77 of the 100 "soon" (in-progress) tokens are below 10% bonded; one is at 50 to 59%.
- 25 of the 100 in-progress tokens name a partner, 22 of them `0x40FA5b555b83676E203Dac4CfB70fD13A53bf6a7`, whose identity was not established (Gaps).
- 33 tokens are "bonded": 23 v2 and 10 v1; 27 graduated in July 2026, 4 in August, 2 in September.
- Median time from launch to graduation among bonded tokens is 0.5 hours; the slowest took 191 hours.
- On chain, 38 `Migrated` events exist across all curves since block 7887312 and 23 `PoolMinted` events on the live hook, so 23 v2 graduations and 15 v1 graduations, of which the feed shows 10 (`_raw/rpc/curve-Migrated-logs-2026-09-02.json`, `_raw/rpc/hook-PoolMinted-logs-2026-09-02.json`).
- Graduation rate is therefore about 0.9% of launches (38 of 4248).

Notable tokens (`_raw/api/api-evm-rh-pulse-2026-09-02b.json` bonded list, app token pages):

| token | address | version | graduated | 24h volume | app page |
| --- | --- | --- | --- | --- | --- |
| CATS, Robinhood Cats | `0x7195e2088f3DFCca56e6A71D129051963Ed9657A` | v2 | 2026-07-15 | 89.5 ETH; app shows $445K market cap, $60K liquidity, $214K volume, 948 trades | `pages/112-app-token-cats.md`, `screenshots/114-app-0x7195e2088f.png` |
| BARRY, Barry Marquet | `0x1F24CE2dEC25B8bD5C88316A69B188221d3bf8aF` | v2 | 2026-09-02 | 28.0 ETH; app shows $24.8K market cap, $14.2K liquidity, $66.9K volume, 696 trades; Dexscreener $14,194 liquidity | `pages/111-app-token-barry.md`, `_raw/dexscreener/token-pairs-BARRY.json` |
| SNP500, Sock & Pussy 500 | `0xcf12d7c256D60dD96750e8BA8afeeA90d4114D33` | v2 | 2026-08-13 | 2.0 ETH | `pages/104-app-home.md` |
| MERRY | `0x66c9Ba158b2b80c2A51Ca75F3e4155a682676C7A` | v2 | 2026-09-01 | 1.6 ETH | `pages/104-app-home.md` |
| NASDAQ, NASDAQ 6900 | `0xEa3d8Cac0545055f570feA87c4cf1E449cF36A38` | v2 | 2026-08-13 | 0.6 ETH | `pages/104-app-home.md` |
| FINN, The Bagworker Bull | `0xED66C633CF546B50787640800cbD989Fa851C52E` | v1 | 2026-07-12 | 0.2 ETH | `pages/104-app-home.md` |
| MOONCAT | `0x4BC437B2dB77b6fa9D9Fe54473D5eAd9f194C631` | v1 | 2026-07-12 | 0.03 ETH; first v1 token, created 2026-07-10 20:12 UTC | `pages/104-app-home.md` |

The trending row on the home page is the same handful of cat-themed and stock-parody tokens (`pages/104-app-home.md`, `pages/116-app-home-bonded.md`).
Fees: DefiLlama attributes $585,729 of all-time fees on Robinhood Chain to Bags against $310.4M for the chain as a whole, so Bags is a small share of chain activity (`_raw/api/defillama-fees-robinhood-chain-2026-09-02.json`).
The vault held 28.171 ETH at capture, which is the protocol half accumulated net of any withdrawals; withdrawals were not enumerated (`_raw/rpc/factory-state-2026-09-02.json`, Gaps).
For scale, the Dexscreener "bags" search returns 30 Robinhood Chain pairs, all Uniswap v4, but the large ones (OUROBOROS, AI, MOO) are not Bags tokens; they match the query by name (`_raw/dexscreener/search-bags.json`).

Company-wide, mostly Solana (`_raw/api/api-data-stats.json`): 183,031 coins launched, $4.657B lifetime volume, 1,632,605 unique traders, $19.94M paid out in 394,311 user claims to 20,528 claimers, $31.94M lifetime revenue, 2,109 lifetime migrations, 14 launches and 3,325 trades in the last 24h.

## 8. Link inventory summary

`LINKS.md` has 965 rows, one per link per page, deduplicated per page (`LINKS.md` header).
By type: 388 social, 207 docs, 135 repo, 133 support, 70 external, 31 app, 1 explorer.
Every one of the 103 docs.bags.fm URLs in the sitemap has a `pages/` file, mapped in `_raw/tavily/pages-index-docs.tsv`.
All 137 page files carry the required `Source` and `Retrieved` header; the two shortest (`pages/117-app-profile-thegivingblock.md`, `pages/118-support-home.md`) are genuinely thin upstream and are annotated.
20 screenshots cover the home page, the network selector, the four wizard steps, the trade list, two token pages, about, contact, terms, the docs home and overview, and the support centre (`screenshots/`).
Seven socials files cover X, Discord, Telegram, LinkedIn, GitHub and the two app stores (`socials/`).
Repos cloned: `bags-sdk`, `bags-cli`, `bags-idl` (including `robinhood-abi-v2` and `legacy-robinhood-abi`), `bags-skill`, `play` (`_raw/github/`).

## 9. Gaps

- Wallet gate: the fee-claimer editor and the launch confirmation sit behind a Privy login ("Login to launch"); the archive stopped there and did not authenticate, so no UI-built calldata was captured. The three decoded production launches in section 3.5 stand in for it and are better evidence.
- The creator profile page (`bags.fm/$thegivingblock`) rendered only a header without login (`pages/117-app-profile-thegivingblock.md`).
- X posts were not captured: Bright Data's `x_posts` pipeline only accepts status URLs and there is no `x_profiles` pipeline (`_raw/socials/x-bagsapp-posts.err`, `_raw/socials/x-bagsapp-profile.err`); only the profile header via Jina is on disk (`socials/01-x-bagsapp.md`).
- The Discord invite page needs JavaScript and Jina returned the app shell, so no member count or channel list (`socials/02-discord-bagsapp.md`).
- Team identities: no captured page names founders or staff; LinkedIn hides employees without login.
- dev.bags.fm (API key portal) is behind a login and was not captured.
- The partner `0x40FA5b555b83676E203Dac4CfB70fD13A53bf6a7` on 22 in-progress launches was not identified.
- `0xcF8DA63Dd1cb58daDd2c1B350ac756ffA43EF2d4` (v1 deployer, 2026-07-10) is unverified and its purpose unknown.
- Blockscout has not matched the bytecode of the BARRY fee-share `BeaconProxy` or the `BagsToken` clone, so those two directories hold `bytecode.hex` plus the resolved beacon and implementation rather than sources.
- Vault withdrawals were not enumerated (only the first 50 `Received` logs were pulled), so the 28.171 ETH balance cannot be asserted as the lifetime protocol take.
- The 38 on-chain `Migrated` events versus 33 tokens in the app's bonded feed were not reconciled token by token.
- The app's RPC endpoint did not appear in the network capture.
- USD conversions of ETH figures were not made; the CoinGecko ETH price response body was not stored.
- The docs mention BNB Chain as a separate deployment; nothing about it was investigated.
- The Solana product (Meteora DBC and DAMM v2, 85 SOL threshold) is documented in 94 captured pages but was not analysed beyond the identity and scale facts above, because the launch decision concerns Robinhood Chain.
- No audit of the Robinhood Chain contracts was found on any captured page.
- Only two docs pages were screenshotted (`screenshots/120-docs-home.png`, `screenshots/121-docs-robinhood-overview.png`); the docs are captured as clean markdown instead.
