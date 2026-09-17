# StreamableFeesLockerV2 - 0x7b6147ac3f615bdb764e7ebd5f517dac1ad163b8

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x7b6147ac3f615bdb764e7ebd5f517dac1ad163b8
Role: StreamableFeesLockerV2.
Verified: True (verified at 2026-07-01T19:42:04.437577Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 0.
Main file: src/lockers/StreamableFeesLockerV2.sol.
Source files written: 27 under `sources/`.
Creator: 0x6C852852BFa632d00CF5A91DFF466Cc1b8dB194f.
Creation tx: 0x8ff7d1d8b10b4c5f9531976d7b9a7c49e84790e41f197362be47708772c201c5.
Proxy type: None; implementations: [].

## Constructor arguments

- `poolManager_` (address): `0x8366a39CC670B4001A1121B8F6A443A643e40951`
- `owner_` (address): `0xEDeAa06E2eB42A5c19ce27c6cfFb36fd4fE1eDa8`

## Events

- Collect
- Lock
- MigratorApproval
- OwnershipTransferred
- Release
- Unlock
- UpdateBeneficiary

## State-changing functions

- `approveMigrator(address)`
- `collectFees(bytes32)`
- `lock(tuple,uint32,address,tuple[],tuple[])`
- `renounceOwnership()`
- `revokeMigrator(address)`
- `transferOwnership(address)`
- `unlockCallback(bytes)`
- `updateBeneficiary(bytes32,address)`

## View functions

- `approvedMigrators(address)`
- `getCumulatedFees0(bytes32)`
- `getCumulatedFees1(bytes32)`
- `getLastCumulatedFees0(bytes32,address)`
- `getLastCumulatedFees1(bytes32,address)`
- `getPoolKey(bytes32)`
- `getShares(bytes32,address)`
- `owner()`
- `poolManager()`
- `streams(bytes32)`
