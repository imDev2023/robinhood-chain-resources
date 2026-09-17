# UniswapV4PoolManager

`0x8366a39CC670B4001A1121B8F6A443A643e40951`

Group: Uniswap.
Singleton v4 pool manager. Every graduated v2 pons pool lives here.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | yes |
| Contract name | `PoolManager` |
| Compiler | v0.8.26+commit.8a97fa7a |
| Optimizer | True, runs 44444444 |
| EVM version | cancun |
| License | none |
| Proxy type | none |
| Creator | `0x4e59b44847b379578588920cA78FbF26c0B4956C` |
| Creation tx | `0x4fb28d4935866f462582c6c931c6f2705e55f5be5eb178c7d8d9329a95c44c41` |

## Functions that matter for launching

- `burn(address from, uint256 id, uint256 amount)`
- `collectProtocolFees(address recipient, address currency, uint256 amount)`
- `setProtocolFee(tuple key, uint24 newProtocolFee)`
- `setProtocolFeeController(address controller)`
- `unlock(bytes data)`
- `updateDynamicLPFee(tuple key, uint24 newDynamicLPFee)`

## Reads that matter

- `protocolFeeController()`
- `protocolFeesAccrued(address currency)`

## Events

- `ProtocolFeeControllerUpdated(address protocolFeeController)`
- `ProtocolFeeUpdated(bytes32 id, uint24 protocolFee)`

Full ABI in `abi.json`. Verified sources in `sources/`. Raw Blockscout response in `metadata.json`.
Counts: 21 state-changing functions, 12 views, 10 events, 15 custom errors.
