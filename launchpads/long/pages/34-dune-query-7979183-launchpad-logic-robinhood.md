# Long - Dune query 7979183, launchpad_logic -- robinhood

> Source: https://dune.com/queries/7979183
> Retrieved: 2026-09-02 (Jina Reader)
> Raw capture: `_raw/dune/query-7979183.md`

---

WITH v2_pairs AS(

SELECT DISTINCT address AS token_address

FROM robinhood.creation_traces

WHERE"from"= 0x8bceaa40b9acdfaedf85adf4ff01f5ad6517937f

AND block_time>=TIMESTAMP'2026-01-01'

),

mints AS(

SELECT

contract_address AS token_address,

block_date,

topic2

FROM robinhood.logs

WHERE block_date>=DATE'2026-01-01'

AND topic0= 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef

AND topic1= 0x0000000000000000000000000000000000000000000000000000000000000000

AND topic3 IS NULL

),

first_mints AS(

SELECT

m.token_address,

MIN(m.block_date)AS first_date

FROM mints m

LEFT JOIN v2_pairs p ON m.token_address=p.token_address

WHERE p.token_address IS NULL

GROUP BY 1

),

noxa_tokens AS(

SELECT DISTINCT address AS token_address

FROM robinhood.creation_traces

WHERE"from"= 0xd9ec2db5f3d1b236843925949fe5bd8a3836fccb

AND block_time>=TIMESTAMP'2026-06-01'

),

trench_tokens AS(

SELECT DISTINCT address AS token_address

FROM robinhood.creation_traces

WHERE"from"= 0x2ecfb98bce4f3616115e4a2a7a2379af388dfbaa
