# Robinhood Chain launchpad market context

Captured 2026-09-02.
This directory holds the discovery pass that was run alongside the per-platform archives: web searches, DefiLlama data, comparison articles, and the news that explains the state of the market.
Everything in `pages/` is a verbatim capture with its source URL.
Everything in `_raw/` is the untouched tool output (Bright Data search JSON, Jina output, DefiLlama API responses).
This file is original writing that synthesizes them.

## Why this matters

The launchpad list in `launchpad-research.md` (10 platforms) is a subset of a much larger and fast-moving field.
DefiLlama tracks 30 protocols in its Launchpad category on Robinhood Chain and 143 fee-earning protocols on the chain overall (`_raw/llama-robinhood-protocols.txt`, `_raw/llama-fees-robinhood.txt`).
Several platforms that were not on the list are larger than several that were.

## Timeline (from the captured sources)

| Date | Event | Source |
| --- | --- | --- |
| 2026-07-01 | Uniswap announces it is the primary public AMM on Robinhood Chain from day one | `pages/03-bankless-uniswap.md` |
| early July | NOXA Fun dominates launches (about 75% of all deployments, 60,000+ tokens, $12M+ protocol fees); CASHCAT peaks above $200M market cap on July 11 | `pages/17-odaily-noxa.md`, `pages/18-pons-v2-news.md` |
| 2026-07-11 | NOXA pauses new token launches citing spam and copycat bots; its domains go down | `pages/17-odaily-noxa.md`, `pages/15-noxa-halt-x.md` |
| 2026-07-13 | Uniswap Continuous Clearing Auctions (CCA) go live on Robinhood Chain | `pages/17-odaily-noxa.md` |
| 2026-07-14 | NOXA relaunches a static ENS/IPFS interface at fun.noxa.eth (eth.limo) with launches permanently disabled and 100% of trading fees to creators | `pages/15-noxa-halt-x.md` |
| 2026-07-22 | **NOXA quietly deploys a second launch factory** `0xDd84fDdE...` and resumes launching at fun.noxa.fi; 1,090 launches through it by 2026-09-03. This contradicts the "permanently disabled" line above, which holds only for the V1 factory | `launchpads/noxa/README.md` |
| 2026-07-15 | Pons passes Flap as the launchpad with the most tokens deployed; ranking was Pons, Flap, hood.fun (a week earlier: NOXA, Doppler/Bankr, Virtuals) | `pages/22-tomwan-x.md` |
| 2026-07-23 | Pons announces V2: ETH bonding curve, Uniswap v4 hook, ETH creator payouts, RWA quote pairs, 4.2 ETH graduation, 3-day timelock CTO | `pages/18-pons-v2-news.md` |
| late July | Uniswap adds a "Launches" tab (beta, Robinhood Chain only) aggregating Bankr, Pons, Long and others; 340,000+ tokens launched into Uniswap pools, $3.6B launchpad volume | `pages/03-bankless-uniswap.md`, `pages/26-uniswap-aggregator.md` |
| 2026-08-05 | Pools.trade launches (described by TrustSwap as built by Uniswap Labs) | `pages/23-trustswap-compared.md` |
| mid August | "pools fun" goes live with no bonding curve, direct SushiSwap V3 pools, PartyFactory `0x626C3d09B65bF5d1D40E0D5F25e19fa49783B3D4`, 2,439 tokens on day one | `pages/19-reddit-nobonding.md` |
| 2026-09-02 | Pons V2 is the largest fee earner among launchpads (see table below) | `_raw/llama-fees-robinhood.txt` |

Robinhood Chain 7-day meme DEX volume was $6.0B against Solana's $7.9B, with a much higher average trade size ($171.9 vs $58.1) per the Dune "Meme Trading Battlefield" dashboard (`pages/13-dune-meme-battlefield.md`).

## Launchpad fees on Robinhood Chain (DefiLlama, USD, captured 2026-09-02)

Source: `_raw/llama-fees-robinhood.json`, chain-filtered fees overview.
Only rows in the Launchpad category plus the platforms on the user's list are shown.

| Protocol | 24h | 7d | 30d | All time | On user's list |
| --- | --- | --- | --- | --- | --- |
| Pons V2 | 4,221,588 | 21,826,857 | 26,939,684 | 26,939,684 | yes (5.x) |
| Pons V1 | 335,884 | 2,533,267 | 8,300,755 | 23,887,250 | yes (5.x) |
| NOXA Fun | 142,924 | 933,642 | 4,069,455 | 20,894,770 | yes (10.x), launches disabled |
| StonkBrokers | 32,076 | 192,563 | 2,542,956 | 3,490,561 | no |
| LetsCash | 40,841 | 454,683 | 1,613,786 | 1,970,583 | no |
| Pools | 32,451 | 260,828 | 1,514,075 | 1,546,609 | yes (7.x) |
| o1 Launchpad | 463,085 | 622,239 | 656,777 | 1,164,955 | no |
| Flap sh | 9,177 | 58,950 | 179,570 | 1,077,783 | yes (6.x) |
| Bags | 22,155 | 66,882 | 203,850 | 585,729 | no, archived in `../bags/` |
| Virtuals Protocol (AI Agents category) | 27,497 | 150,634 | 438,465 | 2,556,217 | yes (9.x) |
| bow.fun | 458 | 3,142 | 31,264 | 431,612 | no |
| Coinbarrel | 10,498 | 108,291 | 124,515 | 164,216 | no |
| token.select | 2,804 | 48,093 | 101,970 | 104,774 | no |
| Sentry | 4,698 | 49,243 | 75,790 | 102,063 | yes (3.x) |
| PAIR | 22,522 | 24,987 | 24,987 | 47,509 | no |
| basedbid | 1,063 | 4,238 | 12,142 | 23,207 | no |
| Hookers | 819 | 7,013 | 10,697 | 10,697 | no |
| RH.fun | 0 | 1 | 188 | 7,678 | no |
| Based Alpha | 0 | 0 | 3 | 5,919 | no |
| Frontier | 55 | 2,000 | 3,094 | 3,867 | no |

Long, Doppler, hood.fun and HOOD10 do not appear as fee-tracked launchpads on DefiLlama for this chain, so their activity must be read from their own archives and on-chain data.

## Full catalog of launchpads found on Robinhood Chain

"List" marks platforms in `launchpad-research.md`.
Mechanism text is from the cited source, not verified here; the per-platform archives verify the listed ones.

| Platform | Site | X | Mechanism (per source) | List | Source |
| --- | --- | --- | --- | --- | --- |
| Long | app.long.xyz | @longdotxyz | see `../long/` | yes | user list |
| Doppler | app.doppler.lol | @dopplerprotocol | Uniswap v4 hook auctions, protocol used by Bankr and others | yes | `../doppler/` |
| Sentry | sentry.trading | @sentrylauncher | one-click ERC-20 with Uniswap V3 pool seeded at launch, LP permanently locked; also on Ink | yes | `_raw/llama-sentry.json` |
| HOOD10 | hood10.xyz | | index token plus launchpad | yes | `../hood10/` |
| Pons | ponsfamily.com | @ponsdotfamily | V1: launch into Uniswap V3; V2: ETH bonding curve, 4.2 ETH graduation, Uniswap v4 hook, ETH payouts, RWA quote pairs | yes | `pages/18-pons-v2-news.md` |
| Flap | flap.sh | @flapdotsh | bonding curve launchpad, multi-chain | yes | `pages/22-tomwan-x.md` |
| Pools.trade | pools.trade | | Uniswap Labs launch flow, immediate Uniswap depth (TrustSwap claim) | yes | `pages/23-trustswap-compared.md` |
| hood.fun | hood.fun | @hooddotfun | pump.fun-style bonding curve, V3 migration and permanent lock, no creation fee | yes | `pages/06-bitcoinfoundation-best.md` |
| Virtuals Protocol | virtuals.io | @virtuals_io | AI agent launchpad, bonding curve to graduation | yes | `../virtuals/` |
| NOXA Fun | fun.noxa.fi, fun.noxa.eth.limo | @Noxa_Fi, @NoxaLaunchpad | direct Uniswap V3 single-sided LP, no curve; V1 disabled since 2026-07-11, but a V2 factory has been **live since 2026-07-22** | yes, archived 2026-09-03 | `launchpads/noxa/README.md`, `pages/17-odaily-noxa.md` |
| Bags | bags.fm | | on-chain BagsFactory, x*y=k curve 830M/170M, 2% fee, graduates to Uniswap v4 with hook, 0.02 ETH creation fee | no | `pages/02-bags-robinhood.md`, `../bags/` |
| Uniswap Auctions (CCA) | app.uniswap.org/liquidity/launch-auction | @UniswapAuctions | continuous clearing auction, fixed 1B supply, proceeds into Uniswap v4 pool with vested LP | no | `pages/27-uniswap-cca-x.md`, `resources/uniswap/liquidity/liquidity-launchpad/` |
| Bankr | bankr.bot | @bankrbot | Doppler-based, v4 hook splits fees among creator, locked liquidity, protocol, BNKR buybacks, Doppler | no | `pages/03-bankless-uniswap.md` |
| Clanker | clanker.world | | mentioned as active daily deployer on Dune | no | `pages/17-odaily-noxa.md`, `pages/09-bitrue-best.md` |
| StonkBrokers | stonkbrokers.cash | @ClutchMarkets | DeFi suite: launches, swaps, NFT AMM, covered calls | no | `_raw/llama-stonkbrokers.json` |
| LetsCash | | | launchpad, second largest 30d fees after Pons | no | `_raw/llama-fees-robinhood.txt` |
| o1 Launchpad | | | launchpad, large 24h fees on capture date | no | `_raw/llama-fees-robinhood.txt` |
| pools fun (PartyFactory) | | | no bonding curve, direct SushiSwap V3 pools, 25% of fees buy and burn top 3 tokens daily | no | `pages/19-reddit-nobonding.md` |
| Coinbarrel | | @UseCoinbarrel | launchpad | no | `_raw/llama-coinbarrel.json` |
| token.select | token.select | @selectfdn | fixed price contributor funding, migrates into Uniswap | no | `_raw/llama-token.select.json` |
| basedbid | | @basedbidx | multi-chain bonding curves, Flash Tokens, white-label Boards | no | `_raw/llama-basedbid.json` |
| Frontier | | @frontierhood | shared bonding curve, graduates to Uniswap V4 | no | `_raw/llama-frontier.json` |
| Boardwalk | useboardwalk.com | @useboardwalk | fee-protection launch protocol, multi-chain | no | `_raw/llama-boardwalk.json` |
| DexLaunch | | @dexlaunchfun | fixed-price presales plus bonding curves | no | `_raw/llama-dexlaunch.json` |
| RaiseHood | raisehood.xyz | @RaiseHood | fixed-price presales paired with ETH, USDG or stock tokens, auto-seeds locked V3 liquidity | no | `_raw/llama-raisehood.json` |
| Based Alpha | alpha.based.one | @BasedOneX | pump.fun-style | no | `_raw/llama-based-alpha.json` |
| Unihood | | @unihoodotfun | full 1B supply as single-sided Uniswap V4 liquidity from launch | no | `_raw/llama-unihood.json` |
| Mixpad | | @mixpadfun | Uniswap V4 hook-based launchpad | no | `_raw/llama-mixpad.json` |
| HoodMint | | @HoodMintFun | pump.fun-style curve, locked liquidity on graduation | no | `_raw/llama-hoodmint.json` |
| RH.fun | | @RHdotfun | bonding curve, graduates to Uniswap V2 | no | `_raw/llama-rh.fun.json` |
| Peeps | | @peepsdotwtf | bonding curve to locked Uniswap V3 | no | `_raw/llama-peeps.json` |
| MerryForge | | @merryforge | fair launches, creator bonds, locked liquidity | no | `_raw/llama-merryforge.json` |
| popi | | @popiwtf | gacha bonding curve, Solana and Robinhood | no | `_raw/llama-popi.json` |
| ArrowPad.fun, ArrowPad, RobinFun, keep.coffee, DOTT, HoodPump, H00D, ymym.meme, BlueFun, BowYard, AvaLove, LuckyLaunch | | | small launchpads with near-zero fees | no | `_raw/llama-robinhood-protocols.txt` |
| Openfair | | | bonding curve or instant listing, 0.0005 ETH creation, permanent V3 lock (ranked "best overall" by one article) | no | `pages/06-bitcoinfoundation-best.md` |
| RobinPad | | | direct-to-DEX fair launch, permanent V3 lock | no | `pages/06-bitcoinfoundation-best.md` |
| Trench (trensh.today), Bow (bow.fun), The Arena, Circus, Memecoin.fun, CASHCAT community pad, TrustSwap Launchpad (vetted raise) | | | mentioned as competitors | no | `pages/18-pons-v2-news.md`, `pages/09-bitrue-best.md`, `pages/14-memecoinfun-dealroom.md`, `pages/23-trustswap-compared.md` |

## Observations for the platform decision

- The fee data says Pons V2 is where the volume is right now, by an order of magnitude over the next launchpad.
- **Corrected 2026-09-03: NOXA can be launched on.** The read-only ENS snapshot is real but covers only the V1 factory; a V2 factory shipped 2026-07-22 and `fun.noxa.fi` is back on the conventional domain with a working create form, a 0 launch fee and 100 percent of trading fees to the creator. See `launchpads/noxa/README.md`.
- Uniswap's own two routes (CCA auctions for fair price discovery, and the Launches aggregator for distribution) are official and documented in `resources/uniswap/liquidity/liquidity-launchpad/`.
- Bags is the most developer-friendly documented option found: every contract address, fee and event is published and the flow is fully on-chain with no API key.
- Several launchpads let a token be paired against a stock token or USDG instead of ETH (Pons V2, RaiseHood), which is unique to this chain.
- Launchpad risk is real: NOXA's front end disappeared with liquidity intact but launches gone, so prefer platforms whose contracts are verified and whose liquidity is locked on-chain.
  The follow-up is that it came back on a new factory whose owner key has no on-chain link to the original team, which is its own kind of risk.

## Files

- `pages/` 27 verbatim captures.
- `_raw/search-*.json` six Bright Data Google searches.
- `_raw/llama-*.json` DefiLlama protocol metadata for the 20 Launchpad-category protocols listed on the DefiLlama page, plus `llama-fees-robinhood.json` (chain fee overview) and `llama-robinhood-protocols.txt` (all 134 protocols on the chain).
- `_raw/page-*.md` raw Jina output including link summaries.
