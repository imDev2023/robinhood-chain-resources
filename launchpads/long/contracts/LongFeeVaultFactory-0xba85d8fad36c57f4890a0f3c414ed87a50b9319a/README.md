# LongFeeVaultFactory - 0xba85d8fad36c57f4890a0f3c414ed87a50b9319a

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xba85d8fad36c57f4890a0f3c414ed87a50b9319a
Role: LongFeeVaultFactory.
Contract name: LongFeeVaultFactory.
Verified: True (verified at 2026-08-05T15:22:17.571570Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/community/LongFeeVaultFactory.sol.
Source files written: 25 under `sources/`.
Creator: 0x4e59b44847b379578588920cA78FbF26c0B4956C.
Creation tx: 0x839bc1f67d06d9a6801e154ae09f9237b27363bc7458797caa8032e56927a336.
Proxy type: None; implementations: [].

`communityFactory` in the app's chain config for Robinhood. Creates the per-token fee vault behind Community mode.

## Constructor arguments

- `initializer_` (address): `0x4e3468951D49f2EEa976eD0D6e75fFCb44a9a544`

## Events

- `VaultDeployed(address,bytes32,address,address,uint8)`

## State-changing functions

- `deployVault(address,uint8)`

## View functions

- `INITIALIZER()`
- `MIN_DEPLOY_SHARES()`
- `getDeployment(address)`
- `isActivated(address)`
- `splitsFor(uint8)`
