# V2BondingCurve-Example-COPPERINU

`0x6a7a7F7cd83719f47f6fd15b580d24A9A8e6df2f`

Group: pons v2.
One curve per launch. Example instance; resolve the real one from the factory.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | yes |
| Contract name | `PonsV2BondingCurve` |
| Compiler | v0.8.35+commit.47b9dedd |
| Optimizer | True, runs 200 |
| EVM version | cancun |
| License | none |
| Proxy type | none |
| Creator | `0x3711ceA4feaDE896C913C68F01Eda97Cb06D1A42` |
| Creation tx | `0x376cad198a1dc19804f43a925bbf3ef512ef6438009a9255fed7f93a3efe4b68` |

## Constructor arguments

- `pairToken_` (address) = `0x0000000000000000000000000000000000000000`
- `deployer_` (address) = `0x844a5604dCE56d56E7144135A153c3a5F039d155`
- `factory_` (address) = `0x7eD598BcEf8bd9Edd8C97A195C6d13f40801EC7e`
- `feePolicy_` (contract IPonsV2FeePolicy) = `0xE5e702641Ea86F4ae6cC3cDaeD2B886f976Be044`
- `policy_` (struct FeePolicySnapshot) = `['0x263ed295dAFaE1d9AAdD6E56c4B6F9f38eE019Dd', '3000', '5000', '100', '300']`
- `feeEscrow_` (contract IPonsV2FeeEscrow) = `0xd3AFEB2a57f70eF218Aa82451c51B2fb0416Ac9e`
- `buybackVault_` (contract PonsV2BuybackVault) = `0x42df2a798f82289E177311362e8f5ccC45c1219c`
- `phantomQuote_` (uint256) = `1680000000000000000`
- `feeBps_` (uint256) = `100`
- `creatorTaxBps_` (uint256) = `400`
- `buybackEnabled_` (bool) = `false`
- `graduationThreshold_` (uint256) = `4200000000000000000`

## Functions that matter for launching

- `buy(uint256 quoteIn, uint256 minTokensOut, address recipient)` payable
- `exemptFromSnipeTax(address account)`
- `graduate(address recipient)`
- `rescueFees()`
- `sell(uint256 tokensIn, uint256 minQuoteOut, address recipient)`
- `setBuybackEnabled(bool enabled)`
- `setCreatorFeeRecipient(address newRecipient)`
- `sweepFees(uint256 minBuybackTokensOut)`

## Reads that matter

- `buybackBurnBps()`
- `buybackCreatorRecipient()`
- `buybackEnabled()`
- `buybackQuoteBalance()`
- `buybackVault()`
- `creatorTaxBalance()`
- `creatorTaxBps()`
- `currentSnipeTaxBps(address recipient)`
- `feeBps()`
- `feeEscrow()`
- `feePolicy()`
- `graduated()`
- `isNativeQuote()`
- `launchSupply()`
- `launchedAt()`
- `phantomQuote()`
- `protocolFeeRecipient()`
- `protocolFeeShareBps()`
- `quoteFeeBalance()`
- `quoteReserve()`
- `readyToGraduate()`
- `realQuoteReserve()`
- `sellableTokens()`
- `snipeTaxExempt(address account)`
- `snipeTaxSeconds()`
- `snipeTaxStartBps()`
- `trackedQuote()`

## Events

- `BuybackEnabledUpdated(bool enabled)`
- `BuybackLocked(uint256 quoteSpent, uint256 tokensLocked)`
- `CreatorFeeRecipientUpdated(address previousRecipient, address newRecipient)`
- `CurveBuy(address buyer, address recipient, uint256 quoteIn, uint256 tokensOut, uint256 fee, uint256 tax)`
- `CurveBuyRefunded(address buyer, uint256 refund)`
- `CurveSell(address seller, address recipient, uint256 tokensIn, uint256 quoteOut, uint256 fee, uint256 tax)`
- `FeesRescued(address protocolRecipient, address creatorRecipient, uint256 protocolAmount, uint256 creatorAmount)`
- `FeesSwept(uint256 protocolAmount, uint256 buybackAmount, uint256 creatorAmount)`
- `SnipeTaxCharged(address recipient, uint256 amount)`
- `SnipeTaxExempted(address account)`

Full ABI in `abi.json`. Verified sources in `sources/`. Raw Blockscout response in `metadata.json`.
Counts: 9 state-changing functions, 37 views, 13 events, 22 custom errors.
