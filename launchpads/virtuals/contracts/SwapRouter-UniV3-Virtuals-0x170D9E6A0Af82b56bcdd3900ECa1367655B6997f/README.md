# SwapRouter-UniV3-Virtuals - 0x170D9E6A0Af82b56bcdd3900ECa1367655B6997f

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x170D9E6A0Af82b56bcdd3900ECa1367655B6997f
Role: SwapRouter-UniV3-Virtuals.
Contract name: SwapRouter.
Verified: True (verified at 2026-07-08T17:49:25.329052Z).
Compiler: v0.7.6+commit.7338295f, EVM istanbul, optimizer True runs 1000000.
Main file: contracts/SwapRouter.sol.
Source files written: 115 under `sources/`.
Creator: 0xe4a0015B4c12f84bF9B8b9DB56b7ef0Bc539D88F.
Creation tx: 0x86d5b003a8c1253b9502cc46d329a7e660e76bb43f6dc3e6ac7052232657a0c8.
Proxy type: None; implementations: [].

Uniswap V3 SwapRouter deployed by the Virtuals deployer on 2026-06-30, used for the deployer's own VIRTUAL/USDG swaps.

## Constructor arguments

- `_factory` (address): `0x1f7d7550B1b028f7571E69A784071F0205FD2EfA`
- `_WETH9` (address): `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`

## Events

None.

## State-changing functions

- `exactInput(tuple)`
- `exactInputSingle(tuple)`
- `exactOutput(tuple)`
- `exactOutputSingle(tuple)`
- `multicall(bytes[])`
- `refundETH()`
- `selfPermit(address,uint256,uint256,uint8,bytes32,bytes32)`
- `selfPermitAllowed(address,uint256,uint256,uint8,bytes32,bytes32)`
- `selfPermitAllowedIfNecessary(address,uint256,uint256,uint8,bytes32,bytes32)`
- `selfPermitIfNecessary(address,uint256,uint256,uint8,bytes32,bytes32)`
- `sweepToken(address,uint256,address)`
- `sweepTokenWithFee(address,uint256,address,uint256,address)`
- `uniswapV3SwapCallback(int256,int256,bytes)`
- `unwrapWETH9(uint256,address)`
- `unwrapWETH9WithFee(uint256,address,uint256,address)`

## View functions

- `WETH9()`
- `factory()`
