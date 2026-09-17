# AgentTaxV2-Proxy - 0x6D80B81d9Fc56A7A839b1Af9006Eb49151961ce7

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x6D80B81d9Fc56A7A839b1Af9006Eb49151961ce7
Role: AgentTaxV2-Proxy.
Contract name: TransparentUpgradeableProxy.
Verified: True (verified at 2026-07-02T06:42:05.213097Z).
Compiler: v0.8.29+commit.ab55807c, EVM paris, optimizer True runs 200.
Main file: @openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol.
Source files written: 12 under `sources/`.
Creator: 0xe4a0015B4c12f84bF9B8b9DB56b7ef0Bc539D88F.
Creation tx: 0x19da292aa34ef51df52f1e94f5f8185953e3161931d80558ef765cbbb4b0e794.
Proxy type: eip1967; implementations: ['0x4D4e8F06FE9a3dB2FA7AD4D17893128600Ec01bB'].

Tax vault. Receives the 1 percent VIRTUAL tax per token, swaps it to USDG through Uniswap V2 and splits it 30 percent treasury, 70 percent creator (minus any partner share).

## Constructor arguments

- `_logic` (address): `0x4D4e8F06FE9a3dB2FA7AD4D17893128600Ec01bB`
- `initialOwner` (address): `0x023d90298eDF920e989c3d7f89C49EB3007dB64b`
- `_data` (bytes): `0xb015ba98000000000000000000000000e4a0015b4c12f84bf9b8b9db56b7ef0bc539d88f0000000000000000000000005fc5360d0400a0fd4f2af552add042d716f1d168000000000000000000000000c6911796042b15d7fa4f6cde69e245ddcd3d9c3100000000000000000000000089e5db8b5aa49aa85ac63f691524311aeb649eba000000000000000000000000b51c52d9e5e41937b0100840b6c3cba6f7a57a0c0000000000000000000000000000000000000000000000008ac7230489e8000000000000000000000000000000000000000000000000003635c9adc5dea000000000000000000000000000000000000000000000000000000000000000000bb8`

## Events

- `AdminChanged(address,address)`
- `Upgraded(address)`

## State-changing functions

None.

## View functions

None.
