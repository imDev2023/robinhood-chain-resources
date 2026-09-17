# AgentFactoryV7-Proxy - 0x43E4C17b15365596Caae8e7d00E42Bc8E988c2d4

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x43E4C17b15365596Caae8e7d00E42Bc8E988c2d4
Role: AgentFactoryV7-Proxy.
Contract name: TransparentUpgradeableProxy.
Verified: True (verified at 2026-07-02T06:03:27.228689Z).
Compiler: v0.8.29+commit.ab55807c, EVM paris, optimizer True runs 200.
Main file: @openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol.
Source files written: 12 under `sources/`.
Creator: 0xe4a0015B4c12f84bF9B8b9DB56b7ef0Bc539D88F.
Creation tx: 0x0e3f1be5e75e20ccf598ba9853c7cf3f317d4acb9d14b1656cb904109fd89207.
Proxy type: eip1967; implementations: ['0xF0a8089da19568a37bCCacc4BFE3A2a9f1E71675'].

Mints the agent token clone at preLaunch and, at graduation, creates the Uniswap V2 pool, the veToken (10-year LP lock), the DAO, the agent NFT and the ERC-6551 token-bound account.

## Constructor arguments

- `_logic` (address): `0xF0a8089da19568a37bCCacc4BFE3A2a9f1E71675`
- `initialOwner` (address): `0x023d90298eDF920e989c3d7f89C49EB3007dB64b`
- `_data` (bytes): `0x88301911000000000000000000000000581f7b996e6d3e436c537989157c9cb36421419b000000000000000000000000d851e9f4c40c7df6a2ce16065a4ecbc86c7321e70000000000000000000000005b56842ba4aac6bbba74e1490c791bfac2c5fa8c000000000000000000000000f504ab63fd11871f2a4d356989273f02c219b467000000000000000000000000c6911796042b15d7fa4f6cde69e245ddcd3d9c310000000000000000000000004008561d44a774ad3d517a009d0b6b647932d8d00000000000000000000000001764d9440bd7d2b96f90afae29c12198399adb090000000000000000000000000000000000000000000000000000000000000001`

## Events

- `AdminChanged(address,address)`
- `Upgraded(address)`

## State-changing functions

None.

## View functions

None.
