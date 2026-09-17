# RelayDepository - 0x4cd00e387622c35bddb9b4c962c136462338bc31

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x4cd00e387622c35bddb9b4c962c136462338bc31
Role: RelayDepository.
Contract name: RelayDepository.
Verified: True.
Compiler: v0.8.28+commit.7893614a, EVM cancun, optimizer False runs None.
Main file: src/RelayDepository.sol.
Source files written: 7 under `sources/`.
Creator: 0x4e59b44847b379578588920cA78FbF26c0B4956C.
Creation tx: 0x3dce830a05a70f0526775bbdeddd2d2df16281f2310582938bad39334f9cc928.
Proxy type: None; implementations: [].

Relay bridge depository. Not part of the launch path; it is what the app's Bridge tab and the treasury use to move ETH off the chain.

## Constructor arguments

None decoded.

## Events

- `OwnershipHandoverCanceled(address)`
- `OwnershipHandoverRequested(address)`
- `OwnershipTransferred(address,address)`
- `RelayCallExecuted(bytes32,tuple)`
- `RelayErc20Deposit(address,address,uint256,bytes32)`
- `RelayNativeDeposit(address,uint256,bytes32)`

## State-changing functions

- `cancelOwnershipHandover()`
- `completeOwnershipHandover(address)`
- `depositErc20(address,address,bytes32)`
- `depositErc20(address,address,uint256,bytes32)`
- `depositNative(address,bytes32)`
- `execute(tuple,bytes)`
- `renounceOwnership()`
- `requestOwnershipHandover()`
- `setAllocator(address)`
- `transferOwnership(address)`

## View functions

- `_CALL_REQUEST_TYPEHASH()`
- `_CALL_TYPEHASH()`
- `allocator()`
- `callRequests(bytes32)`
- `eip712Domain()`
- `owner()`
- `ownershipHandoverExpiresAt(address)`
