# Long - Dune query 8032287, LONG: headline counters

> Source: https://dune.com/queries/8032287
> Retrieved: 2026-09-02 (Jina Reader)
> Raw capture: `_raw/dune/query-8032287.md`

---

-- LONG widget: headline counters (one row; each counter viz binds one column)

-- gross = every swap incl. protocol buyback legs; user = trader-initiated swaps only

WITH s AS(

SELECT*FROM query_8032229

)

SELECT

(SELECT SUM(amount_usd)FROM s)AS gross_volume_usd,

(SELECT SUM(amount_usd)FROM s WHERE NOT is_buyback)AS user_volume_usd,

(SELECT SUM(amount_usd)FROM s WHERE is_buyback)AS buyback_volume_usd,

(SELECT SUM(amount_usd)FROM s WHERE block_time>=NOW()-INTERVAL'24'HOUR)AS gross_volume_24h_usd,

(SELECT SUM(amount_usd)FROM s WHERE NOT is_buyback AND block_time>=NOW()-INTERVAL'24'HOUR)AS user_volume_24h_usd,

(SELECT SUM(amount_usd)FROM s WHERE block_time>=NOW()-INTERVAL'7'DAY)AS gross_volume_7d_usd,

(SELECT COUNT(*)FROM s WHERE NOT is_buyback)AS user_trades,

(SELECT COUNT(DISTINCT trader)FROM s WHERE NOT is_buyback)AS total_traders,

(SELECT COUNT(DISTINCT trader)FROM s WHERE NOT is_buyback AND block_time>=NOW()-INTERVAL'24'HOUR)AS traders_24h,

(SELECT COUNT(*)FROM query_8032167

WHERE(CASE WHEN numeraire= 0x0000000000000000000000000000000000000000

THEN 0x0bd7d308f8e1639fab988df18a8011f41eacad73 ELSE numeraire END)

IN(SELECT token FROM query_8032188 UNION SELECT token FROM query_8391616))AS tokens_launched,

(SELECT COUNT(DISTINCT numeraire)FROM s)AS stocks_traded
