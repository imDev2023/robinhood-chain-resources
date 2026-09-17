# ExampleLaunchStockChill - 0xf699aea8a333202a7dc610abc664c213c9dc4111

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xf699aea8a333202a7dc610abc664c213c9dc4111
Role: ExampleLaunchStockChill.
Contract name: SentryTokenizedStocks.
Verified: True (verified at 2026-07-21T20:21:06.818933Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/SentryTokenizedStocks.sol.
Source files written: 1 under `sources/`.
Creator: 0xd0A93885a387e3a8a14dd82776CF9104a3676b3A.
Creation tx: 0x863c18ba9081579a005039f2cc1893ea76516ced5ed5943730ca76399e0408b1.
Proxy type: None; implementations: [].

Netflix and Chill (CHILL), the highest-volume Sentry launch, paired against NFLX.

## Constructor arguments

- `_name` (string): `Netflix and Chill`
- `_symbol` (string): `CHILL`
- `_deployer` (address): `0xd0A93885a387e3a8a14dd82776CF9104a3676b3A`
- `_rewardToken` (address): `0xE0444EF8BF4eD74f74FD73686e2ddF4C1c5591E8`
- `_excluded` (address[]): `['0x8366a39CC670B4001A1121B8F6A443A643e40951', '0xd0A93885a387e3a8a14dd82776CF9104a3676b3A']`

## Events

- `Approval(address,address,uint256)`
- `DividendClaimed(address,uint256)`
- `DividendExclusionSet(address,bool)`
- `RewardsDistributed(uint256,uint256)`
- `Transfer(address,address,uint256)`

## State-changing functions

- `approve(address,uint256)`
- `claim()`
- `notifyReward()`
- `setDividendExcluded(address,bool)`
- `transfer(address,uint256)`
- `transferFrom(address,address,uint256)`

## View functions

- `accountedRewards()`
- `accumulativeDividendOf(address)`
- `allowance(address,address)`
- `balanceOf(address)`
- `decimals()`
- `dividendExcluded(address)`
- `factory()`
- `magDividendPerShare()`
- `name()`
- `owner()`
- `pendingUndistributed()`
- `rewardToken()`
- `symbol()`
- `totalSupply()`
- `trackedSupply()`
- `withdrawableDividendOf(address)`
- `withdrawnDividends(address)`
