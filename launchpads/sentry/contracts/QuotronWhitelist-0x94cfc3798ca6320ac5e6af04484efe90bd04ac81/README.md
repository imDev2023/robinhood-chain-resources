# QuotronWhitelist - 0x94cfc3798ca6320ac5e6af04484efe90bd04ac81

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x94cfc3798ca6320ac5e6af04484efe90bd04ac81
Role: QuotronWhitelist.
Contract name: QuotronWhitelist.
Verified: True (verified at 2026-08-13T15:23:59.774218Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/QuotronWhitelist.sol.
Source files written: 1 under `sources/`.
Creator: 0x7171E64E979265aeD6588577D1c6b60A701d7866.
Creation tx: 0x1fe077a2a637b1ea5084984c40d434283b8dd606e2ae12d541b1cb112bd153c2.
Proxy type: None; implementations: [].

Quotrons launch whitelist registry.

## Constructor arguments

- `brokers` (address): `0x539CdD042c2f3d93EbC5BE7DfFf0c79F3B4fAbF0`

## Events

- `Claimed(address,bytes32)`
- `CollectionSet(address,bool)`
- `ReducedSpotClaimed(address,uint256)`
- `RootSet(bytes32,bool)`
- `WhitelistSet(address,bool)`

## State-changing functions

- `claim(bytes32,bytes32[])`
- `claimReducedSpot()`
- `setCollection(address,bool)`
- `setRoot(bytes32,bool)`
- `setWhitelisted(address[],bool)`
- `transferOwnership(address)`

## View functions

- `REDUCED_CAP()`
- `allowed(address)`
- `claimed(bytes32,address)`
- `collectionCount()`
- `collections(uint256)`
- `directCount()`
- `isCollection(address)`
- `isReduced(address)`
- `isWhitelisted(address)`
- `owner()`
- `reason(address)`
- `reduced(address)`
- `reducedCount()`
- `roots(bytes32)`
