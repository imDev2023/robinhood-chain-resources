# LaunchToken-sample-FLYWHEEL - 0x4E17C658b0ccFB5ba0168cf6FF43DA5Ced9afc07

Chain: Robinhood Chain (4663).
Blockscout: https://robinhoodchain.blockscout.com/address/0x4E17C658b0ccFB5ba0168cf6FF43DA5Ced9afc07
Role: LaunchToken-sample-FLYWHEEL.
Contract name: LaunchToken.
Verified: True (verified at 2026-08-29T18:47:53.242842Z).
Compiler: v0.8.26+commit.8a97fa7a, EVM cancun, optimizer True runs 800.
Main file: src/LaunchToken.sol.
Source files on disk: 20 under `sources/`.
Creator: 0x718633252AA8329495Df8BBa8fF7c9e8378CFC63.
Creation tx: 0x10bd2fba9290f45f4e28925a8217b7d27d6e88b02c30cdc0974315f39ea6e8e8.
Proxy type: None; implementations: [].
External libraries: none.

## What it is

One example of what `LaunchFactory` deploys: a plain fixed-supply ERC-20 with no mint, no owner and no transfer hook.
The tax lives in the pool hook, not in the token, and the token only reports it: `buyTaxRate()` and `sellTaxRate()` proxy through to `LaunchHook.currentFeeRate(poolId, ...)` so tax scanners read a live number.
Included because it is the shape every HOOD10 Launchpad coin has.

## Constructor arguments

None decoded.

## Events

- `Approval(address,address,uint256)`
- `EIP712DomainChanged()`
- `MetadataURIUpdated(string,string)`
- `Transfer(address,address,uint256)`

## State-changing functions

- `approve(address,uint256)`
- `burn(uint256)`
- `initializePool(bytes32)`
- `permit(address,address,uint256,uint256,uint8,bytes32,bytes32)`
- `setMetadataURI(string)`
- `transfer(address,uint256)`
- `transferFrom(address,address,uint256)`

## View functions

- `DOMAIN_SEPARATOR()`
- `MAX_METADATA_BYTES()`
- `PIPS_PER_BP()`
- `allowance(address,address)`
- `balanceOf(address)`
- `buyTaxRate()`
- `contractURI()`
- `creator()`
- `currentCreator()`
- `decimals()`
- `eip712Domain()`
- `factory()`
- `hook()`
- `launchBlock()`
- `metaURI()`
- `name()`
- `nonces(address)`
- `poolId()`
- `sellTaxRate()`
- `symbol()`
- `taxBps()`
- `taxRatePips()`
- `tokenURI()`
- `totalSupply()`
