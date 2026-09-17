# Doppler - paper, Doppler Multicurve

> Source: https://doppler.lol/multicurve.pdf
> Retrieved: 2026-09-02 (Jina Reader, saved as `_raw/jina/ext-multicurve-pdf.md`)
> Page title: Doppler Multicurve

---

# Doppler Multicurve 

# April 2025 

# Austin Adams 

austin@whetstone.cc 

# Matt Czernik 

matt@whetstone.cc 

# Rohan Kulkarni 

rohan@zora.co 

# Cooper Kunz 

cooper@whetstone.cc 

## Abstract 

Financial markets are increasingly becoming internet native. One-size-fits-all token launchpads and liquidity bootstrapping proto-cols have failed to meet the needs of token creators and their communities. Developers increasingly want onchain markets with application-specific customizations. We introduce Doppler Multi-curve, a new primitive for onchain issuance that enables multiple price curves to be specified during an initial auction or liquidity bootstrapping phase, which can then be tailored to a specific use case or application’s needs. In doing so, developers have the expres-sivity necessary to reduce maximal extractable value (MEV), and enable more capital-efficient liquidity formation. 

## 1 Introduction 

When utilizing a concentrated liquidity automated market maker (CLAMM), static bonding curve-based projects place one constant liquidity position for buyers. However, one constant liquidity place-ment comes with a subtle but impactful downside: significantly more tokens are available for trading at the cheapest prices on the position, leading to an outsized portion of the token supply sold to the earliest buyers (who are generally MEV bots). MEV bots, in turn, quickly dump these cheap shares when new buyers enter the market, extracting value from both the new buyers and the token project. Additionally, the wider the position across the price spec-trum, the more outsized this price dilation effect is, and potential downside for users. 0.90 0.92 0.94 0.96 0.98 1.00 

> Price
> 020 40 60 80 100
> Normalized liquidity (k) at price (%)

Figure 1: A Single Constant Liquidity Position 

Doppler Multicurve turns this on its head and addresses one of the biggest limitations of liquidity-bootstrapping protocol’s inte-gration with CLAMMs. Instead of placing one constant liquidity position (shown in Figure 1), integrators specify their desired curves, which in itself is entirely managed by Multicurve. Multicurve is entirely compatible with the current Doppler Protocol [1] ecosystem. In practice, this means that Multicurve creates a curve mimick-ing a log-normal curve utilizing individual concentrated liquidity positions, which aims to sell a constant number of tokens in each price bucket. An example of this is shown above in Figure 1. Ad-ditionally, while not shown in the above figure, multiple of these curves can be placed, allowing customization of complex curves and price paths, entirely maintained and executed inside the existing Doppler position manager. Similar to all other Doppler features, it’s natively compatible with existing popular AMM integrations, such as Uniswap. Compared to a static bonding curve, Multicurve reduces snip-ing, leads to higher liquidity and prices, allows for a more customiz-able market structure, and lowers the cost of price discovery. 

## 2 Background 

Over the last year, there has been a significant increase in the num-ber of bonding curve-based liquidity bootstrapping protocols such as pumpdotfun, clanker, and Meteora. This proliferation has re-sulted in a awide variety of different implementations with various market structure impacts. The bonding curve design utilized by most (with notable exceptions like pumpdotfun) utilizes an 𝑥 ·𝑦 = 𝑘 

concentrated-liquidity AMM (CLAMM), such as Uniswap v3 [2], as the matching engine for their protocols. However, as previously stated, 𝑥 · 𝑦 = 𝑘 AMMs have a major drawback for new token liquidity bootstrapping, where the amount of tokens sold by the protocol decreases as the price of the token goes up, which is guaranteed if there is any trading activity. By selling the most amount of tokens at the cheapest possible price, token projects that use these static bonding curves will have in-creased losses from sniping, increased cost of price discovery, and will result in overall lower user welfare. Additionally, we will show mathematically in the appendix that selling more tokens during the earlier trading period phase is a fundamental property of 𝑥 · 𝑦 = 𝑘 

AMMs, which is addressed through a layering technique pioneered by Doppler Multicurve. 

> 1Adams et all

## 3 Single Curve 

At its core, Doppler Multicurve is first a collection of individual single log-normal curves. With multiple curves, integrators can describe increasingly complex curvatures by combining multiple single curves. First, we describe the parameterization of a single curve. We note for brevity that we only describe the case where the new token is 

𝑡𝑜𝑘𝑒𝑛 0.To parameterize a single curve, integrators provide a 𝑡𝑖𝑐𝑘𝐿𝑜𝑤𝑒𝑟 ,

𝑡𝑖𝑐𝑘𝑈 𝑝𝑝𝑒𝑟 , total token amount ( 𝑎𝑚𝑜𝑢𝑛𝑡 ) for bootstrapping liquidity, and desired steepness (known as 𝑛𝑢𝑚𝑃𝑜𝑠𝑖𝑡𝑖𝑜𝑛𝑠 ). The 𝑛𝑢𝑚𝑃𝑜𝑠𝑖𝑡𝑖𝑜𝑛𝑠 

is the number of positions created by Multicurve. 

𝑡𝑖𝑐𝑘𝐿𝑜𝑤𝑒𝑟 and 𝑡𝑖𝑐𝑘𝑈 𝑝𝑝𝑒𝑟 refer to the placement of possible liq-uidity positions in CLAMMs and must satisfy the conditions en-forced by the specific AMM. To start, the total token amount, 𝑎𝑚𝑜𝑢𝑛𝑡 is divided equally among all positions. 

𝑝𝑜𝑠𝑖𝑡𝑖𝑜𝑛𝑇𝑜𝑘𝑒𝑛𝑠 𝑖 = 𝑎𝑚𝑜𝑢𝑛𝑡 𝑛𝑢𝑚𝑃𝑜𝑠𝑖𝑡𝑖𝑜𝑛𝑠 (3.1) Next, in the 𝑡𝑜𝑘𝑒𝑛 0 case, each position ends at 𝑡𝑖𝑐𝑘𝑈 𝑝𝑝𝑒𝑟 with the 𝑡𝑖𝑐𝑘𝐿𝑜𝑤𝑒𝑟 of the the position linearly spanning from 𝑡𝑖𝑐𝑘𝐿𝑜𝑤𝑒𝑟 

to 𝑡𝑖𝑐𝑘𝑈 𝑝𝑝𝑒𝑟 . This is flipped accordingly in the 𝑡𝑜𝑘𝑒𝑛 1 case. 

𝑡𝑖𝑐𝑘𝐿𝑜𝑤𝑒𝑟 𝑖 = 𝑡𝑖𝑐𝑘𝐿𝑜𝑤𝑒𝑟 + ⌊ 𝑖 · ( 𝑡𝑖𝑐𝑘𝑈 𝑝𝑝𝑒𝑟 − 𝑡𝑖𝑐𝑘𝐿𝑜𝑤𝑒𝑟 )

𝑛𝑢𝑚𝑃𝑜𝑠𝑖𝑡𝑖𝑜𝑛𝑠 ⌋ (3.2) Due to both integer math and implementation details, each 

𝑡𝑖𝑐𝑘𝐿𝑜𝑤𝑒𝑟 𝑖 is binned according to the 𝑡𝑖𝑐𝑘𝑆𝑝𝑎𝑐𝑖𝑛𝑔 . Depending on the configuration of the curve and the 𝑛𝑢𝑚𝑃𝑜𝑠𝑖𝑡𝑖𝑜𝑛𝑠 , this could result in multiple positions overlapping with the same 𝑡𝑖𝑐𝑘𝐿𝑜𝑤𝑒𝑟 

and 𝑡𝑖𝑐𝑘𝑈 𝑝𝑝𝑒𝑟 . This should be avoided due to unnecessary gas costs, but is accounted for in the implementation. Each position is placed from its calculated 𝑡𝑖𝑐𝑘𝐿𝑜𝑤𝑒𝑟 𝑖 to 𝑡𝑖𝑐𝑘𝑈 𝑝𝑝𝑒𝑟 .Each of these positions are given equal numbers of tokens with their 𝑙𝑖𝑞𝑢𝑖𝑑𝑖𝑡𝑦 calculated at run time, resulting in a staircase-like liquidity structure, where positions closer to 𝑡𝑖𝑐𝑘𝑈 𝑝𝑝𝑒𝑟 have more liquidity. This results in more tokens concentrated around that value than a constant liquidity position. 0.825 0.850 0.875 0.900 0.925 0.950 0.975 1.000 

> Price
> 020 40 60 80 100
> Normalized liquidity (k) at price (%)

Figure 2: A selected single curve 

In Figure 2, we show a sample implementation of the single curve design with 𝑡𝑖𝑐𝑘𝐿𝑜𝑤𝑒𝑟 = −2000 , 𝑡𝑖𝑐𝑘𝑈 𝑝𝑝𝑒𝑟 = 0, 𝑛𝑢𝑚𝑃𝑜𝑠𝑖𝑡𝑖𝑜𝑛𝑠 =

10 1. With more positions, the 𝑙𝑖𝑞𝑢𝑖𝑑𝑖𝑡𝑦 of the system is more con-centrated around global 𝑡𝑖𝑐𝑘𝑈 𝑝𝑝𝑒𝑟 of the curve. More liquidity in the upper parts of the curve results in faster price accumulation and a higher average price execution. From these four parameters, every position in the curve can always be cheaply calculated ensuring that all positions are always tracked while additionally lowering the gas cost by maintaining less information inside onchain storage. 

## 4 Multicurve 

In principle, Multicurve is a direct extension of a single curve, allowing integrators to provide multiple curve parameterizations that are then jointly managed by the Doppler position manager. By allowing integrators to place multiple curves, increasingly complex curvatures can be described, resulting in the ability to place bonding curves that are molded around the design of the token and the expected price path. As different token types will have different expected price paths, features, and timelines, the structure of the liquidity bootstrapping should also adapt to these features as well. 0.825 0.850 0.875 0.900 0.925 0.950 0.975 1.000 

> Price
> 020 40 60 80 100
> Normalized liquidity (k) at price (%)

Figure 3: Two selected multiple curvitures 

An example Multicurve liquidity path is shown above. The two curves are 𝐶𝑢𝑟𝑣𝑒 1 colored in black with ( 𝑡𝑖𝑐𝑘𝐿𝑜𝑤𝑒𝑟 1 = −2000 , 𝑡𝑖𝑐𝑘𝑈 𝑝𝑝𝑒𝑟 1 = 0, 𝑛𝑢𝑚𝑃𝑜𝑠𝑖𝑡𝑖𝑜𝑛𝑠 1 = 5, 𝑡𝑜𝑘𝑒𝑛𝐴𝑚𝑡 1 = 10%) and 

𝐶𝑢𝑟𝑣𝑒 2 colored in blue with ( 𝑡𝑖𝑐𝑘𝐿𝑜𝑤𝑒𝑟 2 = −1000 , 𝑡𝑖𝑐𝑘𝑈 𝑝𝑝𝑒𝑟 1 = 0, 

𝑛𝑢𝑚𝑃𝑜𝑠𝑖𝑡𝑖𝑜𝑛𝑠 1 = 5, 𝑡𝑜𝑘𝑒𝑛𝐴𝑚𝑡 1 = 25%). This curve is designed to fa-cilitate early price discovery from 𝐶𝑢𝑟𝑣𝑒 1 with thin but continuous liquidity. From there, a 𝐶𝑢𝑟𝑣𝑒 2 is layered over the first to lower price impact at higher prices. Both of these curves are entirely managed by the Doppler position manager As an added feature, Doppler itself calculates the amount of the numeraire token (generally ETH, but there is no requirement) that will result in exiting the entire curve. This allows integrators to easily know how many tokens will be generated during initial liquidity bootstrapping. This also allows Doppler itself to calcu-late the optimal amount of the quote token (the token being sold)     

> 1As 𝑙𝑖𝑞𝑢𝑖𝑑𝑖𝑡 𝑦 is normalized in the chart, 𝑎𝑚𝑜𝑢𝑛𝑡 is arbitrary 2Doppler Multicurve

needed to bond. Finally, this ensures that Doppler has enough of the bootstrapping token liquidity to bond against as a safety check. 

## 5 Conclusion 

As more of the financial economy moves onchain, and internet capital markets become increasingly relevant, it is important to have practical mechanisms that can support their ambitions. The design of Doppler Multicurve is intended to simplify the integrator experience while allowing them to customize their capital markets to their application or implementation needs. Integrators pick what their starting and ending price of the token is, and then go end to end with cheaper price discovery. For one example, by utilizing just one single curve in Multic-urve, Zora lowered the starting price of their tokens by 60x (from $1,320 to $22) with the same cost from sniping as a constant liquidity curve. By lowering the cost of sniping with high price precision, the tokens created on the protocol will result in higher prices and more liquidity, as less value will be extracted via sniping bots. By incorporating a second curve and iterating on the design according to market feedback, the cost of initial liquidity provision should continue to lower. 

## A Mathematical Appendix 

To explain why a constant liquidity position leads to more tokens sold at cheaper prices, we first must explain what constant liquidity in concentrated liquidity math refers to. A good mental model is that 𝑙𝑖𝑞𝑢𝑖𝑑𝑖𝑡𝑦 is the 𝑘 in the ever popular 

𝑥 · 𝑦 = 𝑘 equation. 2

First, we define the price 𝑝 as the reserves of 𝑥 divided by the reserves of 𝑦 .

𝑝 = 𝑥 𝑦 (A.1) Next, we can rewrite and substitute 𝑥 to find the impact of 𝑝𝑟𝑖𝑐𝑒 

increasing. 

𝑘 = 𝑦 2𝑝 (A.2) Finally, we can rewrite to isolate 𝑦 .

𝑦 =√︄ 𝑘 𝑝 (A.3) Since 𝑝 = 𝑥 𝑦 , an increase in 𝑝𝑟𝑖𝑐𝑒 means that 𝑦 is more valuable than it previously was worth. We see that as the price increases, the amount of 𝑦 in the pool likewise must decrease. This is fairly obvious because users are buying 𝑦 with 𝑥 if the price is going up, resulting in more 𝑥 and less 𝑦 in the pool. 0 2 4 6 8 10 012345Price 

> 𝑦  =√︁  𝑘 /𝑝

Plot of 𝑦 =√︁ 𝑘 /𝑝 with 𝑘 = 10 

𝑘 = 10 However, what is important to note is actually the shape of this graph. It is non-linear, meaning that the amount of tokens sold between two bins is not constant. Now, we want to show that there always exists more tokens in earlier price bins than in later price bins if 𝑘 is constant in the bin. This results in the amount of 𝑦 sold to be larger at the earliest stages inside the liquidity pool. This effect results in an outsized portion of the token supply sold to the earliest buyers. To move between arbitrary prices in concentrated liquidity, we must buy all the tokens 𝑦 from 𝑝 to 𝑝 + 𝛿 .

> 2We note that in the Uniswap v3 model, liquidity is actually sqrt(k) due to implemen-tation details, but this does not notably impact the directionality of the meaning. 3Adams et all

To show that the amount 𝑦 is strictly decreasing from 𝑝 1 to 𝑝 2

if 𝑝 2 > 𝑝 1, we must show that the derivative of 𝑦 with respect to 

𝑝𝑟𝑖𝑐𝑒 is always negative. 

𝑑𝑦 𝑑𝑝 = −√𝑘 

2𝑝 3/2 (A.4) This derivative is negative for all positive values of 𝑝 and 𝑘 ,which means the function is always decreasing as price increases. This results in more tokens sold at the earliest bins than later ones. 2 4 6 8 10 

−5

−4

−3

−2

−10Price 

> 𝑑𝑦 𝑑𝑝  = −
> √𝑘
> 2·𝑝𝑟𝑖𝑐𝑒 3/2

Derivative of 𝑦 =√︁ 𝑘 /𝑝 with respect to 𝑝 𝑘 = 10 Additionally, the derivative is non-linear and increases rapidly around the earliest possible prices, resulting in this effect to be larger at the start of the price curve and for smaller token prices (which is what is commonly used for new token projects) Overall, the main way to combat this effect is to utilize a shift-ing 𝑘 value, which is all implemented via Doppler Multicurve. As shifting the amount of 𝑘 between bins negates this non-linear decrease in the amount sold per bin. 

## References               

> [1] Austin Adams, Matt Czernik, Clement Lakhal, and Kaden Zipfel. 2025.
> Doppler: A liquidity bootstrapping ecosystem .Retrieved Apr 21, 2025 from https://github.com/whetstoneresearch/docs/blob/main/whitepapers/doppler/ Dutch_auction_Dynamic_Bonding_Curves.pdf [2] Hayden Adams, Noah Zinsmeister, Moody Salem, River Keefer, and Dan Robin-son. 2021. Uniswap v3 Core .Retrieved Jun 12, 2023 from https://uniswap.org/ whitepaper-v3.pdf

## B Disclaimers 

No Legal, Financial, or Investment Advice. This document does not constitute legal advice, financial advice, investment advice, trading advice, or a recommendation of any kind by Doppler, its affiliates, or any of their respective officers, directors, managers, employees, agents, advisors, or consultants. No information con-tained herein should be relied upon as the basis for any investment decision, contract, or any other decision regarding engagement with Doppler or any of its projects. 

Forward-Looking Statements. This document may contain forward-looking statements based on assumptions and beliefs of Doppler, its officers, or its affiliates. These statements are subject to known and unknown risks, uncertainties, and other factors, many of which are outside Doppler’s control, that may cause actual outcomes to differ materially from the projections or expectations set forth in such statements. Doppler makes no obligation to update or revise any forward-looking statements to reflect subsequent events, developments, or changes in circumstances after the date on which such statements were made, except as required by law.

Links/Buttons:
This page does not seem to contain any buttons/links.
