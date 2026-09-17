# CCIP-RegistryModuleOwnerCustom - 0x3237c0D7B58bEC8Dc17F00103B784Bd6678F789E

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x3237c0D7B58bEC8Dc17F00103B784Bd6678F789E
Role: CCIP-RegistryModuleOwnerCustom.
Contract name: RegistryModuleOwnerCustom.
Verified: True (verified at 2026-05-26T17:13:03.628198Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM paris, optimizer True runs 80000.
Main file: contracts/tokenAdminRegistry/RegistryModuleOwnerCustom.sol.
Source files written: 10 under `sources/`.
Creator: 0x062f05CD6c835677B05a8658A351969476861316.
Creation tx: 0x5088699ed7f7488b0316a9697dcbbab321be45f2b96fc272fd9e1cc780feabbc.
Proxy type: None; implementations: [].

Chainlink CCIP module used by the token owner to register VIRTUAL as admin. Third-party infrastructure.

## Constructor arguments

- `tokenAdminRegistry` (address): `0x1912C3cFafE8A76A32a92861d815aC2837F237Ca`

## Events

- `AdministratorRegistered(address,address)`

## State-changing functions

- `registerAccessControlDefaultAdmin(address)`
- `registerAdminViaGetCCIPAdmin(address)`
- `registerAdminViaOwner(address)`

## View functions

- `typeAndVersion()`
