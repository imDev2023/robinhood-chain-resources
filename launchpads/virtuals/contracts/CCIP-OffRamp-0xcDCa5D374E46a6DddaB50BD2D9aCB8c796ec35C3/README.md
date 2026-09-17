# CCIP-OffRamp - 0xcDCa5D374E46a6DddaB50BD2D9aCB8c796ec35C3

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xcDCa5D374E46a6DddaB50BD2D9aCB8c796ec35C3
Role: CCIP-OffRamp.
Contract name: OffRamp.
Verified: True (verified at 2026-05-22T21:43:52.842255Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM paris, optimizer True runs 800.
Main file: contracts/offRamp/OffRamp.sol.
Source files written: 25 under `sources/`.
Creator: 0x062f05CD6c835677B05a8658A351969476861316.
Creation tx: 0x4e1862a8bcff346c75fec1f5415598541925923f1cc125413b4c3c9ad736bba6.
Proxy type: None; implementations: [].

Chainlink CCIP off-ramp that executes inbound VIRTUAL mints. Third-party infrastructure.

## Constructor arguments

- `staticConfig` (tuple): `['6180753054346818345', '5000', '0xe8464c353210Cc398A45dB2454FBc5BCd25fFf20', '0x1912C3cFafE8A76A32a92861d815aC2837F237Ca', '0xc23071a8AE83671f37bdA1DaDBC745a9780f632A']`
- `dynamicConfig` (tuple): `['0x02A4D69cFfeC00Fbf7F3B60c93e3529Dfc58894d', '3600', '0x0000000000000000000000000000000000000000']`
- `sourceChainConfigs` (tuple[]): `[]`

## Events

- `AlreadyAttempted(uint64,uint64)`
- `CommitReportAccepted(tuple[],tuple[],tuple)`
- `ConfigSet(uint8,bytes32,address[],address[],uint8)`
- `DynamicConfigSet(tuple)`
- `ExecutionStateChanged(uint64,uint64,bytes32,bytes32,uint8,bytes,uint256)`
- `OwnershipTransferRequested(address,address)`
- `OwnershipTransferred(address,address)`
- `RootRemoved(bytes32)`
- `SkippedAlreadyExecutedMessage(uint64,uint64)`
- `SkippedReportExecution(uint64)`
- `SourceChainConfigSet(uint64,tuple)`
- `SourceChainSelectorAdded(uint64)`
- `StaticConfigSet(tuple)`
- `Transmitted(uint8,bytes32,uint64)`

## State-changing functions

- `acceptOwnership()`
- `applySourceChainConfigUpdates(tuple[])`
- `commit(bytes32[2],bytes,bytes32[],bytes32[],bytes32)`
- `execute(bytes32[2],bytes)`
- `executeSingleMessage(tuple,bytes[],uint32[])`
- `manuallyExecute(tuple[],tuple[][])`
- `setDynamicConfig(tuple)`
- `setOCR3Configs(tuple[])`
- `transferOwnership(address)`

## View functions

- `ccipReceive(tuple)`
- `getAllSourceChainConfigs()`
- `getDynamicConfig()`
- `getExecutionState(uint64,uint64)`
- `getLatestPriceSequenceNumber()`
- `getMerkleRoot(uint64,bytes32)`
- `getSourceChainConfig(uint64)`
- `getStaticConfig()`
- `latestConfigDetails(uint8)`
- `owner()`
- `typeAndVersion()`
