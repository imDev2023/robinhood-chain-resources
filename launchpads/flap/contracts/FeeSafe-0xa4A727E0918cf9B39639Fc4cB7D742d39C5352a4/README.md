# FeeSafe-0xa4A727E0918cf9B39639Fc4cB7D742d39C5352a4

**Flap fee recipient and Portal admin, a Gnosis Safe**

- Address: `0xa4A727E0918cf9B39639Fc4cB7D742d39C5352a4`
- Contract name on Blockscout: `SafeProxy`
- Verified: yes
- Proxy type: `master_copy`, implementation `0x29fcB43b46531BcA003ddC8FCB67FFE91900C762`
- Creator: `0x4e1DCf7AD4e460CfD30791CCC4F9c8a4f820ec67`
- Creation tx: `0x2a415435bde7faaa32dba55a8853a452148f675f2ab9825ea139b10c1ece4db5`
- Compiler: `v0.7.6+commit.7338295f`, optimizer off, EVM `default`
- License: `none`
- Explorer: <https://robinhoodchain.blockscout.com/address/0xa4A727E0918cf9B39639Fc4cB7D742d39C5352a4>

Safe v1.4.1, **2 of 3** (`_raw/rpc/feesafe-and-roles.txt`), owners `0xa85c06f5...`, `0x01db3757...`, `0x29a64981...`.

Two roles, both material:

1. It receives the 1% bonding-curve fee directly. `_raw/blockscout/txinternal-0xec60221a...json` shows a `37053982898397` wei buy sending `370539828983` wei, exactly 1%, to this address in the same transaction.
2. `Portal.hasRole(DEFAULT_ADMIN_ROLE, FeeSafe)` returns `true`, so the same 2-of-3 can change quote-token configuration, fee rates, token beneficiaries and blocked tokens.

## Constructor arguments

- `_singleton` (`address`): `0x29fcB43b46531BcA003ddC8FCB67FFE91900C762`

## Files in this directory

- `abi.json`
- `address.json`
- `metadata.json`
- `methods-read.json`
- `sources`/
