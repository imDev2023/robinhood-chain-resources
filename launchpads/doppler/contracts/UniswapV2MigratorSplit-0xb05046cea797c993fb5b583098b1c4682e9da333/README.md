# UniswapV2MigratorSplit - 0xb05046cea797c993fb5b583098b1c4682e9da333

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xb05046cea797c993fb5b583098b1c4682e9da333
Role: UniswapV2MigratorSplit.
Verified: True (verified at 2026-07-01T19:43:03.135178Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 0.
Main file: src/migrators/UniswapV2MigratorSplit.sol.
Source files written: 26 under `sources/`.
Creator: 0x3213996297CAB8A81952c3F92F7330121A19Ad2C.
Creation tx: 0x6bb59b4e221005e7121eee0e79fddd0967c230d03d0e108c7dcbd8b9a2b6f428.
Proxy type: None; implementations: [].

## Constructor arguments

- `airlock_` (address): `0xeb7C034704eF8Dcd2D32324c1545f62fB4aD0862`
- `factory_` (address): `0x8bcEaA40B9AcdfAedF85AdF4FF01F5Ad6517937f`
- `topUpDistributor` (address): `0x46adee7595d48b1Ec53090e9bc78e1E69Fa0eF06`
- `weth_` (address): `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`

## Events

- DistributeSplit

## State-changing functions

- `initialize(address,address,bytes)`
- `migrate(uint160,address,address,address)`

## View functions

- `TOP_UP_DISTRIBUTOR()`
- `airlock()`
- `factory()`
- `locker()`
- `splitConfigurationOf(address,address)`
- `weth()`
