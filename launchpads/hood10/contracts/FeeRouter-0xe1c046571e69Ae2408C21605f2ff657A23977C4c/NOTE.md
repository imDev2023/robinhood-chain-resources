## What it does, and why it is no longer in the path

Written to convert the launchpad's 1% platform fee into WETH and split it `DIVIDEND_SHARE_BPS` = 7000 to `dividendSink` and the rest to `protocolTreasury`, with a sandwich defence built from per-sale depth caps rather than an oracle.
Its live config still reads `dividendSink` 0x9f3edbfAE8014d55E328b6Dd966C6C95E75f6210, `protocolTreasury` 0xfe2cF227e21C5FC54dcE8Bb65F7C1E1E90236862, `bountyBps` 0 (`_raw/rpc/live-state.txt`).

**It is not the hook's fee router any more.**
`LaunchHook.RouterUpdated` fired twice: to this contract at block 49311480 on 2026-08-29, and away from it at block 49485132 the same evening.
Every one of the 117 `PlatformCollected` events since names the EOA 0xbd40E138 as the collector (`_raw/rpc/hook-fee-events.txt`), so the 70/30 split this contract enforces is not what happens today.
