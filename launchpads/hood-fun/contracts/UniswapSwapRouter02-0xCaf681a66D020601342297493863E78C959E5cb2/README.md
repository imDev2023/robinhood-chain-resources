# SwapRouter02 - 0xCaf681a66D020601342297493863E78C959E5cb2

Role: UniswapSwapRouter02.
Address: `0xCaf681a66D020601342297493863E78C959E5cb2` on Robinhood Chain (chain id 4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xCaf681a66D020601342297493863E78C959E5cb2
Verified: True (fully verified: False, partially: True).
Compiler: v0.7.6+commit.7338295f, EVM istanbul, optimizer True runs 1000000.
Language: solidity. License: none.
Proxy type: None. Implementations: [].
Main source file: `src/pkgs/swap-router-contracts/contracts/SwapRouter02.sol`. Source files written: 63 under `sources/`.
Raw constructor args: `0x0000000000000000000000008bceaa40b9acdfaedf85adf4ff01f5ad6517937f0000000000000000000000001f7d7550b1b028f7571e69a784071f0205fd2efa00000000000000000000000073991a25c818bf1f1128deaab1492d45638de0d30000000000000000000000000bd7d308f8e1639fab988df18a8011f41eacad73`.

Decoded constructor args:
- _factoryV2 (address): `0x8bcEaA40B9AcdfAedF85AdF4FF01F5Ad6517937f`
- factoryV3 (address): `0x1f7d7550B1b028f7571E69A784071F0205FD2EfA`
- _positionManager (address): `0x73991a25C818Bf1f1128dEAaB1492D45638DE0D3`
- _WETH9 (address): `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`

## Functions

- `WETH9()` -> address [view]
- `approveMax(address token)` ->  [payable]
- `approveMaxMinusOne(address token)` ->  [payable]
- `approveZeroThenMax(address token)` ->  [payable]
- `approveZeroThenMaxMinusOne(address token)` ->  [payable]
- `callPositionManager(bytes data)` -> bytes [payable]
- `checkOracleSlippage(bytes[] paths, uint128[] amounts, uint24 maximumTickDivergence, uint32 secondsAgo)` ->  [view]
- `checkOracleSlippage(bytes path, uint24 maximumTickDivergence, uint32 secondsAgo)` ->  [view]
- `exactInput(tuple params)` -> uint256 [payable]
- `exactInputSingle(tuple params)` -> uint256 [payable]
- `exactOutput(tuple params)` -> uint256 [payable]
- `exactOutputSingle(tuple params)` -> uint256 [payable]
- `factory()` -> address [view]
- `factoryV2()` -> address [view]
- `getApprovalType(address token, uint256 amount)` -> uint8 [nonpayable]
- `increaseLiquidity(tuple params)` -> bytes [payable]
- `mint(tuple params)` -> bytes [payable]
- `multicall(bytes32 previousBlockhash, bytes[] data)` -> bytes[] [payable]
- `multicall(uint256 deadline, bytes[] data)` -> bytes[] [payable]
- `multicall(bytes[] data)` -> bytes[] [payable]
- `positionManager()` -> address [view]
- `pull(address token, uint256 value)` ->  [payable]
- `refundETH()` ->  [payable]
- `selfPermit(address token, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)` ->  [payable]
- `selfPermitAllowed(address token, uint256 nonce, uint256 expiry, uint8 v, bytes32 r, bytes32 s)` ->  [payable]
- `selfPermitAllowedIfNecessary(address token, uint256 nonce, uint256 expiry, uint8 v, bytes32 r, bytes32 s)` ->  [payable]
- `selfPermitIfNecessary(address token, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)` ->  [payable]
- `swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] path, address to)` -> uint256 [payable]
- `swapTokensForExactTokens(uint256 amountOut, uint256 amountInMax, address[] path, address to)` -> uint256 [payable]
- `sweepToken(address token, uint256 amountMinimum, address recipient)` ->  [payable]
- `sweepToken(address token, uint256 amountMinimum)` ->  [payable]
- `sweepTokenWithFee(address token, uint256 amountMinimum, uint256 feeBips, address feeRecipient)` ->  [payable]
- `sweepTokenWithFee(address token, uint256 amountMinimum, address recipient, uint256 feeBips, address feeRecipient)` ->  [payable]
- `uniswapV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes _data)` ->  [nonpayable]
- `unwrapWETH9(uint256 amountMinimum, address recipient)` ->  [payable]
- `unwrapWETH9(uint256 amountMinimum)` ->  [payable]
- `unwrapWETH9WithFee(uint256 amountMinimum, address recipient, uint256 feeBips, address feeRecipient)` ->  [payable]
- `unwrapWETH9WithFee(uint256 amountMinimum, uint256 feeBips, address feeRecipient)` ->  [payable]
- `wrapETH(uint256 value)` ->  [payable]

## Events


Launch-relevant items (create, launch, buy, sell, graduate, migrate, claim, lock, collect) are marked by name above.
See `metadata.json` for the full Blockscout smart-contracts response and `abi.json` for the ABI.
