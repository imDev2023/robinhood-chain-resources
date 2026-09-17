# Long - Dune query 8237276, LONG widget: stock-pair share

> Source: https://dune.com/queries/8237276
> Retrieved: 2026-09-02 (Jina Reader)
> Raw capture: `_raw/dune/query-8237276.md`

---

-- LONG widget: stock-pair share + share of ALL stock trading (one row; counters bind columns)

-- Displayed meme-free: "LONG share of stock pair volumes" / "LONG share of stock trading volume".

-- Chain-wide method copied from the RWA trading-volume dashboard (query_8071940):

-- dex.trades rows with exactly one tokenized-stock side (registry query_8071980); pair rows

-- have a launchpad token (classifier query_7979183, launchpad <> 'other') on the other side;

-- hourly-Chainlink fallback pricing (query_8076065) where Dune left amount_usd NULL; routed

-- legs of pad-routed trades excluded like the original; Rialto venue volume (txs to

-- 0x4262…c7e8, USDG quote transfers /1e6) added to the total-stock-trading denominator.

-- LONG legs = pad side in query_8032167 (both factory deployments) — exact, and unioned into

-- the pad set so LONG launches the heuristic classifier misses still count.

WITH stock_tokens AS(

SELECT token_address AS address FROM query_8071980 GROUP BY 1

),

long_tokens AS(

SELECT DISTINCT asset AS address FROM query_8032167

),

pad_tokens AS(

SELECT token_address AS address FROM query_7979183 WHERE launchpad<>'other'

UNION

SELECT address FROM long_tokens

),

pair_txs AS(

SELECT tx_hash

FROM(

SELECT d.tx_hash,

MAX(CASE WHEN s.address IS NOT NULL THEN 1 ELSE 0 END)AS has_stock,

MAX(CASE WHEN p.address IS NOT NULL THEN 1 ELSE 0 END)AS has_pad

FROM dex.trades d

CROSS JOIN UNNEST(ARRAY[d.token_bought_address,d.token_sold_address])AS u(tok)

LEFT JOIN stock_tokens s ON s.address=u.tok

LEFT JOIN pad_tokens p ON p.address=u.tok

WHERE d.blockchain='robinhood'

AND d.block_date>=DATE'2026-07-01'

GROUP BY 1

)

WHERE has_stock= 1 AND has_pad= 1
