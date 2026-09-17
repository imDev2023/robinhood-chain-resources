# V2MemeHook

`0xE5e702641Ea86F4ae6cC3cDaeD2B886f976Be044`

Group: pons v2.
Singleton Uniswap v4 hook on every graduated pool. Holds the live fee policy.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | yes |
| Contract name | `V2MemeHook` |
| Compiler | v0.8.35+commit.47b9dedd |
| Optimizer | True, runs 200 |
| EVM version | cancun |
| License | none |
| Proxy type | none |
| Creator | `0x4e59b44847b379578588920cA78FbF26c0B4956C` |
| Creation tx | `0x220a9825bb32374540a6c7f3d6e7c769de64430c7f2155484ad0344d1c955d4b` |

## Constructor arguments

- `poolManager_` (contract IPoolManager) = `0x8366a39CC670B4001A1121B8F6A443A643e40951`
- `feeEscrow_` (contract IV2FeeEscrow) = `0xd3AFEB2a57f70eF218Aa82451c51B2fb0416Ac9e`
- `protocolFeeRecipient_` (address) = `0xFdDE5a1E3cDF791Da71E49F817D70C7ceD72CC36`
- `initialOwner_` (address) = `0xFdDE5a1E3cDF791Da71E49F817D70C7ceD72CC36`

## Functions that matter for launching

- `rescuePoolFees(bytes32 poolId)`
- `setBuybackBurnBps(uint256 bps)`
- `setBuybackEnabled(bytes32 poolId, bool enabled)`
- `setBuybackVault(address buybackVault_)`
- `setCreatorFeeRecipient(bytes32 poolId, address newRecipient)`
- `setFeeSweepOperator(address operator)`
- `setHookFeeBps(uint256 bps)`
- `setProtocolFeeRecipient(address recipient)`
- `setProtocolFeeShareBps(uint256 bps)`
- `sweepPoolFees(bytes32 poolId, uint256 minConversionQuoteOut, uint256 minBuybackTokensOut)`
- `unlockCallback(bytes data)`

## Reads that matter

- `buybackBurnBps()`
- `buybackVault()`
- `currentFeePolicy()`
- `feeEscrow()`
- `feeSweepOperator()`
- `hookFeeBps()`
- `launches(bytes32 )`
- `pendingBuyback(bytes32 , address currency)`
- `pendingCreatorTax(bytes32 , address currency)`
- `pendingFees(bytes32 , address currency)`
- `protocolFeeRecipient()`
- `protocolFeeShareBps()`

## Events

- `BuybackBurnBpsUpdated(uint256 bps)`
- `BuybackEnabledUpdated(bytes32 poolId, bool enabled)`
- `BuybackVaultSet(address vault)`
- `CreatorFeeRecipientUpdated(bytes32 poolId, address previousRecipient, address newRecipient)`
- `FeeSweepOperatorUpdated(address operator)`
- `HookFeeBpsUpdated(uint256 bps)`
- `HookFeeCollected(bytes32 poolId, address currency, uint256 feeAmount, uint256 taxAmount)`
- `PoolBuybackSkipped(bytes32 poolId, uint256 foldedBackQuote)`
- `PoolFeesRescued(bytes32 poolId, address quoteToken, uint256 protocolAmount, uint256 creatorAmount)`
- `PoolFeesSwept(bytes32 poolId, uint256 protocolAmount, uint256 buybackAmount, uint256 creatorAmount, uint256 tokensLocked)`
- `ProtocolFeeRecipientUpdated(address recipient)`
- `ProtocolFeeShareUpdated(uint256 bps)`

Full ABI in `abi.json`. Verified sources in `sources/`. Raw Blockscout response in `metadata.json`.
Counts: 26 state-changing functions, 19 views, 18 events, 22 custom errors.
