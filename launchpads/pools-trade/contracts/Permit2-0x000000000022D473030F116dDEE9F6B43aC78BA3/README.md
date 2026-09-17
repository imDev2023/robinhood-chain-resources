# Permit2 - 0x000000000022D473030F116dDEE9F6B43aC78BA3

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x000000000022D473030F116dDEE9F6B43aC78BA3
Role: Permit2.
Contract name: Permit2.
Verified: True (sources from `smart-contracts`, flag from `addresses`).
Compiler: v0.8.17+commit.8df45f5f, EVM london, optimizer True runs 1000000.
Main file: src/Permit2.sol.
Source files written: 13 under `sources/`.
Creator: None.
Creation tx: None.
Proxy type: None; implementations: [].

## Constructor arguments

None decoded.

## Events

- `Approval(address,address,address,uint160,uint48)`
- `Lockdown(address,address,address)`
- `NonceInvalidation(address,address,address,uint48,uint48)`
- `Permit(address,address,address,uint160,uint48,uint48)`
- `UnorderedNonceInvalidation(address,uint256,uint256)`

## State-changing functions

- `approve(address,address,uint160,uint48)`
- `invalidateNonces(address,address,uint48)`
- `invalidateUnorderedNonces(uint256,uint256)`
- `lockdown(tuple[])`
- `permit(address,tuple,bytes)`
- `permitTransferFrom(tuple,tuple,address,bytes)`
- `permitTransferFrom(tuple,tuple[],address,bytes)`
- `permitWitnessTransferFrom(tuple,tuple,address,bytes32,string,bytes)`
- `permitWitnessTransferFrom(tuple,tuple[],address,bytes32,string,bytes)`
- `transferFrom(address,address,uint160,address)`
- `transferFrom(tuple[])`

## View functions

- `DOMAIN_SEPARATOR()`
- `allowance(address,address,address)`
- `nonceBitmap(address,uint256)`
