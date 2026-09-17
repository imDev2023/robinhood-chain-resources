# BagsFactoryImpl - 0x7dfa0131F6c8626F199A2E33E49DfB5660e6Ef1C

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x7dfa0131F6c8626F199A2E33E49DfB5660e6Ef1C
Role: BagsFactoryImpl.
Contract name: BagsFactory.
Verified: True (verified at 2026-07-12T14:59:15.186329Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/BagsFactory.sol.
Source files written: 98 under `sources/`.
Creator: 0xDEf671F11C8a30818eb3D9Cc9476EEEc805f9058.
Creation tx: 0x67c168a8cb49db48d5623dd27ce14e9cb9a30989bd95658cce947f700cde8665.
Proxy type: None; implementations: [].

Current BagsFactory implementation behind the UUPS proxy 0xe8Cc...Cb37.

## Constructor arguments

None decoded.

## Events

- `CreationFeeUpdated(uint256)`
- `GraduationThresholdUpdated(uint256,uint256)`
- `HookUpdated(address)`
- `Initialized(uint64)`
- `OwnershipTransferStarted(address,address)`
- `OwnershipTransferred(address,address)`
- `PartnerFeeBpsUpdated(uint16,uint16)`
- `Rescued(address,address,uint256)`
- `TokenCreated(address,address,address,address,address,bytes32,string,string,string)`
- `TokenImplUpdated(address)`
- `Upgraded(address)`

## State-changing functions

- `acceptOwnership()`
- `create(string,string,string,address,address[],uint16[])`
- `createAndBuy(string,string,string,address,address[],uint16[])`
- `initialize(address,address,address,address,address,address,address,address,address,uint256,address)`
- `renounceOwnership()`
- `rescue(address,uint256)`
- `setCreationFee(uint256)`
- `setGraduationThreshold(uint256)`
- `setHook(address)`
- `setPartnerFeeBps(uint16)`
- `setTokenImpl(address)`
- `transferOwnership(address)`
- `upgradeToAndCall(address,bytes)`

## View functions

- `UPGRADE_INTERFACE_VERSION()`
- `allTokens(uint256)`
- `allTokensLength()`
- `bondingCurveBeacon()`
- `creationFee()`
- `curveForToken(address)`
- `feeShareBeacon()`
- `feeShareForToken(address)`
- `getTokens(uint256,uint256)`
- `graduationThreshold()`
- `hook()`
- `owner()`
- `partnerFeeBps()`
- `pendingOwner()`
- `permit2()`
- `poolManager()`
- `positionManager()`
- `proxiableUUID()`
- `tokenForPoolId(bytes32)`
- `tokenImpl()`
- `vault()`
- `weth()`
