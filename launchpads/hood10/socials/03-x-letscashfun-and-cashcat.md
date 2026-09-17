# HOOD10 - letscash.fun and CASHCAT, and how they relate to HOOD10

> Source: https://x.com/letscashfun and https://letscash.fun/
> Retrieved: 2026-09-02 (X syndication endpoint, raw in `_raw/x/syndication-letscashfun.json`; site reads in `_raw/jina-letscash-*.md`)

---

## Why this file is in the HOOD10 archive

`SCRAPING-PLAN.md` section 5.8 notes CashCat contracts in the archive and asks the README to state the relationship with evidence.
The relationship is not shared launchpad infrastructure.
It is one fact: **the HOOD10 index token was launched on letscash.fun, and the HOOD10 Launchpad is separate, later, and independently written code.**

Evidence, in order of strength:

1. `HOOD10` at `0x0D257cA40d40090BE60C2d2Ed5bB3535392838cc` is an EIP-1167 clone whose 45-byte stub embeds `0xd6Da7f07eE822C8538C901217b37D1e7d86c76E5`, the verified `CashCatTokenV2` master, and whose creator is the CashCat factory proxy `0x5bd1Fbe78a78fe8236fa00CF48fbEBA74ae34661` (`_raw/blockscout/address-hood10.json`).
2. `HOOD10.hook()` returns `CashCatHookV2` `0x75A54357D9C78a2Db19004a5FDc76c50F9242AEC`, and that hook returns `currentFeeRate` = 50000 pips for HOOD10's pool: the 5% index tax is charged by CashCat's engine, not by anything HOOD10 wrote (`_raw/rpc/hood10-token-state.txt`).
3. The HOOD10 docs' own tax table lists a `0.30%` wedge going to a "letscash.fun platform fee" (`pages/02-docs.md`).
4. `letscash.fun/token/0x0D257cA4...` renders the HOOD10 token page with a live trade feed, so the index still trades as a letscash listing (`_raw/jina-letscash-token-hood10.md`).
5. Nothing runs the other way. `LaunchFactory`, `LaunchHook`, `QuoteRegistry`, `FeeRouter` and `DividendDeployer` reference no CashCat address, and the CashCat factory references no HOOD10 address. The only thing the two stacks share is the chain's single Uniswap v4 `PoolManager` `0x8366a39C...`.

The HOOD10 `QuoteRegistry` natspec is the clearest statement of the relationship from the HOOD10 side, and it is a competitive one:

> This is deliberately NOT an allowlist. The incumbent pad on this chain restricts launches to "an approved ERC-20"; letting a creator denominate a pool in literally anything is the product.

`approvedQuote(address)` is a real selector in the CashCat factory's current implementation (`contracts/CashCatFactory-current-impl-unverified-0x40250b4C73FC30f8F6ad077744B0124B3f111C28/README.md`), so "the incumbent pad" is letscash.fun.

## The letscash.fun account

| field | value |
| --- | --- |
| Display name | letscash.fun |
| Handle | @letscashfun |
| Bio | custom launchpad on robinhood, built on uniswap v4. |
| Created | Thu Jul 09 15:54:29 +0000 2026 |
| Followers | 6097 |
| Statuses | 15 |
| Website | https://www.letscash.fun/ |

## Live CashCat state at capture

From `_raw/rpc/cashcat-state.txt`:

| read | value |
| --- | --- |
| `launchFee()` | 500000000000000 wei, 0.0005 ETH |
| `launchEnabled()` | true |
| `owner()` | `0xd2DEfBd13aFF22d6989e8C14b4517eC308079e91` |
| `treasury()` | `0x67cCBFb238047d62736265B3093a5989836794b0` |
| `nextConfigId()` | 1064 |
| `MODULE_GENERATION()` | 2 |
| EIP-1967 implementation | `0x40250b4C73FC30f8F6ad077744B0124B3f111C28`, unverified |

HOOD10's pad charges no launch fee at all, so 0.0005 ETH is the fee HOOD10 undercut.

## Timeline as captured

Fifteen entries came back from the syndication endpoint.
The ones that bear on the comparison:

- **Wed Jul 29 20:56:04 +0000 2026** - https://t.co/9deVJISnM8
- **Sat Aug 29 05:21:28 +0000 2026** - For creators this means you can now set your token supply to any whole number between 1 billion and 1 quadrillion.  Enjoy.  https://t.co/HoVtNQw8az https://t.co/Kngkruh7Bj
- **Sat Aug 29 05:09:03 +0000 2026** - A quick technical update:  Supply is now a range, not a menu. Launch any whole number of tokens between 1B and 1Qa.  Integrating? SDK is now on 0.4.0, so please update. Every function signature has changed, so anything pinned to 0.2.1 will revert.  https://t.co/pfNmHbQ1dT
- **Thu Aug 27 14:38:31 +0000 2026** - Meet @letscashradar:  a spotlight directed at projects demonstrating strong performance, technical innovation, and fast growing communities  stay tuned for radar pings
- **Wed Aug 26 23:16:40 +0000 2026** - Introducing the airdropper. First of its kind on this chain.  A bespoke contract that pushes tokens to hundreds of thousands of wallets in minutes. No extra fee, and as always... permissionless.  Live now, first, via the launch flow.  Learn more: https://t.co/vjjJhLFEAP  Thank https://t.co/Jqxs1pwxS0
- **Thu Aug 20 02:15:11 +0000 2026** - Fee streams are a first class asset, something you can toy with and point anywhere:  Your wallet, someone else's, a contract, split 4 ways with customisable shares, straight into buy and burn, handed off entirely later, or claimed to a different address without giving up
- **Wed Aug 19 22:48:43 +0000 2026** - Indices is now live on https://t.co/GYuxi1kDzH  Point your fee recipient at an indices treasury and every trade starts buying a basket of assets for your holders.  No migration, no new contract, coins already launched can repoint today.
- **Thu Aug 13 16:33:55 +0000 2026** - Today we are introducing Letscash Rooms  Every token gets it's own room alongside the global lounge, where holders, creators and spectators can communicate and call home.  We’re also launching our new profile and ranking system, making it easier to discover and connect with https://t.co/3op5CFoAYD
- **Tue Aug 11 01:37:23 +0000 2026** - oh and one more thing  you can now launch with 10billion supply instead of just 1billion  live now https://t.co/lwDPuYIBCB
- **Tue Aug 11 01:31:49 +0000 2026** - The official letscash SDK is now available.  The whole protocol behind one interface, typed, so building on letscash doesn't start with reverse engineering it.  Built for projects launching on letscash, capable of launching, trading, handling fees and everything inbetween.  We're
- **Thu Aug 06 00:00:53 +0000 2026** - Our first round of updates on https://t.co/n42mnvqUKq are live.  - Fees are now adjustable from 1-10%, platform fee stays fixed at 0.3%.  - Tokens can now be quoted against $USDG instead of just $ETH.  - Creators can choose a different wallet to receive the fee stream before https://t.co/PvLlasV3uJ
- **Wed Aug 05 23:39:22 +0000 2026** - 15 minutes https://t.co/FWEuvr9j1v
- **Sat Aug 01 13:25:28 +0000 2026** - Part of the reason @letscashfun took a few weeks to go online was because we were very strict about the security audit progression, and strategic decision to deploy using @uniswap v4 from the jump.  Execution speed versus risk mitigation is a real cost/benefit tradeoff.  In this
- **Tue Jul 28 22:56:48 +0000 2026** - RT @cashcat_token: In light of the launchpad commotion throughout the first few weeks of @RobinhoodCrypto the Cash Cat community came toget…
- **Tue Jul 28 22:36:30 +0000 2026** - cash is king  https://t.co/Rd5FYLgPbP https://t.co/N80kSe2077

Note the 2026-08-29 pair: letscash moved supply from a fixed menu to any whole number between 1B and 1Qa on the same day HOOD10's pad opened with a four-option supply menu.

