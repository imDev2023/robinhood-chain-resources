# Market context - Who Is the Biggest Winner of the Robinhood Chain Launch? Uniswap, but Not Really...

> Source: <https://oakresearch.io/en/analyses/investigations/who-is-biggest-winner-robinhood-chain-launch-uniswap-but-not-really>
> Retrieved: 2026-09-02 (Jina Reader, with links summary)

---

Pitched as the first Layer 2 capable of overshadowing Base, Robinhood Chain set out to become the settlement layer for RWAs. In practice, though, more than 99% of its volume comes from... memecoins. Amid this frenzy, the Uniswap DEX alone accounts for nearly two-thirds of the application fees generated on the chain. But here again, the reality is more nuanced than it looks, since the DEX hasn't pocketed a single cent so far. So who actually comes out ahead from this launch?

## Context Behind the Robinhood Chain

_"The Robinhood Chain is just another Layer 2 that will be abandoned within a few months."_ This statement has been circulating on social media since the blockchain's launch.

While this view is perfectly understandable given the current Layer 2 landscape (the top five rollups account for 95% of app fees), it is worth putting things back into context.

Although Robinhood remains relatively unknown in Europe, it is one of the largest brokers in the United States, with nearly 28 million accounts, operations across 38 countries, and $1.07 billion in revenue in Q1 2026. From our perspective, the Robinhood Chain is the first Layer 2 that could genuinely challenge Base, Coinbase's blockchain: both are playing in the same league.

![Image 1: robinhood-revenue-income-EB.webp](https://oakresearch.io/_next/image?url=https%3A%2F%2Fassets.oakresearch.io%2Frobinhood_revenue_income_EB_57f42299e1.webp&w=3840&q=100)

The idea behind the Robinhood Chain is to allow the broker to own its settlement infrastructure instead of simply building on an existing blockchain. By doing so, it takes control of order routing, compliance, clearing, and, most importantly, value capture. This is exactly the same logic that led Coinbase to launch Base, Circle to launch Arc, and Kraken to launch Ink.

Where the Robinhood Chain differs from Ink or Base is that it was not designed or marketed as a general-purpose blockchain. Instead, it was built as the infrastructure intended to support the next generation of compliance-grade financial products and tokenized securities.

### Infrastructure and Comparison with Existing Layer 2s

In practice, the goal is to make the Layer 2 the settlement layer for RWAs, a market vertical where Robinhood has already established a presence since June 2025 through its Stock Tokens. These are tokenized assets designed to provide economic exposure to U.S. stocks and ETFs (NVDA, GOOG, AAPL, etc.), offering 24/7 trading, DeFi composability, and self-custody through the Robinhood Wallet. It should be noted that none of the tokenized stocks offered by Robinhood grant shareholder rights.

From a technical standpoint, Robinhood opted for the Arbitrum Stack, which is naturally EVM-compatible and offers a 100ms confirmation time. This is another key difference from Base, which initially launched on the OP Stack before developing its own proprietary solution, and from Ink, which still runs on the OP Stack today and therefore remains anchored to the Superchain.

At the same time, Robinhood owns its sequencer, meaning it governs the blockchain and captures the bulk of the revenue generated. For comparison, the Robinhood Chain pays 10% of its revenue to Arbitrum, whereas Base paid Optimism either 2.5% of its gross sequencing revenue or 15% of its on-chain net profit (gross revenue minus Layer 1 related costs), whichever was higher.

At its mainnet launch, which took place roughly five months after the testnet deployment, the Robinhood Chain could already boast a well-developed ecosystem, including Uniswap (v2, v3 and v4,) as its primary liquidity layer, Chainlink for oracles, Morpho for lending, as well as Ethena, Ether.fi, BitGo, Alchemy, Lighter, 1inch, and Arcus, the DEX developed by dYdX exclusively for the Robinhood Chain.

![Image 2: robinhood-ecosystem-EN.webp](https://oakresearch.io/_next/image?url=https%3A%2F%2Fassets.oakresearch.io%2Frobinhood_ecosystem_EN_1b0df8a475.webp&w=3840&q=100)

For the first 90 days following launch, the blockchain subsidizes all transactions executed through the Robinhood Wallet, with the obvious objective of accelerating adoption with little to no-cost with the sequencer revenues way over the fees paid by non-native crypto users opting for Robinhood Wallet.

This should also be viewed alongside the deployment of Lighter as the perpetual DEX directly integrated into the Robinhood Wallet, accompanied by a two-month points campaign, as well as the launch of Robinhood Earn, a savings product offering a variable 7% yield through deposits of USDG, Paxos' stablecoin. In this particular case, the product relies on Morpho's infrastructure through a dedicated vault managed by Steakhouse Financial.

On this particular point, the product is built on Morpho's architecture through a dedicated vault managed by Steakhouse Financial. In practice, users can deposit USDG on Robinhood Earn, and this capital is allocated across different markets to be lent out. Currently, the Robinhood vault is exposed to markets involving Ethena's USDe, Maple's syrupUSDG, and Spark's spUSDG.

* * *

## From the RWA Thesis to Memecoins

At the time of writing, the Robinhood Chain has reached $193 million in TVL, while DEX volume has now surpassed $750 million. In terms of fees, more than $1.14 million has been collected in chain fees, while app fees have generated roughly $40 million.

According to DefiLlama, 48 applications have been deployed on the Robinhood Chain. However, one thing immediately stands out: TVL is highly concentrated among just a handful of protocols:

*   Morpho - $116M
*   Uniswap - $61M
*   Arcus - $14.3M
*   Spark - $8M
*   Noxa - $6M

TVL has continued to grow steadily, daily DEX volume remains stable, and, above all, one player has captured the overwhelming majority of fees: Uniswap. More specifically, the DEX has generated over $26.8 million in fees since the launch of the Robinhood Chain, accounting for nearly 66.4% of all application fees.

The explanation is fairly straightforward. Despite its TVL, Morpho generates relatively little fees (around $12,000 per day), while most other applications produce only modest fees, with the notable exception of Noxa.

The reason is that Noxa's and Uniswap's volumes are deeply interconnected. Noxa is a memecoin launchpad that exploded on the Robinhood Chain immediately after launch, largely thanks to CASHCAT, a token intended as a tribute to Robinhood's former mascot. To put things into perspective, CASHCAT surged by more than 5,500% within just seven days, reached a market capitalization close to $200 million, and recorded over $98 million in trading volume on its best day.

This triggered a wave of FOMO, leading to an avalanche of memecoins launching on the Robinhood Chain, the vast majority through Noxa. When a memecoin is launched, the launchpad deploys newly created tokens directly onto Uniswap v3, without any bonding curve or graduation phase, unlike platforms such as pump.fun. As a result, all trading volume is internalized on Uniswap, with a 1% fee tier.

In total, nearly 60,000 tokens have been created through Noxa, with 23,700 deployers recorded. Since launch, Noxa has generated more than $17.5 million in fees.

The issue is that its success became so overwhelming that the launchpad was [ultimately forced](https://x.com/Noxa_Fi/status/2077054908944076825?s=20) to halt the deployment of new tokens, citing bot activity that had become too difficult to manage, despite being the second-largest revenue generator behind Uniswap and even surpassing pump.fun on its strongest days.

![Image 3: robinhood-solana-dex-EN.webp](https://oakresearch.io/_next/image?url=https%3A%2F%2Fassets.oakresearch.io%2Frobinhood_solana_dex_EN_68f2962e34.webp&w=3840&q=100)

As nature abhors a vacuum, a wave of launchpads quickly emerged to replace Noxa, including Bags, Flap, Clanker, Doppler, Trench, and Bow, to name just a few. At the time of writing, the Robinhood Chain launchpad landscape has become fairly saturated, although pons.family currently appears to be standing out following Noxa's decision.

![Image 4: robinhood-launchpad-tokens.webp](https://oakresearch.io/_next/image?url=https%3A%2F%2Fassets.oakresearch.io%2Frobinhood_launchpad_tokens_d729a49426.webp&w=3840&q=100)

As shown in the chart above, overall memecoin activity on the Robinhood Chain has not been affected by this event whatsoever. In fact, quite the opposite has happened: the number of newly launched tokens has surged. Trading volume, meanwhile, has remained relatively stable, suggesting that part of the capital has simply migrated to other platforms, while Noxa continues to generate a share of the volume through its existing tokens.

At the same time, Uniswap's trading volumes have remained stable. This is because virtually every launchpad relies on the DEX as its underlying infrastructure (Uniswap is the Robinhood Chain's primary AMM), whether through Uniswap v3 or Uniswap v4 hooks.

To put this into perspective, more than 99% of all trading volume recorded on the Robinhood Chain since launch has been related to memecoin activity. In other words, the thesis of a blockchain built for RWAs has yet to materialize in any meaningful way. The 95 available Stock Tokens represent a combined market capitalization of $17.7 million, equivalent to 9.1% of the blockchain's TVL. Meanwhile, only $721,000 worth of tokenized stocks are currently being used as assets within DeFi.

While we’re building robinhood chain to be the best chain for RWA … it works great for memes too

* * *

## Uniswap Is Generating Fees, but Where Are They Going?

At first glance, one might conclude that Uniswap is the biggest winner of the Robinhood Chain launch. By positioning itself as the ecosystem's primary liquidity layer, the DEX has indeed captured the vast majority of trading volume, collecting nearly $27 million in fees.

The problem is that Uniswap has not received a single cent.

You may remember that the "[UNIfication](https://gov.uniswap.org/t/unification-proposal/25881)" governance proposal adopted last December was designed to introduce a burn mechanism for the UNI token, whose price had long been completely disconnected from the protocol's economic success. In practice, a portion of trading fees is collected before being redirected to a blockchain-specific "TokenJar," which is then used to burn the accumulated tokens on Ethereum.

The issue is that this mechanism was never activated on the Robinhood Chain, meaning the fees have so far benefited liquidity providers exclusively. However, on July 11, Uniswap Labs submitted a Temp Check [governance proposal](https://gov.uniswap.org/t/temp-check-protocol-fee-expansion-robinhood-chain/26168) to extend protocol fees to the Robinhood Chain through an accelerated governance process. The proposal passed with overwhelming support, receiving 100% of the votes.

At the same time, as a continuation of UNIfication, another proposal submitted around ten days ago aims to implement protocol fees on Uniswap v4, whose underlying architecture requires a dedicated approach (through LP fee tiers). This proposal was also approved with 95% support, although it has not yet gone live.

Based on estimates that can be made, between $2.49 million (the applicable minimum accross all Uniswap versions) and $6.23 million (the applicable maximum) in protocol fees could have been captured if UNIfication had been enabled on the Robinhood Chain from day one.

For comparison, Ethereum generated $10.38M in fees and $0.77M in protocol fees over the same period. However, protocol fees aren't collected on v4 of the Layer 1 either. That said, looking ahead, Ethereum could have collected up to $8.37M in protocol fees if this version of Uniswap is factored in.

In other words, under the same scenario, the Robinhood Chain would have generated 74.4% of the protocol fees collected on Ethereum over the same period.

> Note: The estimated range varies significantly because several factors affect protocol fee calculations, including the Uniswap version and the fee tier. In general, protocol fees range between 0.05% and 0.25% of LP fees.

As we have seen, trading volumes generated by Uniswap on the Robinhood Chain have remained remarkably stable so far. At this stage, there is therefore no indication that the DEX has missed its opportunity to capture the bulk of the fees generated.

![Image 5: robinhood-uniswap-volumes-EN.webp](https://oakresearch.io/_next/image?url=https%3A%2F%2Fassets.oakresearch.io%2Frobinhood_uniswap_volumes_EN_2acfddab48.webp&w=3840&q=100)

That being said, there is nothing particularly surprising here. Memecoins are, by definition, driven by hype cycles, and there is every reason to believe that this activity will eventually fade. It is worth remembering that the entire loop depends on a constant flow of new participants and that, ultimately, the majority of traders end up losing money.

Moreover, the fact that so many launchpads are currently competing against one another is arguably a negative development, as liquidity is inevitably spread across an ever-growing number of newly launched tokens.

* * *

## The Real Winner: Robinhood?

If we break down the fees generated on the Robinhood Chain between July 7 and July 16, we find that 89.5% goes to Robinhood, 10% is redirected to Arbitrum, and the remaining 0.5% goes to Ethereum. [As we explained on X](https://x.com/OAK_Res/status/2076981651322568807?s=20), this is the cost of introducing EIP-4844, which was specifically designed to reduce fees on Layer 2 networks.

![Image 6: robinhood-chain-fees-EN.webp](https://oakresearch.io/_next/image?url=https%3A%2F%2Fassets.oakresearch.io%2Frobinhood_chain_fees_EN_a14ef5408d.webp&w=3840&q=100)

Robinhood currently covers the transaction fees for all activity carried out through the Robinhood Wallet. In other words, chain fees should end up being higher than they are today once these incentives expire, assuming the blockchain manages to sustain a similar level of activity.

For its part, as the settlement layer, Ethereum captures almost nothing (0.5%), since it only receives the fees related to data availability and settlement. In reality, the largest share goes to Arbitrum (10%) as the provider of the technology stack powering the Robinhood Chain. For reference, 8% of this amount is allocated to the Arbitrum DAO treasury, while the remaining 2% goes to developers.

As you have probably guessed, Robinhood itself is currently the biggest winner. That said, it will be essential for the broker to move beyond its image as a "memecoin chain" and transition toward a business model that is more closely aligned with its traditional activities and a more institutional profile. Once again, memecoin-related activity has accounted for more than 99% of all trading volume on the Robinhood Chain.

The positive takeaway is that the blockchain launch could easily have ended in failure. Instead, thanks to the memecoin frenzy, all eyes are currently on the Robinhood Chain. Now, Robinhood simply needs to convert those users into one of its most promising verticals: RWAs. The ball is now in its court.

* * *

## Who Are the Losers?

Even though Robinhood Chain still has to prove it can retain users over the long run, its splashy launch is already spooking some of its competitors, Base chief among them.

On the morning of July 17, Coinbase CEO Brian Armstrong posted a photo referencing the BRIAN memecoin, despite never having said a word about this type of asset before. The idea, of course, is to ride the memecoin hype building on Robinhood Chain, and that didn't go unnoticed judging by the comments. That said, it didn't stop the token from surging more than 7,500%.

New profile photo - who dis

Still on the Coinbase side, Jesse Pollak, the "face" of Base, [announced](https://x.com/jessepollak/status/2077427261586997745?s=20) that he was handing off the Base App (Coinbase Wallet) to Cobie. Beyond the announcement itself, his message reads mostly as an admission of failure regarding Base's ability to grow around on-chain social (the collapse of Zora is a good example), which ultimately left it sidelined on the verticals that matter most today: perps, RWAs and prediction markets. In other words, two of the three segments Robinhood is specifically looking to build out.

Next, think of the players operating in tokenized equities, like xStocks. Since its acquisition by Kraken at the end of 2025, xStocks has seen its TVL grow healthily ([$491M today](https://app.rwa.xyz/platforms/xstocks)), with billions of dollars traded each month. In its anniversary announcement [published earlier this month](https://xstocks.fi/news/one-year-of-xstocks-the-tokenized-equities-framework-that-made-a-market), xStocks laid out three priorities for its next phase: tokenizing non-US equities, expanding into commodities, and soon adding xStocks assets as collateral within on-chain finance. Here too, the fight with Robinhood will be fierce.

Third, one of the big losers in all this is Ethereum. As we've seen, the Layer 1 now captures very little of the fees generated by Layer 2s, and that's where the problem lies: what we're seeing today is that institutions ready to move on-chain would rather launch their own proprietary Layer 2, with all the advantages that brings, than depend on Ethereum, whose structure remains poorly suited to the task.

Finally, in the most bullish scenario for Robinhood Chain, it will be essential for protocols hoping to capitalize on the momentum to plug in as quickly as possible. Otherwise, they'd forfeit a real long-term edge under first-mover logic. Aerodrome proved this perfectly on Base: with a functional, attractive product, you can capture value over the long run and keep your users loyal.

But once again, all of this will hinge on Robinhood's ability to turn its initial enthusiasm into genuine infrastructure capable of attracting capital in a durable way.

Links/Buttons:
- [](https://t.me/share/url?url=https%3A%2F%2Foakresearch.io%2Fen%2Fanalyses%2Finvestigations%2Fwho-is-biggest-winner-robinhood-chain-launch-uniswap-but-not-really&text=Who%20Is%20the%20Biggest%20Winner%20of%20the%20Robinhood%20Chain%20Launch%3F%20Uniswap%2C%20but%20Not%20Really...)
- [Upgrade](https://oakresearch.io/en/upgrade)
- [Data](https://oakresearch.io/en/assets/1)
- [TradFi](https://oakresearch.io/en/tradfi/1)
- [Projects](https://oakresearch.io/en/projects/1)
- [Hyperliquid](https://oakresearch.io/en/hyperliquid/terminal)
- [OAK Index](https://oakresearch.io/en/index)
- [Yields](https://oakresearch.io/en/yields)
- [Portfolios](https://oakresearch.io/en/portfolio)
- [Research](https://oakresearch.io/en/posts)
- [Premium](https://oakresearch.io/en/posts/premium)
- [Feed](https://oakresearch.io/en/feed/news)
- [Alpha Feed](https://oakresearch.io/en/feed/alpha)
- [Daily Recap](https://oakresearch.io/en/feed/recap)
- [Monitoring](https://oakresearch.io/en/feed/monitoring)
- [About](https://oakresearch.io/en/about)
- [Store](https://oakresearch.io/en/store)
- [Block Note](https://oakresearch.io/en/blocknote)
- [Services](https://oakresearch.io/en/services)
- [Our Team](https://oakresearch.io/en/team)
- [Authors](https://oakresearch.io/en/authors)
- [Brand Kit](https://oakresearch.io/en/brand-kit)
- [Affiliates](https://oakresearch.io/en/affiliates)
- [Discord](https://discord.gg/wCNjsMTcHJ)
- [Instagram](https://www.instagram.com/oak.research)
- [Telegram](https://t.me/oakresearch_en)
- [Tiktok](https://www.tiktok.com/@oak_research)
- [Twitter](https://x.com/OAK_Res)
- [Youtube](https://www.youtube.com/@Oak-Research)
- [Legal](https://oakresearch.io/en/legal)
- [Up to 4% cashback + 6% yield · The stablecoin neobank, now open to allGet Plasma One](https://oakresearch.io/go-plasma)
- [Analyses](https://oakresearch.io/en/analyses)
- [Investigations](https://oakresearch.io/en/analyses/investigations)
- [MPMaximilien Prué](https://oakresearch.io/en/authors/maximilien-prue)
- [UNUniswap+11.24%](https://oakresearch.io/en/assets/coins/uniswap)
- [HOHOOD+2.51%](https://oakresearch.io/en/hyperliquid/hip-3/markets/xyz:HOOD)
- [MakeOAK Researchpreferred on](https://www.google.com/preferences/source?q=oakresearch.io)
- [ultimately forced](https://x.com/Noxa_Fi/status/2077054908944076825?s=20)
- [Follow](https://x.com/intent/follow?screen_name=brian_armstrong)
- [9.7K](https://x.com/intent/like?tweet_id=2074695821896065360)
- [Reply](https://x.com/intent/tweet?in_reply_to=2077904275569783272)
- [UNIfication](https://gov.uniswap.org/t/unification-proposal/25881)
- [governance proposal](https://gov.uniswap.org/t/temp-check-protocol-fee-expansion-robinhood-chain/26168)
- [As we explained on X](https://x.com/OAK_Res/status/2076981651322568807?s=20)
- [4.2K](https://x.com/intent/like?tweet_id=2077904275569783272)
- [announced](https://x.com/jessepollak/status/2077427261586997745?s=20)
- [$491M today](https://app.rwa.xyz/platforms/xstocks)
- [published earlier this month](https://xstocks.fi/news/one-year-of-xstocks-the-tokenized-equities-framework-that-made-a-market)
- [Alpha Recap #35: Google Earnings, Permissionless HIP-4 and Launchpads on the Robinhood ChainJuly 24, 2026HYHOHyperliquid (HYPE), HOOD](https://oakresearch.io/en/analyses/investigations/alpha-recap-35-google-earnings-permissionless-hip-4-launchpads-robinhood-chain)
- [Alpha Recap #17: Uniswap Fee Switch, Fluid Expands to BNB Chain, and Aave Governance VotesFebruary 27, 2026FLUNAAFluid, Uniswap (UNI), Aave](https://oakresearch.io/en/analyses/investigations/alpha-recap-17-uniswap-fee-switch-fluid-expands-bnb-chain-aave-governance-votes)
- [Flashblocks: Towards ultra-fast layer 2 EVMs? March 7, 2025ETUNEthereum (ETH), Uniswap (UNI)](https://oakresearch.io/en/analyses/innovations/flashblocks-towards-ultra-fast-layer2-ev-ms)
- [Where does Uniswap (UNI) money go?March 6, 2025UNUniswap (UNI)](https://oakresearch.io/en/analyses/investigations/where-does-uniswap-uni-money-go)
- [Context Behind the Robinhood Chain](https://oakresearch.io/en/analyses/investigations/who-is-biggest-winner-robinhood-chain-launch-uniswap-but-not-really#context-behind-the-robinhood-chain)
- [Infrastructure and Comparison with Existing Layer 2s](https://oakresearch.io/en/analyses/investigations/who-is-biggest-winner-robinhood-chain-launch-uniswap-but-not-really#infrastructure-and-comparison-with-existing-layer-2s)
- [From the RWA Thesis to Memecoins](https://oakresearch.io/en/analyses/investigations/who-is-biggest-winner-robinhood-chain-launch-uniswap-but-not-really#from-the-rwa-thesis-to-memecoins)
- [Uniswap Is Generating Fees, but Where Are They Going?](https://oakresearch.io/en/analyses/investigations/who-is-biggest-winner-robinhood-chain-launch-uniswap-but-not-really#uniswap-is-generating-fees-but-where-are-they-going)
- [The Real Winner: Robinhood?](https://oakresearch.io/en/analyses/investigations/who-is-biggest-winner-robinhood-chain-launch-uniswap-but-not-really#the-real-winner-robinhood)
- [Who Are the Losers?](https://oakresearch.io/en/analyses/investigations/who-is-biggest-winner-robinhood-chain-launch-uniswap-but-not-really#who-are-the-losers)
