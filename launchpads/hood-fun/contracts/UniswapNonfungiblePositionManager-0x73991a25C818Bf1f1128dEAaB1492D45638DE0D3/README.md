# NonfungiblePositionManager - 0x73991a25C818Bf1f1128dEAaB1492D45638DE0D3

Role: UniswapNonfungiblePositionManager.
Address: `0x73991a25C818Bf1f1128dEAaB1492D45638DE0D3` on Robinhood Chain (chain id 4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x73991a25C818Bf1f1128dEAaB1492D45638DE0D3
Verified: True (fully verified: False, partially: True).
Compiler: v0.7.6+commit.7338295f, EVM istanbul, optimizer True runs 2000.
Language: solidity. License: none.
Proxy type: None. Implementations: [].
Main source file: `src/pkgs/v3-periphery/contracts/NonfungiblePositionManager.sol`. Source files written: 55 under `sources/`.
Raw constructor args: `0x0000000000000000000000001f7d7550b1b028f7571e69a784071f0205fd2efa0000000000000000000000000bd7d308f8e1639fab988df18a8011f41eacad730000000000000000000000006f84dae9c064ff453e5c8af51efb819f8f610225`.

Decoded constructor args:
- _factory (address): `0x1f7d7550B1b028f7571E69A784071F0205FD2EfA`
- _WETH9 (address): `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`
- _tokenDescriptor_ (address): `0x6F84dAE9c064ff453E5C8af51EfB819f8f610225`

## Functions

- `DOMAIN_SEPARATOR()` -> bytes32 [view]
- `PERMIT_TYPEHASH()` -> bytes32 [view]
- `WETH9()` -> address [view]
- `approve(address to, uint256 tokenId)` ->  [nonpayable]
- `balanceOf(address owner)` -> uint256 [view]
- `baseURI()` -> string [pure]
- `burn(uint256 tokenId)` ->  [payable]
- `collect(tuple params)` -> uint256, uint256 [payable]
- `createAndInitializePoolIfNecessary(address token0, address token1, uint24 fee, uint160 sqrtPriceX96)` -> address [payable]
- `decreaseLiquidity(tuple params)` -> uint256, uint256 [payable]
- `factory()` -> address [view]
- `getApproved(uint256 tokenId)` -> address [view]
- `increaseLiquidity(tuple params)` -> uint128, uint256, uint256 [payable]
- `isApprovedForAll(address owner, address operator)` -> bool [view]
- `mint(tuple params)` -> uint256, uint128, uint256, uint256 [payable]
- `multicall(bytes[] data)` -> bytes[] [payable]
- `name()` -> string [view]
- `ownerOf(uint256 tokenId)` -> address [view]
- `permit(address spender, uint256 tokenId, uint256 deadline, uint8 v, bytes32 r, bytes32 s)` ->  [payable]
- `positions(uint256 tokenId)` -> uint96, address, address, address, uint24, int24, int24, uint128, uint256, uint256, uint128, uint128 [view]
- `refundETH()` ->  [payable]
- `safeTransferFrom(address from, address to, uint256 tokenId)` ->  [nonpayable]
- `safeTransferFrom(address from, address to, uint256 tokenId, bytes _data)` ->  [nonpayable]
- `selfPermit(address token, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)` ->  [payable]
- `selfPermitAllowed(address token, uint256 nonce, uint256 expiry, uint8 v, bytes32 r, bytes32 s)` ->  [payable]
- `selfPermitAllowedIfNecessary(address token, uint256 nonce, uint256 expiry, uint8 v, bytes32 r, bytes32 s)` ->  [payable]
- `selfPermitIfNecessary(address token, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)` ->  [payable]
- `setApprovalForAll(address operator, bool approved)` ->  [nonpayable]
- `supportsInterface(bytes4 interfaceId)` -> bool [view]
- `sweepToken(address token, uint256 amountMinimum, address recipient)` ->  [payable]
- `symbol()` -> string [view]
- `tokenByIndex(uint256 index)` -> uint256 [view]
- `tokenOfOwnerByIndex(address owner, uint256 index)` -> uint256 [view]
- `tokenURI(uint256 tokenId)` -> string [view]
- `totalSupply()` -> uint256 [view]
- `transferFrom(address from, address to, uint256 tokenId)` ->  [nonpayable]
- `uniswapV3MintCallback(uint256 amount0Owed, uint256 amount1Owed, bytes data)` ->  [nonpayable]
- `unwrapWETH9(uint256 amountMinimum, address recipient)` ->  [payable]

## Events

- `Approval(address owner, address approved, uint256 tokenId)`
- `ApprovalForAll(address owner, address operator, bool approved)`
- `Collect(uint256 tokenId, address recipient, uint256 amount0, uint256 amount1)`
- `DecreaseLiquidity(uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1)`
- `IncreaseLiquidity(uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1)`
- `Transfer(address from, address to, uint256 tokenId)`

Launch-relevant items (create, launch, buy, sell, graduate, migrate, claim, lock, collect) are marked by name above.
See `metadata.json` for the full Blockscout smart-contracts response and `abi.json` for the ABI.
