# Doppler - token page, JOHNDOG on Robinhood Chain

> Source: https://app.doppler.lol/tokens/robinhood/0x64bcf4aa85559526cff0528bcdc0cb9d3ea41e18
> Retrieved: 2026-09-02 (agent-browser read, session lp-doppler)

---

Screenshot: `screenshots/23-app-token-johndog-robinhood.png`.
A representative Doppler token page on chain 4663.
The URL shape is `/tokens/<chain slug>/<token address>`; the chain slug for Robinhood Chain is `robinhood`.

Page furniture, top to bottom: a ticker strip of movers, the token header with its chain badge (`Robinhood`) and application badge (`Long`), description, `Contract:` and `Creator:` short addresses, a Market cap / Liquidity / Volume (24h) row, a `Top activity` list of recent buyer and seller addresses with signed dollar amounts, a Chart / Pulse toggle, and a Buy / Sell panel.

Header stats read Market cap $993.6K, Liquidity $283.4K, Volume (24h) $5.9M.
The right rail shows Price `$0.0(3)9936`, Created `14h ago`, CA `0x64bc ... 1e18` and Creator `0x9b98 ... bb38`, each with a copy button.

The Buy panel offers preset amounts 0.01, 0.05, 0.1, 0.5, 1, a currency chip reading `ETH`, `Receiving 27,660.06207 JOHNDOG`, and `Fee 1.12%`.
A gear icon opens the slippage setting.
Its submit control is `Connect wallet`.

Two details worth carrying forward.

The chart's own currency toggle reads `USD / SGOV`, and the indexer confirms this asset's `numeraire` is `0x92fd66527192e3e61d4ddd13322aa222de86f9b5`, the SGOV stock token, not ETH.
So the pool is JOHNDOG/SGOV while the Buy panel still quotes in ETH; the app prices the pair by reading Uniswap v3 through its own RPC proxy.

The GeckoTerminal chart is titled `JOHNDOG/USD - 1s - Bankr (Robinhood)`, which labels the venue `Bankr`.
That contradicts the Doppler app's own `Long` badge on this token and the indexer's integrator `0x92d435c96e63c43e12d6d0ab28f6b0b04072f765`.
GeckoTerminal appears to label every Doppler pool on this chain `Bankr`; the app badge and the indexer are the reliable sources.

While this page loaded, the app called:

- `GET https://app.doppler.lol/api/metadata/robinhood/0x64bcf4aa85559526cff0528bcdc0cb9d3ea41e18`
- `GET https://app.doppler.lol/api/social/recent-buyers/robinhood/0x64bcf4aa85559526cff0528bcdc0cb9d3ea41e18`
- `GET https://app.doppler.lol/api/upcoming-auctions?tokenAddress=0x64bc...1e18`
- `POST https://indexer-prod.doppler.lol/` with `ScheduledLaunchDateV4PoolConfigQuery`
- `GET https://rc-api-rc.up.railway.app/api/tokens/eip155%3A4663/0x64bc...1e18`, `/api/launches/eip155%3A4663/0x64bc...1e18/state`, `/api/markets/eip155%3A4663/<v4 pool id>`
- `GET https://app.geckoterminal.com/api/p1/candlesticks/...` for the chart

Full list and bodies: `_raw/har-api/`, HAR at `_raw/network/app-session.har`.

## Rendered text

```text
Home

Create token

Portfolio

Menu

$JOHNDOG

John Dog

Robinhood

Long

+4853.51%

Connect

JOHNDOG·John Dog

MC$947K

4853.51%

S

SETZ·SETZ

MC$320K

2973.33%

DEBTCOIN·Debtcoin

MC$432K

2202.89%

CUM·Cummingtonite

MC$304K

1669.40%

KOLI·KOLI

MC$205K

970.63%

MEOW·AMD

MC$185K

842.48%

AAPLDOG·Apple Dog

MC$195K

817.81%

BOMBA·Bombardilo

MC$318K

599.87%

MONITOR·The Situation

MC$129K

514.27%

BALD

B

BALD·BALD

MC$127K

480.53%

JOHNDOG·John Dog

MC$947K

4853.51%

SETZ

S

SETZ·SETZ

MC$320K

2973.33%

DEBTCOIN·Debtcoin

MC$432K

2202.89%

CUM·Cummingtonite

MC$304K

1669.40%

KOLI·KOLI

MC$205K

970.63%

MEOW·AMD

MC$185K

842.48%

AAPLDOG·Apple Dog

MC$195K

817.81%

BOMBA·Bombardilo

MC$318K

599.87%

MONITOR·The Situation

MC$129K

514.27%

BALD

B

BALD·BALD

MC$127K

480.53%

Long

Robinhood

# $JOHNDOG

John Dog

Treasury Dog doesn’t chase pumps, he chases yield.

Contract: 0x64bc...1e18Creator: 0x9b98...bb38

Contract: 0x64bc...1e18Creator: 0x9b98...bb38

Market cap

$K

Liquidity

$K

Volume (24h)

$M

Market cap

$K

Liquidity

$K

Volume (24h)

$M

Top activity

9334

10551

View all

E

0x4337…1131

+$4.40K

D

0x4337…d995

+$3.50K

E

0x4337…f038

+$1.40K

E

0x90e8…5d33

+$1.10K

D

0x18dd…8e25

-$1.00K

D

0x67d6…60e4

-$979

D

0xd949…e607

+$862

B

0x1bc0…764a

-$733

Chart

Pulse

Buy

Sell

AmountBalance - ETH

ETH

0.010.050.10.51

Receiving

25,380.363821 JOHNDOG

Fee

0

0123456789

.

0

0123456789

0

0123456789

%

Connect wallet

Price

$0.039468

Created13h ago

CA

0x64bc...1e18

Creator

0x9b98...bb38

Trade token

© Doppler 2026

How it works

X.comTelegramDocsMore

$JOHNDOG - John Dog | Doppler
```
