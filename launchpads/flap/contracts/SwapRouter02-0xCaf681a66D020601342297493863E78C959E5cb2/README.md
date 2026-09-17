# SwapRouter02-0xCaf681a66D020601342297493863E78C959E5cb2

**Uniswap SwapRouter02, verified**

- Address: `0xCaf681a66D020601342297493863E78C959E5cb2`
- Contract name on Blockscout: `SwapRouter02`
- Verified: yes
- Proxy type: `none`
- Creator: `0x9701fb0aDe1E269c8f64Ec0C7b3cfADB31A13A52`
- Creation tx: `0xeaa1bf6bd8e86ab33150936414780779800a2aa04a98667f4059ef5dfc0cdf92`
- Compiler: `v0.7.6+commit.7338295f`, optimizer on (1000000 runs), EVM `istanbul`
- License: `none`
- Explorer: <https://robinhoodchain.blockscout.com/address/0xCaf681a66D020601342297493863E78C959E5cb2>

The router the TaxProcessor calls when it converts collected tax into the dividend or quote asset.
Not a Flap contract; it is chain infrastructure.

## Constructor arguments

- `_factoryV2` (`address`): `0x8bcEaA40B9AcdfAedF85AdF4FF01F5Ad6517937f`
- `factoryV3` (`address`): `0x1f7d7550B1b028f7571E69A784071F0205FD2EfA`
- `_positionManager` (`address`): `0x73991a25C818Bf1f1128dEAaB1492D45638DE0D3`
- `_WETH9` (`address`): `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`

## Functions that matter for launching

- `swapExactTokensForTokens(uint256,uint256,address[],address)` returns `(uint256)`  [payable]
- `swapTokensForExactTokens(uint256,uint256,address[],address)` returns `(uint256)`  [payable]
- `sweepTokenWithFee(address,uint256,uint256,address)`  [payable]
- `sweepTokenWithFee(address,uint256,address,uint256,address)`  [payable]
- `uniswapV3SwapCallback(int256,int256,bytes)`  [nonpayable]
- `unwrapWETH9WithFee(uint256,address,uint256,address)`  [payable]
- `unwrapWETH9WithFee(uint256,uint256,address)`  [payable]

## Files in this directory

- `abi.json`
- `address.json`
- `metadata.json`
- `selectors-decoded.txt`
- `selectors-openchain.json`
- `selectors.txt`
- `sources`/
