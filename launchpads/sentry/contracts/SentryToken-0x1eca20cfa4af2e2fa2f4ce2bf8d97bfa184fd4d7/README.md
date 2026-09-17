# SentryToken - 0x1eca20cfa4af2e2fa2f4ce2bf8d97bfa184fd4d7

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x1eca20cfa4af2e2fa2f4ce2bf8d97bfa184fd4d7
Role: SentryToken.
Contract name: SentryTokenRelaunch.
Verified: True (verified at 2026-07-28T15:48:08.575281Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/SentryTokenRelaunch.sol.
Source files written: 1 under `sources/`.
Creator: 0xbF551eED83c7eaEE63854a2013Eb94f18600B7C5.
Creation tx: 0xd03ad7e3162d24cba83e78ef830cea8f3a12b4a3f4a77b828230d49091776bc2.
Proxy type: None; implementations: [].

The SENTRY platform token, contract name SentryTokenRelaunch. Fixed 1B supply, WETH reflections, migration lock and an on-chain extension vote.

## Constructor arguments

- `_name` (string): `Sentry`
- `_symbol` (string): `SENTRY`
- `_deployer` (address): `0xbF551eED83c7eaEE63854a2013Eb94f18600B7C5`
- `_treasury` (address): `0xFFC93474D99f07e8d0F1c7c8c5B93BaA2feDDd07`
- `_founder` (address): `0x7171E64E979265aeD6588577D1c6b60A701d7866`
- `_rewardToken` (address): `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`
- `_excluded` (address[]): `['0x8366a39CC670B4001A1121B8F6A443A643e40951']`

## Events

- `Approval(address,address,uint256)`
- `DividendClaimed(address,uint256)`
- `DividendExclusionSet(address,bool)`
- `ExitVenueSet(address,bool)`
- `MigrationLockSet(address,bool)`
- `OwnershipRenounced(address)`
- `RewardsDistributed(uint256,uint256)`
- `Transfer(address,address,uint256)`
- `VoteCast(address,bool,uint256)`

## State-changing functions

- `airdrop(address[],uint256[])`
- `airdropLocked(address[],uint256[])`
- `approve(address,uint256)`
- `claim()`
- `notifyReward()`
- `renounceOwnership()`
- `setDividendExcluded(address,bool)`
- `setExitVenue(address,bool)`
- `transfer(address,uint256)`
- `transferFrom(address,address,uint256)`
- `unlock(address)`
- `vote(bool)`

## View functions

- `AUG_3()`
- `FOUNDER_CUT()`
- `OCT_3()`
- `TREASURY_CUT()`
- `accountedRewards()`
- `accumulativeDividendOf(address)`
- `allowance(address,address)`
- `balanceOf(address)`
- `decimals()`
- `dividendExcluded(address)`
- `exitVenue(address)`
- `extensionPassing()`
- `founder()`
- `hasVoted(address)`
- `magDividendPerShare()`
- `migrationAllocation(address)`
- `migrationLocked(address)`
- `name()`
- `noVotes()`
- `owner()`
- `pendingUndistributed()`
- `rewardToken()`
- `symbol()`
- `totalSupply()`
- `trackedSupply()`
- `treasury()`
- `unlockTime()`
- `withdrawableDividendOf(address)`
- `withdrawnDividends(address)`
- `yesVotes()`
