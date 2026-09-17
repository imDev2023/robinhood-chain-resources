# Long - Dune query 8391616, LONG: numeraire prices derived (foundation 3b)

> Source: https://dune.com/queries/8391616
> Retrieved: 2026-09-02 (Jina Reader)
> Raw capture: `_raw/dune/query-8391616.md`

---

-- LONG foundation 3b: numeraire_prices_derived (added 2026-08-20)

-- Hourly USD price for numeraires WITHOUT a Chainlink feed, derived from ON-CHAIN

-- price prints: Rialto/Arcus/RH settlements move stock token + USDG in one tx, so

-- every such tx is a price observation. Estimator per (tx, token) = MAX single

-- transfer leg (robust to router-hop duplication; SUM double-counts hops).

-- Validated 2026-08-20 vs the NVDA Chainlink feed (~1-2% err) and RH REST spot

-- (GLD -1.2%, SKHY +0.7%, TTWO +1.8%). Outlier gate: +/-10% band around the hourly

-- median kills launch-day snipe fills (MRNA p90 was 32x median on listing day).

-- Output shape IDENTICAL to query_8032188 (q3) so q4 can UNION them.

-- Scope note: AI and other launch-token/memecoin numeraires (HOODon, PONS, vanity

-- …1e18 copycats) are deliberately ABSENT — q4's inner price join therefore excludes

-- those pairs from the dashboard (Nate 2026-08-19/20).

-- RCAT/AMC/GLXY are real RH stock tokens traded on LONG but missing from the app

-- registry — included here, flagged upstream.

WITH watch(token,symbol,token_decimals,px_lo,px_hi)AS(VALUES

(0x43b07d15ce533bec5476d70c22a78a1b2b662155,'MRNA', 18, 40, 400)

,(0x1d11f0496982706c5e14a514d4e79f2e6bde4516,'DJT', 18, 2.5, 25)

,(0xccee82fe024c36fa15e1005ede3e9e4787e23d09,'HIMS', 18, 9.7, 97)

,(0x980dcf6766fa79f5cf0c4aadb3ab477ff15a9619,'IBM', 18, 70, 700)

,(0x116f00968269b7bfbad4109ce591d6e74c0601d4,'NET', 18, 84, 840)

,(0x5e81213613b6b86eab4c6c50d718d34359459786,'TTWO', 18, 72, 720)

,(0x84cab63bc87912e71ad199ff14a0ba45de68fef8,'SKHY', 18, 48, 484)

,(0xe0444ef8bf4ed74f74fd73686e2ddf4c1c5591e8,'NFLX', 18, 24, 242)

,(0x408c14038a04f7bd235329e26d2bf569ee20e250,'NU', 18, 4.3, 43)

,(0xf0c4bf4c582cb3836e98394b1d4e7b7281101be8,'RBLX', 18, 11.5, 115)

,(0x05b37fb53a299a1b874a619e1c4c404d52c36f4c,'RDDT', 18, 44, 438)

,(0x98e75885157c80992a8d41b696d8c9c6fb30a926,'SOFI', 18, 5.4, 54)

,(0xf23250dac154d05bb671cb0d0ebef3c635c79ce2,'UPS', 18, 31, 309)

,(0x9651342cea770ae9a2969ba2a52611523146aef9,'CCL', 18, 7.6, 76)

,(0x4ea005168d7f09a7a0ba9d1def21a479950e44c2,'COST', 18, 280, 2795)

,(0x822cc93ffd030293e9842c30bbd678f530701867,'BE', 18, 60, 600)

,(0xc9a981fee1f9dec688bb123ccdecc63d0debfc4e,'GLD', 18, 124, 1243)

,(0xa30fa36db767ad9ed3f7a60fc79526fb4d56d344,'CUSO', 18, 37, 375)

,(0x15cd20759ce7f3285c29a319de2d1a2e098c6f43,'XLK', 18, 55, 548)

,(0xfde6b5d9bb419b10c23268c74e369abff39c0460,'RCAT', 18, 2.8, 28)

,(0x05a3d1cd21d0c88145e82600e62e7e496e0f222b,'AMC', 18, 0.75, 7.5)
