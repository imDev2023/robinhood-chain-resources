# Long - Dune query 8071940, RWA on-chain trading volume

> Source: https://dune.com/queries/8071940
> Retrieved: 2026-09-02 (Jina Reader)
> Raw capture: `_raw/dune/query-8071940.md`

---

[Skip to content](https://dune.com/queries/8071940#skip-nav)

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

[Sign up](https://dune.com/auth/register?next=%2Fqueries%2F8071940)[Log in](https://dune.com/auth/login?next=%2Fqueries%2F8071940)

*   [Docs](https://docs.dune.com/)
*   [Pricing](https://dune.com/pricing)

*   [](https://dune.com/)

*   [Log in](https://dune.com/auth/login?next=%2Fqueries%2F8071940)

*   [Sign up](https://dune.com/auth/register?next=%2Fqueries%2F8071940)

# RWA on-chain trading volume

[1](https://dune.com/auth/login?next=%2Fqueries%2F8071940)[Share](https://dune.com/auth/login?next=%2Fqueries%2F8071940)[Fork](https://dune.com/auth/register?next=%2Fqueries%2F8071940&onboarding=short)

[![Image 1: @adam_tehc](https://dune.com/_next/image?url=https%3A%2F%2Fprod-dune-media.s3.eu-west-1.amazonaws.com%2Fprofile_img_d3b19adc-4231-4b8e-bac6-170b20dd225e_tsZ5n.png&w=32&q=75)@adam_tehc](https://dune.com/adam_tehc)

Last run 2h ago in 12m 214 Updated 8d

*   [![Image 2: @adam_tehc](https://dune.com/_next/image?url=https%3A%2F%2Fprod-dune-media.s3.eu-west-1.amazonaws.com%2Fprofile_img_d3b19adc-4231-4b8e-bac6-170b20dd225e_oyamv.png&w=32&q=75)](https://dune.com/u/adam_tehc)

Query editor

*   [](https://dune.com/auth/login?next=%2Fqueries%2F8071940)

[](https://dune.com/queries/8071940/visuals/12058107)

999

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

WITH stock_tokens AS(

SELECT token_address AS address,asset_class FROM query_8071980

),

pad_tokens AS(

SELECT token_address AS address FROM query_7979183 WHERE launchpad<>'other'

),

rialto_txs AS(

SELECT hash AS tx_hash

FROM robinhood.transactions

WHERE block_date>=DATE'2026-07-10'

AND"to"= 0x4262efbd176f02824af27010bea218429c33c7e8

),

venue_stock_txs AS(

SELECT l.tx_hash,

MAX_BY(s.asset_class,varbinary_to_uint256(varbinary_substring(l.data, 1, 32)))AS asset_class

FROM robinhood.logs l

JOIN rialto_txs r ON r.tx_hash=l.tx_hash

JOIN stock_tokens s ON s.address=l.contract_address

WHERE l.block_date>=DATE'2026-07-10'

AND l.block_time>=DATE'2026-07-10'

AND l.topic0= 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef

GROUP BY 1

),

raw_venue_tx AS(

SELECT vs.asset_class,l.block_date,l.tx_hash,

MAX(varbinary_to_uint256(varbinary_substring(l.data, 1, 32))/ 1e6)AS quote_amt

FROM robinhood.logs l

JOIN venue_stock_txs vs ON vs.tx_hash=l.tx_hash

WHERE l.block_date>=DATE'2026-07-10'

AND l.block_time>=DATE'2026-07-10'

AND l.block_date<CURRENT_DATE

AND l.topic0= 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef

AND l.contract_address= 0x5fc5360d0400a0fd4f2af552add042d716f1d168

GROUP BY 1, 2, 3

),

pair_txs AS(

[Run](https://dune.com/auth/register?next=%2Fqueries%2F8071940&onboarding=short)

Query results

[](https://dune.com/auth/login?next=%2Fqueries%2F8071940)

[Query results](https://dune.com/queries/8071940/12058107)[Bar chart](https://dune.com/queries/8071940/12058112)[Lineage](https://dune.com/queries/8071940/lineage)

[Query results RWA on-chain trading volume](https://dune.com/queries/8071940/12058107)

| block_date | series | volume_usd |
| --- | --- | --- |
| 2026-07-10 00:00:00 | ETFs & treasuries | 13350.77519773999 |
| 2026-07-10 00:00:00 | commodities | 4530.217281999998 |
| 2026-07-10 00:00:00 | stock trading (spot) | 674554.9665541103 |
| 2026-07-11 00:00:00 | ETFs & treasuries | 43542.619870511335 |
| 2026-07-11 00:00:00 | commodities | 7667.604980669287 |
| 2026-07-11 00:00:00 | stock trading (spot) | 2662393.008539737 |
| 2026-07-12 00:00:00 | ETFs & treasuries | 56784.461062208036 |
| 2026-07-12 00:00:00 | commodities | 10254.059315999997 |
| 2026-07-12 00:00:00 | memecoin × stock pairs | 0.7132165863574043 |
| 2026-07-12 00:00:00 | stock trading (spot) | 2049756.6053228555 |
| 2026-07-13 00:00:00 | ETFs & treasuries | 59461.4336613076 |
| 2026-07-13 00:00:00 | commodities | 346442.92971106665 |
| 2026-07-13 00:00:00 | memecoin × stock pairs | 0.39051400023493055 |
| 2026-07-13 00:00:00 | stock trading (spot) | 2563208.356757493 |
| 2026-07-14 00:00:00 | ETFs & treasuries | 64443.27909947311 |
| 2026-07-14 00:00:00 | commodities | 401112.20289599994 |
| 2026-07-14 00:00:00 | memecoin × stock pairs | 1748182.9593245315 |
| 2026-07-14 00:00:00 | stock trading (spot) | 2676422.9344020816 |
| 2026-07-15 00:00:00 | ETFs & treasuries | 620919.2752138668 |
| 2026-07-15 00:00:00 | commodities | 1152151.9904674115 |
| 2026-07-15 00:00:00 | memecoin × stock pairs | 899859.8879556523 |
| 2026-07-15 00:00:00 | stock trading (spot) | 3164866.6130533447 |
| 2026-07-16 00:00:00 | ETFs & treasuries | 112192.47280771195 |
| 2026-07-16 00:00:00 | commodities | 780662.0541820194 |
| 2026-07-16 00:00:00 | memecoin × stock pairs | 227835.913980315 |

*   214 rows

*   
    *   2
    *   ...
    *   9

[![Image 3: @adam_tehc](https://dune.com/_next/image?url=https%3A%2F%2Fprod-dune-media.s3.eu-west-1.amazonaws.com%2Fprofile_img_d3b19adc-4231-4b8e-bac6-170b20dd225e_tsZ5n.png&w=32&q=75)@adam_tehc](https://dune.com/adam_tehc)

API 2h

About this query

# Fork with prompt

[Fork](https://dune.com/auth/register?next=%2Fqueries%2F8071940&onboarding=short)

Data sources

 15

*   [robinhood.logs](https://dune.com/data/robinhood.logs)
*   [robinhood.creation_traces](https://dune.com/data/robinhood.creation_traces)
*   [robinhood.traces](https://dune.com/data/robinhood.traces)
*   [robinhood.creation_traces](https://dune.com/data/robinhood.creation_traces)
*   [robinhood.logs](https://dune.com/data/robinhood.logs)
*   [robinhood.traces](https://dune.com/data/robinhood.traces)
*   [robinhood.transactions](https://dune.com/data/robinhood.transactions)
*   [robinhood.logs](https://dune.com/data/robinhood.logs)
*   [dex.trades](https://dune.com/data/dex.trades)
*   [robinhood.logs](https://dune.com/data/robinhood.logs)

[Show all](https://dune.com/queries/8071940/lineage)

Description

 AI

Robinhood marketplace trading volume segmented by asset class (stock spot trading, commodities, ETFs & treasuries, memecoin × stock pairs), combining DEX trades and direct venue transactions since July 10, 2026.

Show more

History

 23

*   Created 1 month ago
*   Updated 8 days ago

Dashboards

 2

*   [![Image 4: @adam_tehc](https://dune.com/_next/image?url=https%3A%2F%2Fprod-dune-media.s3.eu-west-1.amazonaws.com%2Fprofile_img_d3b19adc-4231-4b8e-bac6-170b20dd225e_tsZ5n.png&w=32&q=75)the robinhood trenches](https://dune.com/adam_tehc/the-robinhood-trenches)
*   [![Image 5: @ronaldo1234](https://dune.com/_next/image?url=%2Fassets%2Favatar-fallback%2Fanon-03.png&w=32&q=75&dpl=dpl_AVadPP2B5UWR24VnXSDaBg3oA12P)V](https://dune.com/ronaldo1234/vralsnfsd)

Querying other queries

 3

*   [launchpad_logic -- robinhood](https://dune.com/queries/7979183)
*   [rwa_token_registry (robinhood)](https://dune.com/queries/8071980)
*   [stock_prices (robinhood)](https://dune.com/queries/8076065)

We use cookies to improve your experience on our site. By using this website you agree to our [Cookie Policy](https://dune.com/privacy).

Manage settings Accept

## Version history
