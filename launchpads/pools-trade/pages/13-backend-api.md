# Pools.trade - backend API surface

> Source: https://pools.trade/api/trpc/* and https://pools.trade/entry-gateway/*
> Retrieved: 2026-09-03 (curl with a browser User-Agent; captures under `_raw/api/`)

---

The frontend talks to three back ends.

## 1. `pools.trade/api/trpc/*`, the launchpad's own tRPC router

Open, no key, no cookie, no signature.
Batched HTTP GET, tRPC v11 style: `?batch=1&input=<url-encoded JSON keyed by call index>`.

```bash
UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0 Safari/537.36"
curl -s -A "$UA" 'https://pools.trade/api/trpc/cca.listAuctions?batch=1&input=%7B%220%22%3A%7B%7D%7D'
curl -s -A "$UA" 'https://pools.trade/api/trpc/curve.listLaunches?batch=1&input=%7B%220%22%3A%7B%22sortBy%22%3A%22trending%22%7D%7D'
```

The home page issues one batched call for several procedures at once, for example
`api/trpc/cca.listAuctions,curve.listLaunches,curve.listLaunches,session.status,prices.getTokens?batch=1&input=...`.

Procedure names recovered from the shipped bundles:

| namespace | procedures |
| --- | --- |
| `cca` | `listAuctions`, `listAllAuctions`, `getAuction`, `getAuctionByAddress`, `getBidsHistoryPage`, `getTradesHistoryPage`, `getWalletBids`, `getWalletSnapshot`, `prepareBid`, `prepareClaim`, `prepareRefund`, `prepareExitAndClaim`, `estimateLaunchNetworkCost`, `checkDuplicateToken` |
| `curve` | `listLaunches`, `listLaunchesDeep`, `searchLaunches`, `getLaunchByAddress`, `listLaunchesByCreator`, `listLaunchesByBeneficiary`, `estimateLaunchNetworkCost` |
| `prices` | `getTokens`, `getHistories`, `getOhlc`, `getVolume`, `onPriceUpdate` |
| `session` | `status` |

`cca` covers Crowd Launch (auction) tokens and `curve` covers Instant Launch tokens.
The `prepare*` procedures build calldata for the client to sign, which is why the bid, claim and refund flows never need a bespoke ABI in the frontend.

Input validation is Zod and the error message names the field, which makes the schema easy to recover:

```json
[{"error":{"message":"[{\"expected\":\"string\",\"code\":\"invalid_type\",\"path\":[\"tokenAddress\"], ...}]",
  "code":-32600,"data":{"code":"BAD_REQUEST","httpStatus":400,"path":"curve.getLaunchByAddress","retryable":false}}}]
```

### `curve.listLaunches` record

`input={"0":{"sortBy":"trending"}}`; `sortBy` also accepts `volume`, `recency` and `linked-x`, and an invalid value returns a Zod error listing the accepted set (`_raw/api/api-trpc-curve.listLaunches-invalid-sortBy-error.json`).
Returns 100 records. Live capture: `_raw/api/live-curve.listLaunches-trending.json`.

Fields: `id`, `poolId`, `launchpadId`, `tokenAddress`, `tokenSymbol`, `tokenName`, `description`, `xUrl`, `xProfileImageUrl`, `xVerified`, `imageEmoji`, `imageHue`, `imageUrl`, `chainId`, `status`, `createdAt`, `fdvUsd`, `graduationTargetUsd`, `graduationProgress`, `holderCount`, `creatorAddress`, `creatorHandle`, `buyersLast1h`, `tierPlan`, `poolStats`, `poolPriceSeries`, `recentTrades`, `safety`, `isBlocked`.

`launchpadId` is the model discriminator and takes exactly two values, `uniswap-bonding-curve` (Instant Launch) and `uniswap-cca` (Crowd Launch).
`id` and `poolId` are the same 32-byte Uniswap v4 pool id.
`safety` carries a spam verdict and feature flags, for example `{"isSpam":false,"verdict":"Benign","features":["HIGH_TRADE_VOLUME","SIGNIFICANT_USD_RESERVES","VERIFIED_CONTRACT","DEX_PAID"]}`.

`graduationTargetUsd` is `50000` for every Instant Launch record in the live capture.
That is a display milestone driving the "Near graduation" tab; an Instant Launch has no on-chain graduation event and nothing migrates.

### `cca.listAuctions` record

Live capture: `_raw/api/live-cca.listAuctions.json`, 100 records.

Fields: `id`, `tokenAddress`, `tokenSymbol`, `tokenName`, `description`, `xUrl`, `xProfileImageUrl`, `xVerified`, `imageEmoji`, `imageHue`, `imageUrl`, `chainId`, `status`, `clearingPriceUsd`, `clearingPriceEth`, `clearingPriceQ96`, `floorPriceUsd`, `floorPriceQ96`, `tickSizeQ96`, `totalSupply`, `fdvUsd`, `raisedUsd`, `raisedEth`, `raisedUsdLast1h`, `graduationTargetUsd`, `graduationProgress`, `creatorAddress`, `creatorHandle`, `creatorFeeEnabled`, `bidderCount`, `startsAt`, `endsAt`, `auctionContractAddress`, `priceSeries`, `recentBids`, `isBlocked`.

`id` is `"<chainId>_<auctionContractAddress>"`, not a pool id.
`status` observed: `live`, `graduated`, `notGraduated`.
Across the 100 records `totalSupply` is `1000000000` in every case, `tickSizeQ96` is exactly 1% of `floorPriceQ96` in every case, and `endsAt - startsAt` is 4.00 hours in every case.

### `session.status`

```bash
curl -s 'https://pools.trade/api/trpc/session.status?batch=1&input=%7B%220%22%3A%7B%7D%7D'
{"result":{"data":{"sessionId":"unknown","needChallenge":true,"isLikelyBot":false,"source":"gateway"}}}
```

An unauthenticated caller is told a challenge is needed, and every read endpoint still answers.

## 2. `pools.trade/entry-gateway/*`, a proxy onto Uniswap's own services

Connect-RPC over HTTP POST. Service names seen in the home page network capture (`_raw/network-home.json`):

- `uniswap.platformservice.v1.SessionService/InitSession`
- `uniswap.platformservice.v1.SessionService/Challenge`
- `uniswap.platformservice.v1.SessionService/Verify`
- `uniswap.notificationservice.v1.EventSubscriptionService/Subscribe`
- `data.v1.DataApiService/GetTokenPrices`

These are Uniswap Labs platform services, proxied same-origin. The `uniswap.liquidity.v1.ChainId` protobuf enum, complete with `ROBINHOOD = 4663`, is compiled into `_raw/js/useCreatorFeeExecutor-44W_DATt.js`.

## 3. Third-party endpoints the app calls directly

- `https://browser-intake-datadoghq.com/api/v2/rum?...&ddtags=...env%3Aprod%2Cservice%3Arh-cca%2Cversion%3A80377a7` - Datadog RUM. The internal service name is `rh-cca`, that is, Robinhood CCA.
- `https://pools.trade/amplitude-proxy` - Amplitude analytics, proxied same-origin.
- `https://pools.trade/api/image/token/:address` - server-rendered token images.
- `https://pools.trade/__manifest?paths=...` - React Router lazy route discovery.

## Rate limiting and blocks

No rate limit was hit at the volumes used here (a few dozen requests).
A browser `User-Agent` was set on every call as a precaution; unlike Blockscout, `pools.trade` answered without one as well.
