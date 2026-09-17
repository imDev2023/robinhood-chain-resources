# WETHImpl - 0xC6B81b429797E0f555440b70cD99e032D7AE947e

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xC6B81b429797E0f555440b70cD99e032D7AE947e
Role: WETHImpl.
Contract name: aeWETH.
Verified: True (verified at 2026-05-18T13:08:00.444108Z).
Compiler: v0.8.16+commit.07a7930e, EVM default, optimizer True runs 100.
Main file: contracts/tokenbridge/libraries/aeWETH.sol.
Source files written: 22 under `sources/`.
Creator: 0xE83b11Faa5693E68388785FecA3595C6805dFb9a.
Creation tx: 0x05317cd173ba8e973c7e88aeb7f7e56eb22cf05c12552d4283c993dbb1f56b12.
Proxy type: None; implementations: [].

aeWETH implementation.

## Constructor arguments

None decoded.

## Events

- `Approval(address,address,uint256)`
- `Initialized(uint8)`
- `Transfer(address,address,uint256)`
- `Transfer(address,address,uint256,bytes)`

## State-changing functions

- `approve(address,uint256)`
- `bridgeBurn(address,uint256)`
- `bridgeMint(address,uint256)`
- `decreaseAllowance(address,uint256)`
- `deposit()`
- `depositTo(address)`
- `increaseAllowance(address,uint256)`
- `initialize(string,string,uint8,address,address)`
- `permit(address,address,uint256,uint256,uint8,bytes32,bytes32)`
- `transfer(address,uint256)`
- `transferAndCall(address,uint256,bytes)`
- `transferFrom(address,address,uint256)`
- `withdraw(uint256)`
- `withdrawTo(address,uint256)`

## View functions

- `DOMAIN_SEPARATOR()`
- `allowance(address,address)`
- `balanceOf(address)`
- `decimals()`
- `l1Address()`
- `l2Gateway()`
- `name()`
- `nonces(address)`
- `symbol()`
- `totalSupply()`
