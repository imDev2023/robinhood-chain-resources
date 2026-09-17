# BagsFeeShareImpl - 0xD169EBd0aa9E42F2410f92740D00cD2228d98a1A

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xD169EBd0aa9E42F2410f92740D00cD2228d98a1A
Role: BagsFeeShareImpl.
Contract name: BagsFeeShare.
Verified: True (verified at 2026-07-12T15:04:17.615719Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/BagsFeeShare.sol.
Source files written: 26 under `sources/`.
Creator: 0xDEf671F11C8a30818eb3D9Cc9476EEEc805f9058.
Creation tx: 0xf67a2dc6accc309e7b94e7d84a5024324a8d8724532e84427ca807fb11f0e13e.
Proxy type: None; implementations: [].

Beacon implementation for every per-token fee ledger.

## Constructor arguments

None decoded.

## Events

- `BondingCurveSet(address)`
- `Claimed(address,uint256,bool)`
- `ClaimersUpdated(address[],uint16[])`
- `FeeNotified(uint256)`
- `Initialized(uint64)`
- `OwnershipTransferred(address,address)`
- `PartnerFeeNotified(uint256)`
- `SweepFailed(address)`

## State-changing functions

- `claim(bool)`
- `initialize(address,address,address,address[],uint16[],address,bytes32)`
- `notifyFee(uint256)`
- `notifyPartnerFee(uint256)`
- `renounceOwnership()`
- `setBondingCurve(address)`
- `setClaimers(address[],uint16[])`
- `transferOwnership(address)`

## View functions

- `PARTNER()`
- `WETH()`
- `bondingCurve()`
- `claimable(address)`
- `claimerBps(address)`
- `claimers(uint256)`
- `getClaimers()`
- `hook()`
- `owner()`
- `poolId()`
