# Long - Dune query 8071980, rwa_token_registry (robinhood)

> Source: https://dune.com/queries/8071980
> Retrieved: 2026-09-02 (Jina Reader)
> Raw capture: `_raw/dune/query-8071980.md`

---

[Skip to content](https://dune.com/queries/8071980#skip-nav)

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

[Sign up](https://dune.com/auth/register?next=%2Fqueries%2F8071980)[Log in](https://dune.com/auth/login?next=%2Fqueries%2F8071980)

*   [Docs](https://docs.dune.com/)
*   [Pricing](https://dune.com/pricing)

*   [](https://dune.com/)

*   [Log in](https://dune.com/auth/login?next=%2Fqueries%2F8071980)

*   [Sign up](https://dune.com/auth/register?next=%2Fqueries%2F8071980)

# rwa_token_registry (robinhood)

[1](https://dune.com/auth/login?next=%2Fqueries%2F8071980)[Share](https://dune.com/auth/login?next=%2Fqueries%2F8071980)[Fork](https://dune.com/auth/register?next=%2Fqueries%2F8071980&onboarding=short)

[![Image 1: @adam_tehc](https://dune.com/_next/image?url=https%3A%2F%2Fprod-dune-media.s3.eu-west-1.amazonaws.com%2Fprofile_img_d3b19adc-4231-4b8e-bac6-170b20dd225e_tsZ5n.png&w=32&q=75)@adam_tehc](https://dune.com/adam_tehc)

Last run 24d ago in 3m 11 Updated 9d

*   [![Image 2: @adam_tehc](https://dune.com/_next/image?url=https%3A%2F%2Fprod-dune-media.s3.eu-west-1.amazonaws.com%2Fprofile_img_d3b19adc-4231-4b8e-bac6-170b20dd225e_oyamv.png&w=32&q=75)](https://dune.com/u/adam_tehc)

Query editor

*   [](https://dune.com/auth/login?next=%2Fqueries%2F8071980)

[](https://dune.com/queries/8071980/visuals/12058154)

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

WITH native AS(

SELECT varbinary_substring(l.data, 13, 20)AS token_address,

CAST(l.block_time AS date)AS first_date,

TRY(FROM_UTF8(varbinary_substring(l.data,

varbinary_to_bigint(varbinary_substring(l.data, 57, 8))+ 33,

varbinary_to_bigint(varbinary_substring(l.data,

varbinary_to_bigint(varbinary_substring(l.data, 57, 8))+ 25, 8)))))AS name,

TRY(FROM_UTF8(varbinary_substring(l.data,

varbinary_to_bigint(varbinary_substring(l.data, 89, 8))+ 33,

varbinary_to_bigint(varbinary_substring(l.data,

varbinary_to_bigint(varbinary_substring(l.data, 89, 8))+ 25, 8)))))AS symbol

FROM robinhood.logs l

WHERE l.block_date>=DATE'2026-06-01'

AND l.block_time>=TIMESTAMP'2026-06-01'

AND l.contract_address= 0x4783c67b63de2b358ac5951a7d41f47a38f3c046

AND l.topic0= 0xd9b0c6a1c0de228715ad0fa09f3259686ee84f8cc675e03ef7e47a9cdafa76d6

),

rialto_names AS(

SELECT ct.address AS token_address,

CAST(ct.block_time AS date)AS first_date,

MAX(TRY(FROM_UTF8(varbinary_substring(tr.input, 197,

varbinary_to_bigint(varbinary_substring(tr.input, 189, 8))))))AS name

FROM robinhood.creation_traces ct

JOIN robinhood.traces tr

ON tr."to"=ct.address

AND tr.block_date>=DATE'2026-06-01'

AND varbinary_starts_with(tr.input, 0x6cf1dbed)

WHERE ct.block_month>=DATE'2026-05-01'

AND ct."from"= 0x8bc71ae8eac8b25f30c2990930cc3a80e72e169e

GROUP BY 1, 2

),

unioned AS(

SELECT token_address,first_date,'robinhood'AS issuer,name,symbol FROM native

UNION ALL

SELECT token_address,first_date,'rialto_wrapped'AS issuer,name,CAST(NULL AS varchar)AS symbol FROM rialto_names

)

[Run](https://dune.com/auth/register?next=%2Fqueries%2F8071980&onboarding=short)

Query results

[](https://dune.com/auth/login?next=%2Fqueries%2F8071980)

[Query results](https://dune.com/queries/8071980/12058154)[Lineage](https://dune.com/queries/8071980/lineage)

[Query results rwa_token_registry (robinhood)](https://dune.com/queries/8071980/12058154)

| token_address | first_date | issuer | name | symbol | asset_class |
| --- | --- | --- | --- | --- | --- |
| 0x322f0929c4625ed5bad873c95208d54e1c003b2d | 2026-06-05 00:00:00 | robinhood | Tesla • Robinhood Token | TSLA | stock |
| 0xbef75684c43c4ea7bd18dd532a2244674ee8b926 | 2026-06-09 00:00:00 | robinhood | Nano Nuclear Energy • Robinhood Token | NNE | stock |
| 0xd0601ce157db5bdc3162bbac2a2c8af5320d9eec | 2026-06-09 00:00:00 | robinhood | NVIDIA • Robinhood Token | NVDA | stock |
| 0x82da4646242e1d962e96e932269dc644c94a9caa | 2026-06-09 00:00:00 | robinhood | Workday • Robinhood Token | WDAY | stock |
| 0x5e81213613b6b86eab4c6c50d718d34359459786 | 2026-06-09 00:00:00 | robinhood | Take-Two Interactive Software • Robinhood Token | TTWO | stock |
| 0xb8dbf92f9741c9ac1c32115e78581f23509916fd | 2026-06-09 00:00:00 | robinhood | Applied Digital • Robinhood Token | APLD | stock |
| 0x9b23573b156b52565012f5ce02cdf60afbaa70be | 2026-06-09 00:00:00 | robinhood | Penguin Solutions • Robinhood Token | PENG | stock |
| 0x47f93d52cbec7c6d2cfc080e154002370a60daea | 2026-06-09 00:00:00 | robinhood | ASML Holding NV • Robinhood Token | ASML | stock |
| 0x1af6446f07eb1d97c546afc8c9544cbdf3ad5137 | 2026-06-09 00:00:00 | robinhood | AST SpaceMobile • Robinhood Token | ASTS | stock |
| 0xeb30663bdff0622ef4e4e5cbb4e975f19f33f51d | 2026-06-09 00:00:00 | robinhood | Futu Holdings • Robinhood Token | FUTU | stock |
| 0xa8eb3bccbf2017ee7cbfb652eb51cf2e1b153289 | 2026-06-09 00:00:00 | robinhood | Xanadu Quantum • Robinhood Token | XNDU | stock |
| 0x666716999e75d2652398ff830bbc2e485946e140 | 2026-06-09 00:00:00 | robinhood | Arm Holdings plc • Robinhood Token | ARM | stock |
| 0xc583c60aef9dc401da72cec1b404743a93cea1cc | 2026-06-09 00:00:00 | robinhood | D-Wave Quantum • Robinhood Token | QBTS | stock |
| 0xcbb95bbf36099d34da091dc6fa6f49efa257cee3 | 2026-06-09 00:00:00 | robinhood | CleanSpark • Robinhood Token | CLSK | stock |
| 0x8ef20885f94e3d9bc7eb3080279188bd5ed7c08c | 2026-06-09 00:00:00 | robinhood | Lumentum • Robinhood Token | LITE | stock |
| 0x282e87451e10fa6679bc7d76c69be44cd3fc777c | 2026-06-09 00:00:00 | robinhood | Fluence Energy • Robinhood Token | FLNC | stock |
| 0x4e62068525ab11fe768e29dfd00ef909b9803016 | 2026-06-09 00:00:00 | robinhood | Lululemon • Robinhood Token | LULU | stock |
| 0x05b37fb53a299a1b874a619e1c4c404d52c36f4c | 2026-06-09 00:00:00 | robinhood | Reddit • Robinhood Token | RDDT | stock |
| 0x8cf07c5a878945185d327aaa6e33faa95f95e7bf | 2026-06-09 00:00:00 | robinhood | Celsius • Robinhood Token | CELH | stock |
| 0xf1953dab6fad537488d5a022361ffaa8b4c95ec6 | 2026-06-09 00:00:00 | robinhood | Innodata • Robinhood Token | INOD | stock |
| 0x558378e000d634a36593e338ebacdd6207640efe | 2026-06-09 00:00:00 | robinhood | IonQ • Robinhood Token | IONQ | stock |
| 0x4d21483a44bf67a86b77e3da301411880797d452 | 2026-06-09 00:00:00 | robinhood | Boeing • Robinhood Token | BA | stock |
| 0x4a0e65a3eccec6dbe60ae065f2e7bb85fae35eea | 2026-06-15 00:00:00 | robinhood | SpaceX • Robinhood Token | SPCX | stock |
| 0x5c90450bbb4273d7b2f17cf6917aeb237a569679 | 2026-06-10 00:00:00 | robinhood | Cerebras Systems • Robinhood Token | CBRS | stock |
| 0x15cd20759ce7f3285c29a319de2d1a2e098c6f43 | 2026-06-10 00:00:00 | robinhood | State Street Technology Select Sector SPDR ETF • Robinhood Token | XLK | etf |

*   296 rows

*   
    *   2
    *   ...
    *   12

[![Image 3: @adam_tehc](https://dune.com/_next/image?url=https%3A%2F%2Fprod-dune-media.s3.eu-west-1.amazonaws.com%2Fprofile_img_d3b19adc-4231-4b8e-bac6-170b20dd225e_tsZ5n.png&w=32&q=75)@adam_tehc](https://dune.com/adam_tehc)

API 24d

About this query

# Fork with prompt

[Fork](https://dune.com/auth/register?next=%2Fqueries%2F8071980&onboarding=short)

Data sources

 3

*   [robinhood.logs](https://dune.com/data/robinhood.logs)
*   [robinhood.creation_traces](https://dune.com/data/robinhood.creation_traces)
*   [robinhood.traces](https://dune.com/data/robinhood.traces)

Description

 AI

Robinhood tokenized asset catalog: Identifies on-chain tokens created by Robinhood and Rialto (wrapped assets) from June 2026 onward, extracting token names/symbols from contract creation logs and calls, then classifies them as treasury bills, commodities, ETFs, or stocks—excluding stablecoin variants.

Show more

History

 13

*   Created 1 month ago
*   Updated 9 days ago

Dashboards

 0

No dashboards yet

Querying other queries

 0

No referenced queries

We use cookies to improve your experience on our site. By using this website you agree to our [Cookie Policy](https://dune.com/privacy).

Manage settings Accept

## Version history
