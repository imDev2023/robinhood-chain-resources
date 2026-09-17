# QuotronBurnVault - 0xd1258efafa9d1b1d09c86403139db78465540760

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xd1258efafa9d1b1d09c86403139db78465540760
Role: QuotronBurnVault.
Contract name: QuotronBurnVault.
Verified: True (verified at 2026-08-13T15:25:48.040288Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/v2/QuotronBurnVault.sol.
Source files written: 1 under `sources/`.
Creator: 0x7171E64E979265aeD6588577D1c6b60A701d7866.
Creation tx: 0x8d15bf2e14788ce647bfa70ba0562108edd3bfc507a18fcd28ff5b266c4254c0.
Proxy type: None; implementations: [].

Quotrons burn vault for hardwiring.

## Constructor arguments

- `hook_` (address): `0x62E200Cc8e4D95cf622f40Dd70f407C883EcB0cc`
- `weth_` (address): `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`
- `burnToken_` (address): `0xe934e36A439C94017B64a3FecE66AF12099aBF50`
- `owner_` (address): `0x7171E64E979265aeD6588577D1c6b60A701d7866`

## Events

- `AdapterSealed(address)`
- `BurnExecuted(uint256,uint256)`
- `ExecutorSet(address)`
- `Paused(bool)`

## State-changing functions

- `executeBurn(uint256,uint256,uint256)`
- `setAndSealAdapter(address)`
- `setExecutor(address)`
- `setPaused(bool)`
- `transferOwnership(address)`

## View functions

- `BURN_ADDRESS()`
- `adapter()`
- `adapterSealed()`
- `burnToken()`
- `executor()`
- `hook()`
- `owner()`
- `paused()`
- `weth()`
