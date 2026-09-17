# TokenLocker - 0xbd0e7a242a323e5e4799abe09b7516d9da5ea81d

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xbd0e7a242a323e5e4799abe09b7516d9da5ea81d
Role: TokenLocker.
Contract name: SentryTokenLocker.
Verified: True (verified at 2026-07-04T16:23:17.849453Z).
Compiler: v0.8.20+commit.a1b79de6, EVM paris, optimizer True runs 200.
Main file: src/SentryTokenLocker.sol.
Source files written: 1 under `sources/`.
Creator: 0xbF551eED83c7eaEE63854a2013Eb94f18600B7C5.
Creation tx: 0x582ad5e13d4656edf7f6c1cd54729dc83078bc8dca57d7959d1e0cb9fe997f8c.
Proxy type: None; implementations: [].

Ownerless ERC-20 timelock behind sentry.trading/lock. 509 locks as of 2026-09-02.

## Constructor arguments

None decoded.

## Events

- `LockBeneficiaryTransferred(uint256,address,address)`
- `LockExtended(uint256,uint64,uint64)`
- `TokensLocked(uint256,address,address,uint256,uint64)`
- `TokensWithdrawn(uint256,address,address,uint256)`

## State-changing functions

- `extendLock(uint256,uint64)`
- `lock(address,uint256,uint64,address)`
- `transferBeneficiary(uint256,address)`
- `withdraw(uint256)`

## View functions

- `getBeneficiaryLockIds(address)`
- `getLock(uint256)`
- `getTokenLockIds(address)`
- `lockCount()`
- `totalLocked(address)`
