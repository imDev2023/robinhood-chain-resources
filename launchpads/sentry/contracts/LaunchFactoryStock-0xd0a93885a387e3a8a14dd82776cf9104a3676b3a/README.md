# LaunchFactoryStock - 0xd0a93885a387e3a8a14dd82776cf9104a3676b3a

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xd0a93885a387e3a8a14dd82776cf9104a3676b3a
Role: LaunchFactoryStock.
Contract name: TransparentUpgradeableProxy.
Verified: True (verified at 2026-07-19T16:45:52.045537Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: lib/openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol.
Source files written: 9 under `sources/`.
Creator: 0xbF551eED83c7eaEE63854a2013Eb94f18600B7C5.
Creation tx: 0x6471c12dd3a282ed1fabad792d494370778fba3a5d705a324a5d966df61fa70b.
Proxy type: eip1967; implementations: ['0x818FdD15Dbe95851a0bd8c5389c49ed6d4FE2bBf'].

Transparent proxy. The stock-pair launch factory, same implementation as the WETH factory. `getSupportedBaseTokens()` returned 88 tokenised stocks on 2026-09-02.

## Constructor arguments

- `_logic` (address): `0x671A75A5c1DF4F21C48008199Daff595435345F0`
- `admin_` (address): `0x0d6F17F79df5B5A3DaFfCa9A9Db1260aD1Bfa844`
- `_data` (bytes): `0x`

## Events

- `AdminChanged(address,address)`
- `BeaconUpgraded(address)`
- `Upgraded(address)`

## State-changing functions

None.

## View functions

None.
