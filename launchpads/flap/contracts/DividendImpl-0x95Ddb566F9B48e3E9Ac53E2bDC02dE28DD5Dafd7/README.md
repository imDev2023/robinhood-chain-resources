# DividendImpl-0x95Ddb566F9B48e3E9Ac53E2bDC02dE28DD5Dafd7

**Dividend implementation, verified**

- Address: `0x95Ddb566F9B48e3E9Ac53E2bDC02dE28DD5Dafd7`
- Contract name on Blockscout: `Dividend`
- Verified: yes
- Proxy type: `none`
- Creator: `0x8187F13ed6C7C9554AfE4Dd4C4D4960174846063`
- Creation tx: `0x51e6a049625c464de1d590d60a50f3ce779d4e68d728871d09c47f5e75fd5918`
- Compiler: `v0.8.26+commit.8a97fa7a`, optimizer on (99999 runs), EVM `cancun`
- License: `none`
- Explorer: <https://robinhoodchain.blockscout.com/address/0x95Ddb566F9B48e3E9Ac53E2bDC02dE28DD5Dafd7>

Holds the dividend accounting for a tax token: eligible balances, minimum share balance, and claimable amounts.

## Constructor arguments

- `weth_` (`address`): `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`
- `flapBlackHole_` (`address`): `0x00576E4Fb32296Cd973A0d413D0379609400DEad`

## Functions that matter for launching

- `accumulativeDividendOf(address)` returns `(uint256)`  [view]
- `distributeDividend(address[])` returns `(uint256)`  [nonpayable]
- `dividendToken()` returns `(address)`  [view]
- `excludedFromDividends(address)` returns `(bool)`  [view]
- `getMagnifiedDividendPerShare()` returns `(uint256)`  [view]
- `initialize(address,address,uint256)`  [nonpayable]
- `owner()` returns `(address)`  [view]
- `renounceOwnership()`  [nonpayable]
- `setDividendToken(address)`  [nonpayable]
- `taxToken()` returns `(address)`  [view]
- `totalDividendsDistributed()` returns `(uint256)`  [view]
- `transferOwnership(address)`  [nonpayable]
- `withdrawDividends()` returns `(bool)`  [nonpayable]
- `withdrawDividendsFor(address,bool)` returns `(bool)`  [nonpayable]
- `withdrawDividendsFor(address)` returns `(bool)`  [nonpayable]
- `withdrawableDividendOf(address)` returns `(uint256)`  [view]
- `withdrawableDividends(address)` returns `(uint256)`  [view]
- `withdrawnDividends(address)` returns `(uint256)`  [view]

## Events

- `FlapDividendAddressExcluded(address,address)`
- `FlapDividendAddressUnexcluded(address,address)`
- `FlapDividendDeposited(address,uint256,uint256)`
- `FlapDividendDistributed(address,address,uint256)`
- `FlapDividendPendingBalanceChanged(address,address,uint256)`
- `FlapDividendRewardDebtChanged(address,address,uint256)`
- `FlapDividendShareChanged(address,address,uint256,uint256)`
- `FlapDividendTokenUpdated(address,address,address)`
- `FlapDividendWithdrawalFailed(address,address,uint256)`
- `Initialized(uint8)`
- `OwnershipTransferred(address,address)`

## Files in this directory

- `abi.json`
- `address.json`
- `metadata.json`
- `methods-read.json`
- `sources`/
