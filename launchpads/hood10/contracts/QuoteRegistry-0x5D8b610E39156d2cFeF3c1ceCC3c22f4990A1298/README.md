# QuoteRegistry - 0x5D8b610E39156d2cFeF3c1ceCC3c22f4990A1298

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x5D8b610E39156d2cFeF3c1ceCC3c22f4990A1298
Role: QuoteRegistry.
Contract name: QuoteRegistry.
Verified: True (verified at 2026-08-31T12:31:05.102583Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 800.
Main file: src/QuoteRegistry.sol.
Source files on disk: 11 under `sources/`.
Creator: 0xfe2cF227e21C5FC54dcE8Bb65F7C1E1E90236862.
Creation tx: 0x061ce64a94422395fc95cc8bfebf9db5e7748b196da84a846269f934b0fc3b3c.
Proxy type: None; implementations: [].
External libraries: none.

## What it does

Classifies a quote asset into `NATIVE`, `STOCK`, `ECOSYSTEM`, `EXOTIC` or `UNSUPPORTED` and returns the lot-sizing policy the fee router sells it under.
Its own natspec says it is deliberately not an allowlist: the tier gates what the router will sell, not what a creator may quote a pool in.
Constructor defaults, per tier `maxPoolFractionBps`: NATIVE 0 (no sale), STOCK 50 (0.5%), ECOSYSTEM 100 (1%), EXOTIC 25 (0.25%), UNSUPPORTED not sweepable.
`MAX_POOL_FRACTION_BPS` is 1000.
`isStockToken` probes `uiMultiplier()`, the ERC-8056 Robinhood stock-token selector.

## Constructor arguments

- `weth_` (address): `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`
- `owner_` (address): `0xfe2cF227e21C5FC54dcE8Bb65F7C1E1E90236862`

## Events

- `DefaultSet(uint8,tuple)`
- `EcosystemSet(address,bool)`
- `OwnershipTransferStarted(address,address)`
- `OwnershipTransferred(address,address)`
- `PolicyCleared(address)`
- `PolicySet(address,tuple)`

## State-changing functions

- `acceptOwnership()`
- `clearPolicy(address)`
- `renounceOwnership()`
- `setDefault(uint8,tuple)`
- `setEcosystem(address,bool)`
- `setPolicy(address,tuple)`
- `transferOwnership(address)`

## View functions

- `MAX_POOL_FRACTION_BPS()`
- `classify(address)`
- `defaultFor(uint8)`
- `hasExplicitPolicy(address)`
- `isEcosystem(address)`
- `isStockToken(address)`
- `owner()`
- `pendingOwner()`
- `policyFor(address)`
- `weth()`
