# TaxAccountingAdapter-Proxy - 0xF36F0dd7b6b1730d0A59d1F3fD0E494C4D5c66E8

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xF36F0dd7b6b1730d0A59d1F3fD0E494C4D5c66E8
Role: TaxAccountingAdapter-Proxy.
Contract name: TransparentUpgradeableProxy.
Verified: True (verified at 2026-07-02T07:08:22.361258Z).
Compiler: v0.8.29+commit.ab55807c, EVM paris, optimizer True runs 200.
Main file: @openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol.
Source files written: 14 under `sources/`.
Creator: 0xe4a0015B4c12f84bF9B8b9DB56b7ef0Bc539D88F.
Creation tx: 0x230265ad0c601fbdc06abc2d670ee34f8d7e41686d05d47f7232bfc6ff5830d9.
Proxy type: eip1967; implementations: ['0xbAF52C875916a06Df443b77D634eE4e9170cf06C'].

Post-graduation tax adapter referenced by every AgentTokenV4 clone; forwards the token-level 1 percent tax to AgentTaxV2.

## Constructor arguments

- `_logic` (address): `0xbAF52C875916a06Df443b77D634eE4e9170cf06C`
- `initialOwner` (address): `0x023d90298eDF920e989c3d7f89C49EB3007dB64b`
- `_data` (bytes): `0x485cc955000000000000000000000000023d90298edf920e989c3d7f89c49eb3007db64b0000000000000000000000006d80b81d9fc56a7a839b1af9006eb49151961ce7`

## Events

- `AdminChanged(address,address)`
- `Upgraded(address)`

## State-changing functions

None.

## View functions

None.
