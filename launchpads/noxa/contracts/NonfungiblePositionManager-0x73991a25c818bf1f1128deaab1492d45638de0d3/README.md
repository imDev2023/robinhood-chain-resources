# NonfungiblePositionManager - 0x73991a25c818bf1f1128deaab1492d45638de0d3

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x73991a25c818bf1f1128deaab1492d45638de0d3
Role: NonfungiblePositionManager.
Contract name: NonfungiblePositionManager.
Verified: True.
Compiler: v0.7.6+commit.7338295f, EVM istanbul, optimizer True runs 2000.
Main file: src/pkgs/v3-periphery/contracts/NonfungiblePositionManager.sol.
Source files written: 55 under `sources/`.
Creator: 0x9701fb0aDe1E269c8f64Ec0C7b3cfADB31A13A52.
Creation tx: 0x9a8d07e70166be68c325939e2cece936f3ce5b16c580f49291f844d7cd718d4e.
Proxy type: None; implementations: [].

Mints the single-sided position that the locker then holds.

## Constructor arguments

- `_factory` (address): `0x1f7d7550B1b028f7571E69A784071F0205FD2EfA`
- `_WETH9` (address): `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`
- `_tokenDescriptor_` (address): `0x6F84dAE9c064ff453E5C8af51EfB819f8f610225`

## Events

- `Approval(address,address,uint256)`
- `ApprovalForAll(address,address,bool)`
- `Collect(uint256,address,uint256,uint256)`
- `DecreaseLiquidity(uint256,uint128,uint256,uint256)`
- `IncreaseLiquidity(uint256,uint128,uint256,uint256)`
- `Transfer(address,address,uint256)`

## State-changing functions

- `approve(address,uint256)`
- `burn(uint256)`
- `collect(tuple)`
- `createAndInitializePoolIfNecessary(address,address,uint24,uint160)`
- `decreaseLiquidity(tuple)`
- `increaseLiquidity(tuple)`
- `mint(tuple)`
- `multicall(bytes[])`
- `permit(address,uint256,uint256,uint8,bytes32,bytes32)`
- `refundETH()`
- `safeTransferFrom(address,address,uint256)`
- `safeTransferFrom(address,address,uint256,bytes)`
- `selfPermit(address,uint256,uint256,uint8,bytes32,bytes32)`
- `selfPermitAllowed(address,uint256,uint256,uint8,bytes32,bytes32)`
- `selfPermitAllowedIfNecessary(address,uint256,uint256,uint8,bytes32,bytes32)`
- `selfPermitIfNecessary(address,uint256,uint256,uint8,bytes32,bytes32)`
- `setApprovalForAll(address,bool)`
- `sweepToken(address,uint256,address)`
- `transferFrom(address,address,uint256)`
- `uniswapV3MintCallback(uint256,uint256,bytes)`
- `unwrapWETH9(uint256,address)`

## View functions

- `DOMAIN_SEPARATOR()`
- `PERMIT_TYPEHASH()`
- `WETH9()`
- `balanceOf(address)`
- `baseURI()`
- `factory()`
- `getApproved(uint256)`
- `isApprovedForAll(address,address)`
- `name()`
- `ownerOf(uint256)`
- `positions(uint256)`
- `supportsInterface(bytes4)`
- `symbol()`
- `tokenByIndex(uint256)`
- `tokenOfOwnerByIndex(address,uint256)`
- `tokenURI(uint256)`
- `totalSupply()`
