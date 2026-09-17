# Long - Dune query 8032293, LONG: supply share per stock

> Source: https://dune.com/queries/8032293
> Retrieved: 2026-09-02 (Jina Reader)
> Raw capture: `_raw/dune/query-8032293.md`

---

[Skip to content](https://dune.com/queries/8032293#skip-nav)

[](https://dune.com/)

*   [Search](https://dune.com/search)
*   [Catalog](https://dune.com/data)

[Library](https://dune.com/auth/login?next=%2Fworkspace%2Fqueries)

[Monitor](https://dune.com/auth/login?next=%2Fworkspace%2Factivity)

*   [Activity](https://dune.com/auth/login?next=%2Fworkspace%2Factivity)
*   [Usage](https://dune.com/auth/login?next=%2Fsettings%2Fusage)
*   [Schedules](https://dune.com/auth/login?next=%2Fworkspace%2Fschedules)
*   [Alerts](https://dune.com/auth/login?next=%2Fworkspace%2Falerts)

[Connect](https://dune.com/auth/login?next=%2Fworkspace%2Fapis)

Get started Making onchain finance observable.

[Sign up](https://dune.com/auth/register?next=%2Fqueries%2F8032293)[Log in](https://dune.com/auth/login?next=%2Fqueries%2F8032293)

*   [Docs](https://docs.dune.com/)
*   [Pricing](https://dune.com/pricing)

*   [](https://dune.com/)

*   [Log in](https://dune.com/auth/login?next=%2Fqueries%2F8032293)

*   [Sign up](https://dune.com/auth/register?next=%2Fqueries%2F8032293)

# LONG: supply share per stock

[0](https://dune.com/auth/login?next=%2Fqueries%2F8032293)[Share](https://dune.com/auth/login?next=%2Fqueries%2F8032293)[Fork](https://dune.com/auth/register?next=%2Fqueries%2F8032293&onboarding=short)

[![Image 1: @natan_benish2001](https://dune.com/_next/image?url=%2Fassets%2Favatar-fallback%2Fanon-09.png&w=32&q=75&dpl=dpl_AVadPP2B5UWR24VnXSDaBg3oA12P)@natan_benish2001](https://dune.com/natan_benish2001)

Last run 4h ago in 4m 152 Updated 2d

Query editor

*   [](https://dune.com/auth/login?next=%2Fqueries%2F8032293)

[](https://dune.com/queries/8032293/visuals/12017350)

99

1

2

3

4

5

6

7

8

9

10

11

12

13

14

15

16

17

18

19

20

21

22

23

24

25

26

27

28

29

30

31

32

33

34

35

36

-- LONG widget: % of each stock token's on-chain circulating supply held in LONG pools (spec #4)

-- circulating supply = mints − burns (issuance is off-chain; supply arrives by mint)

-- held in LONG pools = v4 (cumulative pool-perspective numeraire deltas, INCLUDING buyback legs,

-- unmigrated pools only) + graduated pools (ERC20 transfer accounting)

WITH pools AS(

SELECT*FROM query_8032178

),

latest_prices AS(

SELECT token,symbol,token_decimals,MAX_BY(price_usd,hr)AS price_usd

FROM(SELECT*FROM query_8032188

UNION ALL SELECT*FROM query_8391616)-- q3b: derived prices for feedless stocks (2026-08-20)

GROUP BY 1, 2, 3

),

stock_supply AS(

SELECT

l.contract_address AS token,

SUM(CASE WHEN l.topic1= 0x0000000000000000000000000000000000000000000000000000000000000000

THEN CAST(varbinary_to_uint256(l.data)AS double)

ELSE-CAST(varbinary_to_uint256(l.data)AS double)END)AS raw_supply

FROM robinhood.logs l

JOIN(SELECT DISTINCT numeraire FROM pools)n ON n.numeraire=l.contract_address

WHERE l.topic0= 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef

AND l.topic3 IS NULL

AND(l.topic1= 0x0000000000000000000000000000000000000000000000000000000000000000

OR l.topic2= 0x0000000000000000000000000000000000000000000000000000000000000000)

GROUP BY 1

),

v4_held AS(

SELECT s.numeraire,SUM(s.pool_numeraire_delta)AS held

FROM query_8032229 s

JOIN(SELECT DISTINCT asset FROM pools WHERE pool_type='v4'AND migrate_time IS NULL)p

ON p.asset=s.asset

WHERE s.venue='v4'

GROUP BY 1

),

grad_held AS(

[Run](https://dune.com/auth/register?next=%2Fqueries%2F8032293&onboarding=short)

Query results

[](https://dune.com/auth/login?next=%2Fqueries%2F8032293)

[Query results](https://dune.com/queries/8032293/12017350)[% of Stock Circulating Supp...](https://dune.com/queries/8032293/12017434)[Stock Supply Capture](https://dune.com/queries/8032293/12017435)[Lineage](https://dune.com/queries/8032293/lineage)

[Query results LONG: supply share per stock](https://dune.com/queries/8032293/12017350)

| stock | circulating_supply | held_in_long_pools | pct_of_supply | held_usd | stock_price_usd |
| --- | --- | --- | --- | --- | --- |
| NVDA | 59535.636 | 13961.811693025791 | 23.451184250430767 | 3025803.8301125495 | 216.72 |
| HIMS | 81361.475 | 42349.7400435352 | 52.0513425347011 | 1239800.0066726676 | 29.275268405382487 |
| SPCX | 41237.922 | 6643.818511084991 | 16.110943977936113 | 943654.7622219566 | 142.035 |
| MU | 2923.0529277799997 | 905.8438199364417 | 30.98964823139251 | 841953.6504184828 | 929.46889065 |
| AAPL | 11316.80270362 | 2221.911128014596 | 19.63373566019539 | 722074.1453146212 | 324.97885996 |
| TSLA | 7127.696999999999 | 1378.4980099970167 | 19.340019784749785 | 490648.7966982381 | 355.93 |
| GLD | 7738.462000000003 | 996.5813209607916 | 12.878286679714796 | 396860.9820067172 | 398.22237649819533 |
| TSM | 3103.4119999999994 | 945.1472077301893 | 30.455099346467353 | 391310.5558048588 | 414.02075 |
| MSFT | 3213.8810000000003 | 719.3161760441872 | 22.381543561948533 | 360168.8025070849 | 500.71 |
| MSTR | 10630.775 | 2783.2546262924257 | 26.181107457287222 | 345368.5000673745 | 124.088 |
| TTWO | 6547.858999999997 | 1099.494643982886 | 16.791666466594446 | 236998.60116841257 | 215.55230165550634 |
| SNDK | 962.901 | 153.35870973488122 | 15.926736989044691 | 234822.46528134026 | 1531.19745 |
| GOOGL | 5208.334000000001 | 649.1325106406941 | 12.463342608993472 | 219131.8160650472 | 337.5764 |
| PLTR | 7444.154999999999 | 1128.0376445774257 | 15.153333650057338 | 203078.69948927817 | 180.0283 |
| RDDT | 11320.761000000002 | 1245.550963052187 | 11.002360733984109 | 182046.6037554092 | 146.15749106669165 |
| INTC | 11833.041999999996 | 1876.9655081094606 | 15.862070869937428 | 166623.76520312575 | 88.77295 |
| RBLX | 13086.332000000002 | 3842.8220316141674 | 29.36515772039229 | 157747.0835407057 | 41.04980200564856 |
| AMZN | 7004.1269999999995 | 553.5043050416804 | 7.902545242850113 | 141210.0183022335 | 255.12 |
| USAR | 29402.296999999995 | 7581.472721943332 | 25.785307596693322 | 131212.54839867324 | 17.307 |
| GME | 101644.40000000002 | 6839.588383636332 | 6.728937731578257 | 128481.6677866085 | 18.785 |
| META | 2113.8570000000004 | 172.34387979351942 | 8.153052916707203 | 99592.35781628107 | 577.87 |
| SKHY | 3861.0000000000005 | 432.5715370208383 | 11.203614012453723 | 69879.26126470343 | 161.54382635984004 |
| MRNA | 1358.5930000000005 | 445.260580844836 | 32.773654865352306 | 69197.9100935823 | 155.40991740676077 |
| COIN | 6057.8060000000005 | 359.57015511577856 | 5.935649889015569 | 63500.898426295505 | 176.60225 |
| SPY | 15267.170000000002 | 80.24376928728168 | 0.5255968806745565 | 60954.37080715848 | 759.615 |

*   53 rows

*   
    *   2
    *   3

[![Image 2: @natan_benish2001](https://dune.com/_next/image?url=%2Fassets%2Favatar-fallback%2Fanon-09.png&w=32&q=75&dpl=dpl_AVadPP2B5UWR24VnXSDaBg3oA12P)@natan_benish2001](https://dune.com/natan_benish2001)

API 4h

About this query

# Fork with prompt

[Fork](https://dune.com/auth/register?next=%2Fqueries%2F8032293&onboarding=short)

Data sources

 11

*   [robinhood.logs](https://dune.com/data/robinhood.logs)
*   [robinhood.logs](https://dune.com/data/robinhood.logs)
*   [robinhood.logs](https://dune.com/data/robinhood.logs)
*   [tokens.transfers](https://dune.com/data/tokens.transfers)
*   [robinhood.logs](https://dune.com/data/robinhood.logs)
*   [robinhood.logs](https://dune.com/data/robinhood.logs)
*   [robinhood.logs](https://dune.com/data/robinhood.logs)
*   [robinhood.logs](https://dune.com/data/robinhood.logs)
*   [tokens.transfers](https://dune.com/data/tokens.transfers)
*   [robinhood.logs](https://dune.com/data/robinhood.logs)

[Show all](https://dune.com/queries/8032293/lineage)

Description

 AI

Robinhood stock tokens: percentage of circulating supply (mints minus burns) locked in LONG pools, with USD value of holdings and current stock price—tracks capital allocation across graduated and unmigrated v4 pools.

Show more

History

 2

*   Created 1 month ago
*   Updated 2 days ago

Dashboards

 1

*   [![Image 3: @natan_benish2001](https://dune.com/_next/image?url=%2Fassets%2Favatar-fallback%2Fanon-09.png&w=32&q=75&dpl=dpl_AVadPP2B5UWR24VnXSDaBg3oA12P)LONG on Robinhood Chain](https://dune.com/natan_benish2001/long-on-robinhood-chain)

Querying other queries

 5

*   [LONG: launches (foundation)](https://dune.com/queries/8032167)
*   [LONG: pools (foundation)](https://dune.com/queries/8032178)
*   [LONG: numeraire prices hourly (foundation)](https://dune.com/queries/8032188)
*   [LONG: swaps (foundation)](https://dune.com/queries/8032229)
*   [LONG: numeraire prices derived (foundation 3b)](https://dune.com/queries/8391616)

We use cookies to improve your experience on our site. By using this website you agree to our [Cookie Policy](https://dune.com/privacy).

Manage settings Accept

## Version history
