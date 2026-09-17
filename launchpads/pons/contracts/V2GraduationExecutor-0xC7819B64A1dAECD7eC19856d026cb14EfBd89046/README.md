# V2GraduationExecutor

`0xC7819B64A1dAECD7eC19856d026cb14EfBd89046`

Group: pons v2.
Mints the full-range v4 position straight into the locker.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | yes |
| Contract name | `V2GraduationExecutor` |
| Compiler | v0.8.35+commit.47b9dedd |
| Optimizer | True, runs 200 |
| EVM version | cancun |
| License | none |
| Proxy type | none |
| Creator | `0xFdDE5a1E3cDF791Da71E49F817D70C7ceD72CC36` |
| Creation tx | `0x21d0b8698b4e632fe43de1f3fce0b7c8f71740c53b880687348eb5aa2470dcf4` |

## Constructor arguments

- `positionManager_` (contract IPositionManager) = `0x58daec3116aae6D93017bAAea7749052E8a04fA7`
- `permit2_` (contract IAllowanceTransfer) = `0x000000000022D473030F116dDEE9F6B43aC78BA3`
- `locker_` (contract V2LaunchLocker) = `0x267444D099b10fB5Ed7c3Cc7B7c767AdcA574952`
- `factory_` (address) = `0x7eD598BcEf8bd9Edd8C97A195C6d13f40801EC7e`

## Functions that matter for launching

- `mintFullRangePosition(address launchToken, tuple key, int24 tickLower, int24 tickUpper, uint160 sqrtPriceX96, uint256 amount0Max, uint256 amount1Max, address currency0, address currency1, address protocolFeeRecipient)` payable

## Reads that matter

- `locker()`

## Events

- `GraduationDustRetained(address launchToken, address currency, uint256 amount)`
- `GraduationDustSwept(address launchToken, address currency, uint256 amount)`

Full ABI in `abi.json`. Verified sources in `sources/`. Raw Blockscout response in `metadata.json`.
Counts: 1 state-changing functions, 4 views, 2 events, 6 custom errors.
