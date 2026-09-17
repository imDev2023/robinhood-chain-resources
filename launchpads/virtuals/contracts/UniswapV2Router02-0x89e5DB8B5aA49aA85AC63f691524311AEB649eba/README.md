# UniswapV2Router02 - 0x89e5DB8B5aA49aA85AC63f691524311AEB649eba

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x89e5DB8B5aA49aA85AC63f691524311AEB649eba
Role: UniswapV2Router02.
Contract name: UniswapV2Router02.
Verified: True (verified at 2026-05-22T18:41:42.045461Z).
Compiler: v0.6.6+commit.6c089d02, EVM istanbul, optimizer True runs 999999.
Main file: src/pkgs/v2-periphery/contracts/UniswapV2Router02.sol.
Source files written: 10 under `sources/`.
Creator: 0x9701fb0aDe1E269c8f64Ec0C7b3cfADB31A13A52.
Creation tx: 0xd475f23df85f1a821abd8df540f6b2bdecde93593ff36310ddb393f314ce866c.
Proxy type: None; implementations: [].

Uniswap V2 router used by AgentTaxV2 to swap VIRTUAL tax into USDG (third-party).

## Constructor arguments

- `_factory` (address): `0x8bcEaA40B9AcdfAedF85AdF4FF01F5Ad6517937f`
- `_WETH` (address): `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`

## Events

None.

## State-changing functions

- `addLiquidity(address,address,uint256,uint256,uint256,uint256,address,uint256)`
- `addLiquidityETH(address,uint256,uint256,uint256,address,uint256)`
- `removeLiquidity(address,address,uint256,uint256,uint256,address,uint256)`
- `removeLiquidityETH(address,uint256,uint256,uint256,address,uint256)`
- `removeLiquidityETHSupportingFeeOnTransferTokens(address,uint256,uint256,uint256,address,uint256)`
- `removeLiquidityETHWithPermit(address,uint256,uint256,uint256,address,uint256,bool,uint8,bytes32,bytes32)`
- `removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(address,uint256,uint256,uint256,address,uint256,bool,uint8,bytes32,bytes32)`
- `removeLiquidityWithPermit(address,address,uint256,uint256,uint256,address,uint256,bool,uint8,bytes32,bytes32)`
- `swapETHForExactTokens(uint256,address[],address,uint256)`
- `swapExactETHForTokens(uint256,address[],address,uint256)`
- `swapExactETHForTokensSupportingFeeOnTransferTokens(uint256,address[],address,uint256)`
- `swapExactTokensForETH(uint256,uint256,address[],address,uint256)`
- `swapExactTokensForETHSupportingFeeOnTransferTokens(uint256,uint256,address[],address,uint256)`
- `swapExactTokensForTokens(uint256,uint256,address[],address,uint256)`
- `swapExactTokensForTokensSupportingFeeOnTransferTokens(uint256,uint256,address[],address,uint256)`
- `swapTokensForExactETH(uint256,uint256,address[],address,uint256)`
- `swapTokensForExactTokens(uint256,uint256,address[],address,uint256)`

## View functions

- `WETH()`
- `factory()`
- `getAmountIn(uint256,uint256,uint256)`
- `getAmountOut(uint256,uint256,uint256)`
- `getAmountsIn(uint256,address[])`
- `getAmountsOut(uint256,address[])`
- `quote(uint256,uint256,uint256)`
