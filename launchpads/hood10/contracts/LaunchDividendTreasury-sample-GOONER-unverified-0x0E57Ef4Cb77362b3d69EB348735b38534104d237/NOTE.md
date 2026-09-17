## Identified by selector matching

Unverified because it is deployed with `new` by `DividendDeployer`, which Blockscout does not match to the deployer's verified sources.
Its creator is 0x3087cFD761D679Ded5d0a2baf4d3577aE447d5E3 (`DividendDeployer`) and `PairDeployed` names it as the treasury for pool 0x5e5b5fc6d7e12c8c905cff6763b0c481e47e6ae46461e5c6b154f543dd0b5c43, token GOONER 0x51E7bf39c6Cf1A7F53DdfaA5dB346c69994511F2 (`_raw/blockscout/dividenddeployer-logs.json`).

Selectors resolved from bytecode (`_raw/blockscout/selectors-launchdividendtreasury*.`) match `LaunchDividendTreasury.sol` exactly: `commitRoot`, `openClaims`, `claim`, `previewClaim`, `pushBatch`, `closePeriod`, `settleExpired`, `getPeriod`, `currentPeriodId`, `reserved`, `unreserved`, `minDistribution`, `setMinDistribution`, `keeper`, `setKeeper`, `quote`, `sweep`, Ownable2Step.
Readable source for the same code is in `../DividendDeployer-0x3087cFD761D679Ded5d0a2baf4d3577aE447d5E3/sources/src/LaunchDividendTreasury.sol`.
