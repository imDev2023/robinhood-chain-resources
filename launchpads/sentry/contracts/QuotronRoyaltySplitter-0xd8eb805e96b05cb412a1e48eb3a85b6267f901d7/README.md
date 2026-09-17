# QuotronRoyaltySplitter - 0xd8eb805e96b05cb412a1e48eb3a85b6267f901d7

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xd8eb805e96b05cb412a1e48eb3a85b6267f901d7
Role: QuotronRoyaltySplitter.
Contract name: QuotronRoyaltySplitter.
Verified: True (verified at 2026-08-13T15:23:52.606666Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/v2/QuotronRoyaltySplitter.sol.
Source files written: 1 under `sources/`.
Creator: 0x7171E64E979265aeD6588577D1c6b60A701d7866.
Creation tx: 0xf0565ecf04f41a174eed44092b77f1aac976e2affbe8599144f475e98011d65a.
Proxy type: None; implementations: [].

Quotrons royalty splitter.

## Constructor arguments

- `keeper_` (address): `0xd1dE50B724de2e243D3f6f3C3ef1806BABD39e58`
- `creator_` (address): `0x7171E64E979265aeD6588577D1c6b60A701d7866`

## Events

- `NativeRoyaltyReleased(uint256,uint256,uint256)`
- `TokenRoyaltyReleased(address,uint256,uint256,uint256)`

## State-changing functions

- `releaseNative()`
- `releaseToken(address)`

## View functions

- `creator()`
- `keeper()`
