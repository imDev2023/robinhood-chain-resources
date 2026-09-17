# CCIP-TokenAdminRegistry - 0x1912C3cFafE8A76A32a92861d815aC2837F237Ca

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x1912C3cFafE8A76A32a92861d815aC2837F237Ca
Role: CCIP-TokenAdminRegistry.
Contract name: TokenAdminRegistry.
Verified: True (verified at 2026-05-26T17:13:31.394252Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM paris, optimizer True runs 80000.
Main file: contracts/tokenAdminRegistry/TokenAdminRegistry.sol.
Source files written: 10 under `sources/`.
Creator: 0x062f05CD6c835677B05a8658A351969476861316.
Creation tx: 0xac8a39b1a2f5828aa6a6aca23678953a2aaebe4c3e82c70c52d13d7c17c6296e.
Proxy type: None; implementations: [].

Chainlink CCIP registry that maps VIRTUAL to its token pool. Third-party infrastructure, not deployed by Virtuals.

## Constructor arguments

None decoded.

## Events

- `AdministratorTransferRequested(address,address,address)`
- `AdministratorTransferred(address,address)`
- `OwnershipTransferRequested(address,address)`
- `OwnershipTransferred(address,address)`
- `PoolSet(address,address,address)`
- `RegistryModuleAdded(address)`
- `RegistryModuleRemoved(address)`

## State-changing functions

- `acceptAdminRole(address)`
- `acceptOwnership()`
- `addRegistryModule(address)`
- `proposeAdministrator(address,address)`
- `removeRegistryModule(address)`
- `setPool(address,address)`
- `transferAdminRole(address,address)`
- `transferOwnership(address)`

## View functions

- `getAllConfiguredTokens(uint64,uint64)`
- `getPool(address)`
- `getPools(address[])`
- `getTokenConfig(address)`
- `isAdministrator(address,address)`
- `isRegistryModule(address)`
- `owner()`
- `typeAndVersion()`
