# Pools.trade link inventory

Captured 2026-09-02 and 2026-09-03.
Sources: `agent-browser` accessibility snapshots of the home page, the create modal and two token pages; the shipped React Router manifest; the home page network capture; and the off-platform pages the site links to.

`pools.trade` is a single-page app with only five real routes (`/`, `/create`, `/t/:address`, `/portfolio`, `/teaser`) plus an OAuth callback.
The overwhelming majority of links on the site are token pages, which all render from one template.
Every one discovered in a snapshot is listed below; the template itself is captured twice, once for an Instant Launch token and once for a live Crowd Launch.

| found on | link text | href | type | captured as |
| --- | --- | --- | --- | --- |
| every page | Pools home | <https://pools.trade/> | internal route | pages/01-home.md |
| every page | Launch (create modal) | <https://pools.trade/create> | internal route | pages/02-create-launch-model.md, pages/04 to pages/07 |
| every page | Uniswap web app | <https://app.uniswap.org/> | external | not captured, Uniswap product page outside this platform |
| every page footer | Terms of Service | <https://uniswap.org/terms-of-service> | external, legal | not captured, Uniswap Labs terms |
| every page footer | Privacy Policy | <https://uniswap.org/privacy-policy> | external, legal | not captured, Uniswap Labs policy |
| token page trade panel | Learn more (support guide) | <https://support.uniswap.org/hc/en-us/articles/47943121516685-Launching-and-trading-tokens-on-pools-trade> | external, docs | pages/15-uniswap-support-guide.md |
| create review step | Learn more (fully configurable CCA) | <https://app.uniswap.org/liquidity/launch-auction> | external | not captured, Uniswap CCA launch page already documented in resources/uniswap/liquidity/liquidity-launchpad/ |
| home nav | Portfolio (wallet menu) | <https://pools.trade/portfolio> | internal route | pages/10-portfolio.md |
| React Router manifest | Teaser splash | <https://pools.trade/teaser> | internal route | pages/11-teaser.md |
| React Router manifest | X OAuth callback | <https://pools.trade/liquidity/launch-auction/x/callback> | internal route | not captured, OAuth callback with no standalone view |
| page head | Open Graph image | <https://pools.trade/opengraph.png> | asset | not captured |
| page head | Web app manifest | <https://pools.trade/manifest.webmanifest> | asset | pages/12-robots-and-manifest.md, _raw/site/manifest.webmanifest |
| crawler | robots.txt | <https://pools.trade/robots.txt> | asset | pages/12-robots-and-manifest.md, _raw/site/robots.txt |
| twitter card meta | @TradePools | <https://x.com/TradePools> | external, social | socials/01-x-tradepools.md |
| portfolio page | Manage (opens Uniswap portfolio) | <https://app.uniswap.org/positions> | external | not captured |
| token page | Opens this token on the Uniswap web app | <https://app.uniswap.org/explore/tokens/robinhood/<address>> | external, template | not captured, template recovered from _raw/js/useCreatorFeeExecutor-44W_DATt.js |
| network capture | tRPC router | <https://pools.trade/api/trpc/*> | backend api | pages/13-backend-api.md, _raw/api/, _raw/network-home.json |
| network capture | Uniswap platform service proxy | <https://pools.trade/entry-gateway/*> | backend api | pages/13-backend-api.md, _raw/api/, _raw/network-home.json |
| network capture | Amplitude proxy | <https://pools.trade/amplitude-proxy> | backend api | pages/13-backend-api.md, _raw/api/, _raw/network-home.json |
| network capture | token image renderer | <https://pools.trade/api/image/token/:address> | backend api | pages/13-backend-api.md, _raw/api/, _raw/network-home.json |
| network capture | CSP report sink | <https://pools.trade/api/csp-report> | backend api | pages/13-backend-api.md, _raw/api/, _raw/network-home.json |
| network capture | React Router route manifest | <https://pools.trade/__manifest> | backend api | pages/13-backend-api.md, _raw/api/, _raw/network-home.json |
| network capture | Datadog RUM intake | <https://browser-intake-datadoghq.com/api/v2/rum> | external, telemetry | _raw/network-home.json |
| Uniswap blog | Pools.trade: A New Way to Launch on Robinhood Chain | <https://blog.uniswap.org/pools-trade-a-new-way-to-launch-on-robinhood-chain> | external, announcement | pages/16-uniswap-blog-launch-post.md |
| support guide | What are Continuous Clearing Auctions? | <https://support.uniswap.org/hc/en-us/articles/43107626487437> | external, docs | _raw/jina/support.uniswap.org-hc-en-us-articles-43107626487437.md |
| support guide | Technical documentation on the Uniswap Liquidity Launchpad | <https://docs.uniswap.org/contracts/liquidity-launchpad/Overview> | external, docs | already archived at resources/uniswap/liquidity/liquidity-launchpad/ |
| support guide | What is a network cost? | <https://support.uniswap.org/hc/en-us/articles/8370337377805> | external, docs | not captured |
| blog post | Uniswap Launches aggregator | <https://app.uniswap.org/launches> | external | not captured |
| blog post | Uniswap Wallet | <https://wallet.uniswap.org/> | external | not captured |
| blog post | Uniswap docs | <https://docs.uniswap.org/> | external, docs | partly archived at resources/uniswap/ |
| deployments cross-check | Uniswap unified deployments feed | <https://developers.uniswap.org/deployments.json> | external, data | _raw/leads/uniswap-deployments.json |
| deployments cross-check | Liquidity Launchpad deployments page | <https://developers.uniswap.org/docs/liquidity/liquidity-launchpad/deployments> | external, docs | already archived at resources/uniswap/liquidity/liquidity-launchpad/deployments.md |
| market context | DefiLlama protocol record, slug pools | <https://api.llama.fi/protocol/pools> | external, data | socials/03-defillama-pools.md, _raw/leads/defillama-protocol-pools.json |
| market context | DefiLlama fee summary, slug pools | <https://api.llama.fi/summary/fees/pools> | external, data | socials/03-defillama-pools.md, _raw/leads/defillama-fees-pools.json |
| X announcements | @Uniswap launch post | <https://x.com/Uniswap/status/2085136053661213180> | external, social | socials/02-x-uniswap-launch-announcements.md |
| X announcements | @Uniswap follow post | <https://x.com/Uniswap/status/2085136062997754217> | external, social | socials/02-x-uniswap-launch-announcements.md |
| X announcements | @Uniswap "Pools." | <https://x.com/Uniswap/status/2085401598377836865> | external, social | socials/02-x-uniswap-launch-announcements.md |
| X announcements | @Uniswap reply | <https://x.com/Uniswap/status/2088304171984318937> | external, social | socials/02-x-uniswap-launch-announcements.md |
| X announcements | @Uniswap feature list | <https://x.com/Uniswap/status/2092935558993485997> | external, social | socials/02-x-uniswap-launch-announcements.md |
| X announcements | @haydenzadams launch thread | <https://x.com/haydenzadams/status/2085141263310102935> | external, social | socials/02-x-uniswap-launch-announcements.md |
| X announcements | @haydenzadams Binance wallet post | <https://x.com/haydenzadams/status/2087920502559887431> | external, social | socials/02-x-uniswap-launch-announcements.md |
| @TradePools timeline | Pinned "Hello world" | <https://x.com/TradePools/status/2085136370134134831> | external, social | socials/01-x-tradepools.md |
| @TradePools timeline | "we are so back" | <https://x.com/TradePools/status/2090138616672718932> | external, social | socials/01-x-tradepools.md |
| @TradePools timeline | media post | <https://x.com/TradePools/status/2092336773233811775> | external, social | socials/01-x-tradepools.md |
| lead resolution | Reddit: launchpad with no bonding curve (pools.fun, not this platform) | <https://www.reddit.com/r/defi/comments/1vpq3ux/a_launchpad_with_no_bonding_curve_did_52m_volume/> | external, market | _market/pages/19-reddit-nobonding.md, refuted in pages/14 |
| lead resolution | TrustSwap comparison page | <https://trustswap.com/robinhood/launchpads-compared> | external, market | _market/pages/23-trustswap-compared.md, claim confirmed in README section 2 |
| chain explorer | Blockscout address pages for every contract | <https://robinhoodchain.blockscout.com/address/<address>> | external, explorer | contracts/*/metadata.json, _raw/blockscout/ |
| home discovery feed | 12h @Ponkmemecoin Buy PONK PONK FDV $6.2K down 80.4% | <https://pools.trade/t/0x7057759C776024937fDBA4Dbeb4C6af83139868C> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 12h Buy DOGE-1 DOGE-1 FDV $6.1K down 0.1% | <https://pools.trade/t/0x8d447508632E9aA71730BbeAe8dD477326a62DBE> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 13h Buy KITSU KitsuCoin FDV $6.4K down 0.3% | <https://pools.trade/t/0xc5FbA74E083fa0c8163D870ca49245758a552e14> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 13h Buy StupidFish StupidFish FDV $6.1K down 0.2% | <https://pools.trade/t/0x87Ae6B44fCe35030E08929eb9c7Bb36CAEbE2f65> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 13h Buy gasless gasless coin FDV $6.1K down 0.2% | <https://pools.trade/t/0x422A245c89C65dBbd5Ed4ae3E23F2B3b74f9eFdb> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 14h Buy $1 Trump $1 Coin FDV $6.1K down 94.8% | <https://pools.trade/t/0x495CFFADa40D0FEbA1B43ea2812E0fB6a10ED51E> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 14h Buy IOO Initial Onchain Offering FDV $6.1K up 0.3% | <https://pools.trade/t/0xcE982651C0c3a2C23320AAdA9b74FF6194c9EBAD> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 14h Buy PumpCity PumpCity FDV $6.1K up 0.9% | <https://pools.trade/t/0x95665847495EEbBcC8bb063Cc0Ab8f6A94520247> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 15h Buy HOOD The Hood FDV $6.1K down 79.8% | <https://pools.trade/t/0xD8C32FAB3ab49349C5aCA5CCBf2E417B5683833C> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 15h Buy PROPPED Propped FDV $6.1K up 1.0% | <https://pools.trade/t/0x1B906De7a9A9f293A0Fc3f9436f379F99aAdEF7d> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 15h Buy SPDR SPY Mascot FDV $6.1K up 0.6% | <https://pools.trade/t/0x38e42B7e7dd54Ae14eD0136E495f90E80eEA34AF> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 16d Buy PROLOGUE Prologue FDV $9.3M up 69.2% 24H volume $6.4M Holders 7,330 | <https://pools.trade/t/0xb9972CA7188e511174947E3936a5315ac7073277> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 16h Buy MEOW AMD FDV $6.1K up 0.8% | <https://pools.trade/t/0xABA4fdEb3EbB95D10317ad15D3b3Fc74306C15E5> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 16h Buy POINTLESS Pointless Coin FDV $6.1K up 1.0% | <https://pools.trade/t/0xd379Bc26ddE289daD06189386a592e66FBfD876b> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 16h Buy SPCE Seraphim New Space Index FDV $6.1K down 84.8% | <https://pools.trade/t/0xDAfc278A437aA7ef9233150Fb958246DcFe693b0> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 16h Buy SPCE Seraphim New Space UCITS ETF FDV $6.1K up 1.0% | <https://pools.trade/t/0x124c2cdC73a42a71bC55eA403e9D39Ffda6CceE2> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 17h Buy ASTRONAUT Astronaut FDV $6.1K up 0.7% | <https://pools.trade/t/0xAda8e0204649036e7ddD1fC8A85772AC7547828b> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 17h Buy BALLSACK Farty Ballsack FDV $10.9K up 83.4% | <https://pools.trade/t/0x776c906dB487CF57a523eB232A36BB244B3138D2> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 17h Buy BLOW BLOWING FDV $6.2K up 0.6% | <https://pools.trade/t/0x997232904F6D2477E945A1cEF23300Dff19C8bef> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 17h Buy INF INFINTY FDV $6.1K up 0.6% | <https://pools.trade/t/0x218709880E49C84f71949412D55C59aBad7e658B> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 17h Buy INF INFINTY FDV $6.1K up 0.7% | <https://pools.trade/t/0x701DDB3F764672dEb16F486827fDb18206656dFC> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 17h Buy PGPU picoGPU FDV $6.1K up 0.7% | <https://pools.trade/t/0xECfD74b3E92a33EC6a2be3c52b02a53A1a5db513> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 18h Buy ONR ME ON R FDV $6.1K down 0.0% | <https://pools.trade/t/0xD0adA1ed06c868160D333800D62e2A7ee090AA71> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 19d Buy SNOW SnowOn Crowd Launch FDV $261.2K up 22.3% 24H volume $76.9K Holders 481 | <https://pools.trade/t/0xb851CeBcBcf1Dc5F07D9F0a8276caE8D953B3713> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 19h Buy GAMEON GameOn FDV $6.1K down 1.0% | <https://pools.trade/t/0xed993a115C6614793d7bCF7E85c9C6539B0277A6> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 19h Buy OLLIE Ollie the Otter FDV $6.1K down 87.3% | <https://pools.trade/t/0xa7e967A11A0E8BA5b21504ADBe83969B30D391a1> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 1h Buy PVP Player vs Player FDV $6.1K up 0.2% | <https://pools.trade/t/0x96d5A4548D4C1865b7A723271138a12a47E0CC38> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 20h Buy KABOSU KABOSU FDV $6.1K down 1.2% | <https://pools.trade/t/0x8C82a520851A58CE8c4a3376E52cAed0C6d01Cef> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 20h Buy RI Robot Inu FDV $6.1K down 89.8% | <https://pools.trade/t/0x00Bd0C841423708698eb6d5A86225FD0E03a9BCA> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 20h Buy VVO VVO FDV $6.1K down 1.2% | <https://pools.trade/t/0x5E1F0B8ef4208453882DF54821CA7C961e5111dC> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 25d Buy LOGOS LogosLayer FDV $1.6M up 27.5% 24H volume $224.4K Holders 572 | <https://pools.trade/t/0x8C63B6adFb469Bbd0cD5d6EE64F73407f15f4c6c> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 26d Buy 222 divinely protected FDV $198.2K up 93.8% 24H volume $158.1K Holders 1,321 | <https://pools.trade/t/0x21Ed792De0Ebfa85c2f55FF45b2241C576727f7B> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 27d Buy HOOKR Hookr.fun FDV $12.7M down 3.9% 24H volume $3.6M Holders 5,360 | <https://pools.trade/t/0x18E674231A58c239Dc7DaeDcffE15Ec3A24cff5c> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 28d @LitecoinMaxiMan Buy UNICORN Unicorn FDV $27.2K up 49.0% | <https://pools.trade/t/0xfEACeF09BE172634Bd8CADc2429b92EB4ed73799> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 28d Buy FROGE FROGE Crowd Launch FDV $183.5K down 4.5% 24H volume $177.3K Holders 2,752 | <https://pools.trade/t/0x1dF1F09c4Dd65C76746d53467361D536cDfDC719> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 28d Buy GOAT Absolute Goat Crowd Launch FDV $177.3K down 1.2% 24H volume $827.59 Holders 6,372 | <https://pools.trade/t/0x6e9aCBFbdD8b57649ffeAcEa4D26A81aE1395367> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 28d Buy PAWSINU UNISWAP FDV $27.7K up 13.5% | <https://pools.trade/t/0xbCC948e70F1d5DCDC8986147257bf4b6C40105f1> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 28d Buy PosM Possum FDV $185.9K up 54.1% 24H volume $153.9K Holders 1,603 | <https://pools.trade/t/0x658bF542C9384dC000A07540B0B29Ef7E79fe126> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 28d Buy SOCKS UNISOCKS FDV $38.8K up 25.5% | <https://pools.trade/t/0xc3a220648569972F1C101956032ea8f220767547> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 28d Buy UNIPEG Unicorn Pegasus FDV $258.4K up 79.6% 24H volume $487.5K Holders 1,943 | <https://pools.trade/t/0xD3D5bE6558F84e628EE091B511Df92b4e461a53b> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 29d Buy inu inu FDV $57.1K down 4.6% | <https://pools.trade/t/0xb9F89a5a075CC280362C5167c5E95723BB2c8caD> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 29d Buy swappy swappy FDV $693.6K up 24.1% 24H volume $250.9K Holders 2,123 | <https://pools.trade/t/0x298348d5b2e45C774E3ee4f1a0924071DfbDC8C7> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 2d Buy EVP EVP FDV $560.2K up 15.5% 24H volume $187.2K Holders 638 | <https://pools.trade/t/0x8dCb5663BC2149e001a0776585ad59A144dA1B2F> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 2h Buy AI Actually Indian FDV $6.1K up 0.4% | <https://pools.trade/t/0x83D6d81D3E4555FE8bcD3E6aF0AB403b9A0735c3> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 34d Buy ABE ABE FDV $79.4K up 49.4% | <https://pools.trade/t/0xbcA2f7789815d7cf627A60e85f615532efB3BE96> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 34d Buy CHWDR ChowdLaunch Crowd Launch FDV $142.3K up 10.7% 24H volume $78.7K Holders 695 | <https://pools.trade/t/0xB358766827d7C704d3c52a57b5Cf181D1b0ffC6c> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 34d Buy FRONG frong FDV $9.1M up 24.7% 24H volume $8.3M Holders 15,028 | <https://pools.trade/t/0x6245e67affA44a23077f0Ea7f981a8DC743a0c47> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 34d Buy POOLS pools.trade FDV $2.4M up 20.9% 24H volume $1.1M Holders 6,239 | <https://pools.trade/t/0x385b36Ff682Ab4C76E7c37A66b96aABC466471d5> | internal, token page | pages/08-token-page-instant-launch.md |
| home discovery feed | 34d Buy TRASH Trash FDV $17.5K up 36.2% | <https://pools.trade/t/0x5AB5f320D8a3dE4967fBED6D0678Ad71683f53c7> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 34d Buy UNIFROG Unifrog FDV $182.4K down 1.6% 24H volume $117.9K Holders 1,635 | <https://pools.trade/t/0x8750dA3e48345Ec0C5AAAACfcda2A004Da3B60c2> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 4h Buy Fwedgie FrontalWedgie FDV $67.1K up 1011.2% | <https://pools.trade/t/0xAB2300c7d284b769FBF55a2AdFBaEf280ef948D2> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| home discovery feed | 6d Buy WLAI NOLOCK Crowd Launch FDV $1.4M up 9.1% 24H volume $64.3K Holders 191 | <https://pools.trade/t/0x68E3bE6252d97C71b109F1FDb5E4a5b284b7d96d> | internal, token page | not captured individually, the token page template is captured in pages/08 and pages/09 |
| cca.listAuctions capture | Live Crowd Launch, TAARD | <https://pools.trade/t/0xCA645B349005b2d155f272f47ef8ea837CF43987> | internal, token page | pages/09-token-page-crowd-launch.md |
