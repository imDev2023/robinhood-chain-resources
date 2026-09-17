# FFactoryV3-Proxy - 0xFC2E4Da3EdB2E18100473339c763705d263D20A9

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xFC2E4Da3EdB2E18100473339c763705d263D20A9
Role: FFactoryV3-Proxy.
Contract name: TransparentUpgradeableProxy.
Verified: True (verified at 2026-07-01T20:54:28.279230Z).
Compiler: v0.8.29+commit.ab55807c, EVM paris, optimizer True runs 200.
Main file: @openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol.
Source files written: 12 under `sources/`.
Creator: 0xe4a0015B4c12f84bF9B8b9DB56b7ef0Bc539D88F.
Creation tx: 0x17613f2b299ab277f9599ed4326d706dcb79b4af39e1fb8d4dad28148e51895f.
Proxy type: eip1967; implementations: ['0x38b1A526f25b40bf7bb2a8c40957Ae3598C0356f'].

Creates the internal bonding pairs (FPairV2) and holds buyTax, sellTax, taxVault and antiSniperTaxVault. The implementation 0x38b1... is not verified on Blockscout; the ABI used for reads comes from protocol-contracts/contracts/launchpadv2/FFactoryV3.sol.

## Constructor arguments

- `_logic` (address): `0x38b1A526f25b40bf7bb2a8c40957Ae3598C0356f`
- `initialOwner` (address): `0x023d90298eDF920e989c3d7f89C49EB3007dB64b`
- `_data` (bytes): `0x6c28e3490000000000000000000000006d80b81d9fc56a7a839b1af9006eb49151961ce700000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000006300000000000000000000000032487287c65f11d53bbca89c2472171eb09bf337`

## Events

- `AdminChanged(address,address)`
- `Upgraded(address)`

## State-changing functions

None.

## View functions

None.
