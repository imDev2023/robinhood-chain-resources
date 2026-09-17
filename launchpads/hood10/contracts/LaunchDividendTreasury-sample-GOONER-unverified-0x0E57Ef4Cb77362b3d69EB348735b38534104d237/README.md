# LaunchDividendTreasury-sample-GOONER-unverified - 0x0E57Ef4Cb77362b3d69EB348735b38534104d237

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x0E57Ef4Cb77362b3d69EB348735b38534104d237
Role: LaunchDividendTreasury-sample-GOONER-unverified.
Contract name: unknown (unverified).
Verified: None (verified at None).
Compiler: None, EVM None, optimizer None runs None.
Main file: None.
Sources: none (unverified); `bytecode.hex` holds the deployed bytecode.
Creator: 0x3087cFD761D679Ded5d0a2baf4d3577aE447d5E3.
Creation tx: 0xec241d073fec00d878d2456fb15d2369aa2a1614a06e7fc3b60a5af2b20c940d.
Proxy type: None; implementations: [].
External libraries: none.

## Identified by selector matching

Unverified because it is deployed with `new` by `DividendDeployer`, which Blockscout does not match to the deployer's verified sources.
Its creator is 0x3087cFD761D679Ded5d0a2baf4d3577aE447d5E3 (`DividendDeployer`) and `PairDeployed` names it as the treasury for pool 0x5e5b5fc6d7e12c8c905cff6763b0c481e47e6ae46461e5c6b154f543dd0b5c43, token GOONER 0x51E7bf39c6Cf1A7F53DdfaA5dB346c69994511F2 (`_raw/blockscout/dividenddeployer-logs.json`).

Selectors resolved from bytecode (`_raw/blockscout/selectors-launchdividendtreasury*.`) match `LaunchDividendTreasury.sol` exactly: `commitRoot`, `openClaims`, `claim`, `previewClaim`, `pushBatch`, `closePeriod`, `settleExpired`, `getPeriod`, `currentPeriodId`, `reserved`, `unreserved`, `minDistribution`, `setMinDistribution`, `keeper`, `setKeeper`, `quote`, `sweep`, Ownable2Step.
Readable source for the same code is in `../DividendDeployer-0x3087cFD761D679Ded5d0a2baf4d3577aE447d5E3/sources/src/LaunchDividendTreasury.sol`.

## Constructor arguments

None decoded.

## Events

None.

## State-changing functions

None.

## View functions

None.
