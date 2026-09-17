# CashCatTokenV2-impl - 0xd6Da7f07eE822C8538C901217b37D1e7d86c76E5

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0xd6Da7f07eE822C8538C901217b37D1e7d86c76E5
Role: CashCatTokenV2-impl.
Contract name: CashCatTokenV2.
Verified: True (verified at 2026-08-06T00:54:45.944180Z).
Compiler: v0.8.28+commit.7893614a, EVM cancun, optimizer True runs 800.
Main file: src/v4/CashCatTokenV2.sol.
Source files on disk: 8 under `sources/`.
Creator: None.
Creation tx: None.
Proxy type: None; implementations: [].
External libraries: none.

## Context, not part of the HOOD10 Launchpad

The clone master behind the HOOD10 index token.
Ownerless and immutable after `initialize`, with a real `burn`, and `buyTaxRate()`/`sellTaxRate()`/`taxRatePips()` reading through to the pool hook rather than storing a rate.

## Constructor arguments

None decoded.

## Events

- `Approval(address,address,uint256)`
- `Initialized(uint64)`
- `Transfer(address,address,uint256)`

## State-changing functions

- `approve(address,uint256)`
- `burn(uint256)`
- `initialize(tuple)`
- `initializePool(bytes32,address)`
- `transfer(address,uint256)`
- `transferFrom(address,address,uint256)`

## View functions

- `GENERATION()`
- `PIPS_PER_BP()`
- `allowance(address,address)`
- `balanceOf(address)`
- `buyTaxRate()`
- `contractURI()`
- `decimals()`
- `deployer()`
- `description()`
- `factory()`
- `getTokenInfo()`
- `hook()`
- `launchBlock()`
- `logo()`
- `metaURI()`
- `name()`
- `poolId()`
- `sellTaxRate()`
- `socials()`
- `symbol()`
- `taxBps()`
- `taxRatePips()`
- `tokenURI()`
- `totalSupply()`
