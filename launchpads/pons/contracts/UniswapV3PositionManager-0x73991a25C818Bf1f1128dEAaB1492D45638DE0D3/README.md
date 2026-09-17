# UniswapV3PositionManager

`0x73991a25C818Bf1f1128dEAaB1492D45638DE0D3`

Group: Uniswap.
Holds the V1 one-sided position NFT that the V1 locker keeps.

## Deployment

| field | value |
| --- | --- |
| Chain | Robinhood Chain, id 4663 |
| Verified on Blockscout | yes |
| Contract name | `NonfungiblePositionManager` |
| Compiler | v0.7.6+commit.7338295f |
| Optimizer | True, runs 2000 |
| EVM version | istanbul |
| License | none |
| Proxy type | none |
| Creator | `0x9701fb0aDe1E269c8f64Ec0C7b3cfADB31A13A52` |
| Creation tx | `0x9a8d07e70166be68c325939e2cece936f3ce5b16c580f49291f844d7cd718d4e` |

## Constructor arguments

- `_factory` (address) = `0x1f7d7550B1b028f7571E69A784071F0205FD2EfA`
- `_WETH9` (address) = `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`
- `_tokenDescriptor_` (address) = `0x6F84dAE9c064ff453E5C8af51EfB819f8f610225`

## Functions that matter for launching

- `burn(uint256 tokenId)` payable
- `createAndInitializePoolIfNecessary(address token0, address token1, uint24 fee, uint160 sqrtPriceX96)` payable
- `sweepToken(address token, uint256 amountMinimum, address recipient)` payable

## Events

- `Approval(address owner, address approved, uint256 tokenId)`
- `ApprovalForAll(address owner, address operator, bool approved)`
- `Collect(uint256 tokenId, address recipient, uint256 amount0, uint256 amount1)`
- `DecreaseLiquidity(uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1)`
- `IncreaseLiquidity(uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1)`
- `Transfer(address from, address to, uint256 tokenId)`

Full ABI in `abi.json`. Verified sources in `sources/`. Raw Blockscout response in `metadata.json`.
Counts: 21 state-changing functions, 17 views, 6 events, 0 custom errors.
