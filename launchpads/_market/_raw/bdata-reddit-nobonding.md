Reddit - The heart of the internet                               [Skip to main content](#main-content)  Open menu Open navigation [](https://www.reddit.com/)Go to Reddit Home

r/defi 

[Sign Up](https://www.reddit.com/register/) Sign up for Reddit [Log In](https://www.reddit.com/login/) Log in to Reddit

 Expand user menu Open settings menu

 

[

![](https://styles.redditmedia.com/t5_muuww/styles/communityIcon_ifteojzkho951.png?width=96&height=96&frame=1&auto=webp&s=144702927d36d7aa67bee3c24d31d2f3c01f717b)

Go to defi](https://www.reddit.com/r/defi/)

[r/defi](https://www.reddit.com/r/defi/) • 17d ago

[amu4biz](https://www.reddit.com/user/amu4biz/)

# A launchpad with no bonding curve did $5.2M volume on day one, and it uses 25% of protocol fees to buy and burn the community's top tokens daily

pools fun went live yesterday on Robinhood Chain and had one of the strongest first days I've seen from a launchpad. I read the factory contract's events directly rather than going off the announcement, and the numbers hold up. Method at the bottom so anyone can check it.

**Two design choices that make it worth a look**

**1\. No bonding curve.** Every token deploys straight into a SushiSwap V3 pool, paired against WETH, 1% fee tier, fixed 1B supply, around $10k starting FDV. There is no curve phase and no graduation event. Real V3 liquidity exists from the very first block, which means no waiting for a bar to fill before a token is actually tradeable, and no cliff moment where the curve hands off to a DEX. It's just an AMM from second zero.

**2\. Protocol fees buy and burn the community's winners.** 25% of all protocol fees go toward buying and burning the top 3 tokens daily, ranked on a live leaderboard. The first snapshot ran yesterday and hit $sushicat, $ONGR and $FLAMINGO.

That second one is the part I keep thinking about. Most launchpads treat fees as revenue that leaves the ecosystem. Here the protocol's own income is recycled into whichever communities won that day, so the fee split becomes a daily competition instead of a static rev-share. It gives every project on the platform something to organize around beyond just their own chart, and it resets every 24 hours so nobody is permanently locked out.

**The first 24 hours, on-chain**

*   **2,439 tokens launched.** The previous 24 hours had 268, so about 9x on go-live.
    
*   **532 launches in a single hour** at the peak, right as the platform opened.
    
*   **959 unique creator addresses**, so this is a genuinely wide crowd rather than a handful of deployers.
    
*   **$5.19M in 24h volume** and **$12.3M in liquidity** across the pools.
    
*   Top performer was **$ONGR at $1.31M volume, up roughly 3,500%**, and it landed in the first burn snapshot.
    
*   57 tokens cleared $10k in volume on day one, 245 cleared $1k.
    

For a platform that was a splash page 48 hours ago, putting up eight figures of liquidity and a million-dollar token on day one is a real start. The usual launchpad long tail applies and most of what launched is quiet, which is true everywhere, but the top of the distribution is doing actual volume rather than wash-looking noise.

The infrastructure underneath helps. Robinhood Chain is running 0.1 second blocks with gas in the fractions of a cent, so launching and trading feels instant, and Sushi V3 is doing the heavy lifting on the pool side rather than a custom AMM that has to be trusted.

**What I'm curious about**

The daily burn leaderboard is the mechanic I'd watch. If it works, it gives communities a reason to coordinate that isn't just buying their own token, and it turns protocol revenue into something the whole platform competes over. Has anything else tried recycling launchpad fees into buybacks of user tokens rather than a native token? I can't think of one, and I'd be interested if someone has seen this design before.

**Method**

Launch data is decoded from the `TokenLaunched` events on the PartyFactory contract at 0x626C3d09B65bF5d1D40E0D5F25e19fa49783B3D4 on Robinhood Chain, cross-checked against Blockscout. Volume, liquidity and FDV are from DexScreener, filtered to Sushi V3 pairs whose token address appears in those factory events. The RPC and explorer API are both open, so this is fully reproducible. The burn figures are the team's stated policy, I have confirmed the leaderboard and the snapshot but not yet traced the individual burn transactions.

No affiliation with the platform and I don't hold any of these tokens, I just went digging because the no-curve design was unusual. No links in this post on purpose.

Read more

Share    

# People also ask about section

People also ask about

[

Tokenomics of burn mechanisms

](https://www.reddit.com/answers/2f0fa052-64f3-46ed-9382-5a9b5e89f23c/?q=Tokenomics+of+burn+mechanisms&source=PDP&ep=pdp_unit&relatedPostId=t3_1vpq3ux)

[

Community token distribution strategies

](https://www.reddit.com/answers/aee41bbf-bdb4-49b7-8968-777033a177a2/?q=Community+token+distribution+strategies&source=PDP&ep=pdp_unit&relatedPostId=t3_1vpq3ux)

[

Protocol fee allocation models

](https://www.reddit.com/answers/47230b15-ba29-474c-bc90-67cda78f7425/?q=Protocol+fee+allocation+models&source=PDP&ep=pdp_unit&relatedPostId=t3_1vpq3ux)

[

Launchpad volume growth factors

](https://www.reddit.com/answers/3a64fd93-8985-45b9-a5bf-3c6e0148ab57/?q=Launchpad+volume+growth+factors&source=PDP&ep=pdp_unit&relatedPostId=t3_1vpq3ux)

[

Decentralized finance trends

](https://www.reddit.com/answers/cf69234f-3321-415a-8b86-d5e579c53719/?q=Decentralized+finance+trends&source=PDP&ep=pdp_unit&relatedPostId=t3_1vpq3ux)

Public

Anyone can view, post, and comment to this community

0 0

*   [Home](/?feed=home)
*   [Popular](/r/popular/)
*   [News](/news/)
*   [Explore](/explore/)
*   [Best of Reddit](https://www.reddit.com/posts/2026/global/)
*   [Best of Reddit in Portuguese](https://www.reddit.com/posts/2026/tl-pt-BR/)
*   [Best of Reddit in German](https://www.reddit.com/posts/2026/tl-de/)
*   [Reddit Rules](https://www.redditinc.com/policies/content-policy)
*   [Privacy Policy](https://www.reddit.com/policies/privacy-policy)
*   [User Agreement](https://www.redditinc.com/policies/user-agreement)
*   [Your Privacy Choices](https://support.reddithelp.com/hc/articles/43980704794004)
*   [Accessibility](https://support.reddithelp.com/hc/sections/38303584022676-Accessibility)
*   [Reddit, Inc. © 2026. All rights reserved.](https://redditinc.com)

![](https://i.redd.it/cms/b306fd8870bfee4b_snoo_map.png)

Join the most real place on the internet

Continue with Phone Number

Continue with Email

By continuing, you agree to our [User Agreement](https://www.redditinc.com/policies/user-agreement) and acknowledge that you understand the [Privacy Policy](https://www.redditinc.com/policies/privacy-policy). ![](https://id.rlcdn.co
