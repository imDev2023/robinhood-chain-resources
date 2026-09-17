# V1LaunchLocker-Live-Implementation

`0xd4af1dfb098402182875e7f966c01eaac512bd22`

Group: pons v1.
Verified `PonsLaunchLocker`. Implementation behind the live V1 locker proxy.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | yes |
| Contract name | `PonsLaunchLocker` |
| Compiler | v0.8.35+commit.47b9dedd |
| Optimizer | True, runs 200 |
| EVM version | cancun |
| License | none |
| Proxy type | none |
| Creator | `0xda4bCee76B29EFEc9697Fcf663601c2042043968` |
| Creation tx | `0x2fd104cc82888d551cac45af272aa9bd834e596bf26117f10b60bd7b808f6720` |

## Functions that matter for launching

- `collectFees(address token)`
- `lockPosition(address token)`
- `setFeeCollector(address collector, bool enabled)`
- `setFeeRedirect(address token, address newFeeWallet)`
- `setProtocolFeeRecipient(address recipient)`
- `setProtocolFeeShare(uint256 share)`

## Reads that matter

- `MAX_PROTOCOL_FEE_SHARE()`
- `currentFeeRecipient(address token)`
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
Counts: 12 state-changing functions, 18 views, 11 events, 21 custom errors.
