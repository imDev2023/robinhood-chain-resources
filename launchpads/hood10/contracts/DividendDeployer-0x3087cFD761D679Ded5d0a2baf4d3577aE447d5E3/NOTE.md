## What it does

The reflection-launch path.
`deployFor(poolId, minDistribution, maxCutBps)` deploys a `LaunchDividendTreasury` and a `CreatorFeeSplitter` for one pool, deriving the token and quote from `LaunchFactory.launches(poolId)` so a caller cannot point a pair at somebody else's launch.
The creator then calls `LaunchHook.transferCreator(poolId, splitter)` and the splitter accepts, which is the second and third transaction the create form warns about.
`MAX_CUT_BPS` is 3000: the pad may take up to 30% of the creator's fee lane on the way to holders.
Live state at capture: `owner` 0xfe2cF227e21C5FC54dcE8Bb65F7C1E1E90236862, `feeRecipient` 0x7e8ADA37D066a124Cd0A044c1209c48338c962fe.
Seven pairs deployed at capture (`_raw/blockscout/dividenddeployer-logs.json`).
