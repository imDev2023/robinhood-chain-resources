# V1LaunchLocker

`0x736D76699C26D0d966744cAe304C000d471f7F35`

Group: pons v1.
Verified `PonsLaunchLocker`. The locker of the retired `0xA5aAb3F0…` factory.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | yes |
| Contract name | `PonsLaunchLocker` |
| Compiler | v0.8.30+commit.73712a01 |
| Optimizer | True, runs 300 |
| EVM version | cancun |
| License | none |
| Proxy type | none |
| Creator | `0xda4bCee76B29EFEc9697Fcf663601c2042043968` |
| Creation tx | `0xb12910e168a0f59e522798a042741fa20b0bf47e100e598ca19ce2d42f483c70` |

## Constructor arguments

- `initialOwner` (address) = `0xda4bCee76B29EFEc9697Fcf663601c2042043968`
- `initialProtocolFeeRecipient` (address) = `0xda4bCee76B29EFEc9697Fcf663601c2042043968`
- `initialProtocolFeeShare` (uint256) = `10`

## Functions that matter for launching

- `collectFees(address token)`
- `lockPosition(address token)`
- `setFeeCollector(address collector, bool enabled)`
- `setFeeRedirect(address token, address newFeeWallet)`
- `setProtocolFeeRecipient(address recipient)`
- `setProtocolFeeShare(uint256 share)`

## Reads that matter

- `MAX_PROTOCOL_FEE_SHARE()`
- `feeCollectors(address collector)`
- `feeRecipientTokenCount(address recipient_)`
- `feeRecipientTokens(address recipient, uint256 )`
- `feeRedirects(address token)`
- `getLaunchedToken(address token)`
- `protocolFeeRecipient()`
- `protocolFeeShare()`
- `tokenProtocolFeeShares(address token)`

## Events

- `FeeCollectorUpdated(address collector, bool enabled)`
- `FeeRedirectUpdated(address token, address newFeeWallet)`
- `FeesClaimed(address token, address caller, address token0, address token1, uint256 recipientAmount0, uint256 recipientAmount1, uint256 protocolAmount0, uint256 protocolAmount1)`
- `PositionLocked(address token, address deployer, uint256 dexId, address pairToken, uint256 positionId, address positionManager)`
- `ProtocolFeeRecipientUpdated(address recipient)`
- `ProtocolFeeUpdated(uint256 share)`

Full ABI in `abi.json`. Verified sources in `sources/`. Raw Blockscout response in `metadata.json`.
Counts: 10 state-changing functions, 15 views, 9 events, 14 custom errors.
