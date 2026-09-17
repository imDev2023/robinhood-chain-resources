# AgentTokenV4-Impl - 0x581f7B996E6D3E436c537989157c9CB36421419b

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x581f7B996E6D3E436c537989157c9CB36421419b
Role: AgentTokenV4-Impl.
Contract name: AgentTokenV4.
Verified: True (verified at 2026-07-01T23:08:09.308171Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM paris, optimizer True runs 200.
Main file: contracts/virtualPersona/AgentTokenV4.sol.
Source files written: 24 under `sources/`.
Creator: 0xe4a0015B4c12f84bF9B8b9DB56b7ef0Bc539D88F.
Creation tx: 0x9d1449bbd76ccc4ae376bcced1d989778e5d55a1989f8a38c4b4079dac922580.
Proxy type: None; implementations: [].

Implementation cloned (EIP-1167) for every agent token. 1 percent buy and sell project tax, swap threshold, blacklist, vault.

## Constructor arguments

None decoded.

## Events

- `Approval(address,address,uint256)`
- `AutoSwapThresholdUpdated(uint256,uint256)`
- `ExternalCallError(uint256)`
- `InitialLiquidityAdded(uint256,uint256,uint256)`
- `Initialized(uint64)`
- `LimitsUpdated(uint256,uint256,uint256,uint256)`
- `LiquidityPoolAdded(address)`
- `LiquidityPoolCreated(address)`
- `LiquidityPoolRemoved(address)`
- `OwnershipTransferStarted(address,address)`
- `OwnershipTransferred(address,address)`
- `ProjectTaxBasisPointsChanged(uint256,uint256,uint256,uint256)`
- `ProjectTaxRecipientUpdated(address)`
- `RevenueAutoSwap()`
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
