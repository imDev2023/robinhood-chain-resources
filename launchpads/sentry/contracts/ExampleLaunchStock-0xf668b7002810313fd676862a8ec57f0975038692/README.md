# ExampleLaunchStock - 0xf668b7002810313fd676862a8ec57f0975038692

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xf668b7002810313fd676862a8ec57f0975038692
Role: ExampleLaunchStock.
Contract name: SentryTokenizedStocks.
Verified: False (verified at 2026-08-29T13:18:59.408092Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/SentryTokenizedStocks.sol.
Source files written: 1 under `sources/`.
Creator: None.
Creation tx: None.
Proxy type: None; implementations: [].

Silver Inu (SILVER INU), launched 2026-08-29 by `launchWithWhitelist` on the stock factory against SLV. Contract name SentryTokenizedStocks, the stock-paired token template.

## Constructor arguments

None decoded.

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
