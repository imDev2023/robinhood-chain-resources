# UniswapV3Factory - 0x1f7d7550b1b028f7571e69a784071f0205fd2efa

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x1f7d7550b1b028f7571e69a784071f0205fd2efa
Role: UniswapV3Factory.
Contract name: UniswapV3Factory.
Verified: True.
Compiler: v0.7.6+commit.7338295f, EVM istanbul, optimizer True runs 800.
Main file: src/pkgs/v3-core/contracts/UniswapV3Factory.sol.
Source files written: 33 under `sources/`.
Creator: 0x9701fb0aDe1E269c8f64Ec0C7b3cfADB31A13A52.
Creation tx: 0x8add72fbcad4bf7732336de35dcd06b582c1501d0832c4710a30850a7cff8977.
Proxy type: None; implementations: [].

The chain's Uniswap V3 factory. Noxa creates the pool here directly; there is no bonding curve.

## Constructor arguments

None decoded.

## Events

- `FeeAmountEnabled(uint24,int24)`
- `OwnerChanged(address,address)`
- `PoolCreated(address,address,uint24,int24,address)`

## State-changing functions

- `createPool(address,address,uint24)`
- `enableFeeAmount(uint24,int24)`
- `setOwner(address)`

## View functions

- `feeAmountTickSpacing(uint24)`
- `getPool(address,address,uint24)`
- `owner()`
- `parameters()`
