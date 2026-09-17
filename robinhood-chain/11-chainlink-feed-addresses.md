# Chainlink Price Feed Addresses on Robinhood Chain

> Source of truth: <https://docs.chain.link/data-feeds/price-feeds/addresses?network=robinhood>
> The rendered page is JavaScript-driven; the machine-readable backing file is
> <https://reference-data-directory.vercel.app/feeds-robinhood-mainnet.json> (used here).
> Every proxy below was called on-chain via `latestRoundData()` on 2026-08-12 - all 56 returned a live answer.
> Re-checked 2026-09-02: the directory now lists 57 feeds; the one addition is `CBBTC / USD` (added below, live answer verified). No feed was removed. The Stock Token roster grew to 194, so 159 tokens now have no feed (35 equity feeds unchanged).
> Re-checked 2026-09-03: the directory still lists **57** feeds and all 57 proxy addresses match this file exactly, with none added and none removed since 2026-09-02.
> **Always re-read addresses from Chainlink rather than hardcoding this snapshot.**

---

## How to read a feed

All feeds implement `AggregatorV3Interface`. Read through the **proxy** address, never the aggregator.
Robinhood equity feeds return the **token** price (underlying share price x `uiMultiplier()`), not the raw share price.

```solidity
(, int256 answer, , uint256 updatedAt, ) = AggregatorV3Interface(PROXY).latestRoundData();
require(answer > 0, "bad price");
require(block.timestamp - updatedAt < HEARTBEAT, "stale price");
```

## Robinhood tokenized equity feeds (35)

Market hours `us_equities_24/5`. All 8 decimals, 86400s heartbeat, 0.5% deviation threshold.

| Feed | Proxy | `description()` on-chain | Decimals | Heartbeat | Deviation |
| --- | --- | --- | --- | --- | --- |
| Robinhood AAPL / USD | `0x6B22A786bAa607d76728168703a39Ea9C99f2cD0` | `Robinhood AAPL / USD` | 8 | 86400s | 0.5% |
| Robinhood AMD / USD | `0x943A29E7ae51A4798823ca9eEd2ed533B2A22C72` | `RHAMD / USD` | 8 | 86400s | 0.5% |
| Robinhood AMZN / USD | `0xD5a1508ceD74c084eBf3cBe853e2C968fB2a651C` | `Robinhood AMZN / USD` | 8 | 86400s | 0.5% |
| Robinhood ASML / USD | `0xB4106147E8cce40b7d46124090d373A71b70f87D` | `Robinhood ASML / USD` | 8 | 86400s | 0.5% |
| Robinhood BABA / USD | `0x62Cc8F9b5f56a33c9C8A60c8B92779f523c4E984` | `Robinhood BABA / USD` | 8 | 86400s | 0.5% |
| Robinhood CLSK / USD | `0x810c12D3a554Bc47fd39597Fe3b3AAC4941F50eF` | `Robinhood CLSK / USD` | 8 | 86400s | 0.5% |
| Robinhood COIN / USD | `0xA3a468A452940B7D6b69991207B508c609a98Ef2` | `Robinhood COIN / USD` | 8 | 86400s | 0.5% |
| Robinhood CRCL / USD | `0x6652eDf64bA3731C4F2D3ce821A0Fb1f1f6b482a` | `Robinhood CRCL / USD` | 8 | 86400s | 0.5% |
| Robinhood CRWV / USD | `0xe1b3aABCAFAd1c94708dc1367dcfF8Aa4407487C` | `Robinhood CRWV / USD` | 8 | 86400s | 0.5% |
| Robinhood DELL-USD | `0x1C6c8cADBe02E19129c39dDB92281cE4c0bf206b` | `Robinhood DELL-USD` | 8 | 86400s | 0.5% |
| Robinhood EWY / USD | `0xEFdf54610B62A7753Ec30bDc380847c12D32e1D1` | `Robinhood EWY / USD` | 8 | 86400s | 0.5% |
| Robinhood GME / USD | `0x27C71df6A64fB476468EdF256CF72c038baB5B67` | `Robinhood GME / USD` | 8 | 86400s | 0.5% |
| Robinhood GOOGL / USD | `0xF6f373a037c30F0e5010d854385cA89185AE638b` | `Robinhood GOOGL / USD` | 8 | 86400s | 0.5% |
| Robinhood INTC / USD | `0x3f390C5C24628Ac7C489515402235FeAD71D1913` | `RHINTC / USD` | 8 | 86400s | 0.5% |
| Robinhood IONQ / USD | `0x22EfeC4919baf55F360E0EDee4AbEB26DE4971eb` | `Robinhood IONQ / USD` | 8 | 86400s | 0.5% |
| Robinhood META / USD | `0x7C38C00C30BEe9378381E7B6135d7283356D71b1` | `Robinhood META / USD` | 8 | 86400s | 0.5% |
| Robinhood MSFT / USD | `0x45C3C877C15E6BA2EBB19eA114Ea508d14C1Af2E` | `RHMSFT / USD` | 8 | 86400s | 0.5% |
| Robinhood MSTR / USD | `0x396118bdFB181e6240E74D243F266B061c0edc3D` | `Robinhood MSTR / USD` | 8 | 86400s | 0.5% |
| Robinhood MU / USD | `0x425EEFdCf05ed6526C3cE61Af99429A228a6d596` | `RHMU / USD` | 8 | 86400s | 0.5% |
| Robinhood NBIS / USD | `0xE1D87B116Ba0fe898998f1D140339D1fA1E09705` | `Robinhood NBIS / USD` | 8 | 86400s | 0.5% |
| Robinhood NVDA / USD | `0x379EC4f7C378F34a1B47E4F3cbeBCbAC3E8E9F15` | `RHNVDA / USD` | 8 | 86400s | 0.5% |
| Robinhood ORCL / USD | `0x0e6a64a2B58A6693a531E6c555f3A5d042eEA844` | `Robinhood ORCL / USD` | 8 | 86400s | 0.5% |
| Robinhood PLTR / USD | `0x820ABedFF239034956B7A9d2F0a331f9F075eB4c` | `Robinhood PLTR / USD` | 8 | 86400s | 0.5% |
| Robinhood QQQ / USD | `0x80901d846d5D7B030F26B480776EE3b29374C2ae` | `Robinhood QQQ / USD` | 8 | 86400s | 0.5% |
| Robinhood RGTI / USD | `0x2A045cF1C49c61c166C036d2f06FA2D2d984f765` | `Robinhood RGTI / USD` | 8 | 86400s | 0.5% |
| Robinhood RKLB / USD | `0x045477BF65Aef6f4F2386ad0164579e48381CC74` | `Robinhood RKLB / USD` | 8 | 86400s | 0.5% |
| Robinhood SGOV-USD | `0xa0DF4ee0fFf975306345875E3548Fcc519577A11` | `Robinhood SGOV-USD` | 8 | 86400s | 0.5% |
| Robinhood SLV / USD | `0x209b73908e92Ae021826eD79609845451Ecba2ce` | `Robinhood SLV / USD` | 8 | 86400s | 0.5% |
| Robinhood SNDK / USD | `0xfb133Fa4B7b385802B693a293606682Df47109A3` | `RHSNDK / USD` | 8 | 86400s | 0.5% |
| Robinhood SPCX / USD | `0xB265810950ba6c5C0Ff821c9963014a56fD8Bffb` | `Robinhood SPCX / USD` | 8 | 86400s | 0.5% |
| Robinhood SPY / USD | `0x319724394D3A0e3669269846abE664Cd621f9f6A` | `RHSPY / USD` | 8 | 86400s | 0.5% |
| Robinhood TSLA / USD | `0x4A1166a659A55625345e9515b32adECea5547C38` | `RHTSLA / USD` | 8 | 86400s | 0.5% |
| Robinhood TSM / USD | `0x874cF94aa8eC88Fd9560094dD065f2fB3E41Fc2F` | `Robinhood TSM / USD` | 8 | 86400s | 0.5% |
| Robinhood USAR-USD | `0xA994d3684e8400A6c8078226925779FdeE682DD9` | `Robinhood USAR-USD` | 8 | 86400s | 0.5% |
| Robinhood USO / USD | `0x75a9c76Ef439e2C7c2E5a34Ab105EcFe3766431c` | `RHUSO / USD` | 8 | 86400s | 0.5% |

## Crypto, stablecoin and exchange-rate feeds (22)

| Feed | Proxy | Decimals | Heartbeat | Deviation |
| --- | --- | --- | --- | --- |
| BTC / USD | `0xa2c5184bF03d373Dc9dE4876eb4Bce595B460251` | 8 | 86400s | 0.5% |
| CBBTC / USD | `0x0009cD492adf8167f9eEBf1293556A673530a21a` | 8 | 86400s | 0.5% |
| BTC.B / USD | `0x5BB5e6a17a477d5B6Fec77b4322daD4A66bFb732` | 8 | 86400s | 0.5% |
| ENA / USD | `0x2A291496b3aa19d8948e442Ef28Ee952f3Ee97E8` | 8 | 86400s | 0.5% |
| ETH / USD | `0x78F3556b67E17Df817D51Ef5a990cDaF09E8d3A9` | 8 | 86400s | 0.5% |
| EURC / USD | `0xfF2B10c1973eD10c841434f98e456d8f3a0D7DD8` | 8 | 86400s | 0.5% |
| LBTC / USD | `0xa621344AdAEE699491597Fd8890E0C59a5BFBE59` | 8 | 86400s | 0.5% |
| LINK / USD | `0xe86e3422Aa9B5e8ee9f3E41a63975bC387A8bce9` | 8 | 86400s | 0.5% |
| SYRUPUSDC / USD | `0x8765c3B9Cda41d1029E780D0c1C37C8200DC4675` | 8 | 86400s | 0.5% |
| SYRUPUSDC / USDC Exchange Rate | `0x6317f016FA3e312C4625dee51d32b43a223011f8` | 18 | 86400s | 0.05% |
| SYRUPUSDT / USDT Exchange Rate | `0xBB688c0184Ce03fEdac89D71ccE752Ab21bC2999` | 18 | 86400s | 0.05% |
| USDC / USD | `0x9e6f4605992a899eE2999999F3Ec80C41F452546` | 8 | 86400s | 0.5% |
| USDE / USD | `0xb9fB4e65744E4178894f7C61CF80E8a48A5f224a` | 8 | 86400s | 0.5% |
| USDG / USD | `0x61B7e5650328764B076A108EFF5fa7282a1B9aD2` | 8 | 86400s | 0.5% |
| USDS / USD | `0x2D88D75b625633dCcd65d9d53BfDD3Aea2d8e84f` | 8 | 86400s | 0.5% |
| USDT / USD | `0xbf3550B6fAe1671da7C238Af12e03Ac586BEf3B1` | 8 | 86400s | 0.5% |
| WBTC / USD | `0x62107b0d3adA75fc1697fD342d99eed947a3aA5E` | 8 | 86400s | 0.5% |
| WEETH / EETH Exchange Rate | `0xb63f44E40aA811Cc69Fc55da786a5F3834100B4A` | 18 | 86400s | 0.05% |
| WEETH / USD | `0xf882e1D50352aecB0Ac85378378918BCf40511e7` | 8 | 86400s | 0.5% |
| WSTETH / STETH Exchange Rate | `0x8E3Eb706B170c8FD1DdcD402932D952887736f9A` | 18 | 86400s | 0.05% |
| WSTETH / USD | `0x3F5040B50FB37934573B210fE54B53a6F1A792E8` | 8 | 86400s | 0.5% |
| syrupUSDG / USDG Exchange Rate | `0xDd194C66aDcb422F188a04434e4824D70c151cF0` | 18 | 86400s | 0.05% |

## Notes

- Every feed carries a `secondaryProxyAddress` in the Chainlink directory (the SVR / Smart Value Recapture variant). The `path` values ending `-shared-svr` indicate shared SVR aggregators.
- Only **35 of the 96** active Stock Tokens had a published Chainlink feed at capture time (35 of 194 as of 2026-09-02). The Robinhood docs state that every Stock Token has a live feed; treat that as aspirational and handle a missing feed explicitly.
- Feed observed update ages at capture ranged from ~15 minutes to ~15 hours, well inside the 86400s heartbeat but far from tick-by-tick. For sub-second data use Chainlink Data Streams (see `22-data-streams.md`).
- There is no L2 Sequencer Uptime Feed listed for Robinhood Chain in the Chainlink directory, even though the Robinhood docs recommend checking one. See `24-chainlink-l2-sequencer-feeds.md` and confirm availability with Chainlink before relying on it.
