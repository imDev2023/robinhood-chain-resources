# UniswapV3SwapRouter02

`0xCaf681a66D020601342297493863E78C959E5cb2`

Group: Uniswap.
Router the V1 token API reports for trading a graduated V1 token.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | yes |
| Contract name | `SwapRouter02` |
| Compiler | v0.7.6+commit.7338295f |
| Optimizer | True, runs 1000000 |
| EVM version | istanbul |
| License | none |
| Proxy type | none |
| Creator | `0x9701fb0aDe1E269c8f64Ec0C7b3cfADB31A13A52` |
| Creation tx | `0xeaa1bf6bd8e86ab33150936414780779800a2aa04a98667f4059ef5dfc0cdf92` |

## Constructor arguments

- `_factoryV2` (address) = `0x8bcEaA40B9AcdfAedF85AdF4FF01F5Ad6517937f`
- `factoryV3` (address) = `0x1f7d7550B1b028f7571E69A784071F0205FD2EfA`
- `_positionManager` (address) = `0x73991a25C818Bf1f1128dEAaB1492D45638DE0D3`
- `_WETH9` (address) = `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`

## Functions that matter for launching

- `sweepToken(address token, uint256 amountMinimum, address recipient)` payable
- `sweepToken(address token, uint256 amountMinimum)` payable
- `sweepTokenWithFee(address token, uint256 amountMinimum, uint256 feeBips, address feeRecipient)` payable
- `sweepTokenWithFee(address token, uint256 amountMinimum, address recipient, uint256 feeBips, address feeRecipient)` payable
- `unwrapWETH9WithFee(uint256 amountMinimum, address recipient, uint256 feeBips, address feeRecipient)` payable
- `unwrapWETH9WithFee(uint256 amountMinimum, uint256 feeBips, address feeRecipient)` payable

Full ABI in `abi.json`. Verified sources in `sources/`. Raw Blockscout response in `metadata.json`.
Counts: 33 state-changing functions, 6 views, 0 events, 0 custom errors.
