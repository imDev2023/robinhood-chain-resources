# QuotronWethRouter - 0x42024fcfdb4f3089dd619a0cef0cd24e7b841c18

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x42024fcfdb4f3089dd619a0cef0cd24e7b841c18
Role: QuotronWethRouter.
Contract name: QuotronWethRouter.
Verified: True (verified at 2026-08-13T15:24:39.986222Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/v2/QuotronWethRouter.sol.
Source files written: 19 under `sources/`.
Creator: 0x7171E64E979265aeD6588577D1c6b60A701d7866.
Creation tx: 0x484a7ee76bedc75d7bb8351ab91f8e9d8a529f30e6bdd6a6d13c7a3ea7b14fe1.
Proxy type: None; implementations: [].

Quotrons swap router.

## Constructor arguments

- `poolManager_` (address): `0x8366a39CC670B4001A1121B8F6A443A643e40951`
- `quotron_` (address): `0x5a86828Efd322bfb16d93cFeD16EE9BC14940D7F`
- `weth_` (address): `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`
- `poolKey_` (tuple): `['0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73', '0x5a86828Efd322bfb16d93cFeD16EE9BC14940D7F', '8388608', '60', '0x62E200Cc8e4D95cf622f40Dd70f407C883EcB0cc']`

## Events

- `Bought(address,address,uint256,uint256)`
- `Sold(address,address,uint256,uint256)`

## State-changing functions

- `buyExactEth(uint256,address,uint256)`
- `buyExactQuotron(uint256,address,uint256)`
- `sellExactQuotronForEth(uint256,uint256,address,uint256)`
- `unlockCallback(bytes)`

## View functions

- `hook()`
- `poolKey()`
- `poolManager()`
- `quotron()`
- `weth()`
- `wethIsCurrency0()`
