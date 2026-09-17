# LaunchFactoryWeth - 0x472286b7d5c1b2a3ce1132ef73d3bccf446c5cc1

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x472286b7d5c1b2a3ce1132ef73d3bccf446c5cc1
Role: LaunchFactoryWeth.
Contract name: TransparentUpgradeableProxy.
Verified: True (verified at 2026-07-17T16:48:55.308609Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: lib/openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol.
Source files written: 9 under `sources/`.
Creator: 0xbF551eED83c7eaEE63854a2013Eb94f18600B7C5.
Creation tx: 0xef1dbd691269419faae672e31fee6273d7ae8e5415071c328c38fc0847537b32.
Proxy type: eip1967; implementations: ['0x818FdD15Dbe95851a0bd8c5389c49ed6d4FE2bBf'].

Transparent proxy. The WETH-pair launch factory: `launch`, `launchWithFeeRecipient`, `launchWithReflections`, `launchWithWhitelist`. Live implementation read from the EIP-1967 slot on 2026-09-02 is `0x818fdd15dbe95851a0bd8c5389c49ed6d4fe2bbf` (SentryLaunchFactoryV4).

## Constructor arguments

- `_logic` (address): `0x3DFdcC37Bc5BF3958A851a53dc5fE79Dc68E80Ce`
- `admin_` (address): `0xc3DEb59345CF0816307e416737af716021481F3C`
- `_data` (bytes): `0x`

## Events

- `AdminChanged(address,address)`
- `BeaconUpgraded(address)`
- `Upgraded(address)`

## State-changing functions

None.

## View functions

None.
