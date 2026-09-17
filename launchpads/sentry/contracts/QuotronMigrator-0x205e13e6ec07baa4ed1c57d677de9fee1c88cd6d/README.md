# QuotronMigrator - 0x205e13e6ec07baa4ed1c57d677de9fee1c88cd6d

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x205e13e6ec07baa4ed1c57d677de9fee1c88cd6d
Role: QuotronMigrator.
Contract name: QuotronMigrator.
Verified: True (verified at 2026-08-13T15:22:49.119799Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/v2/QuotronMigrator.sol.
Source files written: 1 under `sources/`.
Creator: 0x7171E64E979265aeD6588577D1c6b60A701d7866.
Creation tx: 0x9473553cbb1e92b2b90cdeddccd8fe49a898665c8ae2e1ebb14207940375ee91.
Proxy type: None; implementations: [].

Quotrons V1 to V2 migrator.

## Constructor arguments

- `legacy_` (address): `0x40686524e56AfF0F1446958725dCF6e6dA5381E6`
- `legacyMirror_` (address): `0xbde7BEc47cbFc689e5E952B6cdD113A500abcd83`
- `legacyReflections_` (address): `0x666A51Eb731a9CF79d97B4A9c64cD5a4806c877C`
- `v2_` (address): `0x5a86828Efd322bfb16d93cFeD16EE9BC14940D7F`
- `v2Reflections_` (address): `0xe04fba61FD54Ba78Dd450A30d8Af40167aF5d3Ec`
- `snapshotBlock_` (uint256): `34984482`
- `snapshotRoot_` (bytes32): `0x1c28b8292e4784ff5cd5209dae8e8667d0648c7748c85ce09b9449af0a1a0cde`
- `distributionCap_` (uint256): `3925448872639031210668`

## Events

- `DistributionFinalized(uint256)`
- `FractionalMigrated(address,uint256)`
- `GenesisDistributed(uint8,address,uint256,uint256,uint256)`
- `IdClaimAssigned(uint256,address,address,bytes32)`
- `IdClaimFollowsToken(uint256,address,address)`
- `IdClaimTransferred(uint256,address,address)`
- `IdMigrated(uint8,address,uint256,uint256)`
- `LegacyRewardDeferred(uint256)`
- `LegacyRewardMigrated(uint256,address,uint256)`
- `Paused(bool)`
- `RestitutionClaimed(address,uint256,uint256)`

## State-changing functions

- `assignIdClaim(uint8,uint256,uint256,address,bytes32[])`
- `assignIdClaimToToken(uint8,uint256,uint256,bytes32[])`
- `claimRestitutionDark(uint256,uint256,bytes32[])`
- `completeDepositedId(uint8,address,uint256,uint256,bytes32[])`
- `distributeBatch(tuple[])`
- `finalizeDistribution()`
- `makeIdClaimFollowToken(uint256)`
- `migrateFractional(uint256,bytes32[])`
- `migrateId(uint8,address,uint256,uint256,bytes32[])`
- `retryLegacyRewards(uint256)`
- `setPaused(bool)`
- `transferIdClaim(uint256,address)`
- `transferOwnership(address)`

## View functions

- `INCIDENT_ATTACKER()`
- `INCIDENT_OPERATOR()`
- `INCIDENT_POISON_SEED()`
- `KIND_DARK()`
- `KIND_FRACTIONAL()`
- `KIND_HARDWIRED()`
- `KIND_RESTITUTION_DARK()`
- `LEAF_DOMAIN()`
- `distributionCap()`
- `distributionFinalized()`
- `fractionalSink()`
- `idClaimAssignment(uint256)`
- `leafFor(uint8,address,uint256,uint256,uint256)`
- `legacy()`
- `legacyConfigurationReady()`
- `legacyMirror()`
- `legacyReflections()`
- `owner()`
- `paused()`
- `snapshotBlock()`
- `snapshotRoot()`
- `totalDistributed()`
- `usedLeaf(bytes32)`
- `v2()`
- `v2Reflections()`
- `verifyLeaf(uint8,address,uint256,uint256,uint256,bytes32[])`
