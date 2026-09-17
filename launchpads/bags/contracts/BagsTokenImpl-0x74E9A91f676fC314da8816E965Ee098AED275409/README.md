# BagsTokenImpl - 0x74E9A91f676fC314da8816E965Ee098AED275409

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x74E9A91f676fC314da8816E965Ee098AED275409
Role: BagsTokenImpl.
Contract name: BagsToken.
Verified: True (verified at 2026-07-12T15:01:25.447633Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/BagsToken.sol.
Source files written: 22 under `sources/`.
Creator: 0xDEf671F11C8a30818eb3D9Cc9476EEEc805f9058.
Creation tx: 0xd1a3399d7b01a2548010d302051cc60d3179ee6455d6613b30df0c84e31ff862.
Proxy type: None; implementations: [].

EIP-1167 clone target (`factory.tokenImpl()`). Every launched token's runtime code is `363d3d373d3d3d363d73 74e9...5409 5af43d82803e903d91602b57fd5b`.

## Constructor arguments

None decoded.

## Events

- `Approval(address,address,uint256)`
- `EIP712DomainChanged()`
- `InitialSupplyMinted(address,uint256)`
- `OwnershipTransferred(address,address)`
- `Transfer(address,address,uint256)`

## State-changing functions

- `approve(address,uint256)`
- `initialize(string,string,string,address)`
- `mintInitialSupply(address)`
- `permit(address,address,uint256,uint256,uint8,bytes32,bytes32)`
- `renounceOwnership()`
- `transfer(address,uint256)`
- `transferFrom(address,address,uint256)`
- `transferOwnership(address)`

## View functions

- `DECIMALS()`
- `DOMAIN_SEPARATOR()`
- `INITIAL_SUPPLY()`
- `allowance(address,address)`
- `balanceOf(address)`
- `decimals()`
- `eip712Domain()`
- `metadataURI()`
- `name()`
- `nonces(address)`
- `owner()`
- `symbol()`
- `totalSupply()`
