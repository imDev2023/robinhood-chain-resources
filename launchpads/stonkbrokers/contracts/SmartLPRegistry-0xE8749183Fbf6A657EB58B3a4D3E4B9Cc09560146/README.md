# SmartLPRegistry - 0xE8749183Fbf6A657EB58B3a4D3E4B9Cc09560146

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xE8749183Fbf6A657EB58B3a4D3E4B9Cc09560146
Role: SmartLPRegistry.
Contract name: SmartLpRegistry.
Verified: True (verified at 2026-09-08T21:37:16.705425Z).
Compiler: 0.8.24+commit.e11b9ed9, EVM cancun, optimizer True runs 200.
Main file: contracts/smart-lp/SmartLpRegistry.sol.
Source files written: 1 under `sources/`.
Creator: 0xb668382cF44038a3E8140E789060F6A809787CDa.
Creation tx: 0x7143eb586746ec70e00e241f71bb03532d1ed54317319394525d486bcbdf8db8.
Proxy type: None; implementations: [].

## Constructor arguments

- `_owner` (address): `0xb668382cF44038a3E8140E789060F6A809787CDa`

## Events

- `OwnerSet(address)`
- `VaultDelisted(address)`
- `VaultListed(address,address,uint8)`

## State-changing functions

- `delist(address)`
- `list(address,address,uint8)`
- `setOwner(address)`

## View functions

- `all()`
- `count()`
- `isListed(address)`
- `owner()`
- `vaults(uint256)`
