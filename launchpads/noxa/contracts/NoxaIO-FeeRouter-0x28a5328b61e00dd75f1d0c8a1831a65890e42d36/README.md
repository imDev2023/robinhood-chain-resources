# NoxaIO-FeeRouter - 0x28a5328b61e00dd75f1d0c8a1831a65890e42d36

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x28a5328b61e00dd75f1d0c8a1831a65890e42d36
Role: NoxaIO-FeeRouter.
Contract name: FeeRouter.
Verified: True.
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 200.
Main file: src/FeeRouter.sol.
Source files written: 13 under `sources/`.
Creator: 0x407Fe47FA03617062E9cD27DCACe8DAB006322d8.
Creation tx: 0x0abd644aa80ff852b8821395121266600f1dcbdcb69b195381d9b23ce6141e4b.
Proxy type: None; implementations: [].

Splits every collection three ways. On 2026-09-03 the live shares were protocol 3333, cto 3334, burner 3333 basis points, so a noxa.io creator receives about a third of trading fees rather than all of them.

## Constructor arguments

None decoded.

## Events

- `FeesDistributed(address,address,uint256,uint256,uint256,uint256,uint256,uint256)`
- `LockerUpdated(address)`
- `OwnershipTransferred(address,address)`
- `ProtocolSplitterModeUpdated(bool)`
- `RecipientsUpdated(address,address)`
- `SharesUpdated(uint16,uint16,uint16)`

## State-changing functions

- `distribute(address,address,uint256,uint256,address)`
- `renounceOwnership()`
- `setFeeConfig(address,address,uint16,uint16,uint16)`
- `setLocker(address)`
- `transferOwnership(address)`

## View functions

- `DEFAULT_BURNER_SHARE_BPS()`
- `DEFAULT_CTO_SHARE_BPS()`
- `DEFAULT_PROTOCOL_SHARE_BPS()`
- `MAX_BPS()`
- `burnerRecipient()`
- `burnerShareBps()`
- `ctoShareBps()`
- `locker()`
- `owner()`
- `protocolRecipient()`
- `protocolRecipientIsSplitter()`
- `protocolShareBps()`
