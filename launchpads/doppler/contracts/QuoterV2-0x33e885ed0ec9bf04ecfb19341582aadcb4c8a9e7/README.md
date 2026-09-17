# QuoterV2 - 0x33e885ed0ec9bf04ecfb19341582aadcb4c8a9e7

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x33e885ed0ec9bf04ecfb19341582aadcb4c8a9e7
Role: QuoterV2.
Contract name: QuoterV2.
Verified: True (verified at 2026-05-22T18:39:47.878812Z).
Compiler: v0.7.6+commit.7338295f, EVM istanbul, optimizer True runs 1000000.
Main file: src/pkgs/v3-periphery/contracts/lens/QuoterV2.sol.
Source files written: 21 under `sources/`.
Creator: 0x9701fb0aDe1E269c8f64Ec0C7b3cfADB31A13A52.
Creation tx: 0x62f593041cda98f3418898cfaae97617421de867c0d6fd4480f8a652ffe721b5.
Proxy type: None; implementations: [].

Uniswap v3 QuoterV2. Called by app.doppler.lol through its own RPC proxy for v3 quotes.

## Constructor arguments

- `_factory` (address): `0x1f7d7550B1b028f7571E69A784071F0205FD2EfA`
- `_WETH9` (address): `0x0Bd7D308f8E1639FAb988df18A8011f41EAcAD73`

## Events

None.

## State-changing functions

- `quoteExactInput(bytes,uint256)`
- `quoteExactInputSingle(tuple)`
- `quoteExactOutput(bytes,uint256)`
- `quoteExactOutputSingle(tuple)`

## View functions

- `WETH9()`
- `factory()`
- `uniswapV3SwapCallback(int256,int256,bytes)`
