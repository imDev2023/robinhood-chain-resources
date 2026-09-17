# NoxaIO-LauncherLocker - 0x90331a631123bd2493ba962c4304dcb49f3a5d4a

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x90331a631123bd2493ba962c4304dcb49f3a5d4a
Role: NoxaIO-LauncherLocker.
Contract name: LauncherLocker.
Verified: True.
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/LauncherLocker.sol.
Source files written: 15 under `sources/`.
Creator: 0x407Fe47FA03617062E9cD27DCACe8DAB006322d8.
Creation tx: 0x7a17db9af6c9322a1c52a7d26fcfb5ee297b63abbffc4df53df017a7fb258d18.
Proxy type: None; implementations: [].

Holds the noxa.io positions. `claimFees` is permissionless and collects straight into the FeeRouter.

## Constructor arguments

- `feeRouter_` (address): `0x28A5328B61E00dD75F1d0C8A1831A65890E42d36`

## Events

- `FactoryUpdated(address)`
- `FeeRedirectUpdated(address,address)`
- `FeesClaimed(address,uint256,uint256,uint256)`
- `OwnershipTransferred(address,address)`
- `PositionRegistered(address,uint256,address,address)`

## State-changing functions

- `claimFees(address)`
- `registerPosition(address,uint256,address,address,address,bool)`
- `renounceOwnership()`
- `setFactory(address)`
- `setFeeRedirect(address,address)`
- `transferOwnership(address)`

## View functions

- `factory()`
- `feeRouter()`
- `feeWalletOf(address)`
- `getPosition(address)`
- `onERC721Received(address,address,uint256,bytes)`
- `owner()`
