# SwapRouter02 - 0xcaf681a66d020601342297493863e78c959e5cb2

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xcaf681a66d020601342297493863e78c959e5cb2
Role: SwapRouter02.
Contract name: SwapRouter02.
Verified: True.
Compiler: v0.7.6+commit.7338295f, EVM istanbul, optimizer True runs 1000000.
Main file: src/pkgs/swap-router-contracts/contracts/SwapRouter02.sol.
Source files written: 63 under `sources/`.
Creator: 0x9701fb0aDe1E269c8f64Ec0C7b3cfADB31A13A52.
Creation tx: 0xeaa1bf6bd8e86ab33150936414780779800a2aa04a98667f4059ef5dfc0cdf92.
Proxy type: None; implementations: [].

Used inside the launch call to execute the creator's optional first buy, and by the locker to convert fees.

## Constructor arguments

- `_factoryV2` (address): `0x8bcEaA40B9AcdfAedF85AdF4FF01F5Ad6517937f`
- `factoryV3` (address): `0x1f7d7550B1b028f7571E69A784071F0205FD2EfA`
- `_positionManager` (address): `0x73991a25C818Bf1f1128dEAaB1492D45638DE0D3`
- `_WETH9` (address): `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`

## Events

None (ABI not available).

## State-changing functions

- `approveMax(address)`
- `approveMaxMinusOne(address)`
- `approveZeroThenMax(address)`
- `approveZeroThenMaxMinusOne(address)`
- `callPositionManager(bytes)`
- `exactInput(tuple)`
- `exactInputSingle(tuple)`
- `exactOutput(tuple)`
- `exactOutputSingle(tuple)`
- `getApprovalType(address,uint256)`
- `increaseLiquidity(tuple)`
- `mint(tuple)`
- `multicall(bytes32,bytes[])`
- `multicall(bytes[])`
- `multicall(uint256,bytes[])`
- `pull(address,uint256)`
- `refundETH()`
- `selfPermit(address,uint256,uint256,uint8,bytes32,bytes32)`
- `selfPermitAllowed(address,uint256,uint256,uint8,bytes32,bytes32)`
- `selfPermitAllowedIfNecessary(address,uint256,uint256,uint8,bytes32,bytes32)`
- `selfPermitIfNecessary(address,uint256,uint256,uint8,bytes32,bytes32)`
- `swapExactTokensForTokens(uint256,uint256,address[],address)`
- `swapTokensForExactTokens(uint256,uint256,address[],address)`
- `sweepToken(address,uint256)`
- `sweepToken(address,uint256,address)`
- `sweepTokenWithFee(address,uint256,address,uint256,address)`
- `sweepTokenWithFee(address,uint256,uint256,address)`
- `uniswapV3SwapCallback(int256,int256,bytes)`
- `unwrapWETH9(uint256)`
- `unwrapWETH9(uint256,address)`
- `unwrapWETH9WithFee(uint256,address,uint256,address)`
- `unwrapWETH9WithFee(uint256,uint256,address)`
- `wrapETH(uint256)`

## View functions

- `WETH9()`
- `checkOracleSlippage(bytes,uint24,uint32)`
- `checkOracleSlippage(bytes[],uint128[],uint24,uint32)`
- `factory()`
- `factoryV2()`
- `positionManager()`
