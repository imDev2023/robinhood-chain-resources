## What it does

The whole launch path.
`launch`, `launchAndBuy` and `launchAndBuyWithEth` deploy a `LaunchToken`, open a Uniswap v4 pool keyed to `LaunchHook`, seed the entire supply as one locked one-sided position, register the pool's terms on the hook, and optionally execute the creator's first buy inside the same `unlock`.
There is no bonding curve contract and no graduation migration: the one-sided concentrated position is the curve.
`LP_FEE` is 0, so nothing accrues to the position and every fee is charged by the hook instead.
Quote assets are not allowlisted: `_assertQuoteLaunchable` refuses only a non-contract, an asset the QuoteRegistry classifies `UNSUPPORTED`, and anything whose `decimals()` reverts.
Live state at capture: `owner` 0xfe2cF227e21C5FC54dcE8Bb65F7C1E1E90236862, `paused` false, 81 `Launched` events (`_raw/rpc/launch-counts.txt`).
