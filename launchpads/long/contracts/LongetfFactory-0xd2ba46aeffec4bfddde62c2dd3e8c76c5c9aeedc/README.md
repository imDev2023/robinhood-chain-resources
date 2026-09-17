# LongetfFactory - 0xd2ba46aeffec4bfddde62c2dd3e8c76c5c9aeedc

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xd2ba46aeffec4bfddde62c2dd3e8c76c5c9aeedc
Role: LongetfFactory.
Contract name: LongetfFactory.
Verified: True (verified at 2026-09-01T23:59:16.863572Z).
Compiler: v0.8.36+commit.8a079791, EVM default, optimizer True runs 200.
Main file: F.sol.
Source files written: 1 under `sources/`.
Creator: 0xAb9a51Ca0f4eF8D131223D59aB17F944b1F85383.
Creation tx: 0x7307df6bf5f535a71f8e00caa14adc0f91e5382624ec76aab0c1afc9f4ff5feb.
Proxy type: None; implementations: [].

Verified 2026-09-01. Name suggests a Long ETF product; see README.md section 5 for what the source does.

## Constructor arguments

- `owner_` (address): `0xAb9a51Ca0f4eF8D131223D59aB17F944b1F85383`
- `vaultInitCodeHash_` (bytes32): `0x4e9eb82cb38d4bf225e8e4936021a56eb49c75bd7337013d90e600b689cb2eef`

## Events

- `OwnerChanged(address,address)`
- `Registered(address,address,address,uint96)`
- `VaultDeployed(address,address,bytes32)`

## State-changing functions

- `acceptOwnership()`
- `deployVault(bytes32,address,bytes)`
- `register(address,address)`
- `setVaultRoles(address,address)`
- `transferOwnership(address)`

## View functions

- `MIN_VAULT_SHARES()`
- `POOL_INITIALIZER()`
- `PROTOCOL_BENEFICIARY()`
- `VAULT_INIT_CODE_HASH()`
- `creatorOf(address)`
- `effectiveSalt(bytes32,address)`
- `isSaltUsable(bytes32,address,bytes)`
- `owner()`
- `page(uint256,uint256)`
- `pendingOwner()`
- `predictVault(bytes32,address,bytes)`
- `tokenOf(address)`
- `vaultCount()`
- `vaultOf(address)`
- `vaultOperator()`
- `vaultOwner()`
- `vaults(uint256)`
