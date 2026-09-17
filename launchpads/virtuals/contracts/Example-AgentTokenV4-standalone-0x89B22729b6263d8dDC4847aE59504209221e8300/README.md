# Example-AgentTokenV4-standalone - 0x89B22729b6263d8dDC4847aE59504209221e8300

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x89B22729b6263d8dDC4847aE59504209221e8300
Role: Example-AgentTokenV4-standalone.
Contract name: AgentTokenV4.
Verified: True (verified at 2026-07-11T13:02:08.859117Z).
Compiler: v0.8.24+commit.e11b9ed9, EVM paris, optimizer True runs 200.
Main file: src/token/AgentTokenV4.sol.
Source files written: 18 under `sources/`.
Creator: 0x38bcCe51c4e346F02a5Cb4410355Fa70054A6e3b.
Creation tx: 0x8f7e5ed253144d57e5fc9694ed9f23c868c503a2549e2c28d4ad2ee23a881a96.
Proxy type: None; implementations: [].

A standalone (non-clone) AgentTokenV4 deployment by 0x38bcCe51..., not part of the Virtuals launch path; kept for reference because Blockscout search returns it.

## Constructor arguments

None decoded.

## Events

- `Approval(address,address,uint256)`
- `AutoSwapThresholdUpdated(uint256,uint256)`
- `ExternalCallError(uint256)`
- `InitialLiquidityAdded(uint256,uint256,uint256)`
- `Initialized(uint8)`
- `LiquidityPoolAdded(address)`
- `LiquidityPoolCreated(address)`
- `LiquidityPoolRemoved(address)`
- `OwnershipTransferStarted(address,address)`
- `OwnershipTransferred(address,address)`
- `ProjectTaxBasisPointsChanged(uint256,uint256,uint256,uint256)`
- `ProjectTaxRecipientUpdated(address)`
- `TaxAccountingAdapterUpdated(address)`
- `Transfer(address,address,uint256)`
- `ValidCallerAdded(bytes32)`
- `ValidCallerRemoved(bytes32)`

## State-changing functions

- `acceptOwnership()`
- `addBlacklistAddress(address)`
- `addInitialLiquidity(address)`
- `addLiquidityPool(address)`
- `addValidCaller(bytes32)`
- `approve(address,uint256)`
- `burn(uint256)`
- `burnFrom(address,uint256)`
- `decreaseAllowance(address,uint256)`
- `distributeTaxTokens()`
- `increaseAllowance(address,uint256)`
- `initialize(address[3],bytes,bytes,bytes,address)`
- `removeBlacklistAddress(address)`
- `removeLiquidityPool(address)`
- `removeValidCaller(bytes32)`
- `renounceOwnership()`
- `setProjectTaxRates(uint16,uint16)`
- `setProjectTaxRecipient(address)`
- `setSwapThresholdBasisPoints(uint16)`
- `setTaxAccountingAdapter(address)`
- `transfer(address,uint256)`
- `transferFrom(address,address,uint256)`
- `transferOwnership(address)`
- `withdrawERC20(address,uint256)`
- `withdrawETH(uint256)`

## View functions

- `allowance(address,address)`
- `balanceOf(address)`
- `blacklists(address)`
- `botProtectionDurationInSeconds()`
- `decimals()`
- `fundedDate()`
- `initialize(address[3],bytes,bytes,bytes)`
- `isLiquidityPool(address)`
- `isValidCaller(bytes32)`
- `liquidityPools()`
- `name()`
- `owner()`
- `pairToken()`
- `pendingOwner()`
- `projectBuyTaxBasisPoints()`
- `projectSellTaxBasisPoints()`
- `projectTaxPendingSwap()`
- `projectTaxRecipient()`
- `swapThresholdBasisPoints()`
- `symbol()`
- `taxAccountingAdapter()`
- `totalBuyTaxBasisPoints()`
- `totalSellTaxBasisPoints()`
- `totalSupply()`
- `uniswapV2Pair()`
- `validCallers()`
- `vault()`
