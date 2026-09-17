# Virtuals Protocol

Archive of the Virtuals Protocol agent-token launchpad as deployed on Robinhood Chain (chain id 4663), captured 2026-09-02.
Every number below cites the file it came from; on-chain reads are in `_raw/rpc/`, Blockscout records in `_raw/blockscout/`, backend responses in `_raw/api/`, and page text in `pages/`.
Virtuals is not Doppler-derived: `indexer-prod.doppler.lol` returns zero assets on chain 4663 for every Virtuals fee, treasury, owner and vault address (see `SESSION-NOTES.md`), and the launch stack below is Virtuals' own bonding-curve contract set with a Uniswap V2 exit.

## 1. Identity

| item | value | source |
| --- | --- | --- |
| Name | Virtuals Protocol ("Society of AI Agents") | `socials/01-x-virtuals-io-profile.md` |
| Marketing site | https://www.virtuals.io/ | `pages/178-www-home.md` |
| App | https://app.virtuals.io/ (Vite SPA, Privy login app id `cltsev9j90f67yhyw4sngtrpv`) | `pages/180-app-home.md`, `_raw/network/requests-app-home.txt` |
| Whitepaper | https://whitepaper.virtuals.io/ (GitBook, 73 listed pages plus 38 unlisted, plus zh and ko translations) | `pages/001-wp-whitepaper-home.md`, `_raw/jina/whitepaper-sitemap-pages.xml`, `_raw/tools/wp-hidden-fetched.txt` |
| EconomyOS docs | https://os.virtuals.io/ (Mintlify, 31 pages) | `pages/267-os-index.md` and following |
| Governance forum | https://gov.virtuals.io/ | `pages/273-gov-gov-home.md` |
| Legacy app | https://legacy.virtuals.io/ (VIRTUAL to xVIRTUAL conversion, bridge) | `pages/278-legacy-home.md` |
| Support | https://support.virtuals.io/ (ticket form only) | `pages/235-ext-support-virtuals-io.md` |
| X | https://x.com/virtuals_io, 294.5K followers, 6,300 posts, joined September 2021 | `socials/01-x-virtuals-io-profile.md` |
| Discord | https://discord.com/invite/virtualsio | `socials/03-discord-invite.md` |
| Telegram | https://t.me/virtuals | `socials/04-telegram.md` |
| Substack | https://virtuals.substack.com/ | `socials/05-substack.md` |
| GitHub | https://github.com/Virtual-Protocol, 37 public repos, 11 cloned into `_raw/github/` | `socials/07-github-org.md` |
| Dune | https://dune.com/virtuals_protocol (Base only, no Robinhood Chain dataset) | `socials/06-dune-dashboards.md` |
| Core contributor handles | Ethermage (x.com/ethermage), everythingempty (x.com/everythingempt0), 0xkookoo | `pages/039-wp-info-hub-virtuals-protocol-core-contributors.md` |
| Chains | Base (primary), Ethereum (VIRTUAL token only), Solana, Robinhood Chain | `pages/043-wp-info-hub-important-links-and-resources-virtuals-protocol-contract-addr.md`, `_raw/api/api2-dex-prices.json` |
| VIRTUAL on Robinhood Chain | `0xc6911796042b15d7Fa4F6CDe69e245DdCd3d9c31`, Chainlink CCIP burn-and-mint token, 8,354,758 VIRTUAL minted on this chain, 14,085 holders | `contracts/ADDRESSES.md`, `_raw/blockscout/token-VIRTUAL.json` |
| Audit | Code4rena competitive audit, April 2025 (only audit listed) | `pages/037-wp-info-hub-security-virtuals-protocol-smart-contract-security-audits.md` |
| Legal | Launchpad developer agreement, terms of use, privacy policy, ACP developer agreement | `pages/279-pdf-launchpad-agreement.md`, `pages/280-pdf-terms-of-use.md`, `pages/281-pdf-privacy-policy.md`, `pages/282-pdf-acp-developer-agreement.md` |
| Capture date | 2026-09-02 | all files |

## 2. What it is

Virtuals is an AI-agent tokenisation platform: a creator "tokenises an agent", which mints a 1,000,000,000-supply ERC-20 paired against VIRTUAL on an internal bonding curve, and the token graduates to a Uniswap V2 pool once 42,000 VIRTUAL of real liquidity has been bought into the curve (`pages/011-wp-about-virtuals-capital-formation-layer-virtuals-launch-mechanics.md`, `_raw/rpc/bondingconfig-reads.txt`).
The whitepaper now describes the launchpad as fully modular: there are no more Genesis or Unicorn launch classes, every feature (anti-sniper tax, 60 Days trial, Automated Capital Formation, airdrop to veVIRTUAL stakers, fee delegation, pre-buy, launch as existing token, Launch Radar, robotics flag) is an independent toggle at creation (`pages/010-wp-about-virtuals-capital-formation-layer.md`).
On this chain the quote asset is CCIP-bridged VIRTUAL, the exit venue is Uniswap V2, and creator fees are paid out in USDG rather than USDC (`_raw/rpc/tax-factory-router-reads.txt`, `_raw/api/defillama-fees-virtuals-protocol.json` methodology).
It is aimed at founders of AI agents and AI-native products who want a token, a locked pool and an optional automated fundraise without seeding liquidity themselves; the creator pays nothing for a plain launch and 10 VIRTUAL for an ACF launch (`_raw/rpc/bondingconfig-reads.txt` `calculateLaunchFee`).
The same token doubles as the agent's identity inside Agent Commerce Protocol (ACP), Virtuals' on-chain job and payment escrow, which is also deployed on this chain (`contracts/ACP-AgenticCommerceV3-Proxy-0x62891D58e1321D92f338901A433c2699aADaf2C1/`).

## 3. How a launch works, step by step

### 3.1 What the creator sees

1. Open https://app.virtuals.io/create or press "Launch Token" / "Create Agent"; both are behind a Privy login ("Account not connected. Login now to launch your token"), so the wizard itself could not be captured (`pages/212-app-create.md`, `pages/216-app-login-modal.md`, `screenshots/35-app-login-modal.png`).
2. Per the whitepaper, the creator fills name, ticker, description, image, socials, picks the chain, and toggles modules; the agent launch page is published instantly and trading opens automatically (`pages/011-wp-about-virtuals-capital-formation-layer-virtuals-launch-mechanics.md`).
3. The app's Robinhood Chain list shows Trending, Top, Gainers and New tabs, live trades, FDV, 24h volume, 24h range, liquidity, age and holders per token (`pages/181-app-robinhood-list.md`, `screenshots/02-app-robinhood-list.png`).
4. A token page shows price, FDV, volume, holders, the bonding-curve progress or the Uniswap pool, tokenomics (for VEX: pool 50 percent, fundraising 25 percent, default vesting 25 percent), a Dexscreener link and a Robinscan link (`pages/183-app-agent-96200-vex.md`, `_raw/api/api2-virtual-96200-tokenomics-parameters.json`).
5. The dashboard shows veVIRTUAL and airdrop allocations, with the note "Staking is currently only supported on Base" (`pages/214-app-dashboard.md`).
6. Vested tokens (team allocation, pre-buy, sniper-tax buybacks) are not pushed; the recipient logs in and claims (`pages/030-wp-info-hub-virtuals-builder-and-agent-token-launch-faq.md`).

### 3.2 What the contracts do

The exact call a live launch makes was decoded from two September 2 transactions (`_raw/blockscout/launches/preLaunch-0x1086e82c...json`, `preLaunch-0x17c5bc80...json`, `launch-0xcee078ea...json`).

1. `BondingV5.preLaunch(name, ticker, cores[], desc, img, urls[4], purchaseAmount, startTime, launchMode, airdropBips, needAcf, antiSniperTaxType, isProject60days, extParams)` on `0xd4cCBFA37e2f35611b3042e4096Ad7a3459Bd007`.
The creator must have approved VIRTUAL: `purchaseAmount` is pulled in full, the launch fee part goes to `feeTo`, the rest is held as the creator's initial buy (`contracts/BondingV5-Impl-current-0x66Fc520c7F316B8623eee2A5dA821c3b34D0539D/sources/contracts/launchpadv2/BondingV5.sol`).
BLITZO used `purchaseAmount 1 VIRTUAL, antiSniperTaxType 1 (60 s), needAcf false`; PawPons used `purchaseAmount 0, antiSniperTaxType 0`.
2. `AgentFactoryV7.createNewAgentTokenAndApplication` clones `AgentTokenV4` (EIP-1167) with name `<name> by Virtuals` unless bit 1 of `extParams` is set, mints the whole 1,000,000,000 supply to BondingV5, and creates the Uniswap V2 pair address up front so it can be blacklisted until graduation (`BondingV5.sol` lines 393 to 419).
3. `FFactoryV3.createPair` creates the internal `FPairV2` bonding pair; `FRouterV3.addInitialLiquidity` deposits the curve supply against a fake initial VIRTUAL liquidity of 8,500 VIRTUAL (18,000 with ACF), which sets the opening price at 117,647 tokens per VIRTUAL, or an opening FDV of 8,500 VIRTUAL (`_raw/rpc/bondingconfig-reads.txt`, `_raw/rpc/tax-factory-router-reads.txt` tokenInfo price field).
4. Reserved supply (airdrop bips plus 50 percent when ACF is on) is transferred to `teamTokenReservedWallet 0x81F7cA6AF86D1CA6335E44A2C28bC88807491415`; the per-token graduation threshold is stored (`BondingV5.sol` lines 443 to 456).
5. `AgentTaxV2.registerToken(token, creator, creator)` records who receives the creator share of the tax (`BondingV5.sol` lines 513 to 521).
6. `BondingV5.launch(token)`: anyone can call it for a plain launch once `startTime` has passed; for 60 Days, X-launch, ACP-skill and fee-delegated launches only a privileged launcher may call it, because the backend must first point the tax recipient at the right party.
It sets the anti-sniper tax start time and executes the creator's initial buy, whose tokens go to `teamTokenReservedWallet` for locking, not to the creator (`BondingV5.sol` lines 579 to 659; PawPons' `launch` was called by `0x81F7...` itself).
7. `buy` and `sell` go through `FRouterV3`, which takes `buyTax 1` and `sellTax 1` percent of the VIRTUAL leg into `AgentTaxV2` with per-token attribution, plus a decaying anti-sniper tax into `antiSniperTaxVault 0x3248...` (`contracts/FRouterV3-Impl-current-0x09256b9D607c53fD946681F7C5a7a4381ba285A1/sources/contracts/launchpadv2/FRouterV3.sol` lines 140 to 245, `_raw/rpc/ffactory-reads.txt`).
8. Graduation is triggered inside `_buy` when the curve's token reserve drops to `tokenGradThreshold` and no anti-sniper tax is active: `FRouterV3.graduate`, the collected VIRTUAL goes to `AgentFactoryV7`, the pool-bound tokens are sent to the token contract, excess tokens go to `graduationExcessBurnWallet 0xAeA2...`, and `executeBondingCurveApplicationSalt` mints the Uniswap V2 pool, the staked-LP veToken with a 10-year maturity, the AgentDAO, the agent NFT and the ERC-6551 account (`BondingV5.sol` lines 783 to 871; VEX graduation logs in `_raw/blockscout/graduations/vex-graduated-0xae1fbd32...-logs.json`).
9. After graduation the `AgentTokenV4` clone itself taxes 1 percent on buys and sells in the Uniswap pool (`projectBuyTaxBasisPoints 100`, `projectSellTaxBasisPoints 100`) and forwards it through `TaxAccountingAdapter` to `AgentTaxV2` (`_raw/rpc/agenttoken-vetoken-reads.txt`).
10. `AgentTaxV2` swaps accumulated VIRTUAL to USDG on Uniswap V2 once at least 1 VIRTUAL has accrued (`minSwapThreshold`), sends 30 percent to the treasury `0xb51C...` and the rest to the creator, minus an optional partner share of up to 20 percent (`contracts/AgentTaxV2-Impl-0x4D4e8F06FE9a3dB2FA7AD4D17893128600Ec01bB/sources/contracts/tax/AgentTaxV2.sol` `_swapAndDistribute`, `_raw/rpc/tax-factory-router-reads.txt`).

### 3.3 The graduation arithmetic, verified against a live token

`calculateGradThreshold = fakeLiq * curveSupply / (42,000 + fakeLiq)` (`contracts/BondingConfig-Impl-current-0x13C4A51590DA706aA01654dF25e80e7d001728C6/sources/contracts/launchpadv2/BondingConfig.sol`).
For a plain launch that is `8,500 * 1e9 / 50,500 = 168,316,831.68` tokens left in the curve, which is exactly the `tokenGradThreshold` read for BLITZO (`_raw/rpc/tax-factory-router-reads.txt`), so graduation happens after 831.7 million tokens have been sold for 42,000 real VIRTUAL.
At graduation the pool receives `168.3M * 42,000 / 50,500 = 140.0M` tokens plus the 42,000 VIRTUAL, and the remaining 28.3 million tokens go to the excess-burn wallet, which is the supply the Hyperboost programme redistributes over 14 days (`BondingV5.sol` `_openTradingOnUniswap`, `pages/011-wp-about-virtuals-capital-formation-layer-virtuals-launch-mechanics.md`).
The graduation FDV is therefore 300,000 VIRTUAL for a plain launch and 400,000 VIRTUAL for an ACF launch (500 million curve supply, 18,000 fake liquidity, 105 million tokens into the pool), about 207,000 and 276,000 USD at the 0.6885 USD VIRTUAL price in `_raw/api/api2-dex-prices.json`.
VEX confirms the lock: `Staked ProjectVex` holds `initialLock 2,101,443 LP` with `matureAt 2098458081`, exactly ten years after `fundedDate 1783098081` (2026-07-03) (`_raw/rpc/agenttoken-vetoken-reads.txt`).

### 3.4 Launch modules as they exist on chain

| module | on-chain parameter | what it does | source |
| --- | --- | --- | --- |
| Anti-sniper | `antiSniperTaxType` 0 none, 1 60 s buy, 5 10 min buy, 2 98 min buy, 3 98 min sell, 4 98 min both | tax starts at 99 percent and decays linearly to the 1 percent base over 60, 600 or 5,880 seconds; proceeds go to the anti-sniper vault for buybacks vested to the team (3-month cliff, 9-month linear) | `_raw/rpc/bondingconfig-reads.txt`, `FRouterV3.sol` `_calculateAntiSniperTaxForSide`, `pages/012-wp-about-virtuals-capital-formation-layer-anti-sniper-protection-for-toke.md` |
| Automated Capital Formation | `needAcf true` | 50 percent of supply reserved (25 percent tiered sell orders from 2M to 160M USD FDV paid to founders in stablecoin, 25 percent team allocation locked 1 year then 6-month linear); curve starts with 18,000 fake liquidity; costs 10 VIRTUAL | `_raw/rpc/bondingconfig-reads.txt` `reserveSupplyParams`, `acfFakeInitialVirtualLiq`, `calculateLaunchFee`; `pages/014-wp-about-virtuals-capital-formation-layer-automated-capital-formation.md` |
| Airdrop to veVIRTUAL stakers | `airdropBips` up to 500 | up to 5 percent of supply moved to the reserved wallet at preLaunch for distribution to stakers | `_raw/rpc/bondingconfig-reads.txt` `maxAirdropBips 500`, `pages/015-wp-about-virtuals-capital-formation-layer-airdrop-distribution.md` |
| 60 Days trial | `isProject60days` | founder share of fees escrowed for 60 days; commit or wind down with refunds; stipend 10 percent of collected funds capped at 5,000 USDC at day 30 and 60 | `pages/013-wp-about-virtuals-capital-formation-layer-60-days.md`; `launch()` restricted to privileged launchers |
| Fee delegation | `extParams` bit 0, bits 3 to 4 type (1 address, 2 X account id), trailing word recipient | creator's 70 percent share accrues to another identity who claims after profile verification | `BondingV5.sol` lines 184 to 270, `pages/018-wp-about-virtuals-capital-formation-layer-fee-delegation-for-ai-agent-tok.md` |
| Pre-buy | `purchaseAmount` | creator's initial buy executed at `launch()` with no anti-sniper tax, tokens locked (default 1-month cliff, 12-month linear) | `BondingV5.sol` `launch`, `pages/019-wp-about-virtuals-capital-formation-layer-pre-buy-tokens-for-ai-agent-lau.md` |
| Scheduled launch | `startTime >= now + 86,400` | pair opens at `startTime`; `normalLaunchFee` is 0 on this chain | `_raw/rpc/bondingconfig-reads.txt` `scheduledLaunchParams` |
| Launch Radar | off-chain flag `launchInfo.launchRadarEnabled` | pre-launch visibility feed, 100 VIRTUAL per the whitepaper; no on-chain fee found | `pages/016-wp-about-virtuals-capital-formation-layer-launch-radar.md`, `_raw/api/api2-virtuals-robinhood-graduated-all.json` |
| Robotics | `extParams` bit 2 | flags the project for the Eastworlds accelerator | `BondingV5.sol`, `pages/020-wp-about-virtuals-physical-labor-layer-robotics-and-embodied-ai.md` |
| Launch as existing token | not in BondingV5 | handled off-chain by the team; minimum FDV applies | `pages/017-wp-about-virtuals-capital-formation-layer-launch-as-an-existing-token.md` |
| X-launch, ACP-skill launch | `launchMode` 1 or 2 | privileged-launcher only, fixed to 60 s anti-sniper, immediate, no airdrop, no ACF | `BondingV5.sol` `_validateLaunchMode` |

Genesis (the points-based allocation model with 21,000 / 42,000 / 100,000 VIRTUAL reserve tiers) still exists in the backend, but every one of the 363 geneses is on Base and the Robinhood filter returns zero; the whitepaper describes Genesis and Unicorn as superseded by modules (`_raw/api/api2-geneses_parameters.json`, `_raw/api/api2-geneses_filters_virtual__chain__ROBINHOOD_pagination_pageSize__30_popu.json`, `_raw/api/api2-geneses_pagination_pageSize__5_populate_0__virtual.json`, `pages/010-wp-about-virtuals-capital-formation-layer.md`).
No Genesis contract exists on this chain (`_raw/blockscout/search-GenesisFactory.json`, `search-VirtualGenesis.json` are empty).

## 4. Economics

| item | value | source |
| --- | --- | --- |
| Creation fee, plain launch | 0 VIRTUAL | `_raw/rpc/bondingconfig-reads.txt` `calculateLaunchFee(False,False) = 0` |
| Creation fee, ACF launch | 10 VIRTUAL to `feeTo 0x86Cb...` | `calculateLaunchFee(*,True) = 10e18`, `feeTo()` |
| Scheduled launch fee | 0 VIRTUAL (`normalLaunchFee`) | `scheduledLaunchParams() = [86400, 0, 10e18]` |
| Launch Radar | 100 VIRTUAL, whitepaper only, not found on chain | `pages/016-wp-about-virtuals-capital-formation-layer-launch-radar.md` |
| Token supply | 1,000,000,000, 18 decimals | `initialSupply() = 1000000000`, `_raw/rpc/agenttoken-vetoken-reads.txt` |
| Curve supply | 100 percent plain; 50 percent with ACF; minus airdrop bips | `calculateBondingCurveSupply(0,False) = 1e9`, `(0,True) = 5e8` |
| Reserve limits | maxAirdropBips 500 (5 percent), acfReservedBips 5000 (50 percent), maxTotalReservedBips 5500 | `reserveSupplyParams() = [500, 5500, 5000]` |
| Opening price | 117,647 tokens per VIRTUAL (8,500 fake VIRTUAL against 1e9 tokens) | `tokenInfo(...)` price field, `getFakeInitialVirtualLiq()` |
| Graduation threshold | 42,000 real VIRTUAL into the curve (`targetRealVirtual`) | `getTargetRealVirtual() = 42000e18`, whitepaper 42,000 |
| Tokens left in curve at graduation | 168,316,831.68 plain, 150,000,000 with ACF | `tokenGradThreshold(BLITZO)`, formula in `BondingConfig.sol` |
| Tokens into Uniswap V2 at graduation | 140.0 M plain, 105.0 M with ACF, paired with 42,000 VIRTUAL | `BondingV5.sol` `_openTradingOnUniswap` |
| Excess tokens at graduation | 28.3 M plain, 45.0 M with ACF, to `graduationExcessBurnWallet 0xAeA2...` (Hyperboost supply) | same, `_raw/rpc/bondingconfig-reads.txt` |
| Graduation FDV | 300,000 VIRTUAL plain, 400,000 VIRTUAL ACF | derived above |
| Destination DEX | Uniswap V2, factory `0x8bcEaA40...`, fee tier 0.30 percent standard V2 | `contracts/UniswapV2Factory-0x8bcEaA40b9AcDfAedF85adF4ff01F5ad6517937F/`, VEX pair `0x817f16F5...` |
| LP lock | 100 percent of LP staked in `AgentVeTokenV2` with `maturityDuration 315,360,000 s` (10 years), the sTOKEN goes to the creator | `_raw/rpc/tax-factory-router-reads.txt` `maturityDuration`, `agenttoken-vetoken-reads.txt` `matureAt`, FAQ in `pages/030-wp-info-hub-virtuals-builder-and-agent-token-launch-faq.md` |
| Trade tax on the curve | 1 percent buy, 1 percent sell of the VIRTUAL leg | `_raw/rpc/ffactory-reads.txt` `buyTax() = 1`, `sellTax() = 1` |
| Trade tax after graduation | 1 percent buy, 1 percent sell inside the token (100 bps) | `_raw/rpc/agenttoken-vetoken-reads.txt` |
| Tax split | 30 percent protocol treasury `0xb51C...`, 70 percent creator, partner share up to 20 percent taken from the creator side | `_raw/rpc/tax-factory-router-reads.txt` `feeRate() = 3000`, `maxPartnerFeeRate() = 2000`; whitepaper 70 / 30 |
| Payout asset | USDG `0x5fc5360D...` (VIRTUAL swapped on Uniswap V2 when at least 1 VIRTUAL has accrued, at most 1,000 per swap) | `assetToken()`, `minSwapThreshold`, `maxSwapThreshold` |
| Anti-sniper tax | starts at 99 percent, linear decay to 0 over 60 s, 600 s or 5,880 s; capped so the total never exceeds 99 percent; proceeds to `0x3248...` | `antiSniperBuyTaxStartValue() = 99`, `getAntiSniperDuration(*)`, `FRouterV3.sol` |
| Sniper-tax buybacks | executed over 24 hours after the window; tokens vest to team, 3-month cliff, 9-month linear | `pages/012-wp-about-virtuals-capital-formation-layer-anti-sniper-protection-for-toke.md` |
| ACF sell tiers | 5 percent of supply per tier at 2 to 10M, 10 to 20M, 20 to 40M, 40 to 80M, 80 to 160M USD FDV; cumulative raise 11.55M USD at 160M | `pages/014-wp-about-virtuals-capital-formation-layer-automated-capital-formation.md` |
| ACF team allocation | 25 percent, locked 1 year, then 6-month linear (VEX: 250,000,000 tokens, `startsAt 2027-07-03`, linear over 6 months) | `_raw/api/api2-virtual-96200-tokenomics.json` |
| Pre-buy vesting | default 1-month cliff, 12-month linear, adjustable | `pages/019-wp-about-virtuals-capital-formation-layer-pre-buy-tokens-for-ai-agent-lau.md` |
| 60 Days stipend | 10 percent of collected funds at day 30 and day 60, capped 5,000 USDC each | `pages/013-wp-about-virtuals-capital-formation-layer-60-days.md` |
| Growth Allocation | up to 5 percent of team allocation sold at founder-set FDV, 6-month linear vesting, full refund if no commit | `pages/013-wp-about-virtuals-capital-formation-layer-60-days.md` |
| Hyperboost | excess graduation supply released 1/14 per day for 14 days to traders by volume share and to content, every graduation after 2026-07-27 16:00 UTC | `pages/011-wp-about-virtuals-capital-formation-layer-virtuals-launch-mechanics.md` |
| Chat room gates | 10,000 tokens, or 100 veVIRTUAL pre-TGE, 1,000 veVIRTUAL post-TGE | `_raw/api/api2-chat-rooms-threshold.json` |
| veVIRTUAL | lock up to 2 years, linear decay, Base only | `pages/033-wp-info-hub-usdvirtual-token-base-asset-for-ai-agents-usdvirtual-staking-.md`, `pages/214-app-dashboard.md` |
| VIRTUAL supply | 1,000,000,000 total, 60 percent public, 5 percent liquidity, 35 percent ecosystem treasury with emissions capped at 10 percent per year for three years | `pages/072-wp-about-virtuals-1-usdvirtual-tokenomics-token-distribution.md` |
| VIRTUAL price and pool | 0.6891 USD, VIRTUAL/WETH Uniswap V3 0.05 percent pool `0x9cc8c4F6...`, 258,241 USD liquidity, 2.79M USD 24h volume | `_raw/dexscreener/pair-virtual-weth.json` |
| Protocol fees, Robinhood Chain | 438,465 USD in the 30 days to 2026-08-31; all chains 657,827 USD 30d, 36,025 USD 24h, 73.7M USD all time | `_raw/api/defillama-fees-virtuals-protocol.json` |

Whitepaper versus chain: the 42,000 VIRTUAL threshold, 1 percent tax, 70 / 30 split, 10-year lock, 10 VIRTUAL ACF fee, 5 percent airdrop cap and the anti-sniper presets all match the contract reads.
Two differences: the whitepaper's "Launch Radar 100 VIRTUAL" fee has no on-chain counterpart (`normalLaunchFee` is 0), and the whitepaper's "creator vault", "sell wall wallet" and "sell order" core addresses are plain EOAs with no code on this chain (`contracts/ADDRESSES.md`).
The Base-era 6,300 VIRTUAL fake liquidity survives as `legacyInitialVirtualLiq` for pre-upgrade tokens; every token read on this chain uses 8,500 (`_raw/rpc/bondingconfig-reads.txt`).

## 5. Smart contracts

Full table with creators, creation transactions and directories: `contracts/ADDRESSES.md` (63 directories, 50 verified with sources, 8 unverified with bytecode, 5 clone or TBA records).

### 5.1 How VIRTUAL reached the chain

VIRTUAL `0xc6911796042b15d7Fa4F6CDe69e245DdCd3d9c31` is a Chainlink CCIP `CrossChainToken` deployed by the Virtuals deployer `0xe4a0015B...` on 2026-06-23 with a `BurnMintTokenPool` bound to the CCIP router `0x06fC836c...`; it is minted on this chain only when VIRTUAL is burned on another chain, so there is no Arbitrum-bridge wrapper (`contracts/VirtualToken-CCIP-0xc6911796042b15d7Fa4F6CDe69e245DdCd3d9c31/README.md`, `contracts/CCIP-BurnMintTokenPool-0x78680385fcb8187ac1b28E0d6b1e0ACf5e0d0992/README.md`, `_raw/blockscout/deployer/all-txs.json`).
The deployer then deployed the whole launch stack in one batch on 2026-06-25 10:19 to 10:27 UTC, three small unverified helpers on 2026-06-29, and a Uniswap V3 SwapRouter on 2026-06-30 (`_raw/blockscout/deployer/all-txs.json`).
The first token, RHOS (`tokenInfos(0)`, virtualId 50000000001), was pre-launched on 2026-06-26 06:48 UTC at block 220,679, and the first graduation was on 2026-07-02 at block 1,239,190 (`_raw/blockscout/launches/rhos-creation-0x569fda24...json`, `_raw/rpc/graduated-events.json`).

### 5.2 The launch path, in call order

| contract | address | verified | notes |
| --- | --- | --- | --- |
| BondingV5 proxy | `0xd4cCBFA37e2f35611b3042e4096Ad7a3459Bd007` | yes, impl `0x66Fc520c...` (4th implementation) | matches the whitepaper's Robinhood bonding curve address |
| BondingConfig proxy | `0x3e331Fdd9Fe54D5047b1B7339Fd5c91977D53e2F` | yes, impl `0x13C4A515...` | all economic parameters |
| FFactoryV3 proxy | `0xFC2E4Da3EdB2E18100473339c763705d263D20A9` | proxy yes, impl `0x38b1A526...` **not verified** | reads done with the repo ABI, all selectors answer |
| FRouterV3 proxy | `0xCa6395246B4382Ba70F886526dD9a9De984F6081` | yes, impl `0x09256b9D...` | tax and anti-sniper logic |
| FPairV2 instances | one per token, e.g. `0xFB899EFC...` (VEX) | **not verified** | bytecode in `contracts/FPairV2-Example-*` |
| AgentFactoryV7 proxy | `0x43E4C17b15365596Caae8e7d00E42Bc8E988c2d4` | yes, impl `0xF0a8089d...` | `totalAgents() = 85` |
| AgentTaxV2 proxy | `0x6D80B81d9Fc56A7A839b1Af9006Eb49151961ce7` | yes, impl `0x4D4e8F06...` | tax vault, USDG payouts |
| TaxAccountingAdapter proxy | `0xF36F0dd7b6b1730d0A59d1F3fD0E494C4D5c66E8` | yes, impl `0xbAF52C87...` | post-graduation tax path |
| AgentTokenV4 implementation | `0x581f7B996E6D3E436c537989157c9CB36421419b` | yes | every agent token is a 45-byte EIP-1167 clone of it |
| AgentVeTokenV2 implementation | `0xD851E9f4C40C7df6a2Ce16065A4EcBC86C7321E7` | yes | LP lock token |
| AgentDAO implementation | `0x5b56842Ba4aac6BBba74E1490c791bfAc2c5fa8C` | yes | governor per agent |
| AgentNftV2 proxy | `0x4008561D44A774AD3D517a009D0B6b647932D8D0` | yes, impl `0x5967bABc...` | agent identity NFT |
| ERC6551Registry, AccountV3Upgradable | `0xf504AB63...`, `0x1a1866D1...` | yes | token-bound accounts |
| Uniswap V2 factory and router | `0x8bcEaA40...`, `0x89e5DB8B...` | yes, third-party | exit pools and tax swaps |
| USDG proxy | `0x5fc5360D...` | yes, third-party | payout asset |

Ownership: the owner and proxy admin of BondingV5, BondingConfig and TaxAccountingAdapter is the EOA `0xc31Cf1168b2f6745650d7B088774041A10D76d55`, which has already upgraded BondingV5 three times (`_raw/rpc/bondingconfig-reads.txt`, `contracts/ADDRESSES.md`); there is no timelock or multisig in front of it on this chain.
The source on chain matches `_raw/github/protocol-contracts` commit `a4b15d69` (`contracts/launchpadv2/BondingV5.sol`, `BondingConfig.sol`, `FRouterV3.sol`, `FFactoryV3.sol`, `contracts/tax/AgentTaxV2.sol`, `contracts/virtualPersona/AgentFactoryV7.sol`), and the whitepaper's Robinhood bonding curve address matches the proxy (`pages/043-wp-info-hub-important-links-and-resources-virtuals-protocol-contract-addr.md`).
Blockscout name search also returns older Virtuals class names (BondingV1, FRouterV1, AgentTaxV1, FFactory, AgentFactory, AgentNFTv3, virtualToken) deployed by unrelated addresses; these are third-party forks and are listed separately in `contracts/ADDRESSES.md` so they are not mistaken for Virtuals.

### 5.3 Counts read from the contracts

`FFactoryV3.allPairsLength() = 25,342` and `BondingV5.tokenInfos` length 25,342 (every token ever pre-launched), `AgentFactoryV7.totalAgents() = 85` (graduated), 85 `Graduated` events between blocks 1,239,190 and 46,245,101 (`_raw/rpc/ffactory-reads.txt`, `_raw/rpc/tax-factory-router-reads.txt`, `_raw/rpc/graduated-events.json`).

## 6. Backend APIs

Hosts observed in the app's network log (`_raw/network/requests-*.txt`): `api2.virtuals.io` (Strapi-style REST), `vp-api.virtuals.io` (trades and candles), `acpx.virtuals.io` (ACP agents), `api.aixvc.io` (DEX search), `auth.privy.io` (login), plus Base RPCs (`mainnet.base.org`, QuickNode) that the SPA still calls even on Robinhood pages.

| endpoint | purpose | example capture |
| --- | --- | --- |
| `GET api2.virtuals.io/api/virtuals?filters[chain]=ROBINHOOD&filters[status]=UNDERGRAD&pagination[pageSize]=50&sort=mcapInVirtual:desc` | Robinhood Chain agents; `status` is `UNDERGRAD` (on curve) or `AVAILABLE` (graduated); `meta.pagination.total` 25,179 undergrad, 85 graduated | `_raw/api/api2-virtuals-robinhood-status1.json`, `api2-virtuals-robinhood-graduated-all.json` |
| `GET api2.virtuals.io/api/virtuals?filters[status]=5&sort[0]=virtualsPoolVol24h:desc&sparkline=true&range24h=true` | the app's Trending list across chains (numeric status 5 = graduated, 3 = new, 4 = upcoming genesis, 2 = undergrad) | `_raw/api/api2-virtuals-status5-top25.json`, `_raw/network/requests-app-home.txt` |
| `GET api2.virtuals.io/api/virtuals/{id}?populate[0]=image&populate[1]=launchInfo&...` | one agent: `preToken`, `preTokenPair`, `lpAddress`, `daoAddress`, `tbaAddress`, `veTokenAddress`, `launchInfo` (launchMode, antiSniperTaxType, airdropPercent, needAcf, isProject60days, launchRadarEnabled, isRobotics, feeDelegationType) | `_raw/api/api2-virtual-96200-full.json` |
| `GET api2.virtuals.io/api/virtuals/{id}/trade-data` | price, FDV, liquidity, 24h volume from the pool | `_raw/api/api2-virtual-96200-trade-data.json` |
| `GET api2.virtuals.io/api/virtuals/{id}/tokenomics` and `/tokenomics/parameters` | vesting schedules (unlocker contract, tracker token) and the pool / fundraising / vesting split | `_raw/api/api2-virtual-96200-tokenomics.json`, `api2-virtual-96200-tokenomics-parameters.json` |
| `GET api2.virtuals.io/api/revenue-connect-metrics/virtuals/{id}?metric=summary` | agent revenue summary | `_raw/api/api2-revenue-96200-summary.json` |
| `GET api2.virtuals.io/api/tokens/{addr}/holders?chain=ROBINHOOD` | top 500 holders as `[address, balance]` | `_raw/api/api2-token-holders-vex.json` |
| `GET api2.virtuals.io/api/geneses/parameters` | Genesis reserve tiers `[21000, 42000, 100000]` | `_raw/api/api2-geneses_parameters.json` |
| `GET api2.virtuals.io/api/geneses?filters[virtual][chain]=ROBINHOOD` | empty on Robinhood | `_raw/api/api2-geneses_filters_virtual__chain__ROBINHOOD_pagination_pageSize__30_popu.json` |
| `GET api2.virtuals.io/api/dex/prices` | VIRTUAL and gas-token prices per chain | `_raw/api/api2-dex-prices.json` |
| `GET api2.virtuals.io/api/chat-rooms/threshold` | holding gates for token chat | `_raw/api/api2-chat-rooms-threshold.json` |
| `GET api2.virtuals.io/api/project-update/{id}/tweets` | project X posts shown on the agent page | `_raw/api/api2-project-update-96200-tweets.json` |
| `GET vp-api.virtuals.io/vp-api/klines?tokenAddress=&granularity=60&chainID=6` and `/trades?tokenAddress=&chainID=6`, `/trades/recent?limit=20`, `/tickers` | candles, trades and tickers; `chainID=6` is Robinhood Chain, trades carry `chain: robinhood` and `poolType: bonding` or `graduated` | `_raw/api/vpapi-trades-recent.json`, `_raw/network/requests-app-agent-96200-vex.txt` |
| `GET acpx.virtuals.io/api/agents?filters[id][$in][]=` | ACP agent profiles (offerings, success rate, wallet) | `_raw/api/acpx-agents-page1.json` |
| `GET api.aixvc.io/gw/api/v1/public/dex/search?inputContent=` | third-party DEX search used by the Base swap widget | `_raw/network/requests-app-home.txt` |
| `api2.virtuals.io/api/leaderboards`, `/points/leaderboard`, `/protocol/stats`, `/dashboard/stats`, `/configs`, `/settings`, `/chains`, `/launch-configs` | 403 or empty without a login token | `_raw/api/api2-leaderboards.json` and the zero-byte files in `_raw/api/` |

Response shape for the list endpoint: `{"data": [{id, name, symbol, chain, status, preToken, preTokenPair, lpAddress, daoAddress, tbaAddress, stakingAddress, taxRecipient, mcapInVirtual, fdvInVirtual, liquidityUsd, holderCount, volume24h, virtualsPoolVol24h, launchInfo{...}, genesis, tokenomics, creator, ...}], "meta": {"pagination": {page, pageSize, pageCount, total}}}` (`_raw/api/api2-virtuals-robinhood-graduated-all.json`).

## 7. Ecosystem

- 25,342 tokens pre-launched on Robinhood Chain since 2026-06-26; 85 have graduated to Uniswap V2, the first on 2026-07-02 and the latest on 2026-08-26 (`_raw/rpc/ffactory-reads.txt`, `_raw/api/api2-virtuals-robinhood-graduated-all.json` launchedAt and lpCreatedAt).
- All 85 graduated tokens launched through `BONDING_V5`; 53 used ACF, 50 used the 60-second anti-sniper preset, 7 used Launch Radar, 13 used fee delegation (7 to an X account, 6 to an address), 1 was a 60 Days project, none had `isDevCommitted` (`_raw/api/api2-virtuals-robinhood-graduated-all.json`).
- Of the 49 largest undergraduated tokens, 48 use ACF, so ACF is the default choice in practice (`_raw/api/api2-virtuals-robinhood-undergrad-top50.json`).
- Graduated pools hold about 6.2M USD of liquidity in total (excluding RAXOL, whose `liquidityUsd` field is a corrupted 3.0B USD) and 63,008 holder records (`_raw/api/api2-virtuals-robinhood-graduated-all.json`).
- Largest graduated tokens by market cap in VIRTUAL: VEX (ProjectVex) 5.2M VIRTUAL, 5,821 holders, 654K USD liquidity; RAXOL 3.6M; GRID 2.4M; KARMA 1.36M; GTR (gtr.trade) 0.61M; BLEP 0.47M; MONVERA 0.45M; FLETCHER 0.41M; VANTIS 0.39M; HAN 0.32M (same file; app views in `pages/183-app-agent-96200-vex.md` and the following agent pages, screenshots 03 to 29).
- VEX, the first big Robinhood launch (2026-07-03): pool `0x817f16F5...`, 736K USD reserve, 1.14M USD 24h volume, of which 709K on the Virtuals UI, 4.4M USD FDV at capture (`_raw/api/api2-virtual-96200-trade-data.json`).
- The app's Trending list on 2026-09-02 mixed Base and Robinhood tokens (12 Base, 11 Robinhood, 2 Solana in the top 25 by 24h pool volume) (`_raw/api/api2-virtuals-status5-top25.json`).
- Protocol revenue on Robinhood Chain overtook Base in August 2026: 438K USD versus 218K USD over 30 days (`_raw/api/defillama-fees-virtuals-protocol.json`).
- Airdrops to veVIRTUAL stakers keep flowing from new launches (OVERNIGHT 10M tokens on 2026-09-02, EARN 50M, STNKR 10M, GLADIUS 50M, START 25M, GME 10M, ANTICHRIST 50M in the dashboard) (`pages/214-app-dashboard.md`).
- Governance: four proposals on gov.virtuals.io, three executed (1 percent VIRTUAL for a Sniper Defense and Yield Fund, an Ecosystem Growth Foundation, a performance grant to Virgen Labs); proposals are restricted to core contributors (`pages/273-gov-gov-home.md` to `pages/277-gov-proposal-858630801508.md`).

## 8. Link inventory summary

`LINKS.md` has 4,573 rows generated from every captured page, snapshot and map by `_raw/tools/mklinks.py`: 2,701 explorer links (Robinscan and Blockscout links on agent pages), 507 social, 378 whitepaper, 273 app, 217 external, 168 repo, 148 other virtuals.io hosts, 111 data, 60 DEX, 7 PDF, 3 audit.
Every whitepaper page in the sitemap (72), every llms.txt entry (73), 38 unlisted whitepaper pages found by following internal links, the 66 zh and ko translations, 31 EconomyOS pages, 3 degen.virtuals.io pages, 5 governance pages, the legacy app, 4 PDFs, 13 external marketing links and 43 app views are in `pages/` (282 files).
The `pages/` whitepaper files strip only the GitBook wrapper (the leading llms.txt hint line and the trailing "Agent Instructions" block); the raw files in `_raw/jina/whitepaper/` are untouched.

## 9. Gaps

- The create wizard, the module toggles and the launch transaction preview are behind a Privy login; the app refuses to show the form without an account, and this environment cannot complete a SIWE login (playbook section 6).
The exact parameters a launch submits were instead decoded from two production `preLaunch` transactions and one `launch` transaction (`_raw/blockscout/launches/`), which is more precise than a screenshot.
- `FFactoryV3` implementation `0x38b1A526...` and every `FPairV2` bonding pair are unverified on Blockscout; bytecode is archived and the repo source is the reference, but the deployed pair bytecode changed between July and September and neither version can be matched to a commit.
- Three small helper contracts deployed by the Virtuals deployer (`0x22aC...`, `0xC8D5...`, `0x32FE...`) have unknown roles.
- The Launch Radar 100 VIRTUAL fee, the Hyperboost reward distribution and the fee-delegation claim vault are backend-side; no contract for them was found on this chain.
- `api2.virtuals.io` leaderboard, points, protocol stats and config endpoints return 403 or nothing without a login token, so the current points system (if any remains) is undocumented here.
- X timeline: Bright Data's `x_posts` pipeline only accepts status URLs and returned one of six submitted posts, with no article body; the profile page is login-walled.
- Individual agent pages linked from whitepaper pages (Base-chain agents `app.virtuals.io/virtuals/3803` and others), ACP agent profile pages (`app.virtuals.io/acp/agent/...`), `app.virtuals.io/acp`, `/acp/join`, `/profile` and degen.virtuals.io agent pages were not captured; they are content items on other chains or login-gated, and are marked "not captured" in `LINKS.md`.
- `docs.game.virtuals.io` is an empty GitBook shell and `acp.virtuals.io` does not resolve (`pages/228-ext-docs-game-virtuals-io.md`, `pages/223-ext-acp-virtuals-io.md`).
- veVIRTUAL staking is Base-only, so airdrop eligibility for a Robinhood launch's stakers cannot be observed on this chain.
- Verbatim page captures keep the em dashes present in the source pages; only the authored files (this README, `LINKS.md`, `contracts/ADDRESSES.md`, `SESSION-NOTES.md`, contract READMEs) are dash-free.
