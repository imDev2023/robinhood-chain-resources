# UniswapV3Factory - 0x1f7d7550B1b028f7571E69A784071F0205FD2EfA

Role: UniswapV3Factory.
Address: `0x1f7d7550B1b028f7571E69A784071F0205FD2EfA` on Robinhood Chain (chain id 4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x1f7d7550B1b028f7571E69A784071F0205FD2EfA
Verified: True (fully verified: False, partially: True).
Compiler: v0.7.6+commit.7338295f, EVM istanbul, optimizer True runs 800.
Language: solidity. License: none.
Proxy type: None. Implementations: [].
Main source file: `src/pkgs/v3-core/contracts/UniswapV3Factory.sol`. Source files written: 33 under `sources/`.
Raw constructor args: `None`.

## Functions

- `createPool(address tokenA, address tokenB, uint24 fee)` -> address [nonpayable]
- `enableFeeAmount(uint24 fee, int24 tickSpacing)` ->  [nonpayable]
- `feeAmountTickSpacing(uint24)` -> int24 [view]
- `getPool(address, address, uint24)` -> address [view]
- `owner()` -> address [view]
- `parameters()` -> address, address, address, uint24, int24 [view]
- `setOwner(address _owner)` ->  [nonpayable]

## Events

- `FeeAmountEnabled(uint24 fee, int24 tickSpacing)`
- `OwnerChanged(address oldOwner, address newOwner)`
- `PoolCreated(address token0, address token1, uint24 fee, int24 tickSpacing, address pool)`

Launch-relevant items (create, launch, buy, sell, graduate, migrate, claim, lock, collect) are marked by name above.
See `metadata.json` for the full Blockscout smart-contracts response and `abi.json` for the ABI.
