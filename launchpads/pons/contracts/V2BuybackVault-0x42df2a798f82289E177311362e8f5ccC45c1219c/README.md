# V2BuybackVault

`0x42df2a798f82289E177311362e8f5ccC45c1219c`

Group: pons v2.
Holds bought-back supply on a five-year weighted linear vest.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | yes |
| Contract name | `V2BuybackVault` |
| Compiler | v0.8.35+commit.47b9dedd |
| Optimizer | True, runs 200 |
| EVM version | cancun |
| License | none |
| Proxy type | none |
| Creator | `0xFdDE5a1E3cDF791Da71E49F817D70C7ceD72CC36` |
| Creation tx | `0x4ceb1e809d55f76045dce2ccd2335e9317b291b07b4d5994aa8b7cdd027af142` |

## Constructor arguments

- `initialOwner` (address) = `0xFdDE5a1E3cDF791Da71E49F817D70C7ceD72CC36`
- `feePolicy_` (contract IV2FeePolicy) = `0xE5e702641Ea86F4ae6cC3cDaeD2B886f976Be044`
- `feeEscrow_` (contract IV2FeeEscrow) = `0xd3AFEB2a57f70eF218Aa82451c51B2fb0416Ac9e`

## Functions that matter for launching

- `lock(address token, uint256 amount, address creatorRecipient, address protocolRecipient, uint16 protocolFeeShareBps)`
- `release(address token)`
- `updateCreatorRecipient(address token, address newRecipient)`

## Reads that matter

- `VESTING_DURATION()`
- `feeEscrow()`
- `feePolicy()`
- `totalLocked(address token)`
- `totalReleased(address token)`
- `vestedAmount(address token)`
- `vestingStart(address token)`
- `vestingTerms(address token)`

## Events

- `CreatorRecipientUpdated(address token, address previousRecipient, address newRecipient)`
- `Locked(address token, address depositor, uint256 amount, uint256 newVestingStart)`
- `Released(address token, uint256 creatorAmount, uint256 protocolAmount)`
- `VestingTermsSnapshotted(address token, address creatorRecipient, address protocolRecipient, uint256 protocolFeeShareBps)`

Full ABI in `abi.json`. Verified sources in `sources/`. Raw Blockscout response in `metadata.json`.
Counts: 6 state-changing functions, 13 views, 7 events, 12 custom errors.
