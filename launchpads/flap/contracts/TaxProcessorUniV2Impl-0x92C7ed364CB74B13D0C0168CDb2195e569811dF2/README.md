# TaxProcessorUniV2Impl-0x92C7ed364CB74B13D0C0168CDb2195e569811dF2

**TaxProcessor implementation, verified**

- Address: `0x92C7ed364CB74B13D0C0168CDb2195e569811dF2`
- Contract name on Blockscout: `TaxProcessorUniV2`
- Verified: yes
- Proxy type: `none`
- Creator: `0x8187F13ed6C7C9554AfE4Dd4C4D4960174846063`
- Creation tx: `0x5a4284db8b09e15805acd12a535a04ac791da13aa6ea9525657b75f17f2a6641`
- Compiler: `v0.8.26+commit.8a97fa7a`, optimizer on (99999 runs), EVM `cancun`
- License: `none`
- Explorer: <https://robinhoodchain.blockscout.com/address/0x92C7ed364CB74B13D0C0168CDb2195e569811dF2>

`TaxProcessorBase._processFeeQuote` is the exact split:

```solidity
uint256 fee = (quoteAmount * config.feeRate) / 10000;
uint256 commission = (quoteAmount * config.commissionBps) / 10000;
uint256 remaining = quoteAmount - fee - commission;
// market / deflation / lp / dividend are taken as bps of `remaining`
if (distributed < remaining) { fee += remaining - distributed; }
```

The last line matters: **any part of the tax the creator does not allocate is added to Flap's fee bucket**, not returned to the trader or the creator.
The app validates that the four buckets total 100%, but nothing on chain requires it.

## Constructor arguments

- `weth_` (`address`): `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`
- `flapBlackHole_` (`address`): `0x000000000000000000000000000000000000dEaD`
- `portal_` (`address`): `0x26605f322f7fF986f381bB9A6e3f5DAb0bEaEb09`
- `swapRegistry_` (`address`): `0x35Bae0b77753a586f68f9C4CD0E8d1a468169031`
- `adminImpl_` (`address`): `0x99aD173883A9f7eB12374d0102d37bFD80E3Fc04`

## Functions that matter for launching

- `ADMIN_IMPL()` returns `(address)`  [view]
- `commissionQuoteBalance()` returns `(uint256)`  [view]
- `deferredTaxTokenBalance()` returns `(uint256)`  [view]
- `dividendAddress()` returns `(address)`  [view]
- `dividendQuoteBalance()` returns `(uint256)`  [view]
- `dividendToken()` returns `(address)`  [view]
- `dividendTokenBalance()` returns `(uint256)`  [view]
- `feeConfig()` returns `(tuple)`  [view]
- `feeConfigV2()` returns `(tuple)`  [view]
- `feeConfigV3()` returns `(tuple)`  [view]
- `feeQuoteBalance()` returns `(uint256)`  [view]
- `feeReceiver()` returns `(address)`  [view]
- `getQuoteToken()` returns `(address)`  [view]
- `initialize(tuple)`  [nonpayable]
- `liqSmoothingGapQuote()` returns `(uint256)`  [view]
- `lpQuoteBalance()` returns `(uint256)`  [view]
- `marketQuoteBalance()` returns `(uint256)`  [view]
- `maxBuyBackGasLimit()` returns `(uint256)`  [view]
- `minBuyBackQuote()` returns `(uint256)`  [view]
- `owner()` returns `(address)`  [view]
- `pendingDividendQuoteTokenBalance()` returns `(uint256)`  [view]
- `processBondingCurveTax(uint256)`  [nonpayable]
- `processTaxTokens(uint256)` returns `(int8)`  [nonpayable]
- `quoteToken()` returns `(address)`  [view]
- `registerV4LPFeeSource(uint8,address,address,uint256,uint256)`  [pure]
- `renounceOwnership()`  [nonpayable]
- `setDividendToken(address)`  [nonpayable]
- `setFeeRate(uint16)`  [nonpayable]
- `setLiqSmoothingGapQuote(uint256)`  [nonpayable]
- `setMaxBuyBackGasLimit(uint256)`  [nonpayable]
- `setMinBuyBackQuote(uint256)`  [nonpayable]
- `setTaxConfig(uint16,uint16,uint16,uint16,uint16)`  [nonpayable]
- `swapRegistry()` returns `(address)`  [view]
- `taxToken()` returns `(address)`  [view]
- `totalDividendTokenSent()` returns `(uint256)`  [view]
- `totalQuoteAddedToLiquidity()` returns `(uint256)`  [view]
- `totalQuoteSentToDividend()` returns `(uint256)`  [view]
- `totalQuoteSentToMarketing()` returns `(uint256)`  [view]
- `transferOwnership(address)`  [nonpayable]
- `v4LPFeeSource()` returns `(uint8,address,address,uint256,uint256)`  [view]

## Events

- `FlapDispatchCheckCooldownUpdated(uint256,uint256)`
- `FlapDispatchQuoteUnavailable(address,address,uint256,uint256)`
- `FlapDispatchReady(address,address,uint256,uint256,uint256)`
- `FlapDispatchThresholdUpdated(uint256,uint256)`
- `FlapNativeReceiveForwardFailed(address,address,uint256)`
- `FlapNativeReceiveForwarded(address,address,uint256)`
- `FlapNativeReceiveForwardingUpdated(address,address,bool,bool)`
- `FlapTaxProcessorBondingCurveTax(address,uint256)`
- `FlapTaxProcessorBurnExecuted(address,uint256,uint256)`
- `FlapTaxProcessorBuyBackSkipped(address,uint256,uint256,string)`
- `FlapTaxProcessorCommissionConfigUpdated(address,uint16)`
- `FlapTaxProcessorCommissionPaid(address,uint256)`
- `FlapTaxProcessorConverterUpdated(address,address)`
- `FlapTaxProcessorDispatchExecuted(address,uint256,uint256,uint256)`
- `FlapTaxProcessorDividendConverted(address,uint256,uint256)`
- `FlapTaxProcessorDividendDepositSkipped(address,uint256,string)`
- `FlapTaxProcessorFeeRateUpdated(uint16,uint16)`
- `FlapTaxProcessorLiqSmoothingGapQuoteUpdated(uint256,uint256)`
- `FlapTaxProcessorMEVProtectionRequired(address,address)`
- `FlapTaxProcessorMaxBuyBackGasLimitUpdated(uint256,uint256)`
- `FlapTaxProcessorMinBuyBackQuoteUpdated(uint256,uint256)`
- `FlapTaxProcessorPortalRefund(address,uint256,bool)`
- `FlapTaxProcessorProcessTaxTokens(address,uint256)`
- `FlapTaxProcessorQuoteReconciled(address,uint256)`
- `FlapTaxProcessorTokensBurned(address,uint256)`
- `FlapTaxProcessorTokensParked(address,uint256)`
- `FlapTaxProcessorTokensReconciled(address,uint256)`
- `FlapTaxProcessorWalletConfigSet(address,uint16,address,uint16,address,uint16,address,uint16)`
- `FlapTaxProcessorWalletDistributed(address,uint16,uint256)`
- `FlapV4FeeCollectFailed(address,bytes)`
- `Initialized(uint8)`
- `OwnershipTransferred(address,address)`
- `TokensReconciled(address,uint256)`

## Files in this directory

- `abi.json`
- `address.json`
- `metadata.json`
- `methods-read.json`
- `sources`/
